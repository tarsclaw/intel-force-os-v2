#!/usr/bin/env tsx
/**
 * Intel Force OS — New tenant onboarding CLI
 * Run: npm run onboard
 *
 * Provisions a customer tenant in Cloudflare KV and uploads their handbook.
 * Run during the 45-minute install call while screen-sharing.
 */

import { input, select, confirm } from '@inquirer/prompts';
import { execSync } from 'child_process';
import { readFileSync, existsSync } from 'fs';
import { randomUUID } from 'crypto';

const env = process.argv.includes('--env=prod') ? 'production' : 'dev';
const envFlag = env === 'production' ? '' : '--env preview';

console.log(`\n╔══════════════════════════════════════════════╗`);
console.log(`║   Intel Force OS — Customer Onboarding CLI   ║`);
console.log(`║   Environment: ${env.padEnd(29)}║`);
console.log(`╚══════════════════════════════════════════════╝\n`);

async function main() {
  // ─── Customer identity ───────────────────────────────────────
  const tenantId = await input({
    message: 'Customer Microsoft 365 tenant ID:',
    validate: (v) => (v.trim().length > 10 ? true : 'Enter the full M365 tenant GUID'),
  });

  const customerName = await input({
    message: 'Company name:',
    validate: (v) => (v.trim() ? true : 'Required'),
  });

  const customerDomain = await input({
    message: 'Company domain (e.g. acme.com):',
    validate: (v) => (v.includes('.') ? true : 'Enter a valid domain'),
  });

  // ─── HR Lead ─────────────────────────────────────────────────
  const hrLeadEmail = await input({
    message: 'HR Lead email:',
    validate: (v) => (v.includes('@') ? true : 'Enter a valid email'),
  });

  const hrLeadAadId = await input({
    message: 'HR Lead Entra ID object ID (from Azure AD):',
    validate: (v) => (v.trim().length > 10 ? true : 'Enter the full AAD object ID GUID'),
  });

  const backupHrLeadAadId = await input({
    message: 'Backup HR Lead Entra ID object ID (optional — press Enter to skip):',
  });

  // ─── Bot behaviour ───────────────────────────────────────────
  const companyTone = await input({
    message: 'Company tone (e.g. "Warm and professional; first names OK"):',
    default: 'Warm and professional. First names are fine.',
  });

  const approvalMode = await select({
    message: 'Approval mode:',
    choices: [
      { name: 'All replies need HR Lead approval (recommended)', value: 'all' },
      { name: 'Only sensitive replies need approval', value: 'sensitive_only' },
    ],
    default: 'all',
  });

  const weeklyReportEnabled = await confirm({
    message: 'Enable weekly Monday 9am summary report?',
    default: true,
  });

  // ─── Handbook ────────────────────────────────────────────────
  const handbookPath = await input({
    message: 'Path to HR handbook file (TXT or MD — PDF: convert first):',
    validate: (v) => {
      if (!v.trim()) return 'Required — the handbook grounds every draft';
      if (!existsSync(v)) return `File not found: ${v}`;
      return true;
    },
  });

  // ─── Confirm ─────────────────────────────────────────────────
  console.log('\n── Config summary ──────────────────────────────────');
  console.log(`Tenant ID:      ${tenantId}`);
  console.log(`Company:        ${customerName} (${customerDomain})`);
  console.log(`HR Lead:        ${hrLeadEmail} (${hrLeadAadId})`);
  console.log(`Backup lead:    ${backupHrLeadAadId || 'none'}`);
  console.log(`Approval mode:  ${approvalMode}`);
  console.log(`Weekly report:  ${weeklyReportEnabled ? 'yes' : 'no'}`);
  console.log(`Handbook:       ${handbookPath}`);
  console.log('────────────────────────────────────────────────────\n');

  const ok = await confirm({ message: 'Write to Cloudflare KV?', default: true });
  if (!ok) {
    console.log('Aborted.');
    process.exit(0);
  }

  // ─── Build config object ─────────────────────────────────────
  const config = {
    tenantId,
    customerName,
    customerDomain,
    anthropicModel: undefined,
    handbookKvKey: `handbook_text:${tenantId}`,
    hrLeadAadId,
    hrLeadEmail,
    backupHrLeadAadId: backupHrLeadAadId || undefined,
    approvalMode,
    sensitivityThreshold: 0.7,
    channels: [],
    escalationChannels: {
      grievance: 'hr_lead',
      resignation: 'hr_lead',
      mental_health: 'hr_lead',
      harassment: 'hr_lead',
      health: 'hr_lead',
    },
    companyTone,
    weeklyReportEnabled,
    weeklyReportTime: 'monday_09:00_BST',
    auditRetentionDays: 2555,
    piiRedactionEnabled: true,
    subscriptionTier: 'founding',
    subscriptionStatus: 'active',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    version: 1,
  };

  // ─── Write tenant config ─────────────────────────────────────
  console.log('\n[1/3] Writing tenant config to KV...');
  const configJson = JSON.stringify(config);
  kv('put', `tenant_config:${tenantId}`, configJson);
  console.log('      ✅ tenant_config written');

  // ─── Upload handbook ─────────────────────────────────────────
  console.log('[2/3] Uploading handbook to KV...');
  const handbookText = readFileSync(handbookPath, 'utf-8');
  const wordCount = handbookText.split(/\s+/).length;
  kv('put', `handbook_text:${tenantId}`, handbookText);
  console.log(`      ✅ Handbook uploaded (${wordCount.toLocaleString()} words)`);

  // ─── Verify ──────────────────────────────────────────────────
  console.log('[3/3] Verifying...');
  const retrieved = kv('get', `tenant_config:${tenantId}`);
  const parsed = JSON.parse(retrieved) as typeof config;
  if (parsed.tenantId !== tenantId) throw new Error('Verification failed — tenantId mismatch');
  console.log('      ✅ Verified\n');

  console.log('══════════════════════════════════════════════════════');
  console.log(`✅  ${customerName} is provisioned.`);
  console.log('');
  console.log('Next steps:');
  console.log('  1. Customer IT admin: upload teams-app/manifest.json zip + click admin consent');
  console.log('  2. HR Lead: open 1:1 chat with Intel Force OS bot in Teams');
  console.log('  3. Run smoke tests from docs/teams-hr-agent/04-deployment-guide.md §6');
  console.log('══════════════════════════════════════════════════════\n');
}

function kv(op: 'put' | 'get', key: string, value?: string): string {
  const base = `wrangler kv key ${op} --binding=TENANT_CONFIG ${envFlag}`;
  if (op === 'put' && value !== undefined) {
    // Write via stdin to avoid shell escaping issues with large values
    const tmp = `/tmp/ifos_${randomUUID()}.json`;
    const { writeFileSync, unlinkSync } = require('fs') as typeof import('fs');
    writeFileSync(tmp, value, 'utf-8');
    execSync(`${base} "${key}" < "${tmp}"`, { stdio: 'inherit' });
    unlinkSync(tmp);
    return '';
  }
  const output = execSync(`${base} "${key}"`, { encoding: 'utf-8' });
  return output.trim();
}

main().catch((err) => {
  console.error('\n❌', err instanceof Error ? err.message : err);
  process.exit(1);
});
