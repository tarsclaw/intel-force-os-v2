# @ifos/open-banking

UK Open Banking connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). Provider abstraction over **TrueLayer (v1.0)** + **Plaid UK (v1.1+ deferred)** with PSD2 90-day consent tracking + token-aging stages. Used by Cash Conductor for bank-transaction ingest + cash-flow forecast balance reads.

**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first TrueLayer dev signup for live-test verification).

**Reference pattern:** mirrors `@ifos/xero` + `@ifos/quickbooks` structure. The PSD2 consent lifecycle is the load-bearing structural difference vs the accounting connectors — banks legally require user re-authentication every 90 days regardless of refresh-token TTL.

---

## Capabilities

| Function | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
|---|---|---|---|---|
| `OpenBankingClient` (class) | HTTP wrapper: provider-aware base URL + OAuth attach + rate-limit + 429 / 5xx retry | constructed in cycle.sh Step 1 | n/a (transport) | n/a |
| `loadTokens(config)` | Read OAuth tokens from disk (includes consent_expires_at_ms) | Step 1 | n/a (read-only) | n/a |
| `saveTokens(config, t)` | Atomic write (.tmp + rename) | refreshTokens internal | n/a | n/a |
| `refreshTokens(config, current, fetchFn?, now?)` | OAuth refresh; provider-aware; concurrent-safe per (provider, connection_id); **refuses if consent is in blocking window** | Step 1 | `open_banking_truelayer` or `open_banking_plaid_uk` | green |
| `shouldRefresh(tokens, now?, window?)` | Returns true if access_token expires within window (default 5 min) | Step 1 + per-call | n/a (pure) | n/a |
| `getTokenAgeStage(tokens, now?)` | Returns `{stage, days_until_consent_expiry}` — pure function over PSD2 lifecycle; classifies into fresh / info / warn / blocking | operator alerting | n/a (pure) | n/a |
| `listTransactionsSince(client, config, options)` | List bank transactions on/after a timestamp; provider-agnostic shape; TrueLayer raw payload preserved in `raw_provider_payload` | Step 3 (transaction ingest) | n/a (read-only) | n/a |
| `getAccountBalance(client, config)` | Current account balance (available + cleared) | Step 10 (cash-flow forecast) | n/a (read-only) | n/a |

All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `open_banking_truelayer` is queued for addition at first Cash Conductor cycle.sh wiring (W7).

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

Conservative per-provider buckets per `src/rate-limit.ts`:

| Provider | Hard cap | Soft (80%) | Notes |
|---|---|---|---|
| TrueLayer | 30 calls/min per (provider, connection_id) | 24/min | Published prod limits are not publicly numbered; sandbox is constrained. We use a conservative 30/min ceiling. Tunable when Cash Conductor cycle.sh telemetry shows actual usage patterns. |
| Plaid UK | 30 calls/min per (provider, item_id) | 24/min | Plaid Standard tier published cap. |

State is in-process and per-(provider, connection_id) — a multi-bank-account runtime that holds many `OpenBankingClient` instances in one process still gets correct isolation.

---

## Retry policy

| Capability | Method | Max retries | Backoff | On exhaustion |
|---|---|---|---|---|
| `listTransactionsSince` / `getAccountBalance` | GET | 2 | Exponential w/ jitter (250-1000ms) | `OpenBankingError` or `OpenBankingRateLimitError` |
| `refreshTokens` | POST | **0** | n/a | `OpenBankingAuthError` / `OpenBankingConsentExpiredError` (caller re-auths) |
| 401 from any GET | — | force-refresh access_token, retry once | — | `OpenBankingAuthError` |
| 429 from any GET | — | honour `Retry-After` header | jittered backoff if no header | `OpenBankingRateLimitError` |

This connector has NO write operations — banks don't generally expose write APIs in the scope Cash Conductor needs. So all calls are read-only; the only state-changing op is OAuth refresh (which has its own consent-aware refusal logic).

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

# Live API tests (requires real TrueLayer sandbox credentials; off by default)
MCP_LIVE_TESTS=true pnpm test
```

**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`; live tests are gated on `MCP_LIVE_TESTS=true`.

Test counts (W4 Day-26 scaffold):
- `tests/scaffold.test.ts`: 5 (public surface, exports, full error hierarchy with NotImplementedError)
- `tests/rate-limit.test.ts`: 5 (initial state, soft 24, hard 30, per-(provider, connection) isolation)
- `tests/token-aging.test.ts`: 6 (property-based day 0-100 boundary: fresh, info, warn, blocking, negative/already-expired, days_until consistency)
- `tests/auth.test.ts`: 8 (load missing, round-trip, shouldRefresh, refresh success + consent_expires preserved, 401 + no-token-leak, **blocking-consent refuses refresh**, concurrent dedup, Plaid-UK NotImplementedError)
- `tests/capabilities.test.ts`: 4 (TrueLayer transactions + balance from fixtures; Plaid UK NotImplementedError for both)

**Total: 28 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).

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
