# Intel Force OS v2 (cortextOS-based)

**Loaded by Claude Code at the start of every session. Read first.**

---

## What this codebase is

The v2 of Intel Force OS, built on top of **cortextOS** (`github.com/grandamenium/cortextos`) — an agentic harness for persistent 24/7 Claude Code agents. The product layer (dashboard, agents, governance, brand) is lifted selectively from Intel Force OS v1. The memory subsystem replaces cortextOS's stock `mmrag.py` knowledge base with an Obsidian-style wiki + graphify second brain.

**Stage:** scaffold + build pack only. Phase 0 has not started.

---

## Canonical paths (this machine)

| What | Path |
|---|---|
| **v2 codebase (this one)** | `/Users/madsadmin/code/CortexOS/` |
| **The build pack** | `/Users/madsadmin/code/CortexOS/docs/build-pack/` |
| **v1 codebase** (alive, do not modify) | `/Users/madsadmin/code/intel-force-os/` |
| **cortextOS upstream** (read-only reference) | `/Users/madsadmin/code/cortex-os-upstream/` |
| **v1 marketing site** (alive, do not modify) | `/Users/madsadmin/Projects/proposal-video-generator/Intelforce Website/` |

---

## Where to start

Read in order:

1. `docs/build-pack/README.md` — orientation
2. `docs/build-pack/01-RECOMMENDATION.md` — the strategic call
3. `docs/build-pack/02-PRODUCT-VISION.md` — what v2 is
4. `docs/build-pack/09-CLAUDE-CODE-UTILITY.md` — how to leverage Claude Code for this build
5. `docs/build-pack/03-ARCHITECTURE.md` — stack + monorepo + cortextOS integration
6. `docs/build-pack/04-DATA-MODEL.md` — Prisma + graph + vault
7. `docs/build-pack/05-MIGRATION-MAP.md` — what lifts from v1, where
8. `docs/build-pack/06-BUILD-PLAN.md` — phased slices
9. `docs/build-pack/07-V1-INHERITED-CONTEXT.md` — inherited product knowledge
10. `docs/build-pack/08-OPEN-DECISIONS.md` — what the founder must decide before Phase 0

The pack is the only context required. v1 and cortextOS source are available for grep when the pack points at them.

---

## Conventions (will be enforced as the codebase grows)

- TypeScript strict everywhere
- pnpm workspaces
- One phase at a time. One slice at a time.
- Commit per slice with conventional-commit prefix.
- Codex review at every phase boundary (see build-pack §09 §10 and §06).

---

## Never (red lines)

- Don't modify `packages/harness/cortextos/*` except the four `bus/kb-*.sh` overrides documented in `docs/build-pack/05-MIGRATION-MAP.md` §2.2
- Don't modify v1 at `/Users/madsadmin/code/intel-force-os/`
- Don't modify cortextOS upstream at `/Users/madsadmin/code/cortex-os-upstream/`
- Don't add features without a corresponding slice in `docs/build-pack/06-BUILD-PLAN.md`
- Don't skip Codex ratification at phase boundaries
- Don't relitigate inherited product context (`docs/build-pack/07-V1-INHERITED-CONTEXT.md` is canon)

---

## Current state

**Phase:** pre-Phase-0. Founder must resolve `docs/build-pack/08-OPEN-DECISIONS.md` §§2, 3, 4, 6, 7, 8 before Phase 0 can start.

**Next slice:** Phase 0 §P0.S1 — monorepo scaffold (`docs/build-pack/06-BUILD-PLAN.md`).

---

## On being stuck

1. Check `docs/build-pack/08-OPEN-DECISIONS.md` — is this an open decision?
2. Check `docs/build-pack/05-MIGRATION-MAP.md` — is there a v1 file that solves this?
3. Check `~/.claude/skills/wiki-brain/SKILL.md` and `~/.claude/skills/graphify/SKILL.md` if the question is brain-related
4. Ask the founder. Don't guess.
