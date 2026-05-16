import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, tenantProcedure } from '../init';
import { ApiKeyCreateSchema } from '@intelforce/schemas';

// API keys are stored as hashed values in Postgres metadata
// The actual key value is returned ONCE on creation — never again
// Format: intel_live_{8-char-prefix}_{32-char-secret}

const MAX_KEYS_PER_TENANT = 5;

interface ApiKeyMeta {
  id: string;
  tenantId: string;
  name: string;
  prefix: string;
  scopes: string[];
  createdAt: string;
  lastUsedAt: string | null;
  createdById: string;
}

// In v1: store API key metadata in a KV-like structure via the audit log table
// In v2: dedicated api_keys table in Postgres
// For now we use a JSON blob stored as audit metadata under action 'api_key.created'

export const apiKeysRouter = router({
  list: tenantProcedure.query(async ({ ctx }) => {
    // Fetch API key metadata from audit log entries
    const records = await ctx.db.auditEvent.findMany({
      where: {
        tenantId: ctx.tenantId,
        action: 'api_key.created',
        // Exclude revoked keys
        NOT: {
          correlationId: {
            in: (
              await ctx.db.auditEvent.findMany({
                where: { tenantId: ctx.tenantId, action: 'api_key.revoked' },
                select: { correlationId: true },
              })
            )
              .map((r) => r.correlationId)
              .filter((id): id is string => id !== null),
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return records.map((r) => {
      const meta = r.metadata as ApiKeyMeta | null;
      return {
        id: r.id,
        name: meta?.name ?? 'Unknown',
        prefix: meta?.prefix ?? 'intel_live_???',
        scopes: meta?.scopes ?? [],
        createdAt: r.createdAt,
        lastUsedAt: null,
      };
    });
  }),

  create: tenantProcedure
    .input(ApiKeyCreateSchema)
    .mutation(async ({ ctx, input }) => {
      // Check limit
      const existing = await ctx.db.auditEvent.count({
        where: { tenantId: ctx.tenantId, action: 'api_key.created' },
      });
      if (existing >= MAX_KEYS_PER_TENANT) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: `Maximum ${MAX_KEYS_PER_TENANT} API keys per tenant`,
        });
      }

      // Generate key
      const prefix = generateRandomString(8);
      const secret = generateRandomString(32);
      const fullKey = `intel_live_${prefix}_${secret}`;

      // Store metadata (never the key value)
      const record = await ctx.db.auditEvent.create({
        data: {
          tenantId: ctx.tenantId,
          actorId: ctx.userId,
          actorKind: 'USER',
          action: 'api_key.created',
          targetKind: 'api_key',
          targetId: prefix,
          detail: input.name,
          severity: 'INFO',
          correlationId: `apikey_${prefix}`,
          metadata: {
            name: input.name,
            prefix: `intel_live_${prefix}`,
            scopes: input.scopes,
            createdById: ctx.userId,
          },
        },
      });

      // Return the FULL key — only time it will ever be shown
      return {
        id: record.id,
        name: input.name,
        key: fullKey,
        prefix: `intel_live_${prefix}`,
        scopes: input.scopes,
        createdAt: record.createdAt,
      };
    }),

  revoke: tenantProcedure
    .input(z.object({ id: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      const record = await ctx.db.auditEvent.findFirst({
        where: { id: input.id, tenantId: ctx.tenantId, action: 'api_key.created' },
      });
      if (!record) throw new TRPCError({ code: 'NOT_FOUND' });

      await ctx.db.auditEvent.create({
        data: {
          tenantId: ctx.tenantId,
          actorId: ctx.userId,
          actorKind: 'USER',
          action: 'api_key.revoked',
          targetId: record.targetId,
          severity: 'WARN',
          correlationId: record.correlationId,
          detail: `Revoked key ${record.targetId}`,
        },
      });

      return { success: true };
    }),
});

function generateRandomString(length: number): string {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  // Use crypto.getRandomValues when available (Workers + Node 19+)
  const array = new Uint8Array(length);
  if (typeof globalThis.crypto !== 'undefined') {
    globalThis.crypto.getRandomValues(array);
    for (const byte of array) result += chars[byte % chars.length];
  } else {
    for (let i = 0; i < length; i++) result += chars[Math.floor(Math.random() * chars.length)];
  }
  return result;
}
