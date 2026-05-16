import { AlertTriangle, TrendingUp, Zap, CheckCircle } from 'lucide-react';
import { cn } from '../../lib/cn';

interface KpiTilesProps {
  openEscalations: number;
  monthSpendGbp: number;
  budgetGbp: number | null;
  invocationsTotal: number;
  invocationsDelta: number;
  successRate: number;
}

export function KpiTiles({
  openEscalations,
  monthSpendGbp,
  budgetGbp,
  invocationsTotal,
  invocationsDelta,
  successRate,
}: KpiTilesProps) {
  const budgetPercent = budgetGbp ? Math.round((monthSpendGbp / budgetGbp) * 100) : null;
  const escalationColour =
    openEscalations === 0
      ? 'text-brand-emerald'
      : openEscalations < 3
      ? 'text-brand-amber'
      : 'text-red-400';

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
      {/* Open escalations */}
      <div className="bg-surface border border-border rounded-lg p-4">
        <div className="flex items-center gap-2 mb-2">
          <AlertTriangle className="w-3.5 h-3.5 text-text-muted" />
          <span className="text-xs text-text-muted uppercase tracking-wide">Escalations</span>
        </div>
        <p className={cn('text-3xl font-semibold tabular-nums', escalationColour)}>
          {openEscalations}
        </p>
        <p className="text-xs text-text-muted mt-1">open right now</p>
      </div>

      {/* Month spend */}
      <div className="bg-surface border border-border rounded-lg p-4">
        <div className="flex items-center gap-2 mb-2">
          <TrendingUp className="w-3.5 h-3.5 text-text-muted" />
          <span className="text-xs text-text-muted uppercase tracking-wide">Spend</span>
        </div>
        <p className="text-3xl font-semibold tabular-nums text-text-primary">
          £{monthSpendGbp.toFixed(2)}
        </p>
        {budgetPercent !== null && (
          <div className="mt-2">
            <div className="h-1 bg-border rounded-full overflow-hidden">
              <div
                className={cn(
                  'h-full rounded-full transition-all',
                  budgetPercent < 70
                    ? 'bg-brand-emerald'
                    : budgetPercent < 90
                    ? 'bg-brand-amber'
                    : 'bg-red-500',
                )}
                style={{ width: `${Math.min(budgetPercent, 100)}%` }}
              />
            </div>
            <p className="text-xs text-text-muted mt-1">
              {budgetPercent}% of £{budgetGbp?.toFixed(0)} budget
            </p>
          </div>
        )}
        {budgetPercent === null && (
          <p className="text-xs text-text-muted mt-1">this month</p>
        )}
      </div>

      {/* Invocations */}
      <div className="bg-surface border border-border rounded-lg p-4">
        <div className="flex items-center gap-2 mb-2">
          <Zap className="w-3.5 h-3.5 text-text-muted" />
          <span className="text-xs text-text-muted uppercase tracking-wide">Invocations</span>
        </div>
        <p className="text-3xl font-semibold tabular-nums text-text-primary">
          {invocationsTotal.toLocaleString()}
        </p>
        <p className={cn('text-xs mt-1', invocationsDelta >= 0 ? 'text-brand-emerald' : 'text-red-400')}>
          {invocationsDelta >= 0 ? '+' : ''}{invocationsDelta} vs last week
        </p>
      </div>

      {/* Success rate */}
      <div className="bg-surface border border-border rounded-lg p-4">
        <div className="flex items-center gap-2 mb-2">
          <CheckCircle className="w-3.5 h-3.5 text-text-muted" />
          <span className="text-xs text-text-muted uppercase tracking-wide">Success Rate</span>
        </div>
        <p
          className={cn(
            'text-3xl font-semibold tabular-nums',
            successRate >= 90 ? 'text-brand-emerald' : successRate >= 70 ? 'text-brand-amber' : 'text-red-400',
          )}
        >
          {successRate}%
        </p>
        <p className="text-xs text-text-muted mt-1">this period</p>
      </div>
    </div>
  );
}
