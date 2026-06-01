# @ifos/quickbooks

QuickBooks Online (QBO) Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 with **per-realm** token rotation + invoice read + payment read/write. Fixture-first; live API gated behind `MCP_LIVE_TESTS=true`.

**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial QB sandbox signup for live-test verification).

**Reference pattern:** mirrors `@ifos/xero` (W4 Day-25 RATIFIED scaffold). The per-realm OAuth diff vs Xero's per-tenant header is the load-bearing structural difference — documented in §"OAuth bootstrap" below. Every new MCP connector follows the parity model per `review-mcp-connector.md` §1.

---

## Capabilities

| Function | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
|---|---|---|---|---|
| `QbClient` (class) | HTTP wrapper: OAuth attach + rate-limit budget + 429 / 5xx retry + per-realm URL construction | constructed in cycle.sh Step 1 | n/a (transport) | n/a |
| `loadTokens(config)` | Read OAuth tokens from disk | Step 1 (auth refresh) | n/a (read-only) | n/a |
| `saveTokens(config, t)` | Atomic write (.tmp + rename) to token file | refreshTokens internal | n/a | n/a |
| `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per realm; returns + persists new bundle | Step 1 | `quickbooks_oauth` | green |
| `shouldRefresh(tokens, now?, window?)` | Returns true if access_token expires within window (default 5 min) | Step 1 + per-call | n/a (pure) | n/a |
| `refreshTokenNearExpiry(tokens, now?, danger?)` | Returns true if refresh token within 7-day re-consent danger window (QB ~100-day TTL) | operator alerting | n/a (pure) | n/a |
| `listOpenInvoices(client, options?)` | Query API: paginated Invoice rows with Balance > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
| `getInvoice(client, invoiceId, options?)` | Single-entity read by QB Id | Step 9 (chase-draft validation) | n/a | n/a |
| `listPayments(client, options?)` | Query API: Payment rows since date | Step 5 (reconciliation pass) | n/a | n/a |
| `writePaymentReceived(client, payment)` | POST /payment — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |

All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `quickbooks_oauth` is queued for addition at first Cash Conductor cycle.sh wiring (W7); `accounting_reconciliation_write` is already present (shared with @ifos/xero per Day-25 verification).

---

## Quick start

```typescript
import { QbClient, listOpenInvoices, writePaymentReceived } from "@ifos/quickbooks";

const client = new QbClient({
  config: {
    client_id: process.env.QB_CLIENT_ID!,
    client_secret: process.env.QB_CLIENT_SECRET!,
    realm_id: "<realmId-from-connections-callback>",
    environment: "sandbox", // or "production"
    token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/qb-tokens-<realmId>.json`,
  },
});

const invoices = await listOpenInvoices(client, { issued_since: "2026-04-01" });
for (const inv of invoices) {
  if (matchesBankDeposit(inv)) {
    await writePaymentReceived(client, {
      CustomerRef: { value: inv.CustomerRef.value },
      TotalAmt: inv.Balance,
      TxnDate: "2026-05-22",
      PaymentRefNum: bankReference,
      Line: [
        {
          Amount: inv.Balance,
          LinkedTxn: [{ TxnId: inv.Id, TxnType: "Invoice" }],
        },
      ],
    });
  }
}
```

---

## OAuth bootstrap (one-time, per QB Online company / realm)

Unlike Xero (one connection = one tenant_id sent as header), QuickBooks is **per-realm**: each connected company has a unique `realmId`, and tokens are realm-scoped. If you connect IFOS to 3 different QB companies, you have 3 separate token bundles + 3 separate base URLs (`/v3/company/<realmId>/...`).

**Bootstrap procedure (manual, one-time per QB company):**

1. Register the IFOS app at https://developer.intuit.com/ → get `client_id` + `client_secret`.
2. Construct the authorise URL with `scope=com.intuit.quickbooks.accounting` + `response_type=code` + your `redirect_uri`.
3. User clicks → consents → Intuit redirects to `redirect_uri?code=<auth_code>&realmId=<realm>&state=...`.
4. POST to `https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer` with Basic auth (Base64 client_id:client_secret) + `grant_type=authorization_code` + the code → receive `{access_token, refresh_token, expires_in, x_refresh_token_expires_in}`.
5. The `realmId` from step 3's redirect IS the realm — save it alongside the tokens.
6. Write the token bundle to `token_file_path` as JSON; mode 0600. The connector handles all subsequent rotations.

**Key QB vs Xero diffs:**

| | Xero | QuickBooks |
|---|---|---|
| Per-tenant identifier | `tenant_id` (header `Xero-tenant-id`) | `realmId` (path component) |
| Token endpoint | `https://identity.xero.com/connect/token` | `https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer` |
| Access token TTL | 30 min | ~60 min |
| Refresh token TTL | 60 days (rolls) | ~100 days (rolls) — `x_refresh_token_expires_in` returned in response |
| Base URL | `https://api.xero.com/api.xro/2.0` (constant) | `https://quickbooks.api.intuit.com/v3/company/<realmId>` (production) or `https://sandbox-quickbooks.api.intuit.com/...` (sandbox) |
| Read pattern | REST resource endpoints (e.g. `/Invoices?where=...`) | Query API: `GET /query?query=SELECT * FROM Invoice WHERE ...` |
| Write pattern | PUT `/Payments` (entity endpoint) | POST `/payment` (entity endpoint) |

After bootstrap, this connector's `refreshTokens()` handles all subsequent rotations automatically. Note that QB refresh tokens have a hard ~100-day TTL — if no refresh happens for that long, you must re-do the consent dance. `refreshTokenNearExpiry()` returns true when within the 7-day danger window so operator alerts can fire.

---

## Rate limits

Per the published Intuit limits page (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):

- **500 calls / 60-second window per app per realmId** (minute bucket)
- **10 calls per second concurrent throttle** (not enforced here — single-process Cash Conductor cycle.sh is serial)
- No published daily cap

This connector tracks the minute bucket per `src/rate-limit.ts`. Soft backoff at 80% (400/minute); hard fail at 100% → `QbRateLimitError`. State is in-process and per-realm — a multi-realm runtime that holds many `QbClient` instances in one process still gets correct isolation.

If you see `QbRateLimitError` consistently in Cash Conductor logs, the polling interval is too tight; tune the cycle's invoice-register ingest frequency.

---

## Retry policy

| Capability | Method | Max retries | Backoff | On exhaustion |
|---|---|---|---|---|
| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` or `QbRateLimitError` |
| `writePaymentReceived` | POST | **0** | n/a (writes never auto-retry) | `QbValidationError` (400) / `QbError` (5xx) |
| `refreshTokens` | POST | **0** | n/a | `QbAuthError` (caller may re-attempt with new credentials) |
| 401 from any GET | — | force-refresh access_token, retry once | — | `QbAuthError` |
| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `QbRateLimitError` |

Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to QB.

---

## Error hierarchy

```
QbError                  // base
├── QbAuthError          // OAuth refresh fail (401/4xx on token endpoint)
├── QbRateLimitError     // 429 OR local bucket exhausted
├── QbNotFoundError      // 404
└── QbValidationError    // 400 (typically Fault.type=ValidationFault)
```

Errors NEVER include credential values in their `.message` — only the key NAMES, status code, and safe metadata. Per `review-mcp-connector.md` §5 (zero secret interpolation).

---

## Tests

```bash
# Unit + fixture tests (fast; no network)
pnpm test

# Live API tests (requires real QB sandbox credentials; off by default)
MCP_LIVE_TESTS=true pnpm test
```

**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`; live tests are gated on `MCP_LIVE_TESTS=true`.

Test counts (W4 Day-26 scaffold):
- `tests/scaffold.test.ts`: 5 (public surface, exports, error hierarchy)
- `tests/rate-limit.test.ts`: 5 (initial state, soft 400, hard 500, per-realm isolation, etc.)
- `tests/auth.test.ts`: 7 (load missing, round-trip, shouldRefresh, refreshTokenNearExpiry, refresh success, 401 + no-token-leak, concurrent dedup)
- `tests/capabilities.test.ts`: 6 (list/get invoice happy + 404, list/write payment happy + 400)

**Total: 23 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).

---

## Build

```bash
pnpm build       # tsup → dist/index.{js,d.ts}
pnpm typecheck   # tsc --noEmit
```

ESM-only; node 20+; target ES2022. Same toolchain as @ifos/companies-house + @ifos/xero.

---

## Where this fits in the IFOS architecture

```
agents/recruitment/cash-conductor/cycle.sh
   │
   ├── Step 1 (auth refresh)            ──┐
   ├── Step 4 (invoice register ingest) ──┤
   ├── Step 5 (reconciliation pass)     ──┼─→ @ifos/quickbooks (this package)
   ├── Step 6 (reconciliation write)    ──┤    │
   └── Step 9 (chase-draft validation)  ──┘    │
                                              ↓
                                         QuickBooks Online v3 REST API
                                         https://quickbooks.api.intuit.com/v3/company/<realmId>
                                              ↓
                                         OAuth bearer (no tenant header — realm in URL)
```

Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is one of three accounting substrate options consumed (Xero / QuickBooks / Sage — Sage deferred per Cash Conductor §9 Q8).

---

## Boundary checks

Per `review-mcp-connector.md` §8:
- ✓ No Composio / AgentMail references
- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)
- ✓ No hardcoded tenant slugs in `src/` (test fixtures only — `fixture-realm`, `test-realm-rate-limit`)

---

*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*
