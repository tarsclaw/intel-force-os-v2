import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { auth } from '@clerk/nextjs/server';
import { appRouter } from '@intelforce/trpc/server';
import { db } from '@intelforce/db';
import { randomUUID } from 'crypto';
import type { Context } from '@intelforce/trpc';

async function handler(req: Request) {
  const { userId } = await auth();

  return fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext: async (): Promise<Context> => {
      const correlationId = randomUUID();

      // Resolve tenant context from headers set by the Providers component
      const tenantSlug = req.headers.get('x-tenant-slug');
      const agencySlug = req.headers.get('x-agency-slug');

      let tenantId: string | null = null;
      let tenantSlugResolved: string | null = null;
      let agencyId: string | null = null;
      let isPlatformAdmin = false;

      if (userId && tenantSlug) {
        // Look up tenant and verify the user has a role in it
        const tenant = await db.tenant.findFirst({
          where: {
            slug: tenantSlug,
            userRoles: { some: { userId, revokedAt: null } },
          },
          select: { id: true, slug: true },
        });
        if (tenant) {
          tenantId = tenant.id;
          tenantSlugResolved = tenant.slug;
        }
      }

      if (userId && agencySlug) {
        const agency = await db.tenant.findFirst({
          where: {
            slug: agencySlug,
            plan: 'AGENCY_PARTNER',
            userRoles: { some: { userId, revokedAt: null } },
          },
          select: { id: true },
        });
        if (agency) agencyId = agency.id;
      }

      // Platform admin: user has a PLATFORM_ADMIN role on any tenant
      if (userId) {
        const adminRole = await db.userRole.findFirst({
          where: { userId, role: 'PLATFORM_ADMIN', revokedAt: null },
        });
        isPlatformAdmin = !!adminRole;
      }

      return {
        userId,
        tenantId,
        tenantSlug: tenantSlugResolved,
        agencyId,
        isPlatformAdmin,
        role: null,
        db,
        correlationId,
        ipAddress: req.headers.get('x-forwarded-for') ?? 'unknown',
        userAgent: req.headers.get('user-agent') ?? 'unknown',
      };
    },
    onError({ error, path }) {
      if (error.code === 'INTERNAL_SERVER_ERROR') {
        console.error(`tRPC error on ${path}:`, error);
      }
    },
  });
}

export { handler as GET, handler as POST };
