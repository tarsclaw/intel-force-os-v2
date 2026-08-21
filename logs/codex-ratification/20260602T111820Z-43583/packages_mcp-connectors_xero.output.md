Reading prompt from stdin...
OpenAI Codex v0.132.0
--------
workdir: /Users/madsadmin/code/CortexOS
model: gpt-5.5
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: none
reasoning summaries: none
session id: 019e880e-5610-7e71-a8df-2da31925f20a
--------
user
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

Xero Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 token rotation + invoice read + payment read/write. Fixture-first; live tests deferred to first commercial Xero signup (see §Tests).

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

All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (`xero_oauth` registered as green per Codex F-R2 closure 2026-06-01; `accounting_reconciliation_write` already present per Day-25 verification). Line numbers in the policy file shift across edits — verify via `grep -n "^  xero_oauth:" agents/_shared/autosend-policy.yaml` rather than relying on a static citation here.

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
```

**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.

**Live tests are deferred** to the first commercial Xero signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal per review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold lands in the same commit as the first sandbox credentials per the W4 Track-1 /goal §1 commercial-gate.

Test counts:
- `tests/scaffold.test.ts`: 5 (public surface, exports, error hierarchy)
- `tests/rate-limit.test.ts`: 7 (initial state, minute soft 48, minute hard 60, per-tenant isolation, **daily-soft 4000, daily-hard 5000** — daily-bucket coverage added per Codex F-R2 #4)
- `tests/auth.test.ts`: 7 (load missing, round-trip, shouldRefresh, refresh success, 401 + no-token-leak, concurrent dedup, etc.)
- `tests/capabilities.test.ts`: 9 (list/get invoice happy + 404, list/write payment happy + 400, **listOpenInvoices 429 retry-exhaust, listPayments 500 retry-exhaust, 401-forces-refresh-then-retry** — all 3 added per Codex F-R1/F-R2)

**Total: 28 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).

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

      // 401: server invalidated the access_token — force an explicit refresh
      // BEFORE the next iteration. Per Codex F-R2 issue #1 (xero): nulling the
      // cached token alone is insufficient — getValidAccessToken() will reload
      // the SAME stale token from disk if shouldRefresh() says it's not near
      // expiry (the access_token's epoch-expiry is unaffected by server-side
      // revocation). Rotate it now; persist the new bundle; let the next
      // iteration pick up the rotated token.
      if (res.status === 401 && attempt < max_retries) {
        if (this.current_tokens) {
          // Throws XeroAuthError on refresh failure → propagates correctly.
          this.current_tokens = await refreshTokens(
            this.opts.config,
            this.current_tokens,
            this.fetchFn,
          );
        } else {
          // No cached tokens — let getValidAccessToken() either load fresh
          // from disk or throw the canonical "no tokens; bootstrap required"
          // XeroAuthError on the next iteration.
        }
        await sleep(backoff(attempt));
        continue;
      }
      // 401 after retries exhausted: surface as AUTH-typed error so the
      // consumer's branch logic maps to ESC_ACCOUNTING_AUTH correctly.
      if (res.status === 401) {
        throw new XeroAuthError(
          `Xero ${method} ${path} returned 401 after ${attempt + 1} attempt(s) including forced refresh`,
          401,
        );
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

  // 401-forces-refresh: per Codex F-R2 issue #1, a 401 on a GET MUST trigger
  // an explicit refreshTokens() call before retrying — NOT just null the cache
  // (which would reload the same stale token from disk if shouldRefresh()
  // returns false). This test would FAIL against the pre-fix code: the second
  // GET would use the same access_token and the 401 loop would never break.
  it("401 on GET forces explicit token refresh + retry uses new access_token", async () => {
    let getCalls = 0;
    let refreshCalls = 0;
    let observedSecondAuth: string | null = null;

    const fakeFetch: typeof fetch = async (input, init) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.includes("identity.xero.com/connect/token")) {
        refreshCalls += 1;
        return new Response(
          JSON.stringify({
            access_token: "rotated-access-token-after-401",
            refresh_token: "rotated-refresh-token",
            expires_in: 1800,
            scope: "accounting.transactions offline_access",
            token_type: "Bearer",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      // Invoice GET path
      getCalls += 1;
      if (getCalls === 1) {
        return new Response("", { status: 401 });
      }
      observedSecondAuth = (init?.headers as Record<string, string>)?.["Authorization"] ?? null;
      return makeOkResponse(INVOICES_PAGE_1);
    };

    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const invoices = await listOpenInvoices(client, { cache, no_cache: true });

    expect(invoices.length).toBe(2);
    expect(getCalls).toBe(2); // initial 401 + retry
    expect(refreshCalls).toBe(1); // forced refresh between attempts
    expect(observedSecondAuth).toBe("Bearer rotated-access-token-after-401");
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

  // Daily-bucket coverage per Codex F-R2 issue #4 — README + module comment
  // claim daily soft (4000) + hard (5000) coverage; this section closes the
  // gap. Strategy: burst 40 calls (under the 48/min soft) per minute window,
  // then tick to the next minute. After 100 bursts → 4000 daily. After 125
  // bursts → 5000 daily. Fits comfortably under the 1440 minute-windows-per-day
  // budget (we use 125 of 1440). check() reports daily-soft / daily-hard
  // because the cascade checks daily BEFORE minute-soft.
  describe("daily bucket (5000/day per Xero published limit)", () => {
    function burstClock(start = 0) {
      let t = start;
      return {
        nowMs: () => t,
        advanceToNextMinute: () => {
          t += 60_001;
        },
      };
    }

    function burstFill(tenant: string, totalCalls: number, perBurst = 40) {
      const clk = burstClock();
      let done = 0;
      while (done < totalCalls) {
        const burst = Math.min(perBurst, totalCalls - done);
        for (let i = 0; i < burst; i++) consume(tenant, clk.nowMs);
        done += burst;
        if (done < totalCalls) clk.advanceToNextMinute();
      }
      return clk;
    }

    it("triggers daily-soft backoff at 4000 used", () => {
      const clk = burstFill(TENANT, 4000);
      const s = check(TENANT, clk.nowMs);
      expect(s.daily_used).toBe(4000);
      expect(s.shouldBackoff).toBe(true);
      expect(s.reason).toBe("daily-soft");
    });

    it("blocks at daily-hard 5000 (consume returns false on the 5001st call)", () => {
      const clk = burstFill(TENANT, 5000);
      const s = check(TENANT, clk.nowMs);
      expect(s.daily_used).toBe(5000);
      expect(s.reason).toBe("daily-hard");
      // Bucket exhausted — consume must return false
      expect(consume(TENANT, clk.nowMs)).toBe(false);
    });
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

exec
/bin/zsh -lc 'rg -n "composio|agentmail|decision_log|packages/harness/cortextos|migration-test|test-tenant-b" packages/mcp-connectors/xero' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "xero|accounting_reconciliation_write|ESC_ACCOUNTING|ESC_PROVIDER_FETCH_FAIL|ESC_RATE_LIMIT_HIT" agents/_shared/autosend-policy.yaml agents/_shared/escalation-codes.md agents/recruitment/cash-conductor/tools.yaml 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/tools.yaml:14:# (current registrations verified W4 Day-25 for accounting_reconciliation_write
agents/recruitment/cash-conductor/tools.yaml:15:# + xero_reminder_draft_internal + xero_reminder_send_customer; open_banking_*
agents/recruitment/cash-conductor/tools.yaml:27:  - id: xero_oauth
agents/recruitment/cash-conductor/tools.yaml:28:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:30:    action_type: xero_oauth          # green tier; registration queued for W7-8
agents/recruitment/cash-conductor/tools.yaml:33:    rate_limit_hint: "60/min per tenant_id (see @ifos/xero README §Rate limits)"
agents/recruitment/cash-conductor/tools.yaml:35:  - id: xero_list_open_invoices
agents/recruitment/cash-conductor/tools.yaml:36:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:41:  - id: xero_get_invoice
agents/recruitment/cash-conductor/tools.yaml:42:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:47:  - id: xero_list_payments
agents/recruitment/cash-conductor/tools.yaml:48:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:53:  - id: xero_write_payment_received
agents/recruitment/cash-conductor/tools.yaml:54:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:56:    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED in autosend-policy.yaml
agents/recruitment/cash-conductor/tools.yaml:89:    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED
agents/recruitment/cash-conductor/tools.yaml:141:    action_type: xero_reminder_send_customer  # ORANGE tier; REGISTERED at autosend-policy.yaml line 263; Cash Conductor OWNS this action_type per the same line
agents/recruitment/cash-conductor/tools.yaml:190:#   xero_reminder_draft_internal       line 188   yellow
agents/recruitment/cash-conductor/tools.yaml:191:#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
agents/recruitment/cash-conductor/tools.yaml:192:#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
agents/recruitment/cash-conductor/tools.yaml:196:#   xero_oauth                         green
agents/_shared/autosend-policy.yaml:53:  xero_query_invoices:
agents/_shared/autosend-policy.yaml:157:  xero_oauth:
agents/_shared/autosend-policy.yaml:160:    reason: "Xero OAuth 2.0 refresh — idempotent token rotation against identity.xero.com; @ifos/xero connector handles concurrent-refresh dedup per-tenant; no external send."
agents/_shared/autosend-policy.yaml:220:  xero_reminder_draft_internal:
agents/_shared/autosend-policy.yaml:241:  accounting_reconciliation_write:
agents/_shared/autosend-policy.yaml:295:  xero_reminder_send_customer:
agents/_shared/autosend-policy.yaml:334:  xero_payment_initiate:
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:280:#### `ESC_ACCOUNTING_AUTH`
agents/_shared/escalation-codes.md:285:- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:317:#### `ESC_ACCOUNTING_WRITE_FAIL`
agents/_shared/escalation-codes.md:319:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
agents/_shared/escalation-codes.md:324:#### `ESC_PROVIDER_FETCH_FAIL`
agents/_shared/escalation-codes.md:414:- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`

 succeeded in 0ms:
packages/mcp-connectors/xero/README.md:122:The connector itself does NOT write `decision_log` rows (vault/Postgres split per ADR-002); the consuming `cycle.sh` catches the typed errors above and emits the right ESC via `hh_decision_action`/`hh_decision_output` from `agents/_shared/hook-helpers.sh`.
packages/mcp-connectors/xero/README.md:198:- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
packages/mcp-connectors/xero/README.md:199:- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)

exec
/bin/zsh -lc "rg -n \"export (async function|function|class|const)|export \\{\" packages/mcp-connectors/xero/src/index.ts packages/mcp-connectors/xero/src/*.ts" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/xero/src/invoices.ts:25:export async function listOpenInvoices(
packages/mcp-connectors/xero/src/invoices.ts:56:export async function getInvoice(
packages/mcp-connectors/xero/src/payments.ts:25:export async function listPayments(
packages/mcp-connectors/xero/src/payments.ts:62:export async function writePaymentReceived(
packages/mcp-connectors/xero/src/rate-limit.ts:40:export function check(
packages/mcp-connectors/xero/src/rate-limit.ts:80:export function consume(
packages/mcp-connectors/xero/src/rate-limit.ts:97:export function reset(tenant_id?: string): void {
packages/mcp-connectors/xero/src/index.ts:20:export { refreshTokens } from "./auth.js";
packages/mcp-connectors/xero/src/index.ts:22:export { listOpenInvoices, getInvoice } from "./invoices.js";
packages/mcp-connectors/xero/src/index.ts:25:export { listPayments, writePaymentReceived } from "./payments.js";
packages/mcp-connectors/xero/src/index.ts:34:export { XeroClient, XERO_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
packages/mcp-connectors/xero/src/index.ts:36:export { loadTokens, saveTokens, shouldRefresh } from "./auth.js";
packages/mcp-connectors/xero/src/index.ts:38:export { XeroCache } from "./cache.js";
packages/mcp-connectors/xero/src/index.ts:42:export {
packages/mcp-connectors/xero/src/index.ts:48:export { _resetInflightForTest } from "./auth.js";
packages/mcp-connectors/xero/src/index.ts:50:export {
packages/mcp-connectors/xero/src/index.ts:69:export const VERSION = "0.1.0";
packages/mcp-connectors/xero/src/errors.ts:5:export class XeroError extends Error {
packages/mcp-connectors/xero/src/errors.ts:17:export class XeroAuthError extends XeroError {
packages/mcp-connectors/xero/src/errors.ts:25:export class XeroRateLimitError extends XeroError {
packages/mcp-connectors/xero/src/errors.ts:36:export class XeroNotFoundError extends XeroError {
packages/mcp-connectors/xero/src/errors.ts:44:export class XeroValidationError extends XeroError {
packages/mcp-connectors/xero/src/auth.ts:29:export async function loadTokens(
packages/mcp-connectors/xero/src/auth.ts:57:export async function saveTokens(
packages/mcp-connectors/xero/src/auth.ts:70:export function shouldRefresh(
packages/mcp-connectors/xero/src/auth.ts:85:export async function refreshTokens(
packages/mcp-connectors/xero/src/auth.ts:151:export function _resetInflightForTest(): void {
packages/mcp-connectors/xero/src/index.ts:20:export { refreshTokens } from "./auth.js";
packages/mcp-connectors/xero/src/index.ts:22:export { listOpenInvoices, getInvoice } from "./invoices.js";
packages/mcp-connectors/xero/src/index.ts:25:export { listPayments, writePaymentReceived } from "./payments.js";
packages/mcp-connectors/xero/src/index.ts:34:export { XeroClient, XERO_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
packages/mcp-connectors/xero/src/index.ts:36:export { loadTokens, saveTokens, shouldRefresh } from "./auth.js";
packages/mcp-connectors/xero/src/index.ts:38:export { XeroCache } from "./cache.js";
packages/mcp-connectors/xero/src/index.ts:42:export {
packages/mcp-connectors/xero/src/index.ts:48:export { _resetInflightForTest } from "./auth.js";
packages/mcp-connectors/xero/src/index.ts:50:export {
packages/mcp-connectors/xero/src/index.ts:69:export const VERSION = "0.1.0";
packages/mcp-connectors/xero/src/client.ts:16:export const XERO_BASE_URL = "https://api.xero.com/api.xro/2.0";
packages/mcp-connectors/xero/src/client.ts:17:export const DEFAULT_TIMEOUT_MS = 15_000;
packages/mcp-connectors/xero/src/client.ts:40:export class XeroClient {
packages/mcp-connectors/xero/src/cache.ts:16:export class XeroCache {

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/tools.yaml | sed -n '20,60p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    20	
    21	capabilities:
    22	
    23	  # ────────────────────────────────────────────────────────────────────────
    24	  # Accounting providers (per-tenant — choose ONE via tenant_adapters.config.accounting_provider)
    25	  # ────────────────────────────────────────────────────────────────────────
    26	
    27	  - id: xero_oauth
    28	    package: "@ifos/xero"
    29	    purpose: "Xero OAuth 2.0 refresh + concurrent-safe token rotation"
    30	    action_type: xero_oauth          # green tier; registration queued for W7-8
    31	    cycle_step: 1
    32	    secrets_required: [XERO_CLIENT_ID, XERO_CLIENT_SECRET]
    33	    rate_limit_hint: "60/min per tenant_id (see @ifos/xero README §Rate limits)"
    34	
    35	  - id: xero_list_open_invoices
    36	    package: "@ifos/xero"
    37	    purpose: "Paginated AUTHORISED+SUBMITTED invoices with AmountDue > 0"
    38	    cycle_step: 4
    39	    state_changing: false
    40	
    41	  - id: xero_get_invoice
    42	    package: "@ifos/xero"
    43	    purpose: "Single-entity invoice fetch by Xero InvoiceID (used at Gate A G1 re-check)"
    44	    cycle_step: 9
    45	    state_changing: false
    46	
    47	  - id: xero_list_payments
    48	    package: "@ifos/xero"
    49	    purpose: "List ACCRECPAYMENT records (reconciliation context)"
    50	    cycle_step: 5
    51	    state_changing: false
    52	
    53	  - id: xero_write_payment_received
    54	    package: "@ifos/xero"
    55	    purpose: "Auto-write Stage 1-2 reconciliation matches (yellow tier; spot-check sampled)"
    56	    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED in autosend-policy.yaml
    57	    cycle_step: 6
    58	    state_changing: true
    59	
    60	  - id: quickbooks_oauth

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '145,170p;235,250p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   145	    agent: diagnostic
   146	    reason: "Internal audit row written by cleanup.sh at end of normal-completion run. Records cache-purge status + workspace cleanup; no external comms."
   147	    irreversible: false
   148	
   149	  # ───────────────────────────────────────────────────────────
   150	  # MCP-connector OAuth refresh action_types (added 2026-06-01
   151	  # per Codex cluster F Round 1 — review-mcp-connector §7 requires
   152	  # documented action_types to exist in this policy with matching
   153	  # tier; round-1 REJECT cited all 4 as missing). All green: OAuth
   154	  # refresh is idempotent token rotation, not external send.
   155	  # ───────────────────────────────────────────────────────────
   156	
   157	  xero_oauth:
   158	    tier: green
   159	    agent: cash-conductor
   160	    reason: "Xero OAuth 2.0 refresh — idempotent token rotation against identity.xero.com; @ifos/xero connector handles concurrent-refresh dedup per-tenant; no external send."
   161	    irreversible: false
   162	
   163	  quickbooks_oauth:
   164	    tier: green
   165	    agent: cash-conductor
   166	    reason: "QuickBooks Online OAuth 2.0 refresh — idempotent token rotation against oauth.platform.intuit.com; @ifos/quickbooks connector handles concurrent-refresh dedup per-realm; QB refresh tokens have ~100-day TTL so operator alerting on refreshTokenNearExpiry() is the consumer's responsibility, not this action_type's."
   167	    irreversible: false
   168	
   169	  open_banking_truelayer:
   170	    tier: green
   235	    tier: yellow
   236	    agent: scribe
   237	    sample_rate: 10
   238	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   239	    irreversible: false
   240	
   241	  accounting_reconciliation_write:
   242	    tier: yellow
   243	    agent: cash-conductor
   244	    sample_rate: 10
   245	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   246	    irreversible: false
   247	
   248	  concierge_email_draft:
   249	    tier: yellow
   250	    agent: concierge

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/src/client.ts | sed -n '80,210p' && nl -ba packages/mcp-connectors/xero/src/payments.ts | sed -n '55,85p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    80	    // Build URL with query
    81	    const url = new URL(XERO_BASE_URL + path);
    82	    if (options.query) {
    83	      for (const [k, v] of Object.entries(options.query)) {
    84	        url.searchParams.set(k, v);
    85	      }
    86	    }
    87	
    88	    let last_error: unknown = null;
    89	    for (let attempt = 0; attempt <= max_retries; attempt++) {
    90	      // Pre-emptive rate-limit check
    91	      const allowed = consume(this.opts.config.tenant_id, this.now);
    92	      if (!allowed) {
    93	        throw new XeroRateLimitError(
    94	          `Xero rate-limit budget exhausted (tenant=${this.opts.config.tenant_id}); ` +
    95	            `local bucket prevents call to avoid upstream 429`,
    96	        );
    97	      }
    98	
    99	      const access_token = await this.getValidAccessToken();
   100	      const headers: Record<string, string> = {
   101	        Authorization: `Bearer ${access_token}`,
   102	        Accept: "application/json",
   103	        "Xero-tenant-id": this.opts.config.tenant_id,
   104	      };
   105	      if (options.body !== undefined) {
   106	        headers["Content-Type"] = "application/json";
   107	      }
   108	
   109	      let res: Response;
   110	      try {
   111	        res = await this.fetchFn(url.toString(), {
   112	          method,
   113	          headers,
   114	          body: options.body !== undefined ? JSON.stringify(options.body) : undefined,
   115	          signal: options.signal,
   116	        });
   117	      } catch (e) {
   118	        // Network error — retry up to max_retries (only for GET; isWrite=true → max_retries=0)
   119	        last_error = e;
   120	        if (attempt < max_retries) {
   121	          await sleep(backoff(attempt));
   122	          continue;
   123	        }
   124	        throw new XeroError(
   125	          `Xero network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
   126	        );
   127	      }
   128	
   129	      // 200-299 happy path
   130	      if (res.ok) {
   131	        return (await res.json()) as T;
   132	      }
   133	
   134	      // 401: server invalidated the access_token — force an explicit refresh
   135	      // BEFORE the next iteration. Per Codex F-R2 issue #1 (xero): nulling the
   136	      // cached token alone is insufficient — getValidAccessToken() will reload
   137	      // the SAME stale token from disk if shouldRefresh() says it's not near
   138	      // expiry (the access_token's epoch-expiry is unaffected by server-side
   139	      // revocation). Rotate it now; persist the new bundle; let the next
   140	      // iteration pick up the rotated token.
   141	      if (res.status === 401 && attempt < max_retries) {
   142	        if (this.current_tokens) {
   143	          // Throws XeroAuthError on refresh failure → propagates correctly.
   144	          this.current_tokens = await refreshTokens(
   145	            this.opts.config,
   146	            this.current_tokens,
   147	            this.fetchFn,
   148	          );
   149	        } else {
   150	          // No cached tokens — let getValidAccessToken() either load fresh
   151	          // from disk or throw the canonical "no tokens; bootstrap required"
   152	          // XeroAuthError on the next iteration.
   153	        }
   154	        await sleep(backoff(attempt));
   155	        continue;
   156	      }
   157	      // 401 after retries exhausted: surface as AUTH-typed error so the
   158	      // consumer's branch logic maps to ESC_ACCOUNTING_AUTH correctly.
   159	      if (res.status === 401) {
   160	        throw new XeroAuthError(
   161	          `Xero ${method} ${path} returned 401 after ${attempt + 1} attempt(s) including forced refresh`,
   162	          401,
   163	        );
   164	      }
   165	
   166	      // 429: rate-limited; honour Retry-After then retry (GET only)
   167	      if (res.status === 429 && attempt < max_retries) {
   168	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   169	        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
   170	        await sleep(waitMs);
   171	        continue;
   172	      }
   173	      if (res.status === 429) {
   174	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   175	        throw new XeroRateLimitError(
   176	          `Xero returned 429 after ${attempt + 1} attempt(s)`,
   177	          retryAfter > 0 ? retryAfter : null,
   178	        );
   179	      }
   180	
   181	      // 5xx: retry with backoff (GET only)
   182	      if (res.status >= 500 && attempt < max_retries) {
   183	        await sleep(backoff(attempt));
   184	        continue;
   185	      }
   186	
   187	      // 4xx (non-401/429): typed error, no retry
   188	      const safeBody = await res.text().catch(() => "");
   189	      if (res.status === 404) {
   190	        throw new XeroNotFoundError(`Xero 404 on ${method} ${path}`);
   191	      }
   192	      if (res.status === 400) {
   193	        throw new XeroValidationError(
   194	          `Xero rejected ${method} ${path} (HTTP 400)`,
   195	          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
   196	        );
   197	      }
   198	      throw new XeroError(
   199	        `Xero ${method} ${path} failed (HTTP ${res.status})`,
   200	        res.status,
   201	      );
   202	    }
   203	    throw new XeroError(
   204	      `Xero ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
   205	    );
   206	  }
   207	}
    55	 * Write a payment received against an invoice. State-changing — emits
    56	 * action_type='accounting_reconciliation_write' (yellow tier per
    57	 * autosend-policy.yaml; documented in agents/recruitment/cash-conductor/agent.md §3).
    58	 *
    59	 * No retry on write failure — caller decides (Cash Conductor §4 Step 6
    60	 * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
    61	 */
    62	export async function writePaymentReceived(
    63	  client: XeroClient,
    64	  payment: XeroPaymentWriteRequest,
    65	): Promise<XeroPayment> {
    66	  const res = await client.request<XeroPaymentsResponse>("/Payments", {
    67	    method: "PUT",
    68	    body: { Payments: [payment] },
    69	    max_retries: 0,
    70	  });
    71	  const created = res.Payments?.[0];
    72	  if (!created) {
    73	    throw new Error(
    74	      "Xero PUT /Payments succeeded but response contained no Payment record",
    75	    );
    76	  }
    77	  return created;
    78	}

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/README.md | sed -n '1,75p;80,125p;130,170p;180,205p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# @ifos/xero
     2	
     3	Xero Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 token rotation + invoice read + payment read/write. Fixture-first; live tests deferred to first commercial Xero signup (see §Tests).
     4	
     5	**Status:** Proposed (W4 Day-25 overnight scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial Xero signup for live-test verification).
     6	
     7	**Reference pattern:** mirrors `@ifos/companies-house` (Day-13 RATIFIED). Every new MCP connector follows this structure per `review-mcp-connector.md` §1.
     8	
     9	---
    10	
    11	## Capabilities
    12	
    13	Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.
    14	
    15	| Capability ID (tools.yaml) | Function (src/index.ts) | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
    16	|---|---|---|---|---|---|
    17	| `xero_oauth` | `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per tenant; atomic-file-write persistence | Step 1 (auth refresh) | `xero_oauth` | green |
    18	| `xero_list_open_invoices` | `listOpenInvoices(client, options?)` | Page through AUTHORISED+SUBMITTED invoices with AmountDue > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
    19	| `xero_get_invoice` | `getInvoice(client, invoiceId, options?)` | Fetch single invoice by Xero InvoiceID | Step 9 (chase-draft validation) | n/a | n/a |
    20	| `xero_list_payments` | `listPayments(client, options?)` | List ACCRECPAYMENT records (reconciliation context) | Step 5 (reconciliation pass) | n/a | n/a |
    21	| `xero_write_payment_received` | `writePaymentReceived(client, payment)` | PUT /Payments — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
    22	
    23	All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (`xero_oauth` registered as green per Codex F-R2 closure 2026-06-01; `accounting_reconciliation_write` already present per Day-25 verification). Line numbers in the policy file shift across edits — verify via `grep -n "^  xero_oauth:" agents/_shared/autosend-policy.yaml` rather than relying on a static citation here.
    24	
    25	### Internal helpers (NOT bus-routed capabilities)
    26	
    27	Exposed by `src/index.ts` for consumer convenience + testing, but NOT declared in `tools.yaml`:
    28	
    29	| Function | Purpose |
    30	|---|---|
    31	| `XeroClient` (class) | Transport — constructed once by cycle.sh Step 1; not a capability in the bus sense (no `action_type`; no authz check) |
    32	| `loadTokens(config)` / `saveTokens(config, t)` | Token-file I/O — called by `refreshTokens`; surfaced for test setup and operator-shell consent-bootstrap helpers |
    33	| `shouldRefresh(tokens, now?, window?)` | Pure predicate — `true` when the access_token expires within `safety_window_ms` (default 5 min); callers use it to decide eager-refresh |
    34	| `rateCheck(tenant_id, now?)` | Returns `RateState` — exposes the **soft-backoff signal** (`shouldBackoff: true` at 80% of either bucket); the consuming cycle.sh is responsible for honouring it (see §Rate limits) |
    35	| `rateConsume(tenant_id, now?)` | Consumes a slot; returns false at the hard 100% gate — the soft signal is read-only |
    36	| `resetRateLimit(tenant_id?)` | Test/diagnostic reset |
    37	| `_resetInflightForTest()` | Clears in-flight OAuth-refresh dedup map; for tests only |
    38	| `XeroCache` (class) | Disk cache — default TTL 5min; surfaced for cache-aware test cases |
    39	
    40	---
    41	
    42	## Quick start
    43	
    44	```typescript
    45	import { XeroClient, listOpenInvoices, writePaymentReceived } from "@ifos/xero";
    46	
    47	const client = new XeroClient({
    48	  config: {
    49	    client_id: process.env.XERO_CLIENT_ID!,
    50	    client_secret: process.env.XERO_CLIENT_SECRET!,
    51	    tenant_id: "<xero-tenant-id-from-connections-endpoint>",
    52	    token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/xero-tokens.json`,
    53	  },
    54	});
    55	
    56	const invoices = await listOpenInvoices(client, { issued_since: "2026-04-01" });
    57	for (const inv of invoices) {
    58	  if (matchesBankDeposit(inv)) {
    59	    await writePaymentReceived(client, {
    60	      Invoice: { InvoiceID: inv.InvoiceID },
    61	      Account: { Code: "090" },
    62	      Date: "2026-05-22",
    63	      Amount: inv.AmountDue,
    64	      Reference: bankReference,
    65	    });
    66	  }
    67	}
    68	```
    69	
    70	---
    71	
    72	## OAuth bootstrap (one-time, per Xero tenant)
    73	
    74	The connector handles the **refresh** half of OAuth 2.0. The **initial authorisation** (consent screen → authorisation code → first token pair) is a one-time human-in-the-loop dance not covered here. Bootstrap procedure (manual):
    75	
    80	5. Call `GET https://api.xero.com/connections` with the access_token → get the `tenant_id` (Xero "connection ID").
    81	6. Write the token bundle to `token_file_path` as JSON; mode 0600.
    82	
    83	After bootstrap, this connector's `refreshTokens()` handles all subsequent rotations automatically.
    84	
    85	---
    86	
    87	## Rate limits
    88	
    89	Per the published Xero limits page (https://developer.xero.com/documentation/guides/oauth2/limits):
    90	
    91	- **60 calls / 60-second window per app per tenant** (minute bucket)
    92	- **5000 calls / day per tenant** (daily bucket, resets at midnight UTC)
    93	- **5 concurrent calls per app per tenant** — not enforced here; single-process Cash Conductor cycle.sh is serial
    94	
    95	This connector tracks BOTH windows per `src/rate-limit.ts`. **Hard gate at 100%** (`consume()` returns false → `XeroRateLimitError`). **Soft signal at 80%** (48/minute, 4000/day) is read-only and exposed via `rateCheck()` — `RateState.shouldBackoff === true` with `reason: "minute-soft" | "daily-soft"`. The consuming agent layer (Cash Conductor cycle.sh) is responsible for honouring the soft signal (e.g. pausing batch operations); the connector does not silently throttle — the contract is "callers query soft, connector enforces hard". `tests/rate-limit.test.ts` exercises both thresholds (`hits soft backoff at minute-soft (48)` + `hits hard fail at minute-hard (60)`).
    96	
    97	State is in-process and per-tenant — a multi-tenant runtime that holds many `XeroClient` instances in one process still gets correct isolation.
    98	
    99	**ESC contract on bucket exhaustion** (consumer-emitted via `agents/_shared/hook-helpers.sh`):
   100	
   101	| Failure | Surfaces as | ESC code (escalation-codes.md) | Payload contract |
   102	|---|---|---|---|
   103	| Local hard-gate (100%) reached | `XeroRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "xero", retry_after_seconds: null, consecutive_429s: 0}` |
   104	| Upstream 429 from Xero API | `XeroRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "xero", retry_after_seconds: <N>, consecutive_429s: <N>}` |
   105	
   106	Both surface as the same ESC code because from the operator's perspective they're the same operational signal (Xero traffic is being throttled). The distinction is in the payload (`retry_after_seconds: null` means local pre-emptive vs upstream-issued).
   107	
   108	---
   109	
   110	## Retry policy
   111	
   112	| Capability | Method | Max retries | Backoff | On exhaustion |
   113	|---|---|---|---|---|
   114	| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `XeroError` or `XeroRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
   115	| `writePaymentReceived` | PUT | **0** | n/a (writes never auto-retry) | `XeroValidationError` (400) / `XeroError` (5xx) → `ESC_ACCOUNTING_WRITE_FAIL` (warn; operator; consumer-emitted; payload includes `provider: "xero"`, `endpoint: "/Payments"`, `status_code`, `error_body_preview`) |
   116	| `refreshTokens` | POST | **0** | n/a | `XeroAuthError` → `ESC_ACCOUNTING_AUTH` (blocking; consumer-emitted; caller may re-attempt with fresh credentials per Bootstrap §) |
   117	| 401 from any GET | — | force-refresh access_token, retry once | — | `XeroAuthError` → `ESC_ACCOUNTING_AUTH` |
   118	| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `XeroRateLimitError` → `ESC_RATE_LIMIT_HIT` |
   119	
   120	Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to Xero.
   121	
   122	The connector itself does NOT write `decision_log` rows (vault/Postgres split per ADR-002); the consuming `cycle.sh` catches the typed errors above and emits the right ESC via `hh_decision_action`/`hh_decision_output` from `agents/_shared/hook-helpers.sh`.
   123	
   124	---
   125	
   130	├── XeroAuthError          // OAuth refresh fail (401/4xx on token endpoint)
   131	├── XeroRateLimitError     // 429 OR local bucket exhausted
   132	├── XeroNotFoundError      // 404
   133	└── XeroValidationError    // 400 (typically schema/business-rule)
   134	```
   135	
   136	Errors NEVER include credential values in their `.message` — only the key NAMES, status code, and safe metadata. Per `review-mcp-connector.md` §5 (zero secret interpolation).
   137	
   138	---
   139	
   140	## Tests
   141	
   142	```bash
   143	# Unit + fixture tests (fast; no network)
   144	pnpm test
   145	```
   146	
   147	**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.
   148	
   149	**Live tests are deferred** to the first commercial Xero signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal per review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold lands in the same commit as the first sandbox credentials per the W4 Track-1 /goal §1 commercial-gate.
   150	
   151	Test counts:
   152	- `tests/scaffold.test.ts`: 5 (public surface, exports, error hierarchy)
   153	- `tests/rate-limit.test.ts`: 7 (initial state, minute soft 48, minute hard 60, per-tenant isolation, **daily-soft 4000, daily-hard 5000** — daily-bucket coverage added per Codex F-R2 #4)
   154	- `tests/auth.test.ts`: 7 (load missing, round-trip, shouldRefresh, refresh success, 401 + no-token-leak, concurrent dedup, etc.)
   155	- `tests/capabilities.test.ts`: 9 (list/get invoice happy + 404, list/write payment happy + 400, **listOpenInvoices 429 retry-exhaust, listPayments 500 retry-exhaust, 401-forces-refresh-then-retry** — all 3 added per Codex F-R1/F-R2)
   156	
   157	**Total: 28 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
   158	
   159	---
   160	
   161	## Build
   162	
   163	```bash
   164	pnpm build       # tsup → dist/index.{js,d.ts}
   165	pnpm typecheck   # tsc --noEmit
   166	```
   167	
   168	ESM-only; node 20+; target ES2022. Same toolchain as @ifos/companies-house.
   169	
   170	---
   180	   ├── Step 6 (reconciliation write)    ──┤    │
   181	   └── Step 9 (chase-draft validation)  ──┘    │
   182	                                              ↓
   183	                                         Xero REST API
   184	                                         https://api.xero.com/api.xro/2.0
   185	                                              ↓
   186	                                         OAuth bearer +
   187	                                         Xero-tenant-id header
   188	```
   189	
   190	Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is the substrate it consumes.
   191	
   192	---
   193	
   194	## Boundary checks
   195	
   196	Per `review-mcp-connector.md` §8:
   197	- ✓ No Composio / AgentMail references
   198	- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
   199	- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)
   200	- ✓ No hardcoded tenant slugs in `src/` (test fixtures only — `fixture-tenant`, `test-tenant-rate-limit`)
   201	
   202	---
   203	
   204	*v0.1.0 — scaffold landed 2026-05-31 overnight.*

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/tests/scaffold.test.ts | sed -n '1,80p'; nl -ba packages/mcp-connectors/xero/tests/capabilities.test.ts | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// Package public surface smoke tests. Per review-mcp-connector §1
     2	// (capabilities surface — exports match README capability table).
     3	
     4	import { describe, expect, it } from "vitest";
     5	import {
     6	  VERSION,
     7	  XeroClient,
     8	  XERO_BASE_URL,
     9	  loadTokens,
    10	  saveTokens,
    11	  refreshTokens,
    12	  shouldRefresh,
    13	  listOpenInvoices,
    14	  getInvoice,
    15	  listPayments,
    16	  writePaymentReceived,
    17	  XeroCache,
    18	  XeroError,
    19	  XeroAuthError,
    20	  XeroRateLimitError,
    21	  XeroNotFoundError,
    22	  XeroValidationError,
    23	} from "../src/index.js";
    24	
    25	describe("@ifos/xero package surface", () => {
    26	  it("exports VERSION 0.1.0", () => {
    27	    expect(VERSION).toBe("0.1.0");
    28	  });
    29	
    30	  it("exports XeroClient class + base URL", () => {
    31	    expect(typeof XeroClient).toBe("function");
    32	    expect(XERO_BASE_URL).toBe("https://api.xero.com/api.xro/2.0");
    33	  });
    34	
    35	  it("exports all 4 capability functions", () => {
    36	    expect(typeof listOpenInvoices).toBe("function");
    37	    expect(typeof getInvoice).toBe("function");
    38	    expect(typeof listPayments).toBe("function");
    39	    expect(typeof writePaymentReceived).toBe("function");
    40	  });
    41	
    42	  it("exports auth helpers (load/save/refresh/shouldRefresh)", () => {
    43	    expect(typeof loadTokens).toBe("function");
    44	    expect(typeof saveTokens).toBe("function");
    45	    expect(typeof refreshTokens).toBe("function");
    46	    expect(typeof shouldRefresh).toBe("function");
    47	  });
    48	
    49	  it("exports XeroCache + error hierarchy", () => {
    50	    expect(typeof XeroCache).toBe("function");
    51	    // All error classes extend XeroError
    52	    expect(new XeroAuthError("x") instanceof XeroError).toBe(true);
    53	    expect(new XeroRateLimitError("x") instanceof XeroError).toBe(true);
    54	    expect(new XeroNotFoundError("x") instanceof XeroError).toBe(true);
    55	    expect(new XeroValidationError("x") instanceof XeroError).toBe(true);
    56	  });
    57	});
     1	// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
     2	// path + ≥1 error path per capability).
     3	
     4	import { promises as fs } from "node:fs";
     5	import { tmpdir } from "node:os";
     6	import { join } from "node:path";
     7	import { afterEach, beforeEach, describe, expect, it } from "vitest";
     8	import { XeroClient } from "../src/client.js";
     9	import { XeroCache } from "../src/cache.js";
    10	import { saveTokens, _resetInflightForTest } from "../src/auth.js";
    11	import { reset as resetRateLimit } from "../src/rate-limit.js";
    12	import { listOpenInvoices, getInvoice } from "../src/invoices.js";
    13	import {
    14	  listPayments,
    15	  writePaymentReceived,
    16	} from "../src/payments.js";
    17	import {
    18	  XeroError,
    19	  XeroNotFoundError,
    20	  XeroRateLimitError,
    21	  XeroValidationError,
    22	} from "../src/errors.js";
    23	import type {
    24	  XeroOAuthConfig,
    25	  XeroTokens,
    26	  XeroPaymentWriteRequest,
    27	} from "../src/types.js";
    28	
    29	import INVOICES_PAGE_1 from "../fixtures/invoices-page-1.json" with { type: "json" };
    30	import PAYMENTS_RECENT from "../fixtures/payments-recent.json" with { type: "json" };
    31	import PAYMENT_WRITE_OK from "../fixtures/payment-write-ok.json" with { type: "json" };
    32	
    33	const FIXTURE_TOKENS: XeroTokens = {
    34	  access_token: "fake-access",
    35	  refresh_token: "fake-refresh",
    36	  expires_at_ms: Date.now() + 1800_000,
    37	  scope: "accounting.transactions offline_access",
    38	  token_type: "Bearer",
    39	};
    40	
    41	let token_file: string;
    42	let cache_dir: string;
    43	let cache: XeroCache;
    44	
    45	function makeConfig(): XeroOAuthConfig {
    46	  return {
    47	    client_id: "fake-client-id",
    48	    client_secret: "fake-client-secret",
    49	    tenant_id: "fixture-tenant",
    50	    token_file_path: token_file,
    51	  };
    52	}
    53	
    54	function makeOkResponse(body: unknown): Response {
    55	  return new Response(JSON.stringify(body), {
    56	    status: 200,
    57	    headers: { "Content-Type": "application/json" },
    58	  });
    59	}
    60	
    61	beforeEach(async () => {
    62	  token_file = join(tmpdir(), `xero-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`);
    63	  cache_dir = join(tmpdir(), `xero-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`);
    64	  cache = new XeroCache(cache_dir);
    65	  _resetInflightForTest();
    66	  resetRateLimit();
    67	  await saveTokens(makeConfig(), FIXTURE_TOKENS);
    68	});
    69	
    70	afterEach(async () => {
    71	  await fs.unlink(token_file).catch(() => undefined);
    72	  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
    73	});
    74	
    75	describe("xero capabilities — invoices", () => {
    76	  it("listOpenInvoices: returns parsed array from fixture", async () => {
    77	    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    78	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    79	    const invoices = await listOpenInvoices(client, { cache, no_cache: true });
    80	    expect(invoices.length).toBe(2);
    81	    expect(invoices[0]?.InvoiceID).toBe("0000aaaa-1111-2222-3333-444455556666");
    82	    expect(invoices[0]?.AmountDue).toBe(1200);
    83	    expect(invoices[1]?.Contact.Name).toBe("Beta Search Partners");
    84	  });
    85	
    86	  it("getInvoice: returns single invoice when present", async () => {
    87	    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    88	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    89	    const inv = await getInvoice(client, "0000aaaa-1111-2222-3333-444455556666", {
    90	      cache,
    91	      no_cache: true,
    92	    });
    93	    expect(inv).not.toBeNull();
    94	    expect(inv?.InvoiceNumber).toBe("INV-0001");
    95	  });
    96	
    97	  it("getInvoice: 404 surfaces as XeroNotFoundError", async () => {
    98	    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    99	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   100	    await expect(
   101	      getInvoice(client, "00000000-0000-0000-0000-000000000000", { cache, no_cache: true }),
   102	    ).rejects.toBeInstanceOf(XeroNotFoundError);
   103	  });
   104	
   105	  // Error-path coverage for listOpenInvoices (per review-mcp-connector §6 +
   106	  // Codex F-R1 issue #4: every capability needs ≥1 happy + ≥1 error fixture).
   107	  it("listOpenInvoices: persistent 429 surfaces as XeroRateLimitError after retries", async () => {
   108	    let calls = 0;
   109	    const fakeFetch: typeof fetch = async () => {
   110	      calls += 1;
   111	      return new Response("", {
   112	        status: 429,
   113	        headers: { "Retry-After": "0" }, // 0s = no wait; just exhausts retries fast
   114	      });
   115	    };
   116	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   117	    await expect(
   118	      listOpenInvoices(client, { cache, no_cache: true }),
   119	    ).rejects.toBeInstanceOf(XeroRateLimitError);
   120	    expect(calls).toBeGreaterThanOrEqual(2); // initial + ≥1 retry per max_retries=2 default for GET
   121	  });
   122	});
   123	
   124	describe("xero capabilities — payments", () => {
   125	  it("listPayments: returns parsed array from fixture", async () => {
   126	    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENTS_RECENT);
   127	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   128	    const payments = await listPayments(client, { cache, no_cache: true });
   129	    expect(payments.length).toBe(1);
   130	    expect(payments[0]?.Amount).toBe(2000);
   131	    expect(payments[0]?.PaymentType).toBe("ACCRECPAYMENT");
   132	  });
   133	
   134	  it("writePaymentReceived: success path returns created payment", async () => {
   135	    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENT_WRITE_OK);
   136	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   137	    const payload: XeroPaymentWriteRequest = {
   138	      Invoice: { InvoiceID: "0000aaaa-1111-2222-3333-444455556666" },
   139	      Account: { Code: "090" },
   140	      Date: "2026-05-22",
   141	      Amount: 1200.0,
   142	      Reference: "BACS-2026-05-22-002",
   143	    };
   144	    const created = await writePaymentReceived(client, payload);
   145	    expect(created.PaymentID).toBe("p000-cccc-2222");
   146	    expect(created.Amount).toBe(1200);
   147	  });
   148	
   149	  it("writePaymentReceived: 400 surfaces as XeroValidationError (no retry)", async () => {
   150	    let calls = 0;
   151	    const fakeFetch: typeof fetch = async () => {
   152	      calls += 1;
   153	      return new Response("Invoice ID does not exist", { status: 400 });
   154	    };
   155	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   156	    const payload: XeroPaymentWriteRequest = {
   157	      Invoice: { InvoiceID: "00000000-0000-0000-0000-000000000000" },
   158	      Account: { Code: "090" },
   159	      Date: "2026-05-22",
   160	      Amount: 1200.0,
   161	    };
   162	    await expect(writePaymentReceived(client, payload)).rejects.toBeInstanceOf(XeroValidationError);
   163	    expect(calls).toBe(1); // write was NOT retried
   164	  });
   165	
   166	  // Error-path coverage for listPayments (per review-mcp-connector §6 +
   167	  // Codex F-R1 issue #4): GET retries 5xx exponentially; after retries
   168	  // exhausted the typed error is XeroError (NOT XeroRateLimitError).
   169	  it("listPayments: persistent 500 surfaces as XeroError after retries", async () => {
   170	    let calls = 0;
   171	    const fakeFetch: typeof fetch = async () => {
   172	      calls += 1;
   173	      return new Response("Xero internal error", { status: 500 });
   174	    };
   175	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   176	    await expect(
   177	      listPayments(client, { cache, no_cache: true }),
   178	    ).rejects.toBeInstanceOf(XeroError);
   179	    expect(calls).toBeGreaterThanOrEqual(2); // initial + retries per max_retries=2
   180	  });
   181	
   182	  // 401-forces-refresh: per Codex F-R2 issue #1, a 401 on a GET MUST trigger
   183	  // an explicit refreshTokens() call before retrying — NOT just null the cache
   184	  // (which would reload the same stale token from disk if shouldRefresh()
   185	  // returns false). This test would FAIL against the pre-fix code: the second
   186	  // GET would use the same access_token and the 401 loop would never break.
   187	  it("401 on GET forces explicit token refresh + retry uses new access_token", async () => {
   188	    let getCalls = 0;
   189	    let refreshCalls = 0;
   190	    let observedSecondAuth: string | null = null;
   191	
   192	    const fakeFetch: typeof fetch = async (input, init) => {
   193	      const url = typeof input === "string" ? input : (input as URL).toString();
   194	      if (url.includes("identity.xero.com/connect/token")) {
   195	        refreshCalls += 1;
   196	        return new Response(
   197	          JSON.stringify({
   198	            access_token: "rotated-access-token-after-401",
   199	            refresh_token: "rotated-refresh-token",
   200	            expires_in: 1800,
   201	            scope: "accounting.transactions offline_access",
   202	            token_type: "Bearer",
   203	          }),
   204	          { status: 200, headers: { "Content-Type": "application/json" } },
   205	        );
   206	      }
   207	      // Invoice GET path
   208	      getCalls += 1;
   209	      if (getCalls === 1) {
   210	        return new Response("", { status: 401 });
   211	      }
   212	      observedSecondAuth = (init?.headers as Record<string, string>)?.["Authorization"] ?? null;
   213	      return makeOkResponse(INVOICES_PAGE_1);
   214	    };
   215	
   216	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   217	    const invoices = await listOpenInvoices(client, { cache, no_cache: true });
   218	
   219	    expect(invoices.length).toBe(2);
   220	    expect(getCalls).toBe(2); // initial 401 + retry
   221	    expect(refreshCalls).toBe(1); // forced refresh between attempts
   222	    expect(observedSecondAuth).toBe("Bearer rotated-access-token-after-401");
   223	  });
   224	});

exec
/bin/zsh -lc "rg -n \"console\\.(log|error|warn).*\\"'$'"\\{.*(KEY|SECRET|PASSWORD|TOKEN|BEARER)|throw\\s+new\\s+Error.*\\"'$'"\\{.*(KEY|SECRET|PASSWORD)\" packages/mcp-connectors/xero || true" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
codex
I’m checking the connector against the ratification rules with the repo files in place, especially the autosend policy and Cash Conductor tool references rather than trusting the README’s claims.
exec
/bin/zsh -lc 'pnpm --filter @ifos/xero test' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'pnpm --filter @ifos/xero typecheck' in /Users/madsadmin/code/CortexOS
 succeeded in 1462ms:

> @ifos/xero@0.1.0 typecheck /Users/madsadmin/code/CortexOS/packages/mcp-connectors/xero
> tsc --noEmit


 succeeded in 2627ms:

> @ifos/xero@0.1.0 test /Users/madsadmin/code/CortexOS/packages/mcp-connectors/xero
> vitest run


 RUN  v2.1.9 /Users/madsadmin/code/CortexOS/packages/mcp-connectors/xero

 ✓ tests/scaffold.test.ts (5 tests) 3ms
 ✓ tests/auth.test.ts (7 tests) 59ms
 ✓ tests/rate-limit.test.ts (7 tests) 709ms
   ✓ xero rate-limit > daily bucket (5000/day per Xero published limit) > blocks at daily-hard 5000 (consume returns false on the 5001st call) 420ms
 ✓ tests/capabilities.test.ts (9 tests) 790ms
   ✓ xero capabilities — payments > listPayments: persistent 500 surfaces as XeroError after retries 413ms

 Test Files  4 passed (4)
      Tests  28 passed (28)
   Start at  12:18:57
   Duration  1.65s (transform 196ms, setup 0ms, collect 372ms, tests 1.56s, environment 1ms, prepare 252ms)


codex
The local tests and typecheck both pass for `@ifos/xero`. I’m doing one final pass for specification mismatches, because passing unit tests does not cover the ratification boundary checks.
exec
/bin/zsh -lc 'rg -n "Xero|xero|InvoiceID|PaymentID|AmountDue|accounting_reconciliation_write|xero_oauth|ESC_PROVIDER_FETCH_FAIL|ESC_ACCOUNTING_WRITE_FAIL|ESC_ACCOUNTING_AUTH" agents/recruitment/cash-conductor packages/mcp-connectors/xero docs/verticals/recruitment/vertical-schema.yaml 2>/dev/null' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "invoice|payment|xero|accounting|reconciliation|AmountDue|InvoiceID|PaymentID" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:296:#     match invoiced amounts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:418:    contact: R             # IFOS-cached read; invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:420:    opportunity: R         # v0.3 NEW — IFOS-cached read; invoice-context (NOT a direct Bullhorn call; only cached rows)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:421:    placement: R           # IFOS-cached read; client linkage on invoice
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:422:    timesheet: R           # IFOS-cached read; verify billable hours match invoice (NOT a direct Bullhorn call)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:426:    # v0.3 EXPLICIT OVERRIDES — R20 reconciliation (2026-05-27): the original
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:477:      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:490:      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:516:      - Cash Conductor (R) # v0.3 NEW — reads for invoice context
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:637:      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:638:      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:658:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:660:      Open invoice register cached from accounting provider. Same auxiliary-
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:666:      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:667:      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:668:      invoice_number: {type: string, required: false, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:672:      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:693:      W4 polish, production use of cash_conductor_invoices is GATED by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:746:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:771:      transactions/invoices since this timestamp.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:905:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:990:         rows retained beyond 7 years for cross-period reconciliation).
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:129:      - Cash Conductor (R — payment reminder tone)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:73:  matched_invoice_id TEXT,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:114:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:117:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:120:  invoice_id               TEXT NOT NULL,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:121:  accounting_provider      TEXT NOT NULL,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:122:  invoice_number           TEXT,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:141:    accounting_provider IN ('xero', 'quickbooks', 'sage')
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:149:  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:153:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:156:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:160:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:163:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:164:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:167:DROP POLICY IF EXISTS cci_tenant_isolation ON cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:168:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:172:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:173:GRANT USAGE, SELECT ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:197:DROP TRIGGER IF EXISTS set_updated_at_cci ON cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:199:  BEFORE UPDATE ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:552:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:554:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:557:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:37:  IF to_regclass('public.cash_conductor_invoices') IS NOT NULL THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:38:    SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:41:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:52:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:109:    WHERE table_name = 'cash_conductor_invoices';

 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
packages/mcp-connectors/xero/src/auth.ts:1:// Xero OAuth 2.0 token refresh + atomic disk persistence + concurrent-call dedup.
packages/mcp-connectors/xero/src/auth.ts:14:// Token file path is per-tenant (configured via XeroOAuthConfig.token_file_path).
packages/mcp-connectors/xero/src/auth.ts:15:// Recommend: ~/.ifos-local-vault/<tenant>/xero-tokens-<xero_tenant_id>.json (mode 0600).
packages/mcp-connectors/xero/src/auth.ts:18:import { XeroAuthError } from "./errors.js";
packages/mcp-connectors/xero/src/auth.ts:19:import type { XeroOAuthConfig, XeroTokens } from "./types.js";
packages/mcp-connectors/xero/src/auth.ts:21:const XERO_TOKEN_ENDPOINT = "https://identity.xero.com/connect/token";
packages/mcp-connectors/xero/src/auth.ts:26:const inflight: Map<string, Promise<XeroTokens>> = new Map();
packages/mcp-connectors/xero/src/auth.ts:30:  config: XeroOAuthConfig,
packages/mcp-connectors/xero/src/auth.ts:31:): Promise<XeroTokens | null> {
packages/mcp-connectors/xero/src/auth.ts:39:    const parsed = JSON.parse(raw) as XeroTokens;
packages/mcp-connectors/xero/src/auth.ts:58:  config: XeroOAuthConfig,
packages/mcp-connectors/xero/src/auth.ts:59:  tokens: XeroTokens,
packages/mcp-connectors/xero/src/auth.ts:71:  tokens: XeroTokens,
packages/mcp-connectors/xero/src/auth.ts:82: * Throws XeroAuthError on 4xx (credentials rejected); does NOT retry — caller
packages/mcp-connectors/xero/src/auth.ts:86:  config: XeroOAuthConfig,
packages/mcp-connectors/xero/src/auth.ts:87:  current_tokens: XeroTokens,
packages/mcp-connectors/xero/src/auth.ts:89:): Promise<XeroTokens> {
packages/mcp-connectors/xero/src/auth.ts:115:        // Never include the response body verbatim — Xero may echo the
packages/mcp-connectors/xero/src/auth.ts:117:        throw new XeroAuthError(
packages/mcp-connectors/xero/src/auth.ts:118:          `Xero OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
packages/mcp-connectors/xero/src/auth.ts:131:      const new_tokens: XeroTokens = {
packages/mcp-connectors/xero/src/rate-limit.ts:1:// Rate limiter for Xero. Per Xero published limits
packages/mcp-connectors/xero/src/rate-limit.ts:2:// (https://developer.xero.com/documentation/guides/oauth2/limits):
packages/mcp-connectors/xero/src/payments.ts:1:// Xero Payments capability surface — read + write (write is the only
packages/mcp-connectors/xero/src/payments.ts:3:// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
packages/mcp-connectors/xero/src/payments.ts:6:import type { XeroClient } from "./client.js";
packages/mcp-connectors/xero/src/payments.ts:7:import { XeroCache } from "./cache.js";
packages/mcp-connectors/xero/src/payments.ts:9:  XeroPayment,
packages/mcp-connectors/xero/src/payments.ts:10:  XeroPaymentsResponse,
packages/mcp-connectors/xero/src/payments.ts:11:  XeroPaymentWriteRequest,
packages/mcp-connectors/xero/src/payments.ts:21:  cache?: XeroCache;
packages/mcp-connectors/xero/src/payments.ts:26:  client: XeroClient,
packages/mcp-connectors/xero/src/payments.ts:28:): Promise<XeroPayment[]> {
packages/mcp-connectors/xero/src/payments.ts:29:  const cache = options.cache ?? XeroCache.fromEnv();
packages/mcp-connectors/xero/src/payments.ts:34:    const hit = await cache.get<XeroPayment[]>(key);
packages/mcp-connectors/xero/src/payments.ts:48:  const res = await client.request<XeroPaymentsResponse>("/Payments", { query });
packages/mcp-connectors/xero/src/payments.ts:56: * action_type='accounting_reconciliation_write' (yellow tier per
packages/mcp-connectors/xero/src/payments.ts:60: * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
packages/mcp-connectors/xero/src/payments.ts:63:  client: XeroClient,
packages/mcp-connectors/xero/src/payments.ts:64:  payment: XeroPaymentWriteRequest,
packages/mcp-connectors/xero/src/payments.ts:65:): Promise<XeroPayment> {
packages/mcp-connectors/xero/src/payments.ts:66:  const res = await client.request<XeroPaymentsResponse>("/Payments", {
packages/mcp-connectors/xero/src/payments.ts:74:      "Xero PUT /Payments succeeded but response contained no Payment record",
agents/recruitment/cash-conductor/cleanup.sh:24:#   - Purge ~/.ifos-cache/xero/* older than 24h (transient HTTP cache; keeps token files)
agents/recruitment/cash-conductor/cleanup.sh:28:#   - Reset in-process rate-limit buckets via @ifos/{xero,quickbooks,open-banking} resetRateLimit()
agents/recruitment/cash-conductor/cleanup.sh:33:#   - Token files at ~/.ifos-local-vault/<tenant>/{xero,qb,ob}-tokens-*.json (load-bearing)
agents/recruitment/cash-conductor/cleanup.sh:79:export XERO_CACHE_DIR="${IFOS_XERO_CACHE_DIR:-${HOME}/.ifos-cache/xero}"
agents/recruitment/cash-conductor/cleanup.sh:111:  "xero_cache_purged:${XERO_PURGED}; qb_cache_purged:${QB_PURGED}; ob_cache_purged:${OB_PURGED}; total:${TOTAL_PURGED}; mode:SKELETON"
agents/recruitment/cash-conductor/cleanup.sh:114:printf '[cash-conductor cleanup.sh] tenant=%s purged total=%d (xero=%d qb=%d ob=%d) mode=SKELETON\n' \
packages/mcp-connectors/xero/src/index.ts:1:// @ifos/xero — public API
packages/mcp-connectors/xero/src/index.ts:16:// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §xero)
packages/mcp-connectors/xero/src/index.ts:19:// xero_oauth (action_type: xero_oauth, green tier per autosend-policy.yaml)
packages/mcp-connectors/xero/src/index.ts:21:// xero_list_open_invoices (read-only) + xero_get_invoice (read-only)
packages/mcp-connectors/xero/src/index.ts:23:// xero_list_payments (read-only) + xero_write_payment_received
packages/mcp-connectors/xero/src/index.ts:24:// (action_type: accounting_reconciliation_write, yellow tier per autosend-policy.yaml)
packages/mcp-connectors/xero/src/index.ts:34:export { XeroClient, XERO_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
packages/mcp-connectors/xero/src/index.ts:38:export { XeroCache } from "./cache.js";
packages/mcp-connectors/xero/src/index.ts:51:  XeroError,
packages/mcp-connectors/xero/src/index.ts:52:  XeroAuthError,
packages/mcp-connectors/xero/src/index.ts:53:  XeroRateLimitError,
packages/mcp-connectors/xero/src/index.ts:54:  XeroNotFoundError,
packages/mcp-connectors/xero/src/index.ts:55:  XeroValidationError,
packages/mcp-connectors/xero/src/index.ts:58:  XeroTokens,
packages/mcp-connectors/xero/src/index.ts:59:  XeroOAuthConfig,
packages/mcp-connectors/xero/src/index.ts:60:  XeroInvoice,
packages/mcp-connectors/xero/src/index.ts:61:  XeroInvoicesResponse,
packages/mcp-connectors/xero/src/index.ts:62:  XeroPayment,
packages/mcp-connectors/xero/src/index.ts:63:  XeroPaymentsResponse,
packages/mcp-connectors/xero/src/index.ts:64:  XeroPaymentWriteRequest,
packages/mcp-connectors/xero/src/index.ts:65:  XeroClientOptions,
packages/mcp-connectors/xero/src/client.ts:1:// Xero HTTP client — wraps fetch with: OAuth token attach, rate-limit
packages/mcp-connectors/xero/src/client.ts:6:  XeroAuthError,
packages/mcp-connectors/xero/src/client.ts:7:  XeroError,
packages/mcp-connectors/xero/src/client.ts:8:  XeroNotFoundError,
packages/mcp-connectors/xero/src/client.ts:9:  XeroRateLimitError,
packages/mcp-connectors/xero/src/client.ts:10:  XeroValidationError,
packages/mcp-connectors/xero/src/client.ts:14:import type { XeroClientOptions, XeroTokens } from "./types.js";
packages/mcp-connectors/xero/src/client.ts:16:export const XERO_BASE_URL = "https://api.xero.com/api.xro/2.0";
packages/mcp-connectors/xero/src/client.ts:40:export class XeroClient {
packages/mcp-connectors/xero/src/client.ts:41:  private readonly opts: XeroClientOptions;
packages/mcp-connectors/xero/src/client.ts:44:  private current_tokens: XeroTokens | null = null;
packages/mcp-connectors/xero/src/client.ts:46:  constructor(opts: XeroClientOptions) {
packages/mcp-connectors/xero/src/client.ts:57:        throw new XeroAuthError(
packages/mcp-connectors/xero/src/client.ts:58:          "No Xero tokens on disk; consent flow required to bootstrap " +
packages/mcp-connectors/xero/src/client.ts:93:        throw new XeroRateLimitError(
packages/mcp-connectors/xero/src/client.ts:94:          `Xero rate-limit budget exhausted (tenant=${this.opts.config.tenant_id}); ` +
packages/mcp-connectors/xero/src/client.ts:103:        "Xero-tenant-id": this.opts.config.tenant_id,
packages/mcp-connectors/xero/src/client.ts:124:        throw new XeroError(
packages/mcp-connectors/xero/src/client.ts:125:          `Xero network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
packages/mcp-connectors/xero/src/client.ts:135:      // BEFORE the next iteration. Per Codex F-R2 issue #1 (xero): nulling the
packages/mcp-connectors/xero/src/client.ts:143:          // Throws XeroAuthError on refresh failure → propagates correctly.
packages/mcp-connectors/xero/src/client.ts:152:          // XeroAuthError on the next iteration.
packages/mcp-connectors/xero/src/client.ts:158:      // consumer's branch logic maps to ESC_ACCOUNTING_AUTH correctly.
packages/mcp-connectors/xero/src/client.ts:160:        throw new XeroAuthError(
packages/mcp-connectors/xero/src/client.ts:161:          `Xero ${method} ${path} returned 401 after ${attempt + 1} attempt(s) including forced refresh`,
packages/mcp-connectors/xero/src/client.ts:175:        throw new XeroRateLimitError(
packages/mcp-connectors/xero/src/client.ts:176:          `Xero returned 429 after ${attempt + 1} attempt(s)`,
packages/mcp-connectors/xero/src/client.ts:190:        throw new XeroNotFoundError(`Xero 404 on ${method} ${path}`);
packages/mcp-connectors/xero/src/client.ts:193:        throw new XeroValidationError(
packages/mcp-connectors/xero/src/client.ts:194:          `Xero rejected ${method} ${path} (HTTP 400)`,
packages/mcp-connectors/xero/src/client.ts:198:      throw new XeroError(
packages/mcp-connectors/xero/src/client.ts:199:        `Xero ${method} ${path} failed (HTTP ${res.status})`,
packages/mcp-connectors/xero/src/client.ts:203:    throw new XeroError(
packages/mcp-connectors/xero/src/client.ts:204:      `Xero ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:36:  accounting_provider: xero
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:52:    - InvoiceID: inv-fix-bbb-001
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:58:      AmountDue: 2500.00       # EXACT match
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:61:    - InvoiceID: inv-fix-bbb-002
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:67:      AmountDue: 2510.00
packages/mcp-connectors/xero/src/cache.ts:1:// Disk cache for Xero responses. Default TTL 5 min (invoices change often;
packages/mcp-connectors/xero/src/cache.ts:16:export class XeroCache {
packages/mcp-connectors/xero/src/cache.ts:19:  static fromEnv(): XeroCache {
packages/mcp-connectors/xero/src/cache.ts:22:      join(homedir(), ".ifos-cache", "xero");
packages/mcp-connectors/xero/src/cache.ts:23:    return new XeroCache(dir);
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:38:  accounting_provider: xero
packages/mcp-connectors/xero/src/types.ts:1:// Xero API types — subset of the v2 API surface IFOS Cash Conductor consumes.
packages/mcp-connectors/xero/src/types.ts:2:// Reference: https://developer.xero.com/documentation/api/accounting/overview
packages/mcp-connectors/xero/src/types.ts:4:// Shapes are intentionally narrower than Xero's full schema — only fields
packages/mcp-connectors/xero/src/types.ts:8:export interface XeroTokens {
packages/mcp-connectors/xero/src/types.ts:19:export interface XeroOAuthConfig {
packages/mcp-connectors/xero/src/types.ts:22:  /** Tenant ID (Xero "connection") this token bundle is for. */
packages/mcp-connectors/xero/src/types.ts:28:export interface XeroInvoice {
packages/mcp-connectors/xero/src/types.ts:29:  InvoiceID: string;
packages/mcp-connectors/xero/src/types.ts:37:  AmountDue: number;
packages/mcp-connectors/xero/src/types.ts:44:export interface XeroInvoicesResponse {
packages/mcp-connectors/xero/src/types.ts:47:  Invoices: XeroInvoice[];
packages/mcp-connectors/xero/src/types.ts:50:export interface XeroPayment {
packages/mcp-connectors/xero/src/types.ts:51:  PaymentID: string;
packages/mcp-connectors/xero/src/types.ts:52:  Invoice: { InvoiceID: string; InvoiceNumber?: string };
packages/mcp-connectors/xero/src/types.ts:63:export interface XeroPaymentsResponse {
packages/mcp-connectors/xero/src/types.ts:66:  Payments: XeroPayment[];
packages/mcp-connectors/xero/src/types.ts:69:export interface XeroPaymentWriteRequest {
packages/mcp-connectors/xero/src/types.ts:70:  Invoice: { InvoiceID: string };
packages/mcp-connectors/xero/src/types.ts:77:export interface XeroClientOptions {
packages/mcp-connectors/xero/src/types.ts:78:  config: XeroOAuthConfig;
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:6:#   accounting_reconciliation_write) → chase generation pass identifies
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:33:  accounting_provider: xero
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:47:# Mocked Xero invoices response
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:50:    - InvoiceID: inv-fix-aaa-001
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:56:      AmountDue: 1500.00       # matches transaction amount EXACTLY
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:69:      action_type: accounting_reconciliation_write
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:77:      action_type_emitted: xero_reminder_draft_internal
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:85:      action_type: accounting_reconciliation_write
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:89:      action_type: xero_reminder_draft_internal
packages/mcp-connectors/xero/src/invoices.ts:1:// Xero Invoices capability surface — read-only (list + get).
packages/mcp-connectors/xero/src/invoices.ts:4:import type { XeroClient } from "./client.js";
packages/mcp-connectors/xero/src/invoices.ts:5:import { XeroCache } from "./cache.js";
packages/mcp-connectors/xero/src/invoices.ts:6:import type { XeroInvoice, XeroInvoicesResponse } from "./types.js";
packages/mcp-connectors/xero/src/invoices.ts:13:  /** 1-indexed page; Xero returns 100 per page. */
packages/mcp-connectors/xero/src/invoices.ts:17:  cache?: XeroCache;
packages/mcp-connectors/xero/src/invoices.ts:21: * List open invoices (Status IN (AUTHORISED, SUBMITTED) with AmountDue > 0).
packages/mcp-connectors/xero/src/invoices.ts:26:  client: XeroClient,
packages/mcp-connectors/xero/src/invoices.ts:28:): Promise<XeroInvoice[]> {
packages/mcp-connectors/xero/src/invoices.ts:29:  const cache = options.cache ?? XeroCache.fromEnv();
packages/mcp-connectors/xero/src/invoices.ts:34:    const hit = await cache.get<XeroInvoice[]>(key);
packages/mcp-connectors/xero/src/invoices.ts:38:  // Xero `where` syntax: e.g. AmountDue>0 AND Status==\"AUTHORISED\"
packages/mcp-connectors/xero/src/invoices.ts:39:  const whereParts = ['AmountDue>0', 'Status=="AUTHORISED"||Status=="SUBMITTED"'];
packages/mcp-connectors/xero/src/invoices.ts:49:  const res = await client.request<XeroInvoicesResponse>("/Invoices", { query });
packages/mcp-connectors/xero/src/invoices.ts:55:/** Get a single invoice by Xero InvoiceID (UUID). */
packages/mcp-connectors/xero/src/invoices.ts:57:  client: XeroClient,
packages/mcp-connectors/xero/src/invoices.ts:59:  options: { cache?: XeroCache; no_cache?: boolean } = {},
packages/mcp-connectors/xero/src/invoices.ts:60:): Promise<XeroInvoice | null> {
packages/mcp-connectors/xero/src/invoices.ts:61:  const cache = options.cache ?? XeroCache.fromEnv();
packages/mcp-connectors/xero/src/invoices.ts:64:    const hit = await cache.get<XeroInvoice>(key);
packages/mcp-connectors/xero/src/invoices.ts:67:  const res = await client.request<XeroInvoicesResponse>(
packages/mcp-connectors/xero/package.json:2:  "name": "@ifos/xero",
packages/mcp-connectors/xero/package.json:5:  "description": "IFOS Xero MCP connector — OAuth 2.0 refresh + invoices read + payments read/write. Used by Cash Conductor agent §4 Steps 4-6 + 10-11 per agents/recruitment/cash-conductor/tools.yaml.",
packages/mcp-connectors/xero/tests/rate-limit.test.ts:3:// both the 60/min and 5000/day Xero buckets.
packages/mcp-connectors/xero/tests/rate-limit.test.ts:10:describe("xero rate-limit", () => {
packages/mcp-connectors/xero/tests/rate-limit.test.ts:63:  describe("daily bucket (5000/day per Xero published limit)", () => {
packages/mcp-connectors/xero/README.md:1:# @ifos/xero
packages/mcp-connectors/xero/README.md:3:Xero Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 token rotation + invoice read + payment read/write. Fixture-first; live tests deferred to first commercial Xero signup (see §Tests).
packages/mcp-connectors/xero/README.md:5:**Status:** Proposed (W4 Day-25 overnight scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial Xero signup for live-test verification).
packages/mcp-connectors/xero/README.md:17:| `xero_oauth` | `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per tenant; atomic-file-write persistence | Step 1 (auth refresh) | `xero_oauth` | green |
packages/mcp-connectors/xero/README.md:18:| `xero_list_open_invoices` | `listOpenInvoices(client, options?)` | Page through AUTHORISED+SUBMITTED invoices with AmountDue > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
packages/mcp-connectors/xero/README.md:19:| `xero_get_invoice` | `getInvoice(client, invoiceId, options?)` | Fetch single invoice by Xero InvoiceID | Step 9 (chase-draft validation) | n/a | n/a |
packages/mcp-connectors/xero/README.md:20:| `xero_list_payments` | `listPayments(client, options?)` | List ACCRECPAYMENT records (reconciliation context) | Step 5 (reconciliation pass) | n/a | n/a |
packages/mcp-connectors/xero/README.md:21:| `xero_write_payment_received` | `writePaymentReceived(client, payment)` | PUT /Payments — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
packages/mcp-connectors/xero/README.md:23:All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (`xero_oauth` registered as green per Codex F-R2 closure 2026-06-01; `accounting_reconciliation_write` already present per Day-25 verification). Line numbers in the policy file shift across edits — verify via `grep -n "^  xero_oauth:" agents/_shared/autosend-policy.yaml` rather than relying on a static citation here.
packages/mcp-connectors/xero/README.md:31:| `XeroClient` (class) | Transport — constructed once by cycle.sh Step 1; not a capability in the bus sense (no `action_type`; no authz check) |
packages/mcp-connectors/xero/README.md:38:| `XeroCache` (class) | Disk cache — default TTL 5min; surfaced for cache-aware test cases |
packages/mcp-connectors/xero/README.md:45:import { XeroClient, listOpenInvoices, writePaymentReceived } from "@ifos/xero";
packages/mcp-connectors/xero/README.md:47:const client = new XeroClient({
packages/mcp-connectors/xero/README.md:51:    tenant_id: "<xero-tenant-id-from-connections-endpoint>",
packages/mcp-connectors/xero/README.md:52:    token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/xero-tokens.json`,
packages/mcp-connectors/xero/README.md:60:      Invoice: { InvoiceID: inv.InvoiceID },
packages/mcp-connectors/xero/README.md:63:      Amount: inv.AmountDue,
packages/mcp-connectors/xero/README.md:72:## OAuth bootstrap (one-time, per Xero tenant)
packages/mcp-connectors/xero/README.md:76:1. Register the IFOS app at https://developer.xero.com/ → get `client_id` + `client_secret`.
packages/mcp-connectors/xero/README.md:78:3. User clicks → consents → Xero redirects to `redirect_uri?code=<auth_code>`.
packages/mcp-connectors/xero/README.md:79:4. POST to `https://identity.xero.com/connect/token` with `grant_type=authorization_code` + the code → receive `{access_token, refresh_token, expires_in}`.
packages/mcp-connectors/xero/README.md:80:5. Call `GET https://api.xero.com/connections` with the access_token → get the `tenant_id` (Xero "connection ID").
packages/mcp-connectors/xero/README.md:89:Per the published Xero limits page (https://developer.xero.com/documentation/guides/oauth2/limits):
packages/mcp-connectors/xero/README.md:95:This connector tracks BOTH windows per `src/rate-limit.ts`. **Hard gate at 100%** (`consume()` returns false → `XeroRateLimitError`). **Soft signal at 80%** (48/minute, 4000/day) is read-only and exposed via `rateCheck()` — `RateState.shouldBackoff === true` with `reason: "minute-soft" | "daily-soft"`. The consuming agent layer (Cash Conductor cycle.sh) is responsible for honouring the soft signal (e.g. pausing batch operations); the connector does not silently throttle — the contract is "callers query soft, connector enforces hard". `tests/rate-limit.test.ts` exercises both thresholds (`hits soft backoff at minute-soft (48)` + `hits hard fail at minute-hard (60)`).
packages/mcp-connectors/xero/README.md:97:State is in-process and per-tenant — a multi-tenant runtime that holds many `XeroClient` instances in one process still gets correct isolation.
packages/mcp-connectors/xero/README.md:103:| Local hard-gate (100%) reached | `XeroRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "xero", retry_after_seconds: null, consecutive_429s: 0}` |
packages/mcp-connectors/xero/README.md:104:| Upstream 429 from Xero API | `XeroRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "xero", retry_after_seconds: <N>, consecutive_429s: <N>}` |
packages/mcp-connectors/xero/README.md:106:Both surface as the same ESC code because from the operator's perspective they're the same operational signal (Xero traffic is being throttled). The distinction is in the payload (`retry_after_seconds: null` means local pre-emptive vs upstream-issued).
packages/mcp-connectors/xero/README.md:114:| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `XeroError` or `XeroRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
packages/mcp-connectors/xero/README.md:115:| `writePaymentReceived` | PUT | **0** | n/a (writes never auto-retry) | `XeroValidationError` (400) / `XeroError` (5xx) → `ESC_ACCOUNTING_WRITE_FAIL` (warn; operator; consumer-emitted; payload includes `provider: "xero"`, `endpoint: "/Payments"`, `status_code`, `error_body_preview`) |
packages/mcp-connectors/xero/README.md:116:| `refreshTokens` | POST | **0** | n/a | `XeroAuthError` → `ESC_ACCOUNTING_AUTH` (blocking; consumer-emitted; caller may re-attempt with fresh credentials per Bootstrap §) |
packages/mcp-connectors/xero/README.md:117:| 401 from any GET | — | force-refresh access_token, retry once | — | `XeroAuthError` → `ESC_ACCOUNTING_AUTH` |
packages/mcp-connectors/xero/README.md:118:| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `XeroRateLimitError` → `ESC_RATE_LIMIT_HIT` |
packages/mcp-connectors/xero/README.md:120:Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to Xero.
packages/mcp-connectors/xero/README.md:129:XeroError                  // base
packages/mcp-connectors/xero/README.md:130:├── XeroAuthError          // OAuth refresh fail (401/4xx on token endpoint)
packages/mcp-connectors/xero/README.md:131:├── XeroRateLimitError     // 429 OR local bucket exhausted
packages/mcp-connectors/xero/README.md:132:├── XeroNotFoundError      // 404
packages/mcp-connectors/xero/README.md:133:└── XeroValidationError    // 400 (typically schema/business-rule)
packages/mcp-connectors/xero/README.md:149:**Live tests are deferred** to the first commercial Xero signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal per review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold lands in the same commit as the first sandbox credentials per the W4 Track-1 /goal §1 commercial-gate.
packages/mcp-connectors/xero/README.md:179:   ├── Step 5 (reconciliation pass)     ──┼─→ @ifos/xero (this package)
packages/mcp-connectors/xero/README.md:183:                                         Xero REST API
packages/mcp-connectors/xero/README.md:184:                                         https://api.xero.com/api.xro/2.0
packages/mcp-connectors/xero/README.md:187:                                         Xero-tenant-id header
packages/mcp-connectors/xero/tests/auth.test.ts:15:import { XeroAuthError } from "../src/errors.js";
packages/mcp-connectors/xero/tests/auth.test.ts:16:import type { XeroOAuthConfig, XeroTokens } from "../src/types.js";
packages/mcp-connectors/xero/tests/auth.test.ts:18:const FIXTURE_TOKENS: XeroTokens = {
packages/mcp-connectors/xero/tests/auth.test.ts:34:function makeConfig(token_file: string, tenant_id = "test-tenant-id"): XeroOAuthConfig {
packages/mcp-connectors/xero/tests/auth.test.ts:46:  token_file = join(tmpdir(), `xero-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`);
packages/mcp-connectors/xero/tests/auth.test.ts:53:describe("xero auth", () => {
packages/mcp-connectors/xero/tests/auth.test.ts:67:    const expiringSoon: XeroTokens = { ...FIXTURE_TOKENS, expires_at_ms: Date.now() + 60_000 };
packages/mcp-connectors/xero/tests/auth.test.ts:72:    const fresh: XeroTokens = { ...FIXTURE_TOKENS, expires_at_ms: Date.now() + 30 * 60_000 };
packages/mcp-connectors/xero/tests/auth.test.ts:89:  it("refreshTokens: 401 surfaces as XeroAuthError; does NOT include token in error", async () => {
packages/mcp-connectors/xero/tests/auth.test.ts:97:    await expect(refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch)).rejects.toBeInstanceOf(XeroAuthError);
packages/mcp-connectors/xero/fixtures/payments-recent.json:6:      "PaymentID": "p000-aaaa-1111",
packages/mcp-connectors/xero/fixtures/payments-recent.json:7:      "Invoice": { "InvoiceID": "0000bbbb-1111-2222-3333-444455556666", "InvoiceNumber": "INV-0002" },
agents/recruitment/cash-conductor/validate.sh:120:# Re-query accounting (Xero/QB) at draft time; if paid_in_last_24h: _fail + ESC_AGENT_OUTPUT_SHAPE
agents/recruitment/cash-conductor/validate.sh:123:# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check
agents/recruitment/cash-conductor/validate.sh:182:  #  G6 → ESC_OPEN_BANKING_TOKEN_AGING; G7 → ESC_ACCOUNTING_AUTH)
packages/mcp-connectors/xero/tests/scaffold.test.ts:7:  XeroClient,
packages/mcp-connectors/xero/tests/scaffold.test.ts:17:  XeroCache,
packages/mcp-connectors/xero/tests/scaffold.test.ts:18:  XeroError,
packages/mcp-connectors/xero/tests/scaffold.test.ts:19:  XeroAuthError,
packages/mcp-connectors/xero/tests/scaffold.test.ts:20:  XeroRateLimitError,
packages/mcp-connectors/xero/tests/scaffold.test.ts:21:  XeroNotFoundError,
packages/mcp-connectors/xero/tests/scaffold.test.ts:22:  XeroValidationError,
packages/mcp-connectors/xero/tests/scaffold.test.ts:25:describe("@ifos/xero package surface", () => {
packages/mcp-connectors/xero/tests/scaffold.test.ts:30:  it("exports XeroClient class + base URL", () => {
packages/mcp-connectors/xero/tests/scaffold.test.ts:31:    expect(typeof XeroClient).toBe("function");
packages/mcp-connectors/xero/tests/scaffold.test.ts:32:    expect(XERO_BASE_URL).toBe("https://api.xero.com/api.xro/2.0");
packages/mcp-connectors/xero/tests/scaffold.test.ts:49:  it("exports XeroCache + error hierarchy", () => {
packages/mcp-connectors/xero/tests/scaffold.test.ts:50:    expect(typeof XeroCache).toBe("function");
packages/mcp-connectors/xero/tests/scaffold.test.ts:51:    // All error classes extend XeroError
packages/mcp-connectors/xero/tests/scaffold.test.ts:52:    expect(new XeroAuthError("x") instanceof XeroError).toBe(true);
packages/mcp-connectors/xero/tests/scaffold.test.ts:53:    expect(new XeroRateLimitError("x") instanceof XeroError).toBe(true);
packages/mcp-connectors/xero/tests/scaffold.test.ts:54:    expect(new XeroNotFoundError("x") instanceof XeroError).toBe(true);
packages/mcp-connectors/xero/tests/scaffold.test.ts:55:    expect(new XeroValidationError("x") instanceof XeroError).toBe(true);
agents/recruitment/cash-conductor/README.md:20:- `tools.yaml` — Xero / QuickBooks / Sage / Open Banking (TrueLayer or Plaid UK) MCP connectors
agents/recruitment/cash-conductor/tools.yaml:14:# (current registrations verified W4 Day-25 for accounting_reconciliation_write
agents/recruitment/cash-conductor/tools.yaml:15:# + xero_reminder_draft_internal + xero_reminder_send_customer; open_banking_*
agents/recruitment/cash-conductor/tools.yaml:27:  - id: xero_oauth
agents/recruitment/cash-conductor/tools.yaml:28:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:29:    purpose: "Xero OAuth 2.0 refresh + concurrent-safe token rotation"
agents/recruitment/cash-conductor/tools.yaml:30:    action_type: xero_oauth          # green tier; registration queued for W7-8
agents/recruitment/cash-conductor/tools.yaml:33:    rate_limit_hint: "60/min per tenant_id (see @ifos/xero README §Rate limits)"
agents/recruitment/cash-conductor/tools.yaml:35:  - id: xero_list_open_invoices
agents/recruitment/cash-conductor/tools.yaml:36:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:37:    purpose: "Paginated AUTHORISED+SUBMITTED invoices with AmountDue > 0"
agents/recruitment/cash-conductor/tools.yaml:41:  - id: xero_get_invoice
agents/recruitment/cash-conductor/tools.yaml:42:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:43:    purpose: "Single-entity invoice fetch by Xero InvoiceID (used at Gate A G1 re-check)"
agents/recruitment/cash-conductor/tools.yaml:47:  - id: xero_list_payments
agents/recruitment/cash-conductor/tools.yaml:48:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:53:  - id: xero_write_payment_received
agents/recruitment/cash-conductor/tools.yaml:54:    package: "@ifos/xero"
agents/recruitment/cash-conductor/tools.yaml:56:    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED in autosend-policy.yaml
agents/recruitment/cash-conductor/tools.yaml:62:    purpose: "QuickBooks OAuth 2.0 refresh (per-realm; PSD2-distinct from Xero per-tenant)"
agents/recruitment/cash-conductor/tools.yaml:88:    purpose: "Auto-write Stage 1-2 reconciliation matches (same action_type as Xero — provider-agnostic at the audit layer)"
agents/recruitment/cash-conductor/tools.yaml:89:    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED
agents/recruitment/cash-conductor/tools.yaml:141:    action_type: xero_reminder_send_customer  # ORANGE tier; REGISTERED at autosend-policy.yaml line 263; Cash Conductor OWNS this action_type per the same line
agents/recruitment/cash-conductor/tools.yaml:190:#   xero_reminder_draft_internal       line 188   yellow
agents/recruitment/cash-conductor/tools.yaml:191:#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
agents/recruitment/cash-conductor/tools.yaml:192:#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
agents/recruitment/cash-conductor/tools.yaml:196:#   xero_oauth                         green
packages/mcp-connectors/xero/fixtures/invoices-page-1.json:6:      "InvoiceID": "0000aaaa-1111-2222-3333-444455556666",
packages/mcp-connectors/xero/fixtures/invoices-page-1.json:14:      "AmountDue": 1200.00,
packages/mcp-connectors/xero/fixtures/invoices-page-1.json:21:      "InvoiceID": "0000bbbb-1111-2222-3333-444455556666",
packages/mcp-connectors/xero/fixtures/invoices-page-1.json:29:      "AmountDue": 1500.00,
packages/mcp-connectors/xero/src/errors.ts:1:// Xero error hierarchy. Errors NEVER include credential values; only key
packages/mcp-connectors/xero/src/errors.ts:5:export class XeroError extends Error {
packages/mcp-connectors/xero/src/errors.ts:12:    this.name = "XeroError";
packages/mcp-connectors/xero/src/errors.ts:17:export class XeroAuthError extends XeroError {
packages/mcp-connectors/xero/src/errors.ts:20:    this.name = "XeroAuthError";
packages/mcp-connectors/xero/src/errors.ts:25:export class XeroRateLimitError extends XeroError {
packages/mcp-connectors/xero/src/errors.ts:31:    this.name = "XeroRateLimitError";
packages/mcp-connectors/xero/src/errors.ts:36:export class XeroNotFoundError extends XeroError {
packages/mcp-connectors/xero/src/errors.ts:39:    this.name = "XeroNotFoundError";
packages/mcp-connectors/xero/src/errors.ts:43:/** Xero rejected the write payload (400). Typically schema or business-rule failures. */
packages/mcp-connectors/xero/src/errors.ts:44:export class XeroValidationError extends XeroError {
packages/mcp-connectors/xero/src/errors.ts:50:    this.name = "XeroValidationError";
agents/recruitment/cash-conductor/context.sh:13:#   CTX_ACCOUNTING_PROVIDER   xero | quickbooks | sage (per tenant config)
agents/recruitment/cash-conductor/context.sh:25:#   - Accounting auth unreachable          → exit 1 with ESC_ACCOUNTING_AUTH
agents/recruitment/cash-conductor/context.sh:73:# tenant_adapters.config; defaults to xero + truelayer per Cash Conductor §9 Q1+Q2.
agents/recruitment/cash-conductor/context.sh:80:: "${CTX_ACCOUNTING_PROVIDER:=xero}"
packages/mcp-connectors/xero/tests/capabilities.test.ts:8:import { XeroClient } from "../src/client.js";
packages/mcp-connectors/xero/tests/capabilities.test.ts:9:import { XeroCache } from "../src/cache.js";
packages/mcp-connectors/xero/tests/capabilities.test.ts:18:  XeroError,
packages/mcp-connectors/xero/tests/capabilities.test.ts:19:  XeroNotFoundError,
packages/mcp-connectors/xero/tests/capabilities.test.ts:20:  XeroRateLimitError,
packages/mcp-connectors/xero/tests/capabilities.test.ts:21:  XeroValidationError,
packages/mcp-connectors/xero/tests/capabilities.test.ts:24:  XeroOAuthConfig,
packages/mcp-connectors/xero/tests/capabilities.test.ts:25:  XeroTokens,
packages/mcp-connectors/xero/tests/capabilities.test.ts:26:  XeroPaymentWriteRequest,
packages/mcp-connectors/xero/tests/capabilities.test.ts:33:const FIXTURE_TOKENS: XeroTokens = {
packages/mcp-connectors/xero/tests/capabilities.test.ts:43:let cache: XeroCache;
packages/mcp-connectors/xero/tests/capabilities.test.ts:45:function makeConfig(): XeroOAuthConfig {
packages/mcp-connectors/xero/tests/capabilities.test.ts:62:  token_file = join(tmpdir(), `xero-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`);
packages/mcp-connectors/xero/tests/capabilities.test.ts:63:  cache_dir = join(tmpdir(), `xero-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`);
packages/mcp-connectors/xero/tests/capabilities.test.ts:64:  cache = new XeroCache(cache_dir);
packages/mcp-connectors/xero/tests/capabilities.test.ts:75:describe("xero capabilities — invoices", () => {
packages/mcp-connectors/xero/tests/capabilities.test.ts:78:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/tests/capabilities.test.ts:81:    expect(invoices[0]?.InvoiceID).toBe("0000aaaa-1111-2222-3333-444455556666");
packages/mcp-connectors/xero/tests/capabilities.test.ts:82:    expect(invoices[0]?.AmountDue).toBe(1200);
packages/mcp-connectors/xero/tests/capabilities.test.ts:88:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/tests/capabilities.test.ts:97:  it("getInvoice: 404 surfaces as XeroNotFoundError", async () => {
packages/mcp-connectors/xero/tests/capabilities.test.ts:99:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/tests/capabilities.test.ts:102:    ).rejects.toBeInstanceOf(XeroNotFoundError);
packages/mcp-connectors/xero/tests/capabilities.test.ts:107:  it("listOpenInvoices: persistent 429 surfaces as XeroRateLimitError after retries", async () => {
packages/mcp-connectors/xero/tests/capabilities.test.ts:116:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/tests/capabilities.test.ts:119:    ).rejects.toBeInstanceOf(XeroRateLimitError);
packages/mcp-connectors/xero/tests/capabilities.test.ts:124:describe("xero capabilities — payments", () => {
packages/mcp-connectors/xero/tests/capabilities.test.ts:127:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/tests/capabilities.test.ts:136:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/tests/capabilities.test.ts:137:    const payload: XeroPaymentWriteRequest = {
packages/mcp-connectors/xero/tests/capabilities.test.ts:138:      Invoice: { InvoiceID: "0000aaaa-1111-2222-3333-444455556666" },
packages/mcp-connectors/xero/tests/capabilities.test.ts:145:    expect(created.PaymentID).toBe("p000-cccc-2222");
packages/mcp-connectors/xero/tests/capabilities.test.ts:149:  it("writePaymentReceived: 400 surfaces as XeroValidationError (no retry)", async () => {
packages/mcp-connectors/xero/tests/capabilities.test.ts:155:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/tests/capabilities.test.ts:156:    const payload: XeroPaymentWriteRequest = {
packages/mcp-connectors/xero/tests/capabilities.test.ts:157:      Invoice: { InvoiceID: "00000000-0000-0000-0000-000000000000" },
packages/mcp-connectors/xero/tests/capabilities.test.ts:162:    await expect(writePaymentReceived(client, payload)).rejects.toBeInstanceOf(XeroValidationError);
packages/mcp-connectors/xero/tests/capabilities.test.ts:168:  // exhausted the typed error is XeroError (NOT XeroRateLimitError).
packages/mcp-connectors/xero/tests/capabilities.test.ts:169:  it("listPayments: persistent 500 surfaces as XeroError after retries", async () => {
packages/mcp-connectors/xero/tests/capabilities.test.ts:173:      return new Response("Xero internal error", { status: 500 });
packages/mcp-connectors/xero/tests/capabilities.test.ts:175:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/tests/capabilities.test.ts:178:    ).rejects.toBeInstanceOf(XeroError);
packages/mcp-connectors/xero/tests/capabilities.test.ts:194:      if (url.includes("identity.xero.com/connect/token")) {
packages/mcp-connectors/xero/tests/capabilities.test.ts:216:    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
packages/mcp-connectors/xero/fixtures/payment-write-ok.json:6:      "PaymentID": "p000-cccc-2222",
packages/mcp-connectors/xero/fixtures/payment-write-ok.json:7:      "Invoice": { "InvoiceID": "0000aaaa-1111-2222-3333-444455556666", "InvoiceNumber": "INV-0001" },
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:32:# - Xero/QuickBooks/Sage: invoice.created, invoice.sent, invoice.viewed,
agents/recruitment/cash-conductor/agent.md:94:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:98:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 263) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:119:2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 188-193), payload links to the draft via the vault path — this row records that Cash Conductor classified the draft as yellow-tier internal.
agents/recruitment/cash-conductor/agent.md:121:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 263; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:160:   → accounting: Xero/QuickBooks/Sage OAuth refresh per provider
agents/recruitment/cash-conductor/agent.md:164:   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on auth failure
agents/recruitment/cash-conductor/agent.md:206:   → on success: hh_decision_action("accounting_reconciliation_write",
agents/recruitment/cash-conductor/agent.md:208:   → on failure: ESC_ACCOUNTING_WRITE_FAIL
agents/recruitment/cash-conductor/agent.md:253:    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:256:    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:264:    → The orange-tier `xero_reminder_send_customer` action row was
agents/recruitment/cash-conductor/agent.md:339:| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:340:| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:343:| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 4 fuzzy multi-candidate match within tolerance (per catalogue §2.10 — bank-feed payment line cannot match a single Xero invoice; multiple candidates) | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:387:| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
agents/recruitment/cash-conductor/agent.md:390:| Xero MCP connector | W7 build start (~2 days) | ⏸ |
agents/recruitment/cash-conductor/agent.md:401:| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:404:| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
agents/recruitment/cash-conductor/agent.md:406:| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
agents/recruitment/cash-conductor/agent.md:420:| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
agents/recruitment/cash-conductor/cycle.sh:20:#   @ifos/xero            — Xero accounting provider
agents/recruitment/cash-conductor/cycle.sh:26:#   1. Reconciliation rows → accounting system (yellow tier accounting_reconciliation_write)
agents/recruitment/cash-conductor/cycle.sh:27:#   2. Chase drafts → vault + decision_log (yellow xero_reminder_draft_internal;
agents/recruitment/cash-conductor/cycle.sh:28:#      Cash Conductor OWNS the orange xero_reminder_send_customer action_type
agents/recruitment/cash-conductor/cycle.sh:92:# Reference: agent.md §4 Step 1; emits ESC_ACCOUNTING_AUTH /
agents/recruitment/cash-conductor/cycle.sh:94:# W7-8 wires: @ifos/xero (or quickbooks) refreshTokens +
agents/recruitment/cash-conductor/cycle.sh:133:# Reference: agent.md §4 Step 4. W7-8 wires: @ifos/xero or @ifos/quickbooks
agents/recruitment/cash-conductor/cycle.sh:158:# Reference: agent.md §3 Output 1. W7-8 wires: @ifos/xero writePaymentReceived
agents/recruitment/cash-conductor/cycle.sh:164:  # hh_decision_action "accounting_reconciliation_write" "invoice:<id>" payload_hash payload_preview
agents/recruitment/cash-conductor/cycle.sh:165:  # On failure: ESC_ACCOUNTING_WRITE_FAIL via hh_decision_action validate_gate_a_fail
agents/recruitment/cash-conductor/cycle.sh:210:# Cash Conductor OWNS xero_reminder_send_customer action_type per autosend-policy.yaml
agents/recruitment/cash-conductor/cycle.sh:221:  #   hh_decision_action "xero_reminder_draft_internal" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:240:    #      --action xero_reminder_send_customer \
agents/recruitment/cash-conductor/cycle.sh:250:    # 2. Emit ORANGE-tier audit row — Cash Conductor OWNS xero_reminder_send_customer
agents/recruitment/cash-conductor/cycle.sh:253:    #    hh_decision_action "xero_reminder_send_customer" "invoice:${INVOICE_ID}" \

exec
/bin/zsh -lc "rg -n \"ULTRAPLAN|master brief|§8\\.2|8\\.2|A4|review-mcp-connector|operational-hygiene\" -S .codex docs agents packages | head -200" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/harness/PINNED-SHA.md:26:   (master brief §3.4 and §5).
packages/harness/PINNED-SHA.md:53:- Codex ratification per master brief §10
packages/agents-runtime/_shared/common-accounting.json:5:  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
packages/agents-runtime/_shared/common-accounting.json:42:      "description": "v1.0 closes loop via Open Banking reconciliation per Ultraplan §8.1 A4; truelayer placeholder."
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
.codex/ratification/review-agent-bundle.md:18:| §1 | Output contract | One-paragraph screenshot per master brief §1 Rule 1. Names WHAT the agent produces in a single paragraph, readable cold | Missing; >3 paragraphs; doesn't name vault write path; doesn't name Gate A + Gate B thresholds |
.codex/ratification/review-agent-bundle.md:19:| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
.codex/ratification/review-agent-bundle.md:22:| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
.codex/ratification/review-agent-bundle.md:24:| §7 | Voice + tone constraints | `_shared/voice-loader.sh` integration; per-tenant scope; voice classifier threshold per agent.md §5 | Missing for agents that produce text output; threshold drift from master brief §8.1 Change 1 |
.codex/ratification/review-agent-bundle.md:26:| §9 | Status + open questions | Numbered list of founder-review questions; each has a resolution path (founder review at next Sunday OR pilot tenant onboarding OR commercial conversation) | Missing; questions are vague (no resolution path); doesn't acknowledge gotchas from corresponding ULTRAPLAN §8.1 A-N spec |
.codex/ratification/review-agent-bundle.md:37:1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
.codex/ratification/review-agent-bundle.md:38:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
.codex/ratification/review-agent-bundle.md:48:- master brief week N cited but row mismatches (e.g. "W5" but the row says W6)
.codex/ratification/review-agent-bundle.md:49:- ULTRAPLAN line-anchor drift (off by ±5 lines after edits)
.codex/ratification/review-agent-bundle.md:53:**Drift between master brief and ULTRAPLAN is the norm, not an error.** Master brief is authoritative per project hierarchy. agent.md should cite BOTH with a "drift flag" note if the build-wave timing differs (e.g. Sourcing Scout: master brief W9 vs ULTRAPLAN A5 W8-9 — note the drift; use master brief).
.codex/ratification/review-agent-bundle.md:92:Every agent.md is checked against the four boundaries (master brief §3):
.codex/ratification/review-agent-bundle.md:111:- All citations verified against source files (master brief / ULTRAPLAN / escalation-codes / vertical-schema)
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:189:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:205:# a customer-visible artefact (Gate B per master brief §1 Rule 4).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:411:    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:817:      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
agents/_shared/autosend-policy.yaml:151:  # per Codex cluster F Round 1 — review-mcp-connector §7 requires
agents/_shared/autosend-policy.yaml:178:    reason: "Plaid UK OAuth 2.0 refresh — v1.1+ stub; never fires v1.0. Registered now so the README + tools.yaml capability declarations have a matching policy entry per review-mcp-connector §7 set-equality."
agents/_shared/voice-loader.sh:3:# IFOS voice-loader — implements the 3 hh_load_* helpers per master brief
.codex/ratification/SKILL.md:16:## §1 — The five rules (master brief §1)
.codex/ratification/SKILL.md:32:## §2 — The four boundaries (master brief §3)
.codex/ratification/SKILL.md:50:- **Citation accuracy** — section references like "§X.Y" MUST be verifiable. Open the cited file at the cited line/section; does the citation hold? Past violations: a Day-6 audit found 15 fabricated "master brief §10.4 cost target" references; §10.4 is actually the Codex exclusion list.
.codex/ratification/SKILL.md:52:- **Length discipline** — operational-hygiene-protocol §4 sets length targets per artefact type. Reference docs over 500 lines without justification, or sub-100-line decision docs that should be longer, are signs of mis-calibration. Flag but don't reject on length alone.
.codex/ratification/SKILL.md:54:- **No defensive additions** — operational-hygiene-protocol §3. Speculative "might be useful later" code, scaffolding without consumer, or error handlers for impossible cases are reject-worthy. Validate at system boundaries only.
.codex/ratification/SKILL.md:56:- **Dates** — operational-hygiene-protocol §5 + master brief §1 Rule 5. Absolute dates (not relative — "by Friday" is wrong; "by 2026-06-03" is right). Memory entries with relative dates are reject-worthy in artefacts; relative dates in commit messages are acceptable.
.codex/ratification/SKILL.md:101:- `review-mcp-connector.md` — for new connectors under `packages/mcp-connectors/`
packages/agents-runtime/_shared/common-client.json:41:      "description": "Sovereign = on-prem cluster; cloud = managed Hetzner. Per master brief §4."
packages/agents-runtime/_shared/common-client.json:47:      "description": "Drives agent Tier 1/2/3 classification per master brief §2.4 primitive 1."
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:168:          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
packages/agents-runtime/_shared/common-notifications.json:5:  "description": "Telegram chat IDs + escalation routing per master brief §2.4 primitive 5. Per PRODUCT-SPEC §5.3 line 359.",
.codex/ratification/review-postgres-migration.md:100:`decision_log` is append-only per Day-4 §6.3 + master brief §3.3 audit discipline. `recent_edit` extends this pattern per v0.2 supplement.
agents/_shared/escalation-codes.md:4:**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:118:Source: master brief §8.1 Change 3 lines 585-592
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:411:  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
agents/_shared/escalation-codes.md:436:  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
agents/_shared/escalation-codes.md:465:| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
packages/agents-runtime/_shared/common-voice.json:5:  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
docs/verticals/recruitment/vertical-schema.yaml:10:# Source: master brief §6 Day 6 line 490 (8 core entities)
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:216:      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:289:      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:822:    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:829:    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
docs/verticals/recruitment/vertical-schema.yaml:896:    expected_date: post first-pilot operations (Q4 2026 if pilot lands per master brief §6 Day 7 question 1)
docs/verticals/recruitment/vertical-schema.yaml:901:    expected_date: 2027+ per master brief §9 build sequence
.codex/ratification/review-mcp-connector.md:1:# Codex ratification skill — review-mcp-connector
.codex/ratification/review-mcp-connector.md:99:- The strings `composio` or `agentmail` (case-insensitive) — adapter boundary per master brief §3.
.codex/ratification/review-mcp-connector.md:151:*End of review-mcp-connector skill.*
packages/agents-runtime/_shared/common-target-patch.json:19:      "description": "ISO-3166-alpha-2 codes or region labels; UK first per master brief §4."
packages/agents-runtime/_shared/common-base.json:16:      "description": "Matches bundle directory at agents/<vertical>/<agent_name>/ per master brief §8."
packages/agents-runtime/_shared/common-base.json:48:      "description": "Daemon-required per master brief §2.4 primitive 2 (71h rotation)."
packages/agents-runtime/_shared/common-base.json:57:      "description": "Per master brief §4 UK-first geography."
.codex/ratification/review-schema-change.md:34:- `v1_0_agent_access` — list of agents from master brief §8.2 with R / W / R+W disposition, OR explicit "none (v1.1+ exercise)"
agents/recruitment/cash-conductor/cycle.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
agents/recruitment/cash-conductor/cycle.sh:320:# DSO metric (Gate B tracking) per ULTRAPLAN A4 line 539.
docs/operations/goal-overnight-2026-05-31.md:26:### 2. `.codex/ratification/review-mcp-connector.md` Codex skill (~90 min)
agents/recruitment/cash-conductor/README.md:18:Full bundle at W7-8 build (~2 weeks per ULTRAPLAN A4 line 541):
agents/recruitment/cash-conductor/README.md:22:- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
agents/recruitment/cash-conductor/README.md:27:- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
.codex/ratification/review-architecture-decision.md:29:5. **Consequences section** — what changes downstream. Includes risk register implications, master brief edits authorised (if any), downstream-artefact updates required. **Required for `Proposed | Accepted`. EXEMPT for `Reference` + `In Force` — downstream impact may be inline (e.g., "Day-7 single-sentence test Q2 references this audit") rather than under a dedicated heading; verify via cross-references in body text.**
.codex/ratification/review-architecture-decision.md:35:The exemptions in items 3, 4, 5 above are the result of Founder Decision D5 (commit `2026-05-22`) resolving the disagreement at `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`. Reference artefacts (e.g., `cortexos-primitive-status.md` audit, `architecture-cohesion-review.md`, `tenancy-invariants.md`) and In Force artefacts (e.g., `operational-hygiene-protocol.md` runbook, `tenant-lifecycle.md` runbook) legitimately do not have "decisions" or "alternatives weighed" — they document findings or procedures.
.codex/ratification/review-architecture-decision.md:60:For every cited section reference (e.g., "master brief §6 Day 7 line 502"):
.codex/ratification/review-architecture-decision.md:66:If even one citation is wrong, REJECT with the specific citation listed. Past pattern: `master brief §10.4 cost target` cited 15 times; §10.4 is actually the Codex exclusion list with no cost-target content.
.codex/ratification/review-architecture-decision.md:76:If the ADR authorises master brief edits (an "## Master brief edits authorised by this ADR" section):
.codex/ratification/review-architecture-decision.md:79:2. The edit's line numbers MUST match the live master brief (sample-check at least one).
.codex/ratification/review-architecture-decision.md:112:## §7 — Decision_log audit fields (master brief §8.1 Change 2)
packages/utilities/web-scraper/pnpm-lock.yaml:166:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:220:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/utilities/web-scraper/pnpm-lock.yaml:436:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/utilities/web-scraper/pnpm-lock.yaml:517:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/utilities/web-scraper/pnpm-lock.yaml:703:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/utilities/web-scraper/pnpm-lock.yaml:793:  mlly@1.8.2:
packages/utilities/web-scraper/pnpm-lock.yaml:1004:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/utilities/web-scraper/pnpm-lock.yaml:1535:      mlly: 1.8.2
packages/utilities/web-scraper/pnpm-lock.yaml:1555:  mlly@1.8.2:
packages/utilities/web-scraper/pnpm-lock.yaml:1589:      mlly: 1.8.2
agents/recruitment/cash-conductor/tools.yaml:203:# Boundary check (per master brief §3 + review-mcp-connector.md §8)
agents/recruitment/cash-conductor/validate.sh:13:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
agents/recruitment/cash-conductor/validate.sh:32:# Checks (per agent.md §5 Gate A, ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/validate.sh:105:# G1 — invoice number + amount + contact (per ULTRAPLAN A4 line 538)
agents/recruitment/cash-conductor/validate.sh:119:# G2 — NOT paid in last 24h (defence-in-depth; per ULTRAPLAN A4 line 538 verbatim)
agents/recruitment/cash-conductor/context.sh:8:# Per master brief §8.1 Change 2: context.sh runs at cycle.sh Step 0 and exports
agents/recruitment/cash-conductor/context.sh:138:# Emit session_start audit row (per master brief §8.1 Change 2 — mandatory first row)
docs/operations/goal-week-4-track-1.md:5:**Master plan citations:** Master brief §8.2 (build wave W4 Cash Conductor MCP connectors) + ULTRAPLAN §8.1 A4 (Cash Conductor spec lines 531-545) + ADR-005 (Week-3 acceleration → Cash Conductor pulled forward to W4 substrate) + `agents/recruitment/cash-conductor/agent.md` §8 build dependencies + `docs/decisions/2026-05-31-d1-founder-decision.md` (D1-B resolved) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic live render by 2026-06-14).
docs/operations/goal-week-4-track-1.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §8.2 W4-W7 rows + §10 (ratification cadence + always-ratify list) + §10.5
docs/operations/goal-week-4-track-1.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A4 lines 531-545 (Cash Conductor spec) + §10 risk rows referencing Open Banking 90-day token rotation
docs/operations/goal-week-4-track-1.md:31:After reading: post in chat **"Read order complete. Five rules: [verbatim]. Four boundaries: [verbatim]. W4 Track 1 scope: Xero + QuickBooks + Open Banking MCP connectors + Cash Conductor bundle scaffold + Diagnostic live-smoke wrapper + review-mcp-connector Codex skill + cluster F manifest. Ready to begin Step 1."**
docs/operations/goal-week-4-track-1.md:63:### Codex `review-mcp-connector.md` skill (Day 1)
docs/operations/goal-week-4-track-1.md:65:13. **`.codex/ratification/review-mcp-connector.md`** exists. Type-specific skill for MCP connector packages. Adds checks on top of SKILL.md: OAuth refresh idempotency; rate-limit budget declared; explicit retry policy; secrets never logged; fixture-first tests; integration with `_shared/hook-helpers.sh` for decision_log emissions. Modeled on `review-agent-bundle.md` length + structure.
docs/operations/goal-week-4-track-1.md:96:| `review-mcp-connector.md` Codex skill | §1 criterion 13; needed before cluster F can ratify the new connectors |
docs/operations/goal-week-4-track-1.md:138:### DAY 1 — Substrate verification + review-mcp-connector skill + Diagnostic live-smoke wrapper
docs/operations/goal-week-4-track-1.md:159:#### Step 2 — Author `review-mcp-connector.md` Codex skill (~1.5 hours)
docs/operations/goal-week-4-track-1.md:161:Create `.codex/ratification/review-mcp-connector.md` modeled on `review-agent-bundle.md`. The skill ADDS these checks on top of `SKILL.md`:
docs/operations/goal-week-4-track-1.md:173:Commit: `feat(codex-skill): review-mcp-connector.md for cluster F ratification`
docs/operations/goal-week-4-track-1.md:229:Acceptance per `review-mcp-connector.md` skill:
docs/operations/goal-week-4-track-1.md:314:Triage per master brief §10.3 step 5 (≤2 round-trips per artefact):
docs/operations/goal-week-4-track-1.md:350:| **Master plan citations** | Every claim cites master brief / ULTRAPLAN / ADR / agent.md line | grep diff for citation strings |
docs/operations/goal-week-4-track-1.md:365:| Cluster F returns >2 REJECTED on a single artefact | Founder review per master brief §10.3 step 5; write disagreement doc; defer |
docs/operations/goal-week-4-track-1.md:398:Per master brief §10 + §10.3 step 5 hard ceiling + Day-25 Codex-cycle pattern.
docs/operations/goal-week-4-track-1.md:402:The new `review-mcp-connector.md` skill is itself an artefact subject to ratification. It ratifies via `review-architecture-decision.md` (skills are architectural artefacts). Add to next ratification cluster.
docs/operations/goal-week-4-track-1.md:464:  .codex/ratification/review-mcp-connector.md: built; ratified via review-architecture-decision
docs/operations/goal-week-4-track-1.md:471:  <SHA>  feat(codex-skill): review-mcp-connector.md
docs/operations/goal-week-4-track-1.md:488:  ✓ master brief §8.2 W4 row — Cash Conductor MCP connectors
docs/operations/goal-week-4-track-1.md:489:  ✓ ULTRAPLAN §8.1 A4 — Cash Conductor spec lines 531-545
docs/operations/goal-week-4-track-1.md:539:**Day 7 (2026-06-05) is the soft target. Day 9 (2026-06-07) is the hard cutoff** (W5 Janitor build starts then per master brief §8.2 if Bullhorn A+B has Accepted). If Day 9 hits without completion, escalate to founder review + scope-cut decision.
agents/recruitment/cash-conductor/agent.md:7:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:8:**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
agents/recruitment/cash-conductor/agent.md:9:**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
agents/recruitment/cash-conductor/agent.md:10:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:16:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:57:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:162:     gotcha per ULTRAPLAN A4 line 541); staged ESC_OPEN_BANKING_TOKEN_AGING:
agents/recruitment/cash-conductor/agent.md:307:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:323:Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
agents/recruitment/cash-conductor/agent.md:329:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:374:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:429:### Gotchas (carried forward from ULTRAPLAN A4 line 541)
agents/recruitment/cash-conductor/agent.md:434:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:451:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
agents/recruitment/scribe/README.md:14:Full bundle at W6 build (~1 week per ULTRAPLAN A3 line 526):
docs/operations/w4-bilateral-pass-6-agent-md.md:175:  - **Cite:** §3 lines 16, 30, 39; cross-ref §8 lines 295-298 + ULTRAPLAN A3 lines 521-523
docs/operations/w4-bilateral-pass-6-agent-md.md:176:  - **Codex says:** "Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly."
docs/operations/w4-bilateral-pass-6-agent-md.md:211:  - **Cite:** §10 lines 417-421; cross-ref ULTRAPLAN A6 line 566 + lines 206-212/276
docs/operations/w4-bilateral-pass-6-agent-md.md:212:  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
docs/operations/w4-bilateral-pass-6-agent-md.md:218:### Finding 4. ULTRAPLAN line-citation drift
docs/operations/w4-bilateral-pass-6-agent-md.md:219:  - **Cite:** §3 lines 16, 39, 76, 333, 345; cross-ref ULTRAPLAN A6
docs/operations/w4-bilateral-pass-6-agent-md.md:220:  - **Codex says:** "Lines 16, 39, 76, 333, and 345 cite line 570 for lifecycle/rejection gotchas, but verified ULTRAPLAN has the gotcha text on line 569 and line 570 is blank. Update these citations to ULTRAPLAN A6 line 569."
docs/operations/w4-bilateral-pass-6-agent-md.md:221:  - **Likely:** FIX-IN-PLACE. Find-and-replace `ULTRAPLAN A6 line 570` → `ULTRAPLAN A6 line 569`. Verify count: 5 sites.
docs/operations/w4-bilateral-pass-6-agent-md.md:236:5. **Status semantics** (Sourcing Scout #2) — confirm with founder: "Ratified at Round-N" is not "Accepted"; Accepted requires bundle completion. Likely a one-line clarification in the agent-bundle skill or master brief §8 to prevent this drift in future agents.
agents/recruitment/janitor/README.md:9:| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed |
agents/recruitment/janitor/README.md:14:Full agent bundle per ADR-003: 6 files + 3 fixtures. Built at W5 start (~2 weeks per ULTRAPLAN A2 line 512):
docs/operations/w4-day-20-founder-runbook.md:27:**Why:** Per master brief §10.5, "every Postgres migration touching tenant
agents/recruitment/scribe/agent.md:7:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:8:**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
agents/recruitment/scribe/agent.md:9:**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
agents/recruitment/scribe/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/scribe/agent.md:17:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:115:Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
agents/recruitment/scribe/agent.md:131:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:217:   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
agents/recruitment/scribe/agent.md:220:     different scopes — master brief 10-min is the product UX promise; catalogue
agents/recruitment/scribe/agent.md:237:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:240:- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
agents/recruitment/scribe/agent.md:253:Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
agents/recruitment/scribe/agent.md:302:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/scribe/agent.md:350:### Gotchas (carried forward from ULTRAPLAN A3 line 527)
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
packages/agent-renderer/src/fileMap.ts:12:    { source: "tests/fixtures/", target: null, action: "stays-in-source", note: "CI fixture runner reads from IFOS repo per master brief §8.3" },
agents/recruitment/janitor/agent.md:7:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:8:**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
agents/recruitment/janitor/agent.md:9:**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.2 (lines 105-116; §2.1 is the Diagnostic section).
agents/recruitment/janitor/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/janitor/agent.md:17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:62:| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
agents/recruitment/janitor/agent.md:70:1. **Candidate / contractor merge** (`PUT /Candidate/{primary_id}` + cascade; candidate and contractor are separate entity types per vertical-schema.yaml §1 but share the §4 Steps 3-4 fuzzy-matcher) — auto-merged only when confidence ≥0.85 AND neither record had Bullhorn activity in the last 90 days (per ULTRAPLAN A2 line 510 verbatim); pairs in the 0.70–0.85 review band, or ≥0.85 with recent activity, are held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before any write. Action type: **`bullhorn_candidate_dedupe`** with `payload.entity_type ∈ {candidate, contractor}` discriminating the two — reused rather than a separate contractor action_type (same yellow tier + matcher; registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:80:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:107:     (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:185:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:188:- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
agents/recruitment/janitor/agent.md:189:- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:205:Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.
agents/recruitment/janitor/agent.md:209:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:251:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:277:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:289:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:296:### Gotchas (carried forward from ULTRAPLAN A2 line 513)
agents/recruitment/janitor/agent.md:298:1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
agents/recruitment/janitor/agent.md:300:3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
agents/recruitment/sourcing-scout/agent.md:11:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).

exec
/bin/zsh -lc "rg --files | rg 'master|brief|ULTRAPLAN|ultraplan|operational-hygiene|ratification'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
logs/codex-ratification.jsonl
docs/decisions/2026-05-18-codex-ratification-manifest.md
docs/runbooks/operational-hygiene-protocol.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md
docs/_supplementary/planning-phase-brief.md
scripts/run-codex-ratification.sh
docs/operations/codex-ratification-guide.md
docs/operations/codex-ratification-execution-plan.md
logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T125002Z-52329/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T125002Z-52329/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T125002Z-52329/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T144919Z-68982/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144919Z-68982/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144919Z-68982/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260525T063903Z-2151/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260525T063903Z-2151/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260525T063903Z-2151/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260525T065832Z-12112/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260525T065832Z-12112/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260525T065832Z-12112/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_yaml.output.md
logs/codex-ratification/manual-run/docs_decisions_sequencing_target_md.output.md
logs/codex-ratification/manual-run/docs_decisions_ADR_003_agent_bundle_renderer_md.output.md
logs/codex-ratification/manual-run/docs_decisions_ADR_001_bus_dispatcher_poll_not_chokidar_md.output.md
logs/codex-ratification/manual-run/docs_decisions_ADR_002_brain_system_as_parallel_not_shadow_md.output.md
logs/codex-ratification/manual-run/docs_decisions_brain_ui_scope_md.output.md
logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md
logs/codex-ratification/manual-run/docs_decisions_v1_0_kill_criterion_md.output.md
logs/codex-ratification/manual-run/docs_architecture_cortexos_primitive_status_md.output.md
logs/codex-ratification/manual-run/docs_architecture_second_brain_design_md.output.md
logs/codex-ratification/manual-run/docs_runbooks_operational_hygiene_protocol_md.output.md
logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md
logs/codex-ratification/manual-run/docs_decisions_ADR_004_renderer_implementation_deviations_md.output.md
logs/codex-ratification/manual-run/docs_decisions_bullhorn_integration_path_md.output.md
logs/codex-ratification/manual-run/docs_architecture_vault_concurrency_md.output.md
logs/codex-ratification/manual-run/docs_architecture_agent_bundle_renderer_design_md.output.md
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T112636Z-79455/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T112636Z-79455/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T112636Z-79455/agents_recruitment_diagnostic_agent-md.verdict.txt
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_open-banking.output.md
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_open-banking.prompt.md
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_quickbooks.verdict.txt
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_open-banking.verdict.txt
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_xero.verdict.txt
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_xero.prompt.md
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_quickbooks.prompt.md
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_quickbooks.output.md
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_xero.output.md
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260525T063904Z-2437/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260525T063904Z-2437/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260525T063904Z-2437/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T063647Z-99548/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.prompt.md
logs/codex-ratification/20260525T063647Z-99548/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.output.md
logs/codex-ratification/20260525T063647Z-99548/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.verdict.txt
logs/codex-ratification/20260524T112917Z-82352/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T112917Z-82352/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T112917Z-82352/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.output.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.prompt.md
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.output.md
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.verdict.txt
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_open-banking.output.md
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_open-banking.prompt.md
logs/codex-ratification/20260602T103527Z-17484/HANDOFF-R3-READY.md
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_quickbooks.verdict.txt
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_open-banking.verdict.txt
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_xero.verdict.txt
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_xero.prompt.md
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_quickbooks.prompt.md
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_quickbooks.output.md
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_xero.output.md
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/round-3-remediation/scripts_run-tenancy-audit-sh.output.md
logs/codex-ratification/round-3-remediation/docs_verticals_recruitment_migrations_v0-2-to-v0-3-pii-purge-sql.output.md
logs/codex-ratification/round-3-remediation/runtime_set_local_helpers.output.md
logs/codex-ratification/round-3-remediation/docs_verticals_recruitment_migrations_v0-1-to-v0-2-sql.output.md
logs/codex-ratification/round-3-remediation/docs_decisions_bullhorn-integration-path-md.output.md
logs/codex-ratification/round-3-remediation/scripts_ifos-pii-purge-sh.output.md
logs/codex-ratification/round-3-remediation/RUN-LOG.md
logs/codex-ratification/round-3-remediation/docs_runbooks_pii-purge-operational-pattern-md.output.md
logs/codex-ratification/round-3-remediation/docs_decisions_codex-disagreement-2026-05-20-bullhorn-week-1-gate-md.output.md
logs/codex-ratification/round-3-remediation/SUMMARY.md
logs/codex-ratification/round-3-remediation/docs_decisions_autosend-approval-bridge-spec-md.output.md
logs/codex-ratification/round-3-remediation/docs_architecture_tenancy-invariants-md.output.md
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/round-2-autonomous/scripts_run-tenancy-audit-sh.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_migrations_v0-2-to-v0-3-pii-purge-sql.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_sequencing-target-md.output.md
logs/codex-ratification/round-2-autonomous/docs_architecture_second-brain-design-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_bullhorn-integration-path-md.output.md
logs/codex-ratification/round-2-autonomous/docs_runbooks_tenant-lifecycle-md.output.md
logs/codex-ratification/round-2-autonomous/scripts_ifos-pii-purge-sh.output.md
logs/codex-ratification/round-2-autonomous/docs_architecture_vault-concurrency-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_2026-05-20-codex-round-1-founder-decisions-md.output.md
logs/codex-ratification/round-2-autonomous/RUN-LOG.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_migrations_v0-3-to-v0-2-pii-purge-sql.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-001-bus-dispatcher-poll-not-chokidar-md.output.md
logs/codex-ratification/round-2-autonomous/docs_runbooks_pii-purge-operational-pattern-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-002-brain-system-as-parallel-not-shadow-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_codex-disagreement-2026-05-20-bullhorn-week-1-gate-md.output.md
logs/codex-ratification/round-2-autonomous/docs_runbooks_operational-hygiene-protocol-md.output.md
logs/codex-ratification/round-2-autonomous/docs_architecture_architecture-cohesion-review-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-003-agent-bundle-renderer-md.output.md
logs/codex-ratification/round-2-autonomous/SUMMARY.md
logs/codex-ratification/round-2-autonomous/docs_architecture_cortexos-primitive-status-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_architecture_agent-bundle-renderer-design-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-approval-bridge-spec-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_codex-disagreement-2026-05-20-decision-doc-shape-on-audits-md.output.md
logs/codex-ratification/round-2-autonomous/docs_architecture_tenancy-invariants-md.output.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_open-banking.output.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_open-banking.prompt.md
logs/codex-ratification/20260601T144038Z-55009/HANDOFF-R2-READY.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.verdict.txt
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_open-banking.verdict.txt
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_xero.verdict.txt
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_xero.prompt.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.prompt.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.output.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_xero.output.md
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T100618Z-10709/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T100618Z-10709/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T100618Z-10738/docs_decisions_ADR-005-week-3-diagnostic-acceleration-md.prompt.md
logs/codex-ratification/20260524T100618Z-10738/docs_decisions_ADR-005-week-3-diagnostic-acceleration-md.output.md
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/manual-cluster-e/REPORT.md
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_xero.prompt.md
logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_xero.output.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_open-banking.output.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_open-banking.prompt.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_quickbooks.verdict.txt
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_open-banking.verdict.txt
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_xero.verdict.txt
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_xero.prompt.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_quickbooks.prompt.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_quickbooks.output.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_xero.output.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T100648Z-11041/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T100648Z-11041/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '529,545p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   529	#### A4. Cash Conductor (real-time mode) — the FD's evenings back
   530	
   531	- **Build wave:** v1.0 (week 7–8)
   532	- **Always-on?** Tier 1 — persistent watcher on accounting + bank webhooks
   533	- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
   534	- **CortexOS primitives required:** Persistent PTY (#1), Telegram approval surface (#5), standing authorisations (#4)
   535	- **MCP tools required:** Xero / QuickBooks / Sage (one of, per tenant), bank-feed connector
   536	- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
   537	- **External APIs:** Xero API or QuickBooks API or Sage API; bank feed via Open Banking (TrueLayer / Plaid UK)
   538	- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
   539	- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
   540	- **Build complexity:** **L** (2 weeks) — three accounting integrations × Open Banking is the work
   541	- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
   542	
   543	#### A5. Sourcing Scout (daytime form) — request-response sourcing
   544	
   545	- **Build wave:** v1.0 (week 8–9)

exec
/bin/zsh -lc 'cat logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_xero.verdict.txt 2>/dev/null; cat logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_xero.verdict.txt 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
RATIFIED
RATIFIED

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '585,610p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   585	- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
   586	- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
   587	- `ESC_SCHEMA_VIOLATION` — agent produced output violating vertical schema
   588	
   589	Build the catalogue in Week 0. New codes only when production demands one.
   590	
   591	### 8.2 The build order — v1.0 only
   592	
   593	| # | Agent | Weeks | Key dependency | Why this order |
   594	|---|---|---|---|---|
   595	| 1 | Diagnostic | 3–4 | LinkedIn + Companies House + scrape | Sales tool — needed before any other agent matters |
   596	| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
   597	| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
   598	| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
   599	| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
   600	| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
   601	
   602	After Concierge ships, week 14 milestone: first pilot converts to paid.
   603	
   604	**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
   605	
   606	### 8.3 The working pattern in Claude Code
   607	
   608	For any new agent:
   609	
   610	```bash

codex
RATIFIED

Advisory: README line 95 under-describes the daily bucket test coverage, though line 153 and the tests themselves cover it.
`pnpm --filter @ifos/xero test` and `typecheck` pass.
tokens used
96,353
RATIFIED

Advisory: README line 95 under-describes the daily bucket test coverage, though line 153 and the tests themselves cover it.
`pnpm --filter @ifos/xero test` and `typecheck` pass.
