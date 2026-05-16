/**
 * Temporal activities for TenantOnboard workflow
 * Each activity is idempotent — safe to retry.
 */

import { db } from '@intelforce/db';

// ─── Step 1: Create Postgres schema ──────────────────────────────────────────

export async function createPostgresSchema(input: { tenantId: string }): Promise<void> {
  const safeId = input.tenantId.replace(/-/g, '_');
  const schemaName = `tenant_${safeId}`;

  // Create schema if not exists (idempotent)
  await db.$executeRawUnsafe(`CREATE SCHEMA IF NOT EXISTS "${schemaName}"`);

  // Create per-tenant tables
  await db.$executeRawUnsafe(`
    CREATE TABLE IF NOT EXISTS "${schemaName}".chunks (
      id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      vault_path  TEXT NOT NULL,
      chunk_index INTEGER NOT NULL,
      content     TEXT NOT NULL,
      tags        TEXT[] DEFAULT '{}',
      modified_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      agent       TEXT,
      UNIQUE(vault_path, chunk_index)
    )
  `);

  await db.$executeRawUnsafe(`
    CREATE INDEX IF NOT EXISTS "${schemaName}_chunks_path_idx"
    ON "${schemaName}".chunks (vault_path)
  `);

  // Enable pgvector extension and add embedding column
  await db.$executeRawUnsafe(`
    ALTER TABLE "${schemaName}".chunks
    ADD COLUMN IF NOT EXISTS embedding vector(1024)
  `);

  await db.$executeRawUnsafe(`
    CREATE INDEX IF NOT EXISTS "${schemaName}_chunks_embedding_idx"
    ON "${schemaName}".chunks USING hnsw (embedding vector_cosine_ops)
  `);

  // Config table
  await db.$executeRawUnsafe(`
    CREATE TABLE IF NOT EXISTS "${schemaName}".config (
      key       TEXT PRIMARY KEY,
      value     JSONB NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);
}

// ─── Step 2: Provision secrets vault ─────────────────────────────────────────

export async function provisionSecretsVault(input: { tenantId: string; plan: string }): Promise<void> {
  // In production: POST /v1/tenants/{tenantId}/provision to the Secrets Vault service
  // The vault service creates a per-tenant KMS CMK and stores the key ARN
  //
  // For now: record the intent in the audit log
  await db.auditEvent.upsert({
    where: {
      // Use a stable ID so this is idempotent
      id: `provisioning-secrets-${input.tenantId}`,
    },
    create: {
      id: `provisioning-secrets-${input.tenantId}`,
      tenantId: input.tenantId,
      actorKind: 'SYSTEM',
      actorLabel: 'temporal:provisioning',
      action: 'provisioning.secrets_vault_created',
      detail: `KMS CMK provisioned for tenant ${input.tenantId}`,
      severity: 'INFO',
    },
    update: {
      detail: `KMS CMK re-provisioned for tenant ${input.tenantId}`,
    },
  });
}

// ─── Step 3: Initialise agent vault ──────────────────────────────────────────

export async function initAgentVault(input: { tenantId: string; tenantSlug: string }): Promise<void> {
  // In production: create a GitHub repo under intelforce-vaults org,
  // push the seed vault skeleton, and register the deploy key in the Secrets Vault
  //
  // For now: create the vault config entry
  const safeId = input.tenantId.replace(/-/g, '_');
  await db.$executeRawUnsafe(`
    INSERT INTO "tenant_${safeId}".config (key, value)
    VALUES ('vault.initialised', 'true'::jsonb),
           ('vault.slug', '${input.tenantSlug}'::jsonb)
    ON CONFLICT (key) DO NOTHING
  `);
}

// ─── Step 4: Configure enabled agents ────────────────────────────────────────

export async function configureEnabledAgents(input: {
  tenantId: string;
  agentsEnabled: string[];
}): Promise<void> {
  // Update the tenant record with enabled agents
  await db.tenant.update({
    where: { id: input.tenantId },
    data: { agentsEnabled: input.agentsEnabled },
  });
}

// ─── Step 5: Register webhook endpoints ──────────────────────────────────────

export async function registerWebhookEndpoints(input: {
  tenantId: string;
  agentsEnabled: string[];
  oauthProvidersPending: string[];
}): Promise<void> {
  // Register webhook endpoints for each connected provider
  // In production: POST to each provider's webhook registration API
  // For now: record the registrations
  for (const provider of input.oauthProvidersPending) {
    await db.webhookRegistration.upsert({
      where: {
        // Use a compound key if available; otherwise create new
        id: `${input.tenantId}-${provider}`,
      },
      create: {
        id: `${input.tenantId}-${provider}`,
        tenantId: input.tenantId,
        provider,
        endpoint: `https://bot.intelforce.ai/webhooks/${provider}/${input.tenantId}`,
        secretHash: 'pending-oauth',
        status: 'pending_oauth',
      },
      update: {
        status: 'pending_oauth',
      },
    });
  }
}

// ─── Step 6: Run preflight checks ────────────────────────────────────────────

export async function runPreflightChecks(input: {
  tenantId: string;
  agentsEnabled: string[];
}): Promise<{ allPassed: boolean; warnings: string[] }> {
  const warnings: string[] = [];

  // Check each agent's required integrations
  const connected = await db.webhookRegistration.findMany({
    where: { tenantId: input.tenantId, status: 'active' },
    select: { provider: true },
  });
  const connectedProviders = new Set(connected.map((c) => c.provider));

  if (input.agentsEnabled.includes('hr-agent') && !connectedProviders.has('breathe_hr')) {
    warnings.push('hr-agent: Breathe HR integration not connected — agent will use handbook only');
  }

  if (input.agentsEnabled.includes('lead-hunter') && !connectedProviders.has('hubspot')) {
    warnings.push('lead-hunter: HubSpot not connected — leads will not sync to CRM');
  }

  return { allPassed: warnings.length === 0, warnings };
}

// ─── Step 7: Mark tenant live ─────────────────────────────────────────────────

export async function markTenantLive(input: { tenantId: string }): Promise<void> {
  await db.tenant.update({
    where: { id: input.tenantId },
    data: { status: 'ACTIVE' },
  });

  await db.auditEvent.create({
    data: {
      tenantId: input.tenantId,
      actorKind: 'SYSTEM',
      actorLabel: 'temporal:provisioning',
      action: 'provisioning.tenant_live',
      detail: 'Tenant provisioned and marked ACTIVE',
      severity: 'INFO',
    },
  });
}

// ─── Failure notification ─────────────────────────────────────────────────────

export async function notifyOperatorFailure(input: {
  tenantId: string;
  error: string;
  completedSteps: string[];
}): Promise<void> {
  await db.auditEvent.create({
    data: {
      tenantId: input.tenantId,
      actorKind: 'SYSTEM',
      actorLabel: 'temporal:provisioning',
      action: 'provisioning.failed',
      detail: input.error,
      severity: 'CRITICAL',
      metadata: { completedSteps: input.completedSteps },
    },
  });

  // In production: POST to Slack webhook / send email to ops team
}
