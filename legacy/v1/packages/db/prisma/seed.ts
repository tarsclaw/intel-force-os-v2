/**
 * Dev seed script — creates a test User + Tenant + role binding
 * so you can sign in via Clerk and immediately navigate to a real tenant.
 *
 * Usage:
 *   1. Sign in to the dashboard via Clerk first (creates the Clerk user).
 *   2. Find your Clerk user ID at https://dashboard.clerk.com/users (starts user_…).
 *   3. Run:
 *        cd packages/db
 *        CLERK_USER_ID=user_xxx EMAIL=you@example.com pnpm tsx prisma/seed.ts
 *   4. Refresh the dashboard — you're now an owner of the Demo Co tenant
 *      and can navigate to /t/demo-co.
 *
 * Idempotent — safe to re-run. Updates the existing rows if they already exist.
 */

import { PrismaClient } from '@prisma/client';

const db = new PrismaClient();

async function main() {
  const clerkUserId = process.env.CLERK_USER_ID;
  const email = process.env.EMAIL ?? 'dev@intelforce.local';
  const name = process.env.NAME ?? 'Dev User';

  if (!clerkUserId) {
    console.error('CLERK_USER_ID env var required.');
    console.error('Find yours at https://dashboard.clerk.com/users');
    process.exit(1);
  }

  console.log(`[seed] linking Clerk user ${clerkUserId} → User row...`);
  const user = await db.user.upsert({
    where: { clerkUserId },
    create: { clerkUserId, email, name },
    update: { email, name },
    select: { id: true },
  });
  console.log(`[seed] ✓ User: ${user.id}`);

  console.log('[seed] upserting Demo Co tenant...');
  const tenant = await db.tenant.upsert({
    where: { slug: 'demo-co' },
    create: {
      slug: 'demo-co',
      name: 'Demo Co',
      plan: 'STARTER',
      status: 'ACTIVE',
      billingEmail: email,
      timezone: 'Europe/London',
      currency: 'GBP',
      agentsEnabled: ['hr-agent'],
      costBudgetGbp: 50,
      hardStopBudget: false,
    },
    update: {},
    select: { id: true, slug: true, name: true },
  });
  console.log(`[seed] ✓ Tenant: ${tenant.name} (${tenant.slug})`);

  console.log('[seed] binding user as TENANT_OWNER...');
  await db.userRole.upsert({
    where: { userId_tenantId: { userId: user.id, tenantId: tenant.id } },
    create: {
      userId: user.id,
      tenantId: tenant.id,
      role: 'TENANT_OWNER',
    },
    update: { role: 'TENANT_OWNER', revokedAt: null },
  });
  console.log('[seed] ✓ Role bound');

  console.log('[seed] reserving brain graph slot for Demo Co...');
  await db.brainGraph.upsert({
    where: { tenantId: tenant.id },
    create: { tenantId: tenant.id, status: 'PENDING' },
    update: {},
  });
  console.log('[seed] ✓ Brain graph row created (status=PENDING — uses demo data)');

  console.log('');
  console.log('Seed complete. Sign in at:');
  console.log(`  http://localhost:3000/sign-in`);
  console.log('Then navigate to:');
  console.log(`  http://localhost:3000/t/${tenant.slug}`);
  console.log('');
}

main()
  .catch((err) => {
    console.error('[seed] failed:', err);
    process.exit(1);
  })
  .finally(() => db.$disconnect());
