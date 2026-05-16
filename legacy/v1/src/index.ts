import { handleBotMessage, handleWebApproval } from './bot/handler';
import { sendWeeklyReports } from './bot/proactive';

export interface Env {
  TENANT_CONFIG: KVNamespace;
  AUDIT_DB: D1Database;
  MICROSOFT_APP_ID: string;
  MICROSOFT_APP_PASSWORD: string;
  ANTHROPIC_API_KEY: string;
  ANTHROPIC_MODEL: string;
  ENVIRONMENT: string;
  // Set via: wrangler secret put PORTAL_API_KEY
  // Used to authenticate web portal approval actions from the Next.js dashboard
  PORTAL_API_KEY?: string;
  // Optional — set via: wrangler secret put SENTRY_DSN
  SENTRY_DSN?: string;
  // Optional — enables dual-write to Postgres ops.* tables alongside D1
  // Set via: wrangler secret put POSTGRES_HTTP_URL
  POSTGRES_HTTP_URL?: string;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    try {
      const url = new URL(request.url);

      if (request.method === 'GET' && url.pathname === '/health') {
        return new Response(
          JSON.stringify({ status: 'ok', env: env.ENVIRONMENT, ts: Date.now() }),
          { status: 200, headers: { 'Content-Type': 'application/json' } },
        );
      }

      if (request.method === 'POST' && url.pathname === '/api/messages') {
        return handleBotMessage(request, env);
      }

      if (request.method === 'POST' && url.pathname === '/api/approve') {
        return handleWebApproval(request, env);
      }

      return new Response('Not Found', { status: 404 });
    } catch (err) {
      // Top-level catch — log and return 200 to prevent Teams from retrying a broken message
      console.error('unhandled_worker_error', {
        error: err instanceof Error ? err.message : 'unknown',
        stack: err instanceof Error ? err.stack?.slice(0, 500) : undefined,
        url: request.url,
      });
      reportToSentry(err, env, ctx);
      return new Response('Internal error', { status: 500 });
    }
  },

  async scheduled(
    _controller: ScheduledController,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<void> {
    try {
      await sendWeeklyReports(env, ctx);
    } catch (err) {
      console.error('scheduled_error', {
        error: err instanceof Error ? err.message : 'unknown',
      });
      reportToSentry(err, env, ctx);
    }
  },
};

// Minimal Sentry error reporting via fetch (avoids SDK bundle size in Workers)
// When SENTRY_DSN is set, unhandled errors are POSTed to Sentry's envelope endpoint.
// Replace with @sentry/cloudflare SDK once it stabilises.
function reportToSentry(
  err: unknown,
  env: Env,
  ctx: ExecutionContext,
): void {
  if (!env.SENTRY_DSN) return;

  const dsn = env.SENTRY_DSN;
  const message = err instanceof Error ? err.message : String(err);
  const stack = err instanceof Error ? (err.stack ?? '') : '';

  // Fire-and-forget — don't let Sentry reporting block or crash the Worker
  ctx.waitUntil(
    fetch(buildSentryUrl(dsn), {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-sentry-envelope' },
      body: buildSentryEnvelope(dsn, message, stack, env.ENVIRONMENT),
    }).catch(() => {
      // Sentry itself is down or DSN invalid — silent fail
    }),
  );
}

function buildSentryUrl(dsn: string): string {
  // DSN format: https://{key}@{host}/{project_id}
  const url = new URL(dsn);
  return `${url.protocol}//${url.host}/api${url.pathname}/envelope/`;
}

function buildSentryEnvelope(
  dsn: string,
  message: string,
  stack: string,
  environment: string,
): string {
  const eventId = crypto.randomUUID().replace(/-/g, '');
  const now = Math.floor(Date.now() / 1000);

  const header = JSON.stringify({ dsn, sent_at: new Date().toISOString() });
  const itemHeader = JSON.stringify({ type: 'event' });
  const event = JSON.stringify({
    event_id: eventId,
    timestamp: now,
    platform: 'javascript',
    environment,
    level: 'error',
    exception: {
      values: [
        {
          type: 'Error',
          value: message,
          stacktrace: {
            frames: stack
              .split('\n')
              .slice(1, 10)
              .map((line) => ({ filename: line.trim() })),
          },
        },
      ],
    },
  });

  return `${header}\n${itemHeader}\n${event}`;
}
