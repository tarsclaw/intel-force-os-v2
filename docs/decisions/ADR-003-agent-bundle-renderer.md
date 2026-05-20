# ADR-003 — Agent Bundle v2 renderer

**Date:** 2026-05-16 (Week 0, Day 1 evening — Week-1-prerequisite pull-forward)
**Author:** Claude Code, founder decision logged 2026-05-16
**Surfaced by:** `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §"For Week 1 work" + `docs/architecture/agent-bundle-renderer-design.md` (full design)
**Submodule SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
**Status:** Accepted. Founder decision logged 2026-05-16.

---

## Context

ADR-002 §1.7-A surfaced the spec gap. Master brief §8 (lines 545-568) specifies the IFOS Agent Bundle v2 — six files plus three fixtures at `agents/recruitment/<name>/` — but is silent on how the bundle becomes a runnable cortextOS agent. The cortextOS daemon's `AgentManager.discoverAndStart()` (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`) reads from `${frameworkRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `CLAUDE.md`, `.env`). The two layouts are incompatible without translation.

The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.

The design document (`docs/architecture/agent-bundle-renderer-design.md`) specified the renderer across five sections: source vs target layout (§1), the 12-row file mapping + R2 commitment + Concierge worked example (§2), six concrete mechanism decisions including TypeScript Node at `packages/agent-renderer/` (§3.1), manual developer invocation (§3.2), Option γ for `_shared/` origination (§3.3.3), and overwrite-no-merge re-render policy (§3.4), seven failure modes with exit codes (§4), and integration with the broader build (§5). 22 spec gaps surfaced and bucketed. This ADR ratifies the design's recommendations.

## Decision

### Decision 1 — Renderer is a new command, not a wrapper around `cortextos-ifos add-agent`

Per design §5.1: the cortextOS `cortextos-ifos add-agent` command is **unchanged**. IFOS does not use it for IFOS-owned agents. The renderer is a **new** command at `packages/agent-renderer/`, invoked via `ifos-render-agent <agent-name> --tenant <slug>` (standalone Node binary per `package.json` `bin`; **errata via ADR-004 Decision 1** — earlier drafts named this `cortextos-ifos render-agent` which would have required modifying the read-only submodule per master brief §3.1 boundary 1).

**R2 commitment** per design §2.2: no `.claude/skills/` inheritance from cortextOS templates. Default is exclusion of all 24 cortextOS-template skills. Opt-in for specific skills only via the bundle's `tools.yaml` `cortextos_skills:` top-level block (syntax per design §2.2 spec gap §2.2-A resolution).

**Protection against accidental `cortextos-ifos add-agent` scaffolding** per design §5.1: marker file `.rendered-by-ifos-renderer` written as the **last** step of every successful render. Renderer preflight refuses with exit code 7 if the target directory exists without this marker; overridable via `--force-overwrite-non-rendered`. This fires before any writes; no partial damage possible.

### Decision 2 — Renderer lives at `packages/agent-renderer/`

Per design §3.1: TypeScript Node. Tooling matched against `packages/harness/cortextos/package.json:11-13` for consistency:

- Build: `tsup`
- Tests: `vitest`
- CLI: `commander`

Three alternatives rejected per design §3.1: `packages/brain/agent-cli/` (wrong cohesion — brain is wiki, renderer is not a wiki concern); `scripts/render-agent.sh` (JSON Schema validation + YAML parsing harder in shell); new top-level directory (loses master brief §4.1 line 195-204 `packages/` convention).

**Invocation mode** per design §3.2: manual developer invocation. Day-1 cadence (founder + Claude Code), per-tenant scope explicit, hand-off boundary clean. Three alternatives rejected per design §3.2: pre-push hook (wrong filesystem — tenant vault on Hetzner UK VPS, hook on dev laptop), CI on merge (same reachability problem), daemon auto-watcher (wrong coupling — daemon is read-only on submodule per master brief §3.1).

**`_shared/` origination** per design §3.3.3 Option γ (hybrid): IFOS repo at `agents/_shared/` is canonical source; renderer copies to `${frameworkRoot}/orgs/<org>/agents/_shared/` once per render invocation (SHA-skip when unchanged); per-agent `.claude/hooks/_shared` symlink resolves to `../../_shared` (relative).

### Decision 3 — Translation contract per design §2.1

12-row file-by-file mapping ratified verbatim:

- **Synthesis (3):** `agent.md` → `CLAUDE.md` (with cortextOS preamble wrapper); `config.schema.json` → `config.json` (materialised via per-tenant `_config.yaml` + common-*.json $refs); `(no source)` → `.env` (from `_secrets.env` + tools.yaml MCP server list).
- **Passthrough (1):** `tools.yaml` → `tools.yaml` (verbatim).
- **Verbatim copy (3):** `validate.sh` → `.claude/hooks/validate.sh`; `context.sh` → `.claude/hooks/context.sh`; `README.md` → `README.md`.
- **Stays in source (1):** `tests/fixtures/` — never copied to runtime; CI fixture runner reads from IFOS repo.
- **Drop (2):** cortextOS template files (IDENTITY.md / SOUL.md / GUARDRAILS.md / GOALS.md / HEARTBEAT.md / MEMORY.md / USER.md / SYSTEM.md / TOOLS.md / AGENTS.md / memory/ / experiments/) and the 24-skill `.claude/skills/` tree.
- **Empty placeholder (1):** `goals.json` materialised as `{focus:"",goals:[],bottleneck:"",updated_at:"",updated_by:""}` per `add-agent.ts:131-140` for daemon-side compatibility.

The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.

### Decision 4 — Re-render policy: overwrite, no merge

Per design §3.4: re-render replaces target directory verbatim. Hand-edits to rendered output are lost. Discipline: hand-edits go to source bundle, then re-render. Warning banner in stdout: `WARN: This will overwrite ${target}; any hand-edits will be lost.`

Two alternatives rejected per design §3.4: merge-with-conflict-markers (premature complexity — master brief §1 Rule 1 "output before architecture" favours simple); refuse-if-exists (friction without benefit — Decision 1's marker-file check handles the actual risk).

**No-op detection** per design §3.4: four-condition check (bundle SHA `git hash-object -t tree` + render log + `/vault/<tenant>/_config.yaml` mtime + `agents/_shared/` SHA). If all four match the last successful render, renderer exits 0 with `No-op:` stdout and a `render_outcome: no-op` JSONL line.

**Atomicity** per design §3.3.4: write to `<name>.tmp.<pid>/`, rename existing target to `<name>.prev.<timestamp>/`, atomic rename `<name>.tmp.<pid>/` → `<name>/`, clean up older `.prev`. The daemon's `discoverAgents()` filters by directory name pattern; the `.tmp.<pid>/` and `.prev.<timestamp>/` directories are invisible to discovery.

## Master brief edits authorised by this ADR

**Errata 2026-05-20 (ADR-004):** Edit B's CLI command text was revised post-ADR-004 from `cortextos-ifos render-agent` to `ifos-render-agent`. The proposed text block below reflects the corrected name. See ADR-004 §"Master brief edits authorised" Edit D for the full disposition.

Three edits per design §5.3. Edits A and B land in this ADR's commit (small wording adds; Edit A is needed live before Week-1 renderer implementation). Edit C joins the deferred atomic correction commit alongside ADR-001 + ADR-002 edits.

### Edit A — Master brief §4.1 directory list

**Current** (master brief §4.1 lines 195-204):

> ```bash
> mkdir -p docs/{specs,architecture,verticals/recruitment,verticals/_future,decisions,runbooks,build-brief,risk}
> mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext}
> mkdir -p packages/brain/{bus-overrides,wiki,graphify,brain-ui}
> mkdir -p packages/agents-runtime/_shared/{hooks,fixtures}
> mkdir -p agents/recruitment
> mkdir -p infrastructure/{docker,terraform,pm2,postgres}
> mkdir -p tests/{unit,integration,eval-sets}
> mkdir -p .agents/{decisions,learnings,priorities}
> mkdir -p .codex/{ratification,evals,scratch}
> ```

**Proposed:** add `agent-renderer` to the `packages/` enumeration. The line becomes:

> ```bash
> mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
> ```

Lands in this ADR's commit. Edit A is the minimum required to make `packages/agent-renderer/` a canonical IFOS package per master brief §4.1; Week-1 renderer implementation depends on the path existing.

### Edit B — Master brief §8.3 working pattern

**Current** (master brief §8.3 lines 614-630):

> ```bash
> git checkout -b agent/{name}                       # e.g. agent/janitor
> mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
>
> # In Claude Code, work the bundle through 6 files in this order:
> # 1. README.md (2-min overview)
> # 2. agent.md (OUTPUT CONTRACT FIRST, then workflow, then gates, then escalation)
> # 3. config.schema.json (what the wizard collects)
> # 4. tools.yaml (MCP servers + scopes + degraded modes)
> # 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
> # 6. context.sh (hydrates CONTEXT via context-assembly API)
>
> # Then the three fixtures with golden outputs.
> # Test against fixtures; iterate; commit; PR; merge.
> ```

**Proposed:** append a renderer step after merge:

> ```bash
> # Then the three fixtures with golden outputs.
> # Test against fixtures; iterate; commit; PR; merge.
>
> # After merge, render the bundle for each tenant that uses this agent:
> ifos-render-agent {name} --tenant <slug>
> # For all active tenants (v1.1+): the --all-tenants flag is deferred to a future ADR-005 (see ADR-004 Edit D)
> # Activate: pm2 restart ifos-daemon   (for new agents)
> #       OR: cortextos-ifos bus self-restart {name}   (for re-renders of running agents)
> ```

Lands in this ADR's commit.

### Edit C — Master brief §8 footnote referencing the renderer

**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.

**Proposed:** insert a one-paragraph footnote at the end of §8 (before §8.1):

> "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The cortextos-ifos add-agent command is NOT the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want."

Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.

## Consequences

**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.

**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.

**For Risk #5 (renderer-not-built).** Severity drops from **Blocking** to **High** with ADR-003 Accepted — design exists, ratified; just needs implementing. Drops to **Medium** once renderer code is committed and the Diagnostic agent renders cleanly (Week 4). Drops to **Low** once all five v1.0 agent bundles render and pass validation. The risk register entry is updated in this session as part of the ADR-003 commit.

**For Codex Day-7 ratification queue.** ADR-003 + the design doc join the queue alongside `cortextos-primitive-status.md`, ADR-001, ADR-002, `second-brain-design.md`, the deferred atomic master-brief correction commit, and the Day-4 Postgres provisioning artefact. The 22-item spec gap consolidation in design §5.4 plus the four-bucket structure (resolved inline / master-brief edits / Week-1+ prerequisites / operational defaults) is the ratification-supporting evidence.

**For the master brief atomic correction commit.** Edit C (the §8 footnote) joins ADR-001 + ADR-002 edits in the deferred single commit at end of Week 0 / early Week 1. Edits A and B land in this batch's commit because (a) Edit A is needed live before Week-1 renderer implementation can scaffold the package path, (b) Edit B is a small wording add to a code block, (c) neither is substantive enough to warrant the atomic-correction overhead.

**For future ADRs.** ADR-003 explicitly defers three further decisions:

- **Renderer implementation details** (test coverage matrix, packaging strategy, schema-validator library choice between Ajv vs alternatives) — to ADR-004 in Week 1 if the implementation work surfaces architectural choices, or to the implementation PR itself if straightforward.
- **`_shared/` helper code authoring** (`voice-loader.sh`, `hook-helpers.sh` contents) — already on the Week-1 prerequisite list per ADR-002 §"For Week 1 work." Not an ADR; just implementation work.
- **`docs/architecture/vault-concurrency.md` companion document** — already on the Week-1 prerequisite list per ADR-002. Not an ADR; resolves design §2.6 spec gap.

## Status

**Accepted.** Founder decision logged 2026-05-16. Next steps:

1. Edits A and B applied to master brief §4.1 and §8.3 in this batch's commit.
2. Edit C (§8 footnote) joins ADR-001 + ADR-002 edits in the deferred atomic correction commit at end of Week 0 / early Week 1. Five-edit manifest for that commit confirmed: ADR-001 §2.4 row 3 + Ultraplan §3.2; ADR-002 Edit 1 §3.4 + Edit 2 §5.5; ADR-003 Edit C §8.
3. Renderer implementation begins Week 1.
4. Day 7 Codex ratification reviews ADR-003 + design doc + the previously-queued artefacts together.
