'use client';

import { useState } from 'react';
import { trpc } from '../../lib/trpc';

interface ConfigPanelProps {
  tenant: {
    id: string;
    name: string;
    slug: string;
    plan: string;
    billingEmail: string | null;
    timezone: string;
    agentsEnabled: string[];
    costBudgetGbp: unknown;
    hardStopBudget: boolean;
  };
}

export function ConfigPanel({ tenant }: ConfigPanelProps) {
  const [name, setName] = useState(tenant.name);
  const [billingEmail, setBillingEmail] = useState(tenant.billingEmail ?? '');
  const [budgetGbp, setBudgetGbp] = useState(
    tenant.costBudgetGbp ? String(Number(tenant.costBudgetGbp)) : '',
  );
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const updateMutation = trpc.tenants.update.useMutation({
    onSuccess: () => {
      setSaved(true);
      setError(null);
      setTimeout(() => setSaved(false), 2500);
    },
    onError: (err) => setError(err.message),
  });

  function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    updateMutation.mutate({
      tenantId: tenant.id,
      data: {
        name: name.trim() || undefined,
        billingEmail: billingEmail || undefined,
        costBudgetGbp: budgetGbp ? Number(budgetGbp) : undefined,
      },
    });
  }

  return (
    <div>
      <h2 className="text-sm font-semibold text-text-primary mb-4">Configuration</h2>
      <form onSubmit={handleSave} className="space-y-4 max-w-md">
        <Field label="Company name" id="name">
          <input id="name" type="text" value={name} onChange={(e) => setName(e.target.value)}
            className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald" />
        </Field>
        <Field label="Billing email" id="billing-email">
          <input id="billing-email" type="email" value={billingEmail} onChange={(e) => setBillingEmail(e.target.value)}
            className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald" />
        </Field>
        <Field label="Monthly cost budget (£)" id="budget">
          <input id="budget" type="number" min="0" step="0.01" value={budgetGbp}
            onChange={(e) => setBudgetGbp(e.target.value)} placeholder="No limit"
            className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald font-mono" />
        </Field>
        <div className="pt-2 border-t border-border space-y-2">
          <ROField label="Slug" value={tenant.slug} />
          <ROField label="Plan" value={tenant.plan} />
          <ROField label="Timezone" value={tenant.timezone} />
        </div>
        {error && <p className="text-xs text-red-400">{error}</p>}
        <button type="submit" disabled={updateMutation.isPending}
          className="px-4 py-2 bg-brand-emerald text-canvas text-sm font-medium rounded-md hover:bg-emerald-500 disabled:opacity-50 transition-colors">
          {updateMutation.isPending ? 'Saving…' : saved ? 'Saved ✓' : 'Save changes'}
        </button>
      </form>
    </div>
  );
}

function Field({ label, id, children }: { label: string; id: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-xs text-text-muted mb-1" htmlFor={id}>{label}</label>
      {children}
    </div>
  );
}

function ROField({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center gap-3">
      <span className="text-xs text-text-muted w-20 shrink-0">{label}</span>
      <span className="text-sm text-text-secondary font-mono">{value}</span>
    </div>
  );
}
