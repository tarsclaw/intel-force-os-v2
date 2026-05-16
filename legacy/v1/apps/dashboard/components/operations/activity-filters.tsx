'use client';

import { useRouter, usePathname, useSearchParams } from 'next/navigation';
import { cn } from '@/lib/cn';

type CountMap = Record<string, number>;

interface Props {
  totals: CountMap;
}

const severities = [
  { key: 'all', label: 'All', dot: null },
  { key: 'CRITICAL', label: 'Critical', dot: 'bg-red-500' },
  { key: 'ERROR', label: 'Error', dot: 'bg-red-400' },
  { key: 'WARN', label: 'Warn', dot: 'bg-amber-400' },
  { key: 'INFO', label: 'Info', dot: 'bg-zinc-500' },
];

export function ActivityFilters({ totals }: Props) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const active = searchParams.get('sev') ?? 'all';

  function setActive(key: string) {
    const params = new URLSearchParams(searchParams.toString());
    if (key === 'all') params.delete('sev');
    else params.set('sev', key);
    const q = params.toString();
    router.push(q ? `${pathname}?${q}` : pathname, { scroll: false });
  }

  return (
    <div className="flex items-center gap-1.5 flex-wrap">
      {severities.map(({ key, label, dot }) => {
        const count = totals[key] ?? 0;
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
            {dot && <span className={cn('w-1.5 h-1.5 rounded-full shrink-0', dot)} />}
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
