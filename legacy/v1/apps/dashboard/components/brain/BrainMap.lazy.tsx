'use client';

// Dynamic-import wrapper for BrainMap.
//
// BrainMap is heavy: ~30KB of compiled component code, plus it pulls in the
// 313KB demo graph.json on mount. By dynamic-importing it we keep that weight
// out of every other tenant page (Overview, Approvals, etc.) and only fetch it
// when the user actually navigates to /t/[slug]/brain.
//
// `ssr: false` because the canvas and force simulation are browser-only.
import dynamic from 'next/dynamic';
import { Sparkles } from 'lucide-react';

const BrainMap = dynamic(() => import('./BrainMap').then((m) => ({ default: m.BrainMap })), {
  ssr: false,
  loading: () => <BrainMapLoading />,
});

function BrainMapLoading() {
  return (
    <div className="h-full w-full grid place-items-center bg-[rgb(7,9,11)]">
      <div className="text-center">
        <div className="relative w-16 h-16 mx-auto mb-4">
          <div className="absolute inset-0 rounded-full bg-emerald-400/20 animate-ping" />
          <div className="absolute inset-2 rounded-full bg-emerald-400/40 animate-pulse" />
          <Sparkles className="absolute inset-0 m-auto w-6 h-6 text-emerald-300" />
        </div>
        <p className="text-sm text-zinc-300 font-medium">Loading the brain…</p>
        <p className="text-xs text-zinc-500 mt-1">Initialising canvas + force layout</p>
      </div>
    </div>
  );
}

export { BrainMap };
