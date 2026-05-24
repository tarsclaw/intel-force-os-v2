// robots.txt fetch + parse + check. Uses robots-parser package.

import robotsParser from "robots-parser";
import { Cache } from "./cache.js";
import { ClientOptions, DEFAULT_USER_AGENT, httpGet } from "./client.js";

const ROBOTS_CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24h

function getCache(): Cache {
  // Re-read env var each call so per-test cache dir overrides take effect.
  return Cache.fromEnv();
}

/**
 * Check whether `url` is allowed by the destination origin's robots.txt
 * for our user agent. Returns true if allowed OR if robots.txt cannot
 * be fetched (open-by-default per scraper-utility convention).
 */
export async function isAllowedByRobots(
  url: string,
  userAgent: string = DEFAULT_USER_AGENT,
  opts: ClientOptions = {},
): Promise<boolean> {
  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    return false;
  }
  const robotsUrl = `${parsed.protocol}//${parsed.host}/robots.txt`;

  const cache = getCache();
  let robotsBody = await cache.get<string>(`robots:${parsed.host}`);

  if (robotsBody === null) {
    try {
      const res = await httpGet(robotsUrl, opts);
      if (res.status === 200) {
        robotsBody = await res.text();
      } else {
        robotsBody = ""; // no robots.txt → open
      }
      await cache.set(`robots:${parsed.host}`, robotsBody, ROBOTS_CACHE_TTL_MS);
    } catch {
      return true; // fetch failed → fail-open
    }
  }

  if (robotsBody.length === 0) return true;

  const robots = robotsParser(robotsUrl, robotsBody);
  return robots.isAllowed(url, userAgent) ?? true;
}
