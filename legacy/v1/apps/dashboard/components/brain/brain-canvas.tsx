'use client';

import { BrainMap } from '@/components/brain/BrainMap.lazy';
import { useSidebar } from '@/components/shared/sidebar-context';
import { cn } from '@/lib/cn';

export function BrainCanvas({ slug }: { slug: string }) {
  const { collapsed } = useSidebar();
  return (
    <div
      className={cn(
        'fixed inset-0 left-0 bottom-20 lg:bottom-0 bg-[rgb(7,9,11)] transition-[left] duration-200 ease-out',
        collapsed ? 'lg:left-14' : 'lg:left-56',
      )}
    >
      <BrainMap slug={slug} />
    </div>
  );
}
