'use client';

import { AlertTriangle, AlertCircle, ShieldAlert, CheckCircle, XCircle } from 'lucide-react';
import { cn } from '../../lib/cn';
import { EmptyState } from '../shared/empty-state';

interface Escalation {
  id: string;
  category: string;
  severity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  status: 'OPEN' | 'ACKNOWLEDGED' | 'RESOLVED' | 'WONT_FIX';
  originalMessage: string;
  createdAt: Date;
}

interface EscalationsFeedProps {
  escalations: Escalation[];
  onResolve?: (id: string) => void;
  onAcknowledge?: (id: string) => void;
}

const severityConfig = {
  LOW: { icon: AlertCircle, colour: 'text-text-muted', label: 'Low' },
  MEDIUM: { icon: AlertTriangle, colour: 'text-brand-amber', label: 'Medium' },
  HIGH: { icon: ShieldAlert, colour: 'text-orange-400', label: 'High' },
  CRITICAL: { icon: ShieldAlert, colour: 'text-red-400', label: 'Critical' },
};

const categoryEmoji: Record<string, string> = {
  grievance: '🤝',
  resignation: '🚪',
  mental_health: '💙',
  harassment: '🛡',
  health: '🏥',
  low_confidence: '❓',
  system_unavailable: '⚠️',
};

function relativeTime(date: Date): string {
  const diff = Date.now() - date.getTime();
  const mins = Math.floor(diff / 60_000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

export function EscalationsFeed({ escalations, onResolve, onAcknowledge }: EscalationsFeedProps) {
  const open = escalations.filter((e) => e.status === 'OPEN' || e.status === 'ACKNOWLEDGED');

  if (open.length === 0) {
    return (
      <EmptyState
        icon={<CheckCircle className="w-5 h-5" />}
        title="No open escalations"
        description="All queries are handled or within automation thresholds."
      />
    );
  }

  return (
    <div className="space-y-1">
      {open.map((esc) => {
        const cfg = severityConfig[esc.severity];
        const Icon = cfg.icon;
        const emoji = categoryEmoji[esc.category.toLowerCase().replace(/\s/g, '_')] ?? '🔔';

        return (
          <article
            key={esc.id}
            className="group flex items-start gap-3 rounded-md px-3 py-2.5 hover:bg-surface-raised transition-colors"
            aria-label={`${esc.severity} escalation: ${esc.category}`}
          >
            <Icon className={cn('w-4 h-4 mt-0.5 shrink-0', cfg.colour)} />
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1.5 mb-0.5">
                <span className="text-xs font-medium text-text-primary">
                  {emoji} {esc.category}
                </span>
                {esc.status === 'ACKNOWLEDGED' && (
                  <span className="text-[10px] px-1 py-0.5 rounded bg-brand-amber/10 text-brand-amber">ack'd</span>
                )}
                <span className="ml-auto text-xs text-text-muted tabular-nums shrink-0">
                  {relativeTime(esc.createdAt)}
                </span>
              </div>
              <p className="text-xs text-text-secondary truncate">{esc.originalMessage}</p>
            </div>
            <div className="hidden group-hover:flex items-center gap-1 shrink-0">
              {esc.status === 'OPEN' && onAcknowledge && (
                <button
                  onClick={() => onAcknowledge(esc.id)}
                  className="text-xs text-text-muted hover:text-brand-amber px-1.5 py-0.5 rounded hover:bg-surface transition-colors"
                >
                  Ack
                </button>
              )}
              {onResolve && (
                <button
                  onClick={() => onResolve(esc.id)}
                  className="text-xs text-text-muted hover:text-brand-emerald px-1.5 py-0.5 rounded hover:bg-surface transition-colors"
                >
                  Resolve
                </button>
              )}
            </div>
          </article>
        );
      })}
    </div>
  );
}
