# Parallel Agent Build Method — canonical approach + live status

**This is the durable source of truth for HOW we build the remaining IFOS agents.**
Loaded every session via the pointer in `.agents/current-priorities.md` (session-start
ritual step 5). When the founder says **"proceed with the agent build"**, follow the
Resume Protocol (§6) using the Live Status table (§7).

Authored 2026-06-09. Method adapted from agentic.james's "One Big Feature
Methodology" (founder-supplied breakdown; see memory [[reference-parallel-dev-cycle-reel]]).

---

## §1 — The core idea

Building all agents one-context-window-at-a-time takes months because it is serial
and re-derives context every session. The fix is a **hierarchical multi-agent
pipeline**: orchestrate → plan → spec → implement → reviewloop. The expensive front
(orchestrate/plan/spec) is **already done for our agents** — each `agent.md` is the
discovery + master plan + step-by-step spec, and the cross-agent contracts (`_shared/`
substrate, `decision_log` shape, `autosend-policy`, ESC catalogue, RLS invariants) are
already written. So we enter at **implement + reviewloop** and fan out.

## §2 — Two-layer autonomy (the mechanism)

- **Layer 1 — `/goal` stop-hook (self-continuing session).** A session under a `/goal`
  cannot stop until its condition holds; on context decay it **re-fires** and resumes.
  This is how one build runs to completion with no human input.
- **Layer 2 — subagents (`Agent` tool, `isolation:"worktree"`, `run_in_background:true`).**
  A subagent is a separate context window with its own git worktree/branch. It works its
  task autonomously and reports a final result back to the orchestrator (not the founder);
  background completion **re-invokes the orchestrator** automatically.

**The build = Layer 1 wrapping Layer 2:** an ORCHESTRATOR session running under a master
`/goal` spawns parallel background worktree subagents (one per agent), collects results,
spawns review subagents, iterates implement↔review, and re-fires itself on decay until
every agent sits on a green reviewed branch. The founder is out of the loop for the
*build*; re-enters only at the **merge gate**.

## §3 — Topology (the build sequence)

```
0. FREEZE shared substrate (serial, orchestrator on main) — _shared/ helpers,
   migration chain, autosend-policy entries, ESC catalogue, RLS invariants. This is
   the upstream contract all parallel specs depend on. Cash Conductor is the PROVEN
   bundle template (Diagnostic is the second reference). MUST precede any fan-out.
1. PROVE on ONE agent (Janitor) — full implement→reviewloop→merge cycle. De-risk the
   orchestration mechanics on real spend before 3×.
2. FAN OUT (parallel background worktrees) — Janitor ║ Scribe ║ Sourcing Scout.
   Structurally identical work on DISJOINT files (cycle.sh + validate.sh + context.sh +
   cleanup.sh + tools.yaml), so no collisions.
3. REVIEWLOOP (parallel reviewers per branch) — spec compliance + adjacent-contract
   compliance + tests + RLS + boundaries → ratings → orchestrator iterates failures.
4. MERGE GATE (founder + Codex) — nothing lands on main without review-subagent PASS +
   Codex ratification PASS + founder sign-off.
5. CONCIERGE last — bigger; partially downstream (consumes Cash Conductor's orange-row
   initiation), so start after the autosend-bridge contract freezes.
```

## §4 — Gate discipline (quality, non-negotiable — improvement not degradation)

Three review tiers, none skippable:
1. **Automated hook gate** (`settings.json`) — runs shellcheck + typecheck + vitest +
   the recon-test pattern before any commit. Non-bypassable.
2. **Review-subagent** — uses the existing `.codex/ratification/review-agent-bundle.md`
   rubric; checks self-spec + adjacent contracts + integration + tests.
3. **Codex ratification** (`scripts/run-codex-ratification.sh`) + **founder merge sign-off.**

Per-agent DONE = every step LIVE + all three tiers green on its branch, OR committed-to-green
with a documented blocker (never faked, never auto-merged unreviewed).

## §5 — Visibility (how the founder views the work)

There is **no separate GUI**. Visibility = three surfaces:
- **This chat** — the orchestrator posts/refreshes a **build-board** (table: agent | phase |
  status | branch | last commit | review) at every milestone; founder can type "status" anytime.
- **`docs/features/agent-build/STATUS.md`** — the build-board mirrored to a file (one file to open).
- **Git ground truth** — `git worktree list`, `git log`/`git diff` per branch; plus per-agent
  summary files (`docs/features/agent-build/03-implementation/<agent>-summary.md`) and review
  files (`04-reviews/review-<agent>.md`).

## §6 — Resume Protocol (run this when founder says "proceed with the agent build")

1. Complete the normal CLAUDE.md session-start ritual.
2. Read THIS doc + the Live Status table (§7).
3. Read memory [[project-parallelized-agent-build-mandate]].
4. Confirm Cash Conductor template state (`git log`, current-priorities header). If CC is not
   yet fully live, the template isn't proven — finish/resolve CC first.
5. Verify which topology step (§3) is next-incomplete from §7.
6. Confirm the substrate-freeze (§3 step 0) status before any fan-out.
7. Propose the concrete next action; wait for founder confirm before spawning subagents
   (per CLAUDE.md "wait for the founder to confirm before writing code").

## §7 — Live status (UPDATE THIS EACH SESSION)

| Agent | Build state | Topology role | Notes |
|---|---|---|---|
| Diagnostic | ✅ LIVE | reference template #1 | 0 TODOs; real 12-section reports |
| Cash Conductor | ✅ COMPLETE — all 14 steps LIVE | reference template #2 (PROVEN) | finished 2026-06-09 PM; the full agent-bundle live-wiring pattern (cycle 14 steps + validate.sh Gate A + cleanup.sh + reusable SQL + fixture suites) is now proven end-to-end |
| Janitor | ⚪ SKELETON (~13 TODOs) | PROVE-ONE pilot (§3 step 1) | first fan-out target once substrate frozen |
| Scribe | ⚪ SKELETON (~13 TODOs) | parallel fan-out (§3 step 2) | |
| Sourcing Scout | ⚪ SKELETON (~15 TODOs) | parallel fan-out (§3 step 2) | LinkedIn NO-OP (Proxycurl shutdown) |
| Concierge | ⚪ SKELETON (~16 TODOs) | last (§3 step 5) | downstream of autosend-bridge contract |

**Substrate freeze (§3 step 0):** ⏸ NOT done — Phase 0 of the first build session.
**Pipeline scaffolding:** ⏸ gate hook + STATUS.md + (optional) `/ifos-implement-agent` `/ifos-reviewloop` skills not yet built.

## §8 — What to verify in Claude Code docs before first fan-out

Confirm (via claude-code-guide) before committing to the topology:
- Max concurrent subagents / background-task limits.
- Exact worktree-isolation mechanics + cleanup behaviour.
- How background-completion notifications interact with the orchestrator's `/goal` re-fire.
Size the fan-out to whatever the docs allow.
