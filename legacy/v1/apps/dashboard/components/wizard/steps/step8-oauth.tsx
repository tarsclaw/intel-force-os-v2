'use client';

import { ExternalLink, CheckCircle, Clock } from 'lucide-react';

interface Step8Props {
  tenantSlug: string;
  onNext: () => void;
}

export function Step8OAuth({ tenantSlug, onNext }: Step8Props) {
  return (
    <div>
      <div className="flex items-center gap-2 mb-1">
        <CheckCircle className="w-5 h-5 text-brand-emerald" />
        <h2 className="text-base font-semibold text-text-primary">Tenant created</h2>
      </div>
      <p className="text-sm text-text-muted mb-5">
        <strong className="text-text-secondary">{tenantSlug}</strong> has been created. Complete any OAuth authorisations below, then provisioning will begin.
      </p>

      <div className="max-w-lg space-y-3 mb-6">
        <div className="p-4 bg-surface-raised border border-border rounded-lg">
          <div className="flex items-center gap-2 mb-3">
            <Clock className="w-4 h-4 text-brand-amber" />
            <p className="text-sm font-medium text-text-primary">OAuth integrations pending</p>
          </div>
          <p className="text-xs text-text-muted mb-3">
            Send these links to the tenant owner so they can authorise each integration in their own account. Each link is valid for 24 hours.
          </p>
          <div className="space-y-2">
            {/* In production: list the queued OAuth providers and their auth URLs */}
            <div className="flex items-center justify-between p-2.5 bg-surface border border-border rounded">
              <span className="text-xs text-text-primary">HubSpot</span>
              <button className="flex items-center gap-1 text-xs text-brand-emerald hover:underline">
                <ExternalLink className="w-3 h-3" />
                Send auth link
              </button>
            </div>
            <div className="flex items-center justify-between p-2.5 bg-surface border border-border rounded">
              <span className="text-xs text-text-primary">Gmail</span>
              <button className="flex items-center gap-1 text-xs text-brand-emerald hover:underline">
                <ExternalLink className="w-3 h-3" />
                Send auth link
              </button>
            </div>
          </div>
        </div>

        <p className="text-xs text-text-muted">
          OAuth authorisations can also be completed later from the tenant&apos;s Settings → Integrations panel.
        </p>
      </div>

      <div className="flex justify-end pt-4 border-t border-border">
        <button
          type="button"
          onClick={onNext}
          className="px-4 py-2 bg-brand-emerald text-canvas text-sm font-medium rounded-md hover:bg-emerald-500 transition-colors"
        >
          Continue to provisioning →
        </button>
      </div>
    </div>
  );
}
