import { verifyBotToken } from './auth';
import { sendCard, sendText, extractConversationRef, stripMention } from './teams-api';
import {
  buildApprovalCard,
  buildEscalationCard,
  buildWelcomeCard,
  buildErrorCard,
} from '../cards';
import { buildStatusCard } from '../cards/status';
import { callClaudeAgent } from '../agents/claude';
import { getTenantConfig, getConversationRef, setConversationRef, getHandbookText } from '../storage/config';
import {
  logMessage,
  logApproval,
  getAuditRecord,
  getPendingApprovals,
} from '../storage/audit';
import { redactPII } from '../utils/redact';
import type { BotActivity, CardActionValue } from './types';
import type { Env } from '../index';

const HELP_TEXT = `**Intel Force OS — HR Agent**

Here's what I can do:

• **Automatic:** I watch your HR channels and draft a reply to every message. You approve, edit, or reject each one.
• \`/status\` — see what's waiting for your approval right now
• \`/report\` — get last week's summary on demand
• \`/help\` — this message

Questions? Contact support@intelforce.ai`;

export async function handleBotMessage(
  request: Request,
  env: Env,
): Promise<Response> {
  // 1. Verify JWT
  const auth = await verifyBotToken(request, env);
  if (!auth.valid) {
    console.warn('jwt_rejected', { error: auth.error });
    return new Response('Unauthorized', { status: 401 });
  }

  let activity: BotActivity;
  try {
    activity = await request.json() as BotActivity;
  } catch {
    return new Response('Bad request', { status: 400 });
  }

  // 2. Extract tenantId
  const tenantId =
    activity.channelData?.tenant?.id ?? activity.conversation.tenantId ?? '';

  if (!tenantId) {
    console.warn('missing_tenant_id', { activityId: activity.id });
    return ok();
  }

  console.log('activity_received', {
    tenantId,
    type: activity.type,
    hasValue: !!activity.value,
  });

  // 3. Route by activity type
  try {
    if (activity.type === 'conversationUpdate') {
      await handleConversationUpdate(activity, env, tenantId);
      return ok();
    }

    if (activity.type === 'message') {
      // Card actions come back as message activities with a value containing action
      const value = activity.value as CardActionValue | undefined;
      if (value?.action) {
        await handleCardAction(activity, env, tenantId, value);
        return ok();
      }
      await handleMessage(activity, env, tenantId);
      return ok();
    }

    // Ignore other activity types (typing, event, etc.)
    return ok();
  } catch (err) {
    console.error('handler_error', {
      tenantId,
      activityId: activity.id,
      error: err instanceof Error ? err.message : 'unknown',
    });
    return ok(); // Always 200 to Teams — let it retry
  }
}

async function handleConversationUpdate(
  activity: BotActivity,
  env: Env,
  tenantId: string,
): Promise<void> {
  const botWasAdded = activity.membersAdded?.some(
    (m) => m.id === activity.recipient.id,
  );
  if (!botWasAdded) return;

  // Store conversation reference for proactive messaging
  const ref = extractConversationRef(activity);
  const userAadId = activity.from.aadObjectId ?? activity.from.id;

  await setConversationRef(env.TENANT_CONFIG, tenantId, userAadId, ref);

  console.log('conversation_ref_stored', { tenantId, userAadId });

  // Send welcome card
  const config = await getTenantConfig(env.TENANT_CONFIG, tenantId);
  const firstName = activity.from.name?.split(' ')[0] ?? 'there';
  const card = buildWelcomeCard({ hrLeadFirstName: firstName });

  await sendCard(
    activity.serviceUrl,
    activity.conversation.id,
    card,
    env.MICROSOFT_APP_ID,
    env.MICROSOFT_APP_PASSWORD,
    activity.id,
  );

  // If this is the HR Lead opening 1:1 chat, update tenant config with convo ref
  if (config?.hrLeadAadId === userAadId) {
    console.log('hr_lead_convo_captured', { tenantId, userAadId });
  }
}

async function handleMessage(
  activity: BotActivity,
  env: Env,
  tenantId: string,
): Promise<void> {
  // 3. Load tenant config
  const config = await getTenantConfig(env.TENANT_CONFIG, tenantId);
  if (!config) {
    await sendText(
      activity.serviceUrl,
      activity.conversation.id,
      "Intel Force OS isn't configured for this workspace yet. Please contact your account manager at support@intelforce.ai.",
      env.MICROSOFT_APP_ID,
      env.MICROSOFT_APP_PASSWORD,
      activity.id,
    );
    return;
  }

  if (config.subscriptionStatus !== 'active') {
    await sendText(
      activity.serviceUrl,
      activity.conversation.id,
      'Intel Force OS is not currently active for your organisation. Please contact support@intelforce.ai.',
      env.MICROSOFT_APP_ID,
      env.MICROSOFT_APP_PASSWORD,
      activity.id,
    );
    return;
  }

  // 4. Strip @-mention and extract query
  const rawText = activity.text ?? '';
  const query = stripMention(rawText, activity.recipient.id).trim();

  if (!query) return;

  // 5. Slash commands
  if (query.startsWith('/help') || query === 'help') {
    await sendText(
      activity.serviceUrl,
      activity.conversation.id,
      HELP_TEXT,
      env.MICROSOFT_APP_ID,
      env.MICROSOFT_APP_PASSWORD,
      activity.id,
    );
    return;
  }

  if (query.startsWith('/status')) {
    const pending = await getPendingApprovals(env.AUDIT_DB, tenantId);
    const card = buildStatusCard({ count: pending.length, items: pending });
    await sendCard(
      activity.serviceUrl,
      activity.conversation.id,
      card,
      env.MICROSOFT_APP_ID,
      env.MICROSOFT_APP_PASSWORD,
      activity.id,
    );
    return;
  }

  if (query.startsWith('/report')) {
    // Proactive report handled separately; here just acknowledge
    await sendText(
      activity.serviceUrl,
      activity.conversation.id,
      'Your weekly report is being compiled. It will arrive in this chat shortly.',
      env.MICROSOFT_APP_ID,
      env.MICROSOFT_APP_PASSWORD,
      activity.id,
    );
    return;
  }

  // 6. Call the agent
  console.log('agent_call_start', { tenantId, queryLength: query.length });

  const handbookText = await getHandbookText(env.TENANT_CONFIG, tenantId);
  const agentResponse = await callClaudeAgent(env, config, handbookText, {
    message: redactPII(query),
    context: {
      employee_name: activity.from.name ?? 'Employee',
      employee_aad_id: activity.from.aadObjectId ?? activity.from.id,
      channel: activity.conversation.conversationType ?? 'channel',
      channel_name: activity.channelData?.channel?.name ?? '#hr',
      timestamp: activity.timestamp,
      company_name: config.customerName,
    },
  });

  console.log('agent_call_done', {
    tenantId,
    sensitivity: agentResponse.sensitivity_score,
    escalation: agentResponse.escalation_recommended,
    confidence: agentResponse.confidence,
  });

  // 7. Log to audit
  const auditId = await logMessage(env.AUDIT_DB, {
    tenantId,
    conversationId: activity.conversation.id,
    messageId: activity.id,
    ...(activity.from.aadObjectId ? { employeeAadId: activity.from.aadObjectId } : {}),
    originalQuery: query,
    draftReply: agentResponse.draft_reply,
    sensitivity: agentResponse.sensitivity_score,
    ...(agentResponse.sensitivity_category ? { sensitivityCategory: agentResponse.sensitivity_category } : {}),
    confidence: agentResponse.confidence,
    escalationRecommended: agentResponse.escalation_recommended,
    status: agentResponse.escalation_recommended ? 'escalated' : 'pending_approval',
  });

  // 8. Get HR Lead conversation ref for proactive card
  const hrLeadRef = await getConversationRef(
    env.TENANT_CONFIG,
    tenantId,
    config.hrLeadAadId,
  );

  const submittedAt = formatTime(activity.timestamp);

  if (agentResponse.escalation_recommended) {
    // Send holding reply immediately to employee
    await sendText(
      activity.serviceUrl,
      activity.conversation.id,
      agentResponse.draft_reply,
      env.MICROSOFT_APP_ID,
      env.MICROSOFT_APP_PASSWORD,
      activity.id,
    );

    // Send escalation card to HR Lead
    if (hrLeadRef) {
      const card = buildEscalationCard({
        employeeName: activity.from.name ?? 'Employee',
        channelName: activity.channelData?.channel?.name ?? '#hr',
        originalMessage: query,
        category: formatCategory(agentResponse.sensitivity_category),
        categoryEmoji: categoryEmoji(agentResponse.sensitivity_category),
        holdingReplySent: true,
        holdingReplyText: agentResponse.draft_reply,
        auditId: String(auditId),
        conversationId: activity.conversation.id,
        submittedAt,
      });

      await sendCard(
        hrLeadRef.serviceUrl,
        hrLeadRef.conversationId,
        card,
        env.MICROSOFT_APP_ID,
        env.MICROSOFT_APP_PASSWORD,
      );
    }
  } else {
    // Send approval card to HR Lead — employee gets nothing until approved
    if (hrLeadRef) {
      const card = buildApprovalCard({
        employeeName: activity.from.name ?? 'Employee',
        channelName: activity.channelData?.channel?.name ?? '#hr',
        originalMessage: query,
        draftReply: agentResponse.draft_reply,
        sensitivityLabel: sensitivityLabel(agentResponse.sensitivity_score),
        sensitivityColor: sensitivityColor(agentResponse.sensitivity_score),
        confidencePercent: Math.round(agentResponse.confidence * 100).toString(),
        citations: agentResponse.handbook_citations.map((c) => ({
          snippet: c.snippet,
          source: c.source ?? c.page?.toString() ?? 'Handbook',
        })),
        auditId: String(auditId),
        conversationId: activity.conversation.id,
        submittedAt,
      });

      await sendCard(
        hrLeadRef.serviceUrl,
        hrLeadRef.conversationId,
        card,
        env.MICROSOFT_APP_ID,
        env.MICROSOFT_APP_PASSWORD,
      );
    } else {
      // No conversation ref yet — HR Lead hasn't opened 1:1 chat with bot
      console.warn('no_hr_lead_convo_ref', { tenantId });
      // Fall back to replying in the channel with an error
      await sendCard(
        activity.serviceUrl,
        activity.conversation.id,
        buildErrorCard({
          errorTitle: 'Setup not complete',
          errorExplanation:
            'The HR Lead needs to open a 1:1 chat with Intel Force OS first so I can send approval cards.',
          whatNext:
            'Ask your HR Lead to open a chat with @Intel Force OS and send a message. After that, everything will work normally.',
          referenceId: `audit_${auditId}`,
        }),
        env.MICROSOFT_APP_ID,
        env.MICROSOFT_APP_PASSWORD,
        activity.id,
      );
    }
  }
}

async function handleCardAction(
  activity: BotActivity,
  env: Env,
  tenantId: string,
  value: CardActionValue,
): Promise<void> {
  const config = await getTenantConfig(env.TENANT_CONFIG, tenantId);
  if (!config) return;

  const auditId = Number(value.auditId);
  if (!auditId) {
    console.warn('card_action_missing_audit_id', { tenantId, value });
    return;
  }

  const record = await getAuditRecord(env.AUDIT_DB, auditId);
  if (!record) {
    console.warn('card_action_record_not_found', { tenantId, auditId });
    return;
  }

  const actorAadId = activity.from.aadObjectId ?? activity.from.id;

  switch (value.action) {
    case 'approve': {
      await postReplyToEmployee(
        activity,
        env,
        config.tenantId,
        record.conversationId,
        record.draftReply ?? '',
      );
      await logApproval(env.AUDIT_DB, auditId, 'approved', actorAadId);
      await sendText(
        activity.serviceUrl,
        activity.conversation.id,
        '✅ Sent.',
        env.MICROSOFT_APP_ID,
        env.MICROSOFT_APP_PASSWORD,
        activity.id,
      );
      break;
    }

    case 'edit': {
      const edited = value.editedReply?.trim() ?? '';
      if (!edited) {
        await sendText(
          activity.serviceUrl,
          activity.conversation.id,
          '⚠ No edited text received. Please try again.',
          env.MICROSOFT_APP_ID,
          env.MICROSOFT_APP_PASSWORD,
        );
        return;
      }
      await postReplyToEmployee(
        activity,
        env,
        config.tenantId,
        record.conversationId,
        edited,
      );
      await logApproval(env.AUDIT_DB, auditId, 'edited_and_approved', actorAadId, edited);
      await sendText(
        activity.serviceUrl,
        activity.conversation.id,
        '✅ Edited and sent.',
        env.MICROSOFT_APP_ID,
        env.MICROSOFT_APP_PASSWORD,
        activity.id,
      );
      break;
    }

    case 'reject': {
      await postReplyToEmployee(
        activity,
        env,
        config.tenantId,
        record.conversationId,
        "Thank you for your message. Your HR Lead will respond to you directly.",
      );
      await logApproval(env.AUDIT_DB, auditId, 'rejected', actorAadId);
      await sendText(
        activity.serviceUrl,
        activity.conversation.id,
        'Rejected. Holding message sent to employee.',
        env.MICROSOFT_APP_ID,
        env.MICROSOFT_APP_PASSWORD,
        activity.id,
      );
      break;
    }

    case 'acknowledge': {
      await logApproval(env.AUDIT_DB, auditId, 'acknowledged', actorAadId);
      await sendText(
        activity.serviceUrl,
        activity.conversation.id,
        "👁 Acknowledged. You're handling this one directly.",
        env.MICROSOFT_APP_ID,
        env.MICROSOFT_APP_PASSWORD,
        activity.id,
      );
      break;
    }

    case 'request_backup': {
      await logApproval(env.AUDIT_DB, auditId, 'acknowledged', actorAadId);
      // DM backup HR Lead if configured
      if (config.backupHrLeadAadId) {
        const backupRef = await getConversationRef(
          env.TENANT_CONFIG,
          tenantId,
          config.backupHrLeadAadId,
        );
        if (backupRef) {
          await sendText(
            backupRef.serviceUrl,
            backupRef.conversationId,
            `⚠️ Backup requested: ${activity.from.name} has flagged an escalation that needs a second pair of eyes. Check the Intel Force OS dashboard.`,
            env.MICROSOFT_APP_ID,
            env.MICROSOFT_APP_PASSWORD,
          );
        }
      }
      await sendText(
        activity.serviceUrl,
        activity.conversation.id,
        'Backup notified.',
        env.MICROSOFT_APP_ID,
        env.MICROSOFT_APP_PASSWORD,
        activity.id,
      );
      break;
    }

    default:
      console.warn('unknown_card_action', { tenantId, action: value.action });
  }
}

async function postReplyToEmployee(
  activity: BotActivity,
  env: Env,
  _tenantId: string,
  conversationId: string,
  text: string,
): Promise<void> {
  await sendText(
    activity.serviceUrl,
    conversationId,
    text,
    env.MICROSOFT_APP_ID,
    env.MICROSOFT_APP_PASSWORD,
  );
}

export async function handleWebApproval(
  request: Request,
  env: Env,
): Promise<Response> {
  const authHeader = request.headers.get('Authorization');
  if (!env.PORTAL_API_KEY || authHeader !== `Bearer ${env.PORTAL_API_KEY}`) {
    return new Response('Unauthorized', { status: 401 });
  }

  let body: {
    auditId: string;
    tenantId: string;
    action: string;
    editedReply?: string;
    actorId?: string;
  };
  try {
    body = await request.json() as typeof body;
  } catch {
    return new Response('Bad request', { status: 400 });
  }

  const { auditId, tenantId, action, editedReply } = body;
  const numericAuditId = Number(auditId);
  if (!numericAuditId || !tenantId || !action) {
    return jsonResponse({ error: 'Missing required fields' }, 400);
  }

  const [record, config] = await Promise.all([
    getAuditRecord(env.AUDIT_DB, numericAuditId),
    getTenantConfig(env.TENANT_CONFIG, tenantId),
  ]);

  if (!record) return jsonResponse({ error: 'Audit record not found' }, 404);
  if (!config) return jsonResponse({ error: 'Tenant not configured' }, 404);

  // Use HR Lead conversation ref to get service URL (same service URL for all conversations in that Teams tenant)
  const hrRef = await getConversationRef(env.TENANT_CONFIG, tenantId, config.hrLeadAadId);
  if (!hrRef) {
    return jsonResponse(
      { error: 'HR Lead has not yet opened a chat with the bot. Teams card approval is available.' },
      400,
    );
  }

  const actorId = body.actorId ?? 'web-portal';

  try {
    switch (action) {
      case 'approve': {
        const reply = editedReply?.trim() || record.draftReply || '';
        await sendText(
          hrRef.serviceUrl,
          record.conversationId,
          reply,
          env.MICROSOFT_APP_ID,
          env.MICROSOFT_APP_PASSWORD,
        );
        await logApproval(
          env.AUDIT_DB,
          numericAuditId,
          editedReply?.trim() ? 'edited_and_approved' : 'approved',
          actorId,
          editedReply?.trim(),
        );
        break;
      }

      case 'reject': {
        await sendText(
          hrRef.serviceUrl,
          record.conversationId,
          'Thank you for your message. Your HR Lead will respond to you directly.',
          env.MICROSOFT_APP_ID,
          env.MICROSOFT_APP_PASSWORD,
        );
        await logApproval(env.AUDIT_DB, numericAuditId, 'rejected', actorId);
        break;
      }

      case 'escalate': {
        await logApproval(env.AUDIT_DB, numericAuditId, 'escalated', actorId);
        await sendText(
          hrRef.serviceUrl,
          hrRef.conversationId,
          '⚠️ Escalation flagged from web portal — this query requires your direct attention.',
          env.MICROSOFT_APP_ID,
          env.MICROSOFT_APP_PASSWORD,
        );
        break;
      }

      default:
        return jsonResponse({ error: `Unknown action: ${action}` }, 400);
    }

    console.log('web_approval_processed', { tenantId, auditId, action });
    return jsonResponse({ success: true });
  } catch (err) {
    const msg = err instanceof Error ? err.message : 'unknown error';
    console.error('web_approval_error', { auditId, action, error: msg });
    return jsonResponse({ error: msg }, 500);
  }
}

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function ok(): Response {
  return new Response('OK', { status: 200 });
}

function formatTime(timestamp: string): string {
  try {
    return new Date(timestamp).toLocaleTimeString('en-GB', {
      hour: '2-digit',
      minute: '2-digit',
      timeZone: 'Europe/London',
    });
  } catch {
    return timestamp;
  }
}

function formatCategory(category: string | null): string {
  const map: Record<string, string> = {
    grievance: 'Grievance',
    resignation: 'Resignation intent',
    mental_health: 'Mental health',
    harassment: 'Harassment or bullying',
    health: 'Health or medical',
    low_confidence: 'Complex query',
    system_unavailable: 'System issue',
    other: 'Sensitive matter',
  };
  return category ? (map[category] ?? 'Sensitive matter') : 'Sensitive matter';
}

function categoryEmoji(category: string | null): string {
  const map: Record<string, string> = {
    grievance: '🤝',
    resignation: '🚪',
    mental_health: '💙',
    harassment: '🛡',
    health: '🏥',
    low_confidence: '❓',
    system_unavailable: '⚠️',
    other: '🔔',
  };
  return category ? (map[category] ?? '🔔') : '🔔';
}

function sensitivityLabel(score: number): string {
  if (score >= 0.7) return 'High';
  if (score >= 0.4) return 'Medium';
  return 'Low';
}

function sensitivityColor(score: number): string {
  if (score >= 0.7) return 'Attention';
  if (score >= 0.4) return 'Warning';
  return 'Good';
}
