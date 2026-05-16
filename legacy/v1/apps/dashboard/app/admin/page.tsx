import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';

export const metadata = { title: 'Platform Overview' };

export default async function AdminOverviewPage() {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

  const [activeTenants, totalTenants, openEscalations, monthCosts, recentDeployments] =
    await Promise.all([
      db.tenant.count({ where: { status: 'ACTIVE' } }),
      db.tenant.count(),
      db.escalation.count({ where: { status: 'OPEN' } }),
      db.cost.aggregate({ where: { recordedAt: { gte: monthStart } }, _sum: { costGbp: true } }),
      db.deployment.findMany({ orderBy: { deployedAt: 'desc' }, take: 5 }),
    ]);

  const kpis = [
    { label: 'Active tenants', value: activeTenants, sub: `${totalTenants} total` },
    { label: 'Open escalations', value: openEscalations, sub: 'across all tenants', urgent: openEscalations > 10 },
    { label: 'Platform spend', value: `£${Number(monthCosts._sum.costGbp ?? 0).toFixed(2)}`, sub: 'this month' },
    { label: 'Last deploy', value: recentDeployments[0]?.deployedAt.toLocaleDateString('en-GB') ?? '—', sub: recentDeployments[0]?.component ?? '—' },
  ];

  return (
    <div className="space-y-5">
      <h1 className="text-base font-semibold text-text-primary">Platform Overview</h1>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {kpis.map(({ label, value, sub, urgent }) => (
          <div key={label} className="bg-surface border border-border rounded-lg p-4">
            <p className="text-xs text-text-muted mb-1">{label}</p>
            <p className={`text-2xl font-semibold tabular-nums ${urgent ? 'text-red-400' : 'text-text-primary'}`}>{value}</p>
            <p className="text-xs text-text-muted mt-1">{sub}</p>
          </div>
        ))}
      </div>

      {/* Recent deployments */}
      <section className="bg-surface border border-border rounded-lg p-4">
        <h2 className="text-sm font-medium text-text-primary mb-3">Recent deployments</h2>
        {recentDeployments.length === 0 ? (
          <p className="text-xs text-text-muted">No deployments recorded</p>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                {['Component', 'Version', 'Environment', 'Deployed'].map((h) => (
                  <th key={h} className="text-left text-xs text-text-muted font-medium pb-2 pr-4">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {recentDeployments.map((d) => (
                <tr key={d.id} className="border-b border-border/50">
                  <td className="py-2 pr-4 text-sm text-text-primary font-mono">{d.component}</td>
                  <td className="py-2 pr-4 text-xs text-text-secondary font-mono">{d.version}</td>
                  <td className="py-2 pr-4 text-xs text-text-secondary">{d.env}</td>
                  <td className="py-2 text-xs text-text-muted">{d.deployedAt.toLocaleDateString('en-GB')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
