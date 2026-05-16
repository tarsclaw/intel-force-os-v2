import type { db as DB } from '@intelforce/db';

export interface Context {
  userId: string | null;
  tenantId: string | null;
  tenantSlug: string | null;
  agencyId: string | null;
  isPlatformAdmin: boolean;
  role: string | null;
  db: typeof DB;
  correlationId: string;
  ipAddress: string;
  userAgent: string;
}

export type AuthenticatedContext = Context & { userId: string };
export type TenantContext = AuthenticatedContext & { tenantId: string };
export type PlatformContext = AuthenticatedContext & { isPlatformAdmin: true };
export type AgencyContext = AuthenticatedContext & { agencyId: string };
