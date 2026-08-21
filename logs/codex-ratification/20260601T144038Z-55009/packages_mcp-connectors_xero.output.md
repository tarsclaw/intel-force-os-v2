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
session id: 019e83a1-3166-7382-be67-ecf0b44b78ab
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

Xero Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 token rotation + invoice read + payment read/write. Fixture-first; live API gated behind `MCP_LIVE_TESTS=true`.

**Status:** Proposed (W4 Day-25 overnight scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial Xero signup for live-test verification).

**Reference pattern:** mirrors `@ifos/companies-house` (Day-13 RATIFIED). Every new MCP connector follows this structure per `review-mcp-connector.md` §1.

---

## Capabilities

| Function | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
|---|---|---|---|---|
| `XeroClient` (class) | HTTP wrapper: OAuth attach + rate-limit budget + 429 / 5xx retry | constructed in cycle.sh Step 1 | n/a (transport) | n/a |
| `loadTokens(config)` | Read OAuth tokens from disk | Step 1 (auth refresh) | n/a (read-only) | n/a |
| `saveTokens(config, t)` | Atomic write (.tmp + rename) to token file | refreshTokens internal | n/a | n/a |
| `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup; returns + persists new bundle | Step 1 | `xero_oauth` | green |
| `shouldRefresh(tokens, now?, window?)` | Returns true if access_token expires within window (default 5 min) | Step 1 + per-call | n/a (pure) | n/a |
| `listOpenInvoices(client, options?)` | Page through AUTHORISED+SUBMITTED invoices with AmountDue > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
| `getInvoice(client, invoiceId, options?)` | Fetch single invoice by Xero InvoiceID | Step 9 (chase-draft validation) | n/a | n/a |
| `listPayments(client, options?)` | List ACCRECPAYMENT records (reconciliation context) | Step 5 (reconciliation pass) | n/a | n/a |
| `writePaymentReceived(client, payment)` | PUT /Payments — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |

All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `xero_oauth` + `accounting_reconciliation_write` already present per Day-25 evening verification.

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

This connector tracks BOTH windows per `src/rate-limit.ts`. Soft backoff at 80% (48/minute, 4000/day); hard fail at 100% → `XeroRateLimitError`. State is in-process and per-tenant — a multi-tenant runtime that holds many `XeroClient` instances in one process still gets correct isolation.

If you see `XeroRateLimitError` consistently in Cash Conductor logs, either the daily budget is too low for the tenant's invoice volume OR the polling interval is too tight; in either case it's an operator-tuning event, not a code bug.

---

## Retry policy

| Capability | Method | Max retries | Backoff | On exhaustion |
|---|---|---|---|---|
| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `XeroError` or `XeroRateLimitError` |
| `writePaymentReceived` | PUT | **0** | n/a (writes never auto-retry) | `XeroValidationError` (400) / `XeroError` (5xx) |
| `refreshTokens` | POST | **0** | n/a | `XeroAuthError` (caller may re-attempt with new credentials) |
| 401 from any GET | — | force-refresh access_token, retry once | — | `XeroAuthError` |
| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `XeroRateLimitError` |

Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to Xero.

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
// Used by Cash Conductor agent (W4-7 build wave) per
// agents/recruitment/cash-conductor/tools.yaml capabilities:
//   xero_oauth                       → auth.refreshTokens + client.getValidAccessToken
//   accounting_reconciliation_write  → payments.writePaymentReceived
//   (read-only invoice register)     → invoices.listOpenInvoices + getInvoice
//
// Reference implementation: @ifos/companies-house. Pattern parity intentional —
// new connectors mirror this structure (see review-mcp-connector skill §1).

export {
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  _resetInflightForTest,
} from "./auth.js";
export { XeroClient, XERO_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
export { listOpenInvoices, getInvoice } from "./invoices.js";
export { listPayments, writePaymentReceived } from "./payments.js";
export { XeroCache } from "./cache.js";
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
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
import { XeroValidationError, XeroNotFoundError } from "../src/errors.js";
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

exec
/bin/zsh -lc 'rg -n "xero|xero_oauth|accounting_reconciliation_write|ESC_RATE_LIMIT_HIT|ESC_ACCOUNTING_WRITE_FAIL" agents packages/mcp-connectors/xero -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/xero/src/client.ts:16:export const XERO_BASE_URL = "https://api.xero.com/api.xro/2.0";
packages/mcp-connectors/xero/src/index.ts:1:// @ifos/xero — public API
packages/mcp-connectors/xero/src/index.ts:5://   xero_oauth                       → auth.refreshTokens + client.getValidAccessToken
packages/mcp-connectors/xero/src/index.ts:6://   accounting_reconciliation_write  → payments.writePaymentReceived
packages/mcp-connectors/xero/src/auth.ts:15:// Recommend: ~/.ifos-local-vault/<tenant>/xero-tokens-<xero_tenant_id>.json (mode 0600).
packages/mcp-connectors/xero/src/auth.ts:21:const XERO_TOKEN_ENDPOINT = "https://identity.xero.com/connect/token";
packages/mcp-connectors/xero/src/rate-limit.ts:2:// (https://developer.xero.com/documentation/guides/oauth2/limits):
packages/mcp-connectors/xero/package.json:2:  "name": "@ifos/xero",
packages/mcp-connectors/xero/src/types.ts:2:// Reference: https://developer.xero.com/documentation/api/accounting/overview
packages/mcp-connectors/xero/src/payments.ts:3:// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
packages/mcp-connectors/xero/src/payments.ts:56: * action_type='accounting_reconciliation_write' (yellow tier per
packages/mcp-connectors/xero/src/payments.ts:60: * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
agents/_shared/autosend-policy.yaml:53:  xero_query_invoices:
agents/_shared/autosend-policy.yaml:188:  xero_reminder_draft_internal:
agents/_shared/autosend-policy.yaml:209:  accounting_reconciliation_write:
agents/_shared/autosend-policy.yaml:263:  xero_reminder_send_customer:
agents/_shared/autosend-policy.yaml:302:  xero_payment_initiate:
packages/mcp-connectors/xero/src/cache.ts:22:      join(homedir(), ".ifos-cache", "xero");
packages/mcp-connectors/xero/README.md:1:# @ifos/xero
packages/mcp-connectors/xero/README.md:18:| `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup; returns + persists new bundle | Step 1 | `xero_oauth` | green |
packages/mcp-connectors/xero/README.md:23:| `writePaymentReceived(client, payment)` | PUT /Payments — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
packages/mcp-connectors/xero/README.md:25:All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `xero_oauth` + `accounting_reconciliation_write` already present per Day-25 evening verification.
packages/mcp-connectors/xero/README.md:32:import { XeroClient, listOpenInvoices, writePaymentReceived } from "@ifos/xero";
packages/mcp-connectors/xero/README.md:38:    tenant_id: "<xero-tenant-id-from-connections-endpoint>",
packages/mcp-connectors/xero/README.md:39:    token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/xero-tokens.json`,
packages/mcp-connectors/xero/README.md:63:1. Register the IFOS app at https://developer.xero.com/ → get `client_id` + `client_secret`.
packages/mcp-connectors/xero/README.md:66:4. POST to `https://identity.xero.com/connect/token` with `grant_type=authorization_code` + the code → receive `{access_token, refresh_token, expires_in}`.
packages/mcp-connectors/xero/README.md:67:5. Call `GET https://api.xero.com/connections` with the access_token → get the `tenant_id` (Xero "connection ID").
packages/mcp-connectors/xero/README.md:76:Per the published Xero limits page (https://developer.xero.com/documentation/guides/oauth2/limits):
packages/mcp-connectors/xero/README.md:156:   ├── Step 5 (reconciliation pass)     ──┼─→ @ifos/xero (this package)
packages/mcp-connectors/xero/README.md:161:                                         https://api.xero.com/api.xro/2.0
packages/mcp-connectors/xero/tests/auth.test.ts:46:  token_file = join(tmpdir(), `xero-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`);
packages/mcp-connectors/xero/tests/auth.test.ts:53:describe("xero auth", () => {
packages/mcp-connectors/xero/tests/scaffold.test.ts:25:describe("@ifos/xero package surface", () => {
packages/mcp-connectors/xero/tests/scaffold.test.ts:32:    expect(XERO_BASE_URL).toBe("https://api.xero.com/api.xro/2.0");
agents/recruitment/cash-conductor/cleanup.sh:24:#   - Purge ~/.ifos-cache/xero/* older than 24h (transient HTTP cache; keeps token files)
agents/recruitment/cash-conductor/cleanup.sh:28:#   - Reset in-process rate-limit buckets via @ifos/{xero,quickbooks,open-banking} resetRateLimit()
agents/recruitment/cash-conductor/cleanup.sh:33:#   - Token files at ~/.ifos-local-vault/<tenant>/{xero,qb,ob}-tokens-*.json (load-bearing)
agents/recruitment/cash-conductor/cleanup.sh:79:export XERO_CACHE_DIR="${IFOS_XERO_CACHE_DIR:-${HOME}/.ifos-cache/xero}"
agents/recruitment/cash-conductor/cleanup.sh:96:# Step 2 — Optional: emit ESC_RATE_LIMIT_HIT if any cache shows
agents/recruitment/cash-conductor/cleanup.sh:111:  "xero_cache_purged:${XERO_PURGED}; qb_cache_purged:${QB_PURGED}; ob_cache_purged:${OB_PURGED}; total:${TOTAL_PURGED}; mode:SKELETON"
agents/recruitment/cash-conductor/cleanup.sh:114:printf '[cash-conductor cleanup.sh] tenant=%s purged total=%d (xero=%d qb=%d ob=%d) mode=SKELETON\n' \
packages/mcp-connectors/xero/tests/capabilities.test.ts:57:  token_file = join(tmpdir(), `xero-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`);
packages/mcp-connectors/xero/tests/capabilities.test.ts:58:  cache_dir = join(tmpdir(), `xero-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`);
packages/mcp-connectors/xero/tests/capabilities.test.ts:70:describe("xero capabilities — invoices", () => {
packages/mcp-connectors/xero/tests/capabilities.test.ts:101:describe("xero capabilities — payments", () => {
packages/mcp-connectors/xero/tests/rate-limit.test.ts:10:describe("xero rate-limit", () => {
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:285:- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:317:#### `ESC_ACCOUNTING_WRITE_FAIL`
agents/_shared/escalation-codes.md:414:- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:36:  accounting_provider: xero
agents/recruitment/concierge/tools.yaml:51:        escalation: ESC_RATE_LIMIT_HIT  # warn; operator; payload.upstream='bullhorn'
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:94:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:98:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 263) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:119:2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 188-193), payload links to the draft via the vault path — this row records that Cash Conductor classified the draft as yellow-tier internal.
agents/recruitment/cash-conductor/agent.md:121:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 263; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:206:   → on success: hh_decision_action("accounting_reconciliation_write",
agents/recruitment/cash-conductor/agent.md:208:   → on failure: ESC_ACCOUNTING_WRITE_FAIL
agents/recruitment/cash-conductor/agent.md:253:    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:256:    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:264:    → The orange-tier `xero_reminder_send_customer` action row was
agents/recruitment/cash-conductor/agent.md:340:| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:351:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:401:| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:404:| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
agents/recruitment/cash-conductor/agent.md:406:| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:38:  accounting_provider: xero
agents/_shared/tests/test-hook-helpers.sh:121:test_lookup_red() { local t; t=$(autosend_policy_lookup "xero_payment_initiate"); _assert_eq "red" "${t}" "red"; }
agents/_shared/tests/test-hook-helpers.sh:145:  hh_decision_action "xero_payment_initiate" "invoice:42" "def456" "test"
agents/_shared/tests/test-hook-helpers.sh:224:  xero_payment_initiate: green
agents/_shared/tests/test-hook-helpers.sh:227:  result=$(autosend_apply_tenant_override "red" "xero_payment_initiate" "${CTX_TENANT_SLUG}")
agents/_shared/tests/test-hook-helpers.sh:293:    hh_decision_action "xero_payment_initiate" "invoice:${i}" "hashred${i}" "amount: £100"
agents/recruitment/janitor/agent.md:100:   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per ESC_RATE_LIMIT_HIT catalogue §2.5 standard handling)
agents/recruitment/janitor/agent.md:129:   → ESC_RATE_LIMIT_HIT on 429
agents/recruitment/janitor/agent.md:223:| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:6:#   accounting_reconciliation_write) → chase generation pass identifies
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:33:  accounting_provider: xero
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:69:      action_type: accounting_reconciliation_write
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:77:      action_type_emitted: xero_reminder_draft_internal
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:85:      action_type: accounting_reconciliation_write
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:89:      action_type: xero_reminder_draft_internal
agents/recruitment/concierge/agent.md:154:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:317:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/cash-conductor/context.sh:13:#   CTX_ACCOUNTING_PROVIDER   xero | quickbooks | sage (per tenant config)
agents/recruitment/cash-conductor/context.sh:73:# tenant_adapters.config; defaults to xero + truelayer per Cash Conductor §9 Q1+Q2.
agents/recruitment/cash-conductor/context.sh:80:: "${CTX_ACCOUNTING_PROVIDER:=xero}"
agents/recruitment/scribe/agent.md:282:| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
agents/recruitment/concierge/cycle.sh:137:# contact entities. ESC_RATE_LIMIT_HIT on 429; ESC_BULLHORN_AUTH on auth
agents/recruitment/sourcing-scout/agent.md:161:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
agents/recruitment/sourcing-scout/agent.md:169:   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
agents/recruitment/sourcing-scout/agent.md:175:   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:182:   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:295:| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
agents/recruitment/cash-conductor/cycle.sh:20:#   @ifos/xero            — Xero accounting provider
agents/recruitment/cash-conductor/cycle.sh:26:#   1. Reconciliation rows → accounting system (yellow tier accounting_reconciliation_write)
agents/recruitment/cash-conductor/cycle.sh:27:#   2. Chase drafts → vault + decision_log (yellow xero_reminder_draft_internal;
agents/recruitment/cash-conductor/cycle.sh:28:#      Cash Conductor OWNS the orange xero_reminder_send_customer action_type
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
agents/recruitment/cash-conductor/tools.yaml:133:    action_type: xero_reminder_send_customer  # ORANGE tier; REGISTERED at autosend-policy.yaml line 263; Cash Conductor OWNS this action_type per the same line
agents/recruitment/cash-conductor/tools.yaml:182:#   xero_reminder_draft_internal       line 188   yellow
agents/recruitment/cash-conductor/tools.yaml:183:#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
agents/recruitment/cash-conductor/tools.yaml:184:#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
agents/recruitment/cash-conductor/tools.yaml:188:#   xero_oauth                         green
agents/recruitment/diagnostic/tools.yaml:42:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:77:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:165:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:171:  - xero           # Cash Conductor's territory (W7-8)
agents/recruitment/diagnostic/agent.md:116:   → v0 NOTE: rate-limit catches (429 → ESC_RATE_LIMIT_HIT) and per-section retry logic are NOT implemented at v0 cycle.sh; W4 polish adds 429 catch + retry-with-backoff to cycle.sh. v0 generator throws-and-exits on upstream errors; validate.sh catches Gate A failure downstream.
agents/recruitment/diagnostic/agent.md:189:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn upstream 429 | warn | operator_chat_id | **v0: NOT implemented in `cycle.sh` (generator throws-and-exits on upstream errors; validate.sh catches downstream as `ESC_AGENT_OUTPUT_SHAPE`). W4-planned: 429 catch + retry-with-backoff in `cycle.sh` + explicit `ESC_RATE_LIMIT_HIT` emission.** |
agents/recruitment/cash-conductor/validate.sh:123:# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check

exec
/bin/zsh -lc 'rg -n "''^'"\\s*(xero_oauth|accounting_reconciliation_write):|action_type:.*(xero_oauth|accounting_reconciliation_write)|tier:\" agents/_shared/autosend-policy.yaml -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
30:    tier: green
36:    tier: green
42:    tier: green
48:    tier: green
54:    tier: green
60:    tier: green
66:    tier: green
72:    tier: green
78:    tier: green
84:    tier: green
90:    tier: green
96:    tier: green
102:    tier: green
108:    tier: green
114:    tier: green
120:    tier: green
126:    tier: green
132:    tier: green
138:    tier: green
144:    tier: green
154:    tier: yellow
161:    tier: yellow
168:    tier: yellow
175:    tier: yellow
182:    tier: yellow
189:    tier: yellow
196:    tier: yellow
203:    tier: yellow
209:  accounting_reconciliation_write:
210:    tier: yellow
217:    tier: yellow
228:    tier: orange
236:    tier: orange
243:    tier: orange
250:    tier: orange
257:    tier: orange
264:    tier: orange
271:    tier: orange
278:    tier: orange
285:    tier: orange
292:    tier: orange
303:    tier: red
310:    tier: red
317:    tier: red
324:    tier: red
331:    tier: red
338:    tier: red
345:    tier: red
352:    tier: red

exec
/bin/zsh -lc 'rg --files packages/mcp-connectors/xero agents/recruitment | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/README.md
agents/recruitment/cash-conductor/agent.md
agents/recruitment/cash-conductor/cleanup.sh
agents/recruitment/cash-conductor/context.sh
agents/recruitment/cash-conductor/cycle.sh
agents/recruitment/cash-conductor/fixtures/01-primary.yaml
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml
agents/recruitment/cash-conductor/tools.yaml
agents/recruitment/cash-conductor/validate.sh
agents/recruitment/concierge/README.md
agents/recruitment/concierge/agent.md
agents/recruitment/concierge/cleanup.sh
agents/recruitment/concierge/context.sh
agents/recruitment/concierge/cycle.sh
agents/recruitment/concierge/fixtures/01-primary.yaml
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml
agents/recruitment/concierge/tools.yaml
agents/recruitment/concierge/validate.sh
agents/recruitment/diagnostic/README.md
agents/recruitment/diagnostic/agent.md
agents/recruitment/diagnostic/cleanup.sh
agents/recruitment/diagnostic/context.sh
agents/recruitment/diagnostic/cycle.sh
agents/recruitment/diagnostic/fixtures/01-primary.yaml
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml
agents/recruitment/diagnostic/tools.yaml
agents/recruitment/diagnostic/validate.sh
agents/recruitment/janitor/README.md
agents/recruitment/janitor/agent.md
agents/recruitment/scribe/README.md
agents/recruitment/scribe/agent.md
agents/recruitment/sourcing-scout/README.md
agents/recruitment/sourcing-scout/agent.md
packages/mcp-connectors/xero/README.md
packages/mcp-connectors/xero/fixtures/invoices-page-1.json
packages/mcp-connectors/xero/fixtures/oauth-refresh-ok.json
packages/mcp-connectors/xero/fixtures/payment-write-ok.json
packages/mcp-connectors/xero/fixtures/payments-recent.json
packages/mcp-connectors/xero/package.json
packages/mcp-connectors/xero/src/auth.ts
packages/mcp-connectors/xero/src/cache.ts
packages/mcp-connectors/xero/src/client.ts
packages/mcp-connectors/xero/src/errors.ts
packages/mcp-connectors/xero/src/index.ts
packages/mcp-connectors/xero/src/invoices.ts
packages/mcp-connectors/xero/src/payments.ts
packages/mcp-connectors/xero/src/rate-limit.ts
packages/mcp-connectors/xero/src/types.ts
packages/mcp-connectors/xero/tests/auth.test.ts
packages/mcp-connectors/xero/tests/capabilities.test.ts
packages/mcp-connectors/xero/tests/rate-limit.test.ts
packages/mcp-connectors/xero/tests/scaffold.test.ts
packages/mcp-connectors/xero/tsconfig.json
packages/mcp-connectors/xero/tsup.config.ts
packages/mcp-connectors/xero/vitest.config.ts

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/README.md | sed -n '1,130p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/tools.yaml | sed -n '20,60p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# @ifos/xero
     2	
     3	Xero Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 token rotation + invoice read + payment read/write. Fixture-first; live API gated behind `MCP_LIVE_TESTS=true`.
     4	
     5	**Status:** Proposed (W4 Day-25 overnight scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial Xero signup for live-test verification).
     6	
     7	**Reference pattern:** mirrors `@ifos/companies-house` (Day-13 RATIFIED). Every new MCP connector follows this structure per `review-mcp-connector.md` §1.
     8	
     9	---
    10	
    11	## Capabilities
    12	
    13	| Function | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
    14	|---|---|---|---|---|
    15	| `XeroClient` (class) | HTTP wrapper: OAuth attach + rate-limit budget + 429 / 5xx retry | constructed in cycle.sh Step 1 | n/a (transport) | n/a |
    16	| `loadTokens(config)` | Read OAuth tokens from disk | Step 1 (auth refresh) | n/a (read-only) | n/a |
    17	| `saveTokens(config, t)` | Atomic write (.tmp + rename) to token file | refreshTokens internal | n/a | n/a |
    18	| `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup; returns + persists new bundle | Step 1 | `xero_oauth` | green |
    19	| `shouldRefresh(tokens, now?, window?)` | Returns true if access_token expires within window (default 5 min) | Step 1 + per-call | n/a (pure) | n/a |
    20	| `listOpenInvoices(client, options?)` | Page through AUTHORISED+SUBMITTED invoices with AmountDue > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
    21	| `getInvoice(client, invoiceId, options?)` | Fetch single invoice by Xero InvoiceID | Step 9 (chase-draft validation) | n/a | n/a |
    22	| `listPayments(client, options?)` | List ACCRECPAYMENT records (reconciliation context) | Step 5 (reconciliation pass) | n/a | n/a |
    23	| `writePaymentReceived(client, payment)` | PUT /Payments — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
    24	
    25	All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `xero_oauth` + `accounting_reconciliation_write` already present per Day-25 evening verification.
    26	
    27	---
    28	
    29	## Quick start
    30	
    31	```typescript
    32	import { XeroClient, listOpenInvoices, writePaymentReceived } from "@ifos/xero";
    33	
    34	const client = new XeroClient({
    35	  config: {
    36	    client_id: process.env.XERO_CLIENT_ID!,
    37	    client_secret: process.env.XERO_CLIENT_SECRET!,
    38	    tenant_id: "<xero-tenant-id-from-connections-endpoint>",
    39	    token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/xero-tokens.json`,
    40	  },
    41	});
    42	
    43	const invoices = await listOpenInvoices(client, { issued_since: "2026-04-01" });
    44	for (const inv of invoices) {
    45	  if (matchesBankDeposit(inv)) {
    46	    await writePaymentReceived(client, {
    47	      Invoice: { InvoiceID: inv.InvoiceID },
    48	      Account: { Code: "090" },
    49	      Date: "2026-05-22",
    50	      Amount: inv.AmountDue,
    51	      Reference: bankReference,
    52	    });
    53	  }
    54	}
    55	```
    56	
    57	---
    58	
    59	## OAuth bootstrap (one-time, per Xero tenant)
    60	
    61	The connector handles the **refresh** half of OAuth 2.0. The **initial authorisation** (consent screen → authorisation code → first token pair) is a one-time human-in-the-loop dance not covered here. Bootstrap procedure (manual):
    62	
    63	1. Register the IFOS app at https://developer.xero.com/ → get `client_id` + `client_secret`.
    64	2. Construct the authorise URL with `response_type=code` + `scope=offline_access accounting.transactions accounting.contacts.read` + your `redirect_uri`.
    65	3. User clicks → consents → Xero redirects to `redirect_uri?code=<auth_code>`.
    66	4. POST to `https://identity.xero.com/connect/token` with `grant_type=authorization_code` + the code → receive `{access_token, refresh_token, expires_in}`.
    67	5. Call `GET https://api.xero.com/connections` with the access_token → get the `tenant_id` (Xero "connection ID").
    68	6. Write the token bundle to `token_file_path` as JSON; mode 0600.
    69	
    70	After bootstrap, this connector's `refreshTokens()` handles all subsequent rotations automatically.
    71	
    72	---
    73	
    74	## Rate limits
    75	
    76	Per the published Xero limits page (https://developer.xero.com/documentation/guides/oauth2/limits):
    77	
    78	- **60 calls / 60-second window per app per tenant** (minute bucket)
    79	- **5000 calls / day per tenant** (daily bucket, resets at midnight UTC)
    80	- **5 concurrent calls per app per tenant** — not enforced here; single-process Cash Conductor cycle.sh is serial
    81	
    82	This connector tracks BOTH windows per `src/rate-limit.ts`. Soft backoff at 80% (48/minute, 4000/day); hard fail at 100% → `XeroRateLimitError`. State is in-process and per-tenant — a multi-tenant runtime that holds many `XeroClient` instances in one process still gets correct isolation.
    83	
    84	If you see `XeroRateLimitError` consistently in Cash Conductor logs, either the daily budget is too low for the tenant's invoice volume OR the polling interval is too tight; in either case it's an operator-tuning event, not a code bug.
    85	
    86	---
    87	
    88	## Retry policy
    89	
    90	| Capability | Method | Max retries | Backoff | On exhaustion |
    91	|---|---|---|---|---|
    92	| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `XeroError` or `XeroRateLimitError` |
    93	| `writePaymentReceived` | PUT | **0** | n/a (writes never auto-retry) | `XeroValidationError` (400) / `XeroError` (5xx) |
    94	| `refreshTokens` | POST | **0** | n/a | `XeroAuthError` (caller may re-attempt with new credentials) |
    95	| 401 from any GET | — | force-refresh access_token, retry once | — | `XeroAuthError` |
    96	| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `XeroRateLimitError` |
    97	
    98	Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to Xero.
    99	
   100	---
   101	
   102	## Error hierarchy
   103	
   104	```
   105	XeroError                  // base
   106	├── XeroAuthError          // OAuth refresh fail (401/4xx on token endpoint)
   107	├── XeroRateLimitError     // 429 OR local bucket exhausted
   108	├── XeroNotFoundError      // 404
   109	└── XeroValidationError    // 400 (typically schema/business-rule)
   110	```
   111	
   112	Errors NEVER include credential values in their `.message` — only the key NAMES, status code, and safe metadata. Per `review-mcp-connector.md` §5 (zero secret interpolation).
   113	
   114	---
   115	
   116	## Tests
   117	
   118	```bash
   119	# Unit + fixture tests (fast; no network)
   120	pnpm test
   121	
   122	# Live API tests (requires real Xero sandbox credentials; off by default)
   123	MCP_LIVE_TESTS=true pnpm test
   124	```
   125	
   126	**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`; live tests are gated on `MCP_LIVE_TESTS=true`.
   127	
   128	Test counts (W4 Day-25 overnight scaffold):
   129	- `tests/scaffold.test.ts`: 5 (public surface, exports, error hierarchy)
   130	- `tests/rate-limit.test.ts`: 5 (initial state, soft 48, hard 60, per-tenant isolation, etc.)

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
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,80p;200,215p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS auto-send policy (runtime table)
     2	#
     3	# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
     4	# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
     5	# hh_decision_action() invocation. Per-tenant overrides live in Postgres
     6	# tenant_adapters.config.tier_overrides (§8).
     7	#
     8	# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
     9	# Each row carries:
    10	#   tier            green|yellow|orange|red
    11	#   agent           v1.0 owning agent (or "all" if cross-cutting red rule)
    12	#   reason          short rationale (mirrors §3 column 3)
    13	#   sample_rate     yellow only: 1-in-N for spot-check sampling
    14	#   block_reason    red only: enum from §3 red table column 2
    15	#   timeout         orange only: ISO-8601 duration; default PT4H if absent
    16	#   irreversible    boolean; informational — drives operator UX framing
    17	#
    18	# Schema validated by common-base.json $refs via render-time pre-flight.
    19	# Schema version stamps decision_log.payload.policy_version_sha at write time.
    20	
    21	version: "v1.0-2026-05-24"
    22	
    23	action_types:
    24	
    25	  # ───────────────────────────────────────────────────────────
    26	  # GREEN — auto-send without review (19 action_types)
    27	  # ───────────────────────────────────────────────────────────
    28	
    29	  diagnostic_report_render:
    30	    tier: green
    31	    agent: diagnostic
    32	    reason: "Internal artefact write; no external comms; idempotent (re-render overwrites)"
    33	    irreversible: false
    34	
    35	  bullhorn_candidate_tag:
    36	    tier: green
    37	    agent: janitor
    38	    reason: "Adds tag with checked_at date; reversible in <30s; high volume"
    39	    irreversible: false
    40	
    41	  bullhorn_note_internal:
    42	    tier: green
    43	    agent: scribe
    44	    reason: "Internal-only Bullhorn note (isExternal: false); consultant-visible; non-customer-facing"
    45	    irreversible: false
    46	
    47	  linkedin_profile_cache:
    48	    tier: green
    49	    agent: sourcing-scout
    50	    reason: "Stores profile snapshot to /vault/<tenant>/wiki/raw/; no external send; no rate-limit cost"
    51	    irreversible: false
    52	
    53	  xero_query_invoices:
    54	    tier: green
    55	    agent: cash-conductor
    56	    reason: "Read-only Xero query; rate-limited via Xero's own quotas; no side effect"
    57	    irreversible: false
    58	
    59	  bullhorn_brief_read:
    60	    tier: green
    61	    agent: concierge
    62	    reason: "Read of inbound brief; idempotent; no comms"
    63	    irreversible: false
    64	
    65	  operator_notify_telegram:
    66	    tier: green
    67	    agent: all
    68	    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
    69	    irreversible: false
    70	
    71	  janitor_run_complete:
    72	    tier: green
    73	    agent: janitor
    74	    reason: "Internal run-complete status marker written to decision_log; no external comms; informational"
    75	    irreversible: false
    76	
    77	  scout_run_complete:
    78	    tier: green
    79	    agent: sourcing-scout
    80	    reason: "Internal run-complete status marker; no external comms"
   200	    irreversible: false
   201	
   202	  bullhorn_scribe_field_write:
   203	    tier: yellow
   204	    agent: scribe
   205	    sample_rate: 10
   206	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   207	    irreversible: false
   208	
   209	  accounting_reconciliation_write:
   210	    tier: yellow
   211	    agent: cash-conductor
   212	    sample_rate: 10
   213	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   214	    irreversible: false
   215	

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/src/client.ts | sed -n '85,180p'; nl -ba packages/mcp-connectors/xero/src/index.ts | sed -n '1,50p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   134	      // 401: token bad — force a refresh next iteration
   135	      if (res.status === 401 && attempt < max_retries) {
   136	        this.current_tokens = null;
   137	        await sleep(backoff(attempt));
   138	        continue;
   139	      }
   140	
   141	      // 429: rate-limited; honour Retry-After then retry (GET only)
   142	      if (res.status === 429 && attempt < max_retries) {
   143	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   144	        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
   145	        await sleep(waitMs);
   146	        continue;
   147	      }
   148	      if (res.status === 429) {
   149	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   150	        throw new XeroRateLimitError(
   151	          `Xero returned 429 after ${attempt + 1} attempt(s)`,
   152	          retryAfter > 0 ? retryAfter : null,
   153	        );
   154	      }
   155	
   156	      // 5xx: retry with backoff (GET only)
   157	      if (res.status >= 500 && attempt < max_retries) {
   158	        await sleep(backoff(attempt));
   159	        continue;
   160	      }
   161	
   162	      // 4xx (non-401/429): typed error, no retry
   163	      const safeBody = await res.text().catch(() => "");
   164	      if (res.status === 404) {
   165	        throw new XeroNotFoundError(`Xero 404 on ${method} ${path}`);
   166	      }
   167	      if (res.status === 400) {
   168	        throw new XeroValidationError(
   169	          `Xero rejected ${method} ${path} (HTTP 400)`,
   170	          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
   171	        );
   172	      }
   173	      throw new XeroError(
   174	        `Xero ${method} ${path} failed (HTTP ${res.status})`,
   175	        res.status,
   176	      );
   177	    }
   178	    throw new XeroError(
   179	      `Xero ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
   180	    );
     1	// @ifos/xero — public API
     2	//
     3	// Used by Cash Conductor agent (W4-7 build wave) per
     4	// agents/recruitment/cash-conductor/tools.yaml capabilities:
     5	//   xero_oauth                       → auth.refreshTokens + client.getValidAccessToken
     6	//   accounting_reconciliation_write  → payments.writePaymentReceived
     7	//   (read-only invoice register)     → invoices.listOpenInvoices + getInvoice
     8	//
     9	// Reference implementation: @ifos/companies-house. Pattern parity intentional —
    10	// new connectors mirror this structure (see review-mcp-connector skill §1).
    11	
    12	export {
    13	  loadTokens,
    14	  saveTokens,
    15	  refreshTokens,
    16	  shouldRefresh,
    17	  _resetInflightForTest,
    18	} from "./auth.js";
    19	export { XeroClient, XERO_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
    20	export { listOpenInvoices, getInvoice } from "./invoices.js";
    21	export { listPayments, writePaymentReceived } from "./payments.js";
    22	export { XeroCache } from "./cache.js";
    23	export {
    24	  check as rateCheck,
    25	  consume as rateConsume,
    26	  reset as resetRateLimit,
    27	} from "./rate-limit.js";
    28	export {
    29	  XeroError,
    30	  XeroAuthError,
    31	  XeroRateLimitError,
    32	  XeroNotFoundError,
    33	  XeroValidationError,
    34	} from "./errors.js";
    35	export type {
    36	  XeroTokens,
    37	  XeroOAuthConfig,
    38	  XeroInvoice,
    39	  XeroInvoicesResponse,
    40	  XeroPayment,
    41	  XeroPaymentsResponse,
    42	  XeroPaymentWriteRequest,
    43	  XeroClientOptions,
    44	} from "./types.js";
    45	export type { RateState } from "./rate-limit.js";
    46	
    47	export const VERSION = "0.1.0";

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/tests/auth.test.ts | sed -n '80,130p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/tests/capabilities.test.ts | sed -n '70,130p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    80	
    81	    const newT = await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    82	    expect(newT.access_token).toBe("fake-new-access-token-abcdef123456");
    83	    expect(newT.refresh_token).toBe("fake-new-refresh-token-zyxwvu987654");
    84	    // File now exists with new tokens
    85	    const onDisk = await loadTokens(config);
    86	    expect(onDisk?.access_token).toBe(newT.access_token);
    87	  });
    88	
    89	  it("refreshTokens: 401 surfaces as XeroAuthError; does NOT include token in error", async () => {
    90	    const config = makeConfig(token_file);
    91	    const fakeFetch = async (): Promise<Response> =>
    92	      new Response(JSON.stringify({ error: "invalid_grant", error_description: "refresh_token expired" }), {
    93	        status: 401,
    94	        headers: { "Content-Type": "application/json" },
    95	      });
    96	
    97	    await expect(refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch)).rejects.toBeInstanceOf(XeroAuthError);
    98	    // Verify the message does NOT leak the refresh_token value
    99	    try {
   100	      await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
   101	    } catch (e) {
   102	      const msg = (e as Error).message;
   103	      expect(msg).not.toContain(FIXTURE_TOKENS.refresh_token);
   104	    }
   105	  });
   106	
   107	  it("refreshTokens: concurrent calls converge on ONE network call (idempotent dedup)", async () => {
   108	    const config = makeConfig(token_file);
   109	    let calls = 0;
   110	    const fakeFetch = async (): Promise<Response> => {
   111	      calls += 1;
   112	      // small delay to ensure overlap
   113	      await new Promise((r) => setTimeout(r, 25));
   114	      return new Response(REFRESH_OK_BODY, { status: 200, headers: { "Content-Type": "application/json" } });
   115	    };
   116	
   117	    const [a, b, c] = await Promise.all([
   118	      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
   119	      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
   120	      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
   121	    ]);
   122	    expect(calls).toBe(1);
   123	    expect(a.access_token).toBe(b.access_token);
   124	    expect(b.access_token).toBe(c.access_token);
   125	    // File written exactly once with the new token
   126	    const onDisk = await loadTokens(config);
   127	    expect(onDisk?.access_token).toBe(a.access_token);
   128	  });
   129	});

 succeeded in 0ms:
    70	describe("xero capabilities — invoices", () => {
    71	  it("listOpenInvoices: returns parsed array from fixture", async () => {
    72	    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    73	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    74	    const invoices = await listOpenInvoices(client, { cache, no_cache: true });
    75	    expect(invoices.length).toBe(2);
    76	    expect(invoices[0]?.InvoiceID).toBe("0000aaaa-1111-2222-3333-444455556666");
    77	    expect(invoices[0]?.AmountDue).toBe(1200);
    78	    expect(invoices[1]?.Contact.Name).toBe("Beta Search Partners");
    79	  });
    80	
    81	  it("getInvoice: returns single invoice when present", async () => {
    82	    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    83	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    84	    const inv = await getInvoice(client, "0000aaaa-1111-2222-3333-444455556666", {
    85	      cache,
    86	      no_cache: true,
    87	    });
    88	    expect(inv).not.toBeNull();
    89	    expect(inv?.InvoiceNumber).toBe("INV-0001");
    90	  });
    91	
    92	  it("getInvoice: 404 surfaces as XeroNotFoundError", async () => {
    93	    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    94	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    95	    await expect(
    96	      getInvoice(client, "00000000-0000-0000-0000-000000000000", { cache, no_cache: true }),
    97	    ).rejects.toBeInstanceOf(XeroNotFoundError);
    98	  });
    99	});
   100	
   101	describe("xero capabilities — payments", () => {
   102	  it("listPayments: returns parsed array from fixture", async () => {
   103	    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENTS_RECENT);
   104	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   105	    const payments = await listPayments(client, { cache, no_cache: true });
   106	    expect(payments.length).toBe(1);
   107	    expect(payments[0]?.Amount).toBe(2000);
   108	    expect(payments[0]?.PaymentType).toBe("ACCRECPAYMENT");
   109	  });
   110	
   111	  it("writePaymentReceived: success path returns created payment", async () => {
   112	    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENT_WRITE_OK);
   113	    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
   114	    const payload: XeroPaymentWriteRequest = {
   115	      Invoice: { InvoiceID: "0000aaaa-1111-2222-3333-444455556666" },
   116	      Account: { Code: "090" },
   117	      Date: "2026-05-22",
   118	      Amount: 1200.0,
   119	      Reference: "BACS-2026-05-22-002",
   120	    };
   121	    const created = await writePaymentReceived(client, payload);
   122	    expect(created.PaymentID).toBe("p000-cccc-2222");
   123	    expect(created.Amount).toBe(1200);
   124	  });
   125	
   126	  it("writePaymentReceived: 400 surfaces as XeroValidationError (no retry)", async () => {
   127	    let calls = 0;
   128	    const fakeFetch: typeof fetch = async () => {
   129	      calls += 1;
   130	      return new Response("Invoice ID does not exist", { status: 400 });

exec
/bin/zsh -lc "rg -n \"ESC_RATE_LIMIT_HIT|payload\\.upstream|XeroRateLimitError|rate-limit\" packages/mcp-connectors/xero/README.md packages/mcp-connectors/xero/tests packages/mcp-connectors/xero/src -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/xero/README.md:15:| `XeroClient` (class) | HTTP wrapper: OAuth attach + rate-limit budget + 429 / 5xx retry | constructed in cycle.sh Step 1 | n/a (transport) | n/a |
packages/mcp-connectors/xero/README.md:82:This connector tracks BOTH windows per `src/rate-limit.ts`. Soft backoff at 80% (48/minute, 4000/day); hard fail at 100% → `XeroRateLimitError`. State is in-process and per-tenant — a multi-tenant runtime that holds many `XeroClient` instances in one process still gets correct isolation.
packages/mcp-connectors/xero/README.md:84:If you see `XeroRateLimitError` consistently in Cash Conductor logs, either the daily budget is too low for the tenant's invoice volume OR the polling interval is too tight; in either case it's an operator-tuning event, not a code bug.
packages/mcp-connectors/xero/README.md:92:| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `XeroError` or `XeroRateLimitError` |
packages/mcp-connectors/xero/README.md:96:| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `XeroRateLimitError` |
packages/mcp-connectors/xero/README.md:107:├── XeroRateLimitError     // 429 OR local bucket exhausted
packages/mcp-connectors/xero/README.md:130:- `tests/rate-limit.test.ts`: 5 (initial state, soft 48, hard 60, per-tenant isolation, etc.)
packages/mcp-connectors/xero/README.md:177:- ✓ No hardcoded tenant slugs in `src/` (test fixtures only — `fixture-tenant`, `test-tenant-rate-limit`)
packages/mcp-connectors/xero/tests/rate-limit.test.ts:6:import { check, consume, reset } from "../src/rate-limit.js";
packages/mcp-connectors/xero/tests/rate-limit.test.ts:8:const TENANT = "test-tenant-rate-limit";
packages/mcp-connectors/xero/tests/rate-limit.test.ts:10:describe("xero rate-limit", () => {
packages/mcp-connectors/xero/tests/scaffold.test.ts:20:  XeroRateLimitError,
packages/mcp-connectors/xero/tests/scaffold.test.ts:53:    expect(new XeroRateLimitError("x") instanceof XeroError).toBe(true);
packages/mcp-connectors/xero/tests/capabilities.test.ts:11:import { reset as resetRateLimit } from "../src/rate-limit.js";
packages/mcp-connectors/xero/src/index.ts:27:} from "./rate-limit.js";
packages/mcp-connectors/xero/src/index.ts:31:  XeroRateLimitError,
packages/mcp-connectors/xero/src/index.ts:45:export type { RateState } from "./rate-limit.js";
packages/mcp-connectors/xero/src/errors.ts:25:export class XeroRateLimitError extends XeroError {
packages/mcp-connectors/xero/src/errors.ts:31:    this.name = "XeroRateLimitError";
packages/mcp-connectors/xero/src/client.ts:1:// Xero HTTP client — wraps fetch with: OAuth token attach, rate-limit
packages/mcp-connectors/xero/src/client.ts:9:  XeroRateLimitError,
packages/mcp-connectors/xero/src/client.ts:12:import { consume } from "./rate-limit.js";
packages/mcp-connectors/xero/src/client.ts:90:      // Pre-emptive rate-limit check
packages/mcp-connectors/xero/src/client.ts:93:        throw new XeroRateLimitError(
packages/mcp-connectors/xero/src/client.ts:94:          `Xero rate-limit budget exhausted (tenant=${this.opts.config.tenant_id}); ` +
packages/mcp-connectors/xero/src/client.ts:141:      // 429: rate-limited; honour Retry-After then retry (GET only)
packages/mcp-connectors/xero/src/client.ts:150:        throw new XeroRateLimitError(

exec
/bin/zsh -lc "rg -n \"console\\.(log|error|warn).*\\"'$'"\\{.*(KEY|SECRET|PASSWORD|TOKEN|BEARER)|throw\\s+new\\s+Error.*\\"'$'"\\{.*(KEY|SECRET|PASSWORD)|composio|agentmail|packages/harness/cortextos|decision_log|migration-test|test-tenant-b\" packages/mcp-connectors/xero -i -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/xero/README.md:175:- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
packages/mcp-connectors/xero/README.md:176:- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/src/auth.ts | sed -n '80,145p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/xero/src/rate-limit.ts | sed -n '1,95p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    80	 * same tenant, return the in-flight Promise (one network call, one file write).
    81	 *
    82	 * Throws XeroAuthError on 4xx (credentials rejected); does NOT retry — caller
    83	 * decides whether to re-attempt with new credentials.
    84	 */
    85	export async function refreshTokens(
    86	  config: XeroOAuthConfig,
    87	  current_tokens: XeroTokens,
    88	  fetchFn: typeof fetch = fetch,
    89	): Promise<XeroTokens> {
    90	  const lockKey = config.tenant_id;
    91	  const existing = inflight.get(lockKey);
    92	  if (existing) return existing;
    93	
    94	  const promise = (async () => {
    95	    try {
    96	      const basic = Buffer.from(
    97	        `${config.client_id}:${config.client_secret}`,
    98	      ).toString("base64");
    99	
   100	      const body = new URLSearchParams({
   101	        grant_type: "refresh_token",
   102	        refresh_token: current_tokens.refresh_token,
   103	      });
   104	
   105	      const res = await fetchFn(XERO_TOKEN_ENDPOINT, {
   106	        method: "POST",
   107	        headers: {
   108	          Authorization: `Basic ${basic}`,
   109	          "Content-Type": "application/x-www-form-urlencoded",
   110	        },
   111	        body,
   112	      });
   113	
   114	      if (!res.ok) {
   115	        // Never include the response body verbatim — Xero may echo the
   116	        // (now-invalid) refresh_token in error responses.
   117	        throw new XeroAuthError(
   118	          `Xero OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
   119	          res.status,
   120	        );
   121	      }
   122	
   123	      const data = (await res.json()) as {
   124	        access_token: string;
   125	        refresh_token: string;
   126	        expires_in: number;
   127	        scope: string;
   128	        token_type: string;
   129	      };
   130	
   131	      const new_tokens: XeroTokens = {
   132	        access_token: data.access_token,
   133	        refresh_token: data.refresh_token,
   134	        expires_at_ms: Date.now() + data.expires_in * 1000,
   135	        scope: data.scope,
   136	        token_type: data.token_type,
   137	      };
   138	
   139	      await saveTokens(config, new_tokens);
   140	      return new_tokens;
   141	    } finally {
   142	      inflight.delete(lockKey);
   143	    }
   144	  })();
   145	

 succeeded in 0ms:
     1	// Rate limiter for Xero. Per Xero published limits
     2	// (https://developer.xero.com/documentation/guides/oauth2/limits):
     3	//   - 60 calls / 60-second window per app per tenant (minute bucket)
     4	//   - 5000 calls / day per tenant (daily bucket)
     5	//   - Concurrent: 5 simultaneous calls per app per tenant (we don't enforce
     6	//     concurrency here — single-process Cash Conductor cycle.sh is serial)
     7	//
     8	// We track BOTH windows; backoff at 80% of the tighter one. Per-tenant
     9	// state (multi-tenant safe).
    10	
    11	const MINUTE_MS = 60 * 1000;
    12	const DAY_MS = 24 * 60 * 60 * 1000;
    13	const MINUTE_HARD = 60;
    14	const DAILY_HARD = 5000;
    15	const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 48
    16	const DAILY_SOFT = Math.floor(DAILY_HARD * 0.8); // 4000
    17	
    18	const minuteTimestamps: Map<string, number[]> = new Map();
    19	const dailyTimestamps: Map<string, number[]> = new Map();
    20	
    21	export interface RateState {
    22	  tenant_id: string;
    23	  minute_used: number;
    24	  minute_remaining: number;
    25	  daily_used: number;
    26	  daily_remaining: number;
    27	  shouldBackoff: boolean;
    28	  reason: "ok" | "minute-soft" | "daily-soft" | "minute-hard" | "daily-hard";
    29	}
    30	
    31	function pruneMinute(arr: number[] | undefined, now: number): number[] {
    32	  if (!arr) return [];
    33	  return arr.filter((ts) => now - ts < MINUTE_MS);
    34	}
    35	function pruneDay(arr: number[] | undefined, now: number): number[] {
    36	  if (!arr) return [];
    37	  return arr.filter((ts) => now - ts < DAY_MS);
    38	}
    39	
    40	export function check(
    41	  tenant_id: string,
    42	  now: () => number = Date.now,
    43	): RateState {
    44	  const t = now();
    45	  const minute = pruneMinute(minuteTimestamps.get(tenant_id), t);
    46	  const day = pruneDay(dailyTimestamps.get(tenant_id), t);
    47	  minuteTimestamps.set(tenant_id, minute);
    48	  dailyTimestamps.set(tenant_id, day);
    49	
    50	  const minute_used = minute.length;
    51	  const daily_used = day.length;
    52	  let reason: RateState["reason"] = "ok";
    53	  let shouldBackoff = false;
    54	
    55	  if (minute_used >= MINUTE_HARD) {
    56	    reason = "minute-hard";
    57	    shouldBackoff = true;
    58	  } else if (daily_used >= DAILY_HARD) {
    59	    reason = "daily-hard";
    60	    shouldBackoff = true;
    61	  } else if (daily_used >= DAILY_SOFT) {
    62	    reason = "daily-soft";
    63	    shouldBackoff = true;
    64	  } else if (minute_used >= MINUTE_SOFT) {
    65	    reason = "minute-soft";
    66	    shouldBackoff = true;
    67	  }
    68	
    69	  return {
    70	    tenant_id,
    71	    minute_used,
    72	    minute_remaining: MINUTE_HARD - minute_used,
    73	    daily_used,
    74	    daily_remaining: DAILY_HARD - daily_used,
    75	    shouldBackoff,
    76	    reason,
    77	  };
    78	}
    79	
    80	export function consume(
    81	  tenant_id: string,
    82	  now: () => number = Date.now,
    83	): boolean {
    84	  const state = check(tenant_id, now);
    85	  if (state.reason === "minute-hard" || state.reason === "daily-hard")
    86	    return false;
    87	  const t = now();
    88	  const minute = pruneMinute(minuteTimestamps.get(tenant_id), t);
    89	  const day = pruneDay(dailyTimestamps.get(tenant_id), t);
    90	  minute.push(t);
    91	  day.push(t);
    92	  minuteTimestamps.set(tenant_id, minute);
    93	  dailyTimestamps.set(tenant_id, day);
    94	  return true;
    95	}

codex
REJECTED

1. `xero_oauth` is documented as registered, but it is absent from autosend policy. README line 25 says "`xero_oauth` + `accounting_reconciliation_write` already present"; `agents/recruitment/cash-conductor/tools.yaml` line 30 says `xero_oauth` registration is queued; `agents/_shared/autosend-policy.yaml` lines 53-57 has `xero_query_invoices`, and lines 209-214 has `accounting_reconciliation_write`, but no `xero_oauth`. This fails mcp-connector §7 and honest-signal rule 5. Add `xero_oauth` to `autosend-policy.yaml` with green tier in the same commit, or mark it explicitly as proposed.

2. Rate-limit handling does not document the required ESC dispatch and does not enforce the documented 80% safety margin. README lines 76-84 names Xero limits and `XeroRateLimitError`, but omits `ESC_RATE_LIMIT_HIT` with `payload.upstream='xero'` required by mcp-connector §3. `src/rate-limit.ts` lines 61-66 only marks soft thresholds, while `consume()` lines 84-86 permits calls until 100%; `src/client.ts` lines 90-96 only fails when `consume()` returns false. Document and wire `ESC_RATE_LIMIT_HIT`, and either enforce the 80% bucket margin or correct the README.

3. The capability surface is not set-equal across tools.yaml, README, and exports. `agents/recruitment/cash-conductor/tools.yaml` lines 27-57 declares `xero_oauth`, `xero_list_open_invoices`, `xero_get_invoice`, `xero_list_payments`, and `xero_write_payment_received`; README lines 15-23 lists helper/function names like `loadTokens`, `saveTokens`, and `shouldRefresh`; `src/index.ts` lines 12-27 exports additional public functions like `_resetInflightForTest`, `rateCheck`, `rateConsume`, and `resetRateLimit`. This fails mcp-connector §1. Make the public capability table, agent tool IDs, and exported capability wrappers identical, with non-capability helpers documented separately or kept internal.

4. Not every capability has both happy-path and error-path fixture tests. `tests/capabilities.test.ts` lines 71-79 covers only the happy path for `listOpenInvoices`, and lines 102-109 covers only the happy path for `listPayments`; the only read error path is for `getInvoice` at lines 92-98. This fails mcp-connector §6. Add fixture-backed 4xx/5xx/429 or malformed-response tests for `listOpenInvoices` and `listPayments`.
tokens used
52,397
REJECTED

1. `xero_oauth` is documented as registered, but it is absent from autosend policy. README line 25 says "`xero_oauth` + `accounting_reconciliation_write` already present"; `agents/recruitment/cash-conductor/tools.yaml` line 30 says `xero_oauth` registration is queued; `agents/_shared/autosend-policy.yaml` lines 53-57 has `xero_query_invoices`, and lines 209-214 has `accounting_reconciliation_write`, but no `xero_oauth`. This fails mcp-connector §7 and honest-signal rule 5. Add `xero_oauth` to `autosend-policy.yaml` with green tier in the same commit, or mark it explicitly as proposed.

2. Rate-limit handling does not document the required ESC dispatch and does not enforce the documented 80% safety margin. README lines 76-84 names Xero limits and `XeroRateLimitError`, but omits `ESC_RATE_LIMIT_HIT` with `payload.upstream='xero'` required by mcp-connector §3. `src/rate-limit.ts` lines 61-66 only marks soft thresholds, while `consume()` lines 84-86 permits calls until 100%; `src/client.ts` lines 90-96 only fails when `consume()` returns false. Document and wire `ESC_RATE_LIMIT_HIT`, and either enforce the 80% bucket margin or correct the README.

3. The capability surface is not set-equal across tools.yaml, README, and exports. `agents/recruitment/cash-conductor/tools.yaml` lines 27-57 declares `xero_oauth`, `xero_list_open_invoices`, `xero_get_invoice`, `xero_list_payments`, and `xero_write_payment_received`; README lines 15-23 lists helper/function names like `loadTokens`, `saveTokens`, and `shouldRefresh`; `src/index.ts` lines 12-27 exports additional public functions like `_resetInflightForTest`, `rateCheck`, `rateConsume`, and `resetRateLimit`. This fails mcp-connector §1. Make the public capability table, agent tool IDs, and exported capability wrappers identical, with non-capability helpers documented separately or kept internal.

4. Not every capability has both happy-path and error-path fixture tests. `tests/capabilities.test.ts` lines 71-79 covers only the happy path for `listOpenInvoices`, and lines 102-109 covers only the happy path for `listPayments`; the only read error path is for `getInvoice` at lines 92-98. This fails mcp-connector §6. Add fixture-backed 4xx/5xx/429 or malformed-response tests for `listOpenInvoices` and `listPayments`.
