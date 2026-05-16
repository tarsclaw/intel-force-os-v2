import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';
import { CheckCircle, AlertTriangle, XCircle } from 'lucide-react';

export const metadata = { title: 'System' };

export default async function SystemPage() {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  let dbOk = false;
  try {
    await db.$queryRaw`SELECT 1`;
    dbOk = true;
  } catch { /* db unavailable */ }

  const recentDeployments = await db.deployment.findMany({
    orderBy: { deployedAt: 'desc' },
    take: 10,
  }).catch(() => []);

  const systemChecks = [
    { label: 'Postgres', status: dbOk ? 'ok' : 'error', detail: dbOk ? 'Responsive' : 'Connection failed' },
    { label: 'Cloudflare Worker', status: 'unknown', detail: 'Check wrangler tail for live status' },
    { label: 'Clerk Auth', status: 'ok', detail: 'Session active' },
    { label: 'Temporal', status: 'unknown', detail: 'Connect Temporal Cloud to verify' },
    { label: 'Secrets Vault', status: 'unknown', detail: 'Deploy secrets-vault service to verify' },
  ];

  return (
    <div className="space-y-5">
      <h1 className="text-base font-semibold text-text-primary">System</h1>

      {/* Status checks */}
      <section className="bg-surface border border-border rounded-lg p-4">
        <h2 className="text-sm font-medium text-text-primary mb-3">Component health</h2>
        <div className="space-y-2">
          {systemChecks.map((check) => (
            <div key={check.label} className="flex items-center gap-3">
              {check.status === 'ok' ? (
                <CheckCircle className="w-4 h-4 text-brand-emerald shrink-0" />
              ) : check.status === 'error' ? (
                <XCircle className="w-4 h-4 text-red-400 shrink-0" />
              ) : (
                <AlertTriangle className="w-4 h-4 text-text-muted shrink-0" />
              )}
              <span className="text-sm text-text-primary w-32 shrink-0">{check.label}</span>
              <span className="text-xs text-text-muted">{check.detail}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Deployments */}
      <section className="bg-surface border border-border rounded-lg p-4">
        <h2 className="text-sm font-medium text-text-primary mb-3">Deployment history</h2>
        {recentDeployments.length === 0 ? (
          <p className="text-xs text-text-muted">No deployments recorded. Push to main to trigger CI/CD.</p>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                {['Component', 'Version', 'Env', 'SHA', 'Deployed'].map((h) => (
                  <th key={h} className="text-left text-xs text-text-muted font-medium pb-2 pr-4">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {recentDeployments.map((d) => (
                <tr key={d.id} className="border-b border-border/50">
                  <td className="py-2 pr-4 text-sm text-text-primary font-mono">{d.component}</td>
                  <td className="py-2 pr-4 text-xs font-mono text-text-secondary">{d.version}</td>
                  <td className="py-2 pr-4 text-xs text-text-muted">{d.env}</td>
                  <td className="py-2 pr-4 text-xs font-mono text-text-muted">{d.sha?.slice(0, 7) ?? '—'}</td>
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
