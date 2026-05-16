'use client';

import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';

interface VolumeChartProps {
  data: Array<{ date: string; count: number }>;
}

export function VolumeChart({ data }: VolumeChartProps) {
  if (data.length === 0) {
    return (
      <div className="flex items-center justify-center h-40 text-sm text-text-muted">
        No data for this period
      </div>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={160}>
      <AreaChart data={data} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
        <defs>
          <linearGradient id="volumeFill" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#10b981" stopOpacity={0.2} />
            <stop offset="100%" stopColor="#10b981" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#ffffff08" vertical={false} />
        <XAxis
          dataKey="date"
          tick={{ fill: '#71717a', fontSize: 10 }}
          tickLine={false}
          axisLine={false}
          tickFormatter={(v: string) => {
            const d = new Date(v);
            return `${d.getDate()}/${d.getMonth() + 1}`;
          }}
          interval="preserveStartEnd"
        />
        <YAxis tick={{ fill: '#71717a', fontSize: 10 }} tickLine={false} axisLine={false} />
        <Tooltip
          contentStyle={{
            background: '#0d1014',
            border: '1px solid rgba(255,255,255,0.08)',
            borderRadius: '0.5rem',
            fontSize: '11px',
            color: '#fafafa',
          }}
          itemStyle={{ color: '#10b981' }}
          labelStyle={{ color: '#a1a1aa' }}
          cursor={{ stroke: '#10b981', strokeOpacity: 0.3, strokeWidth: 1 }}
        />
        <Area
          type="monotone"
          dataKey="count"
          stroke="#10b981"
          strokeWidth={1.5}
          fill="url(#volumeFill)"
          dot={false}
          activeDot={{ r: 3, fill: '#10b981', strokeWidth: 0 }}
        />
      </AreaChart>
    </ResponsiveContainer>
  );
}
