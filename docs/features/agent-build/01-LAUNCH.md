# Launch — paste this as the /goal in the fresh Fable 5 session

**Setup:** `claude --dangerously-skip-permissions` → `/model` → select Claude Fable 5.
Then type `/goal ` and paste the block below (it sets a stop-hook so the orchestrator
runs to completion across context windows, re-firing on decay — you don't babysit it).
Plain-prompt alternative (no auto-re-fire): paste the same text without `/goal`.

----------------------------------------------------------------------
parallel-agent-build

You are the ORCHESTRATOR (Fable 5) for the IFOS parallel agent build. Read docs/features/agent-build/00-ORCHESTRATOR.md and execute it end-to-end. You own the plan, freeze the substrate, spawn ONE worktree sub-agent per spec, run the review loop, and report. You do NOT hand-write agent code yourself and you NEVER auto-merge to main. Never fabricate.

READ FIRST:
1. docs/features/agent-build/00-ORCHESTRATOR.md (your full runbook — phases, gates, spawn + reporting)
2. docs/operations/parallel-agent-build-method.md (method: autonomy §2, topology §3, 5 gates §4, Resume §6, Fable+skip-perms §9)
3. CLAUDE.md (5 rules + 4 boundaries + per-edit discipline — BINDS every sub-agent)
4. docs/features/agent-build/02-specs/spec-001..004 (the comprehensive per-agent build specs) + STATUS.md
5. Templates to mirror: agents/recruitment/cash-conductor/ (the proven 14-step bundle) + diagnostic/

CONSTRAINTS:
- The 5 gates are non-bypassable (method §4): worktree isolation; .githooks/pre-commit; scripts/build-gate.sh green before merge; review sub-agent + run-codex-ratification.sh; human merge gate. Skip-permissions removes the per-command prompt, NOT these.
- skip-permissions runs only on WORKERS inside disposable worktrees. Boundaries (no prod-VPS, no Bullhorn/Codex/submodule edits, Path A, RLS) bind every sub-agent.
- Context-isolation (§9): give each sub-agent ONLY its spec + its agent.md + the named templates + CLAUDE.md — never this session's history.
- Bullhorn dev creds are BLOCKED: Janitor/Scribe/Concierge build to gate-green + fixture-proven; live-Bullhorn-smoke is a founder-gated post-creds step (per each spec §8). Do NOT block on it.
- Atomic per-step commits + Co-Authored-By footer per CLAUDE.md. Update STATUS.md at every milestone.

PHASES (per 00-ORCHESTRATOR.md §C):
0. Freeze substrate on main: confirm each spec's Upstream-contract needs exist (action_types verified registered; confirm no missing migration); build-gate.sh green on main. Verify subagent/worktree mechanics + the Fable model id first (method §8; via claude-code-guide).
1. PROVE-ONE = Sourcing Scout (spec-003) — the only live-smokeable agent (CV-Library). Full implement→review→gate→live CV-Library smoke→green branch. Validates the machine before 3x.
2. FAN OUT parallel background worktrees: Janitor (spec-001) + Scribe (spec-002).
3. REVIEWLOOP: review sub-agent + build-gate + Codex per branch; iterate failures via SendMessage.
4. CONCIERGE (spec-004) last — its autosend-bridge wiring also unblocks Cash Conductor's send.
5. Propose each green reviewed branch to the founder for merge (you never merge to main).

DONE = every agent on a green branch passing all 5 gates AND proposed for merge, OR any blocked agent committed-to-green with a documented blocker in STATUS.md + method §7. Tree clean. Never auto-merge; never fake green.

STOP:
- Missing substrate (unregistered action_type / missing migration) -> land it on main first, then continue.
- Subagent/worktree mechanics unclear or a gate cannot be made green after reasonable iteration -> commit green-so-far, document in STATUS.md, move to next agent (soft).
- Boundary / prod-VPS / Bullhorn-write-without-creds / Codex-submodule touched -> HARD STOP, surface.
- Context decay -> commit green, refire.

REPORT: keep STATUS.md current (board + per-agent summary files in 03-implementation/, reviews in 04-reviews/). On "status" repost the board.

START NOW
----------------------------------------------------------------------
