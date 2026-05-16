import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';
import { Users } from 'lucide-react';

export const metadata = { title: 'Agency Team' };

export default async function AgencyTeamPage({ params }: { params: Promise<{ slug: string }> }) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const agency = await db.tenant.findFirst({
    where: { slug, plan: 'AGENCY_PARTNER' },
    select: { id: true, name: true },
  });
  if (!agency) return null;

  const members = await db.userRole.findMany({
    where: { tenantId: agency.id, revokedAt: null },
    include: { user: { select: { id: true, name: true, email: true } } },
    orderBy: { grantedAt: 'asc' },
  });

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <h1 className="text-base font-semibold text-text-primary">Agency Team</h1>
        <button className="flex items-center gap-1.5 px-3 py-1.5 bg-brand-emerald text-canvas text-xs font-medium rounded-md hover:bg-emerald-500 transition-colors">
          Invite member
        </button>
      </div>

      <section className="bg-surface border border-border rounded-lg overflow-hidden">
        {members.length === 0 ? (
          <div className="py-16 text-center">
            <Users className="w-10 h-10 text-text-muted mx-auto mb-3" />
            <p className="text-sm text-text-muted">No team members yet</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="border-b border-border">
              <tr>
                {['Member', 'Role', 'Added'].map((h) => (
                  <th key={h} className="text-left text-xs text-text-muted font-medium px-4 py-3">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {members.map((m) => (
                <tr key={m.id} className="border-b border-border/50">
                  <td className="px-4 py-3">
                    <p className="text-sm text-text-primary">{m.user.name ?? '—'}</p>
                    <p className="text-xs text-text-muted">{m.user.email}</p>
                  </td>
                  <td className="px-4 py-3 text-xs text-text-secondary">{m.role.replace('AGENCY_', '')}</td>
                  <td className="px-4 py-3 text-xs text-text-muted">{m.grantedAt.toLocaleDateString('en-GB')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
