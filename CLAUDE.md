# ⛔ THIS REPOSITORY IS FROZEN — 2026-08-21

**Superseded by `~/code/ifos`.** Do not build here. Do not resume W3–W8. Do not fix the renderer.

CortexOS is now a **harvest source and a read-only reference**, not a development target. It stays running and
green until the migration completes (target: after thickening pass 2 / WP-12), then retires.

| | |
|---|---|
| **Successor repo** | `~/code/ifos` |
| **What transfers, where, and how** | `harvest/LANDING-ORDER.md` — 67 rows, 11 stages, a verification command per row |
| **Why the architecture changed** | `docs/handoff/SESSION-HANDOFF-cortexos-to-ifos.md`, `TRANSFER-MAP.md` |
| **What had to change to conform** | `docs/handoff/CONFORMANCE-AUDIT.md` + `harvest/patches/` |
| **Decisions and their reversal costs** | `harvest/RULINGS.md` (R-CX-1 … R-CX-9) |
| **Freeze tag** | `frozen-2026-08-21` |

**What the freeze permits:** data-integrity and security fixes, and only to something that will be harvested.
Everything else waits for the new repo.

**Why W3–W8 stopped** (three reasons, each sufficient — `ESTATE-DECISIONS-repo-freeze-vps.md` D3):
1. It builds what is already superseded — the six agent bundles and the renderer are replaced by the three-tool seam.
2. It cannot reach live verification — credentials were declared unobtainable 2026-06-11.
3. `[LOCK-MR-5]` — implementing in a stub-phase package before its phase opens is the spec-gravity trap.

**Do not fix the renderer.** It is confirmed to be six missing `config.schema.json` files and nothing else
(`packages/agent-renderer/src/fileMap.ts:20-22`, `preflight.ts:checkBundle`). It is cheap, and the payoff is zero:
it would render agents into a runtime whose agent model is being replaced.

**The nine connectors, the migrations and the dev-DB harness stay here until their phase opens.** Nothing has been
deleted; every move to `~/code/ifos` is a copy.

---

# Intel Force OS v2 — Claude Code Instructions

**Loaded by Claude Code at the start of every session. Read this first, then the master brief.**

## Reading order — do this at the start of every session

1. **This file** (you are here)
2. **`docs/build-brief/00-MASTER-BRIEF.md`** — the operative one-stop brief, in full
3. **`docs/specs/PRODUCT-SPEC.md`** — what we are building (§0–§4 and §10 minimum)
4. **`docs/specs/ULTRAPLAN.md`** — how, in what order (§1, §3, §4, §9, §11 minimum)
5. **`.agents/current-priorities.md`** — what we're doing today

The build pack at `docs/_archive-build-pack/` is historical reference only. The master brief wins on every conflict.

## What this is

Recruitment-operations product for UK agencies, built on cortextOS. Multi-tenant. 18 agents at full strength, 6 in v1.0. Obsidian-style wiki + graph second brain replaces the stock cortextOS knowledge base behind the four `bus/kb-*.sh` shell entrypoints (master brief §5).

## Instance scoping — CRITICAL

This repo runs against a fully isolated IFOS cortextOS instance. It is NOT the founder's personal cortextOS install. Two separate binaries, two separate state dirs, two separate daemons.

| Resource | IFOS value | Personal install (DO NOT TOUCH) |
|---|---|---|
| Runtime source | `~/code/cortex-os-ifos/` | `~/cortextos/` |
| Binary on PATH | `cortextos-ifos` | `cortextos` |
| `CTX_INSTANCE_ID` | `ifos-v2` | `default` |
| `CTX_ROOT` | `~/.cortextos/ifos-v2/` | `~/.cortextos/default/` |
| Dashboard port | `3100` | `3000` |
| PM2 process prefix | `ifos-*` (when created) | `cortextos-*` |

The env vars come from `.envrc` in the repo root. Verify with `echo $CTX_INSTANCE_ID` — must print `ifos-v2`. If it doesn't, source `.envrc` again before running any cortextos-related command.

**Never run `cortextos` (without `-ifos`) inside this repo. That command targets the personal install. Use `cortextos-ifos` or the `ifosctl` alias.**

There is a safety wrapper `ifosctl-install` that always passes `--instance ifos-v2` to the install command, because cortextOS v0.1.1 has a bug where `install` ignores `CTX_INSTANCE_ID` (see `.agents/learnings/00-cortextos-quirks.md` item 1).

## The five rules — NON-NEGOTIABLE

1. Output before architecture
2. Schema before code
3. Reuse before build
4. Quality gates before features
5. Honest signal before optimistic projection

Full statement of each rule is in `docs/build-brief/00-MASTER-BRIEF.md` §1.

## Coding-agent discipline — per edit

The five rules govern *what* we build and in what order. These four govern *how* you write code each turn. They operate beneath the five rules and never override them or the four boundaries.

1. **Think before coding** — State your assumptions. If a request is ambiguous, ask — don't guess (this is the same "Ask the founder. Do not guess." from the stuck protocol, applied to every edit).
2. **Simplicity first** — Minimum code that solves the stated problem. Nothing speculative — no unrequested abstractions, no "flexibility" for futures not in master brief §6 or §8.
3. **Surgical changes** — Touch only what the task requires. Don't refactor, reformat, or "improve" unrelated code, and never touch anything across the four boundaries below.
4. **Goal-driven execution** — Turn vague asks into verifiable success criteria before starting. Verify by running (tests, smoke, the audit harness) — not by asserting it works.

Derived from Andrej Karpathy's public observations on LLM coding failure modes; phrasing adapted from F. Chang's `andrej-karpathy-skills` CLAUDE.md. Not authored by Karpathy.

## The four boundaries

1. **Submodule boundary** — never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` files we shadow via `packages/brain/bus-overrides/`. The submodule is a reference pin, not the runtime.
2. **Adapter boundary** — never reference Composio or AgentMail in `agent.md`, `tools.yaml`, vault files, or fixtures.
3. **Vault/Postgres split** — markdown in vault, structured state in Postgres, pgvector indexes over both.
4. **Brain-replacement boundary** — only the four `bus/kb-*.sh` shadow points, nothing else in cortextOS gets touched.

Full detail in master brief §3.

## Canonical paths

| What | Path |
|---|---|
| IFOS product repo (this) | `~/code/CortexOS/` |
| IFOS cortextOS runtime | `~/code/cortex-os-ifos/` |
| cortextOS reference pin (submodule) | `~/code/CortexOS/packages/harness/cortextos/` |
| v1 codebase (alive, no modify) | `~/code/intel-force-os/` |

## Current state

**Phase:** pre-Phase-0. The Week 0 checklist (master brief §6) must clear before any agent code.
**Today:** see `.agents/current-priorities.md`.

## Session-start ritual — DO THIS EVERY SESSION

1. Read this file
2. Verify `.envrc` is loaded: `echo $CTX_INSTANCE_ID` must print `ifos-v2`. If it doesn't, stop and tell the founder.
3. Read `docs/build-brief/00-MASTER-BRIEF.md` §1, §3, §6, §8, §10 in full
4. Confirm in your response:
   a. You can list the five rules
   b. You understand the four boundaries
   c. You understand the agent bundle v2 pattern (6 files + 3 fixtures)
   d. You understand the Codex ratification loop
   e. You know the IFOS binary is `cortextos-ifos`, NOT `cortextos`
5. Read `.agents/current-priorities.md` (header-only — it's lean now; ≤120 lines covers today's tactical state, active blockers, action board, clocks, W4 backlog). Reach for `docs/operations/decision-log.md` only when investigating origin of a current decision.
6. Propose today's concrete plan
7. **Wait for the founder to confirm before writing any code.**

### Session-start checklist (explicit, after the reading above)

Run these in your first response, before any code edits:

```
git log --oneline -10                       # last 10 commits — orient on recent work
git status --short | grep -v '^??'          # uncommitted tracked changes (should be CLEAN at start)
echo "CTX_INSTANCE_ID=$CTX_INSTANCE_ID"     # must print: ifos-v2
```

State in your first response: "Reading order complete. Last commit: <SHA>. Tree: <clean | uncommitted: …>. Instance: ifos-v2 ✓. Today's priorities header: <one-line summary of the 'Today's task' line>. Ready for direction."

If anything's red (env unset, tree dirty unexpectedly, last commit doesn't match expectations): surface immediately, don't proceed.

## Session-end ritual — DO THIS BEFORE EVERY COMMIT

1. Update `.agents/current-priorities.md` — what shipped, what's stuck, what changed (lean header; historical sections go to `docs/operations/decision-log.md`)
2. Update `docs/RISK-REGISTER.md` if anything new emerged
3. List anything queued for Codex ratification
4. Commit with a conventional-commit message

### Session-end checklist (explicit, before closing the session)

```
git status --short | grep -v '^??'          # must be CLEAN — no uncommitted tracked changes
git log --oneline -<N>                      # confirm today's commits all landed
```

State in your last response: "Tree clean. Today's commits: <SHA list>. Next session resumes from <latest SHA>. Founder action queued for AM: <X | none>. Goal status: <% complete | done | blocked>."

If the tree isn't clean: either commit the WIP under a clearly-marked `wip(` prefix OR explain why deferring; never end a session leaving uncommitted tracked changes silently.

## On being stuck

1. Re-read the relevant master brief section
2. Check `.agents/learnings/` for prior solutions — start with `00-cortextos-quirks.md`
3. Check `docs/decisions/` for prior decisions on the same question
4. Ask the founder. Do not guess.

## Red lines — never

- Don't modify `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points
- Don't run `cortextos` (without `-ifos`) inside this repo — that's the personal install
- Don't modify `~/cortextos/` or `~/.cortextos/default/` — those are the personal install
- Don't run `cortextos-ifos install` without `--instance ifos-v2` (or via the `ifosctl-install` wrapper)
- Don't modify v1 at `~/code/intel-force-os/`
- Don't add features without a corresponding slice in master brief §6 or §8
- Don't skip Codex ratification for any artefact listed in master brief §10.5
- Don't relitigate the master brief without writing the disagreement to `docs/decisions/`
- Don't write agent code until Week 0 is cleared (master brief §6 Day 7 test passes five-of-five)
