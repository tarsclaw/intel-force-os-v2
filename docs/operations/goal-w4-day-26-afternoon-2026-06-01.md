# /goal — W4 Day-26 afternoon: bundle completion + bridge + polish (2026-06-01)

**Window:** ~6h (14:30 → 20:30 local). Continuation of morning goal `goal-w4-day-26-2026-06-01.md` (Phases 1+2+3 closed at commit `5d15130`). Phase A bundle (~3h) → Phase B bridge (~2.5h) → Phase C polish (~0.5h).

## §0 Read first
Morning goal + this goal's §1 · `agents/recruitment/cash-conductor/agent.md` §3+§4+§5 (consumer spec) · `packages/mcp-connectors/{xero,quickbooks,open-banking}/` (pattern) · `docs/decisions/2026-05-31-d1-founder-decision.md` §"Implementation surface" (bridge contract) · `agents/_shared/{hook-helpers.sh,autosend-policy.yaml}` (existing helpers + action_type registry) · `agents/recruitment/diagnostic/{context,cleanup}.sh` (sibling pattern for Phase A files).

## §1 Phase A — Cash Conductor bundle completion (~3h, 3-5 commits)
1. `agents/recruitment/cash-conductor/context.sh` — hydration: CTX env + accounting auth probe + Open Banking token + voice corpus + tone rules + `last_chase_position` lookup. Mirrors `agents/recruitment/diagnostic/context.sh` pattern + 4-candidate `_shared/` fallback.
2. `agents/recruitment/cash-conductor/cleanup.sh` — transient OAuth cache purge + provider rate-limit cache + emit `cash_conductor_cleanup` green-tier audit row.
3. `agents/recruitment/cash-conductor/fixtures/01-primary.yaml` — happy path: Stage-1 exact match → auto reconciliation write → 1 chase draft at position 1.
4. `.../fixtures/02-edge-case-fuzzy-match.yaml` — Stage-4 fuzzy multi-candidate → `ESC_RECONCILIATION_AMBIGUOUS` + queued for consultant review.
5. `.../fixtures/99-token-aging-canary.yaml` — Open Banking token at 6 days → blocking stage refuses refresh → `ESC_OPEN_BANKING_TOKEN_AGING` blocking emission.

Closes goal-week-4-track-1.md §1 criteria 5-10. Cluster F-bis manifest entry queued (Cash Conductor agent-bundle skill) — actual entry to `run-codex-ratification.sh` lands at start of Day-27 when ready to fire cluster F + F-bis together.

## §2 Phase B — `@ifos/autosend-bridge-telegram` scaffold (~2.5h, 1 commit)
Package at `packages/utilities/autosend-bridge-telegram/`. Mirrors MCP-connector structure (package.json + tsconfig + vitest.config + tsup.config + README ≥120 lines + src + tests + fixtures).

Public API (per D1-B decision doc §"Implementation surface"):
- `proposeApproval({action_type, target, draft_preview, vault_path, timeout?}) → {approval_id}` — posts to operator's tenant Telegram chat with `[ID:<approval_id>]` prefix + draft preview + vault path + `/approve <id>` / `/reject <id>` instructions
- `awaitApprovalDecision(approval_id, options?) → {outcome: "approved"|"rejected"|"timeout", decided_by, decided_at}` — polls Telegram for the operator's reply (or webhook in v1.1+)
- Telegram bot token from `_secrets.env` (existing per Day-4 provisioning); operator chat ID from `tenant_adapters.config.operator_telegram_chat_id` (canonical config key)
- Default timeout `PT4H` per `escalation-codes.md` lines 348-353 (`ESC_APPROVAL_BRIDGE_TIMEOUT`)
- Fail-safe: timeout returns `{outcome: "timeout"}` not an exception — caller (Cash Conductor cycle.sh Step 10, Concierge cycle.sh) decides how to fire the ESC code

≥12 vitest (scaffold + config + propose + await with poll-mock + timeout + reject path + concurrent same-approval-id idempotency). Live Telegram tests gated `BRIDGE_LIVE_TESTS=true`. Zero credential interpolations in errors. README documents D1-B precedent + Concierge W10 integration contract + Cash Conductor `cycle.sh` Step 10 wiring.

## §3 Phase C — 2 polish follow-ups (~0.5h, 2 commits)
6. `scripts/run-tenancy-audit.sh` T12 grep heuristic — refine the candidate-slug-refs grep to exclude lines containing `phase=`, `#` comment leaders, JSON example data (the 4 false positives flagged in yesterday's audit: hook-helpers.sh:166/177 + autosend-policy.yaml:116 + common-target-patch.json:12). Re-run audit to confirm zero noise.
7. `scripts/run-tenancy-audit.sh` `decision_log` write — wrap the audit-row INSERT in `BEGIN; SET LOCAL app.current_tenant='ifos-meta'; INSERT ...; COMMIT;` so RLS doesn't block + the row lands in Postgres rather than the JSONL fallback.

## §4 Scope OUT
No commercial signups · no live API (fixture-first; `MCP_LIVE_TESTS`/`BRIDGE_LIVE_TESTS` off) · no Codex runs (founder triggers cluster F + F-bis) · no live VPS work · no edits to ratified artefacts outside explicit scope · no ECC package installs · no cortextOS submodule edits except shadow points · **NO Sage MCP connector** (Q8 deferred) · **NO voice classifier microservice** (queued for Tue/Wed — lower concentrated leverage today than bridge).

## §5 Per-commit gates
`pnpm typecheck` clean (per modified TS package) · `pnpm test` green (≥12 vitest for bridge; bundle fixtures don't add new vitest) · `shellcheck` clean (any new/modified .sh) · 0 hardcoded secrets · 0 Composio/AgentMail · re-grep cited line numbers AFTER edit (R2 ADR-007 320→326 lesson) · atomic per-artefact commits + Co-Authored-By footer · tests BEFORE commit; never commit red.

## §6 Failure modes
Phase A bundle complexity surge (any file >120 min): commit progress, skip to Phase B — bundle is fixture-static, can land partial without breaking morning's bundle skeleton · Bridge Telegram API ambiguity in poll-mode mechanics: commit clean fixture cases for the easy paths, document the open question in README, defer live integration test · Phase C polish reveals a deeper issue in `run-tenancy-audit.sh`: commit progress, raise concern for Day-27 deeper fix · Red tests: STOP, fix, never commit red · Any artefact would need Codex R3 (none scheduled today): STOP, escalate per learning 01.

## §7 Ask vs proceed
Proceed: file internals, fixture content, bridge API shape, README structure, per-step decisions within scope.
Ask: deviation from D1-B decision doc · deviation from agent.md output contract · commercial signup · live API call · ratified-artefact edit · ECC package install · Codex disagreement.

## §8 End-of-day report (appended to morning's EOD)
Print: phase A/B/C status + commit SHAs · test counts (bridge: ≥12 vitest target) · Cash Conductor bundle 100% complete? · bridge package scaffold complete? · 2 polish items closed? · founder action board refresh · tomorrow's first action (cluster F + F-bis ratification triggers when founder ready; voice classifier microservice begins Tue scaffold).

*End of /goal.*
