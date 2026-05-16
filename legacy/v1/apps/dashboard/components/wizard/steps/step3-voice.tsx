'use client';

import { useState } from 'react';
import { Upload, X, Info } from 'lucide-react';
import { StepFooter } from '../wizard-shell';

interface Step3Props {
  data: Record<string, unknown>;
  onSave: (data: Record<string, unknown>) => Promise<void>;
  onNext: () => void;
  onBack: () => void;
}

export function Step3Voice({ data, onSave, onNext, onBack }: Step3Props) {
  const [samples, setSamples] = useState<string[]>((data['samples'] as string[]) ?? []);
  const [urlInput, setUrlInput] = useState('');
  const [tone, setTone] = useState(String(data['toneDescription'] ?? ''));

  function addUrl() {
    if (!urlInput || samples.includes(urlInput)) return;
    setSamples((p) => [...p, urlInput]);
    setUrlInput('');
  }

  function removeUrl(url: string) {
    setSamples((p) => p.filter((s) => s !== url));
  }

  async function handleNext() {
    await onSave({ samples, toneDescription: tone });
    onNext();
  }

  return (
    <div>
      <h2 className="text-base font-semibold text-text-primary mb-1">Voice profile</h2>
      <p className="text-sm text-text-muted mb-5">
        Provide content samples so the AI can match the tenant&apos;s tone and style. Minimum 5 samples recommended.
      </p>

      <div className="max-w-lg space-y-5">
        {/* Sample URLs */}
        <div>
          <label className="block text-xs text-text-muted mb-2">Content samples (URLs or paste text below)</label>

          <div className="flex gap-2 mb-2">
            <input
              type="url"
              value={urlInput}
              onChange={(e) => setUrlInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addUrl())}
              placeholder="https://their-blog.com/post or LinkedIn URL..."
              className="flex-1 bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald"
            />
            <button type="button" onClick={addUrl} disabled={!urlInput} className="px-3 py-2 border border-border rounded-md text-xs text-text-secondary hover:text-text-primary disabled:opacity-50 transition-colors">
              Add
            </button>
          </div>

          {samples.length > 0 && (
            <ul className="space-y-1">
              {samples.map((url) => (
                <li key={url} className="flex items-center gap-2 py-1.5 px-2 bg-surface-raised rounded text-xs">
                  <span className="flex-1 text-text-secondary truncate font-mono">{url}</span>
                  <button type="button" onClick={() => removeUrl(url)} className="text-text-muted hover:text-red-400 transition-colors shrink-0">
                    <X className="w-3.5 h-3.5" />
                  </button>
                </li>
              ))}
            </ul>
          )}

          {samples.length < 5 && (
            <div className="flex items-center gap-1.5 mt-2 text-xs text-text-muted">
              <Info className="w-3.5 h-3.5 shrink-0" />
              {5 - samples.length} more sample{5 - samples.length !== 1 ? 's' : ''} recommended for accurate voice matching
            </div>
          )}
        </div>

        {/* Manual tone description */}
        <div>
          <label className="block text-xs text-text-muted mb-1" htmlFor="tone">
            Tone description <span className="text-text-muted font-normal">(optional — used directly if no samples)</span>
          </label>
          <textarea
            id="tone"
            value={tone}
            onChange={(e) => setTone(e.target.value)}
            rows={3}
            placeholder="e.g. 'Professional but approachable. We use first names. Avoid corporate jargon. We work with SME clients so keep language simple.'"
            className="w-full bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald resize-none"
          />
        </div>

        {/* File upload note */}
        <div className="flex items-start gap-2 p-3 bg-surface-raised border border-border rounded-lg">
          <Upload className="w-4 h-4 text-text-muted mt-0.5 shrink-0" />
          <p className="text-xs text-text-muted">
            PDF and DOCX sample upload coming in v1.1. For now, paste URLs to public content or use the tone description field.
          </p>
        </div>
      </div>

      <StepFooter onBack={onBack} onNext={handleNext} />
    </div>
  );
}
