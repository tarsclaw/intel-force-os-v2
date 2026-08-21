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
session id: 019e880f-b67a-75d2-bdd8-266b8d114219
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
  "description": "IFOS QuickBooks Online MCP connector — OAuth 2.0 refresh (per-realm) + invoices read + payments read/write. Used by Cash Conductor agent §4 Steps 1, 4, 5, 6, 9 per agents/recruitment/cash-conductor/tools.yaml.",
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
I’ll verify the connector against the ratification checklist in the repo, especially the referenced tools/autosend surfaces and whether the submitted code actually builds under the package config.
exec
/bin/zsh -lc 'rg -n "composio|agentmail|packages/harness/cortextos|decision_log|migration-test|test-tenant-b" packages/mcp-connectors/quickbooks -i -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/quickbooks/README.md:215:- ✓ No Composio / AgentMail references
packages/mcp-connectors/quickbooks/README.md:216:- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
packages/mcp-connectors/quickbooks/README.md:217:- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)

exec
/bin/zsh -lc 'rg -n "quickbooks|accounting_reconciliation_write|quickbooks_oauth|ESC_ACCOUNTING|ESC_RATE_LIMIT_HIT|ESC_PROVIDER_FETCH_FAIL|ESC_ACCOUNTING_WRITE_FAIL" agents packages/mcp-connectors/quickbooks -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
packages/mcp-connectors/quickbooks/src/client.ts:18:export const QB_BASE_URL_PRODUCTION = "https://quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:19:export const QB_BASE_URL_SANDBOX = "https://sandbox-quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:160:      // correctly to ESC_ACCOUNTING_AUTH.
packages/mcp-connectors/quickbooks/package.json:2:  "name": "@ifos/quickbooks",
packages/mcp-connectors/quickbooks/src/payments.ts:3:// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
packages/mcp-connectors/quickbooks/src/payments.ts:57: * action_type='accounting_reconciliation_write' (yellow tier per
packages/mcp-connectors/quickbooks/src/payments.ts:61: * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
packages/mcp-connectors/quickbooks/src/cache.ts:23:      join(homedir(), ".ifos-cache", "quickbooks");
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
packages/mcp-connectors/quickbooks/src/index.ts:1:// @ifos/quickbooks — public API
packages/mcp-connectors/quickbooks/src/index.ts:15:// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §quickbooks)
packages/mcp-connectors/quickbooks/src/index.ts:18:// quickbooks_oauth (action_type: quickbooks_oauth, green tier per autosend-policy.yaml)
packages/mcp-connectors/quickbooks/src/index.ts:20:// quickbooks_list_open_invoices (read-only) + quickbooks_get_invoice (read-only)
packages/mcp-connectors/quickbooks/src/index.ts:22:// quickbooks_list_payments (read-only) + quickbooks_write_payment_received
packages/mcp-connectors/quickbooks/src/index.ts:23:// (action_type: accounting_reconciliation_write, yellow tier per autosend-policy.yaml)
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts:10:describe("quickbooks rate-limit", () => {
packages/mcp-connectors/quickbooks/tests/auth.test.ts:24:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/auth.test.ts:33:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/auth.test.ts:60:describe("quickbooks auth", () => {
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:35:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:80:describe("quickbooks capabilities — invoices", () => {
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:127:describe("quickbooks capabilities — payments", () => {
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:27:describe("@ifos/quickbooks package surface", () => {
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:34:    expect(QB_BASE_URL_PRODUCTION).toBe("https://quickbooks.api.intuit.com");
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:35:    expect(QB_BASE_URL_SANDBOX).toBe("https://sandbox-quickbooks.api.intuit.com");
agents/recruitment/sourcing-scout/agent.md:161:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
agents/recruitment/sourcing-scout/agent.md:169:   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
agents/recruitment/sourcing-scout/agent.md:175:   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:182:   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:295:| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
agents/recruitment/cash-conductor/cleanup.sh:25:#   - Purge ~/.ifos-cache/quickbooks/* older than 24h
agents/recruitment/cash-conductor/cleanup.sh:28:#   - Reset in-process rate-limit buckets via @ifos/{xero,quickbooks,open-banking} resetRateLimit()
agents/recruitment/cash-conductor/cleanup.sh:80:export QB_CACHE_DIR="${IFOS_QB_CACHE_DIR:-${HOME}/.ifos-cache/quickbooks}"
agents/recruitment/cash-conductor/cleanup.sh:96:# Step 2 — Optional: emit ESC_RATE_LIMIT_HIT if any cache shows
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
agents/recruitment/cash-conductor/tools.yaml:192:#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
agents/recruitment/cash-conductor/tools.yaml:197:#   quickbooks_oauth                   green
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:152:   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
agents/recruitment/scribe/agent.md:273:| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:282:| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/context.sh:13:#   CTX_ACCOUNTING_PROVIDER   xero | quickbooks | sage (per tenant config)
agents/recruitment/cash-conductor/context.sh:25:#   - Accounting auth unreachable          → exit 1 with ESC_ACCOUNTING_AUTH
agents/recruitment/cash-conductor/cycle.sh:21:#   @ifos/quickbooks      — QuickBooks accounting provider
agents/recruitment/cash-conductor/cycle.sh:26:#   1. Reconciliation rows → accounting system (yellow tier accounting_reconciliation_write)
agents/recruitment/cash-conductor/cycle.sh:92:# Reference: agent.md §4 Step 1; emits ESC_ACCOUNTING_AUTH /
agents/recruitment/cash-conductor/cycle.sh:94:# W7-8 wires: @ifos/xero (or quickbooks) refreshTokens +
agents/recruitment/cash-conductor/cycle.sh:133:# Reference: agent.md §4 Step 4. W7-8 wires: @ifos/xero or @ifos/quickbooks
agents/recruitment/cash-conductor/cycle.sh:159:# or @ifos/quickbooks writePaymentReceived; atomic per write; rollback on 4xx/5xx.
agents/recruitment/cash-conductor/cycle.sh:164:  # hh_decision_action "accounting_reconciliation_write" "invoice:<id>" payload_hash payload_preview
agents/recruitment/cash-conductor/cycle.sh:165:  # On failure: ESC_ACCOUNTING_WRITE_FAIL via hh_decision_action validate_gate_a_fail
agents/recruitment/cash-conductor/validate.sh:123:# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check
agents/recruitment/cash-conductor/validate.sh:182:  #  G6 → ESC_OPEN_BANKING_TOKEN_AGING; G7 → ESC_ACCOUNTING_AUTH)
agents/recruitment/janitor/agent.md:100:   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per ESC_RATE_LIMIT_HIT catalogue §2.5 standard handling)
agents/recruitment/janitor/agent.md:129:   → ESC_RATE_LIMIT_HIT on 429
agents/recruitment/janitor/agent.md:223:| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
agents/recruitment/concierge/tools.yaml:51:        escalation: ESC_RATE_LIMIT_HIT  # warn; operator; payload.upstream='bullhorn'
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:6:#   accounting_reconciliation_write) → chase generation pass identifies
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:69:      action_type: accounting_reconciliation_write
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:85:      action_type: accounting_reconciliation_write
agents/recruitment/concierge/cycle.sh:137:# contact entities. ESC_RATE_LIMIT_HIT on 429; ESC_BULLHORN_AUTH on auth
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:94:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:164:   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on auth failure
agents/recruitment/cash-conductor/agent.md:206:   → on success: hh_decision_action("accounting_reconciliation_write",
agents/recruitment/cash-conductor/agent.md:208:   → on failure: ESC_ACCOUNTING_WRITE_FAIL
agents/recruitment/cash-conductor/agent.md:339:| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:340:| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:351:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:401:| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
agents/recruitment/diagnostic/tools.yaml:42:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:77:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:165:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:172:  - quickbooks     # Cash Conductor's territory
agents/recruitment/diagnostic/agent.md:116:   → v0 NOTE: rate-limit catches (429 → ESC_RATE_LIMIT_HIT) and per-section retry logic are NOT implemented at v0 cycle.sh; W4 polish adds 429 catch + retry-with-backoff to cycle.sh. v0 generator throws-and-exits on upstream errors; validate.sh catches Gate A failure downstream.
agents/recruitment/diagnostic/agent.md:189:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn upstream 429 | warn | operator_chat_id | **v0: NOT implemented in `cycle.sh` (generator throws-and-exits on upstream errors; validate.sh catches downstream as `ESC_AGENT_OUTPUT_SHAPE`). W4-planned: 429 catch + retry-with-backoff in `cycle.sh` + explicit `ESC_RATE_LIMIT_HIT` emission.** |
agents/recruitment/concierge/agent.md:154:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:317:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |

exec
/bin/zsh -lc "rg -n \"export function|export async function|export class|export const|export \\{\" packages/mcp-connectors/quickbooks/src -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/quickbooks/src/auth.ts:32:export async function loadTokens(
packages/mcp-connectors/quickbooks/src/auth.ts:61:export async function saveTokens(
packages/mcp-connectors/quickbooks/src/auth.ts:73:export function shouldRefresh(
packages/mcp-connectors/quickbooks/src/auth.ts:86:export function refreshTokenNearExpiry(
packages/mcp-connectors/quickbooks/src/auth.ts:100:export async function refreshTokens(
packages/mcp-connectors/quickbooks/src/auth.ts:170:export function _resetInflightForTest(): void {
packages/mcp-connectors/quickbooks/src/rate-limit.ts:29:export function check(
packages/mcp-connectors/quickbooks/src/rate-limit.ts:58:export function consume(
packages/mcp-connectors/quickbooks/src/rate-limit.ts:71:export function reset(realm_id?: string): void {
packages/mcp-connectors/quickbooks/src/payments.ts:26:export async function listPayments(
packages/mcp-connectors/quickbooks/src/payments.ts:63:export async function writePaymentReceived(
packages/mcp-connectors/quickbooks/src/index.ts:19:export { refreshTokens } from "./auth.js";
packages/mcp-connectors/quickbooks/src/index.ts:21:export { listOpenInvoices, getInvoice } from "./invoices.js";
packages/mcp-connectors/quickbooks/src/index.ts:24:export { listPayments, writePaymentReceived } from "./payments.js";
packages/mcp-connectors/quickbooks/src/index.ts:31:export {
packages/mcp-connectors/quickbooks/src/index.ts:39:export {
packages/mcp-connectors/quickbooks/src/index.ts:46:export { QbCache } from "./cache.js";
packages/mcp-connectors/quickbooks/src/index.ts:50:export {
packages/mcp-connectors/quickbooks/src/index.ts:56:export { _resetInflightForTest } from "./auth.js";
packages/mcp-connectors/quickbooks/src/index.ts:58:export {
packages/mcp-connectors/quickbooks/src/index.ts:76:export const VERSION = "0.1.0";
packages/mcp-connectors/quickbooks/src/client.ts:18:export const QB_BASE_URL_PRODUCTION = "https://quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:19:export const QB_BASE_URL_SANDBOX = "https://sandbox-quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:20:export const DEFAULT_TIMEOUT_MS = 15_000;
packages/mcp-connectors/quickbooks/src/client.ts:40:export class QbClient {
packages/mcp-connectors/quickbooks/src/cache.ts:17:export class QbCache {
packages/mcp-connectors/quickbooks/src/invoices.ts:29:export async function listOpenInvoices(
packages/mcp-connectors/quickbooks/src/invoices.ts:60:export async function getInvoice(
packages/mcp-connectors/quickbooks/src/errors.ts:5:export class QbError extends Error {
packages/mcp-connectors/quickbooks/src/errors.ts:17:export class QbAuthError extends QbError {
packages/mcp-connectors/quickbooks/src/errors.ts:25:export class QbRateLimitError extends QbError {
packages/mcp-connectors/quickbooks/src/errors.ts:36:export class QbNotFoundError extends QbError {
packages/mcp-connectors/quickbooks/src/errors.ts:44:export class QbValidationError extends QbError {

codex
The first pass shows a possible autosend/tools mismatch in the surrounding repo comments, but the actual policy entries exist. I’m going to run the connector’s own checks now because build/type errors are ratification blockers for an MCP package.
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/src/client.ts | sed -n '70,230p'; nl -ba packages/mcp-connectors/quickbooks/src/invoices.ts | sed -n '20,80p'; nl -ba packages/mcp-connectors/quickbooks/src/payments.ts | sed -n '20,85p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    70	      this.current_tokens = await refreshTokens(
    71	        this.opts.config,
    72	        this.current_tokens,
    73	        this.fetchFn,
    74	      );
    75	    }
    76	    return this.current_tokens.access_token;
    77	  }
    78	
    79	  /** Public: low-level call. Most callers use the capability helpers in invoices/payments. */
    80	  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    81	    const method = options.method ?? "GET";
    82	    const isWrite = method !== "GET";
    83	    const max_retries = options.max_retries ?? (isWrite ? 0 : 2);
    84	
    85	    // QB v3 API path always includes /v3/company/<realmId>/...
    86	    const url = new URL(
    87	      `${this.base_url}/v3/company/${this.opts.config.realm_id}${path}`,
    88	    );
    89	    if (options.query) {
    90	      for (const [k, v] of Object.entries(options.query)) {
    91	        url.searchParams.set(k, v);
    92	      }
    93	    }
    94	    // QB wants minorversion query param for forward-compat
    95	    if (!url.searchParams.has("minorversion")) {
    96	      url.searchParams.set("minorversion", "73");
    97	    }
    98	
    99	    let last_error: unknown = null;
   100	    for (let attempt = 0; attempt <= max_retries; attempt++) {
   101	      const allowed = consume(this.opts.config.realm_id, this.now);
   102	      if (!allowed) {
   103	        throw new QbRateLimitError(
   104	          `QuickBooks rate-limit budget exhausted (realm=${this.opts.config.realm_id}); ` +
   105	            `local bucket prevents call to avoid upstream 429`,
   106	        );
   107	      }
   108	
   109	      const access_token = await this.getValidAccessToken();
   110	      const headers: Record<string, string> = {
   111	        Authorization: `Bearer ${access_token}`,
   112	        Accept: "application/json",
   113	      };
   114	      if (options.body !== undefined) {
   115	        headers["Content-Type"] = "application/json";
   116	      }
   117	
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
   167	
   168	      // 429: rate-limited; honour Retry-After then retry (GET only)
   169	      if (res.status === 429 && attempt < max_retries) {
   170	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   171	        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
   172	        await sleep(waitMs);
   173	        continue;
   174	      }
   175	      if (res.status === 429) {
   176	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   177	        throw new QbRateLimitError(
   178	          `QuickBooks returned 429 after ${attempt + 1} attempt(s)`,
   179	          retryAfter > 0 ? retryAfter : null,
   180	        );
   181	      }
   182	
   183	      // 5xx: retry with backoff (GET only)
   184	      if (res.status >= 500 && attempt < max_retries) {
   185	        await sleep(backoff(attempt));
   186	        continue;
   187	      }
   188	
   189	      // 4xx (non-401/429): typed error, no retry
   190	      const safeBody = await res.text().catch(() => "");
   191	      if (res.status === 404) {
   192	        throw new QbNotFoundError(`QuickBooks 404 on ${method} ${path}`);
   193	      }
   194	      if (res.status === 400) {
   195	        throw new QbValidationError(
   196	          `QuickBooks rejected ${method} ${path} (HTTP 400)`,
   197	          safeBody.length > 0 && safeBody.length < 2000 ? [safeBody] : [],
   198	        );
   199	      }
   200	      throw new QbError(
   201	        `QuickBooks ${method} ${path} failed (HTTP ${res.status})`,
   202	        res.status,
   203	      );
   204	    }
   205	    throw new QbError(
   206	      `QuickBooks ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
   207	    );
   208	  }
   209	}
    20	  max_results?: number;
    21	  no_cache?: boolean;
    22	  cache?: QbCache;
    23	}
    24	
    25	/**
    26	 * List open invoices (Balance > 0).
    27	 * QB pagination uses startposition + maxresults; default 100 per call.
    28	 */
    29	export async function listOpenInvoices(
    30	  client: QbClient,
    31	  options: ListOpenInvoicesOptions = {},
    32	): Promise<QbInvoice[]> {
    33	  const cache = options.cache ?? QbCache.fromEnv();
    34	  const start = options.start_position ?? 1;
    35	  const max = options.max_results ?? 100;
    36	  const key = `invoices:open:start=${start}:max=${max}:since=${options.issued_since ?? "all"}`;
    37	
    38	  if (!options.no_cache) {
    39	    const hit = await cache.get<QbInvoice[]>(key);
    40	    if (hit !== null) return hit;
    41	  }
    42	
    43	  // QB query syntax: SQL-like, with single-quote string literals
    44	  let query = "SELECT * FROM Invoice WHERE Balance > '0'";
    45	  if (options.issued_since) {
    46	    query += ` AND TxnDate >= '${options.issued_since}'`;
    47	  }
    48	  query += ` STARTPOSITION ${start} MAXRESULTS ${max}`;
    49	
    50	  const res = await client.request<QbQueryResponse<"Invoice", QbInvoice>>(
    51	    "/query",
    52	    { query: { query } },
    53	  );
    54	  const invoices = res.QueryResponse.Invoice ?? [];
    55	  await cache.set(key, invoices, INVOICE_CACHE_TTL_MS);
    56	  return invoices;
    57	}
    58	
    59	/** Get a single invoice by QB Id (numeric string). */
    60	export async function getInvoice(
    61	  client: QbClient,
    62	  invoiceId: string,
    63	  options: { cache?: QbCache; no_cache?: boolean } = {},
    64	): Promise<QbInvoice | null> {
    65	  const cache = options.cache ?? QbCache.fromEnv();
    66	  const key = `invoice:${invoiceId}`;
    67	  if (!options.no_cache) {
    68	    const hit = await cache.get<QbInvoice>(key);
    69	    if (hit !== null) return hit;
    70	  }
    71	  // Single-entity read returns { Invoice: {...} } (not wrapped in QueryResponse)
    72	  const res = await client.request<{ Invoice: QbInvoice }>(
    73	    `/invoice/${encodeURIComponent(invoiceId)}`,
    74	  );
    75	  const inv = res.Invoice ?? null;
    76	  if (inv) await cache.set(key, inv, INVOICE_CACHE_TTL_MS);
    77	  return inv;
    78	}
    20	  max_results?: number;
    21	  no_cache?: boolean;
    22	  cache?: QbCache;
    23	}
    24	
    25	/** List payments. QB doesn't separate received vs sent at the type level — caller filters via TotalAmt sign + LinkedTxn presence if needed. */
    26	export async function listPayments(
    27	  client: QbClient,
    28	  options: ListPaymentsOptions = {},
    29	): Promise<QbPayment[]> {
    30	  const cache = options.cache ?? QbCache.fromEnv();
    31	  const start = options.start_position ?? 1;
    32	  const max = options.max_results ?? 100;
    33	  const key = `payments:start=${start}:max=${max}:since=${options.since ?? "all"}`;
    34	
    35	  if (!options.no_cache) {
    36	    const hit = await cache.get<QbPayment[]>(key);
    37	    if (hit !== null) return hit;
    38	  }
    39	
    40	  let query = "SELECT * FROM Payment";
    41	  if (options.since) {
    42	    query += ` WHERE TxnDate >= '${options.since}'`;
    43	  }
    44	  query += ` STARTPOSITION ${start} MAXRESULTS ${max}`;
    45	
    46	  const res = await client.request<QbQueryResponse<"Payment", QbPayment>>(
    47	    "/query",
    48	    { query: { query } },
    49	  );
    50	  const payments = res.QueryResponse.Payment ?? [];
    51	  await cache.set(key, payments, PAYMENTS_CACHE_TTL_MS);
    52	  return payments;
    53	}
    54	
    55	/**
    56	 * Write a payment received against an invoice. State-changing — emits
    57	 * action_type='accounting_reconciliation_write' (yellow tier per
    58	 * autosend-policy.yaml; documented in agents/recruitment/cash-conductor/agent.md §3).
    59	 *
    60	 * No retry on write failure — caller decides (Cash Conductor §4 Step 6
    61	 * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
    62	 */
    63	export async function writePaymentReceived(
    64	  client: QbClient,
    65	  payment: QbPaymentWriteRequest,
    66	): Promise<QbPayment> {
    67	  // QB POST /payment returns { Payment: {...} } (not wrapped in QueryResponse)
    68	  const res = await client.request<{ Payment: QbPayment }>("/payment", {
    69	    method: "POST",
    70	    body: payment,
    71	    max_retries: 0,
    72	  });
    73	  if (!res.Payment) {
    74	    throw new Error(
    75	      "QuickBooks POST /payment succeeded but response contained no Payment record",
    76	    );
    77	  }
    78	  return res.Payment;
    79	}

exec
/bin/zsh -lc 'pnpm --dir packages/mcp-connectors/quickbooks typecheck' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'pnpm --dir packages/mcp-connectors/quickbooks test' in /Users/madsadmin/code/CortexOS
 succeeded in 1947ms:

> @ifos/quickbooks@0.1.0 typecheck /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks
> tsc --noEmit


 succeeded in 3776ms:

> @ifos/quickbooks@0.1.0 test /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks
> vitest run


 RUN  v2.1.9 /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks

 ✓ tests/rate-limit.test.ts (5 tests) 23ms
 ✓ tests/scaffold.test.ts (5 tests) 3ms
 ✓ tests/auth.test.ts (7 tests) 100ms
 ✓ tests/capabilities.test.ts (9 tests) 1125ms
   ✓ quickbooks capabilities — invoices > listOpenInvoices: persistent 429 surfaces as QbRateLimitError after retries 493ms
   ✓ quickbooks capabilities — payments > listPayments: persistent 500 surfaces as QbError after retries 451ms

 Test Files  4 passed (4)
      Tests  26 passed (26)
   Start at  12:20:09
   Duration  2.78s (transform 354ms, setup 0ms, collect 584ms, tests 1.25s, environment 1ms, prepare 459ms)


codex
The capability code has one substantive risk already: the read helpers interpolate caller-controlled date strings directly into QuickBooks SQL-like query strings. I’m waiting on the package checks to see whether there are additional hard failures.
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/README.md | sed -n '1,245p'; nl -ba agents/recruitment/cash-conductor/tools.yaml | sed -n '55,95p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '155,170p;235,248p'" in /Users/madsadmin/code/CortexOS
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
    31	| `QbClient` (class) | Transport — constructed once by cycle.sh Step 1; per-realm URL construction (production vs sandbox) |
    32	| `loadTokens(config)` / `saveTokens(config, t)` | Token-file I/O — called by `refreshTokens`; surfaced for test setup and operator consent-bootstrap |
    33	| `shouldRefresh(tokens, now?, window?)` | Pure predicate — `true` when the access_token expires within `safety_window_ms` (default 5 min) |
    34	| `refreshTokenNearExpiry(tokens, now?, danger?)` | Pure predicate — `true` when the **refresh** token expires within the 7-day re-consent danger window (QB ~100-day TTL); operator alerting hook |
    35	| `rateCheck(realm_id, now?)` | Returns `RateState` — exposes the **soft-backoff signal** (`shouldBackoff: true` at 80% of the minute bucket); consuming cycle.sh is responsible for honouring it (see §Rate limits) |
    36	| `rateConsume(realm_id, now?)` | Consumes a slot; returns false at the hard 100% gate |
    37	| `resetRateLimit(realm_id?)` | Test/diagnostic reset |
    38	| `_resetInflightForTest()` | Clears in-flight OAuth-refresh dedup map; for tests only |
    39	| `QbCache` (class) | Disk cache — default TTL 5min |
    40	
    41	---
    42	
    43	## Quick start
    44	
    45	```typescript
    46	import { QbClient, listOpenInvoices, writePaymentReceived } from "@ifos/quickbooks";
    47	
    48	const client = new QbClient({
    49	  config: {
    50	    client_id: process.env.QB_CLIENT_ID!,
    51	    client_secret: process.env.QB_CLIENT_SECRET!,
    52	    realm_id: "<realmId-from-connections-callback>",
    53	    environment: "sandbox", // or "production"
    54	    token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/qb-tokens-<realmId>.json`,
    55	  },
    56	});
    57	
    58	const invoices = await listOpenInvoices(client, { issued_since: "2026-04-01" });
    59	for (const inv of invoices) {
    60	  if (matchesBankDeposit(inv)) {
    61	    await writePaymentReceived(client, {
    62	      CustomerRef: { value: inv.CustomerRef.value },
    63	      TotalAmt: inv.Balance,
    64	      TxnDate: "2026-05-22",
    65	      PaymentRefNum: bankReference,
    66	      Line: [
    67	        {
    68	          Amount: inv.Balance,
    69	          LinkedTxn: [{ TxnId: inv.Id, TxnType: "Invoice" }],
    70	        },
    71	      ],
    72	    });
    73	  }
    74	}
    75	```
    76	
    77	---
    78	
    79	## OAuth bootstrap (one-time, per QB Online company / realm)
    80	
    81	Unlike Xero (one connection = one tenant_id sent as header), QuickBooks is **per-realm**: each connected company has a unique `realmId`, and tokens are realm-scoped. If you connect IFOS to 3 different QB companies, you have 3 separate token bundles + 3 separate base URLs (`/v3/company/<realmId>/...`).
    82	
    83	**Bootstrap procedure (manual, one-time per QB company):**
    84	
    85	1. Register the IFOS app at https://developer.intuit.com/ → get `client_id` + `client_secret`.
    86	2. Construct the authorise URL with `scope=com.intuit.quickbooks.accounting` + `response_type=code` + your `redirect_uri`.
    87	3. User clicks → consents → Intuit redirects to `redirect_uri?code=<auth_code>&realmId=<realm>&state=...`.
    88	4. POST to `https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer` with Basic auth (Base64 client_id:client_secret) + `grant_type=authorization_code` + the code → receive `{access_token, refresh_token, expires_in, x_refresh_token_expires_in}`.
    89	5. The `realmId` from step 3's redirect IS the realm — save it alongside the tokens.
    90	6. Write the token bundle to `token_file_path` as JSON; mode 0600. The connector handles all subsequent rotations.
    91	
    92	**Key QB vs Xero diffs:**
    93	
    94	| | Xero | QuickBooks |
    95	|---|---|---|
    96	| Per-tenant identifier | `tenant_id` (header `Xero-tenant-id`) | `realmId` (path component) |
    97	| Token endpoint | `https://identity.xero.com/connect/token` | `https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer` |
    98	| Access token TTL | 30 min | ~60 min |
    99	| Refresh token TTL | 60 days (rolls) | ~100 days (rolls) — `x_refresh_token_expires_in` returned in response |
   100	| Base URL | `https://api.xero.com/api.xro/2.0` (constant) | `https://quickbooks.api.intuit.com/v3/company/<realmId>` (production) or `https://sandbox-quickbooks.api.intuit.com/...` (sandbox) |
   101	| Read pattern | REST resource endpoints (e.g. `/Invoices?where=...`) | Query API: `GET /query?query=SELECT * FROM Invoice WHERE ...` |
   102	| Write pattern | PUT `/Payments` (entity endpoint) | POST `/payment` (entity endpoint) |
   103	
   104	After bootstrap, this connector's `refreshTokens()` handles all subsequent rotations automatically. Note that QB refresh tokens have a hard ~100-day TTL — if no refresh happens for that long, you must re-do the consent dance. `refreshTokenNearExpiry()` returns true when within the 7-day danger window so operator alerts can fire.
   105	
   106	---
   107	
   108	## Rate limits
   109	
   110	Per the published Intuit limits page (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):
   111	
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
   143	---
   144	
   145	## Error hierarchy
   146	
   147	```
   148	QbError                  // base
   149	├── QbAuthError          // OAuth refresh fail (401/4xx on token endpoint)
   150	├── QbRateLimitError     // 429 OR local bucket exhausted
   151	├── QbNotFoundError      // 404
   152	└── QbValidationError    // 400 (typically Fault.type=ValidationFault)
   153	```
   154	
   155	Errors NEVER include credential values in their `.message` — only the key NAMES, status code, and safe metadata. Per `review-mcp-connector.md` §5 (zero secret interpolation).
   156	
   157	---
   158	
   159	## Tests
   160	
   161	```bash
   162	# Unit + fixture tests (fast; no network)
   163	pnpm test
   164	```
   165	
   166	**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.
   167	
   168	**Live tests are deferred** to the first commercial QB sandbox signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal per review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold lands in the same commit as the first sandbox credentials.
   169	
   170	Test counts:
   171	- `tests/scaffold.test.ts`: 5 (public surface, exports, error hierarchy)
   172	- `tests/rate-limit.test.ts`: 5 (initial state, soft 400, hard 500, per-realm isolation, etc.)
   173	- `tests/auth.test.ts`: 7 (load missing, round-trip, shouldRefresh, refreshTokenNearExpiry, refresh success, 401 + no-token-leak, concurrent dedup)
   174	- `tests/capabilities.test.ts`: 9 (list/get invoice happy + 404, list/write payment happy + 400, **listOpenInvoices 429 retry-exhaust, listPayments 500 retry-exhaust, 401-forces-refresh-then-retry** — all 3 added per Codex F-R1/F-R2)
   175	
   176	**Total: 26 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
   177	
   178	---
   179	
   180	## Build
   181	
   182	```bash
   183	pnpm build       # tsup → dist/index.{js,d.ts}
   184	pnpm typecheck   # tsc --noEmit
   185	```
   186	
   187	ESM-only; node 20+; target ES2022. Same toolchain as @ifos/companies-house + @ifos/xero.
   188	
   189	---
   190	
   191	## Where this fits in the IFOS architecture
   192	
   193	```
   194	agents/recruitment/cash-conductor/cycle.sh
   195	   │
   196	   ├── Step 1 (auth refresh)            ──┐
   197	   ├── Step 4 (invoice register ingest) ──┤
   198	   ├── Step 5 (reconciliation pass)     ──┼─→ @ifos/quickbooks (this package)
   199	   ├── Step 6 (reconciliation write)    ──┤    │
   200	   └── Step 9 (chase-draft validation)  ──┘    │
   201	                                              ↓
   202	                                         QuickBooks Online v3 REST API
   203	                                         https://quickbooks.api.intuit.com/v3/company/<realmId>
   204	                                              ↓
   205	                                         OAuth bearer (no tenant header — realm in URL)
   206	```
   207	
   208	Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) **landed at the scaffold layer 2026-06-01** (commits 6ab59d8 + 5ab2f0f) with SKELETON TODO(W7-8) markers throughout. The W7-8 build slice replaces the TODOs with live impl; this connector is the accounting substrate it consumes (alongside @ifos/xero — Sage deferred per Cash Conductor §9 Q8). Per Cash Conductor agent.md §8, production-readiness still gates on Hire #1 + accounting commercial signups.
   209	
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
   221	
   222	*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*
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
    93	  # Sage MCP connector deferred per Cash Conductor §9 Q8 (first-pilot-on-Sage trigger).
    94	
    95	  # ────────────────────────────────────────────────────────────────────────
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

codex
Typecheck and unit tests pass, so I’m narrowing the rejection candidates to substantive contract problems rather than general package health. One more build run will catch declaration-generation issues that `tsc --noEmit` can miss in this setup.
exec
/bin/zsh -lc "rg -n \"console\\.(log|error|warn).*\\"'$'"\\{.*(KEY|SECRET|PASSWORD|TOKEN|BEARER)|throw\\s+new\\s+Error.*\\"'$'"\\{.*(KEY|SECRET|PASSWORD)\" packages/mcp-connectors/quickbooks -S" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"MCP_LIVE_TESTS|describe\\.skipIf|fetch\\(|https://|http://\" packages/mcp-connectors/quickbooks/tests packages/mcp-connectors/quickbooks/src -S" in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
 succeeded in 0ms:
packages/mcp-connectors/quickbooks/src/client.ts:18:export const QB_BASE_URL_PRODUCTION = "https://quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:19:export const QB_BASE_URL_SANDBOX = "https://sandbox-quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/rate-limit.ts:2:// (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):
packages/mcp-connectors/quickbooks/src/auth.ts:11://   - Endpoint: https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer
packages/mcp-connectors/quickbooks/src/auth.ts:12://     (vs Xero's https://identity.xero.com/connect/token)
packages/mcp-connectors/quickbooks/src/auth.ts:27:const QB_TOKEN_ENDPOINT = "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer";
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:34:    expect(QB_BASE_URL_PRODUCTION).toBe("https://quickbooks.api.intuit.com");
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:35:    expect(QB_BASE_URL_SANDBOX).toBe("https://sandbox-quickbooks.api.intuit.com");
packages/mcp-connectors/quickbooks/src/types.ts:3:// Reference: https://developer.intuit.com/app/developer/qbo/docs/api/accounting/most-commonly-used/invoice

exec
/bin/zsh -lc 'pnpm --dir packages/mcp-connectors/quickbooks build' in /Users/madsadmin/code/CortexOS
 succeeded in 1684ms:

> @ifos/quickbooks@0.1.0 build /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks
> tsup

CLI Building entry: src/index.ts
CLI Using tsconfig: tsconfig.json
CLI tsup v8.5.1
CLI Using tsup config: /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks/tsup.config.ts
CLI Target: node20
CLI Cleaning output folder
ESM Build start
ESM dist/index.js     14.04 KB
ESM dist/index.js.map 36.23 KB
ESM ⚡️ Build success in 33ms
DTS Build start
DTS ⚡️ Build success in 650ms
DTS dist/index.d.ts 8.77 KB

codex
Build passes as well. I’m checking the artifact’s load-bearing citations now; the README relies on several external section claims, and fabricated or stale section references are explicitly ratification failures.
exec
/bin/zsh -lc "rg --files | rg 'master|ULTRAPLAN|ultraplan|operational-hygiene|ratification|review-mcp-connector|review-mcp'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
logs/codex-ratification.jsonl
docs/operations/codex-ratification-guide.md
docs/operations/codex-ratification-execution-plan.md
docs/decisions/2026-05-18-codex-ratification-manifest.md
docs/runbooks/operational-hygiene-protocol.md
docs/specs/ULTRAPLAN.md
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
scripts/run-codex-ratification.sh
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T112636Z-79455/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T112636Z-79455/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T112636Z-79455/agents_recruitment_diagnostic_agent-md.verdict.txt
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
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.prompt.md
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.output.md
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.verdict.txt
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
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
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.verdict.txt
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
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
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
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/manual-cluster-e/REPORT.md
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T100648Z-11041/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T100648Z-11041/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_xero.verdict.txt
logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_xero.prompt.md
logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_quickbooks.prompt.md
logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_quickbooks.output.md
logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_xero.output.md
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T100618Z-10738/docs_decisions_ADR-005-week-3-diagnostic-acceleration-md.prompt.md
logs/codex-ratification/20260524T100618Z-10738/docs_decisions_ADR-005-week-3-diagnostic-acceleration-md.output.md
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T100618Z-10709/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T100618Z-10709/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_open-banking.output.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_open-banking.prompt.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_quickbooks.verdict.txt
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_open-banking.verdict.txt
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_xero.verdict.txt
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_xero.prompt.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_quickbooks.prompt.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_quickbooks.output.md
logs/codex-ratification/20260602T105413Z-29512/packages_mcp-connectors_xero.output.md
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md

exec
/bin/zsh -lc "rg -n \"§8\\.2|§8\\.1|A4|QuickBooks|quickbooks|Day-25|Day-26|W4|W7|review-mcp-connector|Pre-build connector|Live tests\" docs agents .codex packages -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:151:  # per Codex cluster F Round 1 — review-mcp-connector §7 requires
agents/_shared/autosend-policy.yaml:163:  quickbooks_oauth:
agents/_shared/autosend-policy.yaml:166:    reason: "QuickBooks Online OAuth 2.0 refresh — idempotent token rotation against oauth.platform.intuit.com; @ifos/quickbooks connector handles concurrent-refresh dedup per-realm; QB refresh tokens have ~100-day TTL so operator alerting on refreshTokenNearExpiry() is the consumer's responsibility, not this action_type's."
agents/_shared/autosend-policy.yaml:178:    reason: "Plaid UK OAuth 2.0 refresh — v1.1+ stub; never fires v1.0. Registered now so the README + tools.yaml capability declarations have a matching policy entry per review-mcp-connector §7 set-equality."
agents/_shared/autosend-policy.yaml:245:    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
.codex/ratification/review-agent-bundle.md:19:| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
.codex/ratification/review-agent-bundle.md:24:| §7 | Voice + tone constraints | `_shared/voice-loader.sh` integration; per-tenant scope; voice classifier threshold per agent.md §5 | Missing for agents that produce text output; threshold drift from master brief §8.1 Change 1 |
.codex/ratification/review-agent-bundle.md:26:| §9 | Status + open questions | Numbered list of founder-review questions; each has a resolution path (founder review at next Sunday OR pilot tenant onboarding OR commercial conversation) | Missing; questions are vague (no resolution path); doesn't acknowledge gotchas from corresponding ULTRAPLAN §8.1 A-N spec |
.codex/ratification/review-agent-bundle.md:37:1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
.codex/ratification/review-agent-bundle.md:38:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
.codex/ratification/review-agent-bundle.md:129:- "§8 prereq list missing the voice classifier microservice as W4-5 dependency"
.codex/ratification/review-mcp-connector.md:1:# Codex ratification skill — review-mcp-connector
.codex/ratification/review-mcp-connector.md:19:Pre-build connector exception: if the connector is W4-W7 scaffold (no agent yet), check #3 may be empty; checks #1 + #2 must still match.
.codex/ratification/review-mcp-connector.md:23:Connectors that handle OAuth (Xero / QuickBooks / Bullhorn / TrueLayer / Plaid / Microsoft Graph / Gmail) MUST:
.codex/ratification/review-mcp-connector.md:134:- **Pre-build connector with `MCP_LIVE_TESTS` not yet wired:** acceptable IF README marks the live tests as "wired at first commercial signup." Note as advisory not REJECT.
.codex/ratification/review-mcp-connector.md:151:*End of review-mcp-connector skill.*
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:20:# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:67:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:80:          W4 polish may add controlled-vocabulary clustering. Max 20 items
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:411:    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:647:      INTENT (W4-polish enforcement required): 7-year retention with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:651:      pseudonymization + purge implementation is a W4-polish slice (pg_cron
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:655:      implementation lands as W4 polish. Per-tenant DPA addendum signed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:666:      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:667:      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:680:      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:686:      INTENT (W4-polish enforcement required): 7-year retention with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:689:      pseudonymization + purge implementation is a W4-polish slice
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:693:      W4 polish, production use of cash_conductor_invoices is GATED by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:821:      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:838:      schema declaration in v0.3 supplement is added Day-20 W4 bilateral pass
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:851:      declaration is the canonical schema authority added in W4 bilateral pass
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:854:  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:856:  # declare this config key; the W4 ADR will introduce both the field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:867:  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:874:    schema_owner: future W4-polish supplement (not v0.3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:881:      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:995:      override. Pseudonymization implementation lands in W4-polish slice.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1023:  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1037:      residual gaps are tracked in W4-polish-schema-extension backlog;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1043:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
packages/diagnostic-generator/src/generate.ts:49:    `**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).`,
packages/utilities/web-scraper/README.md:9:- `googleSearch(query)` — stub for v0; W4 polish wires SerpAPI or alternative
.codex/ratification/SKILL.md:101:- `review-mcp-connector.md` — for new connectors under `packages/mcp-connectors/`
.codex/ratification/review-architecture-decision.md:112:## §7 — Decision_log audit fields (master brief §8.1 Change 2)
.codex/ratification/review-schema-change.md:34:- `v1_0_agent_access` — list of agents from master brief §8.2 with R / W / R+W disposition, OR explicit "none (v1.1+ exercise)"
agents/_shared/escalation-codes.md:4:**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:118:Source: master brief §8.1 Change 3 lines 585-592
agents/_shared/escalation-codes.md:129:- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:285:- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
agents/_shared/escalation-codes.md:465:| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:180:- `docs/build-brief/00-MASTER-BRIEF.md` §8.1 Changes 2+3 — decision-log + ESC vocabulary
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
packages/utilities/web-scraper/src/fetcher.ts:121: * alternative is wired at W4 polish per tools.yaml.
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:35:# source-tree execution (Day-13 + Day-25 Hays smoke) prints "policy file
agents/_shared/hook-helpers.sh:189:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/voice-loader.sh:4:# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
packages/diagnostic-generator/src/sections/recent-activity.ts:55:    "**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.",
packages/utilities/web-scraper/pnpm-lock.yaml:166:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:220:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/utilities/web-scraper/pnpm-lock.yaml:436:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/utilities/web-scraper/pnpm-lock.yaml:517:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/utilities/web-scraper/pnpm-lock.yaml:703:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/utilities/web-scraper/pnpm-lock.yaml:773:    resolution: {integrity: sha512-34wB/Y7MW7bzjKRjUKTa46I2Z7eV62Rkhva+KkopW7Qvv/OSWBqvkSY7vusOPrNuZcUG3tApvdVgNB8POj3SPw==}
packages/utilities/web-scraper/pnpm-lock.yaml:1004:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
docs/operations/goal-overnight-2026-05-31.md:1:# /goal — Overnight W4 Track-1 + smoke-fix (2026-05-31 → 2026-06-01)
docs/operations/goal-overnight-2026-05-31.md:16:2. `docs/operations/goal-week-4-track-1.md` §0 + §2 + §9 (canonical W4 spec)
docs/operations/goal-overnight-2026-05-31.md:26:### 2. `.codex/ratification/review-mcp-connector.md` Codex skill (~90 min)
docs/operations/goal-overnight-2026-05-31.md:48:### 4. (stretch) `packages/mcp-connectors/quickbooks/` (~3-4 hours)
docs/operations/goal-overnight-2026-05-31.md:54:Update `.agents/current-priorities.md` (W4-day-25-overnight section) with shipped items + smoke outcome + 2 path bugs fixed + Anthropic-credit founder-action queued + next-step on pickup. Commit.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:1:# /goal — W4 Day-26 afternoon: bundle completion + bridge + polish (2026-06-01)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:6:Morning goal + this goal's §1 · `agents/recruitment/cash-conductor/agent.md` §3+§4+§5 (consumer spec) · `packages/mcp-connectors/{xero,quickbooks,open-banking}/` (pattern) · `docs/decisions/2026-05-31-d1-founder-decision.md` §"Implementation surface" (bridge contract) · `agents/_shared/{hook-helpers.sh,autosend-policy.yaml}` (existing helpers + action_type registry) · `agents/recruitment/diagnostic/{context,cleanup}.sh` (sibling pattern for Phase A files).
packages/harness/cortextos/package-lock.json:194:      "integrity": "sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==",
packages/harness/cortextos/package-lock.json:245:      "integrity": "sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==",
packages/harness/cortextos/package-lock.json:466:      "integrity": "sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==",
packages/harness/cortextos/package-lock.json:805:      "integrity": "sha512-zYyqWgGQi3NhBcNq4Isc5rB3oEdQEh1Q/EcAnOW0FK4MpnXWkvSBYgA4cYrTM4A9UB573omouZbnL9JJ74Mq3A==",
packages/harness/cortextos/package-lock.json:828:      "integrity": "sha512-aetVUNeKNc/VriqXlw1NRSW0zhMBB0W4bNbWRJgzRl/3d0QNDQFfk0GO5SDdtjMZVg6o8ZKEiadd7SCCzoOn5Q==",
packages/harness/cortextos/package-lock.json:1275:      "integrity": "sha512-L+34Qqil+v5uC0zEubW7uByo78WOCIrBvci69E7sFASRl0X7b/MB6Cqd1lky/CtcSVTydWa2WZwFuWexjS5o6g==",
packages/harness/cortextos/package-lock.json:1331:      "integrity": "sha512-VSvgvQeIcsEvY4bKDHEDWcpW4Yw7BtlKG1GUT4FzBUlEKQK0rWHYBqQt6Fm2taXS+1bXvJT6kICu5ZwqKCnvlQ==",
packages/harness/cortextos/package-lock.json:1485:      "integrity": "sha512-i1okWYkA4FJICtr7KpYzFpRTHgy5jdDbZiWfvny21iIKky5YExiDXP+zbXzm3dUcFpkEeYNHgQ5fuG236JPq0g==",
packages/harness/cortextos/package-lock.json:1513:      "integrity": "sha512-k+600V9Zl1CM7eZxJgMyTUzmrmhB/0XZnF4pRypKAlAgxmedUA+1v9R+XOFv56W4SlHEzfeMtzujLJD22Uz5zg==",
packages/harness/cortextos/package-lock.json:1612:      "integrity": "sha512-Ize4iQtEALHDttPRCmN+FKqOl2vxTiNUhzobQFFt/BM1lRUTG7zRCLOykG/6Vo4E4hnUdfVLo5/eqKPukcWW7Q==",
packages/harness/cortextos/package-lock.json:1720:      "integrity": "sha512-Bq3SmSpyFHaWjPk8If9yc6svM8c56dB5BAtW4Qbw5jHTwwXXcTLoRMkpDJp6VL0XzlWaCHTXrkFURMYmD0sLqg==",
packages/harness/cortextos/package-lock.json:2118:      "integrity": "sha512-34wB/Y7MW7bzjKRjUKTa46I2Z7eV62Rkhva+KkopW7Qvv/OSWBqvkSY7vusOPrNuZcUG3tApvdVgNB8POj3SPw==",
packages/harness/cortextos/package-lock.json:2943:      "integrity": "sha512-6hJPQ8N0V0P3SNmP6h2J99RLuzrWz2gvT7VnK5tKvrNqJoyS9W4/Fb8mo31UiPvy00z7DQXkP2hnKBVav76thw==",
packages/harness/cortextos/package-lock.json:3149:      "integrity": "sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==",
agents/recruitment/cash-conductor/cleanup.sh:2:# Cash Conductor agent — cleanup.sh (post-run state purge; W4 Day-26 SKELETON)
agents/recruitment/cash-conductor/cleanup.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
agents/recruitment/cash-conductor/cleanup.sh:13:# for registration at W7-8 build start (per tools.yaml status table). Once
agents/recruitment/cash-conductor/cleanup.sh:14:# registered + the W7-8 build wires the real purge logic, this script emits
agents/recruitment/cash-conductor/cleanup.sh:23:# Side effects (W7-8 build slice):
agents/recruitment/cash-conductor/cleanup.sh:25:#   - Purge ~/.ifos-cache/quickbooks/* older than 24h
agents/recruitment/cash-conductor/cleanup.sh:28:#   - Reset in-process rate-limit buckets via @ifos/{xero,quickbooks,open-banking} resetRateLimit()
agents/recruitment/cash-conductor/cleanup.sh:77:# Exported so the W7-8 build-slice can extend the find -delete logic via
agents/recruitment/cash-conductor/cleanup.sh:80:export QB_CACHE_DIR="${IFOS_QB_CACHE_DIR:-${HOME}/.ifos-cache/quickbooks}"
agents/recruitment/cash-conductor/cleanup.sh:83:# TODO(W7-8): replace these STUB counts with actual find -delete invocations
agents/recruitment/cash-conductor/cleanup.sh:98:# Deferred to W7-8 build (analytical signal; not blocking).
agents/recruitment/cash-conductor/cleanup.sh:107:# TODO(W7-8): once cash_conductor_cleanup action_type is registered in
packages/diagnostic-generator/src/sections/stubs.ts:26:    "**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.",
packages/diagnostic-generator/src/sections/stubs.ts:40:    "**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:57:    "**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:67:    "**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:100:      "**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).",
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:18:# Status: Proposed (W4 Day-26 SKELETON).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:17:--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:19:--     does NOT extend the payload shape; the W4 ADR will add both the new
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:141:    accounting_provider IN ('xero', 'quickbooks', 'sage')
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:  -- diagnostic_per_claim_sample_rate DEFERRED to W4-polish ADR; not validated
packages/diagnostic-generator/src/sections/conversation-opener.ts:6:// (W4-5 polish wires it; for now §12 ships LLM-generated text without
packages/diagnostic-generator/src/sections/conversation-opener.ts:25:  // Voice corpus context (optional; W4-5 polish wires real corpus)
packages/diagnostic-generator/src/sections/conversation-opener.ts:259:      "**Generation:** LLM-driven (Claude API + evidence context). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0 scaffold; W4-5 polish wires real classifier.",
packages/diagnostic-generator/src/sections/conversation-opener.ts:263:      "**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.",
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:20:# Status: Proposed (W4 Day-26 SKELETON).
packages/diagnostic-generator/src/sections/icp-fit.ts:3:// (sector match + size-band proxy). Full multi-dimension scoring at W4.
packages/diagnostic-generator/src/sections/icp-fit.ts:77:    "**v0 limitation:** geography + deal_size_band scoring requires LinkedIn job-post data. Wire Proxycurl (W4 polish).",
docs/operations/goal-week-4-track-1.md:3:**Status:** Authored 2026-05-31 (Day 25 / W4 Day-2); ready for execution.
docs/operations/goal-week-4-track-1.md:4:**Type:** Goal prompt (paste into Claude Code at session start; executor runs to completion across W4 Days 3-7, target 2026-06-01 → 2026-06-05).
docs/operations/goal-week-4-track-1.md:5:**Master plan citations:** Master brief §8.2 (build wave W4 Cash Conductor MCP connectors) + ULTRAPLAN §8.1 A4 (Cash Conductor spec lines 531-545) + ADR-005 (Week-3 acceleration → Cash Conductor pulled forward to W4 substrate) + `agents/recruitment/cash-conductor/agent.md` §8 build dependencies + `docs/decisions/2026-05-31-d1-founder-decision.md` (D1-B resolved) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic live render by 2026-06-14).
docs/operations/goal-week-4-track-1.md:16:2. **`.agents/current-priorities.md`** Open + Day-25 sections (this goal opens W4 Track 1)
docs/operations/goal-week-4-track-1.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §8.2 W4-W7 rows + §10 (ratification cadence + always-ratify list) + §10.5
docs/operations/goal-week-4-track-1.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A4 lines 531-545 (Cash Conductor spec) + §10 risk rows referencing Open Banking 90-day token rotation
docs/operations/goal-week-4-track-1.md:31:After reading: post in chat **"Read order complete. Five rules: [verbatim]. Four boundaries: [verbatim]. W4 Track 1 scope: Xero + QuickBooks + Open Banking MCP connectors + Cash Conductor bundle scaffold + Diagnostic live-smoke wrapper + review-mcp-connector Codex skill + cluster F manifest. Ready to begin Step 1."**
docs/operations/goal-week-4-track-1.md:35:## §1 — Success state (what "done" looks like at end of W4 Track 1)
docs/operations/goal-week-4-track-1.md:42:2. **`packages/mcp-connectors/quickbooks/`** exists; same shape as Xero. Capabilities mirrored. ≥12 vitest passing. README documents QB rate-limit (500/min throttled).
docs/operations/goal-week-4-track-1.md:44:4. **Sage MCP connector — DEFERRED** per Cash Conductor §9 Q8 recommendation; documented in W4-5 backlog as "rebuild at first pilot tenant on Sage."
docs/operations/goal-week-4-track-1.md:52:9. **`agents/recruitment/cash-conductor/tools.yaml`** exists; declares: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram` (per D1-B).
docs/operations/goal-week-4-track-1.md:63:### Codex `review-mcp-connector.md` skill (Day 1)
docs/operations/goal-week-4-track-1.md:65:13. **`.codex/ratification/review-mcp-connector.md`** exists. Type-specific skill for MCP connector packages. Adds checks on top of SKILL.md: OAuth refresh idempotency; rate-limit budget declared; explicit retry policy; secrets never logged; fixture-first tests; integration with `_shared/hook-helpers.sh` for decision_log emissions. Modeled on `review-agent-bundle.md` length + structure.
docs/operations/goal-week-4-track-1.md:71:    - `packages/mcp-connectors/quickbooks/`
docs/operations/goal-week-4-track-1.md:78:16. **`.agents/current-priorities.md`** updated with W4 Track 1 close section.
docs/operations/goal-week-4-track-1.md:81:19. **All commits pushed.** Atomic per-package per Day-21 + Day-25 pattern.
docs/operations/goal-week-4-track-1.md:92:| QuickBooks MCP connector | §1 success criterion 2; second-most-likely |
docs/operations/goal-week-4-track-1.md:96:| `review-mcp-connector.md` Codex skill | §1 criterion 13; needed before cluster F can ratify the new connectors |
docs/operations/goal-week-4-track-1.md:105:| Diagnostic voice classifier microservice | Separate W4-5 polish goal; deferred until Anthropic key live + first pilot voice corpus seeded |
docs/operations/goal-week-4-track-1.md:138:### DAY 1 — Substrate verification + review-mcp-connector skill + Diagnostic live-smoke wrapper
docs/operations/goal-week-4-track-1.md:159:#### Step 2 — Author `review-mcp-connector.md` Codex skill (~1.5 hours)
docs/operations/goal-week-4-track-1.md:161:Create `.codex/ratification/review-mcp-connector.md` modeled on `review-agent-bundle.md`. The skill ADDS these checks on top of `SKILL.md`:
docs/operations/goal-week-4-track-1.md:173:Commit: `feat(codex-skill): review-mcp-connector.md for cluster F ratification`
docs/operations/goal-week-4-track-1.md:229:Acceptance per `review-mcp-connector.md` skill:
docs/operations/goal-week-4-track-1.md:237:### DAY 3 — QuickBooks MCP connector
docs/operations/goal-week-4-track-1.md:239:#### Step 5 — Scaffold `packages/mcp-connectors/quickbooks/` (~3-4 hours)
docs/operations/goal-week-4-track-1.md:245:Commit: `feat(mcp/quickbooks): scaffold @ifos/quickbooks MCP connector — fixture-first parity with xero`
docs/operations/goal-week-4-track-1.md:276:- `agents/recruitment/cash-conductor/tools.yaml` — capability declarations: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram`
docs/operations/goal-week-4-track-1.md:296:packages/mcp-connectors/quickbooks|mcp-connector
docs/operations/goal-week-4-track-1.md:305:Commit: `feat(codex-harness): add cluster F for W4 Track-1 connectors + Cash Conductor bundle`
docs/operations/goal-week-4-track-1.md:321:### DAY 7 — State + manifest sync + W4 Track-1 close
docs/operations/goal-week-4-track-1.md:325:1. **`.agents/current-priorities.md`** — W4 Track 1 close section. List shipped artefacts. Update Open backlog: W4 Track 2 (Bullhorn-dependent agents — Janitor/Scribe) conditional on Bullhorn A+B Accepted; Cash Conductor full live test conditional on accounting/Open Banking commercial signups; Diagnostic live render gated on API keys.
docs/operations/goal-week-4-track-1.md:329:Commit: `state(w4-track-1-close): cluster F verdicts + W4 Track-2 backlog + risk register sync`
docs/operations/goal-week-4-track-1.md:398:Per master brief §10 + §10.3 step 5 hard ceiling + Day-25 Codex-cycle pattern.
docs/operations/goal-week-4-track-1.md:402:The new `review-mcp-connector.md` skill is itself an artefact subject to ratification. It ratifies via `review-architecture-decision.md` (skills are architectural artefacts). Add to next ratification cluster.
docs/operations/goal-week-4-track-1.md:444:W4 TRACK 1 COMPLETE — Cash Conductor MCP CONNECTORS + DIAGNOSTIC LIVE-SMOKE WRAPPER
docs/operations/goal-week-4-track-1.md:448:  @ifos/quickbooks:        <N> capabilities, <M> vitest, README <L> lines
docs/operations/goal-week-4-track-1.md:464:  .codex/ratification/review-mcp-connector.md: built; ratified via review-architecture-decision
docs/operations/goal-week-4-track-1.md:471:  <SHA>  feat(codex-skill): review-mcp-connector.md
docs/operations/goal-week-4-track-1.md:474:  <SHA>  feat(mcp/quickbooks): scaffold @ifos/quickbooks
docs/operations/goal-week-4-track-1.md:487:  ✓ ADR-005 — Cash Conductor pull-forward to W4 substrate
docs/operations/goal-week-4-track-1.md:488:  ✓ master brief §8.2 W4 row — Cash Conductor MCP connectors
docs/operations/goal-week-4-track-1.md:489:  ✓ ULTRAPLAN §8.1 A4 — Cash Conductor spec lines 531-545
docs/operations/goal-week-4-track-1.md:493:W4 Track 2 backlog (unchanged; conditional on Bullhorn A+B Accepted):
docs/operations/goal-week-4-track-1.md:494:  - Bullhorn MCP connector (W4-5 build chain)
docs/operations/goal-week-4-track-1.md:509:  - Approve W4 Track 2 entry condition (Bullhorn A+B Accepted) or pivot to next Track-1 slice (Diagnostic voice classifier microservice)?
docs/operations/goal-week-4-track-1.md:524:| 6 | Founder commercial signups delay live testing | Medium | All scaffolds work fixture-first; live testing deferred without blocking the W4 Track-1 close |
docs/operations/goal-week-4-track-1.md:529:## §12 — Definition of "W4 Track 1 complete"
docs/operations/goal-week-4-track-1.md:539:**Day 7 (2026-06-05) is the soft target. Day 9 (2026-06-07) is the hard cutoff** (W5 Janitor build starts then per master brief §8.2 if Bullhorn A+B has Accepted). If Day 9 hits without completion, escalate to founder review + scope-cut decision.
docs/operations/goal-week-4-track-1.md:543:*End of /goal prompt for W4 Track 1.*
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:13:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice wires the real
packages/utilities/autosend-bridge-telegram/README.md:5:**Status:** Proposed (W4 Day-26 scaffold, fully unit-tested; production wiring lands in the Concierge W10–13 build slice).
agents/recruitment/cash-conductor/cycle.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
agents/recruitment/cash-conductor/cycle.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
agents/recruitment/cash-conductor/cycle.sh:19:# Package dependencies (W4 Day-25/26 scaffolded; v0.1.0 fixture-first):
agents/recruitment/cash-conductor/cycle.sh:21:#   @ifos/quickbooks      — QuickBooks accounting provider
agents/recruitment/cash-conductor/cycle.sh:81:# consumed by the W4 Day-26 skeleton — wired at W7-8 build slice.
agents/recruitment/cash-conductor/cycle.sh:94:# W7-8 wires: @ifos/xero (or quickbooks) refreshTokens +
agents/recruitment/cash-conductor/cycle.sh:98:# TODO(W7-8): replace this STUB with actual provider refresh calls. Skeleton
agents/recruitment/cash-conductor/cycle.sh:120:# W7-8 wires: @ifos/open-banking listTransactionsSince — store in Postgres
agents/recruitment/cash-conductor/cycle.sh:125:  # TODO(W7-8): @ifos/open-banking listTransactionsSince(since=last_ingested_at)
agents/recruitment/cash-conductor/cycle.sh:133:# Reference: agent.md §4 Step 4. W7-8 wires: @ifos/xero or @ifos/quickbooks
agents/recruitment/cash-conductor/cycle.sh:138:  # TODO(W7-8): provider-aware (tenant_adapters.config.accounting_provider)
agents/recruitment/cash-conductor/cycle.sh:150:  # TODO(W7-8): match algorithm per agent.md §3 stages 1-5. SQL JOIN against
agents/recruitment/cash-conductor/cycle.sh:158:# Reference: agent.md §3 Output 1. W7-8 wires: @ifos/xero writePaymentReceived
agents/recruitment/cash-conductor/cycle.sh:159:# or @ifos/quickbooks writePaymentReceived; atomic per write; rollback on 4xx/5xx.
agents/recruitment/cash-conductor/cycle.sh:163:  # TODO(W7-8): per-match: accounting.writePaymentReceived(...) → emit per write
agents/recruitment/cash-conductor/cycle.sh:176:  # TODO(W7-8): SELECT overdue invoices; determine chase position 1-4 per §3.2;
agents/recruitment/cash-conductor/cycle.sh:191:  # TODO(W7-8): LLM call → write draft body to vault → emit:
agents/recruitment/cash-conductor/cycle.sh:203:  # TODO(W7-8): per draft → bash validate.sh <draft_path>; exit on fail.
agents/recruitment/cash-conductor/cycle.sh:220:  # TODO(W7-8): per draft iteration:
agents/recruitment/cash-conductor/cycle.sh:228:    # Production-shape call site (SKELETON; W7-8 build slice wires the per-draft
agents/recruitment/cash-conductor/cycle.sh:282:    : # TODO(W7-8): wire the per-draft loop above (steps 1–4); tsx CLI entrypoints land alongside in the same build slice
agents/recruitment/cash-conductor/cycle.sh:300:  # TODO(W7-8): webhook-driven; UPDATE cash_conductor_invoices SET ...
agents/recruitment/cash-conductor/cycle.sh:312:  # TODO(W7-8): re-query Step 5 for paid-since detection; ESC_AUTOSEND_RACE
agents/recruitment/cash-conductor/cycle.sh:320:# DSO metric (Gate B tracking) per ULTRAPLAN A4 line 539.
agents/recruitment/cash-conductor/cycle.sh:324:  # TODO(W7-8): SELECT decision_log + cash tables for 7-day window; compute
agents/recruitment/cash-conductor/cycle.sh:328:  printf '# Weekly cash-flow report — STUB\n\nTODO(W7-8): full §3 Output 3 6-section report.\n' > "${REPORT_PATH}" 2>/dev/null || true
agents/recruitment/cash-conductor/cycle.sh:339:# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')
docs/operations/w4-bilateral-pass-6-agent-md.md:1:# W4 bilateral pass — 6 agent.md scaffolds → RATIFIED
docs/operations/w4-bilateral-pass-6-agent-md.md:38:| 4 | Cash Conductor | 3 | Blocked partially by D1 (W4 #4) — pre-resolve docs-only items. |
docs/operations/w4-bilateral-pass-6-agent-md.md:40:| 6 | Concierge | 4 | Depends on Concierge-Gate-A ADR (W4 #3) — may defer to that ADR. |
docs/operations/w4-bilateral-pass-6-agent-md.md:50:  - **Codex says:** "Line 109 says `ESC_VOICE_DRIFT` is 'raised internally by §12 LLM step if classifier <0.75 after 3 retries,' but the generator README says v0 has 'No LLM-driven §12' and 'No voice classifier gate,' and `validate.sh` only calls the classifier once when `IFOS_VOICE_CLASSIFIER_URL` is set. Fix §4 to say voice drift is a `validate.sh` V3 concern in v0, with retries deferred to W4 if intended."
docs/operations/w4-bilateral-pass-6-agent-md.md:51:  - **Likely:** FIX-IN-PLACE. Rewrite §4 line 109 to scope to v0 (single-pass classifier on V3, no retries, no LLM §12). Add W4 forward-look as a parenthetical.
docs/operations/w4-bilateral-pass-6-agent-md.md:56:  - **Codex says:** "Lines 108 and 173 say `ESC_RATE_LIMIT_HIT` is raised for Companies House or LinkedIn 429s, but `cycle.sh` has no 429 catch or `hh_decision_action` path for that code; the generator CLI just exits generic on thrown errors. Fix by either implementing a 429 catch that emits `ESC_RATE_LIMIT_HIT`, or marking this as a W4/planned tools.yaml mapping rather than current v0 behaviour."
docs/operations/w4-bilateral-pass-6-agent-md.md:57:  - **Likely:** FIX-IN-PLACE + DEFER. Re-label both lines as W4-planned (mark with planned-W4 tag); implementation deferred to bundle-build slice.
docs/operations/w4-bilateral-pass-6-agent-md.md:68:  - **Codex says:** "Line 45 cites `validate.sh` lines 89-97 as saying 'W4 polish adds title + order check,' but those lines say only that exact heading matching is not implemented and 'At W3 build' it should tighten. Fix the citation wording to match the live file or remove the quoted claim."
docs/operations/w4-bilateral-pass-6-agent-md.md:74:  - **Codex says:** "Line 238 says Proxycurl/API choice is 'Resolved at W3 start before Companies House + LinkedIn MCP connectors authored,' while this Day-19 artefact and §8 lines 213-215 say the connector/web-scraper work is already shipped and Proxycurl is deferred. Fix Q3 to describe the current W4 Proxycurl/commercial decision path."
docs/operations/w4-bilateral-pass-6-agent-md.md:75:  - **Likely:** FIX-IN-PLACE. Rewrite Q3 to describe the actual Day-19 disposition (Proxycurl deferred; current W4 decision is whether to re-evaluate before pilot).
docs/operations/w4-bilateral-pass-6-agent-md.md:147:  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
docs/operations/w4-bilateral-pass-6-agent-md.md:213:  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
docs/operations/w4-bilateral-pass-6-agent-md.md:214:    - (a) Add Concierge-Gate-A-ADR to §10 Accepted blockers; flip Concierge agent.md → RATIFIED (but Status stays Proposed pending ADR). W4 #3 then writes the ADR + closes the loop.
docs/operations/w4-bilateral-pass-6-agent-md.md:247:- [ ] SCOPE-EXPAND items moved to W4 backlog with concrete next-action
docs/operations/w4-bilateral-pass-6-agent-md.md:257:- [ ] `.agents/current-priorities.md` updated with W4 Day-20 close
agents/recruitment/cash-conductor/README.md:3:**Status:** Proposed (Day-18 pre-W7-8-build scaffold).
agents/recruitment/cash-conductor/README.md:18:Full bundle at W7-8 build (~2 weeks per ULTRAPLAN A4 line 541):
agents/recruitment/cash-conductor/README.md:20:- `tools.yaml` — Xero / QuickBooks / Sage / Open Banking (TrueLayer or Plaid UK) MCP connectors
agents/recruitment/cash-conductor/README.md:22:- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
agents/recruitment/cash-conductor/README.md:27:- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
docs/operations/w4-day-20-founder-runbook.md:1:# W4 Day-20 founder runbook — v0.3 migration + bilateral pass
docs/operations/w4-day-20-founder-runbook.md:8:This runbook is the founder-action sequence for the first two W4 priorities.
docs/operations/w4-day-20-founder-runbook.md:113:6. Concierge (4 findings) — depends on Concierge-Gate-A ADR (W4 item #3)
docs/operations/w4-day-20-founder-runbook.md:117:- **FIX-IN-FOLLOW-UP** — defer to a numbered commit later in W4
docs/operations/w4-day-20-founder-runbook.md:131:W4 queue items #3 + #4. Concierge-Gate-A 30-min SLA hybrid ADR is needed
docs/operations/w4-day-20-founder-runbook.md:140:1. **No v0.3 wrapper existed.** W4 queue note flagged this (`(or wrapper for v0.2→v0.3 specifically)`). Wrapper now drafted at `scripts/run-v0.3-migration.sh`.
docs/operations/w4-day-20-founder-runbook.md:141:2. **PII purge v0.3 migration (`v0.2-to-v0.3-pii-purge.sql`) is separate** — gated on Founder Decision D3 + SeedLegals advisor input on retention period. NOT part of W4 item #1. Out of scope this session.
docs/operations/goal-w4-day-26-2026-06-01.md:1:# /goal — W4 Day-26 autonomous build (2026-06-01)
docs/operations/goal-w4-day-26-2026-06-01.md:16:6. `@ifos/quickbooks` MCP — mirror `@ifos/xero`; per-realm OAuth diff in README; ≥15 vitest (scaffold + rate-limit + auth/concurrent-dedup + capabilities); README ≥150 lines citing Intuit rate-limits verbatim; fixture-first.
docs/operations/goal-w4-day-26-2026-06-01.md:18:8. Cluster F manifest entry in `scripts/run-codex-ratification.sh` — xero + quickbooks + open-banking via `mcp-connector` skill. Cash Conductor bundle queued for next manifest update when scaffold lands.
agents/recruitment/cash-conductor/tools.yaml:3:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice may add per-tenant
agents/recruitment/cash-conductor/tools.yaml:14:# (current registrations verified W4 Day-25 for accounting_reconciliation_write
agents/recruitment/cash-conductor/tools.yaml:16:# queued for W7-8 build per agent.md §8 backlog).
agents/recruitment/cash-conductor/tools.yaml:30:    action_type: xero_oauth          # green tier; registration queued for W7-8
agents/recruitment/cash-conductor/tools.yaml:60:  - id: quickbooks_oauth
agents/recruitment/cash-conductor/tools.yaml:61:    package: "@ifos/quickbooks"
agents/recruitment/cash-conductor/tools.yaml:62:    purpose: "QuickBooks OAuth 2.0 refresh (per-realm; PSD2-distinct from Xero per-tenant)"
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
agents/recruitment/cash-conductor/tools.yaml:180:    action_type: cash_conductor_cleanup  # green tier; registration queued for cleanup.sh build at W7-8
agents/recruitment/cash-conductor/tools.yaml:185:# Action-type registration status (cross-reference autosend-policy.yaml at W7-8)
agents/recruitment/cash-conductor/tools.yaml:195:# QUEUED for registration at W7-8 build start:
agents/recruitment/cash-conductor/tools.yaml:197:#   quickbooks_oauth                   green
agents/recruitment/cash-conductor/tools.yaml:203:# Boundary check (per master brief §3 + review-mcp-connector.md §8)
agents/recruitment/cash-conductor/tools.yaml:210:#   marked QUEUED above for W7-8 build-start registration).
packages/harness/cortextos/dashboard/package-lock.json:546:      "integrity": "sha512-LwdZHpScM4Qz8Xw2iKSzS+cfglZzJGvofQICy7W7v4caru4EaAmyUuO6BGrbyQ2mYV11W0U8j5mBhd14dd3B0A==",
packages/harness/cortextos/dashboard/package-lock.json:926:      "integrity": "sha512-S48WzZW777zhNIrn7gxOlISNAqi9ZC/uQFnRdbeIHhZhCA6UqpkOT8T1G7BvfdgP4Er8gF4sUbaS0i7QvIfCWw==",
packages/harness/cortextos/dashboard/package-lock.json:1305:      "integrity": "sha512-Td76q7j57o/tLVdgS746cYARfSyxk8iEfRxewL9h4OMzYhbW4TAcppl0mT4eyqXddh6L/jwoM75mo7ixa/pCeQ==",
packages/harness/cortextos/dashboard/package-lock.json:2729:      "integrity": "sha512-Kd6kAHTA6/nUpp8mySPqj3en3dm0tdMIgbttnQ1xFMVpufoj+ADi8pXLBsd4xzTRHQa7t/Jv8W5UnCuW4kuWMQ==",
packages/harness/cortextos/dashboard/package-lock.json:3243:      "integrity": "sha512-4og1V+ftEPXGttOO7eCmW7VICmzzJWgMx+QXAJRAhjrSjumCwWqMfkDrNu1LXEQzNAwz28NCUpucgQPrR4S2yw==",
packages/harness/cortextos/dashboard/package-lock.json:3341:      "integrity": "sha512-qPmaQM4iKu5mxpsrWZMOZRgZv1tOZpUm+zdhhQP0VhJfyGGO3aUKdbh3gDZc/dPLQwW4eSqWGrrcWNBZWUWaXQ==",
packages/harness/cortextos/dashboard/package-lock.json:3515:      "integrity": "sha512-NcV1JjO5oDzoK26oMzbILE6HW7uVXOHLQvHshBUW4UMdZGfiY6v5BeQwh9a9tCzv+CeefZQHJt5SRgK154RtiA==",
packages/harness/cortextos/dashboard/package-lock.json:3521:      "integrity": "sha512-mgLPETlrpVV1YRJIglr4Ez47g7Yxjl1lj7YKsiMCb27VJH9W8NVM6Bb9d8kkpG/uAQS5AmbA48q2IAolKKo1MA==",
packages/harness/cortextos/dashboard/package-lock.json:3530:      "integrity": "sha512-VMZBYyQvbGmWyWVea0EHs/BwLgxc+MKi1zLDCONksozI4YJMcTt8ZEuIR4Sb1MMTE8MMW49v0IwI5+b7RmfWlg==",
packages/harness/cortextos/dashboard/package-lock.json:4057:      "integrity": "sha512-34gw7PjDGB9JgePJEmhEqBhWvCiiWCuXsL9hYphDF7crW7UgI05gyBAi6MF58uGcMOiOqSJ2ybEeCvHcq0BCmQ==",
packages/harness/cortextos/dashboard/package-lock.json:4085:      "integrity": "sha512-D8Vae74A4/a+mZH0FbOkFJL9DSK2R6TFPC9M+jCWYia/q2einCubX10pecpDiTmkJVUH+y8K3BZClycD8nCShA==",
packages/harness/cortextos/dashboard/package-lock.json:4099:      "integrity": "sha512-frxL4OrzOWVVsOc96+V3aqTIQl1O2TjgExV4EKgRY09AJ9leZpEg8Ak9phadbuX0BA4k8U5qtvMSQQGGmaJqcQ==",
packages/harness/cortextos/dashboard/package-lock.json:4246:      "integrity": "sha512-Ize4iQtEALHDttPRCmN+FKqOl2vxTiNUhzobQFFt/BM1lRUTG7zRCLOykG/6Vo4E4hnUdfVLo5/eqKPukcWW7Q==",
packages/harness/cortextos/dashboard/package-lock.json:4403:      "integrity": "sha512-8iUql50EUR+uUcdRQ3HDqa6EVyo3docL8g5WJ3FNcWmu62IbkGUue/pEyLBW8VGKKucTPgqeks4fIU1DA4yowQ==",
packages/harness/cortextos/dashboard/package-lock.json:4442:      "integrity": "sha512-Bq3SmSpyFHaWjPk8If9yc6svM8c56dB5BAtW4Qbw5jHTwwXXcTLoRMkpDJp6VL0XzlWaCHTXrkFURMYmD0sLqg==",
packages/harness/cortextos/dashboard/package-lock.json:5130:      "integrity": "sha512-IV3Ou0jSMzZrd3pZ48nLkT9DA7Ag1pnPzaiQhpW7c3RbcqqzvzzVu+L8gfqMp/8IM2MQtSiqaCxrrcfu8I8rMA==",
packages/harness/cortextos/dashboard/package-lock.json:5468:      "integrity": "sha512-GZW464g1SH7ag3Y7hXjf8RoUuAFIqklOAq3MRl4OaWabTFJY9PN/E1YklhXLh+OQ3fM9yS2nOkCoS+WLZ6kvxQ==",
packages/harness/cortextos/dashboard/package-lock.json:6575:      "integrity": "sha512-KmfKL3b6G+RXvP8N1vr3Tq1kL/oCFgn2NYXEtqP8/L3pKapUA4G8cFVaoF3SU323CD4XypR/ffioHmkti6/Tag==",
packages/harness/cortextos/dashboard/package-lock.json:6633:      "integrity": "sha512-CRT1WTyuQoD771GW56XEZFQ/ZoSfWid1alKGDYMmkt2yl8UXrVR4pspqWNEcqKvVIzg6PAltWjxcSSPrboA4iA==",
packages/harness/cortextos/dashboard/package-lock.json:7234:      "integrity": "sha512-SyHy3T1v2NUXn29OsWdxmK6RwHD+vkj3v8en8AOBZ1wBQ/hCAQ5bAQTD02kW4W9tUp/3Qh6J8r9EvntiyCmOOw==",
packages/harness/cortextos/dashboard/package-lock.json:7683:      "integrity": "sha512-wa56o2/ElJMYqjCjGkXri7it5FbebW5usLw/nPmCMs5DeZ7eziSYZhSmPRn0txqeW4LnAmQQU7FgqLpsEFKM4A==",
packages/harness/cortextos/dashboard/package-lock.json:7700:      "integrity": "sha512-gNCGbnnnnFAUGKeZ9PdbyeGYJqewpmc2aKHUEMO5nQPWU9lOmv7jcmQIv+qHD8fXW6W7qfuCwX4rY9LNRjXrkQ==",
packages/harness/cortextos/dashboard/package-lock.json:7968:      "integrity": "sha512-IlsXEHOjtKhpN8r/tRFj2nDyTmHvcfNeu/nrRIcXE17ROeatXchkojffa1SpdqW4cr/Fj6QkEf/Gn4zf6KKvEQ==",
packages/harness/cortextos/dashboard/package-lock.json:8168:      "integrity": "sha512-mfcwb6IzQyOKTs84CQMrOwW4gQcaTOAWJ0zzJCl2WSPDrWk/OzDaImWFH3djXhb24g4eudZfLRozAvPGw4d9hQ==",
packages/harness/cortextos/dashboard/package-lock.json:8496:      "integrity": "sha512-MbjN408fEndfiQXbFQ1vnd+1NoLDsnQW41410oQBXiyXDMYH5z505juWa4KUE1LqxRC7DgOgZDbKLxHIwm27hA==",
packages/harness/cortextos/dashboard/package-lock.json:8842:      "integrity": "sha512-0KpjqXRVvrYyCsX1swR/XTK0va6VQkQM6MNo7PqW77ByjAhoARA8EfrP1N4+KlKj8YS0ZUCtRT/YUuhyYDujIQ==",
packages/harness/cortextos/dashboard/package-lock.json:8957:      "integrity": "sha512-9Yubnt3e8A0OKwxYSXyhLymGW4sCufcLG6VdiDdUGVkPhpqLxlvP5vl1983gQjJl3tqbrM731mjaZaP68AgosQ==",
packages/harness/cortextos/dashboard/package-lock.json:8984:      "integrity": "sha512-abv/qOcuPfk3URPfDzmZU1LKmuw8kT+0nIHvKrKgFrwifol/doWcdA4ZqsWQ8ENrFKkd67Mfpo/LovbIUsbt3w==",
packages/harness/cortextos/dashboard/package-lock.json:8990:      "integrity": "sha512-8q7VEgMJW4J8tcfVPy8g09NcQwZdbwFEqhe/WZkoIzjn/3TGDwtOCYtXGxA3O8tPzpczCCDgv+P2P5y00ZJOOg==",
packages/harness/cortextos/dashboard/package-lock.json:9021:      "integrity": "sha512-Lbgzdk0h4juoQ9fCKXW4by0UJqj+nOOrI9MJ1sSj4nI8aI2eo1qmvQEie4VD1glsS250n15LsWsYtCugiStS5A==",
packages/harness/cortextos/dashboard/package-lock.json:9499:      "integrity": "sha512-EFVjAYfzWqWsBMRHPMAXLCDIJnpMhdWAqR7xG6M6a2cs6PMFpl/+Z20w9zDW4vkxOFfddegBKq9Rehd0bxWE7A==",
packages/harness/cortextos/dashboard/package-lock.json:9529:      "integrity": "sha512-8u/hfXFRBD1O0hPUjioLhoWFHRmt6tKA4/vZPyckBr18l1KE9uHrFaFaUi8MDRTpi4uak2goyPTSNJLXX2k2Hw==",
packages/harness/cortextos/dashboard/package-lock.json:9579:      "integrity": "sha512-gXah6aZrcUxjWg2zR2MwouP2eHlCBzdV4pygudehaKXSGW4v2AsRQUK+lwwXhii6KFZcunEnmSUoYp5CXibxtA==",
packages/harness/cortextos/dashboard/package-lock.json:9645:      "integrity": "sha512-smsWv2LzFjP03xmvFoJ331ss6h+jixfA4UUV/Bsiyuu4YJPfN+FIQGOIiv4w9/+MoHkfkJ22UIaQWRVFRfH6Vw==",
packages/harness/cortextos/dashboard/package-lock.json:9900:      "integrity": "sha512-wQ0b/W4Fr01qtpHlqSqspcj3EhBvimsdh0KlHhH8HRZnMsEa0ea2fTULOXOS9ccQr3om+GcGRk4e+isrZWV8qQ==",
packages/harness/cortextos/dashboard/package-lock.json:10109:      "integrity": "sha512-24e6ynE2H+OKt4kqsOvNd8kBpV65zoxbA4BVsEOB3ARVWQki/DHzaUoC5KuON/BiccDaCCTZBuOcfZs70kR8bQ==",
packages/harness/cortextos/dashboard/package-lock.json:11542:      "integrity": "sha512-9QNk5KwDF+Bvz+PyObkmSYjI5ksVUYtjW7AU22r2NKcfLJcXp96hkDWU3+XndOsUb+AQ9QhfzfCT2O+CNWT5Tw==",
packages/harness/cortextos/dashboard/package-lock.json:11576:      "integrity": "sha512-KWBIxs1Xb6NoLdMVqhbhgwZf2PGBpPEiwOqgI4pFIYbNTfBXiKYyWoTsXgBQ9WFg/OlhnvHaY+AEpW7wSmFo2Q==",
packages/harness/cortextos/dashboard/package-lock.json:11836:      "integrity": "sha512-7bziOlRqH0hJx80h/3mbicLW7o8qLsH5+RaLR2t+OHM3D0JlWGODQKQ4cxbK7WlvmUxpcj6Kgu6EKqjrGFe3QQ==",
packages/harness/cortextos/dashboard/package-lock.json:12450:      "integrity": "sha512-o8qghlI8NZHU1lLPrpi2+Uq7abh4GGPpYANlalzWxyWteJOCsr/P+oPBA49TOLu5FTZO4d3F9MnWJfiMo4BkmA==",
packages/harness/cortextos/dashboard/package-lock.json:12720:      "integrity": "sha512-JZnDKK8B0RCDw84FNdDAIpZK+JuJw+s7Lz8nksI7SIuU3UXJJslUthsi+uWBUYOwPFwW7W7PRLRfUKpxjtjFCw==",
packages/harness/cortextos/dashboard/package-lock.json:12759:      "integrity": "sha512-tVpsJW7DdjecAiFpbIB1e3qxIQsE6NoPc5/eTdrbbIC4h0LVsWhnoa3g+m2HclBIujHzsxZ4VJVA+GUuc2/LBw==",
packages/diagnostic-generator/README.md:21:- **§3 Sector mix** — stub with Companies House SIC codes; LinkedIn jobs at W4.
packages/diagnostic-generator/README.md:22:- **§4 Geography** — Companies House registered office; LinkedIn job-post locations at W4.
packages/diagnostic-generator/README.md:23:- **§5 Deal-size band** — firm-age proxy from Companies House; LinkedIn salary bands at W4.
packages/diagnostic-generator/README.md:25:- **§7 Tech stack** — stub; LinkedIn skills + JD parsing at W4.
packages/diagnostic-generator/README.md:27:- **§9 Competitor positioning** — stub; LinkedIn profile employment-history at W4.
packages/diagnostic-generator/README.md:28:- **§10 Recent activity** — Companies House filings last 90 days; LinkedIn posts + Google news at W4.
packages/diagnostic-generator/README.md:29:- **§11 Decision-maker map** — Companies House directors as proxy; LinkedIn employee search at W4.
packages/diagnostic-generator/README.md:30:- **§12 Conversation opener** — deterministic anchor-based composition (LLM at W4).
packages/diagnostic-generator/README.md:37:2. **No LLM-driven §12.** Conversation opener is deterministic anchor-based. W4 wires an LLM + voice classifier.
packages/agents-runtime/_shared/common-accounting.json:5:  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
packages/agents-runtime/_shared/common-accounting.json:42:      "description": "v1.0 closes loop via Open Banking reconciliation per Ultraplan §8.1 A4; truelayer placeholder."
agents/recruitment/cash-conductor/validate.sh:3:# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W7-8)
agents/recruitment/cash-conductor/validate.sh:8:# Cash Conductor agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
agents/recruitment/cash-conductor/validate.sh:10:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice completes the impl).
agents/recruitment/cash-conductor/validate.sh:13:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
agents/recruitment/cash-conductor/validate.sh:32:# Checks (per agent.md §5 Gate A, ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/validate.sh:105:# G1 — invoice number + amount + contact (per ULTRAPLAN A4 line 538)
agents/recruitment/cash-conductor/validate.sh:111:# TODO(W7-8): parse draft YAML frontmatter; SELECT FROM cash_conductor_invoices
agents/recruitment/cash-conductor/validate.sh:116:_ok "G1: invoice/amount/contact triple-check — SKELETON (W7-8 wires the SQL)"
agents/recruitment/cash-conductor/validate.sh:119:# G2 — NOT paid in last 24h (defence-in-depth; per ULTRAPLAN A4 line 538 verbatim)
agents/recruitment/cash-conductor/validate.sh:123:# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check
agents/recruitment/cash-conductor/validate.sh:127:_ok "G2: not-paid-in-24h — SKELETON (W7-8 wires the accounting re-query)"
agents/recruitment/cash-conductor/validate.sh:134:# TODO(W7-8): parse draft YAML for voice_score + escalation_position; compare
agents/recruitment/cash-conductor/validate.sh:137:_ok "G3: voice classifier per-position threshold — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:143:# TODO(W7-8): grep draft body for email patterns NOT matching the tenant's
agents/recruitment/cash-conductor/validate.sh:146:_ok "G4: no PII outside firm boundary — SKELETON (W7-8 wires firm-domain whitelist)"
agents/recruitment/cash-conductor/validate.sh:153:_ok "G5: reconciliation match-confidence ≥0.85 — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:160:# TODO(W7-8): @ifos/open-banking loadTokens + getTokenAgeStage; if stage=="blocking"
agents/recruitment/cash-conductor/validate.sh:163:_ok "G6: Open Banking token ≥7d from PSD2 expiry — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:170:_ok "G7: accounting auth refresh in this session — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:179:  # TODO(W7-8): per-failure routing — different ESC code per failure class
docs/operations/codex-ratification-guide.md:122:Three more skills (`review-agent-bundle.md`, `review-mcp-connector.md`, `review-harness-bump.md`) are deferred per the execution plan §3 — they're lazy, built at first need.
agents/recruitment/cash-conductor/context.sh:2:# Cash Conductor agent — context.sh (hydration; W4 Day-26 SKELETON)
agents/recruitment/cash-conductor/context.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
agents/recruitment/cash-conductor/context.sh:8:# Per master brief §8.1 Change 2: context.sh runs at cycle.sh Step 0 and exports
agents/recruitment/cash-conductor/context.sh:13:#   CTX_ACCOUNTING_PROVIDER   xero | quickbooks | sage (per tenant config)
agents/recruitment/cash-conductor/context.sh:76:# TODO(W7-8): SELECT config->>'accounting_provider', config->>'open_banking_provider'
agents/recruitment/cash-conductor/context.sh:89:# TODO(W7-8): replace skeleton stubs with real voice-loader calls. Skeleton
agents/recruitment/cash-conductor/context.sh:96:# TODO(W7-8): CTX_TONE_RULES=$(hh_load_tone_rules "cash_conductor" 2>/dev/null || echo "[]")
agents/recruitment/cash-conductor/context.sh:97:# TODO(W7-8): CTX_TONE_RULES_COUNT=$(echo "${CTX_TONE_RULES}" | jq 'length')
agents/recruitment/cash-conductor/context.sh:103:# TODO(W7-8): CTX_VOICE_CORPUS_ID=$(hh_load_voice_samples "${CTX_TENANT_SLUG}" "chase-email" 2>/dev/null)
agents/recruitment/cash-conductor/context.sh:118:# TODO(W7-8): node -e "import('@ifos/open-banking').then(ob => {
agents/recruitment/cash-conductor/context.sh:132:# TODO(W7-8): query Postgres via the daemon
agents/recruitment/cash-conductor/context.sh:138:# Emit session_start audit row (per master brief §8.1 Change 2 — mandatory first row)
agents/recruitment/cash-conductor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (today): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. Awaits Q1 LOI + accounting + Open Banking commercial signups + Founder Decision D1 resolved + autosend bridge built (Concierge W10) + W7 build slice.
agents/recruitment/cash-conductor/agent.md:7:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:8:**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
agents/recruitment/cash-conductor/agent.md:9:**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
agents/recruitment/cash-conductor/agent.md:10:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:32:# - Xero/QuickBooks/Sage: invoice.created, invoice.sent, invoice.viewed,
agents/recruitment/cash-conductor/agent.md:57:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:151:14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
agents/recruitment/cash-conductor/agent.md:160:   → accounting: Xero/QuickBooks/Sage OAuth refresh per provider
agents/recruitment/cash-conductor/agent.md:162:     gotcha per ULTRAPLAN A4 line 541); staged ESC_OPEN_BANKING_TOKEN_AGING:
agents/recruitment/cash-conductor/agent.md:177:     tenant per Day-4 §6.3 + tenancy-invariants T1-T3; W7 build slice creates
agents/recruitment/cash-conductor/agent.md:186:     W7 build slice creates per ADR-002 vault/Postgres split)
agents/recruitment/cash-conductor/agent.md:195:     candidate, not low-confidence single). W4-polish backlog: register
agents/recruitment/cash-conductor/agent.md:307:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:319:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/cash-conductor/agent.md:323:Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
agents/recruitment/cash-conductor/agent.md:329:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:339:| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:344:| (Stage 3 low-confidence single-match review queue) | Stage 3 single low-confidence exact-amount match queued for consultant review — NOT ESC_RECONCILIATION_AMBIGUOUS (catalogue defines ambiguity as multi-candidate, not low-confidence single). v0.3 W4-polish backlog: add ESC_RECONCILIATION_LOW_CONFIDENCE for single-match-low-confidence case OR widen ESC_RECONCILIATION_AMBIGUOUS catalogue trigger. | flagged in weekly report exception list (no ESC fire at v0.3) | (weekly report aggregation) |
agents/recruitment/cash-conductor/agent.md:374:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:378:## §8 — Build dependencies (W7-8 prerequisites)
agents/recruitment/cash-conductor/agent.md:387:| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
agents/recruitment/cash-conductor/agent.md:390:| Xero MCP connector | W7 build start (~2 days) | ⏸ |
agents/recruitment/cash-conductor/agent.md:391:| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
agents/recruitment/cash-conductor/agent.md:392:| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
agents/recruitment/cash-conductor/agent.md:393:| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
agents/recruitment/cash-conductor/agent.md:398:| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
agents/recruitment/cash-conductor/agent.md:399:| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:400:| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
agents/recruitment/cash-conductor/agent.md:401:| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:402:| `cleanup.sh` post-run state purge (transient OAuth tokens; provider rate-limit caches) | Build at W7 start (~0.5 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:403:| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:406:| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
agents/recruitment/cash-conductor/agent.md:408:**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.
agents/recruitment/cash-conductor/agent.md:414:**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
agents/recruitment/cash-conductor/agent.md:420:| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
agents/recruitment/cash-conductor/agent.md:427:| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
agents/recruitment/cash-conductor/agent.md:429:### Gotchas (carried forward from ULTRAPLAN A4 line 541)
agents/recruitment/cash-conductor/agent.md:434:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:448:- W7-8 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/cash-conductor/agent.md:451:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
packages/agents-runtime/_shared/common-voice.json:5:  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:7:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:17:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:131:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:217:   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
agents/recruitment/scribe/agent.md:237:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:302:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/scribe/agent.md:317:| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/scribe/agent.md:328:| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:66:| 10 | Reporting Engine | Operations | Friday 07:00 | Weekly briefing | Stripe, GA4, Meta Ads, Slack |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:206:- GA4 (Reporting Engine)
docs/operations/codex-ratification-execution-plan.md:73:| `review-mcp-connector.md` | New MCP connector checklist | ~200 | Pre-Janitor-W5 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (today): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:11:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:109:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:211:     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
agents/recruitment/sourcing-scout/agent.md:236:      violations at write time; audit row mandatory per master brief §8.1
agents/recruitment/sourcing-scout/agent.md:256:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:269:On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.
agents/recruitment/sourcing-scout/agent.md:308:- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
agents/recruitment/sourcing-scout/agent.md:324:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/sourcing-scout/agent.md:339:| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
agents/recruitment/janitor/README.md:30:- Bullhorn MCP connector built (W3-W4 conditional per ADR-005)
packages/agent-renderer/templates/claude-md-preamble.md:20:Decision-log calls are mandatory per master brief §8.1 Change 2:
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:7:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:80:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:132:   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
agents/recruitment/janitor/agent.md:185:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:209:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:251:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:266:| Bullhorn MCP connector built | W3-W4 conditional (per ADR-005 sequencing) | ⏸ Not started |
agents/recruitment/janitor/agent.md:277:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
docs/operations/goal-week-3-polish-and-scaffold.md:3:**Status:** CLOSED (Day-19 narrative close 2026-05-24; **true Codex ratification close 2026-05-31**). Day-19 close was optimistic (premature RATIFIED status flips at commit `75ccc5f`, later reverted by R19 bilateral pass). True close 2026-05-31: ran `bash scripts/run-codex-ratification.sh --cluster E` three rounds — R1 verdict 4/9 RATIFIED, R2 verdict 6/9, R3 verdict **8/9 RATIFIED**; the 9th artefact (v0.2-to-v0.3 migration) had its R3 rollback finding fixed at commit `0f4ce8d` and re-ratification deferred per master brief §10.3 step 5 ceiling (3 round-trips already crossed; founder decision 2026-05-31 — fix + stop). Net effective state: **8/9 Codex-RATIFIED + 1 with the latest R3 fix applied = 9/9 in substance**. v0.3 schema supplement RATIFIED (final via Round 3). ADR-006 Diagnostic Gate A hybrid Accepted (founder-arbitrated). ADR-007 Concierge Gate A hybrid RATIFIED (still Status: Proposed pending founder Accept per its own §10). All 6 agent.md scaffolds RATIFIED at the contract level (Status: Proposed; production-readiness gates unchanged: pilot LOI · Bullhorn A+B · API keys · live VPS migration). See `.agents/current-priorities.md` "W4 Day-25" section for per-round detail + the deferred rollback re-ratification W4 backlog item. **STOP-HOOK NOTE: this file's gate-structure was superseded by in-session founder AUQ authorization; do not re-fire on subsequent turns.**
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:21:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:35:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:47:3. **§12 conversation opener is LLM-driven, not deterministic.** Calls Claude API (or OpenAI fallback) with §1-§11 context + tenant voice corpus + tone rules. Voice classifier microservice STUB in place (real classifier W4-5; for now: skip-with-warning preserved).
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:54:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:55:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:95:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
docs/operations/goal-week-3-polish-and-scaffold.md:108:| Voice classifier microservice | Reserved for W4-5 polish; for Week 3, §12 LLM call skips voice-classifier gate (V3 stays as a skipped-with-warning) |
docs/operations/goal-week-3-polish-and-scaffold.md:215:3. Voice classifier integration: STUB — `IFOS_VOICE_CLASSIFIER_URL` unset means skip-with-warning (preserves V3 behaviour). Real classifier wires up at W4-5.
docs/operations/goal-week-3-polish-and-scaffold.md:293:- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
docs/operations/goal-week-3-polish-and-scaffold.md:294:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:312:- **§8 Build prerequisites:** Bullhorn MCP connector wired (W3 conditional; W4-5 if A+B answered) + first pilot tenant with Bullhorn corpToken in `_secrets.env`.
docs/operations/goal-week-3-polish-and-scaffold.md:324:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:331:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:332:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:352:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:359:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:360:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:361:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:369:- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
docs/operations/goal-week-3-polish-and-scaffold.md:376:- **§8 Build prerequisites:** Xero MCP connector (W4 build) + QuickBooks MCP + Sage MCP + Open Banking via TrueLayer (or similar; founder commercial signup) + tenant accounting credentials in `_secrets.env`.
docs/operations/goal-week-3-polish-and-scaffold.md:381:Commit: `decision(pre-build): agents/recruitment/cash-conductor/agent.md — output contract per ULTRAPLAN §8.1 A4`
docs/operations/goal-week-3-polish-and-scaffold.md:388:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:389:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:395:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:409:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:414:- ULTRAPLAN §8.1 A6 lines 561-570 (Concierge spec)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:436:Commit: `decision(pre-build): agents/recruitment/concierge/agent.md — output contract per ULTRAPLAN §8.1 A6`
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:591:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:620:  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:641:  ✓ ULTRAPLAN §8.1 — all 6 agents have output contracts authored
docs/operations/goal-week-3-polish-and-scaffold.md:642:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:650:    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/goal-week-3-polish-and-scaffold.md:664:  - <Xero dev account for W4>
docs/operations/goal-week-3-polish-and-scaffold.md:682:| 1 | Anthropic API rate-limit / outage during Step 4 dev | Low | Built-in retry + deterministic fallback; flag as W4 polish if rate-limited persistently |
docs/operations/goal-week-3-polish-and-scaffold.md:687:| 6 | LLM-driven §12 produces opener that fails voice classifier consistently | Medium | Deterministic fallback already in place; flag as W4 polish (real voice classifier wires up later) |
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:804:            &mdash; share code <em>W12&nbsp;EX9&nbsp;A4T</em>, valid through Dec 2027.
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
docs/operations/decision-log.md:12:Established 2026-06-01 (W4 Day-26) as part of the priorities refactor (goal §1.2). Pre-refactor, all of this content lived in `.agents/current-priorities.md` itself (had grown to 1161 lines + accreted across 25 days). The refactor preserves every historical entry verbatim; only the surface presentation changed.
docs/operations/decision-log.md:16:## W4 Day-25 overnight (2026-05-31 → 2026-06-01) — autonomous Track-1 start ✓
docs/operations/decision-log.md:26:| `267913b` | `.codex/ratification/review-mcp-connector.md` Codex skill | 151 lines, 7 checks layered on SKILL.md; output format identical to existing skills |
docs/operations/decision-log.md:53:### What's queued for daytime W4 Track-1 continuation
docs/operations/decision-log.md:57:- **`@ifos/quickbooks`** MCP connector — same shape as @ifos/xero (per-realm OAuth diff documented); est. 2-3 hours (pattern now established)
docs/operations/decision-log.md:60:- **Cluster F manifest add** — add Xero + QuickBooks + Open Banking + Cash Conductor to `scripts/run-codex-ratification.sh` and trigger founder-side ratification run
docs/operations/decision-log.md:68:## W4 Day-25 evening (2026-05-31) — v0.3 migration APPLIED to live VPS ✓
docs/operations/decision-log.md:87:- **W4 backlog item #1 CLOSED** (Day-20 queue's first item).
docs/operations/decision-log.md:88:- **Cash Conductor `cash_conductor_transactions` + `cash_conductor_invoices` tables exist on live VPS** — the W4 Track-1 /goal can wire MCP connectors against real schema (not just fixtures).
docs/operations/decision-log.md:100:| 4 | Apply v0.3 migration to live VPS | ✅ **APPLIED + tenancy audit 12/12** (Day-25 evening 2026-05-31) |
docs/operations/decision-log.md:106:## W4 Day-25 (2026-05-31) — founder decisions captured + W4 Track-1 /goal authored
docs/operations/decision-log.md:119:| 8 | Proxycurl + Reed + CV-Library signups | DEFERRABLE | not blocking W4 Track 1 |
docs/operations/decision-log.md:127:- W4 Track-1 work has a complete /goal prompt — paste `docs/operations/goal-week-4-track-1.md` into any new Claude Code session and it executes the next 5-7 days autonomously (with founder gates as documented).
docs/operations/decision-log.md:130:## W4 Day-25 (2026-05-31) — Codex Round 1 (agent-bundle) verdict closed
docs/operations/decision-log.md:156:**Founder decision (2026-05-31): Fix + STOP — no Round 4.** Migration has had 3 round-trips (R1 → R2 → R3) and applying-and-re-running would be a 4th, crossing master brief §10.3 step 5 ≤2-cap further. Codex spelled out the exact `to_regclass` fix; it's applied at `0f4ce8d`. Re-ratification of the rollback path is deferred to its next natural touch (live VPS apply OR v0.4 supplement work) and recorded in the W4 backlog. Net effective state: **8/9 Codex-RATIFIED + 1 with the latest R3 fix applied = 9/9 in substance**.
docs/operations/decision-log.md:158:### W4 backlog addition (from R3 stop decision)
docs/operations/decision-log.md:173:## W4 Day-21 (2026-05-27) — ratification remediation + harness fix
docs/operations/decision-log.md:213:| ESC codes referenced ∈ escalation-codes.md | ✓ (3 are sanctioned W4-backlog proposals / changelog notes; janitor's `ESC_BULLHORN_OAUTH_REVOKED` disclaimer corrected → folded into `ESC_BULLHORN_AUTH` payload) |
docs/operations/decision-log.md:220:## W4 Day-20 shipped
docs/operations/decision-log.md:224:1. `22cd672 ops(w4-day-20)` — v0.3 migration wrapper (`scripts/run-v0.3-migration.sh`; --dry-run; closes W4 backlog item #1 gap) + Day-20 founder runbook + bilateral-pass working doc
docs/operations/decision-log.md:230:7. `26551c8 feat(ADR-007 + concierge-r4)` — ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted; analogue of ADR-006; closes Concierge R3 Finding 3 structurally. Step 11 `hh_decision_action` added. **Closes W4 founder-action queue item #3** (drafted; ratification gates Concierge Accepted).
docs/operations/decision-log.md:264:## W4 backlog
docs/operations/decision-log.md:269:- [ ] **Diagnostic validate.sh + cycle.sh polish (W3-W4)** — emit specific ESC codes per §6; write validate_check_skipped row; add operator_notify_telegram hh_decision_action call.
docs/operations/decision-log.md:272:## W4 founder-action queue (Day-20 update)
docs/operations/decision-log.md:315:- [x] **Phase 5** — `voice-loader.sh` + tests + README updates. Landed Day 8 `fe56e93`. Closes master brief §8.1 Change 1. 9/9 voice-loader tests pass.
docs/operations/decision-log.md:360:- [ ] **R11**: tenant_eval_sets + tenant_adapters usage spec — Diagnostic W4 (first eval-set)
docs/operations/decision-log.md:434:1. Gate A vs ULTRAPLAN source-data citation strength → hybrid v0 + W4 polish
docs/operations/decision-log.md:451:- ✓ ULTRAPLAN §8.1 — all 6 v1.0 agents have output contracts authored
docs/operations/decision-log.md:452:- ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/decision-log.md:461:- Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/decision-log.md:481:- **Step 8** (`2340e24`) — Janitor agent.md (296 lines) per ULTRAPLAN §8.1 A2 (W5 build wave)
docs/operations/decision-log.md:482:- **Step 9** (`7730baa`) — Scribe agent.md (336 lines) per ULTRAPLAN §8.1 A3 (W6 build wave)
docs/operations/decision-log.md:483:- **Step 10** (`d64d1c5`) — Cash Conductor agent.md (377 lines) per ULTRAPLAN §8.1 A4 (W7-8 build wave; Hire #1 anchor)
docs/operations/decision-log.md:484:- **Step 11** (`1472e04`) — Sourcing Scout agent.md (335 lines) per ULTRAPLAN §8.1 A5 (W9 build wave)
docs/operations/decision-log.md:485:- **Step 12** (`94485aa`) — Concierge agent.md (387 lines) per ULTRAPLAN §8.1 A6 (W10-13 build wave; XL complexity)
docs/operations/decision-log.md:502:Per master brief §8.2 + ULTRAPLAN §8.1, each scaffold cites verbatim:
docs/operations/decision-log.md:508:| Cash Conductor | W7-8 (Hire #1 anchor) | A4 lines 529-542 |
docs/operations/decision-log.md:517:- Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/decision-log.md:560:**LinkedIn integration:** Option A (free unauthenticated public-page HEAD check) wired today per founder pick. Proxycurl signup deferred to W4 polish.
docs/operations/decision-log.md:648:  - §3 The 12 required sections (Firm signal / Online footprint / Sector + role-type mix / Geography / Deal-size band proxy / ICP fit vs target_patch / Tech stack signals / Pain signals / Competitor positioning / Recent activity / Decision-maker map / Conversation opener) — proposed enumeration per Ultraplan §8.1 A1; founder review pending
docs/operations/decision-log.md:649:  - §4 Workflow (10-step process from Ultraplan §8.1 A1 with `hh_decision_*` integration per master brief §8.1 Change 2)
docs/operations/decision-log.md:652:  - §7 Voice + tone constraints (integration with `_shared/voice-loader.sh` per master brief §8.1 Change 1)
docs/operations/decision-log.md:798:- `agents/_shared/voice-loader.sh` (292 lines, shellcheck clean) — 3 hh_load_* helpers per master brief §8.1 Change 1. Live mode (RLS-isolated SELECT) + fallback (vault files).
docs/operations/decision-log.md:854:- `agents/_shared/escalation-codes.md` (255 lines, Reference) — closes master brief §8.1 Change 3 Week-0 task ("Build the catalogue in Week 0"); 24 active codes + 2 reserved across 6 sections
docs/operations/decision-log.md:922:**Spot-checks that PASSED audit** (no fixes needed): master brief §3.2 line 155 (canonical vocabulary), §5.1 lines 325-329 (vault structure), §8.1 Change 1/2/3 (voice + decision logging + escalation), ADR-003 Decision 3 referencing design §2.1, sequencing-target.md §6.6 three failure conditions, ULTRAPLAN.md existence, bullhorn-integration-path.md §4.1 + §6.3 canonical-orange anchor.
docs/operations/decision-log.md:1062:- `docs/decisions/sequencing-target.md` — 522 lines, 7 sections. **Accepted** Option Alpha (master brief §8.2 ratified)
docs/operations/decision-log.md:1085:- `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh` per master brief §8.1 Changes 1 + 2. **Full ESC_* wiring scope now specified across prior documents:**
docs/operations/decision-log.md:1159:- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
docs/architecture/architecture-cohesion-review.md:91:| A4 | **`ifos_app` Postgres role is the only role used by app code.** No path uses postgres superuser or admin role. | Day-4 §6.3 grants + RLS posture | If any path uses superuser, RLS is bypassed (RLS doesn't apply to superusers by default). |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
agents/recruitment/diagnostic/cycle.sh:32:# Proxycurl deep-data integration deferred to W4 polish per ADR-005.
agents/recruitment/diagnostic/cycle.sh:37:#     per-section telemetry is W4 polish optional per §4)
agents/recruitment/diagnostic/cycle.sh:40:#     §5 honesty note; W4 polish closes those to hard-fail)
agents/recruitment/diagnostic/cycle.sh:118:# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:54:- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:153:**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:702:New escalation code added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3:
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:800:**Edit C — Master brief §8.1 add renderer reference:**
docs/architecture/agent-bundle-renderer-design.md:804:**Proposed:** add a one-paragraph footnote at the end of §8 (before §8.1): "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per ADR-003) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant)."
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
docs/operations/goal-option-c-diagnostic-end-to-end.md:68:| §12 conversation opener — LLM-generated, minimal voice gate | Sufficient for v0 demo; full voice classifier in W4 polish |
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:312:| Real run reveals Gate A V3 voice classifier was actually needed (skipped warning was too lenient) | Surface as W4 polish item; do not block the milestone. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:398:Master plan alignment: ULTRAPLAN §8.1 Week-4 milestone hit on Day-13
agents/recruitment/diagnostic/tools.yaml:3:# Status: Proposed (Day-19; @ifos/web-scraper + @ifos/companies-house MCP connectors shipped Day 13; LinkedIn via web-scraper page-fetch in v0; Proxycurl deferred to W4 polish).
agents/recruitment/diagnostic/tools.yaml:171:  - xero           # Cash Conductor's territory (W7-8)
agents/recruitment/diagnostic/tools.yaml:172:  - quickbooks     # Cash Conductor's territory
docs/operations/founder-manual-playbook-2026-05-31.md:1:# Founder manual playbook — W4 (2026-05-31)
docs/operations/founder-manual-playbook-2026-05-31.md:4:**Window:** today → end-of-W4 (~2026-06-05)
docs/operations/founder-manual-playbook-2026-05-31.md:20:**Why first:** unblocks all v0.3 schema usage (Cash Conductor tables, Janitor dedup config, blocked_recipients, etc.). Without this, every downstream W4 build is just writing code against schema that doesn't exist on the live database.
docs/operations/founder-manual-playbook-2026-05-31.md:84:**What I do on your reply:** mark W4 backlog item #1 closed; flip the deferred-rollback re-ratification note to "next natural touch is now this VPS apply — schedule a cluster E re-run."
docs/operations/founder-manual-playbook-2026-05-31.md:230:written response on A + B unblocks our W4-5 build sprint.
docs/operations/founder-manual-playbook-2026-05-31.md:279:- Sign up → create an app called "IFOS Cash Conductor" → choose **Web App** flavour → set redirect URI to `https://migration-test.ifos.app/oauth/xero/callback` (placeholder; we'll wire properly at W4-5)
docs/operations/founder-manual-playbook-2026-05-31.md:362:- **(A)** Wait for the priority-1/2/3 confirms before starting the W4 Track-1 /goal (cleaner sequencing — no risk of building against absent infra).
docs/operations/founder-manual-playbook-2026-05-31.md:363:- **(B)** Start the W4 Track-1 /goal now in this session — Day-1 work is substrate verify + `review-mcp-connector.md` Codex skill + Diagnostic live-smoke wrapper (already done ✓). Day-2 onward is the Xero MCP connector scaffold (fixture-first; doesn't need v0.3 migration applied).
docs/operations/founder-manual-playbook-2026-05-31.md:382:| W4 Track-1 /goal | `docs/operations/goal-week-4-track-1.md` |
agents/recruitment/diagnostic/agent.md:7:**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
agents/recruitment/diagnostic/agent.md:8:**Build complexity:** M (1 week) per Ultraplan §8.1 A1 line 489.
agents/recruitment/diagnostic/agent.md:17:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (target voice-classifier ≥ 0.75 per `common-voice.json`; v0 implementation warns + exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unreachable per §5 honesty note — W4 polish closes this to unconditional hard-fail) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:46:Every report MUST contain these 12 sections. The generator (`@ifos/diagnostic-generator`) emits them in the order listed below. Gate A at v0 enforces (a) exactly 12 `##` headings present in the rendered draft — `validate.sh` lines 93-98 hard-fail when the section count != 12 — AND (b) per-section citation coverage. v0 `validate.sh` V1 counts `##` headings without enforcing exact section titles or order — see `validate.sh` lines 89-91 comment ("Section labels documented for reference; not currently regex-matched individually... At W4 polish: tighten to enforce exact-heading match per EXPECTED_SECTIONS"). The comment was authored as "At W3 build" but W3 closed without the tightening; it is now W4 polish. Both the agent.md and `validate.sh` comment are updated to "W4 polish" in this round.
agents/recruitment/diagnostic/agent.md:48:**v0 source-coverage state:** Companies House data (§1, §10) is live via `@ifos/companies-house` MCP connector. Web-scraped pages (§2 footprint URLs, §8 careers-page pain signals) are live via `@ifos/web-scraper`. **LinkedIn deep-data sections (§3 job posts, §5 placement timeline, §7 employee skills, §9 competitor employee scan, §11 decision-maker profiles) currently use `@ifos/diagnostic-generator` stub-with-Companies-House-fallback citations** — Proxycurl integration deferred to W4 polish per ADR-005. Each LinkedIn-dependent section still emits ≥1 evidence link (per-section Gate A satisfied) by falling back to Companies House URLs, but the data depth is degraded vs the full-coverage W4 target.
agents/recruitment/diagnostic/agent.md:50:| # | Section | What it contains | v0 source(s) | W4-polish source |
agents/recruitment/diagnostic/agent.md:72:**Gate A complement (v0 — warn-only-on-upstream-unavailable; W4-polish closes to hard-fail):**
agents/recruitment/diagnostic/agent.md:74:- Section 12 voice-classifier score < 0.75 — hard-fails IF `IFOS_VOICE_CLASSIFIER_URL` is reachable; warns + exits 0 if URL unreachable. W4 polish closes to unconditional hard-fail with explicit `validate_check_skipped` audit row.
agents/recruitment/diagnostic/agent.md:75:- PII (email-domain mismatch) outside firm boundary — hard-fails IF firm-domain whitelist is available; warns + exits 0 if whitelist absent. W4 polish closes to unconditional hard-fail. v0 PII regex covers emails only; phone-number PII detection deferred to W4 polish.
agents/recruitment/diagnostic/agent.md:89:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
agents/recruitment/diagnostic/agent.md:116:   → v0 NOTE: rate-limit catches (429 → ESC_RATE_LIMIT_HIT) and per-section retry logic are NOT implemented at v0 cycle.sh; W4 polish adds 429 catch + retry-with-backoff to cycle.sh. v0 generator throws-and-exits on upstream errors; validate.sh catches Gate A failure downstream.
agents/recruitment/diagnostic/agent.md:117:   → v0 NOTE: per-§12 LLM voice classifier retry loop is NOT implemented in generator at v0 (§12 stub-via-Companies-House fallback). Voice classification happens at validate.sh V3 (single call to IFOS_VOICE_CLASSIFIER_URL when set; warn + exit 0 when unset/unreachable). W4 polish adds full LLM §12 pipeline with 3-retry classifier loop and explicit ESC_VOICE_DRIFT emission in the generator.
agents/recruitment/diagnostic/agent.md:124:     upstream-unavailable in v0; W4 closes to hard-fail)
agents/recruitment/diagnostic/agent.md:160:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:162:**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
agents/recruitment/diagnostic/agent.md:164:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:168:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:171:- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.
agents/recruitment/diagnostic/agent.md:175:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:187:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 | warn | operator_chat_id | **v0: single-pass via `validate.sh` V3 (no in-generator retries); W4-planned: 3-retry classifier loop in `@ifos/diagnostic-generator` §12 LLM step.** Aggregate-tenant `ESC_VOICE_DRIFT_TENANT` is per `_shared/escalation-codes.md` (nightly cron). |
agents/recruitment/diagnostic/agent.md:188:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall | v0: emails-only regex; warn + exit 0 when firm-domain whitelist absent. W4-planned: phone-number PII detection + hard-fail when whitelist absent. |
agents/recruitment/diagnostic/agent.md:189:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn upstream 429 | warn | operator_chat_id | **v0: NOT implemented in `cycle.sh` (generator throws-and-exits on upstream errors; validate.sh catches downstream as `ESC_AGENT_OUTPUT_SHAPE`). W4-planned: 429 catch + retry-with-backoff in `cycle.sh` + explicit `ESC_RATE_LIMIT_HIT` emission.** |
agents/recruitment/diagnostic/agent.md:211:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. **v0: per-run `ESC_VOICE_DRIFT` fires when `validate.sh` V3 single-pass classifier call (no retries) returns score <0.75 AND `IFOS_VOICE_CLASSIFIER_URL` was reachable. W4-planned: 3-retry classifier loop in `@ifos/diagnostic-generator` §12 LLM step + unconditional hard-fail when URL unreachable.** Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/agent.md:213:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/diagnostic/agent.md:230:| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
agents/recruitment/diagnostic/agent.md:232:| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
agents/recruitment/diagnostic/agent.md:252:| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
agents/recruitment/diagnostic/agent.md:254:| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | v0 (Day 13 ship) skipped Proxycurl: LinkedIn deep-data sections (§3, §5, §7, §9, §11) use Companies House fallback citations per §3 table (status confirmed in §8 dependencies row "LinkedIn read-only via web-scraper" — Proxycurl deferred to W4). W4 polish decision path: founder evaluates commercial Proxycurl signup ($39/mo Proxycurl pricing low-volume) vs alternative (PhantomBuster, Bright Data, scraper.api) vs continued Companies House fallback. Resolution due before first pilot tenant onboarding (Risk #3 LOI close). |
agents/recruitment/diagnostic/agent.md:259:### Gotchas (carried forward from Ultraplan §8.1 A1)
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
agents/recruitment/diagnostic/validate.sh:67:# direct source-tree execution (Day-13 smoke tests + Day-25 evening
agents/recruitment/diagnostic/validate.sh:114:# At W4 polish: tighten to enforce exact-heading match per EXPECTED_SECTIONS
agents/recruitment/concierge/cleanup.sh:2:# Concierge agent — cleanup.sh (post-run state purge; W4 Day-26 SKELETON)
agents/recruitment/concierge/cleanup.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
agents/recruitment/diagnostic/context.sh:10:# the first workflow step runs. Per master brief §8.1 Change 1: load voice
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:19:# Status: Proposed (W4 Day-26 SKELETON).
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:133:**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
docs/decisions/ADR-003-agent-bundle-renderer.md:135:**Proposed:** insert a one-paragraph footnote at the end of §8 (before §8.1):
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
agents/recruitment/concierge/tools.yaml:3:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces per-cap
agents/recruitment/concierge/tools.yaml:33:    purpose: "Bullhorn OAuth refresh + per-tenant token rotation (deferred to W7 Janitor bundle Track-2 per master brief §8.2)"
agents/recruitment/concierge/tools.yaml:205:#   bullhorn_oauth                     green               (W7 Janitor + Bullhorn partnership)
agents/recruitment/concierge/tools.yaml:212:# Boundary check (per master brief §3 + review-mcp-connector.md §8)
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:31:Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:33:Option B — **Amend Ultraplan §8.1 A1 line 497** to read "no unsupported claims at section level" (loosens upstream to match v0 implementation).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:37:**My recommendation:** **C** (hybrid). Per-claim validation is genuinely hard to automate at v0 (requires NLP claim-extraction + per-claim evidence-link matching); deferring to W4 is honest. But Codex is right that the §1 contract reads as if we're skipping it entirely — needs clearer "deferred to W4 with documented gap-coverage plan."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:45:**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:83:**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:92:4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:127:1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:128:2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:144:- Per-claim Gate A validation is genuinely hard to automate (NLP claim-extraction + per-claim evidence linkage); the hybrid v0+W4 path is the industry-standard approach.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:149:These are not unprincipled compromises — they're the right v0 stance with W4-13 polish path documented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:287:#### Category β — Schema-supplement-needed (v0.3 supplement is a founder-action gate before W4-W13 builds)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:293:- All five are blocked on v0.3 supplement landing (founder review at first-pilot-onboarding) — DOCUMENTED IN W4 BACKLOG
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:302:- DOCUMENTED IN W4 BACKLOG (catalogue v2 amendments)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:309:- All five build-slice items (W4-W13) DOCUMENTED IN BUILD-SLICE BACKLOG
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:320:- DOCUMENTED IN W4 BACKLOG (cycle.sh build slices deliver these calls per agent §4 specs)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:403:- **A) Amend ULTRAPLAN §8.1 A1 line 497** — change "no claims unsupported by source data" to "no claims unsupported at section level" to match v0 reality. Aggressive; rewrites upstream spec.
agents/recruitment/concierge/fixtures/01-primary.yaml:11:# Status: Proposed (W4 Day-26 SKELETON).
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:1:# Codex disagreement — `@ifos/quickbooks` 10/s concurrent throttle
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:6:**Codex session:** `20260602T105413Z-29512` Round 3, `packages_mcp-connectors_quickbooks.output.md` issue #1.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:10:> QuickBooks' second/concurrent throttle is declared but deliberately not implemented. `README.md` lines 112-116 and `src/rate-limit.ts` lines 1-8 cite the upstream `10 calls per second concurrent throttle`, then say it is "not enforced here"; `src/rate-limit.ts` lines 10-14 only implement the 500/minute bucket. This fails `review-mcp-connector.md` §3 because the declared upstream rate-limit budget is not covered by a safety-margin implementation or exhaustion test. Add a per-second/concurrency limiter with tests, or remove the claim only if provider docs prove it is not an applicable call/window budget.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:16:`packages/mcp-connectors/quickbooks/README.md` line 113 verbatim:
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:20:Intuit's "10 concurrent calls per realmId" cap fires when ≥10 in-flight HTTP requests exist simultaneously against the same realm. Cash Conductor `cycle.sh` calls `@ifos/quickbooks` from a serial bash flow — `await` resolves before the next call is issued. The number of in-flight requests against any one realm at any moment is **exactly 1**. The concurrent throttle cannot be hit by definition.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:44:- A new consumer of `@ifos/quickbooks` lands that doesn't share Cash Conductor's serial-bash discipline (e.g. a webhook handler that batches concurrent invoice lookups).
agents/recruitment/concierge/validate.sh:3:# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W10-13)
agents/recruitment/concierge/validate.sh:8:# Concierge agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
agents/recruitment/concierge/validate.sh:10:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice completes the impl).
agents/recruitment/concierge/validate.sh:14:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:16:# Status: Proposed (W4 Day-26 SKELETON).
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:13:ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:42:| W4 Days 21-27: Diagnostic end-to-end | W4 Days 21-27: Diagnostic polish + first-pilot prep + Bullhorn MCP if A+B answered |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:100:| Codex ratification of bundle | ⏸ W4 | — |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:106:- ULTRAPLAN §8.1 line 753-755 (Week-4 milestone definition)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:119:| LinkedIn deep data via Proxycurl: now or W4? | Day-13 founder pick: Option A (free unauthenticated path) for v0; Proxycurl evaluated W4 polish |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:13:ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:23:(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:33:Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:45:The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:52:- Authored as a separate W4 ADR (number to be assigned at W4-polish authoring time; this ADR does NOT pre-assign a number) together with the schema supplements that define its payload key + per-tenant config field
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:58:**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:64:`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:90:- Hybrid preserves the W4-polish path; permanent amendment closes that door
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:93:- v0 implementation does what it says; W4 polish path is documented + scheduled
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:95:- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:116:### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Sample rate configurable per tenant via field landing in the future W4-polish vertical-schema supplement (concrete field name + type specified there alongside the Tier 2 writer + sampling-activation work; NOT in v0.3 supplement — v0.3 explicitly defers per its §5 `deferred_to_future_adr` block to avoid speculative schema without a current consumer)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:138:| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:139:| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:140:| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
agents/recruitment/concierge/context.sh:2:# Concierge agent — context.sh (pre-cycle hydration; W4 Day-26 SKELETON)
agents/recruitment/concierge/context.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/architecture/second-brain-design.md:52:**IFOS agents do not run cortextOS's heartbeat-memory pattern.** The IFOS Agent Bundle v2 (master brief §8.1) specifies six files per agent:
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:110:**But IFOS Agent Bundle v2 is a different shape.** Master brief §8.1 specifies six files plus three fixture directories:
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:701:- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:907:2. **Master brief §8 (Agent Bundle v2 pattern + `tools.yaml` contract).** §8.1 specifies the bundle has `tools.yaml` for "MCP servers + scopes + degraded modes" — i.e. external MCP connectors (Bullhorn, Companies House, Xero). The wiki is **internal** to IFOS, not an external execution backend. Treating wiki ops as bus commands (Option α) keeps `tools.yaml` clean of internal-surface declarations; treating them as MCP tools (Option β) conflates internal-data-access with external-tool-invocation in the same `tools.yaml`.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
agents/recruitment/concierge/cycle.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs with
agents/recruitment/concierge/cycle.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (today): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`; Concierge Status flip Proposed → Accepted requires ADR-007 RATIFIED. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
agents/recruitment/concierge/agent.md:7:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:117:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:218:       — mandatory audit row per master brief §8.1 Change 2 (phase=output;
agents/recruitment/concierge/agent.md:282:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:363:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:376:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:379:| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/concierge/agent.md:386:| Voice classifier microservice live | W4-5 polish | ⏸ |
agents/recruitment/concierge/agent.md:435:- **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes the documented deviation from ULTRAPLAN A6 line 566 wording. ADR drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` (Day 20 W4 bilateral pass); ratifies via `.codex/ratification/review-architecture-decision.md` skill. Until RATIFIED, agent.md's Gate B framing of the 30-min SLA is documented disposition only.
packages/agent-renderer/pnpm-lock.yaml:178:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/agent-renderer/pnpm-lock.yaml:232:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/agent-renderer/pnpm-lock.yaml:448:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/agent-renderer/pnpm-lock.yaml:529:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/agent-renderer/pnpm-lock.yaml:693:    resolution: {integrity: sha512-8iUql50EUR+uUcdRQ3HDqa6EVyo3docL8g5WJ3FNcWmu62IbkGUue/pEyLBW8VGKKucTPgqeks4fIU1DA4yowQ==}
packages/agent-renderer/pnpm-lock.yaml:732:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/agent-renderer/pnpm-lock.yaml:736:    resolution: {integrity: sha512-Vw8qHK3bZM9y/P10u3Vib8o/DdkvA2OtPtZvD871QKjy74Wj1WSKFILMPRPSdUSx5RFK1arlJzEtA4PkFgnbuA==}
packages/agent-renderer/pnpm-lock.yaml:812:    resolution: {integrity: sha512-34wB/Y7MW7bzjKRjUKTa46I2Z7eV62Rkhva+KkopW7Qvv/OSWBqvkSY7vusOPrNuZcUG3tApvdVgNB8POj3SPw==}
packages/agent-renderer/pnpm-lock.yaml:1050:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:99:| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:109:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:122:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 526 estimate **M (1 week)**. Webhook-driven not always-on. Structured-field mapping is per-firm config not code per Ultraplan §8.1 line 526. Tacit-note extraction is the hard part per Ultraplan §8.1 line 527 ("Start with a small taxonomy (5-10 tacit-note types) and expand") |
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:135:| 1. Implementation simplicity | **Medium-High** | Ultraplan §8.1 line 541 estimate **L (2 weeks)**. Three accounting integrations (Xero / QuickBooks / Sage — one per tenant per Ultraplan §8.1 line 537). Open Banking auth complexity (90-day token rotation per Ultraplan §8.1 line 542 gotcha). Tier 1 always-on (cortextOS Primitive 1 dependency) |
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:140:| 6. Tenant-onboarding readiness | **Medium** | Needs Xero/QuickBooks/Sage OAuth (one of, per tenant) + Open Banking auth (TrueLayer/Plaid UK per Ultraplan §8.1 line 539). Chase-cadence config per tenant. FD's mobile for Telegram approval per Ultraplan §8.1 line 540 |
docs/decisions/sequencing-target.md:142:**Hire-#1 anchor (per Ultraplan §9 line 766 verbatim):** "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)." Cash Conductor's three-accounting-API + Open-Banking integration is the right scope for Hire #1's first sprint per Ultraplan §9 — this places Cash Conductor at W7-8 in the canonical sequence.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:163:| 1. Implementation simplicity | **High complexity (Low simplicity)** | Ultraplan §8.1 line 568 estimate **XL (4 weeks)** — biggest v1.0 agent. Lifecycle state machine across 24+ months of candidate post-placement (week-1 / month-1 / month-3 / month-6 / month-12 / month-24 nurture per Product Spec §2.2 R7). Six-plus comms types (acknowledgement, prep, debrief, rejection, placement, multi-stage check-ins) |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:184:W7-8: Cash Conductor (A4) — Hire-#1-anchored per Ultraplan §9 line 766
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:192:- W4: Risk #5 (renderer) — Diagnostic first user. Reduction trigger fires (High → Medium per RISK-REGISTER #5).
docs/decisions/sequencing-target.md:194:- W7-8: Risk #1 (cortextOS Primitives 1+4+5) — Cash Conductor first Tier-1. Reduction trigger fires.
docs/decisions/sequencing-target.md:198:- Bullhorn webhook coverage gaps surface only at Concierge W10-13 (Ultraplan §8.1 line 569 caveat).
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:232:W11:  Cash Conductor (A4)
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:242:3. **Hire-#1 anchor broken.** Cash Conductor at W11 is 4 weeks after Hire #1's assumed W7 start. Hire #1 again has no first-sprint scope.
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:401:- Output: 12-page audit per Ultraplan §8.1 line 489-496 against a real prospect's public footprint.
docs/decisions/sequencing-target.md:402:- First production render lands W4 per ADR-003 design §5.2 line "First production render is the Diagnostic agent at Week 4."
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:410:§4.3 Trigger 1 activation point: end of W4 weekly review if Sub-decisions A and B still Proposed.
docs/decisions/sequencing-target.md:414:Diagnostic W3-W4 build window is the first production renderer exercise per ADR-003 design §5.2. The reduction-trigger cascade per `docs/RISK-REGISTER.md` Risk #5 fires:
docs/decisions/sequencing-target.md:417:- W4 Diagnostic first-render-clean → **Medium** (renderer code proven against one production bundle).
docs/decisions/sequencing-target.md:420:No new discrepancy to surface — earlier draft concern about W3-vs-W4 framing resolved per §6.2.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:494:| W3 vs W4 framing | §6.2 + §6.4 | Build-window-vs-completion-week distinction: Diagnostic build W3-W4, first production render W4. Not a true discrepancy. |
docs/decisions/sequencing-target.md:508:| Day 2 commercial conversations land by start of W4 (Risk #2 reduction triggers) | Founder | Sunday-Monday outreach; resolved by end of W3 | Already tracked from `bullhorn-integration-path.md` §1.3 |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/decisions/sequencing-target.md:520:| Diagnostic W3 build start (vs W4 first render) | If renderer impl slips past end of W2, Diagnostic build start slips correspondingly |
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md:39:2. Consider whether the review-mcp-connector skill itself needs hardening (e.g. an explicit "401-must-actually-refresh" check that would have caught the bug at R1).
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:242:| A4 | 4h timeout: bridge calls `updateApproval(..., 'denied', 'ifos_timeout')` cleanly | Integration test: write `.pending` marker, advance simulated clock 4h, assert cortextOS `pending/` is empty + `resolved/` has `denied` record |
docs/build-brief/00-MASTER-BRIEF.md:151:| Companies House, Xero, QuickBooks, FreeAgent, Sage, HMRC MTD | `packages/mcp-connectors/{name}/` first-party MCP | Vertical-specific or UK-specific |
docs/build-brief/00-MASTER-BRIEF.md:724:| `review-mcp-connector.md` | Specific checklist for a new MCP connector |
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:289:| **A1 Diagnostic** (no Bullhorn) | n/a | n/a | n/a | n/a | n/a | n/a — runs against public footprint per Ultraplan §8.1 line 489 |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/_supplementary/build-plan-original.md:814:- Last 7 days of data from: Stripe, GA4, Meta Ads, Google Ads, HubSpot, CRM, LinkedIn Ads, Shopify (if retail client), Klaviyo, etc.
docs/_supplementary/build-plan-original.md:821:- **GA4 MCP** — traffic + conversion
docs/_supplementary/build-plan-original.md:1261:| GA4 | No official | Build your own wrapper |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** **Accepted (founder-arbitrated 2026-05-31).** Codex `review-architecture-decision` skill RATIFIED this ADR at Round 3 of the cluster-E run (2026-05-31) after R1+R2 mechanical fixes (commits `ca66431` + `9b2e10a`). The ULTRAPLAN §8.1 A6 line 566 + line 567 amendments are now **permanent** (no longer provisional). The original Codex R3 Finding 3 (Concierge agent.md reframes 30-min SLA as Gate B without an authoritative ADR) is structurally closed by this Accept.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:13:ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:83:**ULTRAPLAN §8.1 A6 line 566 is amended in-band (Accepted by founder 2026-05-31)** following the ADR-006 precedent, which made the same kind of in-band amendment at line 496. There is no separate master-brief clause authorizing in-band spec amendments — master brief §10.3 step 4 only covers incorporating Codex feedback or writing a disagreement doc; the authority for the amendment is this ADR itself, now Accepted:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:114:ULTRAPLAN §8.1 A6 line 566 amended in the same commit as this ADR. Pre-amendment / post-amendment text is captured in this ADR's body. The amendment also updated line 567 Gate B target to include the new ≥90% 30-min SLA hit rate threshold (per ADR-007). See commit history for the diff.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:137:- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:227:| `review-mcp-connector.md` | Specific checklist for a new MCP connector |
docs/decisions/2026-05-18-codex-ratification-manifest.md:268:| 5 | §8 renderer footnote (before §8.1) | ADR-003 Edit C | ✓ verbatim |
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:535:- **MCP tools required:** Xero / QuickBooks / Sage (one of, per tenant), bank-feed connector
docs/specs/ULTRAPLAN.md:537:- **External APIs:** Xero API or QuickBooks API or Sage API; bank feed via Open Banking (TrueLayer / Plaid UK)
docs/specs/ULTRAPLAN.md:603:Already specified in §8.1 A4 as v1.0. The v1.1 work is the reframe of pitch and any latency optimisations needed once we have 3+ tenants in production. Not a new build, ~3 days of polish.
docs/specs/ULTRAPLAN.md:713:7. **Xero / QuickBooks / Sage** — 4 of 18 (one per tenant typically). Cash Conductor's blocker.
docs/_supplementary/strategic-plan.md:92:8. **Reporting Engine** — pulls from Stripe, GA4, Meta Ads, CRM. Delivers weekly briefing in-Slack + PDF
docs/_supplementary/strategic-plan.md:174:│    Notion, GA4, Meta Ads, Stripe, Calendly, Dentally        │
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
docs/_supplementary/planning-phase-brief.md:38:| **CC9** | **Custom MCP Servers (6 of them)** — DocuSign, GA4, Meta Ads, Companies House, Prospeo, Dentally | Python (FastMCP) or TypeScript | §3.8 (six of the 15 integration specs) |
docs/_supplementary/planning-phase-brief.md:178:- Session 25: Integration Specs Batch 2 — Stripe, GA4, Meta Ads, Cal.com (3.8)
docs/specs/_archive-build-handoff.md:400:- Companies House, Xero, QuickBooks, FreeAgent, Sage, HMRC MTD
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1054:### §8.1 — Hetzner-level: enable automatic backups (already done in §2.3)
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/_supplementary/technical-strategy-v2.md:259:0 7 * * 5 cd /tenant && claude -p "Run the Reporting Engine. Pull last 7 days from Stripe, GA4, Meta Ads, and HubSpot. Produce the weekly briefing. Save to /outbox/reports/. Post the summary to #leadership in Slack." --output-format json >> /logs/reporting-$(date +\%Y\%m\%d).log 2>&1
docs/specs/PRODUCT-SPEC.md:80:- **Per-tenant config:** accounting OAuth (Xero / QuickBooks / Sage), bank-feed connection, chase-cadence rules, escalation-threshold pounds, FD's mobile for Telegram approval.
docs/specs/PRODUCT-SPEC.md:329:- Customer clicks 5 OAuth buttons in the wizard: ATS (Bullhorn / Vincere / Voyager), accounting (Xero / Sage / QuickBooks), Microsoft 365 or Google Workspace, transcript source (Fathom / Fireflies / Ringover), LinkedIn.
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/_supplementary/execution-plan.md:291:  - *Prompt per integration:* "Write the {Integration Name} Integration Specification: the MCP server choice (fork X / build from Y spec / official), auth setup (OAuth flow or API key), the scopes/permissions required and why, the specific operations used by agents (read leads, write deals, fetch transcript, etc.), fallback behaviour on failure, test checklist, rate limit handling. Priority 1 integrations: Fathom, HubSpot, Gmail, Slack, Notion, DocuSign. Priority 2: Companies House, Prospeo, Kaspr, Stripe, GA4, Meta Ads, Cal.com, Loom, Google Drive."
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:71:- **Risk #5 (renderer-not-built)** in `docs/RISK-REGISTER.md` reduced from Blocking → High on Day 1 evening when ADR-003 + design doc Accepted. Three-stage ladder to Medium (W4 first Diagnostic render) → Low (W13 all 5 v1.0 bundles rendered).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
packages/mcp-connectors/quickbooks/src/auth.ts:1:// QuickBooks Online OAuth 2.0 token refresh + atomic disk persistence + concurrent-call dedup.
packages/mcp-connectors/quickbooks/src/auth.ts:3:// Per review-mcp-connector §2 (OAuth refresh idempotency):
packages/mcp-connectors/quickbooks/src/auth.ts:8://   - Tokens NEVER logged or thrown into error messages (review-mcp-connector §5).
packages/mcp-connectors/quickbooks/src/auth.ts:10:// QuickBooks vs Xero refresh diff:
packages/mcp-connectors/quickbooks/src/auth.ts:134:          `QuickBooks OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:26:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:34:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:42:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:78:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:94:**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.
packages/mcp-connectors/quickbooks/src/rate-limit.ts:1:// Rate limiter for QuickBooks Online. Per Intuit published limits
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
packages/mcp-connectors/open-banking/src/auth.ts:16:// Provider scope (W4 Day-26):
packages/mcp-connectors/quickbooks/src/payments.ts:1:// QuickBooks Payments capability surface — read + write (write is the only
packages/mcp-connectors/quickbooks/src/payments.ts:75:      "QuickBooks POST /payment succeeded but response contained no Payment record",
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:31:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:39:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:47:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:59:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:87:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:101:**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:111:**Generation:** LLM-driven (Claude API + evidence context). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0 scaffold; W4-5 polish wires real classifier.
packages/mcp-connectors/quickbooks/src/index.ts:1:// @ifos/quickbooks — public API
packages/mcp-connectors/quickbooks/src/index.ts:3:// The exports below split into TWO groups per review-mcp-connector §1 +
packages/mcp-connectors/quickbooks/src/index.ts:12:// review-mcp-connector §1 requires capability surface set-equality.
packages/mcp-connectors/quickbooks/src/index.ts:15:// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §quickbooks)
packages/mcp-connectors/quickbooks/src/index.ts:18:// quickbooks_oauth (action_type: quickbooks_oauth, green tier per autosend-policy.yaml)
packages/mcp-connectors/quickbooks/src/index.ts:20:// quickbooks_list_open_invoices (read-only) + quickbooks_get_invoice (read-only)
packages/mcp-connectors/quickbooks/src/index.ts:22:// quickbooks_list_payments (read-only) + quickbooks_write_payment_received
packages/mcp-connectors/quickbooks/src/client.ts:1:// QuickBooks Online HTTP client — wraps fetch with: OAuth token attach,
packages/mcp-connectors/quickbooks/src/client.ts:18:export const QB_BASE_URL_PRODUCTION = "https://quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:19:export const QB_BASE_URL_SANDBOX = "https://sandbox-quickbooks.api.intuit.com";
packages/mcp-connectors/quickbooks/src/client.ts:63:          "No QuickBooks tokens on disk; consent flow required to bootstrap " +
packages/mcp-connectors/quickbooks/src/client.ts:104:          `QuickBooks rate-limit budget exhausted (realm=${this.opts.config.realm_id}); ` +
packages/mcp-connectors/quickbooks/src/client.ts:133:          `QuickBooks network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
packages/mcp-connectors/quickbooks/src/client.ts:163:          `QuickBooks ${method} ${path} returned 401 after ${attempt + 1} attempt(s) including forced refresh`,
packages/mcp-connectors/quickbooks/src/client.ts:178:          `QuickBooks returned 429 after ${attempt + 1} attempt(s)`,
packages/mcp-connectors/quickbooks/src/client.ts:192:        throw new QbNotFoundError(`QuickBooks 404 on ${method} ${path}`);
packages/mcp-connectors/quickbooks/src/client.ts:196:          `QuickBooks rejected ${method} ${path} (HTTP 400)`,
packages/mcp-connectors/quickbooks/src/client.ts:201:        `QuickBooks ${method} ${path} failed (HTTP ${res.status})`,
packages/mcp-connectors/quickbooks/src/client.ts:206:      `QuickBooks ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:26:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:34:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:42:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:78:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:94:**v0 limitation:** voice classifier ≥ 0.75 gate (per agent.md §5 V3) skipped at v0; opener is deterministic anchor-based composition. Wire LLM + per-tenant voice classifier at W4 polish.
packages/mcp-connectors/companies-house/pnpm-lock.yaml:162:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:216:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:432:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:513:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:699:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:769:    resolution: {integrity: sha512-34wB/Y7MW7bzjKRjUKTa46I2Z7eV62Rkhva+KkopW7Qvv/OSWBqvkSY7vusOPrNuZcUG3tApvdVgNB8POj3SPw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:996:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/mcp-connectors/open-banking/src/index.ts:6:// declaring a v1.1+ stub as a current capability violated review-mcp-connector
packages/mcp-connectors/open-banking/src/index.ts:11:// The exports below split into TWO groups per review-mcp-connector §1 +
packages/mcp-connectors/quickbooks/src/cache.ts:1:// Disk cache for QuickBooks responses. Default TTL 5 min (invoices change often;
packages/mcp-connectors/quickbooks/src/cache.ts:23:      join(homedir(), ".ifos-cache", "quickbooks");
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:31:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:39:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:47:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:59:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:87:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:101:**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:111:**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.
packages/mcp-connectors/quickbooks/src/types.ts:1:// QuickBooks Online API types — subset of the v3 Accounting API surface
packages/mcp-connectors/quickbooks/src/types.ts:5:// QuickBooks is per-realm: each connected company has a unique realmId, and
packages/mcp-connectors/quickbooks/src/types.ts:25:  /** QuickBooks "realmId" (per-company identifier; unique per connected QB Online company). */
packages/mcp-connectors/quickbooks/package.json:2:  "name": "@ifos/quickbooks",
packages/mcp-connectors/quickbooks/package.json:5:  "description": "IFOS QuickBooks Online MCP connector — OAuth 2.0 refresh (per-realm) + invoices read + payments read/write. Used by Cash Conductor agent §4 Steps 1, 4, 5, 6, 9 per agents/recruitment/cash-conductor/tools.yaml.",
packages/mcp-connectors/quickbooks/src/invoices.ts:1:// QuickBooks Invoices capability surface — read-only (list + get).
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts:1:// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts:10:describe("quickbooks rate-limit", () => {
packages/mcp-connectors/quickbooks/src/errors.ts:1:// QuickBooks error hierarchy. Errors NEVER include credential values; only key
packages/mcp-connectors/quickbooks/src/errors.ts:2:// names + status codes + safe metadata. Per review-mcp-connector §5
packages/mcp-connectors/quickbooks/src/errors.ts:43:/** QuickBooks rejected the write payload (400 + Fault.type=ValidationFault). */
packages/mcp-connectors/quickbooks/README.md:1:# @ifos/quickbooks
packages/mcp-connectors/quickbooks/README.md:3:QuickBooks Online (QBO) Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 with **per-realm** token rotation + invoice read + payment read/write. Fixture-first; live tests deferred to first commercial QB sandbox signup (see §Tests).
packages/mcp-connectors/quickbooks/README.md:5:**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial QB sandbox signup for live-test verification).
packages/mcp-connectors/quickbooks/README.md:7:**Reference pattern:** mirrors `@ifos/xero` (W4 Day-25 RATIFIED scaffold). The per-realm OAuth diff vs Xero's per-tenant header is the load-bearing structural difference — documented in §"OAuth bootstrap" below. Every new MCP connector follows the parity model per `review-mcp-connector.md` §1.
packages/mcp-connectors/quickbooks/README.md:13:Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.
packages/mcp-connectors/quickbooks/README.md:17:| `quickbooks_oauth` | `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per realm; atomic-file-write persistence | Step 1 (auth refresh) | `quickbooks_oauth` | green |
packages/mcp-connectors/quickbooks/README.md:18:| `quickbooks_list_open_invoices` | `listOpenInvoices(client, options?)` | Query API: paginated Invoice rows with Balance > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
packages/mcp-connectors/quickbooks/README.md:19:| `quickbooks_get_invoice` | `getInvoice(client, invoiceId, options?)` | Single-entity read by QB Id | Step 9 (chase-draft validation) | n/a | n/a |
packages/mcp-connectors/quickbooks/README.md:20:| `quickbooks_list_payments` | `listPayments(client, options?)` | Query API: Payment rows since date | Step 5 (reconciliation pass) | n/a | n/a |
packages/mcp-connectors/quickbooks/README.md:21:| `quickbooks_write_payment_received` | `writePaymentReceived(client, payment)` | POST /payment — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
packages/mcp-connectors/quickbooks/README.md:23:All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (verified 2026-06-01 Codex F-R2 closure — `quickbooks_oauth` registered as green; `accounting_reconciliation_write` already present shared with @ifos/xero).
packages/mcp-connectors/quickbooks/README.md:46:import { QbClient, listOpenInvoices, writePaymentReceived } from "@ifos/quickbooks";
packages/mcp-connectors/quickbooks/README.md:81:Unlike Xero (one connection = one tenant_id sent as header), QuickBooks is **per-realm**: each connected company has a unique `realmId`, and tokens are realm-scoped. If you connect IFOS to 3 different QB companies, you have 3 separate token bundles + 3 separate base URLs (`/v3/company/<realmId>/...`).
packages/mcp-connectors/quickbooks/README.md:86:2. Construct the authorise URL with `scope=com.intuit.quickbooks.accounting` + `response_type=code` + your `redirect_uri`.
packages/mcp-connectors/quickbooks/README.md:94:| | Xero | QuickBooks |
packages/mcp-connectors/quickbooks/README.md:100:| Base URL | `https://api.xero.com/api.xro/2.0` (constant) | `https://quickbooks.api.intuit.com/v3/company/<realmId>` (production) or `https://sandbox-quickbooks.api.intuit.com/...` (sandbox) |
packages/mcp-connectors/quickbooks/README.md:124:| Local hard-gate (100%) reached | `QbRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "quickbooks", retry_after_seconds: null, consecutive_429s: 0}` |
packages/mcp-connectors/quickbooks/README.md:125:| Upstream 429 from QB API | `QbRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "quickbooks", retry_after_seconds: <N>, consecutive_429s: <N>}` |
packages/mcp-connectors/quickbooks/README.md:136:| `writePaymentReceived` | POST | **0** | n/a (writes never auto-retry) | `QbValidationError` (400) / `QbError` (5xx) → `ESC_ACCOUNTING_WRITE_FAIL` (warn; operator; consumer-emitted; payload includes `provider: "quickbooks"`, `endpoint: "/payment"`, `status_code`, `error_body_preview`) |
packages/mcp-connectors/quickbooks/README.md:155:Errors NEVER include credential values in their `.message` — only the key NAMES, status code, and safe metadata. Per `review-mcp-connector.md` §5 (zero secret interpolation).
packages/mcp-connectors/quickbooks/README.md:166:**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.
packages/mcp-connectors/quickbooks/README.md:168:**Live tests are deferred** to the first commercial QB sandbox signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal per review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold lands in the same commit as the first sandbox credentials.
packages/mcp-connectors/quickbooks/README.md:176:**Total: 26 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
packages/mcp-connectors/quickbooks/README.md:198:   ├── Step 5 (reconciliation pass)     ──┼─→ @ifos/quickbooks (this package)
packages/mcp-connectors/quickbooks/README.md:202:                                         QuickBooks Online v3 REST API
packages/mcp-connectors/quickbooks/README.md:203:                                         https://quickbooks.api.intuit.com/v3/company/<realmId>
packages/mcp-connectors/quickbooks/README.md:208:Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) **landed at the scaffold layer 2026-06-01** (commits 6ab59d8 + 5ab2f0f) with SKELETON TODO(W7-8) markers throughout. The W7-8 build slice replaces the TODOs with live impl; this connector is the accounting substrate it consumes (alongside @ifos/xero — Sage deferred per Cash Conductor §9 Q8). Per Cash Conductor agent.md §8, production-readiness still gates on Hire #1 + accounting commercial signups.
packages/mcp-connectors/quickbooks/README.md:214:Per `review-mcp-connector.md` §8:
packages/mcp-connectors/quickbooks/README.md:222:*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:1:// Package public surface smoke tests. Per review-mcp-connector §1
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:27:describe("@ifos/quickbooks package surface", () => {
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:34:    expect(QB_BASE_URL_PRODUCTION).toBe("https://quickbooks.api.intuit.com");
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:35:    expect(QB_BASE_URL_SANDBOX).toBe("https://sandbox-quickbooks.api.intuit.com");
packages/mcp-connectors/open-banking/src/cache.ts:3:// @ifos/companies-house + @ifos/xero + @ifos/quickbooks; intentionally
packages/mcp-connectors/quickbooks/tests/auth.test.ts:1:// OAuth tests per review-mcp-connector §2 (idempotency + atomic file
packages/mcp-connectors/quickbooks/tests/auth.test.ts:24:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/auth.test.ts:33:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/auth.test.ts:60:describe("quickbooks auth", () => {
packages/mcp-connectors/open-banking/src/types.ts:4:// Provider scope (W4 Day-26 scaffold):
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:1:// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:35:  scope: "com.intuit.quickbooks.accounting",
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:80:describe("quickbooks capabilities — invoices", () => {
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:108:  // Error-path coverage for listOpenInvoices (per review-mcp-connector §6 +
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:127:describe("quickbooks capabilities — payments", () => {
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:175:  // Error-path coverage for listPayments (per review-mcp-connector §6 +
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:182:      return new Response("QuickBooks internal error", { status: 500 });
packages/mcp-connectors/open-banking/src/errors.ts:2:// key names + status codes + safe metadata. Per review-mcp-connector §5.
packages/mcp-connectors/open-banking/README.md:3:UK Open Banking connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). Provider abstraction over **TrueLayer (v1.0)** + **Plaid UK (v1.1+ deferred)** with PSD2 90-day consent tracking + token-aging stages. Used by Cash Conductor for bank-transaction ingest + cash-flow forecast balance reads.
packages/mcp-connectors/open-banking/README.md:5:**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first TrueLayer dev signup for live-test verification).
packages/mcp-connectors/open-banking/README.md:7:**Reference pattern:** mirrors `@ifos/xero` + `@ifos/quickbooks` structure. The PSD2 consent lifecycle is the load-bearing structural difference vs the accounting connectors — banks legally require user re-authentication every 90 days regardless of refresh-token TTL.
packages/mcp-connectors/open-banking/README.md:13:Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.
packages/mcp-connectors/open-banking/README.md:15:**Provider scope (v1.0):** TrueLayer ONLY. Plaid UK exists as an internal stub in `src/` for v1.1+ work but is NOT a v1.0 bus-routed capability (per Codex F-R3 closure 2026-06-02 — `docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md`; pre-R3 the v1.1+ stub was declared as a v1.0 capability for set-equality, which violated review-mcp-connector single-upstream-provider intent + had no success fixtures to back the surface). When the first IFOS tenant picks Plaid over TrueLayer in v1.1+, the Plaid implementation graduates to a bus-routed capability and re-registers here.
packages/mcp-connectors/open-banking/README.md:187:**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.
packages/mcp-connectors/open-banking/README.md:189:**Live tests are deferred** to the first TrueLayer dev signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal — review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold will land in the same commit as the first sandbox credentials per the W4 Track-1 /goal §1 commercial-gate; the fixture-first suite below is fully sufficient for the W4 ratification pass.
packages/mcp-connectors/open-banking/README.md:198:**Total: 31 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
packages/mcp-connectors/open-banking/README.md:228:Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is one of the substrate dependencies (alongside the accounting connector chosen per tenant).
packages/mcp-connectors/open-banking/README.md:234:Per `review-mcp-connector.md` §8:
packages/mcp-connectors/open-banking/README.md:242:*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*
packages/mcp-connectors/xero/src/auth.ts:3:// Per review-mcp-connector §2 (OAuth refresh idempotency):
packages/mcp-connectors/xero/src/auth.ts:8://   - Tokens NEVER logged or thrown into error messages (review-mcp-connector §5).
packages/mcp-connectors/open-banking/tests/rate-limit.test.ts:1:// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
packages/mcp-connectors/open-banking/tests/scaffold.test.ts:1:// Package public surface smoke tests. Per review-mcp-connector §1.
packages/mcp-connectors/open-banking/tests/auth.test.ts:1:// OAuth tests per review-mcp-connector §2 (idempotency + atomic file write +
packages/mcp-connectors/open-banking/tests/capabilities.test.ts:1:// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
packages/mcp-connectors/open-banking/tests/capabilities.test.ts:116:  // Codex F-R2 issue #3 (open-banking): review-mcp-connector §6 requires
packages/mcp-connectors/xero/src/index.ts:3:// The exports below split into TWO groups per review-mcp-connector §1 +
packages/mcp-connectors/xero/README.md:3:Xero Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 token rotation + invoice read + payment read/write. Fixture-first; live tests deferred to first commercial Xero signup (see §Tests).
packages/mcp-connectors/xero/README.md:5:**Status:** Proposed (W4 Day-25 overnight scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial Xero signup for live-test verification).
packages/mcp-connectors/xero/README.md:7:**Reference pattern:** mirrors `@ifos/companies-house` (Day-13 RATIFIED). Every new MCP connector follows this structure per `review-mcp-connector.md` §1.
packages/mcp-connectors/xero/README.md:13:Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.
packages/mcp-connectors/xero/README.md:23:All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (`xero_oauth` registered as green per Codex F-R2 closure 2026-06-01; `accounting_reconciliation_write` already present per Day-25 verification). Line numbers in the policy file shift across edits — verify via `grep -n "^  xero_oauth:" agents/_shared/autosend-policy.yaml` rather than relying on a static citation here.
packages/mcp-connectors/xero/README.md:136:Errors NEVER include credential values in their `.message` — only the key NAMES, status code, and safe metadata. Per `review-mcp-connector.md` §5 (zero secret interpolation).
packages/mcp-connectors/xero/README.md:147:**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.
packages/mcp-connectors/xero/README.md:149:**Live tests are deferred** to the first commercial Xero signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal per review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold lands in the same commit as the first sandbox credentials per the W4 Track-1 /goal §1 commercial-gate.
packages/mcp-connectors/xero/README.md:157:**Total: 28 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
packages/mcp-connectors/xero/README.md:190:Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is the substrate it consumes.
packages/mcp-connectors/xero/README.md:196:Per `review-mcp-connector.md` §8:
packages/mcp-connectors/xero/src/errors.ts:2:// names + status codes + safe metadata. Per review-mcp-connector §5
packages/mcp-connectors/xero/tests/rate-limit.test.ts:1:// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
packages/mcp-connectors/xero/tests/scaffold.test.ts:1:// Package public surface smoke tests. Per review-mcp-connector §1
packages/mcp-connectors/xero/tests/auth.test.ts:1:// OAuth tests per review-mcp-connector §2 (idempotency + atomic file
packages/mcp-connectors/xero/tests/capabilities.test.ts:1:// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
packages/mcp-connectors/xero/tests/capabilities.test.ts:105:  // Error-path coverage for listOpenInvoices (per review-mcp-connector §6 +
packages/mcp-connectors/xero/tests/capabilities.test.ts:166:  // Error-path coverage for listPayments (per review-mcp-connector §6 +

codex
The local package passes `pnpm typecheck`, `pnpm test`, and `pnpm build`. The remaining decision is based on contract fidelity and implementation risks that the tests don’t cover.
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/src/client.ts | sed -n '28,40p;168,187p'; nl -ba packages/mcp-connectors/quickbooks/README.md | sed -n '131,140p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    28	  signal?: AbortSignal;
    29	}
    30	
    31	function sleep(ms: number): Promise<void> {
    32	  return new Promise((r) => setTimeout(r, ms));
    33	}
    34	
    35	function backoff(attempt: number): number {
    36	  const base = 250 * 2 ** attempt;
    37	  return Math.floor(Math.random() * base);
    38	}
    39	
    40	export class QbClient {
   168	      // 429: rate-limited; honour Retry-After then retry (GET only)
   169	      if (res.status === 429 && attempt < max_retries) {
   170	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   171	        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
   172	        await sleep(waitMs);
   173	        continue;
   174	      }
   175	      if (res.status === 429) {
   176	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   177	        throw new QbRateLimitError(
   178	          `QuickBooks returned 429 after ${attempt + 1} attempt(s)`,
   179	          retryAfter > 0 ? retryAfter : null,
   180	        );
   181	      }
   182	
   183	      // 5xx: retry with backoff (GET only)
   184	      if (res.status >= 500 && attempt < max_retries) {
   185	        await sleep(backoff(attempt));
   186	        continue;
   187	      }
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

exec
/bin/zsh -lc "for f in logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_quickbooks.output.md logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_quickbooks.verdict.txt logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_quickbooks.verdict.txt logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.verdict.txt; do printf '%s\\n' \""'$f"; sed -n '"'1,80p' \""'$f"; done' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_quickbooks.output.md
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
session id: 019e880f-b67a-75d2-bdd8-266b8d114219
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
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_quickbooks.verdict.txt
REJECTED:2
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_quickbooks.verdict.txt
REJECTED:3
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.verdict.txt
REJECTED:5

codex
Older ratification logs show this connector has been rejected in prior rounds and remediated down from five to two issues. I’m not using those as the verdict, but they’re useful for spotting whether any known blocker is still present.
exec
/bin/zsh -lc "rg -n \"SELECT \\* FROM|issued_since|since\\?:|start_position|max_results|Payment WHERE|Invoice WHERE\" packages/mcp-connectors/quickbooks/src packages/mcp-connectors/quickbooks/tests -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/quickbooks/src/invoices.ts:5://   GET /v3/company/<realmId>/query?query=SELECT * FROM Invoice WHERE Balance > '0'
packages/mcp-connectors/quickbooks/src/invoices.ts:17:  issued_since?: string;
packages/mcp-connectors/quickbooks/src/invoices.ts:19:  start_position?: number;
packages/mcp-connectors/quickbooks/src/invoices.ts:20:  max_results?: number;
packages/mcp-connectors/quickbooks/src/invoices.ts:34:  const start = options.start_position ?? 1;
packages/mcp-connectors/quickbooks/src/invoices.ts:35:  const max = options.max_results ?? 100;
packages/mcp-connectors/quickbooks/src/invoices.ts:36:  const key = `invoices:open:start=${start}:max=${max}:since=${options.issued_since ?? "all"}`;
packages/mcp-connectors/quickbooks/src/invoices.ts:44:  let query = "SELECT * FROM Invoice WHERE Balance > '0'";
packages/mcp-connectors/quickbooks/src/invoices.ts:45:  if (options.issued_since) {
packages/mcp-connectors/quickbooks/src/invoices.ts:46:    query += ` AND TxnDate >= '${options.issued_since}'`;
packages/mcp-connectors/quickbooks/src/payments.ts:18:  since?: string;
packages/mcp-connectors/quickbooks/src/payments.ts:19:  start_position?: number;
packages/mcp-connectors/quickbooks/src/payments.ts:20:  max_results?: number;
packages/mcp-connectors/quickbooks/src/payments.ts:31:  const start = options.start_position ?? 1;
packages/mcp-connectors/quickbooks/src/payments.ts:32:  const max = options.max_results ?? 100;
packages/mcp-connectors/quickbooks/src/payments.ts:40:  let query = "SELECT * FROM Payment";

exec
/bin/zsh -lc "tail -n 80 logs/codex-ratification/20260602T111820Z-43583/packages_mcp-connectors_quickbooks.output.md; printf '\\n--- prior verdicts ---\\n'; for f in logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_quickbooks.output.md logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_quickbooks.output.md logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.output.md; do printf '%s\\n' \""'$f"; tail -n 40 "$f"; done' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
reasoning summaries: none
session id: 019e880f-b67a-75d2-bdd8-266b8d114219
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
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_quickbooks.verdict.txt
REJECTED:2
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_quickbooks.verdict.txt
REJECTED:3
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.verdict.txt
REJECTED:5

codex
Older ratification logs show this connector has been rejected in prior rounds and remediated down from five to two issues. I’m not using those as the verdict, but they’re useful for spotting whether any known blocker is still present.

--- prior verdicts ---
logs/codex-ratification/20260602T111248Z-39896/packages_mcp-connectors_quickbooks.output.md
   420	| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |

exec
/bin/zsh -lc 'pnpm --dir packages/mcp-connectors/quickbooks build' in /Users/madsadmin/code/CortexOS
 succeeded in 2091ms:

> @ifos/quickbooks@0.1.0 build /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks
> tsup

CLI Building entry: src/index.ts
CLI Using tsconfig: tsconfig.json
CLI tsup v8.5.1
CLI Using tsup config: /Users/madsadmin/code/CortexOS/packages/mcp-connectors/quickbooks/tsup.config.ts
CLI Target: node20
CLI Cleaning output folder
ESM Build start
ESM dist/index.js     14.04 KB
ESM dist/index.js.map 36.23 KB
ESM ⚡️ Build success in 12ms
DTS Build start
DTS ⚡️ Build success in 703ms
DTS dist/index.d.ts 8.77 KB

web search: 
web search: Intuit QuickBooks Online API rate limits 500 requests per minute 10 concurrent requests
web search: 
web search: https://developer.intuit.com/app/developer/qbo/docs/learn/rest-api-features
codex
REJECTED

1. QuickBooks 10/sec throttle is documented but not implemented. README lines 110-116 cite Intuit limits, then line 113 says the 10 requests/second cap is “not enforced here”; `src/rate-limit.ts` lines 13-15 and 39-63 implement only the 500/minute bucket. This fails `review-mcp-connector.md` §3 because every upstream rate-limit needs a declared safety margin, bucket implementation, and exhaustion test. Add a per-realm 10/sec bucket, document its margin, and add a bucket-exhaustion vitest.

2. The README mischaracterizes the upstream 10/sec cap as “concurrent”. README line 113 says “10 calls per second concurrent throttle”, but the cited Intuit REST API limits page describes “10 requests per second, per realm ID and app”; a serial loop can still exceed that. This fails the top-level citation-accuracy / honest-signal check because the caveat justifies not enforcing a real rate-limit. Correct the wording and enforcement model so the connector handles the actual 10/sec request budget.
tokens used
122,674
REJECTED

1. QuickBooks 10/sec throttle is documented but not implemented. README lines 110-116 cite Intuit limits, then line 113 says the 10 requests/second cap is “not enforced here”; `src/rate-limit.ts` lines 13-15 and 39-63 implement only the 500/minute bucket. This fails `review-mcp-connector.md` §3 because every upstream rate-limit needs a declared safety margin, bucket implementation, and exhaustion test. Add a per-realm 10/sec bucket, document its margin, and add a bucket-exhaustion vitest.

2. The README mischaracterizes the upstream 10/sec cap as “concurrent”. README line 113 says “10 calls per second concurrent throttle”, but the cited Intuit REST API limits page describes “10 requests per second, per realm ID and app”; a serial loop can still exceed that. This fails the top-level citation-accuracy / honest-signal check because the caveat justifies not enforcing a real rate-limit. Correct the wording and enforcement model so the connector handles the actual 10/sec request budget.
logs/codex-ratification/20260602T103527Z-17484/packages_mcp-connectors_quickbooks.output.md
   175	  // Error-path coverage for listPayments (per review-mcp-connector §6 +

exec
/bin/zsh -lc "rg -n \"MCP_LIVE_TESTS|describe\\.skipIf|live tests|LIVE\" packages/mcp-connectors/quickbooks/tests packages/mcp-connectors/quickbooks/src -S" in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
exec
/bin/zsh -lc 'rg --files agents/recruitment/cash-conductor packages/mcp-connectors/quickbooks/tests | sort' in /Users/madsadmin/code/CortexOS
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
packages/mcp-connectors/quickbooks/tests/auth.test.ts
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts

codex
REJECTED

1. 401 retry policy is documented but not implemented. `README.md` line 138 claims "401 from any GET" will "force-refresh access_token, retry once", but `src/client.ts` lines 141-145 only set `this.current_tokens = null` and retry; the next pass reloads the same disk token via lines 59-75 and does not call `refreshTokens()` unless `shouldRefresh()` says it is near expiry. Fix by refreshing from the current token bundle on 401 before retrying, and add a test for that path.

2. Live-test gating is claimed but absent. `README.md` lines 165-169 advertise live API tests gated by `MCP_LIVE_TESTS=true`, but `rg "MCP_LIVE_TESTS|describe\\.skipIf|live tests|LIVE" packages/mcp-connectors/quickbooks/tests packages/mcp-connectors/quickbooks/src` returns no matches. This fails the honest-signal requirement and conflicts with review-mcp-connector §6’s live-test gate contract. Add gated live tests with `describe.skipIf(!LIVE)` or explicitly mark live tests as not wired until first QB sandbox signup.

3. The README contains stale status about Cash Conductor not yet existing. `README.md` line 209 says the full Cash Conductor bundle "lands later", but the repo already contains `agents/recruitment/cash-conductor/cycle.sh`, `validate.sh`, `context.sh`, `cleanup.sh`, `tools.yaml`, and fixtures. This violates top-level Rule 5 honest signal. Update the wording to reflect the current bundle state and any remaining wiring gaps only.
tokens used
59,896
REJECTED

1. 401 retry policy is documented but not implemented. `README.md` line 138 claims "401 from any GET" will "force-refresh access_token, retry once", but `src/client.ts` lines 141-145 only set `this.current_tokens = null` and retry; the next pass reloads the same disk token via lines 59-75 and does not call `refreshTokens()` unless `shouldRefresh()` says it is near expiry. Fix by refreshing from the current token bundle on 401 before retrying, and add a test for that path.

2. Live-test gating is claimed but absent. `README.md` lines 165-169 advertise live API tests gated by `MCP_LIVE_TESTS=true`, but `rg "MCP_LIVE_TESTS|describe\\.skipIf|live tests|LIVE" packages/mcp-connectors/quickbooks/tests packages/mcp-connectors/quickbooks/src` returns no matches. This fails the honest-signal requirement and conflicts with review-mcp-connector §6’s live-test gate contract. Add gated live tests with `describe.skipIf(!LIVE)` or explicitly mark live tests as not wired until first QB sandbox signup.

3. The README contains stale status about Cash Conductor not yet existing. `README.md` line 209 says the full Cash Conductor bundle "lands later", but the repo already contains `agents/recruitment/cash-conductor/cycle.sh`, `validate.sh`, `context.sh`, `cleanup.sh`, `tools.yaml`, and fixtures. This violates top-level Rule 5 honest signal. Update the wording to reflect the current bundle state and any remaining wiring gaps only.
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.output.md
    97	REJECT immediately if any of these appear in the connector source or fixtures:
    98	
    99	- The strings `composio` or `agentmail` (case-insensitive) — adapter boundary per master brief §3.
   100	- Imports from `packages/harness/cortextos/` (submodule boundary; the connector is in `packages/mcp-connectors/` and must not depend on the cortextOS submodule).
   101	- Direct writes to `decision_log` from the connector (vault/Postgres split per ADR-002 — only the shell `_shared/hook-helpers.sh` writes Postgres; connectors return data, the agent's cycle.sh persists).
   102	- Hardcoded tenant slugs (`migration-test`, `test-tenant-b`, etc.) in `src/` outside of test fixtures.
   103	
   104	## §9 — Output contract for this skill
   105	
   106	```
   107	RATIFIED
   108	[optional 0-5 lines of advisory notes — minor wording, suggested README clarifications, deferred-to-next-touch items]
   109	```
   110	

codex
REJECTED

1. Capabilities surface is not set-equal. `agents/recruitment/cash-conductor/tools.yaml` lines 60-89 declares `quickbooks_oauth`, `quickbooks_list_open_invoices`, `quickbooks_get_invoice`, `quickbooks_list_payments`, and `quickbooks_write_payment_received`, while `packages/mcp-connectors/quickbooks/src/index.ts` lines 14-34 exports raw functions/helpers such as `refreshTokens`, `listOpenInvoices`, `rateCheck`, and `resetRateLimit`; the README table lines 15-24 lists yet another surface including `QbClient`, `loadTokens`, and `saveTokens`. This fails `review-mcp-connector.md` §1. Fix by making the tool IDs, exported capability functions, and README capability table one identical public set, with non-capability helpers excluded or explicitly non-public.

2. `quickbooks_oauth` is documented as green but is absent from autosend policy. README line 18 assigns `quickbooks_oauth` action_type `green`, and line 26 says it is “queued for addition”; `agents/recruitment/cash-conductor/tools.yaml` lines 60-64 also references it, but `agents/_shared/autosend-policy.yaml` lines 209-214 only contains `accounting_reconciliation_write` for this connector path. This fails `review-mcp-connector.md` §7 lines 89-93. Add `quickbooks_oauth` to `agents/_shared/autosend-policy.yaml` in the same commit with the documented tier, or remove the action_type until it lands.

3. Rate-limit exhaustion does not document or test the required ESC signal. README lines 97-103 cites Intuit limits and the 80%/100% bucket, but only mentions `QbRateLimitError`; it does not name `ESC_RATE_LIMIT_HIT` with `payload.upstream='quickbooks'`, and `tests/rate-limit.test.ts` lines 38-44 only asserts `consume()` returns false. This fails `review-mcp-connector.md` §3 lines 33-38. Document the ESC emission contract and add a fixture/wrapper test asserting bucket exhaustion produces the required ESC payload.

4. Retry policy omits required ESC codes for state-changing failure paths. README lines 113-115 lists `writePaymentReceived` and `refreshTokens` exhaustion as `QbValidationError` / `QbError` / `QbAuthError`, not an `ESC_<PROVIDER>_WRITE_FAIL` or OAuth equivalent. This fails `review-mcp-connector.md` §4 lines 42-47. Add explicit ESC codes for `writePaymentReceived` and OAuth refresh failure, and wire/assert them in the consuming shell wrapper.

5. Fixture coverage is incomplete for read capabilities. `tests/capabilities.test.ts` lines 75-84 has only a happy-path fixture for `listOpenInvoices`, and lines 104-112 has only a happy-path fixture for `listPayments`; the only read error fixture is `getInvoice` 404 at lines 95-100. This fails `review-mcp-connector.md` §6 lines 68-81, which requires every capability to have at least one success and one error-path fixture. Add error-path fixtures for `listOpenInvoices` and `listPayments` such as 429, 5xx, or malformed provider responses.
tokens used
72,451
REJECTED

1. Capabilities surface is not set-equal. `agents/recruitment/cash-conductor/tools.yaml` lines 60-89 declares `quickbooks_oauth`, `quickbooks_list_open_invoices`, `quickbooks_get_invoice`, `quickbooks_list_payments`, and `quickbooks_write_payment_received`, while `packages/mcp-connectors/quickbooks/src/index.ts` lines 14-34 exports raw functions/helpers such as `refreshTokens`, `listOpenInvoices`, `rateCheck`, and `resetRateLimit`; the README table lines 15-24 lists yet another surface including `QbClient`, `loadTokens`, and `saveTokens`. This fails `review-mcp-connector.md` §1. Fix by making the tool IDs, exported capability functions, and README capability table one identical public set, with non-capability helpers excluded or explicitly non-public.

2. `quickbooks_oauth` is documented as green but is absent from autosend policy. README line 18 assigns `quickbooks_oauth` action_type `green`, and line 26 says it is “queued for addition”; `agents/recruitment/cash-conductor/tools.yaml` lines 60-64 also references it, but `agents/_shared/autosend-policy.yaml` lines 209-214 only contains `accounting_reconciliation_write` for this connector path. This fails `review-mcp-connector.md` §7 lines 89-93. Add `quickbooks_oauth` to `agents/_shared/autosend-policy.yaml` in the same commit with the documented tier, or remove the action_type until it lands.

3. Rate-limit exhaustion does not document or test the required ESC signal. README lines 97-103 cites Intuit limits and the 80%/100% bucket, but only mentions `QbRateLimitError`; it does not name `ESC_RATE_LIMIT_HIT` with `payload.upstream='quickbooks'`, and `tests/rate-limit.test.ts` lines 38-44 only asserts `consume()` returns false. This fails `review-mcp-connector.md` §3 lines 33-38. Document the ESC emission contract and add a fixture/wrapper test asserting bucket exhaustion produces the required ESC payload.

4. Retry policy omits required ESC codes for state-changing failure paths. README lines 113-115 lists `writePaymentReceived` and `refreshTokens` exhaustion as `QbValidationError` / `QbError` / `QbAuthError`, not an `ESC_<PROVIDER>_WRITE_FAIL` or OAuth equivalent. This fails `review-mcp-connector.md` §4 lines 42-47. Add explicit ESC codes for `writePaymentReceived` and OAuth refresh failure, and wire/assert them in the consuming shell wrapper.

5. Fixture coverage is incomplete for read capabilities. `tests/capabilities.test.ts` lines 75-84 has only a happy-path fixture for `listOpenInvoices`, and lines 104-112 has only a happy-path fixture for `listPayments`; the only read error fixture is `getInvoice` 404 at lines 95-100. This fails `review-mcp-connector.md` §6 lines 68-81, which requires every capability to have at least one success and one error-path fixture. Add error-path fixtures for `listOpenInvoices` and `listPayments` such as 429, 5xx, or malformed provider responses.

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/src/rate-limit.ts | sed -n '1,80p'; nl -ba packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts | sed -n '1,70p'" in /Users/madsadmin/code/CortexOS
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
    46	    shouldBackoff = true;
    47	  }
    48	
    49	  return {
    50	    realm_id,
    51	    minute_used,
    52	    minute_remaining: MINUTE_HARD - minute_used,
    53	    shouldBackoff,
    54	    reason,
    55	  };
    56	}
    57	
    58	export function consume(
    59	  realm_id: string,
    60	  now: () => number = Date.now,
    61	): boolean {
    62	  const state = check(realm_id, now);
    63	  if (state.reason === "minute-hard") return false;
    64	  const t = now();
    65	  const minute = pruneMinute(minuteTimestamps.get(realm_id), t);
    66	  minute.push(t);
    67	  minuteTimestamps.set(realm_id, minute);
    68	  return true;
    69	}
    70	
    71	export function reset(realm_id?: string): void {
    72	  if (realm_id !== undefined) {
    73	    minuteTimestamps.delete(realm_id);
    74	  } else {
    75	    minuteTimestamps.clear();
    76	  }
    77	}
     1	// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
     2	// MUST exist). Verifies soft (80%) and hard (100%) thresholds against
     3	// the 500/min Intuit bucket.
     4	
     5	import { beforeEach, describe, expect, it } from "vitest";
     6	import { check, consume, reset } from "../src/rate-limit.js";
     7	
     8	const REALM = "test-realm-rate-limit";
     9	
    10	describe("quickbooks rate-limit", () => {
    11	  beforeEach(() => {
    12	    reset();
    13	  });
    14	
    15	  it("starts at 0 used with full budget", () => {
    16	    const s = check(REALM);
    17	    expect(s.minute_used).toBe(0);
    18	    expect(s.minute_remaining).toBe(500);
    19	    expect(s.shouldBackoff).toBe(false);
    20	    expect(s.reason).toBe("ok");
    21	  });
    22	
    23	  it("does NOT backoff before minute soft threshold (400)", () => {
    24	    for (let i = 0; i < 399; i++) consume(REALM);
    25	    const s = check(REALM);
    26	    expect(s.minute_used).toBe(399);
    27	    expect(s.shouldBackoff).toBe(false);
    28	  });
    29	
    30	  it("triggers minute-soft backoff at 400", () => {
    31	    for (let i = 0; i < 400; i++) consume(REALM);
    32	    const s = check(REALM);
    33	    expect(s.minute_used).toBe(400);
    34	    expect(s.shouldBackoff).toBe(true);
    35	    expect(s.reason).toBe("minute-soft");
    36	  });
    37	
    38	  it("blocks at minute-hard 500 (consume returns false)", () => {
    39	    for (let i = 0; i < 500; i++) consume(REALM);
    40	    const s = check(REALM);
    41	    expect(s.minute_used).toBe(500);
    42	    expect(s.reason).toBe("minute-hard");
    43	    expect(consume(REALM)).toBe(false);
    44	  });
    45	
    46	  it("isolates buckets per realm_id", () => {
    47	    for (let i = 0; i < 450; i++) consume("realm-A");
    48	    expect(check("realm-A").shouldBackoff).toBe(true);
    49	    expect(check("realm-B").shouldBackoff).toBe(false);
    50	    expect(check("realm-B").minute_used).toBe(0);
    51	  });
    52	});

codex
REJECTED

1. QuickBooks 10/sec upstream limit is documented but deliberately not enforced. `README.md:112-116` lists “10 calls per second” and says it is “not enforced here”; `src/rate-limit.ts:1-14` repeats that caveat, and `src/rate-limit.ts:29-68` implements only the 500/minute bucket. This fails `review-mcp-connector.md` §3 because every upstream rate-limit needs a bucket implementation and exhaustion test. Add a per-realm 10/sec bucket, document its safety margin, and add a vitest for second-bucket exhaustion.

2. Retry backoff documentation does not match the implementation. `README.md:135` declares “Exponential w/ jitter (250-1000ms)”, but `src/client.ts:35-38` returns `Math.random() * (250 * 2 ** attempt)`, which can be 0ms and, under the default 2 retries, only reaches <500ms before exhaustion (`src/client.ts:168-186`). This fails `review-mcp-connector.md` §4’s explicit retry-policy requirement and top-level Rule 5 honest signal. Either implement the documented 250-1000ms jitter window or correct the README and tests to match the actual retry budget.
tokens used
94,697
REJECTED

1. QuickBooks 10/sec upstream limit is documented but deliberately not enforced. `README.md:112-116` lists “10 calls per second” and says it is “not enforced here”; `src/rate-limit.ts:1-14` repeats that caveat, and `src/rate-limit.ts:29-68` implements only the 500/minute bucket. This fails `review-mcp-connector.md` §3 because every upstream rate-limit needs a bucket implementation and exhaustion test. Add a per-realm 10/sec bucket, document its safety margin, and add a vitest for second-bucket exhaustion.

2. Retry backoff documentation does not match the implementation. `README.md:135` declares “Exponential w/ jitter (250-1000ms)”, but `src/client.ts:35-38` returns `Math.random() * (250 * 2 ** attempt)`, which can be 0ms and, under the default 2 retries, only reaches <500ms before exhaustion (`src/client.ts:168-186`). This fails `review-mcp-connector.md` §4’s explicit retry-policy requirement and top-level Rule 5 honest signal. Either implement the documented 250-1000ms jitter window or correct the README and tests to match the actual retry budget.
