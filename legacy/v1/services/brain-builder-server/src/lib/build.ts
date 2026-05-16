import { db } from './db';
import { runGraphify, type GraphifyResult } from './graphify-runner';
import { collectSourceFiles } from './source-collector';
import { embedNodes } from './embed-nodes';

export interface BuildOptions {
  tenantSlug: string;
  sourceDir: string;
  /** If true, ingest a fresh build even if status is BUILDING (e.g. after a crash). */
  force?: boolean;
}

export interface BuildResult {
  nodeCount: number;
  edgeCount: number;
  communityCount: number;
  durationMs: number;
  costGbp: number;
}

/**
 * Build the brain for a single tenant. Idempotent — safe to call again on the
 * same tenant; it'll bump the version and replace the previous graph.
 *
 * Status transitions:
 *   PENDING/STALE → BUILDING → READY        (success)
 *   PENDING/STALE → BUILDING → FAILED       (graphify or DB error)
 *
 * If the tenant already has status=BUILDING and force is false, this throws
 * to prevent duplicate concurrent builds.
 */
export async function buildTenantBrain(opts: BuildOptions): Promise<BuildResult> {
  const start = Date.now();

  const tenant = await db.tenant.findUnique({
    where: { slug: opts.tenantSlug },
    select: { id: true, name: true },
  });
  if (!tenant) {
    throw new Error(`Tenant not found: ${opts.tenantSlug}`);
  }

  // Mark BUILDING (upserts because new tenants have no row yet)
  const existing = await db.brainGraph.findUnique({
    where: { tenantId: tenant.id },
    select: { status: true, version: true },
  });

  if (existing?.status === 'BUILDING' && !opts.force) {
    throw new Error('Brain build already in progress. Pass --force to override.');
  }

  await db.brainGraph.upsert({
    where: { tenantId: tenant.id },
    create: {
      tenantId: tenant.id,
      status: 'BUILDING',
      version: 1,
    },
    update: {
      status: 'BUILDING',
      lastError: null,
      version: { increment: 1 },
    },
  });

  try {
    const sources = await collectSourceFiles(opts.sourceDir);
    if (sources.length === 0) {
      throw new Error(`No source files found in ${opts.sourceDir}`);
    }

    const result = await runGraphify(sources, { tenantSlug: opts.tenantSlug });

    // Persist the graph first so even if embeddings fail, the brain is queryable.
    const brainGraph = await db.brainGraph.update({
      where: { tenantId: tenant.id },
      data: {
        status: 'READY',
        graphJson: result.graph as object,
        nodeCount: result.nodeCount,
        edgeCount: result.edgeCount,
        communityCount: result.communityCount,
        sourceFiles: sources.map((s) => ({
          name: s.name,
          sha256: s.sha256,
          size: s.size,
          ingestedAt: s.ingestedAt,
        })),
        generatedAt: new Date(),
        durationMs: Date.now() - start,
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
        costGbp: result.costGbp,
      },
      select: { id: true },
    });

    // Generate embeddings — best-effort. If COHERE_API_KEY isn't set or the
    // call fails, we still ship the graph; semantic search degrades to substring.
    try {
      await embedNodes(brainGraph.id, result.graph);
    } catch (err) {
      console.warn(
        '[brain-builder] embedding generation failed (graph still saved):',
        err instanceof Error ? err.message : err,
      );
    }

    const durationMs = Date.now() - start;

    return {
      nodeCount: result.nodeCount,
      edgeCount: result.edgeCount,
      communityCount: result.communityCount,
      durationMs,
      costGbp: result.costGbp,
    };
  } catch (err) {
    await db.brainGraph.update({
      where: { tenantId: tenant.id },
      data: {
        status: 'FAILED',
        lastError: err instanceof Error ? err.message : String(err),
      },
    });
    throw err;
  }
}

export { GraphifyResult };
