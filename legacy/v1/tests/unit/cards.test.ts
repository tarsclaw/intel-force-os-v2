import { describe, it, expect } from 'vitest';
import { buildApprovalCard } from '../../src/cards/approval';
import { buildEscalationCard } from '../../src/cards/escalation';
import { buildWeeklyReportCard } from '../../src/cards/report';
import { buildWelcomeCard } from '../../src/cards/welcome';
import { buildErrorCard } from '../../src/cards/error';

describe('Adaptive Cards', () => {
  it('approval card has correct structure', () => {
    const card = buildApprovalCard({
      employeeName: 'Sarah Chen',
      channelName: '#hr',
      originalMessage: "What's the holiday policy?",
      draftReply: 'Our holiday policy allows 25 days per year.',
      sensitivityLabel: 'Low',
      sensitivityColor: 'Good',
      confidencePercent: '92',
      citations: [{ snippet: 'Holiday entitlement', source: 'Handbook p.12' }],
      auditId: '42',
      conversationId: '19:abc@thread.v2',
      submittedAt: '14:23',
    }) as Record<string, unknown>;

    expect(card['type']).toBe('AdaptiveCard');
    expect(card['version']).toBe('1.5');
    const actions = card['actions'] as Array<Record<string, unknown>>;
    expect(actions).toHaveLength(3);
    const actionTypes = actions.map((a) => a['type']);
    expect(actionTypes).toContain('Action.Submit');
    expect(actionTypes).toContain('Action.ShowCard');
  });

  it('approval card approve action has correct data', () => {
    const card = buildApprovalCard({
      employeeName: 'Test',
      channelName: '#hr',
      originalMessage: 'Question',
      draftReply: 'Answer',
      sensitivityLabel: 'Low',
      sensitivityColor: 'Good',
      confidencePercent: '90',
      citations: [],
      auditId: '99',
      conversationId: 'conv-123',
      submittedAt: '09:00',
    }) as Record<string, unknown>;

    const actions = card['actions'] as Array<Record<string, unknown>>;
    const approveAction = actions.find((a) => a['title'] === '✓ Approve') as Record<string, unknown>;
    expect(approveAction).toBeDefined();
    const data = approveAction['data'] as Record<string, unknown>;
    expect(data['action']).toBe('approve');
    expect(data['auditId']).toBe('99');
  });

  it('escalation card has attention style', () => {
    const card = buildEscalationCard({
      employeeName: 'Sarah',
      channelName: '#hr',
      originalMessage: "I've been having issues with my manager",
      category: 'Grievance',
      categoryEmoji: '🤝',
      holdingReplySent: true,
      holdingReplyText: 'Thank you for reaching out...',
      auditId: '43',
      conversationId: '19:def@thread.v2',
      submittedAt: '15:00',
    }) as Record<string, unknown>;

    const body = card['body'] as Array<Record<string, unknown>>;
    const header = body[0] as Record<string, unknown>;
    expect(header['style']).toBe('attention');
  });

  it('weekly report card renders stat columns', () => {
    const card = buildWeeklyReportCard({
      customerName: 'Acme Ltd',
      weekStartDate: '6 May',
      weekEndDate: '12 May',
      messagesHandled: 47,
      approvedAsIs: 32,
      approvedAsIsPercent: 68,
      edited: 10,
      editedPercent: 21,
      rejected: 2,
      escalated: 3,
      avgConfidence: '4.7',
      topPatterns: [],
      thisWeekPriority: 'All steady.',
    }) as Record<string, unknown>;

    expect(card['type']).toBe('AdaptiveCard');
  });

  it('welcome card mentions HR Lead name', () => {
    const card = buildWelcomeCard({ hrLeadFirstName: 'Charlotte' }) as Record<string, unknown>;
    const json = JSON.stringify(card);
    expect(json).toContain('Charlotte');
  });

  it('error card includes reference ID', () => {
    const card = buildErrorCard({
      errorTitle: 'Something broke',
      errorExplanation: 'The AI backend is down.',
      whatNext: 'Maddox will fix it.',
      referenceId: 'err_xyz',
    }) as Record<string, unknown>;

    const json = JSON.stringify(card);
    expect(json).toContain('err_xyz');
  });
});
