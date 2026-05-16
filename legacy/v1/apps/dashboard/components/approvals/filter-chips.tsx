'use client';

import { useRouter, usePathname, useSearchParams } from 'next/navigation';
import { cn } from '@/lib/cn';

interface FilterChipsProps {
  counts: { all: number; critical: number; high: number; medium: number; low: number };
}

const chips: { key: 'all' | 'critical' | 'high' | 'medium' | 'low'; label: string; color?: string }[] = [
  { key: 'all', label: 'All' },
  { key: 'critical', label: 'Critical', color: 'red' },
  { key: 'high', label: 'High', color: 'amber' },
  { key: 'medium', label: 'Medium', color: 'zinc' },
  { key: 'low', label: 'Low', color: 'zinc' },
];

const dotByColor: Record<string, string> = {
  red: 'bg-red-500',
  amber: 'bg-amber-400',
  zinc: 'bg-zinc-500',
};

export function FilterChips({ counts }: FilterChipsProps) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const active = searchParams.get('sev') ?? 'all';

  function setActive(key: string) {
    const params = new URLSearchParams(searchParams.toString());
    if (key === 'all') {
      params.delete('sev');
    } else {
      params.set('sev', key);
    }
    const q = params.toString();
    router.push(q ? `${pathname}?${q}` : pathname, { scroll: false });
  }

  return (
    <div className="flex items-center gap-1.5 flex-wrap">
      {chips.map(({ key, label, color }) => {
        const count = counts[key as keyof typeof counts];
        const isActive = active === key;
        return (
          <button
            key={key}
            onClick={() => setActive(key)}
            className={cn(
              'inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full ring-1 transition-all',
              isActive
                ? 'bg-white/[0.06] ring-white/15 text-text-primary'
                : 'bg-transparent ring-white/8 text-text-muted hover:text-text-secondary hover:ring-white/15',
            )}
          >
            {color && (
              <span className={cn('w-1.5 h-1.5 rounded-full shrink-0', dotByColor[color])} />
            )}
            {label}
            <span
              className={cn(
                'font-mono text-[10px]',
                isActive ? 'text-text-secondary' : 'text-text-muted',
              )}
            >
              {count}
            </span>
          </button>
        );
      })}
    </div>
  );
}
