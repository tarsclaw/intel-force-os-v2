import { NextRequest, NextResponse } from 'next/server';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { db } from '@intelforce/db';
import { requireTenantAccess } from '@/lib/tenant-access';

// GET /api/brain/[slug]/graph
//
// Returns the tenant's brain graph from `ops.brain_graphs`.
// Falls back to the demo graph in `public/brain-demo/graph.json` when:
//   - the tenant has no BrainGraph row yet (e.g. wizard never finished), or
//   - the row exists but status is PENDING / BUILDING / FAILED.
//
// The fallback shape is identical to a real graph, so the client-side
// BrainMap renders the same way regardless of source. The page banner tells
// the user when they're looking at demo data vs their own brain.
export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug } = await params;
  const access = await requireTenantAccess(slug);
  if (!access.ok) return access.response;

  const { tenant } = access;

  // Try to load the tenant's brain graph
  const brain = await db.brainGraph.findUnique({
    where: { tenantId: tenant.id },
    select: {
      status: true,
      graphJson: true,
      nodeCount: true,
      edgeCount: true,
      generatedAt: true,
      version: true,
    },
  });

  if (brain && brain.status === 'READY' && brain.graphJson) {
    return NextResponse.json(
      {
        ...(brain.graphJson as Record<string, unknown>),
        _meta: {
          source: 'tenant',
          status: brain.status,
          version: brain.version,
          generatedAt: brain.generatedAt,
          nodeCount: brain.nodeCount,
          edgeCount: brain.edgeCount,
        },
      },
      { headers: { 'Cache-Control': 'private, max-age=60' } },
    );
  }

  // Fallback to demo graph — read from public/brain-demo/graph.json
  try {
    const file = path.join(process.cwd(), 'public', 'brain-demo', 'graph.json');
    const buf = await readFile(file, 'utf-8');
    const demo = JSON.parse(buf);
    return NextResponse.json(
      {
        ...demo,
        _meta: {
          source: 'demo',
          status: brain?.status ?? 'PENDING',
          // surface the build state so the UI can show e.g. "Building your brain…"
        },
      },
      { headers: { 'Cache-Control': 'private, max-age=60' } },
    );
  } catch {
    return NextResponse.json({
      nodes: [],
      edges: [],
      communities: {},
      _meta: { source: 'empty', status: brain?.status ?? 'PENDING' },
    });
  }
}
