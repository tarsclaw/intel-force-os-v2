'use client';

import { useState } from 'react';
import { KeyRound, RotateCcw, ShieldAlert, AlertTriangle, Clock } from 'lucide-react';
import { cn } from '../../lib/cn';

interface SecretRef {
  ref: string;
  kind: string;
  provider: string;
  label: string;
  status: 'active' | 'expired' | 'rotation_pending' | 'revoked';
  lastRotatedAt: Date | null;
  nextRotationAt: Date | null;
  lastAccessedAt: Date | null;
}

interface SecretsPanelProps {
  secrets: SecretRef[];
}

const statusConfig = {
  active: { label: 'Active', colour: 'text-brand-emerald', bg: 'bg-brand-emerald/10' },
  expired: { label: 'Expired', colour: 'text-red-400', bg: 'bg-red-500/10' },
  rotation_pending: { label: 'Rotation pending', colour: 'text-brand-amber', bg: 'bg-brand-amber/10' },
  revoked: { label: 'Revoked', colour: 'text-text-muted', bg: 'bg-surface-raised' },
};

function formatDate(d: Date | null): string {
  if (!d) return '—';
  return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

export function SecretsPanel({ secrets }: SecretsPanelProps) {
  const [showEmergencyConfirm, setShowEmergencyConfirm] = useState(false);
  const [emergencyReason, setEmergencyReason] = useState('');

  if (secrets.length === 0) {
    return (
      <div>
        <h2 className="text-sm font-semibold text-text-primary mb-4">Secrets</h2>
        <div className="py-12 text-center border border-dashed border-border rounded-lg">
          <KeyRound className="w-8 h-8 text-text-muted mx-auto mb-2" />
          <p className="text-sm font-medium text-text-primary mb-1">No secrets configured</p>
          <p className="text-xs text-text-muted">
            Secrets are stored automatically when you connect integrations.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-sm font-semibold text-text-primary">Secrets</h2>
        <button
          onClick={() => setShowEmergencyConfirm(true)}
          className="flex items-center gap-1.5 text-xs text-red-400 hover:text-red-300 px-2 py-1.5 rounded border border-red-500/30 hover:border-red-500/50 transition-colors"
        >
          <ShieldAlert className="w-3.5 h-3.5" />
          Emergency rotation
        </button>
      </div>

      <p className="text-xs text-text-muted mb-4">
        Secret values are never shown. Refs point to encrypted values in the Secrets Vault.
      </p>

      {/* Emergency rotation confirm */}
      {showEmergencyConfirm && (
        <div className="mb-4 p-3 border border-red-500/30 rounded-lg bg-red-500/5">
          <p className="text-xs font-medium text-red-400 mb-1">Emergency rotation</p>
          <p className="text-xs text-text-muted mb-3">
            This immediately revokes ALL secrets. All integrations will need reauthorisation. This action requires a 2-person approval.
          </p>
          <input
            type="text"
            placeholder="Reason for emergency rotation (min 10 chars)..."
            value={emergencyReason}
            onChange={(e) => setEmergencyReason(e.target.value)}
            className="w-full bg-surface border border-border rounded px-2.5 py-1.5 text-xs text-text-primary focus:outline-none focus:border-red-500 mb-2"
          />
          <div className="flex gap-2">
            <button
              disabled={emergencyReason.length < 10}
              className="text-xs px-3 py-1.5 bg-red-500 text-white rounded disabled:opacity-50 hover:bg-red-600 transition-colors"
            >
              Initiate emergency rotation
            </button>
            <button
              onClick={() => { setShowEmergencyConfirm(false); setEmergencyReason(''); }}
              className="text-xs text-text-muted hover:text-text-secondary transition-colors"
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      <table className="w-full text-sm" aria-label="Secret references">
        <thead>
          <tr className="border-b border-border">
            {['Secret', 'Status', 'Last rotated', 'Next rotation', 'Actions'].map((h) => (
              <th key={h} className="text-left text-xs text-text-muted font-medium pb-2 pr-4">{h}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {secrets.map((secret) => {
            const cfg = statusConfig[secret.status];
            const isDue = secret.nextRotationAt && secret.nextRotationAt < new Date();
            return (
              <tr key={secret.ref} className="border-b border-border/50">
                <td className="py-3 pr-4">
                  <div className="flex items-center gap-2">
                    <KeyRound className="w-3.5 h-3.5 text-text-muted shrink-0" />
                    <div>
                      <p className="text-sm text-text-primary font-medium">{secret.label}</p>
                      <p className="text-xs text-text-muted font-mono truncate max-w-[160px]">
                        {secret.ref.split('/').slice(-2).join('/')}
                      </p>
                    </div>
                  </div>
                </td>
                <td className="py-3 pr-4">
                  <span className={cn('inline-flex items-center gap-1 text-xs px-1.5 py-0.5 rounded', cfg.bg, cfg.colour)}>
                    {cfg.label}
                  </span>
                </td>
                <td className="py-3 pr-4 text-xs text-text-muted">{formatDate(secret.lastRotatedAt)}</td>
                <td className="py-3 pr-4">
                  <div className="flex items-center gap-1">
                    {isDue && <AlertTriangle className="w-3 h-3 text-brand-amber" />}
                    <span className={cn('text-xs', isDue ? 'text-brand-amber' : 'text-text-muted')}>
                      {formatDate(secret.nextRotationAt)}
                    </span>
                  </div>
                </td>
                <td className="py-3">
                  <button className="flex items-center gap-1 text-xs text-text-muted hover:text-text-primary transition-colors">
                    <RotateCcw className="w-3 h-3" />
                    Rotate
                  </button>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>

      <div className="flex items-center gap-1.5 mt-3 text-xs text-text-muted">
        <Clock className="w-3 h-3" />
        Secrets rotate automatically every 90 days. Manual rotation creates a 24-hour dual-window.
      </div>
    </div>
  );
}
