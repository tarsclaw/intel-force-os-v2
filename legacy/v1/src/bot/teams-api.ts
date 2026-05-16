import { getBotToken } from './auth';
import type { BotActivity } from './types';

// Send an activity to Teams via the Bot Framework REST API
export async function sendActivity(
  serviceUrl: string,
  conversationId: string,
  activity: Record<string, unknown>,
  appId: string,
  appPassword: string,
  replyToId?: string,
): Promise<void> {
  const token = await getBotToken(appId, appPassword);
  const base = serviceUrl.replace(/\/$/, '');
  const path = replyToId
    ? `/v3/conversations/${encodeURIComponent(conversationId)}/activities/${encodeURIComponent(replyToId)}`
    : `/v3/conversations/${encodeURIComponent(conversationId)}/activities`;

  const resp = await fetch(`${base}${path}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ type: 'message', ...activity }),
  });

  if (!resp.ok) {
    const body = await resp.text().catch(() => '');
    throw new Error(`Teams API error ${resp.status}: ${body}`);
  }
}

// Send an Adaptive Card as an attachment
export async function sendCard(
  serviceUrl: string,
  conversationId: string,
  cardJson: object,
  appId: string,
  appPassword: string,
  replyToId?: string,
): Promise<void> {
  await sendActivity(
    serviceUrl,
    conversationId,
    {
      attachments: [
        {
          contentType: 'application/vnd.microsoft.card.adaptive',
          content: cardJson,
        },
      ],
    },
    appId,
    appPassword,
    replyToId,
  );
}

// Send a plain text message
export async function sendText(
  serviceUrl: string,
  conversationId: string,
  text: string,
  appId: string,
  appPassword: string,
  replyToId?: string,
): Promise<void> {
  await sendActivity(
    serviceUrl,
    conversationId,
    { text },
    appId,
    appPassword,
    replyToId,
  );
}

// Build a conversation reference from an incoming activity
export function extractConversationRef(activity: BotActivity) {
  return {
    serviceUrl: activity.serviceUrl,
    conversationId: activity.conversation.id,
    tenantId:
      activity.channelData?.tenant?.id ?? activity.conversation.tenantId ?? '',
    botId: activity.recipient.id,
    userId: activity.from.id,
  };
}

// Strip @mention from the bot out of a message
export function stripMention(text: string, botId: string): string {
  // Teams wraps @-mentions in <at>...</at> XML tags
  const stripped = text
    .replace(/<at>[^<]*<\/at>/gi, '')
    .replace(/<[^>]+>/g, '')
    .trim();
  // Also strip the plain @IntelForceOS pattern
  return stripped.replace(new RegExp(`@${botId}\\s*`, 'i'), '').trim();
}
