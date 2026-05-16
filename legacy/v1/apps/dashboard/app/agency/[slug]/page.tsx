import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';
import { KpiTiles } from '../../../components/operations/kpi-tiles';
import { AlertTriangle, Building2 } from 'lucide-react';

export const metadata = { title: 'Agency Portfolio' };

export default async function AgencyOverviewPage({ params }: { params: Promise<{ slug: string }> }) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const agency = await db.tenant.findFirst({
    where: { slug, plan: 'AGENCY_PARTNER' },
    select: { id: true, name: true },
  });
  if (!agency) return null;

  const subTenants = await db.tenant.findMany({
    where: { parentTenantId: agency.id },
    orderBy: { createdAt: 'desc' },
    take: 20,
  });

  const subTenantIds = subTenants.map((t) => t.id);
  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const weekStart = new Date(now);
  weekStart.setDate(now.getDate() - 7);

  let openEscalations = 0;
  let monthSpendGbp = 0;
  let invocationsTotal = 0;
  let successRate = 0;

  if (subTenantIds.length > 0) {
    const [escalations, invocations, costs] = await Promise.all([
      db.escalation.count({ where: { tenantId: { in: subTenantIds }, status: { in: ['OPEN', 'ACKNOWLEDGED'] } } }),
      db.invocation.groupBy({ by: ['status'], where: { tenantId: { in: subTenantIds }, startedAt: { gte: weekStart } }, _count: true }),
      db.cost.aggregate({ where: { tenantId: { in: subTenantIds }, recordedAt: { gte: monthStart } }, _sum: { costGbp: true } }),
    ]);

    openEscalations = escalations;
    monthSpendGbp = Number(costs._sum.costGbp ?? 0);
    const total = invocations.reduce((a, g) => a + g._count, 0);
    const success = invocations.find((g) => g.status === 'SUCCESS')?._count ?? 0;
    invocationsTotal = total;
    successRate = total > 0 ? Math.round((success / total) * 100) : 0;
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <h1 className="text-base font-semibold text-text-primary">Portfolio — {agency.name}</h1>
        <span className="text-xs text-text-muted">{subTenants.length} tenant{subTenants.length !== 1 ? 's' : ''}</span>
      </div>

      <KpiTiles
        openEscalations={openEscalations}
        monthSpendGbp={monthSpendGbp}
        budgetGbp={null}
        invocationsTotal={invocationsTotal}
        invocationsDelta={0}
        successRate={successRate}
      />

      {/* Sub-tenant table */}
      <section className="bg-surface border border-border rounded-lg p-4">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-sm font-medium text-text-primary">Sub-tenants</h2>
          <a href={`/agency/${slug}/tenants`} className="text-xs text-brand-emerald hover:underline">View all →</a>
        </div>

        {subTenants.length === 0 ? (
          <div className="py-10 text-center">
            <Building2 className="w-8 h-8 text-text-muted mx-auto mb-2" />
            <p className="text-sm text-text-muted">No sub-tenants yet</p>
            <p className="text-xs text-text-muted">Use the wizard to create and add sub-tenants to this agency.</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                {['Tenant', 'Plan', 'Status', 'Created'].map((h) => (
                  <th key={h} className="text-left text-xs text-text-muted font-medium pb-2 pr-4">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {subTenants.map((t) => (
                <tr key={t.id} className="border-b border-border/50 hover:bg-surface-raised/50 transition-colors">
                  <td className="py-2.5 pr-4">
                    <a href={`/t/${t.slug}`} className="text-text-primary hover:text-brand-emerald transition-colors">{t.name}</a>
                    <p className="text-xs text-text-muted font-mono">{t.slug}</p>
                  </td>
                  <td className="py-2.5 pr-4 text-xs text-text-secondary">{t.plan}</td>
                  <td className="py-2.5 pr-4">
                    <span className={`text-xs ${t.status === 'ACTIVE' ? 'text-brand-emerald' : 'text-text-muted'}`}>
                      {t.status}
                    </span>
                  </td>
                  <td className="py-2.5 text-xs text-text-muted">{t.createdAt.toLocaleDateString('en-GB')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
