# ADR-004 — Renderer implementation deviations from ADR-003

**Date:** 2026-05-20 (Week 0, Day 8 — Phase-2/3 follow-up)
**Author:** Claude Code, with founder review pending
**Surfaced by:** Phase-2 + Phase-3 of `~/.claude/plans/bubbly-snuggling-lantern.md` (commits `3c16d35` + `e6e9df1`)
**Submodule SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383` (unchanged from ADR-003)
**Predecessor:** [ADR-003 — Agent bundle v2 renderer](./ADR-003-agent-bundle-renderer.md) (Accepted)
**Status:** Proposed

---

## Context

ADR-003 ratified the renderer design on 2026-05-16 (Day 1 evening). Phase 2 of the Week-1 product-code slice (commit `3c16d35`) implemented the renderer per ADR-003 §3.1 — TypeScript Node, `tsup` + `vitest` + `commander`, 12-row file map, atomic-write protocol. Phase 3 (commit `e6e9df1`) implemented `agents/_shared/hook-helpers.sh` and triggered an end-to-end integration test against the rendered output.

During implementation, three points of the ratified design did not survive contact with the live system. Each was resolved by deviating from the specification text; each is documented in commit messages + the renderer's `README.md`. This ADR ratifies the three deviations as deliberate decisions before they surface as REJECT items in Codex Day-7 ratification.

The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.

---

## Decision

### Decision 1 — Standalone `ifos-render-agent` Node binary, NOT `cortextos-ifos render-agent` subcommand

**ADR-003 §3.3.1 specified the CLI signature:** `cortextos-ifos render-agent <agent-name> --tenant <slug>`.

**Implementation ships:** `ifos-render-agent <agent-name> --tenant <slug>` as a standalone Node binary declared in `packages/agent-renderer/package.json` `bin` field. Same arguments + flags as ADR-003 §3.3.1; different command name.

**Why the deviation:** `cortextos-ifos` is the upstream CLI shipped from the cortextOS submodule at `/opt/homebrew/bin/cortextos-ifos`. Adding a `render-agent` subcommand to that binary requires modifying source in `packages/harness/cortextos/`, which violates master brief §3.1 boundary 1 (cortextOS submodule read-only). The boundary is non-negotiable per master brief §3.1 + the build-pack discipline that the submodule is a "reference pin, not the runtime."

Three alternatives considered:

- **Modify upstream cortextOS.** Rejected — violates §3.1 boundary 1. Also forks IFOS off the upstream maintenance line.
- **`ifosctl` shim that multiplexes** (`.envrc` already declares `alias ifosctl="cortextos-ifos"`). Rejected for Phase 2 — would require building a routing shim that intercepts `render-agent` and forwards everything else. Real engineering cost; not a 10-minute alias swap. Founder can layer this on later if naming uniformity matters.
- **Standalone binary** (chosen) — zero changes to upstream; CLI surface lives entirely under `packages/agent-renderer/`. Invocation pattern matches every other Node CLI in the IFOS ecosystem.

**Consequences:**

- ADR-003 §3.3.1 needs an erratum or this ADR's ratification, depending on how Codex treats the divergence.
- Master brief §8.3 Edit B (the `cortextos-ifos render-agent {name} --tenant <slug>` invocation line in the agent-development working pattern) needs an update — see §"Master brief edits authorised" below.
- `ifosctl render-agent` is **not** available; future shim work is a separate ADR (call it ADR-005 if/when it lands).

### Decision 2 — Symlink target is `../../../_shared`, not `../../_shared`

**ADR-003 §3.3.3 Option γ specified verbatim:** *"per-agent `.claude/hooks/_shared` symlink resolves to `../../_shared` (relative)."*

**Implementation ships:** `../../../_shared` (3 `..` segments, not 2).

**Why the deviation:** counting error in ADR-003. Starting from the symlink file at `<agent_dir>/.claude/hooks/_shared`, the canonical `_shared/` directory at `<org>/agents/_shared/` is **3 levels up**, not 2:

```
<agent_dir>/.claude/hooks/_shared       ← symlink lives here
<agent_dir>/.claude/hooks/              ← `..`
<agent_dir>/.claude/                    ← `../..`
<agent_dir>/                            ← `../../..`
<org>/agents/                           ← contains <agent_dir>/ AND _shared/
<org>/agents/_shared/                   ← target
```

So the relative path from the symlink's containing directory is `../../../_shared`, NOT `../../_shared`. With the ADR-003 spec verbatim, the symlink resolves to `<agent_dir>/_shared/` (INSIDE the agent dir, where no `_shared` exists) and breaks at first source. This was caught during the Phase-3 end-to-end integration test when `source .claude/hooks/_shared/hook-helpers.sh` failed with `No such file or directory`.

**No alternatives** — this is an off-by-one fix, not a design choice. The deviation is corrected in `packages/agent-renderer/src/renderer.ts` with an inline comment flagging the ADR-003 spec error.

**Consequences:**

- ADR-003 §3.3.3 should be updated to say `../../../_shared` (4 segments including `_shared`).
- ADR-003 §2.3 worked-Concierge-example output diagram says `_shared/` lives at `orgs/acme/agents/_shared/` — that's correct, the bug is only in the symlink-target text. Diagram is right; symlink string is wrong.

### Decision 3 — `_shared/` listed as phantom agent in `cortextos-ifos list-agents` is accepted as upstream concern

**Observation:** `cortextos-ifos list-agents` (which calls into `packages/harness/cortextos/src/bus/agents.ts` `listAgents()`) scans `${frameworkRoot}/orgs/<org>/agents/*` and treats every immediate directory child as an agent. `_shared/` sits in that location per ADR-003 §3.3.3 Option γ. Result: `_shared` appears in the list-agents output as if it were an agent named `_shared` in org `<tenant>`, with no display name + no config + status `stopped`.

**Decision:** **Accept as upstream limitation.** Do NOT modify the renderer to relocate `_shared/` outside the scanned directory. The placement matches ADR-003's design intent (one canonical `_shared/` per org reachable by all agents via relative symlink). Renderer correctness is unaffected — the daemon's own `discoverAndStart()` doesn't try to launch `_shared` because it has no `config.json`; PM2 + agent-manager skip it cleanly. Only the cosmetic `list-agents` output is affected.

Three alternatives considered:

- **Relocate `_shared/` outside `orgs/<org>/agents/`** — would break the relative-symlink semantics from `.claude/hooks/_shared → ../../../_shared`. Either we accept a longer relative path (`../../../../_shared` from outside `agents/`) or absolute path (loses portability). Both worse than the cosmetic phantom-listing issue.
- **Prefix `_shared/` with a dotfile** (`.shared/`) to make the listAgents scan skip it. Rejected — Bash glob conventions + Postgres conventions both treat dot-prefix as "hidden", and we'd lose the discoverable convention that `_shared/` follows IFOS naming rules. Also drifts further from the master brief vocabulary.
- **File an upstream issue / PR against cortextOS** to filter out `_shared/` (and other underscore-prefixed names) in `listAgents()`. **Recommended path** — open an issue on the cortextOS repo per master brief §3 boundary 1 ("the submodule is a reference pin, not the runtime; upstream changes go upstream"). Phase 2 ships the deviation as documented; founder + upstream maintainer fix it on their schedule.

**Consequences:**

- Cosmetic `list-agents` output has one extra row per tenant. Founder-side tooling that consumes `list-agents` JSON output must filter for `name !== '_shared'`.
- File an upstream issue on cortextOS at next reasonable opportunity. Track in `.agents/learnings/00-cortextos-quirks.md` so future builds don't re-discover this.

---

## Master brief edits authorised by this ADR

**Edit D — Master brief §8.3 working pattern line 121 (post-ADR-003 Edit B).**

Current (post-ADR-003 Edit B at master brief §8.3 lines 614-630):

```bash
# After merge, render the bundle for each tenant that uses this agent:
cortextos-ifos render-agent {name} --tenant <slug>
# For all active tenants (v1.1+): cortextos-ifos render-agent {name} --all-tenants
# Activate: pm2 restart ifos-daemon   (for new agents)
#       OR: cortextos-ifos bus self-restart {name}   (for re-renders of running agents)
```

Proposed (Decision 1 ratifies the deviation):

```bash
# After merge, render the bundle for each tenant that uses this agent:
ifos-render-agent {name} --tenant <slug>
# (Or via the Node CLI in repo: `node packages/agent-renderer/dist/cli.js render {name} --tenant <slug>`.)
# For all active tenants (v1.1+): the --all-tenants flag is deferred to a future ADR-005
# Activate: pm2 restart ifos-daemon   (for new agents)
#       OR: cortextos-ifos bus self-restart {name}   (for re-renders of running agents)
```

Lands in this ADR's commit if approved; otherwise queued for the next atomic-correction commit alongside ADR-003 spec-text fixes.

**Edit E — ADR-003 §3.3.3 symlink target string.**

Current (ADR-003 §3.3.3 — Option γ paragraph):

> "per-agent `.claude/hooks/_shared` symlink resolves to `../../_shared` (relative)."

Proposed (Decision 2 ratifies the off-by-one correction):

> "per-agent `.claude/hooks/_shared` symlink resolves to `../../../_shared` (relative — three levels up from `.claude/hooks/` to `orgs/<org>/agents/`, then `_shared`)."

Lands in ADR-003 itself as an inline erratum (small text fix), OR as a §5 entry in this ADR titled "Errata to ADR-003." Founder decision at ratification time.

**Edit F — ADR-003 §3.3.1 CLI signature.**

Current (ADR-003 Decision 1 paragraph, internal text):

> "invoked via `cortextos-ifos render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1)."

Proposed (Decision 1 ratifies the deviation):

> "invoked via `ifos-render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1 + ADR-004 Decision 1; standalone Node binary per `packages/agent-renderer/package.json` `bin`. The `cortextos-ifos render-agent` form named in earlier drafts requires modifying the read-only submodule and was rejected per master brief §3.1 boundary 1)."

Lands in ADR-003 itself OR as §5 in this ADR per Edit E's pattern.

---

## Consequences

**For Risk #5 (renderer-not-built).** Severity unchanged at High per ADR-003 line 145 staged ladder ("Drops to Medium once renderer code is committed AND the Diagnostic agent renders cleanly (Week 4)"). The Phase-2 commit `3c16d35` satisfies the first condition; the second condition (Diagnostic render) is gated on Q1 design-partner LOI. ADR-004 closes a stylistic gap (3 deviations) but does not change risk severity.

**For Codex Day-7 ratification.** ADR-004 joins the queue. The 3 deviations were pre-flagged in Phase-2 and Phase-3 commit messages + `packages/agent-renderer/README.md`; this ADR consolidates them into a single ratifiable artefact. Without ADR-004, Codex would likely REJECT each deviation individually as "implementation diverges from ADR-003"; with ADR-004, the deviations are deliberately-ratified design decisions Codex either RATIFIES or REJECTS as a coherent set.

**For master brief drift.** Edit D + Edit E + Edit F enter the deferred atomic-correction queue (if not landed in this commit). Risk #7 (master-brief-drift-accumulation) is currently closed; reopening it for 3 small text edits is honest but tracked here. Founder decides at ratification time whether to land in this commit or queue for the next atomic correction.

**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."

**For `.agents/learnings/00-cortextos-quirks.md`.** Add a Day-8 entry under "Quirks of cortextOS we've worked around" naming Decision 3's phantom-`_shared`-listing observation. Helps future agent builds avoid re-discovering it.

---

## Status

**Proposed.** Founder review pending. Codex Day-7 queue position 34 (appended after the 33-item Day-8 close). If founder accepts:

- Land ADR-004 commit with the three §"Master brief edits authorised" applied verbatim
- Land erratum on ADR-003 §3.3.3 (Edit E) + §3.3.1 internal text (Edit F) in the same commit OR in next atomic-correction commit
- Reopen Risk #7 with edit count = 3 (Edits D + E + F) for tracking
- File upstream cortextOS issue against `bus/agents.ts:listAgents()` for Decision 3's phantom-listing fix

If founder rejects any deviation:

- Decision 1 reject = build `ifosctl` shim that multiplexes; ~2-3 days of work; new ADR-005
- Decision 2 reject = impossible (off-by-one is a fact, not a choice); rejection means rebuilding the symlink topology, which means re-architecting `_shared/` placement, which means a new ADR
- Decision 3 reject = relocate `_shared/` outside `orgs/<org>/agents/`; loses relative-symlink portability; new ADR

Founder bias: accept all three. The deviations are small, well-justified, and the cost of un-deviating is disproportionate to the benefit.

*End of ADR-004.*
