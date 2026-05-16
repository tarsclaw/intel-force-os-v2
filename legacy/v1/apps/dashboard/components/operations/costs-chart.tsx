'use client';

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  ReferenceLine,
} from 'recharts';

interface DaySpend {
  date: string;
  costGbp: number;
}

interface AgentSpend {
  agent: string;
  invocations: number;
  costGbp: number;
}

interface CostsChartProps {
  byDay: DaySpend[];
  byAgent: AgentSpend[];
  budgetGbp: number | null;
  monthSpendGbp: number;
}

function formatDay(dateStr: string): string {
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
}

const CustomTooltip = ({
  active,
  payload,
  label,
}: {
  active?: boolean;
  payload?: Array<{ value: number }>;
  label?: string;
}) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-surface-raised border border-border rounded-md px-2.5 py-1.5 text-xs">
      <p className="text-text-muted mb-0.5">{label}</p>
      <p className="text-text-primary font-mono">£{payload[0]?.value.toFixed(4)}</p>
    </div>
  );
};

export function CostsChart({ byDay, byAgent, budgetGbp, monthSpendGbp }: CostsChartProps) {
  const dailyBudget = budgetGbp ? budgetGbp / 30 : null;

  return (
    <div className="space-y-4">
      {/* Daily spend bar chart */}
      <div>
        <p className="text-xs text-text-muted mb-2">Daily spend (last 30 days)</p>
        <ResponsiveContainer width="100%" height={120}>
          <BarChart data={byDay} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
            <XAxis
              dataKey="date"
              tickFormatter={formatDay}
              tick={{ fontSize: 10, fill: '#71717a' }}
              axisLine={false}
              tickLine={false}
              interval={6}
            />
            <YAxis
              tick={{ fontSize: 10, fill: '#71717a' }}
              axisLine={false}
              tickLine={false}
              tickFormatter={(v: number) => `£${v.toFixed(2)}`}
            />
            <Tooltip content={<CustomTooltip />} />
            {dailyBudget && (
              <ReferenceLine y={dailyBudget} stroke="#f59e0b" strokeDasharray="3 3" />
            )}
            <Bar dataKey="costGbp" fill="#10b981" radius={[2, 2, 0, 0]} maxBarSize={20} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Per-agent breakdown */}
      {byAgent.length > 0 && (
        <div>
          <p className="text-xs text-text-muted mb-2">By agent</p>
          <div className="space-y-1.5">
            {byAgent
              .sort((a, b) => b.costGbp - a.costGbp)
              .map((a) => {
                const pct = monthSpendGbp > 0 ? (a.costGbp / monthSpendGbp) * 100 : 0;
                return (
                  <div key={a.agent} className="flex items-center gap-2">
                    <span className="text-xs text-text-secondary w-28 truncate">{a.agent}</span>
                    <div className="flex-1 h-1.5 bg-border rounded-full overflow-hidden">
                      <div
                        className="h-full bg-brand-emerald rounded-full"
                        style={{ width: `${pct}%` }}
                      />
                    </div>
                    <span className="text-xs text-text-muted font-mono w-16 text-right">
                      £{a.costGbp.toFixed(4)}
                    </span>
                    <span className="text-xs text-text-muted w-12 text-right">
                      {a.invocations} runs
                    </span>
                  </div>
                );
              })}
          </div>
        </div>
      )}
    </div>
  );
}
