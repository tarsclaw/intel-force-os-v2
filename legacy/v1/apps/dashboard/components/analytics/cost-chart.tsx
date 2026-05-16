'use client';

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ReferenceLine,
  ResponsiveContainer,
} from 'recharts';

interface CostChartProps {
  data: Array<{ date: string; costGbp: number }>;
  budgetGbp: number | null;
}

export function CostChart({ data, budgetGbp }: CostChartProps) {
  if (data.length === 0) {
    return (
      <div className="flex items-center justify-center h-40 text-sm text-text-muted">
        No cost data for this period
      </div>
    );
  }

  // Running total for each day
  let cumulative = 0;
  const cumData = data.map((d) => {
    cumulative += d.costGbp;
    return { date: d.date, daily: d.costGbp, cumulative };
  });

  const overBudget = budgetGbp !== null && cumulative > budgetGbp;

  return (
    <ResponsiveContainer width="100%" height={160}>
      <LineChart data={cumData} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
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
        <YAxis
          tick={{ fill: '#71717a', fontSize: 10 }}
          tickLine={false}
          axisLine={false}
          tickFormatter={(v: number) => `£${v.toFixed(0)}`}
        />
        <Tooltip
          contentStyle={{
            background: '#0d1014',
            border: '1px solid rgba(255,255,255,0.08)',
            borderRadius: '0.5rem',
            fontSize: '11px',
            color: '#fafafa',
          }}
          formatter={(value: number, name: string) => [
            `£${value.toFixed(3)}`,
            name === 'cumulative' ? 'Running total' : 'Daily',
          ]}
          labelStyle={{ color: '#a1a1aa' }}
        />
        {budgetGbp !== null && (
          <ReferenceLine
            y={budgetGbp}
            stroke="#f59e0b"
            strokeDasharray="4 4"
            strokeOpacity={0.6}
            label={{ value: `Budget £${budgetGbp}`, fill: '#f59e0b', fontSize: 9, position: 'right' }}
          />
        )}
        <Line
          type="monotone"
          dataKey="cumulative"
          stroke={overBudget ? '#ef4444' : '#10b981'}
          strokeWidth={1.5}
          dot={false}
          activeDot={{ r: 3, strokeWidth: 0 }}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
