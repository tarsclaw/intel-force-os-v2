// Open Banking HTTP client façade — provider-aware (TrueLayer fully implemented;
// Plaid UK stubbed for v1.1+). Wraps fetch with: OAuth token attach, rate-limit
// budget, 429 retry-after, 5xx exponential backoff, 4xx surface as typed errors.

import {
  NotImplementedError,
  OpenBankingAuthError,
  OpenBankingError,
  OpenBankingNotFoundError,
  OpenBankingRateLimitError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import { loadTokens, refreshTokens, shouldRefresh } from "./auth.js";
import type { OpenBankingClientOptions, OpenBankingTokens } from "./types.js";

export const TRUELAYER_API_PROD = "https://api.truelayer.com";
export const TRUELAYER_API_SANDBOX = "https://api.truelayer-sandbox.com";
export const DEFAULT_TIMEOUT_MS = 15_000;

interface RequestOptions {
  method?: "GET" | "POST";
  query?: Record<string, string>;
  max_retries?: number;
  signal?: AbortSignal;
}

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

function backoff(attempt: number): number {
  const base = 250 * 2 ** attempt;
  return Math.floor(Math.random() * base);
}

export class OpenBankingClient {
  private readonly opts: OpenBankingClientOptions;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private current_tokens: OpenBankingTokens | null = null;
  private readonly base_url: string;

  constructor(opts: OpenBankingClientOptions) {
    this.opts = opts;
    this.fetchFn = opts.fetchFn ?? fetch;
    this.now = opts.now ?? Date.now;
    if (opts.config.provider === "plaid_uk") {
      // Plaid UK API URL would land here; v1.1+ deferred.
      this.base_url = "https://plaid_uk-not-yet-implemented.invalid";
    } else {
      this.base_url =
        opts.config.environment === "production"
          ? TRUELAYER_API_PROD
          : TRUELAYER_API_SANDBOX;
    }
  }

  async getValidAccessToken(): Promise<string> {
    if (!this.current_tokens) {
      this.current_tokens = await loadTokens(this.opts.config);
      if (!this.current_tokens) {
        throw new OpenBankingAuthError(
          `No ${this.opts.config.provider} tokens on disk; PSD2 consent + initial token exchange required to bootstrap token_file_path (run the one-time OAuth authorise flow per README §Bootstrap)`,
        );
      }
    }
    if (shouldRefresh(this.current_tokens, this.now)) {
      this.current_tokens = await refreshTokens(
        this.opts.config,
        this.current_tokens,
        this.fetchFn,
        this.now,
      );
    }
    return this.current_tokens.access_token;
  }

  /** Low-level request. Capability helpers (transactions, balance) use this. */
  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    if (this.opts.config.provider === "plaid_uk") {
      throw new NotImplementedError(
        "Plaid UK provider client not yet implemented (v1.1+ deferred). Use provider: 'truelayer' for v1.0.",
      );
    }

    const method = options.method ?? "GET";
    const max_retries = options.max_retries ?? 2;

    const url = new URL(this.base_url + path);
    if (options.query) {
      for (const [k, v] of Object.entries(options.query)) {
        url.searchParams.set(k, v);
      }
    }

    let last_error: unknown = null;
    for (let attempt = 0; attempt <= max_retries; attempt++) {
      const allowed = consume(
        this.opts.config.provider,
        this.opts.config.connection_id,
        this.now,
      );
      if (!allowed) {
        throw new OpenBankingRateLimitError(
          `Open Banking rate-limit budget exhausted (provider=${this.opts.config.provider}, connection=${this.opts.config.connection_id})`,
        );
      }

      const access_token = await this.getValidAccessToken();
      const headers: Record<string, string> = {
        Authorization: `Bearer ${access_token}`,
        Accept: "application/json",
      };

      let res: Response;
      try {
        res = await this.fetchFn(url.toString(), {
          method,
          headers,
          signal: options.signal,
        });
      } catch (e) {
        last_error = e;
        if (attempt < max_retries) {
          await sleep(backoff(attempt));
          continue;
        }
        throw new OpenBankingError(
          `Open Banking network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
        );
      }

      if (res.ok) {
        return (await res.json()) as T;
      }

      // 401: server invalidated the access_token — force an explicit refresh
      // BEFORE the next iteration. Per Codex F-R2 issue #2 (open-banking):
      // nulling the cached token alone is insufficient — getValidAccessToken()
      // will reload the SAME stale token from disk if shouldRefresh() says
      // it's not near expiry. Rotate it now; persist the new bundle; let the
      // next iteration pick up the rotated token. Throws OpenBankingAuthError
      // (or OpenBankingConsentExpiredError if PSD2 consent is in blocking)
      // on refresh failure → propagates correctly.
      if (res.status === 401 && attempt < max_retries) {
        if (this.current_tokens) {
          this.current_tokens = await refreshTokens(
            this.opts.config,
            this.current_tokens,
            this.fetchFn,
          );
        }
        await sleep(backoff(attempt));
        continue;
      }
      // 401 after retries exhausted: AUTH-typed error (NOT generic
      // OpenBankingError) so consumer branches correctly to ESC_OPEN_BANKING_AUTH.
      // Per Codex F-R2 issue #2 (open-banking).
      if (res.status === 401) {
        throw new OpenBankingAuthError(
          `Open Banking ${method} ${path} returned 401 after ${attempt + 1} attempt(s) including forced refresh`,
          401,
        );
      }

      if (res.status === 429 && attempt < max_retries) {
        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
        await sleep(waitMs);
        continue;
      }
      if (res.status === 429) {
        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
        throw new OpenBankingRateLimitError(
          `Open Banking returned 429 after ${attempt + 1} attempt(s)`,
          retryAfter > 0 ? retryAfter : null,
        );
      }

      if (res.status >= 500 && attempt < max_retries) {
        await sleep(backoff(attempt));
        continue;
      }

      if (res.status === 404) {
        throw new OpenBankingNotFoundError(`Open Banking 404 on ${method} ${path}`);
      }
      throw new OpenBankingError(
        `Open Banking ${method} ${path} failed (HTTP ${res.status})`,
        res.status,
      );
    }
    throw new OpenBankingError(
      `Open Banking ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
    );
  }
}
