'use client';

import { useState } from 'react';
import { Plus, X } from 'lucide-react';
import { StepFooter } from '../wizard-shell';

interface Step4Props {
  data: Record<string, unknown>;
  onSave: (data: Record<string, unknown>) => Promise<void>;
  onNext: () => void;
  onBack: () => void;
}

export function Step4Brand({ data, onSave, onNext, onBack }: Step4Props) {
  const [services, setServices] = useState<string[]>((data['services'] as string[]) ?? []);
  const [serviceInput, setServiceInput] = useState('');
  const [icp, setIcp] = useState(String(data['icp'] ?? ''));
  const [positioning, setPositioning] = useState(String(data['positioningStatement'] ?? ''));
  const [banned, setBanned] = useState<string[]>((data['bannedPhrases'] as string[]) ?? []);
  const [bannedInput, setBannedInput] = useState('');

  function addService() {
    if (!serviceInput.trim() || services.includes(serviceInput.trim())) return;
    setServices((p) => [...p, serviceInput.trim()]);
    setServiceInput('');
  }

  function addBanned() {
    if (!bannedInput.trim() || banned.includes(bannedInput.trim())) return;
    setBanned((p) => [...p, bannedInput.trim()]);
    setBannedInput('');
  }

  async function handleNext() {
    await onSave({ services, icp, positioningStatement: positioning, bannedPhrases: banned, suppressionList: [] });
    onNext();
  }

  return (
    <div>
      <h2 className="text-base font-semibold text-text-primary mb-1">Brand & positioning</h2>
      <p className="text-sm text-text-muted mb-5">
        Helps agents understand what the company sells, who they sell to, and what language to avoid.
      </p>

      <div className="max-w-lg space-y-5">
        {/* Services */}
        <div>
          <label className="block text-xs text-text-muted mb-1">Services / products <span className="text-red-400">*</span></label>
          <div className="flex gap-2 mb-2">
            <input
              type="text"
              value={serviceInput}
              onChange={(e) => setServiceInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addService())}
              placeholder="e.g. SEO consulting, Content writing..."
              className="flex-1 bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald"
            />
            <button type="button" onClick={addService} disabled={!serviceInput} className="flex items-center gap-1 px-3 py-2 border border-border rounded-md text-xs text-text-secondary hover:text-text-primary disabled:opacity-50 transition-colors">
              <Plus className="w-3.5 h-3.5" />Add
            </button>
          </div>
          {services.length > 0 && (
            <div className="flex flex-wrap gap-1.5">
              {services.map((s) => (
                <span key={s} className="flex items-center gap-1 bg-surface-raised border border-border rounded-full px-2.5 py-1 text-xs text-text-secondary">
                  {s}
                  <button type="button" onClick={() => setServices((p) => p.filter((x) => x !== s))} className="text-text-muted hover:text-red-400 transition-colors">
                    <X className="w-3 h-3" />
                  </button>
                </span>
              ))}
            </div>
          )}
        </div>

        {/* ICP */}
        <div>
          <label className="block text-xs text-text-muted mb-1" htmlFor="icp">Ideal customer profile (ICP) <span className="text-red-400">*</span></label>
          <textarea
            id="icp"
            value={icp}
            onChange={(e) => setIcp(e.target.value)}
            rows={2}
            placeholder="e.g. UK-based SMEs (20–200 employees) in professional services with a dedicated HR or Ops lead"
            className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald resize-none"
          />
        </div>

        {/* Positioning */}
        <div>
          <label className="block text-xs text-text-muted mb-1" htmlFor="positioning">Positioning statement</label>
          <textarea
            id="positioning"
            value={positioning}
            onChange={(e) => setPositioning(e.target.value)}
            rows={2}
            placeholder="e.g. We help UK SMEs save 10+ hours a week on HR admin by drafting every reply and flagging what needs human attention."
            className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald resize-none"
          />
        </div>

        {/* Banned phrases */}
        <div>
          <label className="block text-xs text-text-muted mb-1">Banned phrases (words agents must never use)</label>
          <div className="flex gap-2 mb-2">
            <input
              type="text"
              value={bannedInput}
              onChange={(e) => setBannedInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addBanned())}
              placeholder="e.g. synergy, leverage, paradigm shift..."
              className="flex-1 bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald"
            />
            <button type="button" onClick={addBanned} disabled={!bannedInput} className="px-3 py-2 border border-border rounded-md text-xs text-text-secondary hover:text-text-primary disabled:opacity-50 transition-colors">Add</button>
          </div>
          {banned.length > 0 && (
            <div className="flex flex-wrap gap-1.5">
              {banned.map((phrase) => (
                <span key={phrase} className="flex items-center gap-1 bg-red-500/10 border border-red-500/20 rounded-full px-2.5 py-1 text-xs text-red-400">
                  {phrase}
                  <button type="button" onClick={() => setBanned((p) => p.filter((x) => x !== phrase))} className="hover:text-red-300 transition-colors">
                    <X className="w-3 h-3" />
                  </button>
                </span>
              ))}
            </div>
          )}
        </div>
      </div>

      <StepFooter onBack={onBack} onNext={handleNext} nextDisabled={services.length === 0 || !icp.trim()} />
    </div>
  );
}
