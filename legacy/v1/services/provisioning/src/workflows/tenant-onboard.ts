/**
 * TenantOnboard — Temporal workflow
 * Per docs/phase-3-platform/provisioning/provisioning-system-spec.md
 *
 * Runs when a new tenant is submitted via the Configuration Wizard.
 * Idempotent: safe to retry at any step.
 * Retries each activity 3× with exponential backoff before failing the workflow.
 */

import { proxyActivities, log, sleep } from '@temporalio/workflow';
import type * as activities from '../activities/tenant-onboard-activities';

const {
  createPostgresSchema,
  provisionSecretsVault,
  initAgentVault,
  configureEnabledAgents,
  registerWebhookEndpoints,
  runPreflightChecks,
  markTenantLive,
  notifyOperatorFailure,
} = proxyActivities<typeof activities>({
  startToCloseTimeout: '5 minutes',
  retry: {
    maximumAttempts: 3,
    initialInterval: '2s',
    backoffCoefficient: 2,
  },
});

export interface TenantOnboardInput {
  tenantId: string;
  tenantSlug: string;
  plan: string;
  agentsEnabled: string[];
  ownerEmail: string;
  timezone: string;
  oauthProvidersPending: string[];
}

export interface TenantOnboardResult {
  tenantId: string;
  status: 'live' | 'failed';
  completedSteps: string[];
  error?: string;
}

export async function tenantOnboard(input: TenantOnboardInput): Promise<TenantOnboardResult> {
  const completed: string[] = [];

  log.info('TenantOnboard starting', { tenantId: input.tenantId });

  try {
    // Step 1 — Create per-tenant Postgres schema
    await createPostgresSchema({ tenantId: input.tenantId });
    completed.push('postgres_schema');
    log.info('Schema created', { tenantId: input.tenantId });

    // Step 2 — Provision secrets vault (AWS KMS CMK per tenant)
    await provisionSecretsVault({ tenantId: input.tenantId, plan: input.plan });
    completed.push('secrets_vault');
    log.info('Secrets vault provisioned', { tenantId: input.tenantId });

    // Step 3 — Initialise agent vault (GitHub repo + seed structure)
    await initAgentVault({ tenantId: input.tenantId, tenantSlug: input.tenantSlug });
    completed.push('agent_vault');
    log.info('Agent vault initialised', { tenantId: input.tenantId });

    // Step 4 — Configure enabled agents (load agent bundles, write per-tenant config)
    await configureEnabledAgents({ tenantId: input.tenantId, agentsEnabled: input.agentsEnabled });
    completed.push('agents_configured');
    log.info('Agents configured', { tenantId: input.tenantId });

    // Step 5 — Register webhook endpoints with external providers
    await registerWebhookEndpoints({
      tenantId: input.tenantId,
      agentsEnabled: input.agentsEnabled,
      oauthProvidersPending: input.oauthProvidersPending,
    });
    completed.push('webhooks_registered');
    log.info('Webhooks registered', { tenantId: input.tenantId });

    // Step 6 — Run preflight checks (verify each agent's required integrations)
    const preflight = await runPreflightChecks({
      tenantId: input.tenantId,
      agentsEnabled: input.agentsEnabled,
    });
    completed.push('preflight_complete');

    if (!preflight.allPassed) {
      log.warn('Preflight checks had warnings — proceeding', {
        tenantId: input.tenantId,
        warnings: preflight.warnings,
      });
    }

    // Step 7 — Mark tenant as ACTIVE
    await markTenantLive({ tenantId: input.tenantId });
    completed.push('tenant_live');

    log.info('TenantOnboard complete', { tenantId: input.tenantId });

    return { tenantId: input.tenantId, status: 'live', completedSteps: completed };

  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    log.error('TenantOnboard failed', { tenantId: input.tenantId, error: message, completedSteps: completed });

    // Notify operator — non-blocking
    try {
      await notifyOperatorFailure({
        tenantId: input.tenantId,
        error: message,
        completedSteps: completed,
      });
    } catch {
      // Notification failure should not re-throw
    }

    return {
      tenantId: input.tenantId,
      status: 'failed',
      completedSteps: completed,
      error: message,
    };
  }
}

export async function tenantDecommission(input: { tenantId: string; reason: string }) {
  log.info('TenantDecommission starting', { tenantId: input.tenantId });
  // Decommission workflow: suspend → export data → delete secrets → drop schema
  // Full implementation in Phase 3 when Temporal is wired
}
