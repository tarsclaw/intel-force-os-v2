import Link from 'next/link';
import { Search } from 'lucide-react';

// 404 within a tenant segment — usually means a wrong slug, deleted tenant,
// or a typo in a deep link.
export default function TenantNotFound() {
  return (
    <div className="flex items-center justify-center min-h-[60vh] px-4">
      <div className="max-w-md text-center">
        <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-white/[0.04] ring-1 ring-white/10 grid place-items-center">
          <Search className="w-5 h-5 text-text-muted" />
        </div>
        <h2 className="font-display text-xl font-light text-text-primary mb-2">
          We couldn't find that
        </h2>
        <p className="text-sm text-text-muted leading-relaxed mb-6">
          The tenant or page you're looking for doesn't exist or has been moved.
        </p>
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm font-medium px-4 py-2 rounded-lg bg-emerald-400 text-emerald-950 hover:bg-emerald-300 transition-colors"
        >
          Back to dashboard
        </Link>
      </div>
    </div>
  );
}
