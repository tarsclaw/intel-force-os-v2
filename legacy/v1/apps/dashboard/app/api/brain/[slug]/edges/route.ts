import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { db } from '@intelforce/db';
import { requireTenantAccess } from '@/lib/tenant-access';

// Canonical edge key: sort the two node IDs so {s,t} and {t,s} share a key.
function edgeKey(a: string, b: string): string {
  return a < b ? `${a}|${b}` : `${b}|${a}`;
}

// ─── GET ─────────────────────────────────────────────────────────────────────
// Returns all reviews for this tenant's brain graph.
// Used by the BrainMap to render approve/reject state on the Surprises tab.
export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug } = await params;
  const access = await requireTenantAccess(slug);
  if (!access.ok) return access.response;

  const brain = await db.brainGraph.findUnique({
    where: { tenantId: access.tenant.id },
    select: { id: true },
  });
  if (!brain) return NextResponse.json({ reviews: [] });

  const reviews = await db.brainEdgeReview.findMany({
    where: { brainGraphId: brain.id },
    select: {
      edgeKey: true,
      decision: true,
      reviewerNote: true,
      reviewedAt: true,
    },
  });

  return NextResponse.json({ reviews });
}

// ─── POST ────────────────────────────────────────────────────────────────────
// Persist an approve/reject decision on an inferred edge.
// Body: { sourceNodeId, targetNodeId, relation, decision: 'APPROVED'|'REJECTED'|'UNCERTAIN', note? }
//
// Idempotent: re-posting on the same edge updates the prior decision.
const Body = z.object({
  sourceNodeId: z.string().min(1).max(200),
  targetNodeId: z.string().min(1).max(200),
  relation: z.string().min(1).max(80),
  decision: z.enum(['APPROVED', 'REJECTED', 'UNCERTAIN']),
  note: z.string().max(2000).optional(),
});

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug } = await params;
  const access = await requireTenantAccess(slug);
  if (!access.ok) return access.response;
  const { tenant, userId } = access;

  let body;
  try {
    body = Body.parse(await req.json());
  } catch (e) {
    return NextResponse.json({ error: 'Invalid request body' }, { status: 400 });
  }

  const brain = await db.brainGraph.findUnique({
    where: { tenantId: tenant.id },
    select: { id: true },
  });
  if (!brain) {
    return NextResponse.json(
      { error: 'No brain graph for this tenant. Complete the wizard first.' },
      { status: 404 },
    );
  }

  // Look up the dashboard's User row from the Clerk user id
  const user = await db.user.findUnique({
    where: { clerkUserId: userId },
    select: { id: true },
  });

  const ek = edgeKey(body.sourceNodeId, body.targetNodeId);

  const review = await db.brainEdgeReview.upsert({
    where: { brainGraphId_edgeKey: { brainGraphId: brain.id, edgeKey: ek } },
    create: {
      brainGraphId: brain.id,
      edgeKey: ek,
      sourceNodeId: body.sourceNodeId,
      targetNodeId: body.targetNodeId,
      relation: body.relation,
      decision: body.decision,
      reviewerId: user?.id,
      reviewerNote: body.note,
    },
    update: {
      decision: body.decision,
      reviewerId: user?.id,
      reviewerNote: body.note,
      reviewedAt: new Date(),
    },
  });

  // Audit trail — every brain edit is logged so a customer can prove who did what
  await db.auditEvent.create({
    data: {
      tenantId: tenant.id,
      actorKind: 'USER',
      action: 'brain.edge.review',
      targetKind: 'brain_edge',
      targetId: ek,
      targetLabel: `${body.sourceNodeId} → ${body.targetNodeId}`,
      detail: `${body.decision}${body.note ? `: ${body.note}` : ''}`,
      severity: 'INFO',
    },
  });

  return NextResponse.json({
    edgeKey: ek,
    decision: review.decision,
    reviewedAt: review.reviewedAt,
  });
}
