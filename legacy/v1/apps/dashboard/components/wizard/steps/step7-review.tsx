'use client';

import { useState } from 'react';
import { AlertCircle, CheckCircle } from 'lucide-react';
import { Loader2 } from 'lucide-react';

interface Step7Props {
  allStepData: Record<number, Record<string, unknown>>;
  onBack: () => void;
  onSubmit: (confirmSlug: string) => Promise<void>;
  isSaving: boolean;
}

export function Step7Review({ allStepData, onBack, onSubmit, isSaving }: Step7Props) {
  const [confirmSlug, setConfirmSlug] = useState('');

  const step1 = allStepData[1] ?? {};
  const step2 = allStepData[2] ?? {};
  const expectedSlug = String(step1['slug'] ?? '');
  const slugMatch = confirmSlug === expectedSlug;

  const sections: { label: string; items: [string, unknown][] }[] = [
    {
      label: 'Tenant basics',
      items: [
        ['Company name', step1['name']],
        ['Slug', `/${step1['slug']}`],
        ['Industry', step1['industry']],
        ['Owner email', step1['ownerEmail']],
        ['Timezone', step1['timezone']],
        ['Currency', step1['currency']],
      ],
    },
    {
      label: 'Plan',
      items: [
        ['Plan', step2['plan']],
        ['Monthly budget', step2['costBudgetGbp'] ? `£${step2['costBudgetGbp']}` : 'No limit'],
        ['Hard stop', step2['hardStopBudget'] ? 'Yes' : 'No'],
      ],
    },
    {
      label: 'Brand',
      items: [
        ['Services', (allStepData[4]?.['services'] as string[] | undefined)?.join(', ') ?? '—'],
        ['ICP', allStepData[4]?.['icp']],
      ],
    },
  ];

  const readyToSubmit = expectedSlug && slugMatch;

  return (
    <div>
      <h2 className="text-base font-semibold text-text-primary mb-1">Review & submit</h2>
      <p className="text-sm text-text-muted mb-5">
        Review everything below. Once submitted, the tenant is created and provisioning begins.
      </p>

      {/* Summary sections */}
      <div className="space-y-4 mb-6 max-w-xl">
        {sections.map((section) => (
          <div key={section.label} className="bg-surface-raised border border-border rounded-lg p-3">
            <p className="text-xs font-medium text-text-muted mb-2">{section.label}</p>
            <dl className="space-y-1">
              {section.items.map(([label, value]) => (
                <div key={String(label)} className="flex gap-3">
                  <dt className="text-xs text-text-muted w-28 shrink-0">{label}</dt>
                  <dd className="text-xs text-text-primary font-mono truncate">
                    {value ? String(value) : <span className="text-text-muted italic">Not set</span>}
                  </dd>
                </div>
              ))}
            </dl>
          </div>
        ))}
      </div>

      {/* Slug confirmation */}
      <div className="max-w-sm mb-6">
        <div className="p-3 bg-brand-amber/10 border border-brand-amber/30 rounded-lg mb-3">
          <p className="text-xs text-brand-amber font-medium mb-1">Confirm before creating</p>
          <p className="text-xs text-brand-amber/80">
            Once created, the slug cannot be changed. Type <code className="font-mono">{expectedSlug}</code> to confirm.
          </p>
        </div>
        <div className="relative">
          <input
            type="text"
            value={confirmSlug}
            onChange={(e) => setConfirmSlug(e.target.value)}
            placeholder={`Type "${expectedSlug}" to confirm`}
            className={`w-full bg-surface-raised border rounded-md px-3 py-2 text-sm font-mono text-text-primary focus:outline-none ${
              confirmSlug && !slugMatch ? 'border-red-500 focus:border-red-500' : slugMatch ? 'border-brand-emerald' : 'border-border focus:border-brand-emerald'
            }`}
          />
          {slugMatch && <CheckCircle className="absolute right-3 top-2.5 w-4 h-4 text-brand-emerald" />}
          {confirmSlug && !slugMatch && <AlertCircle className="absolute right-3 top-2.5 w-4 h-4 text-red-400" />}
        </div>
        {confirmSlug && !slugMatch && (
          <p className="text-xs text-red-400 mt-1">Does not match — expected <code className="font-mono">{expectedSlug}</code></p>
        )}
      </div>

      <div className="flex items-center justify-between pt-4 border-t border-border">
        <button type="button" onClick={onBack} className="text-sm text-text-muted hover:text-text-secondary transition-colors">← Back</button>
        <button
          type="button"
          onClick={() => onSubmit(confirmSlug)}
          disabled={!readyToSubmit || isSaving}
          className="flex items-center gap-2 px-5 py-2 bg-brand-emerald text-canvas text-sm font-medium rounded-md hover:bg-emerald-500 disabled:opacity-50 transition-colors"
        >
          {isSaving && <Loader2 className="w-4 h-4 animate-spin" />}
          {isSaving ? 'Creating tenant…' : 'Create tenant'}
        </button>
      </div>
    </div>
  );
}
