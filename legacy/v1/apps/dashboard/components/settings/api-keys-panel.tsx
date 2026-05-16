'use client';

import { useState } from 'react';
import { Key, Copy, Trash2, Plus, Loader2 } from 'lucide-react';
import { trpc } from '../../lib/trpc';

const SCOPES = [
  { value: 'read:all', label: 'Read all data' },
  { value: 'read:costs', label: 'Read costs' },
  { value: 'read:invocations', label: 'Read invocations' },
  { value: 'read:escalations', label: 'Read escalations' },
  { value: 'write:escalations', label: 'Write escalations' },
  { value: 'write:settings', label: 'Write settings' },
] as const;

type Scope = typeof SCOPES[number]['value'];

export function ApiKeysPanel({ apiKeys: initialKeys }: {
  apiKeys: Array<{ id: string; prefix: string; name: string; scopes: string[]; createdAt: Date; lastUsedAt: Date | null }>;
}) {
  const [keys, setKeys] = useState(initialKeys);
  const [showCreate, setShowCreate] = useState(false);
  const [newName, setNewName] = useState('');
  const [scopes, setScopes] = useState<Scope[]>(['read:all']);
  const [generatedKey, setGeneratedKey] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  const createMutation = trpc.apiKeys.create.useMutation({
    onSuccess: (data) => {
      setGeneratedKey(data.key);
      setKeys((prev) => [
        ...prev,
        {
          id: data.id,
          prefix: data.prefix,
          name: data.name,
          scopes: data.scopes,
          // The mutation returns createdAt as an ISO string; the local state expects a Date.
          createdAt: typeof data.createdAt === 'string' ? new Date(data.createdAt) : data.createdAt,
          lastUsedAt: null,
        },
      ]);
      setShowCreate(false);
      setNewName('');
      setScopes(['read:all']);
    },
  });

  const revokeMutation = trpc.apiKeys.revoke.useMutation({
    onSuccess: (_, vars) => setKeys((prev) => prev.filter((k) => k.id !== vars.id)),
  });

  async function copyKey(key: string) {
    await navigator.clipboard.writeText(key);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  const atLimit = keys.length >= 5;

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-sm font-semibold text-text-primary">API Keys</h2>
        {!atLimit && (
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 bg-brand-emerald text-canvas rounded-md hover:bg-emerald-500 transition-colors">
            <Plus className="w-3.5 h-3.5" />Generate key
          </button>
        )}
      </div>

      {generatedKey && (
        <div className="mb-4 p-3 bg-brand-emerald/10 border border-brand-emerald/30 rounded-lg">
          <p className="text-xs font-medium text-brand-emerald mb-1">Key generated — copy it now</p>
          <p className="text-xs text-brand-emerald/70 mb-2">This is the only time the full key will be shown.</p>
          <div className="flex items-center gap-2">
            <code className="flex-1 bg-surface rounded px-2 py-1.5 text-xs font-mono text-text-primary truncate">{generatedKey}</code>
            <button onClick={() => copyKey(generatedKey)}
              className="flex items-center gap-1 text-xs px-2 py-1.5 bg-brand-emerald text-canvas rounded hover:bg-emerald-500 transition-colors shrink-0">
              <Copy className="w-3 h-3" />{copied ? 'Copied!' : 'Copy'}
            </button>
          </div>
          <button onClick={() => setGeneratedKey(null)} className="mt-2 text-xs text-brand-emerald/70 hover:text-brand-emerald">
            I&apos;ve copied it — dismiss
          </button>
        </div>
      )}

      {showCreate && (
        <form onSubmit={(e) => { e.preventDefault(); createMutation.mutate({ name: newName, scopes }); }}
          className="mb-4 p-3 bg-surface-raised border border-border rounded-lg space-y-3">
          <h3 className="text-xs font-medium text-text-primary">New API key</h3>
          <input type="text" placeholder="Key name (e.g. CI pipeline)" value={newName}
            onChange={(e) => setNewName(e.target.value)} required maxLength={50}
            className="w-full bg-surface border border-border rounded px-2.5 py-1.5 text-sm text-text-primary focus:outline-none focus:border-brand-emerald" />
          <div>
            <p className="text-xs text-text-muted mb-2">Scopes</p>
            <div className="space-y-1.5">
              {SCOPES.map((s) => (
                <label key={s.value} className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" checked={scopes.includes(s.value)}
                    onChange={() => setScopes((prev) => prev.includes(s.value) ? prev.filter((x) => x !== s.value) : [...prev, s.value])} />
                  <span className="text-xs text-text-secondary">{s.label}</span>
                </label>
              ))}
            </div>
          </div>
          {createMutation.error && <p className="text-xs text-red-400">{createMutation.error.message}</p>}
          <div className="flex gap-2">
            <button type="submit" disabled={!newName || scopes.length === 0 || createMutation.isPending}
              className="flex items-center gap-1.5 px-3 py-1.5 bg-brand-emerald text-canvas text-xs font-medium rounded disabled:opacity-50 hover:bg-emerald-500 transition-colors">
              {createMutation.isPending && <Loader2 className="w-3 h-3 animate-spin" />}Generate
            </button>
            <button type="button" onClick={() => setShowCreate(false)} className="text-xs text-text-muted hover:text-text-secondary transition-colors px-2">Cancel</button>
          </div>
        </form>
      )}

      {keys.length === 0 && !showCreate && (
        <div className="py-10 text-center border border-dashed border-border rounded-lg">
          <Key className="w-8 h-8 text-text-muted mx-auto mb-2" />
          <p className="text-sm text-text-muted">No API keys</p>
        </div>
      )}

      {keys.length > 0 && (
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border">
              {['Name', 'Prefix', 'Scopes', 'Created', ''].map((h) => (
                <th key={h} className="text-left text-xs text-text-muted font-medium pb-2 pr-4">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {keys.map((k) => (
              <tr key={k.id} className="border-b border-border/50">
                <td className="py-2.5 pr-4 text-sm text-text-primary font-medium">{k.name}</td>
                <td className="py-2.5 pr-4"><code className="text-xs font-mono text-text-secondary">{k.prefix}…</code></td>
                <td className="py-2.5 pr-4">
                  <div className="flex flex-wrap gap-1">
                    {k.scopes.map((s) => <span key={s} className="text-[10px] px-1 py-0.5 rounded bg-surface-raised text-text-muted">{s}</span>)}
                  </div>
                </td>
                <td className="py-2.5 pr-4 text-xs text-text-muted">{new Date(k.createdAt).toLocaleDateString('en-GB')}</td>
                <td className="py-2.5">
                  <button onClick={() => revokeMutation.mutate({ id: k.id })} disabled={revokeMutation.isPending}
                    className="text-red-400 hover:text-red-300 disabled:opacity-50 transition-colors">
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
