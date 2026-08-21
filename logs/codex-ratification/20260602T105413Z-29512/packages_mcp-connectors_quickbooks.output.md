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
session id: 019e87f9-8ad5-7242-9df0-4995935ba243
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

Path: packages/mcp-connectors/quickbooks

--- BEGIN ARTEFACT ---


--- FILE: packages/mcp-connectors/quickbooks/fixtures/invoices-page-1.json ---

{
  "QueryResponse": {
    "Invoice": [
      {
        "Id": "1001",
        "DocNumber": "INV-1001",
        "TxnDate": "2026-05-15",
        "DueDate": "2026-06-14",
        "CurrencyRef": { "value": "GBP", "name": "Pound Sterling" },
        "TotalAmt": 1500.00,
        "Balance": 1500.00,
        "CustomerRef": { "value": "200", "name": "Acme Recruitment Ltd" },
        "CustomerMemo": null,
        "MetaData": {
          "CreateTime": "2026-05-15T09:00:00Z",
          "LastUpdatedTime": "2026-05-15T09:00:00Z"
        }
      },
      {
        "Id": "1002",
        "DocNumber": "INV-1002",
        "TxnDate": "2026-05-10",
        "DueDate": "2026-06-09",
        "CurrencyRef": { "value": "GBP", "name": "Pound Sterling" },
        "TotalAmt": 4200.00,
        "Balance": 2200.00,
        "CustomerRef": { "value": "201", "name": "Beta Search Partners" },
        "CustomerMemo": { "value": "Partial payment received 2026-05-20" },
        "MetaData": {
          "CreateTime": "2026-05-10T14:30:00Z",
          "LastUpdatedTime": "2026-05-20T11:00:00Z"
        }
      }
    ],
    "startPosition": 1,
    "maxResults": 100,
    "totalCount": 2
  },
  "time": "2026-06-01T12:00:00Z"
}

--- FILE: packages/mcp-connectors/quickbooks/fixtures/payment-write-ok.json ---

{
  "Payment": {
    "Id": "p-502",
    "TxnDate": "2026-05-22",
    "TotalAmt": 1500.00,
    "CustomerRef": { "value": "200", "name": "Acme Recruitment Ltd" },
    "PaymentRefNum": "BACS-2026-05-22-002",
    "Line": [
      {
        "Amount": 1500.00,
        "LinkedTxn": [{ "TxnId": "1001", "TxnType": "Invoice" }]
      }
    ],
    "MetaData": {
      "CreateTime": "2026-05-22T14:00:00Z",
      "LastUpdatedTime": "2026-05-22T14:00:00Z"
    }
  },
  "time": "2026-06-01T12:00:00Z"
}

--- FILE: packages/mcp-connectors/quickbooks/fixtures/payments-recent.json ---

{
  "QueryResponse": {
    "Payment": [
      {
        "Id": "p-501",
        "TxnDate": "2026-05-20",
        "TotalAmt": 2000.00,
        "CustomerRef": { "value": "201", "name": "Beta Search Partners" },
        "PaymentRefNum": "BACS-2026-05-20-001",
        "Line": [
          {
            "Amount": 2000.00,
            "LinkedTxn": [{ "TxnId": "1002", "TxnType": "Invoice" }]
          }
        ],
        "MetaData": {
          "CreateTime": "2026-05-20T11:00:00Z",
          "LastUpdatedTime": "2026-05-20T11:00:00Z"
        }
      }
    ],
    "startPosition": 1,
    "maxResults": 100,
    "totalCount": 1
  },
  "time": "2026-06-01T12:00:00Z"
}

--- FILE: packages/mcp-connectors/quickbooks/package.json ---

{
  "name": "@ifos/quickbooks",
  "version": "0.1.0",
  "private": true,
  "description": "IFOS QuickBooks Online MCP connector — OAuth 2.0 refresh (per-realm) + invoices read + payments read/write. Used by Cash Conductor agent §4 Steps 4-6 + 10-11 per agents/recruitment/cash-conductor/tools.yaml.",
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

--- FILE: packages/mcp-connectors/quickbooks/README.md ---

# @ifos/quickbooks

QuickBooks Online (QBO) Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 with **per-realm** token rotation + invoice read + payment read/write. Fixture-first; live tests deferred to first commercial QB sandbox signup (see §Tests).

**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial QB sandbox signup for live-test verification).

**Reference pattern:** mirrors `@ifos/xero` (W4 Day-25 RATIFIED scaffold). The per-realm OAuth diff vs Xero's per-tenant header is the load-bearing structural difference — documented in §"OAuth bootstrap" below. Every new MCP connector follows the parity model per `review-mcp-connector.md` §1.

---

## Capabilities

Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.

| Capability ID (tools.yaml) | Function (src/index.ts) | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
|---|---|---|---|---|---|
| `quickbooks_oauth` | `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per realm; atomic-file-write persistence | Step 1 (auth refresh) | `quickbooks_oauth` | green |
| `quickbooks_list_open_invoices` | `listOpenInvoices(client, options?)` | Query API: paginated Invoice rows with Balance > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
| `quickbooks_get_invoice` | `getInvoice(client, invoiceId, options?)` | Single-entity read by QB Id | Step 9 (chase-draft validation) | n/a | n/a |
| `quickbooks_list_payments` | `listPayments(client, options?)` | Query API: Payment rows since date | Step 5 (reconciliation pass) | n/a | n/a |
| `quickbooks_write_payment_received` | `writePaymentReceived(client, payment)` | POST /payment — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |

All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (verified 2026-06-01 Codex F-R2 closure — `quickbooks_oauth` registered as green; `accounting_reconciliation_write` already present shared with @ifos/xero).

### Internal helpers (NOT bus-routed capabilities)

Exposed by `src/index.ts` for consumer convenience + testing, but NOT declared in `tools.yaml`:

| Function | Purpose |
|---|---|
| `QbClient` (class) | Transport — constructed once by cycle.sh Step 1; per-realm URL construction (production vs sandbox) |
| `loadTokens(config)` / `saveTokens(config, t)` | Token-file I/O — called by `refreshTokens`; surfaced for test setup and operator consent-bootstrap |
| `shouldRefresh(tokens, now?, window?)` | Pure predicate — `true` when the access_token expires within `safety_window_ms` (default 5 min) |
| `refreshTokenNearExpiry(tokens, now?, danger?)` | Pure predicate — `true` when the **refresh** token expires within the 7-day re-consent danger window (QB ~100-day TTL); operator alerting hook |
| `rateCheck(realm_id, now?)` | Returns `RateState` — exposes the **soft-backoff signal** (`shouldBackoff: true` at 80% of the minute bucket); consuming cycle.sh is responsible for honouring it (see §Rate limits) |
| `rateConsume(realm_id, now?)` | Consumes a slot; returns false at the hard 100% gate |
| `resetRateLimit(realm_id?)` | Test/diagnostic reset |
| `_resetInflightForTest()` | Clears in-flight OAuth-refresh dedup map; for tests only |
| `QbCache` (class) | Disk cache — default TTL 5min |

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

This connector tracks the minute bucket per `src/rate-limit.ts`. **Hard gate at 100%** (`consume()` returns false → `QbRateLimitError`). **Soft signal at 80%** (400/minute) is read-only and exposed via `rateCheck()` — `RateState.shouldBackoff === true` with `reason: "minute-soft"`. The consuming agent layer (Cash Conductor cycle.sh) is responsible for honouring the soft signal (e.g. pausing batch operations); the connector does not silently throttle — the contract is "callers query soft, connector enforces hard". `tests/rate-limit.test.ts` exercises both thresholds.

State is in-process and per-realm — a multi-realm runtime that holds many `QbClient` instances in one process still gets correct isolation.

**ESC contract on bucket exhaustion** (consumer-emitted via `agents/_shared/hook-helpers.sh`):

| Failure | Surfaces as | ESC code (escalation-codes.md) | Payload contract |
|---|---|---|---|
| Local hard-gate (100%) reached | `QbRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "quickbooks", retry_after_seconds: null, consecutive_429s: 0}` |
| Upstream 429 from QB API | `QbRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "quickbooks", retry_after_seconds: <N>, consecutive_429s: <N>}` |

Both surface as the same ESC because from the operator's perspective they're the same operational signal (QB traffic is being throttled). The payload distinguishes local pre-emptive (`retry_after_seconds: null`) from upstream-issued.

---

## Retry policy

| Capability | Method | Max retries | Backoff | On exhaustion |
|---|---|---|---|---|
| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` / `QbRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
| `writePaymentReceived` | POST | **0** | n/a (writes never auto-retry) | `QbValidationError` (400) / `QbError` (5xx) → `ESC_ACCOUNTING_WRITE_FAIL` (warn; operator; consumer-emitted; payload includes `provider: "quickbooks"`, `endpoint: "/payment"`, `status_code`, `error_body_preview`) |
| `refreshTokens` | POST | **0** | n/a | `QbAuthError` → `ESC_ACCOUNTING_AUTH` (blocking; consumer-emitted; caller may re-attempt with fresh credentials per Bootstrap §) |
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
```

**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.

**Live tests are deferred** to the first commercial QB sandbox signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal per review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold lands in the same commit as the first sandbox credentials.

Test counts:
- `tests/scaffold.test.ts`: 5 (public surface, exports, error hierarchy)
- `tests/rate-limit.test.ts`: 5 (initial state, soft 400, hard 500, per-realm isolation, etc.)
- `tests/auth.test.ts`: 7 (load missing, round-trip, shouldRefresh, refreshTokenNearExpiry, refresh success, 401 + no-token-leak, concurrent dedup)
- `tests/capabilities.test.ts`: 9 (list/get invoice happy + 404, list/write payment happy + 400, **listOpenInvoices 429 retry-exhaust, listPayments 500 retry-exhaust, 401-forces-refresh-then-retry** — all 3 added per Codex F-R1/F-R2)

**Total: 26 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).

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

Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) **landed at the scaffold layer 2026-06-01** (commits 6ab59d8 + 5ab2f0f) with SKELETON TODO(W7-8) markers throughout. The W7-8 build slice replaces the TODOs with live impl; this connector is the accounting substrate it consumes (alongside @ifos/xero — Sage deferred per Cash Conductor §9 Q8). Per Cash Conductor agent.md §8, production-readiness still gates on Hire #1 + accounting commercial signups.

---

## Boundary checks

Per `review-mcp-connector.md` §8:
- ✓ No Composio / AgentMail references
- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)
- ✓ No hardcoded tenant slugs in `src/` (test fixtures only — `fixture-realm`, `test-realm-rate-limit`)

---

*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*

--- FILE: packages/mcp-connectors/quickbooks/src/auth.ts ---

// QuickBooks Online OAuth 2.0 token refresh + atomic disk persistence + concurrent-call dedup.
//
// Per review-mcp-connector §2 (OAuth refresh idempotency):
//   - Concurrent refresh() calls converge on ONE token rotation, not N
//     (in-process Promise lock per realm_id).
//   - Atomic write to token_file_path via .tmp + rename — no torn file
//     visible to a parallel reader even mid-refresh.
//   - Tokens NEVER logged or thrown into error messages (review-mcp-connector §5).
//
// QuickBooks vs Xero refresh diff:
//   - Endpoint: https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer
//     (vs Xero's https://identity.xero.com/connect/token)
//   - Both use Basic auth (Base64(client_id:client_secret)) + grant_type=refresh_token
//   - Both rotate the refresh_token on every refresh
//   - QB returns BOTH `expires_in` (access; ~3600s) AND `x_refresh_token_expires_in`
//     (refresh; ~8640000s ~ 100 days) — Xero doesn't return refresh expiry
//   - QB tokens are per-realm (each connected company has its own bundle)
//
// Token file shape (JSON):
//   { "access_token": "...", "refresh_token": "...", "expires_at_ms": N,
//     "refresh_token_expires_at_ms": N, "scope": "...", "token_type": "Bearer" }

import { promises as fs } from "node:fs";
import { QbAuthError } from "./errors.js";
import type { QbOAuthConfig, QbTokens } from "./types.js";

const QB_TOKEN_ENDPOINT = "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer";

const inflight: Map<string, Promise<QbTokens>> = new Map();

/** Read token file from disk; returns null if missing/malformed. */
export async function loadTokens(
  config: QbOAuthConfig,
): Promise<QbTokens | null> {
  let raw: string;
  try {
    raw = await fs.readFile(config.token_file_path, "utf8");
  } catch {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as QbTokens;
    if (
      typeof parsed.access_token !== "string" ||
      typeof parsed.refresh_token !== "string" ||
      typeof parsed.expires_at_ms !== "number" ||
      typeof parsed.refresh_token_expires_at_ms !== "number"
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
  config: QbOAuthConfig,
  tokens: QbTokens,
): Promise<void> {
  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
  await fs.rename(tmpPath, config.token_file_path);
}

/**
 * Returns true if access token expires within the next `safety_window_ms` (default 5 min).
 */
export function shouldRefresh(
  tokens: QbTokens,
  now: () => number = Date.now,
  safety_window_ms = 5 * 60 * 1000,
): boolean {
  return tokens.expires_at_ms - now() < safety_window_ms;
}

/**
 * Returns true if refresh token is within the danger window (default 7 days from expiry).
 * QB refresh tokens are ~100-day TTL; if you cross the danger window without using them,
 * you'll need to re-do the consent dance from scratch.
 */
export function refreshTokenNearExpiry(
  tokens: QbTokens,
  now: () => number = Date.now,
  danger_window_ms = 7 * 24 * 60 * 60 * 1000,
): boolean {
  return tokens.refresh_token_expires_at_ms - now() < danger_window_ms;
}

/**
 * Refresh OAuth tokens. Concurrent-safe: if a refresh is in flight for the
 * same realm, return the in-flight Promise (one network call, one file write).
 *
 * Throws QbAuthError on 4xx (credentials rejected); does NOT retry.
 */
export async function refreshTokens(
  config: QbOAuthConfig,
  current_tokens: QbTokens,
  fetchFn: typeof fetch = fetch,
): Promise<QbTokens> {
  const lockKey = config.realm_id;
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

      const res = await fetchFn(QB_TOKEN_ENDPOINT, {
        method: "POST",
        headers: {
          Authorization: `Basic ${basic}`,
          "Content-Type": "application/x-www-form-urlencoded",
          Accept: "application/json",
        },
        body,
      });

      if (!res.ok) {
        // Never include the response body verbatim — QB may echo the
        // (now-invalid) refresh_token in error responses.
        throw new QbAuthError(
          `QuickBooks OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
          res.status,
        );
      }

      const data = (await res.json()) as {
        access_token: string;
        refresh_token: string;
        expires_in: number;
        x_refresh_token_expires_in: number;
        scope?: string;
        token_type: string;
      };

      const now = Date.now();
      const new_tokens: QbTokens = {
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at_ms: now + data.expires_in * 1000,
        refresh_token_expires_at_ms: now + data.x_refresh_token_expires_in * 1000,
        scope: data.scope ?? "",
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

--- FILE: packages/mcp-connectors/quickbooks/src/cache.ts ---

// Disk cache for QuickBooks responses. Default TTL 5 min (invoices change often;
// shorter than Companies House 7-day cache). Pattern matches @ifos/companies-house
// CHCache + @ifos/xero XeroCache; intentionally not shared to keep package
// boundaries clean.

import { createHash } from "node:crypto";
import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

interface CacheEntry<T> {
  cachedAt: number;
  ttlMs: number;
  value: T;
}

export class QbCache {
  constructor(private readonly dir: string) {}

  static fromEnv(): QbCache {
    const dir =
      process.env.IFOS_QB_CACHE_DIR ??
      join(homedir(), ".ifos-cache", "quickbooks");
    return new QbCache(dir);
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

--- FILE: packages/mcp-connectors/quickbooks/src/client.ts ---

// QuickBooks Online HTTP client — wraps fetch with: OAuth token attach,
// rate-limit budget, 429 retry-after, 5xx exponential backoff (max 2 retries),
// 4xx surface as typed errors. No retry on POST writes (caller decides).
//
// Per-realm base URL: production vs sandbox switches via config.environment.

import {
  QbAuthError,
  QbError,
  QbNotFoundError,
  QbRateLimitError,
  QbValidationError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import { loadTokens, refreshTokens, shouldRefresh } from "./auth.js";
import type { QbClientOptions, QbTokens } from "./types.js";

export const QB_BASE_URL_PRODUCTION = "https://quickbooks.api.intuit.com";
export const QB_BASE_URL_SANDBOX = "https://sandbox-quickbooks.api.intuit.com";
export const DEFAULT_TIMEOUT_MS = 15_000;

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "DELETE";
  query?: Record<string, string>;
  body?: unknown;
  /** Override max retries for this call (default 2 for GET, 0 for writes). */
  max_retries?: number;
  signal?: AbortSignal;
}

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

function backoff(attempt: number): number {
  const base = 250 * 2 ** attempt;
  return Math.floor(Math.random() * base);
}

export class QbClient {
  private readonly opts: QbClientOptions;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private readonly base_url: string;
  private current_tokens: QbTokens | null = null;

  constructor(opts: QbClientOptions) {
    this.opts = opts;
    this.fetchFn = opts.fetchFn ?? fetch;
    this.now = opts.now ?? Date.now;
    this.base_url =
      opts.config.environment === "sandbox"
        ? QB_BASE_URL_SANDBOX
        : QB_BASE_URL_PRODUCTION;
  }

  /** Returns a valid access_token, refreshing eagerly if within the safety window. */
  async getValidAccessToken(): Promise<string> {
    if (!this.current_tokens) {
      this.current_tokens = await loadTokens(this.opts.config);
      if (!this.current_tokens) {
        throw new QbAuthError(
          "No QuickBooks tokens on disk; consent flow required to bootstrap " +
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

    // QB v3 API path always includes /v3/company/<realmId>/...
    const url = new URL(
      `${this.base_url}/v3/company/${this.opts.config.realm_id}${path}`,
    );
    if (options.query) {
      for (const [k, v] of Object.entries(options.query)) {
        url.searchParams.set(k, v);
      }
    }
    // QB wants minorversion query param for forward-compat
    if (!url.searchParams.has("minorversion")) {
      url.searchParams.set("minorversion", "73");
    }

    let last_error: unknown = null;
    for (let attempt = 0; attempt <= max_retries; attempt++) {
      const allowed = consume(this.opts.config.realm_id, this.now);
      if (!allowed) {
        throw new QbRateLimitError(
          `QuickBooks rate-limit budget exhausted (realm=${this.opts.config.realm_id}); ` +
            `local bucket prevents call to avoid upstream 429`,
        );
      }

      const access_token = await this.getValidAccessToken();
      const headers: Record<string, string> = {
        Authorization: `Bearer ${access_token}`,
        Accept: "application/json",
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
        last_error = e;
        if (attempt < max_retries) {
          await sleep(backoff(attempt));
          continue;
        }
        throw new QbError(
          `QuickBooks network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
        );
      }

      if (res.ok) {
        return (await res.json()) as T;
      }

      // 401: server invalidated the access_token — force an explicit refresh
      // BEFORE the next iteration. Per Codex F-R2 issue #1 (qb): nulling the
      // cached token alone is insufficient — getValidAccessToken() will reload
      // the SAME stale token from disk if shouldRefresh() says it's not near
      // expiry. Rotate it now; persist the new bundle; let the next iteration
      // pick up the rotated token.
      if (res.status === 401 && attempt < max_retries) {
        if (this.current_tokens) {
          // Throws QbAuthError on refresh failure → propagates correctly.
          this.current_tokens = await refreshTokens(
            this.opts.config,
            this.current_tokens,
            this.fetchFn,
          );
        }
        await sleep(backoff(attempt));
        continue;
      }
      // 401 after retries exhausted: AUTH-typed error so consumer branches
      // correctly to ESC_ACCOUNTING_AUTH.
      if (res.status === 401) {
        throw new QbAuthError(
          `QuickBooks ${method} ${path} returned 401 after ${attempt + 1} attempt(s) including forced refresh`,
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
        throw new QbRateLimitError(
          `QuickBooks returned 429 after ${attempt + 1} attempt(s)`,
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
        throw new QbNotFoundError(`QuickBooks 404 on ${method} ${path}`);
      }
      if (res.status === 400) {
        throw new QbValidationError(
          `QuickBooks rejected ${method} ${path} (HTTP 400)`,
          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
        );
      }
      throw new QbError(
        `QuickBooks ${method} ${path} failed (HTTP ${res.status})`,
        res.status,
      );
    }
    throw new QbError(
      `QuickBooks ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
    );
  }
}

--- FILE: packages/mcp-connectors/quickbooks/src/errors.ts ---

// QuickBooks error hierarchy. Errors NEVER include credential values; only key
// names + status codes + safe metadata. Per review-mcp-connector §5
// (zero secret interpolation in error messages).

export class QbError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
  ) {
    super(message);
    this.name = "QbError";
  }
}

/** OAuth refresh failed: client_id/secret rejected, refresh_token invalid, or token-file write/read failed. */
export class QbAuthError extends QbError {
  constructor(message: string, status?: number) {
    super(message, status, false);
    this.name = "QbAuthError";
  }
}

/** Rate-limit budget exhausted (500/min per realmId per Intuit docs). */
export class QbRateLimitError extends QbError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "QbRateLimitError";
  }
}

/** Invoice/payment/customer not found. */
export class QbNotFoundError extends QbError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "QbNotFoundError";
  }
}

/** QuickBooks rejected the write payload (400 + Fault.type=ValidationFault). */
export class QbValidationError extends QbError {
  constructor(
    message: string,
    public readonly providerErrors: string[] = [],
  ) {
    super(message, 400, false);
    this.name = "QbValidationError";
  }
}

--- FILE: packages/mcp-connectors/quickbooks/src/index.ts ---

// @ifos/quickbooks — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
//       on agents/recruitment/cash-conductor/tools.yaml AND (for state-changing
//       capabilities) has an action_type entry in agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check).
//
// Reference implementation: @ifos/xero. Pattern parity intentional —
// review-mcp-connector §1 requires capability surface set-equality.

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §quickbooks)
// ─────────────────────────────────────────────────────────────────────────

// quickbooks_oauth (action_type: quickbooks_oauth, green tier per autosend-policy.yaml)
export { refreshTokens } from "./auth.js";
// quickbooks_list_open_invoices (read-only) + quickbooks_get_invoice (read-only)
export { listOpenInvoices, getInvoice } from "./invoices.js";
// quickbooks_list_payments (read-only) + quickbooks_write_payment_received
// (action_type: accounting_reconciliation_write, yellow tier per autosend-policy.yaml)
export { listPayments, writePaymentReceived } from "./payments.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once by cycle.sh Step 1; per-realm URL construction
export {
  QbClient,
  QB_BASE_URL_PRODUCTION,
  QB_BASE_URL_SANDBOX,
  DEFAULT_TIMEOUT_MS,
} from "./client.js";
// Token-file I/O + pure predicates (shouldRefresh for access; refreshTokenNearExpiry
// for the 7-day re-consent danger window — operator alerting hook)
export {
  loadTokens,
  saveTokens,
  shouldRefresh,
  refreshTokenNearExpiry,
} from "./auth.js";
// Disk cache
export { QbCache } from "./cache.js";
// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
// consumer responsible for honouring shouldBackoff at the 80% soft threshold;
// hard 100% gate is enforced inside rateConsume()).
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
// Test/diagnostic
export { _resetInflightForTest } from "./auth.js";
// Error hierarchy
export {
  QbError,
  QbAuthError,
  QbRateLimitError,
  QbNotFoundError,
  QbValidationError,
} from "./errors.js";
export type {
  QbTokens,
  QbOAuthConfig,
  QbInvoice,
  QbQueryResponse,
  QbPayment,
  QbPaymentWriteRequest,
  QbClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";

--- FILE: packages/mcp-connectors/quickbooks/src/invoices.ts ---

// QuickBooks Invoices capability surface — read-only (list + get).
// Consumed by Cash Conductor §4 Step 4 (invoice register ingest).
//
// QB uses the Query API for list operations:
//   GET /v3/company/<realmId>/query?query=SELECT * FROM Invoice WHERE Balance > '0'
// Single-entity reads use the entity endpoint:
//   GET /v3/company/<realmId>/invoice/<id>

import type { QbClient } from "./client.js";
import { QbCache } from "./cache.js";
import type { QbInvoice, QbQueryResponse } from "./types.js";

const INVOICE_CACHE_TTL_MS = 5 * 60 * 1000;

export interface ListOpenInvoicesOptions {
  /** ISO yyyy-MM-dd; filter to invoices issued on/after this date. */
  issued_since?: string;
  /** 1-indexed start position (QB pagination). 1000 max per page. */
  start_position?: number;
  max_results?: number;
  no_cache?: boolean;
  cache?: QbCache;
}

/**
 * List open invoices (Balance > 0).
 * QB pagination uses startposition + maxresults; default 100 per call.
 */
export async function listOpenInvoices(
  client: QbClient,
  options: ListOpenInvoicesOptions = {},
): Promise<QbInvoice[]> {
  const cache = options.cache ?? QbCache.fromEnv();
  const start = options.start_position ?? 1;
  const max = options.max_results ?? 100;
  const key = `invoices:open:start=${start}:max=${max}:since=${options.issued_since ?? "all"}`;

  if (!options.no_cache) {
    const hit = await cache.get<QbInvoice[]>(key);
    if (hit !== null) return hit;
  }

  // QB query syntax: SQL-like, with single-quote string literals
  let query = "SELECT * FROM Invoice WHERE Balance > '0'";
  if (options.issued_since) {
    query += ` AND TxnDate >= '${options.issued_since}'`;
  }
  query += ` STARTPOSITION ${start} MAXRESULTS ${max}`;

  const res = await client.request<QbQueryResponse<"Invoice", QbInvoice>>(
    "/query",
    { query: { query } },
  );
  const invoices = res.QueryResponse.Invoice ?? [];
  await cache.set(key, invoices, INVOICE_CACHE_TTL_MS);
  return invoices;
}

/** Get a single invoice by QB Id (numeric string). */
export async function getInvoice(
  client: QbClient,
  invoiceId: string,
  options: { cache?: QbCache; no_cache?: boolean } = {},
): Promise<QbInvoice | null> {
  const cache = options.cache ?? QbCache.fromEnv();
  const key = `invoice:${invoiceId}`;
  if (!options.no_cache) {
    const hit = await cache.get<QbInvoice>(key);
    if (hit !== null) return hit;
  }
  // Single-entity read returns { Invoice: {...} } (not wrapped in QueryResponse)
  const res = await client.request<{ Invoice: QbInvoice }>(
    `/invoice/${encodeURIComponent(invoiceId)}`,
  );
  const inv = res.Invoice ?? null;
  if (inv) await cache.set(key, inv, INVOICE_CACHE_TTL_MS);
  return inv;
}

--- FILE: packages/mcp-connectors/quickbooks/src/payments.ts ---

// QuickBooks Payments capability surface — read + write (write is the only
// state-changing capability in this connector). Consumed by Cash Conductor
// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
// yellow tier per autosend-policy.yaml).

import type { QbClient } from "./client.js";
import { QbCache } from "./cache.js";
import type {
  QbPayment,
  QbPaymentWriteRequest,
  QbQueryResponse,
} from "./types.js";

const PAYMENTS_CACHE_TTL_MS = 5 * 60 * 1000;

export interface ListPaymentsOptions {
  /** ISO yyyy-MM-dd; payments on/after this date. */
  since?: string;
  start_position?: number;
  max_results?: number;
  no_cache?: boolean;
  cache?: QbCache;
}

/** List payments. QB doesn't separate received vs sent at the type level — caller filters via TotalAmt sign + LinkedTxn presence if needed. */
export async function listPayments(
  client: QbClient,
  options: ListPaymentsOptions = {},
): Promise<QbPayment[]> {
  const cache = options.cache ?? QbCache.fromEnv();
  const start = options.start_position ?? 1;
  const max = options.max_results ?? 100;
  const key = `payments:start=${start}:max=${max}:since=${options.since ?? "all"}`;

  if (!options.no_cache) {
    const hit = await cache.get<QbPayment[]>(key);
    if (hit !== null) return hit;
  }

  let query = "SELECT * FROM Payment";
  if (options.since) {
    query += ` WHERE TxnDate >= '${options.since}'`;
  }
  query += ` STARTPOSITION ${start} MAXRESULTS ${max}`;

  const res = await client.request<QbQueryResponse<"Payment", QbPayment>>(
    "/query",
    { query: { query } },
  );
  const payments = res.QueryResponse.Payment ?? [];
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
  client: QbClient,
  payment: QbPaymentWriteRequest,
): Promise<QbPayment> {
  // QB POST /payment returns { Payment: {...} } (not wrapped in QueryResponse)
  const res = await client.request<{ Payment: QbPayment }>("/payment", {
    method: "POST",
    body: payment,
    max_retries: 0,
  });
  if (!res.Payment) {
    throw new Error(
      "QuickBooks POST /payment succeeded but response contained no Payment record",
    );
  }
  return res.Payment;
}

--- FILE: packages/mcp-connectors/quickbooks/src/rate-limit.ts ---

// Rate limiter for QuickBooks Online. Per Intuit published limits
// (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):
//   - 500 calls / 60-second window per app per realmId (minute bucket)
//   - 10 calls / second concurrent throttle (not enforced here — single-process
//     Cash Conductor cycle.sh is serial)
//
// No published daily cap; only the per-minute throttle. Pre-emptive backoff at
// 80% of the minute bucket. Per-realm state (multi-realm safe).

const MINUTE_MS = 60 * 1000;
const MINUTE_HARD = 500;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 400

const minuteTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  realm_id: string;
  minute_used: number;
  minute_remaining: number;
  shouldBackoff: boolean;
  reason: "ok" | "minute-soft" | "minute-hard";
}

function pruneMinute(arr: number[] | undefined, now: number): number[] {
  if (!arr) return [];
  return arr.filter((ts) => now - ts < MINUTE_MS);
}

export function check(
  realm_id: string,
  now: () => number = Date.now,
): RateState {
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(realm_id), t);
  minuteTimestamps.set(realm_id, minute);

  const minute_used = minute.length;
  let reason: RateState["reason"] = "ok";
  let shouldBackoff = false;

  if (minute_used >= MINUTE_HARD) {
    reason = "minute-hard";
    shouldBackoff = true;
  } else if (minute_used >= MINUTE_SOFT) {
    reason = "minute-soft";
    shouldBackoff = true;
  }

  return {
    realm_id,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  realm_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(realm_id, now);
  if (state.reason === "minute-hard") return false;
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(realm_id), t);
  minute.push(t);
  minuteTimestamps.set(realm_id, minute);
  return true;
}

export function reset(realm_id?: string): void {
  if (realm_id !== undefined) {
    minuteTimestamps.delete(realm_id);
  } else {
    minuteTimestamps.clear();
  }
}

--- FILE: packages/mcp-connectors/quickbooks/src/types.ts ---

// QuickBooks Online API types — subset of the v3 Accounting API surface
// IFOS Cash Conductor consumes.
// Reference: https://developer.intuit.com/app/developer/qbo/docs/api/accounting/most-commonly-used/invoice
//
// QuickBooks is per-realm: each connected company has a unique realmId, and
// the token bundle + base URL are realm-scoped. This is the key structural
// difference from Xero (which uses one tenant_id header per call).

export interface QbTokens {
  access_token: string;
  refresh_token: string;
  /** Unix epoch milliseconds when the access_token expires (typically ~1h after issue). */
  expires_at_ms: number;
  /** Refresh token expiry (QB rolls refresh tokens; ~100 days from issue). */
  refresh_token_expires_at_ms: number;
  /** Comma-separated scopes granted. */
  scope: string;
  /** Always 'Bearer' in v3. */
  token_type: string;
}

export interface QbOAuthConfig {
  client_id: string;
  client_secret: string;
  /** QuickBooks "realmId" (per-company identifier; unique per connected QB Online company). */
  realm_id: string;
  /** Production vs sandbox base URL switch. */
  environment: "production" | "sandbox";
  /** Token file on disk; atomic-rename writes go here. */
  token_file_path: string;
}

export interface QbInvoice {
  Id: string;
  DocNumber: string | null;
  TxnDate: string; // yyyy-MM-dd
  DueDate: string;
  CurrencyRef: { value: string; name?: string };
  TotalAmt: number;
  Balance: number;
  CustomerRef: { value: string; name?: string };
  CustomerMemo: { value: string } | null;
  /** Document line items omitted at v0; Cash Conductor doesn't need them. */
  MetaData: {
    CreateTime: string;
    LastUpdatedTime: string;
  };
}

export interface QbQueryResponse<TEntity extends string, TBody> {
  QueryResponse: { [K in TEntity]?: TBody[] } & {
    startPosition?: number;
    maxResults?: number;
    totalCount?: number;
  };
  time: string;
}

export interface QbPayment {
  Id: string;
  TxnDate: string;
  TotalAmt: number;
  CustomerRef: { value: string; name?: string };
  PaymentRefNum: string | null;
  /** Lines map each payment to one or more invoices (Cash Conductor uses single-invoice payments). */
  Line: Array<{
    Amount: number;
    LinkedTxn: Array<{ TxnId: string; TxnType: "Invoice" }>;
  }>;
  MetaData: {
    CreateTime: string;
    LastUpdatedTime: string;
  };
}

export interface QbPaymentWriteRequest {
  /** Single-invoice payment shape. Cash Conductor doesn't write multi-invoice payments at v0. */
  CustomerRef: { value: string };
  TotalAmt: number;
  TxnDate?: string;
  PaymentRefNum?: string;
  Line: Array<{
    Amount: number;
    LinkedTxn: Array<{ TxnId: string; TxnType: "Invoice" }>;
  }>;
}

export interface QbClientOptions {
  config: QbOAuthConfig;
  /** Override fetch (testing). */
  fetchFn?: typeof fetch;
  /** Override now() (testing). */
  now?: () => number;
}

--- FILE: packages/mcp-connectors/quickbooks/tests/auth.test.ts ---

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
  refreshTokenNearExpiry,
  saveTokens,
  shouldRefresh,
} from "../src/auth.js";
import { QbAuthError } from "../src/errors.js";
import type { QbOAuthConfig, QbTokens } from "../src/types.js";

const FIXTURE_TOKENS: QbTokens = {
  access_token: "fake-access-old",
  refresh_token: "fake-refresh-old",
  expires_at_ms: Date.now() + 3600_000,
  refresh_token_expires_at_ms: Date.now() + 100 * 24 * 60 * 60 * 1000,
  scope: "com.intuit.quickbooks.accounting",
  token_type: "Bearer",
};

const REFRESH_OK_BODY = JSON.stringify({
  access_token: "fake-new-access-abcdef123456",
  refresh_token: "fake-new-refresh-zyxwvu987654",
  expires_in: 3600,
  x_refresh_token_expires_in: 100 * 24 * 60 * 60,
  scope: "com.intuit.quickbooks.accounting",
  token_type: "Bearer",
});

function makeConfig(token_file: string, realm_id = "test-realm-id"): QbOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    realm_id,
    environment: "sandbox",
    token_file_path: token_file,
  };
}

let token_file: string;

beforeEach(() => {
  token_file = join(
    tmpdir(),
    `qb-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  _resetInflightForTest();
});
afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("quickbooks auth", () => {
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
    const expiringSoon: QbTokens = {
      ...FIXTURE_TOKENS,
      expires_at_ms: Date.now() + 60_000,
    };
    expect(shouldRefresh(expiringSoon)).toBe(true);
  });

  it("refreshTokenNearExpiry: true when refresh token within 7-day danger window", () => {
    const danger: QbTokens = {
      ...FIXTURE_TOKENS,
      refresh_token_expires_at_ms: Date.now() + 24 * 60 * 60 * 1000,
    };
    expect(refreshTokenNearExpiry(danger)).toBe(true);
    expect(refreshTokenNearExpiry(FIXTURE_TOKENS)).toBe(false);
  });

  it("refreshTokens: success writes new tokens atomically + returns them", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(REFRESH_OK_BODY, {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });

    const newT = await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    expect(newT.access_token).toBe("fake-new-access-abcdef123456");
    expect(newT.refresh_token).toBe("fake-new-refresh-zyxwvu987654");
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(newT.access_token);
    expect(onDisk?.refresh_token_expires_at_ms).toBeGreaterThan(Date.now());
  });

  it("refreshTokens: 401 surfaces as QbAuthError; does NOT include token in error", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(
        JSON.stringify({ error: "invalid_grant" }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );

    await expect(
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
    ).rejects.toBeInstanceOf(QbAuthError);
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
      await new Promise((r) => setTimeout(r, 25));
      return new Response(REFRESH_OK_BODY, {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    };

    const [a, b, c] = await Promise.all([
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
    ]);
    expect(calls).toBe(1);
    expect(a.access_token).toBe(b.access_token);
    expect(b.access_token).toBe(c.access_token);
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(a.access_token);
  });
});

--- FILE: packages/mcp-connectors/quickbooks/tests/capabilities.test.ts ---

// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
// path + ≥1 error path per capability).

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { QbClient } from "../src/client.js";
import { QbCache } from "../src/cache.js";
import { saveTokens, _resetInflightForTest } from "../src/auth.js";
import { reset as resetRateLimit } from "../src/rate-limit.js";
import { listOpenInvoices, getInvoice } from "../src/invoices.js";
import { listPayments, writePaymentReceived } from "../src/payments.js";
import {
  QbError,
  QbNotFoundError,
  QbRateLimitError,
  QbValidationError,
} from "../src/errors.js";
import type {
  QbOAuthConfig,
  QbTokens,
  QbPaymentWriteRequest,
} from "../src/types.js";

import INVOICES_PAGE_1 from "../fixtures/invoices-page-1.json" with { type: "json" };
import PAYMENTS_RECENT from "../fixtures/payments-recent.json" with { type: "json" };
import PAYMENT_WRITE_OK from "../fixtures/payment-write-ok.json" with { type: "json" };

const FIXTURE_TOKENS: QbTokens = {
  access_token: "fake-access",
  refresh_token: "fake-refresh",
  expires_at_ms: Date.now() + 3600_000,
  refresh_token_expires_at_ms: Date.now() + 100 * 24 * 60 * 60 * 1000,
  scope: "com.intuit.quickbooks.accounting",
  token_type: "Bearer",
};

let token_file: string;
let cache_dir: string;
let cache: QbCache;

function makeConfig(): QbOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    realm_id: "fixture-realm",
    environment: "sandbox",
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
  token_file = join(
    tmpdir(),
    `qb-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  cache_dir = join(
    tmpdir(),
    `qb-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`,
  );
  cache = new QbCache(cache_dir);
  _resetInflightForTest();
  resetRateLimit();
  await saveTokens(makeConfig(), FIXTURE_TOKENS);
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
});

describe("quickbooks capabilities — invoices", () => {
  it("listOpenInvoices: returns parsed array from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const invoices = await listOpenInvoices(client, { cache, no_cache: true });
    expect(invoices.length).toBe(2);
    expect(invoices[0]?.Id).toBe("1001");
    expect(invoices[0]?.Balance).toBe(1500);
    expect(invoices[1]?.CustomerRef.name).toBe("Beta Search Partners");
  });

  it("getInvoice: returns single invoice when present (single-entity endpoint shape)", async () => {
    const fakeFetch: typeof fetch = async () =>
      makeOkResponse({ Invoice: INVOICES_PAGE_1.QueryResponse.Invoice[0] });
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const inv = await getInvoice(client, "1001", { cache, no_cache: true });
    expect(inv).not.toBeNull();
    expect(inv?.DocNumber).toBe("INV-1001");
  });

  it("getInvoice: 404 surfaces as QbNotFoundError", async () => {
    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      getInvoice(client, "99999", { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(QbNotFoundError);
  });

  // Error-path coverage for listOpenInvoices (per review-mcp-connector §6 +
  // Codex F-R1 issue #5: every capability needs ≥1 happy + ≥1 error fixture).
  it("listOpenInvoices: persistent 429 surfaces as QbRateLimitError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("", {
        status: 429,
        headers: { "Retry-After": "0" }, // 0s = no wait; just exhausts retries fast
      });
    };
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      listOpenInvoices(client, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(QbRateLimitError);
    expect(calls).toBeGreaterThanOrEqual(2); // initial + ≥1 retry per max_retries=2 default
  });
});

describe("quickbooks capabilities — payments", () => {
  it("listPayments: returns parsed array from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENTS_RECENT);
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payments = await listPayments(client, { cache, no_cache: true });
    expect(payments.length).toBe(1);
    expect(payments[0]?.TotalAmt).toBe(2000);
    expect(payments[0]?.Line[0]?.LinkedTxn[0]?.TxnId).toBe("1002");
  });

  it("writePaymentReceived: success path returns created payment", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENT_WRITE_OK);
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payload: QbPaymentWriteRequest = {
      CustomerRef: { value: "200" },
      TotalAmt: 1500.0,
      TxnDate: "2026-05-22",
      PaymentRefNum: "BACS-2026-05-22-002",
      Line: [
        {
          Amount: 1500.0,
          LinkedTxn: [{ TxnId: "1001", TxnType: "Invoice" }],
        },
      ],
    };
    const created = await writePaymentReceived(client, payload);
    expect(created.Id).toBe("p-502");
    expect(created.TotalAmt).toBe(1500);
  });

  it("writePaymentReceived: 400 surfaces as QbValidationError (no retry)", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("Invoice Id does not exist", { status: 400 });
    };
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payload: QbPaymentWriteRequest = {
      CustomerRef: { value: "0" },
      TotalAmt: 100.0,
      Line: [{ Amount: 100.0, LinkedTxn: [{ TxnId: "0", TxnType: "Invoice" }] }],
    };
    await expect(writePaymentReceived(client, payload)).rejects.toBeInstanceOf(
      QbValidationError,
    );
    expect(calls).toBe(1); // write was NOT retried
  });

  // Error-path coverage for listPayments (per review-mcp-connector §6 +
  // Codex F-R1 issue #5): GET retries 5xx exponentially; after retries
  // exhausted the typed error is QbError (NOT QbRateLimitError).
  it("listPayments: persistent 500 surfaces as QbError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("QuickBooks internal error", { status: 500 });
    };
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      listPayments(client, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(QbError);
    expect(calls).toBeGreaterThanOrEqual(2); // initial + retries per max_retries=2
  });

  // 401-forces-refresh: per Codex F-R2 issue #1, a 401 on a GET MUST trigger
  // an explicit refreshTokens() call before retrying — NOT just null the cache
  // (which would reload the same stale token from disk if shouldRefresh()
  // returns false). This test would FAIL against the pre-fix code.
  it("401 on GET forces explicit token refresh + retry uses new access_token", async () => {
    let getCalls = 0;
    let refreshCalls = 0;
    let observedSecondAuth: string | null = null;

    const fakeFetch: typeof fetch = async (input, init) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.includes("oauth.platform.intuit.com/oauth2/v1/tokens/bearer")) {
        refreshCalls += 1;
        return new Response(
          JSON.stringify({
            access_token: "rotated-access-token-after-401",
            refresh_token: "rotated-refresh-token",
            expires_in: 3600,
            x_refresh_token_expires_in: 100 * 24 * 60 * 60,
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

    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const invoices = await listOpenInvoices(client, { cache, no_cache: true });

    expect(invoices.length).toBeGreaterThan(0);
    expect(getCalls).toBe(2); // initial 401 + retry
    expect(refreshCalls).toBe(1); // forced refresh between attempts
    expect(observedSecondAuth).toBe("Bearer rotated-access-token-after-401");
  });
});

--- FILE: packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts ---

// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
// MUST exist). Verifies soft (80%) and hard (100%) thresholds against
// the 500/min Intuit bucket.

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

const REALM = "test-realm-rate-limit";

describe("quickbooks rate-limit", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check(REALM);
    expect(s.minute_used).toBe(0);
    expect(s.minute_remaining).toBe(500);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute soft threshold (400)", () => {
    for (let i = 0; i < 399; i++) consume(REALM);
    const s = check(REALM);
    expect(s.minute_used).toBe(399);
    expect(s.shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 400", () => {
    for (let i = 0; i < 400; i++) consume(REALM);
    const s = check(REALM);
    expect(s.minute_used).toBe(400);
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 500 (consume returns false)", () => {
    for (let i = 0; i < 500; i++) consume(REALM);
    const s = check(REALM);
    expect(s.minute_used).toBe(500);
    expect(s.reason).toBe("minute-hard");
    expect(consume(REALM)).toBe(false);
  });

  it("isolates buckets per realm_id", () => {
    for (let i = 0; i < 450; i++) consume("realm-A");
    expect(check("realm-A").shouldBackoff).toBe(true);
    expect(check("realm-B").shouldBackoff).toBe(false);
    expect(check("realm-B").minute_used).toBe(0);
  });
});

--- FILE: packages/mcp-connectors/quickbooks/tests/scaffold.test.ts ---

// Package public surface smoke tests. Per review-mcp-connector §1
// (capabilities surface — exports match README capability table).

import { describe, expect, it } from "vitest";
import {
  VERSION,
  QbClient,
  QB_BASE_URL_PRODUCTION,
  QB_BASE_URL_SANDBOX,
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  refreshTokenNearExpiry,
  listOpenInvoices,
  getInvoice,
  listPayments,
  writePaymentReceived,
  QbCache,
  QbError,
  QbAuthError,
  QbRateLimitError,
  QbNotFoundError,
  QbValidationError,
} from "../src/index.js";

describe("@ifos/quickbooks package surface", () => {
  it("exports VERSION 0.1.0", () => {
    expect(VERSION).toBe("0.1.0");
  });

  it("exports QbClient class + base URLs (production + sandbox)", () => {
    expect(typeof QbClient).toBe("function");
    expect(QB_BASE_URL_PRODUCTION).toBe("https://quickbooks.api.intuit.com");
    expect(QB_BASE_URL_SANDBOX).toBe("https://sandbox-quickbooks.api.intuit.com");
  });

  it("exports all 4 capability functions", () => {
    expect(typeof listOpenInvoices).toBe("function");
    expect(typeof getInvoice).toBe("function");
    expect(typeof listPayments).toBe("function");
    expect(typeof writePaymentReceived).toBe("function");
  });

  it("exports auth helpers (load/save/refresh/shouldRefresh/refreshTokenNearExpiry)", () => {
    expect(typeof loadTokens).toBe("function");
    expect(typeof saveTokens).toBe("function");
    expect(typeof refreshTokens).toBe("function");
    expect(typeof shouldRefresh).toBe("function");
    expect(typeof refreshTokenNearExpiry).toBe("function");
  });

  it("exports QbCache + error hierarchy", () => {
    expect(typeof QbCache).toBe("function");
    expect(new QbAuthError("x") instanceof QbError).toBe(true);
    expect(new QbRateLimitError("x") instanceof QbError).toBe(true);
    expect(new QbNotFoundError("x") instanceof QbError).toBe(true);
    expect(new QbValidationError("x") instanceof QbError).toBe(true);
  });
});

--- FILE: packages/mcp-connectors/quickbooks/tsconfig.json ---

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

--- FILE: packages/mcp-connectors/quickbooks/tsup.config.ts ---

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

--- FILE: packages/mcp-connectors/quickbooks/vitest.config.ts ---

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

codex
I’m going to verify the connector against the repo-side references the ratification checklist depends on: exported surface, Cash Conductor tools, autosend policy, and boundary strings.
exec
/bin/zsh -lc 'rg --files packages/mcp-connectors/quickbooks agents/recruitment/cash-conductor agents/_shared | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/README.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
agents/_shared/voice-loader.sh
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
packages/mcp-connectors/quickbooks/README.md
packages/mcp-connectors/quickbooks/fixtures/invoices-page-1.json
packages/mcp-connectors/quickbooks/fixtures/payment-write-ok.json
packages/mcp-connectors/quickbooks/fixtures/payments-recent.json
packages/mcp-connectors/quickbooks/package.json
packages/mcp-connectors/quickbooks/src/auth.ts
packages/mcp-connectors/quickbooks/src/cache.ts
packages/mcp-connectors/quickbooks/src/client.ts
packages/mcp-connectors/quickbooks/src/errors.ts
packages/mcp-connectors/quickbooks/src/index.ts
packages/mcp-connectors/quickbooks/src/invoices.ts
packages/mcp-connectors/quickbooks/src/payments.ts
packages/mcp-connectors/quickbooks/src/rate-limit.ts
packages/mcp-connectors/quickbooks/src/types.ts
packages/mcp-connectors/quickbooks/tests/auth.test.ts
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts
packages/mcp-connectors/quickbooks/tsconfig.json
packages/mcp-connectors/quickbooks/tsup.config.ts
packages/mcp-connectors/quickbooks/vitest.config.ts

exec
/bin/zsh -lc 'rg -n "composio|agentmail|packages/harness/cortextos|decision_log|migration-test|test-tenant-b" packages/mcp-connectors/quickbooks -S -i' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/quickbooks/README.md:215:- ✓ No Composio / AgentMail references
packages/mcp-connectors/quickbooks/README.md:216:- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
packages/mcp-connectors/quickbooks/README.md:217:- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)

exec
/bin/zsh -lc 'rg -n "quickbooks|accounting_reconciliation_write|quickbooks_oauth|ESC_ACCOUNTING|ESC_PROVIDER_FETCH_FAIL|ESC_RATE_LIMIT_HIT" agents/recruitment/cash-conductor agents/_shared packages/mcp-connectors/quickbooks -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/quickbooks/src/cache.ts:23:      join(homedir(), ".ifos-cache", "quickbooks");
agents/recruitment/cash-conductor/tools.yaml:14:# (current registrations verified W4 Day-25 for accounting_reconciliation_write
agents/recruitment/cash-conductor/tools.yaml:56:    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED in autosend-policy.yaml
agents/recruitment/cash-conductor/tools.yaml:60:  - id: quickbooks_oauth
agents/recruitment/cash-conductor/tools.yaml:61:    package: "@ifos/quickbooks"
agents/recruitment/cash-conductor/tools.yaml:63:    action_type: quickbooks_oauth    # green tier; registration queued for W7-8
agents/recruitment/cash-conductor/tools.yaml:66:    rate_limit_hint: "500/min per realm_id (see @ifos/quickbooks README §Rate limits)"
agents/recruitment/cash-conductor/tools.yaml:68:  - id: quickbooks_list_open_invoices
agents/recruitment/cash-conductor/tools.yaml:69:    package: "@ifos/quickbooks"
agents/recruitment/cash-conductor/tools.yaml:74:  - id: quickbooks_get_invoice
agents/recruitment/cash-conductor/tools.yaml:75:    package: "@ifos/quickbooks"
agents/recruitment/cash-conductor/tools.yaml:80:  - id: quickbooks_list_payments
agents/recruitment/cash-conductor/tools.yaml:81:    package: "@ifos/quickbooks"
agents/recruitment/cash-conductor/tools.yaml:86:  - id: quickbooks_write_payment_received
agents/recruitment/cash-conductor/tools.yaml:87:    package: "@ifos/quickbooks"
agents/recruitment/cash-conductor/tools.yaml:89:    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED
agents/recruitment/cash-conductor/tools.yaml:193:#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
agents/recruitment/cash-conductor/tools.yaml:198:#   quickbooks_oauth                   green
packages/mcp-connectors/quickbooks/package.json:2:  "name": "@ifos/quickbooks",
agents/recruitment/cash-conductor/cleanup.sh:25:#   - Purge ~/.ifos-cache/quickbooks/* older than 24h
agents/recruitment/cash-conductor/cleanup.sh:28:#   - Reset in-process rate-limit buckets via @ifos/{xero,quickbooks,open-banking} resetRateLimit()
agents/recruitment/cash-conductor/cleanup.sh:80:export QB_CACHE_DIR="${IFOS_QB_CACHE_DIR:-${HOME}/.ifos-cache/quickbooks}"
agents/recruitment/cash-conductor/cleanup.sh:96:# Step 2 — Optional: emit ESC_RATE_LIMIT_HIT if any cache shows
agents/_shared/autosend-policy.yaml:163:  quickbooks_oauth:
agents/_shared/autosend-policy.yaml:166:    reason: "QuickBooks Online OAuth 2.0 refresh — idempotent token rotation against oauth.platform.intuit.com; @ifos/quickbooks connector handles concurrent-refresh dedup per-realm; QB refresh tokens have ~100-day TTL so operator alerting on refreshTokenNearExpiry() is the consumer's responsibility, not this action_type's."
agents/_shared/autosend-policy.yaml:241:  accounting_reconciliation_write:
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:280:#### `ESC_ACCOUNTING_AUTH`
agents/_shared/escalation-codes.md:285:- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:317:#### `ESC_ACCOUNTING_WRITE_FAIL`
agents/_shared/escalation-codes.md:319:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
agents/_shared/escalation-codes.md:324:#### `ESC_PROVIDER_FETCH_FAIL`
packages/mcp-connectors/quickbooks/src/payments.ts:3:// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
packages/mcp-connectors/quickbooks/src/payments.ts:57: * action_type='accounting_reconciliation_write' (yellow tier per
packages/mcp-connectors/quickbooks/src/payments.ts:61: * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
packages/mcp-connectors/quickbooks/src/index.ts:1:// @ifos/quickbooks — public API
packages/mcp-connectors/quickbooks/src/index.ts:15:// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §quickbooks)
packages/mcp-connectors/quickbooks/src/index.ts:18:// quickbooks_oauth (action_type: quickbooks_oauth, green tier per autosend-policy.yaml)
packages/mcp-connectors/quickbooks/src/index.ts:20:// quickbooks_list_open_invoices (read-only) + quickbooks_get_invoice (read-only)
packages/mcp-connectors/quickbooks/src/index.ts:22:// quickbooks_list_payments (read-only) + quickbooks_write_payment_received
packages/mcp-connectors/quickbooks/src/index.ts:23:// (action_type: accounting_reconciliation_write, yellow tier per autosend-policy.yaml)
agents/recruitment/cash-conductor/validate.sh:123:# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check
agents/recruitment/cash-conductor/validate.sh:182:  #  G6 → ESC_OPEN_BANKING_TOKEN_AGING; G7 → ESC_ACCOUNTING_AUTH)
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts:10:describe("quickbooks rate-limit", () => {
agents/recruitment/cash-conductor/context.sh:13:#   CTX_ACCOUNTING_PROVIDER   xero | quickbooks | sage (per tenant config)
agents/recruitment/cash-conductor/context.sh:25:#   - Accounting auth unreachable          → exit 1 with ESC_ACCOUNTING_AUTH
packages/mcp-connectors/quickbooks/README.md:1:# @ifos/quickbooks
packages/mcp-connectors/quickbooks/README.md:17:| `quickbooks_oauth` | `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per realm; atomic-file-write persistence | Step 1 (auth refresh) | `quickbooks_oauth` | green |
packages/mcp-connectors/quickbooks/README.md:18:| `quickbooks_list_open_invoices` | `listOpenInvoices(client, options?)` | Query API: paginated Invoice rows with Balance > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
packages/mcp-connectors/quickbooks/README.md:19:| `quickbooks_get_invoice` | `getInvoice(client, invoiceId, options?)` | Single-entity read by QB Id | Step 9 (chase-draft validation) | n/a | n/a |
packages/mcp-connectors/quickbooks/README.md:20:| `quickbooks_list_payments` | `listPayments(client, options?)` | Query API: Payment rows since date | Step 5 (reconciliation pass) | n/a | n/a |
packages/mcp-connectors/quickbooks/README.md:21:| `quickbooks_write_payment_received` | `writePaymentReceived(client, payment)` | POST /payment — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
packages/mcp-connectors/quickbooks/README.md:23:All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (verified 2026-06-01 Codex F-R2 closure — `quickbooks_oauth` registered as green; `accounting_reconciliation_write` already present shared with @ifos/xero).
packages/mcp-connectors/quickbooks/README.md:46:import { QbClient, listOpenInvoices, writePaymentReceived } from "@ifos/quickbooks";
packages/mcp-connectors/quickbooks/README.md:86:2. Construct the authorise URL with `scope=com.intuit.quickbooks.accounting` + `response_type=code` + your `redirect_uri`.
packages/mcp-connectors/quickbooks/README.md:100:| Base URL | `https://api.xero.com/api.xro/2.0` (constant) | `https://quickbooks.api.intuit.com/v3/company/<realmId>` (production) or `https://sandbox-quickbooks.api.intuit.com/...` (sandbox) |
packages/mcp-connectors/quickbooks/README.md:124:| Local hard-gate (100%) reached | `QbRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "quickbooks", retry_after_seconds: null, consecutive_429s: 0}` |
packages/mcp-connectors/quickbooks/README.md:125:| Upstream 429 from QB API | `QbRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "quickbooks", retry_after_seconds: <N>, consecutive_429s: <N>}` |
packages/mcp-connectors/quickbooks/README.md:135:| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` / `QbRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
packages/mcp-connectors/quickbooks/README.md:136:| `writePaymentReceived` | POST | **0** | n/a (writes never auto-retry) | `QbValidationError` (400) / `QbError` (5xx) → `ESC_ACCOUNTING_WRITE_FAIL` (warn; operator; consumer-emitted; payload includes `provider: "quickbooks"`, `endpoint: "/payment"`, `status_code`, `error_body_preview`) |
packages/mcp-connectors/quickbooks/README.md:137:| `refreshTokens` | POST | **0** | n/a | `QbAuthError` → `ESC_ACCOUNTING_AUTH` (blocking; consumer-emitted; caller may re-attempt with fresh credentials per Bootstrap §) |
packages/mcp-connectors/quickbooks/README.md:198:   ├── Step 5 (reconciliation pass)     ──┼─→ @ifos/quickbooks (this package)
packages/mcp-connectors/quickbooks/README.md:203:                                         https://quickbooks.api.intuit.com/v3/company/<realmId>
agents/recruitment/cash-conductor/cycle.sh:21:#   @ifos/quickbooks      — QuickBooks accounting provider
agents/recruitment/cash-conductor/cycle.sh:26:#   1. Reconciliation rows → accounting system (yellow tier accounting_reconciliation_write)
agents/recruitment/cash-conductor/cycle.sh:92:# Reference: agent.md §4 Step 1; emits ESC_ACCOUNTING_AUTH /
agents/recruitment/cash-conductor/cycle.sh:94:# W7-8 wires: @ifos/xero (or quickbooks) refreshTokens +
agents/recruitment/cash-conductor/cycle.sh:133:# Reference: agent.md §4 Step 4. W7-8 wires: @ifos/xero or @ifos/quickbooks
agents/recruitment/cash-conductor/cycle.sh:159:# or @ifos/quickbooks writePaymentReceived; atomic per write; rollback on 4xx/5xx.
agents/recruitment/cash-conductor/cycle.sh:164:  # hh_decision_action "accounting_reconciliation_write" "invoice:<id>" payload_hash payload_preview
agents/recruitment/cash-conductor/cycle.sh:165:  # On failure: ESC_ACCOUNTING_WRITE_FAIL via hh_decision_action validate_gate_a_fail
packages/mcp-connectors/quickbooks/src/client.ts:18:export const QB_BASE_URL_PRODUCTION = "https://quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:19:export const QB_BASE_URL_SANDBOX = "https://sandbox-quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:160:      // correctly to ESC_ACCOUNTING_AUTH.
packages/mcp-connectors/quickbooks/tests/auth.test.ts:24:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/auth.test.ts:33:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/auth.test.ts:60:describe("quickbooks auth", () => {
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:35:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:80:describe("quickbooks capabilities — invoices", () => {
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:127:describe("quickbooks capabilities — payments", () => {
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:27:describe("@ifos/quickbooks package surface", () => {
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:34:    expect(QB_BASE_URL_PRODUCTION).toBe("https://quickbooks.api.intuit.com");
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:35:    expect(QB_BASE_URL_SANDBOX).toBe("https://sandbox-quickbooks.api.intuit.com");
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:6:#   accounting_reconciliation_write) → chase generation pass identifies
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:69:      action_type: accounting_reconciliation_write
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:85:      action_type: accounting_reconciliation_write
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:94:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:164:   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on auth failure
agents/recruitment/cash-conductor/agent.md:206:   → on success: hh_decision_action("accounting_reconciliation_write",
agents/recruitment/cash-conductor/agent.md:208:   → on failure: ESC_ACCOUNTING_WRITE_FAIL
agents/recruitment/cash-conductor/agent.md:339:| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:340:| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:351:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:401:| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |

codex
The first pass found a mismatch worth checking carefully: the README says `quickbooks_oauth` is registered as green, while the Cash Conductor tools file comments say that registration was queued. I’m opening the policy and tools around those lines to distinguish stale comments from an actual gate mismatch.
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '150,175p;235,250p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   171	    agent: cash-conductor
   172	    reason: "TrueLayer OAuth 2.0 refresh — idempotent token rotation against auth.truelayer.com; @ifos/open-banking connector handles concurrent-refresh dedup per-connection; PSD2 90-day consent expiry surfaces via ESC_OPEN_BANKING_TOKEN_AGING (separate aging signal, not this action_type)."
   173	    irreversible: false
   174	
   175	  open_banking_plaid_uk:
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
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/tools.yaml | sed -n '52,92p;188,202p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    52	
    53	  - id: xero_write_payment_received
    54	    package: "@ifos/xero"
    55	    purpose: "Auto-write Stage 1-2 reconciliation matches (yellow tier; spot-check sampled)"
    56	    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED in autosend-policy.yaml
    57	    cycle_step: 6
    58	    state_changing: true
    59	
    60	  - id: quickbooks_oauth
    61	    package: "@ifos/quickbooks"
    62	    purpose: "QuickBooks OAuth 2.0 refresh (per-realm; PSD2-distinct from Xero per-tenant)"
    63	    action_type: quickbooks_oauth    # green tier; registration queued for W7-8
    64	    cycle_step: 1
    65	    secrets_required: [QB_CLIENT_ID, QB_CLIENT_SECRET]
    66	    rate_limit_hint: "500/min per realm_id (see @ifos/quickbooks README §Rate limits)"
    67	
    68	  - id: quickbooks_list_open_invoices
    69	    package: "@ifos/quickbooks"
    70	    purpose: "Query API: SELECT * FROM Invoice WHERE Balance > 0"
    71	    cycle_step: 4
    72	    state_changing: false
    73	
    74	  - id: quickbooks_get_invoice
    75	    package: "@ifos/quickbooks"
    76	    purpose: "Single-entity invoice fetch by QB Id (Gate A G1 re-check)"
    77	    cycle_step: 9
    78	    state_changing: false
    79	
    80	  - id: quickbooks_list_payments
    81	    package: "@ifos/quickbooks"
    82	    purpose: "List Payment records (reconciliation context)"
    83	    cycle_step: 5
    84	    state_changing: false
    85	
    86	  - id: quickbooks_write_payment_received
    87	    package: "@ifos/quickbooks"
    88	    purpose: "Auto-write Stage 1-2 reconciliation matches (same action_type as Xero — provider-agnostic at the audit layer)"
    89	    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED
    90	    cycle_step: 6
    91	    state_changing: true
    92	
   188	#
   189	# Already REGISTERED in agents/_shared/autosend-policy.yaml (verified 2026-05-25
   190	# during cash-conductor Codex Round 1 closure):
   191	#   xero_reminder_draft_internal       line 188   yellow
   192	#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
   193	#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
   194	#   operator_notify_telegram           green
   195	#
   196	# QUEUED for registration at W7-8 build start:
   197	#   xero_oauth                         green
   198	#   quickbooks_oauth                   green
   199	#   open_banking_truelayer             green
   200	#   open_banking_plaid_uk              green   (v1.1+; queued but never fires v1.0)
   201	#   cash_conductor_cleanup             green
   202	

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/README.md | sed -n '1,30p;112,142p;210,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# @ifos/quickbooks
     2	
     3	QuickBooks Online (QBO) Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 with **per-realm** token rotation + invoice read + payment read/write. Fixture-first; live tests deferred to first commercial QB sandbox signup (see §Tests).
     4	
     5	**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial QB sandbox signup for live-test verification).
     6	
     7	**Reference pattern:** mirrors `@ifos/xero` (W4 Day-25 RATIFIED scaffold). The per-realm OAuth diff vs Xero's per-tenant header is the load-bearing structural difference — documented in §"OAuth bootstrap" below. Every new MCP connector follows the parity model per `review-mcp-connector.md` §1.
     8	
     9	---
    10	
    11	## Capabilities
    12	
    13	Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.
    14	
    15	| Capability ID (tools.yaml) | Function (src/index.ts) | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
    16	|---|---|---|---|---|---|
    17	| `quickbooks_oauth` | `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per realm; atomic-file-write persistence | Step 1 (auth refresh) | `quickbooks_oauth` | green |
    18	| `quickbooks_list_open_invoices` | `listOpenInvoices(client, options?)` | Query API: paginated Invoice rows with Balance > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
    19	| `quickbooks_get_invoice` | `getInvoice(client, invoiceId, options?)` | Single-entity read by QB Id | Step 9 (chase-draft validation) | n/a | n/a |
    20	| `quickbooks_list_payments` | `listPayments(client, options?)` | Query API: Payment rows since date | Step 5 (reconciliation pass) | n/a | n/a |
    21	| `quickbooks_write_payment_received` | `writePaymentReceived(client, payment)` | POST /payment — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
    22	
    23	All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (verified 2026-06-01 Codex F-R2 closure — `quickbooks_oauth` registered as green; `accounting_reconciliation_write` already present shared with @ifos/xero).
    24	
    25	### Internal helpers (NOT bus-routed capabilities)
    26	
    27	Exposed by `src/index.ts` for consumer convenience + testing, but NOT declared in `tools.yaml`:
    28	
    29	| Function | Purpose |
    30	|---|---|
   112	- **500 calls / 60-second window per app per realmId** (minute bucket)
   113	- **10 calls per second concurrent throttle** (not enforced here — single-process Cash Conductor cycle.sh is serial)
   114	- No published daily cap
   115	
   116	This connector tracks the minute bucket per `src/rate-limit.ts`. **Hard gate at 100%** (`consume()` returns false → `QbRateLimitError`). **Soft signal at 80%** (400/minute) is read-only and exposed via `rateCheck()` — `RateState.shouldBackoff === true` with `reason: "minute-soft"`. The consuming agent layer (Cash Conductor cycle.sh) is responsible for honouring the soft signal (e.g. pausing batch operations); the connector does not silently throttle — the contract is "callers query soft, connector enforces hard". `tests/rate-limit.test.ts` exercises both thresholds.
   117	
   118	State is in-process and per-realm — a multi-realm runtime that holds many `QbClient` instances in one process still gets correct isolation.
   119	
   120	**ESC contract on bucket exhaustion** (consumer-emitted via `agents/_shared/hook-helpers.sh`):
   121	
   122	| Failure | Surfaces as | ESC code (escalation-codes.md) | Payload contract |
   123	|---|---|---|---|
   124	| Local hard-gate (100%) reached | `QbRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "quickbooks", retry_after_seconds: null, consecutive_429s: 0}` |
   125	| Upstream 429 from QB API | `QbRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "quickbooks", retry_after_seconds: <N>, consecutive_429s: <N>}` |
   126	
   127	Both surface as the same ESC because from the operator's perspective they're the same operational signal (QB traffic is being throttled). The payload distinguishes local pre-emptive (`retry_after_seconds: null`) from upstream-issued.
   128	
   129	---
   130	
   131	## Retry policy
   132	
   133	| Capability | Method | Max retries | Backoff | On exhaustion |
   134	|---|---|---|---|---|
   135	| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` / `QbRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
   136	| `writePaymentReceived` | POST | **0** | n/a (writes never auto-retry) | `QbValidationError` (400) / `QbError` (5xx) → `ESC_ACCOUNTING_WRITE_FAIL` (warn; operator; consumer-emitted; payload includes `provider: "quickbooks"`, `endpoint: "/payment"`, `status_code`, `error_body_preview`) |
   137	| `refreshTokens` | POST | **0** | n/a | `QbAuthError` → `ESC_ACCOUNTING_AUTH` (blocking; consumer-emitted; caller may re-attempt with fresh credentials per Bootstrap §) |
   138	| 401 from any GET | — | force-refresh access_token, retry once | — | `QbAuthError` |
   139	| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `QbRateLimitError` |
   140	
   141	Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to QB.
   142	
   210	---
   211	
   212	## Boundary checks
   213	
   214	Per `review-mcp-connector.md` §8:
   215	- ✓ No Composio / AgentMail references
   216	- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
   217	- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)
   218	- ✓ No hardcoded tenant slugs in `src/` (test fixtures only — `fixture-realm`, `test-realm-rate-limit`)
   219	
   220	---

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/src/client.ts | sed -n '118,136p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   118	      let res: Response;
   119	      try {
   120	        res = await this.fetchFn(url.toString(), {
   121	          method,
   122	          headers,
   123	          body: options.body !== undefined ? JSON.stringify(options.body) : undefined,
   124	          signal: options.signal,
   125	        });
   126	      } catch (e) {
   127	        last_error = e;
   128	        if (attempt < max_retries) {
   129	          await sleep(backoff(attempt));
   130	          continue;
   131	        }
   132	        throw new QbError(
   133	          `QuickBooks network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
   134	        );
   135	      }
   136	

codex
The policy file does contain `quickbooks_oauth` as green, so the queued note in `tools.yaml` is stale rather than a tier failure. I’m running the package checks now because ratification can’t rely only on the embedded artefact text.
exec
/bin/zsh -lc "rg -n \"console\\.(log|error|warn).*\\"'$'"\\{.*(KEY|SECRET|PASSWORD|TOKEN|BEARER)|throw\\s+new\\s+Error.*\\"'$'"\\{.*(KEY|SECRET|PASSWORD)\" packages/mcp-connectors/quickbooks -S" in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
exec
/bin/zsh -lc 'pnpm --filter @ifos/quickbooks typecheck' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'pnpm --filter @ifos/quickbooks test' in /Users/madsadmin/code/CortexOS
 succeeded in 1266ms:

> @ifos/quickbooks@0.1.0 typecheck /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks
> tsc --noEmit


 succeeded in 3068ms:

> @ifos/quickbooks@0.1.0 test /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks
> vitest run


 RUN  v2.1.9 /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks

 ✓ tests/rate-limit.test.ts (5 tests) 23ms
 ✓ tests/scaffold.test.ts (5 tests) 3ms
 ✓ tests/auth.test.ts (7 tests) 80ms
 ✓ tests/capabilities.test.ts (9 tests) 1253ms
   ✓ quickbooks capabilities — invoices > listOpenInvoices: persistent 429 surfaces as QbRateLimitError after retries 462ms
   ✓ quickbooks capabilities — payments > listPayments: persistent 500 surfaces as QbError after retries 574ms

 Test Files  4 passed (4)
      Tests  26 passed (26)
   Start at  11:56:17
   Duration  2.19s (transform 293ms, setup 0ms, collect 466ms, tests 1.36s, environment 1ms, prepare 661ms)


codex
Tests and typecheck pass. I’m doing one last consistency check for claim-level drift, because this review brief explicitly treats stale section/step references as ratification blockers.
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/src/client.ts | sed -n '136,166p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/package.json | sed -n '1,8p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   136	
   137	      if (res.ok) {
   138	        return (await res.json()) as T;
   139	      }
   140	
   141	      // 401: server invalidated the access_token — force an explicit refresh
   142	      // BEFORE the next iteration. Per Codex F-R2 issue #1 (qb): nulling the
   143	      // cached token alone is insufficient — getValidAccessToken() will reload
   144	      // the SAME stale token from disk if shouldRefresh() says it's not near
   145	      // expiry. Rotate it now; persist the new bundle; let the next iteration
   146	      // pick up the rotated token.
   147	      if (res.status === 401 && attempt < max_retries) {
   148	        if (this.current_tokens) {
   149	          // Throws QbAuthError on refresh failure → propagates correctly.
   150	          this.current_tokens = await refreshTokens(
   151	            this.opts.config,
   152	            this.current_tokens,
   153	            this.fetchFn,
   154	          );
   155	        }
   156	        await sleep(backoff(attempt));
   157	        continue;
   158	      }
   159	      // 401 after retries exhausted: AUTH-typed error so consumer branches
   160	      // correctly to ESC_ACCOUNTING_AUTH.
   161	      if (res.status === 401) {
   162	        throw new QbAuthError(
   163	          `QuickBooks ${method} ${path} returned 401 after ${attempt + 1} attempt(s) including forced refresh`,
   164	          401,
   165	        );
   166	      }

 succeeded in 0ms:
     1	{
     2	  "name": "@ifos/quickbooks",
     3	  "version": "0.1.0",
     4	  "private": true,
     5	  "description": "IFOS QuickBooks Online MCP connector — OAuth 2.0 refresh (per-realm) + invoices read + payments read/write. Used by Cash Conductor agent §4 Steps 4-6 + 10-11 per agents/recruitment/cash-conductor/tools.yaml.",
     6	  "license": "UNLICENSED",
     7	  "type": "module",
     8	  "engines": { "node": ">=20.0.0" },

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/README.md | sed -n '133,140p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/src/index.ts | sed -n '18,64p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   133	| Capability | Method | Max retries | Backoff | On exhaustion |
   134	|---|---|---|---|---|
   135	| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` / `QbRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
   136	| `writePaymentReceived` | POST | **0** | n/a (writes never auto-retry) | `QbValidationError` (400) / `QbError` (5xx) → `ESC_ACCOUNTING_WRITE_FAIL` (warn; operator; consumer-emitted; payload includes `provider: "quickbooks"`, `endpoint: "/payment"`, `status_code`, `error_body_preview`) |
   137	| `refreshTokens` | POST | **0** | n/a | `QbAuthError` → `ESC_ACCOUNTING_AUTH` (blocking; consumer-emitted; caller may re-attempt with fresh credentials per Bootstrap §) |
   138	| 401 from any GET | — | force-refresh access_token, retry once | — | `QbAuthError` |
   139	| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `QbRateLimitError` |
   140	

 succeeded in 0ms:
    18	// quickbooks_oauth (action_type: quickbooks_oauth, green tier per autosend-policy.yaml)
    19	export { refreshTokens } from "./auth.js";
    20	// quickbooks_list_open_invoices (read-only) + quickbooks_get_invoice (read-only)
    21	export { listOpenInvoices, getInvoice } from "./invoices.js";
    22	// quickbooks_list_payments (read-only) + quickbooks_write_payment_received
    23	// (action_type: accounting_reconciliation_write, yellow tier per autosend-policy.yaml)
    24	export { listPayments, writePaymentReceived } from "./payments.js";
    25	
    26	// ─────────────────────────────────────────────────────────────────────────
    27	// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
    28	// ─────────────────────────────────────────────────────────────────────────
    29	
    30	// Transport class — constructed once by cycle.sh Step 1; per-realm URL construction
    31	export {
    32	  QbClient,
    33	  QB_BASE_URL_PRODUCTION,
    34	  QB_BASE_URL_SANDBOX,
    35	  DEFAULT_TIMEOUT_MS,
    36	} from "./client.js";
    37	// Token-file I/O + pure predicates (shouldRefresh for access; refreshTokenNearExpiry
    38	// for the 7-day re-consent danger window — operator alerting hook)
    39	export {
    40	  loadTokens,
    41	  saveTokens,
    42	  shouldRefresh,
    43	  refreshTokenNearExpiry,
    44	} from "./auth.js";
    45	// Disk cache
    46	export { QbCache } from "./cache.js";
    47	// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
    48	// consumer responsible for honouring shouldBackoff at the 80% soft threshold;
    49	// hard 100% gate is enforced inside rateConsume()).
    50	export {
    51	  check as rateCheck,
    52	  consume as rateConsume,
    53	  reset as resetRateLimit,
    54	} from "./rate-limit.js";
    55	// Test/diagnostic
    56	export { _resetInflightForTest } from "./auth.js";
    57	// Error hierarchy
    58	export {
    59	  QbError,
    60	  QbAuthError,
    61	  QbRateLimitError,
    62	  QbNotFoundError,
    63	  QbValidationError,
    64	} from "./errors.js";

codex
The remaining findings are claim/spec mismatches rather than failing tests: the connector passes its suite, but the ratification standard is stricter than test success. I have enough to return the verdict.
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/tools.yaml | sed -n '60,91p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    60	  - id: quickbooks_oauth
    61	    package: "@ifos/quickbooks"
    62	    purpose: "QuickBooks OAuth 2.0 refresh (per-realm; PSD2-distinct from Xero per-tenant)"
    63	    action_type: quickbooks_oauth    # green tier; registration queued for W7-8
    64	    cycle_step: 1
    65	    secrets_required: [QB_CLIENT_ID, QB_CLIENT_SECRET]
    66	    rate_limit_hint: "500/min per realm_id (see @ifos/quickbooks README §Rate limits)"
    67	
    68	  - id: quickbooks_list_open_invoices
    69	    package: "@ifos/quickbooks"
    70	    purpose: "Query API: SELECT * FROM Invoice WHERE Balance > 0"
    71	    cycle_step: 4
    72	    state_changing: false
    73	
    74	  - id: quickbooks_get_invoice
    75	    package: "@ifos/quickbooks"
    76	    purpose: "Single-entity invoice fetch by QB Id (Gate A G1 re-check)"
    77	    cycle_step: 9
    78	    state_changing: false
    79	
    80	  - id: quickbooks_list_payments
    81	    package: "@ifos/quickbooks"
    82	    purpose: "List Payment records (reconciliation context)"
    83	    cycle_step: 5
    84	    state_changing: false
    85	
    86	  - id: quickbooks_write_payment_received
    87	    package: "@ifos/quickbooks"
    88	    purpose: "Auto-write Stage 1-2 reconciliation matches (same action_type as Xero — provider-agnostic at the audit layer)"
    89	    action_type: accounting_reconciliation_write  # yellow tier; REGISTERED
    90	    cycle_step: 6
    91	    state_changing: true

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/src/rate-limit.ts | sed -n '1,45p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// Rate limiter for QuickBooks Online. Per Intuit published limits
     2	// (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):
     3	//   - 500 calls / 60-second window per app per realmId (minute bucket)
     4	//   - 10 calls / second concurrent throttle (not enforced here — single-process
     5	//     Cash Conductor cycle.sh is serial)
     6	//
     7	// No published daily cap; only the per-minute throttle. Pre-emptive backoff at
     8	// 80% of the minute bucket. Per-realm state (multi-realm safe).
     9	
    10	const MINUTE_MS = 60 * 1000;
    11	const MINUTE_HARD = 500;
    12	const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 400
    13	
    14	const minuteTimestamps: Map<string, number[]> = new Map();
    15	
    16	export interface RateState {
    17	  realm_id: string;
    18	  minute_used: number;
    19	  minute_remaining: number;
    20	  shouldBackoff: boolean;
    21	  reason: "ok" | "minute-soft" | "minute-hard";
    22	}
    23	
    24	function pruneMinute(arr: number[] | undefined, now: number): number[] {
    25	  if (!arr) return [];
    26	  return arr.filter((ts) => now - ts < MINUTE_MS);
    27	}
    28	
    29	export function check(
    30	  realm_id: string,
    31	  now: () => number = Date.now,
    32	): RateState {
    33	  const t = now();
    34	  const minute = pruneMinute(minuteTimestamps.get(realm_id), t);
    35	  minuteTimestamps.set(realm_id, minute);
    36	
    37	  const minute_used = minute.length;
    38	  let reason: RateState["reason"] = "ok";
    39	  let shouldBackoff = false;
    40	
    41	  if (minute_used >= MINUTE_HARD) {
    42	    reason = "minute-hard";
    43	    shouldBackoff = true;
    44	  } else if (minute_used >= MINUTE_SOFT) {
    45	    reason = "minute-soft";

codex
REJECTED

1. QuickBooks’ second/concurrent throttle is declared but deliberately not implemented. `README.md` lines 112-116 and `src/rate-limit.ts` lines 1-8 cite the upstream `10 calls per second concurrent throttle`, then say it is “not enforced here”; `src/rate-limit.ts` lines 10-14 only implement the 500/minute bucket. This fails `review-mcp-connector.md` §3 because the declared upstream rate-limit budget is not covered by a safety-margin implementation or exhaustion test. Add a per-second/concurrency limiter with tests, or remove the claim only if provider docs prove it is not an applicable call/window budget.

2. The package description cites the wrong Cash Conductor steps. `package.json` line 5 says the connector is used by “§4 Steps 4-6 + 10-11 per agents/recruitment/cash-conductor/tools.yaml,” but `tools.yaml` lines 60-90 maps QuickBooks to steps 1, 4, 5, 6, and 9. This violates the top-level citation-accuracy/honest-signal check. Update the description to cite the actual tool steps: 1, 4, 5, 6, and 9.
tokens used
54,314
REJECTED

1. QuickBooks’ second/concurrent throttle is declared but deliberately not implemented. `README.md` lines 112-116 and `src/rate-limit.ts` lines 1-8 cite the upstream `10 calls per second concurrent throttle`, then say it is “not enforced here”; `src/rate-limit.ts` lines 10-14 only implement the 500/minute bucket. This fails `review-mcp-connector.md` §3 because the declared upstream rate-limit budget is not covered by a safety-margin implementation or exhaustion test. Add a per-second/concurrency limiter with tests, or remove the claim only if provider docs prove it is not an applicable call/window budget.

2. The package description cites the wrong Cash Conductor steps. `package.json` line 5 says the connector is used by “§4 Steps 4-6 + 10-11 per agents/recruitment/cash-conductor/tools.yaml,” but `tools.yaml` lines 60-90 maps QuickBooks to steps 1, 4, 5, 6, and 9. This violates the top-level citation-accuracy/honest-signal check. Update the description to cite the actual tool steps: 1, 4, 5, 6, and 9.
