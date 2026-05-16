'use client';

import { useState } from 'react';
import { CheckCircle, Plug, AlertCircle } from 'lucide-react';
import { cn } from '../../../lib/cn';
import { StepFooter } from '../wizard-shell';

interface Integration {
  provider: string;
  name: string;
  description: string;
  authType: 'api_key' | 'oauth2';
  required: boolean;
  plans: string[];
}

const INTEGRATIONS: Integration[] = [
  { provider: 'breathe_hr', name: 'Breathe HR', description: 'Employee records and leave management', authType: 'api_key', required: true, plans: ['STARTER', 'GROWTH', 'SCALE', 'ENTERPRISE'] },
  { provider: 'slack', name: 'Slack', description: 'Escalation notifications', authType: 'oauth2', required: false, plans: ['STARTER', 'GROWTH', 'SCALE', 'ENTERPRISE'] },
  { provider: 'hubspot', name: 'HubSpot', description: 'Deal and pipeline management', authType: 'oauth2', required: false, plans: ['GROWTH', 'SCALE', 'ENTERPRISE'] },
  { provider: 'gmail', name: 'Gmail', description: 'Draft emails from agents', authType: 'oauth2', required: false, plans: ['GROWTH', 'SCALE', 'ENTERPRISE'] },
  { provider: 'fathom', name: 'Fathom', description: 'Call transcript processing', authType: 'api_key', required: false, plans: ['GROWTH', 'SCALE', 'ENTERPRISE'] },
];

interface Step6Props {
  data: Record<string, unknown>;
  plan: string;
  onSave: (data: Record<string, unknown>) => Promise<void>;
  onNext: () => void;
  onBack: () => void;
}

export function Step6Integrations({ data, plan, onSave, onNext, onBack }: Step6Props) {
  const [apiKeys, setApiKeys] = useState<Record<string, string>>(
    (data['apiKeys'] as Record<string, string>) ?? {},
  );
  const [oauthPending, setOauthPending] = useState<string[]>([]);

  const available = INTEGRATIONS.filter((i) => i.plans.includes(plan));
  const required = available.filter((i) => i.required);
  const allRequiredConnected = required.every(
    (r) => apiKeys[r.provider] || oauthPending.includes(r.provider),
  );

  async function handleNext() {
    await onSave({ apiKeys, oauthProvidersPending: oauthPending });
    onNext();
  }

  return (
    <div>
      <h2 className="text-base font-semibold text-text-primary mb-1">Integrations</h2>
      <p className="text-sm text-text-muted mb-5">
        Connect data sources and notification channels. OAuth integrations complete after tenant creation.
      </p>

      <div className="max-w-lg space-y-2 mb-5">
        {available.map((integration) => {
          const hasKey = !!apiKeys[integration.provider];
          const isPending = oauthPending.includes(integration.provider);
          const isConnected = hasKey || isPending;

          return (
            <div
              key={integration.provider}
              className={cn(
                'p-3 border rounded-lg transition-colors',
                isConnected ? 'border-brand-emerald/30 bg-brand-emerald/5' : 'border-border',
              )}
            >
              <div className="flex items-start gap-3">
                <div className={cn('w-8 h-8 rounded-md flex items-center justify-center shrink-0', isConnected ? 'bg-brand-emerald/10' : 'bg-surface-raised')}>
                  {isConnected ? (
                    <CheckCircle className="w-4 h-4 text-brand-emerald" />
                  ) : (
                    <Plug className="w-4 h-4 text-text-muted" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-0.5">
                    <p className="text-sm font-medium text-text-primary">{integration.name}</p>
                    {integration.required && (
                      <span className="text-[10px] px-1.5 py-0.5 rounded bg-brand-amber/10 text-brand-amber">Required</span>
                    )}
                    {isPending && (
                      <span className="text-[10px] px-1.5 py-0.5 rounded bg-blue-500/10 text-blue-400">OAuth pending</span>
                    )}
                  </div>
                  <p className="text-xs text-text-muted">{integration.description}</p>

                  {!isConnected && integration.authType === 'api_key' && (
                    <input
                      type="password"
                      placeholder={`${integration.name} API key...`}
                      value={apiKeys[integration.provider] ?? ''}
                      onChange={(e) => setApiKeys((p) => ({ ...p, [integration.provider]: e.target.value }))}
                      className="mt-2 w-full bg-surface border border-border rounded px-2.5 py-1.5 text-xs text-text-primary focus:outline-none focus:border-brand-emerald font-mono"
                    />
                  )}

                  {!isConnected && integration.authType === 'oauth2' && (
                    <button
                      type="button"
                      onClick={() => setOauthPending((p) => [...p, integration.provider])}
                      className="mt-2 text-xs px-2.5 py-1 border border-border rounded text-text-secondary hover:text-text-primary hover:border-border-subtle transition-colors"
                    >
                      Queue for OAuth (connects after tenant is created)
                    </button>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {!allRequiredConnected && (
        <div className="flex items-center gap-2 p-2.5 bg-brand-amber/10 border border-brand-amber/30 rounded-md mb-4 max-w-lg">
          <AlertCircle className="w-4 h-4 text-brand-amber shrink-0" />
          <p className="text-xs text-brand-amber">Required integrations must be connected before the tenant can go live.</p>
        </div>
      )}

      <StepFooter onBack={onBack} onNext={handleNext} />
    </div>
  );
}
