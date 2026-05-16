import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';
import { Settings as SettingsIcon } from 'lucide-react';
import { SettingsTabs } from '../../../../components/settings/tabs';
import { PageHeader, StatusPill } from '@/components/shared';

export const metadata = { title: 'Settings' };

const planLabels: Record<string, string> = {
  FOUNDING: 'Founding',
  STARTER: 'Starter',
  GROWTH: 'Growth',
  SCALE: 'Scale',
  ENTERPRISE: 'Enterprise',
  AGENCY_PARTNER: 'Agency partner',
};

const statusTone: Record<string, 'good' | 'warn' | 'danger' | 'muted' | 'info'> = {
  ACTIVE: 'good',
  PROVISIONING: 'info',
  SUSPENDED: 'warn',
  DECOMMISSIONED: 'danger',
};

export default async function SettingsPage({ params }: { params: Promise<{ slug: string }> }) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const tenant = await db.tenant.findUnique({
    where: { slug },
    select: {
      id: true,
      name: true,
      slug: true,
      plan: true,
      status: true,
      billingEmail: true,
      timezone: true,
      agentsEnabled: true,
      costBudgetGbp: true,
      hardStopBudget: true,
      userRoles: {
        where: { revokedAt: null },
        include: { user: { select: { id: true, name: true, email: true, imageUrl: true } } },
      },
    },
  });

  if (!tenant) return null;

  const planLabel = planLabels[tenant.plan] ?? tenant.plan;
  const teamCount = tenant.userRoles.length;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Settings"
        description={`${tenant.name} · ${planLabel} plan · ${teamCount} member${teamCount === 1 ? '' : 's'}`}
        actions={
          <div className="flex items-center gap-2">
            <StatusPill tone="info">{planLabel}</StatusPill>
            <StatusPill tone={statusTone[tenant.status] ?? 'muted'} showDot pulse={tenant.status === 'ACTIVE'}>
              {tenant.status}
            </StatusPill>
          </div>
        }
      />

      <SettingsTabs tenant={tenant} />
    </div>
  );
}
