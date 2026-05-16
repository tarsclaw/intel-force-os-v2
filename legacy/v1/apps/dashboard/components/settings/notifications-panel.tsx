'use client';

import { useState } from 'react';
import { Bell, Slack, Mail, Plus, X } from 'lucide-react';
import { trpc } from '../../lib/trpc';

interface NotificationSettings {
  slackWebhookUrl: string;
  slackSeverities: string[];
  emailRecipients: string[];
  emailDigest: 'instant' | 'hourly' | 'daily';
  mutedCodes: string[];
}

interface NotificationsPanelProps {
  settings: NotificationSettings;
}

const SEVERITIES = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

export function NotificationsPanel({ settings: initial }: NotificationsPanelProps) {
  const [settings, setSettings] = useState(initial);
  const [newEmail, setNewEmail] = useState('');
  const [saved, setSaved] = useState(false);
  const [testResult, setTestResult] = useState<string | null>(null);

  const saveMutation = trpc.notifications.saveSettings.useMutation({
    onSuccess: () => {
      setSaved(true);
      setTimeout(() => setSaved(false), 2500);
    },
  });

  const testMutation = trpc.notifications.testSlack.useMutation({
    onSuccess: (data) => {
      // Narrow the discriminated union — `data.success` decides which fields exist.
      const message = data.success
        ? '✅ Test message sent'
        : `❌ Failed: ${'error' in data ? data.error : 'unknown error'}`;
      setTestResult(message);
      setTimeout(() => setTestResult(null), 4000);
    },
  });

  function toggleSeverity(sev: string) {
    setSettings((p) => ({
      ...p,
      slackSeverities: p.slackSeverities.includes(sev)
        ? p.slackSeverities.filter((s) => s !== sev)
        : [...p.slackSeverities, sev],
    }));
  }

  function addEmail() {
    if (!newEmail || settings.emailRecipients.includes(newEmail)) return;
    setSettings((p) => ({ ...p, emailRecipients: [...p.emailRecipients, newEmail] }));
    setNewEmail('');
  }

  function handleSave(e: React.FormEvent) {
    e.preventDefault();
    saveMutation.mutate({
      slackWebhookUrl: settings.slackWebhookUrl,
      slackSeverities: settings.slackSeverities as ('LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL')[],
      emailRecipients: settings.emailRecipients,
      emailDigest: settings.emailDigest,
      mutedCodes: settings.mutedCodes,
    });
  }

  return (
    <div>
      <h2 className="text-sm font-semibold text-text-primary mb-4">Notifications</h2>
      <form onSubmit={handleSave} className="space-y-6 max-w-lg">
        <section>
          <div className="flex items-center gap-2 mb-3">
            <Slack className="w-4 h-4 text-text-muted" />
            <h3 className="text-sm font-medium text-text-primary">Slack</h3>
          </div>
          <div className="space-y-3">
            <div>
              <label className="block text-xs text-text-muted mb-1">Webhook URL</label>
              <div className="flex gap-2">
                <input type="url" value={settings.slackWebhookUrl}
                  onChange={(e) => setSettings((p) => ({ ...p, slackWebhookUrl: e.target.value }))}
                  placeholder="https://hooks.slack.com/services/..."
                  className="flex-1 bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald font-mono" />
                {settings.slackWebhookUrl && (
                  <button type="button" onClick={() => testMutation.mutate({ webhookUrl: settings.slackWebhookUrl })}
                    disabled={testMutation.isPending}
                    className="text-xs px-3 py-2 border border-border rounded-md text-text-secondary hover:text-text-primary transition-colors shrink-0 disabled:opacity-50">
                    {testMutation.isPending ? '…' : 'Test'}
                  </button>
                )}
              </div>
              {testResult && <p className="text-xs mt-1">{testResult}</p>}
            </div>
            <div>
              <p className="text-xs text-text-muted mb-2">Alert on severity</p>
              <div className="flex gap-2">
                {SEVERITIES.map((sev) => {
                  const active = settings.slackSeverities.includes(sev);
                  return (
                    <button key={sev} type="button" onClick={() => toggleSeverity(sev)}
                      className={`text-xs px-2.5 py-1.5 rounded border transition-colors ${
                        active ? 'border-brand-emerald bg-brand-emerald/10 text-brand-emerald' : 'border-border text-text-muted hover:border-border-subtle'
                      }`}>{sev}</button>
                  );
                })}
              </div>
            </div>
          </div>
        </section>

        <section>
          <div className="flex items-center gap-2 mb-3">
            <Mail className="w-4 h-4 text-text-muted" />
            <h3 className="text-sm font-medium text-text-primary">Email</h3>
          </div>
          <div className="space-y-3">
            <div>
              <p className="text-xs text-text-muted mb-2">Recipients</p>
              <div className="flex flex-wrap gap-1.5 mb-2">
                {settings.emailRecipients.map((email) => (
                  <span key={email} className="flex items-center gap-1 bg-surface-raised border border-border rounded-full px-2.5 py-1 text-xs text-text-secondary">
                    {email}
                    <button type="button" onClick={() => setSettings((p) => ({ ...p, emailRecipients: p.emailRecipients.filter((e) => e !== email) }))}
                      className="text-text-muted hover:text-red-400 transition-colors"><X className="w-3 h-3" /></button>
                  </span>
                ))}
              </div>
              <div className="flex gap-2">
                <input type="email" value={newEmail} onChange={(e) => setNewEmail(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addEmail())}
                  placeholder="Add email address..."
                  className="flex-1 bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald" />
                <button type="button" onClick={addEmail} disabled={!newEmail}
                  className="flex items-center gap-1 text-xs px-3 py-2 border border-border rounded-md text-text-secondary disabled:opacity-50 hover:text-text-primary transition-colors">
                  <Plus className="w-3.5 h-3.5" />Add
                </button>
              </div>
            </div>
            <div>
              <label className="block text-xs text-text-muted mb-1">Digest frequency</label>
              <select value={settings.emailDigest} onChange={(e) => setSettings((p) => ({ ...p, emailDigest: e.target.value as typeof p.emailDigest }))}
                className="bg-surface-raised border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald">
                <option value="instant">Instant (every escalation)</option>
                <option value="hourly">Hourly digest</option>
                <option value="daily">Daily digest (09:00 BST)</option>
              </select>
            </div>
          </div>
        </section>

        {saveMutation.error && <p className="text-xs text-red-400">{saveMutation.error.message}</p>}

        <button type="submit" disabled={saveMutation.isPending}
          className="px-4 py-2 bg-brand-emerald text-canvas text-sm font-medium rounded-md hover:bg-emerald-500 disabled:opacity-50 transition-colors">
          {saveMutation.isPending ? 'Saving…' : saved ? 'Saved ✓' : 'Save settings'}
        </button>
      </form>
    </div>
  );
}
