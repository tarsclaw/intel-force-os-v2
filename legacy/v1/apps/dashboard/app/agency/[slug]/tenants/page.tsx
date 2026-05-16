import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';
import { Building2, Plus } from 'lucide-react';

export const metadata = { title: 'Sub-tenants' };

export default async function AgencyTenantsPage({ params }: { params: Promise<{ slug: string }> }) {
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
  });

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <h1 className="text-base font-semibold text-text-primary">Sub-tenants</h1>
        <a
          href={`/agency/${slug}/tenants/new`}
          className="flex items-center gap-1.5 px-3 py-1.5 bg-brand-emerald text-canvas text-xs font-medium rounded-md hover:bg-emerald-500 transition-colors"
        >
          <Plus className="w-3.5 h-3.5" />
          Add tenant
        </a>
      </div>

      <section className="bg-surface border border-border rounded-lg overflow-hidden">
        {subTenants.length === 0 ? (
          <div className="py-16 text-center">
            <Building2 className="w-10 h-10 text-text-muted mx-auto mb-3" />
            <p className="text-sm font-medium text-text-primary mb-1">No sub-tenants</p>
            <p className="text-xs text-text-muted">Add the first tenant to this agency portfolio.</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="border-b border-border">
              <tr>
                {['Tenant', 'Plan', 'Status', 'Agents', 'Created', ''].map((h) => (
                  <th key={h} className="text-left text-xs text-text-muted font-medium px-4 py-3">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {subTenants.map((t) => (
                <tr key={t.id} className="border-b border-border/50 hover:bg-surface-raised/50 transition-colors">
                  <td className="px-4 py-3">
                    <p className="text-sm font-medium text-text-primary">{t.name}</p>
                    <p className="text-xs text-text-muted font-mono">/t/{t.slug}</p>
                  </td>
                  <td className="px-4 py-3 text-xs text-text-secondary">{t.plan}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-1.5 py-0.5 rounded ${
                      t.status === 'ACTIVE' ? 'bg-brand-emerald/10 text-brand-emerald' :
                      t.status === 'SUSPENDED' ? 'bg-red-500/10 text-red-400' :
                      'bg-surface-raised text-text-muted'
                    }`}>
                      {t.status}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-xs text-text-muted">{t.agentsEnabled.join(', ') || '—'}</td>
                  <td className="px-4 py-3 text-xs text-text-muted">{t.createdAt.toLocaleDateString('en-GB')}</td>
                  <td className="px-4 py-3">
                    <a href={`/t/${t.slug}`} className="text-xs text-brand-emerald hover:underline">View →</a>
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
