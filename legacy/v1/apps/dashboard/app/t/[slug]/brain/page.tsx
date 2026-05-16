import { auth } from '@clerk/nextjs/server';
import { redirect, notFound } from 'next/navigation';
import { db } from '@intelforce/db';
import { BrainCanvas } from '@/components/brain/brain-canvas';
import { BrainChatBar } from '@/components/brain/brain-chat-bar';

export const metadata = { title: 'Brain Map · Intel Force OS' };

// Brain Map needs the full viewport (minus sidebar) — it deliberately escapes
// the layout's max-w-7xl content container. The canvas tracks the dynamic
// sidebar width via the SidebarProvider.
export default async function BrainPage({ params }: { params: Promise<{ slug: string }> }) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  const tenant = await db.tenant.findUnique({
    where: { slug },
    select: { id: true, name: true, status: true },
  });
  if (!tenant) notFound();

  return (
    <>
      {/* Tooltip styles — scoped to the brain canvas */}
      <style>{`
        .brain-tooltip {
          position: fixed;
          display: none;
          pointer-events: none;
          padding: 6px 10px;
          background: rgba(15, 17, 20, 0.96);
          border: 1px solid rgba(255, 255, 255, 0.14);
          border-radius: 6px;
          font-size: 12px;
          color: #fafafa;
          z-index: 50;
          white-space: nowrap;
          max-width: 320px;
          overflow: hidden;
          text-overflow: ellipsis;
          box-shadow: 0 6px 16px rgba(0, 0, 0, 0.4);
        }
      `}</style>

      {/* Full-bleed canvas brain. The graph data is the same Obsidian-compatible
          vault that sub-agents query via /graphify — one source of truth. */}
      <BrainCanvas slug={slug} />

      {/* Brain-only: floating chat bar so customers can query their handbook
          without leaving the canvas. Other tenant pages don't get the bar —
          this is a brain-specific affordance. */}
      <BrainChatBar slug={slug} />

      {/* Spacer so the layout's container reserves vertical space and scroll
          containers behave. The fixed element renders above this. */}
      <div className="h-[calc(100vh-3.5rem)] lg:h-screen" aria-hidden="true" />
    </>
  );
}
