# Agent-Build Orchestrator — LAUNCH ENTRYPOINT

**Point a fresh Claude Code (Fable 5, `--dangerously-skip-permissions`) session at THIS file.**
It is the single entrypoint for the parallel build of the remaining IFOS agents. Read it
top-to-bottom, then execute §C. Do not skip the gates.

> You are the **ORCHESTRATOR** (Fable 5). You own the plan, freeze the shared substrate,
> spawn one worktree sub-agent per agent spec, run the review loop, and report. You do NOT
> hand-write agent code yourself and you NEVER auto-merge to `main`.

---

## A. Read these first (context)

1. `CLAUDE.md` — 5 rules, 4 boundaries, Karpathy per-edit discipline, session rituals. **Binds every sub-agent.**
2. `docs/operations/parallel-agent-build-method.md` — the method: two-layer autonomy (§2), topology (§3), the 5-gate discipline (§4), visibility (§5), Resume Protocol (§6), Fable 5 + skip-permissions operating mode (§9), and the live status table (§7).
3. `docs/build-brief/00-MASTER-BRIEF.md` + `docs/specs/ULTRAPLAN.md` — the master plan the specs must match.
4. The per-agent build specs in `02-specs/` (one per agent — comprehensive, contract-linked).
5. The TWO proven reference templates (mirror these exactly):
   - **Diagnostic** (`agents/recruitment/diagnostic/`) — live LLM-output agent.
   - **Cash Conductor** (`agents/recruitment/cash-conductor/`) — live 14-step bundle: cycle.sh + validate.sh Gate A + cleanup.sh + reusable `sql/*.sh` + `bin/` + the six `scripts/run-*-test.sh` fixture suites. **This is the canonical agent-bundle live-wiring pattern.**

## B. The non-negotiable gates (method doc §4 + §9)

Skip-permissions removes the per-command prompt, NOT these:
1. **Worktree isolation** — every sub-agent works in its own `git worktree` on its own branch.
2. **Pre-commit hook** — `.githooks/pre-commit` (active via `core.hooksPath`) shellchecks staged shells; a red commit is blocked by git itself.
3. **Merge-readiness gate** — `bash scripts/build-gate.sh` MUST be green on a branch before merge (shellcheck + connector typecheck/vitest + all DB fixture suites).
4. **Review tier** — a review sub-agent + `bash scripts/run-codex-ratification.sh` (where configured) judge the branch against its spec + adjacent contracts.
5. **Human merge gate** — the founder merges. The orchestrator proposes; it never merges to `main`.

## C. Execution loop (do this in order)

### Phase 0 — Freeze the shared substrate (serial, on `main`, BEFORE any fan-out)
The substrate is the upstream contract every sub-agent consumes read-only:
- `agents/_shared/` (hook-helpers.sh, voice-loader.sh, autosend-policy.yaml, escalation-codes.md)
- the migration chain (`docs/verticals/recruitment/migrations/`) + RLS invariants
- the v0.4 schema + any per-agent table/policy needs called out in that agent's spec under **Upstream contract**

Action: for each spec, check its **Upstream contract** section. If an agent needs a NEW
substrate element (a new `autosend-policy` action_type, a new migration, a new `_shared`
helper), land that on `main` FIRST (serial, gated), then mark it frozen in the method doc §7.
Confirm `bash scripts/build-gate.sh` is green on `main`. Only then fan out.

### Phase 1 — Prove ONE (Janitor) end-to-end
Spawn a single worktree sub-agent for `02-specs/spec-001-janitor.md`. Let it run the full
implement→self-review→gate loop to a green branch. You (orchestrator) run `scripts/build-gate.sh`
+ a review sub-agent on the branch. Surface the branch to the founder for merge. This validates
the whole machine before 3×.

### Phase 2 — Fan out (parallel background worktree sub-agents)
Spawn, in parallel, one sub-agent per remaining spec that has no unmet upstream dependency:
`spec-002-scribe`, `spec-003-sourcing-scout`. Each runs in its own worktree + branch,
`run_in_background: true`. **Context-isolation (method §9):** give each sub-agent ONLY its
spec file + its agent.md + the named template pointers + CLAUDE.md — never this full session.

### Phase 3 — Review loop
As each sub-agent reports a green branch, spawn a review sub-agent: does it satisfy its spec's
acceptance criteria? does it honour adjacent contracts (decision_log markers, RLS, the four
boundaries)? `scripts/build-gate.sh` green? Iterate failures back to the implement sub-agent
(`SendMessage`) until the branch passes.

### Phase 4 — Concierge (last)
`spec-004-concierge` is partially downstream (it owns the autosend-bridge transport that
Cash Conductor's orange row opens). Build its independent parts; gate the integration parts on
the autosend-bridge production contract (W10-13). Follow the spec's dependency notes.

### Phase 5 — Merge gate
Each agent sits on a green, reviewed branch. Founder + Codex sign off + merge. Update method
doc §7 live status as each lands.

## D. Reporting (visibility — method §5)
Maintain `docs/features/agent-build/STATUS.md` (the build-board: agent | phase | status | branch |
last commit | review) and refresh it at every milestone. Post the board in chat on request ("status").
Each sub-agent writes a summary to `03-implementation/<agent>-summary.md`; each reviewer writes
`04-reviews/review-<agent>.md`.

## E. Done definition
Every agent on a green branch passing all 5 gates, OR any blocked agent committed-to-green with a
documented blocker in the method doc §7 + `STATUS.md`. Never auto-merge; never fake green.
