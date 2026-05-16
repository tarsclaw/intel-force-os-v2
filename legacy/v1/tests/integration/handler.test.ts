/**
 * Integration tests for the bot message handler.
 * Mocks the KV, D1, Claude agent, JWT auth, and Teams API boundaries.
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { Env } from '../../src/index';
import type { BotActivity } from '../../src/bot/types';
import type { AgentResponse } from '../../src/agents/types';

// ─── Module mocks (hoisted by Vitest) ────────────────────────────────────────

vi.mock('../../src/bot/auth', () => ({
  verifyBotToken: vi.fn(),
  getBotToken: vi.fn().mockResolvedValue('mock-token'),
}));

vi.mock('../../src/agents/claude', () => ({
  callClaudeAgent: vi.fn(),
}));

const sentMessages: Array<{ conversationId: string; type: 'card' | 'text'; content: unknown }> = [];

vi.mock('../../src/bot/teams-api', () => ({
  sendCard: vi.fn(),
  sendText: vi.fn(),
  extractConversationRef: vi.fn(),
  stripMention: vi.fn(),
}));

// Import after mocks are declared (Vitest hoists vi.mock calls)
import { handleBotMessage } from '../../src/bot/handler';
import { verifyBotToken } from '../../src/bot/auth';
import { callClaudeAgent } from '../../src/agents/claude';
import { sendCard, sendText, extractConversationRef, stripMention } from '../../src/bot/teams-api';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const ROUTINE_RESPONSE: AgentResponse = {
  draft_reply: 'You can carry over up to 5 days of holiday per year.',
  sensitivity_score: 0.1,
  sensitivity_category: null,
  confidence: 0.92,
  handbook_citations: [{ snippet: 'Holiday carry-over', page: 23, source: 'Handbook', url: null }],
  escalation_recommended: false,
  reasoning: 'Simple policy question.',
};

const ESCALATION_RESPONSE: AgentResponse = {
  draft_reply: 'Thank you for reaching out. Your HR Lead will be in touch shortly.',
  sensitivity_score: 0.95,
  sensitivity_category: 'grievance',
  confidence: 0.9,
  handbook_citations: [],
  escalation_recommended: true,
  reasoning: 'Grievance — escalate.',
};

const TENANT_STORE: Record<string, string> = {
  'tenant_config:test-tenant': JSON.stringify({
    tenantId: 'test-tenant',
    customerName: 'Test Co',
    customerDomain: 'test.com',
    handbookKvKey: 'handbook_text:test-tenant',
    hrLeadAadId: 'hr-lead-aad-id',
    hrLeadEmail: 'hr@test.com',
    approvalMode: 'all',
    sensitivityThreshold: 0.7,
    channels: [],
    escalationChannels: {},
    companyTone: 'Professional',
    weeklyReportEnabled: true,
    weeklyReportTime: 'monday_09:00_BST',
    auditRetentionDays: 2555,
    piiRedactionEnabled: true,
    subscriptionTier: 'founding',
    subscriptionStatus: 'active',
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    version: 1,
  }),
  'handbook_text:test-tenant': 'Holiday carry-over: up to 5 days per year.',
  'hr_lead_conversation:test-tenant:hr-lead-aad-id': JSON.stringify({
    serviceUrl: 'https://smba.trafficmanager.net/uk/',
    conversationId: '19:hr-lead-dm@thread.v2',
    tenantId: 'test-tenant',
    botId: 'bot-id',
    userId: 'hr-lead-aad-id',
  }),
};

let auditRowId = 0;

function makeEnv(): Env {
  return {
    TENANT_CONFIG: {
      get: vi.fn().mockImplementation((key: string) =>
        Promise.resolve(TENANT_STORE[key] ?? null),
      ),
      put: vi.fn().mockResolvedValue(undefined),
      list: vi.fn().mockResolvedValue({ keys: [] }),
      delete: vi.fn().mockResolvedValue(undefined),
      getWithMetadata: vi.fn(),
    } as unknown as KVNamespace,

    AUDIT_DB: {
      prepare: vi.fn().mockReturnValue({
        bind: vi.fn().mockReturnThis(),
        run: vi.fn().mockImplementation(() => {
          auditRowId++;
          return Promise.resolve({ meta: { last_row_id: auditRowId, changes: 1 } });
        }),
        first: vi.fn().mockResolvedValue(null),
        all: vi.fn().mockResolvedValue({ results: [] }),
      }),
      exec: vi.fn(),
      batch: vi.fn(),
      dump: vi.fn(),
    } as unknown as D1Database,

    MICROSOFT_APP_ID: 'test-app-id',
    MICROSOFT_APP_PASSWORD: 'test-app-password',
    ANTHROPIC_API_KEY: 'test-key',
    ANTHROPIC_MODEL: 'claude-sonnet-4-6',
    ENVIRONMENT: 'test',
    SENTRY_DSN: undefined,
  };
}

function makeActivity(overrides: Partial<BotActivity> = {}): BotActivity {
  return {
    type: 'message',
    id: 'test-activity-id',
    timestamp: '2026-04-24T14:23:00Z',
    serviceUrl: 'https://smba.trafficmanager.net/uk/',
    channelId: 'msteams',
    from: { id: 'aad-employee', name: 'Sarah Chen', aadObjectId: 'aad-employee' },
    conversation: {
      id: '19:channel@thread.v2',
      tenantId: 'test-tenant',
      conversationType: 'channel',
    },
    recipient: { id: 'test-app-id', name: 'Intel Force OS' },
    channelData: {
      tenant: { id: 'test-tenant' },
      channel: { id: '19:channel@thread.v2', name: '#hr' },
    },
    text: "What's the holiday carry-over policy?",
    ...overrides,
  };
}

function makeRequest(activity: BotActivity): Request {
  return new Request('https://bot.intelforce.ai/api/messages', {
    method: 'POST',
    headers: {
      Authorization: 'Bearer test-jwt',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(activity),
  });
}

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('handleBotMessage', () => {
  let env: Env;

  beforeEach(() => {
    env = makeEnv();
    sentMessages.length = 0;

    vi.mocked(verifyBotToken).mockResolvedValue({ valid: true });
    vi.mocked(callClaudeAgent).mockResolvedValue(ROUTINE_RESPONSE);

    vi.mocked(sendCard).mockImplementation((_svc, convId, card) => {
      sentMessages.push({ conversationId: String(convId), type: 'card', content: card });
      return Promise.resolve();
    });

    vi.mocked(sendText).mockImplementation((_svc, convId, text) => {
      sentMessages.push({ conversationId: String(convId), type: 'text', content: text });
      return Promise.resolve();
    });

    vi.mocked(extractConversationRef).mockReturnValue({
      serviceUrl: 'https://smba.trafficmanager.net/uk/',
      conversationId: '19:hr-lead-dm@thread.v2',
      tenantId: 'test-tenant',
      botId: 'bot-id',
      userId: 'hr-lead-aad-id',
    });

    vi.mocked(stripMention).mockImplementation((text: string) =>
      text.replace(/<at>[^<]*<\/at>/gi, '').trim(),
    );
  });

  it('returns 200 for a valid message', async () => {
    const response = await handleBotMessage(makeRequest(makeActivity()), env);
    expect(response.status).toBe(200);
  });

  it('returns 401 when JWT is invalid', async () => {
    vi.mocked(verifyBotToken).mockResolvedValue({ valid: false, error: 'Expired' });
    const response = await handleBotMessage(makeRequest(makeActivity()), env);
    expect(response.status).toBe(401);
  });

  it('sends approval card to HR Lead for low-sensitivity query', async () => {
    await handleBotMessage(makeRequest(makeActivity()), env);

    const hrCards = sentMessages.filter(
      (m) => m.type === 'card' && m.conversationId === '19:hr-lead-dm@thread.v2',
    );
    expect(hrCards.length).toBeGreaterThan(0);

    const cardJson = JSON.stringify(hrCards[0]?.content);
    expect(cardJson).toContain('approve');
    expect(cardJson).toContain('✓ Approve');
  });

  it('does NOT reply to employee before HR Lead approves', async () => {
    await handleBotMessage(makeRequest(makeActivity()), env);

    const employeeMsgs = sentMessages.filter(
      (m) => m.conversationId === '19:channel@thread.v2',
    );
    expect(employeeMsgs).toHaveLength(0);
  });

  it('sends holding reply immediately for high-sensitivity query', async () => {
    vi.mocked(callClaudeAgent).mockResolvedValue(ESCALATION_RESPONSE);

    await handleBotMessage(
      makeRequest(makeActivity({ text: 'I need to raise a formal complaint.' })),
      env,
    );

    // Employee gets the holding reply right away
    const employeeMsgs = sentMessages.filter(
      (m) => m.conversationId === '19:channel@thread.v2',
    );
    expect(employeeMsgs.length).toBeGreaterThan(0);

    // HR Lead gets escalation card
    const hrCards = sentMessages.filter(
      (m) => m.type === 'card' && m.conversationId === '19:hr-lead-dm@thread.v2',
    );
    expect(hrCards.length).toBeGreaterThan(0);
    const escalationJson = JSON.stringify(hrCards[0]?.content);
    expect(escalationJson).toContain('acknowledge');
    expect(escalationJson).toContain('Requires your attention');
  });

  it('sends welcome card on conversationUpdate when bot is added', async () => {
    const welcomeActivity: BotActivity = {
      ...makeActivity(),
      type: 'conversationUpdate',
      membersAdded: [{ id: 'test-app-id', name: 'Intel Force OS' }],
      from: { id: 'hr-lead-aad-id', name: 'HR Lead', aadObjectId: 'hr-lead-aad-id' },
      conversation: {
        id: '19:hr-lead-dm@thread.v2',
        tenantId: 'test-tenant',
        conversationType: 'personal',
      },
    };

    const response = await handleBotMessage(makeRequest(welcomeActivity), env);
    expect(response.status).toBe(200);

    const cards = sentMessages.filter((m) => m.type === 'card');
    expect(cards.length).toBeGreaterThan(0);
    // Handler uses first name only — "HR Lead" → "HR"
    expect(JSON.stringify(cards[0]?.content)).toContain("Hi HR");
  });

  it('replies to /help with text', async () => {
    await handleBotMessage(makeRequest(makeActivity({ text: '/help' })), env);

    const texts = sentMessages.filter((m) => m.type === 'text');
    expect(texts.length).toBeGreaterThan(0);
    expect(String(texts[0]?.content)).toContain('Intel Force OS');
  });

  it('returns 200 even when agent throws (Teams must always get 200)', async () => {
    vi.mocked(callClaudeAgent).mockRejectedValue(new Error('Anthropic down'));
    const response = await handleBotMessage(makeRequest(makeActivity()), env);
    expect(response.status).toBe(200);
  });

  it('returns 200 and sends nothing when tenantId is missing', async () => {
    const badActivity = makeActivity();
    badActivity.channelData = {};
    (badActivity.conversation as Record<string, unknown>)['tenantId'] = undefined;

    const response = await handleBotMessage(makeRequest(badActivity), env);
    expect(response.status).toBe(200);
    expect(sentMessages).toHaveLength(0);
  });
});
