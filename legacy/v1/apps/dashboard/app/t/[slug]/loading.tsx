// Default loading state for any tenant page during streaming SSR.
// Individual pages can still ship their own loading.tsx in deeper segments
// to override this. Mirrors the page header + skeleton block layout that
// almost every page uses.
export default function TenantLoading() {
  return (
    <div className="space-y-6 animate-pulse">
      {/* Page header skeleton */}
      <div>
        <div className="h-7 w-48 rounded-md bg-white/[0.04] mb-3" />
        <div className="h-4 w-72 rounded-md bg-white/[0.03]" />
      </div>

      {/* KPI strip skeleton */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div
            key={i}
            className="bg-[rgb(var(--bg-surface))] rounded-2xl ring-1 ring-white/5 p-5"
          >
            <div className="h-2 w-16 rounded bg-white/[0.05] mb-4" />
            <div className="h-8 w-20 rounded bg-white/[0.05] mb-3" />
            <div className="h-2 w-24 rounded bg-white/[0.04]" />
          </div>
        ))}
      </div>

      {/* Body skeleton */}
      <div className="bg-[rgb(var(--bg-surface))] rounded-2xl ring-1 ring-white/5 p-5">
        <div className="h-5 w-40 rounded bg-white/[0.05] mb-4" />
        <div className="space-y-2">
          <div className="h-3 w-full rounded bg-white/[0.04]" />
          <div className="h-3 w-5/6 rounded bg-white/[0.04]" />
          <div className="h-3 w-3/4 rounded bg-white/[0.04]" />
        </div>
      </div>
    </div>
  );
}
