// CV-Library HTTP client — wraps fetch with: dual-mode auth (Basic OR
// Bearer per CVLibraryConfig.auth_mode), per-account_id rate-limit budget,
// 429 retry-after, 5xx exponential backoff, typed errors. NO 401-force-
// refresh path — same long-lived-key pattern as @ifos/workos + @ifos/reed.
//
// TODO(W6-live): verify exact auth_mode + base_url + endpoint paths at
// CV-Library commercial signup. v0.1.0 supports both Basic AND Bearer to
// avoid commit churn when the actual answer lands.

import {
  CVLibraryAuthError,
  CVLibraryError,
  CVLibraryNotFoundError,
  CVLibraryRateLimitError,
  CVLibraryValidationError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import type { CVLibraryClientOptions } from "./types.js";

export const DEFAULT_TIMEOUT_MS = 15_000;
export const DEFAULT_BASE_URL = "https://api.cv-library.co.uk";

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "DELETE";
  query?: Record<string, string>;
  body?: unknown;
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

export class CVLibraryClient {
  private readonly opts: CVLibraryClientOptions;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private readonly baseUrl: string;
  private readonly authHeader: string;

  constructor(opts: CVLibraryClientOptions) {
    this.opts = opts;
    this.fetchFn = opts.fetchFn ?? fetch;
    this.now = opts.now ?? Date.now;
    this.baseUrl = (opts.config.base_url ?? DEFAULT_BASE_URL).replace(/\/$/, "");
    // Construct auth header per configured auth_mode
    if (opts.config.auth_mode === "basic") {
      if (!opts.config.api_key) {
        throw new CVLibraryError(
          "CVLibraryConfig: api_key required when auth_mode='basic'",
        );
      }
      // Mirror Reed: api_key as username + empty password
      const credentials = `${opts.config.api_key}:`;
      this.authHeader = `Basic ${Buffer.from(credentials, "utf8").toString("base64")}`;
    } else if (opts.config.auth_mode === "bearer") {
      if (!opts.config.access_token) {
        throw new CVLibraryError(
          "CVLibraryConfig: access_token required when auth_mode='bearer'",
        );
      }
      this.authHeader = `Bearer ${opts.config.access_token}`;
    } else {
      throw new CVLibraryError(
        `CVLibraryConfig: unknown auth_mode '${opts.config.auth_mode}'`,
      );
    }
  }

  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    const method = options.method ?? "GET";
    const isWrite = method !== "GET";
    const max_retries = options.max_retries ?? (isWrite ? 0 : 2);

    let last_error: unknown = null;
    for (let attempt = 0; attempt <= max_retries; attempt++) {
      const allowed = consume(this.opts.config.account_id, this.now);
      if (!allowed) {
        throw new CVLibraryRateLimitError(
          `CV-Library rate-limit budget exhausted (account=${this.opts.config.account_id}); ` +
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
        Authorization: this.authHeader,
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
        last_error = e;
        if (attempt < max_retries) {
          await sleep(backoff(attempt));
          continue;
        }
        throw new CVLibraryError(
          `CV-Library network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
        );
      }

      if (res.ok) {
        return (await res.json()) as T;
      }

      // 401: auth credential invalid/revoked. NO refresh path.
      if (res.status === 401) {
        throw new CVLibraryAuthError(
          `CV-Library ${method} ${path} returned 401 — auth credential invalid or revoked. ` +
            `Rotate via CV-Library portal, update env-var, restart process.`,
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
        throw new CVLibraryRateLimitError(
          `CV-Library returned 429 after ${attempt + 1} attempt(s)`,
          retryAfter > 0 ? retryAfter : null,
        );
      }

      if (res.status >= 500 && attempt < max_retries) {
        await sleep(backoff(attempt));
        continue;
      }

      const safeBody = await res.text().catch(() => "");
      if (res.status === 404) {
        throw new CVLibraryNotFoundError(`CV-Library 404 on ${method} ${path}`);
      }
      if (res.status === 400) {
        throw new CVLibraryValidationError(
          `CV-Library rejected ${method} ${path} (HTTP 400)`,
          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
        );
      }
      throw new CVLibraryError(
        `CV-Library ${method} ${path} failed (HTTP ${res.status})`,
        res.status,
      );
    }
    throw new CVLibraryError(
      `CV-Library ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
    );
  }
}
