'use client';

import { useState } from 'react';
import { CheckCircle } from 'lucide-react';
import { cn } from '../../../lib/cn';
import { StepFooter } from '../wizard-shell';

const PLANS = [
  {
    id: 'STARTER',
    name: 'Starter',
    price: '£450/mo',
    description: 'Core agents for solo operators validating the product.',
    agents: ['Proposal Builder', 'Client Onboarder', 'Caption Writer', 'Reporting Engine'],
    seats: 1,
    runs: 100,
  },
  {
    id: 'GROWTH',
    name: 'Growth',
    price: '£1,800/mo',
    description: 'The full agent workforce for small-to-mid agencies.',
    agents: ['Everything in Starter', 'Lead Hunter', 'Content Creator', 'Repurposer', 'Follow-Up Pilot'],
    seats: 3,
    runs: 500,
    popular: true,
  },
  {
    id: 'SCALE',
    name: 'Scale',
    price: '£4,500/mo',
    description: 'Full suite plus SOP Writer, priority support, agency option.',
    agents: ['Everything in Growth', 'SOP Writer'],
    seats: 10,
    runs: 2000,
  },
  {
    id: 'ENTERPRISE',
    name: 'Enterprise',
    price: 'Custom',
    description: 'Custom agents, dedicated infra, negotiated SLA.',
    agents: ['Everything in Scale', 'Custom agents', 'Dedicated infrastructure'],
    seats: -1,
    runs: -1,
  },
];

interface Step2Props {
  data: Record<string, unknown>;
  onSave: (data: Record<string, unknown>) => Promise<void>;
  onNext: () => void;
  onBack: () => void;
}

export function Step2Plan({ data, onSave, onNext, onBack }: Step2Props) {
  const [plan, setPlan] = useState(String(data['plan'] ?? 'GROWTH'));
  const [budget, setBudget] = useState(String(data['costBudgetGbp'] ?? ''));
  const [hardStop, setHardStop] = useState(Boolean(data['hardStopBudget'] ?? false));

  async function handleNext() {
    await onSave({ plan, costBudgetGbp: budget ? Number(budget) : null, hardStopBudget: hardStop, agentsEnabled: [] });
    onNext();
  }

  return (
    <div>
      <h2 className="text-base font-semibold text-text-primary mb-1">Plan & agents</h2>
      <p className="text-sm text-text-muted mb-5">Select the plan that fits this tenant. Agents enabled are determined by the plan.</p>

      <div className="grid grid-cols-2 gap-3 mb-6 max-w-2xl">
        {PLANS.map((p) => (
          <button
            key={p.id}
            type="button"
            onClick={() => setPlan(p.id)}
            className={cn(
              'relative text-left p-3 rounded-lg border transition-colors',
              plan === p.id ? 'border-brand-emerald bg-brand-emerald/5' : 'border-border hover:border-border-subtle bg-surface-raised',
            )}
          >
            {p.popular && (
              <span className="absolute top-2 right-2 text-[10px] px-1.5 py-0.5 rounded-full bg-brand-emerald/10 text-brand-emerald">Popular</span>
            )}
            <div className="flex items-center justify-between mb-1">
              <span className="text-sm font-semibold text-text-primary">{p.name}</span>
              <span className="text-xs text-text-secondary font-mono">{p.price}</span>
            </div>
            <p className="text-xs text-text-muted mb-2">{p.description}</p>
            <ul className="space-y-0.5">
              {p.agents.map((a) => (
                <li key={a} className="flex items-center gap-1.5 text-xs text-text-secondary">
                  <CheckCircle className={cn('w-3 h-3 shrink-0', plan === p.id ? 'text-brand-emerald' : 'text-text-muted')} />
                  {a}
                </li>
              ))}
            </ul>
            {p.runs > 0 && (
              <p className="text-xs text-text-muted mt-2">
                {p.seats} {p.seats === 1 ? 'seat' : 'seats'} · {p.runs.toLocaleString()} runs/mo
              </p>
            )}
          </button>
        ))}
      </div>

      {/* Budget */}
      <div className="max-w-sm space-y-3">
        <div>
          <label className="block text-xs text-text-muted mb-1" htmlFor="budget">Monthly cost budget (£)</label>
          <input
            id="budget"
            type="number"
            min="0"
            step="0.01"
            value={budget}
            onChange={(e) => setBudget(e.target.value)}
            placeholder="No limit"
            className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald font-mono"
          />
          <p className="text-xs text-text-muted mt-1">Sets an alert threshold. Leave blank for no limit.</p>
        </div>
        {budget && (
          <label className="flex items-start gap-2 cursor-pointer">
            <input type="checkbox" checked={hardStop} onChange={(e) => setHardStop(e.target.checked)} className="mt-0.5" />
            <div>
              <span className="text-xs font-medium text-text-primary">Hard stop at budget</span>
              <p className="text-xs text-text-muted">Agents pause automatically when the budget is reached. Recommended for cost control.</p>
            </div>
          </label>
        )}
      </div>

      <StepFooter onBack={onBack} onNext={handleNext} />
    </div>
  );
}
