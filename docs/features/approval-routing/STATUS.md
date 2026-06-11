# Approval-routing + The Desk — STATUS board

_Orchestrator refreshes at every milestone. Spec: `docs/specs/approval-routing-architecture.md` · Plan: `PLAN.md` (founder-approved 2026-06-11)._

**Phase:** Wave 1 COMPLETE — both slices PROPOSED FOR FOUNDER MERGE (2026-06-11).

| Slice | Content | Status | Branch | Gates |
|---|---|---|---|---|
| W1 | approval-routing pkg (resolver core) | ✅ **PROPOSED** @ `5d3e000` (6 commits, 86/86 vitest): review PASS (9/9 deviations accepted; MAJOR parser fix applied + 19 regression tests); Codex rides W3's round per bridge precedent. W3 inherits: bullhorn normaliser owner fix + registry-envelope collapse | `worktree-agent-ac81e530c28302bbb` | gate ✓ review ✓ |
| W2 | registry (53 rows) + 3 ESC codes + holding-reply template | ✅ **PROPOSED** @ `7e308b0` (8 commits): review PASS (12/12 judgements accepted); Codex trail 2→2(wrong-skill rounds)→2-incorporated under the NEW review-policy-config skill; standing approvals now Postgres-canonical (boundary 3) | `worktree-agent-aa7320163e4edb70d` | gate ✓ review ✓ codex trail ✓ |
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
