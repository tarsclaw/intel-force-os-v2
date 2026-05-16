#!/usr/bin/env tsx
/**
 * Intel Force OS — List all configured tenants
 * Run: npm run tenants
 */

import { execSync } from 'child_process';

const env = process.argv.includes('--env=prod') ? 'production' : 'dev';
const envFlag = env === 'production' ? '' : '--env preview';

interface TenantConfig {
  tenantId: string;
  customerName: string;
  customerDomain: string;
  hrLeadEmail: string;
  subscriptionTier: string;
  subscriptionStatus: string;
  weeklyReportEnabled: boolean;
  createdAt: string;
  handbookKvKey: string;
}

async function main() {
  console.log(`\nIntel Force OS — Tenants (${env})\n`);

  let listOutput: string;
  try {
    listOutput = execSync(
      `wrangler kv key list --binding=TENANT_CONFIG ${envFlag} --prefix="tenant_config:"`,
      { encoding: 'utf-8' },
    ).trim();
  } catch {
    console.log('No tenants found, or KV not accessible.');
    process.exit(0);
  }

  let keys: Array<{ name: string }>;
  try {
    keys = JSON.parse(listOutput) as Array<{ name: string }>;
  } catch {
    console.log('Could not parse KV list output.');
    process.exit(1);
  }

  if (keys.length === 0) {
    console.log('No tenants provisioned yet.');
    return;
  }

  const tenants: TenantConfig[] = [];
  for (const { name } of keys) {
    try {
      const json = execSync(
        `wrangler kv key get --binding=TENANT_CONFIG ${envFlag} "${name}"`,
        { encoding: 'utf-8' },
      ).trim();
      tenants.push(JSON.parse(json) as TenantConfig);
    } catch {
      console.warn(`  Could not read: ${name}`);
    }
  }

  // Check which tenants have handbooks
  const handbookSizes: Record<string, string> = {};
  for (const t of tenants) {
    try {
      const text = execSync(
        `wrangler kv key get --binding=TENANT_CONFIG ${envFlag} "handbook_text:${t.tenantId}"`,
        { encoding: 'utf-8' },
      ).trim();
      handbookSizes[t.tenantId] = `${Math.round(text.length / 1000)}k chars`;
    } catch {
      handbookSizes[t.tenantId] = 'no handbook';
    }
  }

  // Print table
  const col = (s: string, w: number) => s.slice(0, w).padEnd(w);

  console.log(
    col('Company', 28) +
    col('Domain', 22) +
    col('HR Lead', 28) +
    col('Tier', 10) +
    col('Status', 12) +
    col('Handbook', 14) +
    'Created',
  );
  console.log('─'.repeat(124));

  for (const t of tenants) {
    console.log(
      col(t.customerName, 28) +
      col(t.customerDomain, 22) +
      col(t.hrLeadEmail, 28) +
      col(t.subscriptionTier, 10) +
      col(t.subscriptionStatus, 12) +
      col(handbookSizes[t.tenantId] ?? '—', 14) +
      t.createdAt.slice(0, 10),
    );
  }

  console.log(`\n${tenants.length} tenant(s) total.\n`);
}

main().catch((err) => {
  console.error('\n❌', err instanceof Error ? err.message : err);
  process.exit(1);
});
