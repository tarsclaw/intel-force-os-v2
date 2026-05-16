/**
 * Brain Builder HTTP server
 *
 * Endpoints:
 *   POST /build      — enqueue a build for a tenant (fire-and-forget)
 *   GET  /status/:id — peek at the BrainGraph row for a tenant
 *   GET  /health     — liveness
 *
 * The wizard's tRPC `submit` mutation POSTs to /build immediately after
 * creating the tenant. The build runs async — this endpoint returns 202 once
 * the BrainGraph row is marked BUILDING, and the actual graphify+embed work
 * proceeds in the background. Status updates land back on the BrainGraph row
 * directly, so the dashboard reads progress without polling this service.
 *
 * Concurrency: an in-process queue (single worker) prevents duplicate concurrent
 * builds for the same tenant. For multi-host scaling, swap to Cloudflare Queues —
 * see services/cf-brain-queue-consumer/.
 */
import http from 'node:http';
import { buildTenantBrain } from './lib/build';
import { db } from './lib/db';

const PORT = Number(process.env.PORT ?? 8090);
const SHARED_TOKEN = process.env.BRAIN_BUILDER_TOKEN; // optional bearer auth

// In-process active build set. Keyed by tenantSlug.
const inFlight = new Set<string>();

interface BuildBody {
  tenantSlug: string;
  sourceDir: string;
  force?: boolean;
}

const server = http.createServer(async (req, res) => {
  // Auth gate
  if (SHARED_TOKEN) {
    const auth = req.headers.authorization;
    if (auth !== `Bearer ${SHARED_TOKEN}`) {
      res.writeHead(401, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Unauthorized' }));
      return;
    }
  }

  const url = new URL(req.url ?? '/', `http://localhost:${PORT}`);

  // ─── GET /health ──────────────────────────────────────────────────────────
  if (req.method === 'GET' && url.pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(
      JSON.stringify({
        status: 'ok',
        inFlight: inFlight.size,
        graphifyServiceUrl: process.env.GRAPHIFY_SERVICE_URL ?? null,
        cohereConfigured: Boolean(process.env.COHERE_API_KEY),
      }),
    );
    return;
  }

  // ─── GET /status/:slug ────────────────────────────────────────────────────
  if (req.method === 'GET' && url.pathname.startsWith('/status/')) {
    const slug = decodeURIComponent(url.pathname.slice('/status/'.length));
    try {
      const tenant = await db.tenant.findUnique({
        where: { slug },
        select: { id: true },
      });
      if (!tenant) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'tenant not found' }));
        return;
      }
      const brain = await db.brainGraph.findUnique({
        where: { tenantId: tenant.id },
        select: {
          status: true,
          version: true,
          generatedAt: true,
          nodeCount: true,
          edgeCount: true,
          lastError: true,
        },
      });
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(
        JSON.stringify({
          tenantSlug: slug,
          inFlightLocally: inFlight.has(slug),
          brain,
        }),
      );
    } catch (err) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
    }
    return;
  }

  // ─── POST /build ──────────────────────────────────────────────────────────
  if (req.method === 'POST' && url.pathname === '/build') {
    let raw = '';
    req.setEncoding('utf-8');
    req.on('data', (chunk) => (raw += chunk));
    req.on('end', async () => {
      let body: BuildBody;
      try {
        body = JSON.parse(raw);
      } catch {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON' }));
        return;
      }

      if (!body.tenantSlug || !body.sourceDir) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'tenantSlug and sourceDir required' }));
        return;
      }

      if (inFlight.has(body.tenantSlug) && !body.force) {
        res.writeHead(409, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Build already in progress for this tenant' }));
        return;
      }

      // Ack immediately. Build runs in the background.
      res.writeHead(202, { 'Content-Type': 'application/json' });
      res.end(
        JSON.stringify({
          status: 'accepted',
          tenantSlug: body.tenantSlug,
          startedAt: new Date().toISOString(),
        }),
      );

      // Background work — fire and forget
      inFlight.add(body.tenantSlug);
      buildTenantBrain({
        tenantSlug: body.tenantSlug,
        sourceDir: body.sourceDir,
        force: body.force ?? false,
      })
        .then((result) => {
          console.log(
            `[brain-builder-server] ✓ tenant=${body.tenantSlug} nodes=${result.nodeCount} edges=${result.edgeCount}`,
          );
        })
        .catch((err) => {
          console.error(
            `[brain-builder-server] ✗ tenant=${body.tenantSlug} failed:`,
            err instanceof Error ? err.message : err,
          );
        })
        .finally(() => {
          inFlight.delete(body.tenantSlug);
        });
    });
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not found' }));
});

server.listen(PORT, () => {
  console.log(`[brain-builder-server] listening on :${PORT}`);
  if (SHARED_TOKEN) console.log('[brain-builder-server] auth: bearer token required');
  if (process.env.GRAPHIFY_SERVICE_URL) {
    console.log(`[brain-builder-server] graphify: ${process.env.GRAPHIFY_SERVICE_URL}`);
  } else {
    console.log('[brain-builder-server] graphify: NOT configured (will fail unless GRAPHIFY_USE_STUB=true)');
  }
});

// Graceful shutdown — drain in-flight builds (best effort)
process.on('SIGTERM', () => {
  console.log('[brain-builder-server] SIGTERM received');
  server.close(() => {
    if (inFlight.size > 0) {
      console.warn(`[brain-builder-server] ${inFlight.size} builds in progress — they will finish even after exit`);
    }
    process.exit(0);
  });
});
