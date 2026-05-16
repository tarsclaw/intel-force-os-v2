'use client';

import { useEffect } from 'react';
import { AlertTriangle, RefreshCw } from 'lucide-react';

// App Router automatic error boundary — catches any thrown error in this
// segment (including data-fetch errors from Server Components). Resets via
// the `reset()` callback, which re-renders the boundary's children.
export default function TenantError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // TODO: pipe to Sentry / Datadog when wired
    console.error('[tenant error]', error);
  }, [error]);

  return (
    <div className="flex items-center justify-center min-h-[60vh] px-4">
      <div className="max-w-md text-center">
        <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-red-500/10 ring-1 ring-red-500/20 grid place-items-center">
          <AlertTriangle className="w-5 h-5 text-red-400" />
        </div>
        <h2 className="font-display text-xl font-light text-text-primary mb-2">
          Something went wrong
        </h2>
        <p className="text-sm text-text-muted leading-relaxed mb-1">
          We couldn't load this page. The error has been logged.
        </p>
        {error.digest && (
          <p className="font-mono text-[10px] text-text-muted/60 mb-6">
            error id: {error.digest}
          </p>
        )}
        <div className="flex items-center justify-center gap-2">
          <button
            onClick={reset}
            className="inline-flex items-center gap-2 text-sm font-medium px-4 py-2 rounded-lg bg-emerald-400 text-emerald-950 hover:bg-emerald-300 transition-colors"
          >
            <RefreshCw className="w-3.5 h-3.5" />
            Try again
          </button>
          <a
            href="/"
            className="inline-flex items-center gap-2 text-sm font-medium px-4 py-2 rounded-lg bg-white/[0.04] ring-1 ring-white/10 text-text-secondary hover:text-text-primary hover:ring-white/20 transition-all"
          >
            Go home
          </a>
        </div>
      </div>
    </div>
  );
}
