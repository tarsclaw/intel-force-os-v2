// HTTP client for Companies House REST API.
// Auth: HTTP Basic with API key as username, empty password.

import { CHAuthError, CHError, CHNotFoundError, CHRateLimitError } from "./errors.js";

export const CH_BASE_URL = "https://api.company-information.service.gov.uk";
export const DEFAULT_TIMEOUT_MS = 8_000;

export type FetchFn = typeof globalThis.fetch;

export interface CHClientOptions {
  readonly apiKey?: string;
  readonly baseUrl?: string;
  readonly fetchImpl?: FetchFn;
  readonly timeoutMs?: number;
}

export class CHClient {
  private readonly apiKey: string;
  private readonly baseUrl: string;
  private readonly fetchImpl: FetchFn;
  private readonly timeoutMs: number;

  constructor(opts: CHClientOptions = {}) {
    const apiKey = opts.apiKey ?? process.env.COMPANIES_HOUSE_API_KEY ?? "";
    if (!apiKey) {
      throw new CHAuthError("(client init)");
    }
    this.apiKey = apiKey;
    this.baseUrl = opts.baseUrl ?? CH_BASE_URL;
    this.fetchImpl = opts.fetchImpl ?? globalThis.fetch;
    this.timeoutMs = opts.timeoutMs ?? DEFAULT_TIMEOUT_MS;
  }

  async getJson<T>(path: string, query?: Record<string, string>): Promise<T> {
    const url = new URL(this.baseUrl + path);
    if (query) {
      for (const [k, v] of Object.entries(query)) url.searchParams.set(k, v);
    }

    const authHeader = "Basic " + Buffer.from(`${this.apiKey}:`).toString("base64");

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeoutMs);
    let res: Response;
    try {
      res = await this.fetchImpl(url.toString(), {
        method: "GET",
        headers: { Authorization: authHeader, Accept: "application/json" },
        signal: controller.signal,
      });
    } catch (err) {
      throw new CHError(`fetch failed: ${(err as Error).message}`, path, undefined, err);
    } finally {
      clearTimeout(timer);
    }

    if (res.status === 401 || res.status === 403) throw new CHAuthError(path);
    if (res.status === 404) throw new CHNotFoundError(path);
    if (res.status === 429) throw new CHRateLimitError(path);
    if (res.status >= 500) {
      throw new CHError(`server error ${res.status}`, path, res.status);
    }
    if (res.status >= 400) {
      throw new CHError(`unexpected status ${res.status}`, path, res.status);
    }

    try {
      return (await res.json()) as T;
    } catch (err) {
      throw new CHError(`response not JSON: ${(err as Error).message}`, path, res.status, err);
    }
  }
}
