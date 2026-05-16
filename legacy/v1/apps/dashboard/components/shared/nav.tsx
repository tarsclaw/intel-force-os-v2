'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { UserButton } from '@clerk/nextjs';
import {
  LayoutDashboard,
  CheckCircle2,
  Network,
  ListTree,
  BarChart3,
  BookOpen,
  Sparkles,
  Settings,
  ChevronDown,
  Command,
  Zap,
  PanelLeftClose,
  PanelLeftOpen,
} from 'lucide-react';
import { cn } from '@/lib/cn';
import { useSidebar } from './sidebar-context';

interface NavProps {
  slug: string;
  tenantName: string;
  tenantPlan: string;
  pendingCount: number;
}

const mainNav = [
  { label: 'Overview', href: '', icon: LayoutDashboard },
  { label: 'Approvals', href: '/approvals', icon: CheckCircle2, badge: true },
  { label: 'Agents', href: '/agents', icon: Network },
  { label: 'Activity', href: '/activity', icon: ListTree },
  { label: 'Analytics', href: '/analytics', icon: BarChart3 },
  { label: 'Knowledge', href: '/knowledge', icon: BookOpen },
  { label: 'Brain Map', href: '/brain', icon: Sparkles },
];

const secondaryNav = [{ label: 'Settings', href: '/settings', icon: Settings }];

// Mobile bottom bar — 5 most critical items
const mobileNav = [
  { label: 'Overview', href: '', icon: LayoutDashboard },
  { label: 'Approvals', href: '/approvals', icon: CheckCircle2, badge: true },
  { label: 'Agents', href: '/agents', icon: Network },
  { label: 'Activity', href: '/activity', icon: ListTree },
  { label: 'Settings', href: '/settings', icon: Settings },
];

const planLabels: Record<string, string> = {
  FOUNDING: 'Founding',
  STARTER: 'Starter',
  GROWTH: 'Growth',
  SCALE: 'Scale',
  ENTERPRISE: 'Enterprise',
  AGENCY_PARTNER: 'Agency',
};

export function TenantNav({ slug, tenantName, tenantPlan, pendingCount }: NavProps) {
  const pathname = usePathname();
  const base = `/t/${slug}`;
  const { collapsed, toggle } = useSidebar();

  function isActive(href: string): boolean {
    const full = `${base}${href}`;
    return href === '' ? pathname === base || pathname === `${base}/` : pathname.startsWith(full);
  }

  function navItem(
    label: string,
    href: string,
    Icon: React.ElementType,
    badge?: boolean,
  ) {
    const active = isActive(href);
    return (
      <Link
        key={label}
        href={`${base}${href}`}
        aria-label={label}
        title={collapsed ? label : undefined}
        aria-current={active ? 'page' : undefined}
        className={cn(
          'group relative flex items-center gap-2.5 rounded-lg text-sm transition-all',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400/50 focus-visible:ring-offset-1 focus-visible:ring-offset-[rgb(var(--bg-surface))]',
          collapsed ? 'justify-center px-2.5 py-2.5' : 'px-2.5 py-2',
          active
            ? 'bg-emerald-400/[0.08] text-text-primary'
            : 'text-text-secondary hover:text-text-primary hover:bg-white/[0.03]',
        )}
      >
        {active && !collapsed && (
          <span className="absolute left-0 top-1/2 -translate-y-1/2 w-0.5 h-4 bg-emerald-400 rounded-r-full" />
        )}
        <Icon
          className={cn(
            'shrink-0 w-4 h-4',
            active ? 'text-emerald-400' : 'text-text-muted group-hover:text-text-secondary',
          )}
          aria-hidden="true"
        />
        {!collapsed && <span className="truncate">{label}</span>}
        {badge && pendingCount > 0 && (
          <>
            {!collapsed && (
              <span className="ml-auto flex items-center justify-center min-w-[20px] h-5 px-1.5 rounded-full text-[10px] font-medium bg-amber-400/20 text-amber-300">
                {pendingCount > 99 ? '99+' : pendingCount}
              </span>
            )}
            {collapsed && (
              <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 rounded-full bg-amber-400" />
            )}
          </>
        )}
      </Link>
    );
  }

  return (
    <>
      {/* ── Desktop / tablet sidebar ──────────────────────────── */}
      <aside
        data-collapsed={collapsed ? 'true' : 'false'}
        className={cn(
          'fixed inset-y-0 left-0 z-20 hidden lg:flex flex-col border-r border-white/5 bg-[rgb(var(--bg-surface))] transition-[width] duration-200 ease-out',
          collapsed ? 'w-14' : 'w-56',
        )}
      >
        {/* Logo */}
        <div
          className={cn(
            'h-14 flex items-center gap-2.5 border-b border-white/5 shrink-0',
            collapsed ? 'px-3 justify-center' : 'px-4',
          )}
        >
          <div className="w-7 h-7 rounded-md bg-gradient-to-br from-emerald-400 to-emerald-600 flex items-center justify-center shrink-0">
            <Command className="w-3.5 h-3.5 text-emerald-950" strokeWidth={2.5} />
          </div>
          {!collapsed && (
            <span className="font-display text-sm text-text-primary font-medium tracking-tight truncate">
              IntelForce<span className="text-emerald-400">.</span>OS
            </span>
          )}
          {!collapsed && (
            <button
              type="button"
              onClick={toggle}
              aria-label="Collapse sidebar"
              title="Collapse sidebar"
              className="ml-auto p-1 rounded-md text-text-muted hover:text-text-primary hover:bg-white/[0.05] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400/50"
            >
              <PanelLeftClose className="w-4 h-4" aria-hidden="true" />
            </button>
          )}
        </div>

        {collapsed && (
          <div className="flex justify-center pt-2 shrink-0">
            <button
              type="button"
              onClick={toggle}
              aria-label="Expand sidebar"
              title="Expand sidebar"
              className="p-1.5 rounded-md text-text-muted hover:text-text-primary hover:bg-white/[0.05] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400/50"
            >
              <PanelLeftOpen className="w-4 h-4" aria-hidden="true" />
            </button>
          </div>
        )}

        {/* Tenant chip */}
        <button
          className={cn(
            'flex items-center gap-2 py-3 border-b border-white/5 hover:bg-white/[0.02] transition-colors text-left w-full shrink-0',
            collapsed ? 'px-3 justify-center' : 'px-4',
          )}
          title={collapsed ? tenantName : undefined}
          aria-label={collapsed ? `Tenant: ${tenantName}` : undefined}
        >
          <div className="w-5 h-5 rounded-sm bg-emerald-400/15 flex items-center justify-center shrink-0">
            <Zap className="w-2.5 h-2.5 text-emerald-400" />
          </div>
          {!collapsed && (
            <>
              <span className="text-xs text-text-primary truncate flex-1">{tenantName}</span>
              <ChevronDown className="w-3 h-3 text-text-muted shrink-0" />
            </>
          )}
        </button>

        {/* Main nav */}
        <nav
          className={cn(
            'flex-1 overflow-y-auto py-2 space-y-0.5',
            collapsed ? 'px-1.5' : 'px-2',
          )}
        >
          {mainNav.map(({ label, href, icon: Icon, badge }) =>
            navItem(label, href, Icon, badge),
          )}
          <div className="my-2 mx-1 border-t border-white/5" />
          {secondaryNav.map(({ label, href, icon: Icon }) => navItem(label, href, Icon))}
        </nav>

        {/* Plan + user */}
        <div
          className={cn(
            'border-t border-white/5 shrink-0 space-y-2',
            collapsed ? 'p-2' : 'p-3',
          )}
        >
          {!collapsed && (
            <div className="flex items-center gap-2 px-2 py-1.5 rounded-lg bg-emerald-400/[0.05] ring-1 ring-emerald-400/15">
              <div className="w-1.5 h-1.5 rounded-full bg-emerald-400 pulse-dot" />
              <span className="text-[11px] text-emerald-400 font-medium">
                {planLabels[tenantPlan] ?? tenantPlan} plan
              </span>
            </div>
          )}
          <div
            className={cn(
              'flex items-center gap-2.5',
              collapsed ? 'justify-center' : 'px-1',
            )}
          >
            <UserButton appearance={{ elements: { avatarBox: 'w-7 h-7' } }} />
            {!collapsed && <span className="text-xs text-text-muted truncate">Account</span>}
          </div>
        </div>
      </aside>

      {/* ── Mobile bottom tab bar ─────────────────────────────── */}
      <nav className="lg:hidden fixed bottom-0 inset-x-0 z-20 safe-area-pb bg-[rgb(var(--bg-surface))]/95 backdrop-blur-md border-t border-white/5 flex items-stretch">
        {mobileNav.map(({ label, href, icon: Icon, badge }) => {
          const active = isActive(href);
          return (
            <Link
              key={label}
              href={`${base}${href}`}
              className={cn(
                'flex-1 flex flex-col items-center gap-1 pt-2.5 pb-2 relative transition-colors',
                active ? 'text-emerald-400' : 'text-text-muted',
              )}
            >
              {active && (
                <span className="absolute top-0 left-1/2 -translate-x-1/2 w-8 h-0.5 bg-emerald-400 rounded-b-full" />
              )}
              <div className="relative">
                <Icon className="w-5 h-5" />
                {badge && pendingCount > 0 && (
                  <span className="absolute -top-1.5 -right-2 min-w-[16px] h-4 flex items-center justify-center rounded-full px-1 text-[9px] font-bold bg-amber-400 text-amber-950">
                    {pendingCount > 9 ? '9+' : pendingCount}
                  </span>
                )}
              </div>
              <span className="text-[10px] font-medium">{label}</span>
            </Link>
          );
        })}
      </nav>
    </>
  );
}
