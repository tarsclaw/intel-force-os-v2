// @ifos/companies-house — public API

export { search, profile, officers, filingHistory, _resetForTest } from "./capabilities.js";
export { CHClient, CH_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
export type { CHClientOptions, FetchFn } from "./client.js";
export { CHCache } from "./cache.js";
export { check as rateCheck, consume as rateConsume, reset as resetRateLimit } from "./rate-limit.js";
export {
  CHError,
  CHAuthError,
  CHRateLimitError,
  CHNotFoundError,
} from "./errors.js";
export type {
  CHSearchResult,
  CHSearchResponse,
  CHProfile,
  CHAddress,
  CHOfficer,
  CHOfficersResponse,
  CHFiling,
  CHFilingHistoryResponse,
} from "./types.js";

export const VERSION = "0.1.0";
