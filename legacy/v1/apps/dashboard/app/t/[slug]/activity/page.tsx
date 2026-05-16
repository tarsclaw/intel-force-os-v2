import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';
import {
  CheckCircle,
  AlertTriangle,
  Plug,
  Unplug,
  KeyRound,
  Settings,
  User,
  Webhook,
  Activity,
  Download,
  Inbox,
  Clock,
  AlertOctagon,
} from 'lucide-react';
import { cn } from '../../../../lib/cn';
import {
  PageHeader,
  StatTile,
  Card,
  CardBody,
  Eyebrow,
  formatRelative,
} from '@/components/shared';
import { ActivityFilters } from '../../../../components/operations/activity-filters';
import { AgentActivityLog } from '../../../../components/operations/agent-activity-log';
import { loadAgentActivity } from '../../../../lib/agent-activity';

export const metadata = { title: 'Activity' };

const actionIcons: Record<string, React.ElementType> = {
  'agent.': Activity,
  'escalation.': AlertTriangle,
  'integration.connect': Plug,
  'integration.disconnect': Unplug,
  'secret.rotate': KeyRound,
  'config.': Settings,
  'user.': User,
  'webhook.': Webhook,
};

function getIcon(action: string): React.ElementType {
  for (const [prefix, icon] of Object.entries(actionIcons)) {
    if (action.startsWith(prefix)) return icon;
  }
  return CheckCircle;
}

const severityChip: Record<string, { dot: string; text: string; bg: string }> = {
  INFO: { dot: 'bg-zinc-500', text: 'text-zinc-400', bg: 'bg-zinc-500/10' },
  WARN: { dot: 'bg-amber-400', text: 'text-amber-300', bg: 'bg-amber-400/10' },
  ERROR: { dot: 'bg-red-400', text: 'text-red-400', bg: 'bg-red-400/10' },
  CRITICAL: { dot: 'bg-red-500', text: 'text-red-300', bg: 'bg-red-500/15' },
};

function dayLabel(d: Date): string {
  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  if (d.toDateString() === today.toDateString()) return 'Today';
  if (d.toDateString() === yesterday.toDateString()) return 'Yesterday';
  return d.toLocaleDateString('en-GB', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  });
}

export default async function ActivityPage({
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

  const tenant = await db.tenant.findUnique({ where: { slug }, select: { id: true } });
  if (!tenant) return null;

  const sevWhere = sevParam && sevParam !== 'all' ? { severity: sevParam as 'INFO' | 'WARN' | 'ERROR' | 'CRITICAL' } : {};

  const agentRows = await loadAgentActivity(tenant.id);

  const [events, totalAll, totalInfo, totalWarn, totalError, totalCritical, errorsToday] =
    await Promise.all([
      db.auditEvent.findMany({
        where: { tenantId: tenant.id, ...sevWhere },
        orderBy: { createdAt: 'desc' },
        take: 100,
        include: { actor: { select: { name: true, email: true } } },
      }),
      db.auditEvent.count({ where: { tenantId: tenant.id } }),
      db.auditEvent.count({ where: { tenantId: tenant.id, severity: 'INFO' } }),
      db.auditEvent.count({ where: { tenantId: tenant.id, severity: 'WARN' } }),
      db.auditEvent.count({ where: { tenantId: tenant.id, severity: 'ERROR' } }),
      db.auditEvent.count({ where: { tenantId: tenant.id, severity: 'CRITICAL' } }),
      db.auditEvent.count({
        where: {
          tenantId: tenant.id,
          severity: { in: ['ERROR', 'CRITICAL'] },
          createdAt: { gte: new Date(new Date().setHours(0, 0, 0, 0)) },
        },
      }),
    ]);

  // Group events by day
  const grouped: { day: string; date: Date; events: typeof events }[] = [];
  let currentDay: string | null = null;
  for (const event of events) {
    const dl = dayLabel(event.createdAt);
    if (dl !== currentDay) {
      grouped.push({ day: dl, date: event.createdAt, events: [event] });
      currentDay = dl;
    } else {
      grouped[grouped.length - 1].events.push(event);
    }
  }

  const lastEvent = events[0];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Activity"
        description={`${totalAll.toLocaleString()} total events recorded · last ${events.length} shown`}
        actions={
          <button className="flex items-center gap-2 text-xs font-medium px-3.5 py-2 rounded-lg bg-white/[0.04] ring-1 ring-white/10 text-text-secondary hover:text-text-primary hover:ring-white/20 transition-all">
            <Download className="w-3.5 h-3.5" />
            Export CSV
          </button>
        }
      />

      {/* KPI strip */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <StatTile
          label="Total events"
          value={totalAll.toLocaleString()}
          hint="All time"
          icon={Inbox}
          tone="neutral"
        />
        <StatTile
          label="Errors today"
          value={errorsToday.toString()}
          hint={errorsToday > 0 ? 'Investigate immediately' : 'Clean run'}
          icon={AlertOctagon}
          tone={errorsToday > 0 ? 'danger' : 'good'}
        />
        <StatTile
          label="Last event"
          value={
            lastEvent ? (
              <span suppressHydrationWarning>{formatRelative(lastEvent.createdAt)}</span>
            ) : (
              '—'
            )
          }
          hint={lastEvent?.action ?? 'No activity yet'}
          icon={Clock}
          tone="neutral"
        />
        <StatTile
          label="Critical / error"
          value={(totalCritical + totalError).toLocaleString()}
          hint={`${totalCritical} critical · ${totalError} error`}
          icon={AlertTriangle}
          tone={totalCritical > 0 ? 'danger' : totalError > 0 ? 'warn' : 'neutral'}
        />
      </div>

      {/* Agent activity log — derived from real Invocation + Escalation tables */}
      <AgentActivityLog rows={agentRows} />

      {/* Audit-event log filters (system events, not agent runs) */}
      <ActivityFilters
        totals={{
          all: totalAll,
          INFO: totalInfo,
          WARN: totalWarn,
          ERROR: totalError,
          CRITICAL: totalCritical,
        }}
      />

      {/* Body */}
      {grouped.length === 0 ? (
        <Card>
          <CardBody className="py-16 text-center">
            <Activity className="w-10 h-10 text-text-muted/30 mx-auto mb-3" />
            <p className="text-sm text-text-primary font-medium mb-1">
              {sevParam && sevParam !== 'all'
                ? `No ${sevParam.toLowerCase()} events`
                : 'No activity recorded yet'}
            </p>
            <p className="text-xs text-text-muted max-w-sm mx-auto">
              Activity appears here when employees interact with the agent or admins change config.
            </p>
          </CardBody>
        </Card>
      ) : (
        <div className="space-y-6">
          {grouped.map(({ day, events: dayEvents }) => (
            <section key={day}>
              <div className="sticky top-0 z-10 -mx-4 sm:-mx-6 px-4 sm:px-6 py-2 bg-[rgb(var(--bg-canvas))]/90 backdrop-blur flex items-baseline gap-3 mb-3">
                <Eyebrow>{day}</Eyebrow>
                <span className="text-[10px] font-mono text-text-muted">
                  {dayEvents.length} event{dayEvents.length !== 1 ? 's' : ''}
                </span>
              </div>
              <Card>
                <ul className="divide-y divide-white/5">
                  {dayEvents.map((event) => {
                    const Icon = getIcon(event.action);
                    const sev = event.severity as keyof typeof severityChip;
                    const chip = severityChip[sev] ?? severityChip.INFO;
                    return (
                      <li
                        key={event.id}
                        className="flex items-start gap-3 px-4 py-3.5 hover:bg-white/[0.02] transition-colors group"
                      >
                        <div
                          className={cn(
                            'w-7 h-7 rounded-lg flex items-center justify-center shrink-0 mt-0.5 transition-colors',
                            chip.bg,
                          )}
                        >
                          <Icon className={cn('w-3.5 h-3.5', chip.text)} />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 flex-wrap">
                            <p className="text-sm text-text-primary font-medium truncate">
                              {event.action}
                            </p>
                            {event.targetLabel && (
                              <span className="text-xs text-text-secondary">
                                · {event.targetLabel}
                              </span>
                            )}
                            <span
                              className={cn(
                                'font-mono uppercase tracking-wider text-[9px] px-1.5 py-0.5 rounded',
                                chip.bg,
                                chip.text,
                              )}
                            >
                              {sev}
                            </span>
                          </div>
                          {event.detail && (
                            <p className="text-xs text-text-muted mt-0.5 line-clamp-1 group-hover:line-clamp-none transition-all">
                              {event.detail}
                            </p>
                          )}
                          {event.actor && (
                            <p className="text-[11px] text-text-muted mt-0.5">
                              by {event.actor.name ?? event.actor.email}
                              {event.actorKind && (
                                <span className="ml-1.5 font-mono uppercase tracking-wider text-[9px] text-text-muted/70">
                                  · {event.actorKind}
                                </span>
                              )}
                            </p>
                          )}
                        </div>
                        <time
                          dateTime={event.createdAt.toISOString()}
                          className="text-[11px] font-mono text-text-muted tabular-nums shrink-0 mt-0.5"
                        >
                          {event.createdAt.toLocaleTimeString('en-GB', {
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </time>
                      </li>
                    );
                  })}
                </ul>
              </Card>
            </section>
          ))}
          {events.length === 100 && (
            <p className="text-center text-xs text-text-muted py-2">
              Showing the most recent 100 events. Export CSV for full history.
            </p>
          )}
        </div>
      )}
    </div>
  );
}
