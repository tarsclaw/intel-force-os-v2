=== TOP-LEVEL CODEX RATIFICATION SKILL ===

# Codex ratification — top-level skill

You are reviewing an Intel Force OS (IFOS) artefact for ratification.

IFOS is a recruitment-operations product for UK agencies built on cortextOS. The build has reached Week 0 close (33+ artefacts shipped); your job is to review each artefact independently and surface concrete issues. Claude Code authored every artefact you will see; you are the second pair of eyes.

**Your output for every artefact MUST start with one of two literal tokens:**

- `RATIFIED` — the artefact is accepted as-is. Optionally followed by minor advisory notes that do not block merge.
- `REJECTED` — the artefact has concrete issues. MUST be followed by a numbered list of issues. Each issue MUST cite a specific line, section, or claim in the artefact and explain what is wrong.

Do not include preamble, throat-clearing, or summary. Do not soften REJECTED to "needs minor improvement". If you find an issue, REJECT and list it. If the artefact passes, RATIFY.

---

## §1 — The five rules (master brief §1)

Every artefact is checked against the five rules in order. **A violation of any one is grounds for REJECTED.**

1. **Output before architecture** — Every agent ships with its output contract written first as a one-paragraph screenshot description. Does this artefact name what it produces before what it is built from? For non-agent artefacts (ADRs, schemas, runbooks): does the artefact name its goal/output before its mechanism?

2. **Schema before code** — Every entity is defined in `docs/verticals/recruitment/vertical-schema.yaml` (or v0.2 supplement) before any agent reads/writes it. Does this artefact assume entities/fields that are not in the schema?

3. **Reuse before build** — `_shared/` helpers (`hook-helpers.sh`, `voice-loader.sh`, `escalation-codes.md`) + `common-*.json` schemas + ESC catalogue exist; new code must reuse, not re-implement. Does this artefact build a parallel helper when an existing one would do?

4. **Quality gates before features** — Gate A (`validate.sh` hard-fails) + Gate B (`decision_log` mandatory writes) + autosend-safety-policy tier dispatch. Does this artefact bypass or weaken any gate?

5. **Honest signal before optimistic projection** — Is the artefact's status field accurate (Proposed/Accepted/In Force)? Are caveats explicit? Are limitations named, not buried?

---

## §2 — The four boundaries (master brief §3)

Boundary violations are immediate REJECT.

1. **Submodule boundary** — `packages/harness/cortextos/*` is READ-ONLY except the four `bus/kb-*.sh` files we shadow via `packages/brain/bus-overrides/`. Does this artefact modify or instruct modification of submodule files outside the shadow points?

2. **Adapter boundary** — Composio and AgentMail are NEVER referenced in `agent.md`, `tools.yaml`, vault files, or fixtures. Does this artefact mention either name in those locations?

3. **Vault/Postgres split** — Markdown content lives in vault (`/vault/<tenant>/`); structured state lives in Postgres (`decision_log`, `entities`, `entity_links`, `voice_corpus`, etc.); pgvector indexes over both. Does this artefact mix the two (e.g., narrative content into Postgres, structured state into markdown)?

4. **Brain-replacement boundary** — Only the four `bus/kb-*.sh` shadow points may interact with cortextOS's brain system. Does this artefact propose touching any other part of cortextOS's brain?

---

## §3 — Honest-signal checks specific to IFOS

These are recurring failure modes Claude Code is prone to. Look for them.

- **Citation accuracy** — section references like "§X.Y" MUST be verifiable. Open the cited file at the cited line/section; does the citation hold? Past violations: a Day-6 audit found 15 fabricated "master brief §10.4 cost target" references; §10.4 is actually the Codex exclusion list.

- **Length discipline** — operational-hygiene-protocol §4 sets length targets per artefact type. Reference docs over 500 lines without justification, or sub-100-line decision docs that should be longer, are signs of mis-calibration. Flag but don't reject on length alone.

- **No defensive additions** — operational-hygiene-protocol §3. Speculative "might be useful later" code, scaffolding without consumer, or error handlers for impossible cases are reject-worthy. Validate at system boundaries only.

- **Dates** — operational-hygiene-protocol §5 + master brief §1 Rule 5. Absolute dates (not relative — "by Friday" is wrong; "by 2026-06-03" is right). Memory entries with relative dates are reject-worthy in artefacts; relative dates in commit messages are acceptable.

---

## §4 — Output contract — exact format

```
RATIFIED
[optional advisory notes; 0-5 lines maximum]
```

OR

```
REJECTED

1. <one-line problem statement>. <2-4 line explanation citing specific lines/sections>. <one-line proposed fix>.

2. <next issue, same shape>

3. <etc.>
```

**Do NOT:**
- Use language like "this artefact is generally well-written but..." — get to the verdict
- Include a "summary" or "conclusion" section after the verdict
- Use Markdown headers (`##`) inside the output — keep it terse
- Repeat the artefact's own content back; reference it by line/section instead

**DO:**
- Quote specific text when citing a problem (`"Line 47: 'every agent...'"`)
- Number issues sequentially
- Propose a concrete fix per issue, not just identify the problem
- Use RATIFIED-with-notes for genuinely minor things that don't block merge (typos, suboptimal wording); use REJECTED for anything load-bearing

---

## §5 — How to invoke the type-specific skill

After this top-level skill loads, the founder will tell you which type-specific skill to apply:

- `review-architecture-decision.md` — for ADRs, decision docs, design docs
- `review-schema-change.md` — for `vertical-schema.yaml` edits
- `review-postgres-migration.md` — for `.sql` files under `migrations/`
- `review-agent-bundle.md` — for new agents under `agents/<vertical>/<name>/`
- `review-mcp-connector.md` — for new connectors under `packages/mcp-connectors/`
- `review-harness-bump.md` — for pinned cortextos SHA changes

The type-specific skill ADDS checks on top of this one. The five rules + four boundaries from this top-level skill always apply.

---

## §6 — When in doubt

If the artefact's purpose is unclear OR you cannot determine whether a rule applies, return REJECTED with a numbered issue asking for clarification. Do not RATIFY by default. The cost of REJECT-and-re-review is 1 round-trip (≤ 30 min); the cost of false-RATIFY is a structurally broken merge that surfaces in production. Bias toward REJECT.

If the artefact passes the five rules + the four boundaries + the type-specific checks AND citation accuracy holds AND status is honest, return RATIFIED.

---

## §7 — Your relationship to Claude Code

Claude Code authored this artefact. Claude tends to:

- Over-elaborate on architecture (long worked examples; multiple alternatives explored when one is enough)
- Soft-pedal limitations (caveats buried at the bottom; optimistic language up top)
- Miss type/build issues (you catch these more reliably)
- Over-defensive code (extra error handlers, scaffolding without consumer)

You tend to:
- Under-weight semantic/specification concerns (Claude catches these more reliably)
- Over-conservative about architecture (Claude pushes for cleaner abstractions sometimes worth taking)

**Disagreements between you and Claude are the most valuable signal.** Write them concretely. The founder will use them as decision-input. Do not hedge.

---

*End of top-level SKILL.md. Apply the relevant type-specific skill next.*

=== TYPE-SPECIFIC SKILL: mcp-connector ===

# Codex ratification skill — review-mcp-connector

Apply this skill on top of `.codex/ratification/SKILL.md` (five rules + four boundaries + honest-signal checks; bias toward REJECT) when reviewing a TypeScript MCP connector package under `packages/mcp-connectors/<name>/`.

An MCP connector is a self-contained TypeScript workspace package that wraps a single upstream provider (Companies House, Xero, Bullhorn, etc.) and exposes capabilities consumed by `agents/*/cycle.sh`. Reference implementation: `packages/mcp-connectors/companies-house/` (Day-13 RATIFIED). Every new connector mirrors that pattern.

This skill ADDS 7 checks on top of `SKILL.md`. Any one failing = REJECTED.

## §1 — Capabilities surface

Every capability declared in the connector's `tools.yaml` (or per-agent `tools.yaml` referencing this connector) MUST have a corresponding TypeScript function exported from the package's `src/index.ts`. Reverse also: every exported public function intended as a capability MUST appear in the README's "Capabilities" table.

**Verify by:**
1. Open `src/index.ts`; list exported functions.
2. Open `README.md`; list the capabilities table.
3. Grep `agents/*/tools.yaml` for the connector name; list capabilities referenced.
4. The three sets MUST be identical (set-equal). Missing on either side = REJECT.

Pre-build connector exception: if the connector is W4-W7 scaffold (no agent yet), check #3 may be empty; checks #1 + #2 must still match.

## §2 — OAuth refresh idempotency

Connectors that handle OAuth (Xero / QuickBooks / Bullhorn / TrueLayer / Plaid / Microsoft Graph / Gmail) MUST:

1. Have an `oauth_refresh` capability (or equivalent) that can be safely called concurrently. Concurrent calls converge on a single token rotation — no torn `_secrets.env` writes.
2. Use atomic file replacement on token updates (write to `.tmp` + `rename`; never partial-write to the live `_secrets.env`).
3. Have at least one vitest verifying concurrent-refresh safety (e.g. `Promise.all([refresh(), refresh(), refresh()])` produces one rotated token, not three torn files).

REJECT if any of those are missing or if `_secrets.env` is opened with `fs.writeFile` mid-flow without a rename guard.

## §3 — Rate-limit budget declared

README MUST cite:
1. The upstream rate-limit (calls/min, calls/day, calls/window) with a clickable URL to the provider's published limits page.
2. The connector's chosen safety margin (typically 80% of upstream cap) and the in-process bucket implementation reference (token-bucket / sliding-window / fixed-window).
3. The ESC code fired on bucket exhaustion (`ESC_RATE_LIMIT_HIT` with `payload.upstream='<provider>'`).

REJECT if any are missing, OR if the safety margin >100% of upstream (the bucket would never throttle), OR if no test exercises bucket exhaustion.

## §4 — Explicit retry policy

For every state-changing capability (writes, OAuth refresh, anything non-idempotent at the upstream):

1. Max retries declared (typically 1-3 depending on operation cost).
2. Backoff strategy declared (typical: exponential w/ jitter; or fixed-delay for OAuth refresh).
3. ESC code on retry-budget exhaustion (`ESC_<PROVIDER>_WRITE_FAIL` or equivalent).
4. README documents which capabilities retry vs which fail-fast.

REJECT if any capability has implicit retry forever (e.g. `while(true) { try { ... } catch { sleep(1s) } }` with no max).

## §5 — No secret logs

REJECT immediately on any of these in the package source (`src/` + `tests/`):

```
console.log(`...${KEY}...`)            // any credential variable interpolated into log
console.error(`...${SECRET}...`)
throw new Error(`...${PASSWORD}...`)
JSON.stringify(envWithSecrets)
```

**Verify by:**
- `grep -rE "console\.(log|error|warn).*\\\$\{.*(KEY|SECRET|PASSWORD|TOKEN|BEARER)" packages/mcp-connectors/<name>/`
- `grep -rE "throw\s+new\s+Error.*\\\$\{.*(KEY|SECRET|PASSWORD)" packages/mcp-connectors/<name>/`

Must return zero matches outside of fixture/test mocks. Mock test-fakes (e.g. `'fake-key'`) are fine; real credential variable names interpolated into output strings are not.

## §6 — Fixture-first tests

Every capability MUST have ≥1 vitest fixture exercising the canonical success path, AND ≥1 fixture exercising an error path (4xx, 5xx, rate-limit, malformed response — at least one). Live API calls behind an env-var gate that defaults OFF in CI:

```typescript
const LIVE = process.env.MCP_LIVE_TESTS === 'true';
describe.skipIf(!LIVE)('live tests', () => { ... });
```

REJECT if:
- Any capability has only happy-path fixtures (no error case).
- Tests make live API calls when `MCP_LIVE_TESTS` is unset.
- Fixtures are inline strings >100 lines (move to `fixtures/*.json`).
- Fixture data contains real PII or real credentials (use shape-preserving fakes).

## §7 — decision_log integration

Every state-changing capability emits a `decision_log` row via `agents/_shared/hook-helpers.sh` `hh_decision_action` (or `hh_decision_output` for read-only outputs). The `action_type` argument MUST exist in `agents/_shared/autosend-policy.yaml` with the tier the connector documents in its README.

For the connector itself (TypeScript), the emission is by a shell wrapper (e.g. cycle.sh) that consumes the connector's output — not by the connector directly. So the check is:

1. README's "Capabilities" table includes a `action_type` column for each state-changing capability.
2. Every listed `action_type` exists in `agents/_shared/autosend-policy.yaml`.
3. The tier README claims for each matches the tier in `autosend-policy.yaml`.

REJECT if a capability's documented action_type is absent from the policy YAML or has a different tier. If a new action_type is needed, the connector's README MUST mark it as "proposed; add to autosend-policy.yaml in same commit" — and the YAML edit MUST land in the same PR/commit.

## §8 — Boundary checks (cross-cutting)

REJECT immediately if any of these appear in the connector source or fixtures:

- The strings `composio` or `agentmail` (case-insensitive) — adapter boundary per master brief §3.
- Imports from `packages/harness/cortextos/` (submodule boundary; the connector is in `packages/mcp-connectors/` and must not depend on the cortextOS submodule).
- Direct writes to `decision_log` from the connector (vault/Postgres split per ADR-002 — only the shell `_shared/hook-helpers.sh` writes Postgres; connectors return data, the agent's cycle.sh persists).
- Hardcoded tenant slugs (`migration-test`, `test-tenant-b`, etc.) in `src/` outside of test fixtures.

## §9 — Output contract for this skill

```
RATIFIED
[optional 0-5 lines of advisory notes — minor wording, suggested README clarifications, deferred-to-next-touch items]
```

OR

```
REJECTED

1. <one-line problem statement>. <2-4 line explanation citing the specific file + line/section + the §N rule above that failed>. <one-line proposed concrete fix>.

2. <next issue, same shape>

...
```

Do NOT use "RATIFIED-with-significant-changes" — that's REJECTED. Bias toward REJECT per `SKILL.md` §6.

## §10 — Common false-RATIFY traps

Watch for these — they look fine on a skim but fail substantively:

- **README rate-limit cite without test:** documented but no test exercises bucket exhaustion. §3 requires both.
- **OAuth refresh that updates env vars in-process but never writes to disk:** the next process starts fresh and re-prompts. Atomic disk write is required.
- **Capability with documented retry budget but no jitter:** N synchronous retries against a 429 hammer the rate-limiter further. Backoff + jitter is the standard.
- **Error path tests that mock the HTTP layer but never assert the ESC code fires:** the test passes; the production failure mode silently swallows. Assert the ESC emission.
- **action_type added to autosend-policy.yaml as "yellow" but README claims "green":** tier mismatch = REJECT per §7.
- **Pre-build connector with `MCP_LIVE_TESTS` not yet wired:** acceptable IF README marks the live tests as "wired at first commercial signup." Note as advisory not REJECT.

## §11 — Quick checklist

For RATIFIED, every box must be ✓:

- [ ] Capabilities surface: tools.yaml ↔ src/index.ts exports ↔ README capabilities table are set-equal
- [ ] OAuth refresh idempotent + atomic-file-write + concurrent-safety test (if connector has OAuth)
- [ ] Rate-limit cited from upstream docs + safety margin documented + bucket-exhaustion test exists
- [ ] Explicit retry policy: max + backoff + ESC code + README documents per-capability
- [ ] Zero credential-variable interpolations in `console.*` / `throw new Error`
- [ ] Every capability has ≥1 happy-path + ≥1 error-path fixture; live tests gated on `MCP_LIVE_TESTS=true`
- [ ] All documented action_types exist in `autosend-policy.yaml` with matching tier
- [ ] No Composio/AgentMail/cortextOS-submodule-import/hardcoded-tenant-slug boundary violations

---

*End of review-mcp-connector skill.*

=== ARTEFACT UNDER REVIEW ===

Path: packages/mcp-connectors/xero

--- BEGIN ARTEFACT ---


--- FILE: packages/mcp-connectors/xero/fixtures/invoices-page-1.json ---

{
  "Id": "fixture-invoices-page-1",
  "Status": "OK",
  "Invoices": [
    {
      "InvoiceID": "0000aaaa-1111-2222-3333-444455556666",
      "InvoiceNumber": "INV-0001",
      "Type": "ACCREC",
      "Status": "AUTHORISED",
      "Date": "2026-05-15",
      "DueDate": "2026-06-14",
      "CurrencyCode": "GBP",
      "Total": 1200.00,
      "AmountDue": 1200.00,
      "AmountPaid": 0.00,
      "Contact": { "ContactID": "c000-aaaa", "Name": "Acme Recruitment Ltd" },
      "Reference": "PO-12345",
      "UpdatedDateUTC": "/Date(1747401234567+0000)/"
    },
    {
      "InvoiceID": "0000bbbb-1111-2222-3333-444455556666",
      "InvoiceNumber": "INV-0002",
      "Type": "ACCREC",
      "Status": "AUTHORISED",
      "Date": "2026-05-10",
      "DueDate": "2026-06-09",
      "CurrencyCode": "GBP",
      "Total": 3500.00,
      "AmountDue": 1500.00,
      "AmountPaid": 2000.00,
      "Contact": { "ContactID": "c000-bbbb", "Name": "Beta Search Partners" },
      "Reference": null,
      "UpdatedDateUTC": "/Date(1746900012345+0000)/"
    }
  ]
}

--- FILE: packages/mcp-connectors/xero/fixtures/oauth-refresh-ok.json ---

{
  "access_token": "fake-new-access-token-abcdef123456",
  "refresh_token": "fake-new-refresh-token-zyxwvu987654",
  "expires_in": 1800,
  "scope": "accounting.transactions accounting.contacts.read offline_access",
  "token_type": "Bearer"
}

--- FILE: packages/mcp-connectors/xero/fixtures/payment-write-ok.json ---

{
  "Id": "fixture-payment-write-ok",
  "Status": "OK",
  "Payments": [
    {
      "PaymentID": "p000-cccc-2222",
      "Invoice": { "InvoiceID": "0000aaaa-1111-2222-3333-444455556666", "InvoiceNumber": "INV-0001" },
      "Account": { "AccountID": "acct-bank-current", "Code": "090" },
      "Date": "2026-05-22",
      "Amount": 1200.00,
      "Reference": "BACS-2026-05-22-002",
      "CurrencyRate": 1.0,
      "PaymentType": "ACCRECPAYMENT",
      "Status": "AUTHORISED",
      "UpdatedDateUTC": "/Date(1747900000000+0000)/"
    }
  ]
}

--- FILE: packages/mcp-connectors/xero/fixtures/payments-recent.json ---

{
  "Id": "fixture-payments-recent",
  "Status": "OK",
  "Payments": [
    {
      "PaymentID": "p000-aaaa-1111",
      "Invoice": { "InvoiceID": "0000bbbb-1111-2222-3333-444455556666", "InvoiceNumber": "INV-0002" },
      "Account": { "AccountID": "acct-bank-current", "Code": "090" },
      "Date": "2026-05-20",
      "Amount": 2000.00,
      "Reference": "BACS-2026-05-20-001",
      "CurrencyRate": 1.0,
      "PaymentType": "ACCRECPAYMENT",
      "Status": "AUTHORISED",
      "UpdatedDateUTC": "/Date(1747700012345+0000)/"
    }
  ]
}

--- FILE: packages/mcp-connectors/xero/package.json ---

{
  "name": "@ifos/xero",
  "version": "0.1.0",
  "private": true,
  "description": "IFOS Xero MCP connector — OAuth 2.0 refresh + invoices read + payments read/write. Used by Cash Conductor agent §4 Steps 4-6 + 10-11 per agents/recruitment/cash-conductor/tools.yaml.",
  "license": "UNLICENSED",
  "type": "module",
  "engines": { "node": ">=20.0.0" },
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsup",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {},
  "devDependencies": {
    "@types/node": "^20.14.0",
    "tsup": "^8.3.0",
    "tsx": "^4.19.0",
    "typescript": "^5.5.0",
    "vitest": "^2.1.0"
  }
}

--- FILE: packages/mcp-connectors/xero/README.md ---

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

--- FILE: packages/mcp-connectors/xero/src/auth.ts ---

// Xero OAuth 2.0 token refresh + atomic disk persistence + concurrent-call dedup.
//
// Per review-mcp-connector §2 (OAuth refresh idempotency):
//   - Concurrent refresh() calls converge on ONE token rotation, not N
//     (in-process Promise lock per tenant_id).
//   - Atomic write to token_file_path via .tmp + rename — no torn file
//     visible to a parallel reader even mid-refresh.
//   - Tokens NEVER logged or thrown into error messages (review-mcp-connector §5).
//
// Token file shape (JSON):
//   { "access_token": "...", "refresh_token": "...", "expires_at_ms": N,
//     "scope": "...", "token_type": "Bearer" }
//
// Token file path is per-tenant (configured via XeroOAuthConfig.token_file_path).
// Recommend: ~/.ifos-local-vault/<tenant>/xero-tokens-<xero_tenant_id>.json (mode 0600).

import { promises as fs } from "node:fs";
import { XeroAuthError } from "./errors.js";
import type { XeroOAuthConfig, XeroTokens } from "./types.js";

const XERO_TOKEN_ENDPOINT = "https://identity.xero.com/connect/token";

// In-process per-tenant refresh dedup: while a refresh is in-flight,
// concurrent callers share the same Promise → one network call, one
// token rotation, one file write.
const inflight: Map<string, Promise<XeroTokens>> = new Map();

/** Read token file from disk; returns null if missing/malformed. */
export async function loadTokens(
  config: XeroOAuthConfig,
): Promise<XeroTokens | null> {
  let raw: string;
  try {
    raw = await fs.readFile(config.token_file_path, "utf8");
  } catch {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as XeroTokens;
    if (
      typeof parsed.access_token !== "string" ||
      typeof parsed.refresh_token !== "string" ||
      typeof parsed.expires_at_ms !== "number"
    ) {
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

/**
 * Atomic save: write to <path>.tmp then rename. A parallel reader either
 * sees the OLD file or the NEW file, never a torn partial.
 */
export async function saveTokens(
  config: XeroOAuthConfig,
  tokens: XeroTokens,
): Promise<void> {
  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
  await fs.rename(tmpPath, config.token_file_path);
}

/**
 * Returns true if tokens expire within the next `safety_window_ms` (default 5 min).
 * Use to decide whether to refresh eagerly before a downstream call.
 */
export function shouldRefresh(
  tokens: XeroTokens,
  now: () => number = Date.now,
  safety_window_ms = 5 * 60 * 1000,
): boolean {
  return tokens.expires_at_ms - now() < safety_window_ms;
}

/**
 * Refresh OAuth tokens. Concurrent-safe: if a refresh is in flight for the
 * same tenant, return the in-flight Promise (one network call, one file write).
 *
 * Throws XeroAuthError on 4xx (credentials rejected); does NOT retry — caller
 * decides whether to re-attempt with new credentials.
 */
export async function refreshTokens(
  config: XeroOAuthConfig,
  current_tokens: XeroTokens,
  fetchFn: typeof fetch = fetch,
): Promise<XeroTokens> {
  const lockKey = config.tenant_id;
  const existing = inflight.get(lockKey);
  if (existing) return existing;

  const promise = (async () => {
    try {
      const basic = Buffer.from(
        `${config.client_id}:${config.client_secret}`,
      ).toString("base64");

      const body = new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: current_tokens.refresh_token,
      });

      const res = await fetchFn(XERO_TOKEN_ENDPOINT, {
        method: "POST",
        headers: {
          Authorization: `Basic ${basic}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body,
      });

      if (!res.ok) {
        // Never include the response body verbatim — Xero may echo the
        // (now-invalid) refresh_token in error responses.
        throw new XeroAuthError(
          `Xero OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
          res.status,
        );
      }

      const data = (await res.json()) as {
        access_token: string;
        refresh_token: string;
        expires_in: number;
        scope: string;
        token_type: string;
      };

      const new_tokens: XeroTokens = {
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at_ms: Date.now() + data.expires_in * 1000,
        scope: data.scope,
        token_type: data.token_type,
      };

      await saveTokens(config, new_tokens);
      return new_tokens;
    } finally {
      inflight.delete(lockKey);
    }
  })();

  inflight.set(lockKey, promise);
  return promise;
}

/** Test helper — clears the in-flight refresh map. */
export function _resetInflightForTest(): void {
  inflight.clear();
}

--- FILE: packages/mcp-connectors/xero/src/cache.ts ---

// Disk cache for Xero responses. Default TTL 5 min (invoices change often;
// shorter than Companies House 7-day cache). Pattern matches @ifos/companies-house
// CHCache; intentionally not shared to keep package boundaries clean.

import { createHash } from "node:crypto";
import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

interface CacheEntry<T> {
  cachedAt: number;
  ttlMs: number;
  value: T;
}

export class XeroCache {
  constructor(private readonly dir: string) {}

  static fromEnv(): XeroCache {
    const dir =
      process.env.IFOS_XERO_CACHE_DIR ??
      join(homedir(), ".ifos-cache", "xero");
    return new XeroCache(dir);
  }

  async get<T>(key: string): Promise<T | null> {
    const path = this.keyToPath(key);
    let raw: string;
    try {
      raw = await fs.readFile(path, "utf8");
    } catch {
      return null;
    }
    let entry: CacheEntry<T>;
    try {
      entry = JSON.parse(raw) as CacheEntry<T>;
    } catch {
      return null;
    }
    if (Date.now() - entry.cachedAt > entry.ttlMs) return null;
    return entry.value;
  }

  async set<T>(key: string, value: T, ttlMs: number): Promise<void> {
    const path = this.keyToPath(key);
    await fs.mkdir(this.dir, { recursive: true });
    await fs.writeFile(
      path,
      JSON.stringify({ cachedAt: Date.now(), ttlMs, value }),
      { mode: 0o600 },
    );
  }

  private keyToPath(key: string): string {
    const hash = createHash("sha256").update(key).digest("hex");
    return join(this.dir, `${hash}.json`);
  }
}

--- FILE: packages/mcp-connectors/xero/src/client.ts ---

// Xero HTTP client — wraps fetch with: OAuth token attach, rate-limit
// budget, 429 retry-after, 5xx exponential backoff (max 2 retries),
// 4xx surface as typed errors. No retry on POST writes (caller decides).

import {
  XeroAuthError,
  XeroError,
  XeroNotFoundError,
  XeroRateLimitError,
  XeroValidationError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import { loadTokens, refreshTokens, shouldRefresh } from "./auth.js";
import type { XeroClientOptions, XeroTokens } from "./types.js";

export const XERO_BASE_URL = "https://api.xero.com/api.xro/2.0";
export const DEFAULT_TIMEOUT_MS = 15_000;

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "DELETE";
  query?: Record<string, string>;
  body?: unknown;
  /** Override max retries for this call (default 2 for GET, 0 for writes). */
  max_retries?: number;
  /** Caller-supplied AbortSignal. */
  signal?: AbortSignal;
}

/** Sleep `ms` milliseconds. */
function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

/** Exponential backoff with full jitter. */
function backoff(attempt: number): number {
  const base = 250 * 2 ** attempt; // 250, 500, 1000, 2000 ms
  return Math.floor(Math.random() * base);
}

export class XeroClient {
  private readonly opts: XeroClientOptions;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private current_tokens: XeroTokens | null = null;

  constructor(opts: XeroClientOptions) {
    this.opts = opts;
    this.fetchFn = opts.fetchFn ?? fetch;
    this.now = opts.now ?? Date.now;
  }

  /** Returns a valid access_token, refreshing eagerly if within the safety window. */
  async getValidAccessToken(): Promise<string> {
    if (!this.current_tokens) {
      this.current_tokens = await loadTokens(this.opts.config);
      if (!this.current_tokens) {
        throw new XeroAuthError(
          "No Xero tokens on disk; consent flow required to bootstrap " +
            "tokens at token_file_path (run the one-time OAuth authorise " +
            "flow per README §Bootstrap)",
        );
      }
    }
    if (shouldRefresh(this.current_tokens, this.now)) {
      this.current_tokens = await refreshTokens(
        this.opts.config,
        this.current_tokens,
        this.fetchFn,
      );
    }
    return this.current_tokens.access_token;
  }

  /** Public: low-level call. Most callers use the capability helpers in invoices/payments. */
  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    const method = options.method ?? "GET";
    const isWrite = method !== "GET";
    const max_retries = options.max_retries ?? (isWrite ? 0 : 2);

    // Build URL with query
    const url = new URL(XERO_BASE_URL + path);
    if (options.query) {
      for (const [k, v] of Object.entries(options.query)) {
        url.searchParams.set(k, v);
      }
    }

    let last_error: unknown = null;
    for (let attempt = 0; attempt <= max_retries; attempt++) {
      // Pre-emptive rate-limit check
      const allowed = consume(this.opts.config.tenant_id, this.now);
      if (!allowed) {
        throw new XeroRateLimitError(
          `Xero rate-limit budget exhausted (tenant=${this.opts.config.tenant_id}); ` +
            `local bucket prevents call to avoid upstream 429`,
        );
      }

      const access_token = await this.getValidAccessToken();
      const headers: Record<string, string> = {
        Authorization: `Bearer ${access_token}`,
        Accept: "application/json",
        "Xero-tenant-id": this.opts.config.tenant_id,
      };
      if (options.body !== undefined) {
        headers["Content-Type"] = "application/json";
      }

      let res: Response;
      try {
        res = await this.fetchFn(url.toString(), {
          method,
          headers,
          body: options.body !== undefined ? JSON.stringify(options.body) : undefined,
          signal: options.signal,
        });
      } catch (e) {
        // Network error — retry up to max_retries (only for GET; isWrite=true → max_retries=0)
        last_error = e;
        if (attempt < max_retries) {
          await sleep(backoff(attempt));
          continue;
        }
        throw new XeroError(
          `Xero network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
        );
      }

      // 200-299 happy path
      if (res.ok) {
        return (await res.json()) as T;
      }

      // 401: token bad — force a refresh next iteration
      if (res.status === 401 && attempt < max_retries) {
        this.current_tokens = null;
        await sleep(backoff(attempt));
        continue;
      }

      // 429: rate-limited; honour Retry-After then retry (GET only)
      if (res.status === 429 && attempt < max_retries) {
        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
        await sleep(waitMs);
        continue;
      }
      if (res.status === 429) {
        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
        throw new XeroRateLimitError(
          `Xero returned 429 after ${attempt + 1} attempt(s)`,
          retryAfter > 0 ? retryAfter : null,
        );
      }

      // 5xx: retry with backoff (GET only)
      if (res.status >= 500 && attempt < max_retries) {
        await sleep(backoff(attempt));
        continue;
      }

      // 4xx (non-401/429): typed error, no retry
      const safeBody = await res.text().catch(() => "");
      if (res.status === 404) {
        throw new XeroNotFoundError(`Xero 404 on ${method} ${path}`);
      }
      if (res.status === 400) {
        throw new XeroValidationError(
          `Xero rejected ${method} ${path} (HTTP 400)`,
          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
        );
      }
      throw new XeroError(
        `Xero ${method} ${path} failed (HTTP ${res.status})`,
        res.status,
      );
    }
    throw new XeroError(
      `Xero ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
    );
  }
}

--- FILE: packages/mcp-connectors/xero/src/errors.ts ---

// Xero error hierarchy. Errors NEVER include credential values; only key
// names + status codes + safe metadata. Per review-mcp-connector §5
// (zero secret interpolation in error messages).

export class XeroError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
  ) {
    super(message);
    this.name = "XeroError";
  }
}

/** OAuth refresh failed: client_id/secret rejected, refresh_token invalid, or token-file write/read failed. */
export class XeroAuthError extends XeroError {
  constructor(message: string, status?: number) {
    super(message, status, false);
    this.name = "XeroAuthError";
  }
}

/** Rate-limit budget exhausted (60/min per app per tenant; 5000/day per tenant). */
export class XeroRateLimitError extends XeroError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "XeroRateLimitError";
  }
}

/** Invoice/payment/contact not found. */
export class XeroNotFoundError extends XeroError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "XeroNotFoundError";
  }
}

/** Xero rejected the write payload (400). Typically schema or business-rule failures. */
export class XeroValidationError extends XeroError {
  constructor(
    message: string,
    public readonly providerErrors: string[] = [],
  ) {
    super(message, 400, false);
    this.name = "XeroValidationError";
  }
}

--- FILE: packages/mcp-connectors/xero/src/index.ts ---

// @ifos/xero — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
//       on agents/recruitment/cash-conductor/tools.yaml AND (for state-changing
//       capabilities) has an action_type entry in agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check). Adding
//       a new one here does NOT require a tools.yaml edit; promoting one to a
//       capability does.
//
// Reference implementation: @ifos/companies-house. Pattern parity intentional.

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §xero)
// ─────────────────────────────────────────────────────────────────────────

// xero_oauth (action_type: xero_oauth, green tier per autosend-policy.yaml)
export { refreshTokens } from "./auth.js";
// xero_list_open_invoices (read-only) + xero_get_invoice (read-only)
export { listOpenInvoices, getInvoice } from "./invoices.js";
// xero_list_payments (read-only) + xero_write_payment_received
// (action_type: accounting_reconciliation_write, yellow tier per autosend-policy.yaml)
export { listPayments, writePaymentReceived } from "./payments.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once by cycle.sh Step 1; not a capability in
// the bus sense (no action_type; no authz check) — it carries the capabilities
// above through the rate-limit + retry + OAuth attach path.
export { XeroClient, XERO_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
// Token-file I/O + pure predicates
export { loadTokens, saveTokens, shouldRefresh } from "./auth.js";
// Disk cache
export { XeroCache } from "./cache.js";
// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
// see README §"Rate limits" — consumer is responsible for honouring shouldBackoff
// at the soft threshold; the hard 100% gate is enforced inside rateConsume()).
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
// Test/diagnostic
export { _resetInflightForTest } from "./auth.js";
// Error hierarchy
export {
  XeroError,
  XeroAuthError,
  XeroRateLimitError,
  XeroNotFoundError,
  XeroValidationError,
} from "./errors.js";
export type {
  XeroTokens,
  XeroOAuthConfig,
  XeroInvoice,
  XeroInvoicesResponse,
  XeroPayment,
  XeroPaymentsResponse,
  XeroPaymentWriteRequest,
  XeroClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";

--- FILE: packages/mcp-connectors/xero/src/invoices.ts ---

// Xero Invoices capability surface — read-only (list + get).
// Consumed by Cash Conductor §4 Step 4 (invoice register ingest).

import type { XeroClient } from "./client.js";
import { XeroCache } from "./cache.js";
import type { XeroInvoice, XeroInvoicesResponse } from "./types.js";

const INVOICE_CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes — invoices change often

export interface ListOpenInvoicesOptions {
  /** ISO yyyy-MM-dd; filter to invoices issued on/after this date. */
  issued_since?: string;
  /** 1-indexed page; Xero returns 100 per page. */
  page?: number;
  /** Bypass disk cache. */
  no_cache?: boolean;
  cache?: XeroCache;
}

/**
 * List open invoices (Status IN (AUTHORISED, SUBMITTED) with AmountDue > 0).
 * Pagination via `page` (1-indexed; 100 per page); call repeatedly until
 * fewer than 100 results return.
 */
export async function listOpenInvoices(
  client: XeroClient,
  options: ListOpenInvoicesOptions = {},
): Promise<XeroInvoice[]> {
  const cache = options.cache ?? XeroCache.fromEnv();
  const page = options.page ?? 1;
  const key = `invoices:open:page=${page}:issued_since=${options.issued_since ?? "all"}`;

  if (!options.no_cache) {
    const hit = await cache.get<XeroInvoice[]>(key);
    if (hit !== null) return hit;
  }

  // Xero `where` syntax: e.g. AmountDue>0 AND Status==\"AUTHORISED\"
  const whereParts = ['AmountDue>0', 'Status=="AUTHORISED"||Status=="SUBMITTED"'];
  if (options.issued_since) {
    whereParts.push(`Date>=DateTime(${options.issued_since.replace(/-/g, ",")})`);
  }
  const query: Record<string, string> = {
    where: whereParts.join(" AND "),
    order: "Date DESC",
    page: String(page),
  };

  const res = await client.request<XeroInvoicesResponse>("/Invoices", { query });
  const invoices = res.Invoices ?? [];
  await cache.set(key, invoices, INVOICE_CACHE_TTL_MS);
  return invoices;
}

/** Get a single invoice by Xero InvoiceID (UUID). */
export async function getInvoice(
  client: XeroClient,
  invoiceId: string,
  options: { cache?: XeroCache; no_cache?: boolean } = {},
): Promise<XeroInvoice | null> {
  const cache = options.cache ?? XeroCache.fromEnv();
  const key = `invoice:${invoiceId}`;
  if (!options.no_cache) {
    const hit = await cache.get<XeroInvoice>(key);
    if (hit !== null) return hit;
  }
  const res = await client.request<XeroInvoicesResponse>(
    `/Invoices/${encodeURIComponent(invoiceId)}`,
  );
  const inv = res.Invoices?.[0] ?? null;
  if (inv) await cache.set(key, inv, INVOICE_CACHE_TTL_MS);
  return inv;
}

--- FILE: packages/mcp-connectors/xero/src/payments.ts ---

// Xero Payments capability surface — read + write (write is the only
// state-changing capability in this connector). Consumed by Cash Conductor
// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
// yellow tier per autosend-policy.yaml).

import type { XeroClient } from "./client.js";
import { XeroCache } from "./cache.js";
import type {
  XeroPayment,
  XeroPaymentsResponse,
  XeroPaymentWriteRequest,
} from "./types.js";

const PAYMENTS_CACHE_TTL_MS = 5 * 60 * 1000;

export interface ListPaymentsOptions {
  /** ISO yyyy-MM-dd; payments on/after this date. */
  since?: string;
  page?: number;
  no_cache?: boolean;
  cache?: XeroCache;
}

/** List payments received (PaymentType=ACCRECPAYMENT). */
export async function listPayments(
  client: XeroClient,
  options: ListPaymentsOptions = {},
): Promise<XeroPayment[]> {
  const cache = options.cache ?? XeroCache.fromEnv();
  const page = options.page ?? 1;
  const key = `payments:page=${page}:since=${options.since ?? "all"}`;

  if (!options.no_cache) {
    const hit = await cache.get<XeroPayment[]>(key);
    if (hit !== null) return hit;
  }

  const whereParts = ['PaymentType=="ACCRECPAYMENT"'];
  if (options.since) {
    whereParts.push(`Date>=DateTime(${options.since.replace(/-/g, ",")})`);
  }
  const query: Record<string, string> = {
    where: whereParts.join(" AND "),
    order: "Date DESC",
    page: String(page),
  };

  const res = await client.request<XeroPaymentsResponse>("/Payments", { query });
  const payments = res.Payments ?? [];
  await cache.set(key, payments, PAYMENTS_CACHE_TTL_MS);
  return payments;
}

/**
 * Write a payment received against an invoice. State-changing — emits
 * action_type='accounting_reconciliation_write' (yellow tier per
 * autosend-policy.yaml; documented in agents/recruitment/cash-conductor/agent.md §3).
 *
 * No retry on write failure — caller decides (Cash Conductor §4 Step 6
 * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
 */
export async function writePaymentReceived(
  client: XeroClient,
  payment: XeroPaymentWriteRequest,
): Promise<XeroPayment> {
  const res = await client.request<XeroPaymentsResponse>("/Payments", {
    method: "PUT",
    body: { Payments: [payment] },
    max_retries: 0,
  });
  const created = res.Payments?.[0];
  if (!created) {
    throw new Error(
      "Xero PUT /Payments succeeded but response contained no Payment record",
    );
  }
  return created;
}

--- FILE: packages/mcp-connectors/xero/src/rate-limit.ts ---

// Rate limiter for Xero. Per Xero published limits
// (https://developer.xero.com/documentation/guides/oauth2/limits):
//   - 60 calls / 60-second window per app per tenant (minute bucket)
//   - 5000 calls / day per tenant (daily bucket)
//   - Concurrent: 5 simultaneous calls per app per tenant (we don't enforce
//     concurrency here — single-process Cash Conductor cycle.sh is serial)
//
// We track BOTH windows; backoff at 80% of the tighter one. Per-tenant
// state (multi-tenant safe).

const MINUTE_MS = 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
const MINUTE_HARD = 60;
const DAILY_HARD = 5000;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 48
const DAILY_SOFT = Math.floor(DAILY_HARD * 0.8); // 4000

const minuteTimestamps: Map<string, number[]> = new Map();
const dailyTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  tenant_id: string;
  minute_used: number;
  minute_remaining: number;
  daily_used: number;
  daily_remaining: number;
  shouldBackoff: boolean;
  reason: "ok" | "minute-soft" | "daily-soft" | "minute-hard" | "daily-hard";
}

function pruneMinute(arr: number[] | undefined, now: number): number[] {
  if (!arr) return [];
  return arr.filter((ts) => now - ts < MINUTE_MS);
}
function pruneDay(arr: number[] | undefined, now: number): number[] {
  if (!arr) return [];
  return arr.filter((ts) => now - ts < DAY_MS);
}

export function check(
  tenant_id: string,
  now: () => number = Date.now,
): RateState {
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(tenant_id), t);
  const day = pruneDay(dailyTimestamps.get(tenant_id), t);
  minuteTimestamps.set(tenant_id, minute);
  dailyTimestamps.set(tenant_id, day);

  const minute_used = minute.length;
  const daily_used = day.length;
  let reason: RateState["reason"] = "ok";
  let shouldBackoff = false;

  if (minute_used >= MINUTE_HARD) {
    reason = "minute-hard";
    shouldBackoff = true;
  } else if (daily_used >= DAILY_HARD) {
    reason = "daily-hard";
    shouldBackoff = true;
  } else if (daily_used >= DAILY_SOFT) {
    reason = "daily-soft";
    shouldBackoff = true;
  } else if (minute_used >= MINUTE_SOFT) {
    reason = "minute-soft";
    shouldBackoff = true;
  }

  return {
    tenant_id,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    daily_used,
    daily_remaining: DAILY_HARD - daily_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  tenant_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(tenant_id, now);
  if (state.reason === "minute-hard" || state.reason === "daily-hard")
    return false;
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(tenant_id), t);
  const day = pruneDay(dailyTimestamps.get(tenant_id), t);
  minute.push(t);
  day.push(t);
  minuteTimestamps.set(tenant_id, minute);
  dailyTimestamps.set(tenant_id, day);
  return true;
}

export function reset(tenant_id?: string): void {
  if (tenant_id !== undefined) {
    minuteTimestamps.delete(tenant_id);
    dailyTimestamps.delete(tenant_id);
  } else {
    minuteTimestamps.clear();
    dailyTimestamps.clear();
  }
}

--- FILE: packages/mcp-connectors/xero/src/types.ts ---

// Xero API types — subset of the v2 API surface IFOS Cash Conductor consumes.
// Reference: https://developer.xero.com/documentation/api/accounting/overview
//
// Shapes are intentionally narrower than Xero's full schema — only fields
// Cash Conductor §3 Output 1 (reconciliation) + §3 Output 2 (chase drafts) +
// §10 (weekly report DSO) actually read.

export interface XeroTokens {
  access_token: string;
  refresh_token: string;
  /** Unix epoch milliseconds when the access_token expires. */
  expires_at_ms: number;
  /** Comma-separated scopes granted. */
  scope: string;
  /** Bearer; always 'Bearer' in v2. */
  token_type: string;
}

export interface XeroOAuthConfig {
  client_id: string;
  client_secret: string;
  /** Tenant ID (Xero "connection") this token bundle is for. */
  tenant_id: string;
  /** Token file on disk; atomic-rename writes go here. */
  token_file_path: string;
}

export interface XeroInvoice {
  InvoiceID: string;
  InvoiceNumber: string | null;
  Type: "ACCREC" | "ACCPAY";
  Status: "DRAFT" | "SUBMITTED" | "AUTHORISED" | "PAID" | "VOIDED" | "DELETED";
  Date: string; // ISO yyyy-MM-dd
  DueDate: string;
  CurrencyCode: string;
  Total: number;
  AmountDue: number;
  AmountPaid: number;
  Contact: { ContactID: string; Name: string };
  Reference: string | null;
  UpdatedDateUTC: string; // /Date(<ms>+0000)/
}

export interface XeroInvoicesResponse {
  Id: string;
  Status: string;
  Invoices: XeroInvoice[];
}

export interface XeroPayment {
  PaymentID: string;
  Invoice: { InvoiceID: string; InvoiceNumber?: string };
  Account: { AccountID: string; Code?: string };
  Date: string;
  Amount: number;
  Reference: string | null;
  CurrencyRate: number;
  PaymentType: "ACCRECPAYMENT" | "ACCPAYPAYMENT";
  Status: "AUTHORISED" | "DELETED";
  UpdatedDateUTC: string;
}

export interface XeroPaymentsResponse {
  Id: string;
  Status: string;
  Payments: XeroPayment[];
}

export interface XeroPaymentWriteRequest {
  Invoice: { InvoiceID: string };
  Account: { Code: string };
  Date: string;
  Amount: number;
  Reference?: string;
}

export interface XeroClientOptions {
  config: XeroOAuthConfig;
  /** Override fetch (testing). */
  fetchFn?: typeof fetch;
  /** Override now() (testing). */
  now?: () => number;
}

--- FILE: packages/mcp-connectors/xero/tests/auth.test.ts ---

// OAuth tests per review-mcp-connector §2 (idempotency + atomic file
// write + concurrent-safety test).

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  _resetInflightForTest,
  loadTokens,
  refreshTokens,
  saveTokens,
  shouldRefresh,
} from "../src/auth.js";
import { XeroAuthError } from "../src/errors.js";
import type { XeroOAuthConfig, XeroTokens } from "../src/types.js";

const FIXTURE_TOKENS: XeroTokens = {
  access_token: "fake-access-old",
  refresh_token: "fake-refresh-old",
  expires_at_ms: Date.now() + 1800_000,
  scope: "accounting.transactions offline_access",
  token_type: "Bearer",
};

const REFRESH_OK_BODY = JSON.stringify({
  access_token: "fake-new-access-token-abcdef123456",
  refresh_token: "fake-new-refresh-token-zyxwvu987654",
  expires_in: 1800,
  scope: "accounting.transactions offline_access",
  token_type: "Bearer",
});

function makeConfig(token_file: string, tenant_id = "test-tenant-id"): XeroOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    tenant_id,
    token_file_path: token_file,
  };
}

let token_file: string;

beforeEach(() => {
  token_file = join(tmpdir(), `xero-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`);
  _resetInflightForTest();
});
afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("xero auth", () => {
  it("loadTokens returns null when file missing", async () => {
    const config = makeConfig(token_file);
    expect(await loadTokens(config)).toBeNull();
  });

  it("save + load round-trips token bundle", async () => {
    const config = makeConfig(token_file);
    await saveTokens(config, FIXTURE_TOKENS);
    const loaded = await loadTokens(config);
    expect(loaded).toEqual(FIXTURE_TOKENS);
  });

  it("shouldRefresh: true if within 5-min safety window", () => {
    const expiringSoon: XeroTokens = { ...FIXTURE_TOKENS, expires_at_ms: Date.now() + 60_000 };
    expect(shouldRefresh(expiringSoon)).toBe(true);
  });

  it("shouldRefresh: false if comfortably ahead of safety window", () => {
    const fresh: XeroTokens = { ...FIXTURE_TOKENS, expires_at_ms: Date.now() + 30 * 60_000 };
    expect(shouldRefresh(fresh)).toBe(false);
  });

  it("refreshTokens: success path writes new tokens atomically + returns them", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(REFRESH_OK_BODY, { status: 200, headers: { "Content-Type": "application/json" } });

    const newT = await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    expect(newT.access_token).toBe("fake-new-access-token-abcdef123456");
    expect(newT.refresh_token).toBe("fake-new-refresh-token-zyxwvu987654");
    // File now exists with new tokens
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(newT.access_token);
  });

  it("refreshTokens: 401 surfaces as XeroAuthError; does NOT include token in error", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(JSON.stringify({ error: "invalid_grant", error_description: "refresh_token expired" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });

    await expect(refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch)).rejects.toBeInstanceOf(XeroAuthError);
    // Verify the message does NOT leak the refresh_token value
    try {
      await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    } catch (e) {
      const msg = (e as Error).message;
      expect(msg).not.toContain(FIXTURE_TOKENS.refresh_token);
    }
  });

  it("refreshTokens: concurrent calls converge on ONE network call (idempotent dedup)", async () => {
    const config = makeConfig(token_file);
    let calls = 0;
    const fakeFetch = async (): Promise<Response> => {
      calls += 1;
      // small delay to ensure overlap
      await new Promise((r) => setTimeout(r, 25));
      return new Response(REFRESH_OK_BODY, { status: 200, headers: { "Content-Type": "application/json" } });
    };

    const [a, b, c] = await Promise.all([
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
    ]);
    expect(calls).toBe(1);
    expect(a.access_token).toBe(b.access_token);
    expect(b.access_token).toBe(c.access_token);
    // File written exactly once with the new token
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(a.access_token);
  });
});

--- FILE: packages/mcp-connectors/xero/tests/capabilities.test.ts ---

// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
// path + ≥1 error path per capability).

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { XeroClient } from "../src/client.js";
import { XeroCache } from "../src/cache.js";
import { saveTokens, _resetInflightForTest } from "../src/auth.js";
import { reset as resetRateLimit } from "../src/rate-limit.js";
import { listOpenInvoices, getInvoice } from "../src/invoices.js";
import {
  listPayments,
  writePaymentReceived,
} from "../src/payments.js";
import {
  XeroError,
  XeroNotFoundError,
  XeroRateLimitError,
  XeroValidationError,
} from "../src/errors.js";
import type {
  XeroOAuthConfig,
  XeroTokens,
  XeroPaymentWriteRequest,
} from "../src/types.js";

import INVOICES_PAGE_1 from "../fixtures/invoices-page-1.json" with { type: "json" };
import PAYMENTS_RECENT from "../fixtures/payments-recent.json" with { type: "json" };
import PAYMENT_WRITE_OK from "../fixtures/payment-write-ok.json" with { type: "json" };

const FIXTURE_TOKENS: XeroTokens = {
  access_token: "fake-access",
  refresh_token: "fake-refresh",
  expires_at_ms: Date.now() + 1800_000,
  scope: "accounting.transactions offline_access",
  token_type: "Bearer",
};

let token_file: string;
let cache_dir: string;
let cache: XeroCache;

function makeConfig(): XeroOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    tenant_id: "fixture-tenant",
    token_file_path: token_file,
  };
}

function makeOkResponse(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

beforeEach(async () => {
  token_file = join(tmpdir(), `xero-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`);
  cache_dir = join(tmpdir(), `xero-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`);
  cache = new XeroCache(cache_dir);
  _resetInflightForTest();
  resetRateLimit();
  await saveTokens(makeConfig(), FIXTURE_TOKENS);
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
});

describe("xero capabilities — invoices", () => {
  it("listOpenInvoices: returns parsed array from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const invoices = await listOpenInvoices(client, { cache, no_cache: true });
    expect(invoices.length).toBe(2);
    expect(invoices[0]?.InvoiceID).toBe("0000aaaa-1111-2222-3333-444455556666");
    expect(invoices[0]?.AmountDue).toBe(1200);
    expect(invoices[1]?.Contact.Name).toBe("Beta Search Partners");
  });

  it("getInvoice: returns single invoice when present", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const inv = await getInvoice(client, "0000aaaa-1111-2222-3333-444455556666", {
      cache,
      no_cache: true,
    });
    expect(inv).not.toBeNull();
    expect(inv?.InvoiceNumber).toBe("INV-0001");
  });

  it("getInvoice: 404 surfaces as XeroNotFoundError", async () => {
    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      getInvoice(client, "00000000-0000-0000-0000-000000000000", { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(XeroNotFoundError);
  });

  // Error-path coverage for listOpenInvoices (per review-mcp-connector §6 +
  // Codex F-R1 issue #4: every capability needs ≥1 happy + ≥1 error fixture).
  it("listOpenInvoices: persistent 429 surfaces as XeroRateLimitError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("", {
        status: 429,
        headers: { "Retry-After": "0" }, // 0s = no wait; just exhausts retries fast
      });
    };
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      listOpenInvoices(client, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(XeroRateLimitError);
    expect(calls).toBeGreaterThanOrEqual(2); // initial + ≥1 retry per max_retries=2 default for GET
  });
});

describe("xero capabilities — payments", () => {
  it("listPayments: returns parsed array from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENTS_RECENT);
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payments = await listPayments(client, { cache, no_cache: true });
    expect(payments.length).toBe(1);
    expect(payments[0]?.Amount).toBe(2000);
    expect(payments[0]?.PaymentType).toBe("ACCRECPAYMENT");
  });

  it("writePaymentReceived: success path returns created payment", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENT_WRITE_OK);
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payload: XeroPaymentWriteRequest = {
      Invoice: { InvoiceID: "0000aaaa-1111-2222-3333-444455556666" },
      Account: { Code: "090" },
      Date: "2026-05-22",
      Amount: 1200.0,
      Reference: "BACS-2026-05-22-002",
    };
    const created = await writePaymentReceived(client, payload);
    expect(created.PaymentID).toBe("p000-cccc-2222");
    expect(created.Amount).toBe(1200);
  });

  it("writePaymentReceived: 400 surfaces as XeroValidationError (no retry)", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("Invoice ID does not exist", { status: 400 });
    };
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payload: XeroPaymentWriteRequest = {
      Invoice: { InvoiceID: "00000000-0000-0000-0000-000000000000" },
      Account: { Code: "090" },
      Date: "2026-05-22",
      Amount: 1200.0,
    };
    await expect(writePaymentReceived(client, payload)).rejects.toBeInstanceOf(XeroValidationError);
    expect(calls).toBe(1); // write was NOT retried
  });

  // Error-path coverage for listPayments (per review-mcp-connector §6 +
  // Codex F-R1 issue #4): GET retries 5xx exponentially; after retries
  // exhausted the typed error is XeroError (NOT XeroRateLimitError).
  it("listPayments: persistent 500 surfaces as XeroError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("Xero internal error", { status: 500 });
    };
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      listPayments(client, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(XeroError);
    expect(calls).toBeGreaterThanOrEqual(2); // initial + retries per max_retries=2
  });
});

--- FILE: packages/mcp-connectors/xero/tests/rate-limit.test.ts ---

// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
// MUST exist). Verifies soft (80%) and hard (100%) thresholds against
// both the 60/min and 5000/day Xero buckets.

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

const TENANT = "test-tenant-rate-limit";

describe("xero rate-limit", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check(TENANT);
    expect(s.minute_used).toBe(0);
    expect(s.daily_used).toBe(0);
    expect(s.minute_remaining).toBe(60);
    expect(s.daily_remaining).toBe(5000);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute soft threshold (48)", () => {
    for (let i = 0; i < 47; i++) consume(TENANT);
    const s = check(TENANT);
    expect(s.minute_used).toBe(47);
    expect(s.shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 48", () => {
    for (let i = 0; i < 48; i++) consume(TENANT);
    const s = check(TENANT);
    expect(s.minute_used).toBe(48);
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 60 (consume returns false)", () => {
    for (let i = 0; i < 60; i++) consume(TENANT);
    const s = check(TENANT);
    expect(s.minute_used).toBe(60);
    expect(s.reason).toBe("minute-hard");
    // Bucket exhausted — consume must return false
    expect(consume(TENANT)).toBe(false);
  });

  it("isolates buckets per tenant_id", () => {
    for (let i = 0; i < 50; i++) consume("tenant-A");
    expect(check("tenant-A").shouldBackoff).toBe(true);
    expect(check("tenant-B").shouldBackoff).toBe(false);
    expect(check("tenant-B").minute_used).toBe(0);
  });
});

--- FILE: packages/mcp-connectors/xero/tests/scaffold.test.ts ---

// Package public surface smoke tests. Per review-mcp-connector §1
// (capabilities surface — exports match README capability table).

import { describe, expect, it } from "vitest";
import {
  VERSION,
  XeroClient,
  XERO_BASE_URL,
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  listOpenInvoices,
  getInvoice,
  listPayments,
  writePaymentReceived,
  XeroCache,
  XeroError,
  XeroAuthError,
  XeroRateLimitError,
  XeroNotFoundError,
  XeroValidationError,
} from "../src/index.js";

describe("@ifos/xero package surface", () => {
  it("exports VERSION 0.1.0", () => {
    expect(VERSION).toBe("0.1.0");
  });

  it("exports XeroClient class + base URL", () => {
    expect(typeof XeroClient).toBe("function");
    expect(XERO_BASE_URL).toBe("https://api.xero.com/api.xro/2.0");
  });

  it("exports all 4 capability functions", () => {
    expect(typeof listOpenInvoices).toBe("function");
    expect(typeof getInvoice).toBe("function");
    expect(typeof listPayments).toBe("function");
    expect(typeof writePaymentReceived).toBe("function");
  });

  it("exports auth helpers (load/save/refresh/shouldRefresh)", () => {
    expect(typeof loadTokens).toBe("function");
    expect(typeof saveTokens).toBe("function");
    expect(typeof refreshTokens).toBe("function");
    expect(typeof shouldRefresh).toBe("function");
  });

  it("exports XeroCache + error hierarchy", () => {
    expect(typeof XeroCache).toBe("function");
    // All error classes extend XeroError
    expect(new XeroAuthError("x") instanceof XeroError).toBe(true);
    expect(new XeroRateLimitError("x") instanceof XeroError).toBe(true);
    expect(new XeroNotFoundError("x") instanceof XeroError).toBe(true);
    expect(new XeroValidationError("x") instanceof XeroError).toBe(true);
  });
});

--- FILE: packages/mcp-connectors/xero/tsconfig.json ---

{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true,
    "skipLibCheck": true,
    "types": ["node"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}

--- FILE: packages/mcp-connectors/xero/tsup.config.ts ---

import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/index.ts"],
  format: ["esm"],
  target: "node20",
  platform: "node",
  outDir: "dist",
  splitting: false,
  sourcemap: true,
  clean: true,
  dts: true,
});

--- FILE: packages/mcp-connectors/xero/vitest.config.ts ---

import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: false,
    environment: "node",
    include: ["tests/**/*.test.ts"],
    testTimeout: 15000,
  },
});

--- END ARTEFACT ---

=== YOUR TASK ===

Apply the top-level SKILL.md plus the type-specific skill above to the artefact.

Return EXACTLY ONE of:

  RATIFIED
  [optional 0-5 lines of advisory notes]

OR

  REJECTED

  1. <one-line problem statement>. <2-4 line explanation citing specific lines/sections>. <one-line proposed fix>.

  2. <next issue, same shape>

  ...

Do not include preamble, throat-clearing, or summary. Begin your response with the literal word RATIFIED or REJECTED.
