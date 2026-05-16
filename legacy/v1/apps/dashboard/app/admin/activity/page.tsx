import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';

export const metadata = { title: 'Platform Activity' };

export default async function AdminActivityPage() {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const events = await db.auditEvent.findMany({
    orderBy: { createdAt: 'desc' },
    take: 100,
    include: {
      tenant: { select: { name: true, slug: true } },
      actor: { select: { name: true, email: true } },
    },
  });

  return (
    <div className="space-y-5">
      <h1 className="text-base font-semibold text-text-primary">Platform Activity</h1>

      <section className="bg-surface border border-border rounded-lg overflow-hidden">
        {events.length === 0 ? (
          <div className="py-16 text-center">
            <p className="text-sm text-text-muted">No activity recorded yet.</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="border-b border-border">
              <tr>
                {['Time', 'Tenant', 'Action', 'Actor', 'Severity'].map((h) => (
                  <th key={h} className="text-left text-xs text-text-muted font-medium px-4 py-3">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {events.map((e) => (
                <tr key={e.id} className="border-b border-border/50 hover:bg-surface-raised/50 transition-colors">
                  <td className="px-4 py-2.5 text-xs text-text-muted tabular-nums whitespace-nowrap">
                    {e.createdAt.toLocaleString('en-GB', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })}
                  </td>
                  <td className="px-4 py-2.5">
                    {e.tenant ? (
                      <a href={`/t/${e.tenant.slug}`} className="text-xs text-brand-emerald hover:underline">{e.tenant.name}</a>
                    ) : (
                      <span className="text-xs text-text-muted">Platform</span>
                    )}
                  </td>
                  <td className="px-4 py-2.5 text-xs font-mono text-text-primary">{e.action}</td>
                  <td className="px-4 py-2.5 text-xs text-text-muted">
                    {e.actor?.name ?? e.actor?.email ?? e.actorKind}
                  </td>
                  <td className="px-4 py-2.5">
                    <span className={`text-xs ${
                      e.severity === 'CRITICAL' ? 'text-red-500' :
                      e.severity === 'ERROR' ? 'text-red-400' :
                      e.severity === 'WARN' ? 'text-brand-amber' :
                      'text-text-muted'
                    }`}>
                      {e.severity}
                    </span>
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
