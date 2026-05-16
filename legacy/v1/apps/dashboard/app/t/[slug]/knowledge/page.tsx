import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import Link from 'next/link';
import { db } from '@intelforce/db';
import {
  BookOpen,
  RefreshCw,
  Upload,
  Database,
  Sparkles,
  CheckCircle,
  AlertCircle,
  FileText,
  ArrowRight,
  Clock,
  Activity,
  HardDrive,
  Search,
  Plus,
} from 'lucide-react';
import {
  Card,
  CardHeader,
  CardBody,
  StatTile,
  HealthBar,
  StatusPill,
  Eyebrow,
  PageHeader,
  RelativeTime,
} from '@/components/shared';

export const metadata = { title: 'Knowledge' };

export default async function KnowledgePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const tenant = await db.tenant.findUnique({
    where: { slug },
    select: { id: true, name: true, plan: true },
  });
  if (!tenant) return null;

  const lastHandbookInvocation = await db.invocation.findFirst({
    where: { tenantId: tenant.id, trigger: { contains: 'handbook' } },
    orderBy: { startedAt: 'desc' },
  });
  const hasHandbook = lastHandbookInvocation !== null;

  const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const recentReferences = await db.invocation.findMany({
    where: {
      tenantId: tenant.id,
      startedAt: { gte: since },
      trigger: { contains: 'handbook' },
    },
    orderBy: { startedAt: 'desc' },
    take: 5,
    select: { id: true, startedAt: true, trigger: true, agent: true },
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Knowledge"
        description="Everything your agent can reference — company handbook, live employee data, and the connected brain that ties them together."
        actions={
          <>
            <button className="flex items-center gap-2 text-xs font-medium px-3.5 py-2 rounded-lg bg-white/[0.04] ring-1 ring-white/10 text-text-secondary hover:text-text-primary hover:ring-white/20 transition-all">
              <Search className="w-3.5 h-3.5" />
              Search docs
            </button>
            <button className="flex items-center gap-2 text-xs font-semibold px-3.5 py-2 rounded-lg bg-emerald-400 text-emerald-950 hover:bg-emerald-300 transition-colors">
              <Plus className="w-3.5 h-3.5" />
              Upload document
            </button>
          </>
        }
      />

      {/* ── Status strip ──────────────────────────────────────────── */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <StatTile
          label="Handbook"
          value={hasHandbook ? 'Active' : 'Missing'}
          hint={hasHandbook ? 'HR_Handbook_2025.pdf · 48 pages' : 'Upload to enable agent answers'}
          icon={BookOpen}
          tone={hasHandbook ? 'good' : 'warn'}
        />
        <StatTile
          label="Employee data"
          value="Live"
          hint="Breathe HR · synced 12 min ago"
          icon={Database}
          tone="good"
        />
        <StatTile
          label="Brain"
          value="Demo"
          hint="1,002 nodes · 1,137 edges"
          icon={Sparkles}
          tone="neutral"
        />
        <StatTile
          label="Storage"
          value="2.4 / 100 MB"
          hint={`${tenant.plan} plan · 97.6 MB free`}
          icon={HardDrive}
          tone="neutral"
        />
      </div>

      {/* ── Documents library + Brain Map preview side-by-side ──── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 sm:gap-6">
        {/* Documents library — spans 2 cols */}
        <Card className="lg:col-span-2">
          <CardHeader
            icon={BookOpen}
            title="Company documents"
            accessory={
              hasHandbook ? (
                <StatusPill tone="good" icon={CheckCircle}>
                  INDEXED
                </StatusPill>
              ) : (
                <StatusPill tone="warn" icon={AlertCircle}>
                  NEEDED
                </StatusPill>
              )
            }
          />
          <CardBody>
            {hasHandbook ? (
              <>
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 mb-5">
                  <div>
                    <Eyebrow className="mb-1">Filename</Eyebrow>
                    <p className="text-sm text-text-primary truncate flex items-center gap-1.5">
                      <FileText className="w-3.5 h-3.5 text-text-muted shrink-0" />
                      HR_Handbook_2025.pdf
                    </p>
                  </div>
                  <div>
                    <Eyebrow className="mb-1">Uploaded</Eyebrow>
                    <p className="text-sm text-text-primary">
                      {lastHandbookInvocation?.startedAt.toLocaleDateString('en-GB', {
                        day: 'numeric',
                        month: 'short',
                        year: 'numeric',
                      }) ?? '—'}
                    </p>
                  </div>
                  <div>
                    <Eyebrow className="mb-1">Size</Eyebrow>
                    <p className="text-sm text-text-primary">2.4 MB · 48 pages · 9 sections</p>
                  </div>
                </div>

                <Eyebrow className="mb-3">Policy coverage</Eyebrow>
                <div className="space-y-2.5">
                  <HealthBar label="Leave & holiday" pct={95} />
                  <HealthBar label="Sick leave" pct={92} />
                  <HealthBar label="Grievance procedure" pct={88} />
                  <HealthBar label="Disciplinary" pct={84} />
                  <HealthBar label="Health & safety" pct={76} />
                  <HealthBar label="Pay & benefits" pct={58} />
                </div>

                <div className="mt-3 px-3 py-2 rounded-md bg-amber-400/[0.05] ring-1 ring-amber-400/15">
                  <p className="text-[11px] text-amber-200/90 leading-relaxed">
                    <strong className="text-amber-300">Pay &amp; benefits</strong> is thin —
                    consider expanding with salary band details to improve answer quality.
                  </p>
                </div>

                <div className="mt-5 flex flex-wrap gap-2">
                  <button className="flex items-center gap-2 text-xs font-medium px-3.5 py-2 rounded-lg bg-white/[0.04] ring-1 ring-white/10 text-text-secondary hover:text-text-primary hover:ring-white/20 transition-all">
                    <Upload className="w-3.5 h-3.5" />
                    Upload new version
                  </button>
                  <button className="flex items-center gap-2 text-xs font-medium px-3.5 py-2 rounded-lg bg-white/[0.04] ring-1 ring-white/10 text-text-secondary hover:text-text-primary hover:ring-white/20 transition-all">
                    Download current
                  </button>
                  <Link
                    href={`/t/${slug}/brain`}
                    className="flex items-center gap-2 text-xs font-medium px-3.5 py-2 rounded-lg text-emerald-400 hover:text-emerald-300 transition-colors ml-auto"
                  >
                    See what the agent learned
                    <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                </div>
              </>
            ) : (
              <div className="text-center py-10">
                <BookOpen className="w-12 h-12 text-text-muted/30 mx-auto mb-4" />
                <p className="text-sm text-text-primary mb-1.5 font-medium">No handbook uploaded</p>
                <p className="text-xs text-text-muted mb-5 max-w-sm mx-auto leading-relaxed">
                  Upload your company HR handbook and the agent will reference it when answering
                  employee questions. PDF or Markdown.
                </p>
                <Link
                  href={`/t/${slug}/wizard`}
                  className="inline-flex items-center gap-2 text-sm font-semibold px-4 py-2 rounded-lg bg-emerald-400 text-emerald-950 hover:bg-emerald-300 transition-colors"
                >
                  <Upload className="w-3.5 h-3.5" />
                  Upload handbook
                </Link>
              </div>
            )}
          </CardBody>
        </Card>

        {/* Brain Map preview */}
        <Link href={`/t/${slug}/brain`} className="group block">
          <Card variant="interactive" className="group-hover:ring-emerald-400/30">
            <CardHeader
              icon={Sparkles}
              title="Brain Map"
              accessory={<StatusPill tone="good">LIVE</StatusPill>}
            />
            <div className="relative aspect-square bg-[rgb(7,9,11)] overflow-hidden">
              <div
                className="absolute inset-0"
                style={{
                  background:
                    'radial-gradient(circle at 50% 50%, rgba(16,185,129,0.08) 0%, transparent 60%)',
                }}
              />
              <ConstellationThumbnail />
            </div>
            <CardBody>
              <div className="flex items-baseline justify-between mb-2">
                <Eyebrow>Connected concepts</Eyebrow>
                <span className="font-mono text-sm text-text-primary font-semibold">1,002</span>
              </div>
              <p className="text-[11px] text-text-muted leading-relaxed mb-3">
                Every doc, decision, and connection — searchable, traceable, and used by the agent
                to answer with citations.
              </p>
              <div className="flex items-center gap-1.5 text-emerald-400 group-hover:text-emerald-300 transition-colors text-xs font-medium">
                Open Brain Map
                <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-0.5" />
              </div>
            </CardBody>
          </Card>
        </Link>
      </div>

      {/* ── Live employee data ────────────────────────────────────── */}
      <Card>
        <CardHeader
          icon={Database}
          title="Live employee data"
          subtitle="via Breathe HR"
          accessory={
            <StatusPill tone="good" showDot pulse>
              CONNECTED
            </StatusPill>
          }
        />
        <CardBody>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 sm:gap-5 mb-5">
            <div>
              <Eyebrow className="mb-1">Employees</Eyebrow>
              <p className="font-display text-2xl font-light text-text-primary leading-none">34</p>
            </div>
            <div>
              <Eyebrow className="mb-1">Departments</Eyebrow>
              <p className="font-display text-2xl font-light text-text-primary leading-none">5</p>
            </div>
            <div>
              <Eyebrow className="mb-1">Sync interval</Eyebrow>
              <p className="text-sm text-text-primary mt-1">Every 4 hours</p>
            </div>
            <div>
              <Eyebrow className="mb-1">Last sync</Eyebrow>
              <p className="text-sm text-text-primary mt-1">12 minutes ago</p>
            </div>
          </div>

          <Eyebrow className="mb-3">Data availability</Eyebrow>
          <div className="space-y-2.5">
            <HealthBar label="Leave balances" pct={100} status="100%" />
            <HealthBar label="Employee profiles" pct={100} status="100%" />
            <HealthBar label="Absence history" pct={100} status="100%" />
            <HealthBar label="Department mapping" pct={100} status="100%" />
          </div>

          <div className="mt-5 flex gap-2">
            <button className="flex items-center gap-2 text-xs font-medium px-3.5 py-2 rounded-lg bg-white/[0.04] ring-1 ring-white/10 text-text-secondary hover:text-text-primary hover:ring-white/20 transition-all">
              <RefreshCw className="w-3.5 h-3.5" />
              Force sync
            </button>
            <Link
              href={`/t/${slug}/settings`}
              className="flex items-center gap-2 text-xs font-medium px-3.5 py-2 rounded-lg bg-white/[0.04] ring-1 ring-white/10 text-text-secondary hover:text-text-primary hover:ring-white/20 transition-all"
            >
              Integration settings
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </CardBody>
      </Card>

      {/* ── Recently referenced ──────────────────────────────────── */}
      <Card>
        <CardHeader
          icon={Activity}
          title="Recently referenced"
          subtitle="last 24 hours"
          accessory={
            <Link
              href={`/t/${slug}/activity`}
              className="text-xs text-emerald-400 hover:text-emerald-300 flex items-center gap-1"
            >
              All activity <ArrowRight className="w-3 h-3" />
            </Link>
          }
        />

        {recentReferences.length === 0 ? (
          <CardBody className="text-center py-10">
            <Clock className="w-8 h-8 text-text-muted/30 mx-auto mb-2" />
            <p className="text-xs text-text-muted">
              Nothing referenced yet today. The agent will list handbook lookups here as they
              happen.
            </p>
          </CardBody>
        ) : (
          <ul className="divide-y divide-white/5">
            {recentReferences.map((ref) => (
              <li
                key={ref.id}
                className="px-5 py-3 flex items-center gap-3 hover:bg-white/[0.02] transition-colors"
              >
                <FileText className="w-3.5 h-3.5 text-text-muted shrink-0" />
                <div className="flex-1 min-w-0">
                  <p className="text-xs text-text-primary truncate">{ref.trigger}</p>
                  <p className="text-[11px] text-text-muted">{ref.agent}</p>
                </div>
                <RelativeTime date={ref.startedAt} />
              </li>
            ))}
          </ul>
        )}
      </Card>
    </div>
  );
}

// Tiny static constellation, drawn with CSS — no JS, no canvas.
// Just enough to hint at the real Brain Map without loading 313KB on the Knowledge page.
function ConstellationThumbnail() {
  const dots: { x: number; y: number; r: number; c: string; o: number }[] = [];
  const colors = ['#10B981', '#22D3EE', '#A78BFA', '#F59E0B', '#FB7185', '#60A5FA', '#2DD4BF'];
  let seed = 12345;
  const rand = () => {
    seed = (seed * 9301 + 49297) % 233280;
    return seed / 233280;
  };
  for (let i = 0; i < 80; i++) {
    const angle = rand() * Math.PI * 2;
    const radius = Math.pow(rand(), 0.6) * 45 + 5;
    const x = 50 + Math.cos(angle) * radius;
    const y = 50 + Math.sin(angle) * radius;
    dots.push({
      x,
      y,
      r: rand() < 0.15 ? 2.4 : 1.4,
      c: colors[Math.floor(rand() * colors.length)],
      o: 0.4 + rand() * 0.5,
    });
  }
  return (
    <svg
      viewBox="0 0 100 100"
      className="absolute inset-0 w-full h-full"
      preserveAspectRatio="xMidYMid meet"
    >
      <g stroke="rgba(180,200,210,0.18)" strokeWidth="0.18">
        {dots.flatMap((a, i) =>
          dots.slice(i + 1).map((b, j) => {
            const dx = a.x - b.x;
            const dy = a.y - b.y;
            const d = Math.sqrt(dx * dx + dy * dy);
            if (d > 18) return null;
            return <line key={`${i}-${j}`} x1={a.x} y1={a.y} x2={b.x} y2={b.y} />;
          }),
        )}
      </g>
      {dots.map((d, i) => (
        <circle key={i} cx={d.x} cy={d.y} r={d.r} fill={d.c} opacity={d.o} />
      ))}
      <circle cx={50} cy={50} r={3.2} fill="#34D399">
        <animate attributeName="opacity" values="0.9;0.4;0.9" dur="2.4s" repeatCount="indefinite" />
        <animate attributeName="r" values="3.2;3.8;3.2" dur="2.4s" repeatCount="indefinite" />
      </circle>
    </svg>
  );
}
