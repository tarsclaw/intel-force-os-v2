'use client';

import { cn } from '@/lib/cn';
import { useSidebar } from './sidebar-context';

export function MainContent({ children }: { children: React.ReactNode }) {
  const { collapsed } = useSidebar();
  return (
    <main
      className={cn(
        'pl-0 pb-20 lg:pb-0 min-h-screen transition-[padding] duration-200 ease-out',
        collapsed ? 'lg:pl-14' : 'lg:pl-56',
      )}
    >
      <div className="max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8 py-5 sm:py-6">{children}</div>
    </main>
  );
}
