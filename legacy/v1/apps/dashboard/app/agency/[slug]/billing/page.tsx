import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';

export const metadata = { title: 'Agency Billing' };

export default async function AgencyBillingPage({ params }: { params: Promise<{ slug: string }> }) {
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
    select: { id: true, name: true, plan: true },
  });

  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

  const costsByTenant = await Promise.all(
    subTenants.map(async (t) => {
      const cost = await db.cost.aggregate({
        where: { tenantId: t.id, recordedAt: { gte: monthStart } },
        _sum: { costGbp: true },
      });
      return { ...t, monthCost: Number(cost._sum.costGbp ?? 0) };
    }),
  );

  const totalMonthCost = costsByTenant.reduce((sum, t) => sum + t.monthCost, 0);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <h1 className="text-base font-semibold text-text-primary">Consolidated Billing</h1>
        <span className="text-sm font-mono text-text-primary">
          £{totalMonthCost.toFixed(2)} <span className="text-xs text-text-muted font-sans">this month</span>
        </span>
      </div>

      <section className="bg-surface border border-border rounded-lg overflow-hidden">
        <div className="px-4 py-3 border-b border-border">
          <h2 className="text-sm font-medium text-text-primary">Cost by sub-tenant</h2>
        </div>
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border">
              {['Tenant', 'Plan', 'Month spend'].map((h) => (
                <th key={h} className="text-left text-xs text-text-muted font-medium px-4 py-2">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {costsByTenant.map((t) => (
              <tr key={t.id} className="border-b border-border/50">
                <td className="px-4 py-2.5 text-sm text-text-primary">{t.name}</td>
                <td className="px-4 py-2.5 text-xs text-text-secondary">{t.plan}</td>
                <td className="px-4 py-2.5 text-sm font-mono text-text-primary">
                  £{t.monthCost.toFixed(2)}
                </td>
              </tr>
            ))}
            {costsByTenant.length > 0 && (
              <tr className="bg-surface-raised">
                <td className="px-4 py-2.5 text-xs font-medium text-text-primary" colSpan={2}>Total</td>
                <td className="px-4 py-2.5 text-sm font-mono font-semibold text-text-primary">
                  £{totalMonthCost.toFixed(2)}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </section>
    </div>
  );
}
