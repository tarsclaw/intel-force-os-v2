import { cn } from '@/lib/cn';

// Eyebrow — uppercase, tracked label used above headings, sections, and stat values.
// Standard typography: 10px / 0.14em letter-spacing / muted text.
export function Eyebrow({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <p
      className={cn(
        'text-[10px] tracking-[0.14em] uppercase text-text-muted font-medium',
        className,
      )}
    >
      {children}
    </p>
  );
}
