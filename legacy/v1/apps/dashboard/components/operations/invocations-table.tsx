import { CheckCircle, XCircle, Clock, AlertTriangle, Loader2 } from 'lucide-react';
import { cn } from '../../lib/cn';

interface Invocation {
  id: string;
  agent: string;
  trigger: string;
  status: 'RUNNING' | 'SUCCESS' | 'FAILED' | 'ESCALATED' | 'CANCELLED';
  startedAt: Date;
  durationMs: number | null;
  costGbp: number | null;
}

interface InvocationsTableProps {
  items: Invocation[];
}

const statusConfig = {
  RUNNING: { icon: Loader2, colour: 'text-brand-amber', label: 'Running', animate: true },
  SUCCESS: { icon: CheckCircle, colour: 'text-brand-emerald', label: 'Success', animate: false },
  FAILED: { icon: XCircle, colour: 'text-red-400', label: 'Failed', animate: false },
  ESCALATED: { icon: AlertTriangle, colour: 'text-orange-400', label: 'Escalated', animate: false },
  CANCELLED: { icon: XCircle, colour: 'text-text-muted', label: 'Cancelled', animate: false },
};

function formatDuration(ms: number | null): string {
  if (!ms) return '—';
  if (ms < 1000) return `${ms}ms`;
  return `${(ms / 1000).toFixed(1)}s`;
}

function formatTime(date: Date): string {
  return date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
}

export function InvocationsTable({ items }: InvocationsTableProps) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-border">
            <th className="text-left text-xs text-text-muted font-medium pb-2 pr-4">Agent</th>
            <th className="text-left text-xs text-text-muted font-medium pb-2 pr-4">Trigger</th>
            <th className="text-left text-xs text-text-muted font-medium pb-2 pr-4">Started</th>
            <th className="text-right text-xs text-text-muted font-medium pb-2 pr-4">Duration</th>
            <th className="text-left text-xs text-text-muted font-medium pb-2 pr-4">Status</th>
            <th className="text-right text-xs text-text-muted font-medium pb-2">Cost</th>
          </tr>
        </thead>
        <tbody>
          {items.map((inv) => {
            const cfg = statusConfig[inv.status];
            const Icon = cfg.icon;
            return (
              <tr
                key={inv.id}
                className="border-b border-border/50 hover:bg-surface-raised/50 transition-colors cursor-pointer"
              >
                <td className="py-2 pr-4">
                  <span className="font-medium text-text-primary">{inv.agent}</span>
                </td>
                <td className="py-2 pr-4 text-text-secondary">{inv.trigger}</td>
                <td className="py-2 pr-4 text-text-secondary tabular-nums">{formatTime(inv.startedAt)}</td>
                <td className="py-2 pr-4 text-right text-text-secondary tabular-nums font-mono">
                  {formatDuration(inv.durationMs)}
                </td>
                <td className="py-2 pr-4">
                  <div className="flex items-center gap-1.5">
                    <Icon
                      className={cn('w-3.5 h-3.5', cfg.colour, cfg.animate && 'animate-spin')}
                    />
                    <span className={cn('text-xs', cfg.colour)}>{cfg.label}</span>
                  </div>
                </td>
                <td className="py-2 text-right text-text-secondary font-mono tabular-nums">
                  {inv.costGbp ? `£${inv.costGbp.toFixed(4)}` : '—'}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
