import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, tenantProcedure, platformProcedure } from '../init';

// Secrets are NEVER returned as values — only refs and metadata
// Actual values live in the Secrets Vault service (AWS KMS)

interface SecretRef {
  ref: string;        // e.g. secrets://tnt_abc123/breathe_hr/api_key
  kind: string;       // api_key | oauth_access_token | oauth_refresh_token | webhook_secret
  provider: string;   // breathe_hr | slack | hubspot | ...
  label: string;      // human-readable name
  status: 'active' | 'expired' | 'rotation_pending' | 'revoked';
  lastRotatedAt: Date | null;
  nextRotationAt: Date | null;
  lastAccessedAt: Date | null;
  createdAt: Date;
}

function mockSecretRefs(tenantId: string): SecretRef[] {
  // In production these come from the Secrets Vault service
  // The vault returns refs + metadata, NEVER values
  void tenantId;
  return [];
}

export const secretsRouter = router({
  // List all secret refs for a tenant (never values)
  listRefs: tenantProcedure.query(async ({ ctx }) => {
    // Production: call Secrets Vault service: GET /v1/secrets/{tenantId}
    return mockSecretRefs(ctx.tenantId);
  }),

  // Initiate rotation — creates a new version while old one remains valid for 24h (dual-window)
  rotate: tenantProcedure
    .input(z.object({
      ref: z.string().startsWith('secrets://'),
      newValue: z.string().optional(), // If omitted: auto-rotate (provider generates new key)
    }))
    .mutation(async ({ ctx, input }) => {
      // Verify ref belongs to this tenant
      if (!input.ref.includes(ctx.tenantId.replace(/-/g, ''))) {
        throw new TRPCError({ code: 'FORBIDDEN', message: 'Secret does not belong to this tenant' });
      }

      // Production: POST /v1/secrets/{tenantId}/rotate — Secrets Vault handles dual-window
      // Log the rotation attempt
      await ctx.db.auditEvent.create({
        data: {
          tenantId: ctx.tenantId,
          actorId: ctx.userId,
          actorKind: 'USER',
          actorLabel: 'user',
          action: 'secret.rotate',
          targetKind: 'secret',
          targetId: input.ref,
          severity: 'WARN',
        },
      });

      return { success: true, message: 'Rotation initiated. Old credential remains valid for 24 hours.' };
    }),

  // Emergency rotation — immediately revokes old key, no dual-window
  // Requires step-up auth (2-person approval in production)
  rotateAllEmergency: tenantProcedure
    .input(z.object({ reason: z.string().min(10) }))
    .mutation(async ({ ctx, input }) => {
      await ctx.db.auditEvent.create({
        data: {
          tenantId: ctx.tenantId,
          actorId: ctx.userId,
          actorKind: 'USER',
          actorLabel: 'emergency_rotation',
          action: 'secret.rotate_all_emergency',
          detail: input.reason,
          severity: 'CRITICAL',
        },
      });

      // Production: POST /v1/secrets/{tenantId}/rotate-all-emergency
      return { success: true, affectedCount: 0, message: 'Emergency rotation complete. All integrations will need reauthorisation.' };
    }),

  // Revoke a specific secret
  revoke: tenantProcedure
    .input(z.object({ ref: z.string().startsWith('secrets://'), reason: z.string() }))
    .mutation(async ({ ctx, input }) => {
      await ctx.db.auditEvent.create({
        data: {
          tenantId: ctx.tenantId,
          actorId: ctx.userId,
          actorKind: 'USER',
          action: 'secret.revoke',
          targetId: input.ref,
          detail: input.reason,
          severity: 'WARN',
        },
      });

      return { success: true, message: 'Secret revoked.' };
    }),

  // Platform: view all secrets across all tenants (operator only)
  listGlobal: platformProcedure
    .input(z.object({ filter: z.enum(['expired', 'rotation_due', 'all']).default('all') }))
    .query(async () => {
      // Production: call Secrets Vault service global listing
      return { items: [] as SecretRef[], total: 0 };
    }),
});
