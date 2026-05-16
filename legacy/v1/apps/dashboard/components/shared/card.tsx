import { cn } from '@/lib/cn';

// Base card surface used everywhere. Variants:
//   default   — standard card
//   raised    — slightly lighter background (for nested cards)
//   interactive — adds hover ring + cursor pointer (use when card is a Link)
//
// Header is opt-in. Pass icon + title + accessory for the standard pattern.
type Variant = 'default' | 'raised' | 'interactive';

const variantClass: Record<Variant, string> = {
  default: 'bg-[rgb(var(--bg-surface))] ring-1 ring-white/5',
  raised: 'bg-[rgb(var(--bg-raised))] ring-1 ring-white/5',
  interactive:
    'bg-[rgb(var(--bg-surface))] ring-1 ring-white/5 hover:ring-emerald-400/20 transition-all',
};

export function Card({
  children,
  variant = 'default',
  className,
  ...rest
}: {
  children: React.ReactNode;
  variant?: Variant;
  className?: string;
} & React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={cn('rounded-2xl overflow-hidden', variantClass[variant], className)} {...rest}>
      {children}
    </div>
  );
}

export function CardHeader({
  icon: Icon,
  title,
  subtitle,
  accessory,
  className,
}: {
  icon?: React.ElementType;
  title: React.ReactNode;
  subtitle?: React.ReactNode;
  accessory?: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={cn(
        'px-5 py-4 border-b border-white/5 flex items-center gap-3',
        className,
      )}
    >
      {Icon && <Icon className="w-4 h-4 text-emerald-400 shrink-0" />}
      <div className="min-w-0 flex-1">
        <h2 className="text-sm font-semibold text-text-primary truncate">{title}</h2>
        {subtitle && (
          <p className="text-[11px] text-text-muted truncate -mt-px">{subtitle}</p>
        )}
      </div>
      {accessory && <div className="shrink-0 ml-auto flex items-center gap-2">{accessory}</div>}
    </div>
  );
}

export function CardBody({
  children,
  className,
  padding = 'normal',
}: {
  children: React.ReactNode;
  className?: string;
  padding?: 'normal' | 'tight' | 'none';
}) {
  const padCls =
    padding === 'tight' ? 'px-5 py-3' : padding === 'none' ? '' : 'px-5 py-5';
  return <div className={cn(padCls, className)}>{children}</div>;
}
