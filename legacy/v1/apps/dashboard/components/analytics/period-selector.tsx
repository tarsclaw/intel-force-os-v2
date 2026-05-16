'use client';

import { useRouter, usePathname, useSearchParams } from 'next/navigation';
import { cn } from '@/lib/cn';

const periods = [
  { key: '7d', label: '7 days' },
  { key: '30d', label: '30 days' },
  { key: '90d', label: '90 days' },
  { key: 'mtd', label: 'Month to date' },
];

export function PeriodSelector() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const active = searchParams.get('period') ?? 'mtd';

  function setActive(key: string) {
    const params = new URLSearchParams(searchParams.toString());
    if (key === 'mtd') params.delete('period');
    else params.set('period', key);
    const q = params.toString();
    router.push(q ? `${pathname}?${q}` : pathname, { scroll: false });
  }

  return (
    <div className="inline-flex items-center p-1 bg-[rgb(var(--bg-surface))] ring-1 ring-white/5 rounded-lg gap-0.5">
      {periods.map(({ key, label }) => (
        <button
          key={key}
          onClick={() => setActive(key)}
          className={cn(
            'px-3 py-1.5 text-xs font-medium rounded-md transition-all',
            active === key
              ? 'bg-white/[0.06] text-text-primary'
              : 'text-text-muted hover:text-text-secondary',
          )}
        >
          {label}
        </button>
      ))}
    </div>
  );
}
