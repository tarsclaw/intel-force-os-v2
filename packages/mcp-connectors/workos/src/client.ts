// WorkOS HTTP client — wraps fetch with: Bearer-secret-key attach, per-org_id
// rate-limit budget, 429 retry-after, 5xx exponential backoff, typed errors.
// NOTE: NO 401-force-refresh path — distinct from Bullhorn/Xero/QB clients.
// WorkOS uses a long-lived secret key with NO refresh dance; a 401 means the
// key has been rotated/revoked in the WorkOS dashboard and the env-var must
// be updated + the process restarted. No retry on 401 — surface immediately
// as WorkosAuthError so the consumer can degrade gracefully.

import {
  WorkosAuthError,
  WorkosError,
  WorkosNotFoundError,
  WorkosRateLimitError,
  WorkosValidationError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import type { WorkosClientOptions } from "./types.js";

export const DEFAULT_TIMEOUT_MS = 15_000;
export const DEFAULT_BASE_URL = "https://api.workos.com";

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "DELETE";
  query?: Record<string, string>;
  body?: unknown;
  /** Override max retries for this call (default 2 for GET, 0 for writes). */
  max_retries?: number;
  /** Caller-supplied AbortSignal. */
  signal?: AbortSignal;
  /** Override per-call org_id for rate-limit bucketing — typically derived
   *  from the path's organization_id segment. Defaults to "global" if not
   *  set, matching read-paths that aren't org-scoped (e.g. /organizations). */
  org_id?: string;
}

/** Sleep `ms` milliseconds. */
function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

/** Full-jitter exponential backoff. */
function backoff(attempt: number): number {
  const base = 250 * 2 ** attempt; // 250, 500, 1000, 2000 ms
  return Math.floor(Math.random() * base);
}

export class WorkosClient {
  private readonly opts: WorkosClientOptions;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private readonly baseUrl: string;

  constructor(opts: WorkosClientOptions) {
    this.opts = opts;
    this.fetchFn = opts.fetchFn ?? fetch;
    this.now = opts.now ?? Date.now;
    this.baseUrl = (opts.config.base_url ?? DEFAULT_BASE_URL).replace(/\/$/, "");
  }

  /** Public: low-level call. Most callers use the capability helpers
   *  (organizations / connections / directorySync). */
  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    const method = options.method ?? "GET";
    const isWrite = method !== "GET";
    const max_retries = options.max_retries ?? (isWrite ? 0 : 2);
    const rateOrg = options.org_id ?? "global";

    let last_error: unknown = null;
    for (let attempt = 0; attempt <= max_retries; attempt++) {
      // Pre-emptive rate-limit check (per-org_id bucket; "global" for org-list
      // and similar top-level endpoints)
      const allowed = consume(rateOrg, this.now);
      if (!allowed) {
        throw new WorkosRateLimitError(
          `WorkOS rate-limit budget exhausted (org=${rateOrg}); ` +
            `local bucket prevents call to avoid upstream 429`,
        );
      }

      const url = new URL(this.baseUrl + path);
      if (options.query) {
        for (const [k, v] of Object.entries(options.query)) {
          url.searchParams.set(k, v);
        }
      }
      const headers: Record<string, string> = {
        Authorization: `Bearer ${this.opts.config.secret_key}`,
        Accept: "application/json",
      };
      if (options.body !== undefined) {
        headers["Content-Type"] = "application/json";
      }

      let res: Response;
      try {
        res = await this.fetchFn(url.toString(), {
          method,
          headers,
          body: options.body !== undefined ? JSON.stringify(options.body) : undefined,
          signal: options.signal,
        });
      } catch (e) {
        // Network error — retry up to max_retries (only for GET; writes don't retry)
        last_error = e;
        if (attempt < max_retries) {
          await sleep(backoff(attempt));
          continue;
        }
        throw new WorkosError(
          `WorkOS network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
        );
      }

      // 200-299 happy path
      if (res.ok) {
        return (await res.json()) as T;
      }

      // 401: secret_key invalid/revoked. NO refresh path. Surface immediately;
      // do NOT retry (a retry would just 401 again with the same dead key).
      if (res.status === 401) {
        throw new WorkosAuthError(
          `WorkOS ${method} ${path} returned 401 — secret key invalid or revoked. ` +
            `Rotate via WorkOS dashboard, update env-var, restart process.`,
          401,
        );
      }

      // 429: rate-limited; honour Retry-After then retry (GET only)
      if (res.status === 429 && attempt < max_retries) {
        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
        await sleep(waitMs);
        continue;
      }
      if (res.status === 429) {
        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
        throw new WorkosRateLimitError(
          `WorkOS returned 429 after ${attempt + 1} attempt(s)`,
          retryAfter > 0 ? retryAfter : null,
        );
      }

      // 5xx: retry with backoff (GET only)
      if (res.status >= 500 && attempt < max_retries) {
        await sleep(backoff(attempt));
        continue;
      }

      // 4xx (non-401/429): typed error, no retry
      const safeBody = await res.text().catch(() => "");
      if (res.status === 404) {
        throw new WorkosNotFoundError(`WorkOS 404 on ${method} ${path}`);
      }
      if (res.status === 422 || res.status === 400) {
        throw new WorkosValidationError(
          `WorkOS rejected ${method} ${path} (HTTP ${res.status})`,
          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
        );
      }
      throw new WorkosError(
        `WorkOS ${method} ${path} failed (HTTP ${res.status})`,
        res.status,
      );
    }
    throw new WorkosError(
      `WorkOS ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
    );
  }
}
