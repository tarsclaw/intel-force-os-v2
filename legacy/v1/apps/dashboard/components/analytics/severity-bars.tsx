'use client';

import { BarChart, Bar, XAxis, YAxis, Tooltip, Cell, ResponsiveContainer } from 'recharts';

interface SeverityBarsProps {
  data: Array<{ severity: string; count: number; pct: number }>;
}

const colors: Record<string, string> = {
  CRITICAL: '#ef4444',
  HIGH: '#f59e0b',
  MEDIUM: '#71717a',
  LOW: '#3f3f46',
};

export function SeverityBars({ data }: SeverityBarsProps) {
  if (data.length === 0) {
    return (
      <div className="flex items-center justify-center h-40 text-sm text-text-muted">
        No data
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {data.map((d) => (
        <div key={d.severity} className="flex items-center gap-3">
          <span className="text-[11px] font-medium text-text-muted w-16 shrink-0">
            {d.severity}
          </span>
          <div className="flex-1 h-2 rounded-full bg-white/5 overflow-hidden">
            <div
              className="h-full rounded-full transition-all"
              style={{ width: `${d.pct}%`, backgroundColor: colors[d.severity] ?? '#71717a' }}
            />
          </div>
          <span className="text-[11px] font-mono text-text-muted w-12 text-right shrink-0">
            {d.pct}%
          </span>
        </div>
      ))}
    </div>
  );
}
