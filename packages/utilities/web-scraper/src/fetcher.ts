// Main public API for web-scraper. Composes robots check → rate limit →
// cache lookup → HTTP call → cache store.

import {
  bodyFirstNLines,
  ClientOptions,
  DEFAULT_USER_AGENT,
  httpGet,
  httpHead,
} from "./client.js";
import { Cache } from "./cache.js";
import { tryConsume } from "./rate-limit.js";
import { isAllowedByRobots } from "./robots.js";

const HEAD_CACHE_TTL_MS = 60 * 60 * 1000; // 1h
const BODY_CACHE_TTL_MS = 60 * 60 * 1000; // 1h

export interface HeadResult {
  readonly status: number;
  readonly lastModified: string | null;
  readonly contentType: string | null;
  readonly finalUrl: string;
}

export interface BodyResult {
  readonly status: number;
  readonly lines: string[];
  readonly contentType: string | null;
  readonly finalUrl: string;
}

function getCache(): Cache {
  // Re-read env var each call so per-test cache dir overrides take effect.
  return Cache.fromEnv();
}

export async function headCheck(
  url: string,
  opts: ClientOptions = {},
): Promise<HeadResult | null> {
  const cacheKey = `head:${url}`;
  const cached = await getCache().get<HeadResult>(cacheKey);
  if (cached) return cached;

  if (!(await isAllowedByRobots(url, opts.userAgent ?? DEFAULT_USER_AGENT, opts))) {
    return null;
  }

  if (!tryConsume()) {
    return null;
  }

  let res: Response;
  try {
    res = await httpHead(url, opts);
  } catch {
    return null;
  }

  const result: HeadResult = {
    status: res.status,
    lastModified: res.headers.get("last-modified"),
    contentType: res.headers.get("content-type"),
    finalUrl: res.url,
  };

  if (res.status >= 200 && res.status < 400) {
    await getCache().set(cacheKey, result, HEAD_CACHE_TTL_MS);
  }
  return result;
}

export async function fetchFirstNLines(
  url: string,
  n: number,
  opts: ClientOptions = {},
): Promise<BodyResult | null> {
  const cacheKey = `body:${url}:n=${n}`;
  const cached = await getCache().get<BodyResult>(cacheKey);
  if (cached) return cached;

  if (!(await isAllowedByRobots(url, opts.userAgent ?? DEFAULT_USER_AGENT, opts))) {
    return null;
  }

  if (!tryConsume()) {
    return null;
  }

  let res: Response;
  try {
    res = await httpGet(url, opts);
  } catch {
    return null;
  }

  let lines: string[] = [];
  if (res.body) {
    try {
      lines = await bodyFirstNLines(res, n);
    } catch {
      lines = [];
    }
  }

  const result: BodyResult = {
    status: res.status,
    lines,
    contentType: res.headers.get("content-type"),
    finalUrl: res.url,
  };

  if (res.status >= 200 && res.status < 400 && lines.length > 0) {
    await getCache().set(cacheKey, result, BODY_CACHE_TTL_MS);
  }
  return result;
}

/**
 * Google web search — stub for v0. Returns null until SerpAPI or
 * alternative is wired at W4 polish per tools.yaml.
 */
export async function googleSearch(_query: string): Promise<null> {
  return null;
}
