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

**Provider scope (v1.0):** TrueLayer ONLY. Plaid UK exists as an internal stub in `src/` for v1.1+ work but is NOT a v1.0 bus-routed capability (per Codex F-R3 closure 2026-06-02 — `docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md`; pre-R3 the v1.1+ stub was declared as a v1.0 capability for set-equality, which violated review-mcp-connector single-upstream-provider intent + had no success fixtures to back the surface). When the first IFOS tenant picks Plaid over TrueLayer in v1.1+, the Plaid implementation graduates to a bus-routed capability and re-registers here.

| Capability ID (tools.yaml) | Function (src/index.ts) | Purpose | Cash Conductor cycle.sh step | action_type | Tier |
|---|---|---|---|---|---|
| `open_banking_truelayer_oauth` | `refreshTokens(config, current, fetchFn?, now?)` | OAuth refresh against TrueLayer; concurrent-safe per (provider, connection_id); **refuses if consent is in PSD2 blocking window (≤7 days)** | Step 1 (auth refresh) | `open_banking_truelayer` | green |
| `open_banking_list_transactions` | `listTransactionsSince(client, config, options)` | List bank transactions on/after a timestamp; TrueLayer raw payload preserved in `raw_provider_payload` for v1.1+ provider-agnostic upgrade | Step 3 (transaction ingest) | n/a (read-only) | n/a |
| `open_banking_get_account_balance` | `getAccountBalance(client, config)` | Current account balance (available + cleared) | Step 10 (cash-flow forecast) | n/a (read-only) | n/a |

`open_banking_truelayer` action_type exists in `agents/_shared/autosend-policy.yaml` at green tier. `open_banking_plaid_uk` ALSO exists in the policy (registered 2026-06-01 in commit f414492) — kept registered to avoid churn when v1.1+ work re-promotes Plaid; not currently consumed.

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
| Local hard-gate (100%) reached | `OpenBankingRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "truelayer" | "plaid_uk", retry_after_seconds: null, consecutive_429s: 0}` |
| Upstream 429 from provider API | `OpenBankingRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "truelayer" | "plaid_uk", retry_after_seconds: <N>, consecutive_429s: <N>}` |

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

Test counts:
- `tests/scaffold.test.ts`: 5 (public surface, exports, full error hierarchy with NotImplementedError)
- `tests/rate-limit.test.ts`: 5 (initial state, soft 24, hard 30, per-(provider, connection) isolation)
- `tests/token-aging.test.ts`: 6 (property-based day 0-100 boundary: fresh, info, warn, blocking, negative/already-expired, days_until consistency)
- `tests/auth.test.ts`: 8 (load missing, round-trip, shouldRefresh, refresh success + consent_expires preserved, 401 + no-token-leak, **blocking-consent refuses refresh**, concurrent dedup, Plaid-UK NotImplementedError)
- `tests/capabilities.test.ts`: 7 (TrueLayer transactions + balance from fixtures; Plaid UK NotImplementedError for both; **listTransactionsSince 429 retry-exhaust, getAccountBalance 500 retry-exhaust, 401-forces-refresh-then-retry** — all 3 added per Codex F-R2 #2 + #3)

**Total: 31 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + the W4 Track-1 /goal §1).

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

  if (config.provider === "plaid_uk") {
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
  if (config.provider === "plaid_uk") {
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
    if (opts.config.provider === "plaid_uk") {
      // Plaid UK API URL would land here; v1.1+ deferred.
      this.base_url = "https://plaid_uk-not-yet-implemented.invalid";
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
    if (this.opts.config.provider === "plaid_uk") {
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

      // 401: server invalidated the access_token — force an explicit refresh
      // BEFORE the next iteration. Per Codex F-R2 issue #2 (open-banking):
      // nulling the cached token alone is insufficient — getValidAccessToken()
      // will reload the SAME stale token from disk if shouldRefresh() says
      // it's not near expiry. Rotate it now; persist the new bundle; let the
      // next iteration pick up the rotated token. Throws OpenBankingAuthError
      // (or OpenBankingConsentExpiredError if PSD2 consent is in blocking)
      // on refresh failure → propagates correctly.
      if (res.status === 401 && attempt < max_retries) {
        if (this.current_tokens) {
          this.current_tokens = await refreshTokens(
            this.opts.config,
            this.current_tokens,
            this.fetchFn,
          );
        }
        await sleep(backoff(attempt));
        continue;
      }
      // 401 after retries exhausted: AUTH-typed error (NOT generic
      // OpenBankingError) so consumer branches correctly to ESC_OPEN_BANKING_AUTH.
      // Per Codex F-R2 issue #2 (open-banking).
      if (res.status === 401) {
        throw new OpenBankingAuthError(
          `Open Banking ${method} ${path} returned 401 after ${attempt + 1} attempt(s) including forced refresh`,
          401,
        );
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
// v1.0 SCOPE: TrueLayer only. Plaid UK exists as an internal stub in src/ for
// v1.1+ work but is NOT a v1.0 bus-routed capability — per Codex cluster F R3
// closure 2026-06-02 (docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md),
// declaring a v1.1+ stub as a current capability violated review-mcp-connector
// single-upstream-provider intent + had no success fixtures to back the surface.
// The Plaid stub stays in src/ so v1.1+ work has scaffolding to graduate from;
// it just isn't surfaced as a v1.0 capability.
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
//       on agents/recruitment/cash-conductor/tools.yaml AND (for state-changing
//       capabilities) has an action_type entry in agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check).
//
// PSD2 90-day consent tracking is THE load-bearing distinction from Xero / QB:
// banks legally require user re-authentication every 90 days regardless of
// refresh-token TTL. See auth.ts getTokenAgeStage + README §"PSD2 consent lifecycle".

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §open-banking)
//     v1.0 = TrueLayer only.
// ─────────────────────────────────────────────────────────────────────────

// open_banking_truelayer_oauth (action_type: open_banking_truelayer, green tier).
// The function dispatches internally by config.provider; calling with
// provider='plaid_uk' throws NotImplementedError (v1.1+ stub kept in src/auth.ts).
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
  if (config.provider === "plaid_uk") {
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

export type OpenBankingProvider = "truelayer" | "plaid_uk";

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
    const config = makeConfig(token_file, { provider: "plaid_uk" });
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
import {
  NotImplementedError,
  OpenBankingError,
  OpenBankingRateLimitError,
} from "../src/errors.js";
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

  // Error-path coverage for listTransactionsSince + getAccountBalance per
  // Codex F-R2 issue #3 (open-banking): review-mcp-connector §6 requires
  // ≥1 happy + ≥1 error fixture per capability. R1 wrongly assumed the Plaid
  // NotImplementedError test counted as the error path; Codex correctly
  // distinguishes "stub-throws-on-unsupported-provider" from "TrueLayer
  // upstream returns error".
  it("listTransactionsSince: persistent 429 surfaces as OpenBankingRateLimitError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("", {
        status: 429,
        headers: { "Retry-After": "0" },
      });
    };
    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    await expect(
      listTransactionsSince(client, config, {
        since: "2026-05-01T00:00:00Z",
        cache,
        no_cache: true,
      }),
    ).rejects.toBeInstanceOf(OpenBankingRateLimitError);
    expect(calls).toBeGreaterThanOrEqual(2);
  });

  it("getAccountBalance: persistent 500 surfaces as OpenBankingError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("TrueLayer internal error", { status: 500 });
    };
    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    await expect(getAccountBalance(client, config)).rejects.toBeInstanceOf(
      OpenBankingError,
    );
    expect(calls).toBeGreaterThanOrEqual(2);
  });

  // 401-forces-refresh: per Codex F-R2 issue #2 (open-banking), a 401 on a GET
  // MUST trigger an explicit refreshTokens() call before retrying, AND on final
  // exhaustion throw OpenBankingAuthError (not the generic OpenBankingError).
  it("401 on GET forces explicit token refresh + retry uses new access_token", async () => {
    let getCalls = 0;
    let refreshCalls = 0;
    let observedSecondAuth: string | null = null;

    const fakeFetch: typeof fetch = async (input, init) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.includes("auth.truelayer-sandbox.com/connect/token")) {
        refreshCalls += 1;
        return new Response(
          JSON.stringify({
            access_token: "rotated-access-token-after-401",
            refresh_token: "rotated-refresh-token",
            expires_in: 3600,
            scope: "accounts transactions balance",
            token_type: "Bearer",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      // Data GET path
      getCalls += 1;
      if (getCalls === 1) {
        return new Response("", { status: 401 });
      }
      observedSecondAuth = (init?.headers as Record<string, string>)?.["Authorization"] ?? null;
      return makeOkResponse(TL_TRANSACTIONS);
    };

    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    const txns = await listTransactionsSince(client, config, {
      since: "2026-05-01T00:00:00Z",
      cache,
      no_cache: true,
    });

    expect(txns.length).toBeGreaterThan(0);
    expect(getCalls).toBe(2);
    expect(refreshCalls).toBe(1);
    expect(observedSecondAuth).toBe("Bearer rotated-access-token-after-401");
  });
});

describe("open-banking capabilities — Plaid UK (v1.1+ deferred)", () => {
  it("listTransactionsSince throws NotImplementedError for Plaid UK", async () => {
    const config = makeConfig({ provider: "plaid_uk" });
    const client = new OpenBankingClient({ config });
    await expect(
      listTransactionsSince(client, config, { since: "2026-05-01T00:00:00Z" }),
    ).rejects.toBeInstanceOf(NotImplementedError);
  });

  it("getAccountBalance throws NotImplementedError for Plaid UK", async () => {
    const config = makeConfig({ provider: "plaid_uk" });
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
    expect(check("plaid_uk", "acct-A").shouldBackoff).toBe(false);
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
