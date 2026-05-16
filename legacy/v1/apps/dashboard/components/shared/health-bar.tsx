import { cn } from '@/lib/cn';

// HealthBar — labeled progress bar with status text. Used for policy coverage,
// data availability, completeness checks. Threshold defaults: >=80 GOOD,
// >=40 PARTIAL, <40 THIN. Pass `status` to override the auto-status text.

type Tone = 'auto' | 'good' | 'warn' | 'danger';

function autoTone(pct: number): Exclude<Tone, 'auto'> {
  if (pct >= 80) return 'good';
  if (pct >= 40) return 'warn';
  return 'danger';
}

const colorByTone = {
  good: 'bg-emerald-400',
  warn: 'bg-amber-400',
  danger: 'bg-red-500',
};

const textByTone = {
  good: 'text-emerald-400',
  warn: 'text-amber-400',
  danger: 'text-red-400',
};

const defaultStatus = {
  good: 'GOOD',
  warn: 'PART',
  danger: 'THIN',
};

export function HealthBar({
  label,
  pct,
  status,
  tone = 'auto',
  labelWidth = 'w-44',
  className,
}: {
  label: string;
  pct: number;
  status?: string;
  tone?: Tone;
  labelWidth?: string;
  className?: string;
}) {
  const resolved = tone === 'auto' ? autoTone(pct) : tone;
  const statusText = status ?? defaultStatus[resolved];
  return (
    <div className={cn('flex items-center gap-3', className)}>
      <span className={cn('text-xs text-text-secondary shrink-0 truncate', labelWidth)}>
        {label}
      </span>
      <div className="flex-1 h-1.5 rounded-full bg-white/5 overflow-hidden">
        <div
          className={cn('h-full rounded-full', colorByTone[resolved])}
          style={{ width: `${Math.max(0, Math.min(100, pct))}%` }}
        />
      </div>
      <span
        className={cn(
          'text-[10px] font-medium font-mono w-14 text-right shrink-0',
          textByTone[resolved],
        )}
      >
        {statusText}
      </span>
    </div>
  );
}
