'use client';

import { useState, useMemo, useRef, useEffect } from 'react';
import {
  X,
  Sliders,
  Plus,
  Network,
  LayoutGrid,
  Layers,
  CircuitBoard,
  ShieldCheck,
} from 'lucide-react';
import { cn } from '@/lib/cn';

// ─────────────────────────────────────────────────────────────────────────────
// AgentWeb — interactive, animated rendering of the multi-agent system.
//
// Layout (SVG, viewBox 920×580):
//
//   ┌──────────┐   ┌──────────┐   ┌────────────┐   ┌───────────────────────┐
//   │ Channels │   │          │   │ Directors  │   │ Sub-agents (grouped)  │
//   │ Sources  │──▶│ Gateway  │──▶│ ×4         │──▶│ ×14, status + output  │
//   │ Triggers │   │          │   │            │   │                       │
//   └──────────┘   └──────────┘   └────────────┘   └───────────────────────┘
//
// • Curved bezier connectors flow left → right with gradient strokes.
// • Hovered/selected director highlights its branch only.
// • Clicking a sub-agent opens the inline detail panel below the canvas.
// • Animated SVG <animate> elements pulse the live status dots.
// ─────────────────────────────────────────────────────────────────────────────

export type AgentStatus = 'ACTIVE' | 'RUNNING' | 'SCHEDULED' | 'IDLE';
export type DirectorKey = 'HR' | 'Sales' | 'Marketing' | 'Operations';

export interface AgentSpec {
  key: string;
  name: string;
  director: DirectorKey;
  status: AgentStatus;
  model: string;
  description: string;
  schedule: string;
  output: string;
  integrations: string[];
}

export interface IntegrationGroup {
  label: string;
  items: { name: string; status: 'live' | 'ready' | 'idle'; meta?: string }[];
}

interface AgentWebProps {
  agents: AgentSpec[];
  channels: IntegrationGroup;
  dataSources: IntegrationGroup;
  triggers: IntegrationGroup;
  // Tenant slug — used to poll /api/agents/[slug]/activity for live data.
  // If omitted (e.g. demo / Storybook), the component renders without live
  // wiring and shows the static AgentSpec data only.
  slug?: string;
}

interface InvocationRow {
  id: string;
  agent: string;
  trigger: string;
  status: string;
  startedAt: string;
  durationMs: number | null;
  costGbp: number;
}

interface AgentLiveStats {
  agent: string;
  count24h: number;
  lastRun: string | null;
  costGbp24h: number;
  failedRecently: boolean;
}

interface ActivityPayload {
  recent: InvocationRow[];
  buckets: Record<string, number[]>;
  stats: AgentLiveStats[];
  lastActivity: string | null;
  generatedAt: string;
}

const DIRECTOR_META: Record<DirectorKey, { color: string; soft: string; model: string }> = {
  HR: { color: '#a78bfa', soft: 'rgba(167,139,250,0.18)', model: 'sonnet-4.6' },
  Sales: { color: '#60a5fa', soft: 'rgba(96,165,250,0.18)', model: 'opus-4.7' },
  Marketing: { color: '#5eead4', soft: 'rgba(94,234,212,0.18)', model: 'opus-4.7' },
  Operations: { color: '#fdba74', soft: 'rgba(253,186,116,0.18)', model: 'sonnet-4.6' },
};

const STATUS_DOT: Record<AgentStatus, string> = {
  ACTIVE: '#10b981',
  RUNNING: '#f59e0b',
  SCHEDULED: '#38bdf8',
  IDLE: '#52525b',
};

// Layout constants — tweaking these reflows the whole canvas. This is the
// showpiece of the dashboard; rows breathe (40px), gaps are generous, and the
// gateway gets real centre-stage real estate.
//
// Vertical accounting (11 agents, 4 director groups, ROW_H=40, GROUP_GAP=24):
//   margin(28) + HR(2*44) + gap(24) + Sales(3*44) + gap(24)
//   + Mktg(3*44) + gap(24) + Ops(3*44) + bottom(28) = 624.
const VB_W = 1120;
const VB_H = 640;
const INPUT_X = 16;
const INPUT_W = 160;
const GW_X = 208;
const GW_W = 156;
const DIR_X = 396;
const DIR_W = 182;
const AGENT_X = 612;
const AGENT_W = 492;
const ROW_H = 40;
const ROW_GAP = 4;
const GROUP_GAP = 24;

function statusDot(status: AgentStatus): string {
  return STATUS_DOT[status];
}

type ViewMode = 'hierarchy' | 'cards' | 'subagents' | 'models';

export function AgentWeb({ agents, channels, dataSources, triggers, slug }: AgentWebProps) {
  const [selected, setSelected] = useState<AgentSpec | null>(null);
  const [hoveredDir, setHoveredDir] = useState<DirectorKey | null>(null);
  const [viewMode, setViewMode] = useState<ViewMode>('hierarchy');
  // Hidden directors — branches the user has collapsed to declutter.
  // Rendered as a slim collapsed director box; their agents + connectors +
  // particles all skip rendering and the layout reflows to fill the space.
  const [hiddenDirs, setHiddenDirs] = useState<Set<DirectorKey>>(new Set());
  const toggleDir = (k: DirectorKey) =>
    setHiddenDirs((curr) => {
      const next = new Set(curr);
      if (next.has(k)) next.delete(k);
      else next.add(k);
      return next;
    });
  // Mount flag drives a subtle entry animation: the canvas fades + lifts in
  // from 4px below over 600ms. Feels like the system "comes online" rather
  // than appearing all at once.
  const [mounted, setMounted] = useState(false);
  useEffect(() => {
    const id = requestAnimationFrame(() => setMounted(true));
    return () => cancelAnimationFrame(id);
  }, []);

  // Live activity payload — recent invocations, per-agent buckets, rollup
  // stats. Polled every 10s. When `slug` isn't supplied, this stays null and
  // the canvas falls back to static AgentSpec data.
  const [live, setLive] = useState<ActivityPayload | null>(null);
  useEffect(() => {
    if (!slug) return;
    let cancelled = false;
    const fetchActivity = async () => {
      try {
        const r = await fetch(`/api/agents/${slug}/activity`, {
          cache: 'no-store',
        });
        if (!r.ok) return;
        const data = (await r.json()) as ActivityPayload;
        if (!cancelled) setLive(data);
      } catch {
        // Silent — the canvas still renders from static props.
      }
    };
    fetchActivity();
    const id = setInterval(fetchActivity, 10_000);
    return () => {
      cancelled = true;
      clearInterval(id);
    };
  }, [slug]);

  // Lookup map: agent.key → live stats. Agent keys in our static spec match
  // the `agent` column in `Invocation` (we kebab-case names on insert).
  const liveStatsByKey = useMemo(() => {
    const map = new Map<string, AgentLiveStats>();
    if (live) {
      for (const s of live.stats) map.set(s.agent, s);
    }
    return map;
  }, [live]);
  const bucketsByKey = useMemo(() => live?.buckets ?? {}, [live]);

  // Group agents by director, preserving the input order.
  const grouped = useMemo(() => {
    const order: DirectorKey[] = ['HR', 'Sales', 'Marketing', 'Operations'];
    return order.map((key) => ({
      key,
      agents: agents.filter((a) => a.director === key),
    }));
  }, [agents]);

  // Compute per-row Y for each agent, plus director group bounds. Honours
  // hiddenDirs — collapsed directors take a slim 60px slot (just the box,
  // no agents) so the layout reflows cleanly when the user toggles one off.
  const COLLAPSED_DIR_H = 60;
  const layout = useMemo(() => {
    const rows: Record<string, { y: number; group: DirectorKey }> = {};
    const groupBounds: Record<DirectorKey, { yStart: number; yEnd: number; centerY: number }> = {
      HR: { yStart: 0, yEnd: 0, centerY: 0 },
      Sales: { yStart: 0, yEnd: 0, centerY: 0 },
      Marketing: { yStart: 0, yEnd: 0, centerY: 0 },
      Operations: { yStart: 0, yEnd: 0, centerY: 0 },
    };
    let cursor = 28; // top margin — generous so the first row breathes
    for (const g of grouped) {
      const yStart = cursor;
      if (hiddenDirs.has(g.key)) {
        // Collapsed: reserve just enough room for the director box itself.
        cursor += COLLAPSED_DIR_H;
      } else {
        for (const a of g.agents) {
          rows[a.key] = { y: cursor, group: g.key };
          cursor += ROW_H + ROW_GAP;
        }
      }
      const yEnd = cursor - (hiddenDirs.has(g.key) ? 0 : ROW_GAP);
      const centerY = (yStart + yEnd) / 2;
      groupBounds[g.key] = { yStart, yEnd, centerY };
      cursor += GROUP_GAP;
    }
    return { rows, groupBounds, contentHeight: cursor };
  }, [grouped, hiddenDirs]);

  // Gateway centre — mean of all four director centres so connectors balance.
  const gatewayCenterY = useMemo(() => {
    const centres = (Object.keys(layout.groupBounds) as DirectorKey[]).map(
      (k) => layout.groupBounds[k].centerY,
    );
    return centres.reduce((s, n) => s + n, 0) / centres.length;
  }, [layout]);

  // Hover only adds emphasis; nothing ever fades to "dim". The reference
  // design (translucent glass boxes, see-through canvas) is incompatible
  // with the previous click-to-dim behaviour.
  function isDirectorHovered(key: DirectorKey): boolean {
    return hoveredDir === key;
  }

  return (
    <div className="relative bg-[rgb(7,9,11)] rounded-2xl ring-1 ring-white/5 overflow-hidden">
      {/* Title bar — page identity, view mode tabs, primary CTA */}
      <AgentHeader
        agents={agents}
        live={live}
        viewMode={viewMode}
        onViewMode={setViewMode}
      />
      {/* Live activity strip — what's happening right now */}
      <ActivityStrip agents={agents} live={live} />
      {/* Live invocation stream — only when there's real activity */}
      {live && live.recent.length > 0 && (
        <InvocationStream rows={live.recent} agents={agents} onPick={(a) => setSelected(a)} />
      )}

      {/* SVG canvas — fills container width up to 1280px so elements don't
          stretch awkwardly on ultrawide screens. Drag-to-pan kicks in if
          the viewport is narrower than the SVG's natural width. */}
      <DraggableScroll className="relative">
        <svg
          viewBox={`0 0 ${VB_W} ${VB_H}`}
          className="block w-full h-auto mx-auto"
          style={{
            minWidth: VB_W,
            maxWidth: 1280,
            opacity: mounted ? 1 : 0,
            transform: mounted ? 'translateY(0)' : 'translateY(4px)',
            transition: 'opacity 600ms ease, transform 600ms ease',
          }}
          preserveAspectRatio="xMidYMid meet"
          onClick={(e) => {
            // Click on empty canvas closes any open detail panel.
            if ((e.target as SVGElement).tagName === 'svg') {
              setSelected(null);
            }
          }}
        >
          <defs>
            <pattern id="agent-grid" width="36" height="36" patternUnits="userSpaceOnUse">
              <path d="M 36 0 L 0 0 0 36" fill="none" stroke="rgba(255,255,255,.025)" strokeWidth=".5" />
            </pattern>
            <radialGradient id="gw-glow" cx="50%" cy="50%" r="50%">
              <stop offset="0%" stopColor="#34d399" stopOpacity="0.28" />
              <stop offset="100%" stopColor="#34d399" stopOpacity="0" />
            </radialGradient>
            {/* Per-director edge gradients — fade-in/out along the curve */}
            {(Object.keys(DIRECTOR_META) as DirectorKey[]).map((k) => (
              <linearGradient id={`edge-${k}`} key={k} x1="0" x2="1">
                <stop offset="0%" stopColor={DIRECTOR_META[k].color} stopOpacity="0.1" />
                <stop offset="50%" stopColor={DIRECTOR_META[k].color} stopOpacity="0.7" />
                <stop offset="100%" stopColor={DIRECTOR_META[k].color} stopOpacity="0.25" />
              </linearGradient>
            ))}
          </defs>

          <rect width={VB_W} height={VB_H} fill="url(#agent-grid)" />

          {/* Ambient glow behind gateway — wider, two-pass for depth */}
          <circle cx={GW_X + GW_W / 2} cy={gatewayCenterY} r={130} fill="url(#gw-glow)">
            <animate
              attributeName="r"
              values="125;138;125"
              dur="3.5s"
              repeatCount="indefinite"
            />
          </circle>
          <circle
            cx={GW_X + GW_W / 2}
            cy={gatewayCenterY}
            r={70}
            fill="url(#gw-glow)"
            opacity={0.6}
          />

          {/* ─── INPUTS COLUMN ─── */}
          <InputsColumn
            channels={channels}
            dataSources={dataSources}
            triggers={triggers}
          />

          {/* ─── INPUT → GATEWAY connectors. With the trimmed input list,
              each connector originates from one of three Y "bands" so the
              flow visually fans into the gateway. ─── */}
          {[VB_H * 0.32, VB_H * 0.5, VB_H * 0.68].map((y, i) => (
            <path
              key={i}
              id={`agw-ig-${i}`}
              d={`M ${INPUT_X + INPUT_W} ${y} C ${INPUT_X + INPUT_W + 18} ${y} ${GW_X - 18} ${gatewayCenterY} ${GW_X} ${gatewayCenterY}`}
              fill="none"
              stroke="#34d399"
              strokeOpacity="0.32"
              strokeWidth={1.2}
            />
          ))}
          {[VB_H * 0.32, VB_H * 0.5, VB_H * 0.68].map((_, i) => (
            <FlowParticle
              key={`p-ig-${i}`}
              pathId={`agw-ig-${i}`}
              color="#34d399"
              dur={2.2 + i * 0.3}
              begin={i * 0.6}
              radius={1.8}
            />
          ))}

          {/* ─── GATEWAY ─── orb-style box, dual-ring frame,
              "Routes by intent" subtitle, breathing inner glow */}
          <g>
            {/* Outer soft ring */}
            <rect
              x={GW_X - 10}
              y={gatewayCenterY - 44}
              width={GW_W + 20}
              height={88}
              rx={18}
              fill="none"
              stroke="rgba(52,211,153,0.10)"
              strokeWidth={9}
            />
            {/* Inner glass body */}
            <rect
              x={GW_X}
              y={gatewayCenterY - 36}
              width={GW_W}
              height={72}
              rx={14}
              fill="rgba(52,211,153,0.05)"
              stroke="#34d399"
              strokeWidth={1.6}
              strokeOpacity={0.85}
            />
            {/* Glyph (Lightning bolt — "fast routing") */}
            <g transform={`translate(${GW_X + GW_W / 2 - 8}, ${gatewayCenterY - 24}) scale(0.85)`}>
              <path
                d="M 13 1 L 3 14 L 8.5 14 L 6 21 L 17 8 L 11.5 8 L 13 1 Z"
                fill="#34d399"
                fillOpacity={0.95}
              >
                <animate
                  attributeName="fill-opacity"
                  values="0.95;0.55;0.95"
                  dur="2.4s"
                  repeatCount="indefinite"
                />
              </path>
            </g>
            {/* Title */}
            <text
              x={GW_X + GW_W / 2}
              y={gatewayCenterY + 10}
              textAnchor="middle"
              fill="#fafafa"
              fontSize={14}
              fontFamily="Geist, sans-serif"
              fontWeight="600"
            >
              Gateway
            </text>
            {/* Subtitle */}
            <text
              x={GW_X + GW_W / 2}
              y={gatewayCenterY + 26}
              textAnchor="middle"
              fill="#71717a"
              fontSize={9.5}
              fontFamily="JetBrains Mono, monospace"
              letterSpacing="0.5"
            >
              routes by intent
            </text>
            {/* Live indicator dot */}
            <circle cx={GW_X + GW_W - 14} cy={gatewayCenterY - 22} r={4} fill="#34d399">
              <animate
                attributeName="opacity"
                values="1;0.3;1"
                dur="2s"
                repeatCount="indefinite"
              />
            </circle>
          </g>

          {/* ─── GATEWAY → DIRECTORS (one bezier per director) ─── */}
          {(Object.keys(DIRECTOR_META) as DirectorKey[]).map((k) => {
            const cy = layout.groupBounds[k].centerY;
            const hovered = isDirectorHovered(k);
            const hidden = hiddenDirs.has(k);
            return (
              <path
                key={k}
                id={`agw-gd-${k}`}
                d={`M ${GW_X + GW_W} ${gatewayCenterY} C ${GW_X + GW_W + 32} ${gatewayCenterY} ${DIR_X - 28} ${cy} ${DIR_X} ${cy}`}
                fill="none"
                stroke={`url(#edge-${k})`}
                strokeWidth={hovered ? 2.4 : 1.8}
                strokeOpacity={hidden ? 0.18 : 1}
                strokeDasharray={hidden ? '3 5' : ''}
                style={{ transition: 'stroke-width 200ms ease, stroke-opacity 200ms ease' }}
              />
            );
          })}
          {/* Particles flowing outward from gateway to each visible director.
              Hidden directors get no particles — keeps the canvas calm. */}
          {(Object.keys(DIRECTOR_META) as DirectorKey[])
            .filter((k) => !hiddenDirs.has(k))
            .map((k, i) => {
              const hovered = isDirectorHovered(k);
              return (
                <FlowParticle
                  key={`p-gd-${k}`}
                  pathId={`agw-gd-${k}`}
                  color={DIRECTOR_META[k].color}
                  dur={hovered ? 1.5 : 2.6}
                  begin={i * 0.5}
                  radius={hovered ? 2.4 : 2}
                />
              );
            })}

          {/* ─── DIRECTORS ─── */}
          {(Object.keys(DIRECTOR_META) as DirectorKey[]).map((k) => {
            const meta = DIRECTOR_META[k];
            const cy = layout.groupBounds[k].centerY;
            const count = grouped.find((g) => g.key === k)?.agents.length ?? 0;
            const hovered = isDirectorHovered(k);
            const hidden = hiddenDirs.has(k);
            return (
              <g
                key={k}
                onMouseEnter={() => setHoveredDir(k)}
                onMouseLeave={() => setHoveredDir(null)}
                style={{ cursor: 'pointer' }}
              >
                <rect
                  x={DIR_X}
                  y={cy - 30}
                  width={DIR_W}
                  height={60}
                  rx={14}
                  fill={hidden ? 'rgba(255,255,255,0.012)' : 'rgba(255,255,255,0.028)'}
                  stroke={meta.color}
                  strokeWidth={hovered ? 1.8 : 1.2}
                  strokeOpacity={hidden ? 0.25 : hovered ? 0.9 : 0.55}
                  strokeDasharray={hidden ? '4 4' : ''}
                  style={{ transition: 'stroke-width 200ms ease, stroke-opacity 200ms ease' }}
                />
                <circle
                  cx={DIR_X + 18}
                  cy={cy}
                  r={5.5}
                  fill={meta.color}
                  fillOpacity={hidden ? 0.4 : 1}
                >
                  {!hidden && (
                    <animate
                      attributeName="opacity"
                      values="1;0.4;1"
                      dur={`${1.8 + Math.random() * 0.8}s`}
                      repeatCount="indefinite"
                    />
                  )}
                </circle>
                <text
                  x={DIR_X + 34}
                  y={cy - 6}
                  fill={hidden ? '#71717a' : '#fafafa'}
                  fontSize={13.5}
                  fontFamily="Geist, sans-serif"
                  fontWeight="600"
                  style={{ transition: 'fill 200ms ease' }}
                >
                  {k} Director
                </text>
                <text
                  x={DIR_X + 34}
                  y={cy + 11}
                  fill={hidden ? '#3f3f46' : '#71717a'}
                  fontSize={10}
                  fontFamily="JetBrains Mono, monospace"
                >
                  {hidden ? 'hidden · click to show' : `${count} ${count === 1 ? 'agent' : 'agents'} · ${meta.model}`}
                </text>
                {/* Toggle — subtle dot in the top-right corner. Filled when
                    visible (a quiet "on" indicator), hollow + dashed when
                    hidden ("off"). The whole director box is clickable so the
                    target is forgiving; the dot is just the visual affordance. */}
                <g
                  transform={`translate(${DIR_X + DIR_W - 18}, ${cy - 18})`}
                  onClick={(e) => {
                    e.stopPropagation();
                    toggleDir(k);
                  }}
                >
                  <circle
                    r={9}
                    fill="transparent"
                    style={{ cursor: 'pointer' }}
                  />
                  {hidden ? (
                    <circle
                      r={4}
                      fill="none"
                      stroke="#71717a"
                      strokeWidth={1}
                      strokeDasharray="2 2"
                    />
                  ) : (
                    <>
                      <circle r={4} fill="none" stroke={meta.color} strokeOpacity={0.5} strokeWidth={1} />
                      <circle r={1.6} fill={meta.color} />
                    </>
                  )}
                </g>
              </g>
            );
          })}

          {/* ─── DIRECTOR → SUB-AGENT connectors (skipped for hidden) ─── */}
          {grouped
            .filter((g) => !hiddenDirs.has(g.key))
            .flatMap((g) =>
              g.agents.map((a) => {
                const row = layout.rows[a.key];
                const dirCy = layout.groupBounds[g.key].centerY;
                const meta = DIRECTOR_META[g.key];
                const rowY = row.y + ROW_H / 2;
                const hovered = isDirectorHovered(g.key);
                return (
                  <path
                    key={a.key}
                    id={`agw-da-${a.key}`}
                    d={`M ${DIR_X + DIR_W} ${dirCy} C ${DIR_X + DIR_W + 22} ${dirCy} ${AGENT_X - 22} ${rowY} ${AGENT_X} ${rowY}`}
                    fill="none"
                    stroke={meta.color}
                    strokeOpacity={hovered ? 0.65 : 0.38}
                    strokeWidth={hovered ? 1.6 : 1.2}
                    style={{ transition: 'stroke-opacity 200ms ease, stroke-width 200ms ease' }}
                  />
                );
              }),
            )}
          {/* Particles along visible director→agent paths only. */}
          {grouped
            .filter((g) => !hiddenDirs.has(g.key))
            .flatMap((g) =>
              g.agents
                .filter((a) => a.status !== 'IDLE')
                .map((a, i) => {
                  const meta = DIRECTOR_META[g.key];
                  const dur =
                    a.status === 'RUNNING' ? 1.6 : a.status === 'ACTIVE' ? 2.8 : 4.0;
                  return (
                    <FlowParticle
                      key={`p-da-${a.key}`}
                      pathId={`agw-da-${a.key}`}
                      color={meta.color}
                      dur={dur}
                      begin={i * 0.4}
                      radius={a.status === 'RUNNING' ? 2.2 : 1.6}
                    />
                  );
                }),
            )}

          {/* ─── SUB-AGENT GROUP LABELS + SEPARATORS ─── */}
          {grouped.map((g, i) => {
            const meta = DIRECTOR_META[g.key];
            const bounds = layout.groupBounds[g.key];
            const hovered = isDirectorHovered(g.key);
            // Hide labels + separators for collapsed branches — there's
            // nothing to label.
            if (hiddenDirs.has(g.key)) return null;
            return (
              <g key={`label-${g.key}`}>
                <text
                  x={AGENT_X + 4}
                  y={bounds.yStart - 6}
                  fill={meta.color}
                  fontSize={8.5}
                  fontFamily="Geist, sans-serif"
                  fontWeight="700"
                  opacity={hovered ? 0.85 : 0.5}
                  letterSpacing="1.2"
                  style={{ transition: 'opacity 200ms ease' }}
                >
                  {g.key.toUpperCase()}
                </text>
                {i > 0 && (
                  <line
                    x1={AGENT_X}
                    y1={bounds.yStart - 14}
                    x2={AGENT_X + AGENT_W}
                    y2={bounds.yStart - 14}
                    stroke="rgba(255,255,255,0.05)"
                    strokeWidth={1}
                  />
                )}
              </g>
            );
          })}

          {/* ─── SUB-AGENT ROWS ─── (skipped for hidden directors) */}
          {grouped.filter((g) => !hiddenDirs.has(g.key)).flatMap((g) =>
            g.agents.map((a) => {
              const row = layout.rows[a.key];
              const sd = statusDot(a.status);
              const isSel = selected?.key === a.key;
              const isLive = a.status === 'ACTIVE' || a.status === 'RUNNING';
              const meta = DIRECTOR_META[g.key];
              return (
                <g
                  key={a.key}
                  transform={`translate(${AGENT_X}, ${row.y})`}
                  onClick={(e) => {
                    e.stopPropagation();
                    setSelected((curr) => (curr?.key === a.key ? null : a));
                  }}
                  onMouseEnter={() => setHoveredDir(g.key)}
                  onMouseLeave={() => setHoveredDir(null)}
                  style={{ cursor: 'pointer' }}
                >
                  {/* Translucent glass row — fills with the canvas behind, no
                      hard black backdrop. Hover/selected lift via subtle
                      colour wash + border, never via opacity. */}
                  <rect
                    width={AGENT_W}
                    height={ROW_H}
                    rx={9}
                    fill={
                      isSel
                        ? `${meta.color}14`
                        : 'rgba(255,255,255,0.025)'
                    }
                    stroke={
                      isSel
                        ? meta.color
                        : a.status === 'RUNNING'
                          ? 'rgba(245,158,11,0.34)'
                          : a.status === 'SCHEDULED'
                            ? 'rgba(56,189,248,0.24)'
                            : 'rgba(255,255,255,0.07)'
                    }
                    strokeWidth={isSel ? 1.5 : 1}
                    style={{ transition: 'fill 200ms ease, stroke 200ms ease' }}
                  />
                  {/* Left accent strip — director colour. Taller now so it
                      anchors the row firmly to its branch. */}
                  <rect
                    x={0}
                    y={6}
                    width={3.5}
                    height={ROW_H - 12}
                    rx={2}
                    fill={meta.color}
                    fillOpacity={isSel ? 1 : 0.65}
                  />
                  {/* Travelling ring for RUNNING agents — subtle dashed border
                      that animates so the running state reads at a glance. */}
                  {a.status === 'RUNNING' && (
                    <rect
                      width={AGENT_W}
                      height={ROW_H}
                      rx={9}
                      fill="none"
                      stroke="#f59e0b"
                      strokeOpacity={0.6}
                      strokeWidth={1}
                      strokeDasharray="3 6"
                    >
                      <animate
                        attributeName="stroke-dashoffset"
                        from="0"
                        to="-18"
                        dur="1.4s"
                        repeatCount="indefinite"
                      />
                    </rect>
                  )}
                  <circle cx={20} cy={ROW_H / 2} r={4.5} fill={sd}>
                    {isLive && (
                      <animate
                        attributeName="opacity"
                        values="1;0.4;1"
                        dur="1.8s"
                        repeatCount="indefinite"
                      />
                    )}
                  </circle>
                  <text
                    x={34}
                    y={ROW_H / 2 - 5}
                    fill="#fafafa"
                    fontSize={13.5}
                    fontFamily="Geist, sans-serif"
                    fontWeight="500"
                  >
                    {a.name}
                  </text>
                  <text
                    x={34}
                    y={ROW_H / 2 + 11}
                    fill={
                      a.status === 'RUNNING'
                        ? '#f59e0b'
                        : a.status === 'SCHEDULED'
                          ? '#38bdf8'
                          : a.status === 'IDLE'
                            ? '#3f3f46'
                            : '#71717a'
                    }
                    fontSize={10}
                    fontFamily="JetBrains Mono, monospace"
                  >
                    {a.status} · {a.schedule}
                  </text>
                  {/* Right-side: live sparkline + 24h count, vertically centred.
                      Falls back to static `output` text when no live data. */}
                  {bucketsByKey[a.key] && bucketsByKey[a.key].some((n) => n > 0) ? (
                    <>
                      <Sparkline
                        buckets={bucketsByKey[a.key]}
                        color={meta.color}
                        width={72}
                        height={20}
                        x={AGENT_W - 130}
                        y={(ROW_H - 20) / 2}
                      />
                      <text
                        x={AGENT_W - 14}
                        y={ROW_H / 2 - 4}
                        textAnchor="end"
                        fill="#e4e4e7"
                        fontSize={11}
                        fontFamily="Geist, sans-serif"
                        fontWeight="500"
                      >
                        {liveStatsByKey.get(a.key)?.count24h ?? 0}
                      </text>
                      <text
                        x={AGENT_W - 14}
                        y={ROW_H / 2 + 11}
                        textAnchor="end"
                        fill="#52525b"
                        fontSize={9}
                        fontFamily="JetBrains Mono, monospace"
                      >
                        runs · 24h
                      </text>
                    </>
                  ) : (
                    <text
                      x={AGENT_W - 14}
                      y={ROW_H / 2 + 3}
                      textAnchor="end"
                      fill="#71717a"
                      fontSize={10}
                      fontFamily="JetBrains Mono, monospace"
                    >
                      {a.output}
                    </text>
                  )}
                  {/* Anomaly halo — red ring when this agent has failed in the
                      last hour. Only renders when live data flags it. */}
                  {liveStatsByKey.get(a.key)?.failedRecently && (
                    <rect
                      x={-2}
                      y={-2}
                      width={AGENT_W + 4}
                      height={ROW_H + 4}
                      rx={11}
                      fill="none"
                      stroke="#ef4444"
                      strokeOpacity={0.55}
                      strokeWidth={1}
                    >
                      <animate
                        attributeName="stroke-opacity"
                        values="0.55;0.2;0.55"
                        dur="1.6s"
                        repeatCount="indefinite"
                      />
                    </rect>
                  )}
                </g>
              );
            }),
          )}

          {/* Footer hint */}
          <text
            x={VB_W / 2}
            y={VB_H - 6}
            textAnchor="middle"
            fill="#27272a"
            fontSize={10}
            fontFamily="Geist, sans-serif"
          >
            All drafts route through HR Lead approval — nothing sends without you
          </text>
        </svg>
      </DraggableScroll>

      {/* Agent detail strip */}
      {selected && (
        <div className="border-t border-white/5 bg-[rgb(10,12,15)] px-5 py-4 animate-in fade-in slide-in-from-bottom-2 duration-200">
          <AgentDetail agent={selected} onClose={() => setSelected(null)} />
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Inputs column (channels, data sources, triggers) rendered as SVG
// ─────────────────────────────────────────────────────────────────────────────

// Brand colours + glyph paths. Single-colour Simple-Icons-style SVG paths so
// each input renders as a recognisable badge without pulling a 3000-icon
// dependency. Paths are 24×24 viewBox, single-fill — coloured at render time
// with the brand hex, sat on a tinted disc so it reads at small sizes.
type BrandStyle = { color: string; path: string; bgFill?: string };

const BRAND: Record<string, BrandStyle> = {
  'Microsoft Teams': {
    color: '#5059C9',
    // Stylised "T" — Teams' identity at small sizes
    path: 'M3 5h12v3H10v8H8V8H3V5zm15 1h4v2h-1.5v8H19V8h-1V6z',
  },
  Slack: {
    color: '#E01E5A',
    // Hash-style four-square Slack glyph (simplified, single colour)
    path: 'M5 9V6.5a1.5 1.5 0 113 0V9H5zm-3 1.5A1.5 1.5 0 013.5 9H6v3H3.5A1.5 1.5 0 012 10.5zm12.5 4.5a1.5 1.5 0 11-3 0V12.5h3V15zm.5-12a1.5 1.5 0 11-3 0V.5h3V3zm-7.5 8H5V8h2.5a1.5 1.5 0 110 3zm.5 4.5A1.5 1.5 0 1110.5 17H8v-1.5zM17 9V6.5a1.5 1.5 0 113 0V9h-3zm3 1.5A1.5 1.5 0 0118.5 12H16V9h2.5a1.5 1.5 0 011.5 1.5z',
  },
  Gmail: {
    color: '#EA4335',
    path: 'M2 6l10 7L22 6v12a2 2 0 01-2 2H4a2 2 0 01-2-2V6zm10 4.5L4 5h16l-8 5.5z',
  },
  Email: {
    color: '#71717A',
    path: 'M2 6l10 7L22 6v12a2 2 0 01-2 2H4a2 2 0 01-2-2V6zm10 4.5L4 5h16l-8 5.5z',
  },
  'Breathe HR': {
    color: '#22C55E',
    // Person + leaf — Breathe HR is people-centric
    path: 'M12 4a3 3 0 110 6 3 3 0 010-6zm6 14v2H6v-2c0-3 4-5 6-5s6 2 6 5z',
  },
  HubSpot: {
    color: '#FF7A59',
    // Stylised HubSpot sprocket — circle + cross
    path: 'M18 9V5h-2v4.2A6 6 0 0010 11.1V8h-2v3.4A6 6 0 1014 18a6 6 0 005.5-3.6L21 16l1-1-2-2 .5-1.4A6 6 0 0018 9zm-4 7a3 3 0 110-6 3 3 0 010 6z',
  },
  Notion: {
    color: '#FAFAFA',
    // Notion's distinctive "N" notch
    path: 'M5 4h11l3 3v13H5V4zm2 2v12h10V8.4L15.6 7H7zm2 2h6v2H9V8zm0 4h6v2H9v-2z',
  },
  Calendly: {
    color: '#006BFF',
    path: 'M18 4h-1V3a1 1 0 10-2 0v1H9V3a1 1 0 10-2 0v1H6a2 2 0 00-2 2v13a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2zm0 15H6V8h12v11z',
  },
  Cron: {
    color: '#38BDF8',
    // Clock face
    path: 'M12 2a10 10 0 1010 10A10 10 0 0012 2zm5 11h-6V7h2v4h4v2z',
  },
  Webhooks: {
    color: '#A78BFA',
    // Three-node connector
    path: 'M6 16a3 3 0 116 0 3 3 0 01-6 0zm10-6a3 3 0 110 6 3 3 0 010-6zm-10-2a3 3 0 116 0 3 3 0 01-6 0z',
  },
};

function InputsColumn({
  channels,
  dataSources,
  triggers,
}: {
  channels: IntegrationGroup;
  dataSources: IntegrationGroup;
  triggers: IntegrationGroup;
}) {
  // All items in one flat list — no section headers (the reference design
  // doesn't have them and they were just visual noise at this size).
  const items = [...channels.items, ...dataSources.items, ...triggers.items];
  const cardH = 36;
  const cardGap = 8;
  // Centre the stack vertically inside the input card.
  const stackH = items.length * cardH + (items.length - 1) * cardGap;
  const startY = (VB_H - stackH) / 2;

  return (
    <g>
      {/* Outer container — same translucent glass treatment as other layers */}
      <rect
        x={INPUT_X}
        y={10}
        width={INPUT_W}
        height={VB_H - 20}
        rx={14}
        fill="rgba(255,255,255,0.02)"
        stroke="rgba(255,255,255,0.06)"
        strokeWidth={1}
      />
      {/* Compact section eyebrow at top */}
      <text
        x={INPUT_X + INPUT_W / 2}
        y={28}
        textAnchor="middle"
        fill="#3f3f46"
        fontSize={8.5}
        fontFamily="Geist, sans-serif"
        fontWeight="700"
        letterSpacing="1.8"
      >
        INPUTS · {items.length}
      </text>

      {items.map((item, i) => {
        const y = startY + i * (cardH + cardGap);
        const brand = BRAND[item.name] ?? BRAND['Email'];
        const isLive = item.status === 'live';
        return (
          <InputCard
            key={item.name}
            name={item.name}
            meta={item.meta}
            status={item.status}
            x={INPUT_X + 8}
            y={y}
            w={INPUT_W - 16}
            h={cardH}
            brand={brand}
            isLive={isLive}
          />
        );
      })}
    </g>
  );
}

// Single input card — colored badge (brand glyph) + name + status pulse.
function InputCard({
  name,
  meta,
  status,
  x,
  y,
  w,
  h,
  brand,
  isLive,
}: {
  name: string;
  meta?: string;
  status: 'live' | 'ready' | 'idle';
  x: number;
  y: number;
  w: number;
  h: number;
  brand: BrandStyle;
  isLive: boolean;
}) {
  const badgeR = h - 12;
  const badgeX = x + 6;
  const badgeY = y + 6;
  return (
    <g>
      {/* Card body — translucent so it sits on the canvas grid */}
      <rect
        x={x}
        y={y}
        width={w}
        height={h}
        rx={9}
        fill="rgba(255,255,255,0.025)"
        stroke="rgba(255,255,255,0.06)"
        strokeWidth={1}
      />
      {/* Brand badge — colored disc with the glyph centred on it */}
      <rect
        x={badgeX}
        y={badgeY}
        width={badgeR}
        height={badgeR}
        rx={6}
        fill={`${brand.color}1F`}
        stroke={`${brand.color}55`}
        strokeWidth={0.8}
      />
      <g transform={`translate(${badgeX + badgeR / 2 - 8}, ${badgeY + badgeR / 2 - 8}) scale(0.67)`}>
        <path d={brand.path} fill={brand.color} />
      </g>
      {/* Name */}
      <text
        x={badgeX + badgeR + 8}
        y={y + h / 2 + 1}
        fill={status === 'live' ? '#e4e4e7' : '#71717a'}
        fontSize={11}
        fontFamily="Geist, sans-serif"
        fontWeight="500"
        dominantBaseline="middle"
      >
        {name.length > 14 ? `${name.slice(0, 13)}…` : name}
      </text>
      {/* Status pulse — top-right corner of card */}
      <circle
        cx={x + w - 10}
        cy={y + 10}
        r={2.5}
        fill={isLive ? '#10b981' : status === 'ready' ? '#3f3f46' : '#27272a'}
      >
        {isLive && (
          <animate
            attributeName="opacity"
            values="1;0.35;1"
            dur="2.2s"
            repeatCount="indefinite"
          />
        )}
      </circle>
      {meta && (
        <text
          x={x + w - 10}
          y={y + h - 8}
          textAnchor="end"
          fill="#3f3f46"
          fontSize={8.5}
          fontFamily="JetBrains Mono, monospace"
        >
          {meta}
        </text>
      )}
    </g>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline agent detail panel
// ─────────────────────────────────────────────────────────────────────────────

function AgentDetail({ agent, onClose }: { agent: AgentSpec; onClose: () => void }) {
  const meta = DIRECTOR_META[agent.director];
  return (
    <div>
      <div className="flex items-start justify-between mb-3">
        <div>
          <p className="text-[10px] tracking-widest uppercase text-zinc-500 font-medium mb-1 flex items-center gap-2">
            <span
              className="w-1.5 h-1.5 rounded-full"
              style={{ background: meta.color }}
            />
            {agent.director} Director · sub-agent
          </p>
          <h3 className="font-display text-lg font-medium text-zinc-100 tracking-tight">
            {agent.name}
          </h3>
        </div>
        <div className="flex items-center gap-2">
          <span
            className="text-[10px] font-semibold tracking-wider px-2 py-0.5 rounded-full"
            style={{
              color: STATUS_DOT[agent.status],
              backgroundColor: `${STATUS_DOT[agent.status]}18`,
              border: `1px solid ${STATUS_DOT[agent.status]}40`,
            }}
          >
            {agent.status}
          </span>
          <button
            onClick={onClose}
            className="w-7 h-7 flex items-center justify-center rounded-lg hover:bg-white/5 text-zinc-500 hover:text-zinc-200 transition-colors"
            aria-label="Close detail"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      </div>

      <p className="text-sm text-zinc-300 leading-relaxed mb-4 max-w-3xl">
        {agent.description}
      </p>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
        <DetailStat label="Schedule" value={agent.schedule} />
        <DetailStat label="Output" value={agent.output} />
        <DetailStat label="Model" value={agent.model} mono color={meta.color} />
        <DetailStat label="p50 latency" value="1.8s" mono />
      </div>

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap gap-1.5">
          {agent.integrations.map((i) => (
            <span
              key={i}
              className="text-[10px] font-mono px-2 py-0.5 rounded bg-white/5 text-zinc-400"
            >
              {i}
            </span>
          ))}
        </div>
        <a
          href="settings"
          className="flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-lg ring-1 ring-white/10 text-zinc-300 hover:ring-emerald-400/40 hover:text-emerald-300 transition-all"
        >
          <Sliders className="w-3.5 h-3.5" />
          Configure
        </a>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AgentHeader — title bar at the very top of the canvas. Page identity (with
// concrete metric subtitle), view-mode tabs, primary CTA. Shaped after the
// reference Lumen Studio header but using Intel Force's HR-first language and
// governance-aware metrics ("approvals pending" instead of generic counts).
// ─────────────────────────────────────────────────────────────────────────────

const VIEW_MODES: { id: ViewMode; label: string; Icon: typeof Network }[] = [
  { id: 'hierarchy', label: 'Hierarchy', Icon: Network },
  { id: 'cards', label: 'Cards', Icon: LayoutGrid },
  { id: 'subagents', label: 'Subagents', Icon: Layers },
  { id: 'models', label: 'Models', Icon: CircuitBoard },
];

function AgentHeader({
  agents,
  live,
  viewMode,
  onViewMode,
}: {
  agents: AgentSpec[];
  live: ActivityPayload | null;
  viewMode: ViewMode;
  onViewMode: (m: ViewMode) => void;
}) {
  const directors = new Set(agents.map((a) => a.director));
  const lastActivity = live?.lastActivity ? relativeAgo(live.lastActivity) : null;
  const cost24h = live?.stats.reduce((s, x) => s + (x.costGbp24h ?? 0), 0) ?? 0;

  return (
    <div className="px-5 py-4 border-b border-white/5 flex items-start gap-4 flex-wrap">
      <div className="flex-1 min-w-0">
        <div className="flex items-baseline gap-3">
          <h2 className="font-display text-xl font-medium text-white tracking-tight">Agents</h2>
          <span className="flex items-center gap-1.5 text-[10px] uppercase tracking-widest text-emerald-300 font-semibold">
            <ShieldCheck className="w-3 h-3" />
            Approvals required
          </span>
        </div>
        <p className="text-xs text-zinc-400 mt-1">
          <span className="text-zinc-200 font-medium">{agents.length}</span> agents configured ·{' '}
          <span className="text-zinc-200 font-medium">{directors.size}</span> directors
          {lastActivity && (
            <>
              {' '}· last activity <span className="text-zinc-200">{lastActivity}</span>
            </>
          )}
          {cost24h > 0 && (
            <>
              {' '}· £<span className="text-zinc-200 font-mono">{cost24h.toFixed(2)}</span> spent (24h)
            </>
          )}
        </p>
      </div>

      <div className="flex items-center gap-2 shrink-0">
        {/* View-mode tabs */}
        <div className="flex items-center p-0.5 bg-white/[0.03] border border-white/[0.06] rounded-lg">
          {VIEW_MODES.map((m) => {
            const active = viewMode === m.id;
            return (
              <button
                key={m.id}
                onClick={() => onViewMode(m.id)}
                className={cn(
                  'px-2.5 py-1 text-[11px] rounded-md transition-colors flex items-center gap-1.5',
                  active
                    ? 'bg-white/[0.06] text-white'
                    : 'text-zinc-500 hover:text-zinc-200',
                )}
                title={m.label}
              >
                <m.Icon className="w-3 h-3" strokeWidth={1.5} />
                <span className="hidden md:inline">{m.label}</span>
              </button>
            );
          })}
        </div>

        {/* Primary CTA — Intel Force flavour: "Configure agent" routes to the
            existing wizard step rather than a generic "Add Agent". Customers
            don't add agents ad-hoc; they configure the bundle they bought. */}
        <button
          className="flex items-center gap-1.5 px-3 py-1.5 text-[11px] font-medium rounded-lg bg-emerald-400/10 border border-emerald-400/30 text-emerald-300 hover:bg-emerald-400/15 transition-colors"
          onClick={() => {
            // Scroll to the per-agent activity table (existing) — non-destructive
            // affordance until the configure-agent flow lands.
            document
              .querySelector('[data-agent-activity-table]')
              ?.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }}
        >
          <Plus className="w-3 h-3" strokeWidth={1.8} />
          Configure agent
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ActivityStrip — header showing the system's live state. The currently-running
// agent name rotates through the active set, the runs counter ticks gently,
// the "since last invocation" stamp counts up. Reads as a control room rather
// than a static "14 agents" label.
// ─────────────────────────────────────────────────────────────────────────────

function ActivityStrip({
  agents,
  live,
}: {
  agents: AgentSpec[];
  live: ActivityPayload | null;
}) {
  const liveAgents = agents.filter((a) => a.status === 'ACTIVE' || a.status === 'RUNNING');
  const running = agents.filter((a) => a.status === 'RUNNING');
  const scheduled = agents.filter((a) => a.status === 'SCHEDULED').length;

  // What's happening RIGHT NOW. Prefer the most recent real invocation from
  // the live feed; fall back to cycling through static RUNNING agents only
  // if we genuinely have no data yet.
  const nowAgent: { name: string; subtitle: string } | null = (() => {
    if (live && live.recent.length > 0) {
      const r = live.recent[0];
      const spec = agents.find((a) => keyForRow(r.agent) === a.key);
      const name = spec?.name ?? r.agent;
      const ago = relativeAgo(r.startedAt);
      const verb = r.status === 'RUNNING' ? 'running' : r.status === 'SUCCESS' ? `finished ${ago}` : `${r.status.toLowerCase()} ${ago}`;
      return { name, subtitle: verb };
    }
    if (running.length > 0) return { name: running[0].name, subtitle: 'running' };
    if (liveAgents.length > 0) return { name: liveAgents[0].name, subtitle: 'active' };
    return null;
  })();

  return (
    <div className="flex items-center justify-between px-5 py-3 border-b border-white/5">
      <div className="flex items-center gap-4 min-w-0">
        <p className="text-[10px] tracking-widest uppercase text-zinc-500 font-medium shrink-0">
          Agent system
        </p>
        <div className="flex items-center gap-2 text-xs min-w-0">
          <span className="relative flex h-2 w-2 shrink-0">
            <span className="absolute inset-0 rounded-full bg-emerald-400 animate-ping opacity-75" />
            <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-400" />
          </span>
          <span className="text-emerald-300 font-medium shrink-0">Live</span>
          <span className="text-zinc-600 shrink-0">·</span>
          {nowAgent ? (
            <span className="text-zinc-400 truncate">
              <span className="text-zinc-200">{nowAgent.name}</span>
              <span className="text-zinc-500"> {nowAgent.subtitle}</span>
            </span>
          ) : (
            <span className="text-zinc-500">No activity yet</span>
          )}
        </div>
      </div>

      <div className="flex items-center gap-4 text-[10px] text-zinc-500 shrink-0">
        <span className="flex items-center gap-1.5">
          <span className="font-mono text-zinc-300">{liveAgents.length}/{agents.length}</span>
          <span className="text-zinc-600">live</span>
        </span>
        <span className="flex items-center gap-1.5">
          <span className="font-mono text-zinc-300">{running.length}</span>
          <span className="text-zinc-600">running</span>
        </span>
        <span className="flex items-center gap-1.5">
          <span className="font-mono text-zinc-300">{scheduled}</span>
          <span className="text-zinc-600">scheduled</span>
        </span>
        {live?.lastActivity && (
          <>
            <span className="text-zinc-700">·</span>
            <span className="flex items-center gap-1.5">
              <span className="text-zinc-600">last invocation</span>
              <span className="font-mono text-zinc-300 tabular-nums" suppressHydrationWarning>
                {relativeAgo(live.lastActivity)}
              </span>
            </span>
          </>
        )}
      </div>
    </div>
  );
}

// Helper: map invocation.agent column (kebab-case slug) to AgentSpec.key.
// Kept loose to tolerate either form already in flight in the audit log.
function keyForRow(agentField: string): string {
  return agentField.toLowerCase().replace(/\s+/g, '-');
}

// Compact relative-time string for the activity strip + stream rows.
function relativeAgo(iso: string): string {
  const d = new Date(iso).getTime();
  const sec = Math.max(0, Math.floor((Date.now() - d) / 1000));
  if (sec < 5) return 'now';
  if (sec < 60) return `${sec}s ago`;
  const m = Math.floor(sec / 60);
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ago`;
  return `${Math.floor(h / 24)}d ago`;
}

// ─────────────────────────────────────────────────────────────────────────────
// InvocationStream — scrolling strip of recent invocations, just below the
// activity header. Click an agent's name to open its detail panel. Empty
// when there's nothing to show.
// ─────────────────────────────────────────────────────────────────────────────

function InvocationStream({
  rows,
  agents,
  onPick,
}: {
  rows: InvocationRow[];
  agents: AgentSpec[];
  onPick: (a: AgentSpec) => void;
}) {
  return (
    <div className="border-b border-white/5 bg-white/[0.01]">
      <div className="px-5 py-2 flex items-center gap-3 overflow-x-auto whitespace-nowrap">
        <span className="text-[9px] uppercase tracking-widest text-zinc-600 font-semibold shrink-0">
          Stream
        </span>
        {rows.map((r) => {
          const spec = agents.find((a) => keyForRow(r.agent) === a.key);
          const meta = spec ? DIRECTOR_META[spec.director] : null;
          const tone =
            r.status === 'FAILED'
              ? '#ef4444'
              : r.status === 'RUNNING'
                ? '#f59e0b'
                : r.status === 'SUCCESS'
                  ? '#10b981'
                  : '#52525b';
          return (
            <button
              key={r.id}
              onClick={() => spec && onPick(spec)}
              className="group flex items-center gap-1.5 text-[11px] text-zinc-400 hover:text-zinc-100 transition-colors shrink-0"
              title={r.trigger}
            >
              <span
                className="w-1.5 h-1.5 rounded-full shrink-0"
                style={{ background: tone, boxShadow: r.status === 'RUNNING' ? `0 0 6px ${tone}` : undefined }}
              />
              <span
                className="font-medium"
                style={{ color: meta?.color ?? '#e4e4e7' }}
              >
                {spec?.name ?? r.agent}
              </span>
              <span className="text-zinc-600 font-mono">
                {r.durationMs ? `${r.durationMs}ms` : '—'}
              </span>
              <span className="text-zinc-600 tabular-nums" suppressHydrationWarning>
                {relativeAgo(r.startedAt)}
              </span>
              <span className="text-zinc-700 mx-1">·</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkline — 24-hour activity histogram, rendered inline on each agent row.
// 24 bars across ~64px width, each bar's height ∝ count for that hour. A
// tasteful visual signal that beats "47 runs" by an order of magnitude.
// ─────────────────────────────────────────────────────────────────────────────

function Sparkline({
  buckets,
  color,
  width,
  height,
  x,
  y,
}: {
  buckets: number[];
  color: string;
  width: number;
  height: number;
  x: number;
  y: number;
}) {
  const max = Math.max(1, ...buckets);
  const barW = width / buckets.length;
  return (
    <g transform={`translate(${x}, ${y})`}>
      {buckets.map((n, i) => {
        const h = (n / max) * height;
        return (
          <rect
            key={i}
            x={i * barW + 0.5}
            y={height - h}
            width={Math.max(0.8, barW - 1)}
            height={Math.max(0, h)}
            rx={0.6}
            fill={color}
            fillOpacity={n === 0 ? 0.12 : 0.7}
          />
        );
      })}
    </g>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FlowParticle — a glowing dot that travels along an SVG path. Used on every
// connector in the agent web so the system reads as actively flowing data,
// not a static org chart. Speed/size driven by the source's activity level.
// ─────────────────────────────────────────────────────────────────────────────

function FlowParticle({
  pathId,
  color,
  dur,
  begin,
  radius,
}: {
  pathId: string;
  color: string;
  dur: number;
  begin: number;
  radius: number;
}) {
  return (
    <g>
      {/* Outer soft glow */}
      <circle r={radius * 2.2} fill={color} fillOpacity={0.18}>
        <animateMotion dur={`${dur}s`} repeatCount="indefinite" begin={`${begin}s`}>
          <mpath href={`#${pathId}`} />
        </animateMotion>
      </circle>
      {/* Bright core */}
      <circle r={radius} fill={color} fillOpacity={0.95}>
        <animateMotion dur={`${dur}s`} repeatCount="indefinite" begin={`${begin}s`}>
          <mpath href={`#${pathId}`} />
        </animateMotion>
      </circle>
    </g>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DraggableScroll — wrapper that horizontally scrolls when content overflows
// AND lets the user grab-and-drag to pan, with edge-fade cues that fade in
// only when scroll is possible. Native vertical scroll on the page still works
// because we never preventDefault unless the pointer is actively dragging.
// ─────────────────────────────────────────────────────────────────────────────

function DraggableScroll({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [showLeft, setShowLeft] = useState(false);
  const [showRight, setShowRight] = useState(false);
  const dragRef = useRef<{ x: number; left: number } | null>(null);
  const wasDragging = useRef(false);

  function updateCues() {
    const el = ref.current;
    if (!el) return;
    setShowLeft(el.scrollLeft > 4);
    setShowRight(el.scrollLeft < el.scrollWidth - el.clientWidth - 4);
  }

  useEffect(() => {
    updateCues();
    const el = ref.current;
    if (!el) return;
    const onScroll = () => updateCues();
    el.addEventListener('scroll', onScroll, { passive: true });
    const ro = new ResizeObserver(updateCues);
    ro.observe(el);
    return () => {
      el.removeEventListener('scroll', onScroll);
      ro.disconnect();
    };
  }, []);

  function onPointerDown(e: React.PointerEvent<HTMLDivElement>) {
    // Only left-button drags. Don't capture pointer events on actual interactive
    // children (buttons, agent rects) — those should receive their own clicks.
    if (e.button !== 0) return;
    const target = e.target as HTMLElement;
    if (target.closest('g[style*="cursor: pointer"], button, a')) return;
    const el = ref.current;
    if (!el) return;
    dragRef.current = { x: e.clientX, left: el.scrollLeft };
    wasDragging.current = false;
    el.setPointerCapture(e.pointerId);
  }

  function onPointerMove(e: React.PointerEvent<HTMLDivElement>) {
    const drag = dragRef.current;
    const el = ref.current;
    if (!drag || !el) return;
    const dx = e.clientX - drag.x;
    if (Math.abs(dx) > 3) wasDragging.current = true;
    el.scrollLeft = drag.left - dx;
  }

  function onPointerUp(e: React.PointerEvent<HTMLDivElement>) {
    dragRef.current = null;
    ref.current?.releasePointerCapture(e.pointerId);
    // Suppress the click that follows a drag (otherwise the agent rect under
    // the cursor would open its detail panel just because the user dragged).
    if (wasDragging.current) {
      const el = ref.current;
      if (el) {
        const swallow = (ev: MouseEvent) => {
          ev.stopPropagation();
          ev.preventDefault();
          el.removeEventListener('click', swallow, true);
        };
        el.addEventListener('click', swallow, true);
      }
    }
  }

  return (
    <div className={cn('relative overflow-hidden', className)}>
      <div
        ref={ref}
        className="overflow-x-auto overscroll-x-contain cursor-grab active:cursor-grabbing"
        style={{ touchAction: 'pan-x' }}
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerUp}
        onPointerCancel={onPointerUp}
      >
        {children}
      </div>
      {/* Edge-fade cues — fade in when there's content to scroll to */}
      <div
        className="pointer-events-none absolute top-0 bottom-0 left-0 w-12 bg-gradient-to-r from-[rgb(7,9,11)] to-transparent transition-opacity duration-200"
        style={{ opacity: showLeft ? 1 : 0 }}
      />
      <div
        className="pointer-events-none absolute top-0 bottom-0 right-0 w-12 bg-gradient-to-l from-[rgb(7,9,11)] to-transparent transition-opacity duration-200"
        style={{ opacity: showRight ? 1 : 0 }}
      />
      {/* "More →" hint, only when overflowing right */}
      <div
        className="pointer-events-none absolute bottom-3 right-4 text-[10px] text-zinc-500 font-mono transition-opacity duration-200"
        style={{ opacity: showRight ? 1 : 0 }}
      >
        drag to see more →
      </div>
    </div>
  );
}

function DetailStat({
  label,
  value,
  mono,
  color,
}: {
  label: string;
  value: string;
  mono?: boolean;
  color?: string;
}) {
  return (
    <div>
      <p className="text-[9px] uppercase tracking-widest text-zinc-600 font-semibold mb-1">
        {label}
      </p>
      <p
        className={`text-sm font-semibold ${mono ? 'font-mono' : ''}`}
        style={{ color: color ?? '#fafafa' }}
      >
        {value}
      </p>
    </div>
  );
}
