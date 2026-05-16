import Anthropic from '@anthropic-ai/sdk';
import type { TenantConfig } from '../storage/config';
import { type AgentInput, type AgentResponse, ESCALATION_FALLBACK } from './types';
import { HR_AGENT_TOOLS } from './tools';
import { buildSystemPrompt } from './prompt';
import { executeTools } from './tool-executor';
import type { Env } from '../index';

const MAX_TOOL_ROUNDS = 5;
const MAX_TOKENS = 4096;
const TIMEOUT_MS = 25_000;

export async function callClaudeAgent(
  env: Env,
  config: TenantConfig,
  handbookText: string,
  input: AgentInput,
): Promise<AgentResponse> {
  const client = new Anthropic({ apiKey: env.ANTHROPIC_API_KEY });
  const model = config.anthropicModel ?? env.ANTHROPIC_MODEL;

  const systemPrompt = buildSystemPrompt(config, handbookText);

  const userMessage = formatUserMessage(input);
  const messages: Anthropic.MessageParam[] = [
    { role: 'user', content: userMessage },
  ];

  for (let round = 0; round < MAX_TOOL_ROUNDS; round++) {
    let response: Anthropic.Message;

    try {
      response = await Promise.race([
        client.messages.create({
          model,
          max_tokens: MAX_TOKENS,
          system: [
            {
              type: 'text',
              text: systemPrompt,
              // Prompt cache the system prompt (includes handbook) — 10% cost on cache hits
              cache_control: { type: 'ephemeral' },
            },
          ],
          tools: HR_AGENT_TOOLS,
          messages,
        }),
        timeout(TIMEOUT_MS),
      ]);
    } catch (err) {
      const reason = err instanceof Error ? err.message : 'unknown';
      console.error('anthropic_error', { tenantId: config.tenantId, round, reason });
      return ESCALATION_FALLBACK;
    }

    // Check for submit_draft_for_approval in this response
    const submitBlock = response.content.find(
      (b): b is Anthropic.ToolUseBlock =>
        b.type === 'tool_use' && b.name === 'submit_draft_for_approval',
    );

    if (submitBlock) {
      const parsed = parseSubmitDraft(submitBlock.input);
      if (parsed !== null) return parsed;
      // Parsing failed — escalate safely
      return ESCALATION_FALLBACK;
    }

    if (response.stop_reason !== 'tool_use') {
      // Model stopped without calling submit — shouldn't happen with a well-crafted prompt
      console.warn('agent_no_submit', { tenantId: config.tenantId, round, stopReason: response.stop_reason });
      return ESCALATION_FALLBACK;
    }

    // Execute all non-submit tool calls, continue the loop
    // Pass Breathe HR API key if the tenant has one configured
    // In production: resolve from Secrets Vault via config.breatheHrApiKeyRef
    // For now: look for BREATHE_HR_API_KEY_{tenantId} in env (set via wrangler secret)
    const breatheHrKey = (env as Env & Record<string, string | undefined>)[
      `BREATHE_HR_API_KEY_${config.tenantId.replace(/-/g, '_')}`
    ] ?? undefined;
    const toolResults = await executeTools(response.content, handbookText, breatheHrKey);
    messages.push(
      { role: 'assistant', content: response.content },
      { role: 'user', content: toolResults },
    );
  }

  // Exceeded max rounds without submitting a draft
  console.error('agent_max_rounds', { tenantId: config.tenantId });
  return ESCALATION_FALLBACK;
}

function formatUserMessage(input: AgentInput): string {
  return [
    `Employee: ${input.context.employee_name}`,
    `Channel: ${input.context.channel_name}`,
    `Time: ${input.context.timestamp}`,
    ``,
    `Message:`,
    input.message,
  ].join('\n');
}

function parseSubmitDraft(raw: unknown): AgentResponse | null {
  if (typeof raw !== 'object' || raw === null) return null;
  const input = raw as Record<string, unknown>;

  const draft_reply = String(input['draft_reply'] ?? '');
  const sensitivity_score = clamp(Number(input['sensitivity_score'] ?? 1.0), 0, 1);
  const confidence = clamp(Number(input['confidence'] ?? 0.0), 0, 1);
  const escalation_recommended = Boolean(input['escalation_recommended'] ?? true);

  if (!draft_reply) return null;

  const rawCategory = input['sensitivity_category'];
  const sensitivity_category = isValidCategory(rawCategory) ? rawCategory : null;

  const rawCitations = input['handbook_citations'];
  const handbook_citations = Array.isArray(rawCitations)
    ? rawCitations.map((c) => ({
        snippet: String((c as Record<string, unknown>)['snippet'] ?? ''),
        page: typeof (c as Record<string, unknown>)['page'] === 'number'
          ? ((c as Record<string, unknown>)['page'] as number)
          : null,
        source: typeof (c as Record<string, unknown>)['source'] === 'string'
          ? ((c as Record<string, unknown>)['source'] as string)
          : null,
        url: null,
      }))
    : [];

  // Enforce: if sensitivity >= 0.7 or confidence < 0.5, must escalate
  const mustEscalate = sensitivity_score >= 0.7 || confidence < 0.5;

  return {
    draft_reply,
    sensitivity_score,
    sensitivity_category,
    confidence,
    handbook_citations,
    escalation_recommended: mustEscalate || escalation_recommended,
    reasoning: String(input['reasoning'] ?? ''),
  };
}

function isValidCategory(v: unknown): v is AgentResponse['sensitivity_category'] {
  const valid = ['grievance', 'resignation', 'mental_health', 'harassment', 'health', 'low_confidence', 'system_unavailable', 'other'];
  return typeof v === 'string' && valid.includes(v);
}

function clamp(n: number, min: number, max: number): number {
  return Math.min(Math.max(n, min), max);
}

function timeout(ms: number): Promise<never> {
  return new Promise((_, reject) =>
    setTimeout(() => reject(new Error('anthropic_timeout')), ms),
  );
}

// Re-export for type inference
export type { AgentResponse };
