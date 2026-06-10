# Spec NNN — <Agent> build (template)

**This is a contract-linked build spec. A sub-agent given ONLY this file + the named agent.md
+ the template pointers + CLAUDE.md has everything it needs to build the agent autonomously.**

- **Agent dir:** `agents/recruitment/<agent>/`
- **Master-plan source (the detailed spec — READ IN FULL):** `agents/recruitment/<agent>/agent.md`
- **Mirror template:** Cash Conductor (`agents/recruitment/cash-conductor/`) — the proven 14-step
  bundle. Mirror its idioms exactly (see "Pattern mapping" below).
- **Build wave / tier / status:** <from agent.md header>

## 1. Scope (what this build delivers)
The TODO(W7-8/Wx) markers in the bundle replaced with live impl matching `agent.md`. Concretely:
cycle.sh steps <list> + validate.sh Gate A <G-list> + cleanup.sh + any reusable `sql/` + `bin/`
helpers + deterministic fixture tests. Out of scope: <deferred items>.

## 2. Upstream contract (what this build CONSUMES — must be frozen on main first)
- `agents/_shared/` substrate (hook-helpers, voice-loader, autosend-policy, escalation-codes).
- Postgres tables it reads/writes: <tables> (schema version <vN>). **New tables/policy/migration
  needed? → list here; the orchestrator lands it on main BEFORE this sub-agent spawns.**
- Connectors/CLIs it calls: <list>.
- autosend-policy action_types this agent owns (must be registered): <list + tier>.

## 3. Downstream contract (what this build MUST EXPOSE for adjacent components)
- decision_log markers other components/the weekly aggregations expect: <list>.
- State it writes that other agents read (e.g. cached rows, status fields): <list>.

## 4. Workflow steps to wire (from agent.md §4 — enumerate EVERY step)
| Step | agent.md ref | What to implement | decision_log marker | ESC on failure | CC pattern to mirror |
|---|---|---|---|---|---|
| N | §4 Step N | … | … | … | cycle.sh Step X / sql/… |
(One row per step. This table is the build checklist — nothing in agent.md §4 may be missed.)

## 5. Gate A (validate.sh) — enumerate every check (from agent.md §5)
| Check | Rule | ESC on fail | Enforcement |
|---|---|---|---|
| G1 | … | … | hard / warn / best-effort |

## 6. Acceptance criteria (the build is DONE when…)
- All §4 steps emit their contract markers (verify against decision_log after a live-smoke).
- All Gate A checks live per §5.
- `bash scripts/build-gate.sh` green; new fixture suite(s) added + green.
- shellcheck CLEAN; RLS-scoped; boundaries honoured; tree clean; atomic commits.

## 7. Test plan (deterministic fixtures — mirror scripts/run-*-test.sh)
- <new test script(s)> seeding crafted rows under a throwaway tenant in a ROLLBACK'd transaction
  (or registered-tenant + cleanup where decision_log FK applies), asserting <behaviours>.

## 8. Honest-scope flags (document, never fake)
- <e.g. empty voice_corpus → unscored; vendor NO-OP; webhook trigger deferred; etc.>

## 9. Dependencies + sequencing
- Blocked by: <upstream specs / substrate / founder actions>. Can run in parallel with: <specs>.
