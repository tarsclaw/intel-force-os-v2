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
session id: 019e83a2-386e-7261-85fc-f81ad4e6ac8b
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
// Used by Cash Conductor agent (W4-7 build wave) per
// agents/recruitment/cash-conductor/tools.yaml capabilities:
//   quickbooks_oauth                 → auth.refreshTokens + client.getValidAccessToken
//   accounting_reconciliation_write  → payments.writePaymentReceived
//   (read-only invoice register)     → invoices.listOpenInvoices + getInvoice
//
// Reference implementation: @ifos/xero (Day-25 RATIFIED scaffold). Pattern
// parity intentional — review-mcp-connector §1 requires capability surface
// set-equality with the reference connector for the same Cash Conductor
// consumer interface.

export {
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  refreshTokenNearExpiry,
  _resetInflightForTest,
} from "./auth.js";
export {
  QbClient,
  QB_BASE_URL_PRODUCTION,
  QB_BASE_URL_SANDBOX,
  DEFAULT_TIMEOUT_MS,
} from "./client.js";
export { listOpenInvoices, getInvoice } from "./invoices.js";
export { listPayments, writePaymentReceived } from "./payments.js";
export { QbCache } from "./cache.js";
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
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
import { QbValidationError, QbNotFoundError } from "../src/errors.js";
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
I’m going to verify the connector against the ratification checklist in the live tree: public exports, README claims, agent tool references, autosend policy, and boundary/secret patterns.
exec
/bin/zsh -lc "rg -n \"quickbooks|QbClient|loadTokens|saveTokens|refreshTokens|shouldRefresh|refreshTokenNearExpiry|listOpenInvoices|getInvoice|listPayments|writePaymentReceived|quickbooks_oauth|accounting_reconciliation_write\" packages/mcp-connectors/quickbooks agents -g 'tools.yaml' -g 'README.md' -g 'src/index.ts' -g 'autosend-policy.yaml'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/diagnostic/tools.yaml:172:  - quickbooks     # Cash Conductor's territory
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
agents/recruitment/cash-conductor/tools.yaml:184:#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
agents/recruitment/cash-conductor/tools.yaml:189:#   quickbooks_oauth                   green
packages/mcp-connectors/quickbooks/README.md:1:# @ifos/quickbooks
packages/mcp-connectors/quickbooks/README.md:15:| `QbClient` (class) | HTTP wrapper: OAuth attach + rate-limit budget + 429 / 5xx retry + per-realm URL construction | constructed in cycle.sh Step 1 | n/a (transport) | n/a |
packages/mcp-connectors/quickbooks/README.md:16:| `loadTokens(config)` | Read OAuth tokens from disk | Step 1 (auth refresh) | n/a (read-only) | n/a |
packages/mcp-connectors/quickbooks/README.md:17:| `saveTokens(config, t)` | Atomic write (.tmp + rename) to token file | refreshTokens internal | n/a | n/a |
packages/mcp-connectors/quickbooks/README.md:18:| `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per realm; returns + persists new bundle | Step 1 | `quickbooks_oauth` | green |
packages/mcp-connectors/quickbooks/README.md:19:| `shouldRefresh(tokens, now?, window?)` | Returns true if access_token expires within window (default 5 min) | Step 1 + per-call | n/a (pure) | n/a |
packages/mcp-connectors/quickbooks/README.md:20:| `refreshTokenNearExpiry(tokens, now?, danger?)` | Returns true if refresh token within 7-day re-consent danger window (QB ~100-day TTL) | operator alerting | n/a (pure) | n/a |
packages/mcp-connectors/quickbooks/README.md:21:| `listOpenInvoices(client, options?)` | Query API: paginated Invoice rows with Balance > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
packages/mcp-connectors/quickbooks/README.md:22:| `getInvoice(client, invoiceId, options?)` | Single-entity read by QB Id | Step 9 (chase-draft validation) | n/a | n/a |
packages/mcp-connectors/quickbooks/README.md:23:| `listPayments(client, options?)` | Query API: Payment rows since date | Step 5 (reconciliation pass) | n/a | n/a |
packages/mcp-connectors/quickbooks/README.md:24:| `writePaymentReceived(client, payment)` | POST /payment — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
packages/mcp-connectors/quickbooks/README.md:26:All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `quickbooks_oauth` is queued for addition at first Cash Conductor cycle.sh wiring (W7); `accounting_reconciliation_write` is already present (shared with @ifos/xero per Day-25 verification).
packages/mcp-connectors/quickbooks/README.md:33:import { QbClient, listOpenInvoices, writePaymentReceived } from "@ifos/quickbooks";
packages/mcp-connectors/quickbooks/README.md:35:const client = new QbClient({
packages/mcp-connectors/quickbooks/README.md:45:const invoices = await listOpenInvoices(client, { issued_since: "2026-04-01" });
packages/mcp-connectors/quickbooks/README.md:48:    await writePaymentReceived(client, {
packages/mcp-connectors/quickbooks/README.md:73:2. Construct the authorise URL with `scope=com.intuit.quickbooks.accounting` + `response_type=code` + your `redirect_uri`.
packages/mcp-connectors/quickbooks/README.md:87:| Base URL | `https://api.xero.com/api.xro/2.0` (constant) | `https://quickbooks.api.intuit.com/v3/company/<realmId>` (production) or `https://sandbox-quickbooks.api.intuit.com/...` (sandbox) |
packages/mcp-connectors/quickbooks/README.md:91:After bootstrap, this connector's `refreshTokens()` handles all subsequent rotations automatically. Note that QB refresh tokens have a hard ~100-day TTL — if no refresh happens for that long, you must re-do the consent dance. `refreshTokenNearExpiry()` returns true when within the 7-day danger window so operator alerts can fire.
packages/mcp-connectors/quickbooks/README.md:103:This connector tracks the minute bucket per `src/rate-limit.ts`. Soft backoff at 80% (400/minute); hard fail at 100% → `QbRateLimitError`. State is in-process and per-realm — a multi-realm runtime that holds many `QbClient` instances in one process still gets correct isolation.
packages/mcp-connectors/quickbooks/README.md:113:| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` or `QbRateLimitError` |
packages/mcp-connectors/quickbooks/README.md:114:| `writePaymentReceived` | POST | **0** | n/a (writes never auto-retry) | `QbValidationError` (400) / `QbError` (5xx) |
packages/mcp-connectors/quickbooks/README.md:115:| `refreshTokens` | POST | **0** | n/a | `QbAuthError` (caller may re-attempt with new credentials) |
packages/mcp-connectors/quickbooks/README.md:152:- `tests/auth.test.ts`: 7 (load missing, round-trip, shouldRefresh, refreshTokenNearExpiry, refresh success, 401 + no-token-leak, concurrent dedup)
packages/mcp-connectors/quickbooks/README.md:177:   ├── Step 5 (reconciliation pass)     ──┼─→ @ifos/quickbooks (this package)
packages/mcp-connectors/quickbooks/README.md:182:                                         https://quickbooks.api.intuit.com/v3/company/<realmId>
agents/_shared/autosend-policy.yaml:209:  accounting_reconciliation_write:

exec
/bin/zsh -lc "rg -n \"console\\.(log|error|warn).*\\"'$'"\\{.*(KEY|SECRET|PASSWORD|TOKEN|BEARER)|throw\\s+new\\s+Error.*\\"'$'"\\{.*(KEY|SECRET|PASSWORD)|composio|agentmail|packages/harness/cortextos|decision_log|migration-test|test-tenant-b\" packages/mcp-connectors/quickbooks" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/quickbooks/README.md:195:- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
packages/mcp-connectors/quickbooks/README.md:196:- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)

exec
/bin/zsh -lc "rg -n \"describe\\.skipIf|MCP_LIVE_TESTS|fetch\\(|new Response|QbRateLimitError|ESC_|RateLimit|rate-limit|accounting_reconciliation_write|quickbooks_oauth\" packages/mcp-connectors/quickbooks agents/_shared/autosend-policy.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:50:    reason: "Stores profile snapshot to /vault/<tenant>/wiki/raw/; no external send; no rate-limit cost"
agents/_shared/autosend-policy.yaml:56:    reason: "Read-only Xero query; rate-limited via Xero's own quotas; no side effect"
agents/_shared/autosend-policy.yaml:122:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:128:    reason: "Internal audit row written by cycle.sh Step 1 when firm-name validation fails. Carries ESC_INPUT_VALIDATION_FAIL payload; just the audit-row write, not external send."
agents/_shared/autosend-policy.yaml:134:    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
agents/_shared/autosend-policy.yaml:209:  accounting_reconciliation_write:
agents/_shared/autosend-policy.yaml:299:  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
packages/mcp-connectors/quickbooks/src/rate-limit.ts:2:// (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):
packages/mcp-connectors/quickbooks/src/payments.ts:3:// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
packages/mcp-connectors/quickbooks/src/payments.ts:57: * action_type='accounting_reconciliation_write' (yellow tier per
packages/mcp-connectors/quickbooks/src/payments.ts:61: * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
packages/mcp-connectors/quickbooks/src/index.ts:5://   quickbooks_oauth                 → auth.refreshTokens + client.getValidAccessToken
packages/mcp-connectors/quickbooks/src/index.ts:6://   accounting_reconciliation_write  → payments.writePaymentReceived
packages/mcp-connectors/quickbooks/src/index.ts:34:  reset as resetRateLimit,
packages/mcp-connectors/quickbooks/src/index.ts:35:} from "./rate-limit.js";
packages/mcp-connectors/quickbooks/src/index.ts:39:  QbRateLimitError,
packages/mcp-connectors/quickbooks/src/index.ts:52:export type { RateState } from "./rate-limit.js";
packages/mcp-connectors/quickbooks/src/client.ts:2:// rate-limit budget, 429 retry-after, 5xx exponential backoff (max 2 retries),
packages/mcp-connectors/quickbooks/src/client.ts:11:  QbRateLimitError,
packages/mcp-connectors/quickbooks/src/client.ts:14:import { consume } from "./rate-limit.js";
packages/mcp-connectors/quickbooks/src/client.ts:103:        throw new QbRateLimitError(
packages/mcp-connectors/quickbooks/src/client.ts:104:          `QuickBooks rate-limit budget exhausted (realm=${this.opts.config.realm_id}); ` +
packages/mcp-connectors/quickbooks/src/client.ts:148:      // 429: rate-limited; honour Retry-After then retry (GET only)
packages/mcp-connectors/quickbooks/src/client.ts:157:        throw new QbRateLimitError(
packages/mcp-connectors/quickbooks/src/errors.ts:25:export class QbRateLimitError extends QbError {
packages/mcp-connectors/quickbooks/src/errors.ts:31:    this.name = "QbRateLimitError";
packages/mcp-connectors/quickbooks/README.md:3:QuickBooks Online (QBO) Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 with **per-realm** token rotation + invoice read + payment read/write. Fixture-first; live API gated behind `MCP_LIVE_TESTS=true`.
packages/mcp-connectors/quickbooks/README.md:15:| `QbClient` (class) | HTTP wrapper: OAuth attach + rate-limit budget + 429 / 5xx retry + per-realm URL construction | constructed in cycle.sh Step 1 | n/a (transport) | n/a |
packages/mcp-connectors/quickbooks/README.md:18:| `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per realm; returns + persists new bundle | Step 1 | `quickbooks_oauth` | green |
packages/mcp-connectors/quickbooks/README.md:24:| `writePaymentReceived(client, payment)` | POST /payment — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
packages/mcp-connectors/quickbooks/README.md:26:All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `quickbooks_oauth` is queued for addition at first Cash Conductor cycle.sh wiring (W7); `accounting_reconciliation_write` is already present (shared with @ifos/xero per Day-25 verification).
packages/mcp-connectors/quickbooks/README.md:97:Per the published Intuit limits page (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):
packages/mcp-connectors/quickbooks/README.md:103:This connector tracks the minute bucket per `src/rate-limit.ts`. Soft backoff at 80% (400/minute); hard fail at 100% → `QbRateLimitError`. State is in-process and per-realm — a multi-realm runtime that holds many `QbClient` instances in one process still gets correct isolation.
packages/mcp-connectors/quickbooks/README.md:105:If you see `QbRateLimitError` consistently in Cash Conductor logs, the polling interval is too tight; tune the cycle's invoice-register ingest frequency.
packages/mcp-connectors/quickbooks/README.md:113:| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` or `QbRateLimitError` |
packages/mcp-connectors/quickbooks/README.md:117:| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `QbRateLimitError` |
packages/mcp-connectors/quickbooks/README.md:128:├── QbRateLimitError     // 429 OR local bucket exhausted
packages/mcp-connectors/quickbooks/README.md:144:MCP_LIVE_TESTS=true pnpm test
packages/mcp-connectors/quickbooks/README.md:147:**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`; live tests are gated on `MCP_LIVE_TESTS=true`.
packages/mcp-connectors/quickbooks/README.md:151:- `tests/rate-limit.test.ts`: 5 (initial state, soft 400, hard 500, per-realm isolation, etc.)
packages/mcp-connectors/quickbooks/README.md:197:- ✓ No hardcoded tenant slugs in `src/` (test fixtures only — `fixture-realm`, `test-realm-rate-limit`)
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts:6:import { check, consume, reset } from "../src/rate-limit.js";
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts:8:const REALM = "test-realm-rate-limit";
packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts:10:describe("quickbooks rate-limit", () => {
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:22:  QbRateLimitError,
packages/mcp-connectors/quickbooks/tests/scaffold.test.ts:56:    expect(new QbRateLimitError("x") instanceof QbError).toBe(true);
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:11:import { reset as resetRateLimit } from "../src/rate-limit.js";
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:49:  return new Response(JSON.stringify(body), {
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:66:  resetRateLimit();
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:96:    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
packages/mcp-connectors/quickbooks/tests/capabilities.test.ts:138:      return new Response("Invoice Id does not exist", { status: 400 });
packages/mcp-connectors/quickbooks/tests/auth.test.ts:93:      new Response(REFRESH_OK_BODY, {
packages/mcp-connectors/quickbooks/tests/auth.test.ts:109:      new Response(
packages/mcp-connectors/quickbooks/tests/auth.test.ts:131:      return new Response(REFRESH_OK_BODY, {

codex
The first pass already found a load-bearing mismatch: the README and Cash Conductor tools reference `quickbooks_oauth`, but the shared autosend policy search only found `accounting_reconciliation_write`. I’m checking exact lines and whether there are additional blocking mismatches before returning the verdict.
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/README.md | sed -n '1,35p;95,120p;140,155p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# @ifos/quickbooks
     2	
     3	QuickBooks Online (QBO) Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 with **per-realm** token rotation + invoice read + payment read/write. Fixture-first; live API gated behind `MCP_LIVE_TESTS=true`.
     4	
     5	**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial QB sandbox signup for live-test verification).
     6	
     7	**Reference pattern:** mirrors `@ifos/xero` (W4 Day-25 RATIFIED scaffold). The per-realm OAuth diff vs Xero's per-tenant header is the load-bearing structural difference — documented in §"OAuth bootstrap" below. Every new MCP connector follows the parity model per `review-mcp-connector.md` §1.
     8	
     9	---
    10	
    11	## Capabilities
    12	
    13	| Function | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
    14	|---|---|---|---|---|
    15	| `QbClient` (class) | HTTP wrapper: OAuth attach + rate-limit budget + 429 / 5xx retry + per-realm URL construction | constructed in cycle.sh Step 1 | n/a (transport) | n/a |
    16	| `loadTokens(config)` | Read OAuth tokens from disk | Step 1 (auth refresh) | n/a (read-only) | n/a |
    17	| `saveTokens(config, t)` | Atomic write (.tmp + rename) to token file | refreshTokens internal | n/a | n/a |
    18	| `refreshTokens(config, current, fetchFn?)` | OAuth 2.0 refresh; concurrent-safe dedup per realm; returns + persists new bundle | Step 1 | `quickbooks_oauth` | green |
    19	| `shouldRefresh(tokens, now?, window?)` | Returns true if access_token expires within window (default 5 min) | Step 1 + per-call | n/a (pure) | n/a |
    20	| `refreshTokenNearExpiry(tokens, now?, danger?)` | Returns true if refresh token within 7-day re-consent danger window (QB ~100-day TTL) | operator alerting | n/a (pure) | n/a |
    21	| `listOpenInvoices(client, options?)` | Query API: paginated Invoice rows with Balance > 0 | Step 4 (invoice register ingest) | n/a (read-only) | n/a |
    22	| `getInvoice(client, invoiceId, options?)` | Single-entity read by QB Id | Step 9 (chase-draft validation) | n/a | n/a |
    23	| `listPayments(client, options?)` | Query API: Payment rows since date | Step 5 (reconciliation pass) | n/a | n/a |
    24	| `writePaymentReceived(client, payment)` | POST /payment — creates a payment record against an invoice (Stage-1/2 reconciliation auto-write) | Step 6 (reconciliation write) | `accounting_reconciliation_write` | yellow |
    25	
    26	All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `quickbooks_oauth` is queued for addition at first Cash Conductor cycle.sh wiring (W7); `accounting_reconciliation_write` is already present (shared with @ifos/xero per Day-25 verification).
    27	
    28	---
    29	
    30	## Quick start
    31	
    32	```typescript
    33	import { QbClient, listOpenInvoices, writePaymentReceived } from "@ifos/quickbooks";
    34	
    35	const client = new QbClient({
    95	## Rate limits
    96	
    97	Per the published Intuit limits page (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):
    98	
    99	- **500 calls / 60-second window per app per realmId** (minute bucket)
   100	- **10 calls per second concurrent throttle** (not enforced here — single-process Cash Conductor cycle.sh is serial)
   101	- No published daily cap
   102	
   103	This connector tracks the minute bucket per `src/rate-limit.ts`. Soft backoff at 80% (400/minute); hard fail at 100% → `QbRateLimitError`. State is in-process and per-realm — a multi-realm runtime that holds many `QbClient` instances in one process still gets correct isolation.
   104	
   105	If you see `QbRateLimitError` consistently in Cash Conductor logs, the polling interval is too tight; tune the cycle's invoice-register ingest frequency.
   106	
   107	---
   108	
   109	## Retry policy
   110	
   111	| Capability | Method | Max retries | Backoff | On exhaustion |
   112	|---|---|---|---|---|
   113	| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` or `QbRateLimitError` |
   114	| `writePaymentReceived` | POST | **0** | n/a (writes never auto-retry) | `QbValidationError` (400) / `QbError` (5xx) |
   115	| `refreshTokens` | POST | **0** | n/a | `QbAuthError` (caller may re-attempt with new credentials) |
   116	| 401 from any GET | — | force-refresh access_token, retry once | — | `QbAuthError` |
   117	| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `QbRateLimitError` |
   118	
   119	Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to QB.
   120	
   140	# Unit + fixture tests (fast; no network)
   141	pnpm test
   142	
   143	# Live API tests (requires real QB sandbox credentials; off by default)
   144	MCP_LIVE_TESTS=true pnpm test
   145	```
   146	
   147	**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`; live tests are gated on `MCP_LIVE_TESTS=true`.
   148	
   149	Test counts (W4 Day-26 scaffold):
   150	- `tests/scaffold.test.ts`: 5 (public surface, exports, error hierarchy)
   151	- `tests/rate-limit.test.ts`: 5 (initial state, soft 400, hard 500, per-realm isolation, etc.)
   152	- `tests/auth.test.ts`: 7 (load missing, round-trip, shouldRefresh, refreshTokenNearExpiry, refresh success, 401 + no-token-leak, concurrent dedup)
   153	- `tests/capabilities.test.ts`: 6 (list/get invoice happy + 404, list/write payment happy + 400)
   154	
   155	**Total: 23 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/src/index.ts | sed -n '1,60p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// @ifos/quickbooks — public API
     2	//
     3	// Used by Cash Conductor agent (W4-7 build wave) per
     4	// agents/recruitment/cash-conductor/tools.yaml capabilities:
     5	//   quickbooks_oauth                 → auth.refreshTokens + client.getValidAccessToken
     6	//   accounting_reconciliation_write  → payments.writePaymentReceived
     7	//   (read-only invoice register)     → invoices.listOpenInvoices + getInvoice
     8	//
     9	// Reference implementation: @ifos/xero (Day-25 RATIFIED scaffold). Pattern
    10	// parity intentional — review-mcp-connector §1 requires capability surface
    11	// set-equality with the reference connector for the same Cash Conductor
    12	// consumer interface.
    13	
    14	export {
    15	  loadTokens,
    16	  saveTokens,
    17	  refreshTokens,
    18	  shouldRefresh,
    19	  refreshTokenNearExpiry,
    20	  _resetInflightForTest,
    21	} from "./auth.js";
    22	export {
    23	  QbClient,
    24	  QB_BASE_URL_PRODUCTION,
    25	  QB_BASE_URL_SANDBOX,
    26	  DEFAULT_TIMEOUT_MS,
    27	} from "./client.js";
    28	export { listOpenInvoices, getInvoice } from "./invoices.js";
    29	export { listPayments, writePaymentReceived } from "./payments.js";
    30	export { QbCache } from "./cache.js";
    31	export {
    32	  check as rateCheck,
    33	  consume as rateConsume,
    34	  reset as resetRateLimit,
    35	} from "./rate-limit.js";
    36	export {
    37	  QbError,
    38	  QbAuthError,
    39	  QbRateLimitError,
    40	  QbNotFoundError,
    41	  QbValidationError,
    42	} from "./errors.js";
    43	export type {
    44	  QbTokens,
    45	  QbOAuthConfig,
    46	  QbInvoice,
    47	  QbQueryResponse,
    48	  QbPayment,
    49	  QbPaymentWriteRequest,
    50	  QbClientOptions,
    51	} from "./types.js";
    52	export type { RateState } from "./rate-limit.js";
    53	
    54	export const VERSION = "0.1.0";

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '200,218p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/tools.yaml | sed -n '50,92p;180,192p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   180	# Already REGISTERED in agents/_shared/autosend-policy.yaml (verified 2026-05-25
   181	# during cash-conductor Codex Round 1 closure):
   182	#   xero_reminder_draft_internal       line 188   yellow
   183	#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
   184	#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
   185	#   operator_notify_telegram           green
   186	#
   187	# QUEUED for registration at W7-8 build start:
   188	#   xero_oauth                         green
   189	#   quickbooks_oauth                   green
   190	#   open_banking_truelayer             green
   191	#   open_banking_plaid_uk              green   (v1.1+; queued but never fires v1.0)
   192	#   cash_conductor_cleanup             green

 succeeded in 0ms:
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
   216	  concierge_email_draft:
   217	    tier: yellow
   218	    agent: concierge

codex
There are multiple independent blockers now, so I’m not going to run a full test suite; the artefact already fails policy-level ratification. I’m doing one citation check because this review mode explicitly calls out fabricated section references as a recurring failure mode.
exec
/bin/zsh -lc "rg --files | rg 'master|brief|ULTRAPLAN|ultraplan|operational-hygiene|ratification|review-mcp-connector'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
logs/codex-ratification.jsonl
logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T125002Z-52329/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T125002Z-52329/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T125002Z-52329/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
docs/specs/ULTRAPLAN.md
logs/codex-ratification/20260524T144919Z-68982/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144919Z-68982/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144919Z-68982/agents_recruitment_cash-conductor_agent-md.verdict.txt
docs/_supplementary/planning-phase-brief.md
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
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
docs/decisions/2026-05-18-codex-ratification-manifest.md
logs/codex-ratification/20260525T063904Z-2437/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260525T063904Z-2437/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260525T063904Z-2437/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T063647Z-99548/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.prompt.md
logs/codex-ratification/20260525T063647Z-99548/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.output.md
logs/codex-ratification/20260525T063647Z-99548/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.verdict.txt
docs/runbooks/operational-hygiene-protocol.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.prompt.md
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.output.md
logs/codex-ratification/20260525T065823Z-10646/docs_decisions_ADR-007-concierge-gate-a-30min-sla-hybrid-md.verdict.txt
docs/build-brief/00-MASTER-BRIEF.md
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T115519Z-5641/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T113038Z-83732/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T170811Z-78348/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T102511Z-28420/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T143747Z-56811/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T124738Z-50139/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T174156Z-10120/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T101934Z-19923/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T125652Z-59039/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144244Z-61554/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T102050Z-21293/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T115042Z-904/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/manual-cluster-e/REPORT.md
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260525T065831Z-11826/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260525T065825Z-10956/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144455Z-63555/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T145439Z-74254/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T123001Z-37001/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T174401Z-12038/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T125346Z-55888/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260525T065833Z-12399/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T103757Z-37420/agents_recruitment_janitor_agent-md.output.md
scripts/run-codex-ratification.sh
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T130117Z-63874/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T112917Z-82352/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T112917Z-82352/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T112917Z-82352/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T102202Z-22338/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T112807Z-81339/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260525T063655Z-170/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T115726Z-8181/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260525T063909Z-3039/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260525T065834Z-12691/agents_recruitment_concierge_agent-md.prompt.md
docs/operations/codex-ratification-guide.md
docs/operations/codex-ratification-execution-plan.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T104642Z-44464/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T124427Z-47109/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T145157Z-71687/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-approval-bridge-spec-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_codex-disagreement-2026-05-20-decision-doc-shape-on-audits-md.output.md
logs/codex-ratification/round-2-autonomous/docs_architecture_tenancy-invariants-md.output.md
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
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260524T115207Z-2587/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T113247Z-86019/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_xero.verdict.txt
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_xero.prompt.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.prompt.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_quickbooks.output.md
logs/codex-ratification/20260601T144038Z-55009/packages_mcp-connectors_xero.output.md
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260525T065826Z-11246/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T143957Z-58446/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.verdict.txt
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.prompt.md
logs/codex-ratification/20260525T065827Z-11521/agents_recruitment_janitor_agent-md.output.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T100618Z-10709/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T100618Z-10709/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.output.md
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.prompt.md
logs/codex-ratification/20260524T170949Z-81713/agents_recruitment_scribe_agent-md.verdict.txt
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.verdict.txt
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T100618Z-10738/docs_decisions_ADR-005-week-3-diagnostic-acceleration-md.prompt.md
logs/codex-ratification/20260524T100618Z-10738/docs_decisions_ADR-005-week-3-diagnostic-acceleration-md.output.md
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260524T171051Z-83049/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T144700Z-67035/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.prompt.md
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.output.md
logs/codex-ratification/20260525T063911Z-3341/agents_recruitment_concierge_agent-md.verdict.txt
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260525T063905Z-2728/agents_recruitment_cash-conductor_agent-md.verdict.txt
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
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.output.md
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.prompt.md
logs/codex-ratification/20260524T102316Z-23548/agents_recruitment_cash-conductor_agent-md.verdict.txt
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151525Z-95136/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T151757Z-97714/agents_recruitment_sourcing-scout_agent-md.output.md
logs/codex-ratification/20260524T100648Z-11041/agents_recruitment_diagnostic_agent-md.prompt.md
logs/codex-ratification/20260524T100648Z-11041/agents_recruitment_diagnostic_agent-md.output.md
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.verdict.txt
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.output.md
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md

exec
/bin/zsh -lc "rg -n \"ULTRAPLAN|master brief|§8\\.2|8\\.2|A4|Cash Conductor|W4-W7|W4\" docs .codex agents packages -g '*.md' -g '*.yaml'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
.codex/ratification/review-agent-bundle.md:18:| §1 | Output contract | One-paragraph screenshot per master brief §1 Rule 1. Names WHAT the agent produces in a single paragraph, readable cold | Missing; >3 paragraphs; doesn't name vault write path; doesn't name Gate A + Gate B thresholds |
.codex/ratification/review-agent-bundle.md:19:| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
.codex/ratification/review-agent-bundle.md:20:| §3 | Output shape | Specific to agent. Diagnostic: 12 sections. Janitor: day-30 report + Bullhorn writes. Cash Conductor: reconciliation rows + chase drafts + weekly report | Missing; doesn't name the artefact paths; doesn't name the decision_log audit-row signature for each output |
.codex/ratification/review-agent-bundle.md:22:| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
.codex/ratification/review-agent-bundle.md:24:| §7 | Voice + tone constraints | `_shared/voice-loader.sh` integration; per-tenant scope; voice classifier threshold per agent.md §5 | Missing for agents that produce text output; threshold drift from master brief §8.1 Change 1 |
.codex/ratification/review-agent-bundle.md:26:| §9 | Status + open questions | Numbered list of founder-review questions; each has a resolution path (founder review at next Sunday OR pilot tenant onboarding OR commercial conversation) | Missing; questions are vague (no resolution path); doesn't acknowledge gotchas from corresponding ULTRAPLAN §8.1 A-N spec |
.codex/ratification/review-agent-bundle.md:37:1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
.codex/ratification/review-agent-bundle.md:38:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
.codex/ratification/review-agent-bundle.md:48:- master brief week N cited but row mismatches (e.g. "W5" but the row says W6)
.codex/ratification/review-agent-bundle.md:49:- ULTRAPLAN line-anchor drift (off by ±5 lines after edits)
.codex/ratification/review-agent-bundle.md:53:**Drift between master brief and ULTRAPLAN is the norm, not an error.** Master brief is authoritative per project hierarchy. agent.md should cite BOTH with a "drift flag" note if the build-wave timing differs (e.g. Sourcing Scout: master brief W9 vs ULTRAPLAN A5 W8-9 — note the drift; use master brief).
.codex/ratification/review-agent-bundle.md:61:**Pre-build scaffold (Status: Proposed)** — written BEFORE the sibling bundle files exist. The 5 W3-scaffold agents (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) are all pre-build scaffolds. Allowed gaps:
.codex/ratification/review-agent-bundle.md:92:Every agent.md is checked against the four boundaries (master brief §3):
.codex/ratification/review-agent-bundle.md:111:- All citations verified against source files (master brief / ULTRAPLAN / escalation-codes / vertical-schema)
.codex/ratification/review-agent-bundle.md:129:- "§8 prereq list missing the voice classifier microservice as W4-5 dependency"
.codex/ratification/SKILL.md:16:## §1 — The five rules (master brief §1)
.codex/ratification/SKILL.md:32:## §2 — The four boundaries (master brief §3)
.codex/ratification/SKILL.md:50:- **Citation accuracy** — section references like "§X.Y" MUST be verifiable. Open the cited file at the cited line/section; does the citation hold? Past violations: a Day-6 audit found 15 fabricated "master brief §10.4 cost target" references; §10.4 is actually the Codex exclusion list.
.codex/ratification/SKILL.md:56:- **Dates** — operational-hygiene-protocol §5 + master brief §1 Rule 5. Absolute dates (not relative — "by Friday" is wrong; "by 2026-06-03" is right). Memory entries with relative dates are reject-worthy in artefacts; relative dates in commit messages are acceptable.
packages/diagnostic-generator/README.md:21:- **§3 Sector mix** — stub with Companies House SIC codes; LinkedIn jobs at W4.
packages/diagnostic-generator/README.md:22:- **§4 Geography** — Companies House registered office; LinkedIn job-post locations at W4.
packages/diagnostic-generator/README.md:23:- **§5 Deal-size band** — firm-age proxy from Companies House; LinkedIn salary bands at W4.
packages/diagnostic-generator/README.md:25:- **§7 Tech stack** — stub; LinkedIn skills + JD parsing at W4.
packages/diagnostic-generator/README.md:27:- **§9 Competitor positioning** — stub; LinkedIn profile employment-history at W4.
packages/diagnostic-generator/README.md:28:- **§10 Recent activity** — Companies House filings last 90 days; LinkedIn posts + Google news at W4.
packages/diagnostic-generator/README.md:29:- **§11 Decision-maker map** — Companies House directors as proxy; LinkedIn employee search at W4.
packages/diagnostic-generator/README.md:30:- **§12 Conversation opener** — deterministic anchor-based composition (LLM at W4).
packages/diagnostic-generator/README.md:37:2. **No LLM-driven §12.** Conversation opener is deterministic anchor-based. W4 wires an LLM + voice classifier.
.codex/ratification/review-postgres-migration.md:100:`decision_log` is append-only per Day-4 §6.3 + master brief §3.3 audit discipline. `recent_edit` extends this pattern per v0.2 supplement.
.codex/ratification/review-mcp-connector.md:19:Pre-build connector exception: if the connector is W4-W7 scaffold (no agent yet), check #3 may be empty; checks #1 + #2 must still match.
.codex/ratification/review-mcp-connector.md:99:- The strings `composio` or `agentmail` (case-insensitive) — adapter boundary per master brief §3.
packages/agent-renderer/templates/claude-md-preamble.md:18:A non-zero exit from `validate.sh` blocks the action (Gate A; master brief §1 Rule 4).
packages/agent-renderer/templates/claude-md-preamble.md:20:Decision-log calls are mandatory per master brief §8.1 Change 2:
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
packages/agent-renderer/README.md:34:| `--bundle-root` | `<repo>/agents/recruitment/` | master brief §4.1 |
packages/agent-renderer/README.md:68:ADR-003 §3.3.1 specifies `cortextos-ifos render-agent`. The upstream `cortextos-ifos` binary lives in the read-only submodule per master brief §3.1 boundary, so we can't add a subcommand there. Phase 2 ships the renderer as standalone `ifos-render-agent` (Node binary; `bin` field in package.json). The `.envrc` `alias ifosctl="cortextos-ifos"` is unchanged; a separate wrapper for `ifosctl render-agent <args>` is **not** in Phase 2 scope.
packages/agent-renderer/README.md:83:| `tests/fixtures/` | — | Stays in source (CI fixture runner per master brief §8.3) |
.codex/ratification/review-schema-change.md:34:- `v1_0_agent_access` — list of agents from master brief §8.2 with R / W / R+W disposition, OR explicit "none (v1.1+ exercise)"
.codex/ratification/review-schema-change.md:80:`agent_access_matrix:` must list every v1.0 agent (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) + state R / W / R+W / none for every entity_type.
.codex/ratification/review-architecture-decision.md:29:5. **Consequences section** — what changes downstream. Includes risk register implications, master brief edits authorised (if any), downstream-artefact updates required. **Required for `Proposed | Accepted`. EXEMPT for `Reference` + `In Force` — downstream impact may be inline (e.g., "Day-7 single-sentence test Q2 references this audit") rather than under a dedicated heading; verify via cross-references in body text.**
.codex/ratification/review-architecture-decision.md:60:For every cited section reference (e.g., "master brief §6 Day 7 line 502"):
.codex/ratification/review-architecture-decision.md:66:If even one citation is wrong, REJECT with the specific citation listed. Past pattern: `master brief §10.4 cost target` cited 15 times; §10.4 is actually the Codex exclusion list with no cost-target content.
.codex/ratification/review-architecture-decision.md:76:If the ADR authorises master brief edits (an "## Master brief edits authorised by this ADR" section):
.codex/ratification/review-architecture-decision.md:79:2. The edit's line numbers MUST match the live master brief (sample-check at least one).
.codex/ratification/review-architecture-decision.md:112:## §7 — Decision_log audit fields (master brief §8.1 Change 2)
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
packages/agent-renderer/tests/fixtures/test-agent/README.md:7:Six bundle files + three fixture sub-directories per master brief §8 layout.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:20:# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:80:          W4 polish may add controlled-vocabulary clustering. Max 20 items
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:295:#   - Cash Conductor timesheet: none → R (reads to verify billable hours
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:410:    # NOTE: Cash Conductor has NO direct Bullhorn endpoint access per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:411:    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:414:    # sync paths). Cash Conductor never calls Bullhorn endpoints directly.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:477:      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:481:      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:490:      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:496:      Diagnostic + Cash Conductor gain R for context.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:516:      - Cash Conductor (R) # v0.3 NEW — reads for invoice context
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:523:      timing), Diagnostic + Cash Conductor (reads for context).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:526:    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:530:      - Cash Conductor (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:537:    v0_1_v1_0_agent_access: [Cash Conductor (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:541:      - Cash Conductor (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:544:      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:579:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:588:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:605:      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:609:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:615:# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:624:      RLS isolation and indexes for date + match-status. Per Cash Conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:637:      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:639:      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:647:      INTENT (W4-polish enforcement required): 7-year retention with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:651:      pseudonymization + purge implementation is a W4-polish slice (pg_cron
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:655:      implementation lands as W4 polish. Per-tenant DPA addendum signed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:661:      table pattern as transactions. Per Cash Conductor §4 Step 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:672:      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:675:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor resolves the billing contact from cached Bullhorn client_contact rows via the placement→client→contact entity_links relationship; NOT from a denormalized placement.client_contact_id field, which the base schema does not declare)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:677:      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:686:      INTENT (W4-polish enforcement required): 7-year retention with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:689:      pseudonymization + purge implementation is a W4-polish slice
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:693:      W4 polish, production use of cash_conductor_invoices is GATED by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:731:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:770:      Cash Conductor cron sweep updates at session-close. Next run queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:817:      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:821:      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:838:      schema declaration in v0.3 supplement is added Day-20 W4 bilateral pass
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:851:      declaration is the canonical schema authority added in W4 bilateral pass
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:854:  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:856:  # declare this config key; the W4 ADR will introduce both the field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:867:  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:874:    schema_owner: future W4-polish supplement (not v0.3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:881:      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:927:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:995:      override. Pseudonymization implementation lands in W4-polish slice.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1018:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1023:  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1037:      residual gaps are tracked in W4-polish-schema-extension backlog;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1041:    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1043:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
agents/_shared/autosend-policy.yaml:213:    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
packages/harness/PINNED-SHA.md:26:   (master brief §3.4 and §5).
packages/harness/PINNED-SHA.md:53:- Codex ratification per master brief §10
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:129:      - Cash Conductor (R — payment reminder tone)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:168:          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
agents/_shared/escalation-codes.md:4:**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:118:Source: master brief §8.1 Change 3 lines 585-592
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:281:- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
agents/_shared/escalation-codes.md:289:- **Severity:** **blocking** — Cash Conductor cannot fetch latest bank-feed; falls back to last-known balance
agents/_shared/escalation-codes.md:297:- **Severity:** staged — info → warn → blocking as expiry approaches (per Cash Conductor agent.md §6)
agents/_shared/escalation-codes.md:301:  - **≤7 days remaining:** blocking — Cash Conductor enters degraded mode (cached balance only; no fresh bank-feed reads); operator must complete SCA reauth before token expires
agents/_shared/escalation-codes.md:360:  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:410:  - **Cash Conductor:** chase/reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure between accounting + ATS)
agents/_shared/escalation-codes.md:411:  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
agents/_shared/escalation-codes.md:414:- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
agents/_shared/escalation-codes.md:418:- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
agents/_shared/escalation-codes.md:436:  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
agents/_shared/escalation-codes.md:465:| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
docs/architecture/architecture-cohesion-review.md:5:**Method:** Read all 4 ADRs + 4 reference designs end-to-end as a coherent set. Walk each of the 4 boundaries from master brief §3 with adversarial questions. Identify gaps, contradictions, implicit assumptions.
docs/architecture/architecture-cohesion-review.md:58:| ADR-001 | bus mechanism (chokidar→FastChecker) | master brief §2.4 row 3 (Edit) | ✓ landed atomic `0e5b2b4` |
docs/architecture/architecture-cohesion-review.md:91:| A4 | **`ifos_app` Postgres role is the only role used by app code.** No path uses postgres superuser or admin role. | Day-4 §6.3 grants + RLS posture | If any path uses superuser, RLS is bypassed (RLS doesn't apply to superusers by default). |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:114:- **master brief §3.1 boundary 1** read-only submodule
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:162:## §7 — Per-boundary adversarial walk (master brief §3 boundaries)
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
packages/agent-renderer/pnpm-lock.yaml:13:        version: 8.20.0
packages/agent-renderer/pnpm-lock.yaml:16:        version: 3.0.1(ajv@8.20.0)
packages/agent-renderer/pnpm-lock.yaml:178:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/agent-renderer/pnpm-lock.yaml:232:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/agent-renderer/pnpm-lock.yaml:448:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/agent-renderer/pnpm-lock.yaml:529:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/agent-renderer/pnpm-lock.yaml:693:    resolution: {integrity: sha512-8iUql50EUR+uUcdRQ3HDqa6EVyo3docL8g5WJ3FNcWmu62IbkGUue/pEyLBW8VGKKucTPgqeks4fIU1DA4yowQ==}
packages/agent-renderer/pnpm-lock.yaml:700:  ajv@8.20.0:
packages/agent-renderer/pnpm-lock.yaml:732:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/agent-renderer/pnpm-lock.yaml:736:    resolution: {integrity: sha512-Vw8qHK3bZM9y/P10u3Vib8o/DdkvA2OtPtZvD871QKjy74Wj1WSKFILMPRPSdUSx5RFK1arlJzEtA4PkFgnbuA==}
packages/agent-renderer/pnpm-lock.yaml:839:  mlly@1.8.2:
packages/agent-renderer/pnpm-lock.yaml:1050:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/agent-renderer/pnpm-lock.yaml:1447:  ajv-formats@3.0.1(ajv@8.20.0):
packages/agent-renderer/pnpm-lock.yaml:1449:      ajv: 8.20.0
packages/agent-renderer/pnpm-lock.yaml:1451:  ajv@8.20.0:
packages/agent-renderer/pnpm-lock.yaml:1602:      mlly: 1.8.2
packages/agent-renderer/pnpm-lock.yaml:1628:  mlly@1.8.2:
packages/agent-renderer/pnpm-lock.yaml:1662:      mlly: 1.8.2
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:1:# Cash Conductor fixture — 02-edge-case-fuzzy-match
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:6:# Cash Conductor MUST NOT auto-write; instead it fires ESC_RECONCILIATION_AMBIGUOUS
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:11:# routing. NOT blocking — Cash Conductor continues processing other matches.
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:18:# Status: Proposed (W4 Day-26 SKELETON).
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:1:# Cash Conductor fixture — 99-token-aging-canary
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:6:# (throws OpenBankingConsentExpiredError) — Cash Conductor cycle.sh Step 1
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:12:# dance before Cash Conductor can resume. The fixture verifies the system
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:20:# Status: Proposed (W4 Day-26 SKELETON).
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:82:    consent_expires_at_ms, Cash Conductor resumes automatically on next run.
packages/utilities/web-scraper/README.md:9:- `googleSearch(query)` — stub for v0; W4 polish wires SerpAPI or alternative
docs/verticals/recruitment/vertical-schema.yaml:10:# Source: master brief §6 Day 6 line 490 (8 core entities)
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:216:      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:289:      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:822:    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:829:    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
docs/verticals/recruitment/vertical-schema.yaml:896:    expected_date: post first-pilot operations (Q4 2026 if pilot lands per master brief §6 Day 7 question 1)
docs/verticals/recruitment/vertical-schema.yaml:901:    expected_date: 2027+ per master brief §9 build sequence
docs/architecture/agent-bundle-renderer-design.md:6:**Prior work referenced:** master brief §8 (bundle spec); `docs/architecture/second-brain-design.md` §1.7 (R2 inheritance recommendation); `docs/architecture/cortexos-primitive-status.md` Primitive 1 (PTY/PM2 spawn mechanism).
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:45:| `tools.yaml` (line 554) | MCP servers + scopes + degraded modes for external execution backends (Bullhorn, Companies House, Microsoft Graph etc. per master brief §3.2 first-party MCP list) | the renderer (passes through to rendered agent dir); agent uses it via Claude Code's MCP loading at PTY spawn time | **Static** — founder writes once per agent |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:48:| `tests/fixtures/01-primary/` (line 559) | Happy-path input.json + expected.md. The demo example. | CI fixture runner (master brief §8.3 line 628 "Test against fixtures"); not read at runtime | **Static** — author once, regenerate `expected.md` after intentional behaviour changes |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:54:- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:115:| `agents/recruitment/<name>/tests/fixtures/{01-primary,02-edge-case-*,99-voice-drift-canary}/` | **Not rendered** | **Stays in source** | n/a | n/a — fixtures live in the IFOS repo at `agents/recruitment/<name>/tests/fixtures/`; CI fixture runner (master brief §8.3 line 628) reads them there; runtime does not need them |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:143:| `approvals` | cortextOS's per-action approval-gate skill — agent creates an approval entry, blocks until human resolves via Telegram inline buttons | IFOS uses the same primitive 4 approval gates (cortextOS primitive — `src/bus/approval.ts`), but the approval *categories* and *escalation routing* are declared in `tools.yaml` + `agent.md` per master brief §3.2, not via inherited skill documentation |
docs/architecture/agent-bundle-renderer-design.md:153:**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:326:# Hydrate via context-assembly API per master brief §9
docs/architecture/agent-bundle-renderer-design.md:367:A non-zero exit from validate.sh blocks the action (Gate A; master brief §1 Rule 4).
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:465:Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.
docs/architecture/agent-bundle-renderer-design.md:477:- Brand new top-level dir — rejected for cohesion with master brief §4.1's existing `packages/` convention.
docs/architecture/agent-bundle-renderer-design.md:493:- **Daemon auto-renders on bundle change (filesystem watcher inside cortextOS daemon):** rejected because cortextOS daemon is read-only on the submodule (master brief §3.1), and adding render logic to the daemon would couple bundle synthesis to runtime supervision. Two concerns, one process — wrong.
docs/architecture/agent-bundle-renderer-design.md:503:(CLI name per ADR-004 Decision 1; earlier drafts of this design named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1. The corrected standalone `ifos-render-agent` Node binary ships from `packages/agent-renderer/package.json` `bin`.)
docs/architecture/agent-bundle-renderer-design.md:597:- **Merge with conflict markers:** rejected for v1.0. Renderer doesn't have a three-way-merge semantic (source bundle, last-render, current rendered output). Building it adds substantial complexity for a workflow nobody asked for; the master brief §1 Rule 1 ("output before architecture") favours the simple overwrite model.
docs/architecture/agent-bundle-renderer-design.md:622:The v1.0 minimum keeps the renderer's CLI surface small (one mode, two required args) and defers cross-tenant orchestration to bash. The Postgres `tenants` table dependency (v1.0 Day 4 per master brief §6) is what unblocks `--all-tenants`; until then there's no programmatic source of truth for "the list of active tenants."
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
docs/architecture/agent-bundle-renderer-design.md:702:New escalation code added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3:
docs/architecture/agent-bundle-renderer-design.md:764:| Postgres `decision_log` table live (per master brief §6 Day 4) | founder | Day 4 of Week 0 (already scheduled) |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:775:**Current** (master brief §4.1 line 195-204): "Create the operative directory structure" followed by an `mkdir -p` command listing `packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}`.
docs/architecture/agent-bundle-renderer-design.md:787:**Current** (master brief §8.3 lines 614-630): the `bash` block showing the bundle authoring workflow ends with: "Test against fixtures; iterate; commit; PR; merge."
docs/architecture/agent-bundle-renderer-design.md:802:**Current** (master brief §8 lines 545-568): bundle file list with no reference to renderer.
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:1:# Cash Conductor fixture — 01-primary (happy path)
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:13:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice wires the real
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
packages/mcp-connectors/companies-house/pnpm-lock.yaml:162:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:216:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:432:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:513:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:699:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:789:  mlly@1.8.2:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:996:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1527:      mlly: 1.8.2
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1547:  mlly@1.8.2:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1581:      mlly: 1.8.2
packages/utilities/autosend-bridge-telegram/README.md:3:Telegram approval-bridge for orange-tier autosend gating. Backs the **D1-B founder decision** (`docs/decisions/2026-05-31-d1-founder-decision.md`) — consumed by **Concierge `cycle.sh` Step 11** + **Cash Conductor `cycle.sh` Step 10**.
packages/utilities/autosend-bridge-telegram/README.md:5:**Status:** Proposed (W4 Day-26 scaffold, fully unit-tested; production wiring lands in the Concierge W10–13 build slice).
packages/utilities/autosend-bridge-telegram/README.md:54:Convenience wrapper for try/catch-style call sites: throws `BridgeTimeoutError` on expiry rather than returning `outcome: "timeout"`. The Concierge / Cash Conductor `cycle.sh` wrappers use this form so the script's `set -e` propagates the timeout naturally.
packages/utilities/autosend-bridge-telegram/README.md:95:If the underlying state changes between proposal and approval — e.g. a Cash Conductor chase is proposed at 15:00, the customer pays at 15:30, the operator approves at 15:45 — the **agent layer** (not this package) must detect that the action no longer applies and emit `ESC_AUTOSEND_RACE` with `race_class: state_change_cancellation` instead of executing the transport. This package is intentionally state-agnostic.
packages/utilities/autosend-bridge-telegram/README.md:104:4. Wire the call from the agent's `cycle.sh` (mirroring Concierge Step 11 or Cash Conductor Step 10).
packages/utilities/autosend-bridge-telegram/README.md:141:- Cash Conductor agent.md: §4 Step 10 (consumer)
packages/mcp-connectors/open-banking/README.md:3:UK Open Banking connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). Provider abstraction over **TrueLayer (v1.0)** + **Plaid UK (v1.1+ deferred)** with PSD2 90-day consent tracking + token-aging stages. Used by Cash Conductor for bank-transaction ingest + cash-flow forecast balance reads.
packages/mcp-connectors/open-banking/README.md:5:**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first TrueLayer dev signup for live-test verification).
packages/mcp-connectors/open-banking/README.md:13:| Function | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
packages/mcp-connectors/open-banking/README.md:24:All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `open_banking_truelayer` is queued for addition at first Cash Conductor cycle.sh wiring (W7).
packages/mcp-connectors/open-banking/README.md:46:| 0-7 | `blocking` | **HARD STOP** — `refreshTokens()` refuses to issue a new access token; operator MUST re-do PSD2 consent dance with the user before Cash Conductor can resume |
packages/mcp-connectors/open-banking/README.md:115:| TrueLayer | 30 calls/min per (provider, connection_id) | 24/min | Published prod limits are not publicly numbered; sandbox is constrained. We use a conservative 30/min ceiling. Tunable when Cash Conductor cycle.sh telemetry shows actual usage patterns. |
packages/mcp-connectors/open-banking/README.md:131:This connector has NO write operations — banks don't generally expose write APIs in the scope Cash Conductor needs. So all calls are read-only; the only state-changing op is OAuth refresh (which has its own consent-aware refusal logic).
packages/mcp-connectors/open-banking/README.md:162:Test counts (W4 Day-26 scaffold):
packages/mcp-connectors/open-banking/README.md:169:**Total: 28 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
packages/mcp-connectors/open-banking/README.md:199:Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is one of the substrate dependencies (alongside the accounting connector chosen per tenant).
packages/mcp-connectors/open-banking/README.md:213:*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*
docs/architecture/cortexos-kb-surface-investigation.md:12:Day-1 audit of cortextOS Primitive 3 (`docs/architecture/cortexos-primitive-status.md`) surfaced that master brief §3.4 names four shadow files (`kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`) that **do not exist** at the verified SHA. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`.
docs/architecture/cortexos-kb-surface-investigation.md:14:Drafting ADR-002 began with the plan to read all four real files and pick one of three outcomes (full shadow / mixed shadow + new wrappers / abandon shadow). After reading **only `kb-setup.sh`**, the substrate of cortextOS's KB became clear, and that substrate is incompatible with the IFOS wiki data model in master brief §5. The ADR's scope is too narrow to absorb that finding — it would be designing the second brain inside an architectural decision record, on the side of an audit.
docs/architecture/cortexos-kb-surface-investigation.md:35:- **Per-instance isolation:** the KB root path includes `$CTX_INSTANCE_ID`, so IFOS's `ifos-v2` install and the personal install at `default` have **separate** KB indexes by construction. This is already correct against the master brief §3.1 submodule boundary.
docs/architecture/cortexos-kb-surface-investigation.md:83:**cortextOS's KB is a chunked-vector RAG store; the IFOS wiki in master brief §5 is an entity-document store. These data models do not compose without an adapter layer, and the adapter layer is large enough to be a design decision rather than a shadow-wrapper detail.**
docs/architecture/cortexos-kb-surface-investigation.md:88:- **IFOS wiki unit of storage:** one markdown file per entity (Candidate, Client, Brief, Placement…) with structured YAML frontmatter (`id / entity_type / tenant_id / created_at / updated_at / provenance / importance_score / linked_entities`) and `[[wiki-link]]` references in body — per master brief §5.2 example at lines 357-369. The natural read pattern is "give me the canonical page for this entity, plus its backlinks".
docs/architecture/cortexos-kb-surface-investigation.md:97:  - **Indexing of ingested raw email/transcript chunks** (master brief §5.1 `raw/` directory tree). The chunked-vector model fits the "raw inbox-emails / calls / briefs" surface well; it only stops fitting at the `compiled/` entity-document boundary.
docs/architecture/cortexos-kb-surface-investigation.md:98:- **What this means for §3.4:** the master brief calls the seam between cortextOS and IFOS "the four `bus/kb-*.sh` shadow points." That framing assumed the same data model on both sides of the seam. With the substrate now known, the seam is not a four-file shadow but a much smaller boundary — to be defined in the second-brain design.
agents/recruitment/cash-conductor/README.md:1:# Cash Conductor — directory README
agents/recruitment/cash-conductor/README.md:18:Full bundle at W7-8 build (~2 weeks per ULTRAPLAN A4 line 541):
agents/recruitment/cash-conductor/README.md:22:- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
agents/recruitment/cash-conductor/README.md:27:- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
agents/recruitment/cash-conductor/README.md:39:*End of Cash Conductor README.*
agents/recruitment/cash-conductor/tools.yaml:1:# Cash Conductor agent — tools.yaml (capability declarations)
agents/recruitment/cash-conductor/tools.yaml:3:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice may add per-tenant
agents/recruitment/cash-conductor/tools.yaml:14:# (current registrations verified W4 Day-25 for accounting_reconciliation_write
agents/recruitment/cash-conductor/tools.yaml:93:  # Sage MCP connector deferred per Cash Conductor §9 Q8 (first-pilot-on-Sage trigger).
agents/recruitment/cash-conductor/tools.yaml:126:  # both Concierge AND Cash Conductor (Cash Conductor is the Step-10 consumer).
agents/recruitment/cash-conductor/tools.yaml:133:    action_type: xero_reminder_send_customer  # ORANGE tier; REGISTERED at autosend-policy.yaml line 263; Cash Conductor OWNS this action_type per the same line
agents/recruitment/cash-conductor/tools.yaml:183:#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
agents/recruitment/cash-conductor/tools.yaml:195:# Boundary check (per master brief §3 + review-mcp-connector.md §8)
packages/mcp-connectors/quickbooks/README.md:3:QuickBooks Online (QBO) Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 with **per-realm** token rotation + invoice read + payment read/write. Fixture-first; live API gated behind `MCP_LIVE_TESTS=true`.
packages/mcp-connectors/quickbooks/README.md:5:**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial QB sandbox signup for live-test verification).
packages/mcp-connectors/quickbooks/README.md:7:**Reference pattern:** mirrors `@ifos/xero` (W4 Day-25 RATIFIED scaffold). The per-realm OAuth diff vs Xero's per-tenant header is the load-bearing structural difference — documented in §"OAuth bootstrap" below. Every new MCP connector follows the parity model per `review-mcp-connector.md` §1.
packages/mcp-connectors/quickbooks/README.md:13:| Function | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
packages/mcp-connectors/quickbooks/README.md:26:All `action_type` values listed above MUST exist in `agents/_shared/autosend-policy.yaml` with the documented tier. `quickbooks_oauth` is queued for addition at first Cash Conductor cycle.sh wiring (W7); `accounting_reconciliation_write` is already present (shared with @ifos/xero per Day-25 verification).
packages/mcp-connectors/quickbooks/README.md:100:- **10 calls per second concurrent throttle** (not enforced here — single-process Cash Conductor cycle.sh is serial)
packages/mcp-connectors/quickbooks/README.md:105:If you see `QbRateLimitError` consistently in Cash Conductor logs, the polling interval is too tight; tune the cycle's invoice-register ingest frequency.
packages/mcp-connectors/quickbooks/README.md:119:Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to QB.
packages/mcp-connectors/quickbooks/README.md:149:Test counts (W4 Day-26 scaffold):
packages/mcp-connectors/quickbooks/README.md:155:**Total: 23 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
packages/mcp-connectors/quickbooks/README.md:187:Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is one of three accounting substrate options consumed (Xero / QuickBooks / Sage — Sage deferred per Cash Conductor §9 Q8).
packages/mcp-connectors/quickbooks/README.md:201:*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*
docs/architecture/cortexos-primitive-status.md:7:**Method:** read code under `src/daemon/`, `src/pty/`, `src/bus/`, `src/telegram/`, `src/cli/`; cross-reference with `README.md`, `CHANGELOG.md`, `CRONS_MIGRATION_GUIDE.md`, `templates/{orchestrator,analyst,agent,m2c1-worker,agent-codex}/`; line-cite `tests/unit/**` and `tests/integration/**`; cross-check Day-0 findings in `.agents/learnings/00-cortextos-quirks.md`; classify per the four-status scheme from master brief §6 Day 1.
docs/architecture/cortexos-primitive-status.md:9:Two findings need founder review before the Day 7 single-sentence test (master brief §6 / Ultraplan §12). Both are master-brief drifts against the verified SHA, surfaced in Primitive 3:
docs/architecture/cortexos-primitive-status.md:11:1. **No `chokidar` watcher in the bus** — master brief §2.4 row 3 says "bus/ shell wrappers + chokidar watcher in daemon", but the bus is poll-based (`FastChecker` default 1000ms). `chokidar` is only used by the dashboard's UI file-feed.
docs/architecture/cortexos-primitive-status.md:12:2. **The four `bus/kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 names `kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`. The actual files at SHA `c21fbfe` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`. The brain-replacement seam (§3.4 + §5) needs reconciliation before Codex ratification.
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:36:**Master-brief description:** `node-pty` + `ecosystem.config.js` regen via `cortextos ecosystem`; agents run as PM2-managed PTY processes that auto-restart on crash or after the 71-hour context rotation (master brief §2.4 row 1).
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:97:**Master-brief description:** The daemon auto-restarts a session before the context limit; pre-rotation hook checkpoints state to vault (master brief §2.4 row 2).
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:157:**Master-brief description:** `bus/` shell wrappers + `chokidar` watcher in the daemon; agents drop typed files for inter-agent handoff (master brief §2.4 row 3).
docs/architecture/cortexos-primitive-status.md:184:2. **The four `kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 lists `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`. The actual files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. This is the brain-replacement seam — the master brief's named files do not exist at SHA `c21fbfe`. Either the brief was written against a different cortextOS version, or the four shadow points need to be revised. This is a Day-7 Codex-ratification-blocking discrepancy.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:228:**Master-brief description:** Daemon enforces explicit approval before external action; `manualFireDisabled` flag on crons; standing authorisations per agent (master brief §2.4 row 4).
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:292:**Master-brief description:** Bot per agent, `.env` carries `BOT_TOKEN / CHAT_ID / ALLOWED_USER`; the escalation path for every Tier-1 agent (master brief §2.4 row 5).
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:328:**Risk if flaky:** Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5 ("iOS in v1.2 is the marketing line, not a tech blocker"). Real risk is Telegram outage during a Cash Conductor escalation, which is exactly what the activity-channel + per-agent-bot belt-and-braces pattern (primitive 4 evidence, `approval.ts:222-226`) was built to mitigate after the "50h+ Repo-B-style stall" incident.
docs/architecture/cortexos-primitive-status.md:366:**Master-brief description:** Analyst-template agents schedule overnight experiments, evaluate results, surface findings for review (master brief §2.4 row 6).
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:430:**Master-brief description:** Orchestrator template + file-bus handoff contract; supervisor agent watches the others, escalates jams, balances load (master brief §2.4 row 7).
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/architecture/cortexos-primitive-status.md:504:- **Day-7 spec drifts for Codex ratification:** the chokidar mention in master brief §2.4 row 3 and the four `kb-*.sh` filenames in master brief §3.4 do not match the verified SHA. Both need a one-line correction or a §3.4 re-scoping decision.
docs/architecture/cortexos-primitive-status.md:505:- **Standing authorisations** (master brief §2.4 row 4) are not a cortextOS primitive at this SHA. We build them in our layer — confirm scope in the Day 5 auto-send safety policy artefact.
agents/recruitment/cash-conductor/agent.md:1:# Cash Conductor — the FD's evenings back
agents/recruitment/cash-conductor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (today): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. Awaits Q1 LOI + accounting + Open Banking commercial signups + Founder Decision D1 resolved + autosend bridge built (Concierge W10) + W7 build slice.
agents/recruitment/cash-conductor/agent.md:7:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:8:**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
agents/recruitment/cash-conductor/agent.md:9:**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
agents/recruitment/cash-conductor/agent.md:10:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:16:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:57:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:82:Per webhook event, Cash Conductor reconciles incoming bank deposits against the tenant's open invoice register. Match algorithm:
agents/recruitment/cash-conductor/agent.md:96:### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
agents/recruitment/cash-conductor/agent.md:98:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 263) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:119:2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 188-193), payload links to the draft via the vault path — this row records that Cash Conductor classified the draft as yellow-tier internal.
agents/recruitment/cash-conductor/agent.md:121:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 263; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:132:Position 4 is the kill-switch: Cash Conductor never auto-drafts beyond position 3. Operator decides next step manually.
agents/recruitment/cash-conductor/agent.md:162:     gotcha per ULTRAPLAN A4 line 541); staged ESC_OPEN_BANKING_TOKEN_AGING:
agents/recruitment/cash-conductor/agent.md:195:     candidate, not low-confidence single). W4-polish backlog: register
agents/recruitment/cash-conductor/agent.md:246:       blocking for Cash Conductor invoice/chase addressee resolution)
agents/recruitment/cash-conductor/agent.md:248:     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
agents/recruitment/cash-conductor/agent.md:258:      line 263; Cash Conductor owns this action_type and OPENS the
agents/recruitment/cash-conductor/agent.md:263:    send → Cash Conductor receives webhook + records state mutation)
agents/recruitment/cash-conductor/agent.md:265:      written by Cash Conductor at Step 10 (Cash Conductor owns this
agents/recruitment/cash-conductor/agent.md:270:    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
agents/recruitment/cash-conductor/agent.md:307:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:317:Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
agents/recruitment/cash-conductor/agent.md:319:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/cash-conductor/agent.md:323:Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
agents/recruitment/cash-conductor/agent.md:327:Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
agents/recruitment/cash-conductor/agent.md:329:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:335:Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/cash-conductor/agent.md:344:| (Stage 3 low-confidence single-match review queue) | Stage 3 single low-confidence exact-amount match queued for consultant review — NOT ESC_RECONCILIATION_AMBIGUOUS (catalogue defines ambiguity as multi-candidate, not low-confidence single). v0.3 W4-polish backlog: add ESC_RECONCILIATION_LOW_CONFIDENCE for single-match-low-confidence case OR widen ESC_RECONCILIATION_AMBIGUOUS catalogue trigger. | flagged in weekly report exception list (no ESC fire at v0.3) | (weekly report aggregation) |
agents/recruitment/cash-conductor/agent.md:349:| `ESC_ADDRESSEE_MISMATCH` | Gate A miss on client_contact_email / addressee resolution (per catalogue §2.10 Cash Conductor case) | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:354:Cash Conductor does NOT use:
agents/recruitment/cash-conductor/agent.md:357:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:358:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
agents/recruitment/cash-conductor/agent.md:359:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/cash-conductor/agent.md:372:- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 729; recent_edit block at lines 721-731), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:374:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:380:Cash Conductor build cannot start until ALL of the following are confirmed:
agents/recruitment/cash-conductor/agent.md:396:| Concierge agent.md ratified Accepted (for chase-send routing contract; full Concierge production-build at W10-13, but Cash Conductor only depends on the Concierge agent.md contract being Accepted, not the full bundle being In Force) | Post-Concierge agent.md re-ratification | ⏸ |
agents/recruitment/cash-conductor/agent.md:404:| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
agents/recruitment/cash-conductor/agent.md:406:| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
agents/recruitment/cash-conductor/agent.md:408:**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.
agents/recruitment/cash-conductor/agent.md:425:| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
agents/recruitment/cash-conductor/agent.md:426:| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
agents/recruitment/cash-conductor/agent.md:429:### Gotchas (carried forward from ULTRAPLAN A4 line 541)
agents/recruitment/cash-conductor/agent.md:434:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:451:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
agents/recruitment/cash-conductor/agent.md:456:*End of Cash Conductor agent.md draft.*
packages/mcp-connectors/xero/README.md:3:Xero Accounting API connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). OAuth 2.0 token rotation + invoice read + payment read/write. Fixture-first; live API gated behind `MCP_LIVE_TESTS=true`.
packages/mcp-connectors/xero/README.md:5:**Status:** Proposed (W4 Day-25 overnight scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first commercial Xero signup for live-test verification).
packages/mcp-connectors/xero/README.md:13:| Function | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
packages/mcp-connectors/xero/README.md:80:- **5 concurrent calls per app per tenant** — not enforced here; single-process Cash Conductor cycle.sh is serial
packages/mcp-connectors/xero/README.md:84:If you see `XeroRateLimitError` consistently in Cash Conductor logs, either the daily budget is too low for the tenant's invoice volume OR the polling interval is too tight; in either case it's an operator-tuning event, not a code bug.
packages/mcp-connectors/xero/README.md:98:Writes never auto-retry — the caller (Cash Conductor cycle.sh Step 6) decides whether a 4xx is recoverable. This avoids accidentally posting duplicate payments to Xero.
packages/mcp-connectors/xero/README.md:128:Test counts (W4 Day-25 overnight scaffold):
packages/mcp-connectors/xero/README.md:134:**Total: ≥23 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
packages/mcp-connectors/xero/README.md:167:Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is the substrate it consumes.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
agents/recruitment/scribe/README.md:14:Full bundle at W6 build (~1 week per ULTRAPLAN A3 line 526):
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
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
agents/recruitment/scribe/agent.md:317:| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/scribe/agent.md:328:| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
agents/recruitment/scribe/agent.md:350:### Gotchas (carried forward from ULTRAPLAN A3 line 527)
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
docs/architecture/second-brain-design.md:14:The goal: confirm what cortextOS uses its own KB for, so we know what we are deliberately leaving alone — and verify the master brief §3.1 submodule boundary is not in tension with the plan in Q3.
docs/architecture/second-brain-design.md:52:**IFOS agents do not run cortextOS's heartbeat-memory pattern.** The IFOS Agent Bundle v2 (master brief §8.1) specifies six files per agent:
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:76:- This respects master brief §3.1 ("never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points") without exercising the exception — we don't shadow them at all.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:136:1. **It honours the §3.1 boundary cleanly.** The §3.1 exception in master brief is "the four `bus/kb-*.sh` shadow points." If we don't shadow them (per §1.5), inheriting skills that call them invites confusion — the inherited skills point at cortextOS's KB, and we'd need to remember that IFOS-owned agents must not invoke them. R2 removes the question entirely.
docs/architecture/second-brain-design.md:140:**Until the renderer is built** (Week 0 has no agent code per master brief §6 Day 7; the renderer is a Week 1+ concern), the inherited-skills risk only matters for any debug/probe agents scaffolded via `cortextos-ifos add-agent` during Week 0 verification. Those probe agents will inherit the kb-* calls and write to cortextOS's KB — which is fine, because cortextOS's KB stays in place per §1.5.
docs/architecture/second-brain-design.md:161:/vault/{tenant-slug}/                               ← path per master brief §3.3 line 217, Ultraplan §5.1 line 217
docs/architecture/second-brain-design.md:163:│   ├── style-guide.md                              ← master brief §5.5 footnote, Ultraplan §5.2 wizard Day 3
docs/architecture/second-brain-design.md:169:├── wiki/                                           ← the second brain (master brief §5.1 line 306)
docs/architecture/second-brain-design.md:170:│   ├── raw/                                        ← append-only ingestion (master brief §5.1 lines 316-321)
docs/architecture/second-brain-design.md:171:│   │   ├── inbox-emails/                           ← from email ingestion (master brief §5.1 line 317)
docs/architecture/second-brain-design.md:172:│   │   ├── calls/                                  ← Fathom/Fireflies transcripts (master brief §5.1 line 318)
docs/architecture/second-brain-design.md:173:│   │   ├── briefs/                                 ← inbound brief detection (master brief §5.1 line 319)
docs/architecture/second-brain-design.md:174:│   │   ├── notes/                                  ← freeform consultant notes (master brief §5.1 line 320)
docs/architecture/second-brain-design.md:175:│   │   └── ats-snapshots/                          ← Bullhorn entity snapshots (master brief §5.1 line 321)
docs/architecture/second-brain-design.md:176:│   ├── compiled/                                   ← LLM-owned, agent-managed (master brief §5.1 line 323)
docs/architecture/second-brain-design.md:177:│   │   ├── index.md                                ← master index, one-line per page (master brief §5.1 line 324)
docs/architecture/second-brain-design.md:178:│   │   ├── candidates/                             ← one .md per Candidate (master brief §5.1 line 325)
docs/architecture/second-brain-design.md:179:│   │   ├── clients/                                ← one .md per Client (master brief §5.1 line 326)
docs/architecture/second-brain-design.md:180:│   │   ├── briefs/                                 ← one .md per Brief (master brief §5.1 line 327)
docs/architecture/second-brain-design.md:181:│   │   ├── placements/                             ← one .md per Placement (master brief §5.1 line 328)
docs/architecture/second-brain-design.md:182:│   │   ├── people/                                 ← Contacts at clients (master brief §5.1 line 329)
docs/architecture/second-brain-design.md:183:│   │   ├── concepts/                               ← firm domain concepts (master brief §5.1 line 330) — v1.2+ deferred
docs/architecture/second-brain-design.md:185:│   │   └── archive/                                ← absorbed/deleted pages (master brief §5.1 line 332)
docs/architecture/second-brain-design.md:186:│   └── .wiki/                                      ← compilation state (master brief §5.1 line 334)
docs/architecture/second-brain-design.md:187:│       ├── manifest.json                           ← per-raw-file compilation status (master brief §5.1 line 335)
docs/architecture/second-brain-design.md:188:│       ├── reflect-state.json                      ← reflect cycle state (master brief §5.1 line 336)
docs/architecture/second-brain-design.md:189:│       └── graph.json                              ← cached graph for fast UI loads (master brief §5.1 line 337) — v1.2 graph view
docs/architecture/second-brain-design.md:203:| `wiki/raw/inbox-emails/` | one file per email | markdown with frontmatter | `{epoch}-{from-domain}-{rand5}.md` | inbound email webhook handler (v1.0: Cash Conductor for AR-relevant; v1.1: Triage for everything) | Brief Decoder (v1.1), Cash Conductor (v1.0); future Pulse semantic-search-over-raw |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:227:Eight canonical entities exist per master brief §6 Day 6 / Ultraplan §11 Day 6 line 490:
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:246:**Frontmatter schema** (master brief §5.2 lines 357-369 starting example; extended for v1.0 completeness):
docs/architecture/second-brain-design.md:311:xero_contact_id: 9876                                # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:394:**Decision: adopt `[[Entity-Type: Display Name]]` verbatim** as master brief specifies. Rationale: matches master brief decision, Obsidian-compatible, human-readable in raw markdown. Cost: rename safety is fragile — renaming "Sarah Bowen" to "Sarah Bowen-Smith" breaks all links unless an explicit rewrite step runs.
docs/architecture/second-brain-design.md:398:**Spec gap 2.2-A:** master brief §5 does not specify the rewrite-backlinks mechanism. Recommended resolution: implement as part of `update-entity` in `packages/brain/wiki/lib/update.ts` v1.0.
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:437:- Graph multi-hop traversal — v1.2 graph view (master brief §5.5 line 423)
docs/architecture/second-brain-design.md:438:- Wiki health reflect (orphan detection, contradiction detection) — v1.1 (master brief §5.2 lines 371)
docs/architecture/second-brain-design.md:439:- Per-firm LoRA query — v2.0 (master brief §5.5 line 424)
docs/architecture/second-brain-design.md:456:- **Obsidian compatibility:** frontmatter restricted to YAML 1.2 features Obsidian's `gray-matter` parser accepts — strings, ints, floats, ISO 8601 strings, flow-style and block-style sequences, flow-style and block-style mappings (one level of nesting only). **No anchors, no aliases, no merge keys, no custom tags.** Wiki-links in body use Obsidian's `[[Display Name]]` and `[[Type: Display Name]]` syntax — both render. Frontmatter `linked_entities` is a list of strings that *look like* wiki-links; Obsidian doesn't render frontmatter strings as links by default, but the master brief §5.2 example uses this form and we adopt it.
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:465:**Table: `tenants`** (master brief §3.3 + Ultraplan §5.1)
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:569:**Spec gap 2.4-B:** Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`". This design splits them into `entities` + `entity_links` for clearer indexing semantics. **Recommended resolution:** adopt the split; update master brief §3.3 or Ultraplan §5.1 to reflect the two-table model. Codex-ratifiable on Day 7 by reading this section.
docs/architecture/second-brain-design.md:672:| `search-by-name` | Postgres `entities` trigram on `display_name` (`gin_trgm_ops`) | Filesystem grep over `wiki/compiled/{type}/*.md` frontmatter | Hot path; sub-second target. Fuzzy match returns top-N by similarity score; tie-break by `importance_score DESC` then `updated_at DESC`. Fallback only fires if Postgres unhealthy (per master brief §3.5 RLS / Ultraplan §3.5 degraded-mode contingency). |
docs/architecture/second-brain-design.md:701:- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
docs/architecture/second-brain-design.md:727:**Spec gap 2.6:** none of this is in the master brief. **Recommended resolution:** adopt the mechanism above verbatim; document in a `docs/architecture/vault-concurrency.md` companion file in Week 1 (before agent code starts). **Blocks v1.0 build:** no — concurrency code is a v1.0 build artefact, not a Week 0 prerequisite, but the design needs to land before the first multi-agent test in week 5.
docs/architecture/second-brain-design.md:747:**Why not atomic across all files:** filesystems aren't transactional across files. Atomic-by-emulation (write all to `.tmp` then rename all) is brittle and doesn't compose with `flock`. Eventually-consistent with Postgres-as-truth is the realistic choice and matches master brief §3.3's "Postgres is the source of truth for state and provenance."
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
docs/architecture/second-brain-design.md:893:| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
docs/architecture/second-brain-design.md:896:| **Lock-in cost** — how hard to switch to a different option later | Low. Wrappers are 3-line shims; replace with calls to a different backend (MCP server, library) by changing the `exec` line. Library is reusable. Agents see the same `cortextos-ifos bus wiki-search` invocation regardless of backend — interface stable. | Medium. Agents have MCP `tools.yaml` entries committed; migration to α means rewriting `agent.md` and `tools.yaml` for every agent (18 in full strength per master brief §0). Library is reusable. | High. Skill-installation path is per-agent; migration requires per-agent skill removal + new wrapper/MCP declaration. Also under R2 the original installation path was a hack, which makes "switch away from γ" the cleanup of that hack. |
docs/architecture/second-brain-design.md:904:**Rationale anchored to three master brief sections:**
docs/architecture/second-brain-design.md:920:- **v1.2 graph view (master brief §5.5):** add `wiki-graph-traverse.sh` and a `graphify` subcommand. Surface grows by N scripts, not by architecture.
docs/architecture/second-brain-design.md:921:- **v2.0 LoRA scale (master brief §5.5):** the LoRA pipeline operates on the `decision_log` table, not on the wiki. Wiki ops from LoRA-enhanced agents are unchanged. Both options work.
docs/architecture/second-brain-design.md:924:**v1.0 build day estimate for Option α: 11-13 days.** Fits master brief §5.5's weeks 11-13 allocation. Detail in §3.4 below.
docs/architecture/second-brain-design.md:926:### 3.4 — Impact on master brief §5.5 build sequence
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:956:- **Scope:** larger than master brief §5.5 currently states (9 ops + 4 Postgres tables + concurrency machinery, vs. the original "2 ts files"). Still fits the 11-13 day budget because the bulk of the surface area is small Postgres operations with thin shell wrappers; the heavy code is in `concurrency.ts` and `update.ts` which together are ~400-600 lines.
docs/architecture/second-brain-design.md:958:- **Earlier work needed:** Postgres schema and the entity_graph→entities+entity_links rename move to Week 0 Day 4 (this week, already planned per master brief §6).
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/architecture/second-brain-design.md:969:| **2.1-C** | `wiki/compiled/playbooks/` (master brief §5.1 line 331) collides with `/vault/{tenant}/_playbooks/` (Ultraplan §5.1) | Same folder name at two paths with different intended uses | **Recommendation:** drop `wiki/compiled/playbooks/`. Playbooks live at `/vault/{tenant}/_playbooks/` only. Update master brief §5.1 to remove the `playbooks/` line from the `wiki/compiled/` tree. | No |
docs/architecture/second-brain-design.md:973:| **2.4-B** | Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`" | Single-table model insufficient for the JSONB GIN + trigram + adjacency mix v1.0 needs | Split into `entities` + `entity_links` per §2.4.2. Update master brief §3.3 / Ultraplan §5.1 wording. **Roll into Week 0 Day 4 Postgres provisioning.** | **Tight** — Day 4 of Week 0 (this week). |
docs/architecture/second-brain-design.md:981:## Impact on master brief §5.5 build sequence — closing paragraph
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
agents/recruitment/diagnostic/tools.yaml:3:# Status: Proposed (Day-19; @ifos/web-scraper + @ifos/companies-house MCP connectors shipped Day 13; LinkedIn via web-scraper page-fetch in v0; Proxycurl deferred to W4 polish).
agents/recruitment/diagnostic/tools.yaml:146:      Per master brief primitive 5 — Telegram notification on report
agents/recruitment/diagnostic/tools.yaml:171:  - xero           # Cash Conductor's territory (W7-8)
agents/recruitment/diagnostic/tools.yaml:172:  - quickbooks     # Cash Conductor's territory
agents/recruitment/diagnostic/tools.yaml:173:  - sage           # Cash Conductor's territory
agents/recruitment/diagnostic/tools.yaml:174:  - open_banking   # Cash Conductor's territory
agents/recruitment/diagnostic/README.md:9:| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed (Day-11 draft) |
agents/recruitment/diagnostic/README.md:14:Per master brief §3.1 boundary 1 + ADR-003 (agent bundle v2 pattern), a full agent bundle is 6 files + 3 fixtures:
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (today): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:11:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:12:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
agents/recruitment/sourcing-scout/agent.md:13:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:19:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/sourcing-scout/agent.md:21:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:109:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:211:     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
agents/recruitment/sourcing-scout/agent.md:236:      violations at write time; audit row mandatory per master brief §8.1
agents/recruitment/sourcing-scout/agent.md:256:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:269:On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.
agents/recruitment/sourcing-scout/agent.md:275:Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
agents/recruitment/sourcing-scout/agent.md:281:Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
agents/recruitment/sourcing-scout/agent.md:308:- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
agents/recruitment/sourcing-scout/agent.md:324:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/sourcing-scout/agent.md:339:| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/sourcing-scout/agent.md:370:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:375:### Gotchas (carried forward from ULTRAPLAN A5 line 555)
agents/recruitment/sourcing-scout/agent.md:378:2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
agents/recruitment/sourcing-scout/agent.md:379:3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
agents/recruitment/diagnostic/agent.md:4:**Build state:** Full bundle built (agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures). Codex review-agent-bundle rounds run through R19 (latest applied 2026-05-25 bilateral pass); ADR-006 closed the Cat-1/Cat-ζ Gate A finding at R10; subsequent rounds sit at steady-state ~4 mechanical cross-reference findings/round per master brief §10.3 step 5. Status flips Proposed → Accepted when ALL: (a) Codex RATIFIED verdict (R19 or escalated founder-arbitrated per §10.3 step 5), AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.
agents/recruitment/diagnostic/agent.md:7:**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
agents/recruitment/diagnostic/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/diagnostic/agent.md:17:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (target voice-classifier ≥ 0.75 per `common-voice.json`; v0 implementation warns + exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unreachable per §5 honesty note — W4 polish closes this to unconditional hard-fail) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:34:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY). Typical wall-clock: 10-15 minutes (empirical Day-13 measurement against Hays plc + Charterhouse fixtures); not specified in upstream master brief or Ultraplan.
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
agents/recruitment/diagnostic/agent.md:187:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 | warn | operator_chat_id | **v0: single-pass via `validate.sh` V3 (no in-generator retries); W4-planned: 3-retry classifier loop in `@ifos/diagnostic-generator` §12 LLM step.** Aggregate-tenant `ESC_VOICE_DRIFT_TENANT` is per `_shared/escalation-codes.md` (nightly cron). |
agents/recruitment/diagnostic/agent.md:188:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall | v0: emails-only regex; warn + exit 0 when firm-domain whitelist absent. W4-planned: phone-number PII detection + hard-fail when whitelist absent. |
agents/recruitment/diagnostic/agent.md:189:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn upstream 429 | warn | operator_chat_id | **v0: NOT implemented in `cycle.sh` (generator throws-and-exits on upstream errors; validate.sh catches downstream as `ESC_AGENT_OUTPUT_SHAPE`). W4-planned: 429 catch + retry-with-backoff in `cycle.sh` + explicit `ESC_RATE_LIMIT_HIT` emission.** |
agents/recruitment/diagnostic/agent.md:211:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. **v0: per-run `ESC_VOICE_DRIFT` fires when `validate.sh` V3 single-pass classifier call (no retries) returns score <0.75 AND `IFOS_VOICE_CLASSIFIER_URL` was reachable. W4-planned: 3-retry classifier loop in `@ifos/diagnostic-generator` §12 LLM step + unconditional hard-fail when URL unreachable.** Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/agent.md:213:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/diagnostic/agent.md:230:| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
agents/recruitment/diagnostic/agent.md:232:| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
agents/recruitment/diagnostic/agent.md:254:| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | v0 (Day 13 ship) skipped Proxycurl: LinkedIn deep-data sections (§3, §5, §7, §9, §11) use Companies House fallback citations per §3 table (status confirmed in §8 dependencies row "LinkedIn read-only via web-scraper" — Proxycurl deferred to W4). W4 polish decision path: founder evaluates commercial Proxycurl signup ($39/mo Proxycurl pricing low-volume) vs alternative (PhantomBuster, Bright Data, scraper.api) vs continued Companies House fallback. Resolution due before first pilot tenant onboarding (Risk #3 LOI close). |
agents/recruitment/janitor/README.md:9:| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed |
agents/recruitment/janitor/README.md:14:Full agent bundle per ADR-003: 6 files + 3 fixtures. Built at W5 start (~2 weeks per ULTRAPLAN A2 line 512):
agents/recruitment/janitor/README.md:30:- Bullhorn MCP connector built (W3-W4 conditional per ADR-005)
docs/operations/goal-w4-day-26-2026-06-01.md:1:# /goal — W4 Day-26 autonomous build (2026-06-01)
docs/operations/goal-w4-day-26-2026-06-01.md:18:8. Cluster F manifest entry in `scripts/run-codex-ratification.sh` — xero + quickbooks + open-banking via `mcp-connector` skill. Cash Conductor bundle queued for next manifest update when scaffold lands.
docs/operations/goal-w4-day-26-2026-06-01.md:21:9. Cash Conductor bundle skeletons — `cycle.sh` (14-step per agent.md §4) + `validate.sh` (Gate A per §5) + `tools.yaml`. Fixtures + `context.sh` + `cleanup.sh` deferred. Drafts-only graceful degradation when `autosend-bridge-telegram` absent (D1-B doc).
docs/operations/goal-w4-day-26-2026-06-01.md:37:Print: commits + SHAs · test counts per new package · Phase 1 ✓ + context-cost reduction · ECC patterns adopted (≤3) · Phase 2 status (qb / open-banking; partial OK) · Phase 3 reached? · founder action board refresh · tomorrow's first action: Cash Conductor bundle + cluster F run.
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:19:# Status: Proposed (W4 Day-26 SKELETON).
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:96:      routing: [operator_chat_id, tenant_admin]   # per agent.md §6 row 11 (NOT ifos_oncall — that's the Cash Conductor routing variant)
docs/operations/goal-overnight-2026-05-31.md:1:# /goal — Overnight W4 Track-1 + smoke-fix (2026-05-31 → 2026-06-01)
docs/operations/goal-overnight-2026-05-31.md:16:2. `docs/operations/goal-week-4-track-1.md` §0 + §2 + §9 (canonical W4 spec)
docs/operations/goal-overnight-2026-05-31.md:54:Update `.agents/current-priorities.md` (W4-day-25-overnight section) with shipped items + smoke outcome + 2 path bugs fixed + Anthropic-credit founder-action queued + next-step on pickup. Commit.
docs/operations/goal-overnight-2026-05-31.md:62:- Cash Conductor bundle scaffold (depends on connectors landing first)
docs/operations/goal-overnight-2026-05-31.md:80:- Next step on pickup: cluster F manifest entry + Open Banking connector + Cash Conductor bundle
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:7:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:8:**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
agents/recruitment/janitor/agent.md:9:**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.2 (lines 105-116; §2.1 is the Diagnostic section).
agents/recruitment/janitor/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/janitor/agent.md:17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:62:| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
agents/recruitment/janitor/agent.md:70:1. **Candidate / contractor merge** (`PUT /Candidate/{primary_id}` + cascade; candidate and contractor are separate entity types per vertical-schema.yaml §1 but share the §4 Steps 3-4 fuzzy-matcher) — auto-merged only when confidence ≥0.85 AND neither record had Bullhorn activity in the last 90 days (per ULTRAPLAN A2 line 510 verbatim); pairs in the 0.70–0.85 review band, or ≥0.85 with recent activity, are held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before any write. Action type: **`bullhorn_candidate_dedupe`** with `payload.entity_type ∈ {candidate, contractor}` discriminating the two — reused rather than a separate contractor action_type (same yellow tier + matcher; registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:80:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:107:     (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:132:   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
agents/recruitment/janitor/agent.md:185:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:188:- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
agents/recruitment/janitor/agent.md:189:- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:205:Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.
agents/recruitment/janitor/agent.md:209:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:251:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:266:| Bullhorn MCP connector built | W3-W4 conditional (per ADR-005 sequencing) | ⏸ Not started |
agents/recruitment/janitor/agent.md:277:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:289:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:296:### Gotchas (carried forward from ULTRAPLAN A2 line 513)
agents/recruitment/janitor/agent.md:298:1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
agents/recruitment/janitor/agent.md:300:3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
agents/recruitment/concierge/fixtures/01-primary.yaml:11:# Status: Proposed (W4 Day-26 SKELETON).
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:1:# /goal — W4 Day-26 afternoon: bundle completion + bridge + polish (2026-06-01)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:8:## §1 Phase A — Cash Conductor bundle completion (~3h, 3-5 commits)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:15:Closes goal-week-4-track-1.md §1 criteria 5-10. Cluster F-bis manifest entry queued (Cash Conductor agent-bundle skill) — actual entry to `run-codex-ratification.sh` lands at start of Day-27 when ready to fire cluster F + F-bis together.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:25:- Fail-safe: timeout returns `{outcome: "timeout"}` not an exception — caller (Cash Conductor cycle.sh Step 10, Concierge cycle.sh) decides how to fire the ESC code
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:27:≥12 vitest (scaffold + config + propose + await with poll-mock + timeout + reject path + concurrent same-approval-id idempotency). Live Telegram tests gated `BRIDGE_LIVE_TESTS=true`. Zero credential interpolations in errors. README documents D1-B precedent + Concierge W10 integration contract + Cash Conductor `cycle.sh` Step 10 wiring.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:47:Print: phase A/B/C status + commit SHAs · test counts (bridge: ≥12 vitest target) · Cash Conductor bundle 100% complete? · bridge package scaffold complete? · 2 polish items closed? · founder action board refresh · tomorrow's first action (cluster F + F-bis ratification triggers when founder ready; voice classifier microservice begins Tue scaffold).
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:66:| 10 | Reporting Engine | Operations | Friday 07:00 | Weekly briefing | Stripe, GA4, Meta Ads, Slack |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:206:- GA4 (Reporting Engine)
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
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §1 Output contract (one-paragraph screenshot per master brief §1 Rule 1)
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:95:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
docs/operations/goal-week-3-polish-and-scaffold.md:108:| Voice classifier microservice | Reserved for W4-5 polish; for Week 3, §12 LLM call skips voice-classifier gate (V3 stays as a skipped-with-warning) |
docs/operations/goal-week-3-polish-and-scaffold.md:215:3. Voice classifier integration: STUB — `IFOS_VOICE_CLASSIFIER_URL` unset means skip-with-warning (preserves V3 behaviour). Real classifier wires up at W4-5.
docs/operations/goal-week-3-polish-and-scaffold.md:293:- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
docs/operations/goal-week-3-polish-and-scaffold.md:294:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:306:- **§3 Output shape:** day-30 report has 8 sections per ULTRAPLAN line 511 (record counts, dedup pairs, field-completeness deltas, tacit-note coverage, agent vs. consultant attribution, gate-B metric, exception list, executive summary).
docs/operations/goal-week-3-polish-and-scaffold.md:309:- **§5 Gate B:** ≥15% dedup improvement + ≥10% field-completeness improvement per ULTRAPLAN line 512.
docs/operations/goal-week-3-polish-and-scaffold.md:312:- **§8 Build prerequisites:** Bullhorn MCP connector wired (W3 conditional; W4-5 if A+B answered) + first pilot tenant with Bullhorn corpToken in `_secrets.env`.
docs/operations/goal-week-3-polish-and-scaffold.md:322:- §1 reads as a complete one-paragraph screenshot per master brief §1 Rule 1
docs/operations/goal-week-3-polish-and-scaffold.md:324:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:331:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:332:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:352:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:354:### DAY 18 — Cash Conductor agent.md scaffold (Step 10)
docs/operations/goal-week-3-polish-and-scaffold.md:359:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:360:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:361:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:362:- `vertical-schema.yaml` §3 agent_access_matrix Cash Conductor row
docs/operations/goal-week-3-polish-and-scaffold.md:363:- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:370:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
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
docs/operations/goal-week-3-polish-and-scaffold.md:450:Triage protocol (master brief §10.3 step 5 hard ceiling: ≤2 round-trips):
docs/operations/goal-week-3-polish-and-scaffold.md:461:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:487:| **Master plan citations** | Every architectural claim cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:502:| Codex Round 4 returns >2 REJECTED on any single artefact | Founder review; do NOT remediate-and-resubmit beyond hard ceiling (per master brief §10.3 step 5); write founder-decision doc; defer |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:540:Per master brief §10 + §10.3 step 5 hard ceiling + Day-11 Round-2/3 pattern.
docs/operations/goal-week-3-polish-and-scaffold.md:573:- **Mechanical REJECTIONS (citation drift, line-anchor error, formatting):** Round 4 remediation prompt; expect Round 5 final. Hard ceiling per master brief §10.3 step 5: 2 round-trips MAX. Round 5 RATIFIED → close. Round 5 STILL REJECTED → founder review.
docs/operations/goal-week-3-polish-and-scaffold.md:590:1. **Every claim cites a master plan section.** No bare assertions. Every paragraph either cites the master brief / ULTRAPLAN / sequencing-target / kill-criterion / specific ADR, OR is explicitly stated as "scaffold inference; founder review required."
docs/operations/goal-week-3-polish-and-scaffold.md:591:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:595:6. **Every Gate B target is measurable.** Cite the master plan section or ULTRAPLAN line that establishes the metric. No invented numbers.
docs/operations/goal-week-3-polish-and-scaffold.md:620:  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:641:  ✓ ULTRAPLAN §8.1 — all 6 agents have output contracts authored
docs/operations/goal-week-3-polish-and-scaffold.md:642:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:650:    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/goal-week-3-polish-and-scaffold.md:651:    - Cash Conductor build (full bundle)
docs/operations/goal-week-3-polish-and-scaffold.md:664:  - <Xero dev account for W4>
docs/operations/goal-week-3-polish-and-scaffold.md:682:| 1 | Anthropic API rate-limit / outage during Step 4 dev | Low | Built-in retry + deterministic fallback; flag as W4 polish if rate-limited persistently |
docs/operations/goal-week-3-polish-and-scaffold.md:687:| 6 | LLM-driven §12 produces opener that fails voice classifier consistently | Medium | Deterministic fallback already in place; flag as W4 polish (real voice classifier wires up later) |
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:4:# THE HARDEST CASE per ULTRAPLAN A6 §gotchas: "respectful, specific, leaves
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:16:# Status: Proposed (W4 Day-26 SKELETON).
docs/operations/codex-ratification-guide.md:30:- Citation drift — `master brief §10.4` quoted 15 times in one batch, all wrong (real past incident)
docs/operations/codex-ratification-guide.md:200:2. Citation §10.4 incorrect — master brief §10.4 is the Codex exclusion list, not the cost target the ADR cites. Past pattern of 15 fabricated §10.4 references; verify line numbers before citing. Citation: ADR-001 line 47.
docs/operations/codex-ratification-guide.md:373:The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.
docs/operations/codex-ratification-guide.md:516:- **Possibly updated master brief** — Codex may flag spec drifts requiring atomic correction
agents/recruitment/concierge/README.md:18:Full bundle at W10-13 build (~4 weeks per ULTRAPLAN A6 line 568 XL flag):
agents/recruitment/concierge/tools.yaml:3:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces per-cap
agents/recruitment/concierge/tools.yaml:33:    purpose: "Bullhorn OAuth refresh + per-tenant token rotation (deferred to W7 Janitor bundle Track-2 per master brief §8.2)"
agents/recruitment/concierge/tools.yaml:200:#   gmail_outlook_send_to_candidate    orange              [shared with Cash Conductor at audit layer when bullhorn channel = email]
agents/recruitment/concierge/tools.yaml:212:# Boundary check (per master brief §3 + review-mcp-connector.md §8)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:5:**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:17:Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:31:Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:37:**My recommendation:** **C** (hybrid). Per-claim validation is genuinely hard to automate at v0 (requires NLP claim-extraction + per-claim evidence-link matching); deferring to W4 is honest. But Codex is right that the §1 contract reads as if we're skipping it entirely — needs clearer "deferred to W4 with documented gap-coverage plan."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:45:**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:83:**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:92:4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:127:1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:128:2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:144:- Per-claim Gate A validation is genuinely hard to automate (NLP claim-extraction + per-claim evidence linkage); the hybrid v0+W4 path is the industry-standard approach.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:147:- §5 honesty (Issue 5) is exactly the kind of "honest signal" the master brief §1 Rule 5 demands; framing §5 as "intended behaviour, build slice will deliver" is more honest than asserting Gate A as already-implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:149:These are not unprincipled compromises — they're the right v0 stance with W4-13 polish path documented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:165:**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:186:Despite master brief §10.3 step 5 protocol saying founder review after Round 5, Round 6 attempted with all Round-5 issues remediated (commit `aaa376d`). Round 6 returned REJECTED with **4 new findings**, none of which appeared in any prior round:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:188:1. Gate B composite score (≥12.5) weakens dual ULTRAPLAN thresholds (15% dedup AND 10% field-completeness independently)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:206:This document now contains 4 rounds of empirical evidence supporting the master brief's documented hard-ceiling protocol. Founder Sunday review session is the right next step.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:229:**Round 7 findings 1 + 2 + 3 + 4 are all CAUSED BY my Round 6 fixes.** When I fixed one section, I introduced inconsistencies between it and other sections referencing the same concept. This is the perfect illustration of why master brief §10.3 step 5 caps round-trips: each fix changes the document, and the changed document has new inconsistencies between the fixed-section and the related-but-unfixed sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:275:| Cash Conductor | 5 | `20260524T113038Z-83732` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:287:#### Category β — Schema-supplement-needed (v0.3 supplement is a founder-action gate before W4-W13 builds)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:293:- All five are blocked on v0.3 supplement landing (founder review at first-pilot-onboarding) — DOCUMENTED IN W4 BACKLOG
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:297:- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:300:- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:301:- `ESC_AUTOSEND_RACE` — Cash Conductor uses for payment-received-during-chase race; catalogue defines for two-agents-same-payload_hash race. Resolution: widen to cover both.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:302:- DOCUMENTED IN W4 BACKLOG (catalogue v2 amendments)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:309:- All five build-slice items (W4-W13) DOCUMENTED IN BUILD-SLICE BACKLOG
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:317:  - Cash Conductor Steps 7-8, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:320:- DOCUMENTED IN W4 BACKLOG (cycle.sh build slices deliver these calls per agent §4 specs)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:358:- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:373:| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:378:**Cumulative empirical (10 rounds total):** ~75 unique findings catalogued; ~7 closed via Cat-α + Cat-γ + Cat-δ inline this session; convergence rate ~10% per round. The pattern documented in master brief §10.3 step 5 holds.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:403:- **A) Amend ULTRAPLAN §8.1 A1 line 497** — change "no claims unsupported by source data" to "no claims unsupported at section level" to match v0 reality. Aggressive; rewrites upstream spec.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:409:### Decision — stop Codex looping per master brief §10.3 step 5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:200:ratification per master brief §10.5. Decide whether Claude's counter-argument
docs/operations/codex-round-2-handoff.md:292:Hard ceiling: 2 round-trips (master brief §10.3 step 5). After Round 2, no Round 3 — escalate to founder for explicit decision.
docs/operations/codex-round-2-handoff.md:332:Any Round-2 REJECTED items get their own row in the manifest queue updated to "REJECTED→ROUND-3-pending OR founder-escalated". Per §10.3 master brief: no Round 3 until founder decides.
docs/operations/codex-round-2-handoff.md:373:Per master brief §10.6 + execution plan §5:
docs/operations/codex-round-2-handoff.md:406:Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).
docs/operations/decision-log.md:12:Established 2026-06-01 (W4 Day-26) as part of the priorities refactor (goal §1.2). Pre-refactor, all of this content lived in `.agents/current-priorities.md` itself (had grown to 1161 lines + accreted across 25 days). The refactor preserves every historical entry verbatim; only the surface presentation changed.
docs/operations/decision-log.md:16:## W4 Day-25 overnight (2026-05-31 → 2026-06-01) — autonomous Track-1 start ✓
docs/operations/decision-log.md:53:### What's queued for daytime W4 Track-1 continuation
docs/operations/decision-log.md:59:- **Cash Conductor bundle scaffold** — cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures; depends on at least Xero + Open Banking landing
docs/operations/decision-log.md:60:- **Cluster F manifest add** — add Xero + QuickBooks + Open Banking + Cash Conductor to `scripts/run-codex-ratification.sh` and trigger founder-side ratification run
docs/operations/decision-log.md:68:## W4 Day-25 evening (2026-05-31) — v0.3 migration APPLIED to live VPS ✓
docs/operations/decision-log.md:77:- **Third attempt: SUCCESS.** Migration applied cleanly (BEGIN…41 DDL…in-migration smoke "v0.3 migration smoke passed"…COMMIT). Post-flight verification confirmed: both Cash Conductor tables present and `postgres`-owned (Day-12 compliant); `validate_voice_scores` trigger replaced by `validate_entities_data_v0_3`; `validate_tenant_adapters_config_v0_3` present.
docs/operations/decision-log.md:87:- **W4 backlog item #1 CLOSED** (Day-20 queue's first item).
docs/operations/decision-log.md:88:- **Cash Conductor `cash_conductor_transactions` + `cash_conductor_invoices` tables exist on live VPS** — the W4 Track-1 /goal can wire MCP connectors against real schema (not just fixtures).
docs/operations/decision-log.md:106:## W4 Day-25 (2026-05-31) — founder decisions captured + W4 Track-1 /goal authored
docs/operations/decision-log.md:119:| 8 | Proxycurl + Reed + CV-Library signups | DEFERRABLE | not blocking W4 Track 1 |
docs/operations/decision-log.md:121:| 10 | Xero developer account | DEFERRABLE | gates live Cash Conductor test (scaffold proceeds fixture-first) |
docs/operations/decision-log.md:127:- W4 Track-1 work has a complete /goal prompt — paste `docs/operations/goal-week-4-track-1.md` into any new Claude Code session and it executes the next 5-7 days autonomously (with founder gates as documented).
docs/operations/decision-log.md:130:## W4 Day-25 (2026-05-31) — Codex Round 1 (agent-bundle) verdict closed
docs/operations/decision-log.md:156:**Founder decision (2026-05-31): Fix + STOP — no Round 4.** Migration has had 3 round-trips (R1 → R2 → R3) and applying-and-re-running would be a 4th, crossing master brief §10.3 step 5 ≤2-cap further. Codex spelled out the exact `to_regclass` fix; it's applied at `0f4ce8d`. Re-ratification of the rollback path is deferred to its next natural touch (live VPS apply OR v0.4 supplement work) and recorded in the W4 backlog. Net effective state: **8/9 Codex-RATIFIED + 1 with the latest R3 fix applied = 9/9 in substance**.
docs/operations/decision-log.md:158:### W4 backlog addition (from R3 stop decision)
docs/operations/decision-log.md:171:**Round 3 ready** (re-run `--cluster E`) — expect RATIFIED 9/9. **Ceiling note:** master brief §10.3 step 5 caps round-trips at 2; R3 crosses for ADR-007 / v0.3 / migration. Justified because the R2 findings were tiny mechanical drift items Codex spelled out exactly. **If R3 returns NEW issues, that is the escalation signal — stop and route to founder arbitration; do NOT run R4.**
docs/operations/decision-log.md:173:## W4 Day-21 (2026-05-27) — ratification remediation + harness fix
docs/operations/decision-log.md:184:   - **Cash Conductor (2):** autosend line cites (182→188, 257→263); missing vault-write step
docs/operations/decision-log.md:186:   - **Concierge (5):** ULTRAPLAN 566 citation realign; SLA-miss audit row; 24h→PT4H timeout; ESC_VOICE_DRIFT severity→warn; third Gate B threshold
docs/operations/decision-log.md:195:4. **ADR-007 ULTRAPLAN amendment marked provisional** pending founder Accept (kept Status: Proposed; did NOT self-Accept — founder arbitrates per ADR-006 precedent).
docs/operations/decision-log.md:203:Run because the founder hit Codex usage limits. This is the strongest assurance available without the independent second model; it is NOT a replacement for Codex ratification (master brief §10.5), which stays a deferred gate.
docs/operations/decision-log.md:212:| Citation ranges (ULTRAPLAN 34 + master-brief 8 line-refs) | all in-range ✓ |
docs/operations/decision-log.md:213:| ESC codes referenced ∈ escalation-codes.md | ✓ (3 are sanctioned W4-backlog proposals / changelog notes; janitor's `ESC_BULLHORN_OAUTH_REVOKED` disclaimer corrected → folded into `ESC_BULLHORN_AUTH` payload) |
docs/operations/decision-log.md:220:## W4 Day-20 shipped
docs/operations/decision-log.md:224:1. `22cd672 ops(w4-day-20)` — v0.3 migration wrapper (`scripts/run-v0.3-migration.sh`; --dry-run; closes W4 backlog item #1 gap) + Day-20 founder runbook + bilateral-pass working doc
docs/operations/decision-log.md:230:7. `26551c8 feat(ADR-007 + concierge-r4)` — ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted; analogue of ADR-006; closes Concierge R3 Finding 3 structurally. Step 11 `hh_decision_action` added. **Closes W4 founder-action queue item #3** (drafted; ratification gates Concierge Accepted).
docs/operations/decision-log.md:237:| Cash Conductor | Pre-Build-Round-18-Bilateral-Confirmed | 3 | 0 (all in `9ae6874`) | Codex R19 re-ratification |
docs/operations/decision-log.md:254:  - Cash Conductor: R10-R17 (Pre-Build-Round-17-Reviewed; 3 last-mile)
docs/operations/decision-log.md:264:## W4 backlog
docs/operations/decision-log.md:268:- [x] **ADR-006 Diagnostic Gate A hybrid** — Accepted founder-arbitrated at commit `6d2d43e`; ULTRAPLAN line 496 in-band amendment at `aed9d3b`.
docs/operations/decision-log.md:269:- [ ] **Diagnostic validate.sh + cycle.sh polish (W3-W4)** — emit specific ESC codes per §6; write validate_check_skipped row; add operator_notify_telegram hh_decision_action call.
docs/operations/decision-log.md:272:## W4 founder-action queue (Day-20 update)
docs/operations/decision-log.md:296:Clear all seven days of master brief §6 by Sunday. Five-of-five yeses on the
docs/operations/decision-log.md:301:Single-sentence test result 3 of 5 YES (Q1 NO + Q3 NO + Q2/Q4/Q5 YES). Week 0 extends per master brief §6 line 502. **Week 1 named agent-build slices DO NOT BEGIN until at minimum Q1 turns YES.**
docs/operations/decision-log.md:315:- [x] **Phase 5** — `voice-loader.sh` + tests + README updates. Landed Day 8 `fe56e93`. Closes master brief §8.1 Change 1. 9/9 voice-loader tests pass.
docs/operations/decision-log.md:360:- [ ] **R11**: tenant_eval_sets + tenant_adapters usage spec — Diagnostic W4 (first eval-set)
docs/operations/decision-log.md:375:- ❌ Diagnostic W3-4 agent build (and all named v1.0 agent builds: Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/operations/decision-log.md:408:- `d64d1c5` (Step 10) Cash Conductor agent.md (377 lines)
docs/operations/decision-log.md:428:| Cash Conductor agent.md | REJECTED ~5-7 issues | Same |
docs/operations/decision-log.md:434:1. Gate A vs ULTRAPLAN source-data citation strength → hybrid v0 + W4 polish
docs/operations/decision-log.md:451:- ✓ ULTRAPLAN §8.1 — all 6 v1.0 agents have output contracts authored
docs/operations/decision-log.md:452:- ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/decision-log.md:461:- Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/decision-log.md:462:- Cash Conductor build (full bundle)
docs/operations/decision-log.md:481:- **Step 8** (`2340e24`) — Janitor agent.md (296 lines) per ULTRAPLAN §8.1 A2 (W5 build wave)
docs/operations/decision-log.md:482:- **Step 9** (`7730baa`) — Scribe agent.md (336 lines) per ULTRAPLAN §8.1 A3 (W6 build wave)
docs/operations/decision-log.md:483:- **Step 10** (`d64d1c5`) — Cash Conductor agent.md (377 lines) per ULTRAPLAN §8.1 A4 (W7-8 build wave; Hire #1 anchor)
docs/operations/decision-log.md:484:- **Step 11** (`1472e04`) — Sourcing Scout agent.md (335 lines) per ULTRAPLAN §8.1 A5 (W9 build wave)
docs/operations/decision-log.md:485:- **Step 12** (`94485aa`) — Concierge agent.md (387 lines) per ULTRAPLAN §8.1 A6 (W10-13 build wave; XL complexity)
docs/operations/decision-log.md:498:All 6 v1.0 agents now have ratified-or-pending-ratification output contracts (master brief §1 Rule 1 satisfied):
docs/operations/decision-log.md:500:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: Proposed; ready for Codex Round 4 Phase 2
docs/operations/decision-log.md:502:Per master brief §8.2 + ULTRAPLAN §8.1, each scaffold cites verbatim:
docs/operations/decision-log.md:503:| Agent | Build wave (master brief) | ULTRAPLAN line range |
docs/operations/decision-log.md:508:| Cash Conductor | W7-8 (Hire #1 anchor) | A4 lines 529-542 |
docs/operations/decision-log.md:512:Drift flags surfaced for Sourcing Scout (master brief W9 vs ULTRAPLAN W8-9) and Concierge (master brief W10-13 = 4w vs ULTRAPLAN W9-10 = 2w). Master brief authoritative per project hierarchy; XL complexity in ULTRAPLAN A6 line 568 corroborates 4-week duration for Concierge.
docs/operations/decision-log.md:517:- Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/decision-log.md:527:**Codex Round 4 ratification queue:** 11 items prepared in manifest §1.10. Phase 1 (6 items) ready when founder runs Step 7; Phase 2 (5 items) ready when founder runs Step 13. Hard ceiling per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 max).
docs/operations/decision-log.md:543:**This is the Week-4 milestone arriving on Day 13 of Week 2.** Per ULTRAPLAN line 753-755: "Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact." Day-13 v0 delivery satisfies the structural form of this milestone — pending Step 7 real-firm smoke run after founder registers Companies House API key.
docs/operations/decision-log.md:556:**ADR-005 ratifies the sequencing change** (commit `e578354`): Week 3 repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build per ULTRAPLAN §10 Risk #2 contingency. Bullhorn-touching agents (Janitor W5+) gated on Bullhorn Sub-decisions A+B response (form submitted 2026-05-24) or 2026-06-10 force-fallback.
docs/operations/decision-log.md:560:**LinkedIn integration:** Option A (free unauthenticated public-page HEAD check) wired today per founder pick. Proxycurl signup deferred to W4 polish.
docs/operations/decision-log.md:645:- `agents/recruitment/diagnostic/agent.md` (~370 lines, Status: Proposed) — full output contract per master brief §1 Rule 1:
docs/operations/decision-log.md:649:  - §4 Workflow (10-step process from Ultraplan §8.1 A1 with `hh_decision_*` integration per master brief §8.1 Change 2)
docs/operations/decision-log.md:652:  - §7 Voice + tone constraints (integration with `_shared/voice-loader.sh` per master brief §8.1 Change 1)
docs/operations/decision-log.md:663:**Why now:** master brief §1 Rule 1 "Output before architecture" + ADR-003 agent bundle v2 pattern + zero blocking dependency on founder-side D1/D2/D3 + zero blocking dependency on pilot tenant. Output contract is self-contained spec.
docs/operations/decision-log.md:798:- `agents/_shared/voice-loader.sh` (292 lines, shellcheck clean) — 3 hh_load_* helpers per master brief §8.1 Change 1. Live mode (RLS-isolated SELECT) + fallback (vault files).
docs/operations/decision-log.md:854:- `agents/_shared/escalation-codes.md` (255 lines, Reference) — closes master brief §8.1 Change 3 Week-0 task ("Build the catalogue in Week 0"); 24 active codes + 2 reserved across 6 sections
docs/operations/decision-log.md:862:Week 0 closing day per master brief §6 Day 7. Three deliverables landed across two commits.
docs/operations/decision-log.md:874:**Per master brief §6 line 502 verbatim: "Five yeses → Week 1 starts Monday. Anything less → Week 0 extends."** → **Week 0 EXTENDS.**
docs/operations/decision-log.md:878:1. **Atomic-correction commit `0e5b2b4`** — master brief reconciliation, 11 edits batch-applied (10 master brief + 1 Ultraplan):
docs/operations/decision-log.md:913:- **15 fabricated "master brief §10.4" references** across 5 files. Master brief §10.4 is "What never goes through ratification" (Codex exclusion list), not a Hetzner location or cost-target section. Root cause: Day-4 runbook §1.4 invented the citation; propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1), RISK-REGISTER (2), current-priorities (1) by citation transitivity rather than re-verification against master brief.
docs/operations/decision-log.md:922:**Spot-checks that PASSED audit** (no fixes needed): master brief §3.2 line 155 (canonical vocabulary), §5.1 lines 325-329 (vault structure), §8.1 Change 1/2/3 (voice + decision logging + escalation), ADR-003 Decision 3 referencing design §2.1, sequencing-target.md §6.6 three failure conditions, ULTRAPLAN.md existence, bullhorn-integration-path.md §4.1 + §6.3 canonical-orange anchor.
docs/operations/decision-log.md:928:Single-day light artefact per master brief §6 Day 6 framing. Drafting → batched founder review (8 surfaces + 3 findings) → 4 revisions → commit.
docs/operations/decision-log.md:933:  - 8 core entities per master brief §6 Day 6 line 490: `candidate`, `contractor`, `client`, `contact`, `brief` (with `role` alias), `placement`, `opportunity`, `timesheet`
docs/operations/decision-log.md:936:  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
docs/operations/decision-log.md:946:- **`brief` as canonical slug** with `role` documented alias (matches master brief §3.2 + §5.1 + §9 canonical vocabulary)
docs/operations/decision-log.md:976:  - **Trigger 8 (Gate-B revenue uplift):** master brief canonical — <£20k/year/tenant after 3 pilots → KILL
docs/operations/decision-log.md:1007:- Postgres 16.14 + pgvector 0.8.2 on the LUKS volume; data directory on `/dev/mapper/ifos_data`; service `is-enabled: disabled` at boot (LUKS-noauto conflict per §5.2 deviation 14); `ifos-unlock` starts it post-mount.
docs/operations/decision-log.md:1062:- `docs/decisions/sequencing-target.md` — 522 lines, 7 sections. **Accepted** Option Alpha (master brief §8.2 ratified)
docs/operations/decision-log.md:1085:- `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh` per master brief §8.1 Changes 1 + 2. **Full ESC_* wiring scope now specified across prior documents:**
docs/operations/decision-log.md:1119:Commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1 + Day-5 path drift + decision_log.phase render`. Single Codex ratification on Day 7.
docs/operations/decision-log.md:1125:Per master brief §10.6 first ratification run — Day 7 added items 20 + 21 + the landed atomic-correction commit `0e5b2b4`. Total: 21 items + 1 commit. **Execution deferred** to Week 0 extension period (skills + Q1 unblocker both required first). See `docs/decisions/2026-05-18-codex-ratification-manifest.md` §3 + §4 for the gap + schedule.
docs/operations/decision-log.md:1148:22. **Atomic-correction commit `0e5b2b4`** — LANDED Day 7 2026-05-20 (`docs: master brief reconciliation — 11 edits batch-applied`); two side effects flagged for Codex review per commit message
docs/operations/decision-log.md:1159:- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
docs/RISK-REGISTER.md:4:the top. Full risk list is in master brief §12 and Ultraplan §10.
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:50:Full risk register per master brief §12 / Ultraplan §10. Port the remaining
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:63:- 2026-05-17 (Day 4) — **Day 4 provisioning executed end-to-end against Hetzner Cloud NBG1 VPS (178.105.87.24).** All 9 runbook sections complete; §7 RLS isolation gate passed all 5 conditions (cross-tenant data access structurally impossible for `ifos_app` regardless of application bugs); 22 of 22 §9 automated checks passed. **Risk #7 edit count revised from 8 to 9** with new Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations"). **One new risk added (#8 LUKS manual unlock single-point-of-failure)** — Low probability, Medium-High impact, v1.2+ TPM/key-server mitigation path named. Two non-blocking operational items deferred to founder convenience: (a) Hetzner Console snapshot of `ifos-v2-prod-01`; (b) ifos_app password retrieval from `/vault/.ifos_app_password.tmp` → 1Password → temp file delete; (c) **high-priority** LUKS new-passphrase retrieval from `/root/.new_luks_passphrase.tmp` → 1Password → temp file delete (must be done before next reboot — old leaked passphrase already invalidated by Day-4 §11 rotation). Path B protocol gap (LUKS passphrase entered chat for `ifos-unlock` end-to-end test) closed via `cryptsetup luksChangeKey` rotation: OLD (leaked) rejected by `--test-passphrase`, NEW accepted; leaked passphrase in chat transcript is cryptographically invalid. v1.1 runbook revisions catalogued (8 items) for collection during Days 5-7. Codex Day-7 queue grows from 13 to 15 (Day 4 runbook + executed version).
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/operations/goal-week-4-track-1.md:1:# /goal — Week 4 Track 1: Cash Conductor MCP connectors + Diagnostic live polish
docs/operations/goal-week-4-track-1.md:3:**Status:** Authored 2026-05-31 (Day 25 / W4 Day-2); ready for execution.
docs/operations/goal-week-4-track-1.md:4:**Type:** Goal prompt (paste into Claude Code at session start; executor runs to completion across W4 Days 3-7, target 2026-06-01 → 2026-06-05).
docs/operations/goal-week-4-track-1.md:5:**Master plan citations:** Master brief §8.2 (build wave W4 Cash Conductor MCP connectors) + ULTRAPLAN §8.1 A4 (Cash Conductor spec lines 531-545) + ADR-005 (Week-3 acceleration → Cash Conductor pulled forward to W4 substrate) + `agents/recruitment/cash-conductor/agent.md` §8 build dependencies + `docs/decisions/2026-05-31-d1-founder-decision.md` (D1-B resolved) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic live render by 2026-06-14).
docs/operations/goal-week-4-track-1.md:16:2. **`.agents/current-priorities.md`** Open + Day-25 sections (this goal opens W4 Track 1)
docs/operations/goal-week-4-track-1.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §8.2 W4-W7 rows + §10 (ratification cadence + always-ratify list) + §10.5
docs/operations/goal-week-4-track-1.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A4 lines 531-545 (Cash Conductor spec) + §10 risk rows referencing Open Banking 90-day token rotation
docs/operations/goal-week-4-track-1.md:19:5. **`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`** (Cash Conductor pull-forward authorisation)
docs/operations/goal-week-4-track-1.md:20:6. **`docs/decisions/2026-05-31-d1-founder-decision.md`** (D1-B Telegram shim — affects Cash Conductor `xero_reminder_send_customer` flow)
docs/operations/goal-week-4-track-1.md:21:7. **`agents/recruitment/cash-conductor/agent.md`** in full (the output contract; §4 workflow shows the 14 steps Cash Conductor needs the connectors to fulfil)
docs/operations/goal-week-4-track-1.md:31:After reading: post in chat **"Read order complete. Five rules: [verbatim]. Four boundaries: [verbatim]. W4 Track 1 scope: Xero + QuickBooks + Open Banking MCP connectors + Cash Conductor bundle scaffold + Diagnostic live-smoke wrapper + review-mcp-connector Codex skill + cluster F manifest. Ready to begin Step 1."**
docs/operations/goal-week-4-track-1.md:35:## §1 — Success state (what "done" looks like at end of W4 Track 1)
docs/operations/goal-week-4-track-1.md:43:3. **`packages/mcp-connectors/open-banking/`** exists; abstraction over TrueLayer + Plaid UK (provider chosen per-tenant config). Capabilities: `oauth_refresh` (90-day PSD2 consent), `list_transactions_since(last_ingested_at)`, `get_account_balance`. **Token-aging logic implemented**: emits `ESC_OPEN_BANKING_TOKEN_AGING` with `info`/`warn`/`blocking` staging per Cash Conductor §6 (≤30d/14d/7d). ≥15 vitest passing.
docs/operations/goal-week-4-track-1.md:44:4. **Sage MCP connector — DEFERRED** per Cash Conductor §9 Q8 recommendation; documented in W4-5 backlog as "rebuild at first pilot tenant on Sage."
docs/operations/goal-week-4-track-1.md:46:### Cash Conductor bundle scaffold (Day 5)
docs/operations/goal-week-4-track-1.md:57:11. **Cash Conductor agent.md `Status: Proposed`** unchanged — the agent.md was already RATIFIED by Codex R3; the bundle scaffold doesn't flip Status (production-readiness still gates on Hire #1 + accounting/Open Banking commercial signups per §8).
docs/operations/goal-week-4-track-1.md:78:16. **`.agents/current-priorities.md`** updated with W4 Track 1 close section.
docs/operations/goal-week-4-track-1.md:91:| Xero MCP connector (fixture-first; OAuth scaffold) | §1 success criterion 1; Cash Conductor's most likely first-tenant accounting system |
docs/operations/goal-week-4-track-1.md:94:| Cash Conductor bundle scaffold (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) | §1 criteria 5-10; agent.md is already RATIFIED, needs siblings |
docs/operations/goal-week-4-track-1.md:104:| Sage MCP connector | Cash Conductor §9 Q8 — defer to first-pilot-on-Sage trigger |
docs/operations/goal-week-4-track-1.md:105:| Diagnostic voice classifier microservice | Separate W4-5 polish goal; deferred until Anthropic key live + first pilot voice corpus seeded |
docs/operations/goal-week-4-track-1.md:107:| Cash Conductor live integration tests (against real Xero/QB sandbox) | Gated on founder commercial signups (item 10); fixture-first is the v1.0 ship gate |
docs/operations/goal-week-4-track-1.md:108:| `autosend-bridge-telegram` package | Reserved for Concierge W10 build slice per D1-B doc §"Implementation surface"; Cash Conductor cycle.sh degrades gracefully when absent (drafts-only mode) |
docs/operations/goal-week-4-track-1.md:265:### DAY 5 — Cash Conductor bundle scaffold
docs/operations/goal-week-4-track-1.md:305:Commit: `feat(codex-harness): add cluster F for W4 Track-1 connectors + Cash Conductor bundle`
docs/operations/goal-week-4-track-1.md:314:Triage per master brief §10.3 step 5 (≤2 round-trips per artefact):
docs/operations/goal-week-4-track-1.md:321:### DAY 7 — State + manifest sync + W4 Track-1 close
docs/operations/goal-week-4-track-1.md:325:1. **`.agents/current-priorities.md`** — W4 Track 1 close section. List shipped artefacts. Update Open backlog: W4 Track 2 (Bullhorn-dependent agents — Janitor/Scribe) conditional on Bullhorn A+B Accepted; Cash Conductor full live test conditional on accounting/Open Banking commercial signups; Diagnostic live render gated on API keys.
docs/operations/goal-week-4-track-1.md:329:Commit: `state(w4-track-1-close): cluster F verdicts + W4 Track-2 backlog + risk register sync`
docs/operations/goal-week-4-track-1.md:350:| **Master plan citations** | Every claim cites master brief / ULTRAPLAN / ADR / agent.md line | grep diff for citation strings |
docs/operations/goal-week-4-track-1.md:365:| Cluster F returns >2 REJECTED on a single artefact | Founder review per master brief §10.3 step 5; write disagreement doc; defer |
docs/operations/goal-week-4-track-1.md:366:| Cash Conductor bundle integration with `autosend-bridge-telegram` blocked (package not yet built — that's Concierge W10) | cycle.sh degrades to drafts-only mode per agent.md §1 readiness caveat; documented and tested via fixture 01-primary |
docs/operations/goal-week-4-track-1.md:390:- Any reduction in Gate A strictness on the Cash Conductor bundle
docs/operations/goal-week-4-track-1.md:398:Per master brief §10 + §10.3 step 5 hard ceiling + Day-25 Codex-cycle pattern.
docs/operations/goal-week-4-track-1.md:406:Add CLUSTERS[F] to `scripts/run-codex-ratification.sh`. 4 artefacts (3 connectors + Cash Conductor bundle).
docs/operations/goal-week-4-track-1.md:444:W4 TRACK 1 COMPLETE — Cash Conductor MCP CONNECTORS + DIAGNOSTIC LIVE-SMOKE WRAPPER
docs/operations/goal-week-4-track-1.md:452:Cash Conductor bundle:
docs/operations/goal-week-4-track-1.md:487:  ✓ ADR-005 — Cash Conductor pull-forward to W4 substrate
docs/operations/goal-week-4-track-1.md:488:  ✓ master brief §8.2 W4 row — Cash Conductor MCP connectors
docs/operations/goal-week-4-track-1.md:489:  ✓ ULTRAPLAN §8.1 A4 — Cash Conductor spec lines 531-545
docs/operations/goal-week-4-track-1.md:493:W4 Track 2 backlog (unchanged; conditional on Bullhorn A+B Accepted):
docs/operations/goal-week-4-track-1.md:494:  - Bullhorn MCP connector (W4-5 build chain)
docs/operations/goal-week-4-track-1.md:509:  - Approve W4 Track 2 entry condition (Bullhorn A+B Accepted) or pivot to next Track-1 slice (Diagnostic voice classifier microservice)?
docs/operations/goal-week-4-track-1.md:523:| 5 | Cash Conductor bundle integration test surface grows beyond fixture coverage | Medium | Three fixtures targeted at the highest-risk paths (happy / fuzzy-match-ambiguity / token-aging); broader integration coverage deferred to first-pilot-tenant phase |
docs/operations/goal-week-4-track-1.md:524:| 6 | Founder commercial signups delay live testing | Medium | All scaffolds work fixture-first; live testing deferred without blocking the W4 Track-1 close |
docs/operations/goal-week-4-track-1.md:525:| 7 | Goal slippage past 7-day window | Low-medium | Open Banking is the longest step (~5 hours); if it slips, defer to Day-7 polish; ship Xero + QB + Cash Conductor scaffold + smoke wrapper first |
docs/operations/goal-week-4-track-1.md:529:## §12 — Definition of "W4 Track 1 complete"
docs/operations/goal-week-4-track-1.md:539:**Day 7 (2026-06-05) is the soft target. Day 9 (2026-06-07) is the hard cutoff** (W5 Janitor build starts then per master brief §8.2 if Bullhorn A+B has Accepted). If Day 9 hits without completion, escalate to founder review + scope-cut decision.
docs/operations/goal-week-4-track-1.md:543:*End of /goal prompt for W4 Track 1.*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:13:ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:23:(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:25:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:33:Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:45:The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:52:- Authored as a separate W4 ADR (number to be assigned at W4-polish authoring time; this ADR does NOT pre-assign a number) together with the schema supplements that define its payload key + per-tenant config field
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:58:**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:62:## ULTRAPLAN amendment
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:64:`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:72:**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:87:**Why not (c) amend ULTRAPLAN downward permanently?**
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:89:- Permanently removing it from ULTRAPLAN loses the documented quality bar
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:90:- Hybrid preserves the W4-polish path; permanent amendment closes that door
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:93:- v0 implementation does what it says; W4 polish path is documented + scheduled
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:95:- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:113:- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:116:### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Sample rate configurable per tenant via field landing in the future W4-polish vertical-schema supplement (concrete field name + type specified there alongside the Tier 2 writer + sampling-activation work; NOT in v0.3 supplement — v0.3 explicitly defers per its §5 `deferred_to_future_adr` block to avoid speculative schema without a current consumer)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:138:| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:139:| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:140:| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
docs/operations/codex-round-2-remediation-prompt.md:407:Per master brief §10.3 step 5: Round 3 is the LAST automated round.
docs/operations/codex-round-2-remediation-prompt.md:433:     Per master brief §10.3, this is the last automated round. Confirm
docs/operations/codex-round-2-remediation-prompt.md:525:  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (today): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`; Concierge Status flip Proposed → Accepted requires ADR-007 RATIFIED. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
agents/recruitment/concierge/agent.md:7:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:8:**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
agents/recruitment/concierge/agent.md:9:**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
agents/recruitment/concierge/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:40:Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha — see Step 1 polling fallback.
agents/recruitment/concierge/agent.md:77:| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) — respectful, specific, leaves door open |
agents/recruitment/concierge/agent.md:117:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:167:     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
agents/recruitment/concierge/agent.md:218:       — mandatory audit row per master brief §8.1 Change 2 (phase=output;
agents/recruitment/concierge/agent.md:220:   → per ULTRAPLAN A6 line 566 (as amended by ADR-007): the 30-min draft SLA is
agents/recruitment/concierge/agent.md:282:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:291:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:299:Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).
agents/recruitment/concierge/agent.md:302:- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%. (per ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:303:- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`. (per ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:304:- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:349:  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §gotchas (line numbers vary; see live file); demand specificity)
agents/recruitment/concierge/agent.md:361:- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §gotchas (line numbers vary; see live file) explicitly names rejection voice as the hardest case)
agents/recruitment/concierge/agent.md:363:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:376:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:379:| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/concierge/agent.md:386:| Voice classifier microservice live | W4-5 polish | ⏸ |
agents/recruitment/concierge/agent.md:420:### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
agents/recruitment/concierge/agent.md:435:- **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes the documented deviation from ULTRAPLAN A6 line 566 wording. ADR drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` (Day 20 W4 bilateral pass); ratifies via `.codex/ratification/review-architecture-decision.md` skill. Until RATIFIED, agent.md's Gate B framing of the 30-min SLA is documented disposition only.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
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
docs/operations/w4-bilateral-pass-6-agent-md.md:134:## 4. Cash Conductor — `agents/recruitment/cash-conductor/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:146:  - **Codex says:** "Line 380 says Cash Conductor only depends on Concierge `agent.md` being Accepted, but lines 235-253 require Concierge to receive drafts, run the approval bridge, transport sends, and callback; line 244 also cites the unresolved D1 path. Add Founder Decision D1 resolved + autosend bridge/Concierge transport availability as explicit prerequisites, or rewrite §4 to use the existing shared autosend approval helper without Concierge."
docs/operations/w4-bilateral-pass-6-agent-md.md:147:  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
docs/operations/w4-bilateral-pass-6-agent-md.md:175:  - **Cite:** §3 lines 16, 30, 39; cross-ref §8 lines 295-298 + ULTRAPLAN A3 lines 521-523
docs/operations/w4-bilateral-pass-6-agent-md.md:176:  - **Codex says:** "Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly."
docs/operations/w4-bilateral-pass-6-agent-md.md:211:  - **Cite:** §10 lines 417-421; cross-ref ULTRAPLAN A6 line 566 + lines 206-212/276
docs/operations/w4-bilateral-pass-6-agent-md.md:212:  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
docs/operations/w4-bilateral-pass-6-agent-md.md:213:  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
docs/operations/w4-bilateral-pass-6-agent-md.md:214:    - (a) Add Concierge-Gate-A-ADR to §10 Accepted blockers; flip Concierge agent.md → RATIFIED (but Status stays Proposed pending ADR). W4 #3 then writes the ADR + closes the loop.
docs/operations/w4-bilateral-pass-6-agent-md.md:218:### Finding 4. ULTRAPLAN line-citation drift
docs/operations/w4-bilateral-pass-6-agent-md.md:219:  - **Cite:** §3 lines 16, 39, 76, 333, 345; cross-ref ULTRAPLAN A6
docs/operations/w4-bilateral-pass-6-agent-md.md:220:  - **Codex says:** "Lines 16, 39, 76, 333, and 345 cite line 570 for lifecycle/rejection gotchas, but verified ULTRAPLAN has the gotcha text on line 569 and line 570 is blank. Update these citations to ULTRAPLAN A6 line 569."
docs/operations/w4-bilateral-pass-6-agent-md.md:221:  - **Likely:** FIX-IN-PLACE. Find-and-replace `ULTRAPLAN A6 line 570` → `ULTRAPLAN A6 line 569`. Verify count: 5 sites.
docs/operations/w4-bilateral-pass-6-agent-md.md:236:5. **Status semantics** (Sourcing Scout #2) — confirm with founder: "Ratified at Round-N" is not "Accepted"; Accepted requires bundle completion. Likely a one-line clarification in the agent-bundle skill or master brief §8 to prevent this drift in future agents.
docs/operations/w4-bilateral-pass-6-agent-md.md:247:- [ ] SCOPE-EXPAND items moved to W4 backlog with concrete next-action
docs/operations/w4-bilateral-pass-6-agent-md.md:257:- [ ] `.agents/current-priorities.md` updated with W4 Day-20 close
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
docs/operations/goal-option-c-diagnostic-end-to-end.md:68:| §12 conversation opener — LLM-generated, minimal voice gate | Sufficient for v0 demo; full voice classifier in W4 polish |
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:297:| **Master plan citations** | Every architectural decision cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
docs/operations/goal-option-c-diagnostic-end-to-end.md:312:| Real run reveals Gate A V3 voice classifier was actually needed (skipped warning was too lenient) | Surface as W4 polish item; do not block the milestone. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:357:ULTRAPLAN line 755 sets the bar: "Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."
docs/operations/goal-option-c-diagnostic-end-to-end.md:398:Master plan alignment: ULTRAPLAN §8.1 Week-4 milestone hit on Day-13
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:13:ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:18:| 3 | **Bullhorn MCP server build** (auth, read endpoints, write endpoints, webhook subscription) per ULTRAPLAN line 752 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:19:| 4 | **Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint** per ULTRAPLAN line 753 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:42:| W4 Days 21-27: Diagnostic end-to-end | W4 Days 21-27: Diagnostic polish + first-pilot prep + Bullhorn MCP if A+B answered |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:48:2. **The Week-4 milestone is achievable today.** ULTRAPLAN line 755: *"Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."* Option C produces exactly this; the dependencies (LinkedIn + Companies House + scrape) are independent of Bullhorn.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:100:| Codex ratification of bundle | ⏸ W4 | — |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:106:- ULTRAPLAN §8.1 line 753-755 (Week-4 milestone definition)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:107:- ULTRAPLAN §10 Risk #2 row contingency (defer Bullhorn-touching agents)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:119:| LinkedIn deep data via Proxycurl: now or W4? | Day-13 founder pick: Option A (free unauthenticated path) for v0; Proxycurl evaluated W4 polish |
docs/operations/w4-day-20-founder-runbook.md:1:# W4 Day-20 founder runbook — v0.3 migration + bilateral pass
docs/operations/w4-day-20-founder-runbook.md:8:This runbook is the founder-action sequence for the first two W4 priorities.
docs/operations/w4-day-20-founder-runbook.md:27:**Why:** Per master brief §10.5, "every Postgres migration touching tenant
docs/operations/w4-day-20-founder-runbook.md:111:4. Cash Conductor (3 findings) — depends on D1 decision documentation
docs/operations/w4-day-20-founder-runbook.md:113:6. Concierge (4 findings) — depends on Concierge-Gate-A ADR (W4 item #3)
docs/operations/w4-day-20-founder-runbook.md:117:- **FIX-IN-FOLLOW-UP** — defer to a numbered commit later in W4
docs/operations/w4-day-20-founder-runbook.md:131:W4 queue items #3 + #4. Concierge-Gate-A 30-min SLA hybrid ADR is needed
docs/operations/w4-day-20-founder-runbook.md:140:1. **No v0.3 wrapper existed.** W4 queue note flagged this (`(or wrapper for v0.2→v0.3 specifically)`). Wrapper now drafted at `scripts/run-v0.3-migration.sh`.
docs/operations/w4-day-20-founder-runbook.md:141:2. **PII purge v0.3 migration (`v0.2-to-v0.3-pii-purge.sql`) is separate** — gated on Founder Decision D3 + SeedLegals advisor input on retention period. NOT part of W4 item #1. Out of scope this session.
docs/decisions/brain-ui-scope.md:9:**Reading order:** master brief §5.5 (Brain UI build sequence stages) + ADR-002 (parallel-not-shadow + v1.0 brain build wording correction) + `second-brain-design.md` §3.4 closing paragraph (Brain UI v1.0+ scope) first; then this document end-to-end.
docs/decisions/brain-ui-scope.md:15:Per master brief §5.5 (lines 416-424) after ADR-002 Edit 2 applies in the atomic correction commit, the staged Brain UI build is:
docs/decisions/brain-ui-scope.md:19:- **v1.2:** graph view (cytoscape force-directed, master brief §5.3 line 396).
docs/decisions/brain-ui-scope.md:20:- **v2.0:** second-brain-at-scale features (reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views per master brief §5.5).
docs/decisions/brain-ui-scope.md:34:Three features named in master brief §5.5 (post-ADR-002-Edit-2 wording) + `second-brain-design.md` §3.4. Each feature scoped here without implementation commitment.
docs/decisions/brain-ui-scope.md:51:- No mobile-optimised layout (desktop-first per master brief §5.3 line 397 framework choice).
docs/decisions/brain-ui-scope.md:68:- No graph visualisation (text / list format only — graph view is v1.2 per master brief §5.5).
docs/decisions/brain-ui-scope.md:105:- Tight coupling to cortextOS submodule (`packages/harness/cortextos/dashboard/`) — submodule boundary per master brief §3.1 must hold; the `dashboard-ext` integration point is the cortextOS-blessed extension surface, not a fork.
docs/decisions/brain-ui-scope.md:112:- Needs IFOS-owned auth — WorkOS AuthKit per master brief §5.3 line 401 ("Auth: WorkOS AuthKit (per memory: founder already uses this)").
docs/decisions/brain-ui-scope.md:121:| Auth model | cortextOS dashboard auth | WorkOS AuthKit per master brief §5.3 line 401 |
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:154:**No Brain UI tour in v1.0 sales motion.** Brain UI is a forward-feature, not a v1.0 sales asset. The closing demo is the agent outputs landing in the design partner's existing tools — the wedge per master brief §0 paragraph 1. Brain UI joins the sales asset list at v1.1.
docs/decisions/brain-ui-scope.md:168:Per pre-write check: master brief §6 Day 3 line 472 contains **three drifts** bundled into a single-line rewrite.
docs/decisions/brain-ui-scope.md:170:**Current** (master brief §6 Day 3 line 472 verbatim):
docs/decisions/brain-ui-scope.md:220:| Graph visualisation for backlinks panel (cytoscape force-directed) | v1.2 per master brief §5.5 — explicitly v1.2 milestone, not v1.1 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:15:> "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**." (master brief §3.4 line 167)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:19:The Day-1 cortextOS primitive audit (`docs/architecture/cortexos-primitive-status.md` — Primitive 3) surfaced that **none of those four files exist at SHA `c21fbfe`**. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. Reading `kb-setup.sh` revealed the substrate underneath: `mmrag.py` over ChromaDB with Gemini embeddings and 1000-char chunks (`docs/architecture/cortexos-kb-surface-investigation.md` §"What is cortextOS's KB substrate"). That data model is incompatible with the IFOS wiki's entity-document model in master brief §5.2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:27:cortextOS's `bus/kb-*.sh` surface and the `mmrag.py` / ChromaDB / Gemini stack at `packages/harness/cortextos/knowledge-base/` remain **untouched**. IFOS agents do **not** invoke `kb-query`, `kb-ingest`, `kb-collections`, or `kb-setup`. The §3.1 "edit-exception for four `bus/kb-*.sh` shadow points" in the master brief becomes a **dead clause**: there is no shadowing, the exception is never exercised, and §3.1's "never edit `packages/harness/cortextos/*`" stands without qualifier.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:75:**Disposition update 2026-05-20 (Day 8 Codex Round 1):** all three edits landed in the atomic-correction commit **`0e5b2b4`** ("docs: master brief reconciliation — 11 edits batch-applied", Day 7 2026-05-20). Manifest-of-record below — each edit's "where it landed" is `0e5b2b4`.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:81:**Current** (master brief §3.4 line 167-176): "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**. … 1. Vendored copy at `packages/harness/cortextos/bus/kb-*.sh` is left untouched. 2. Our overrides live at `packages/brain/bus-overrides/kb-*.sh`. 3. PM2 `ecosystem.config.js` sets `PATH` so our overrides are picked up first…"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:87:**Current** (master brief §5.5 lines 416-420):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:97:**Current** (master brief §6 Day 4 line 478):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:105:This edit lands on **Day 4 of Week 0 (this week)** as part of the Postgres provisioning task per master brief §6 Day 4, **not** in the brain-ADR atomic commit. ADR-002 authorises the split; Day 4 implements it.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:119:**For cortextOS upstream.** No PR upstreamable from this ADR. cortextOS code is untouched; the submodule pin (`c21fbfe991a0030ea055bd8e2389a0801a424383`) stays. The brain-replacement boundary in master brief §3.1 simply isn't exercised — that's not a bug in cortextOS, it's an IFOS-side decision to use a parallel surface.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:127:- **Future v1.1+ ADR (Brain UI implementation choice)** — Next.js routes extending the cortextOS dashboard per master brief §5.3 vs. standalone — out of scope for Q3.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/operations/founder-manual-playbook-2026-05-31.md:1:# Founder manual playbook — W4 (2026-05-31)
docs/operations/founder-manual-playbook-2026-05-31.md:4:**Window:** today → end-of-W4 (~2026-06-05)
docs/operations/founder-manual-playbook-2026-05-31.md:20:**Why first:** unblocks all v0.3 schema usage (Cash Conductor tables, Janitor dedup config, blocked_recipients, etc.). Without this, every downstream W4 build is just writing code against schema that doesn't exist on the live database.
docs/operations/founder-manual-playbook-2026-05-31.md:84:**What I do on your reply:** mark W4 backlog item #1 closed; flip the deferred-rollback re-ratification note to "next natural touch is now this VPS apply — schedule a cluster E re-run."
docs/operations/founder-manual-playbook-2026-05-31.md:191:**What I do on your reply:** flip ADR-007 Status from "Proposed (...) The ULTRAPLAN amendments below are applied PROVISIONALLY..." → "Accepted (founder-arbitrated 2026-05-31). ULTRAPLAN amendments are permanent." + remove the "reverts if rejected" clause + commit. Concierge §10 Proposed→Accepted blocker satisfied.
docs/operations/founder-manual-playbook-2026-05-31.md:230:written response on A + B unblocks our W4-5 build sprint.
docs/operations/founder-manual-playbook-2026-05-31.md:275:### 6.1 Xero developer account (~15 min) — unblocks live Cash Conductor test
docs/operations/founder-manual-playbook-2026-05-31.md:279:- Sign up → create an app called "IFOS Cash Conductor" → choose **Web App** flavour → set redirect URI to `https://migration-test.ifos.app/oauth/xero/callback` (placeholder; we'll wire properly at W4-5)
docs/operations/founder-manual-playbook-2026-05-31.md:298:- Cost: $39/mo for 5,000 credits (low-volume v1.0 sufficient; scales with usage — Cash Conductor §8 estimates $20-50/day at peak per consultant)
docs/operations/founder-manual-playbook-2026-05-31.md:362:- **(A)** Wait for the priority-1/2/3 confirms before starting the W4 Track-1 /goal (cleaner sequencing — no risk of building against absent infra).
docs/operations/founder-manual-playbook-2026-05-31.md:363:- **(B)** Start the W4 Track-1 /goal now in this session — Day-1 work is substrate verify + `review-mcp-connector.md` Codex skill + Diagnostic live-smoke wrapper (already done ✓). Day-2 onward is the Xero MCP connector scaffold (fixture-first; doesn't need v0.3 migration applied).
docs/operations/founder-manual-playbook-2026-05-31.md:382:| W4 Track-1 /goal | `docs/operations/goal-week-4-track-1.md` |
docs/operations/codex-ratification-execution-plan.md:5:**Source artefacts:** master brief §10 (the loop) + `docs/decisions/2026-05-18-codex-ratification-manifest.md` (the queue) + this plan (the how).
docs/operations/codex-ratification-execution-plan.md:10:## §1 — Why this loop matters (re-statement from master brief §10.1)
docs/operations/codex-ratification-execution-plan.md:78:### Skill shape (per master brief §10.2 last paragraph)
docs/operations/codex-ratification-execution-plan.md:93:## Five-rule pass (master brief §1)
docs/operations/codex-ratification-execution-plan.md:100:## Four-boundary pass (master brief §3)
docs/operations/codex-ratification-execution-plan.md:204:Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:317:Per master brief §10.3 step 5:
docs/operations/codex-ratification-execution-plan.md:338:4. **Spec drift** — Codex reviews an artefact that's based on a now-stale version of the master brief. Disagreement → update the master brief OR the artefact; re-review. Moderately expensive.
docs/operations/codex-ratification-execution-plan.md:340:**Worth tracking for retro:** category mix on first run. If category 1 dominates, the master brief needs sharpening. If category 4 dominates, the atomic-correction discipline is failing.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:427:- **Multi-model ratification (e.g., adding Gemini)** — v1.0 is Claude + Codex per master brief §10. Multi-model is v2.0+ if signal justifies.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:26:This drift surfaced during the Day-1 primitive audit. It has no Day-0 quirk attached and no real-world brittleness — the bus itself ships and is tested (`tests/unit/bus/message.test.ts`, `tests/integration/multi-agent-crons.test.ts`, `tests/e2e/lifecycle.test.ts`). Only the master brief's mechanism description is wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:32:**1. Correct master brief §2.4 row 3.** Replace:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:47:| **B. Reduce to 250ms** | Set `pollInterval: 250` in the IFOS agent template's `config.json`. Re-measure daemon CPU on a 6-agent fleet under load (master brief §6 Day 4 stress-test addition). Keep the existing "complete in seconds" framing | ~0.5 day to add the config + re-baseline; ongoing 4× CPU per FastChecker poll (still negligible — `readdirSync` on a typically-empty inbox dir is sub-millisecond, so 4× sub-ms is still sub-ms). The risk is `bus-signing-key` HMAC verification cost × 4 if inbox traffic spikes | Pipeline floor drops to ~750ms — restores headroom for the sales narrative while leaving CPU comfortable. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:51:1. The honest-signal Rule 5 (master brief §1) makes "rewrite the claim" cheaper than "tune the substrate to fit the claim".
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:58:- Single edit to master brief §2.4 row 3 (the correction itself).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:66:- Day 4 infra stress-test (master brief §6) gains a new sub-task: measure daemon CPU on a synthetic 6-agent fleet at 250ms poll vs 1000ms baseline.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:70:- The "no chokidar" finding propagates to two other places that referenced the old mechanism: `docs/build-brief/00-MASTER-BRIEF.md` §2.4 row 3 + footnote, and the `docs/specs/ULTRAPLAN.md` §3.2 wording. Both edits are part of the same atomic correction.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:71:- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:76:**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
docs/operations/codex-round-2-autonomous-prompt.md:91:recursive ratification per master brief §10.5. Decide whether Claude's 
docs/operations/codex-round-2-autonomous-prompt.md:196:  Disagreement docs (recursive ratification per master brief §10.5):
docs/operations/codex-round-2-autonomous-prompt.md:320:**If SUMMARY.md shows unexpected REJECTED items:** Codex caught something. Read the per-artefact output file. Decide whether to incorporate or counter-argue. Then Round 3 (~limited; ≤2 round-trips per master brief §10.3).
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:33:// EXISTS in upstream — read-only submodule per master brief §3.1 boundary 1
docs/decisions/autosend-approval-bridge-spec.md:242:| A4 | 4h timeout: bridge calls `updateApproval(..., 'denied', 'ifos_timeout')` cleanly | Integration test: write `.pending` marker, advance simulated clock 4h, assert cortextOS `pending/` is empty + `resolved/` has `denied` record |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:261:**Founder decision:** schedule for Week 9 (sequential with master brief) OR insert now (parallel with Diagnostic prep).
docs/decisions/2026-05-31-d1-founder-decision.md:22:| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
docs/decisions/2026-05-31-d1-founder-decision.md:51:3. **Cash Conductor `cycle.sh` Step 10** — same `proposeApproval` call for `xero_reminder_send_customer` rows; identical handling.
docs/decisions/2026-05-31-d1-founder-decision.md:52:4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
docs/decisions/2026-05-31-d1-founder-decision.md:64:- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10 ships the `autosend-bridge-telegram` package."
docs/decisions/2026-05-18-codex-ratification-manifest.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar; actual execution 2026-05-20)
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:153:**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.
docs/decisions/2026-05-18-codex-ratification-manifest.md:157:**Round-4 disagreement protocol** (per master brief §10 + Day-8 pattern):
docs/decisions/2026-05-18-codex-ratification-manifest.md:205:## §2 — Ratification protocol per master brief §10.3
docs/decisions/2026-05-18-codex-ratification-manifest.md:207:Verbatim from master brief §10.3 (post-Edit 7 path correction):
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:245:| **Build `.codex/ratification/*.md` skills** | Week 0 extension period (concurrent with Q1 design-partner work) | 2-3 person-days. 7 skill files per master brief §10.2; each follows the "RATIFIED / REJECTED with numbered issues" output contract. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:247:| **Disagreement artefacts** | If Codex REJECTS or disagrees with any artefact | `docs/decisions/codex-disagreement-<date>.md` per master brief §10.3 step 4. Founder decides on escalations. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:253:**LANDED TODAY at `0e5b2b4`** — `docs: master brief reconciliation — 11 edits batch-applied`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:258:- `docs/specs/ULTRAPLAN.md` (1 edit)
docs/decisions/2026-05-18-codex-ratification-manifest.md:288:| 9 | `brain-ui-scope.md` | Proposed pending v1.1 phase | Likely Codex ratifies as-is post-Edit 8 atomic correction (master brief §6 Day 3 line 472 + §5.5 now consistent). No founder action needed. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:303:3. **What landed today** (atomic-correction commit `0e5b2b4`; master brief fully reconciled).
docs/decisions/sequencing-target.md:6:**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:46:The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
docs/decisions/sequencing-target.md:50:Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
docs/decisions/sequencing-target.md:65:Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:84:**Section 4's recommendation evaluates both orderings** (founder-prompt-Alpha and master-brief-Alpha) against the §1.3 criteria, picks whichever wins on the merits, and explicitly aligns with the master brief by default unless rationale exists to revise it. This document is the "confirm or revise" decision per master brief §6 Day 3 line 471 — both options are on the table.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:142:**Hire-#1 anchor (per Ultraplan §9 line 766 verbatim):** "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)." Cash Conductor's three-accounting-API + Open-Banking integration is the right scope for Hire #1's first sprint per Ultraplan §9 — this places Cash Conductor at W7-8 in the canonical sequence.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
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
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:232:W11:  Cash Conductor (A4)
docs/decisions/sequencing-target.md:236:**Why this ordering:** Front-load risk-de-risking by building Concierge (the most Primitive-heavy agent) early. Cash Conductor's Risk #1 exercise becomes redundant if Concierge already exercises Primitives 1+2+4+5.
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:242:3. **Hire-#1 anchor broken.** Cash Conductor at W11 is 4 weeks after Hire #1's assumed W7 start. Hire #1 again has no first-sprint scope.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:334:- Whether Cash Conductor's 2-week build can compress if Hire #1 onboarding is fast — deferred to Week 7 Cash-Conductor-kickoff check-in.
docs/decisions/sequencing-target.md:335:- Per-agent Codex-ratification timing within each build slot — every `agent.md` ratifies before merge per master brief §10.5; specific ratification cadence emerges from each agent's PR cycle.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:374:4. **If scope-cut activates twice in one v1.0 cycle, escalate to v1.0 kill criterion** — the Day 5 work (master brief §6 Day 5) defines the kill-criterion threshold; sequencing failures count toward that threshold.
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:402:- First production render lands W4 per ADR-003 design §5.2 line "First production render is the Diagnostic agent at Week 4."
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:410:§4.3 Trigger 1 activation point: end of W4 weekly review if Sub-decisions A and B still Proposed.
docs/decisions/sequencing-target.md:414:Diagnostic W3-W4 build window is the first production renderer exercise per ADR-003 design §5.2. The reduction-trigger cascade per `docs/RISK-REGISTER.md` Risk #5 fires:
docs/decisions/sequencing-target.md:417:- W4 Diagnostic first-render-clean → **Medium** (renderer code proven against one production bundle).
docs/decisions/sequencing-target.md:420:No new discrepancy to surface — earlier draft concern about W3-vs-W4 framing resolved per §6.2.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:455:Per §1.5 Spec gap §1-A finding: master brief §6 Day 3 line 471 names the path `.agents/decisions/sequencing-target.md` but the convention established by Days 1-2 is `docs/decisions/`. Same path-convention drift applies to line 472 (Brain UI scope decision; will be flagged in `brain-ui-scope.md` separately if needed).
docs/decisions/sequencing-target.md:457:**Current** (master brief §6 Day 3 line 471 verbatim):
docs/decisions/sequencing-target.md:489:| §1-A | §6.8 + atomic correction commit edit 7 | Path convention `.agents/decisions/` → `docs/decisions/` for master brief §6 Day 3 line 471 (and likely line 472 per brain-ui-scope.md) |
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:494:| W3 vs W4 framing | §6.2 + §6.4 | Build-window-vs-completion-week distinction: Diagnostic build W3-W4, first production render W4. Not a true discrepancy. |
docs/decisions/sequencing-target.md:508:| Day 2 commercial conversations land by start of W4 (Risk #2 reduction triggers) | Founder | Sunday-Monday outreach; resolved by end of W3 | Already tracked from `bullhorn-integration-path.md` §1.3 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/sequencing-target.md:520:| Diagnostic W3 build start (vs W4 first render) | If renderer impl slips past end of W2, Diagnostic build start slips correspondingly |
docs/decisions/ADR-004-renderer-implementation-deviations.md:18:The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
docs/decisions/ADR-004-renderer-implementation-deviations.md:30:**Why the deviation:** `cortextos-ifos` is the upstream CLI shipped from the cortextOS submodule at `/opt/homebrew/bin/cortextos-ifos`. Adding a `render-agent` subcommand to that binary requires modifying source in `packages/harness/cortextos/`, which violates master brief §3.1 boundary 1 (cortextOS submodule read-only). The boundary is non-negotiable per master brief §3.1 + the build-pack discipline that the submodule is a "reference pin, not the runtime."
docs/decisions/ADR-004-renderer-implementation-deviations.md:79:- **Prefix `_shared/` with a dotfile** (`.shared/`) to make the listAgents scan skip it. Rejected — Bash glob conventions + Postgres conventions both treat dot-prefix as "hidden", and we'd lose the discoverable convention that `_shared/` follows IFOS naming rules. Also drifts further from the master brief vocabulary.
docs/decisions/ADR-004-renderer-implementation-deviations.md:80:- **File an upstream issue / PR against cortextOS** to filter out `_shared/` (and other underscore-prefixed names) in `listAgents()`. **Recommended path** — open an issue on the cortextOS repo per master brief §3 boundary 1 ("the submodule is a reference pin, not the runtime; upstream changes go upstream"). Phase 2 ships the deviation as documented; founder + upstream maintainer fix it on their schedule.
docs/decisions/ADR-004-renderer-implementation-deviations.md:93:Current (post-ADR-003 Edit B at master brief §8.3 lines 614-630):
docs/decisions/ADR-004-renderer-implementation-deviations.md:136:> "invoked via `ifos-render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1 + ADR-004 Decision 1; standalone Node binary per `packages/agent-renderer/package.json` `bin`. The `cortextos-ifos render-agent` form named in earlier drafts requires modifying the read-only submodule and was rejected per master brief §3.1 boundary 1)."
docs/decisions/ADR-004-renderer-implementation-deviations.md:148:**For master brief drift.** Edit D + Edit E + Edit F enter the deferred atomic-correction queue (if not landed in this commit). Risk #7 (master-brief-drift-accumulation) is currently closed; reopening it for 3 small text edits is honest but tracked here. Founder decides at ratification time whether to land in this commit or queue for the next atomic correction.
docs/decisions/ADR-004-renderer-implementation-deviations.md:150:**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:17:Three sub-decisions, named in master brief §6 Day 2 line 466 and extended in Ultraplan §11 Day 2 lines 847-849.
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:42:This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
docs/decisions/bullhorn-integration-path.md:48:**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:70:| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
docs/decisions/bullhorn-integration-path.md:74:The Sunday design-partner conversation 2 is the most time-sensitive: it can flip the entire premise of Sub-decisions A and C. Founder cadence per master brief §6 Day 2 (line 467) and §11.2 line 791 ("Day 2 — Tuesday — Bullhorn integration path... — Design-partner conversation 2") puts this as a parallel-to-Claude-Code track.
docs/decisions/bullhorn-integration-path.md:91:- **Day 7 review (master brief §6 Day 7 Sunday):**
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:226:**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:239:This forecloses one option that the master brief §6 Day 2 line 466 pre-statement contemplated — "service-account for dev." The closest substitute is one of:
docs/decisions/bullhorn-integration-path.md:256:**Recommendation:** authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement "browser dance for production"). For IFOS dev: authorization-code grant against an IFOS-owned Bullhorn dev tenant; service-account / client_credentials grant deferred (because Bullhorn doesn't document support for it per §3.2).
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:375:3. First design partner ATS confirmed as Bullhorn (Sunday design-partner conversation 2 per master brief §6 Day 2 line 467).
docs/decisions/bullhorn-integration-path.md:381:Recommendation: authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement); authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (client_credentials grant **foreclosed** by Bullhorn OAuth docs per §3.2 — Bullhorn does not support client_credentials grant for tenant-scoped data). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:442:§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.
docs/decisions/bullhorn-integration-path.md:444:**Current** (master brief §6 Day 2 line 466 verbatim):
docs/decisions/bullhorn-integration-path.md:452:Joins the atomic correction commit at end of Week 0 / early Week 1. Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/_supplementary/PRD-autonomous-agent.md:1143:  "overall_score": 8.2,
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/build-brief/00-MASTER-BRIEF.md:12:3. `docs/specs/ULTRAPLAN.md` — how, in what order
docs/build-brief/00-MASTER-BRIEF.md:15:If anything in `docs/build-pack/` conflicts with this brief, **this brief wins**. The build pack stays in-tree as historical record; the master brief is operative.
docs/build-brief/00-MASTER-BRIEF.md:238:git commit -m "chore: reconcile scaffold against master brief; vendor cortextos@${HARNESS_SHA:0:7}"
docs/build-brief/00-MASTER-BRIEF.md:252:cp "$SRCDIR/intelforce-os-ultraplan.md"                        docs/specs/ULTRAPLAN.md
docs/build-brief/00-MASTER-BRIEF.md:260:git commit -m "docs: import authoritative specs + master brief"
docs/build-brief/00-MASTER-BRIEF.md:591:### 8.2 The build order — v1.0 only
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:852:Drop this verbatim at `~/code/CortexOS/CLAUDE.md`. It supersedes the existing CLAUDE.md (which keeps the path table and red lines, but defers all build-pack references to this master brief).
docs/build-brief/00-MASTER-BRIEF.md:867:start. The build pack at `docs/_archive-build-pack/` is historical; the master brief wins on
docs/build-brief/00-MASTER-BRIEF.md:907:merge. See master brief §10.
docs/build-brief/00-MASTER-BRIEF.md:910:1. Read this file, then master brief §1, §3, §6, §8, §10
docs/build-brief/00-MASTER-BRIEF.md:922:1. Check the master brief §-references first
docs/build-brief/00-MASTER-BRIEF.md:931:- Don't add features without a corresponding slice in the master brief
docs/build-brief/00-MASTER-BRIEF.md:933:- Don't relitigate the master brief without writing the disagreement to `docs/decisions/`
docs/build-brief/00-MASTER-BRIEF.md:948:> Read `CLAUDE.md`, then `docs/build-brief/00-MASTER-BRIEF.md` in full. Then read `docs/specs/PRODUCT-SPEC.md` §0–§4 and §10 (the single-sentence list), and `docs/specs/ULTRAPLAN.md` §1, §3, §4, §9, §11. Skim `docs/architecture/PATTERN-REFERENCE.md`.
docs/build-brief/00-MASTER-BRIEF.md:998:*End of master brief. Drop at `docs/build-brief/00-MASTER-BRIEF.md`. Re-read §1, §3, §6, and §10 weekly.*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** **Accepted (founder-arbitrated 2026-05-31).** Codex `review-architecture-decision` skill RATIFIED this ADR at Round 3 of the cluster-E run (2026-05-31) after R1+R2 mechanical fixes (commits `ca66431` + `9b2e10a`). The ULTRAPLAN §8.1 A6 line 566 + line 567 amendments are now **permanent** (no longer provisional). The original Codex R3 Finding 3 (Concierge agent.md reframes 30-min SLA as Gate B without an authoritative ADR) is structurally closed by this Accept.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:13:ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:28:> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:30:Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:36:The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:44:The 30-minute SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Treating it as Gate B at the 90% threshold:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:55:**Alternative A — Keep ULTRAPLAN A6 line 566 verbatim: 30-min SLA is per-draft Gate A hard-fail.** Rejected because Bullhorn webhook coverage is patchy per the ULTRAPLAN A6 gotcha (the same source spec acknowledging the polling-fallback requirement); per-draft hard-fail would drop legitimate drafts whose Concierge generation IS within 30 min of detection but whose upstream detection latency exceeded 30 min. The product harm: candidate experiences "ghosted by recruiter" — exactly the pattern Concierge was designed to prevent.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:57:**Alternative B — Remove the 30-minute SLA entirely.** Rejected because the SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Removing it would let drafts slip indefinitely with no quality signal — the "no candidate ghosted" goal becomes unmeasurable.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:67:**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:83:**ULTRAPLAN §8.1 A6 line 566 is amended in-band (Accepted by founder 2026-05-31)** following the ADR-006 precedent, which made the same kind of in-band amendment at line 496. There is no separate master-brief clause authorizing in-band spec amendments — master brief §10.3 step 4 only covers incorporating Codex feedback or writing a disagreement doc; the authority for the amendment is this ADR itself, now Accepted:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:108:4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:112:### In-band ULTRAPLAN amendment (Accepted with this ADR 2026-05-31; ADR-006 precedent)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:114:ULTRAPLAN §8.1 A6 line 566 amended in the same commit as this ADR. Pre-amendment / post-amendment text is captured in this ADR's body. The amendment also updated line 567 Gate B target to include the new ≥90% 30-min SLA hit rate threshold (per ADR-007). See commit history for the diff.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:120:> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:137:- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:145:**Status:** **Accepted (founder-arbitrated 2026-05-31).** Codex RATIFIED at Round 3 of the cluster-E 2026-05-31 session; founder Accept stamp completes the §10.5 cycle. ULTRAPLAN amendments permanent.
docs/_supplementary/build-plan-original.md:814:- Last 7 days of data from: Stripe, GA4, Meta Ads, Google Ads, HubSpot, CRM, LinkedIn Ads, Shopify (if retail client), Klaviyo, etc.
docs/_supplementary/build-plan-original.md:821:- **GA4 MCP** — traffic + conversion
docs/_supplementary/build-plan-original.md:1261:| GA4 | No official | Build your own wrapper |
docs/_supplementary/README.md:5:- `docs/build-brief/00-MASTER-BRIEF.md` — the master brief Claude Code reads first
docs/_supplementary/README.md:7:- `docs/specs/ULTRAPLAN.md` — how, in what order
docs/decisions/autosend-safety-policy.md:21:**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:188:      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:585:4. **Cyber insurance.** IFOS Limited needs cyber insurance covering policy miscategorisation events. Quote requests pending; budget impact on v1.0 founder-set cost budget (Day-4 runbook §1.4 — £20/mo for infrastructure at single-tenant pilot scale; master brief does not specify a numeric cost target).
docs/decisions/autosend-safety-policy.md:620:- **Q3 (lookup latency / 71-hour cache lifetime):** ACCEPTED for v1.0. Policy hot-reload deliberately deferred to v1.1+; v1.0 accepts up-to-71-hour delay on policy changes taking effect at agent layer. Material policy changes must wait for next 71-hour boundary (cortextOS context rotation per master brief §2.4 primitive 2) or trigger deliberate cortextOS PTY restart. Operational footgun documented in §4.
docs/decisions/autosend-safety-policy.md:648:**For atomic-correction manifest.** Edit 10 adds the path drift correction (master brief §6 Day 5 line 484-485 → docs/decisions/). Manifest grows from 9 to 10.
docs/decisions/autosend-safety-policy.md:660:**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 484-485 paths to live at `docs/decisions/`.
docs/_supplementary/technical-strategy-v2.md:259:0 7 * * 5 cd /tenant && claude -p "Run the Reporting Engine. Pull last 7 days from Stripe, GA4, Meta Ads, and HubSpot. Produce the weekly briefing. Save to /outbox/reports/. Post the summary to #leadership in Slack." --output-format json >> /logs/reporting-$(date +\%Y\%m\%d).log 2>&1
docs/_supplementary/strategic-plan.md:92:8. **Reporting Engine** — pulls from Stripe, GA4, Meta Ads, CRM. Delivers weekly briefing in-Slack + PDF
docs/_supplementary/strategic-plan.md:174:│    Notion, GA4, Meta Ads, Stripe, Calendly, Dentally        │
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
docs/_supplementary/strategic-plan.md:394:### 8.2 Channels, ranked by realistic ROI for you
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:571:### 8.2 v1.1 agents (seven, in build order)
docs/specs/ULTRAPLAN.md:601:#### A9. Real-time Cash Conductor reframe (2 weeks)
docs/specs/ULTRAPLAN.md:603:Already specified in §8.1 A4 as v1.0. The v1.1 work is the reframe of pitch and any latency optimisations needed once we have 3+ tenants in production. Not a new build, ~3 days of polish.
docs/specs/ULTRAPLAN.md:688:| Cash Conductor | ✓ | | | ✓ | | | | | | ✓ | Open Banking |
docs/specs/ULTRAPLAN.md:713:7. **Xero / QuickBooks / Sage** — 4 of 18 (one per tenant typically). Cash Conductor's blocker.
docs/specs/ULTRAPLAN.md:764:### Weeks 7–8 — Cash Conductor + Hire #1 onboards
docs/specs/ULTRAPLAN.md:767:- Week 8: Cash Conductor agent; chase-cadence config; tenant-level baseline DSO captured
docs/specs/ULTRAPLAN.md:769:Milestone: Cash Conductor running in shadow mode against first pilot's accounting data.
docs/specs/ULTRAPLAN.md:800:5. Cash Conductor's escalation-tier-3 (bad debt write-off draft) — manual until 6 months in
docs/specs/ULTRAPLAN.md:821:| 5 | Open Banking integration takes more than 1 week | Medium | Medium | End of week 7 status not "Xero + first bank connected" | Cash Conductor ships with manual reconciliation in v1.0; webhook-driven mode at v1.1 |
docs/specs/PRODUCT-SPEC.md:73:#### R2. Real-Time Cash Conductor — the FD's evenings back
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:345:- Cash Conductor runs against historical invoices — produces the DSO baseline.
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:401:| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:474:- Cash Conductor (real-time mode)
docs/specs/PRODUCT-SPEC.md:523:2. **Real-Time Cash Conductor** — "DSO drops by 15+ days, working capital unlocked."
docs/decisions/v1.0-kill-criterion.md:37:**v1.0 commitments to existing pilots are honoured under original scope.** New v1.0 contracts under rescoped terms. The master brief and Ultraplan are amended by atomic-correction commit; Codex ratifies before v1.0 resumption.
docs/decisions/v1.0-kill-criterion.md:47:**Threshold:** No design partner has confirmed pilot intent (signed LOI or equivalent written commitment to pilot in Q3 2026 per master brief §6 Day 7 question 1) by end of Week 2.
docs/decisions/v1.0-kill-criterion.md:53:**Source:** Risk #3 in `docs/RISK-REGISTER.md` (escalating status); Day-5 Risk #3 update reflects "zero design partners in pipeline" as of this commit; master brief §6 Day 7 question 1.
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:89:**Recovery path:** PIVOT is structural; resumption is via rescoped v1.0 under new ATS assumption. Pivoted v1.0 continues with adjusted master brief / Ultraplan; atomic-correction commit lands the rescope.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:134:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:156:**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
docs/decisions/v1.0-kill-criterion.md:164:**Source:** Master brief §6 Day 5 line 486 — canonical example trigger from master brief.
docs/decisions/v1.0-kill-criterion.md:182:**Unfreeze criterion:** Either (1) cortextOS upstream PR lands the fix (per master brief §3.1 cross-vertical primitive process), OR (2) IFOS vendor-patches via `packages/harness-patches/` per master brief §3.1 fallback path. Unfreeze after **2 consecutive incident-free weeks** (matched to tightened threshold).
docs/decisions/v1.0-kill-criterion.md:306:1. Rescope plan replaces affected slices of master brief and Ultraplan. New atomic-correction commit lands the rescope edits (separate from the existing 10-edit atomic-correction manifest — pivot is a wholly new manifest event).
docs/decisions/v1.0-kill-criterion.md:322:4. v1.1 — if launched — is a wholly new initiative under different premises. Not a continuation of v1.0. Has its own master brief, Ultraplan, kill criterion.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:338:- The vertical assumption: UK recruitment agencies (per master brief §0 + Product Spec)
docs/decisions/v1.0-kill-criterion.md:345:v1.1 begins when v1.0 is operationally stable with ≥1 pilot operational. v1.1 scope per master brief §9 build sequence + Product Spec:
docs/decisions/v1.0-kill-criterion.md:350:- Adds AgentMail integration (Inbound Triage only) per master brief §3.2
docs/decisions/v1.0-kill-criterion.md:399:**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 486 path to live at `docs/decisions/`.
docs/_supplementary/planning-phase-brief.md:38:| **CC9** | **Custom MCP Servers (6 of them)** — DocuSign, GA4, Meta Ads, Companies House, Prospeo, Dentally | Python (FastMCP) or TypeScript | §3.8 (six of the 15 integration specs) |
docs/_supplementary/planning-phase-brief.md:178:- Session 25: Integration Specs Batch 2 — Stripe, GA4, Meta Ads, Cal.com (3.8)
docs/specs/_archive-build-handoff.md:163:│   ├── ULTRAPLAN.md                                   ← copy of intelforce-os-ultraplan.md
docs/specs/_archive-build-handoff.md:185:See `docs/ULTRAPLAN.md` §9 for the 14-week v1.0 sprint plan.
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/_archive-build-handoff.md:467:> Read `CLAUDE.md`, then `docs/ULTRAPLAN.md` §1, §3, §4, §9, §11. Confirm you understand the five rules and the boundary with CortexOS. Then look at `.agents/current-priorities.md` and tell me what we're doing today.
docs/runbooks/day-4-provisioning.md:15:This runbook is the **reviewable plan** for Day 4 of Week 0 per master brief §6 Day 4. It is **not executed by writing it.** Execution happens in a separate session against a real VPS after this document is reviewed and ratified.
docs/runbooks/day-4-provisioning.md:30:- **Rule 5 (Honest signal before optimistic projection):** §0 surfaces every drift between the master brief and reality (notably: Hetzner has no UK data centre).
docs/runbooks/day-4-provisioning.md:38:### §0.1 — DRIFT: Hetzner has no UK data centre (master brief §6 Day 4 line 477)
docs/runbooks/day-4-provisioning.md:40:**Master brief asserts (line 477 verbatim):** "Hetzner UK VPS provisioned, LUKS-encrypted volume mounted at `/vault/`". This is the single Hetzner reference in the master brief. §10 (Codex ratification loop) does not mention Hetzner or cost targets — earlier drafts of this runbook cited "master brief §10.4" for cost target and Hetzner location; both fabricated. Corrected in citation-audit pass 2026-05-18.
docs/runbooks/day-4-provisioning.md:51:| £20/mo target (Day-4 runbook §1.4 founder-set budget; not specified in master brief) | ✅ well under | ✅ within budget |
docs/runbooks/day-4-provisioning.md:56:**Master-brief correction:** add to the atomic-correction commit manifest (currently 8 edits at end of Week 0). Proposed Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; flag UK-residency as a commercial-conversation gate. (Earlier drafts also referenced "§10.4" as a separate location-naming surface; verified that §10.4 — "What never goes through ratification" — contains no Hetzner or cost-target content. §10.4 component dropped.)
docs/runbooks/day-4-provisioning.md:58:### §0.2 — DRIFT: master brief §6 Day 4 table list says `entity_graph`, ADR-002 Edit 3 split this to `entities` + `entity_links`
docs/runbooks/day-4-provisioning.md:64:**This runbook follows the corrected list.** The atomic correction commit manifest covers the master brief §6 wording.
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/runbooks/day-4-provisioning.md:171:| Instance type | CX22 (2 vCPU, 4 GB RAM, 40 GB NVMe) | Fits v1.0 pilot scale per founder-set budget in this section §1.4; master brief does not specify a numeric cost target |
docs/runbooks/day-4-provisioning.md:178:Estimated monthly cost: ~€5/mo VPS + ~€2.40/mo (50 GB volume at €0.0476/GB/mo) ≈ €7.40/mo ≈ £6.40/mo. Well under the £20/mo founder-set budget for v1.0 pilot scale (this section §1.4; master brief does not specify a numeric cost target).
docs/runbooks/day-4-provisioning.md:766:-- Note: NO UPDATE/DELETE grant. Decision log is append-only per master brief §5.7.
docs/runbooks/day-4-provisioning.md:768:-- tenant_eval_sets (per master brief §6 Day 4 line 478; v1.0 placeholder)
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1090:The vault per ADR-002 + master brief §3.3 is markdown, git-backed. Initial baseline:
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1187:- Add Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; document UK-residency as commercial-conversation gate. (§10.4 reference dropped per 2026-05-18 citation audit; §10.4 is Codex exclusion list, not a Hetzner or cost-target section.)
docs/runbooks/day-4-provisioning.md:1212:3. **§2 location — NBG1 substituted for FSN1:** FSN1 unavailable at provisioning time. Substituted Nuremberg (NBG1) — same Hetzner eu-central zone, identical Schrems II EU jurisdiction (German court orders only), latency to UK ~25-30ms vs FSN1 ~20-25ms (functionally equivalent). **Triggers §11.4 master-brief Edit 9:** master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations". (Earlier drafts of Edit 9 also referenced master brief §10.4; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list, not a Hetzner or cost-target section. §10.4 component dropped.)
docs/_supplementary/execution-plan.md:291:  - *Prompt per integration:* "Write the {Integration Name} Integration Specification: the MCP server choice (fork X / build from Y spec / official), auth setup (OAuth flow or API key), the scopes/permissions required and why, the specific operations used by agents (read leads, write deals, fetch transcript, etc.), fallback behaviour on failure, test checklist, rate limit handling. Priority 1 integrations: Fathom, HubSpot, Gmail, Slack, Notion, DocuSign. Priority 2: Companies House, Prospeo, Kaspr, Stripe, GA4, Meta Ads, Cal.com, Loom, Google Drive."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar position; actual execution 2026-05-20)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:12:From master brief §6 Day 7 lines 494-501 verbatim:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:43:- **Primitive 1 (Persistent PTY via PM2):** functional per Day-1 audit `docs/architecture/cortexos-primitive-status.md` — "shipped but flaky" per master brief §12 Risk #1. Day-1 audit found the substrate is operational for development workloads. Quirks 2-3 + 2026-04-22 restart-storm evidence document occasional instability under load, not broken.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:45:- **Primitive 5 (Telegram + iOS approval surface):** confirmed shipped per `cortexos-primitive-status.md` audit. Two-poller mechanism (`agent-manager.ts:478-575`, `maybeStartActivityChannelPoller()`) integrates with primitive 4 approval gates. Per master brief §12 Risk #1 framing: "Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:61:- **"Cleared the auth path" interpretation:** strict — "cleared" means the technical and commercial gates have both passed. Technical path documented (auth-code-against-IFOS-dev-tenant; `client_credentials` foreclosed per master brief §6 Day 2 atomic-correction Edit 6 verified at `0e5b2b4`). Commercial gates not passed. Q3 = NO.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:71:- **Risk #5 (renderer-not-built)** in `docs/RISK-REGISTER.md` reduced from Blocking → High on Day 1 evening when ADR-003 + design doc Accepted. Three-stage ladder to Medium (W4 first Diagnostic render) → Low (W13 all 5 v1.0 bundles rendered).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:78:- **8 entities per master brief §6 Day 6 line 490:** `candidate`, `contractor`, `client`, `contact`, `brief` (with `role` alias), `placement`, `opportunity`, `timesheet`.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:100:**Week 0 EXTENDS per master brief §6 line 502.**
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:113:2. **`.codex/ratification/*.md` skills** — master brief §10.2 Day-1 task deferred during Days 0-6; surfaced as gap during Day-7 grounding. Build during extension period. 7 skill files (SKILL.md + 6 review-{type}.md per master brief §10.2). Estimated 2-3 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:133:- If re-run produces 4 of 5 YES (Q3 still NO because Bullhorn commercial conversations haven't completed), founder may accept Q3 as risk-noted and declare Week 0 closed with Week 1 starting under that accepted risk. This is a founder-discretion call, not automatic from the master brief test.
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:30:No edit to the agent.md or validate.sh. R17 dispositions cover the other 4 findings; this disagreement is recorded per master brief §10.3 step 4 ("Claude Code reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)").
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:26:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:34:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:42:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:78:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:94:**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.
docs/runbooks/operational-hygiene-protocol.md:27:- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
docs/runbooks/operational-hygiene-protocol.md:231:**Day-6 lesson (§7 below):** 15 fabricated "master brief §10.4" references propagated across 5 files. The root cause: Day-4 runbook drafting invented a citation that didn't exist, and subsequent artefacts cited the Day-4 runbook citation without re-verifying against master brief.
docs/runbooks/operational-hygiene-protocol.md:234:- When citing master brief, verify against master brief — never against an intermediate artefact's citation of master brief
docs/runbooks/operational-hygiene-protocol.md:262:### §7.1 — Finding: master brief §10.4 fabrication
docs/runbooks/operational-hygiene-protocol.md:264:**Scope:** 15 references to "master brief §10.4" across 5 files, claiming §10.4 contains either (a) a Hetzner UK / FSN1 location reference or (b) a £20/mo cost target.
docs/runbooks/operational-hygiene-protocol.md:266:**Verified ground truth:** master brief §10.4 is "What never goes through ratification" — a 5-bullet list of Codex exclusions (comment-only changes, test fixture additions, documentation typos, build/deps version bumps, anything inside `.agents/`). It contains no Hetzner reference and no cost-target reference.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:274:| `docs/runbooks/day-4-provisioning.md` | 8 | "+§10.4" dropped from Edit 9 scope (was about Hetzner UK); "§10.4 cost target" replaced with "Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target)" |
docs/runbooks/operational-hygiene-protocol.md:296:- `master brief §3.2 line 155` (canonical vocabulary "candidate, placement, brief") — ✅ verified line 155 matches
docs/runbooks/operational-hygiene-protocol.md:297:- `master brief §5.1 lines 325-329` (vault directory structure) — ✅ verified
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/runbooks/operational-hygiene-protocol.md:301:- `docs/specs/ULTRAPLAN.md` — ✅ verified exists (60KB; ratified canonical doc)
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:23:Per design §5.1: the cortextOS `cortextos-ifos add-agent` command is **unchanged**. IFOS does not use it for IFOS-owned agents. The renderer is a **new** command at `packages/agent-renderer/`, invoked via `ifos-render-agent <agent-name> --tenant <slug>` (standalone Node binary per `package.json` `bin`; **errata via ADR-004 Decision 1** — earlier drafts named this `cortextos-ifos render-agent` which would have required modifying the read-only submodule per master brief §3.1 boundary 1).
docs/decisions/ADR-003-agent-bundle-renderer.md:37:Three alternatives rejected per design §3.1: `packages/brain/agent-cli/` (wrong cohesion — brain is wiki, renderer is not a wiki concern); `scripts/render-agent.sh` (JSON Schema validation + YAML parsing harder in shell); new top-level directory (loses master brief §4.1 line 195-204 `packages/` convention).
docs/decisions/ADR-003-agent-bundle-renderer.md:39:**Invocation mode** per design §3.2: manual developer invocation. Day-1 cadence (founder + Claude Code), per-tenant scope explicit, hand-off boundary clean. Three alternatives rejected per design §3.2: pre-push hook (wrong filesystem — tenant vault on Hetzner UK VPS, hook on dev laptop), CI on merge (same reachability problem), daemon auto-watcher (wrong coupling — daemon is read-only on submodule per master brief §3.1).
docs/decisions/ADR-003-agent-bundle-renderer.md:60:Two alternatives rejected per design §3.4: merge-with-conflict-markers (premature complexity — master brief §1 Rule 1 "output before architecture" favours simple); refuse-if-exists (friction without benefit — Decision 1's marker-file check handles the actual risk).
docs/decisions/ADR-003-agent-bundle-renderer.md:74:**Current** (master brief §4.1 lines 195-204):
docs/decisions/ADR-003-agent-bundle-renderer.md:94:Lands in this ADR's commit. Edit A is the minimum required to make `packages/agent-renderer/` a canonical IFOS package per master brief §4.1; Week-1 renderer implementation depends on the path existing.
docs/decisions/ADR-003-agent-bundle-renderer.md:98:**Current** (master brief §8.3 lines 614-630):
docs/decisions/ADR-003-agent-bundle-renderer.md:133:**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:151:**For the master brief atomic correction commit.** Edit C (the §8 footnote) joins ADR-001 + ADR-002 edits in the deferred single commit at end of Week 0 / early Week 1. Edits A and B land in this batch's commit because (a) Edit A is needed live before Week-1 renderer implementation can scaffold the package path, (b) Edit B is a small wording add to a code block, (c) neither is substantive enough to warrant the atomic-correction overhead.
docs/decisions/ADR-003-agent-bundle-renderer.md:163:1. Edits A and B applied to master brief §4.1 and §8.3 in this batch's commit.
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:31:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:39:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:47:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:59:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:87:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:101:**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-06-01.md:111:**Generation:** LLM-driven (Claude API + evidence context). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0 scaffold; W4-5 polish wires real classifier.
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:31:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:39:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:47:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:59:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:87:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:101:**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-31.md:111:**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:26:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:34:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:42:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:78:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:94:**v0 limitation:** voice classifier ≥ 0.75 gate (per agent.md §5 V3) skipped at v0; opener is deterministic anchor-based composition. Wire LLM + per-tenant voice classifier at W4 polish.

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/quickbooks/tests/capabilities.test.ts | sed -n '70,150p' && nl -ba packages/mcp-connectors/quickbooks/tests/rate-limit.test.ts | sed -n '1,60p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    70	afterEach(async () => {
    71	  await fs.unlink(token_file).catch(() => undefined);
    72	  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
    73	});
    74	
    75	describe("quickbooks capabilities — invoices", () => {
    76	  it("listOpenInvoices: returns parsed array from fixture", async () => {
    77	    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    78	    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    79	    const invoices = await listOpenInvoices(client, { cache, no_cache: true });
    80	    expect(invoices.length).toBe(2);
    81	    expect(invoices[0]?.Id).toBe("1001");
    82	    expect(invoices[0]?.Balance).toBe(1500);
    83	    expect(invoices[1]?.CustomerRef.name).toBe("Beta Search Partners");
    84	  });
    85	
    86	  it("getInvoice: returns single invoice when present (single-entity endpoint shape)", async () => {
    87	    const fakeFetch: typeof fetch = async () =>
    88	      makeOkResponse({ Invoice: INVOICES_PAGE_1.QueryResponse.Invoice[0] });
    89	    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    90	    const inv = await getInvoice(client, "1001", { cache, no_cache: true });
    91	    expect(inv).not.toBeNull();
    92	    expect(inv?.DocNumber).toBe("INV-1001");
    93	  });
    94	
    95	  it("getInvoice: 404 surfaces as QbNotFoundError", async () => {
    96	    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    97	    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    98	    await expect(
    99	      getInvoice(client, "99999", { cache, no_cache: true }),
   100	    ).rejects.toBeInstanceOf(QbNotFoundError);
   101	  });
   102	});
   103	
   104	describe("quickbooks capabilities — payments", () => {
   105	  it("listPayments: returns parsed array from fixture", async () => {
   106	    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENTS_RECENT);
   107	    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
   108	    const payments = await listPayments(client, { cache, no_cache: true });
   109	    expect(payments.length).toBe(1);
   110	    expect(payments[0]?.TotalAmt).toBe(2000);
   111	    expect(payments[0]?.Line[0]?.LinkedTxn[0]?.TxnId).toBe("1002");
   112	  });
   113	
   114	  it("writePaymentReceived: success path returns created payment", async () => {
   115	    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENT_WRITE_OK);
   116	    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
   117	    const payload: QbPaymentWriteRequest = {
   118	      CustomerRef: { value: "200" },
   119	      TotalAmt: 1500.0,
   120	      TxnDate: "2026-05-22",
   121	      PaymentRefNum: "BACS-2026-05-22-002",
   122	      Line: [
   123	        {
   124	          Amount: 1500.0,
   125	          LinkedTxn: [{ TxnId: "1001", TxnType: "Invoice" }],
   126	        },
   127	      ],
   128	    };
   129	    const created = await writePaymentReceived(client, payload);
   130	    expect(created.Id).toBe("p-502");
   131	    expect(created.TotalAmt).toBe(1500);
   132	  });
   133	
   134	  it("writePaymentReceived: 400 surfaces as QbValidationError (no retry)", async () => {
   135	    let calls = 0;
   136	    const fakeFetch: typeof fetch = async () => {
   137	      calls += 1;
   138	      return new Response("Invoice Id does not exist", { status: 400 });
   139	    };
   140	    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
   141	    const payload: QbPaymentWriteRequest = {
   142	      CustomerRef: { value: "0" },
   143	      TotalAmt: 100.0,
   144	      Line: [{ Amount: 100.0, LinkedTxn: [{ TxnId: "0", TxnType: "Invoice" }] }],
   145	    };
   146	    await expect(writePaymentReceived(client, payload)).rejects.toBeInstanceOf(
   147	      QbValidationError,
   148	    );
   149	    expect(calls).toBe(1); // write was NOT retried
   150	  });
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

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,610p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   560	```
   561	
   562	**The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly.** The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The `cortextos-ifos add-agent` command is **NOT** the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want.
   563	
   564	### 8.1 The three v2 changes (Ultraplan §4.2)
   565	
   566	**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
   567	
   568	**Change 2 — Decision logging is enforced.** Three required calls per agent run:
   569	
   570	```bash
   571	hh_decision_trigger   # at start; logs trigger
   572	hh_decision_output    # on output; logs the artefact
   573	hh_decision_action    # when human acts; logs the action
   574	```
   575	
   576	`validate.sh` hard-fails on missing calls. This is what enables the v2.0 LoRA pipeline — no decision log, no SFT corpus, no Scale-tier moat.
   577	
   578	**Change 3 — Escalation codes expand to recruitment vocabulary.** ~20–30 codes. Examples:
   579	
   580	- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
   581	- `ESC_BULLHORN_AUTH` — OAuth token expired/revoked
   582	- `ESC_DUPLICATE_DETECTED` — high-confidence dedup needs human review
   583	- `ESC_JSL_RED_FLAG` — Supply Chain Auditor detected red flag
   584	- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
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

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '520,538p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   520	- **CortexOS primitives required:** None per call (stateless between calls)
   521	- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
   522	- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
   523	- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
   524	- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
   525	- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
   526	- **Build complexity:** **M** (1 week) — the structured field mapping is per-firm config, not code
   527	- **Gotchas:** Tacit-note extraction is the hard part. Start with a small taxonomy (5–10 tacit-note types) and expand. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   528	
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

exec
/bin/zsh -lc "nl -ba .codex/ratification/review-mcp-connector.md | sed -n '1,90p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Codex ratification skill — review-mcp-connector
     2	
     3	Apply this skill on top of `.codex/ratification/SKILL.md` (five rules + four boundaries + honest-signal checks; bias toward REJECT) when reviewing a TypeScript MCP connector package under `packages/mcp-connectors/<name>/`.
     4	
     5	An MCP connector is a self-contained TypeScript workspace package that wraps a single upstream provider (Companies House, Xero, Bullhorn, etc.) and exposes capabilities consumed by `agents/*/cycle.sh`. Reference implementation: `packages/mcp-connectors/companies-house/` (Day-13 RATIFIED). Every new connector mirrors that pattern.
     6	
     7	This skill ADDS 7 checks on top of `SKILL.md`. Any one failing = REJECTED.
     8	
     9	## §1 — Capabilities surface
    10	
    11	Every capability declared in the connector's `tools.yaml` (or per-agent `tools.yaml` referencing this connector) MUST have a corresponding TypeScript function exported from the package's `src/index.ts`. Reverse also: every exported public function intended as a capability MUST appear in the README's "Capabilities" table.
    12	
    13	**Verify by:**
    14	1. Open `src/index.ts`; list exported functions.
    15	2. Open `README.md`; list the capabilities table.
    16	3. Grep `agents/*/tools.yaml` for the connector name; list capabilities referenced.
    17	4. The three sets MUST be identical (set-equal). Missing on either side = REJECT.
    18	
    19	Pre-build connector exception: if the connector is W4-W7 scaffold (no agent yet), check #3 may be empty; checks #1 + #2 must still match.
    20	
    21	## §2 — OAuth refresh idempotency
    22	
    23	Connectors that handle OAuth (Xero / QuickBooks / Bullhorn / TrueLayer / Plaid / Microsoft Graph / Gmail) MUST:
    24	
    25	1. Have an `oauth_refresh` capability (or equivalent) that can be safely called concurrently. Concurrent calls converge on a single token rotation — no torn `_secrets.env` writes.
    26	2. Use atomic file replacement on token updates (write to `.tmp` + `rename`; never partial-write to the live `_secrets.env`).
    27	3. Have at least one vitest verifying concurrent-refresh safety (e.g. `Promise.all([refresh(), refresh(), refresh()])` produces one rotated token, not three torn files).
    28	
    29	REJECT if any of those are missing or if `_secrets.env` is opened with `fs.writeFile` mid-flow without a rename guard.
    30	
    31	## §3 — Rate-limit budget declared
    32	
    33	README MUST cite:
    34	1. The upstream rate-limit (calls/min, calls/day, calls/window) with a clickable URL to the provider's published limits page.
    35	2. The connector's chosen safety margin (typically 80% of upstream cap) and the in-process bucket implementation reference (token-bucket / sliding-window / fixed-window).
    36	3. The ESC code fired on bucket exhaustion (`ESC_RATE_LIMIT_HIT` with `payload.upstream='<provider>'`).
    37	
    38	REJECT if any are missing, OR if the safety margin >100% of upstream (the bucket would never throttle), OR if no test exercises bucket exhaustion.
    39	
    40	## §4 — Explicit retry policy
    41	
    42	For every state-changing capability (writes, OAuth refresh, anything non-idempotent at the upstream):
    43	
    44	1. Max retries declared (typically 1-3 depending on operation cost).
    45	2. Backoff strategy declared (typical: exponential w/ jitter; or fixed-delay for OAuth refresh).
    46	3. ESC code on retry-budget exhaustion (`ESC_<PROVIDER>_WRITE_FAIL` or equivalent).
    47	4. README documents which capabilities retry vs which fail-fast.
    48	
    49	REJECT if any capability has implicit retry forever (e.g. `while(true) { try { ... } catch { sleep(1s) } }` with no max).
    50	
    51	## §5 — No secret logs
    52	
    53	REJECT immediately on any of these in the package source (`src/` + `tests/`):
    54	
    55	```
    56	console.log(`...${KEY}...`)            // any credential variable interpolated into log
    57	console.error(`...${SECRET}...`)
    58	throw new Error(`...${PASSWORD}...`)
    59	JSON.stringify(envWithSecrets)
    60	```
    61	
    62	**Verify by:**
    63	- `grep -rE "console\.(log|error|warn).*\\\$\{.*(KEY|SECRET|PASSWORD|TOKEN|BEARER)" packages/mcp-connectors/<name>/`
    64	- `grep -rE "throw\s+new\s+Error.*\\\$\{.*(KEY|SECRET|PASSWORD)" packages/mcp-connectors/<name>/`
    65	
    66	Must return zero matches outside of fixture/test mocks. Mock test-fakes (e.g. `'fake-key'`) are fine; real credential variable names interpolated into output strings are not.
    67	
    68	## §6 — Fixture-first tests
    69	
    70	Every capability MUST have ≥1 vitest fixture exercising the canonical success path, AND ≥1 fixture exercising an error path (4xx, 5xx, rate-limit, malformed response — at least one). Live API calls behind an env-var gate that defaults OFF in CI:
    71	
    72	```typescript
    73	const LIVE = process.env.MCP_LIVE_TESTS === 'true';
    74	describe.skipIf(!LIVE)('live tests', () => { ... });
    75	```
    76	
    77	REJECT if:
    78	- Any capability has only happy-path fixtures (no error case).
    79	- Tests make live API calls when `MCP_LIVE_TESTS` is unset.
    80	- Fixtures are inline strings >100 lines (move to `fixtures/*.json`).
    81	- Fixture data contains real PII or real credentials (use shape-preserving fakes).
    82	
    83	## §7 — decision_log integration
    84	
    85	Every state-changing capability emits a `decision_log` row via `agents/_shared/hook-helpers.sh` `hh_decision_action` (or `hh_decision_output` for read-only outputs). The `action_type` argument MUST exist in `agents/_shared/autosend-policy.yaml` with the tier the connector documents in its README.
    86	
    87	For the connector itself (TypeScript), the emission is by a shell wrapper (e.g. cycle.sh) that consumes the connector's output — not by the connector directly. So the check is:
    88	
    89	1. README's "Capabilities" table includes a `action_type` column for each state-changing capability.
    90	2. Every listed `action_type` exists in `agents/_shared/autosend-policy.yaml`.

exec
/bin/zsh -lc "nl -ba .codex/ratification/review-mcp-connector.md | sed -n '89,110p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    89	1. README's "Capabilities" table includes a `action_type` column for each state-changing capability.
    90	2. Every listed `action_type` exists in `agents/_shared/autosend-policy.yaml`.
    91	3. The tier README claims for each matches the tier in `autosend-policy.yaml`.
    92	
    93	REJECT if a capability's documented action_type is absent from the policy YAML or has a different tier. If a new action_type is needed, the connector's README MUST mark it as "proposed; add to autosend-policy.yaml in same commit" — and the YAML edit MUST land in the same PR/commit.
    94	
    95	## §8 — Boundary checks (cross-cutting)
    96	
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
