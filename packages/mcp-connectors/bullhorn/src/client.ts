// Bullhorn HTTP client — wraps fetch with: BhRestToken attach (NOT OAuth
// access_token; per Bullhorn's two-step model the REST endpoints use the
// session-layer BhRestToken on the per-corp restUrl returned by /login),
// rate-limit budget, 429 retry-after, 5xx exponential backoff, 401 force-
// refresh (single rotation per request lifecycle per cluster F R4 lesson),
// 4xx surface as typed errors. No retry on POST/PUT writes (caller decides).

import {
  BullhornAuthError,
  BullhornError,
  BullhornNotFoundError,
  BullhornRateLimitError,
  BullhornValidationError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import { loadTokens, refreshTokens, shouldRefresh } from "./auth.js";
import type { BullhornClientOptions, BullhornTokens } from "./types.js";

export const DEFAULT_TIMEOUT_MS = 15_000;

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

export class BullhornClient {
  private readonly opts: BullhornClientOptions;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private current_tokens: BullhornTokens | null = null;

  constructor(opts: BullhornClientOptions) {
    this.opts = opts;
    this.fetchFn = opts.fetchFn ?? fetch;
    this.now = opts.now ?? Date.now;
  }

  /**
   * Returns the active session bundle (BhRestToken + per-corp restUrl),
   * refreshing eagerly if either token is within the safety window.
   * Loads from disk on first call.
   */
  async getValidSession(): Promise<{ bh_rest_token: string; rest_url: string }> {
    if (!this.current_tokens) {
      this.current_tokens = await loadTokens(this.opts.config);
      if (!this.current_tokens) {
        throw new BullhornAuthError(
          "No Bullhorn tokens on disk; consent flow required to bootstrap " +
            "tokens at token_file_path (run the one-time OAuth authorise " +
            "flow per README §Bootstrap; per-corporation_id setup)",
        );
      }
    }
    if (shouldRefresh(this.current_tokens, this.now)) {
      this.current_tokens = await refreshTokens(
        this.opts.config,
        this.current_tokens,
        this.fetchFn,
      );
    }
    return {
      bh_rest_token: this.current_tokens.bh_rest_token,
      rest_url: this.current_tokens.rest_url,
    };
  }

  /** Public: low-level call. Most callers use the capability helpers
   *  (candidates / placements / clients / contacts / notes). */
  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    const method = options.method ?? "GET";
    const isWrite = method !== "GET";
    const max_retries = options.max_retries ?? (isWrite ? 0 : 2);

    // Per cluster F R4 lesson (open-banking + quickbooks 401 double-refresh
    // bug): refreshTokens() is state-changing — rotates the refresh_token on
    // success AND issues a new BhRestToken. Allowing the 401 branch to fire
    // on multiple attempts in the same request lifecycle would rotate twice
    // for a single end-user request, wasting a refresh_token rotation. Track
    // whether we've already forced a refresh in this request; a second 401
    // after the forced refresh → throw immediately (the server is rejecting
    // the newly-rotated token, which means consent is revoked or the rotation
    // itself returned a bad bundle).
    let didForceRefresh = false;

    let last_error: unknown = null;
    for (let attempt = 0; attempt <= max_retries; attempt++) {
      // Pre-emptive rate-limit check (per-corporation_id bucket)
      const allowed = consume(this.opts.config.corporation_id, this.now);
      if (!allowed) {
        throw new BullhornRateLimitError(
          `Bullhorn rate-limit budget exhausted (corporation=${this.opts.config.corporation_id}); ` +
            `local bucket prevents call to avoid upstream 429`,
        );
      }

      const session = await this.getValidSession();
      const url = new URL(session.rest_url.replace(/\/$/, "") + path);
      if (options.query) {
        for (const [k, v] of Object.entries(options.query)) {
          url.searchParams.set(k, v);
        }
      }
      // BhRestToken can be passed as query param OR header; we use header
      // (cleaner for log redaction; query-param tokens leak in access logs).
      const headers: Record<string, string> = {
        BhRestToken: session.bh_rest_token,
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
        throw new BullhornError(
          `Bullhorn network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
        );
      }

      // 200-299 happy path
      if (res.ok) {
        return (await res.json()) as T;
      }

      // 401: BhRestToken expired or revoked — force full refresh (Step A + B)
      // BEFORE the next iteration. Per cluster F R4 lesson: only ONE forced
      // refresh per request lifecycle.
      if (res.status === 401 && attempt < max_retries && !didForceRefresh) {
        if (this.current_tokens) {
          // Throws BullhornAuthError on refresh failure → propagates correctly.
          this.current_tokens = await refreshTokens(
            this.opts.config,
            this.current_tokens,
            this.fetchFn,
          );
        }
        didForceRefresh = true;
        await sleep(backoff(attempt));
        continue;
      }
      // 401 after retries exhausted OR after a forced refresh: AUTH-typed
      // error so consumer branches correctly to ESC_BULLHORN_AUTH.
      if (res.status === 401) {
        throw new BullhornAuthError(
          `Bullhorn ${method} ${path} returned 401 after ${attempt + 1} attempt(s)` +
            (didForceRefresh
              ? " including a forced full-refresh (Step A + B) — server is rejecting the rotated session"
              : ""),
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
        throw new BullhornRateLimitError(
          `Bullhorn returned 429 after ${attempt + 1} attempt(s)`,
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
        throw new BullhornNotFoundError(`Bullhorn 404 on ${method} ${path}`);
      }
      if (res.status === 400) {
        throw new BullhornValidationError(
          `Bullhorn rejected ${method} ${path} (HTTP 400)`,
          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
        );
      }
      throw new BullhornError(
        `Bullhorn ${method} ${path} failed (HTTP ${res.status})`,
        res.status,
      );
    }
    throw new BullhornError(
      `Bullhorn ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
    );
  }
}
