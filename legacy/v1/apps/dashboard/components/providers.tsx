'use client';

import { useState } from 'react';
import { QueryClientProvider } from '@tanstack/react-query';
import { httpBatchLink, loggerLink } from '@trpc/client';
import superjson from 'superjson';
import { trpc } from '../lib/trpc';
import { getQueryClient } from '../lib/query-client';
import { SidebarProvider } from './shared/sidebar-context';

function getBaseUrl() {
  if (typeof window !== 'undefined') return '';
  return process.env['VERCEL_URL']
    ? `https://${process.env['VERCEL_URL']}`
    : `http://localhost:${process.env['PORT'] ?? 3000}`;
}

interface ProvidersProps {
  children: React.ReactNode;
  // Current tenant slug — passed from the layout so tRPC requests are scoped correctly
  tenantSlug?: string;
  agencySlug?: string;
}

export function Providers({ children, tenantSlug, agencySlug }: ProvidersProps) {
  const queryClient = getQueryClient();

  const [trpcClient] = useState(() =>
    trpc.createClient({
      links: [
        loggerLink({
          enabled: (opts) =>
            process.env['NODE_ENV'] === 'development' ||
            (opts.direction === 'down' && opts.result instanceof Error),
        }),
        httpBatchLink({
          url: `${getBaseUrl()}/api/trpc`,
          transformer: superjson,
          headers() {
            const headers: Record<string, string> = {};
            if (tenantSlug) headers['x-tenant-slug'] = tenantSlug;
            if (agencySlug) headers['x-agency-slug'] = agencySlug;
            return headers;
          },
        }),
      ],
    }),
  );

  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        <SidebarProvider>{children}</SidebarProvider>
      </QueryClientProvider>
    </trpc.Provider>
  );
}
