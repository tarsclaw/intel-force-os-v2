import { auth } from '@clerk/nextjs/server';
import { db } from '@intelforce/db';
import { NextResponse } from 'next/server';

// Result type — discriminated union so callers know what they got.
export type TenantAccessResult =
  | { ok: true; userId: string; tenant: { id: string; slug: string; status: string }; role: string }
  | { ok: false; response: NextResponse };

/**
 * Require that the current Clerk user has access to the tenant.
 *
 * Use this in every API route that touches tenant-scoped data. Returns the
 * tenant + role if access is granted, otherwise a NextResponse with the
 * appropriate status code (401 unauthenticated, 403 unauthorized, 404 missing,
 * 410 decommissioned).
 *
 * Usage:
 *   const access = await requireTenantAccess(slug);
 *   if (!access.ok) return access.response;
 *   const { tenant, role, userId } = access;
 */
export async function requireTenantAccess(tenantSlug: string): Promise<TenantAccessResult> {
  const { userId } = await auth();
  if (!userId) {
    return {
      ok: false,
      response: new NextResponse('Unauthorized', { status: 401 }),
    };
  }

  const tenant = await db.tenant.findUnique({
    where: { slug: tenantSlug },
    select: { id: true, slug: true, status: true },
  });

  if (!tenant) {
    return {
      ok: false,
      response: new NextResponse('Not found', { status: 404 }),
    };
  }

  if (tenant.status === 'DECOMMISSIONED') {
    return {
      ok: false,
      response: new NextResponse('Gone', { status: 410 }),
    };
  }

  // Look up the user's role on this tenant
  const user = await db.user.findUnique({
    where: { clerkUserId: userId },
    select: { id: true },
  });

  if (!user) {
    return {
      ok: false,
      response: new NextResponse('Forbidden', { status: 403 }),
    };
  }

  const role = await db.userRole.findFirst({
    where: { userId: user.id, tenantId: tenant.id, revokedAt: null },
    select: { role: true },
  });

  if (!role) {
    // Platform admin override: also allow platform-admin users
    const platformAdminRole = await db.userRole.findFirst({
      where: { userId: user.id, role: 'PLATFORM_ADMIN', revokedAt: null },
      select: { role: true },
    });
    if (!platformAdminRole) {
      return {
        ok: false,
        response: new NextResponse('Forbidden', { status: 403 }),
      };
    }
    return { ok: true, userId, tenant, role: 'PLATFORM_ADMIN' };
  }

  return { ok: true, userId, tenant, role: role.role };
}
