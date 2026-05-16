import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { db } from '@intelforce/db';

// Root redirect — send authenticated users to their first tenant.
// `auth().userId` returns the Clerk user ID (e.g. user_xxx) — we map that to
// our internal User row via clerkUserId, then look up tenant roles by user.id.
export default async function RootPage() {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  try {
    // Map Clerk → internal User row
    const user = await db.user.findUnique({
      where: { clerkUserId: userId },
      select: { id: true },
    });

    if (!user) {
      // First-time sign-in. The seed script (or Clerk webhook in prod) hasn't
      // created the User row yet — drop them on /admin which is permissive.
      redirect('/admin');
    }

    const firstRole = await db.userRole.findFirst({
      where: { userId: user.id, revokedAt: null },
      include: { tenant: { select: { slug: true, plan: true } } },
      orderBy: { grantedAt: 'asc' },
    });

    if (firstRole?.tenant) {
      if (firstRole.tenant.plan === 'AGENCY_PARTNER') {
        redirect(`/agency/${firstRole.tenant.slug}`);
      }
      redirect(`/t/${firstRole.tenant.slug}`);
    }

    redirect('/admin');
  } catch (err) {
    // Next's redirect() throws a control-flow exception — re-throw so the
    // browser navigates. Real errors fall through to /admin as a safety net.
    if (err instanceof Error && err.message === 'NEXT_REDIRECT') throw err;
    redirect('/admin');
  }
}
