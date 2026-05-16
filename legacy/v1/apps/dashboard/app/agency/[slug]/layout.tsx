import { auth } from '@clerk/nextjs/server';
import { redirect, notFound } from 'next/navigation';
import { db } from '@intelforce/db';
import Link from 'next/link';
import { UserButton } from '@clerk/nextjs';
import { LayoutDashboard, Users, CreditCard, Activity, Users2, Settings2 } from 'lucide-react';

const agencyNav = [
  { label: 'Portfolio', href: '', icon: LayoutDashboard },
  { label: 'Tenants', href: '/tenants', icon: Users },
  { label: 'Activity', href: '/activity', icon: Activity },
  { label: 'Billing', href: '/billing', icon: CreditCard },
  { label: 'Team', href: '/team', icon: Users2 },
  { label: 'Settings', href: '/settings', icon: Settings2 },
];

export default async function AgencyLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ slug: string }>;
}) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const agency = await db.tenant.findFirst({
    where: { slug, plan: 'AGENCY_PARTNER' },
    select: { id: true, name: true, slug: true },
  });
  if (!agency) notFound();

  return (
    <div className="min-h-screen bg-canvas">
      <aside className="fixed inset-y-0 left-0 w-56 flex flex-col border-r border-border bg-surface z-10">
        <div className="h-14 flex items-center gap-2 px-4 border-b border-border">
          <div className="w-7 h-7 rounded-md bg-brand-emerald flex items-center justify-center shrink-0">
            <span className="text-[10px] font-bold text-canvas">IF</span>
          </div>
          <span className="text-text-primary font-semibold text-sm truncate">Intel Force OS</span>
        </div>

        <div className="px-4 py-2 border-b border-border">
          <p className="text-xs text-text-muted">Agency Partner</p>
          <p className="text-sm font-medium text-text-primary truncate">{agency.name}</p>
        </div>

        <nav className="flex-1 overflow-y-auto py-2">
          {agencyNav.map(({ label, href, icon: Icon }) => (
            <Link
              key={label}
              href={`/agency/${slug}${href}`}
              className="flex items-center gap-2.5 px-4 py-2 text-sm text-text-secondary hover:text-text-primary hover:bg-surface-raised transition-colors"
            >
              <Icon className="w-4 h-4 shrink-0" />
              {label}
            </Link>
          ))}
        </nav>

        <div className="h-14 flex items-center px-4 border-t border-border gap-2">
          <UserButton appearance={{ elements: { avatarBox: 'w-7 h-7' } }} />
          <span className="text-sm text-text-secondary truncate">Account</span>
        </div>
      </aside>

      <main className="pl-56 min-h-screen">
        <div className="max-w-7xl mx-auto px-6 py-6">{children}</div>
      </main>
    </div>
  );
}
