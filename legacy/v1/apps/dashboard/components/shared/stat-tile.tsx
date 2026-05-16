import { cn } from '@/lib/cn';

// StatTile — status-style tile with an icon, label, value (often non-numeric),
// and a hint underneath. Used on Knowledge, Settings overview, and anywhere
// a KPI is more about *state* than a *number*.
//
// For numerical KPIs with sparklines, use <StatCard> instead.

type Tone = 'neutral' | 'good' | 'warn' | 'danger';

const ringByTone: Record<Tone, string> = {
  neutral: 'ring-white/5 hover:ring-white/10',
  good: 'ring-emerald-400/20 hover:ring-emerald-400/30',
  warn: 'ring-amber-400/20 hover:ring-amber-400/30',
  danger: 'ring-red-500/20 hover:ring-red-500/30',
};

const iconByTone: Record<Tone, string> = {
  neutral: 'text-text-muted',
  good: 'text-emerald-400',
  warn: 'text-amber-400',
  danger: 'text-red-400',
};

export function StatTile({
  label,
  value,
  hint,
  icon: Icon,
  tone = 'neutral',
  className,
}: {
  label: string;
  // ReactNode so callers can wrap relative-time values in `<span suppressHydrationWarning>`
  value: React.ReactNode;
  hint?: string;
  icon?: React.ElementType;
  tone?: Tone;
  className?: string;
}) {
  return (
    <div
      className={cn(
        'bg-[rgb(var(--bg-surface))] rounded-2xl ring-1 transition-colors p-4 sm:p-5',
        ringByTone[tone],
        className,
      )}
    >
      <div className="flex items-start justify-between mb-3">
        <span className="text-[10px] tracking-[0.14em] uppercase text-text-muted font-medium">
          {label}
        </span>
        {Icon && <Icon className={cn('w-3.5 h-3.5 shrink-0', iconByTone[tone])} />}
      </div>
      <div className="font-display text-2xl sm:text-3xl font-light text-text-primary leading-none mb-1.5">
        {value}
      </div>
      {hint && <p className="text-xs text-text-muted">{hint}</p>}
    </div>
  );
}
