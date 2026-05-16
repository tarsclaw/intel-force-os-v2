'use client';

import { useState, useEffect } from 'react';
import { StepFooter } from '../wizard-shell';

interface Step1Data {
  name?: string;
  slug?: string;
  industry?: string;
  ownerEmail?: string;
  billingEmail?: string;
  website?: string;
  timezone?: string;
  currency?: string;
}

interface Step1Props {
  data: Record<string, unknown>;
  draftId: string;
  onSave: (data: Record<string, unknown>) => Promise<void>;
  onNext: () => void;
}

function toSlug(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .slice(0, 40);
}

const INDUSTRIES = [
  'Consulting', 'Technology', 'Marketing / Creative Agency', 'Legal', 'Finance',
  'Healthcare', 'Retail', 'Manufacturing', 'Recruitment', 'Property', 'Other',
];

const TIMEZONES = ['Europe/London', 'Europe/Paris', 'Europe/Berlin', 'America/New_York', 'America/Los_Angeles', 'Asia/Singapore'];

export function Step1Basics({ data, onSave, onNext, draftId }: Step1Props) {
  void draftId;
  const [form, setForm] = useState<Step1Data>({
    name: String(data['name'] ?? ''),
    slug: String(data['slug'] ?? ''),
    industry: String(data['industry'] ?? ''),
    ownerEmail: String(data['ownerEmail'] ?? ''),
    billingEmail: String(data['billingEmail'] ?? ''),
    website: String(data['website'] ?? ''),
    timezone: String(data['timezone'] ?? 'Europe/London'),
    currency: String(data['currency'] ?? 'GBP'),
  });
  const [slugEdited, setSlugEdited] = useState(!!data['slug']);
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Auto-generate slug from name
  useEffect(() => {
    if (!slugEdited && form.name) {
      setForm((p) => ({ ...p, slug: toSlug(form.name!) }));
    }
  }, [form.name, slugEdited]);

  function validate(): boolean {
    const errs: Record<string, string> = {};
    if (!form.name?.trim()) errs['name'] = 'Required';
    if (!form.slug?.match(/^[a-z0-9-]{2,40}$/)) errs['slug'] = 'Lowercase letters, numbers, hyphens only (2–40 chars)';
    if (!form.industry) errs['industry'] = 'Required';
    if (!form.ownerEmail?.includes('@')) errs['ownerEmail'] = 'Valid email required';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  }

  async function handleNext() {
    if (!validate()) return;
    await onSave(form as Record<string, unknown>);
    onNext();
  }

  const field = (
    key: keyof Step1Data,
    label: string,
    type = 'text',
    required = false,
    hint?: string,
  ) => (
    <div key={key}>
      <label className="block text-xs text-text-muted mb-1" htmlFor={key}>
        {label} {required && <span className="text-red-400">*</span>}
      </label>
      <input
        id={key}
        type={type}
        value={form[key] ?? ''}
        onChange={(e) => {
          setForm((p) => ({ ...p, [key]: e.target.value }));
          if (key === 'slug') setSlugEdited(true);
        }}
        className={`w-full bg-surface-raised border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald ${errors[key] ? 'border-red-500' : 'border-border'}`}
      />
      {hint && !errors[key] && <p className="text-xs text-text-muted mt-1">{hint}</p>}
      {errors[key] && <p className="text-xs text-red-400 mt-1">{errors[key]}</p>}
    </div>
  );

  return (
    <div>
      <h2 className="text-base font-semibold text-text-primary mb-1">Tenant basics</h2>
      <p className="text-sm text-text-muted mb-5">Core identity for the new tenant. Used across the platform and in customer-facing emails.</p>

      <div className="grid grid-cols-2 gap-4 max-w-xl">
        {field('name', 'Company name', 'text', true)}

        <div>
          <label className="block text-xs text-text-muted mb-1" htmlFor="slug">
            URL slug <span className="text-red-400">*</span>
          </label>
          <div className="flex items-center">
            <span className="text-xs text-text-muted px-2 py-2 bg-surface border border-r-0 border-border rounded-l-md">/t/</span>
            <input
              id="slug"
              type="text"
              value={form.slug ?? ''}
              onChange={(e) => { setForm((p) => ({ ...p, slug: e.target.value })); setSlugEdited(true); }}
              className={`flex-1 bg-surface-raised border rounded-r-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald font-mono ${errors['slug'] ? 'border-red-500' : 'border-border'}`}
            />
          </div>
          {errors['slug'] && <p className="text-xs text-red-400 mt-1">{errors['slug']}</p>}
        </div>

        <div className="col-span-2">
          <label className="block text-xs text-text-muted mb-1" htmlFor="industry">
            Industry <span className="text-red-400">*</span>
          </label>
          <select
            id="industry"
            value={form.industry ?? ''}
            onChange={(e) => setForm((p) => ({ ...p, industry: e.target.value }))}
            className={`w-full bg-surface-raised border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald ${errors['industry'] ? 'border-red-500' : 'border-border'}`}
          >
            <option value="">Select industry…</option>
            {INDUSTRIES.map((i) => <option key={i} value={i}>{i}</option>)}
          </select>
          {errors['industry'] && <p className="text-xs text-red-400 mt-1">{errors['industry']}</p>}
        </div>

        {field('ownerEmail', 'Owner email', 'email', true, 'This person gets the Clerk invitation')}
        {field('billingEmail', 'Billing email', 'email', false, 'Leave blank to use owner email')}
        {field('website', 'Website', 'url', false)}

        <div>
          <label className="block text-xs text-text-muted mb-1" htmlFor="timezone">Timezone</label>
          <select id="timezone" value={form.timezone} onChange={(e) => setForm((p) => ({ ...p, timezone: e.target.value }))} className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald">
            {TIMEZONES.map((t) => <option key={t} value={t}>{t}</option>)}
          </select>
        </div>

        <div>
          <label className="block text-xs text-text-muted mb-1" htmlFor="currency">Currency</label>
          <select id="currency" value={form.currency} onChange={(e) => setForm((p) => ({ ...p, currency: e.target.value }))} className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald">
            <option value="GBP">GBP (£)</option>
            <option value="EUR">EUR (€)</option>
            <option value="USD">USD ($)</option>
          </select>
        </div>
      </div>

      <StepFooter onNext={handleNext} showBack={false} />
    </div>
  );
}
