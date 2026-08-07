# Approval-routing + The Desk — STATUS board

_Orchestrator refreshes at every milestone. Spec: `docs/specs/approval-routing-architecture.md` · Plan: `PLAN.md` (founder-approved 2026-06-11)._

**Phase:** Wave 1 **MERGED TO MAIN 2026-08-07** (`0020fdc`, fast-forward, 17 commits). Wave 2 (W3 + W7) unblocked.

| Slice | Content | Status | Branch | Gates |
|---|---|---|---|---|
| W1 | approval-routing pkg (resolver core) | ✅ **MERGED** @ `5d3e000` (6 commits, 86/86 vitest): review PASS (9/9 deviations accepted; MAJOR parser fix applied + 19 regression tests); Codex rides W3's round per bridge precedent. W3 inherits: bullhorn normaliser owner fix + registry-envelope collapse | merged, branch deleted | gate ✓ review ✓ |
| W2 | registry (53 rows) + 3 ESC codes + holding-reply template | ✅ **MERGED** @ `7e308b0` (8 commits): review PASS (12/12 judgements accepted); Codex trail 2→2(wrong-skill rounds)→2-incorporated under the NEW review-policy-config skill; standing approvals now Postgres-canonical (boundary 3) | merged, branch deleted | gate ✓ review ✓ codex trail ✓ |
| W3 | orange-path integration + backcompat suites | ⏳ wave 2 (needs W1+W2 on main) | — | — |
| W4 | graduation + standing approvals | ⏳ wave 3 | — | — |
| W5 | escalation/on-expiry/quiet-hours/digest | ⏳ wave 3 | — | — |
| W6 | Teams C1 surface | ⏳ wave 3 | — | — |
| W7 | brain retrieval (Desk substrate) | ⏳ wave 2 (needs W1 on main) | — | — |
| W8 | The Desk chat + approve-in-thread | ⏳ wave 4 | — | — |
| C2 | Azure bot + live Graph + VPS TLS + mobile push | 🔒 pilot/founder-gated | — | runbook |

**Method:** parallel worktree workers; per slice build-gate PASS + review-subagent + Codex (≤2 rounds) + founder merge proposal at wave boundaries.
**Founder decisions locked:** all spec-§10 defaults · VPS+TLS endpoint · Desk in `packages/brain` · full sequence, Telegram digest interim.
**Open founder items (non-blocking):** VPS TLS ops session · Telegram-digest-for-pilots confirm · split-desk prospect re-confirms §10.4/§10.5.

## Merge verification — 2026-08-07 (independent re-run before merge)

Both slices re-verified from scratch, not taken on the boards' word:

- **W1** — typecheck CLEAN, 86/86 vitest (7 files); 0 files under `packages/harness/` (boundary 1 ✓); 0 adapter-boundary violations (boundary 2 ✓); pure new package, touches nothing in `agents/`.
- **W2** — 5/5 YAML parse; **registry↔autosend-policy set equality 53 = 53, zero drift either direction** (PLAN decision 4 confirmed; the `47` in autosend-policy's header is stale text, not a join defect); all 53 types carry all 7 required fields; 3/3 new ESC codes present.
- **Integration** — zero merge conflicts, **zero file overlap** between slices; full `build-gate.sh` PASS.
- **Post-merge on main** — shellcheck CLEAN (60 files) · 9 packages typecheck+vitest green · 18 DB-backed fixture suites green · **BUILD GATE: PASS**.

**Gap found and closed pre-merge:** `scripts/build-gate.sh` loops a hardcoded package list; `packages/utilities/approval-routing` was absent, so W1's 86 tests never ran in the gate and a regression would have shipped silently. Fixed at `0020fdc`. (The tier-4 fixture loop auto-discovers `run-*-test.sh`; the tier-2+3 package loop does not.) **Still outside the gate:** `diagnostic-generator`, `agent-renderer`, `granola`, `workos`.

**Three PLAN deviations recorded (none blocking):**
1. PLAN §14 names six function roles; registry uses four — `candidate_comms_default` / `client_comms_default` unused.
2. PLAN §14 allows `on_expiry: hold|auto_execute|safe_default`; registry uses only `hold` + `safe_default` — **no action type can auto-execute on expiry**. More conservative than specced; judged correct.
3. PLAN §14 says "v1.1 agents seeded `dormant: true`" but only `open_banking_plaid_uk` is dormant. Forced by decision 4 — set-equality against a v1.0-only `autosend-policy.yaml` makes v1.1 rows impossible. Decision 4 wins; the PLAN sentence is stale text, not a build error.
