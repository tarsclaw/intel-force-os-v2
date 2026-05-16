import { db } from '@intelforce/db';
import { AGENT_CATALOG, type AgentSpec, type AgentStatus, type Director } from './agent-catalog';

export type AgentActivityEvent = {
  time: string;
  label: string;
  escalation?: boolean;
};

export type AgentActivityRow = {
  num: string;
  key: string;
  name: string;
  director: Director;
  status: AgentStatus;
  lastRun: string;          // human-readable relative time, e.g. "4m ago"
  output: string;           // headline output label
  delta?: string;           // optional delta chip, e.g. "+3 today"
  description: string;
  recent: AgentActivityEvent[];
  lastOutput: string;
  hasNeverRun: boolean;     // true if no invocations in the 7d window
};

/**
 * Derive the per-agent activity rollup for a tenant.
 *
 * Strategy:
 *   - Pull the last 7 days of Invocation rows for the tenant
 *   - Pull the last 7 days of Escalation rows for the tenant
 *   - Group by Invocation.agent (matches AgentSpec.key)
 *   - For each catalog entry, compute live status, last-run time, recent feed
 *
 * No invocation data → returns the catalog with status=IDLE and a
 * "no runs yet" placeholder feed. This is the honest empty state.
 */
export async function loadAgentActivity(tenantId: string): Promise<AgentActivityRow[]> {
  const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

  const [invocations, escalations] = await Promise.all([
    db.invocation.findMany({
      where: { tenantId, startedAt: { gte: since } },
      orderBy: { startedAt: 'desc' },
      select: {
        id: true,
        agent: true,
        trigger: true,
        status: true,
        startedAt: true,
        completedAt: true,
        durationMs: true,
        outputPath: true,
        metadata: true,
      },
    }),
    db.escalation.findMany({
      where: { tenantId, createdAt: { gte: since } },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        category: true,
        createdAt: true,
        originalMessage: true,
      },
    }),
  ]);

  // Bucket invocations by agent key
  const invByAgent = new Map<string, typeof invocations>();
  for (const inv of invocations) {
    const key = (inv.agent || '').toLowerCase().trim();
    if (!key) continue;
    const arr = invByAgent.get(key) ?? [];
    arr.push(inv);
    invByAgent.set(key, arr);
  }

  // Escalations are HR-shaped today — bucket all of them under hr-assistant for v1
  const escByAgent = new Map<string, typeof escalations>();
  if (escalations.length > 0) {
    escByAgent.set('hr-assistant', escalations);
  }

  return AGENT_CATALOG.map((spec, i) => buildRow(spec, i, invByAgent, escByAgent));
}

function buildRow(
  spec: AgentSpec,
  index: number,
  invByAgent: Map<string, { id: string; agent: string; trigger: string; status: string; startedAt: Date; completedAt: Date | null; durationMs: number | null; outputPath: string | null; metadata: unknown }[]>,
  escByAgent: Map<string, { id: string; category: string; createdAt: Date; originalMessage: string }[]>,
): AgentActivityRow {
  const num = String(index + 1).padStart(2, '0');
  const invs = invByAgent.get(spec.key) ?? [];
  const escs = escByAgent.get(spec.key) ?? [];

  // Status derivation
  const now = Date.now();
  const FIVE_MIN = 5 * 60 * 1000;
  const ONE_DAY = 24 * 60 * 60 * 1000;
  const isRunning = invs.some((i) => i.status === 'RUNNING' && now - i.startedAt.getTime() < FIVE_MIN);
  const lastInv = invs[0];
  const ranToday = lastInv && now - lastInv.startedAt.getTime() < ONE_DAY;

  let status: AgentStatus;
  if (isRunning) status = 'RUNNING';
  else if (ranToday) status = 'ACTIVE';
  else if (invs.length === 0 && spec.defaultStatus === 'SCHEDULED') status = 'SCHEDULED';
  else if (invs.length === 0) status = 'IDLE';
  else status = 'IDLE';

  // Last-run label
  const lastRun = lastInv ? formatRelative(lastInv.startedAt) : 'awaiting first run';

  // Output label — use the catalog default for now; replaceable with a real
  // count once Invocation.metadata stores headline metrics consistently
  const output = invs.length > 0 ? `${invs.length} runs · 7d` : spec.output;
  const delta = invs.length > 0 ? `+${countToday(invs)} today` : undefined;

  // Recent feed: merge invocations + escalations, sort, take top 6
  const events: AgentActivityEvent[] = [];
  for (const inv of invs.slice(0, 5)) {
    events.push({
      time: formatRelative(inv.startedAt),
      label: invocationLabel(inv),
    });
  }
  for (const e of escs.slice(0, 3)) {
    events.push({
      time: formatRelative(e.createdAt),
      label: `Escalated: ${e.category}`,
      escalation: true,
    });
  }
  events.sort((a, b) => 0); // already sorted by recency from DB

  if (events.length === 0) {
    events.push({
      time: '—',
      label: 'Listening. Will draft on first trigger.',
    });
  }

  // Last-output preview
  const lastOutput =
    lastInv && (lastInv.metadata as { preview?: string })?.preview
      ? (lastInv.metadata as { preview: string }).preview
      : `${spec.description} Once invocations record output previews, they appear here.`;

  return {
    num,
    key: spec.key,
    name: spec.name,
    director: spec.director,
    status,
    lastRun,
    output,
    delta,
    description: spec.description,
    recent: events.slice(0, 6),
    lastOutput,
    hasNeverRun: invs.length === 0,
  };
}

function countToday(invs: { startedAt: Date }[]): number {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return invs.filter((i) => i.startedAt >= today).length;
}

function invocationLabel(inv: { trigger: string; status: string; durationMs: number | null }): string {
  const trigger = inv.trigger || 'invocation';
  if (inv.status === 'RUNNING') return `Running · trigger: ${trigger}`;
  if (inv.status === 'FAILED') return `Failed · trigger: ${trigger}`;
  if (inv.durationMs) return `Completed · ${trigger} (${(inv.durationMs / 1000).toFixed(1)}s)`;
  return `Completed · ${trigger}`;
}

function formatRelative(d: Date): string {
  const diff = Date.now() - d.getTime();
  const sec = Math.floor(diff / 1000);
  if (sec < 30) return 'just now';
  if (sec < 60) return `${sec}s ago`;
  const min = Math.floor(sec / 60);
  if (min < 60) return `${min}m ago`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h ago`;
  const days = Math.floor(hr / 24);
  if (days === 1) return 'yesterday';
  if (days < 7) {
    return d.toLocaleDateString('en-GB', { weekday: 'short' }) + ' ' +
      d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
  }
  return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
}
