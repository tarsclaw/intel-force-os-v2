'use client';

import { useState, useTransition } from 'react';
import { CheckCircle, XCircle, ArrowUpRight, Edit3, Loader2, BookOpen, Database } from 'lucide-react';
import { cn } from '@/lib/cn';
import { SensitivityBadge, type Severity } from '@/components/shared/sensitivity-badge';
import { approveEscalation } from '@/app/actions/approve';

interface ApprovalCardProps {
  id: string;
  correlationId: string | null;
  tenantId: string;
  tenantSlug: string;
  severity: Severity;
  category: string;
  originalMessage: string;
  draftReply: string | null;
  handbookSections?: string | null;
  createdAt: Date;
  employeeRef?: string | null;
}

function timeAgo(date: Date): string {
  const secs = Math.floor((Date.now() - date.getTime()) / 1000);
  if (secs < 60) return `${secs}s ago`;
  if (secs < 3600) return `${Math.floor(secs / 60)}m ago`;
  if (secs < 86400) return `${Math.floor(secs / 3600)}h ago`;
  return `${Math.floor(secs / 86400)}d ago`;
}

export function ApprovalCard({
  id,
  correlationId,
  tenantId,
  tenantSlug,
  severity,
  category,
  originalMessage,
  draftReply,
  handbookSections,
  createdAt,
  employeeRef,
}: ApprovalCardProps) {
  const [editing, setEditing] = useState(false);
  const [editedText, setEditedText] = useState(draftReply ?? '');
  const [dismissed, setDismissed] = useState(false);
  const [isPending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  if (dismissed) return null;

  function handleAction(action: 'approve' | 'reject' | 'escalate') {
    if (!correlationId) {
      setError('No correlation ID — use the Teams card to approve.');
      return;
    }
    setError(null);
    startTransition(async () => {
      const result = await approveEscalation(
        correlationId,
        tenantId,
        tenantSlug,
        action,
        action === 'approve' && editing ? editedText : undefined,
      );
      if (result.success) {
        setDismissed(true);
      } else {
        setError(result.error ?? 'Action failed');
      }
    });
  }

  const borderColor =
    severity === 'CRITICAL'
      ? 'border-red-500/40'
      : severity === 'HIGH'
        ? 'border-amber-400/30'
        : 'border-white/8';

  return (
    <article
      className={cn(
        'bg-[rgb(var(--bg-surface))] rounded-2xl ring-1 ring-white/5 overflow-hidden',
        'border-l-2',
        borderColor,
      )}
    >
      {/* Header */}
      <div className="flex items-center gap-3 px-5 py-3.5 border-b border-white/5">
        <SensitivityBadge severity={severity} />
        <span className="text-xs text-text-muted font-medium">{category}</span>
        <span className="ml-auto text-xs text-text-muted font-mono">{timeAgo(createdAt)}</span>
      </div>

      {/* Meta */}
      <div className="px-5 pt-4">
        <div className="flex flex-wrap gap-x-6 gap-y-1 text-[11px] text-text-muted mb-4">
          {employeeRef && (
            <span>
              <span className="text-text-secondary font-medium">Employee </span>
              {employeeRef}
            </span>
          )}
          <span>
            <span className="text-text-secondary font-medium">Category </span>
            {category}
          </span>
        </div>

        {/* Original query */}
        <div className="mb-4">
          <p className="text-[10px] tracking-widest uppercase text-text-muted font-medium mb-1.5">
            Employee query
          </p>
          <p className="text-sm text-text-secondary leading-relaxed">{originalMessage}</p>
        </div>

        {/* Draft reply */}
        <div className="mb-4">
          <p className="text-[10px] tracking-widest uppercase text-text-muted font-medium mb-1.5">
            Draft reply
          </p>
          {draftReply ? (
            editing ? (
              <textarea
                value={editedText}
                onChange={(e) => setEditedText(e.target.value)}
                rows={5}
                className="w-full bg-[rgb(var(--bg-deep))] text-sm text-text-primary rounded-lg px-3 py-2.5 ring-1 ring-white/10 focus:ring-emerald-400/40 outline-none resize-y leading-relaxed"
              />
            ) : (
              <p className="text-sm text-text-primary leading-relaxed bg-[rgb(var(--bg-deep))] rounded-lg px-3 py-2.5 ring-1 ring-white/8">
                {draftReply}
              </p>
            )
          ) : (
            <p className="text-sm text-text-muted italic">
              Draft available in Teams — approve there or{' '}
              {!correlationId && 'configure WORKER_URL to enable web approval.'}
            </p>
          )}
        </div>

        {/* Sources */}
        {handbookSections && (
          <div className="flex items-center gap-2 mb-4 text-[11px] text-text-muted">
            <BookOpen className="w-3.5 h-3.5 text-emerald-400/60 shrink-0" />
            <span>
              <span className="text-text-secondary font-medium">Handbook: </span>
              {handbookSections}
            </span>
          </div>
        )}

        {!correlationId && (
          <div className="flex items-center gap-2 mb-4 text-[11px] text-amber-400/80">
            <Database className="w-3.5 h-3.5 shrink-0" />
            <span>Web approval requires WORKER_URL env var. Teams card works normally.</span>
          </div>
        )}
      </div>

      {/* Error */}
      {error && (
        <p className="mx-5 mb-3 text-xs text-red-400 bg-red-500/10 rounded-lg px-3 py-2 ring-1 ring-red-500/20">
          {error}
        </p>
      )}

      {/* Actions */}
      <div className="px-4 py-3 bg-[rgb(var(--bg-deep))] border-t border-white/5 flex flex-wrap items-center gap-2">
        <button
          onClick={() => handleAction('reject')}
          disabled={isPending}
          className="flex items-center gap-1.5 text-xs px-3 py-2 rounded-lg ring-1 ring-white/10 text-text-secondary hover:text-red-400 hover:ring-red-500/30 transition-all disabled:opacity-40"
        >
          <XCircle className="w-3.5 h-3.5" />
          Reject
        </button>

        <button
          onClick={() => {
            setEditing((v) => !v);
          }}
          disabled={!draftReply || isPending}
          className={cn(
            'flex items-center gap-1.5 text-xs px-3 py-2 rounded-lg ring-1 transition-all disabled:opacity-40',
            editing
              ? 'ring-emerald-400/30 text-emerald-400 bg-emerald-400/5'
              : 'ring-white/10 text-text-secondary hover:text-text-primary hover:ring-white/20',
          )}
        >
          <Edit3 className="w-3.5 h-3.5" />
          {editing ? 'Cancel edit' : 'Edit draft'}
        </button>

        <button
          onClick={() => handleAction('escalate')}
          disabled={isPending}
          className="flex items-center gap-1.5 text-xs px-3 py-2 rounded-lg ring-1 ring-white/10 text-text-secondary hover:text-amber-300 hover:ring-amber-400/30 transition-all disabled:opacity-40"
        >
          <ArrowUpRight className="w-3.5 h-3.5" />
          Escalate
        </button>

        <button
          onClick={() => handleAction('approve')}
          disabled={isPending || (editing && !editedText.trim())}
          className="ml-auto flex items-center gap-1.5 text-sm font-semibold px-4 py-2 rounded-lg bg-emerald-400 hover:bg-emerald-300 text-emerald-950 transition-all disabled:opacity-40 disabled:cursor-not-allowed"
        >
          {isPending ? (
            <Loader2 className="w-3.5 h-3.5 animate-spin" />
          ) : (
            <CheckCircle className="w-3.5 h-3.5" />
          )}
          {editing ? 'Send edited' : 'Approve & send'}
        </button>
      </div>
    </article>
  );
}
