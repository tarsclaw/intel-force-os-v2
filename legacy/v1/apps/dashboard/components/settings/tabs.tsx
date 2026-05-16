'use client';

import { useState } from 'react';
import { Plug, KeyRound, CreditCard, Settings, Users, Key, Bell } from 'lucide-react';
import { cn } from '../../lib/cn';
import { ConfigPanel } from './config-panel';
import { TeamPanel } from './team-panel';
import { IntegrationsPanel } from './integrations-panel';
import { SecretsPanel } from './secrets-panel';
import { BillingPanel } from './billing-panel';
import { ApiKeysPanel } from './api-keys-panel';
import { NotificationsPanel } from './notifications-panel';

interface TenantData {
  id: string;
  name: string;
  slug: string;
  plan: string;
  status: string;
  billingEmail: string | null;
  timezone: string;
  agentsEnabled: string[];
  costBudgetGbp: unknown;
  hardStopBudget: boolean;
  userRoles: Array<{
    role: string;
    user: { id: string; name: string | null; email: string; imageUrl: string | null };
  }>;
}

const tabs = [
  { id: 'integrations', label: 'Integrations', icon: Plug },
  { id: 'secrets', label: 'Secrets', icon: KeyRound },
  { id: 'billing', label: 'Billing', icon: CreditCard },
  { id: 'config', label: 'Config', icon: Settings },
  { id: 'team', label: 'Team', icon: Users },
  { id: 'api-keys', label: 'API Keys', icon: Key },
  { id: 'notifications', label: 'Notifications', icon: Bell },
] as const;

type TabId = typeof tabs[number]['id'];

export function SettingsTabs({ tenant }: { tenant: TenantData }) {
  const [active, setActive] = useState<TabId>('config');

  return (
    <div className="flex gap-5">
      {/* Sidebar nav */}
      <nav className="w-44 shrink-0">
        <ul className="space-y-0.5">
          {tabs.map(({ id, label, icon: Icon }) => (
            <li key={id}>
              <button
                onClick={() => setActive(id)}
                className={cn(
                  'w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm transition-colors text-left',
                  active === id
                    ? 'bg-surface-raised text-text-primary'
                    : 'text-text-secondary hover:text-text-primary hover:bg-surface-raised',
                )}
              >
                <Icon className={cn('w-4 h-4 shrink-0', active === id && 'text-brand-emerald')} />
                {label}
              </button>
            </li>
          ))}
        </ul>
      </nav>

      {/* Panel content */}
      <div className="flex-1 min-w-0 bg-surface border border-border rounded-lg p-5">
        {active === 'config' && <ConfigPanel tenant={tenant} />}
        {active === 'team' && <TeamPanel members={tenant.userRoles} />}
        {active === 'integrations' && (
          <IntegrationsPanel tenantId={tenant.id} integrations={[]} />
        )}
        {active === 'secrets' && <SecretsPanel secrets={[]} />}
        {active === 'billing' && (
          <BillingPanel
            plan={tenant.plan}
            status={tenant.status}
            monthSpendGbp={0}
            budgetGbp={tenant.costBudgetGbp ? Number(tenant.costBudgetGbp) : null}
          />
        )}
        {active === 'api-keys' && <ApiKeysPanel apiKeys={[]} />}
        {active === 'notifications' && (
          <NotificationsPanel
            settings={{
              slackWebhookUrl: '',
              slackSeverities: ['HIGH', 'CRITICAL'],
              emailRecipients: [],
              emailDigest: 'instant',
              mutedCodes: [],
            }}
          />
        )}
      </div>
    </div>
  );
}
