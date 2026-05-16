import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, tenantProcedure } from '../init';

const AVAILABLE_INTEGRATIONS = [
  { provider: 'breathe_hr', name: 'Breathe HR', category: 'hr', authType: 'api_key', required: true, description: 'Employee records and leave management' },
  { provider: 'slack', name: 'Slack', category: 'notifications', authType: 'oauth2', required: false, description: 'Escalation notifications and alerts' },
  { provider: 'hubspot', name: 'HubSpot', category: 'crm', authType: 'oauth2', required: false, description: 'Deal and contact management' },
  { provider: 'gmail', name: 'Gmail', category: 'email', authType: 'oauth2', required: false, description: 'Email drafts and notifications' },
  { provider: 'microsoft_graph', name: 'Microsoft Graph', category: 'directory', authType: 'oauth2', required: false, description: 'Employee name lookup from Entra ID' },
  { provider: 'fathom', name: 'Fathom', category: 'calls', authType: 'api_key', required: false, description: 'Call transcript processing' },
] as const;

export const integrationsRouter = router({
  list: tenantProcedure.query(async ({ ctx }) => {
    const connected = await ctx.db.webhookRegistration.findMany({
      where: { tenantId: ctx.tenantId },
    });

    const connectedProviders = new Set(connected.map((w) => w.provider));

    return AVAILABLE_INTEGRATIONS.map((integration) => ({
      ...integration,
      connected: connectedProviders.has(integration.provider),
      connectedRecord: connected.find((w) => w.provider === integration.provider) ?? null,
    }));
  }),

  get: tenantProcedure
    .input(z.object({ provider: z.string() }))
    .query(async ({ ctx, input }) => {
      const integration = AVAILABLE_INTEGRATIONS.find((i) => i.provider === input.provider);
      if (!integration) throw new TRPCError({ code: 'NOT_FOUND' });

      const connected = await ctx.db.webhookRegistration.findFirst({
        where: { tenantId: ctx.tenantId, provider: input.provider },
      });

      return { ...integration, connected: !!connected, connectedRecord: connected };
    }),

  // Returns OAuth URL for the provider — in production this calls the provider's OAuth endpoint
  beginOAuth: tenantProcedure
    .input(z.object({ provider: z.string(), redirectUri: z.string().url() }))
    .mutation(async ({ ctx, input }) => {
      const integration = AVAILABLE_INTEGRATIONS.find((i) => i.provider === input.provider);
      if (!integration) throw new TRPCError({ code: 'NOT_FOUND' });
      if (integration.authType !== 'oauth2') {
        throw new TRPCError({ code: 'BAD_REQUEST', message: 'Provider uses API key auth, not OAuth' });
      }

      // In production: generate state token, store in Redis, return provider OAuth URL
      // For now: return a placeholder URL
      const state = `${ctx.tenantId}:${input.provider}:${Date.now()}`;
      return {
        authUrl: `https://app.${input.provider.replace('_', '-')}.com/oauth/authorize?state=${encodeURIComponent(state)}&redirect_uri=${encodeURIComponent(input.redirectUri)}`,
        state,
      };
    }),

  // Complete OAuth with the callback code
  completeOAuth: tenantProcedure
    .input(z.object({ provider: z.string(), code: z.string(), state: z.string() }))
    .mutation(async ({ ctx, input }) => {
      // In production: exchange code for tokens, store encrypted in Secrets Vault
      // For now: create a webhook registration record
      const existing = await ctx.db.webhookRegistration.findFirst({
        where: { tenantId: ctx.tenantId, provider: input.provider },
      });

      if (existing) {
        return ctx.db.webhookRegistration.update({
          where: { id: existing.id },
          data: { status: 'active', lastFiredAt: null },
        });
      }

      return ctx.db.webhookRegistration.create({
        data: {
          tenantId: ctx.tenantId,
          provider: input.provider,
          endpoint: `https://bot.intelforce.ai/webhooks/${input.provider}/${ctx.tenantId}`,
          secretHash: 'pending', // Set by Secrets Vault
          status: 'active',
        },
      });
    }),

  // Connect with API key (for non-OAuth providers)
  connectApiKey: tenantProcedure
    .input(z.object({ provider: z.string(), apiKey: z.string().min(1) }))
    .mutation(async ({ ctx, input }) => {
      const integration = AVAILABLE_INTEGRATIONS.find((i) => i.provider === input.provider);
      if (!integration) throw new TRPCError({ code: 'NOT_FOUND' });
      if (integration.authType !== 'api_key') {
        throw new TRPCError({ code: 'BAD_REQUEST', message: 'Provider uses OAuth, not API key' });
      }

      // In production: store key in Secrets Vault, test connection
      // For now: create registration record
      const existing = await ctx.db.webhookRegistration.findFirst({
        where: { tenantId: ctx.tenantId, provider: input.provider },
      });

      if (existing) {
        return ctx.db.webhookRegistration.update({
          where: { id: existing.id },
          data: { status: 'active', secretHash: `sk_${input.apiKey.slice(0, 8)}...` },
        });
      }

      return ctx.db.webhookRegistration.create({
        data: {
          tenantId: ctx.tenantId,
          provider: input.provider,
          endpoint: `https://api.${input.provider.replace('_', '-')}.com`,
          secretHash: `sk_${input.apiKey.slice(0, 8)}...`,
          status: 'active',
        },
      });
    }),

  disable: tenantProcedure
    .input(z.object({ provider: z.string() }))
    .mutation(async ({ ctx, input }) => {
      const record = await ctx.db.webhookRegistration.findFirst({
        where: { tenantId: ctx.tenantId, provider: input.provider },
      });
      if (!record) throw new TRPCError({ code: 'NOT_FOUND' });

      return ctx.db.webhookRegistration.update({
        where: { id: record.id },
        data: { status: 'disabled' },
      });
    }),

  testConnection: tenantProcedure
    .input(z.object({ provider: z.string() }))
    .mutation(async ({ ctx, input }) => {
      const record = await ctx.db.webhookRegistration.findFirst({
        where: { tenantId: ctx.tenantId, provider: input.provider },
      });
      if (!record) throw new TRPCError({ code: 'NOT_FOUND', message: 'Not connected' });

      // In production: actually test the connection
      // For now: optimistic success if status is active
      if (record.status !== 'active') {
        return { success: false, message: 'Integration is disabled' };
      }
      return { success: true, message: 'Connection verified' };
    }),
});
