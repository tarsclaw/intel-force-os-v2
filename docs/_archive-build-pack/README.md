# Intel Force on cortextOS — Build Pack

**A self-contained context pack for building v2 of Intel Force OS on top of cortextOS (`github.com/grandamenium/cortextos`), with an Obsidian-style wiki + graphify second brain replacing the stock knowledge-base, and selective UX/agent inheritance from Intel Force OS v1. Designed to be read top-to-bottom by a fresh Claude Code session, ratified through Codex, then executed in one focused build campaign.**

---

## The frame

Three concrete things on this machine today:

| Repo | Path | Role |
|---|---|---|
| **cortextOS upstream** | `/Users/madsadmin/code/cortex-os-upstream/` | The agentic harness. v0.1.1. Persistent 24/7 Claude Code agents, PM2-managed, file-bus coordination, Telegram + Next.js dashboard. Read-only reference. |
| **Intel Force OS v1** | `/Users/madsadmin/code/intel-force-os/` | Working v1. Dashboard, 11 agents across 4 directors, governance model, brand, ICP. Stays alive serving founding customers. |
| **v2 codebase (this build)** | `/Users/madsadmin/code/CortexOS/` | Empty scaffold from 10 May — `CLAUDE.md` stub + `.claude/settings.json` + git initialised. Phase 0 starts here. |

The build is:

> **cortextOS (harness, vendored) + Intel Force product layer (lifted from v1) + Wiki+Graphify Brain (replaces stock knowledge-base) = one fresh codebase that ships as v2.**

---

## What cortextOS is, in two paragraphs

cortextOS is a Node 20+ daemon (`dist/daemon.js`, CLI `dist/cli.js`) that runs Claude Code (or OpenAI's `codex-app-server`) in persistent PTY sessions under PM2, auto-restarting on crash or after a 71-hour context rotation. Agents coordinate through a shared **file bus** (47 shell scripts in `bus/`) that wrap a TypeScript bus in `src/bus/`. Templates in `templates/` define agent roles — Orchestrator, Analyst, Specialist, Hermes, M2C1-worker. Telegram is the primary control surface; a Next.js 14 dashboard in `dashboard/` is secondary.

The stock memory subsystem is `knowledge-base/scripts/mmrag.py` — a Python multimodal-RAG system backed by Gemini embeddings, scoped by org/agent/instance with shared/private/all collections, accessed through `bus/kb-query.sh`, `bus/kb-ingest.sh`, `bus/kb-setup.sh`, `bus/kb-collections.sh`. **This is the single swap point for the wiki+graphify brain**: keep the shell-script interface stable, replace the Python backend with a graph store + wiki generator. Every agent in the system continues to call `bus/kb-query.sh "<question>"` and gets results — but those results now come from a graph traversal over a stunning Obsidian-shaped wiki.

---

## Recommendation in one paragraph

Don't modify cortextOS upstream. Don't modify v1 in place. Build v2 fresh at `/Users/madsadmin/code/CortexOS/`. Vendor cortextOS into `packages/harness/cortextos/` with a `.upstream-version` SHA pin. Build `packages/brain/` that ships drop-in replacements for `bus/kb-*.sh` (same interface, graph+wiki backend). Lift v1's dashboard chrome, agent catalogue, governance model, and brand context as **concepts** into clean packages — never `cp -r`. Keep v1 unmodified until v2 reaches feature parity; then mechanical cutover. Full case in `01-RECOMMENDATION.md`.

---

## How to use this pack

### Founder path (alignment)
1. `01-RECOMMENDATION.md` — strategic call
2. `02-PRODUCT-VISION.md` — what v2 is
3. `08-OPEN-DECISIONS.md` — what you must decide

### Fresh Claude Code session path (build)
Read in order:
1. `README.md` (this file)
2. `01-RECOMMENDATION.md`
3. `02-PRODUCT-VISION.md`
4. `09-CLAUDE-CODE-UTILITY.md`
5. `03-ARCHITECTURE.md`
6. `04-DATA-MODEL.md`
7. `05-MIGRATION-MAP.md`
8. `06-BUILD-PLAN.md`
9. `07-V1-INHERITED-CONTEXT.md`
10. `08-OPEN-DECISIONS.md`

Treat the pack as the **only** required context. v1 and cortextOS source are available for grep but the pack points at exact files when needed.

### Codex path (ratify)
Pack + cortextOS source + v1 source. Pressure-test §03 / §04 / §05. Return a delta document. Claude Code applies the delta before Phase 0.

---

## File map

| File | Purpose |
|---|---|
| `README.md` | This file. |
| `01-RECOMMENDATION.md` | Why a fresh third codebase. Trade-off analysis. |
| `02-PRODUCT-VISION.md` | Cortex / Workforce / Brain / Queue. What v2 is. What the wiki-graphify brain adds. |
| `03-ARCHITECTURE.md` | Stack. Monorepo layout. cortextOS integration. Runtimes. Data flow. Concrete file paths. |
| `04-DATA-MODEL.md` | Hybrid persistence: Prisma for governance, graph store for brain, file-bus state dirs for runtime. |
| `05-MIGRATION-MAP.md` | Concept-by-concept: keep / rebuild / drop. With paths. Lookup during build. |
| `06-BUILD-PLAN.md` | Phase 0 (scaffold + vendor) → Phase 1 (brain swap) → Phase 2 (dashboard + agents) → Phase 3 (parity + migration). Acceptance criteria. |
| `07-V1-INHERITED-CONTEXT.md` | Inherited product knowledge: ICP, pricing, brand, invariants, agents, integrations, compliance. |
| `08-OPEN-DECISIONS.md` | Open questions only the founder resolves. |
| `09-CLAUDE-CODE-UTILITY.md` | How to maximise Claude Code for this build: skills, sub-agents, MCP, scheduled agents, project memory, slash commands. |

---

## Canonical locations

| What | Path |
|---|---|
| v1 product | `/Users/madsadmin/code/intel-force-os/` |
| v1 marketing site | `/Users/madsadmin/Projects/proposal-video-generator/Intelforce Website/` |
| cortextOS upstream (read-only) | `/Users/madsadmin/code/cortex-os-upstream/` |
| v2 product (this build) | `/Users/madsadmin/code/CortexOS/` |
| This pack | `/Users/madsadmin/code/CortexOS/docs/build-pack/` |

---

## Meta-rule (inherited from v1)

v1 was over-specified and under-shipped. v2 must not repeat that. Pack exists to bridge spec → execution, not extend spec. Once Phase 0 acceptance is met (`06-BUILD-PLAN.md`), the pack is reference, not active reading.

Close the pack. Open the editor.
