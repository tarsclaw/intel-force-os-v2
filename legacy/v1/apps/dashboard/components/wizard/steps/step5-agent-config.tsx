'use client';

import { useState } from 'react';
import { ChevronDown, ChevronRight } from 'lucide-react';
import { cn } from '../../../lib/cn';
import { StepFooter } from '../wizard-shell';

interface Step5Props {
  data: Record<string, unknown>;
  plan: string;
  onSave: (data: Record<string, unknown>) => Promise<void>;
  onNext: () => void;
  onBack: () => void;
}

const AGENT_CONFIGS: Record<string, Array<{ key: string; label: string; type: string; placeholder: string; required?: boolean }>> = {
  'HR Agent': [
    { key: 'hrLeadAadId', label: 'HR Lead Entra ID object ID', type: 'text', placeholder: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', required: true },
    { key: 'breatheHrApiKey', label: 'Breathe HR API key', type: 'password', placeholder: 'sk_live_...' },
    { key: 'companyTone', label: 'HR response tone', type: 'textarea', placeholder: 'e.g. Warm and professional. First names are fine. Avoid jargon.' },
    { key: 'sensitivityThreshold', label: 'Escalation threshold (0.0–1.0)', type: 'number', placeholder: '0.7' },
  ],
  'Proposal Builder': [
    { key: 'minSignalWords', label: 'Minimum call signal words', type: 'number', placeholder: '200' },
    { key: 'maxDealValue', label: 'Max deal value for auto-draft (£)', type: 'number', placeholder: '10000' },
  ],
  'Lead Hunter': [
    { key: 'employeeRange', label: 'Target employee range', type: 'text', placeholder: 'e.g. 20-200' },
    { key: 'targetIndustries', label: 'Target industries (comma-separated)', type: 'text', placeholder: 'Consulting, Tech, Marketing' },
    { key: 'geographyUk', label: 'UK-only targeting', type: 'checkbox', placeholder: '' },
  ],
};

const PLAN_AGENTS: Record<string, string[]> = {
  STARTER: ['HR Agent', 'Proposal Builder'],
  GROWTH: ['HR Agent', 'Proposal Builder', 'Lead Hunter', 'Content Creator', 'Repurposer', 'Follow-Up Pilot'],
  SCALE: ['HR Agent', 'Proposal Builder', 'Lead Hunter', 'Content Creator', 'Repurposer', 'Follow-Up Pilot', 'SOP Writer'],
  ENTERPRISE: ['HR Agent', 'Proposal Builder', 'Lead Hunter', 'Content Creator', 'Repurposer', 'Follow-Up Pilot', 'SOP Writer'],
};

export function Step5AgentConfig({ data, plan, onSave, onNext, onBack }: Step5Props) {
  const agents = PLAN_AGENTS[plan] ?? PLAN_AGENTS['STARTER']!;
  const [expanded, setExpanded] = useState<string | null>(agents[0] ?? null);
  const [configs, setConfigs] = useState<Record<string, Record<string, string>>>(
    (data['agentConfigs'] as Record<string, Record<string, string>>) ?? {},
  );

  function setField(agent: string, key: string, value: string) {
    setConfigs((prev) => ({
      ...prev,
      [agent]: { ...(prev[agent] ?? {}), [key]: value },
    }));
  }

  async function handleNext() {
    await onSave({ agentConfigs: configs });
    onNext();
  }

  return (
    <div>
      <h2 className="text-base font-semibold text-text-primary mb-1">Per-agent configuration</h2>
      <p className="text-sm text-text-muted mb-5">
        Fine-tune each agent. Required fields are marked. Optional fields use sensible defaults.
      </p>

      <div className="max-w-lg space-y-2">
        {agents.map((agent) => {
          const fields = AGENT_CONFIGS[agent] ?? [];
          const isOpen = expanded === agent;
          return (
            <div key={agent} className="border border-border rounded-lg overflow-hidden">
              <button
                type="button"
                onClick={() => setExpanded(isOpen ? null : agent)}
                className="w-full flex items-center justify-between px-4 py-3 text-sm font-medium text-text-primary hover:bg-surface-raised transition-colors text-left"
              >
                <span>{agent}</span>
                {isOpen ? <ChevronDown className="w-4 h-4 text-text-muted" /> : <ChevronRight className="w-4 h-4 text-text-muted" />}
              </button>

              {isOpen && (
                <div className="px-4 pb-4 space-y-3 border-t border-border bg-surface-raised/50">
                  {fields.length === 0 ? (
                    <p className="text-xs text-text-muted pt-3">No configuration required for this agent.</p>
                  ) : (
                    fields.map((f) => (
                      <div key={f.key} className="pt-2">
                        <label className="block text-xs text-text-muted mb-1">
                          {f.label} {f.required && <span className="text-red-400">*</span>}
                        </label>
                        {f.type === 'textarea' ? (
                          <textarea
                            value={configs[agent]?.[f.key] ?? ''}
                            onChange={(e) => setField(agent, f.key, e.target.value)}
                            placeholder={f.placeholder}
                            rows={2}
                            className="w-full bg-surface border border-border rounded px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald resize-none"
                          />
                        ) : f.type === 'checkbox' ? (
                          <label className="flex items-center gap-2 cursor-pointer">
                            <input
                              type="checkbox"
                              checked={configs[agent]?.[f.key] === 'true'}
                              onChange={(e) => setField(agent, f.key, e.target.checked ? 'true' : 'false')}
                            />
                            <span className="text-xs text-text-secondary">Enabled</span>
                          </label>
                        ) : (
                          <input
                            type={f.type}
                            value={configs[agent]?.[f.key] ?? ''}
                            onChange={(e) => setField(agent, f.key, e.target.value)}
                            placeholder={f.placeholder}
                            className="w-full bg-surface border border-border rounded px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald font-mono"
                          />
                        )}
                      </div>
                    ))
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>

      <StepFooter onBack={onBack} onNext={handleNext} />
    </div>
  );
}
