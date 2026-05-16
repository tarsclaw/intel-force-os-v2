import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';

export const metadata = { title: 'Agency Activity' };

export default async function AgencyActivityPage({ params }: { params: Promise<{ slug: string }> }) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const agency = await db.tenant.findFirst({
    where: { slug, plan: 'AGENCY_PARTNER' },
    select: { id: true },
  });
  if (!agency) return null;

  const subTenantIds = (
    await db.tenant.findMany({ where: { parentTenantId: agency.id }, select: { id: true } })
  ).map((t) => t.id);

  const events = subTenantIds.length > 0
    ? await db.auditEvent.findMany({
        where: { tenantId: { in: subTenantIds } },
        orderBy: { createdAt: 'desc' },
        take: 50,
        include: {
          tenant: { select: { name: true, slug: true } },
          actor: { select: { name: true, email: true } },
        },
      })
    : [];

  return (
    <div className="space-y-5">
      <h1 className="text-base font-semibold text-text-primary">Portfolio Activity</h1>

      <section className="bg-surface border border-border rounded-lg overflow-hidden">
        {events.length === 0 ? (
          <div className="py-16 text-center">
            <p className="text-sm text-text-muted">No activity yet across this portfolio.</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="border-b border-border">
              <tr>
                {['Time', 'Tenant', 'Action', 'Actor'].map((h) => (
                  <th key={h} className="text-left text-xs text-text-muted font-medium px-4 py-3">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {events.map((e) => (
                <tr key={e.id} className="border-b border-border/50 hover:bg-surface-raised/50 transition-colors">
                  <td className="px-4 py-2.5 text-xs text-text-muted tabular-nums">
                    {e.createdAt.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' })}
                  </td>
                  <td className="px-4 py-2.5">
                    <a href={`/t/${e.tenant?.slug}`} className="text-xs text-brand-emerald hover:underline">
                      {e.tenant?.name ?? '—'}
                    </a>
                  </td>
                  <td className="px-4 py-2.5 text-xs text-text-primary font-mono">{e.action}</td>
                  <td className="px-4 py-2.5 text-xs text-text-muted">
                    {e.actor?.name ?? e.actor?.email ?? e.actorKind}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
