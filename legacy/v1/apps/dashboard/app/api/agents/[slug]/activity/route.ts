import { NextRequest, NextResponse } from 'next/server';
import { db } from '@intelforce/db';
import { requireTenantAccess } from '@/lib/tenant-access';

// GET /api/agents/[slug]/activity
//
// Returns the data the live AgentWeb canvas needs to feel like an operating
// system rather than a static org chart:
//
//   recent: the 12 most recent invocations (for the scrolling stream strip)
//   buckets: for each agent, a 24-element array of hourly run counts from
//            now-24h → now (for inline sparklines)
//   stats: per-agent { count24h, lastRun, status, costGbp24h, failedRecently }
//
// All scoped to the tenant. Polled every 10s by the canvas component.
export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug } = await params;
  const access = await requireTenantAccess(slug);
  if (!access.ok) return access.response;
  const { tenant } = access;

  const now = new Date();
  const since24h = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  const since1h = new Date(now.getTime() - 60 * 60 * 1000);

  // Recent stream — last 12 invocations, any agent.
  const recentRaw = await db.invocation.findMany({
    where: { tenantId: tenant.id },
    orderBy: { startedAt: 'desc' },
    take: 12,
    select: {
      id: true,
      agent: true,
      trigger: true,
      status: true,
      startedAt: true,
      completedAt: true,
      durationMs: true,
      costGbp: true,
    },
  });

  const recent = recentRaw.map((r) => ({
    id: r.id,
    agent: r.agent,
    trigger: r.trigger?.slice(0, 100) ?? '',
    status: r.status,
    startedAt: r.startedAt.toISOString(),
    durationMs: r.durationMs,
    costGbp: r.costGbp ? Number(r.costGbp) : 0,
  }));

  // 24h activity buckets — group by agent + floor(startedAt / 1h).
  // Postgres-friendly raw query keeps this fast even at 100k+ rows/tenant.
  const bucketsRaw = await db.$queryRaw<
    { agent: string; bucket: Date; n: bigint }[]
  >`
    SELECT
      agent,
      date_trunc('hour', started_at) AS bucket,
      COUNT(*)::bigint AS n
    FROM ops.invocations
    WHERE tenant_id = ${tenant.id}::uuid
      AND started_at >= ${since24h}
    GROUP BY agent, bucket
    ORDER BY agent, bucket;
  `;

  // Pivot into per-agent 24-element arrays. Index 0 = oldest hour, 23 = newest.
  const buckets: Record<string, number[]> = {};
  for (const row of bucketsRaw) {
    if (!buckets[row.agent]) buckets[row.agent] = new Array(24).fill(0);
    const hoursAgo = Math.floor((now.getTime() - row.bucket.getTime()) / 3_600_000);
    const idx = 23 - hoursAgo;
    if (idx >= 0 && idx < 24) buckets[row.agent][idx] = Number(row.n);
  }

  // Per-agent rollup stats — count24h, lastRun, last-hour failure flag.
  const statsRaw = await db.invocation.groupBy({
    by: ['agent'],
    where: {
      tenantId: tenant.id,
      startedAt: { gte: since24h },
    },
    _count: { _all: true },
    _max: { startedAt: true },
    _sum: { costGbp: true },
  });

  const failuresLastHour = await db.invocation.groupBy({
    by: ['agent'],
    where: {
      tenantId: tenant.id,
      status: 'FAILED',
      startedAt: { gte: since1h },
    },
    _count: { _all: true },
  });
  const failedRecently = new Set(
    failuresLastHour.filter((r) => r._count._all > 0).map((r) => r.agent),
  );

  const stats = statsRaw.map((s) => ({
    agent: s.agent,
    count24h: s._count._all,
    lastRun: s._max.startedAt?.toISOString() ?? null,
    costGbp24h: s._sum.costGbp ? Number(s._sum.costGbp) : 0,
    failedRecently: failedRecently.has(s.agent),
  }));

  // System-level last activity timestamp drives the header strip.
  const lastActivity = recent[0]?.startedAt ?? null;

  return NextResponse.json(
    { recent, buckets, stats, lastActivity, generatedAt: now.toISOString() },
    { headers: { 'Cache-Control': 'private, max-age=5' } },
  );
}
