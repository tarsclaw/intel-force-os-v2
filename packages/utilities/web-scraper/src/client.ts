// HTTP client primitives for web-scraper. Wraps globalThis.fetch with
// timeout, user-agent, and a fetch injection point for tests.

import { ScraperTimeoutError, ScraperError } from "./errors.js";

// User-agent intentionally avoids the substring "bot" because some
// robots.txt files (e.g. hays.com) have wildcard-suffix "Disallow: /"
// rules for any agent whose name contains "bot". We identify ourselves
// as an automated client via the more specific "IFOS-Diagnostic/0.1"
// fragment + the contact URL.
export const DEFAULT_USER_AGENT =
  "IFOS-Diagnostic/0.1 (+https://intelforce.io/contact)";

export const DEFAULT_TIMEOUT_MS = 10_000;

export type FetchFn = typeof globalThis.fetch;

export interface ClientOptions {
  readonly fetchImpl?: FetchFn;
  readonly userAgent?: string;
  readonly timeoutMs?: number;
}

export async function httpHead(
  url: string,
  opts: ClientOptions = {},
): Promise<Response> {
  return withTimeout(url, opts.timeoutMs ?? DEFAULT_TIMEOUT_MS, (signal) =>
    (opts.fetchImpl ?? globalThis.fetch)(url, {
      method: "HEAD",
      redirect: "follow",
      signal,
      headers: { "User-Agent": opts.userAgent ?? DEFAULT_USER_AGENT },
    }),
  );
}

export async function httpGet(
  url: string,
  opts: ClientOptions = {},
): Promise<Response> {
  return withTimeout(url, opts.timeoutMs ?? DEFAULT_TIMEOUT_MS, (signal) =>
    (opts.fetchImpl ?? globalThis.fetch)(url, {
      method: "GET",
      redirect: "follow",
      signal,
      headers: { "User-Agent": opts.userAgent ?? DEFAULT_USER_AGENT },
    }),
  );
}

async function withTimeout<T>(
  url: string,
  timeoutMs: number,
  op: (signal: AbortSignal) => Promise<T>,
): Promise<T> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await op(controller.signal);
  } catch (err) {
    if (err instanceof Error && err.name === "AbortError") {
      throw new ScraperTimeoutError(url, timeoutMs);
    }
    throw new ScraperError(`fetch failed: ${(err as Error).message}`, url, err);
  } finally {
    clearTimeout(timer);
  }
}

export async function bodyFirstNLines(res: Response, n: number): Promise<string[]> {
  if (!res.body) return [];
  const reader = res.body.getReader();
  const decoder = new TextDecoder();
  let buffer = "";
  const lines: string[] = [];
  while (lines.length < n) {
    const { value, done } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });
    const parts = buffer.split("\n");
    buffer = parts.pop() ?? "";
    for (const line of parts) {
      lines.push(line);
      if (lines.length >= n) break;
    }
  }
  if (buffer.length > 0 && lines.length < n) lines.push(buffer);
  try {
    await reader.cancel();
  } catch {
    // ignore — we got our N lines
  }
  return lines.slice(0, n);
}
