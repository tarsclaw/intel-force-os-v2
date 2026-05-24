// @ifos/web-scraper public API

export {
  headCheck,
  fetchFirstNLines,
  googleSearch,
  type HeadResult,
  type BodyResult,
} from "./fetcher.js";

export { isAllowedByRobots } from "./robots.js";
export { Cache } from "./cache.js";
export { tryConsume as tryConsumeRateLimit, reset as resetRateLimit } from "./rate-limit.js";
export {
  ScraperError,
  ScraperTimeoutError,
  ScraperRobotsBlockedError,
  ScraperRateLimitError,
} from "./errors.js";
export type { ClientOptions, FetchFn } from "./client.js";
export { DEFAULT_USER_AGENT } from "./client.js";

export const VERSION = "0.1.0";
