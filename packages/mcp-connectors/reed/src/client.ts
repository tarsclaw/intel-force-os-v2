// Reed HTTP client — wraps fetch with: Basic-auth attach (API key as
// username + empty password per reed.co.uk/developers/jobseeker WebFetch
// verification 2026-06-03), per-account_id rate-limit budget, 429
// retry-after, 5xx exponential backoff, typed errors. NO 401-force-refresh
// path — distinct from Bullhorn/Xero/QB clients. Reed uses a long-lived
// API key with NO refresh dance; a 401 means the key has been rotated/
// revoked in the Reed developer portal and the env-var must be updated +
// the process restarted. No retry on 401 — surface immediately as
// ReedAuthError so the consumer can degrade gracefully.

import {
  ReedAuthError,
  ReedError,
  ReedNotFoundError,
  ReedRateLimitError,
  ReedValidationError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import type { ReedClientOptions } from "./types.js";

export const DEFAULT_TIMEOUT_MS = 15_000;
export const DEFAULT_BASE_URL = "https://www.reed.co.uk/api";
export const DEFAULT_API_VERSION = "1.0";

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "DELETE";
  query?: Record<string, string>;
  body?: unknown;
  /** Override max retries for this call (default 2 for GET, 0 for writes). */
  max_retries?: number;
  /** Caller-supplied AbortSignal. */
  signal?: AbortSignal;
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

export class ReedClient {
  private readonly opts: ReedClientOptions;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private readonly baseUrl: string;
  private readonly apiVersion: string;
  private readonly basicAuthHeader: string;

  constructor(opts: ReedClientOptions) {
    this.opts = opts;
    this.fetchFn = opts.fetchFn ?? fetch;
    this.now = opts.now ?? Date.now;
    this.baseUrl = (opts.config.base_url ?? DEFAULT_BASE_URL).replace(/\/$/, "");
    this.apiVersion = opts.config.api_version ?? DEFAULT_API_VERSION;
    // Pre-compute Basic auth header (API key as username, EMPTY password).
    // Per reed.co.uk/developers/jobseeker: "include your api key for all
    // requests in a basic authentication http header as the username,
    // leaving the password empty."
    const credentials = `${opts.config.api_key}:`;
    this.basicAuthHeader = `Basic ${Buffer.from(credentials, "utf8").toString("base64")}`;
  }

  /** Public: low-level call. Most callers use the capability helpers
   *  (candidates / jobs). */
  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    const method = options.method ?? "GET";
    const isWrite = method !== "GET";
    const max_retries = options.max_retries ?? (isWrite ? 0 : 2);

    let last_error: unknown = null;
    for (let attempt = 0; attempt <= max_retries; attempt++) {
      // Pre-emptive rate-limit check (per-account_id bucket)
      const allowed = consume(this.opts.config.account_id, this.now);
      if (!allowed) {
        throw new ReedRateLimitError(
          `Reed rate-limit budget exhausted (account=${this.opts.config.account_id}); ` +
            `local bucket prevents call to avoid upstream 429`,
        );
      }

      // Construct full URL: <base>/<version>/<path>
      const url = new URL(`${this.baseUrl}/${this.apiVersion}${path}`);
      if (options.query) {
        for (const [k, v] of Object.entries(options.query)) {
          url.searchParams.set(k, v);
        }
      }
      const headers: Record<string, string> = {
        Authorization: this.basicAuthHeader,
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
        throw new ReedError(
          `Reed network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
        );
      }

      // 200-299 happy path
      if (res.ok) {
        return (await res.json()) as T;
      }

      // 401: API key invalid/revoked. NO refresh path. Surface immediately;
      // do NOT retry (a retry would just 401 again with the same dead key).
      if (res.status === 401) {
        throw new ReedAuthError(
          `Reed ${method} ${path} returned 401 — API key invalid or revoked. ` +
            `Rotate via Reed developer portal, update env-var, restart process.`,
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
        throw new ReedRateLimitError(
          `Reed returned 429 after ${attempt + 1} attempt(s)`,
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
        throw new ReedNotFoundError(`Reed 404 on ${method} ${path}`);
      }
      if (res.status === 400) {
        throw new ReedValidationError(
          `Reed rejected ${method} ${path} (HTTP 400)`,
          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
        );
      }
      throw new ReedError(
        `Reed ${method} ${path} failed (HTTP ${res.status})`,
        res.status,
      );
    }
    throw new ReedError(
      `Reed ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
    );
  }
}
