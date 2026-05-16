import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';
import { CheckCircle2, Inbox, Clock, History } from 'lucide-react';
import {
  PageHeader,
  StatTile,
  Card,
  CardBody,
  CardHeader,
  StatusPill,
  RelativeTime,
  type Severity,
} from '@/components/shared';
import { ApprovalCard } from '../../../../components/approvals/approval-card';
import { FilterChips } from '../../../../components/approvals/filter-chips';

export const metadata = { title: 'Approvals' };

const severityOrder: Record<string, number> = {
  CRITICAL: 0,
  HIGH: 1,
  MEDIUM: 2,
  LOW: 3,
};

export default async function ApprovalsPage({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ sev?: string }>;
}) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const { sev: sevParam } = await searchParams;

  const tenant = await db.tenant.findUnique({
    where: { slug },
    select: { id: true, name: true },
  });
  if (!tenant) return null;

  const startOfDay = new Date(new Date().setHours(0, 0, 0, 0));

  const [allOpen, resolvedToday, resolvedTotal] = await Promise.all([
    db.escalation.findMany({
      where: { tenantId: tenant.id, status: 'OPEN' },
      orderBy: { createdAt: 'asc' },
      take: 100,
    }),
    db.escalation.findMany({
      where: {
        tenantId: tenant.id,
        status: { in: ['RESOLVED', 'WONT_FIX'] },
        resolvedAt: { gte: startOfDay },
      },
      orderBy: { resolvedAt: 'desc' },
      take: 30,
    }),
    db.escalation.count({
      where: {
        tenantId: tenant.id,
        status: { in: ['RESOLVED', 'WONT_FIX'] },
        resolvedAt: { gte: startOfDay },
      },
    }),
  ]);

  // Counts for filter chips
  const counts = {
    all: allOpen.length,
    critical: allOpen.filter((e) => e.severity === 'CRITICAL').length,
    high: allOpen.filter((e) => e.severity === 'HIGH').length,
    medium: allOpen.filter((e) => e.severity === 'MEDIUM').length,
    low: allOpen.filter((e) => e.severity === 'LOW').length,
  };

  // Apply severity filter from URL
  const filtered = sevParam
    ? allOpen.filter((e) => e.severity === sevParam.toUpperCase())
    : allOpen;

  // Sort by severity (critical first), then time
  const sorted = [...filtered].sort((a, b) => {
    const cmp = (severityOrder[a.severity] ?? 4) - (severityOrder[b.severity] ?? 4);
    if (cmp !== 0) return cmp;
    return a.createdAt.getTime() - b.createdAt.getTime();
  });

  // Compute average response time for resolved today
  const avgMs =
    resolvedToday.length > 0
      ? resolvedToday.reduce((sum, esc) => {
          if (!esc.resolvedAt) return sum;
          return sum + (esc.resolvedAt.getTime() - esc.createdAt.getTime());
        }, 0) / resolvedToday.length
      : 0;
  const avgMin = Math.round(avgMs / 60000);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Approvals"
        description={
          allOpen.length > 0
            ? `${allOpen.length} pending · sorted by severity · all require your review before sending`
            : 'All clear — nothing waiting for review'
        }
        actions={
          allOpen.length > 0 ? (
            <StatusPill tone="warn" showDot pulse className="text-xs px-3 py-1 ring-1">
              {allOpen.length} pending
            </StatusPill>
          ) : (
            <StatusPill tone="good" className="text-xs px-3 py-1 ring-1">
              Queue clear
            </StatusPill>
          )
        }
      />

      {/* KPI strip — 4 tiles (matches design language) */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <StatTile
          label="Open queue"
          value={allOpen.length.toString()}
          hint={
            allOpen.length === 0
              ? 'Nothing pending'
              : allOpen.length === 1
                ? '1 awaiting review'
                : `${allOpen.length} awaiting review`
          }
          icon={Inbox}
          tone={allOpen.length > 0 ? 'warn' : 'good'}
        />
        <StatTile
          label="Critical / high"
          value={(counts.critical + counts.high).toString()}
          hint={`${counts.critical} critical · ${counts.high} high`}
          icon={CheckCircle2}
          tone={counts.critical > 0 ? 'danger' : counts.high > 0 ? 'warn' : 'neutral'}
        />
        <StatTile
          label="Resolved today"
          value={resolvedTotal.toString()}
          hint={
            resolvedTotal === 0
              ? 'No actions yet today'
              : `${resolvedTotal} closed by HR Lead`
          }
          icon={History}
          tone="neutral"
        />
        <StatTile
          label="Avg response time"
          value={resolvedToday.length === 0 ? '—' : `${avgMin}m`}
          hint={
            resolvedToday.length === 0
              ? 'No resolutions today'
              : `${resolvedToday.length} samples`
          }
          icon={Clock}
          tone={avgMin > 60 ? 'warn' : 'good'}
        />
      </div>

      {/* Filter chips */}
      {allOpen.length > 0 && <FilterChips counts={counts} />}

      {/* Body */}
      {allOpen.length === 0 ? (
        <Card>
          <CardBody className="py-16 text-center">
            <CheckCircle2 className="w-12 h-12 text-emerald-400/30 mx-auto mb-4" />
            <p className="font-display text-lg font-light text-text-primary mb-1">
              Approval queue is clear
            </p>
            <p className="text-sm text-text-muted max-w-sm mx-auto leading-relaxed">
              When employees ask HR questions, drafted replies will appear here for your review.
            </p>
          </CardBody>
        </Card>
      ) : sorted.length === 0 ? (
        <Card>
          <CardBody className="py-12 text-center">
            <p className="text-sm text-text-muted">
              No approvals match the <strong className="text-text-primary">{sevParam}</strong>{' '}
              filter.
            </p>
          </CardBody>
        </Card>
      ) : (
        <div className="space-y-4">
          {sorted.map((esc) => (
            <ApprovalCard
              key={esc.id}
              id={esc.id}
              correlationId={esc.correlationId ?? null}
              tenantId={tenant.id}
              tenantSlug={slug}
              severity={esc.severity as Severity}
              category={esc.category}
              originalMessage={esc.originalMessage}
              draftReply={esc.agentReasoning ?? null}
              handbookSections={null}
              createdAt={esc.createdAt}
              employeeRef={
                esc.employeeAadId ? `${esc.employeeAadId.slice(0, 6)}…` : undefined
              }
            />
          ))}
        </div>
      )}

      {/* Resolved today */}
      {resolvedToday.length > 0 && (
        <Card>
          <CardHeader
            icon={History}
            title="Resolved today"
            subtitle={`${resolvedToday.length} closed`}
          />
          <ul className="divide-y divide-white/5">
            {resolvedToday.map((esc) => {
              const wasRejected = esc.status === 'WONT_FIX';
              return (
                <li
                  key={esc.id}
                  className="px-5 py-3 flex items-center gap-3 hover:bg-white/[0.02] transition-colors"
                >
                  <span
                    className={
                      wasRejected
                        ? 'w-1.5 h-1.5 rounded-full bg-red-500 shrink-0'
                        : 'w-1.5 h-1.5 rounded-full bg-emerald-400 shrink-0'
                    }
                  />
                  <p className="text-sm text-text-secondary truncate flex-1">
                    {esc.originalMessage}
                  </p>
                  <span className="text-[10px] font-mono uppercase tracking-wider text-text-muted shrink-0">
                    {wasRejected ? 'rejected' : 'approved'}
                  </span>
                  {esc.resolvedAt && <RelativeTime date={esc.resolvedAt} />}
                </li>
              );
            })}
          </ul>
        </Card>
      )}
    </div>
  );
}
