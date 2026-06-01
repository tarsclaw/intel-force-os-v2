# @ifos/xero

Xero Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 token rotation + invoice read + payment read/write. Fixture-first; live API gated behind `MCP_LIVE_TESTS=true`.

**Status:** Proposed (W4 Day-25 overnight scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial Xero signup for live-test verification).

**Reference pattern:** mirrors `@ifos/companies-house` (Day-13 RATIFIED). Every new MCP connector follows this structure per `review-mcp-connector.md` §1.

---

## Capabilities

Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.

| Capability ID (tools.yaml) | Function (src/index.ts) | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
|---|---|---|---|---|---|
| `xero_oauth` | `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per tenant; atomic-file-write persistence | Step 1 (auth refresh) | `xero_oauth` | green |
| `xero_list_open_invoices` | `listOpenInvoices(client, options?)` | Page through AUTHORISED+SUBMITTED invoices with AmountDue > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
| `xero_get_invoice` | `getInvoice(client, invoiceId, options?)` | Fetch single invoice by Xero InvoiceID | Step 9 (chase-draft validation) | n/a | n/a |
| `xero_list_payments` | `listPayments(client, options?)` | List ACCRECPAYMENT records (reconciliation context) | Step 5 (reconciliation pass) | n/a | n/a |
| `xero_write_payment_received` | `writePaymentReceived(client, payment)` | PUT /Payments — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |

All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (verified 2026-06-01 Codex F-R2 closure — `xero_oauth` registered as green at line 158; `accounting_reconciliation_write` already present at line 209).

### Internal helpers (NOT bus-routed capabilities)

Exposed by `src/index.ts` for consumer convenience + testing, but NOT declared in `tools.yaml`:

| Function | Purpose |
|---|---|
| `XeroClient` (class) | Transport — constructed once by cycle.sh Step 1; not a capability in the bus sense (no `action_type`; no authz check) |
| `loadTokens(config)` / `saveTokens(config, t)` | Token-file I/O — called by `refreshTokens`; surfaced for test setup and operator-shell consent-bootstrap helpers |
| `shouldRefresh(tokens, now?, window?)` | Pure predicate — `true` when the access_token expires within `safety_window_ms` (default 5 min); callers use it to decide eager-refresh |
| `rateCheck(tenant_id, now?)` | Returns `RateState` — exposes the **soft-backoff signal** (`shouldBackoff: true` at 80% of either bucket); the consuming cycle.sh is responsible for honouring it (see §Rate limits) |
| `rateConsume(tenant_id, now?)` | Consumes a slot; returns false at the hard 100% gate — the soft signal is read-only |
| `resetRateLimit(tenant_id?)` | Test/diagnostic reset |
| `_resetInflightForTest()` | Clears in-flight OAuth-refresh dedup map; for tests only |
| `XeroCache` (class) | Disk cache — default TTL 5min; surfaced for cache-aware test cases |

---

## Quick start

```typescript
import { XeroClient, listOpenInvoices, writePaymentReceived } from "@ifos/xero";

const client = new XeroClient({
  config: {
    client_id: process.env.XERO_CLIENT_ID!,
    client_secret: process.env.XERO_CLIENT_SECRET!,
    tenant_id: "<xero-tenant-id-from-connections-endpoint>",
    token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/xero-tokens.json`,
  },
});

const invoices = await listOpenInvoices(client, { issued_since: "2026-04-01" });
for (const inv of invoices) {
  if (matchesBankDeposit(inv)) {
    await writePaymentReceived(client, {
      Invoice: { InvoiceID: inv.InvoiceID },
      Account: { Code: "090" },
      Date: "2026-05-22",
      Amount: inv.AmountDue,
      Reference: bankReference,
    });
  }
}
```

---

## OAuth bootstrap (one-time, per Xero tenant)

The connector handles the **refresh** half of OAuth 2.0. The **initial authorisation** (consent screen → authorisation code → first token pair) is a one-time human-in-the-loop dance not covered here. Bootstrap procedure (manual):

1. Register the IFOS app at https://developer.xero.com/ → get `client_id` + `client_secret`.
2. Construct the authorise URL with `response_type=code` + `scope=offline_access accounting.transactions accounting.contacts.read` + your `redirect_uri`.
3. User clicks → consents → Xero redirects to `redirect_uri?code=<auth_code>`.
4. POST to `https://identity.xero.com/connect/token` with `grant_type=authorization_code` + the code → receive `{access_token, refresh_token, expires_in}`.
5. Call `GET https://api.xero.com/connections` with the access_token → get the `tenant_id` (Xero "connection ID").
6. Write the token bundle to `token_file_path` as JSON; mode 0600.

After bootstrap, this connector's `refreshTokens()` handles all subsequent rotations automatically.

---

## Rate limits

Per the published Xero limits page (https://developer.xero.com/documentation/guides/oauth2/limits):

- **60 calls / 60-second window per app per tenant** (minute bucket)
- **5000 calls / day per tenant** (daily bucket, resets at midnight UTC)
- **5 concurrent calls per app per tenant** — not enforced here; single-process Cash Conductor cycle.sh is serial

This connector tracks BOTH windows per `src/rate-limit.ts`. **Hard gate at 100%** (`consume()` returns false → `XeroRateLimitError`). **Soft signal at 80%** (48/minute, 4000/day) is read-only and exposed via `rateCheck()` — `RateState.shouldBackoff === true` with `reason: "minute-soft" | "daily-soft"`. The consuming agent layer (Cash Conductor cycle.sh) is responsible for honouring the soft signal (e.g. pausing batch operations); the connector does not silently throttle — the contract is "callers query soft, connector enforces hard". `tests/rate-limit.test.ts` exercises both thresholds (`hits soft backoff at minute-soft (48)` + `hits hard fail at minute-hard (60)`).

State is in-process and per-tenant — a multi-tenant runtime that holds many `XeroClient` instances in one process still gets correct isolation.

**ESC contract on bucket exhaustion** (consumer-emitted via `agents/_shared/hook-helpers.sh`):

| Failure | Surfaces as | ESC code (escalation-codes.md) | Payload contract |
|---|---|---|---|
| Local hard-gate (100%) reached | `XeroRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "xero", retry_after_seconds: null, consecutive_429s: 0}` |
| Upstream 429 from Xero API | `XeroRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "xero", retry_after_seconds: <N>, consecutive_429s: <N>}` |

Both surface as the same ESC code because from the operator's perspective they're the same operational signal (Xero traffic is being throttled). The distinction is in the payload (`retry_after_seconds: null` means local pre-emptive vs upstream-issued).

---

## Retry policy

| Capability | Method | Max retries | Backoff | On exhaustion |
|---|---|---|---|---|
| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `XeroError` or `XeroRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
| `writePaymentReceived` | PUT | **0** | n/a (writes never auto-retry) | `XeroValidationError` (400) / `XeroError` (5xx) → `ESC_ACCOUNTING_WRITE_FAIL` (warn; operator; consumer-emitted; payload includes `provider: "xero"`, `endpoint: "/Payments"`, `status_code`, `error_body_preview`) |
| `refreshTokens` | POST | **0** | n/a | `XeroAuthError` → `ESC_ACCOUNTING_AUTH` (blocking; consumer-emitted; caller may re-attempt with fresh credentials per Bootstrap §) |
| 401 from any GET | — | force-refresh access_token, retry once | — | `XeroAuthError` → `ESC_ACCOUNTING_AUTH` |
| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `XeroRateLimitError` → `ESC_RATE_LIMIT_HIT` |

Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to Xero.

The connector itself does NOT write `decision_log` rows (vault/Postgres split per ADR-002); the consuming `cycle.sh` catches the typed errors above and emits the right ESC via `hh_decision_action`/`hh_decision_output` from `agents/_shared/hook-helpers.sh`.

---

## Error hierarchy

```
XeroError                  // base
├── XeroAuthError          // OAuth refresh fail (401/4xx on token endpoint)
├── XeroRateLimitError     // 429 OR local bucket exhausted
├── XeroNotFoundError      // 404
└── XeroValidationError    // 400 (typically schema/business-rule)
```

Errors NEVER include credential values in their `.message` — only the key NAMES, status code, and safe metadata. Per `review-mcp-connector.md` §5 (zero secret interpolation).

---

## Tests

```bash
# Unit + fixture tests (fast; no network)
pnpm test

# Live API tests (requires real Xero sandbox credentials; off by default)
MCP_LIVE_TESTS=true pnpm test
```

**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`; live tests are gated on `MCP_LIVE_TESTS=true`.

Test counts (W4 Day-25 overnight scaffold):
- `tests/scaffold.test.ts`: 5 (public surface, exports, error hierarchy)
- `tests/rate-limit.test.ts`: 5 (initial state, soft 48, hard 60, per-tenant isolation, etc.)
- `tests/auth.test.ts`: 7 (load missing, round-trip, shouldRefresh, refresh success, 401 + no-token-leak, concurrent dedup, etc.)
- `tests/capabilities.test.ts`: 6 (list/get invoice happy + 404, list/write payment happy + 400)

**Total: ≥23 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).

---

## Build

```bash
pnpm build       # tsup → dist/index.{js,d.ts}
pnpm typecheck   # tsc --noEmit
```

ESM-only; node 20+; target ES2022. Same toolchain as @ifos/companies-house.

---

## Where this fits in the IFOS architecture

```
agents/recruitment/cash-conductor/cycle.sh
   │
   ├── Step 1 (auth refresh)            ──┐
   ├── Step 4 (invoice register ingest) ──┤
   ├── Step 5 (reconciliation pass)     ──┼─→ @ifos/xero (this package)
   ├── Step 6 (reconciliation write)    ──┤    │
   └── Step 9 (chase-draft validation)  ──┘    │
                                              ↓
                                         Xero REST API
                                         https://api.xero.com/api.xro/2.0
                                              ↓
                                         OAuth bearer +
                                         Xero-tenant-id header
```

Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is the substrate it consumes.

---

## Boundary checks

Per `review-mcp-connector.md` §8:
- ✓ No Composio / AgentMail references
- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)
- ✓ No hardcoded tenant slugs in `src/` (test fixtures only — `fixture-tenant`, `test-tenant-rate-limit`)

---

*v0.1.0 — scaffold landed 2026-05-31 overnight.*
