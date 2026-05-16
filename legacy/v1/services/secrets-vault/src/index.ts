/**
 * Secrets Vault HTTP service — Hono
 *
 * Runs as a sidecar alongside the provisioning system.
 * Internal only — not public-facing.
 *
 * Required env vars:
 *   AWS_ACCESS_KEY_ID
 *   AWS_SECRET_ACCESS_KEY
 *   AWS_KMS_REGION    (default: eu-west-2)
 *   DATABASE_URL
 *   VAULT_INTERNAL_TOKEN  (bearer token for service-to-service auth)
 */

import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { z } from 'zod';
import { listSecretRefs, retrieveSecret, rotateSecret, storeSecret } from './vault';
import { createTenantCmk, scheduleCmkDeletion } from './kms';
import { db } from '@intelforce/db';

const app = new Hono();
const INTERNAL_TOKEN = process.env['VAULT_INTERNAL_TOKEN'] ?? 'dev-token';

// ─── Auth middleware ──────────────────────────────────────────────────────────

app.use('*', async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '');
  if (token !== INTERNAL_TOKEN) {
    return c.json({ error: 'Unauthorized' }, 401);
  }
  return next();
});

// ─── Routes ───────────────────────────────────────────────────────────────────

// Provision a new tenant CMK
app.post('/v1/tenants/:tenantId/provision', async (c) => {
  const { tenantId } = c.req.param();
  const body = await c.req.json() as { plan: string };

  const key = await createTenantCmk(tenantId, body.plan);
  const cmkArn = key.KeyMetadata?.Arn;
  if (!cmkArn) return c.json({ error: 'KMS key creation failed' }, 500);

  // Store CMK ARN in audit log for future operations
  await db.auditEvent.create({
    data: {
      tenantId,
      actorKind: 'SYSTEM',
      actorLabel: 'secrets-vault',
      action: 'vault.cmk_created',
      detail: cmkArn,
      severity: 'INFO',
    },
  });

  return c.json({ cmkArn });
});

// List secret refs (never values)
app.get('/v1/secrets/:tenantId', async (c) => {
  const { tenantId } = c.req.param();
  const refs = await listSecretRefs(tenantId);
  return c.json({ refs });
});

// Store a secret
app.post('/v1/secrets/:tenantId', async (c) => {
  const { tenantId } = c.req.param();
  const body = z.object({
    provider: z.string(),
    kind: z.enum(['api_key', 'oauth_access_token', 'oauth_refresh_token', 'webhook_secret']),
    label: z.string(),
    value: z.string(),
    cmkArn: z.string(),
    expiresAt: z.string().datetime().optional(),
  }).parse(await c.req.json());

  const ref = await storeSecret({ ...body, tenantId, expiresAt: body.expiresAt ? new Date(body.expiresAt) : undefined });
  return c.json({ ref });
});

// Retrieve a secret value (restricted to internal callers only)
app.post('/v1/secrets/:tenantId/retrieve', async (c) => {
  const { tenantId } = c.req.param();
  const { ref } = await c.req.json() as { ref: string };
  const value = await retrieveSecret(ref, tenantId);

  // Log every access
  await db.auditEvent.create({
    data: {
      tenantId,
      actorKind: 'SYSTEM',
      actorLabel: 'secrets-vault',
      action: 'vault.secret_accessed',
      targetId: ref,
      severity: 'INFO',
    },
  });

  return c.json({ value });
});

// Rotate a secret
app.post('/v1/secrets/:tenantId/rotate', async (c) => {
  const { tenantId } = c.req.param();
  const { ref, newValue } = await c.req.json() as { ref: string; newValue: string };
  await rotateSecret(ref, tenantId, newValue);

  await db.auditEvent.create({
    data: {
      tenantId,
      actorKind: 'SYSTEM',
      actorLabel: 'secrets-vault',
      action: 'vault.secret_rotated',
      targetId: ref,
      severity: 'WARN',
    },
  });

  return c.json({ success: true });
});

// Schedule CMK deletion (GDPR Art. 17 — mathematical erasure)
app.delete('/v1/tenants/:tenantId/cmk', async (c) => {
  const { tenantId } = c.req.param();
  const { cmkArn } = await c.req.json() as { cmkArn: string };
  await scheduleCmkDeletion(cmkArn, 30);

  await db.auditEvent.create({
    data: {
      tenantId,
      actorKind: 'SYSTEM',
      actorLabel: 'secrets-vault',
      action: 'vault.cmk_deletion_scheduled',
      detail: `30-day pending window. Mathematical erasure on deletion.`,
      severity: 'CRITICAL',
    },
  });

  return c.json({ success: true, message: '30-day pending deletion scheduled' });
});

app.get('/health', (c) => c.json({ status: 'ok' }));

// ─── Start ────────────────────────────────────────────────────────────────────

const PORT = parseInt(process.env['PORT'] ?? '4001');

serve({ fetch: app.fetch, port: PORT }, (info) => {
  console.log(`Secrets Vault running on port ${info.port}`);
});

export default app;
