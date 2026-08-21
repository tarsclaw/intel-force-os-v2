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
session id: 019e87e9-97d4-70d1-a9aa-71c11a6d1e55
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

Path: packages/mcp-connectors/open-banking

--- BEGIN ARTEFACT ---


--- FILE: packages/mcp-connectors/open-banking/fixtures/truelayer-balance.json ---

{
  "results": [
    {
      "available": 47823.55,
      "current": 47909.05,
      "currency": "GBP",
      "update_timestamp": "2026-06-01T08:30:00Z"
    }
  ],
  "status": "Succeeded"
}

--- FILE: packages/mcp-connectors/open-banking/fixtures/truelayer-transactions.json ---

{
  "results": [
    {
      "transaction_id": "tl-tx-aaa-111",
      "timestamp": "2026-05-20T10:30:00Z",
      "amount": 2000.00,
      "currency": "GBP",
      "description": "BETA SEARCH PARTNERS",
      "transaction_type": "CREDIT",
      "transaction_category": "BUSINESS",
      "meta": { "reference": "BACS-2026-05-20-001" }
    },
    {
      "transaction_id": "tl-tx-bbb-222",
      "timestamp": "2026-05-22T14:15:00Z",
      "amount": 1500.00,
      "currency": "GBP",
      "description": "ACME RECRUITMENT LTD",
      "transaction_type": "CREDIT",
      "transaction_category": "BUSINESS",
      "meta": { "reference": "BACS-2026-05-22-002" }
    },
    {
      "transaction_id": "tl-tx-ccc-333",
      "timestamp": "2026-05-25T09:00:00Z",
      "amount": -85.50,
      "currency": "GBP",
      "description": "STRIPE FEE",
      "transaction_type": "DEBIT",
      "transaction_category": "FEES",
      "meta": {}
    }
  ],
  "status": "Succeeded"
}

--- FILE: packages/mcp-connectors/open-banking/package.json ---

{
  "name": "@ifos/open-banking",
  "version": "0.1.0",
  "private": true,
  "description": "IFOS Open Banking MCP connector — TrueLayer (v1.0) + Plaid UK (v1.1+ interface stub) abstraction; PSD2 90-day consent + token-aging stages; list transactions + get balance. Used by Cash Conductor agent §4 Step 3 (bank transaction ingest) per agents/recruitment/cash-conductor/tools.yaml.",
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

--- FILE: packages/mcp-connectors/open-banking/README.md ---

# @ifos/open-banking

UK Open Banking connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). Provider abstraction over **TrueLayer (v1.0)** + **Plaid UK (v1.1+ deferred)** with PSD2 90-day consent tracking + token-aging stages. Used by Cash Conductor for bank-transaction ingest + cash-flow forecast balance reads.

**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first TrueLayer dev signup for live-test verification).

**Reference pattern:** mirrors `@ifos/xero` + `@ifos/quickbooks` structure. The PSD2 consent lifecycle is the load-bearing structural difference vs the accounting connectors — banks legally require user re-authentication every 90 days regardless of refresh-token TTL.

---

## Capabilities

Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.

| Capability ID (tools.yaml) | Function (src/index.ts) | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
|---|---|---|---|---|---|
| `open_banking_truelayer_oauth` | `refreshTokens(config, current, fetchFn?, now?)` (provider='truelayer') | OAuth refresh; concurrent-safe per (provider, connection_id); **refuses if consent is in PSD2 blocking window (≤7 days)** | Step 1 (auth refresh) | `open_banking_truelayer` | green |
| `open_banking_plaid_uk_oauth` (v1.1+ stub) | `refreshTokens(config, current, fetchFn?, now?)` (provider='plaid-uk') | Plaid UK OAuth refresh — interface in place; implementation throws `NotImplementedError` until v1.1+ | (never fires v1.0) | `open_banking_plaid_uk` | green |
| `open_banking_list_transactions` | `listTransactionsSince(client, config, options)` | List bank transactions on/after a timestamp; provider-agnostic shape; TrueLayer raw payload preserved in `raw_provider_payload` | Step 3 (transaction ingest) | n/a (read-only) | n/a |
| `open_banking_get_account_balance` | `getAccountBalance(client, config)` | Current account balance (available + cleared) | Step 10 (cash-flow forecast) | n/a (read-only) | n/a |

All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (verified 2026-06-01 Codex F-R2 closure — both `open_banking_truelayer` and `open_banking_plaid_uk` registered as green).

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
| Local hard-gate (100%) reached | `OpenBankingRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "truelayer" | "plaid-uk", retry_after_seconds: null, consecutive_429s: 0}` |
| Upstream 429 from provider API | `OpenBankingRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "truelayer" | "plaid-uk", retry_after_seconds: <N>, consecutive_429s: <N>}` |

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

--- FILE: packages/mcp-connectors/open-banking/src/auth.ts ---

// Open Banking OAuth refresh + PSD2 90-day consent tracking + token-aging stages.
//
// PSD2 mandates that users re-authenticate every 90 days regardless of whether
// the refresh token would otherwise still be valid. This package's auth layer
// tracks BOTH:
//   - access_token expiry (typical ~1h) → refresh transparently
//   - consent expiry (~90 days from initial consent) → emit ESC_OPEN_BANKING_TOKEN_AGING
//     stages so the agent can notify the operator before the consent dies
//
// Token-aging stages (per Cash Conductor agent.md §6):
//   - fresh:    > 30 days to consent expiry
//   - info:     ≤ 30 days  (operator-aware; nothing breaks)
//   - warn:     ≤ 14 days  (escalate to operator chat)
//   - blocking: ≤ 7  days  (HARD STOP — must re-consent; refuses to issue new access tokens)
//
// Provider scope (W4 Day-26):
//   - TrueLayer: full OAuth refresh implemented.
//   - Plaid UK: refreshTokens throws NotImplementedError (v1.1+).

import { promises as fs } from "node:fs";
import {
  NotImplementedError,
  OpenBankingAuthError,
  OpenBankingConsentExpiredError,
} from "./errors.js";
import type {
  OpenBankingConfig,
  OpenBankingTokens,
  TokenAgeReport,
  TokenAgeStage,
} from "./types.js";

const TRUELAYER_TOKEN_ENDPOINT_PROD =
  "https://auth.truelayer.com/connect/token";
const TRUELAYER_TOKEN_ENDPOINT_SANDBOX =
  "https://auth.truelayer-sandbox.com/connect/token";

const DAY_MS = 24 * 60 * 60 * 1000;

const inflight: Map<string, Promise<OpenBankingTokens>> = new Map();

/** Read token file from disk; returns null if missing/malformed. */
export async function loadTokens(
  config: OpenBankingConfig,
): Promise<OpenBankingTokens | null> {
  let raw: string;
  try {
    raw = await fs.readFile(config.token_file_path, "utf8");
  } catch {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as OpenBankingTokens;
    if (
      typeof parsed.access_token !== "string" ||
      typeof parsed.refresh_token !== "string" ||
      typeof parsed.expires_at_ms !== "number" ||
      typeof parsed.consent_expires_at_ms !== "number"
    ) {
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

/** Atomic save: write to <path>.tmp then rename. */
export async function saveTokens(
  config: OpenBankingConfig,
  tokens: OpenBankingTokens,
): Promise<void> {
  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
  await fs.rename(tmpPath, config.token_file_path);
}

/** Returns true if access token expires within the next `safety_window_ms` (default 5 min). */
export function shouldRefresh(
  tokens: OpenBankingTokens,
  now: () => number = Date.now,
  safety_window_ms = 5 * 60 * 1000,
): boolean {
  return tokens.expires_at_ms - now() < safety_window_ms;
}

/**
 * Pure function: classify token age based on days to PSD2 consent expiry.
 * Property-tested across day 0-100 boundary.
 */
export function getTokenAgeStage(
  tokens: OpenBankingTokens,
  now: () => number = Date.now,
): TokenAgeReport {
  const days = (tokens.consent_expires_at_ms - now()) / DAY_MS;
  let stage: TokenAgeStage;
  if (days <= 7) stage = "blocking";
  else if (days <= 14) stage = "warn";
  else if (days <= 30) stage = "info";
  else stage = "fresh";
  return {
    stage,
    days_until_consent_expiry: days,
    consent_expires_at_ms: tokens.consent_expires_at_ms,
  };
}

/**
 * Refresh OAuth tokens. Provider-aware: TrueLayer fully implemented; Plaid UK
 * throws NotImplementedError. Concurrent-safe per (provider, connection_id).
 *
 * Refuses refresh if consent age is "blocking" — operator MUST re-do the PSD2
 * consent dance with the user first.
 */
export async function refreshTokens(
  config: OpenBankingConfig,
  current_tokens: OpenBankingTokens,
  fetchFn: typeof fetch = fetch,
  now: () => number = Date.now,
): Promise<OpenBankingTokens> {
  // Consent-age hard stop BEFORE attempting refresh
  const ageReport = getTokenAgeStage(current_tokens, now);
  if (ageReport.stage === "blocking") {
    throw new OpenBankingConsentExpiredError(
      `PSD2 consent within ${Math.max(0, Math.floor(ageReport.days_until_consent_expiry))} days of expiry; ` +
        `re-consent required before refresh (provider=${config.provider}, connection_id=${config.connection_id})`,
    );
  }

  if (config.provider === "plaid-uk") {
    throw new NotImplementedError(
      "Plaid UK OAuth refresh not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2; v1.0 path is TrueLayer)",
    );
  }

  const lockKey = `${config.provider}:${config.connection_id}`;
  const existing = inflight.get(lockKey);
  if (existing) return existing;

  const tokenEndpoint =
    config.environment === "production"
      ? TRUELAYER_TOKEN_ENDPOINT_PROD
      : TRUELAYER_TOKEN_ENDPOINT_SANDBOX;

  const promise = (async () => {
    try {
      const body = new URLSearchParams({
        grant_type: "refresh_token",
        client_id: config.client_id,
        client_secret: config.client_secret,
        refresh_token: current_tokens.refresh_token,
      });

      const res = await fetchFn(tokenEndpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          Accept: "application/json",
        },
        body,
      });

      if (!res.ok) {
        // Never include the response body verbatim — TrueLayer may echo
        // the (now-invalid) refresh_token in error responses.
        throw new OpenBankingAuthError(
          `TrueLayer OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
          res.status,
          res.status === 401 ? "refresh_token_revoked" : "credentials",
        );
      }

      const data = (await res.json()) as {
        access_token: string;
        refresh_token: string;
        expires_in: number;
        scope?: string;
        token_type: string;
      };

      // TrueLayer does NOT extend the PSD2 consent on refresh — only the
      // access_token rotates. Preserve the consent_expires_at_ms from
      // current_tokens; the consent dance has its own re-authentication flow.
      const new_tokens: OpenBankingTokens = {
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at_ms: now() + data.expires_in * 1000,
        consent_expires_at_ms: current_tokens.consent_expires_at_ms,
        scope: data.scope ?? current_tokens.scope,
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

--- FILE: packages/mcp-connectors/open-banking/src/balance.ts ---

// Open Banking balance capability — get current account balance.
// Consumed by Cash Conductor §10 (weekly cash-flow forecast; available + cleared
// distinction matters for pending-transaction nuance).
//
// TrueLayer endpoint: GET /data/v1/accounts/<account_id>/balance
// Plaid UK endpoint (v1.1+): POST /accounts/balance/get (deferred).

import type { OpenBankingClient } from "./client.js";
import { NotImplementedError } from "./errors.js";
import type {
  OpenBankingBalance,
  OpenBankingConfig,
} from "./types.js";

interface TrueLayerBalanceResponse {
  results: Array<{
    available: number;
    current: number;
    currency: string;
    update_timestamp: string;
  }>;
  status: string;
}

/**
 * Fetch current account balance. Returns provider-agnostic OpenBankingBalance
 * shape. NOT cached by default — balances are point-in-time values; staleness
 * matters more than throughput for Cash Conductor's weekly forecast.
 */
export async function getAccountBalance(
  client: OpenBankingClient,
  config: OpenBankingConfig,
): Promise<OpenBankingBalance> {
  if (config.provider === "plaid-uk") {
    throw new NotImplementedError(
      "Plaid UK getAccountBalance not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2)",
    );
  }

  const path = `/data/v1/accounts/${encodeURIComponent(config.connection_id)}/balance`;
  const res = await client.request<TrueLayerBalanceResponse>(path);

  const r = res.results?.[0];
  if (!r) {
    throw new Error(
      `TrueLayer balance fetch returned no results for connection ${config.connection_id}`,
    );
  }

  return {
    available: r.available,
    current: r.current,
    currency: r.currency,
    fetched_at: r.update_timestamp,
  };
}

--- FILE: packages/mcp-connectors/open-banking/src/cache.ts ---

// Disk cache for Open Banking responses. Default TTL 5 min for transaction
// lists; balance reads typically not cached (always fresh). Pattern matches
// @ifos/companies-house + @ifos/xero + @ifos/quickbooks; intentionally
// not shared to keep package boundaries clean.

import { createHash } from "node:crypto";
import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

interface CacheEntry<T> {
  cachedAt: number;
  ttlMs: number;
  value: T;
}

export class OpenBankingCache {
  constructor(private readonly dir: string) {}

  static fromEnv(): OpenBankingCache {
    const dir =
      process.env.IFOS_OPEN_BANKING_CACHE_DIR ??
      join(homedir(), ".ifos-cache", "open-banking");
    return new OpenBankingCache(dir);
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

--- FILE: packages/mcp-connectors/open-banking/src/client.ts ---

// Open Banking HTTP client façade — provider-aware (TrueLayer fully implemented;
// Plaid UK stubbed for v1.1+). Wraps fetch with: OAuth token attach, rate-limit
// budget, 429 retry-after, 5xx exponential backoff, 4xx surface as typed errors.

import {
  NotImplementedError,
  OpenBankingAuthError,
  OpenBankingError,
  OpenBankingNotFoundError,
  OpenBankingRateLimitError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import { loadTokens, refreshTokens, shouldRefresh } from "./auth.js";
import type { OpenBankingClientOptions, OpenBankingTokens } from "./types.js";

export const TRUELAYER_API_PROD = "https://api.truelayer.com";
export const TRUELAYER_API_SANDBOX = "https://api.truelayer-sandbox.com";
export const DEFAULT_TIMEOUT_MS = 15_000;

interface RequestOptions {
  method?: "GET" | "POST";
  query?: Record<string, string>;
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

export class OpenBankingClient {
  private readonly opts: OpenBankingClientOptions;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private current_tokens: OpenBankingTokens | null = null;
  private readonly base_url: string;

  constructor(opts: OpenBankingClientOptions) {
    this.opts = opts;
    this.fetchFn = opts.fetchFn ?? fetch;
    this.now = opts.now ?? Date.now;
    if (opts.config.provider === "plaid-uk") {
      // Plaid UK API URL would land here; v1.1+ deferred.
      this.base_url = "https://plaid-uk-not-yet-implemented.invalid";
    } else {
      this.base_url =
        opts.config.environment === "production"
          ? TRUELAYER_API_PROD
          : TRUELAYER_API_SANDBOX;
    }
  }

  async getValidAccessToken(): Promise<string> {
    if (!this.current_tokens) {
      this.current_tokens = await loadTokens(this.opts.config);
      if (!this.current_tokens) {
        throw new OpenBankingAuthError(
          `No ${this.opts.config.provider} tokens on disk; PSD2 consent + initial token exchange required to bootstrap token_file_path (run the one-time OAuth authorise flow per README §Bootstrap)`,
        );
      }
    }
    if (shouldRefresh(this.current_tokens, this.now)) {
      this.current_tokens = await refreshTokens(
        this.opts.config,
        this.current_tokens,
        this.fetchFn,
        this.now,
      );
    }
    return this.current_tokens.access_token;
  }

  /** Low-level request. Capability helpers (transactions, balance) use this. */
  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    if (this.opts.config.provider === "plaid-uk") {
      throw new NotImplementedError(
        "Plaid UK provider client not yet implemented (v1.1+ deferred). Use provider: 'truelayer' for v1.0.",
      );
    }

    const method = options.method ?? "GET";
    const max_retries = options.max_retries ?? 2;

    const url = new URL(this.base_url + path);
    if (options.query) {
      for (const [k, v] of Object.entries(options.query)) {
        url.searchParams.set(k, v);
      }
    }

    let last_error: unknown = null;
    for (let attempt = 0; attempt <= max_retries; attempt++) {
      const allowed = consume(
        this.opts.config.provider,
        this.opts.config.connection_id,
        this.now,
      );
      if (!allowed) {
        throw new OpenBankingRateLimitError(
          `Open Banking rate-limit budget exhausted (provider=${this.opts.config.provider}, connection=${this.opts.config.connection_id})`,
        );
      }

      const access_token = await this.getValidAccessToken();
      const headers: Record<string, string> = {
        Authorization: `Bearer ${access_token}`,
        Accept: "application/json",
      };

      let res: Response;
      try {
        res = await this.fetchFn(url.toString(), {
          method,
          headers,
          signal: options.signal,
        });
      } catch (e) {
        last_error = e;
        if (attempt < max_retries) {
          await sleep(backoff(attempt));
          continue;
        }
        throw new OpenBankingError(
          `Open Banking network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
        );
      }

      if (res.ok) {
        return (await res.json()) as T;
      }

      if (res.status === 401 && attempt < max_retries) {
        this.current_tokens = null;
        await sleep(backoff(attempt));
        continue;
      }

      if (res.status === 429 && attempt < max_retries) {
        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
        await sleep(waitMs);
        continue;
      }
      if (res.status === 429) {
        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
        throw new OpenBankingRateLimitError(
          `Open Banking returned 429 after ${attempt + 1} attempt(s)`,
          retryAfter > 0 ? retryAfter : null,
        );
      }

      if (res.status >= 500 && attempt < max_retries) {
        await sleep(backoff(attempt));
        continue;
      }

      if (res.status === 404) {
        throw new OpenBankingNotFoundError(`Open Banking 404 on ${method} ${path}`);
      }
      throw new OpenBankingError(
        `Open Banking ${method} ${path} failed (HTTP ${res.status})`,
        res.status,
      );
    }
    throw new OpenBankingError(
      `Open Banking ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
    );
  }
}

--- FILE: packages/mcp-connectors/open-banking/src/errors.ts ---

// Open Banking error hierarchy. Errors NEVER include credential values; only
// key names + status codes + safe metadata. Per review-mcp-connector §5.

export class OpenBankingError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
  ) {
    super(message);
    this.name = "OpenBankingError";
  }
}

/** OAuth refresh failed: client_id/secret rejected, refresh_token invalid, OR consent expired (must re-do PSD2 dance). */
export class OpenBankingAuthError extends OpenBankingError {
  constructor(
    message: string,
    status?: number,
    public readonly reason: "credentials" | "consent_expired" | "refresh_token_revoked" | "unknown" = "unknown",
  ) {
    super(message, status, false);
    this.name = "OpenBankingAuthError";
  }
}

/** Rate-limit budget exhausted. */
export class OpenBankingRateLimitError extends OpenBankingError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "OpenBankingRateLimitError";
  }
}

/** Consent expired (PSD2 90-day) — special-case of auth failure with re-consent guidance. */
export class OpenBankingConsentExpiredError extends OpenBankingAuthError {
  constructor(message: string) {
    super(message, undefined, "consent_expired");
    this.name = "OpenBankingConsentExpiredError";
  }
}

/** Connection or transaction not found. */
export class OpenBankingNotFoundError extends OpenBankingError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "OpenBankingNotFoundError";
  }
}

/** Provider not implemented (e.g. Plaid UK during v1.0 — deferred to v1.1+). */
export class NotImplementedError extends OpenBankingError {
  constructor(message: string) {
    super(message, undefined, false);
    this.name = "NotImplementedError";
  }
}

--- FILE: packages/mcp-connectors/open-banking/src/index.ts ---

// @ifos/open-banking — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
//       on agents/recruitment/cash-conductor/tools.yaml AND (for state-changing
//       capabilities) has an action_type entry in agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check).
//
// Provider scope (W4 Day-26):
//   - TrueLayer: fully implemented (v1.0 path per Cash Conductor §9 Q2).
//   - Plaid UK: interface present; implementation throws NotImplementedError
//     until v1.1+ (no UK Cash Conductor pilot needs Plaid at v1.0).
//
// PSD2 90-day consent tracking is THE load-bearing distinction from Xero / QB:
// banks legally require user re-authentication every 90 days regardless of
// refresh-token TTL. See auth.ts getTokenAgeStage + README §"PSD2 consent lifecycle".

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §open-banking)
// ─────────────────────────────────────────────────────────────────────────

// open_banking_truelayer_oauth (action_type: open_banking_truelayer, green tier)
// open_banking_plaid_uk_oauth — same function with provider='plaid-uk'; throws
// NotImplementedError until v1.1+; action_type open_banking_plaid_uk green tier
// per autosend-policy.yaml (registered for set-equality even though it never
// fires in v1.0).
export { refreshTokens } from "./auth.js";
// open_banking_list_transactions (read-only)
export { listTransactionsSince } from "./transactions.js";
// open_banking_get_account_balance (read-only)
export { getAccountBalance } from "./balance.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once by cycle.sh Step 1; provider-aware base URL
export {
  OpenBankingClient,
  TRUELAYER_API_PROD,
  TRUELAYER_API_SANDBOX,
  DEFAULT_TIMEOUT_MS,
} from "./client.js";
// Token-file I/O + pure predicates (shouldRefresh for access-token age;
// getTokenAgeStage for PSD2 consent-expiry staged alerting)
export {
  loadTokens,
  saveTokens,
  shouldRefresh,
  getTokenAgeStage,
} from "./auth.js";
// Disk cache (transactions TTL 5min; balance TTL 0)
export { OpenBankingCache } from "./cache.js";
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
// Error hierarchy (OpenBankingConsentExpiredError + NotImplementedError are
// load-bearing for the consumer's branching logic)
export {
  OpenBankingError,
  OpenBankingAuthError,
  OpenBankingConsentExpiredError,
  OpenBankingRateLimitError,
  OpenBankingNotFoundError,
  NotImplementedError,
} from "./errors.js";
export type {
  OpenBankingProvider,
  OpenBankingTokens,
  OpenBankingConfig,
  OpenBankingTransaction,
  OpenBankingBalance,
  TokenAgeStage,
  TokenAgeReport,
  OpenBankingClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";

--- FILE: packages/mcp-connectors/open-banking/src/rate-limit.ts ---

// Rate limiter for Open Banking providers. Conservative per-provider buckets;
// per-(provider, connection_id) state for multi-bank isolation.
//
// TrueLayer published limits (https://docs.truelayer.com/docs/api-overview):
//   Production: not publicly numbered; sandbox often constrained to ~10/min
//   per connection. We use a conservative 30/min cap with 24/min soft.
// Plaid UK published limits (https://plaid.com/docs/api/rate-limits/):
//   Standard tier: 30 calls/minute per item. Same cap structure.
//
// Both providers handle rate-limit-friendly behaviour at the protocol layer
// (429 + Retry-After honoured by client.ts).

const MINUTE_MS = 60 * 1000;
const MINUTE_HARD = 30;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 24

const minuteTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  provider_connection_key: string;
  minute_used: number;
  minute_remaining: number;
  shouldBackoff: boolean;
  reason: "ok" | "minute-soft" | "minute-hard";
}

function key(provider: string, connection_id: string): string {
  return `${provider}:${connection_id}`;
}

function pruneMinute(arr: number[] | undefined, now: number): number[] {
  if (!arr) return [];
  return arr.filter((ts) => now - ts < MINUTE_MS);
}

export function check(
  provider: string,
  connection_id: string,
  now: () => number = Date.now,
): RateState {
  const k = key(provider, connection_id);
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(k), t);
  minuteTimestamps.set(k, minute);

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
    provider_connection_key: k,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  provider: string,
  connection_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(provider, connection_id, now);
  if (state.reason === "minute-hard") return false;
  const k = key(provider, connection_id);
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(k), t);
  minute.push(t);
  minuteTimestamps.set(k, minute);
  return true;
}

export function reset(provider?: string, connection_id?: string): void {
  if (provider !== undefined && connection_id !== undefined) {
    minuteTimestamps.delete(key(provider, connection_id));
  } else {
    minuteTimestamps.clear();
  }
}

--- FILE: packages/mcp-connectors/open-banking/src/transactions.ts ---

// Open Banking transactions capability — list transactions since a given timestamp.
// Consumed by Cash Conductor §4 Step 3 (bank transaction ingest).
//
// TrueLayer endpoint: GET /data/v1/accounts/<account_id>/transactions?from=<ISO>&to=<ISO>
// Plaid UK endpoint (v1.1+): POST /transactions/get (different shape; deferred).

import type { OpenBankingClient } from "./client.js";
import { OpenBankingCache } from "./cache.js";
import { NotImplementedError } from "./errors.js";
import type {
  OpenBankingConfig,
  OpenBankingTransaction,
} from "./types.js";

const TRANSACTIONS_CACHE_TTL_MS = 5 * 60 * 1000;

interface TrueLayerTransactionsResponse {
  results: Array<{
    transaction_id: string;
    timestamp: string;
    amount: number;
    currency: string;
    description: string;
    transaction_type?: string;
    transaction_category?: string;
    meta?: { reference?: string };
  }>;
  status: string;
}

export interface ListTransactionsOptions {
  /** ISO 8601 — fetch transactions on/after this timestamp. */
  since: string;
  /** ISO 8601 — fetch transactions on/before this timestamp (defaults to now). */
  until?: string;
  no_cache?: boolean;
  cache?: OpenBankingCache;
}

/**
 * List transactions for a connected bank account since a given timestamp.
 * Returns provider-agnostic OpenBankingTransaction shape; TrueLayer raw payload
 * preserved in `raw_provider_payload`.
 */
export async function listTransactionsSince(
  client: OpenBankingClient,
  config: OpenBankingConfig,
  options: ListTransactionsOptions,
): Promise<OpenBankingTransaction[]> {
  if (config.provider === "plaid-uk") {
    throw new NotImplementedError(
      "Plaid UK listTransactionsSince not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2)",
    );
  }

  const cache = options.cache ?? OpenBankingCache.fromEnv();
  const until = options.until ?? new Date().toISOString();
  const key = `transactions:${config.connection_id}:since=${options.since}:until=${until}`;

  if (!options.no_cache) {
    const hit = await cache.get<OpenBankingTransaction[]>(key);
    if (hit !== null) return hit;
  }

  const path = `/data/v1/accounts/${encodeURIComponent(config.connection_id)}/transactions`;
  const res = await client.request<TrueLayerTransactionsResponse>(path, {
    query: { from: options.since, to: until },
  });

  const transactions: OpenBankingTransaction[] = (res.results ?? []).map((r) => ({
    transaction_id: r.transaction_id,
    posted_at: r.timestamp,
    amount: r.amount,
    currency: r.currency,
    description: r.description,
    reference: r.meta?.reference ?? null,
    raw_provider_payload: r as unknown as Record<string, unknown>,
  }));

  await cache.set(key, transactions, TRANSACTIONS_CACHE_TTL_MS);
  return transactions;
}

--- FILE: packages/mcp-connectors/open-banking/src/types.ts ---

// Open Banking API types — provider-agnostic core + provider-tagged variants.
// IFOS Cash Conductor consumes via the provider-switching client façade.
//
// Provider scope (W4 Day-26 scaffold):
//   - TrueLayer: fully implemented (v1.0 path per Cash Conductor §9 Q2).
//   - Plaid UK: interface defined; implementation deferred to v1.1+ (throws
//     NotImplementedError until then).

export type OpenBankingProvider = "truelayer" | "plaid-uk";

export interface OpenBankingTokens {
  access_token: string;
  refresh_token: string;
  /** Unix epoch milliseconds when access_token expires (~1h TrueLayer / ~1h Plaid). */
  expires_at_ms: number;
  /**
   * Unix epoch milliseconds when the PSD2 CONSENT expires (~90 days).
   * Distinct from refresh_token expiry — PSD2 mandates user re-authentication
   * every 90 days regardless of refresh-token TTL.
   */
  consent_expires_at_ms: number;
  scope: string;
  token_type: string;
}

export interface OpenBankingConfig {
  provider: OpenBankingProvider;
  client_id: string;
  client_secret: string;
  /** Per-bank-connection identifier from the provider (TrueLayer: account_id; Plaid UK: item_id). */
  connection_id: string;
  environment: "sandbox" | "production";
  token_file_path: string;
}

export interface OpenBankingTransaction {
  /** Provider-assigned transaction id. */
  transaction_id: string;
  /** ISO 8601 timestamp (UTC) when the transaction posted. */
  posted_at: string;
  /** Amount in major currency units (positive = credit / inbound; negative = debit / outbound). */
  amount: number;
  currency: string;
  /** Free-text counterparty / payee name as provided by the bank. */
  description: string;
  /** Optional bank-reference / memo field. */
  reference: string | null;
  /** Provider-specific raw payload preserved for audit + future fields. */
  raw_provider_payload: Record<string, unknown>;
}

export interface OpenBankingBalance {
  /** Current available balance in major currency units. */
  available: number;
  /** Current cleared balance (may differ from `available` during pending transactions). */
  current: number;
  currency: string;
  /** ISO 8601 timestamp (UTC) when the balance was fetched. */
  fetched_at: string;
}

export type TokenAgeStage = "fresh" | "info" | "warn" | "blocking";

export interface TokenAgeReport {
  stage: TokenAgeStage;
  days_until_consent_expiry: number;
  consent_expires_at_ms: number;
}

export interface OpenBankingClientOptions {
  config: OpenBankingConfig;
  fetchFn?: typeof fetch;
  now?: () => number;
}

--- FILE: packages/mcp-connectors/open-banking/tests/auth.test.ts ---

// OAuth tests per review-mcp-connector §2 (idempotency + atomic file write +
// concurrent-safety test) + PSD2 consent-expiry guard test.

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
import {
  NotImplementedError,
  OpenBankingAuthError,
  OpenBankingConsentExpiredError,
} from "../src/errors.js";
import type {
  OpenBankingConfig,
  OpenBankingTokens,
} from "../src/types.js";

const DAY_MS = 24 * 60 * 60 * 1000;

const FIXTURE_TOKENS: OpenBankingTokens = {
  access_token: "tl-access-old",
  refresh_token: "tl-refresh-old",
  expires_at_ms: Date.now() + 3600_000,
  consent_expires_at_ms: Date.now() + 60 * DAY_MS,
  scope: "accounts transactions balance",
  token_type: "Bearer",
};

const REFRESH_OK_BODY = JSON.stringify({
  access_token: "tl-new-access",
  refresh_token: "tl-new-refresh",
  expires_in: 3600,
  scope: "accounts transactions balance",
  token_type: "Bearer",
});

function makeConfig(
  token_file: string,
  overrides: Partial<OpenBankingConfig> = {},
): OpenBankingConfig {
  return {
    provider: "truelayer",
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    connection_id: "acct-fixture",
    environment: "sandbox",
    token_file_path: token_file,
    ...overrides,
  };
}

let token_file: string;

beforeEach(() => {
  token_file = join(
    tmpdir(),
    `ob-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  _resetInflightForTest();
});
afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("open-banking auth", () => {
  it("loadTokens returns null when file missing", async () => {
    expect(await loadTokens(makeConfig(token_file))).toBeNull();
  });

  it("save + load round-trips token bundle (with consent_expires_at_ms)", async () => {
    const config = makeConfig(token_file);
    await saveTokens(config, FIXTURE_TOKENS);
    const loaded = await loadTokens(config);
    expect(loaded).toEqual(FIXTURE_TOKENS);
  });

  it("shouldRefresh: true if within 5-min safety window", () => {
    const expiringSoon: OpenBankingTokens = {
      ...FIXTURE_TOKENS,
      expires_at_ms: Date.now() + 60_000,
    };
    expect(shouldRefresh(expiringSoon)).toBe(true);
  });

  it("refreshTokens (TrueLayer): success writes new tokens; consent_expires_at_ms PRESERVED", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(REFRESH_OK_BODY, {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });

    const newT = await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    expect(newT.access_token).toBe("tl-new-access");
    expect(newT.consent_expires_at_ms).toBe(FIXTURE_TOKENS.consent_expires_at_ms);
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(newT.access_token);
  });

  it("refreshTokens: 401 surfaces as OpenBankingAuthError (refresh_token_revoked); no token leak", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(JSON.stringify({ error: "invalid_grant" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });

    await expect(
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
    ).rejects.toBeInstanceOf(OpenBankingAuthError);
    try {
      await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    } catch (e) {
      expect((e as Error).message).not.toContain(FIXTURE_TOKENS.refresh_token);
    }
  });

  it("refreshTokens: consent within 7-day blocking window REFUSES refresh (PSD2 hard stop)", async () => {
    const config = makeConfig(token_file);
    const nearExpiry: OpenBankingTokens = {
      ...FIXTURE_TOKENS,
      consent_expires_at_ms: Date.now() + 3 * DAY_MS, // 3 days = blocking
    };
    const fakeFetch = async (): Promise<Response> =>
      new Response(REFRESH_OK_BODY, { status: 200 });
    await expect(
      refreshTokens(config, nearExpiry, fakeFetch as typeof fetch),
    ).rejects.toBeInstanceOf(OpenBankingConsentExpiredError);
  });

  it("refreshTokens: concurrent calls (same provider+connection) converge on ONE network call", async () => {
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
  });

  it("refreshTokens: Plaid UK provider throws NotImplementedError (v1.1+ deferred)", async () => {
    const config = makeConfig(token_file, { provider: "plaid-uk" });
    await expect(
      refreshTokens(config, FIXTURE_TOKENS, fetch),
    ).rejects.toBeInstanceOf(NotImplementedError);
  });
});

--- FILE: packages/mcp-connectors/open-banking/tests/capabilities.test.ts ---

// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
// path + ≥1 error path per capability). Plaid UK NotImplementedError path
// covered for both capabilities.

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { OpenBankingClient } from "../src/client.js";
import { OpenBankingCache } from "../src/cache.js";
import { saveTokens, _resetInflightForTest } from "../src/auth.js";
import { reset as resetRateLimit } from "../src/rate-limit.js";
import { listTransactionsSince } from "../src/transactions.js";
import { getAccountBalance } from "../src/balance.js";
import { NotImplementedError } from "../src/errors.js";
import type {
  OpenBankingConfig,
  OpenBankingTokens,
} from "../src/types.js";

import TL_TRANSACTIONS from "../fixtures/truelayer-transactions.json" with { type: "json" };
import TL_BALANCE from "../fixtures/truelayer-balance.json" with { type: "json" };

const DAY_MS = 24 * 60 * 60 * 1000;

const FIXTURE_TOKENS: OpenBankingTokens = {
  access_token: "tl-access",
  refresh_token: "tl-refresh",
  expires_at_ms: Date.now() + 3600_000,
  consent_expires_at_ms: Date.now() + 60 * DAY_MS,
  scope: "accounts transactions balance",
  token_type: "Bearer",
};

let token_file: string;
let cache_dir: string;
let cache: OpenBankingCache;

function makeConfig(
  overrides: Partial<OpenBankingConfig> = {},
): OpenBankingConfig {
  return {
    provider: "truelayer",
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    connection_id: "acct-fixture",
    environment: "sandbox",
    token_file_path: token_file,
    ...overrides,
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
    `ob-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  cache_dir = join(
    tmpdir(),
    `ob-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`,
  );
  cache = new OpenBankingCache(cache_dir);
  _resetInflightForTest();
  resetRateLimit();
  await saveTokens(makeConfig(), FIXTURE_TOKENS);
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
});

describe("open-banking capabilities — TrueLayer (v1.0)", () => {
  it("listTransactionsSince: returns provider-agnostic OpenBankingTransaction[] from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(TL_TRANSACTIONS);
    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    const txns = await listTransactionsSince(client, config, {
      since: "2026-05-01T00:00:00Z",
      cache,
      no_cache: true,
    });
    expect(txns.length).toBe(3);
    expect(txns[0]?.transaction_id).toBe("tl-tx-aaa-111");
    expect(txns[0]?.amount).toBe(2000);
    expect(txns[0]?.reference).toBe("BACS-2026-05-20-001");
    // Debit transaction preserves negative amount
    expect(txns[2]?.amount).toBe(-85.5);
    // raw_provider_payload preserved
    expect(txns[0]?.raw_provider_payload.transaction_id).toBe("tl-tx-aaa-111");
  });

  it("getAccountBalance: returns OpenBankingBalance with available + current + currency", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(TL_BALANCE);
    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    const bal = await getAccountBalance(client, config);
    expect(bal.available).toBe(47823.55);
    expect(bal.current).toBe(47909.05);
    expect(bal.currency).toBe("GBP");
    expect(bal.fetched_at).toBe("2026-06-01T08:30:00Z");
  });
});

describe("open-banking capabilities — Plaid UK (v1.1+ deferred)", () => {
  it("listTransactionsSince throws NotImplementedError for Plaid UK", async () => {
    const config = makeConfig({ provider: "plaid-uk" });
    const client = new OpenBankingClient({ config });
    await expect(
      listTransactionsSince(client, config, { since: "2026-05-01T00:00:00Z" }),
    ).rejects.toBeInstanceOf(NotImplementedError);
  });

  it("getAccountBalance throws NotImplementedError for Plaid UK", async () => {
    const config = makeConfig({ provider: "plaid-uk" });
    const client = new OpenBankingClient({ config });
    await expect(getAccountBalance(client, config)).rejects.toBeInstanceOf(
      NotImplementedError,
    );
  });
});

--- FILE: packages/mcp-connectors/open-banking/tests/rate-limit.test.ts ---

// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
// MUST exist). Verifies soft (80%) + hard (100%) thresholds, multi-provider
// + multi-connection isolation.

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

describe("open-banking rate-limit", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check("truelayer", "acct-1");
    expect(s.minute_used).toBe(0);
    expect(s.minute_remaining).toBe(30);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute soft threshold (24)", () => {
    for (let i = 0; i < 23; i++) consume("truelayer", "acct-1");
    expect(check("truelayer", "acct-1").shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 24", () => {
    for (let i = 0; i < 24; i++) consume("truelayer", "acct-1");
    const s = check("truelayer", "acct-1");
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 30 (consume returns false)", () => {
    for (let i = 0; i < 30; i++) consume("truelayer", "acct-1");
    expect(check("truelayer", "acct-1").reason).toBe("minute-hard");
    expect(consume("truelayer", "acct-1")).toBe(false);
  });

  it("isolates buckets per (provider, connection_id) pair", () => {
    for (let i = 0; i < 25; i++) consume("truelayer", "acct-A");
    expect(check("truelayer", "acct-A").shouldBackoff).toBe(true);
    expect(check("truelayer", "acct-B").shouldBackoff).toBe(false);
    expect(check("plaid-uk", "acct-A").shouldBackoff).toBe(false);
  });
});

--- FILE: packages/mcp-connectors/open-banking/tests/scaffold.test.ts ---

// Package public surface smoke tests. Per review-mcp-connector §1.

import { describe, expect, it } from "vitest";
import {
  VERSION,
  OpenBankingClient,
  TRUELAYER_API_PROD,
  TRUELAYER_API_SANDBOX,
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  getTokenAgeStage,
  listTransactionsSince,
  getAccountBalance,
  OpenBankingCache,
  OpenBankingError,
  OpenBankingAuthError,
  OpenBankingConsentExpiredError,
  OpenBankingRateLimitError,
  OpenBankingNotFoundError,
  NotImplementedError,
} from "../src/index.js";

describe("@ifos/open-banking package surface", () => {
  it("exports VERSION 0.1.0", () => {
    expect(VERSION).toBe("0.1.0");
  });

  it("exports OpenBankingClient + base URLs (production + sandbox)", () => {
    expect(typeof OpenBankingClient).toBe("function");
    expect(TRUELAYER_API_PROD).toBe("https://api.truelayer.com");
    expect(TRUELAYER_API_SANDBOX).toBe("https://api.truelayer-sandbox.com");
  });

  it("exports all 2 capability functions", () => {
    expect(typeof listTransactionsSince).toBe("function");
    expect(typeof getAccountBalance).toBe("function");
  });

  it("exports auth helpers (load/save/refresh/shouldRefresh/getTokenAgeStage)", () => {
    expect(typeof loadTokens).toBe("function");
    expect(typeof saveTokens).toBe("function");
    expect(typeof refreshTokens).toBe("function");
    expect(typeof shouldRefresh).toBe("function");
    expect(typeof getTokenAgeStage).toBe("function");
  });

  it("exports OpenBankingCache + full error hierarchy including ConsentExpired + NotImplementedError", () => {
    expect(typeof OpenBankingCache).toBe("function");
    expect(new OpenBankingAuthError("x") instanceof OpenBankingError).toBe(true);
    expect(new OpenBankingConsentExpiredError("x") instanceof OpenBankingAuthError).toBe(true);
    expect(new OpenBankingRateLimitError("x") instanceof OpenBankingError).toBe(true);
    expect(new OpenBankingNotFoundError("x") instanceof OpenBankingError).toBe(true);
    expect(new NotImplementedError("x") instanceof OpenBankingError).toBe(true);
  });
});

--- FILE: packages/mcp-connectors/open-banking/tests/token-aging.test.ts ---

// Token-aging property-based tests — covers day 0-100 boundary of the PSD2
// consent lifecycle per goal-w4-day-26 Phase 2 Step 7. Verifies stage
// transitions at the exact day boundaries (7, 14, 30) and post-expiry behaviour.

import { describe, expect, it } from "vitest";
import { getTokenAgeStage } from "../src/auth.js";
import type { OpenBankingTokens, TokenAgeStage } from "../src/types.js";

const DAY_MS = 24 * 60 * 60 * 1000;
const NOW = 1_700_000_000_000; // arbitrary fixed reference time
const fixedNow = (): number => NOW;

function tokensExpiringInDays(days: number): OpenBankingTokens {
  return {
    access_token: "x",
    refresh_token: "x",
    expires_at_ms: NOW + 60 * 60 * 1000,
    consent_expires_at_ms: NOW + days * DAY_MS,
    scope: "accounts transactions balance",
    token_type: "Bearer",
  };
}

describe("getTokenAgeStage — boundary classification", () => {
  it("days > 30 → fresh", () => {
    for (const d of [31, 45, 60, 90, 100]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("fresh");
    }
  });

  it("days 15 .. 30 → info", () => {
    for (const d of [30, 25, 20, 16, 15.001]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("info");
    }
  });

  it("days 8 .. 14 → warn", () => {
    for (const d of [14, 13, 10, 8, 7.001]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("warn");
    }
  });

  it("days 0 .. 7 → blocking", () => {
    for (const d of [7, 6, 3, 1, 0.5, 0]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("blocking");
    }
  });

  it("days negative (already expired) → blocking", () => {
    for (const d of [-0.5, -3, -10, -100]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("blocking");
    }
  });

  it("returns days_until_consent_expiry consistent with input", () => {
    const r = getTokenAgeStage(tokensExpiringInDays(45.5), fixedNow);
    expect(r.days_until_consent_expiry).toBeCloseTo(45.5, 6);
  });
});

--- FILE: packages/mcp-connectors/open-banking/tsconfig.json ---

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

--- FILE: packages/mcp-connectors/open-banking/tsup.config.ts ---

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

--- FILE: packages/mcp-connectors/open-banking/vitest.config.ts ---

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
I’ll verify the connector against the repository context it cites: exported surface, Cash Conductor tools references, autosend policy entries, and the specific escalation/citation claims that affect ratification.
exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/open-banking/README.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# @ifos/open-banking
     2	
     3	UK Open Banking connector for IFOS Cash Conductor (W4-W7 build wave per master brief §8.2 + ULTRAPLAN §8.1 A4). Provider abstraction over **TrueLayer (v1.0)** + **Plaid UK (v1.1+ deferred)** with PSD2 90-day consent tracking + token-aging stages. Used by Cash Conductor for bank-transaction ingest + cash-flow forecast balance reads.
     4	
     5	**Status:** Proposed (W4 Day-26 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F + first TrueLayer dev signup for live-test verification).
     6	
     7	**Reference pattern:** mirrors `@ifos/xero` + `@ifos/quickbooks` structure. The PSD2 consent lifecycle is the load-bearing structural difference vs the accounting connectors — banks legally require user re-authentication every 90 days regardless of refresh-token TTL.
     8	
     9	---
    10	
    11	## Capabilities
    12	
    13	Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/cash-conductor/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.
    14	
    15	| Capability ID (tools.yaml) | Function (src/index.ts) | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
    16	|---|---|---|---|---|---|
    17	| `open_banking_truelayer_oauth` | `refreshTokens(config, current, fetchFn?, now?)` (provider='truelayer') | OAuth refresh; concurrent-safe per (provider, connection_id); **refuses if consent is in PSD2 blocking window (≤7 days)** | Step 1 (auth refresh) | `open_banking_truelayer` | green |
    18	| `open_banking_plaid_uk_oauth` (v1.1+ stub) | `refreshTokens(config, current, fetchFn?, now?)` (provider='plaid-uk') | Plaid UK OAuth refresh — interface in place; implementation throws `NotImplementedError` until v1.1+ | (never fires v1.0) | `open_banking_plaid_uk` | green |
    19	| `open_banking_list_transactions` | `listTransactionsSince(client, config, options)` | List bank transactions on/after a timestamp; provider-agnostic shape; TrueLayer raw payload preserved in `raw_provider_payload` | Step 3 (transaction ingest) | n/a (read-only) | n/a |
    20	| `open_banking_get_account_balance` | `getAccountBalance(client, config)` | Current account balance (available + cleared) | Step 10 (cash-flow forecast) | n/a (read-only) | n/a |
    21	
    22	All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (verified 2026-06-01 Codex F-R2 closure — both `open_banking_truelayer` and `open_banking_plaid_uk` registered as green).
    23	
    24	### Internal helpers (NOT bus-routed capabilities)
    25	
    26	Exposed by `src/index.ts` for consumer convenience + testing, but NOT declared in `tools.yaml`:
    27	
    28	| Function | Purpose |
    29	|---|---|
    30	| `OpenBankingClient` (class) | Transport — constructed once by cycle.sh Step 1; provider-aware base URL (TrueLayer prod/sandbox; Plaid UK v1.1+) |
    31	| `loadTokens(config)` / `saveTokens(config, t)` | Token-file I/O — includes the load-bearing PSD2 `consent_expires_at_ms` field; surfaced for test setup + operator consent-bootstrap |
    32	| `shouldRefresh(tokens, now?, window?)` | Pure predicate — `true` when the access_token expires within `safety_window_ms` (default 5 min) |
    33	| `getTokenAgeStage(tokens, now?)` | Pure predicate — returns `{stage: 'fresh'|'info'|'warn'|'blocking', days_until_consent_expiry}`; staged-severity hook for operator alerting via `ESC_OPEN_BANKING_TOKEN_AGING` |
    34	| `rateCheck(key, now?)` | Returns `RateState` — exposes soft-backoff signal at 80% (24/min) of the conservative 30/min ceiling; consumer responsible for honouring it |
    35	| `rateConsume(key, now?)` | Consumes a slot; returns false at the hard 100% gate |
    36	| `resetRateLimit(key?)` | Test/diagnostic reset |
    37	| `_resetInflightForTest()` | Clears in-flight OAuth-refresh dedup map; for tests only |
    38	| `OpenBankingCache` (class) | Disk cache — transactions TTL 5min; balance TTL 0 (always fresh) |
    39	
    40	---
    41	
    42	## PSD2 consent lifecycle (the load-bearing distinction)
    43	
    44	UK Open Banking is regulated by PSD2 + the OBIE standards. The KEY constraint vs other OAuth flows:
    45	
    46	> **PSD2 requires the user to re-authenticate to their bank every 90 days**, regardless of whether the refresh_token would otherwise still be valid.
    47	
    48	This means the connector tracks TWO expiry timestamps per token bundle:
    49	
    50	1. **`expires_at_ms`** — access_token expiry (typical ~1 hour). Routine refresh via `refreshTokens()` rotates this transparently.
    51	2. **`consent_expires_at_ms`** — PSD2 consent expiry (~90 days from the user's last successful re-authentication). When this hits, the refresh_token itself becomes invalid; the user MUST re-do the PSD2 consent dance.
    52	
    53	`getTokenAgeStage()` is the pure classifier the agent uses to alert the operator BEFORE consent dies. Stages, with the cycle.sh / agent.md §6 mapping to `ESC_OPEN_BANKING_TOKEN_AGING`:
    54	
    55	| Days until consent expiry | Stage | Agent behaviour |
    56	|---|---|---|
    57	| > 30 | `fresh` | (no alert) |
    58	| 15-30 | `info` | log + monitor (operator-aware; nothing breaks) |
    59	| 8-14 | `warn` | escalate to operator chat (`ESC_OPEN_BANKING_TOKEN_AGING` severity warn) |
    60	| 0-7 | `blocking` | **HARD STOP** — `refreshTokens()` refuses to issue a new access token; operator MUST re-do PSD2 consent dance with the user before Cash Conductor can resume |
    61	| < 0 | `blocking` (already expired) | same |
    62	
    63	The blocking-window refusal is enforced server-side by the bank too (refresh_token will 401 once consent expires), but the client-side check fires sooner and with better error messaging (`OpenBankingConsentExpiredError` with explicit guidance).
    64	
    65	`tests/token-aging.test.ts` exhaustively tests the day 0-100 boundary classification per goal-w4-day-26 Phase 2 Step 7 requirement.
    66	
    67	---
    68	
    69	## Quick start
    70	
    71	```typescript
    72	import {
    73	  OpenBankingClient,
    74	  listTransactionsSince,
    75	  getAccountBalance,
    76	  getTokenAgeStage,
    77	  loadTokens,
    78	} from "@ifos/open-banking";
    79	
    80	const config = {
    81	  provider: "truelayer" as const,
    82	  client_id: process.env.TRUELAYER_CLIENT_ID!,
    83	  client_secret: process.env.TRUELAYER_CLIENT_SECRET!,
    84	  connection_id: "<truelayer-account-id>",
    85	  environment: "sandbox" as const,
    86	  token_file_path: `${process.env.HOME}/.ifos-local-vault/<ifos-tenant>/ob-tokens-<account-id>.json`,
    87	};
    88	
    89	// Operator-side: check consent age first
    90	const tokens = await loadTokens(config);
    91	if (tokens) {
    92	  const age = getTokenAgeStage(tokens);
    93	  if (age.stage === "blocking") {
    94	    throw new Error("PSD2 consent expired — re-do consent dance before continuing");
    95	  }
    96	}
    97	
    98	const client = new OpenBankingClient({ config });
    99	const transactions = await listTransactionsSince(client, config, {
   100	  since: "2026-05-01T00:00:00Z",
   101	});
   102	const balance = await getAccountBalance(client, config);
   103	```
   104	
   105	---
   106	
   107	## OAuth bootstrap (one-time per bank connection)
   108	
   109	The connector handles the **refresh** half. The **initial consent dance** (user → bank login → consent → authorisation code → first token pair) is a one-time human-in-the-loop flow:
   110	
   111	1. Register the IFOS app at https://console.truelayer.com/ (TrueLayer) → get `client_id` + `client_secret`.
   112	2. Construct the authorise URL: scope=`accounts transactions balance offline_access`, response_type=code, redirect_uri=your callback, provider_id=`uk-ob-<bank>`.
   113	3. User → bank login → consent screen → bank redirects to your `redirect_uri?code=<auth_code>&scope=...`.
   114	4. POST to `https://auth.truelayer-sandbox.com/connect/token` (or `auth.truelayer.com` for prod) with `grant_type=authorization_code` + the code → receive `{access_token, refresh_token, expires_in}`.
   115	5. Call `GET https://api.truelayer-sandbox.com/data/v1/accounts` with the access_token → get the `account_id`(s) for this connection.
   116	6. Compute `consent_expires_at_ms = Date.now() + 90 * 24 * 60 * 60 * 1000` (PSD2 default). When the user re-consents in the future, recompute.
   117	7. Write the token bundle to `token_file_path` as JSON (mode 0600) — include both `expires_at_ms` AND `consent_expires_at_ms`. The connector handles all subsequent rotations automatically.
   118	
   119	For Plaid UK (v1.1+): pattern is similar but uses `POST /link/token/create` then exchange of public_token → access_token. Interface is in place; implementation is deferred — `NotImplementedError` thrown today.
   120	
   121	---
   122	
   123	## Rate limits
   124	
   125	Conservative per-provider buckets per `src/rate-limit.ts`. Upstream published-limits pages:
   126	
   127	- **TrueLayer:** https://docs.truelayer.com/docs/data-api-rate-limits — production prod-API limits are tier-dependent and not exposed as a single public number; sandbox is documented at 30/min/connection. We use the sandbox figure as the conservative ceiling for production too — it can be tuned upward when Cash Conductor cycle.sh telemetry shows actual usage patterns.
   128	- **Plaid UK:** https://plaid.com/docs/errors/rate-limit-exceeded/ — Plaid Standard tier publishes a 600/min per-Item ceiling; we use 30/min as the conservative starting point until v1.1+ pilots show real load.
   129	
   130	| Provider | Local hard cap (this connector) | Local soft (80%) | Upstream documented |
   131	|---|---|---|---|
   132	| TrueLayer | 30 calls/min per (provider, connection_id) | 24/min | sandbox 30/min; prod tier-dependent |
   133	| Plaid UK | 30 calls/min per (provider, item_id) | 24/min | 600/min per-Item (Standard tier) |
   134	
   135	**Hard gate at 100%** (`consume()` returns false → `OpenBankingRateLimitError`). **Soft signal at 80%** (24/min) is read-only and exposed via `rateCheck()` — `RateState.shouldBackoff === true` with `reason: "minute-soft"`. The consuming agent layer (Cash Conductor cycle.sh) is responsible for honouring the soft signal; the connector does not silently throttle.
   136	
   137	State is in-process and per-(provider, connection_id) — a multi-bank-account runtime that holds many `OpenBankingClient` instances in one process still gets correct isolation.
   138	
   139	**ESC contract on bucket exhaustion** (consumer-emitted via `agents/_shared/hook-helpers.sh`):
   140	
   141	| Failure | Surfaces as | ESC code (escalation-codes.md) | Payload contract |
   142	|---|---|---|---|
   143	| Local hard-gate (100%) reached | `OpenBankingRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "truelayer" | "plaid-uk", retry_after_seconds: null, consecutive_429s: 0}` |
   144	| Upstream 429 from provider API | `OpenBankingRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "truelayer" | "plaid-uk", retry_after_seconds: <N>, consecutive_429s: <N>}` |
   145	
   146	---
   147	
   148	## Retry policy
   149	
   150	| Capability | Method | Max retries | Backoff | On exhaustion |
   151	|---|---|---|---|---|
   152	| `listTransactionsSince` / `getAccountBalance` | GET | 2 | Exponential w/ jitter (250-1000ms) | `OpenBankingError` / `OpenBankingRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
   153	| `refreshTokens` | POST | **0** | n/a | `OpenBankingAuthError` → `ESC_OPEN_BANKING_AUTH` (**blocking**; consumer-emitted; routes operator + ifos_oncall per escalation-codes.md lines 288-294; payload `failure_type: 'refresh_failed'`) |
   154	| `refreshTokens` blocked by PSD2 consent expiry | POST | **0** | n/a | `OpenBankingConsentExpiredError` → `ESC_OPEN_BANKING_AUTH` (blocking; payload `failure_type: 'consent_expired_90d'`); user must re-do SCA per Bootstrap § |
   155	| 401 from any GET | — | force-refresh access_token, retry once | — | `OpenBankingAuthError` → `ESC_OPEN_BANKING_AUTH` |
   156	| 429 from any GET | — | honour `Retry-After` header | jittered backoff if no header | `OpenBankingRateLimitError` → `ESC_RATE_LIMIT_HIT` |
   157	
   158	The only state-changing op is OAuth refresh (which has its own consent-aware refusal logic via `getTokenAgeStage`). All transaction/balance calls are read-only — banks don't generally expose write APIs in the scope Cash Conductor needs. The connector does NOT write `decision_log` rows (vault/Postgres split per ADR-002); the consuming `cycle.sh` catches the typed errors above and emits the right ESC via `hh_decision_action`/`hh_decision_output` from `agents/_shared/hook-helpers.sh`.
   159	
   160	The separate **PSD2 token-aging signal** — `ESC_OPEN_BANKING_TOKEN_AGING` (staged info → warn → blocking per consent-expiry distance) — is emitted by the consumer based on `getTokenAgeStage()` BEFORE refresh fails. That's a different code path from the refresh-failure mapping above; see `agents/_shared/escalation-codes.md` lines 296-307 for the staged severity definition and `agents/recruitment/cash-conductor/agent.md` §6 for the consumer flow.
   161	
   162	---
   163	
   164	## Error hierarchy
   165	
   166	```
   167	OpenBankingError                  // base
   168	├── OpenBankingAuthError          // OAuth refresh fail (4xx on token endpoint)
   169	│   └── OpenBankingConsentExpiredError  // PSD2 90-day consent dead; re-consent required
   170	├── OpenBankingRateLimitError     // 429 OR local bucket exhausted
   171	├── OpenBankingNotFoundError      // 404
   172	└── NotImplementedError           // Plaid UK during v1.0 (interface defined; impl deferred)
   173	```
   174	
   175	Errors NEVER include credential values; only key names, status codes, safe metadata.
   176	
   177	---
   178	
   179	## Tests
   180	
   181	```bash
   182	# Unit + fixture tests (fast; no network)
   183	pnpm test
   184	```
   185	
   186	**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses shape-pinned JSON fixtures under `fixtures/`.
   187	
   188	**Live tests are deferred** to the first TrueLayer dev signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal — review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold will land in the same commit as the first sandbox credentials per the W4 Track-1 /goal §1 commercial-gate; the fixture-first suite below is fully sufficient for the W4 ratification pass.
   189	
   190	Test counts (W4 Day-26 scaffold):
   191	- `tests/scaffold.test.ts`: 5 (public surface, exports, full error hierarchy with NotImplementedError)
   192	- `tests/rate-limit.test.ts`: 5 (initial state, soft 24, hard 30, per-(provider, connection) isolation)
   193	- `tests/token-aging.test.ts`: 6 (property-based day 0-100 boundary: fresh, info, warn, blocking, negative/already-expired, days_until consistency)
   194	- `tests/auth.test.ts`: 8 (load missing, round-trip, shouldRefresh, refresh success + consent_expires preserved, 401 + no-token-leak, **blocking-consent refuses refresh**, concurrent dedup, Plaid-UK NotImplementedError)
   195	- `tests/capabilities.test.ts`: 4 (TrueLayer transactions + balance from fixtures; Plaid UK NotImplementedError for both)
   196	
   197	**Total: 28 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).
   198	
   199	---
   200	
   201	## Build
   202	
   203	```bash
   204	pnpm build       # tsup → dist/index.{js,d.ts}
   205	pnpm typecheck   # tsc --noEmit
   206	```
   207	
   208	ESM-only; node 20+; target ES2022. Same toolchain as other MCP connectors.
   209	
   210	---
   211	
   212	## Where this fits in the IFOS architecture
   213	
   214	```
   215	agents/recruitment/cash-conductor/cycle.sh
   216	   │
   217	   ├── Step 1  (auth refresh + consent age check)  ──┐
   218	   ├── Step 3  (bank transaction ingest)            ──┼─→ @ifos/open-banking (this package)
   219	   └── Step 10 (weekly cash-flow forecast balance)  ──┘    │
   220	                                                          ↓
   221	                                                     TrueLayer or Plaid UK
   222	                                                     (provider chosen at config time)
   223	                                                          ↓
   224	                                                     OAuth bearer (PSD2-consented)
   225	```
   226	
   227	Cash Conductor's full bundle (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures) lands later in W4-7 per `agents/recruitment/cash-conductor/agent.md` §8. This connector is one of the substrate dependencies (alongside the accounting connector chosen per tenant).
   228	
   229	---
   230	
   231	## Boundary checks
   232	
   233	Per `review-mcp-connector.md` §8:
   234	- ✓ No Composio / AgentMail references
   235	- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
   236	- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)
   237	- ✓ No hardcoded tenant slugs in `src/` (test fixtures only)
   238	
   239	---
   240	
   241	*v0.1.0 — scaffold landed 2026-06-01 (W4 Day-26).*

exec
/bin/zsh -lc 'rg --files packages/mcp-connectors/open-banking agents/recruitment/cash-conductor agents/_shared | sort' in /Users/madsadmin/code/CortexOS
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
packages/mcp-connectors/open-banking/README.md
packages/mcp-connectors/open-banking/fixtures/truelayer-balance.json
packages/mcp-connectors/open-banking/fixtures/truelayer-transactions.json
packages/mcp-connectors/open-banking/package.json
packages/mcp-connectors/open-banking/src/auth.ts
packages/mcp-connectors/open-banking/src/balance.ts
packages/mcp-connectors/open-banking/src/cache.ts
packages/mcp-connectors/open-banking/src/client.ts
packages/mcp-connectors/open-banking/src/errors.ts
packages/mcp-connectors/open-banking/src/index.ts
packages/mcp-connectors/open-banking/src/rate-limit.ts
packages/mcp-connectors/open-banking/src/transactions.ts
packages/mcp-connectors/open-banking/src/types.ts
packages/mcp-connectors/open-banking/tests/auth.test.ts
packages/mcp-connectors/open-banking/tests/capabilities.test.ts
packages/mcp-connectors/open-banking/tests/rate-limit.test.ts
packages/mcp-connectors/open-banking/tests/scaffold.test.ts
packages/mcp-connectors/open-banking/tests/token-aging.test.ts
packages/mcp-connectors/open-banking/tsconfig.json
packages/mcp-connectors/open-banking/tsup.config.ts
packages/mcp-connectors/open-banking/vitest.config.ts

exec
/bin/zsh -lc 'nl -ba packages/mcp-connectors/open-banking/src/index.ts && nl -ba packages/mcp-connectors/open-banking/src/client.ts && nl -ba packages/mcp-connectors/open-banking/src/auth.ts && nl -ba packages/mcp-connectors/open-banking/src/rate-limit.ts' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// @ifos/open-banking — public API
     2	//
     3	// The exports below split into TWO groups per review-mcp-connector §1 +
     4	// README §"Capabilities":
     5	//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
     6	//       on agents/recruitment/cash-conductor/tools.yaml AND (for state-changing
     7	//       capabilities) has an action_type entry in agents/_shared/autosend-policy.yaml.
     8	//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
     9	//       declared as bus capabilities (no action_type; no authz check).
    10	//
    11	// Provider scope (W4 Day-26):
    12	//   - TrueLayer: fully implemented (v1.0 path per Cash Conductor §9 Q2).
    13	//   - Plaid UK: interface present; implementation throws NotImplementedError
    14	//     until v1.1+ (no UK Cash Conductor pilot needs Plaid at v1.0).
    15	//
    16	// PSD2 90-day consent tracking is THE load-bearing distinction from Xero / QB:
    17	// banks legally require user re-authentication every 90 days regardless of
    18	// refresh-token TTL. See auth.ts getTokenAgeStage + README §"PSD2 consent lifecycle".
    19	
    20	// ─────────────────────────────────────────────────────────────────────────
    21	// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §open-banking)
    22	// ─────────────────────────────────────────────────────────────────────────
    23	
    24	// open_banking_truelayer_oauth (action_type: open_banking_truelayer, green tier)
    25	// open_banking_plaid_uk_oauth — same function with provider='plaid-uk'; throws
    26	// NotImplementedError until v1.1+; action_type open_banking_plaid_uk green tier
    27	// per autosend-policy.yaml (registered for set-equality even though it never
    28	// fires in v1.0).
    29	export { refreshTokens } from "./auth.js";
    30	// open_banking_list_transactions (read-only)
    31	export { listTransactionsSince } from "./transactions.js";
    32	// open_banking_get_account_balance (read-only)
    33	export { getAccountBalance } from "./balance.js";
    34	
    35	// ─────────────────────────────────────────────────────────────────────────
    36	// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
    37	// ─────────────────────────────────────────────────────────────────────────
    38	
    39	// Transport class — constructed once by cycle.sh Step 1; provider-aware base URL
    40	export {
    41	  OpenBankingClient,
    42	  TRUELAYER_API_PROD,
    43	  TRUELAYER_API_SANDBOX,
    44	  DEFAULT_TIMEOUT_MS,
    45	} from "./client.js";
    46	// Token-file I/O + pure predicates (shouldRefresh for access-token age;
    47	// getTokenAgeStage for PSD2 consent-expiry staged alerting)
    48	export {
    49	  loadTokens,
    50	  saveTokens,
    51	  shouldRefresh,
    52	  getTokenAgeStage,
    53	} from "./auth.js";
    54	// Disk cache (transactions TTL 5min; balance TTL 0)
    55	export { OpenBankingCache } from "./cache.js";
    56	// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
    57	// consumer responsible for honouring shouldBackoff at the 80% soft threshold;
    58	// hard 100% gate is enforced inside rateConsume()).
    59	export {
    60	  check as rateCheck,
    61	  consume as rateConsume,
    62	  reset as resetRateLimit,
    63	} from "./rate-limit.js";
    64	// Test/diagnostic
    65	export { _resetInflightForTest } from "./auth.js";
    66	// Error hierarchy (OpenBankingConsentExpiredError + NotImplementedError are
    67	// load-bearing for the consumer's branching logic)
    68	export {
    69	  OpenBankingError,
    70	  OpenBankingAuthError,
    71	  OpenBankingConsentExpiredError,
    72	  OpenBankingRateLimitError,
    73	  OpenBankingNotFoundError,
    74	  NotImplementedError,
    75	} from "./errors.js";
    76	export type {
    77	  OpenBankingProvider,
    78	  OpenBankingTokens,
    79	  OpenBankingConfig,
    80	  OpenBankingTransaction,
    81	  OpenBankingBalance,
    82	  TokenAgeStage,
    83	  TokenAgeReport,
    84	  OpenBankingClientOptions,
    85	} from "./types.js";
    86	export type { RateState } from "./rate-limit.js";
    87	
    88	export const VERSION = "0.1.0";
     1	// Open Banking HTTP client façade — provider-aware (TrueLayer fully implemented;
     2	// Plaid UK stubbed for v1.1+). Wraps fetch with: OAuth token attach, rate-limit
     3	// budget, 429 retry-after, 5xx exponential backoff, 4xx surface as typed errors.
     4	
     5	import {
     6	  NotImplementedError,
     7	  OpenBankingAuthError,
     8	  OpenBankingError,
     9	  OpenBankingNotFoundError,
    10	  OpenBankingRateLimitError,
    11	} from "./errors.js";
    12	import { consume } from "./rate-limit.js";
    13	import { loadTokens, refreshTokens, shouldRefresh } from "./auth.js";
    14	import type { OpenBankingClientOptions, OpenBankingTokens } from "./types.js";
    15	
    16	export const TRUELAYER_API_PROD = "https://api.truelayer.com";
    17	export const TRUELAYER_API_SANDBOX = "https://api.truelayer-sandbox.com";
    18	export const DEFAULT_TIMEOUT_MS = 15_000;
    19	
    20	interface RequestOptions {
    21	  method?: "GET" | "POST";
    22	  query?: Record<string, string>;
    23	  max_retries?: number;
    24	  signal?: AbortSignal;
    25	}
    26	
    27	function sleep(ms: number): Promise<void> {
    28	  return new Promise((r) => setTimeout(r, ms));
    29	}
    30	
    31	function backoff(attempt: number): number {
    32	  const base = 250 * 2 ** attempt;
    33	  return Math.floor(Math.random() * base);
    34	}
    35	
    36	export class OpenBankingClient {
    37	  private readonly opts: OpenBankingClientOptions;
    38	  private readonly fetchFn: typeof fetch;
    39	  private readonly now: () => number;
    40	  private current_tokens: OpenBankingTokens | null = null;
    41	  private readonly base_url: string;
    42	
    43	  constructor(opts: OpenBankingClientOptions) {
    44	    this.opts = opts;
    45	    this.fetchFn = opts.fetchFn ?? fetch;
    46	    this.now = opts.now ?? Date.now;
    47	    if (opts.config.provider === "plaid-uk") {
    48	      // Plaid UK API URL would land here; v1.1+ deferred.
    49	      this.base_url = "https://plaid-uk-not-yet-implemented.invalid";
    50	    } else {
    51	      this.base_url =
    52	        opts.config.environment === "production"
    53	          ? TRUELAYER_API_PROD
    54	          : TRUELAYER_API_SANDBOX;
    55	    }
    56	  }
    57	
    58	  async getValidAccessToken(): Promise<string> {
    59	    if (!this.current_tokens) {
    60	      this.current_tokens = await loadTokens(this.opts.config);
    61	      if (!this.current_tokens) {
    62	        throw new OpenBankingAuthError(
    63	          `No ${this.opts.config.provider} tokens on disk; PSD2 consent + initial token exchange required to bootstrap token_file_path (run the one-time OAuth authorise flow per README §Bootstrap)`,
    64	        );
    65	      }
    66	    }
    67	    if (shouldRefresh(this.current_tokens, this.now)) {
    68	      this.current_tokens = await refreshTokens(
    69	        this.opts.config,
    70	        this.current_tokens,
    71	        this.fetchFn,
    72	        this.now,
    73	      );
    74	    }
    75	    return this.current_tokens.access_token;
    76	  }
    77	
    78	  /** Low-level request. Capability helpers (transactions, balance) use this. */
    79	  async request<T>(path: string, options: RequestOptions = {}): Promise<T> {
    80	    if (this.opts.config.provider === "plaid-uk") {
    81	      throw new NotImplementedError(
    82	        "Plaid UK provider client not yet implemented (v1.1+ deferred). Use provider: 'truelayer' for v1.0.",
    83	      );
    84	    }
    85	
    86	    const method = options.method ?? "GET";
    87	    const max_retries = options.max_retries ?? 2;
    88	
    89	    const url = new URL(this.base_url + path);
    90	    if (options.query) {
    91	      for (const [k, v] of Object.entries(options.query)) {
    92	        url.searchParams.set(k, v);
    93	      }
    94	    }
    95	
    96	    let last_error: unknown = null;
    97	    for (let attempt = 0; attempt <= max_retries; attempt++) {
    98	      const allowed = consume(
    99	        this.opts.config.provider,
   100	        this.opts.config.connection_id,
   101	        this.now,
   102	      );
   103	      if (!allowed) {
   104	        throw new OpenBankingRateLimitError(
   105	          `Open Banking rate-limit budget exhausted (provider=${this.opts.config.provider}, connection=${this.opts.config.connection_id})`,
   106	        );
   107	      }
   108	
   109	      const access_token = await this.getValidAccessToken();
   110	      const headers: Record<string, string> = {
   111	        Authorization: `Bearer ${access_token}`,
   112	        Accept: "application/json",
   113	      };
   114	
   115	      let res: Response;
   116	      try {
   117	        res = await this.fetchFn(url.toString(), {
   118	          method,
   119	          headers,
   120	          signal: options.signal,
   121	        });
   122	      } catch (e) {
   123	        last_error = e;
   124	        if (attempt < max_retries) {
   125	          await sleep(backoff(attempt));
   126	          continue;
   127	        }
   128	        throw new OpenBankingError(
   129	          `Open Banking network error after ${attempt + 1} attempt(s) on ${method} ${path}`,
   130	        );
   131	      }
   132	
   133	      if (res.ok) {
   134	        return (await res.json()) as T;
   135	      }
   136	
   137	      if (res.status === 401 && attempt < max_retries) {
   138	        this.current_tokens = null;
   139	        await sleep(backoff(attempt));
   140	        continue;
   141	      }
   142	
   143	      if (res.status === 429 && attempt < max_retries) {
   144	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   145	        const waitMs = retryAfter > 0 ? retryAfter * 1000 : backoff(attempt);
   146	        await sleep(waitMs);
   147	        continue;
   148	      }
   149	      if (res.status === 429) {
   150	        const retryAfter = parseInt(res.headers.get("Retry-After") ?? "0", 10);
   151	        throw new OpenBankingRateLimitError(
   152	          `Open Banking returned 429 after ${attempt + 1} attempt(s)`,
   153	          retryAfter > 0 ? retryAfter : null,
   154	        );
   155	      }
   156	
   157	      if (res.status >= 500 && attempt < max_retries) {
   158	        await sleep(backoff(attempt));
   159	        continue;
   160	      }
   161	
   162	      if (res.status === 404) {
   163	        throw new OpenBankingNotFoundError(`Open Banking 404 on ${method} ${path}`);
   164	      }
   165	      throw new OpenBankingError(
   166	        `Open Banking ${method} ${path} failed (HTTP ${res.status})`,
   167	        res.status,
   168	      );
   169	    }
   170	    throw new OpenBankingError(
   171	      `Open Banking ${method} ${path} exhausted retries (${last_error ?? "unknown"})`,
   172	    );
   173	  }
   174	}
     1	// Open Banking OAuth refresh + PSD2 90-day consent tracking + token-aging stages.
     2	//
     3	// PSD2 mandates that users re-authenticate every 90 days regardless of whether
     4	// the refresh token would otherwise still be valid. This package's auth layer
     5	// tracks BOTH:
     6	//   - access_token expiry (typical ~1h) → refresh transparently
     7	//   - consent expiry (~90 days from initial consent) → emit ESC_OPEN_BANKING_TOKEN_AGING
     8	//     stages so the agent can notify the operator before the consent dies
     9	//
    10	// Token-aging stages (per Cash Conductor agent.md §6):
    11	//   - fresh:    > 30 days to consent expiry
    12	//   - info:     ≤ 30 days  (operator-aware; nothing breaks)
    13	//   - warn:     ≤ 14 days  (escalate to operator chat)
    14	//   - blocking: ≤ 7  days  (HARD STOP — must re-consent; refuses to issue new access tokens)
    15	//
    16	// Provider scope (W4 Day-26):
    17	//   - TrueLayer: full OAuth refresh implemented.
    18	//   - Plaid UK: refreshTokens throws NotImplementedError (v1.1+).
    19	
    20	import { promises as fs } from "node:fs";
    21	import {
    22	  NotImplementedError,
    23	  OpenBankingAuthError,
    24	  OpenBankingConsentExpiredError,
    25	} from "./errors.js";
    26	import type {
    27	  OpenBankingConfig,
    28	  OpenBankingTokens,
    29	  TokenAgeReport,
    30	  TokenAgeStage,
    31	} from "./types.js";
    32	
    33	const TRUELAYER_TOKEN_ENDPOINT_PROD =
    34	  "https://auth.truelayer.com/connect/token";
    35	const TRUELAYER_TOKEN_ENDPOINT_SANDBOX =
    36	  "https://auth.truelayer-sandbox.com/connect/token";
    37	
    38	const DAY_MS = 24 * 60 * 60 * 1000;
    39	
    40	const inflight: Map<string, Promise<OpenBankingTokens>> = new Map();
    41	
    42	/** Read token file from disk; returns null if missing/malformed. */
    43	export async function loadTokens(
    44	  config: OpenBankingConfig,
    45	): Promise<OpenBankingTokens | null> {
    46	  let raw: string;
    47	  try {
    48	    raw = await fs.readFile(config.token_file_path, "utf8");
    49	  } catch {
    50	    return null;
    51	  }
    52	  try {
    53	    const parsed = JSON.parse(raw) as OpenBankingTokens;
    54	    if (
    55	      typeof parsed.access_token !== "string" ||
    56	      typeof parsed.refresh_token !== "string" ||
    57	      typeof parsed.expires_at_ms !== "number" ||
    58	      typeof parsed.consent_expires_at_ms !== "number"
    59	    ) {
    60	      return null;
    61	    }
    62	    return parsed;
    63	  } catch {
    64	    return null;
    65	  }
    66	}
    67	
    68	/** Atomic save: write to <path>.tmp then rename. */
    69	export async function saveTokens(
    70	  config: OpenBankingConfig,
    71	  tokens: OpenBankingTokens,
    72	): Promise<void> {
    73	  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
    74	  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
    75	  await fs.rename(tmpPath, config.token_file_path);
    76	}
    77	
    78	/** Returns true if access token expires within the next `safety_window_ms` (default 5 min). */
    79	export function shouldRefresh(
    80	  tokens: OpenBankingTokens,
    81	  now: () => number = Date.now,
    82	  safety_window_ms = 5 * 60 * 1000,
    83	): boolean {
    84	  return tokens.expires_at_ms - now() < safety_window_ms;
    85	}
    86	
    87	/**
    88	 * Pure function: classify token age based on days to PSD2 consent expiry.
    89	 * Property-tested across day 0-100 boundary.
    90	 */
    91	export function getTokenAgeStage(
    92	  tokens: OpenBankingTokens,
    93	  now: () => number = Date.now,
    94	): TokenAgeReport {
    95	  const days = (tokens.consent_expires_at_ms - now()) / DAY_MS;
    96	  let stage: TokenAgeStage;
    97	  if (days <= 7) stage = "blocking";
    98	  else if (days <= 14) stage = "warn";
    99	  else if (days <= 30) stage = "info";
   100	  else stage = "fresh";
   101	  return {
   102	    stage,
   103	    days_until_consent_expiry: days,
   104	    consent_expires_at_ms: tokens.consent_expires_at_ms,
   105	  };
   106	}
   107	
   108	/**
   109	 * Refresh OAuth tokens. Provider-aware: TrueLayer fully implemented; Plaid UK
   110	 * throws NotImplementedError. Concurrent-safe per (provider, connection_id).
   111	 *
   112	 * Refuses refresh if consent age is "blocking" — operator MUST re-do the PSD2
   113	 * consent dance with the user first.
   114	 */
   115	export async function refreshTokens(
   116	  config: OpenBankingConfig,
   117	  current_tokens: OpenBankingTokens,
   118	  fetchFn: typeof fetch = fetch,
   119	  now: () => number = Date.now,
   120	): Promise<OpenBankingTokens> {
   121	  // Consent-age hard stop BEFORE attempting refresh
   122	  const ageReport = getTokenAgeStage(current_tokens, now);
   123	  if (ageReport.stage === "blocking") {
   124	    throw new OpenBankingConsentExpiredError(
   125	      `PSD2 consent within ${Math.max(0, Math.floor(ageReport.days_until_consent_expiry))} days of expiry; ` +
   126	        `re-consent required before refresh (provider=${config.provider}, connection_id=${config.connection_id})`,
   127	    );
   128	  }
   129	
   130	  if (config.provider === "plaid-uk") {
   131	    throw new NotImplementedError(
   132	      "Plaid UK OAuth refresh not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2; v1.0 path is TrueLayer)",
   133	    );
   134	  }
   135	
   136	  const lockKey = `${config.provider}:${config.connection_id}`;
   137	  const existing = inflight.get(lockKey);
   138	  if (existing) return existing;
   139	
   140	  const tokenEndpoint =
   141	    config.environment === "production"
   142	      ? TRUELAYER_TOKEN_ENDPOINT_PROD
   143	      : TRUELAYER_TOKEN_ENDPOINT_SANDBOX;
   144	
   145	  const promise = (async () => {
   146	    try {
   147	      const body = new URLSearchParams({
   148	        grant_type: "refresh_token",
   149	        client_id: config.client_id,
   150	        client_secret: config.client_secret,
   151	        refresh_token: current_tokens.refresh_token,
   152	      });
   153	
   154	      const res = await fetchFn(tokenEndpoint, {
   155	        method: "POST",
   156	        headers: {
   157	          "Content-Type": "application/x-www-form-urlencoded",
   158	          Accept: "application/json",
   159	        },
   160	        body,
   161	      });
   162	
   163	      if (!res.ok) {
   164	        // Never include the response body verbatim — TrueLayer may echo
   165	        // the (now-invalid) refresh_token in error responses.
   166	        throw new OpenBankingAuthError(
   167	          `TrueLayer OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
   168	          res.status,
   169	          res.status === 401 ? "refresh_token_revoked" : "credentials",
   170	        );
   171	      }
   172	
   173	      const data = (await res.json()) as {
   174	        access_token: string;
   175	        refresh_token: string;
   176	        expires_in: number;
   177	        scope?: string;
   178	        token_type: string;
   179	      };
   180	
   181	      // TrueLayer does NOT extend the PSD2 consent on refresh — only the
   182	      // access_token rotates. Preserve the consent_expires_at_ms from
   183	      // current_tokens; the consent dance has its own re-authentication flow.
   184	      const new_tokens: OpenBankingTokens = {
   185	        access_token: data.access_token,
   186	        refresh_token: data.refresh_token,
   187	        expires_at_ms: now() + data.expires_in * 1000,
   188	        consent_expires_at_ms: current_tokens.consent_expires_at_ms,
   189	        scope: data.scope ?? current_tokens.scope,
   190	        token_type: data.token_type,
   191	      };
   192	
   193	      await saveTokens(config, new_tokens);
   194	      return new_tokens;
   195	    } finally {
   196	      inflight.delete(lockKey);
   197	    }
   198	  })();
   199	
   200	  inflight.set(lockKey, promise);
   201	  return promise;
   202	}
   203	
   204	/** Test helper — clears the in-flight refresh map. */
   205	export function _resetInflightForTest(): void {
   206	  inflight.clear();
   207	}
     1	// Rate limiter for Open Banking providers. Conservative per-provider buckets;
     2	// per-(provider, connection_id) state for multi-bank isolation.
     3	//
     4	// TrueLayer published limits (https://docs.truelayer.com/docs/api-overview):
     5	//   Production: not publicly numbered; sandbox often constrained to ~10/min
     6	//   per connection. We use a conservative 30/min cap with 24/min soft.
     7	// Plaid UK published limits (https://plaid.com/docs/api/rate-limits/):
     8	//   Standard tier: 30 calls/minute per item. Same cap structure.
     9	//
    10	// Both providers handle rate-limit-friendly behaviour at the protocol layer
    11	// (429 + Retry-After honoured by client.ts).
    12	
    13	const MINUTE_MS = 60 * 1000;
    14	const MINUTE_HARD = 30;
    15	const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 24
    16	
    17	const minuteTimestamps: Map<string, number[]> = new Map();
    18	
    19	export interface RateState {
    20	  provider_connection_key: string;
    21	  minute_used: number;
    22	  minute_remaining: number;
    23	  shouldBackoff: boolean;
    24	  reason: "ok" | "minute-soft" | "minute-hard";
    25	}
    26	
    27	function key(provider: string, connection_id: string): string {
    28	  return `${provider}:${connection_id}`;
    29	}
    30	
    31	function pruneMinute(arr: number[] | undefined, now: number): number[] {
    32	  if (!arr) return [];
    33	  return arr.filter((ts) => now - ts < MINUTE_MS);
    34	}
    35	
    36	export function check(
    37	  provider: string,
    38	  connection_id: string,
    39	  now: () => number = Date.now,
    40	): RateState {
    41	  const k = key(provider, connection_id);
    42	  const t = now();
    43	  const minute = pruneMinute(minuteTimestamps.get(k), t);
    44	  minuteTimestamps.set(k, minute);
    45	
    46	  const minute_used = minute.length;
    47	  let reason: RateState["reason"] = "ok";
    48	  let shouldBackoff = false;
    49	
    50	  if (minute_used >= MINUTE_HARD) {
    51	    reason = "minute-hard";
    52	    shouldBackoff = true;
    53	  } else if (minute_used >= MINUTE_SOFT) {
    54	    reason = "minute-soft";
    55	    shouldBackoff = true;
    56	  }
    57	
    58	  return {
    59	    provider_connection_key: k,
    60	    minute_used,
    61	    minute_remaining: MINUTE_HARD - minute_used,
    62	    shouldBackoff,
    63	    reason,
    64	  };
    65	}
    66	
    67	export function consume(
    68	  provider: string,
    69	  connection_id: string,
    70	  now: () => number = Date.now,
    71	): boolean {
    72	  const state = check(provider, connection_id, now);
    73	  if (state.reason === "minute-hard") return false;
    74	  const k = key(provider, connection_id);
    75	  const t = now();
    76	  const minute = pruneMinute(minuteTimestamps.get(k), t);
    77	  minute.push(t);
    78	  minuteTimestamps.set(k, minute);
    79	  return true;
    80	}
    81	
    82	export function reset(provider?: string, connection_id?: string): void {
    83	  if (provider !== undefined && connection_id !== undefined) {
    84	    minuteTimestamps.delete(key(provider, connection_id));
    85	  } else {
    86	    minuteTimestamps.clear();
    87	  }
    88	}

exec
/bin/zsh -lc "rg -n \"open_banking|open-banking|open_banking_truelayer|open_banking_plaid|ESC_OPEN_BANKING|ESC_RATE_LIMIT_HIT|ESC_PROVIDER_FETCH_FAIL\" agents packages docs migrations --glob '"'!node_modules'"'" in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: migrations: No such file or directory (os error 2)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:636:      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
agents/_shared/autosend-policy.yaml:169:  open_banking_truelayer:
agents/_shared/autosend-policy.yaml:172:    reason: "TrueLayer OAuth 2.0 refresh — idempotent token rotation against auth.truelayer.com; @ifos/open-banking connector handles concurrent-refresh dedup per-connection; PSD2 90-day consent expiry surfaces via ESC_OPEN_BANKING_TOKEN_AGING (separate aging signal, not this action_type)."
agents/_shared/autosend-policy.yaml:175:  open_banking_plaid_uk:
docs/specs/ULTRAPLAN.md:188:- `ESC_RATE_LIMIT_HIT` — upstream API (LinkedIn especially) rate limited
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:300:- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:358:- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
docs/build-brief/00-MASTER-BRIEF.md:586:- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:288:#### `ESC_OPEN_BANKING_AUTH`
agents/_shared/escalation-codes.md:296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:324:#### `ESC_PROVIDER_FETCH_FAIL`
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:84:    bank_provider IN ('truelayer', 'plaid_uk', 'open_banking_direct')
agents/recruitment/cash-conductor/cleanup.sh:26:#   - Purge ~/.ifos-cache/open-banking/* older than 24h (transactions cache only;
agents/recruitment/cash-conductor/cleanup.sh:28:#   - Reset in-process rate-limit buckets via @ifos/{xero,quickbooks,open-banking} resetRateLimit()
agents/recruitment/cash-conductor/cleanup.sh:81:export OB_CACHE_DIR="${IFOS_OPEN_BANKING_CACHE_DIR:-${HOME}/.ifos-cache/open-banking}"
agents/recruitment/cash-conductor/cleanup.sh:96:# Step 2 — Optional: emit ESC_RATE_LIMIT_HIT if any cache shows
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:37:  open_banking_provider: truelayer
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:41:mocked_open_banking:
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:6:Morning goal + this goal's §1 · `agents/recruitment/cash-conductor/agent.md` §3+§4+§5 (consumer spec) · `packages/mcp-connectors/{xero,quickbooks,open-banking}/` (pattern) · `docs/decisions/2026-05-31-d1-founder-decision.md` §"Implementation surface" (bridge contract) · `agents/_shared/{hook-helpers.sh,autosend-policy.yaml}` (existing helpers + action_type registry) · `agents/recruitment/diagnostic/{context,cleanup}.sh` (sibling pattern for Phase A files).
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:13:5. `.../fixtures/99-token-aging-canary.yaml` — Open Banking token at 6 days → blocking stage refuses refresh → `ESC_OPEN_BANKING_TOKEN_AGING` blocking emission.
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:5:# (per @ifos/open-banking getTokenAgeStage), the connector REFUSES to refresh
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:7:# must surface ESC_OPEN_BANKING_TOKEN_AGING at blocking severity (operator +
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:16:# Per agent.md §6 ESC_OPEN_BANKING_TOKEN_AGING table row: staged severity
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:23:description: PSD2 6-day-to-expiry → blocking → ESC_OPEN_BANKING_TOKEN_AGING + cycle.sh hard exit
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:39:  open_banking_provider: truelayer
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:42:# context.sh / Step 1 calls @ifos/open-banking getTokenAgeStage on the loaded
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:45:  open_banking_token_state:
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:52:mocked_open_banking:
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:62:    - code: ESC_OPEN_BANKING_TOKEN_AGING
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:78:      payload_contains: "ESC_OPEN_BANKING_TOKEN_AGING; stage:blocking"
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:34:  open_banking_provider: truelayer
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:38:mocked_open_banking:
agents/recruitment/cash-conductor/cycle.sh:22:#   @ifos/open-banking    — TrueLayer + Plaid UK bank-feed
agents/recruitment/cash-conductor/cycle.sh:93:# ESC_OPEN_BANKING_AUTH / ESC_OPEN_BANKING_TOKEN_AGING (staged) on failure.
agents/recruitment/cash-conductor/cycle.sh:95:#             @ifos/open-banking refreshTokens (with getTokenAgeStage check).
agents/recruitment/cash-conductor/cycle.sh:101:  "accounting:STUB; open_banking:STUB; token_aging_stage:STUB"
agents/recruitment/cash-conductor/cycle.sh:120:# W7-8 wires: @ifos/open-banking listTransactionsSince — store in Postgres
agents/recruitment/cash-conductor/cycle.sh:125:  # TODO(W7-8): @ifos/open-banking listTransactionsSince(since=last_ingested_at)
docs/operations/goal-option-c-diagnostic-end-to-end.md:155:- `errors.ts` — 429 → ESC_RATE_LIMIT_HIT, 5xx → ESC_SCHEMA_VIOLATION
docs/operations/goal-week-4-track-1.md:28:14. **`agents/_shared/escalation-codes.md`** — `ESC_ACCOUNTING_AUTH`, `ESC_ACCOUNTING_WRITE_FAIL`, `ESC_OPEN_BANKING_AUTH`, `ESC_OPEN_BANKING_TOKEN_AGING`, `ESC_RECONCILIATION_AMBIGUOUS`, `ESC_AUTOSEND_RACE`.
docs/operations/goal-week-4-track-1.md:43:3. **`packages/mcp-connectors/open-banking/`** exists; abstraction over TrueLayer + Plaid UK (provider chosen per-tenant config). Capabilities: `oauth_refresh` (90-day PSD2 consent), `list_transactions_since(last_ingested_at)`, `get_account_balance`. **Token-aging logic implemented**: emits `ESC_OPEN_BANKING_TOKEN_AGING` with `info`/`warn`/`blocking` staging per Cash Conductor §6 (≤30d/14d/7d). ≥15 vitest passing.
docs/operations/goal-week-4-track-1.md:52:9. **`agents/recruitment/cash-conductor/tools.yaml`** exists; declares: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram` (per D1-B).
docs/operations/goal-week-4-track-1.md:56:    - `99-token-aging-canary.yaml` — Open Banking token at 6 days → `ESC_OPEN_BANKING_TOKEN_AGING` blocking
docs/operations/goal-week-4-track-1.md:72:    - `packages/mcp-connectors/open-banking/`
docs/operations/goal-week-4-track-1.md:219:    rate-limit.test.ts      # bucket exhaustion → ESC_RATE_LIMIT_HIT mock fire
docs/operations/goal-week-4-track-1.md:249:#### Step 6 — Scaffold `packages/mcp-connectors/open-banking/` (~5 hours; hardest)
docs/operations/goal-week-4-track-1.md:259:`oauth_refresh` checks staged age + emits `ESC_OPEN_BANKING_TOKEN_AGING` with the appropriate stage in payload. At `blocking`, refresh attempts STOP and the cycle.sh consumer must surface to operator for re-authorization.
docs/operations/goal-week-4-track-1.md:263:Commit: `feat(mcp/open-banking): scaffold @ifos/open-banking MCP connector — TrueLayer + Plaid UK + 90-day token staging`
docs/operations/goal-week-4-track-1.md:276:- `agents/recruitment/cash-conductor/tools.yaml` — capability declarations: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram`
docs/operations/goal-week-4-track-1.md:297:packages/mcp-connectors/open-banking|mcp-connector
docs/operations/goal-week-4-track-1.md:449:  @ifos/open-banking:      <N> capabilities (TrueLayer + Plaid UK), <M> vitest, token-aging logic tested at boundaries
docs/operations/goal-week-4-track-1.md:475:  <SHA>  feat(mcp/open-banking): scaffold @ifos/open-banking
agents/recruitment/cash-conductor/README.md:32:- Open Banking MCP connector + ESC_OPEN_BANKING_TOKEN_AGING UX
docs/operations/goal-week-3-polish-and-scaffold.md:310:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_BULLHORN_WRITE_FAIL, ESC_SCHEMA_VIOLATION, ESC_RATE_LIMIT_HIT, ESC_AUTOSEND_YELLOW_SPOT_CHECK.
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/w4-bilateral-pass-6-agent-md.md:54:### Finding 2. ESC_RATE_LIMIT_HIT claimed but not implemented
docs/operations/w4-bilateral-pass-6-agent-md.md:56:  - **Codex says:** "Lines 108 and 173 say `ESC_RATE_LIMIT_HIT` is raised for Companies House or LinkedIn 429s, but `cycle.sh` has no 429 catch or `hh_decision_action` path for that code; the generator CLI just exits generic on thrown errors. Fix by either implementing a 429 catch that emits `ESC_RATE_LIMIT_HIT`, or marking this as a W4/planned tools.yaml mapping rather than current v0 behaviour."
docs/operations/w4-bilateral-pass-6-agent-md.md:186:### Finding 5. ESC_PROVIDER_FETCH_FAIL used outside catalogue definition
agents/recruitment/cash-conductor/tools.yaml:15:# + xero_reminder_draft_internal + xero_reminder_send_customer; open_banking_*
agents/recruitment/cash-conductor/tools.yaml:99:  - id: open_banking_truelayer_oauth
agents/recruitment/cash-conductor/tools.yaml:100:    package: "@ifos/open-banking"
agents/recruitment/cash-conductor/tools.yaml:102:    action_type: open_banking_truelayer  # green tier; REGISTERED in autosend-policy.yaml per Codex F-R1 closure 2026-06-01
agents/recruitment/cash-conductor/tools.yaml:107:  - id: open_banking_plaid_uk_oauth
agents/recruitment/cash-conductor/tools.yaml:108:    package: "@ifos/open-banking"
agents/recruitment/cash-conductor/tools.yaml:110:    action_type: open_banking_plaid_uk  # green tier; REGISTERED in autosend-policy.yaml per Codex F-R1 closure 2026-06-01
agents/recruitment/cash-conductor/tools.yaml:116:  - id: open_banking_list_transactions
agents/recruitment/cash-conductor/tools.yaml:117:    package: "@ifos/open-banking"
agents/recruitment/cash-conductor/tools.yaml:122:  - id: open_banking_get_account_balance
agents/recruitment/cash-conductor/tools.yaml:123:    package: "@ifos/open-banking"
agents/recruitment/cash-conductor/tools.yaml:199:#   open_banking_truelayer             green
agents/recruitment/cash-conductor/tools.yaml:200:#   open_banking_plaid_uk              green   (v1.1+; queued but never fires v1.0)
agents/recruitment/cash-conductor/validate.sh:38:#   G6 — Open Banking token ≥7 days from expiry (≤7d → ESC_OPEN_BANKING_TOKEN_AGING blocking)
agents/recruitment/cash-conductor/validate.sh:157:# Per @ifos/open-banking getTokenAgeStage; ≤7d = "blocking" stage = hard fail.
agents/recruitment/cash-conductor/validate.sh:160:# TODO(W7-8): @ifos/open-banking loadTokens + getTokenAgeStage; if stage=="blocking"
agents/recruitment/cash-conductor/validate.sh:161:# _fail + ESC_OPEN_BANKING_TOKEN_AGING (catalogue staged severity per §2.7;
agents/recruitment/cash-conductor/validate.sh:182:  #  G6 → ESC_OPEN_BANKING_TOKEN_AGING; G7 → ESC_ACCOUNTING_AUTH)
docs/operations/goal-w4-day-26-2026-06-01.md:17:7. `@ifos/open-banking` MCP — TrueLayer + Plaid UK via `config.provider`; 90-day PSD2 token-aging info/warn/blocking at ≤30/14/7d; property-based test day 0-100 boundary; capabilities: oauth_refresh, list_transactions_since, get_account_balance; ≥15 vitest; README ≥150.
docs/operations/goal-w4-day-26-2026-06-01.md:18:8. Cluster F manifest entry in `scripts/run-codex-ratification.sh` — xero + quickbooks + open-banking via `mcp-connector` skill. Cash Conductor bundle queued for next manifest update when scaffold lands.
docs/operations/goal-w4-day-26-2026-06-01.md:37:Print: commits + SHAs · test counts per new package · Phase 1 ✓ + context-cost reduction · ECC patterns adopted (≤3) · Phase 2 status (qb / open-banking; partial OK) · Phase 3 reached? · founder action board refresh · tomorrow's first action: Cash Conductor bundle + cluster F run.
docs/operations/decision-log.md:58:- **`@ifos/open-banking`** MCP connector — TrueLayer + Plaid UK abstraction; 90-day token-aging logic with info/warn/blocking stages at ≤30/14/7d to expiry; est. 5 hours (the harder one)
docs/operations/decision-log.md:229:6. `40f94c4 fix(scribe-r4)` — all 5 R3 residuals closed; missing `hh_decision_*` calls added at §4 Steps 3+7; Ringover explicitly v1.1+; autosend cite split (decision-doc vs runtime YAML); ESC_PROVIDER_FETCH_FAIL catalogue extension queued
docs/operations/decision-log.md:651:  - §6 Escalation codes (ESC_VOICE_DRIFT / ESC_PII_LEAKAGE_RISK / ESC_RATE_LIMIT_HIT / ESC_SCHEMA_VIOLATION) mapped from `agents/_shared/escalation-codes.md`
agents/recruitment/cash-conductor/context.sh:26:#   - Open Banking auth unreachable        → exit 1 with ESC_OPEN_BANKING_AUTH
agents/recruitment/cash-conductor/context.sh:27:#   - Open Banking token in blocking stage → exit 1 with ESC_OPEN_BANKING_TOKEN_AGING
agents/recruitment/cash-conductor/context.sh:76:# TODO(W7-8): SELECT config->>'accounting_provider', config->>'open_banking_provider'
agents/recruitment/cash-conductor/context.sh:113:# Reference: agent.md §6 ESC_OPEN_BANKING_TOKEN_AGING staged severity.
agents/recruitment/cash-conductor/context.sh:118:# TODO(W7-8): node -e "import('@ifos/open-banking').then(ob => {
agents/recruitment/cash-conductor/context.sh:123:# If stage === 'blocking': emit ESC_OPEN_BANKING_TOKEN_AGING blocking + exit 1.
agents/recruitment/cash-conductor/context.sh:142:  "cash-conductor tenant=${CTX_TENANT_SLUG} accounting=${CTX_ACCOUNTING_PROVIDER} open_banking=${CTX_OPEN_BANKING_PROVIDER} token_stage=${CTX_OPEN_BANKING_TOKEN_STAGE} voice_corpus=${CTX_VOICE_CORPUS_ID:-<empty>} tone_rules=${CTX_TONE_RULES_COUNT}"
agents/recruitment/cash-conductor/context.sh:145:printf '[cash-conductor context.sh] tenant=%s accounting=%s open_banking=%s token_stage=%s voice_corpus=%s tone_rules=%s\n' \
agents/recruitment/sourcing-scout/agent.md:161:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
agents/recruitment/sourcing-scout/agent.md:169:   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
agents/recruitment/sourcing-scout/agent.md:175:   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:182:   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:295:| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:162:     gotcha per ULTRAPLAN A4 line 541); staged ESC_OPEN_BANKING_TOKEN_AGING:
agents/recruitment/cash-conductor/agent.md:164:   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on auth failure
agents/recruitment/cash-conductor/agent.md:166:     "accounting:<ok|fail>; open_banking:<ok|fail>; token_aging_stage:<info|warn|blocking|fresh>")
agents/recruitment/cash-conductor/agent.md:314:- Open Banking token ≥7 days from expiry (≤7d is blocking per ESC_OPEN_BANKING_TOKEN_AGING staged definition; ≤30d info + ≤14d warn are health-warning states that do NOT block Gate A, only signal upcoming reauth need)
agents/recruitment/cash-conductor/agent.md:341:| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:342:| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking PSD2 consent approaching 90-day expiry (staged) | info ≤30d / warn ≤14d / **blocking** ≤7d (per catalogue §2.7) | operator_chat_id (info+warn); + ifos_oncall_chat_id at blocking stage |
agents/recruitment/cash-conductor/agent.md:351:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:401:| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:422:| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
agents/recruitment/cash-conductor/agent.md:426:| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
agents/recruitment/cash-conductor/agent.md:431:1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
packages/agents-runtime/_shared/common-accounting.json:38:    "open_banking_provider": {
agents/recruitment/janitor/agent.md:100:   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per ESC_RATE_LIMIT_HIT catalogue §2.5 standard handling)
agents/recruitment/janitor/agent.md:129:   → ESC_RATE_LIMIT_HIT on 429
agents/recruitment/janitor/agent.md:223:| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:152:   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
agents/recruitment/scribe/agent.md:273:| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:282:| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
agents/recruitment/diagnostic/tools.yaml:42:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:77:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:165:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:174:  - open_banking   # Cash Conductor's territory
agents/recruitment/diagnostic/agent.md:116:   → v0 NOTE: rate-limit catches (429 → ESC_RATE_LIMIT_HIT) and per-section retry logic are NOT implemented at v0 cycle.sh; W4 polish adds 429 catch + retry-with-backoff to cycle.sh. v0 generator throws-and-exits on upstream errors; validate.sh catches Gate A failure downstream.
agents/recruitment/diagnostic/agent.md:189:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn upstream 429 | warn | operator_chat_id | **v0: NOT implemented in `cycle.sh` (generator throws-and-exits on upstream errors; validate.sh catches downstream as `ESC_AGENT_OUTPUT_SHAPE`). W4-planned: 429 catch + retry-with-backoff in `cycle.sh` + explicit `ESC_RATE_LIMIT_HIT` emission.** |
agents/recruitment/concierge/tools.yaml:51:        escalation: ESC_RATE_LIMIT_HIT  # warn; operator; payload.upstream='bullhorn'
agents/recruitment/concierge/agent.md:154:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:317:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/concierge/cycle.sh:137:# contact entities. ESC_RATE_LIMIT_HIT on 429; ESC_BULLHORN_AUTH on auth
packages/mcp-connectors/companies-house/README.md:34:| 429 | Rate limited; back off 60s, retry once | ESC_RATE_LIMIT_HIT |
packages/mcp-connectors/open-banking/src/auth.ts:7://   - consent expiry (~90 days from initial consent) → emit ESC_OPEN_BANKING_TOKEN_AGING
packages/mcp-connectors/open-banking/src/index.ts:1:// @ifos/open-banking — public API
packages/mcp-connectors/open-banking/src/index.ts:21:// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §open-banking)
packages/mcp-connectors/open-banking/src/index.ts:24:// open_banking_truelayer_oauth (action_type: open_banking_truelayer, green tier)
packages/mcp-connectors/open-banking/src/index.ts:25:// open_banking_plaid_uk_oauth — same function with provider='plaid-uk'; throws
packages/mcp-connectors/open-banking/src/index.ts:26:// NotImplementedError until v1.1+; action_type open_banking_plaid_uk green tier
packages/mcp-connectors/open-banking/src/index.ts:30:// open_banking_list_transactions (read-only)
packages/mcp-connectors/open-banking/src/index.ts:32:// open_banking_get_account_balance (read-only)
packages/mcp-connectors/open-banking/src/cache.ts:23:      join(homedir(), ".ifos-cache", "open-banking");
packages/mcp-connectors/open-banking/README.md:1:# @ifos/open-banking
packages/mcp-connectors/open-banking/README.md:17:| `open_banking_truelayer_oauth` | `refreshTokens(config, current, fetchFn?, now?)` (provider='truelayer') | OAuth refresh; concurrent-safe per (provider, connection_id); **refuses if consent is in PSD2 blocking window (≤7 days)** | Step 1 (auth refresh) | `open_banking_truelayer` | green |
packages/mcp-connectors/open-banking/README.md:18:| `open_banking_plaid_uk_oauth` (v1.1+ stub) | `refreshTokens(config, current, fetchFn?, now?)` (provider='plaid-uk') | Plaid UK OAuth refresh — interface in place; implementation throws `NotImplementedError` until v1.1+ | (never fires v1.0) | `open_banking_plaid_uk` | green |
packages/mcp-connectors/open-banking/README.md:19:| `open_banking_list_transactions` | `listTransactionsSince(client, config, options)` | List bank transactions on/after a timestamp; provider-agnostic shape; TrueLayer raw payload preserved in `raw_provider_payload` | Step 3 (transaction ingest) | n/a (read-only) | n/a |
packages/mcp-connectors/open-banking/README.md:20:| `open_banking_get_account_balance` | `getAccountBalance(client, config)` | Current account balance (available + cleared) | Step 10 (cash-flow forecast) | n/a (read-only) | n/a |
packages/mcp-connectors/open-banking/README.md:22:All `action_type` values above exist in `agents/_shared/autosend-policy.yaml` with the documented tier (verified 2026-06-01 Codex F-R2 closure — both `open_banking_truelayer` and `open_banking_plaid_uk` registered as green).
packages/mcp-connectors/open-banking/README.md:33:| `getTokenAgeStage(tokens, now?)` | Pure predicate — returns `{stage: 'fresh'|'info'|'warn'|'blocking', days_until_consent_expiry}`; staged-severity hook for operator alerting via `ESC_OPEN_BANKING_TOKEN_AGING` |
packages/mcp-connectors/open-banking/README.md:53:`getTokenAgeStage()` is the pure classifier the agent uses to alert the operator BEFORE consent dies. Stages, with the cycle.sh / agent.md §6 mapping to `ESC_OPEN_BANKING_TOKEN_AGING`:
packages/mcp-connectors/open-banking/README.md:59:| 8-14 | `warn` | escalate to operator chat (`ESC_OPEN_BANKING_TOKEN_AGING` severity warn) |
packages/mcp-connectors/open-banking/README.md:78:} from "@ifos/open-banking";
packages/mcp-connectors/open-banking/README.md:143:| Local hard-gate (100%) reached | `OpenBankingRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "truelayer" | "plaid-uk", retry_after_seconds: null, consecutive_429s: 0}` |
packages/mcp-connectors/open-banking/README.md:144:| Upstream 429 from provider API | `OpenBankingRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "truelayer" | "plaid-uk", retry_after_seconds: <N>, consecutive_429s: <N>}` |
packages/mcp-connectors/open-banking/README.md:152:| `listTransactionsSince` / `getAccountBalance` | GET | 2 | Exponential w/ jitter (250-1000ms) | `OpenBankingError` / `OpenBankingRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
packages/mcp-connectors/open-banking/README.md:153:| `refreshTokens` | POST | **0** | n/a | `OpenBankingAuthError` → `ESC_OPEN_BANKING_AUTH` (**blocking**; consumer-emitted; routes operator + ifos_oncall per escalation-codes.md lines 288-294; payload `failure_type: 'refresh_failed'`) |
packages/mcp-connectors/open-banking/README.md:154:| `refreshTokens` blocked by PSD2 consent expiry | POST | **0** | n/a | `OpenBankingConsentExpiredError` → `ESC_OPEN_BANKING_AUTH` (blocking; payload `failure_type: 'consent_expired_90d'`); user must re-do SCA per Bootstrap § |
packages/mcp-connectors/open-banking/README.md:155:| 401 from any GET | — | force-refresh access_token, retry once | — | `OpenBankingAuthError` → `ESC_OPEN_BANKING_AUTH` |
packages/mcp-connectors/open-banking/README.md:156:| 429 from any GET | — | honour `Retry-After` header | jittered backoff if no header | `OpenBankingRateLimitError` → `ESC_RATE_LIMIT_HIT` |
packages/mcp-connectors/open-banking/README.md:160:The separate **PSD2 token-aging signal** — `ESC_OPEN_BANKING_TOKEN_AGING` (staged info → warn → blocking per consent-expiry distance) — is emitted by the consumer based on `getTokenAgeStage()` BEFORE refresh fails. That's a different code path from the refresh-failure mapping above; see `agents/_shared/escalation-codes.md` lines 296-307 for the staged severity definition and `agents/recruitment/cash-conductor/agent.md` §6 for the consumer flow.
packages/mcp-connectors/open-banking/README.md:218:   ├── Step 3  (bank transaction ingest)            ──┼─→ @ifos/open-banking (this package)
packages/mcp-connectors/open-banking/tests/rate-limit.test.ts:8:describe("open-banking rate-limit", () => {
packages/mcp-connectors/open-banking/tests/scaffold.test.ts:25:describe("@ifos/open-banking package surface", () => {
packages/mcp-connectors/open-banking/tests/auth.test.ts:72:describe("open-banking auth", () => {
packages/mcp-connectors/open-banking/package.json:2:  "name": "@ifos/open-banking",
packages/mcp-connectors/open-banking/tests/capabilities.test.ts:80:describe("open-banking capabilities — TrueLayer (v1.0)", () => {
packages/mcp-connectors/open-banking/tests/capabilities.test.ts:112:describe("open-banking capabilities — Plaid UK (v1.1+ deferred)", () => {
packages/mcp-connectors/quickbooks/README.md:124:| Local hard-gate (100%) reached | `QbRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "quickbooks", retry_after_seconds: null, consecutive_429s: 0}` |
packages/mcp-connectors/quickbooks/README.md:125:| Upstream 429 from QB API | `QbRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "quickbooks", retry_after_seconds: <N>, consecutive_429s: <N>}` |
packages/mcp-connectors/quickbooks/README.md:135:| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `QbError` / `QbRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
packages/mcp-connectors/xero/README.md:103:| Local hard-gate (100%) reached | `XeroRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "xero", retry_after_seconds: null, consecutive_429s: 0}` |
packages/mcp-connectors/xero/README.md:104:| Upstream 429 from Xero API | `XeroRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "xero", retry_after_seconds: <N>, consecutive_429s: <N>}` |
packages/mcp-connectors/xero/README.md:114:| `listOpenInvoices` / `getInvoice` / `listPayments` | GET | 2 | Exponential w/ jitter (250-1000ms) | `XeroError` or `XeroRateLimitError` → `ESC_PROVIDER_FETCH_FAIL` or `ESC_RATE_LIMIT_HIT` (consumer-emitted) |
packages/mcp-connectors/xero/README.md:118:| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `XeroRateLimitError` → `ESC_RATE_LIMIT_HIT` |

codex
The first pass shows at least one load-bearing mismatch risk: the README claims a four-way capability set but `src/index.ts` exposes one OAuth function for two tool IDs plus many helper exports. I’m checking whether that is an allowed documented split or a hard §1 surface failure, and whether the tests actually cover required error paths/ESC behavior.
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/tools.yaml | sed -n '80,135p;190,205p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    96	  # Open Banking (TrueLayer v1.0; Plaid UK v1.1+ stubbed)
    97	  # ────────────────────────────────────────────────────────────────────────
    98	
    99	  - id: open_banking_truelayer_oauth
   100	    package: "@ifos/open-banking"
   101	    purpose: "TrueLayer OAuth refresh + PSD2 consent age check (refuses refresh in 7-day blocking window)"
   102	    action_type: open_banking_truelayer  # green tier; REGISTERED in autosend-policy.yaml per Codex F-R1 closure 2026-06-01
   103	    cycle_step: 1
   104	    secrets_required: [TRUELAYER_CLIENT_ID, TRUELAYER_CLIENT_SECRET]
   105	    rate_limit_hint: "30/min per (provider, connection_id); 80% soft backoff"
   106	
   107	  - id: open_banking_plaid_uk_oauth
   108	    package: "@ifos/open-banking"
   109	    purpose: "Plaid UK OAuth refresh (v1.1+ stub; throws NotImplementedError until pilot tenant chooses Plaid over TrueLayer). Declared for capability-surface set-equality per review-mcp-connector §1."
   110	    action_type: open_banking_plaid_uk  # green tier; REGISTERED in autosend-policy.yaml per Codex F-R1 closure 2026-06-01
   111	    cycle_step: 1
   112	    secrets_required: [PLAID_CLIENT_ID, PLAID_CLIENT_SECRET]
   113	    rate_limit_hint: "30/min per (provider, item_id); never fires v1.0"
   114	    optional: true  # v1.1+ stub; v1.0 cycle.sh selects TrueLayer
   115	
   116	  - id: open_banking_list_transactions
   117	    package: "@ifos/open-banking"
   118	    purpose: "Provider-agnostic transaction list (TrueLayer impl; Plaid UK throws NotImplementedError until v1.1+)"
   119	    cycle_step: 3
   120	    state_changing: false
   121	
   122	  - id: open_banking_get_account_balance
   123	    package: "@ifos/open-banking"
   124	    purpose: "Current account balance (available + cleared) for weekly cash-flow forecast §10"
   125	    cycle_step: 13
   126	    state_changing: false
   127	
   128	  # ────────────────────────────────────────────────────────────────────────
   129	  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision;
   130	  # package scaffold landed 2026-06-01). Split into two rows because the two
   131	  # public-API call sites have distinct audit + failure semantics:
   132	  #   - proposeApproval: state-changing; emits ORANGE decision_log row
   133	  #   - awaitApprovalDecision: read-only poll; produces no audit row directly
   134	  # Per D1-B doc §"Implementation surface" item 4: declare the capability on
   135	  # both Concierge AND Cash Conductor (Cash Conductor is the Step-10 consumer).
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
   203	# ──────────────────────────────────────────────────────────────────────────────
   204	# Boundary check (per master brief §3 + review-mcp-connector.md §8)
   205	# ──────────────────────────────────────────────────────────────────────────────

exec
/bin/zsh -lc "rg -n \"console\\.(log|error|warn).*\\"'$'"\\{.*(KEY|SECRET|PASSWORD|TOKEN|BEARER)|throw\\s+new\\s+Error.*\\"'$'"\\{.*(KEY|SECRET|PASSWORD)|composio|agentmail|packages/harness/cortextos|decision_log|migration-test|test-tenant-b\" packages/mcp-connectors/open-banking -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/open-banking/README.md:158:The only state-changing op is OAuth refresh (which has its own consent-aware refusal logic via `getTokenAgeStage`). All transaction/balance calls are read-only — banks don't generally expose write APIs in the scope Cash Conductor needs. The connector does NOT write `decision_log` rows (vault/Postgres split per ADR-002); the consuming `cycle.sh` catches the typed errors above and emits the right ESC via `hh_decision_action`/`hh_decision_output` from `agents/_shared/hook-helpers.sh`.
packages/mcp-connectors/open-banking/README.md:235:- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
packages/mcp-connectors/open-banking/README.md:236:- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '160,182p' && nl -ba agents/_shared/escalation-codes.md | sed -n '150,170p;284,310p;320,332p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   176	    tier: green
   177	    agent: cash-conductor
   178	    reason: "Plaid UK OAuth 2.0 refresh — v1.1+ stub; never fires v1.0. Registered now so the README + tools.yaml capability declarations have a matching policy entry per review-mcp-connector §7 set-equality."
   179	    irreversible: false
   180	
   181	  # ───────────────────────────────────────────────────────────
   182	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   150	- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
   151	- **Phase:** `gating_failed`
   152	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — potential GDPR incident
   153	- **Payload fields:** `detected_pii_type` (one of `email`, `phone`, `name`, `address`, `nin`, `passport`), `boundary_violated` (the tenant_slug whose data leaked), `output_snippet_redacted_hash`
   154	- **Recovery:** Agent restart required after operator review; founder must determine whether DPO notification is needed per UK GDPR Art. 33
   155	
   156	#### `ESC_RATE_LIMIT_HIT`
   157	- **Severity:** warn
   158	- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
   159	- **Phase:** `gating_failed`
   160	- **Routing:** `operator_chat_id`
   161	- **Payload fields:** `upstream` (e.g. `bullhorn`, `linkedin`, `reed`, `cv-library`), `retry_after_seconds`, `consecutive_429s`
   162	
   163	#### `ESC_SCHEMA_VIOLATION`
   164	- **Severity:** warn
   165	- **Trigger:** Agent produced output violating vertical-schema.yaml field constraints (e.g. wrote an unknown enum value, missing required field). Detected at write-time by adapter validation
   166	- **Phase:** `gating_failed`
   167	- **Routing:** `operator_chat_id`
   168	- **Payload fields:** `entity_type` (from vertical-schema.yaml entities), `field_violated`, `value_attempted`, `constraint_failed`
   169	
   170	#### `ESC_VOICE_DRIFT_TENANT`
   284	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   285	- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
   286	- **Recovery:** founder reauthenticates accounting OAuth
   287	
   288	#### `ESC_OPEN_BANKING_AUTH`
   289	- **Severity:** **blocking** — Cash Conductor cannot fetch latest bank-feed; falls back to last-known balance
   290	- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
   291	- **Phase:** `gating_failed`
   292	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   293	- **Payload fields:** `failure_type` (`consent_expired_90d` | `refresh_failed`), `consent_expires_at`, `bank_provider`
   294	- **Recovery:** founder completes Open Banking SCA reauthentication flow
   295	
   296	#### `ESC_OPEN_BANKING_TOKEN_AGING`
   297	- **Severity:** staged — info → warn → blocking as expiry approaches (per Cash Conductor agent.md §6)
   298	- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
   299	  - **≤30 days remaining:** info — non-urgent operator awareness; nightly health check emits this
   300	  - **≤14 days remaining:** warn — operator nudge to schedule reauth this week
   301	  - **≤7 days remaining:** blocking — Cash Conductor enters degraded mode (cached balance only; no fresh bank-feed reads); operator must complete SCA reauth before token expires
   302	- **Phase:** `gating_failed`
   303	- **Routing:** `operator_chat_id` (info + warn stages); ADD `ifos_oncall_chat_id` at blocking stage
   304	- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`, `stage` (`info` | `warn` | `blocking`)
   305	- **Recovery:** founder schedules + completes Open Banking SCA reauth via tenant's bank login
   306	
   307	### 2.8 — Provider read/write failures (4 codes)
   308	Source: derived from v1.0 agent.md adapter call sites
   309	
   310	#### `ESC_BULLHORN_WRITE_FAIL`
   320	- **Phase:** `gating_failed`
   321	- **Routing:** `operator_chat_id`
   322	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   323	
   324	#### `ESC_PROVIDER_FETCH_FAIL`
   325	- **Severity:** warn
   326	- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
   327	- **Phase:** `gating_failed`
   328	- **Routing:** `operator_chat_id`
   329	- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`
   330	
   331	#### `ESC_SEND_FAIL`
   332	- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer

exec
/bin/zsh -lc 'nl -ba packages/mcp-connectors/open-banking/tests/capabilities.test.ts && nl -ba packages/mcp-connectors/open-banking/tests/auth.test.ts && nl -ba packages/mcp-connectors/open-banking/tests/rate-limit.test.ts' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
     2	// path + ≥1 error path per capability). Plaid UK NotImplementedError path
     3	// covered for both capabilities.
     4	
     5	import { promises as fs } from "node:fs";
     6	import { tmpdir } from "node:os";
     7	import { join } from "node:path";
     8	import { afterEach, beforeEach, describe, expect, it } from "vitest";
     9	import { OpenBankingClient } from "../src/client.js";
    10	import { OpenBankingCache } from "../src/cache.js";
    11	import { saveTokens, _resetInflightForTest } from "../src/auth.js";
    12	import { reset as resetRateLimit } from "../src/rate-limit.js";
    13	import { listTransactionsSince } from "../src/transactions.js";
    14	import { getAccountBalance } from "../src/balance.js";
    15	import { NotImplementedError } from "../src/errors.js";
    16	import type {
    17	  OpenBankingConfig,
    18	  OpenBankingTokens,
    19	} from "../src/types.js";
    20	
    21	import TL_TRANSACTIONS from "../fixtures/truelayer-transactions.json" with { type: "json" };
    22	import TL_BALANCE from "../fixtures/truelayer-balance.json" with { type: "json" };
    23	
    24	const DAY_MS = 24 * 60 * 60 * 1000;
    25	
    26	const FIXTURE_TOKENS: OpenBankingTokens = {
    27	  access_token: "tl-access",
    28	  refresh_token: "tl-refresh",
    29	  expires_at_ms: Date.now() + 3600_000,
    30	  consent_expires_at_ms: Date.now() + 60 * DAY_MS,
    31	  scope: "accounts transactions balance",
    32	  token_type: "Bearer",
    33	};
    34	
    35	let token_file: string;
    36	let cache_dir: string;
    37	let cache: OpenBankingCache;
    38	
    39	function makeConfig(
    40	  overrides: Partial<OpenBankingConfig> = {},
    41	): OpenBankingConfig {
    42	  return {
    43	    provider: "truelayer",
    44	    client_id: "fake-client-id",
    45	    client_secret: "fake-client-secret",
    46	    connection_id: "acct-fixture",
    47	    environment: "sandbox",
    48	    token_file_path: token_file,
    49	    ...overrides,
    50	  };
    51	}
    52	
    53	function makeOkResponse(body: unknown): Response {
    54	  return new Response(JSON.stringify(body), {
    55	    status: 200,
    56	    headers: { "Content-Type": "application/json" },
    57	  });
    58	}
    59	
    60	beforeEach(async () => {
    61	  token_file = join(
    62	    tmpdir(),
    63	    `ob-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`,
    64	  );
    65	  cache_dir = join(
    66	    tmpdir(),
    67	    `ob-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`,
    68	  );
    69	  cache = new OpenBankingCache(cache_dir);
    70	  _resetInflightForTest();
    71	  resetRateLimit();
    72	  await saveTokens(makeConfig(), FIXTURE_TOKENS);
    73	});
    74	
    75	afterEach(async () => {
    76	  await fs.unlink(token_file).catch(() => undefined);
    77	  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
    78	});
    79	
    80	describe("open-banking capabilities — TrueLayer (v1.0)", () => {
    81	  it("listTransactionsSince: returns provider-agnostic OpenBankingTransaction[] from fixture", async () => {
    82	    const fakeFetch: typeof fetch = async () => makeOkResponse(TL_TRANSACTIONS);
    83	    const config = makeConfig();
    84	    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    85	    const txns = await listTransactionsSince(client, config, {
    86	      since: "2026-05-01T00:00:00Z",
    87	      cache,
    88	      no_cache: true,
    89	    });
    90	    expect(txns.length).toBe(3);
    91	    expect(txns[0]?.transaction_id).toBe("tl-tx-aaa-111");
    92	    expect(txns[0]?.amount).toBe(2000);
    93	    expect(txns[0]?.reference).toBe("BACS-2026-05-20-001");
    94	    // Debit transaction preserves negative amount
    95	    expect(txns[2]?.amount).toBe(-85.5);
    96	    // raw_provider_payload preserved
    97	    expect(txns[0]?.raw_provider_payload.transaction_id).toBe("tl-tx-aaa-111");
    98	  });
    99	
   100	  it("getAccountBalance: returns OpenBankingBalance with available + current + currency", async () => {
   101	    const fakeFetch: typeof fetch = async () => makeOkResponse(TL_BALANCE);
   102	    const config = makeConfig();
   103	    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
   104	    const bal = await getAccountBalance(client, config);
   105	    expect(bal.available).toBe(47823.55);
   106	    expect(bal.current).toBe(47909.05);
   107	    expect(bal.currency).toBe("GBP");
   108	    expect(bal.fetched_at).toBe("2026-06-01T08:30:00Z");
   109	  });
   110	});
   111	
   112	describe("open-banking capabilities — Plaid UK (v1.1+ deferred)", () => {
   113	  it("listTransactionsSince throws NotImplementedError for Plaid UK", async () => {
   114	    const config = makeConfig({ provider: "plaid-uk" });
   115	    const client = new OpenBankingClient({ config });
   116	    await expect(
   117	      listTransactionsSince(client, config, { since: "2026-05-01T00:00:00Z" }),
   118	    ).rejects.toBeInstanceOf(NotImplementedError);
   119	  });
   120	
   121	  it("getAccountBalance throws NotImplementedError for Plaid UK", async () => {
   122	    const config = makeConfig({ provider: "plaid-uk" });
   123	    const client = new OpenBankingClient({ config });
   124	    await expect(getAccountBalance(client, config)).rejects.toBeInstanceOf(
   125	      NotImplementedError,
   126	    );
   127	  });
   128	});
     1	// OAuth tests per review-mcp-connector §2 (idempotency + atomic file write +
     2	// concurrent-safety test) + PSD2 consent-expiry guard test.
     3	
     4	import { promises as fs } from "node:fs";
     5	import { tmpdir } from "node:os";
     6	import { join } from "node:path";
     7	import { afterEach, beforeEach, describe, expect, it } from "vitest";
     8	import {
     9	  _resetInflightForTest,
    10	  loadTokens,
    11	  refreshTokens,
    12	  saveTokens,
    13	  shouldRefresh,
    14	} from "../src/auth.js";
    15	import {
    16	  NotImplementedError,
    17	  OpenBankingAuthError,
    18	  OpenBankingConsentExpiredError,
    19	} from "../src/errors.js";
    20	import type {
    21	  OpenBankingConfig,
    22	  OpenBankingTokens,
    23	} from "../src/types.js";
    24	
    25	const DAY_MS = 24 * 60 * 60 * 1000;
    26	
    27	const FIXTURE_TOKENS: OpenBankingTokens = {
    28	  access_token: "tl-access-old",
    29	  refresh_token: "tl-refresh-old",
    30	  expires_at_ms: Date.now() + 3600_000,
    31	  consent_expires_at_ms: Date.now() + 60 * DAY_MS,
    32	  scope: "accounts transactions balance",
    33	  token_type: "Bearer",
    34	};
    35	
    36	const REFRESH_OK_BODY = JSON.stringify({
    37	  access_token: "tl-new-access",
    38	  refresh_token: "tl-new-refresh",
    39	  expires_in: 3600,
    40	  scope: "accounts transactions balance",
    41	  token_type: "Bearer",
    42	});
    43	
    44	function makeConfig(
    45	  token_file: string,
    46	  overrides: Partial<OpenBankingConfig> = {},
    47	): OpenBankingConfig {
    48	  return {
    49	    provider: "truelayer",
    50	    client_id: "fake-client-id",
    51	    client_secret: "fake-client-secret",
    52	    connection_id: "acct-fixture",
    53	    environment: "sandbox",
    54	    token_file_path: token_file,
    55	    ...overrides,
    56	  };
    57	}
    58	
    59	let token_file: string;
    60	
    61	beforeEach(() => {
    62	  token_file = join(
    63	    tmpdir(),
    64	    `ob-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`,
    65	  );
    66	  _resetInflightForTest();
    67	});
    68	afterEach(async () => {
    69	  await fs.unlink(token_file).catch(() => undefined);
    70	});
    71	
    72	describe("open-banking auth", () => {
    73	  it("loadTokens returns null when file missing", async () => {
    74	    expect(await loadTokens(makeConfig(token_file))).toBeNull();
    75	  });
    76	
    77	  it("save + load round-trips token bundle (with consent_expires_at_ms)", async () => {
    78	    const config = makeConfig(token_file);
    79	    await saveTokens(config, FIXTURE_TOKENS);
    80	    const loaded = await loadTokens(config);
    81	    expect(loaded).toEqual(FIXTURE_TOKENS);
    82	  });
    83	
    84	  it("shouldRefresh: true if within 5-min safety window", () => {
    85	    const expiringSoon: OpenBankingTokens = {
    86	      ...FIXTURE_TOKENS,
    87	      expires_at_ms: Date.now() + 60_000,
    88	    };
    89	    expect(shouldRefresh(expiringSoon)).toBe(true);
    90	  });
    91	
    92	  it("refreshTokens (TrueLayer): success writes new tokens; consent_expires_at_ms PRESERVED", async () => {
    93	    const config = makeConfig(token_file);
    94	    const fakeFetch = async (): Promise<Response> =>
    95	      new Response(REFRESH_OK_BODY, {
    96	        status: 200,
    97	        headers: { "Content-Type": "application/json" },
    98	      });
    99	
   100	    const newT = await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
   101	    expect(newT.access_token).toBe("tl-new-access");
   102	    expect(newT.consent_expires_at_ms).toBe(FIXTURE_TOKENS.consent_expires_at_ms);
   103	    const onDisk = await loadTokens(config);
   104	    expect(onDisk?.access_token).toBe(newT.access_token);
   105	  });
   106	
   107	  it("refreshTokens: 401 surfaces as OpenBankingAuthError (refresh_token_revoked); no token leak", async () => {
   108	    const config = makeConfig(token_file);
   109	    const fakeFetch = async (): Promise<Response> =>
   110	      new Response(JSON.stringify({ error: "invalid_grant" }), {
   111	        status: 401,
   112	        headers: { "Content-Type": "application/json" },
   113	      });
   114	
   115	    await expect(
   116	      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
   117	    ).rejects.toBeInstanceOf(OpenBankingAuthError);
   118	    try {
   119	      await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
   120	    } catch (e) {
   121	      expect((e as Error).message).not.toContain(FIXTURE_TOKENS.refresh_token);
   122	    }
   123	  });
   124	
   125	  it("refreshTokens: consent within 7-day blocking window REFUSES refresh (PSD2 hard stop)", async () => {
   126	    const config = makeConfig(token_file);
   127	    const nearExpiry: OpenBankingTokens = {
   128	      ...FIXTURE_TOKENS,
   129	      consent_expires_at_ms: Date.now() + 3 * DAY_MS, // 3 days = blocking
   130	    };
   131	    const fakeFetch = async (): Promise<Response> =>
   132	      new Response(REFRESH_OK_BODY, { status: 200 });
   133	    await expect(
   134	      refreshTokens(config, nearExpiry, fakeFetch as typeof fetch),
   135	    ).rejects.toBeInstanceOf(OpenBankingConsentExpiredError);
   136	  });
   137	
   138	  it("refreshTokens: concurrent calls (same provider+connection) converge on ONE network call", async () => {
   139	    const config = makeConfig(token_file);
   140	    let calls = 0;
   141	    const fakeFetch = async (): Promise<Response> => {
   142	      calls += 1;
   143	      await new Promise((r) => setTimeout(r, 25));
   144	      return new Response(REFRESH_OK_BODY, {
   145	        status: 200,
   146	        headers: { "Content-Type": "application/json" },
   147	      });
   148	    };
   149	
   150	    const [a, b, c] = await Promise.all([
   151	      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
   152	      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
   153	      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
   154	    ]);
   155	    expect(calls).toBe(1);
   156	    expect(a.access_token).toBe(b.access_token);
   157	    expect(b.access_token).toBe(c.access_token);
   158	  });
   159	
   160	  it("refreshTokens: Plaid UK provider throws NotImplementedError (v1.1+ deferred)", async () => {
   161	    const config = makeConfig(token_file, { provider: "plaid-uk" });
   162	    await expect(
   163	      refreshTokens(config, FIXTURE_TOKENS, fetch),
   164	    ).rejects.toBeInstanceOf(NotImplementedError);
   165	  });
   166	});
     1	// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
     2	// MUST exist). Verifies soft (80%) + hard (100%) thresholds, multi-provider
     3	// + multi-connection isolation.
     4	
     5	import { beforeEach, describe, expect, it } from "vitest";
     6	import { check, consume, reset } from "../src/rate-limit.js";
     7	
     8	describe("open-banking rate-limit", () => {
     9	  beforeEach(() => {
    10	    reset();
    11	  });
    12	
    13	  it("starts at 0 used with full budget", () => {
    14	    const s = check("truelayer", "acct-1");
    15	    expect(s.minute_used).toBe(0);
    16	    expect(s.minute_remaining).toBe(30);
    17	    expect(s.shouldBackoff).toBe(false);
    18	    expect(s.reason).toBe("ok");
    19	  });
    20	
    21	  it("does NOT backoff before minute soft threshold (24)", () => {
    22	    for (let i = 0; i < 23; i++) consume("truelayer", "acct-1");
    23	    expect(check("truelayer", "acct-1").shouldBackoff).toBe(false);
    24	  });
    25	
    26	  it("triggers minute-soft backoff at 24", () => {
    27	    for (let i = 0; i < 24; i++) consume("truelayer", "acct-1");
    28	    const s = check("truelayer", "acct-1");
    29	    expect(s.shouldBackoff).toBe(true);
    30	    expect(s.reason).toBe("minute-soft");
    31	  });
    32	
    33	  it("blocks at minute-hard 30 (consume returns false)", () => {
    34	    for (let i = 0; i < 30; i++) consume("truelayer", "acct-1");
    35	    expect(check("truelayer", "acct-1").reason).toBe("minute-hard");
    36	    expect(consume("truelayer", "acct-1")).toBe(false);
    37	  });
    38	
    39	  it("isolates buckets per (provider, connection_id) pair", () => {
    40	    for (let i = 0; i < 25; i++) consume("truelayer", "acct-A");
    41	    expect(check("truelayer", "acct-A").shouldBackoff).toBe(true);
    42	    expect(check("truelayer", "acct-B").shouldBackoff).toBe(false);
    43	    expect(check("plaid-uk", "acct-A").shouldBackoff).toBe(false);
    44	  });
    45	});

codex
The repository context confirms the autosend action types exist and match the README, but the tests are thinner than the README claims: the TrueLayer read capabilities only have happy-path fixture tests, while Plaid stub failures are tested separately. I’m doing one build/test sanity pass to catch type/build issues before the verdict.
exec
/bin/zsh -lc 'nl -ba packages/mcp-connectors/open-banking/src/balance.ts && nl -ba packages/mcp-connectors/open-banking/src/transactions.ts && nl -ba packages/mcp-connectors/open-banking/tsconfig.json' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// Open Banking balance capability — get current account balance.
     2	// Consumed by Cash Conductor §10 (weekly cash-flow forecast; available + cleared
     3	// distinction matters for pending-transaction nuance).
     4	//
     5	// TrueLayer endpoint: GET /data/v1/accounts/<account_id>/balance
     6	// Plaid UK endpoint (v1.1+): POST /accounts/balance/get (deferred).
     7	
     8	import type { OpenBankingClient } from "./client.js";
     9	import { NotImplementedError } from "./errors.js";
    10	import type {
    11	  OpenBankingBalance,
    12	  OpenBankingConfig,
    13	} from "./types.js";
    14	
    15	interface TrueLayerBalanceResponse {
    16	  results: Array<{
    17	    available: number;
    18	    current: number;
    19	    currency: string;
    20	    update_timestamp: string;
    21	  }>;
    22	  status: string;
    23	}
    24	
    25	/**
    26	 * Fetch current account balance. Returns provider-agnostic OpenBankingBalance
    27	 * shape. NOT cached by default — balances are point-in-time values; staleness
    28	 * matters more than throughput for Cash Conductor's weekly forecast.
    29	 */
    30	export async function getAccountBalance(
    31	  client: OpenBankingClient,
    32	  config: OpenBankingConfig,
    33	): Promise<OpenBankingBalance> {
    34	  if (config.provider === "plaid-uk") {
    35	    throw new NotImplementedError(
    36	      "Plaid UK getAccountBalance not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2)",
    37	    );
    38	  }
    39	
    40	  const path = `/data/v1/accounts/${encodeURIComponent(config.connection_id)}/balance`;
    41	  const res = await client.request<TrueLayerBalanceResponse>(path);
    42	
    43	  const r = res.results?.[0];
    44	  if (!r) {
    45	    throw new Error(
    46	      `TrueLayer balance fetch returned no results for connection ${config.connection_id}`,
    47	    );
    48	  }
    49	
    50	  return {
    51	    available: r.available,
    52	    current: r.current,
    53	    currency: r.currency,
    54	    fetched_at: r.update_timestamp,
    55	  };
    56	}
     1	// Open Banking transactions capability — list transactions since a given timestamp.
     2	// Consumed by Cash Conductor §4 Step 3 (bank transaction ingest).
     3	//
     4	// TrueLayer endpoint: GET /data/v1/accounts/<account_id>/transactions?from=<ISO>&to=<ISO>
     5	// Plaid UK endpoint (v1.1+): POST /transactions/get (different shape; deferred).
     6	
     7	import type { OpenBankingClient } from "./client.js";
     8	import { OpenBankingCache } from "./cache.js";
     9	import { NotImplementedError } from "./errors.js";
    10	import type {
    11	  OpenBankingConfig,
    12	  OpenBankingTransaction,
    13	} from "./types.js";
    14	
    15	const TRANSACTIONS_CACHE_TTL_MS = 5 * 60 * 1000;
    16	
    17	interface TrueLayerTransactionsResponse {
    18	  results: Array<{
    19	    transaction_id: string;
    20	    timestamp: string;
    21	    amount: number;
    22	    currency: string;
    23	    description: string;
    24	    transaction_type?: string;
    25	    transaction_category?: string;
    26	    meta?: { reference?: string };
    27	  }>;
    28	  status: string;
    29	}
    30	
    31	export interface ListTransactionsOptions {
    32	  /** ISO 8601 — fetch transactions on/after this timestamp. */
    33	  since: string;
    34	  /** ISO 8601 — fetch transactions on/before this timestamp (defaults to now). */
    35	  until?: string;
    36	  no_cache?: boolean;
    37	  cache?: OpenBankingCache;
    38	}
    39	
    40	/**
    41	 * List transactions for a connected bank account since a given timestamp.
    42	 * Returns provider-agnostic OpenBankingTransaction shape; TrueLayer raw payload
    43	 * preserved in `raw_provider_payload`.
    44	 */
    45	export async function listTransactionsSince(
    46	  client: OpenBankingClient,
    47	  config: OpenBankingConfig,
    48	  options: ListTransactionsOptions,
    49	): Promise<OpenBankingTransaction[]> {
    50	  if (config.provider === "plaid-uk") {
    51	    throw new NotImplementedError(
    52	      "Plaid UK listTransactionsSince not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2)",
    53	    );
    54	  }
    55	
    56	  const cache = options.cache ?? OpenBankingCache.fromEnv();
    57	  const until = options.until ?? new Date().toISOString();
    58	  const key = `transactions:${config.connection_id}:since=${options.since}:until=${until}`;
    59	
    60	  if (!options.no_cache) {
    61	    const hit = await cache.get<OpenBankingTransaction[]>(key);
    62	    if (hit !== null) return hit;
    63	  }
    64	
    65	  const path = `/data/v1/accounts/${encodeURIComponent(config.connection_id)}/transactions`;
    66	  const res = await client.request<TrueLayerTransactionsResponse>(path, {
    67	    query: { from: options.since, to: until },
    68	  });
    69	
    70	  const transactions: OpenBankingTransaction[] = (res.results ?? []).map((r) => ({
    71	    transaction_id: r.transaction_id,
    72	    posted_at: r.timestamp,
    73	    amount: r.amount,
    74	    currency: r.currency,
    75	    description: r.description,
    76	    reference: r.meta?.reference ?? null,
    77	    raw_provider_payload: r as unknown as Record<string, unknown>,
    78	  }));
    79	
    80	  await cache.set(key, transactions, TRANSACTIONS_CACHE_TTL_MS);
    81	  return transactions;
    82	}
     1	{
     2	  "compilerOptions": {
     3	    "target": "ES2022",
     4	    "module": "ESNext",
     5	    "moduleResolution": "Bundler",
     6	    "lib": ["ES2022"],
     7	    "outDir": "./dist",
     8	    "rootDir": "./src",
     9	    "strict": true,
    10	    "noImplicitAny": true,
    11	    "strictNullChecks": true,
    12	    "noUnusedLocals": true,
    13	    "noUnusedParameters": true,
    14	    "noImplicitReturns": true,
    15	    "noFallthroughCasesInSwitch": true,
    16	    "esModuleInterop": true,
    17	    "forceConsistentCasingInFileNames": true,
    18	    "resolveJsonModule": true,
    19	    "declaration": true,
    20	    "sourceMap": true,
    21	    "skipLibCheck": true,
    22	    "types": ["node"]
    23	  },
    24	  "include": ["src/**/*"],
    25	  "exclude": ["node_modules", "dist", "tests"]
    26	}

exec
/bin/zsh -lc 'pnpm --dir packages/mcp-connectors/open-banking test' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'pnpm --dir packages/mcp-connectors/open-banking typecheck' in /Users/madsadmin/code/CortexOS
 succeeded in 1602ms:

> @ifos/open-banking@0.1.0 typecheck /Users/madsadmin/code/CortexOS/packages/mcp-connectors/open-banking
> tsc --noEmit


 succeeded in 2237ms:

> @ifos/open-banking@0.1.0 test /Users/madsadmin/code/CortexOS/packages/mcp-connectors/open-banking
> vitest run


 RUN  v2.1.9 /Users/madsadmin/code/CortexOS/packages/mcp-connectors/open-banking

 ✓ tests/token-aging.test.ts (6 tests) 2ms
 ✓ tests/rate-limit.test.ts (5 tests) 3ms
 ✓ tests/auth.test.ts (8 tests) 80ms
 ✓ tests/scaffold.test.ts (5 tests) 3ms
 ✓ tests/capabilities.test.ts (4 tests) 83ms

 Test Files  5 passed (5)
      Tests  28 passed (28)
   Start at  11:38:49
   Duration  1.21s (transform 374ms, setup 0ms, collect 696ms, tests 171ms, environment 1ms, prepare 375ms)


exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '630,640p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   630	      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
   631	      posted_at: {type: timestamp, required: true, source: Open Banking provider}
   632	      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
   633	      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
   634	      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   635	      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   636	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
   637	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
   638	      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   639	      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
   640	      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/open-banking/src/types.ts | sed -n '1,30p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// Open Banking API types — provider-agnostic core + provider-tagged variants.
     2	// IFOS Cash Conductor consumes via the provider-switching client façade.
     3	//
     4	// Provider scope (W4 Day-26 scaffold):
     5	//   - TrueLayer: fully implemented (v1.0 path per Cash Conductor §9 Q2).
     6	//   - Plaid UK: interface defined; implementation deferred to v1.1+ (throws
     7	//     NotImplementedError until then).
     8	
     9	export type OpenBankingProvider = "truelayer" | "plaid-uk";
    10	
    11	export interface OpenBankingTokens {
    12	  access_token: string;
    13	  refresh_token: string;
    14	  /** Unix epoch milliseconds when access_token expires (~1h TrueLayer / ~1h Plaid). */
    15	  expires_at_ms: number;
    16	  /**
    17	   * Unix epoch milliseconds when the PSD2 CONSENT expires (~90 days).
    18	   * Distinct from refresh_token expiry — PSD2 mandates user re-authentication
    19	   * every 90 days regardless of refresh-token TTL.
    20	   */
    21	  consent_expires_at_ms: number;
    22	  scope: string;
    23	  token_type: string;
    24	}
    25	
    26	export interface OpenBankingConfig {
    27	  provider: OpenBankingProvider;
    28	  client_id: string;
    29	  client_secret: string;
    30	  /** Per-bank-connection identifier from the provider (TrueLayer: account_id; Plaid UK: item_id). */

codex
The test and typecheck commands both passed, so the rejection is not for build breakage. The blocking problems are semantic/spec compliance: schema enum mismatch, retry/auth behavior mismatch, and missing required error fixtures for the read capabilities.
codex
REJECTED

1. Schema enum mismatch for the Plaid provider. `packages/mcp-connectors/open-banking/src/types.ts` line 9 defines `OpenBankingProvider = "truelayer" | "plaid-uk"`, but `docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml` line 636 defines `bank_provider` enum as `[truelayer, plaid_uk, open_banking_direct]`. This violates top-level Rule 2 because the connector assumes a structured provider value not present in schema. Fix by aligning the connector/provider config to `plaid_uk` or adding a schema-backed translation boundary before any tenant state uses it.

2. The documented 401 retry/auth policy is not implemented. `README.md` line 155 says `401 from any GET` will force-refresh the access token and end as `OpenBankingAuthError`, but `src/client.ts` lines 137-140 only clears `current_tokens` and retries; the next attempt reloads the same disk token and may never force refresh. On final 401, lines 165-168 throw generic `OpenBankingError`, not `OpenBankingAuthError`, breaking review-mcp-connector §4 and the ESC mapping. Fix by explicitly calling `refreshTokens()` on 401 and throwing `OpenBankingAuthError` on refresh/retry exhaustion.

3. Fixture-first error coverage is missing for the TrueLayer read capabilities. `tests/capabilities.test.ts` lines 80-109 cover only happy-path fixture responses for `listTransactionsSince` and `getAccountBalance`; lines 112-127 only test the Plaid `NotImplementedError` stub. review-mcp-connector §6 requires each capability to have at least one canonical success fixture and at least one 4xx/5xx/rate-limit/malformed error fixture. Add TrueLayer error-path fixture tests for both read capabilities, including the typed error/ESC contract expected by the README.
tokens used
73,133
REJECTED

1. Schema enum mismatch for the Plaid provider. `packages/mcp-connectors/open-banking/src/types.ts` line 9 defines `OpenBankingProvider = "truelayer" | "plaid-uk"`, but `docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml` line 636 defines `bank_provider` enum as `[truelayer, plaid_uk, open_banking_direct]`. This violates top-level Rule 2 because the connector assumes a structured provider value not present in schema. Fix by aligning the connector/provider config to `plaid_uk` or adding a schema-backed translation boundary before any tenant state uses it.

2. The documented 401 retry/auth policy is not implemented. `README.md` line 155 says `401 from any GET` will force-refresh the access token and end as `OpenBankingAuthError`, but `src/client.ts` lines 137-140 only clears `current_tokens` and retries; the next attempt reloads the same disk token and may never force refresh. On final 401, lines 165-168 throw generic `OpenBankingError`, not `OpenBankingAuthError`, breaking review-mcp-connector §4 and the ESC mapping. Fix by explicitly calling `refreshTokens()` on 401 and throwing `OpenBankingAuthError` on refresh/retry exhaustion.

3. Fixture-first error coverage is missing for the TrueLayer read capabilities. `tests/capabilities.test.ts` lines 80-109 cover only happy-path fixture responses for `listTransactionsSince` and `getAccountBalance`; lines 112-127 only test the Plaid `NotImplementedError` stub. review-mcp-connector §6 requires each capability to have at least one canonical success fixture and at least one 4xx/5xx/rate-limit/malformed error fixture. Add TrueLayer error-path fixture tests for both read capabilities, including the typed error/ESC contract expected by the README.
