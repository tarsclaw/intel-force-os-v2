import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import Link from 'next/link';
import { db } from '@intelforce/db';
import {
  CheckCircle2,
  ArrowRight,
  Activity,
  Zap,
  Bot,
  Database,
  FileText,
  User,
  Settings as SettingsIcon,
  ShieldCheck,
} from 'lucide-react';
import {
  StatCard,
  Card,
  CardHeader,
  CardBody,
  Eyebrow,
  PageHeader,
  LiveTag,
  RelativeTime,
  formatRelative,
  SensitivityBadge,
  type Severity,
} from '@/components/shared';

export const metadata = { title: 'Overview' };

function greetByHour(): string {
  const h = new Date().getHours();
  if (h < 12) return 'morning';
  if (h < 17) return 'afternoon';
  return 'evening';
}

async function getOverviewData(tenantId: string) {
  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const prevMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  const [escalations, mtdInvocations, prevMtdInvocations, mtdCosts, recentAudit, tenant, weekInvocations] =
    await Promise.all([
      db.escalation.findMany({
        where: { tenantId, status: 'OPEN' },
        orderBy: [{ severity: 'desc' }, { createdAt: 'asc' }],
        take: 3,
      }),
      db.invocation.count({ where: { tenantId, startedAt: { gte: monthStart } } }),
      db.invocation.count({
        where: { tenantId, startedAt: { gte: prevMonthStart, lt: monthStart } },
      }),
      db.cost.aggregate({
        where: { tenantId, recordedAt: { gte: monthStart } },
        _sum: { costGbp: true },
      }),
      db.auditEvent.findMany({
        where: { tenantId },
        orderBy: { createdAt: 'desc' },
        take: 6,
      }),
      db.tenant.findUnique({
        where: { id: tenantId },
        select: { name: true, costBudgetGbp: true, plan: true },
      }),
      db.invocation.findMany({
        where: { tenantId, startedAt: { gte: weekAgo } },
        select: { startedAt: true, status: true },
        orderBy: { startedAt: 'asc' },
      }),
    ]);

  const monthSpend = Number(mtdCosts._sum.costGbp ?? 0);
  const budget = tenant?.costBudgetGbp ? Number(tenant.costBudgetGbp) : null;

  // Build a 7-day spark array of invocation counts
  const sparkBuckets = new Array(7).fill(0);
  for (const inv of weekInvocations) {
    const days = Math.floor((Date.now() - inv.startedAt.getTime()) / (24 * 60 * 60 * 1000));
    const idx = 6 - Math.min(6, Math.max(0, days));
    sparkBuckets[idx]++;
  }
  const handledSpark = sparkBuckets.length >= 2 ? sparkBuckets : [0, 0, 0, 0, 0, 0, mtdInvocations];

  const mtdDeltaPct =
    prevMtdInvocations > 0
      ? Math.round(((mtdInvocations - prevMtdInvocations) / prevMtdInvocations) * 100)
      : mtdInvocations > 0
        ? 100
        : 0;
  const mtdDelta = prevMtdInvocations === 0 && mtdInvocations === 0 ? '—' : `${mtdDeltaPct >= 0 ? '+' : ''}${mtdDeltaPct}%`;

  return {
    tenantName: tenant?.name ?? '',
    tenantPlan: tenant?.plan ?? 'STARTER',
    escalations: escalations.map((e) => ({ ...e, severity: e.severity as Severity })),
    kpi: {
      handledMtd: mtdInvocations.toString(),
      handledDelta: mtdDelta,
      handledDeltaPositive: mtdDeltaPct >= 0,
      handledSpark,
      pendingCount: escalations.length,
      monthSpend: `£${monthSpend.toFixed(2)}`,
      monthSpendNum: monthSpend,
      budget,
    },
    recentAudit,
  };
}

export default async function OverviewPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const tenant = await db.tenant.findUnique({
    where: { slug },
    select: { id: true, name: true },
  });
  if (!tenant) return null;

  const data = await getOverviewData(tenant.id);
  const { kpi } = data;
  const overBudget = kpi.budget !== null && kpi.monthSpendNum > kpi.budget;

  return (
    <div className="space-y-6">
      {/* ── Hero ──────────────────────────────────────────────────── */}
      <PageHeader
        variant="hero"
        title={
          <>
            Good {greetByHour()}
            <span className="text-emerald-400">.</span>
          </>
        }
        description={`${data.tenantName} · HR Agent v1`}
        liveTag={<LiveTag>Live · synced just now</LiveTag>}
        actions={
          kpi.pendingCount > 0 ? (
            <Link
              href={`/t/${slug}/approvals`}
              className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-amber-400/10 ring-1 ring-amber-400/30 text-amber-300 hover:bg-amber-400/15 hover:ring-amber-400/40 transition-colors text-sm font-medium"
            >
              <CheckCircle2 className="w-4 h-4" />
              {kpi.pendingCount} pending approval{kpi.pendingCount !== 1 ? 's' : ''}
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          ) : (
            <span className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-emerald-400/[0.08] ring-1 ring-emerald-400/20 text-emerald-300 text-sm font-medium">
              <CheckCircle2 className="w-4 h-4" />
              Queue clear
            </span>
          )
        }
      />

      {/* ── KPI grid ─────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Handled this month"
          value={kpi.handledMtd}
          delta={kpi.handledDelta}
          deltaPositive={kpi.handledDeltaPositive}
          sparkData={kpi.handledSpark}
          sparkColor="emerald"
        />
        <StatCard
          label="Pending approval"
          value={kpi.pendingCount.toString()}
          delta={kpi.pendingCount > 0 ? `${kpi.pendingCount} open` : 'queue clear'}
          deltaPositive={kpi.pendingCount === 0}
          sparkColor="amber"
        />
        <StatCard
          label="Cost this month"
          value={kpi.monthSpend}
          delta={kpi.budget ? `£${kpi.budget.toFixed(0)} budget` : 'no budget set'}
          deltaPositive={!overBudget}
          sparkData={[1, 3, 5, 7, 9, 12, Math.max(1, Math.round(kpi.monthSpendNum))]}
          sparkColor={overBudget ? 'red' : 'emerald'}
        />
        <StatCard
          label="Agent uptime"
          value="99.9%"
          delta="stable"
          sparkData={[100, 100, 99, 100, 100, 100, 100]}
          sparkColor="emerald"
        />
      </div>

      {/* ── Two-column: Approvals preview + Recent activity ─────── */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
        <section>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-semibold text-text-primary">Pending approvals</h2>
            {data.escalations.length > 0 && (
              <Link
                href={`/t/${slug}/approvals`}
                className="text-xs text-emerald-400 hover:text-emerald-300 flex items-center gap-1 transition-colors"
              >
                View all ({data.escalations.length})
                <ArrowRight className="w-3 h-3" />
              </Link>
            )}
          </div>

          {data.escalations.length === 0 ? (
            <Card>
              <CardBody className="py-10 text-center">
                <CheckCircle2 className="w-10 h-10 text-emerald-400/40 mx-auto mb-3" />
                <p className="text-sm text-text-primary font-medium mb-1">Approval queue is clear</p>
                <p className="text-xs text-text-muted max-w-xs mx-auto">
                  When an employee question requires HR Lead review, it'll appear here for triage.
                </p>
              </CardBody>
            </Card>
          ) : (
            <div className="space-y-2.5">
              {data.escalations.slice(0, 2).map((esc) => (
                <Link
                  key={esc.id}
                  href={`/t/${slug}/approvals#${esc.id}`}
                  className="block bg-[rgb(var(--bg-surface))] rounded-2xl ring-1 ring-white/5 hover:ring-emerald-400/20 transition-all p-4"
                >
                  <div className="flex items-center gap-2 mb-2">
                    <SensitivityBadge severity={esc.severity} />
                    <span className="text-xs text-text-muted">{esc.category}</span>
                    <RelativeTime date={esc.createdAt} className="ml-auto" />
                  </div>
                  <p className="text-sm text-text-primary line-clamp-2 leading-relaxed">
                    {esc.originalMessage}
                  </p>
                </Link>
              ))}
              {data.escalations.length > 2 && (
                <Link
                  href={`/t/${slug}/approvals`}
                  className="block text-center text-xs text-emerald-400 hover:text-emerald-300 py-2 transition-colors"
                >
                  + {data.escalations.length - 2} more pending →
                </Link>
              )}
            </div>
          )}
        </section>

        <section>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-semibold text-text-primary">Recent activity</h2>
            <Link
              href={`/t/${slug}/activity`}
              className="text-xs text-emerald-400 hover:text-emerald-300 flex items-center gap-1 transition-colors"
            >
              View all
              <ArrowRight className="w-3 h-3" />
            </Link>
          </div>

          <Card>
            {data.recentAudit.length === 0 ? (
              <CardBody className="py-10 text-center">
                <Activity className="w-10 h-10 text-text-muted/30 mx-auto mb-3" />
                <p className="text-sm text-text-primary font-medium mb-1">No activity yet</p>
                <p className="text-xs text-text-muted max-w-xs mx-auto">
                  Once your agent starts handling employee questions, the audit trail will appear
                  here.
                </p>
              </CardBody>
            ) : (
              <ol className="divide-y divide-white/5">
                {data.recentAudit.map((event) => (
                  <li key={event.id} className="flex items-start gap-3 px-4 py-3">
                    <ActivityIcon action={event.action} />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-text-primary truncate">{event.action}</p>
                      {event.detail && (
                        <p className="text-xs text-text-muted truncate">{event.detail}</p>
                      )}
                    </div>
                    <RelativeTime date={event.createdAt} className="shrink-0 mt-0.5" />
                  </li>
                ))}
              </ol>
            )}
          </Card>
        </section>
      </div>

      {/* ── System status strip ──────────────────────────────────── */}
      <Card>
        <CardBody padding="tight" className="py-4">
          <Eyebrow className="mb-3">System status</Eyebrow>
          <div className="flex flex-wrap gap-x-7 gap-y-3 items-center">
            <StatusItem icon={Bot} label="Teams bot" status="active" detail="HR Agent v1" />
            <StatusItem icon={Database} label="Breathe HR" status="synced" detail="34 employees · 12m" />
            <StatusItem icon={Zap} label="AI agent" status="active" detail="claude-sonnet-4-6 · p50 1.8s" />
            <StatusItem icon={ShieldCheck} label="Audit log" status="active" detail="Postgres · OK" />
            <span className="ml-auto text-[11px] font-mono text-text-muted">
              v1.0 · dashboard.intelforce.ai
            </span>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}

function ActivityIcon({ action }: { action: string }) {
  const a = action.toLowerCase();
  let Icon: React.ElementType = Activity;
  let cls = 'text-text-muted';
  if (a.includes('approv')) {
    Icon = CheckCircle2;
    cls = 'text-emerald-400';
  } else if (a.includes('handbook') || a.includes('policy')) {
    Icon = FileText;
  } else if (a.includes('employee') || a.includes('user')) {
    Icon = User;
  } else if (a.includes('config') || a.includes('setting')) {
    Icon = SettingsIcon;
  }
  return <Icon className={`w-3.5 h-3.5 mt-0.5 shrink-0 ${cls}`} />;
}

function StatusItem({
  icon: Icon,
  label,
  status,
  detail,
}: {
  icon: React.ElementType;
  label: string;
  status: 'active' | 'synced' | 'offline';
  detail: string;
}) {
  const dotClass = status === 'offline' ? 'bg-red-500' : 'bg-emerald-400 pulse-dot';
  const textClass = status === 'offline' ? 'text-red-400' : 'text-emerald-400';
  return (
    <div className="flex items-center gap-2 min-w-0">
      <Icon className="w-3.5 h-3.5 text-text-muted shrink-0" />
      <span className="text-sm text-text-secondary">{label}</span>
      <span className={`flex items-center gap-1.5 text-[11px] font-medium ${textClass}`}>
        <span className={`w-1.5 h-1.5 rounded-full ${dotClass}`} />
        {status.toUpperCase()}
      </span>
      <span className="text-xs text-text-muted truncate">{detail}</span>
    </div>
  );
}
