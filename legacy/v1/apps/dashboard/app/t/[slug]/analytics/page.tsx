import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';
import { TrendingUp, TrendingDown, ArrowRight } from 'lucide-react';
import { VolumeChart } from '../../../../components/analytics/volume-chart';
import { CostChart } from '../../../../components/analytics/cost-chart';
import { SeverityBars } from '../../../../components/analytics/severity-bars';
import { PeriodSelector } from '../../../../components/analytics/period-selector';
import {
  StatCard,
  Card,
  CardHeader,
  CardBody,
  PageHeader,
} from '@/components/shared';

export const metadata = { title: 'Analytics' };

type Period = '7d' | '30d' | '90d' | 'mtd';

function periodWindow(period: Period): { start: Date; prevStart: Date; label: string } {
  const now = new Date();
  if (period === 'mtd') {
    const start = new Date(now.getFullYear(), now.getMonth(), 1);
    const prevStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    return {
      start,
      prevStart,
      label: now.toLocaleString('en-GB', { month: 'long', year: 'numeric' }),
    };
  }
  const days = period === '7d' ? 7 : period === '30d' ? 30 : 90;
  const start = new Date(now.getTime() - days * 24 * 60 * 60 * 1000);
  const prevStart = new Date(now.getTime() - days * 2 * 24 * 60 * 60 * 1000);
  return { start, prevStart, label: `Last ${days} days` };
}

async function getAnalyticsData(tenantId: string, period: Period) {
  const { start, prevStart } = periodWindow(period);

  const [invocations, prevInvocationsCount, costs, escalations, prevCosts, tenant] =
    await Promise.all([
      db.invocation.findMany({
        where: { tenantId, startedAt: { gte: start } },
        select: { startedAt: true, status: true },
        orderBy: { startedAt: 'asc' },
      }),
      db.invocation.count({
        where: { tenantId, startedAt: { gte: prevStart, lt: start } },
      }),
      db.cost.findMany({
        where: { tenantId, recordedAt: { gte: start } },
        select: { recordedAt: true, costGbp: true },
        orderBy: { recordedAt: 'asc' },
      }),
      db.escalation.findMany({
        where: { tenantId, createdAt: { gte: start } },
        select: { severity: true, status: true, createdAt: true, resolvedAt: true },
      }),
      db.cost.aggregate({
        where: { tenantId, recordedAt: { gte: prevStart, lt: start } },
        _sum: { costGbp: true },
      }),
      db.tenant.findUnique({
        where: { id: tenantId },
        select: { costBudgetGbp: true, plan: true },
      }),
    ]);

  // Volume by day
  const byDay = new Map<string, number>();
  for (const inv of invocations) {
    const day = inv.startedAt.toISOString().slice(0, 10);
    byDay.set(day, (byDay.get(day) ?? 0) + 1);
  }
  const volumeData = Array.from(byDay.entries())
    .sort()
    .map(([date, count]) => ({ date, count }));

  // Costs by day
  const costByDay = new Map<string, number>();
  for (const c of costs) {
    const day = c.recordedAt.toISOString().slice(0, 10);
    costByDay.set(day, (costByDay.get(day) ?? 0) + Number(c.costGbp));
  }
  const costData = Array.from(costByDay.entries())
    .sort()
    .map(([date, costGbp]) => ({ date, costGbp }));

  const periodSpend = costs.reduce((s, c) => s + Number(c.costGbp), 0);
  const prevPeriodSpend = Number(prevCosts._sum.costGbp ?? 0);

  // Severity distribution
  const sevCount: Record<string, number> = {};
  for (const e of escalations) sevCount[e.severity] = (sevCount[e.severity] ?? 0) + 1;
  const total = escalations.length || 1;
  const severityData = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'].map((s) => ({
    severity: s,
    count: sevCount[s] ?? 0,
    pct: Math.round(((sevCount[s] ?? 0) / total) * 100),
  }));

  // Outcomes
  const outcomes: Record<string, number> = {};
  for (const e of escalations) outcomes[e.status] = (outcomes[e.status] ?? 0) + 1;

  // Avg resolution time
  const resolved = escalations.filter((e) => e.resolvedAt);
  const avgResolutionMs =
    resolved.length > 0
      ? resolved.reduce((sum, e) => sum + (e.resolvedAt!.getTime() - e.createdAt.getTime()), 0) /
        resolved.length
      : 0;
  const avgResolutionMin = Math.round(avgResolutionMs / 60000);

  const successRate =
    invocations.length > 0
      ? Math.round(
          (invocations.filter((i) => i.status === 'SUCCESS').length / invocations.length) * 100,
        )
      : 0;

  // Period-over-period change
  const volumeDeltaPct =
    prevInvocationsCount > 0
      ? Math.round(((invocations.length - prevInvocationsCount) / prevInvocationsCount) * 100)
      : invocations.length > 0
        ? 100
        : 0;
  const costDeltaPct =
    prevPeriodSpend > 0
      ? Math.round(((periodSpend - prevPeriodSpend) / prevPeriodSpend) * 100)
      : periodSpend > 0
        ? 100
        : 0;

  const resolvedCount = outcomes['RESOLVED'] ?? 0;
  const approvalRate = total > 0 ? Math.round((resolvedCount / total) * 100) : 0;

  return {
    volumeData,
    costData,
    severityData,
    periodSpend,
    prevPeriodSpend,
    budget: tenant?.costBudgetGbp ? Number(tenant.costBudgetGbp) : null,
    plan: tenant?.plan ?? 'STARTER',
    kpi: {
      total: invocations.length,
      volumeDeltaPct,
      costDeltaPct,
      successRate,
      approvalRate,
      escalationsTotal: total === 1 && escalations.length === 0 ? 0 : escalations.length,
      avgResolutionMin,
      pendingCount: outcomes['OPEN'] ?? 0,
      resolvedCount,
    },
  };
}

export default async function AnalyticsPage({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ period?: string }>;
}) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const { period: periodParam } = await searchParams;
  const period: Period =
    periodParam === '7d' || periodParam === '30d' || periodParam === '90d' ? periodParam : 'mtd';

  const tenant = await db.tenant.findUnique({
    where: { slug },
    select: { id: true },
  });
  if (!tenant) return null;

  const data = await getAnalyticsData(tenant.id, period);
  const { kpi } = data;
  const window = periodWindow(period);
  const overBudget = data.budget !== null && data.periodSpend > data.budget;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Analytics"
        description={`${window.label} · compared to previous period`}
        actions={<PeriodSelector />}
      />

      {/* KPI tiles with deltas */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Queries handled"
          value={kpi.total.toLocaleString()}
          delta={
            kpi.volumeDeltaPct === 0 && data.volumeData.length === 0
              ? '—'
              : `${kpi.volumeDeltaPct >= 0 ? '+' : ''}${kpi.volumeDeltaPct}% vs prior`
          }
          deltaPositive={kpi.volumeDeltaPct >= 0}
          sparkData={data.volumeData.map((d) => d.count)}
          sparkColor="emerald"
        />
        <StatCard
          label="Cost"
          value={`£${data.periodSpend.toFixed(2)}`}
          delta={
            data.budget
              ? `£${data.budget.toFixed(0)} budget`
              : data.prevPeriodSpend > 0
                ? `${kpi.costDeltaPct >= 0 ? '+' : ''}${kpi.costDeltaPct}%`
                : 'no budget set'
          }
          deltaPositive={!overBudget}
          sparkData={data.costData.map((d) => d.costGbp)}
          sparkColor={overBudget ? 'red' : 'emerald'}
        />
        <StatCard
          label="Approval rate"
          value={kpi.escalationsTotal === 0 ? '—' : `${kpi.approvalRate}%`}
          delta={`${kpi.resolvedCount} approved · ${kpi.pendingCount} open`}
          sparkColor="emerald"
        />
        <StatCard
          label="Success rate"
          value={kpi.total === 0 ? '—' : `${kpi.successRate}%`}
          delta={kpi.total === 0 ? 'no runs yet' : kpi.successRate >= 95 ? 'healthy' : 'investigate'}
          deltaPositive={kpi.successRate >= 95}
          sparkColor={kpi.successRate < 90 ? 'red' : 'emerald'}
        />
      </div>

      {/* Charts grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
        <Card>
          <CardHeader title="Query volume" subtitle="Total queries handled per day" />
          <CardBody>
            {data.volumeData.length === 0 ? (
              <ChartEmpty label="No queries in this period" />
            ) : (
              <VolumeChart data={data.volumeData} />
            )}
          </CardBody>
        </Card>

        <Card>
          <CardHeader
            title="Cost tracking"
            subtitle={data.budget ? `Running total vs £${data.budget.toFixed(0)} budget` : 'Running total — no budget set'}
            accessory={
              data.budget ? (
                <span
                  className={
                    overBudget
                      ? 'text-xs text-red-400 font-mono'
                      : 'text-xs text-emerald-400 font-mono'
                  }
                >
                  {Math.round((data.periodSpend / data.budget) * 100)}%
                </span>
              ) : null
            }
          />
          <CardBody>
            {data.costData.length === 0 ? (
              <ChartEmpty label="No costs recorded" />
            ) : (
              <CostChart data={data.costData} budgetGbp={data.budget} />
            )}
          </CardBody>
        </Card>

        <Card>
          <CardHeader
            title="Sensitivity distribution"
            subtitle="Queries by sensitivity this period"
          />
          <CardBody>
            {kpi.escalationsTotal === 0 ? (
              <ChartEmpty label="No escalations in this period" />
            ) : (
              <div className="py-2">
                <SeverityBars data={data.severityData} />
              </div>
            )}
          </CardBody>
        </Card>

        <Card>
          <CardHeader title="Resolution summary" subtitle="Open vs closed escalations" />
          <CardBody>
            <SummaryRow
              label="Total escalations"
              value={kpi.escalationsTotal.toLocaleString()}
            />
            <SummaryRow label="Approved" value={kpi.resolvedCount.toLocaleString()} />
            <SummaryRow label="Pending review" value={kpi.pendingCount.toLocaleString()} highlight={kpi.pendingCount > 0} />
            <SummaryRow
              label="Avg resolution time"
              value={kpi.avgResolutionMin > 0 ? `${kpi.avgResolutionMin}m` : '—'}
              isLast
            />
          </CardBody>
        </Card>
      </div>

      {/* Period summary banner */}
      <Card>
        <CardBody>
          <div className="flex items-start gap-3">
            {kpi.volumeDeltaPct >= 0 ? (
              <TrendingUp className="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
            ) : (
              <TrendingDown className="w-5 h-5 text-amber-400 shrink-0 mt-0.5" />
            )}
            <div className="flex-1 min-w-0">
              <p className="text-sm text-text-primary mb-1 font-medium">
                {summaryHeadline(kpi.volumeDeltaPct, kpi.total, period)}
              </p>
              <p className="text-xs text-text-muted leading-relaxed max-w-2xl">
                {summaryDetail({
                  total: kpi.total,
                  delta: kpi.volumeDeltaPct,
                  successRate: kpi.successRate,
                  costDelta: kpi.costDeltaPct,
                  spend: data.periodSpend,
                  prevSpend: data.prevPeriodSpend,
                })}
              </p>
            </div>
            <a
              href={`/t/${slug}/activity`}
              className="text-xs text-emerald-400 hover:text-emerald-300 flex items-center gap-1 shrink-0 transition-colors"
            >
              View activity <ArrowRight className="w-3 h-3" />
            </a>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}

function ChartEmpty({ label }: { label: string }) {
  return (
    <div className="py-12 text-center text-xs text-text-muted">{label}</div>
  );
}

function SummaryRow({
  label,
  value,
  highlight = false,
  isLast = false,
}: {
  label: string;
  value: string;
  highlight?: boolean;
  isLast?: boolean;
}) {
  return (
    <div
      className={
        isLast
          ? 'flex items-center justify-between py-2.5'
          : 'flex items-center justify-between py-2.5 border-b border-white/5'
      }
    >
      <span className="text-sm text-text-secondary">{label}</span>
      <span
        className={
          highlight
            ? 'text-sm font-medium text-amber-300 font-mono'
            : 'text-sm font-medium text-text-primary font-mono'
        }
      >
        {value}
      </span>
    </div>
  );
}

function summaryHeadline(deltaPct: number, total: number, period: Period): string {
  if (total === 0) return 'No activity in this period yet.';
  const periodWord = period === 'mtd' ? 'month so far' : period === '7d' ? 'week' : `${period} window`;
  if (Math.abs(deltaPct) < 5) return `Volume is steady — ${total} queries this ${periodWord}.`;
  const direction = deltaPct > 0 ? 'up' : 'down';
  return `Volume is ${direction} ${Math.abs(deltaPct)}% vs the prior period — ${total} queries this ${periodWord}.`;
}

function summaryDetail({
  total,
  delta,
  successRate,
  costDelta,
  spend,
  prevSpend,
}: {
  total: number;
  delta: number;
  successRate: number;
  costDelta: number;
  spend: number;
  prevSpend: number;
}): string {
  const parts: string[] = [];
  if (total > 0) {
    parts.push(`Success rate ${successRate}%`);
  }
  if (spend > 0 || prevSpend > 0) {
    if (prevSpend > 0) {
      parts.push(
        costDelta > 0
          ? `cost up ${Math.abs(costDelta)}% (£${spend.toFixed(2)})`
          : costDelta < 0
            ? `cost down ${Math.abs(costDelta)}% (£${spend.toFixed(2)})`
            : `cost flat (£${spend.toFixed(2)})`,
      );
    } else {
      parts.push(`spend £${spend.toFixed(2)}`);
    }
  }
  if (parts.length === 0) {
    return 'Once the agent handles its first query, deltas and trends will appear here.';
  }
  return parts.join(' · ') + '.';
}
