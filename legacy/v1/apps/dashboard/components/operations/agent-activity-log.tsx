'use client';

import { useEffect, useMemo, useState } from 'react';
import { ChevronDown, ArrowRight, LineChart, PenLine, Workflow, Users } from 'lucide-react';
import { cn } from '@/lib/cn';
import { Card, StatusPill, Eyebrow } from '@/components/shared';
import type { AgentActivityRow } from '@/lib/agent-activity';
import type { AgentStatus, Director } from '@/lib/agent-catalog';

// Agent activity log — list of agents grouped by director, with status / last
// run / output. Click a row to expand inline detail (description + recent
// activity feed + last output). Rows are derived server-side from real
// Invocation + Escalation rows; this component is purely presentational.

type DirMeta = {
  chip: string;
  icon: React.ElementType;
  hex: string;          // raw director colour (used for the row hover gradient)
  rgb: string;          // rgb(a) form for the gradient bleed
  textHex: string;
};

const DIRECTOR_META: Record<Director, DirMeta> = {
  HR: {
    chip: 'bg-violet-400/10 text-violet-300 ring-violet-400/20',
    icon: Users,
    hex: '#a78bfa',
    rgb: 'rgba(167, 139, 250, 0.10)',
    textHex: 'text-violet-300',
  },
  Sales: {
    chip: 'bg-sky-400/10 text-sky-300 ring-sky-400/20',
    icon: LineChart,
    hex: '#60a5fa',
    rgb: 'rgba(96, 165, 250, 0.10)',
    textHex: 'text-sky-300',
  },
  Marketing: {
    chip: 'bg-emerald-400/10 text-emerald-300 ring-emerald-400/20',
    icon: PenLine,
    hex: '#34d399',
    rgb: 'rgba(52, 211, 153, 0.10)',
    textHex: 'text-emerald-300',
  },
  Operations: {
    chip: 'bg-amber-400/10 text-amber-300 ring-amber-400/20',
    icon: Workflow,
    hex: '#fbbf24',
    rgb: 'rgba(251, 191, 36, 0.10)',
    textHex: 'text-amber-300',
  },
};

const STATUS_TONE: Record<AgentStatus, 'good' | 'warn' | 'info' | 'muted'> = {
  ACTIVE: 'good',
  RUNNING: 'warn',
  SCHEDULED: 'info',
  IDLE: 'muted',
};

// Director order matches the catalog file
const DIRECTOR_ORDER: Director[] = ['HR', 'Sales', 'Marketing', 'Operations'];

export function AgentActivityLog({ rows }: { rows: AgentActivityRow[] }) {
  const [activeNum, setActiveNum] = useState<string | null>(null);
  const [flickerNum, setFlickerNum] = useState<string | null>(null);

  // Group rows by director, preserving director order + within-group order
  const groups = useMemo(() => {
    return DIRECTOR_ORDER.map((director) => {
      const groupRows = rows.filter((r) => r.director === director);
      const running = groupRows.filter((r) => r.status === 'RUNNING').length;
      const active = groupRows.filter((r) => r.status === 'ACTIVE').length;
      return { director, rows: groupRows, running, active };
    }).filter((g) => g.rows.length > 0);
  }, [rows]);

  // Subtle live flicker — pick a random RUNNING agent every ~8s
  useEffect(() => {
    const running = rows.filter((r) => r.status === 'RUNNING');
    if (running.length === 0) return;
    const id = setInterval(() => {
      const pick = running[Math.floor(Math.random() * running.length)];
      setFlickerNum(pick.num);
      setTimeout(() => setFlickerNum(null), 1000);
    }, 8000);
    return () => clearInterval(id);
  }, [rows]);

  // Esc collapses any open row
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setActiveNum(null);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  return (
    <Card>
      <div className="px-5 py-4 border-b border-white/5 flex items-baseline justify-between gap-4">
        <div className="flex items-baseline gap-3 min-w-0">
          <Eyebrow>Agent activity</Eyebrow>
          <span className="text-[11px] font-mono text-text-muted truncate">
            {rows.length} agents · {groups.length} directors · click any row to expand
          </span>
        </div>
        <div className="flex items-center gap-2 text-[10px] font-mono text-emerald-400 tracking-wider shrink-0">
          <span className="relative flex h-1.5 w-1.5">
            <span className="absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-60 animate-ping" />
            <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-emerald-400" />
          </span>
          LIVE
        </div>
      </div>

      <div>
        {groups.map((group, groupIdx) => {
          const meta = DIRECTOR_META[group.director];
          return (
            <section key={group.director}>
              {/* Director group header */}
              <div
                className={cn(
                  'px-5 py-2.5 flex items-center gap-3',
                  'bg-white/[0.015]',
                  groupIdx > 0 && 'border-t border-white/5',
                  'border-b border-white/5',
                )}
              >
                <span
                  aria-hidden
                  className="h-3 w-[2px] rounded-full"
                  style={{ background: meta.hex }}
                />
                <span
                  className={cn(
                    'text-[10px] font-mono uppercase tracking-[0.18em] font-medium',
                    meta.textHex,
                  )}
                >
                  {group.director}
                </span>
                <span className="text-[10px] font-mono text-text-muted">
                  · {group.rows.length} agent{group.rows.length === 1 ? '' : 's'}
                </span>
                {group.running > 0 && (
                  <span className="text-[10px] font-mono text-amber-300">
                    · {group.running} running
                  </span>
                )}
                {group.active > 0 && (
                  <span className="text-[10px] font-mono text-emerald-300">
                    · {group.active} active
                  </span>
                )}
                {group.running === 0 && group.active === 0 && (
                  <span className="text-[10px] font-mono text-text-muted italic">
                    · awaiting first run
                  </span>
                )}
              </div>

              <ul className="divide-y divide-white/5">
                {group.rows.map((row) => {
                  const isOpen = activeNum === row.num;
                  const isAnyOpen = activeNum !== null;
                  const isDimmed = isAnyOpen && !isOpen;
                  const isFlicker = flickerNum === row.num;
                  const Icon = meta.icon;

                  return (
                    <li
                      key={row.num}
                      className={cn(
                        'relative transition-all duration-300 group/row',
                        isDimmed && 'opacity-50',
                        isOpen && 'bg-white/[0.015]',
                      )}
                    >
                      {/* Director-coloured hover glow — gradient bleed from left */}
                      <div
                        aria-hidden
                        className={cn(
                          'absolute inset-0 pointer-events-none transition-opacity duration-300',
                          isOpen
                            ? 'opacity-100'
                            : 'opacity-0 group-hover/row:opacity-100',
                        )}
                        style={{
                          background: `linear-gradient(90deg, ${meta.rgb} 0%, transparent 55%)`,
                        }}
                      />

                      {/* Active left border (sits above the gradient) */}
                      <div
                        className={cn(
                          'absolute left-0 top-0 bottom-0 w-[2px] transition-opacity duration-200',
                          isOpen ? 'opacity-100' : 'opacity-0',
                        )}
                        style={{ background: meta.hex }}
                      />

                      <button
                        onClick={() => setActiveNum(isOpen ? null : row.num)}
                        className={cn(
                          'relative w-full text-left px-4 sm:px-5 py-4 grid items-center gap-4',
                          'grid-cols-[28px_36px_1fr_auto] sm:grid-cols-[28px_36px_minmax(0,1fr)_auto_auto_auto_20px]',
                        )}
                        aria-expanded={isOpen}
                      >
                        <span className="text-[10px] font-mono text-text-muted tabular-nums">
                          #{row.num}
                        </span>

                        <span
                          className={cn(
                            'w-9 h-9 rounded-lg flex items-center justify-center ring-1',
                            meta.chip,
                          )}
                        >
                          <Icon className="w-4 h-4" />
                        </span>

                        <div className="min-w-0">
                          <div className="flex items-center gap-2">
                            <span className="text-sm font-medium text-text-primary truncate">
                              {row.name}
                            </span>
                            {row.hasNeverRun && (
                              <span className="text-[9px] font-mono uppercase tracking-wider text-text-muted/70 px-1.5 py-0.5 rounded ring-1 ring-white/5 bg-white/[0.02] whitespace-nowrap shrink-0">
                                awaiting first run
                              </span>
                            )}
                          </div>
                          <div className={cn(
                            'text-[10px] font-mono uppercase tracking-wider mt-0.5',
                            meta.textHex,
                            'opacity-70',
                          )}>
                            {row.director}
                          </div>
                        </div>

                        <div className="hidden sm:block">
                          <StatusPill
                            tone={STATUS_TONE[row.status]}
                            showDot
                            pulse={row.status === 'RUNNING' || isFlicker}
                            className={cn(isFlicker && 'ring-2 ring-emerald-400/40')}
                          >
                            {row.status}
                          </StatusPill>
                        </div>

                        <div className={cn(
                          "hidden sm:block text-[11px] font-mono tabular-nums whitespace-nowrap",
                          row.hasNeverRun ? "text-text-muted italic" : "text-text-secondary",
                        )}>
                          {row.lastRun}
                        </div>

                        <div className="text-right hidden sm:block">
                          <div className={cn(
                            "text-sm font-medium whitespace-nowrap",
                            row.hasNeverRun ? "text-text-muted" : "text-text-primary",
                          )}>
                            {row.output}
                          </div>
                          {row.delta && (
                            <div className="text-[10px] font-mono text-emerald-400 mt-0.5">
                              {row.delta} ↑
                            </div>
                          )}
                        </div>

                        <ChevronDown
                          className={cn(
                            'w-4 h-4 text-text-muted transition-transform duration-300 hidden sm:block',
                            isOpen && 'rotate-180 text-emerald-400',
                          )}
                        />

                        <div className="col-span-4 sm:hidden flex items-center justify-between gap-3 pt-1">
                          <StatusPill
                            tone={STATUS_TONE[row.status]}
                            showDot
                            pulse={row.status === 'RUNNING' || isFlicker}
                          >
                            {row.status}
                          </StatusPill>
                          <span className="text-[11px] font-mono text-text-secondary">
                            {row.lastRun}
                          </span>
                          <span className="text-xs font-medium text-text-primary truncate">
                            {row.output}
                          </span>
                        </div>
                      </button>

                      <div
                        className={cn(
                          'relative grid transition-all duration-300 ease-out',
                          isOpen ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0',
                        )}
                      >
                        <div className="overflow-hidden">
                          <div className="px-4 sm:px-5 pb-6 pt-2">
                            <div className="grid lg:grid-cols-[1.1fr_1fr] gap-6 lg:gap-10 mb-7">
                              <div>
                                <Eyebrow className="mb-3">What this agent does</Eyebrow>
                                <p className="text-sm text-text-secondary leading-relaxed">
                                  {row.description}
                                </p>
                              </div>
                              <div>
                                <Eyebrow className="mb-3">Last output · preview</Eyebrow>
                                <blockquote
                                  className="border-l-2 pl-4 pr-3 py-3 rounded-r"
                                  style={{
                                    borderLeftColor: meta.hex,
                                    background: meta.rgb,
                                  }}
                                >
                                  <p className="text-sm text-text-secondary italic leading-relaxed">
                                    “{row.lastOutput}”
                                  </p>
                                </blockquote>
                              </div>
                            </div>

                            <div className="mb-6">
                              <Eyebrow className="mb-4">Recent activity · last 7 days</Eyebrow>
                              <ul className="space-y-2.5">
                                {row.recent.map((evt, i) => (
                                  <li
                                    key={i}
                                    className="grid grid-cols-[12px_72px_1fr] gap-3 items-baseline"
                                    style={{
                                      animation: isOpen
                                        ? `fadeInUp 240ms ${100 + i * 40}ms ease-out backwards`
                                        : 'none',
                                    }}
                                  >
                                    <span
                                      className={cn(
                                        'w-1.5 h-1.5 rounded-full mt-2',
                                        evt.escalation
                                          ? 'bg-transparent ring-1 ring-amber-400'
                                          : evt.time === '—'
                                          ? 'bg-text-muted/40'
                                          : 'bg-emerald-400',
                                      )}
                                    />
                                    <span className="text-[10px] font-mono text-text-muted tabular-nums">
                                      {evt.time}
                                    </span>
                                    <span className={cn(
                                      'text-[13px] leading-relaxed',
                                      evt.time === '—'
                                        ? 'text-text-muted italic'
                                        : 'text-text-secondary',
                                    )}>
                                      {evt.label}
                                    </span>
                                  </li>
                                ))}
                              </ul>
                            </div>

                            <div className="flex items-center gap-2">
                              <button
                                className="inline-flex items-center gap-2 text-[11px] font-medium px-3.5 py-2 rounded-lg bg-white/[0.04] ring-1 ring-white/10 text-text-secondary hover:text-text-primary transition-all"
                                style={{
                                  // director-coloured hover ring via inline CSS var
                                  ['--hover-ring' as string]: meta.hex,
                                }}
                                onMouseEnter={(e) => {
                                  e.currentTarget.style.boxShadow = `inset 0 0 0 1px ${meta.hex}40`;
                                }}
                                onMouseLeave={(e) => {
                                  e.currentTarget.style.boxShadow = '';
                                }}
                              >
                                Inspect this agent
                                <ArrowRight className="w-3.5 h-3.5" />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </li>
                  );
                })}
              </ul>
            </section>
          );
        })}
      </div>

      <style jsx>{`
        @keyframes fadeInUp {
          from {
            opacity: 0;
            transform: translateY(4px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
      `}</style>
    </Card>
  );
}
