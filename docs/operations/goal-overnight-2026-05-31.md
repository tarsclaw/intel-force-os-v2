# /goal — Overnight W4 Track-1 + smoke-fix (2026-05-31 → 2026-06-01)

**Authored:** evening 2026-05-31 (founder asleep; Claude executes autonomously)
**Window:** ~8 hours of session-equivalent; ship 2-3; never commit red
**Supersedes:** nothing. Tighter subset of `docs/operations/goal-week-4-track-1.md`.

## Context

- W3 contracts ratified (8/9 + R3 fix); ADR-007 Accepted; D1-B taken.
- v0.3 migration LIVE on VPS (R3 rollback fix applied via stdin-pipe wrapper); tenancy audit 12/12 PASS.
- Diagnostic smoke ran 2026-05-31 evening: Gate A PASS, 12 sections, 621 words. Two findings: (a) Anthropic credits empty → §12 deterministic fallback fired (founder tops up AM); (b) validate.sh has 2 path bugs looking for shared helpers in wrong dir.

## Reading

1. `CLAUDE.md` (5 rules + 4 boundaries + Karpathy discipline)
2. `docs/operations/goal-week-4-track-1.md` §0 + §2 + §9 (canonical W4 spec)
3. `packages/mcp-connectors/companies-house/` in full (reference pattern; every new connector mirrors this)
4. `.codex/ratification/review-agent-bundle.md` (skill structure template)

## Ships (in order)

### 1. HOTFIX validate.sh path bugs (~20 min)

Two `No such file/found` lookups in `agents/recruitment/diagnostic/validate.sh` + autosend lookup helper. Resolve to the real `agents/_shared/` path (with `IFOS_REPO_ROOT` fallback chain like `context.sh` already does). Re-test against the Hays smoke to confirm zero warnings on the deterministic path. Commit atomically.

### 2. `.codex/ratification/review-mcp-connector.md` Codex skill (~90 min)

Author modeled on `review-agent-bundle.md`. 7 checks layered on top of `SKILL.md`:
1. Capabilities surface — every declared capability has a TS export.
2. OAuth refresh idempotency — concurrent-refresh safety; no torn `_secrets.env` writes.
3. Rate-limit budget declared — upstream limit cited + safety margin documented in README.
4. Explicit retry policy — 429/5xx handling, max retries, backoff, ESC on exhaustion.
5. No secret logs — grep package source for `console.log.*KEY|SECRET|PASSWORD`; must be 0.
6. Fixture-first tests — every capability has ≥1 fixture; live tests behind `MCP_LIVE_TESTS=true`.
7. `decision_log` integration via `_shared/hook-helpers.sh`; action_types match `autosend-policy.yaml`.

Output format identical to existing skills (RATIFIED + ≤5 advisory lines OR REJECTED + numbered issues with line/section + concrete fix). Commit.

### 3. `packages/mcp-connectors/xero/` scaffold (~3-4 hours)

Mirror `@ifos/companies-house` structure exactly:
- `package.json` (workspace), `tsconfig.json`, `vitest.config.ts`, `README.md` (≥150 lines, Xero rate-limit 60/min per tenant + 5000/day per https://developer.xero.com/documentation/guides/oauth2/limits)
- `src/{index, auth, invoices, payments, types, cache, rate-limit}.ts`
- `tests/{auth, invoices, payments, rate-limit}.test.ts` — ≥15 vitest
- `fixtures/{invoices-page-1, invoices-page-2, payments-recent, payment-write-ok, payment-write-409}.json`
- Capabilities: `oauth_refresh`, `list_open_invoices`, `list_payments`, `get_invoice`, `write_payment_received`. Atomic commit.

### 4. (stretch) `packages/mcp-connectors/quickbooks/` (~3-4 hours)

Same shape as Xero. QB OAuth is per-realm — document diff in README. ≥12 vitest. Atomic commit.

### 5. End-of-night state sync

Update `.agents/current-priorities.md` (W4-day-25-overnight section) with shipped items + smoke outcome + 2 path bugs fixed + Anthropic-credit founder-action queued + next-step on pickup. Commit.

## Scope OUT (don't touch)

- Live API calls (no commercial signups yet — fixture-first is the gate)
- Codex runs (founder triggers cluster F when ready)
- Live VPS work (Path A; no creds)
- Open Banking connector (90-day token rotation — needs daytime focus)
- Cash Conductor bundle scaffold (depends on connectors landing first)
- Modifying ratified artefacts (W3 8/9 RATIFIED + ADR-007 Accepted; no regression risk)

## Quality gates per commit

- `shellcheck` clean on any modified `.sh`
- `pnpm typecheck` + `pnpm test` green per modified package
- 0 hardcoded secrets (grep diff for `[A-Za-z0-9_-]{32,}` in non-fixture files)
- 0 `composio|agentmail` in `agents/` (grep)
- Tests BEFORE commit; never commit red

## End-of-night report (last turn before founder wakes)

Print summary:
- Items completed + commit SHAs
- Test counts per package shipped
- Path-bug fixes verified by re-running the Hays smoke
- Anthropic-credit founder-action queued for AM
- Next step on pickup: cluster F manifest entry + Open Banking connector + Cash Conductor bundle

## Failure modes

- Step 1 (validate.sh path bugs) blocks: stop; flag for founder review; do NOT skip — these are live runtime bugs.
- Step 2 (skill) > 120 min: commit progress, jump to Step 3, return later.
- Step 3 (Xero) reveals API doc ambiguity: commit clean cases against fixtures, flag ambiguous for daytime.
- Red test suite: STOP; fix; never commit red.

*End overnight goal.*
