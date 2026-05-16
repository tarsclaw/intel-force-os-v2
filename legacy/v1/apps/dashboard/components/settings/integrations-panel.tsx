'use client';

import { useState, useTransition } from 'react';
import { Plug, Unplug, RefreshCw, CheckCircle, XCircle, AlertCircle } from 'lucide-react';
import { cn } from '../../lib/cn';

interface Integration {
  provider: string;
  name: string;
  category: string;
  authType: string;
  required: boolean;
  description: string;
  connected: boolean;
  connectedRecord: { status: string; lastFiredAt: Date | null } | null;
}

interface IntegrationsPanelProps {
  tenantId: string;
  integrations: Integration[];
}

export function IntegrationsPanel({ tenantId, integrations }: IntegrationsPanelProps) {
  const [apiKeyInputs, setApiKeyInputs] = useState<Record<string, string>>({});
  const [showApiKeyFor, setShowApiKeyFor] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();
  const [testResults, setTestResults] = useState<Record<string, { success: boolean; message: string }>>({});

  void tenantId;

  function handleApiKeyConnect(provider: string) {
    const key = apiKeyInputs[provider] ?? '';
    if (!key) return;

    startTransition(() => {
      // TODO: wire to tRPC integrations.connectApiKey
      console.log('Connecting', provider, 'with API key');
      setShowApiKeyFor(null);
      setApiKeyInputs((prev) => ({ ...prev, [provider]: '' }));
    });
  }

  function handleTest(provider: string) {
    startTransition(() => {
      // TODO: wire to tRPC integrations.testConnection
      setTestResults((prev) => ({
        ...prev,
        [provider]: { success: true, message: 'Connection verified' },
      }));
    });
  }

  const connected = integrations.filter((i) => i.connected);
  const available = integrations.filter((i) => !i.connected);

  return (
    <div>
      <h2 className="text-sm font-semibold text-text-primary mb-4">Integrations</h2>

      {/* Connected */}
      {connected.length > 0 && (
        <section className="mb-6">
          <p className="text-xs text-text-muted font-medium mb-2">Connected</p>
          <div className="space-y-2">
            {connected.map((integration) => {
              const testResult = testResults[integration.provider];
              return (
                <div
                  key={integration.provider}
                  className="flex items-center gap-3 p-3 bg-surface-raised border border-border rounded-lg"
                >
                  <div className="w-8 h-8 rounded-md bg-brand-emerald/10 flex items-center justify-center shrink-0">
                    <Plug className="w-4 h-4 text-brand-emerald" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-medium text-text-primary">{integration.name}</p>
                      {integration.connectedRecord?.status === 'active' ? (
                        <CheckCircle className="w-3.5 h-3.5 text-brand-emerald" />
                      ) : (
                        <AlertCircle className="w-3.5 h-3.5 text-brand-amber" />
                      )}
                    </div>
                    <p className="text-xs text-text-muted">{integration.description}</p>
                    {testResult && (
                      <p className={cn('text-xs mt-0.5', testResult.success ? 'text-brand-emerald' : 'text-red-400')}>
                        {testResult.message}
                      </p>
                    )}
                  </div>
                  <div className="flex items-center gap-1 shrink-0">
                    <button
                      onClick={() => handleTest(integration.provider)}
                      disabled={isPending}
                      className="flex items-center gap-1 text-xs text-text-muted hover:text-text-primary px-2 py-1 rounded hover:bg-surface transition-colors"
                    >
                      <RefreshCw className="w-3 h-3" />
                      Test
                    </button>
                    <button className="flex items-center gap-1 text-xs text-red-400 hover:text-red-300 px-2 py-1 rounded hover:bg-surface transition-colors">
                      <Unplug className="w-3 h-3" />
                      Disable
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </section>
      )}

      {/* Available */}
      {available.length > 0 && (
        <section>
          <p className="text-xs text-text-muted font-medium mb-2">Available</p>
          <div className="grid grid-cols-1 gap-2">
            {available.map((integration) => (
              <div
                key={integration.provider}
                className="flex items-center gap-3 p-3 border border-border border-dashed rounded-lg hover:border-border-subtle transition-colors"
              >
                <div className="w-8 h-8 rounded-md bg-surface-raised flex items-center justify-center shrink-0">
                  <Plug className="w-4 h-4 text-text-muted" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-medium text-text-primary">{integration.name}</p>
                    {integration.required && (
                      <span className="text-[10px] px-1 py-0.5 rounded bg-brand-amber/10 text-brand-amber">Required</span>
                    )}
                  </div>
                  <p className="text-xs text-text-muted">{integration.description}</p>
                </div>
                <div className="shrink-0">
                  {integration.authType === 'api_key' ? (
                    showApiKeyFor === integration.provider ? (
                      <div className="flex items-center gap-2">
                        <input
                          type="password"
                          placeholder="Paste API key..."
                          value={apiKeyInputs[integration.provider] ?? ''}
                          onChange={(e) =>
                            setApiKeyInputs((prev) => ({ ...prev, [integration.provider]: e.target.value }))
                          }
                          className="w-44 bg-surface border border-border rounded px-2 py-1 text-xs text-text-primary focus:outline-none focus:border-brand-emerald"
                        />
                        <button
                          onClick={() => handleApiKeyConnect(integration.provider)}
                          className="text-xs px-2 py-1 bg-brand-emerald text-canvas rounded hover:bg-emerald-500 transition-colors"
                        >
                          Save
                        </button>
                        <button
                          onClick={() => setShowApiKeyFor(null)}
                          className="text-xs text-text-muted hover:text-text-secondary"
                        >
                          Cancel
                        </button>
                      </div>
                    ) : (
                      <button
                        onClick={() => setShowApiKeyFor(integration.provider)}
                        className="text-xs px-3 py-1.5 border border-border rounded-md text-text-secondary hover:text-text-primary hover:border-border-subtle transition-colors"
                      >
                        Connect
                      </button>
                    )
                  ) : (
                    <button className="text-xs px-3 py-1.5 border border-border rounded-md text-text-secondary hover:text-text-primary hover:border-border-subtle transition-colors">
                      Authorise
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </section>
      )}

      {connected.length === 0 && available.length === 0 && (
        <div className="py-12 text-center">
          <XCircle className="w-8 h-8 text-text-muted mx-auto mb-2" />
          <p className="text-sm text-text-muted">No integrations available</p>
        </div>
      )}
    </div>
  );
}
