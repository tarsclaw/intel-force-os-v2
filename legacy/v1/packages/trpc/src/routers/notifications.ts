import { z } from 'zod';
import { router, tenantProcedure } from '../init';
import { NotificationSettingsSchema } from '@intelforce/schemas';

// Notification settings stored as JSON in tenant config (KV key: notification_settings:{tenantId})
// In v2: dedicated notifications_config table in Postgres

export const notificationsRouter = router({
  getSettings: tenantProcedure.query(async ({ ctx }) => {
    // Read from audit log metadata as the persistent store (v1 approach)
    // v2: dedicated Postgres table
    const record = await ctx.db.auditEvent.findFirst({
      where: { tenantId: ctx.tenantId, action: 'notifications.updated' },
      orderBy: { createdAt: 'desc' },
    });

    const defaults = {
      slackWebhookUrl: '',
      slackSeverities: ['HIGH', 'CRITICAL'] as string[],
      emailRecipients: [] as string[],
      emailDigest: 'instant' as const,
      mutedCodes: [] as string[],
    };

    if (!record?.metadata) return defaults;

    const meta = record.metadata as typeof defaults;
    return {
      slackWebhookUrl: meta.slackWebhookUrl ?? '',
      slackSeverities: meta.slackSeverities ?? ['HIGH', 'CRITICAL'],
      emailRecipients: meta.emailRecipients ?? [],
      emailDigest: meta.emailDigest ?? 'instant',
      mutedCodes: meta.mutedCodes ?? [],
    };
  }),

  saveSettings: tenantProcedure
    .input(NotificationSettingsSchema)
    .mutation(async ({ ctx, input }) => {
      // Validate Slack webhook URL if provided
      if (input.slackWebhookUrl) {
        if (!input.slackWebhookUrl.startsWith('https://hooks.slack.com/')) {
          return { success: false, error: 'Invalid Slack webhook URL' };
        }
      }

      await ctx.db.auditEvent.create({
        data: {
          tenantId: ctx.tenantId,
          actorId: ctx.userId,
          actorKind: 'USER',
          action: 'notifications.updated',
          severity: 'INFO',
          detail: 'Notification settings updated',
          metadata: input,
        },
      });

      return { success: true };
    }),

  testSlack: tenantProcedure
    .input(z.object({ webhookUrl: z.string().url() }))
    .mutation(async ({ input }) => {
      // In production: send a test message to the webhook URL
      // POST to webhookUrl with { text: 'Intel Force OS — test notification ✅' }
      try {
        const resp = await fetch(input.webhookUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            text: '🧪 Intel Force OS test notification — if you can see this, notifications are working.',
          }),
        });
        return { success: resp.ok, status: resp.status };
      } catch (err) {
        return { success: false, error: err instanceof Error ? err.message : 'Request failed' };
      }
    }),
});
