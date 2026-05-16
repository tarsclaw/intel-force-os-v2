#!/usr/bin/env tsx
/**
 * Intel Force OS — Tenant offboarding CLI
 * Run: npm run offboard
 *
 * Deletes all tenant data from KV and D1.
 * Per GDPR Art. 17 — run 30 days after cancellation is confirmed final.
 */

import { input, confirm } from '@inquirer/prompts';
import { execSync } from 'child_process';

const env = process.argv.includes('--env=prod') ? 'production' : 'dev';
const envFlag = env === 'production' ? '' : '--env preview';

console.log(`\n╔══════════════════════════════════════════════╗`);
console.log(`║   Intel Force OS — Tenant Offboarding        ║`);
console.log(`║   Environment: ${env.padEnd(29)}║`);
console.log(`╚══════════════════════════════════════════════╝\n`);
console.log('⚠️  This permanently deletes all tenant data. There is no undo.\n');

async function main() {
  const tenantId = await input({
    message: 'Tenant ID to offboard:',
    validate: (v) => (v.trim().length > 10 ? true : 'Enter the full M365 tenant GUID'),
  });

  // Show what exists before deleting
  console.log('\nChecking tenant data...');
  try {
    const config = wrangler(`kv key get --binding=TENANT_CONFIG ${envFlag} "tenant_config:${tenantId}"`);
    const parsed = JSON.parse(config) as { customerName?: string };
    console.log(`Found: ${parsed.customerName ?? 'unknown'} (${tenantId})`);
  } catch {
    console.log('⚠️  No tenant config found. The tenant may already be deleted.');
  }

  const yes = await confirm({
    message: `Permanently delete ALL data for tenant ${tenantId}?`,
    default: false,
  });

  if (!yes) {
    console.log('Aborted. No data deleted.');
    process.exit(0);
  }

  const confirm2 = await input({
    message: 'Type the tenant ID again to confirm:',
    validate: (v) => (v.trim() === tenantId ? true : 'Tenant ID does not match'),
  });

  if (confirm2.trim() !== tenantId) {
    console.log('Aborted.');
    process.exit(0);
  }

  console.log('\nDeleting tenant data...');

  // 1. Delete KV keys
  const kvKeys = [
    `tenant_config:${tenantId}`,
    `handbook_text:${tenantId}`,
  ];

  // Also list and delete conversation refs (hr_lead_conversation:{tenantId}:*)
  try {
    const listOutput = wrangler(`kv key list --binding=TENANT_CONFIG ${envFlag} --prefix="hr_lead_conversation:${tenantId}:"`);
    const keys = JSON.parse(listOutput) as Array<{ name: string }>;
    kvKeys.push(...keys.map((k) => k.name));
  } catch {
    // No conversation refs
  }

  let kvDeleted = 0;
  for (const key of kvKeys) {
    try {
      wrangler(`kv key delete --binding=TENANT_CONFIG ${envFlag} "${key}" --force`);
      kvDeleted++;
    } catch {
      console.warn(`  ⚠️  Could not delete KV key: ${key}`);
    }
  }
  console.log(`[1/2] KV: deleted ${kvDeleted} key(s)`);

  // 2. Delete D1 audit log rows
  try {
    const d1Flag = env === 'production' ? '' : '--env preview';
    const result = wrangler(
      `d1 execute intel-force-audit ${d1Flag} --command "DELETE FROM audit_log WHERE tenant_id = '${tenantId}'"`,
    );
    console.log(`[2/2] D1: audit_log rows deleted`);
    console.log(`      ${result.includes('changes') ? result.trim() : 'done'}`);
  } catch (err) {
    console.warn(`  ⚠️  D1 deletion error: ${err instanceof Error ? err.message : err}`);
  }

  console.log('\n══════════════════════════════════════════════════════');
  console.log(`✅  Tenant ${tenantId} has been offboarded.`);
  console.log('');
  console.log('Confirm with customer in writing that deletion is complete.');
  console.log('Log this action: date, tenant ID, who triggered it, this output.');
  console.log('See: docs/phase-6-ops-runbooks/compliance/gdpr-dsar-and-deletion-runbook.md');
  console.log('══════════════════════════════════════════════════════\n');
}

function wrangler(cmd: string): string {
  return execSync(`wrangler ${cmd}`, { encoding: 'utf-8' }).trim();
}

main().catch((err) => {
  console.error('\n❌', err instanceof Error ? err.message : err);
  process.exit(1);
});
