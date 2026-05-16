import { cn } from '@/lib/cn';

export type Severity = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

const styles: Record<Severity, string> = {
  CRITICAL: 'bg-red-500/10 ring-red-500/30 text-red-400',
  HIGH: 'bg-amber-400/10 ring-amber-400/30 text-amber-300',
  MEDIUM: 'bg-zinc-500/10 ring-zinc-500/30 text-zinc-400',
  LOW: 'bg-zinc-700/10 ring-zinc-700/20 text-zinc-500',
};

const dotStyles: Record<Severity, string> = {
  CRITICAL: 'bg-red-500',
  HIGH: 'bg-amber-400',
  MEDIUM: 'bg-zinc-500',
  LOW: 'bg-zinc-600',
};

interface SensitivityBadgeProps {
  severity: Severity;
  score?: number;
  className?: string;
}

export function SensitivityBadge({ severity, score, className }: SensitivityBadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full',
        'text-[10px] font-medium tracking-wider ring-1',
        styles[severity],
        className,
      )}
    >
      <span className={cn('w-1.5 h-1.5 rounded-full shrink-0', dotStyles[severity])} />
      {severity}
      {score !== undefined && (
        <span className="font-mono opacity-60 ml-0.5">{score.toFixed(2)}</span>
      )}
    </span>
  );
}
