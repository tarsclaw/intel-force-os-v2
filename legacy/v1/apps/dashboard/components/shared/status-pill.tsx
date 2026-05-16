import { cn } from '@/lib/cn';

// StatusPill — coloured rounded pill with optional dot. Use for status indicators
// (UPLOADED, CONNECTED, INDEXED, COMING SOON), document states, etc.
// For severity badges (CRITICAL/HIGH/MEDIUM/LOW), use <SensitivityBadge>.

type Tone = 'good' | 'warn' | 'danger' | 'muted' | 'info' | 'brand';

const styles: Record<Tone, string> = {
  good: 'bg-emerald-400/10 text-emerald-400 ring-emerald-400/20',
  warn: 'bg-amber-400/10 text-amber-300 ring-amber-400/20',
  danger: 'bg-red-500/10 text-red-400 ring-red-500/20',
  muted: 'bg-white/5 text-text-muted ring-white/10',
  info: 'bg-sky-400/10 text-sky-300 ring-sky-400/20',
  brand: 'bg-violet-400/10 text-violet-300 ring-violet-400/20',
};

const dotStyles: Record<Tone, string> = {
  good: 'bg-emerald-400',
  warn: 'bg-amber-400',
  danger: 'bg-red-500',
  muted: 'bg-text-muted',
  info: 'bg-sky-400',
  brand: 'bg-violet-400',
};

export function StatusPill({
  children,
  tone = 'good',
  pulse = false,
  showDot = false,
  icon: Icon,
  className,
}: {
  children: React.ReactNode;
  tone?: Tone;
  pulse?: boolean;
  showDot?: boolean;
  icon?: React.ElementType;
  className?: string;
}) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 text-[10px] font-medium px-2 py-0.5 rounded-full ring-1 tracking-wider',
        styles[tone],
        className,
      )}
    >
      {showDot && (
        <span className={cn('w-1.5 h-1.5 rounded-full shrink-0', dotStyles[tone], pulse && 'pulse-dot')} />
      )}
      {Icon && <Icon className="w-3 h-3 shrink-0" />}
      {children}
    </span>
  );
}
