'use client';

import { useEffect, useState } from 'react';
import { CheckCircle, Loader2, XCircle, ExternalLink } from 'lucide-react';
import { cn } from '../../../lib/cn';

interface ProvisioningStep {
  id: string;
  label: string;
  status: 'pending' | 'running' | 'complete' | 'failed';
  detail?: string;
}

const PROVISIONING_STEPS: ProvisioningStep[] = [
  { id: 'schema', label: 'Create tenant Postgres schema', status: 'pending' },
  { id: 'secrets', label: 'Provision secrets vault (KMS CMK)', status: 'pending' },
  { id: 'vault', label: 'Initialise agent vault', status: 'pending' },
  { id: 'agents', label: 'Configure enabled agents', status: 'pending' },
  { id: 'webhooks', label: 'Register webhook endpoints', status: 'pending' },
  { id: 'preflight', label: 'Run preflight checks', status: 'pending' },
  { id: 'live', label: 'Mark tenant live', status: 'pending' },
];

interface Step9Props {
  tenantSlug: string;
}

export function Step9Provisioning({ tenantSlug }: Step9Props) {
  const [steps, setSteps] = useState(PROVISIONING_STEPS);
  const [currentIdx, setCurrentIdx] = useState(0);
  const [done, setDone] = useState(false);

  // Simulate provisioning progress
  // In production: subscribe to SSE from Temporal workflow via /api/provisioning/stream
  useEffect(() => {
    if (currentIdx >= PROVISIONING_STEPS.length) {
      setDone(true);
      return;
    }

    setSteps((prev) =>
      prev.map((s, i) =>
        i === currentIdx ? { ...s, status: 'running' } : s,
      ),
    );

    const timer = setTimeout(() => {
      setSteps((prev) =>
        prev.map((s, i) =>
          i === currentIdx ? { ...s, status: 'complete' } : s,
        ),
      );
      setCurrentIdx((i) => i + 1);
    }, 800 + Math.random() * 600);

    return () => clearTimeout(timer);
  }, [currentIdx]);

  return (
    <div>
      <h2 className="text-base font-semibold text-text-primary mb-1">
        {done ? '🎉 Tenant provisioned' : 'Provisioning…'}
      </h2>
      <p className="text-sm text-text-muted mb-5">
        {done
          ? `${tenantSlug} is live and ready for its first agent run.`
          : `Configuring ${tenantSlug}. This takes about 30 seconds.`}
      </p>

      <div className="max-w-md space-y-2 mb-6">
        {steps.map((step) => (
          <div
            key={step.id}
            className={cn(
              'flex items-center gap-3 p-3 rounded-lg border transition-colors',
              step.status === 'complete' && 'border-brand-emerald/30 bg-brand-emerald/5',
              step.status === 'running' && 'border-brand-amber/30 bg-brand-amber/5',
              step.status === 'failed' && 'border-red-500/30 bg-red-500/5',
              step.status === 'pending' && 'border-border opacity-50',
            )}
          >
            <span className="shrink-0">
              {step.status === 'complete' && <CheckCircle className="w-4 h-4 text-brand-emerald" />}
              {step.status === 'running' && <Loader2 className="w-4 h-4 text-brand-amber animate-spin" />}
              {step.status === 'failed' && <XCircle className="w-4 h-4 text-red-400" />}
              {step.status === 'pending' && <div className="w-4 h-4 rounded-full border border-border" />}
            </span>
            <span className={cn(
              'text-sm',
              step.status === 'complete' && 'text-text-primary',
              step.status === 'running' && 'text-text-primary font-medium',
              step.status === 'pending' && 'text-text-muted',
              step.status === 'failed' && 'text-red-400',
            )}>
              {step.label}
            </span>
          </div>
        ))}
      </div>

      {done && (
        <div className="flex gap-3">
          <a
            href={`/t/${tenantSlug}`}
            className="flex items-center gap-1.5 px-4 py-2 bg-brand-emerald text-canvas text-sm font-medium rounded-md hover:bg-emerald-500 transition-colors"
          >
            Go to Operations dashboard
            <ExternalLink className="w-3.5 h-3.5" />
          </a>
          <a
            href="/admin/tenants"
            className="px-4 py-2 border border-border text-sm text-text-secondary rounded-md hover:text-text-primary hover:border-border-subtle transition-colors"
          >
            Back to all tenants
          </a>
        </div>
      )}
    </div>
  );
}
