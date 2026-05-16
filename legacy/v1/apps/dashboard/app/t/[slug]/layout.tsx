import { auth } from '@clerk/nextjs/server';
import { redirect, notFound } from 'next/navigation';
import { db } from '@intelforce/db';
import { TenantNav } from '../../../components/shared/nav';
import { MainContent } from '../../../components/shared/main-content';
import { Providers } from '../../../components/providers';

export default async function TenantLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ slug: string }>;
}) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const tenant = await db.tenant.findUnique({
    where: { slug },
    select: { id: true, name: true, slug: true, status: true, plan: true },
  });

  if (!tenant) notFound();
  if (tenant.status === 'DECOMMISSIONED') {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[rgb(var(--bg-canvas))]">
        <p className="text-text-muted text-sm">This workspace has been decommissioned.</p>
      </div>
    );
  }

  const pendingCount = await db.escalation.count({
    where: { tenantId: tenant.id, status: 'OPEN' },
  });

  return (
    <Providers tenantSlug={tenant.slug}>
      <div className="min-h-screen bg-[rgb(var(--bg-canvas))]">
        <TenantNav
          slug={tenant.slug}
          tenantName={tenant.name}
          tenantPlan={tenant.plan}
          pendingCount={pendingCount}
        />
        <MainContent>{children}</MainContent>
      </div>
    </Providers>
  );
}
