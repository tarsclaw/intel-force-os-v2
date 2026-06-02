# @ifos/open-banking

UK Open Banking connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). Provider abstraction over **TrueLayer (v1.0)** + **Plaid UK (v1.1+ deferred)** with PSD2 90-day consent tracking + token-aging stages. Used by Cash Conductor for bank-transaction ingest + cash-flow forecast balance reads.

**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first TrueLayer dev signup for live-test verification).

**Reference pattern:** mirrors `@ifos/xero` + `@ifos/quickbooks` structure. The PSD2 consent lifecycle is the load-bearing structural difference vs the accounting connectors — banks legally require user re-authentication every 90 days regardless of refresh-token TTL.

---

## Capabilities

Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.

**Provider scope (v1.0):** TrueLayer ONLY. Plaid UK exists as an internal stub in `src/` for v1.1+ work but is NOT a v1.0 bus-routed capability (per Codex F-R3 closure 2026-06-02 — `docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md`; pre-R3 the v1.1+ stub was declared as a v1.0 capability for set-equality, which violated review-mcp-connector single-upstream-provider intent + had no success fixtures to back the surface). When the first IFOS tenant picks Plaid over TrueLayer in v1.1+, the Plaid implementation graduates to a bus-routed capability and re-registers here.

| Capability ID (tools.yaml) | Function (src/index.ts) | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
|---|---|---|---|---|---|
| `open_banking_truelayer_oauth` | `refreshTokens(config, current, fetchFn?, now?)` | OAuth refresh against TrueLayer; concurrent-safe per (provider, connection_id); **refuses if consent is in PSD2 blocking window (≤7 days)** | Step 1 (auth refresh) | `open_banking_truelayer` | green |
| `open_banking_list_transactions` | `listTransactionsSince(client, config, options)` | List bank transactions on/after a timestamp; TrueLayer raw payload preserved in `raw_provider_payload` for v1.1+ provider-agnostic upgrade | Step 3 (transaction ingest) | n/a (read-only) | n/a |
| `open_banking_get_account_balance` | `getAccountBalance(client, config)` | Current account balance (available + cleared) | Step 10 (cash-flow forecast) | n/a (read-only) | n/a |

`open_banking_truelayer` action_type exists in `agents/_shared/autosend-policy.yaml` at green tier. `open_banking_plaid_uk` ALSO exists in the policy (registered 2026-06-01 in commit f414492) — kept registered to avoid churn when v1.1+ work re-promotes Plaid; not currently consumed.

### Internal helpers (NOT bus-routed capabilities)

Exposed by `src/index.ts` for consumer convenience + testing, but NOT declared in `tools.yaml`:

| Function | Purpose |
|---|---|
| `OpenBankingClient` (class) | Transport — constructed once by cycle.sh Step 1; provider-aware base URL (TrueLayer prod/sandbox; Plaid UK v1.1+) |
| `loadTokens(config)` / `saveTokens(config, t)` | Token-file I/O — includes the load-bearing PSD2 `consent_expires_at_ms` field; surfaced for test setup + operator consent-bootstrap |
| `shouldRefresh(tokens, now?, window?)` | Pure predicate — `true` when the access_token expires within `safety_window_ms` (default 5 min) |
| `getTokenAgeStage(tokens, now?)` | Pure predicate — returns `{stage: 'fresh'|'info'|'warn'|'blocking', days_until_consent_expiry}`; staged-severity hook for operator alerting via `ESC_OPEN_BANKING_TOKEN_AGING` |
| `rateCheck(key, now?)` | Returns `RateState` — exposes soft-backoff signal at 80% (24/min) of the conservative 30/min ceiling; consumer responsible for honouring it |
| `rateConsume(key, now?)` | Consumes a slot; returns false at the hard 100% gate |
| `resetRateLimit(key?)` | Test/diagnostic reset |
| `_resetInflightForTest()` | Clears in-flight OAuth-refresh dedup map; for tests only |
| `OpenBankingCache` (class) | Disk cache — transactions TTL 5min; balance TTL 0 (always fresh) |

---

## PSD2 consent lifecycle (the load-bearing distinction)

UK Open Banking is regulated by PSD2 + the OBIE standards. The KEY constraint vs other OAuth flows:

> **PSD2 requires the user to re-authenticate to their bank every 90 days**, regardless of whether the refresh_token would otherwise still be valid.

This means the connector tracks TWO expiry timestamps per token bundle:

1. **`expires_at_ms`** — access_token expiry (typical ~1 hour). Routine refresh via `refreshTokens()` rotates this transparently.
2. **`consent_expires_at_ms`** — PSD2 consent expiry (~90 days from the user's last successful re-authentication). When this hits, the refresh_token itself becomes invalid; the user MUST re-do the PSD2 consent dance.

`getTokenAgeStage()` is the pure classifier the agent uses to alert the operator BEFORE consent dies. Stages, with the cycle.sh / agent.md §6 mapping to `ESC_OPEN_BANKING_TOKEN_AGING`:

| Days until consent expiry | Stage | Agent behaviour |
|---|---|---|
| > 30 | `fresh` | (no alert) |
| 15-30 | `info` | log + monitor (operator-aware; nothing breaks) |
| 8-14 | `warn` | escalate to operator chat (`ESC_OPEN_BANKING_TOKEN_AGING` severity warn) |
| 0-7 | `blocking` | **HARD STOP** — `refreshTokens()` refuses to issue a new access token; operator MUST re-do PSD2 consent dance with the user before Cash Conductor can resume |
| < 0 | `blocking` (already expired) | same |

The blocking-window refusal is enforced server-side by the bank too (refresh_token will 401 once consent expires), but the client-side check fires sooner and with better error messaging (`OpenBankingConsentExpiredError` with explicit guidance).

`tests/token-aging.test.ts` exhaustively tests the day 0-100 boundary classification per goal-w4-day-26 Phase 2 Step 7 requirement.

---

## Quick start

```typescript
import {
  OpenBankingClient,
  listTransactionsSince,
  getAccountBalance,
  getTokenAgeStage,
  loadTokens,
} from "@ifos/open-banking";

const config = {
  provider: "truelayer" as const,
  client_id: process.env.TRUELAYER_CLIENT_ID!,
  client_secret: process.env.TRUELAYER_CLIENT_SECRET!,
  connection_id: "<truelayer-account-id>",
  environment: "sandbox" as const,
  token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/ob-tokens-<account-id>.json`,
};

// Operator-side: check consent age first
const tokens = await loadTokens(config);
if (tokens) {
  const age = getTokenAgeStage(tokens);
  if (age.stage === "blocking") {
    throw new Error("PSD2 consent expired — re-do consent dance before continuing");
  }
}

const client = new OpenBankingClient({ config });
const transactions = await listTransactionsSince(client, config, {
  since: "2026-05-01T00:00:00Z",
});
const balance = await getAccountBalance(client, config);
```

---

## OAuth bootstrap (one-time per bank connection)

The connector handles the **refresh** half. The **initial consent dance** (user → bank login → consent → authorisation code → first token pair) is a one-time human-in-the-loop flow:

1. Register the IFOS app at https://console.truelayer.com/ (TrueLayer) → get `client_id` + `client_secret`.
2. Construct the authorise URL: scope=`accounts transactions balance offline_access`, response_type=code, redirect_uri=your callback, provider_id=`uk-ob-<bank>`.
3. User → bank login → consent screen → bank redirects to your `redirect_uri?code=<auth_code>&scope=...`.
4. POST to `https://auth.truelayer-sandbox.com/connect/token` (or `auth.truelayer.com` for prod) with `grant_type=authorization_code` + the code → receive `{access_token, refresh_token, expires_in}`.
5. Call `GET https://api.truelayer-sandbox.com/data/v1/accounts` with the access_token → get the `account_id`(s) for this connection.
6. Compute `consent_expires_at_ms = Date.now() + 90 * 24 * 60 * 60 * 1000` (PSD2 default). When the user re-consents in the future, recompute.
7. Write the token bundle to `token_file_path` as JSON (mode 0600) — include both `expires_at_ms` AND `consent_expires_at_ms`. The connector handles all subsequent rotations automatically.

For Plaid UK (v1.1+): pattern is similar but uses `POST /link/token/create` then exchange of public_token → access_token. Interface is in place; implementation is deferred — `NotImplementedError` thrown today.

---

## Rate limits

Conservative per-provider buckets per `src/rate-limit.ts`. Upstream published-limits pages:

- **TrueLayer:** https://docs.truelayer.com/docs/data-api-rate-limits — production prod-API limits are tier-dependent and not exposed as a single public number; sandbox is documented at 30/min/connection. We use the sandbox figure as the conservative ceiling for production too — it can be tuned upward when Cash Conductor cycle.sh telemetry shows actual usage patterns.
- **Plaid UK:** https://plaid.com/docs/errors/rate-limit-exceeded/ — Plaid Standard tier publishes a 600/min per-Item ceiling; we use 30/min as the conservative starting point until v1.1+ pilots show real load.

| Provider | Local hard cap (this connector) | Local soft (80%) | Upstream documented |
|---|---|---|---|
| TrueLayer | 30 calls/min per (provider, connection_id) | 24/min | sandbox 30/min; prod tier-dependent |
| Plaid UK | 30 calls/min per (provider, item_id) | 24/min | 600/min per-Item (Standard tier) |

**Hard gate at 100%** (`consume()` returns false → `OpenBankingRateLimitError`). **Soft signal at 80%** (24/min) is read-only and exposed via `rateCheck()` — `RateState.shouldBackoff === true` with `reason: "minute-soft"`. The consuming agent layer (Cash Conductor cycle.sh) is responsible for honouring the soft signal; the connector does not silently throttle.

State is in-process and per-(provider, connection_id) — a multi-bank-account runtime that holds many `OpenBankingClient` instances in one process still gets correct isolation.

**ESC contract on bucket exhaustion** (consumer-emitted via `agents/_shared/hook-helpers.sh`):

| Failure | Surfaces as | ESC code (escalation-codes.md) | Payload contract |
|---|---|---|---|
| Local hard-gate (100%) reached | `OpenBankingRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "truelayer" | "plaid_uk", retry_after_seconds: null, consecutive_429s: 0}` |
| Upstream 429 from provider API | `OpenBankingRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "truelayer" | "plaid_uk", retry_after_seconds: <N>, consecutive_429s: <N>}` |

---

## Retry policy

| Capability | Method | Max retries | Backoff | On exhaustion |
|---|---|---|---|---|
| `listTransactionsSince` / `getAccountBalance` | GET | 2 | Exponential w/ jitter (250-1000ms) | `OpenBankingError` / `OpenBankingRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
| `refreshTokens` | POST | **0** | n/a | `OpenBankingAuthError` → `ESC_OPEN_BANKING_AUTH` (**blocking**; consumer-emitted; routes operator + ifos_oncall per escalation-codes.md lines 288-294; payload `failure_type: 'refresh_failed'`) |
| `refreshTokens` blocked by PSD2 consent expiry | POST | **0** | n/a | `OpenBankingConsentExpiredError` → `ESC_OPEN_BANKING_AUTH` (blocking; payload `failure_type: 'consent_expired_90d'`); user must re-do SCA per Bootstrap § |
| 401 from any GET | — | force-refresh access_token, retry once | — | `OpenBankingAuthError` → `ESC_OPEN_BANKING_AUTH` |
| 429 from any GET | — | honour `Retry-After` header | jittered backoff if no header | `OpenBankingRateLimitError` → `ESC_RATE_LIMIT_HIT` |

The only state-changing op is OAuth refresh (which has its own consent-aware refusal logic via `getTokenAgeStage`). All transaction/balance calls are read-only — banks don't generally expose write APIs in the scope Cash Conductor needs. The connector does NOT write `decision_log` rows (vault/Postgres split per ADR-002); the consuming `cycle.sh` catches the typed errors above and emits the right ESC via `hh_decision_action`/`hh_decision_output` from `agents/_shared/hook-helpers.sh`.

The separate **PSD2 token-aging signal** — `ESC_OPEN_BANKING_TOKEN_AGING` (staged info → warn → blocking per consent-expiry distance) — is emitted by the consumer based on `getTokenAgeStage()` BEFORE refresh fails. That's a different code path from the refresh-failure mapping above; see `agents/_shared/escalation-codes.md` lines 296-307 for the staged severity definition and `agents/recruitment/cash-conductor/agent.md` §6 for the consumer flow.

---

## Error hierarchy

```
OpenBankingError                  // base
├── OpenBankingAuthError          // OAuth refresh fail (4xx on token endpoint)
│   └── OpenBankingConsentExpiredError  // PSD2 90-day consent dead; re-consent required
├── OpenBankingRateLimitError     // 429 OR local bucket exhausted
├── OpenBankingNotFoundError      // 404
└── NotImplementedError           // Plaid UK during v1.0 (interface defined; impl deferred)
```

Errors NEVER include credential values; only key names, status codes, safe metadata.

---

## Tests

```bash
# Unit + fixture tests (fast; no network)
pnpm test
```

**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.

**Live tests are deferred** to the first TrueLayer dev signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal — review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold will land in the same commit as the first sandbox credentials per the W4 Track-1 /goal §1 commercial-gate; the fixture-first suite below is fully sufficient for the W4 ratification pass.

Test counts:
- `tests/scaffold.test.ts`: 5 (public surface, exports, full error hierarchy with NotImplementedError)
- `tests/rate-limit.test.ts`: 5 (initial state, soft 24, hard 30, per-(provider, connection) isolation)
- `tests/token-aging.test.ts`: 6 (property-based day 0-100 boundary: fresh, info, warn, blocking, negative/already-expired, days_until consistency)
- `tests/auth.test.ts`: 8 (load missing, round-trip, shouldRefresh, refresh success + consent_expires preserved, 401 + no-token-leak, **blocking-consent refuses refresh**, concurrent dedup, Plaid-UK NotImplementedError)
- `tests/capabilities.test.ts`: 7 (TrueLayer transactions + balance from fixtures; Plaid UK NotImplementedError for both; **listTransactionsSince 429 retry-exhaust, getAccountBalance 500 retry-exhaust, 401-forces-refresh-then-retry** — all 3 added per Codex F-R2 #2 + #3)

**Total: 31 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).

---

## Build

```bash
pnpm build       # tsup → dist/index.{js,d.ts}
pnpm typecheck   # tsc --noEmit
```

ESM-only; node 20+; target ES2022. Same toolchain as other MCP connectors.

---

## Where this fits in the IFOS architecture

```
agents/recruitment/cash-conductor/cycle.sh
   │
   ├── Step 1  (auth refresh + consent age check)  ──┐
   ├── Step 3  (bank transaction ingest)            ──┼─→ @ifos/open-banking (this package)
   └── Step 10 (weekly cash-flow forecast balance)  ──┘    │
                                                          ↓
                                                     TrueLayer or Plaid UK
                                                     (provider chosen at config time)
                                                          ↓
                                                     OAuth bearer (PSD2-consented)
```

Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is one of the substrate dependencies (alongside the accounting connector chosen per tenant).

---

## Boundary checks

Per `review-mcp-connector.md` §8:
- ✓ No Composio / AgentMail references
- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)
- ✓ No hardcoded tenant slugs in `src/` (test fixtures only)

---

*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*
