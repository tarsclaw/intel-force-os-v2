import { cn } from '@/lib/cn';

// KbdHint — small monospace chip for keyboard shortcuts. Examples: ⌘K, /, Esc.
export function KbdHint({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <kbd
      className={cn(
        'font-mono text-[10px] px-1.5 py-0.5 bg-white/5 border border-white/10 rounded text-text-muted',
        className,
      )}
    >
      {children}
    </kbd>
  );
}
