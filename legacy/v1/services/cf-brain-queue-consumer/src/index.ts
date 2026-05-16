/**
 * Cloudflare Queue consumer for brain-build messages.
 *
 * The wizard's tRPC submit handler pushes a message of shape
 *   { type: 'brain.build', payload: { tenantSlug, sourceDir } }
 * onto the `brain-build` queue. This Worker drains the queue and forwards
 * each job to brain-builder-server's POST /build endpoint.
 *
 * Why a queue at all?
 *   - Wizard submission shouldn't block on brain build. Queue gives durable
 *     fire-and-forget without coupling the dashboard to brain-builder uptime.
 *   - Cloudflare Queues handle retry + DLQ for free. If brain-builder is
 *     temporarily unreachable (deploy, restart), messages back off and retry
 *     instead of being lost.
 *   - Multi-region brain-builder fanout becomes a queue-binding change rather
 *     than a code change.
 *
 * The consumer is intentionally thin — all business logic lives in
 * brain-builder. This is just durable transport.
 */

interface Env {
  BRAIN_BUILDER_URL: string;
  BRAIN_BUILDER_TOKEN?: string; // optional bearer auth
  BRAIN_QUEUE: Queue<BrainBuildMessage>;
}

interface BrainBuildMessage {
  type: 'brain.build';
  payload: {
    tenantSlug: string;
    sourceDir: string;
    force?: boolean;
  };
}

export default {
  /**
   * HTTP path: lets the wizard producer use this Worker as the
   * CF_BRAIN_QUEUE_URL endpoint. Validates auth + shape, then sends to queue.
   */
  async fetch(req: Request, env: Env): Promise<Response> {
    if (req.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    if (env.BRAIN_BUILDER_TOKEN) {
      const auth = req.headers.get('Authorization');
      if (auth !== `Bearer ${env.BRAIN_BUILDER_TOKEN}`) {
        return new Response('Unauthorized', { status: 401 });
      }
    }

    let body: BrainBuildMessage;
    try {
      body = (await req.json()) as BrainBuildMessage;
    } catch {
      return new Response('Invalid JSON', { status: 400 });
    }

    if (body?.type !== 'brain.build' || !body.payload?.tenantSlug) {
      return new Response('Invalid message shape', { status: 400 });
    }

    await env.BRAIN_QUEUE.send(body);

    return new Response(
      JSON.stringify({
        status: 'queued',
        tenantSlug: body.payload.tenantSlug,
      }),
      { status: 202, headers: { 'Content-Type': 'application/json' } },
    );
  },

  /**
   * Queue consumer: drains messages and forwards to brain-builder-server.
   * On failure, throws so Cloudflare retries the batch (up to max_retries
   * configured in wrangler.toml). After that the messages flow to the DLQ.
   */
  async queue(batch: MessageBatch<BrainBuildMessage>, env: Env): Promise<void> {
    for (const msg of batch.messages) {
      try {
        if (msg.body.type !== 'brain.build') {
          msg.ack(); // unknown types — don't retry, but log
          console.warn(`[cf-brain-queue] unknown message type, dropping: ${JSON.stringify(msg.body)}`);
          continue;
        }

        const r = await fetch(`${env.BRAIN_BUILDER_URL.replace(/\/$/, '')}/build`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            ...(env.BRAIN_BUILDER_TOKEN
              ? { Authorization: `Bearer ${env.BRAIN_BUILDER_TOKEN}` }
              : {}),
          },
          body: JSON.stringify(msg.body.payload),
        });

        if (r.status === 409) {
          // Build already in progress — ack and don't retry, brain-builder
          // is doing the right thing.
          console.log(
            `[cf-brain-queue] tenant=${msg.body.payload.tenantSlug} already building, ack`,
          );
          msg.ack();
          continue;
        }

        if (!r.ok && r.status !== 202) {
          // Retryable failure — let CF queue retry this message
          throw new Error(`brain-builder returned ${r.status}`);
        }

        msg.ack();
      } catch (err) {
        console.error(
          `[cf-brain-queue] failed for tenant=${msg.body.payload.tenantSlug}:`,
          err instanceof Error ? err.message : err,
        );
        msg.retry({ delaySeconds: 30 }); // exponential-ish backoff via CF
      }
    }
  },
};
