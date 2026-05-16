'use client';

import { CreditCard, TrendingUp, FileText, AlertCircle } from 'lucide-react';
import { cn } from '../../lib/cn';

interface BillingPanelProps {
  plan: string;
  status: string;
  monthSpendGbp: number;
  budgetGbp: number | null;
}

const planConfig: Record<string, { label: string; colour: string; price: string }> = {
  FOUNDING: { label: 'Founding', colour: 'text-brand-amber', price: '£400/mo' },
  STARTER: { label: 'Starter', colour: 'text-text-secondary', price: '£450/mo' },
  GROWTH: { label: 'Growth', colour: 'text-brand-emerald', price: '£1,800/mo' },
  SCALE: { label: 'Scale', colour: 'text-blue-400', price: '£4,500/mo' },
  ENTERPRISE: { label: 'Enterprise', colour: 'text-purple-400', price: 'Custom' },
  AGENCY_PARTNER: { label: 'Agency Partner', colour: 'text-brand-amber', price: 'Bespoke' },
};

export function BillingPanel({ plan, status, monthSpendGbp, budgetGbp }: BillingPanelProps) {
  const cfg = planConfig[plan] ?? planConfig['STARTER']!;
  const budgetPercent = budgetGbp ? Math.round((monthSpendGbp / budgetGbp) * 100) : null;

  return (
    <div>
      <h2 className="text-sm font-semibold text-text-primary mb-4">Billing</h2>

      <div className="space-y-4">
        {/* Current plan */}
        <div className="p-4 bg-surface-raised border border-border rounded-lg">
          <div className="flex items-center justify-between mb-3">
            <div>
              <p className="text-xs text-text-muted mb-0.5">Current plan</p>
              <div className="flex items-center gap-2">
                <span className={cn('text-base font-semibold', cfg.colour)}>{cfg.label}</span>
                <span className="text-sm text-text-secondary">{cfg.price}</span>
                {status === 'SUSPENDED' && (
                  <span className="text-xs px-1.5 py-0.5 rounded bg-red-500/10 text-red-400">Suspended</span>
                )}
              </div>
            </div>
            <button className="text-xs px-3 py-1.5 border border-border rounded-md text-text-secondary hover:text-text-primary hover:border-border-subtle transition-colors">
              Change plan
            </button>
          </div>

          {status === 'SUSPENDED' && (
            <div className="flex items-center gap-2 p-2 bg-red-500/10 rounded text-xs text-red-400">
              <AlertCircle className="w-3.5 h-3.5 shrink-0" />
              Account suspended. Contact support@intelforce.ai to reactivate.
            </div>
          )}
        </div>

        {/* Month spend */}
        <div className="p-4 bg-surface-raised border border-border rounded-lg">
          <div className="flex items-center gap-2 mb-2">
            <TrendingUp className="w-4 h-4 text-text-muted" />
            <p className="text-xs text-text-muted">This month&apos;s usage</p>
          </div>
          <p className="text-2xl font-semibold text-text-primary font-mono mb-2">
            £{monthSpendGbp.toFixed(2)}
          </p>
          {budgetPercent !== null && (
            <div>
              <div className="flex justify-between text-xs text-text-muted mb-1">
                <span>{budgetPercent}% of £{budgetGbp?.toFixed(0)} budget</span>
                <span>{100 - budgetPercent}% remaining</span>
              </div>
              <div className="h-2 bg-border rounded-full overflow-hidden">
                <div
                  className={cn(
                    'h-full rounded-full',
                    budgetPercent < 70 ? 'bg-brand-emerald' : budgetPercent < 90 ? 'bg-brand-amber' : 'bg-red-500',
                  )}
                  style={{ width: `${Math.min(budgetPercent, 100)}%` }}
                />
              </div>
            </div>
          )}
        </div>

        {/* Payment method */}
        <div className="p-4 bg-surface-raised border border-border rounded-lg">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <CreditCard className="w-4 h-4 text-text-muted" />
              <div>
                <p className="text-sm text-text-primary">Payment method</p>
                <p className="text-xs text-text-muted">Manage via Stripe portal</p>
              </div>
            </div>
            <button className="text-xs px-3 py-1.5 border border-border rounded-md text-text-secondary hover:text-text-primary hover:border-border-subtle transition-colors">
              Manage
            </button>
          </div>
        </div>

        {/* Invoices */}
        <div className="p-4 bg-surface-raised border border-border rounded-lg">
          <div className="flex items-center gap-2 mb-3">
            <FileText className="w-4 h-4 text-text-muted" />
            <p className="text-sm text-text-primary">Invoices</p>
          </div>
          <p className="text-xs text-text-muted">
            Invoices are available in your Stripe portal. Click &quot;Manage&quot; above to view billing history.
          </p>
        </div>
      </div>
    </div>
  );
}
