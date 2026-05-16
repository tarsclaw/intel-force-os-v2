import { cn } from '@/lib/cn';

interface StatCardProps {
  label: string;
  value: string;
  delta?: string;
  deltaPositive?: boolean;
  sparkData?: number[];
  sparkColor?: 'emerald' | 'amber' | 'red';
  className?: string;
}

function Sparkline({ data, color }: { data: number[]; color: string }) {
  if (data.length < 2) return null;
  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;
  const pts = data
    .map((v, i) => `${(i / (data.length - 1)) * 100},${28 - ((v - min) / range) * 22}`)
    .join(' ');
  return (
    <svg viewBox="0 0 100 28" className="w-full h-7 overflow-visible" aria-hidden="true">
      <polyline fill="none" stroke={color} strokeWidth="1.5" points={pts} strokeLinecap="round" strokeLinejoin="round" />
      <polygon fill={`${color}22`} points={`0,28 ${pts} 100,28`} />
    </svg>
  );
}

export function StatCard({
  label,
  value,
  delta,
  deltaPositive,
  sparkData,
  sparkColor = 'emerald',
  className,
}: StatCardProps) {
  const colors = { emerald: '#10b981', amber: '#f59e0b', red: '#ef4444' };

  return (
    <div
      className={cn(
        'relative bg-[rgb(var(--bg-surface))] rounded-2xl p-5 ring-1 ring-white/5',
        'hover:ring-emerald-400/20 transition-all overflow-hidden',
        className,
      )}
    >
      <div className="flex items-start justify-between mb-2">
        <p className="text-[11px] tracking-[0.14em] uppercase text-text-muted font-medium">
          {label}
        </p>
        {delta && (
          <span
            className={cn(
              'text-[10px] font-mono',
              delta === 'stable'
                ? 'text-text-muted'
                : deltaPositive !== false
                  ? 'text-emerald-400'
                  : 'text-red-400',
            )}
          >
            {delta}
          </span>
        )}
      </div>
      <p className="font-display text-3xl font-light text-text-primary leading-none mb-3">
        {value}
      </p>
      {sparkData && <Sparkline data={sparkData} color={colors[sparkColor]} />}
    </div>
  );
}
