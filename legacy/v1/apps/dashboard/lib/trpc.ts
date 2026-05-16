import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '@intelforce/trpc';

// Client-side tRPC instance — use this in 'use client' components
export const trpc = createTRPCReact<AppRouter>();
