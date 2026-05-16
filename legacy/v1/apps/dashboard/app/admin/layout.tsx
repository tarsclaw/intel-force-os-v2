import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import Link from 'next/link';
import { UserButton } from '@clerk/nextjs';
import { LayoutDashboard, Building2, Activity, Settings2, Shield } from 'lucide-react';

const adminNav = [
  { label: 'Overview', href: '/admin', icon: LayoutDashboard },
  { label: 'Tenants', href: '/admin/tenants', icon: Building2 },
  { label: 'Activity', href: '/admin/activity', icon: Activity },
  { label: 'System', href: '/admin/system', icon: Settings2 },
];

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');
  // In production: check platform_admin role

  return (
    <div className="min-h-screen bg-canvas">
      <aside className="fixed inset-y-0 left-0 w-56 flex flex-col border-r border-border bg-surface z-10">
        <div className="h-14 flex items-center gap-2 px-4 border-b border-border">
          <div className="w-7 h-7 rounded-md bg-brand-emerald flex items-center justify-center shrink-0">
            <span className="text-[10px] font-bold text-canvas">IF</span>
          </div>
          <span className="text-text-primary font-semibold text-sm truncate">Intel Force OS</span>
        </div>

        <div className="px-4 py-2 border-b border-border flex items-center gap-1.5">
          <Shield className="w-3 h-3 text-brand-amber" />
          <p className="text-xs text-brand-amber font-medium">Platform Admin</p>
        </div>

        <nav className="flex-1 overflow-y-auto py-2">
          {adminNav.map(({ label, href, icon: Icon }) => (
            <Link
              key={label}
              href={href}
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
