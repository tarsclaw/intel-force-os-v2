import { cn } from '@/lib/cn';

// PageHeader — consistent page title block. Most pages should use this so spacing,
// title scale, and the actions row look identical everywhere.
//
// Hero variant adds a glow + a "Live" tag (used on Overview).
export function PageHeader({
  title,
  description,
  actions,
  liveTag,
  variant = 'default',
  className,
}: {
  title: React.ReactNode;
  description?: React.ReactNode;
  actions?: React.ReactNode;
  liveTag?: React.ReactNode; // small element rendered above title (e.g. "LIVE · synced 8s ago")
  variant?: 'default' | 'hero';
  className?: string;
}) {
  if (variant === 'hero') {
    return (
      <div className={cn('relative pb-2', className)}>
        <div
          className="absolute -top-10 -left-20 w-[500px] h-[300px] pointer-events-none"
          style={{
            background:
              'radial-gradient(ellipse at 30% 50%, rgba(16, 185, 129, 0.07) 0%, transparent 70%)',
          }}
          aria-hidden="true"
        />
        <div className="relative flex flex-col sm:flex-row sm:items-end justify-between gap-4">
          <div>
            {liveTag}
            <h1 className="font-display text-3xl sm:text-[42px] leading-none text-text-primary font-light tracking-tight mt-3">
              {title}
            </h1>
            {description && (
              <p className="text-sm text-text-secondary mt-2">{description}</p>
            )}
          </div>
          {actions && <div className="flex items-center gap-2">{actions}</div>}
        </div>
      </div>
    );
  }

  return (
    <header className={cn('flex items-end justify-between gap-4 flex-wrap', className)}>
      <div className="min-w-0">
        {liveTag}
        <h1 className="font-display text-2xl sm:text-3xl font-light text-text-primary tracking-tight">
          {title}
        </h1>
        {description && (
          <p className="text-sm text-text-muted mt-1 max-w-xl">{description}</p>
        )}
      </div>
      {actions && <div className="flex gap-2 shrink-0">{actions}</div>}
    </header>
  );
}

// Reusable Live tag for hero variant
export function LiveTag({ children }: { children: React.ReactNode }) {
  return (
    <p className="text-[11px] tracking-[0.18em] uppercase text-emerald-400 font-medium flex items-center gap-2">
      <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 pulse-dot" />
      {children}
    </p>
  );
}
