import { cn } from '@/lib/cn';

// formatRelative — pure helper. Use directly when you need the string only.
// Returns: "now", "12s", "4m", "2h", "3d", or a localised date string for older.
export function formatRelative(date: Date | string | number): string {
  const d = date instanceof Date ? date : new Date(date);
  const diff = Date.now() - d.getTime();
  const s = Math.floor(diff / 1000);
  if (s < 5) return 'now';
  if (s < 60) return `${s}s`;
  const m = Math.floor(s / 60);
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h`;
  const days = Math.floor(h / 24);
  if (days < 7) return `${days}d`;
  return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
}

// <RelativeTime> — wrapped <time> element with the formatted string.
// suppressHydrationWarning because formatRelative depends on Date.now() — the
// few hundred ms between server render and client hydration produce harmless
// "12s ago" vs "13s ago" mismatches that React would otherwise complain about.
export function RelativeTime({
  date,
  className,
}: {
  date: Date | string | number;
  className?: string;
}) {
  const d = date instanceof Date ? date : new Date(date);
  return (
    <time
      dateTime={d.toISOString()}
      className={cn('text-[10px] font-mono text-text-muted', className)}
      suppressHydrationWarning
    >
      {formatRelative(d)}
    </time>
  );
}
