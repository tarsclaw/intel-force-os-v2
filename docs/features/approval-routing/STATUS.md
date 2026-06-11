# Approval-routing + The Desk — STATUS board

_Orchestrator refreshes at every milestone. Spec: `docs/specs/approval-routing-architecture.md` · Plan: `PLAN.md` (founder-approved 2026-06-11)._

**Phase:** Wave 1 review loops. W1 built (67/67, gate PASS; review in flight). W2 built + review PASS (all 12 seed judgements accepted; 2 MINORs fixed on branch) + Codex R1 REJECTED:2 → both findings incorporated (standing approvals → Postgres decision_log rows, boundary-3 fix; status vocabulary) → R2 in flight.

| Slice | Content | Status | Branch | Gates |
|---|---|---|---|---|
| W1 | approval-routing pkg (resolver core) | 🟡 built — 67/67 vitest, gate PASS; review in flight; NOTE: bullhorn CLI normalisers drop `owner` pre-upsert (W3 inherits the one-line fix) | `worktree-agent-ac81e530c28302bbb` | gate ✓ |
| W2 | registry (53 rows) + 3 ESC codes + holding-reply template | 🟡 review PASS + Codex R1 fixes applied (`e280054`); R2 in flight | `worktree-agent-aa7320163e4edb70d` | gate ✓ review ✓ |
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
