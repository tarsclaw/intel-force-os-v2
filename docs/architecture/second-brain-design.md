# IFOS second brain — design specification

**Date:** 2026-05-16 (Week 0, Day 1)
**Status:** Design specification (not a decision record). Recommendation in Q3 is non-binding; ADR-002 ratifies it.
**Surfaced by:** `docs/architecture/cortexos-kb-surface-investigation.md` — the cortextOS KB substrate is incompatible with the IFOS wiki data model, and the gap is large enough that the second brain needs its own design before ADR-002 can land.
**Submodule SHA audited:** `c21fbfe991a0030ea055bd8e2389a0801a424383`

**Reading order:** the investigation doc first, then this. Then ADR-002.

---

## Question 1 — What does cortextOS itself depend on its KB for?

The goal: confirm what cortextOS uses its own KB for, so we know what we are deliberately leaving alone — and verify the master brief §3.1 submodule boundary is not in tension with the plan in Q3.

### 1.1 — Inventory: every cortextOS template skill that touches kb-*

Discovery sweep: `grep -rn "kb-query\|kb-ingest\|kb-collections\|kb-setup\|knowledge-base\|knowledge\.md" packages/harness/cortextos/templates/` returned 34 files. Eliminating duplicates (the `knowledge-base` skill ships verbatim in `agent`, `analyst`, `orchestrator`, and `agent-codex` template trees), the operationally distinct use cases are:

| Template + file | kb-* command(s) invoked | What it does | Load-bearing? |
|---|---|---|---|
| `agent/CLAUDE.md:8` (and identical in `analyst/AGENTS.md:35`, `orchestrator/CLAUDE.md:8`) | `kb-query` | Session-start protocol: "If resuming a task, query KB: `cortextos bus kb-query <task topic>`" — opportunistic memory recall | **No.** The "If resuming a task" conditional is the giveaway — session bootstraps fine without it. |
| `agent/AGENTS.md:296-300` (and identical in `analyst/AGENTS.md:296-300`) | `kb-ingest` | Heartbeat protocol: "Run on every heartbeat: `kb-ingest ./MEMORY.md ./memory/$(date -u +%Y-%m-%d).md --scope private --collection memory-$CTX_AGENT_NAME --force`" — auto-reindex of agent memory | **Yes** for cortextOS's own agents. This is the mechanism by which an agent's MEMORY.md and daily memory become semantically searchable across sessions. |
| `analyst/.claude/skills/memory/SKILL.md:107` | `kb-ingest` | Same pattern — heartbeat re-ingest of `MEMORY.md` + daily memory files | **Yes**, same role as above. |
| `agent/AGENTS.md:285` (and same in `analyst/AGENTS.md:285`) | (narrative description) | Names the KB explicitly as "Layer 3: Knowledge Base — Associative Memory (RAG/ChromaDB)" with three collections: `memory-{agent}` (private, auto), `private-{agent}` (private, agent-managed), `shared-{org}` (org-wide, agent-managed). | **Yes, by definition** — the three-layer memory model assumes the KB exists. Whether each *call* is load-bearing is the previous rows. |
| `orchestrator/.claude/skills/morning-review/SKILL.md:120-122` | `kb-query "health check"` | Smoke test: confirm KB is configured. Explicitly marked: "**OK or empty results**: note 'KB configured'. **Not configured warning**: note 'KB not configured' (informational, not a failure)." | **No.** Explicitly informational, the morning briefing succeeds either way. |
| `orchestrator/.claude/skills/agent-migration/SKILL.md:214-218` | `kb-ingest` | One-time migration: bulk-ingest meeting notes, docs, `MEMORY.md`, `crm/contacts.json` for an adopted agent that has pre-existing data | **No** — a migration tool, not steady-state. Optional and one-time per agent. |
| `agent/.claude/skills/onboarding/SKILL.md:47` | `kb-ingest` | Onboarding checklist row: "KB initial ingestion done — `cortextos bus kb-ingest`" | **No.** It's one row in a checklist; surrounding rows are similarly optional and the agent boots without completing every row. |

### 1.2 — Skills that mention KB but do NOT call kb-*

Notable absences. These read directly off disk (MEMORY.md, experiment files, heartbeat files), not via the KB:

- `analyst/.claude/skills/theta-wave/SKILL.md` (156 lines) — zero `kb-*` invocations. Phase 2 "Deep System Scan" reads `MEMORY.md`, experiment files, event logs, GOALS.md directly (lines 31-40).
- `analyst/.claude/skills/autoresearch/SKILL.md` — zero `kb-*` invocations.
- `m2c1-worker/.claude/skills/m2c1-worker/SKILL.md` — mentions KB only as a tool reference, doesn't call it.
- `hermes/HEARTBEAT.md`, `hermes/TOOLS.md` — KB listed as available, not invoked from skill flows.

This is a real and slightly surprising finding: cortextOS's flagship "agents do autonomous research" loop (theta-wave + autoresearch) does **not** read from or write to the KB. It treats the KB as orthogonal infrastructure for agent memory, not as the substrate for experiment evidence.

### 1.3 — Synthesis: what cortextOS actually does with its KB

cortextOS's KB is used **operationally** for exactly two things that matter for steady-state behaviour:

1. **Per-agent heartbeat auto-ingest of `MEMORY.md` + daily memory** into the agent's private `memory-{agent}` ChromaDB collection. This is the mechanism that turns the agent's evolving memory file into semantically retrievable history.
2. **Opportunistic session-start recall** via `kb-query "<task topic>"` when an agent boots and might be resuming prior work.

Everything else — the `shared-{org}` collection, the `private-{agent}` ingest of arbitrary work products, the morning-review smoke test, the agent-migration bulk-ingest — is either agent-judgment-based or one-off setup.

### 1.4 — The critical finding for IFOS

**IFOS agents do not run cortextOS's heartbeat-memory pattern.** The IFOS Agent Bundle v2 (master brief §8.1) specifies six files per agent:

```
agents/recruitment/{agent-name}/
├── README.md
├── agent.md
├── config.schema.json
├── tools.yaml
├── validate.sh
└── context.sh
```

None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.

So none of the four operational cortextOS uses above (heartbeat ingest, session-start query, morning-review smoke test, agent-migration) are invoked by any IFOS-owned agent. The IFOS agent bundle never calls `kb-query` or `kb-ingest`.

Implication for the §3.4 brain-replacement seam: **the seam was designed to intercept calls that IFOS agents don't make.** The shadow-the-four-`kb-*`-files framing assumed our agents would inherit cortextOS's heartbeat-memory pattern and we'd swap the KB substrate under them. They don't, so there's nothing to swap.

### 1.5 — What we explicitly leave alone

**The cortextOS KB stays in place, untouched, for cortextOS's own use.** Specifically:

- The mmrag.py engine, ChromaDB index, Gemini embeddings, venv, and `bus/kb-*.sh` scripts under `packages/harness/cortextos/` are not modified, removed, or shadowed.
- If a cortextOS-template-derived agent is ever scaffolded inside the `ifos-v2` instance (e.g. for a debug session, a worker spawn, a meta-orchestrator outside the recruitment vertical), it inherits its template's KB calls verbatim and operates against its own per-org ChromaDB index under `$HOME/.cortextos/ifos-v2/orgs/<org>/knowledge-base/`. No collision with the IFOS wiki.
- This respects master brief §3.1 ("never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points") without exercising the exception — we don't shadow them at all.

The exception in §3.1 becomes a dead clause: there are four `bus/kb-*.sh` files but we don't shadow them. The §3.4 wording needs to change to reflect this (ADR-002 will specify the replacement wording).

### 1.6 — One thing to watch

The agent-migration scenario (`orchestrator/agent-migration/SKILL.md:214-218`) ingests `crm/contacts.json` and meeting notes into the cortextOS KB. If a founder ever runs an orchestrator agent inside `ifos-v2` and that orchestrator is told to migrate a non-IFOS agent's data, it would write to the cortextOS KB. That's fine — those writes go into the cortextOS KB, not into the IFOS wiki, and the two stay separated by directory path. The risk is purely that a careless `--scope shared` ingest could leak tenant data into a shared collection. The "scope" parameter is the gate; that's a cortextOS-layer concern, not an IFOS one.

### 1.7 — Do IFOS agents inherit cortextOS template skills?

The Q1 finding that "no IFOS-owned agent calls kb-*" assumed IFOS agents are NOT scaffolded from cortextOS's base template. That assumption needs verification, because if `cortextos-ifos add-agent` is the path IFOS uses, the inherited `.claude/skills/` tree pulls `knowledge-base` and `memory` skills in by default, and those skills DO call `kb-*`.

**What `cortextos-ifos add-agent` actually does** (`src/cli/add-agent.ts:88-110`):

- Creates `${projectRoot}/orgs/<org>/agents/<name>/` and a `memory/` subdir (line 89-90).
- For Claude-Code runtimes (the IFOS default), creates `.claude/skills/` (line 95-97).
- Resolves the template dir via `findTemplateDir(projectRoot, effectiveTemplate)` (line 107, definition at line 366-380). Search order: `templates/<name>` under projectRoot, then `CTX_FRAMEWORK_ROOT`, then `node_modules/cortextos/templates/<name>`, then this file's `..` for dev.
- Calls `copyTemplateFiles(templateDir, agentDir, name, org)` (line 109, definition at line 382-402): recursive copy of the entire template tree, with `{{agent_name}}` / `{{org}}` / `{{current_timestamp}}` placeholder substitution. Excludes `node_modules`. **Copies `.claude/skills/` verbatim.**

**What the base `agent` template ships in `.claude/skills/`** (from `ls templates/agent/.claude/skills/`):

```
activity-channel  agent-browser  agent-management  approvals
auto-skill  autoresearch  bus-reference  comms  cron-management
env-management  event-logging  guardrails-reference  heartbeat
human-tasks  knowledge-base  m2c1-worker  memory  onboarding
soul-philosophy  system-diagnostics  tasks  tool-registration
worker-agents
```

24 skills. Of these, **`knowledge-base/SKILL.md`** calls `kb-query / kb-ingest / kb-collections / kb-setup` (Q1.1 inventory), and **`memory/SKILL.md`** calls `kb-ingest` for heartbeat memory re-ingestion (analyst memory SKILL.md:107).

**So `cortextos-ifos add-agent --template agent` produces an agent that inherits all kb-* calls.** That is outcome **(b)** per the founder's enumeration — for any agent scaffolded this way.

**But IFOS Agent Bundle v2 is a different shape.** Master brief §8.1 specifies six files plus three fixture directories:

```
agents/recruitment/{agent-name}/
├── README.md
├── agent.md            ← output contract + workflow + gates + escalation
├── config.schema.json
├── tools.yaml
├── validate.sh
├── context.sh
└── tests/fixtures/{01-primary, 02-edge-case-X, 99-voice-drift-canary}/
```

No `CLAUDE.md`, no `AGENTS.md`, no `MEMORY.md`, no `.claude/skills/` tree. The bundle lives at `${repo}/agents/recruitment/<name>/` (in the IFOS repo, not under cortextOS's `orgs/<org>/agents/`). Master brief §8.3 shows the working pattern is hand-`mkdir` of this layout in Claude Code, not `cortextos-ifos add-agent`.

**The spec gap.** The cortextOS daemon's `AgentManager.discoverAndStart()` (Primitive 1 evidence, `src/daemon/agent-manager.ts:47-78`) bootstraps agents from `${projectRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `.env`, `CLAUDE.md` or `AGENTS.md`, etc.). The IFOS Agent Bundle v2 lives at a different path with a different shape. **Master brief §8 does not specify how the v2 bundle becomes a runnable cortextOS agent.** There is no "renderer" that translates the bundle into a cortextOS-compatible directory. This is a real spec gap and goes in the "Spec gaps surfaced" section at the end of this design.

**Two plausible renderer designs:**

| Design | Mechanism | Inherited cortextOS skills? | Net result |
|---|---|---|---|
| **R1. Bundle-on-top-of-template** | Renderer calls `cortextos-ifos add-agent --template agent`, then overlays IFOS files (`agent.md` → custom `CLAUDE.md`, `config.schema.json` → augmented `config.json`, `tools.yaml` references IFOS adapters). | **Yes by default.** All 24 base-template skills come along unless explicitly stripped. | IFOS agents call cortextOS's KB by inheritance, breaking the §1.5 "untouched" promise. |
| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |

**The recommendation.** Design **R2** (bundle-only renderer). Three reasons:

1. **It honours the §3.1 boundary cleanly.** The §3.1 exception in master brief is "the four `bus/kb-*.sh` shadow points." If we don't shadow them (per §1.5), inheriting skills that call them invites confusion — the inherited skills point at cortextOS's KB, and we'd need to remember that IFOS-owned agents must not invoke them. R2 removes the question entirely.
2. **It matches the Rule 3 vocabulary.** Master brief §1 Rule 3 is "Reuse before build" — every agent uses `agents/_shared/` modules. R2 makes `_shared/` the only shared surface; the 24 inherited cortextOS skills would be a parallel shared surface in tension with the IFOS one.
3. **It defers cortextOS-template features cleanly.** If a future IFOS need genuinely benefits from one of cortextOS's 24 skills (e.g. `human-tasks`, `approvals`, `agent-browser`), the bundle's `tools.yaml` can opt in by referencing it explicitly. Explicit opt-in beats default inheritance for a multi-tenant product.

**Until the renderer is built** (Week 0 has no agent code per master brief §6 Day 7; the renderer is a Week 1+ concern), the inherited-skills risk only matters for any debug/probe agents scaffolded via `cortextos-ifos add-agent` during Week 0 verification. Those probe agents will inherit the kb-* calls and write to cortextOS's KB — which is fine, because cortextOS's KB stays in place per §1.5.

**Net answer to the §1.7 question:** at SHA `c21fbfe`, outcome is **(b) by default** for any agent scaffolded via `cortextos-ifos add-agent`. The IFOS bundle's renderer (a Week 1+ artefact, not yet built) should adopt design **R2 (bundle-only)** to flip the default to **(a)**.

**Week-1 prerequisite, flagged for future sessions:** the renderer is a missing first-class artefact in the Week 1 plan. Without it, you cannot run an IFOS agent — the daemon's `AgentManager.discoverAndStart()` will not find a v2 bundle at `${repo}/agents/recruitment/<name>/` because it reads from `${projectRoot}/orgs/<org>/agents/<name>/`. The renderer's full design needs its own dedicated artefact (likely ADR-003 or `docs/architecture/agent-bundle-renderer-design.md`) before any v1.0 agent code can ship.

---

## Question 2 — What does the IFOS second brain need to do?

Concrete operations. No prose architecture without an operation behind it.

### 2.1 — Vault layout (per tenant)

Two source documents touch on vault structure. Master brief §5.1 (lines 297-349) and Ultraplan §5.1 (line 220) **disagree** — flagged as **Spec gap 2.1-A** in the final section. Master brief wins per §0; this design merges the two so nothing is lost.

The structural insight from the investigation document — **raw/ is append-only ingestion, compiled/ is entity-document storage** — is load-bearing for the wiki tree. raw/ stays where cortextOS-style chunked semantic search is plausible (Pulse-like future agents); compiled/ is where IFOS owns its entity-document model fully.

**Canonical v1.0 layout:**

```
/vault/{tenant-slug}/                               ← path per master brief §3.3 line 217, Ultraplan §5.1 line 217
├── _voice/                                         ← voice profile (Ultraplan §5.1 line 220)
│   ├── style-guide.md                              ← master brief §5.5 footnote, Ultraplan §5.2 wizard Day 3
│   ├── tone-rules.yaml                             ← Ultraplan §6.1 line 312
│   └── samples/                                    ← Ultraplan §6.1 line 313 — 20+ pasted emails, embedded in pgvector
├── _playbooks/                                     ← firm SOPs (Ultraplan §5.1 line 220)
├── _decisions/                                     ← narrative summaries — spec gap 2.1-B re: overlap with Postgres decision_log
├── _config.yaml                                    ← per-tenant config (Ultraplan §5.1 line 220)
├── wiki/                                           ← the second brain (master brief §5.1 line 306)
│   ├── raw/                                        ← append-only ingestion (master brief §5.1 lines 316-321)
│   │   ├── inbox-emails/                           ← from email ingestion (master brief §5.1 line 317)
│   │   ├── calls/                                  ← Fathom/Fireflies transcripts (master brief §5.1 line 318)
│   │   ├── briefs/                                 ← inbound brief detection (master brief §5.1 line 319)
│   │   ├── notes/                                  ← freeform consultant notes (master brief §5.1 line 320)
│   │   └── ats-snapshots/                          ← Bullhorn entity snapshots (master brief §5.1 line 321)
│   ├── compiled/                                   ← LLM-owned, agent-managed (master brief §5.1 line 323)
│   │   ├── index.md                                ← master index, one-line per page (master brief §5.1 line 324)
│   │   ├── candidates/                             ← one .md per Candidate (master brief §5.1 line 325)
│   │   ├── clients/                                ← one .md per Client (master brief §5.1 line 326)
│   │   ├── briefs/                                 ← one .md per Brief (master brief §5.1 line 327)
│   │   ├── placements/                             ← one .md per Placement (master brief §5.1 line 328)
│   │   ├── people/                                 ← Contacts at clients (master brief §5.1 line 329)
│   │   ├── concepts/                               ← firm domain concepts (master brief §5.1 line 330) — v1.2+ deferred
│   │   ├── playbooks/                              ← spec gap 2.1-C: conflicts with /vault/{tenant}/_playbooks/
│   │   └── archive/                                ← absorbed/deleted pages (master brief §5.1 line 332)
│   └── .wiki/                                      ← compilation state (master brief §5.1 line 334)
│       ├── manifest.json                           ← per-raw-file compilation status (master brief §5.1 line 335)
│       ├── reflect-state.json                      ← reflect cycle state (master brief §5.1 line 336)
│       └── graph.json                              ← cached graph for fast UI loads (master brief §5.1 line 337) — v1.2 graph view
└── temp/                                           ← if Temp tier active (Ultraplan §5.1 line 220) — v1.1+ deferred for IFOS Temp launch
```

**Per-directory contracts:**

| Path | Granularity | Format | Naming | Writes | Reads |
|---|---|---|---|---|---|
| `_voice/style-guide.md` | one file | markdown | fixed name | Onboarding wizard Day 3 (founder); Concierge edits via Brain UI v1.1+ | every agent's `context.sh` via `_shared/voice-loader.sh` (Ultraplan §6.1 line 322) |
| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
| `_playbooks/` | one file per playbook | markdown | human-readable slugs | founder via Obsidian | every agent context, ad-hoc |
| `_decisions/` | spec gap 2.1-B | spec gap | spec gap | spec gap | spec gap |
| `_config.yaml` | one file | YAML | fixed name | Onboarding wizard Day 4 | every agent's `context.sh` |
| `wiki/raw/inbox-emails/` | one file per email | markdown with frontmatter | `{epoch}-{from-domain}-{rand5}.md` | inbound email webhook handler (v1.0: Cash Conductor for AR-relevant; v1.1: Triage for everything) | Brief Decoder (v1.1), Cash Conductor (v1.0); future Pulse semantic-search-over-raw |
| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
| `wiki/raw/briefs/` | one file per brief intake | markdown with frontmatter | `{epoch}-{brief-id}.md` | Brief Decoder (v1.1) on inbound | Sourcing Scout (v1.0 reads only candidate-relevant); Brief Decoder (v1.1) |
| `wiki/raw/notes/` | one file per note | markdown | free | founder via Obsidian | any agent ad-hoc |
| `wiki/raw/ats-snapshots/` | one file per entity sync | JSON | `{epoch}-{bullhorn-entity-type}-{bullhorn-id}.json` | Janitor (v1.0) on nightly sweep | Janitor itself (diff vs previous), Concierge (v1.0) for entity reconciliation |
| `wiki/compiled/index.md` | one file | markdown | fixed name | compile.ts (v1.1; manual at v1.0 if needed) | Brain UI (v1.1) |
| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
| `wiki/compiled/briefs/{slug}.md` | one per Brief | same | same | Brief Decoder (v1.1); manual at v1.0 if needed | Sourcing Scout (v1.0 reads only); Brief Decoder (v1.1) |
| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
| `wiki/compiled/concepts/` | one per concept | same | same | **v1.2+ deferred** | n/a |
| `wiki/compiled/playbooks/` | spec gap 2.1-C | — | — | — | — |
| `wiki/compiled/archive/` | one per archived entity | same | same | any agent on soft-delete (v1.2+ for hard delete) | wiki health reflect (v1.1) |
| `wiki/.wiki/manifest.json` | one file | JSON | fixed name | compile.ts (v1.1; bypass at v1.0) | compile.ts (v1.1), Brain UI (v1.1) |
| `wiki/.wiki/reflect-state.json` | one file | JSON | fixed name | reflect.ts (v1.1) | reflect.ts (v1.1), Brain UI (v1.1) |
| `wiki/.wiki/graph.json` | one file | JSON | fixed name | graphify (v1.2) | Brain UI graph view (v1.2) |

**Filesystem-ownership note** (Ultraplan §5.1 line 218-223): `/vault/{tenant-slug}/` is owned by OS user `ifos-tenant-{slug}` in group `ifos-tenants`, mode `0700` on the tenant root, `0644` on files. Kernel-enforced isolation per Ultraplan §5.2 "kernel-stops cross-tenant test passes" on Day 4 of Week 0.

**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).

### 2.2 — Entity types in v1.0

Eight canonical entities exist per master brief §6 Day 6 / Ultraplan §11 Day 6 line 490:

> "Candidate, Contractor, Client, Contact, Role/Brief, Placement, Opportunity, Timesheet"

**Release allocation:**

| Entity | Release | Rationale |
|---|---|---|
| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
| Contractor | **v1.1+** | IFOS Temp launches v1.1 per product spec §9.1; T5 Supply Chain Auditor (v1.1) needs Contractor entities |
| Opportunity | **v1.1+** | Client Hunter digest (v1.1) and Spec Pitcher (v1.2) produce these; no v1.0 agent uses them |
| Timesheet | **v1.1+** | IFOS Temp T2 Timesheet Ranger and T6 Pay & Bill Reconciler are v1.2; T1 Onboarding (v1.2) touches them indirectly |

#### 2.2.1 — Candidate (v1.0)

**Frontmatter schema** (master brief §5.2 lines 357-369 starting example; extended for v1.0 completeness):

```yaml
---
id: candidate_sarah_bowen                            # required; format: candidate_{slug}
entity_type: candidate                               # required; fixed string
tenant_id: ifos_tenant_acme                          # required; matches Postgres tenants.slug
display_name: "Sarah Bowen"                          # required; used in wiki-links
created_at: 2026-05-16T14:32:00Z                     # required; ISO 8601 UTC
updated_at: 2026-05-16T14:32:00Z                     # required; ISO 8601 UTC
provenance:                                          # required; list of agent:source strings
  - scribe-agent:call-2026-05-16-1432
  - janitor:bullhorn-2026-05-15
importance_score: 0.83                               # optional v1.0; populated by reflect.ts v1.1+
linked_entities:                                     # optional; list of [[Type: Name]] wiki-links
  - "[[Client: Aragon Labs]]"
  - "[[Brief: Senior PM Role]]"
bullhorn_id: 12345                                   # optional; external ATS reference (Janitor populates)
linkedin_url: https://linkedin.com/in/sarah-bowen    # optional; Janitor populates
right_to_work_status: verified                       # optional; one of {verified, unverified, expired, n/a}
do_not_contact: false                                # required; defaults to false; respected by Concierge
---
```

**Body content** — hybrid structure. v1.0 expectation:

```markdown
## Summary
{Janitor or Scribe one-paragraph summary, regenerated on each ingest}

## Conversation history
{auto-appended by Concierge / Scribe — chronological, agent-attributed}

## Linked entities
{auto-generated from linked_entities frontmatter, with one-line context per link}

## Notes
{free-form, founder via Obsidian}
```

Auto-generated sections are bracketed by HTML comments so `update-entity` can target them without touching free-form notes:

```markdown
<!-- BEGIN auto:conversation-history -->
...
<!-- END auto:conversation-history -->
```

#### 2.2.2 — Client (v1.0)

```yaml
---
id: client_aragon_labs
entity_type: client
tenant_id: ifos_tenant_acme
display_name: "Aragon Labs"
created_at: ...
updated_at: ...
provenance: [...]
companies_house_number: 12345678                     # optional; UK-specific; Janitor populates
sectors: [fintech, b2b-saas]                         # required v1.0; list of strings from firm taxonomy
linked_entities:                                     # contacts, briefs, placements
  - "[[Contact: Jane Smith]]"
  - "[[Placement: Senior PM 2026-Q3]]"
relationship_tier: key-account                       # optional v1.0; one of {key-account, active, dormant, ex-client}
xero_contact_id: 9876                                # optional; Cash Conductor populates
---
```

Body: same hybrid structure as Candidate (Summary / Conversation history / Linked entities / Notes).

#### 2.2.3 — Brief (v1.0 skeleton / v1.1 full)

v1.0 skeleton: only what Sourcing Scout (A5) needs to source against — role title, client, sector, must-haves. Full v1.1 schema waits for Brief Decoder.

```yaml
---
id: brief_aragon_senior_pm_2026q3
entity_type: brief
tenant_id: ifos_tenant_acme
display_name: "Aragon Labs — Senior PM"
created_at: ...
updated_at: ...
provenance: [...]
client_ref: "[[Client: Aragon Labs]]"                # required; wiki-link to Client
role_title: "Senior Product Manager"                 # required
sector: fintech                                      # required v1.0
salary_range_gbp: [80000, 110000]                    # optional v1.0
must_haves: [ "5+ years B2B SaaS", "UK right-to-work" ]   # required v1.0; list of strings
nice_to_haves: []                                    # optional v1.0
status: open                                         # required; one of {open, on-hold, filled, withdrawn}
linked_entities: []                                  # candidates pitched, placements
---
```

#### 2.2.4 — Placement (v1.0)

```yaml
---
id: placement_sarah_bowen_aragon_2026q3
entity_type: placement
tenant_id: ifos_tenant_acme
display_name: "Sarah Bowen → Aragon Labs (Senior PM 2026-Q3)"
created_at: ...
updated_at: ...
provenance: [...]
candidate_ref: "[[Candidate: Sarah Bowen]]"          # required
client_ref: "[[Client: Aragon Labs]]"                # required
brief_ref: "[[Brief: Aragon Labs — Senior PM]]"      # required
placed_at: 2026-09-01                                # required; ISO date
start_date: 2026-10-01                               # required; ISO date
fee_structure:                                       # required v1.0
  type: contingent                                   # one of {contingent, retained, fixed}
  amount_gbp: 18000
  rebate_period_days: 90
status: active                                       # required; one of {active, completed-rebate, refunded, terminated-early}
invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
---
```

#### 2.2.5 — Contact (v1.0, stored under `wiki/compiled/people/`)

```yaml
---
id: contact_jane_smith_aragon
entity_type: contact
tenant_id: ifos_tenant_acme
display_name: "Jane Smith"
created_at: ...
updated_at: ...
provenance: [...]
employer_ref: "[[Client: Aragon Labs]]"              # required; wiki-link to Client
role: "Head of Product"                              # required
email: jane.smith@aragonlabs.com                     # optional
linkedin_url: https://linkedin.com/in/janesmith      # optional
decision_authority: hiring-manager                   # optional; one of {hiring-manager, hr, finance, exec, gatekeeper}
preferred_channel: email                             # optional; one of {email, phone, linkedin}
do_not_contact: false                                # required
---
```

#### 2.2.6 — Wiki-link convention

Master brief §5.2 line 367 and §5.4 line 412 both use the display-name format:

> `linked_entities: [[Client: Aragon Labs]], [[Brief: Senior PM Role]]`
> `[[Candidate: Sarah Bowen]] renders as a hoverable pill`

**Decision: adopt `[[Entity-Type: Display Name]]` verbatim** as master brief specifies. Rationale: matches master brief decision, Obsidian-compatible, human-readable in raw markdown. Cost: rename safety is fragile — renaming "Sarah Bowen" to "Sarah Bowen-Smith" breaks all links unless an explicit rewrite step runs.

**Rename-safety mechanism** (recommended): the `update-entity` operation, when the `display_name` field changes, triggers a `rewrite-backlinks` job that walks all pages with this entity in `linked_entities` and replaces the link text. The stable anchor is the `id` field — backlinks resolution always goes via id, not display name. The on-disk markdown is the human-facing artefact; the Postgres `entity_graph` table holds the id-based relationship truth.

**Spec gap 2.2-A:** master brief §5 does not specify the rewrite-backlinks mechanism. Recommended resolution: implement as part of `update-entity` in `packages/brain/wiki/lib/update.ts` v1.0.

#### 2.2.7 — File-naming convention

Master brief §5.1 lines 325-332 shows directories like `candidates/` but does not specify filename format. **Spec gap 2.2-B.**

**Decision: file = `{slug}.md` where slug is the `id` field minus the entity-type prefix.** Examples:

- `id: candidate_sarah_bowen` → file `wiki/compiled/candidates/sarah_bowen.md`
- `id: client_aragon_labs` → file `wiki/compiled/clients/aragon_labs.md`
- `id: brief_aragon_senior_pm_2026q3` → file `wiki/compiled/briefs/aragon_senior_pm_2026q3.md`

Rationale: stable (slug doesn't change on display-name edit because slug is derived from `id` not `display_name`); directory-disambiguated (no need for entity-type prefix in filename — the parent dir is the type); human-readable (slug is the natural-language identifier).

**Slug-collision handling:** if two Candidates share the same natural slug (two "Sarah Bowen" people), the second gets a numeric suffix at ingest time: `sarah_bowen_2.md`. The `ingest-entity` operation handles collision detection by reading the directory before writing.

### 2.3 — Operations agents must support

The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.

The raw/ vs compiled/ split from the investigation doc surfaces in this table at the `semantic-search-over-raw` row — that's the only operation where cortextOS-style chunked vector search is a candidate substrate.

| Operation | Caller (v1.0/v1.1) | Release | Input | Output | Latency | Notes |
|---|---|---|---|---|---|---|
| `search-by-name` | Concierge (v1.0): name → Candidate page on inbound message | v1.0 | `(entity_type: str, name_query: str, tenant_id: str)` | `List[EntityRef]` ranked by match score | sub-second | Fuzzy match (Levenshtein + token set); falls through to `search-by-attribute(display_name=...)` for exact. Postgres `entity_graph` indexed read. |
| `search-by-id` | every agent: resume context from a known id | v1.0 | `(id: str, tenant_id: str)` | `EntityRef \| None` | sub-second | Direct filesystem read after Postgres id→path lookup. |
| `search-by-relationship` | Janitor (v1.0): all Candidates linked to Brief X for dedup | v1.0 | `(from_id: str, link_type: str, tenant_id: str)` | `List[EntityRef]` | few seconds | Postgres `entity_graph` traversal; one-hop only in v1.0, multi-hop deferred to graph view v1.2 |
| `search-by-attribute` | Brief Decoder (v1.1): Placements where sector=fintech, placed_at in Q3 | v1.1 | `(entity_type: str, filters: dict, tenant_id: str)` | `List[EntityRef]` | few seconds | Postgres `entity_graph` indexed columns + JSONB attribute filter; pgvector for full-text fallback |
| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
| `update-entity` | Concierge (v1.0): append conversation note to Candidate page | v1.0 | `(id: str, section: str, content: str, tenant_id: str)` | `EntityRef` | few seconds | Targets the `<!-- BEGIN auto:{section} -->` block per §2.2.1; preserves frontmatter; rewrites backlinks if `display_name` changes; `hh_decision_*` called |
| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
| `list-by-type-and-tenant` | Sourcing Scout (v1.0): enumerate Candidates for filtering; Brief Decoder (v1.1): enumerate open Briefs | v1.0 (Candidate, Client, Placement, Contact); v1.1 (Brief full enumeration) | `(entity_type: str, tenant_id: str, filters?: dict, limit?: int)` | `List[EntityRef]` | few seconds | Postgres-indexed; filtering matches `search-by-attribute` |
| `semantic-search-over-raw` | future Pulse (v1.2): "any inbox emails mentioning compliance risk in last 30 days" | **v1.2+ deferred** | `(query: str, raw_collection: str, tenant_id: str, date_range?: tuple)` | `List[RawChunkRef]` ranked by similarity | few seconds | The only operation where cortextOS's mmrag/ChromaDB substrate is a plausible candidate. v1.0/v1.1 don't need it — flagged in Q3 as the one place ADR-002 should leave a forward-compatible hook |
| `backlinks` | Brain UI (v1.1): show backlinks panel | v1.1 | `(id: str, tenant_id: str)` | `List[EntityRef]` | few seconds | Postgres `entity_graph` reverse lookup |
| `delete-entity` | any agent + human override; soft via `archive/` move | **v1.2+ deferred** | `(id: str, mode: 'soft'\|'hard', tenant_id: str)` | `EntityRef` (with `status: archived`) | few seconds | Master brief §5.1 line 332 implies soft via archive/; hard delete is GDPR-driven (Ultraplan §5.5 line 275 day-60 cryptographic erase) but operates at tenant level, not entity level |
| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |

**Operations explicitly NOT in v1.0/v1.1 design scope:**

- Graph multi-hop traversal — v1.2 graph view (master brief §5.5 line 423)
- Wiki health reflect (orphan detection, contradiction detection) — v1.1 (master brief §5.2 lines 371)
- Per-firm LoRA query — v2.0 (master brief §5.5 line 424)
- Hard-delete-per-entity — v1.2+; v1.0/v1.1 hard-delete is only at tenant offboarding (Ultraplan §5.5)

**The `semantic-search-over-raw` row is the bridge to ADR-002.** Q3 will recommend whether to use cortextOS's mmrag/ChromaDB for this future operation (which would require shadowing exactly the `bus/kb-ingest.sh` + `bus/kb-query.sh` pair against `raw/` content), or build an IFOS-native pgvector index over raw/ — both are tenable, both are v1.2+ work, neither needs a decision before Week 11.

---

### 2.4 — Storage substrate

#### 2.4.1 Markdown files on disk

- **Path:** `/vault/{tenant-slug}/` on the shared encrypted LUKS volume (Ultraplan §5.1 line 218). Sub-paths per §2.1 above.
- **Ownership:** OS user `ifos-tenant-{slug}` in group `ifos-tenants`, mode `0700` on the tenant root, `0644` on files (Ultraplan §5.1 lines 218-223). The PM2 agent process for tenant X runs as `ifos-tenant-{X}` and cannot read tenant Y's vault — kernel enforces this.
- **Writers (v1.0):**
  - **Founder via Obsidian** writes to `_voice/`, `_playbooks/`, `wiki/raw/notes/`, free-form `## Notes` sections of any compiled entity. Founder has shell access as `ifos-tenant-{slug}` (or runs Obsidian on the same UID via SSHFS/sync — operational detail for the Day 4 infra plan).
  - **Agents** write to `wiki/raw/{inbox-emails,calls,ats-snapshots}/`, `wiki/compiled/{candidates,clients,placements,people}/`, and `wiki/compiled/briefs/` (minimal v1.0). Writes are atomic (write-to-temp-then-rename, matching cortextOS's `src/utils/atomic.ts`).
- **Concurrency mediation** (full mechanism in §2.6): per-entity advisory file lock via `flock(2)` on `wiki/compiled/{type}/{slug}.md.lock`. Lock is held only for the duration of the read-modify-write of the single file (sub-second). Inter-agent collisions surface as "lock held, retry" rather than corruption.
- **Obsidian compatibility:** frontmatter restricted to YAML 1.2 features Obsidian's `gray-matter` parser accepts — strings, ints, floats, ISO 8601 strings, flow-style and block-style sequences, flow-style and block-style mappings (one level of nesting only). **No anchors, no aliases, no merge keys, no custom tags.** Wiki-links in body use Obsidian's `[[Display Name]]` and `[[Type: Display Name]]` syntax — both render. Frontmatter `linked_entities` is a list of strings that *look like* wiki-links; Obsidian doesn't render frontmatter strings as links by default, but the master brief §5.2 example uses this form and we adopt it.
- **Backup model:**
  - **Filesystem:** Restic nightly to S3-compatible UK-region storage, 30 days of dailies + 12 months of monthlies (Ultraplan §5.6 line 281). RPO 5 minutes, RTO 4 hours (Ultraplan §5.6 line 283).
  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.

#### 2.4.2 Postgres tables (v1.0)

Three tables anchored in Ultraplan §5.1 line 227 ("`tenants`, `entity_graph`, `decision_log`"). The IFOS design here renames `entity_graph` to **`entities`** (one row per entity) and adds **`entity_links`** (the adjacency table) — both flagged below as **Spec gap 2.4-B** because Ultraplan groups them under a single name.

**Table: `tenants`** (master brief §3.3 + Ultraplan §5.1)

```sql
CREATE TABLE tenants (
  slug              TEXT PRIMARY KEY,                    -- matches /vault/{slug}/, ifos-tenant-{slug} OS user
  display_name      TEXT NOT NULL,                       -- "Acme Recruitment Ltd"
  tier              TEXT NOT NULL,                       -- one of {solo, boutique, growth, scale, compliance-core, compliance-ops, full-temp}
  status            TEXT NOT NULL,                       -- one of {active, provisioning, suspended, offboarding}
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  postgres_role     TEXT NOT NULL,                       -- ifos_tenant_{slug} — RLS subject
  os_user           TEXT NOT NULL                        -- ifos-tenant-{slug}
);
```

Not RLS-protected — this is the table that *defines* the RLS subject for every other table. Only `ifos_admin` role reads/writes.

**Table: `entities`** (source-of-truth for entity catalog, derived from filesystem on ingest)

```sql
CREATE TABLE entities (
  id                TEXT NOT NULL,                       -- e.g. candidate_sarah_bowen (matches frontmatter id)
  tenant_slug       TEXT NOT NULL REFERENCES tenants(slug),
  entity_type       TEXT NOT NULL,                       -- one of {candidate, client, brief, placement, contact, contractor, opportunity, timesheet}
  display_name      TEXT NOT NULL,                       -- "Sarah Bowen"
  file_path         TEXT NOT NULL,                       -- wiki/compiled/candidates/sarah_bowen.md
  frontmatter       JSONB NOT NULL,                      -- full frontmatter as parsed
  body_summary      TEXT,                                -- optional v1.0; reflect.ts v1.1 populates
  importance_score  REAL,                                -- optional v1.0; reflect.ts populates
  status            TEXT NOT NULL DEFAULT 'active',      -- one of {active, archived, soft-deleted}
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_slug, id)
);

CREATE INDEX entities_type_tenant_idx ON entities (tenant_slug, entity_type, status);
CREATE INDEX entities_display_name_trgm_idx ON entities USING gin (display_name gin_trgm_ops);   -- fuzzy name search
CREATE INDEX entities_frontmatter_gin_idx ON entities USING gin (frontmatter);                   -- attribute search

ALTER TABLE entities ENABLE ROW LEVEL SECURITY;
CREATE POLICY entities_tenant_isolation ON entities
  USING (tenant_slug = current_setting('ifos.current_tenant', true));
```

The trigram index on `display_name` serves `search-by-name` sub-second. The GIN index on `frontmatter` JSONB serves `search-by-attribute` (e.g. `frontmatter @> '{"sector": "fintech"}'`).

**Source of truth:** filesystem markdown is canonical for body content; Postgres `entities` is canonical for the index. On `ingest-entity` and `update-entity`, both write in the same logical transaction (filesystem-atomic-write followed by Postgres UPSERT; if Postgres fails, the filesystem write is rolled back — see §2.6.1).

**Table: `entity_links`** (adjacency table for backlinks, derived from frontmatter on ingest)

```sql
CREATE TABLE entity_links (
  tenant_slug       TEXT NOT NULL REFERENCES tenants(slug),
  from_id           TEXT NOT NULL,
  to_display_name   TEXT NOT NULL,                       -- the target's display_name at time of link
  to_entity_type    TEXT NOT NULL,                       -- the target's entity_type at time of link
  to_id             TEXT,                                -- resolved target id; NULL if dangling link
  link_type         TEXT NOT NULL DEFAULT 'reference',   -- one of {reference, parent, related} — v1.0 only 'reference'
  source_section    TEXT,                                -- which section of the source page contains the link (frontmatter | body | auto-block-name)
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_slug, from_id, to_display_name, to_entity_type)
);

CREATE INDEX entity_links_backlinks_idx ON entity_links (tenant_slug, to_id);
CREATE INDEX entity_links_forward_idx ON entity_links (tenant_slug, from_id);

ALTER TABLE entity_links ENABLE ROW LEVEL SECURITY;
CREATE POLICY entity_links_tenant_isolation ON entity_links
  USING (tenant_slug = current_setting('ifos.current_tenant', true));
```

**Dangling links:** if a wiki-link `[[Candidate: Joe Bloggs]]` points at a non-existent Candidate, the row has `to_id = NULL`. On future `ingest-entity` for "Joe Bloggs", a deferred-resolver pass populates `to_id`. This is how the wiki survives forward-references.

**Source of truth:** filesystem markdown is canonical for the link presence; Postgres `entity_links` is the index. Resolution (display_name → id) is the IFOS-specific value-add — without it, `[[Sarah Bowen]]` is just a string.

**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)

```sql
CREATE TABLE decision_log (
  id                BIGSERIAL,
  tenant_slug       TEXT NOT NULL REFERENCES tenants(slug),
  agent_name        TEXT NOT NULL,                       -- e.g. "concierge"
  agent_run_id      TEXT NOT NULL,                       -- ties trigger/output/action across one run
  phase             TEXT NOT NULL,                       -- one of {trigger, output, action}
  entity_id         TEXT,                                -- which entity this decision relates to (NULL for cross-entity decisions)
  trigger_source    TEXT,                                -- for phase=trigger: webhook | cron | bus-message | telegram
  output_artefact   TEXT,                                -- for phase=output: filesystem path or message id of produced output
  human_action      TEXT,                                -- for phase=action: one of {send-as-is, edit-then-send, reject, ignore}
  human_diff        TEXT,                                -- for phase=action=edit-then-send: the diff captured for voice corpus
  metadata          JSONB,                               -- agent-specific extension
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_slug, id)
) PARTITION BY HASH (tenant_slug);

CREATE INDEX decision_log_entity_idx ON decision_log (tenant_slug, entity_id, created_at DESC);
CREATE INDEX decision_log_agent_run_idx ON decision_log (tenant_slug, agent_run_id);

ALTER TABLE decision_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY decision_log_tenant_isolation ON decision_log
  USING (tenant_slug = current_setting('ifos.current_tenant', true));
```

Partitioned by hash on `tenant_slug` (Ultraplan §5.1 line 228: "Both `entity_graph` and `decision_log` partitioned by `tenant_id` (hash partitioning, 32 partitions to start)"). This is the **only** source of entity-history queries — the `_decisions/` directory in Ultraplan §5.1 line 220 is for narrative summaries (Spec gap 2.1-B remains; recommended resolution: `_decisions/` is for founder-written end-of-quarter narratives only, not for agent decisions; agent decisions live exclusively in `decision_log`).

**Spec gap 2.4-B:** Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`". This design splits them into `entities` + `entity_links` for clearer indexing semantics. **Recommended resolution:** adopt the split; update master brief §3.3 or Ultraplan §5.1 to reflect the two-table model. Codex-ratifiable on Day 7 by reading this section.

**No `agent_runs` table for v1.0.** The `agent_run_id` column on `decision_log` is the join key; "what did this agent do this run" is a `SELECT * FROM decision_log WHERE agent_run_id = ...`. A separate `agent_runs` table can be derived as a materialised view if v1.1 dashboards need it.

#### 2.4.3 pgvector indexes

**v1.0 use:** voice corpus only. Ultraplan §6.1 line 314 says "samples/{n}.md — raw samples indexed for RAG retrieval (embedded with pgvector at capture time)" and line 322 says voice-loader.sh retrieves "the 3 most semantically similar past samples to the current task via pgvector cosine similarity."

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE voice_samples_embedded (
  tenant_slug       TEXT NOT NULL REFERENCES tenants(slug),
  sample_id         TEXT NOT NULL,                       -- {epoch}-{rand5} from _voice/samples/{epoch}-{rand5}.md
  task_type         TEXT,                                -- optional; e.g. "candidate-acknowledgement"
  embedding         vector(3072) NOT NULL,
  body              TEXT NOT NULL,                       -- the sample text (for in-context injection)
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_slug, sample_id)
);

CREATE INDEX voice_samples_embedding_idx ON voice_samples_embedded
  USING hnsw (embedding vector_cosine_ops);

ALTER TABLE voice_samples_embedded ENABLE ROW LEVEL SECURITY;
CREATE POLICY voice_samples_tenant_isolation ON voice_samples_embedded
  USING (tenant_slug = current_setting('ifos.current_tenant', true));
```

**Embedding model decision:** **gemini-embedding-001 (3072 dimensions)**. Same model as cortextOS's KB substrate (per kb-setup.sh's migration target at line 101). Three reasons:

1. **Forward-compatibility with semantic-search-over-raw (v1.2+).** If the eventual Pulse-like agent uses cortextOS's mmrag/ChromaDB for raw/ content, IFOS-side and cortextOS-side embeddings live in the same vector space and a query embedded once can search both indexes. ADR-002 will recommend keeping this hook open.
2. **Operational simplicity.** One Gemini API key (`GEMINI_API_KEY` in `secrets.env`) serves both cortextOS's KB (its own use) and IFOS's voice corpus. Cost is identical per-token.
3. **Master brief is silent on model choice** (Spec gap 2.4-C, recommended resolution: adopt gemini-embedding-001; revisit if Anthropic or OpenAI ships a sharply better embedding model before Week 11).

**Granularity:** one vector per voice sample (whole-file embedding, not chunked). Voice samples are short (typically 100-400 words per sample); chunking adds no value at this scale and increases the storage / retrieval count.

**Not in v1.0 pgvector index:**
- compiled/ entity pages — searched by `search-by-name` (trigram) and `search-by-attribute` (JSONB GIN). Embedding compiled/ pages is v1.1+ if reflect.ts wants semantic dedup.
- raw/ content — v1.2+ semantic-search-over-raw deferral.
- decision_log — never embedded; structured queries only.

#### 2.4.4 cortextOS KB usage in IFOS

Per Q1.5, **zero use of cortextOS's `kb-*` surface by IFOS-owned agents in v1.0 or v1.1.** cortextOS's mmrag.py + ChromaDB + Gemini-embedding stack stays in place under `$HOME/.cortextos/ifos-v2/orgs/<org>/knowledge-base/` for any cortextOS-template agent that happens to be scaffolded in `ifos-v2` (debug, probe, worker spawn).

**v1.2+ forward-compatibility hook:** the semantic-search-over-raw operation (v1.2+) is the one place where cortextOS's substrate could come back into the picture. ADR-002 will recommend leaving the option open — i.e. don't dismantle cortextOS's KB tooling — without scoping the v1.2 work now.

#### 2.4.5 Storage decision diagram (v1.0)

```
        Founder (Obsidian)                          Agent (PTY, ifos-tenant-{slug})
              │                                              │
              │ writes _voice/, _playbooks/, _decisions/,    │ writes wiki/raw/, wiki/compiled/
              │ free-form Notes sections                     │ via atomic-write
              │                                              │
              ▼                                              ▼
        ┌──────────────────────────────────────────────────────────────┐
        │                /vault/{tenant-slug}/                         │
        │  _voice/ samples/*.md  ─┐                                    │
        │  _playbooks/*.md         │                                   │
        │  _decisions/*.md         │ (Source of truth for markdown)    │
        │  wiki/raw/{inbox-emails,calls,briefs,notes,ats-snapshots}/   │
        │  wiki/compiled/{candidates,clients,briefs,placements,people}/│
        └────────────────┬──────────────────────────────┬──────────────┘
                         │                              │
              on ingest- │                              │ embedding job (debounced)
            /update-     │                              │ on _voice/samples/ change
             entity      ▼                              ▼
        ┌────────────────────────────┐    ┌─────────────────────────────┐
        │ Postgres (RLS by tenant)   │    │ Postgres pgvector           │
        │  entities (JSONB +trgm+GIN)│    │  voice_samples_embedded     │
        │  entity_links              │    │   embedding vector(3072)    │
        │  decision_log (partitioned)│    │   hnsw cosine_ops           │
        │  tenants                   │    │                             │
        └────────────────┬───────────┘    └─────────────────────────────┘
                         │                              │
                         │                              │
                         ▼                              ▼
        ┌──────────────────────────────────────────────────────────────┐
        │              Agent read operations (§2.5 table)              │
        │  search-by-name → trigram on entities.display_name           │
        │  search-by-attribute → JSONB GIN on entities.frontmatter     │
        │  search-by-relationship → entity_links lookup                │
        │  ingest/update-entity → filesystem + Postgres atomic write   │
        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
        │  entity-history → decision_log SELECT                        │
        └──────────────────────────────────────────────────────────────┘

        Out of scope for v1.0/v1.1 reads (parallel and untouched):

        ┌──────────────────────────────────────────────────────────────┐
        │ cortextOS KB (mmrag.py + ChromaDB + Gemini embedding)        │
        │  $HOME/.cortextos/ifos-v2/orgs/<org>/knowledge-base/         │
        │  used only by cortextOS-template agents (debug/probe/worker) │
        │  v1.2+ semantic-search-over-raw may bridge here              │
        └──────────────────────────────────────────────────────────────┘
```

### 2.5 — Index strategy per operation

| Operation | Primary index | Fallback index | Notes |
|---|---|---|---|
| `search-by-name` | Postgres `entities` trigram on `display_name` (`gin_trgm_ops`) | Filesystem grep over `wiki/compiled/{type}/*.md` frontmatter | Hot path; sub-second target. Fuzzy match returns top-N by similarity score; tie-break by `importance_score DESC` then `updated_at DESC`. Fallback only fires if Postgres unhealthy (per master brief §3.5 RLS / Ultraplan §3.5 degraded-mode contingency). |
| `search-by-id` | Filesystem read at known path (id → `wiki/compiled/{type}/{slug}.md` derived from id) | Postgres `entities` SELECT by `(tenant_slug, id)` if filesystem missing | id encodes the type-prefix and slug, so no Postgres lookup needed for the read; Postgres is the fallback for missing/moved files. |
| `search-by-relationship` | Postgres `entity_links` reverse lookup by `to_id` (or forward by `from_id`) | None — if Postgres is down, this operation fails loudly rather than falling back | One-hop only in v1.0. The Postgres-only choice is deliberate: filesystem grep over frontmatter `linked_entities` arrays would be slow and brittle. |
| `search-by-attribute` | Postgres `entities` JSONB GIN on `frontmatter` (e.g. `frontmatter @> '{"sector": "fintech"}'`) | None — fail loudly if Postgres is down | v1.1. Supports both exact match (`@>`) and presence (`?`) and partial-string via trigram on `display_name`. Multi-condition uses standard SQL AND/OR; expressed in the API as `filters: dict`. |
| `ingest-entity` | Filesystem write (atomic) + Postgres UPSERT to `entities` + Postgres INSERTs to `entity_links` (all in one transaction per §2.6.1) | None — atomic or fail | Slug collision check via Postgres `SELECT 1 FROM entities WHERE tenant_slug = ? AND id = ?`. `hh_decision_trigger` + `hh_decision_output` calls insert to `decision_log` in the same transaction. |
| `update-entity` | Filesystem read-modify-write (under `flock`) + Postgres UPDATE `entities` + diff-driven update to `entity_links` | None — atomic or fail | Targets `<!-- BEGIN auto:{section} -->` block; preserves frontmatter outside the targeted field set. If `display_name` changed, triggers `rewrite-backlinks` (§2.6.3). |
| `append-to-narrative` | Filesystem append (under `flock`) | None | Lightweight; no Postgres update unless the narrative line crosses a boundary that changes `updated_at` materially. Decision_log row is the always-present audit trail. |
| `list-by-type-and-tenant` | Postgres `entities` indexed on `(tenant_slug, entity_type, status)` | Filesystem `readdir` of `wiki/compiled/{type}/` | Postgres returns refs sorted by `updated_at DESC` by default. Pagination via `limit + offset` or keyset on `(updated_at, id)`. |
| `semantic-search-over-raw` | **v1.2+ deferred** — placeholder primary = either cortextOS mmrag/ChromaDB **OR** IFOS-native pgvector over chunked raw/ content | n/a | ADR-002 will recommend keeping cortextOS's substrate available as the v1.2+ implementation option without committing to it now. |
| `backlinks` | Postgres `entity_links` reverse lookup (`entity_links_backlinks_idx` on `(tenant_slug, to_id)`) | Filesystem grep of `wiki/compiled/**/*.md` body for `[[Display Name]]` | Fallback exists because the Postgres index is *derived* from filesystem; if Postgres is missing rows, filesystem is authoritative. v1.1 Brain UI panel. |
| `entity-history` | Postgres `decision_log` SELECT by `(tenant_slug, entity_id)` ORDER BY `created_at DESC` | None | v1.1 read; v1.0 writes via `hh_decision_*`. No filesystem fallback — decision_log is unique source. |

**Special attention to `search-by-name`:** the trigram index on `entities.display_name` (PostgreSQL `pg_trgm` + GIN) handles fuzzy matching natively. Query: `SELECT id, display_name FROM entities WHERE tenant_slug = $1 AND entity_type = $2 AND display_name % $3 ORDER BY similarity(display_name, $3) DESC LIMIT 10;`. Sub-second on tables up to ~10M rows; the 100-customer × ~50k-candidates-each scale of v1.0 fits comfortably.

**Special attention to `backlinks`:** Postgres `entity_links` is primary, filesystem grep is the fallback. The fallback exists because wiki-links live in the markdown source; if Postgres is rebuilt from scratch (disaster recovery), the rebuild walks the filesystem and repopulates `entity_links`. The fallback is not a hot path — it runs at DR or at periodic reconciliation.

**No operation reads via grep at hot path.** All hot-path reads go through Postgres. Filesystem reads are the source-of-truth fallback for the rare unhealthy-Postgres case (which itself triggers the degraded-mode fallback per Ultraplan §3.5).

### 2.6 — Concurrency model

Master brief §5 is silent on concurrency. This entire section is a recommended default with one spec gap (**Spec gap 2.6**) covering all three scenarios.

#### 2.6.1 Two agents writing to the same entity

**Mechanism:** per-entity advisory `flock(2)` + Postgres-row optimistic concurrency.

- Each `update-entity` / `append-to-narrative` operation acquires `flock` on `wiki/compiled/{type}/{slug}.md.lock` (exclusive, blocking with 5-second timeout).
- Inside the lock: read the file, parse frontmatter, modify the targeted section, write atomically to `.md.tmp` then `rename(2)` over the original.
- Postgres update uses optimistic concurrency: `UPDATE entities SET frontmatter = $1, updated_at = now() WHERE tenant_slug = $2 AND id = $3 AND updated_at = $4` — `$4` is the `updated_at` value the agent read at the start of the operation. If the row count is zero, another agent committed in between; the operation re-reads, re-applies its change, and retries (max 3 times).
- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
- If the Postgres UPDATE fails after 3 retries, the operation fails with `ESC_VAULT_CONCURRENCY` (new code).

**Why both file lock and DB optimistic concurrency:** the file lock prevents body-content corruption (two agents writing different bytes to overlapping regions); the DB optimistic concurrency prevents semantic conflict (two agents each see version N, both compute version N+1, both write — the file lock serializes the writes but doesn't catch the semantic race). Both together give file-byte safety plus row-version safety.

**Concrete example (the carry-forward):**

- t=0: Concierge calls `append-to-narrative(candidate_sarah_bowen, "Sent follow-up email")`. Acquires `sarah_bowen.md.lock`. Reads file. Reads `updated_at = T0` from Postgres.
- t=0+50ms: Janitor calls `update-entity(candidate_sarah_bowen, "right_to_work_status", "verified")`. Blocks on the flock.
- t=0+300ms: Concierge releases flock after writing the narrative line and updating Postgres (`updated_at = T1`). The atomic file rename completes.
- t=0+301ms: Janitor acquires flock. Reads file (now contains Concierge's append). Reads Postgres (`updated_at = T1`). Computes new frontmatter. Writes file atomically. Postgres UPDATE `WHERE updated_at = T1` succeeds (`updated_at = T2`).
- No corruption; both changes land; decision_log captures both `hh_decision_output` rows separately.

#### 2.6.2 Agent writing while human is editing in Obsidian

This is the carry-forward concern from Batch 1 feedback. The risk is real and Obsidian-specific.

**Obsidian's actual behaviour** (well-established, not Obsidian-version-specific): Obsidian uses a filesystem watcher and detects external writes to open files. If the user has unsaved changes in the editor buffer and an external write occurs, Obsidian shows a **"File modified externally, reload?"** prompt with options reload-and-lose-edits / overwrite-with-mine / merge. This is a UX friction, not data corruption.

**Mechanism:**

1. **Hands-off frontmatter field** — every entity's frontmatter carries an optional `human_editing: true` flag the founder can set in Obsidian when they want a quiet window. While set, agent `update-entity` and `append-to-narrative` operations on this entity return `ESC_HUMAN_EDITING_LOCK` (new code) and re-queue with exponential backoff (1 min, 4 min, 16 min, then escalate to operator via Telegram). The flag is a soft handoff, not a hard guarantee — but it gives the founder explicit control during sensitive edits.
2. **Agent-write debounce** — agents writing to an entity check `lstat(2)` on the file just before the flock acquire; if the file's mtime is within the last 10 seconds (i.e. the human just saved), the agent waits 10 seconds and re-checks. This avoids the race-to-save pattern where the human saves at t=0 and the agent overwrites at t=0+50ms before Obsidian's watcher has reloaded.
3. **Obsidian's reload prompt is the safety net** — if a race somehow still occurs (e.g. agent writes during the human's typing), Obsidian will detect the external change and prompt. Data does not get lost silently; the human chooses what to do.
4. **No follow-rename collision** — agents do not use Obsidian's built-in rename feature (we don't have a UI). Rename happens via `update-entity` with a new `display_name`, which triggers `rewrite-backlinks` (§2.6.3). If the human renames a file in Obsidian during this window, the file-path-changes mid-cascade — the cascade detects the rename via the next-scan inotify event and aborts with `ESC_VAULT_RENAME_RACE` (new code), surfacing to the operator.

**Spec gap 2.6:** none of this is in the master brief. **Recommended resolution:** adopt the mechanism above verbatim; document in a `docs/architecture/vault-concurrency.md` companion file in Week 1 (before agent code starts). **Blocks v1.0 build:** no — concurrency code is a v1.0 build artefact, not a Week 0 prerequisite, but the design needs to land before the first multi-agent test in week 5.

#### 2.6.3 rewrite-backlinks cascade

**Mechanism: eventually-consistent, per-file optimistic concurrency, with Postgres as the source-of-truth for which rewrites are pending.**

When `update-entity` changes a `display_name`:

1. Postgres `entity_links` UPDATE sets `to_display_name = new_name WHERE to_id = $1` in one statement (transactional, atomic per the DB).
2. A list of affected files is materialised: `SELECT DISTINCT file_path FROM entities e JOIN entity_links l ON e.id = l.from_id WHERE l.to_id = $1`.
3. For each file in the list: enqueue a `rewrite-backlinks-task` to a Postgres-backed work queue (`pgmq` or a simple `tasks` table — Spec gap 2.6 sub-recommendation: use a simple Postgres queue, not a separate broker). Each task carries `(file_path, old_name, new_name, target_id)`.
4. A worker pool drains tasks: each task acquires the file's `flock`, performs the in-body substring rewrite, releases the lock. If the file is `human_editing: true` (per §2.6.2), the task re-queues with exponential backoff.
5. Tasks are idempotent — they search for `[[Type: old_name]]` and replace; if the substring isn't found (because someone else already rewrote, or the file was re-edited), the task is a no-op.

The cascade is NOT atomic across files. During a rename of "Sarah Bowen" → "Sarah Bowen-Smith":

- Postgres `entity_links` flips immediately (within ms).
- File body rewrites trickle through (seconds to a minute for a typical fanout of 3-15 backlink-holders).
- During the trickle window, a backlinks query returns the correct target id (because Postgres flipped) but a human reading raw markdown sees the old name. Acceptable trade-off — the wiki UI v1.1 reads from Postgres for backlinks, not from filesystem.

**Why not atomic across all files:** filesystems aren't transactional across files. Atomic-by-emulation (write all to `.tmp` then rename all) is brittle and doesn't compose with `flock`. Eventually-consistent with Postgres-as-truth is the realistic choice and matches master brief §3.3's "Postgres is the source of truth for state and provenance."

### 2.7 — Read/write pattern assumptions

v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).

**Hot operations (sub-second target):**

- `search-by-name` — Concierge inbound message processing; the customer-facing latency claim ("60-second response" per Product Spec §2.2 R1) depends on this returning in <100ms.
- `search-by-id` — every agent's startup context hydration. Hot but bounded — agents don't repeatedly read the same id.
- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.

**Cold operations (seconds-to-minutes acceptable):**

- `ingest-entity` — Janitor's nightly sweep ingests thousands of records; batching is the model. Per-record latency 100ms-1s is fine.
- `update-entity` — interactive but human-pace; few-hundred-ms is fine.
- `list-by-type-and-tenant` — typically called once at session start; pagination spreads the cost.
- `search-by-attribute` (v1.1) — Brief Decoder pre-shortlist generation; few-second budget acceptable.
- `entity-history` (v1.1 read) — Brain UI panel; few-second budget.

**Read:write ratio per agent (rough estimate, v1.0):**

| Agent | Reads:Writes | Why |
|---|---|---|
| Concierge | 20:1 | reads candidate state on every lifecycle event; writes only on event transitions |
| Scribe | 3:1 | reads candidate for context on every call; writes structured fields + tacit notes |
| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
| Sourcing Scout | 50:1 | reads briefs + candidate pool to filter; writes only shortlists |
| Janitor | 1:5 | reads each Bullhorn entity once; writes many cleanup updates per sweep |
| Diagnostic | N/A | doesn't touch the per-tenant vault |

**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.

**Peak concurrent tenants on shared infra (v1.0):** 3-6 (Product Spec §3 first three paid pilots target). The shared Postgres + RLS model (Ultraplan §5.1 line 226) handles this trivially.

**Decision-log volume:** every agent run produces 1-3 `decision_log` rows (`hh_decision_trigger`, `hh_decision_output`, optionally `hh_decision_action` when human responds). At 6 v1.0 agents × ~10 runs/agent/day × 3 tenants × 3 rows = ~540 rows/day per shared Postgres instance. Trivial volume; the table needs hash partitioning (per Ultraplan §5.1) primarily for query performance at v1.2+ scale, not v1.0 write throughput.

These assumptions inform §2.4 and §2.5: hot reads go through Postgres-indexed paths (trigram for fuzzy names, GIN for JSONB attributes, plain indexed columns for id/type lookups); write hot-paths use the atomic-file + Postgres-row pattern; pgvector is reserved for voice (low-latency-tolerant retrieval, not transactional) and stays out of the hot agent paths.

---

## Question 3 — How do agents call the second brain?

Three options, bounded by the prior decisions:

- **Q1.5:** cortextOS KB untouched. The wiki is a parallel system.
- **§1.7:** R2 renderer recommended → IFOS agents have no `.claude/skills/` tree by default.
- **§2.3:** 12 operations to expose.
- **§2.4:** four Postgres tables + pgvector voice index + filesystem markdown.
- **§2.6:** concurrency enforced via `flock(2)` + Postgres optimistic concurrency + Obsidian-aware debounce; new escalation codes `ESC_VAULT_*`.

### 3.1 — Restated options with post-design constraints

#### Option α — Shell-wrapper surface

```
packages/brain/
├── bus-overrides/
│   ├── wiki-search.sh           ← search-by-name
│   ├── wiki-get.sh              ← search-by-id
│   ├── wiki-links.sh            ← search-by-relationship + backlinks
│   ├── wiki-find.sh             ← search-by-attribute (v1.1)
│   ├── wiki-ingest.sh           ← ingest-entity
│   ├── wiki-update.sh           ← update-entity
│   ├── wiki-append.sh           ← append-to-narrative
│   ├── wiki-list.sh             ← list-by-type-and-tenant
│   ├── wiki-history.sh          ← entity-history (v1.1)
│   └── wiki-archive.sh          ← v1.2+ placeholder
├── wiki-cli/
│   └── src/cli.ts               ← commander-based dispatcher; one subcommand per op
└── wiki/
    └── lib/
        ├── ingest.ts            ← filesystem-atomic-write + Postgres UPSERT
        ├── update.ts            ← flock + optimistic concurrency + rewrite-backlinks
        ├── search.ts            ← trigram + GIN
        ├── append.ts            ← flock + append
        ├── list.ts              ← Postgres SELECT
        ├── backlinks.ts         ← entity_links reverse lookup
        ├── history.ts           ← decision_log SELECT
        ├── concurrency.ts       ← flock wrapper + ESC_VAULT_* mapping
        └── frontmatter.ts       ← YAML parse + Obsidian-safe write
```

Each `wiki-*.sh` is a thin shim execing `node ${SCRIPT_DIR}/../wiki-cli/dist/cli.js <op> "$@"`. Pattern matches cortextOS's 47-script `bus/` layout verbatim (see `packages/harness/cortextos/bus/send-message.sh:22`). Agent invocation from inside PTY:

```bash
cortextos-ifos bus wiki-search "Sarah Bowen" --type candidate --tenant acme
```

Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.

#### Option β — MCP server

```
packages/brain/
├── wiki-mcp/
│   ├── src/server.ts            ← stdio or TCP MCP server
│   ├── src/tools/                ← one .ts per MCP tool exposed
│   │   ├── wiki-search.ts
│   │   ├── wiki-ingest.ts
│   │   └── ... (12 tools)
│   └── ecosystem.config.js      ← PM2 entry (ifos-wiki-mcp process)
└── wiki/lib/                    ← shared logic — same library Option α uses
```

A long-running PM2-managed process (`ifos-wiki-mcp`) alongside `cortextos-daemon` and `ifos-dashboard`. Agents connect via `tools.yaml`:

```yaml
mcp_servers:
  wiki:
    command: cortextos-ifos-wiki-mcp
    args: ["--tenant", "${CTX_TENANT_SLUG}"]
tools:
  - wiki.search
  - wiki.get
  - wiki.ingest
  - wiki.update
  - wiki.append
  - wiki.list
  - wiki.backlinks
  - wiki.history
```

Concurrency mechanisms live inside the server process. Audit logging via decision_log + an internal request log. Tenant scoping validated at server entry: the `CTX_TENANT_SLUG` from the agent's environment is the authoritative tenant; any tool call carrying a mismatched `tenant_slug` is rejected before reaching the library.

#### Option γ — Claude Code skill + library

```
packages/brain/
├── wiki-skill/
│   └── SKILL.md                 ← documents the wiki API as a Claude Code skill
└── wiki/lib/                    ← Node library agents call directly
```

Skill installed into each agent's `.claude/skills/wiki/` at scaffold time. Agents read the SKILL.md as part of their context and invoke wiki ops via the documented usage pattern (typically by calling the library via `node -e` or a thin per-skill script).

**Critical constraint from §1.7:** if R2 wins (recommended renderer design — bundle-only, no `.claude/skills/` tree copied), the skill installation path **does not exist by default**. The renderer would have to be modified to inject the wiki skill specifically, contradicting R2's "no inherited skills" promise. **Option γ is operationally awkward under R2.** Under R1 (bundle-on-top-of-cortextos-template, NOT recommended), γ is operationally cheap but inherits the 24-skill default-on tax along with it.

### 3.2 — Rubric evaluation

| Criterion | Option α | Option β | Option γ |
|---|---|---|---|
| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
| **Operational complexity** — new infrastructure introduced | None new. 12 shell wrappers + a Node CLI binary + a library; same shape as `packages/harness/cortextos/bus/`. No new PM2 process. | One new PM2 process per machine (`ifos-wiki-mcp`). Adds to the operations surface: process supervision, restart policy, port allocation, logs to manage. At Sovereign tier (one cluster slice per tenant per Ultraplan §5.4) this is one extra process per tenant. | Skill files added to every agent at scaffold time. Under R2 renderer (recommended), the renderer must be extended to inject the wiki skill — additional renderer logic. Under R1, automatic. |
| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
| **v1.0 minimum effort estimate** | ~11-13 days. Breakdown: 12 wrappers × 0.25 day = 3 days; Node CLI + dispatch = 1 day; library (12 ops, concurrency, frontmatter parse/write) = 4-5 days; Postgres migrations = 1 day; pgvector voice integration = 1 day; concurrency tests = 1-2 days. | ~14-17 days. Adds: MCP server scaffolding + tool registration + JSON-RPC handling + PM2 integration + multi-tenant connection-identity validation. The library effort is the same; the server adds ~3-4 days. | ~9-11 days **IF R1**. Under R2, **probably impossible without renderer changes** — adds ~5 days for renderer modification + skill injection logic + per-agent install path. Total under R2: ~14-16 days, **and** undermines R2's clean-separation promise. |
| **Failure mode if cortextOS daemon is unhealthy** | Wrappers don't depend on the daemon — they exec directly into Node. As long as Postgres is up and the filesystem is mounted, wiki ops succeed. Decision_log writes still go through (Postgres direct). Tracks per Ultraplan §3.5 "Tier 1 agents have degraded-mode fallbacks" — the wiki is part of the fallback substrate, not part of what fails. | If `ifos-wiki-mcp` crashes, every agent loses wiki access until it restarts. PM2 auto-restart bounds the outage to ~5s, but during the outage every wiki call fails. If `cortextos-daemon` is unhealthy, MCP connections from agents (which are in PTYs supervised by the daemon) may also be affected. Two-process dependency. | Same as α (library invoked directly, no daemon dependency) but adds skill-discovery path: if the agent's Claude Code session can't find the skill (e.g. corrupted scaffold), all wiki ops fail. |
| **Lock-in cost** — how hard to switch to a different option later | Low. Wrappers are 3-line shims; replace with calls to a different backend (MCP server, library) by changing the `exec` line. Library is reusable. Agents see the same `cortextos-ifos bus wiki-search` invocation regardless of backend — interface stable. | Medium. Agents have MCP `tools.yaml` entries committed; migration to α means rewriting `agent.md` and `tools.yaml` for every agent (18 in full strength per master brief §0). Library is reusable. | High. Skill-installation path is per-agent; migration requires per-agent skill removal + new wrapper/MCP declaration. Also under R2 the original installation path was a hack, which makes "switch away from γ" the cleanup of that hack. |

### 3.3 — Recommendation

**Recommend Option α — shell-wrapper surface.**

The recommendation wins on **operational complexity** (no new PM2 process), **failure-mode robustness** (no daemon dependency for wiki access), **bus-convention consistency** (matches 47 existing bus wrappers verbatim), **agent ergonomics under R2** (no `tools.yaml` entry per agent; just bus invocations), and **lock-in cost** (3-line shims are trivially replaceable).

**Rationale anchored to three master brief sections:**

1. **Master brief §3.1 (submodule boundary).** The §3.1 exception is "shadow four `bus/kb-*.sh` points." Per Q1.5 we don't shadow those — but the **pattern** §3.1 authorises (parallel `bus-overrides/` directory housing shell wrappers that match cortextOS's bus convention) is exactly what Option α uses. We use the boundary's *vocabulary* without exercising its kb-* exception. Option β would require introducing a new vertical surface (MCP server alongside daemon and dashboard) that §3.1 doesn't anticipate. Option γ would require modifying the renderer's skill-installation path, contradicting §1.7's R2 recommendation.
2. **Master brief §8 (Agent Bundle v2 pattern + `tools.yaml` contract).** §8.1 specifies the bundle has `tools.yaml` for "MCP servers + scopes + degraded modes" — i.e. external MCP connectors (Bullhorn, Companies House, Xero). The wiki is **internal** to IFOS, not an external execution backend. Treating wiki ops as bus commands (Option α) keeps `tools.yaml` clean of internal-surface declarations; treating them as MCP tools (Option β) conflates internal-data-access with external-tool-invocation in the same `tools.yaml`.
3. **Master brief §3.5 + §5.5 (multi-tenancy + onboarding wizard 5-day flow).** §3.5's "100 customers by end of 2027" stress test (Product Spec §5.4) demands zero per-customer operational drag. Option α adds no per-customer infrastructure. Option β at Sovereign tier (Ultraplan §5.4 per-tenant cluster slice) means one `ifos-wiki-mcp` process per Sovereign tenant — a new operational surface to monitor at scale.

**What's lost relative to Option β:**

- **Typed RPC.** Shell-stdio + JSON-stdout is less elegant than typed MCP tool calls. Mitigation: the Node CLI's `commander`-defined options give typed argument validation; outputs are JSON; this is comparable to typed RPC at the surface most agents care about.
- **Persistent server state.** Option β's long-running process could cache hot reads, hold prepared statements, maintain pgvector connection pools. Option α pays a fresh Node startup per call (~80-200ms). For v1.0 expected volume (Concierge ~10 lifecycle events/day per tenant × 3 tenants × 5 wiki reads each = 150 calls/day per machine), the cumulative startup cost is ~30 seconds/day. Acceptable. **If hot-path latency becomes a constraint at v1.2+**, we can introduce a persistent CLI daemon (`wiki-cli --daemon`) that pre-warms — a future optimisation without changing the agent surface.
- **Streaming.** Not a v1.0 need; if ever needed, add an `wiki-stream-*.sh` wrapper with line-delimited JSON output. No interface change for existing ops.

**What's lost relative to Option γ:** the deep Claude-Code-native skill-discovery experience. Under R2 (recommended renderer), this path is operationally awkward anyway, so the loss is theoretical.

**Forward compatibility:**

- **v1.2 graph view (master brief §5.5):** add `wiki-graph-traverse.sh` and a `graphify` subcommand. Surface grows by N scripts, not by architecture.
- **v2.0 LoRA scale (master brief §5.5):** the LoRA pipeline operates on the `decision_log` table, not on the wiki. Wiki ops from LoRA-enhanced agents are unchanged. Both options work.
- **v1.2+ semantic-search-over-raw:** ADR-002 will recommend keeping this hook open. Under Option α, the eventual implementation is a `wiki-semantic-search.sh` that internally chooses either cortextOS's mmrag (the v1.2+ option) or an IFOS-native pgvector-over-raw index — no agent-side change.

**v1.0 build day estimate for Option α: 11-13 days.** Fits master brief §5.5's weeks 11-13 allocation. Detail in §3.4 below.

### 3.4 — Impact on master brief §5.5 build sequence

Master brief §5.5 currently says (lines 416-420):

> v1.0 minimum (weeks 11-13) — `bus-overrides/kb-*.sh` shadow + `wiki/lib/{ingest,search}.ts` — agents can write and search but no UI yet

**Per the design, this wording needs to change.** Three substantive shifts:

| Master brief §5.5 wording (current) | Proposed wording (post-design) |
|---|---|
| "bus-overrides/`kb-*.sh` shadow" | "bus-overrides/`wiki-*.sh` parallel surface (9 wrappers v1.0 + 1 v1.1 stub)" |
| "`wiki/lib/{ingest,search}.ts`" | "`wiki/lib/{ingest,update,search,append,list,backlinks,history,concurrency,frontmatter}.ts` (9 files) + `wiki-cli/src/cli.ts` dispatcher" |
| Implied: cortextOS KB is the substrate | Explicit: parallel system. cortextOS KB untouched, IFOS owns Postgres entities/links/decision_log + pgvector voice + filesystem markdown |

**Build sequence (weeks 11-13):**

- **Week 11:** Postgres migrations + RLS tests; library scaffolding; `wiki/lib/{ingest,update,search,list}.ts`; one happy-path fixture per op. **Renderer (ADR-003) must be live by start of week 11** so agents can actually be scaffolded against the wiki API.
- **Week 12:** `wiki/lib/{append,backlinks,history,concurrency}.ts`; the 9 shell wrappers; CLI dispatcher; integration tests against a multi-tenant Postgres fixture. Concurrency tests (the `flock` + optimistic concurrency + Obsidian human-editing scenarios from §2.6).
- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.

**Work that must land before week 11** (Week 1+ prerequisites):

1. **Renderer design (ADR-003, Spec gap §1.7).** Without it, no IFOS agent can run. **Week 1.**
2. **Companion document `docs/architecture/vault-concurrency.md` (Spec gap 2.6 resolution).** Documents the concurrency mechanism so concurrency code in `wiki/lib/concurrency.ts` is reviewable. **Week 1-2.**
3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**

**Does the v1.0 brain build shift in scope or timing?**

- **Scope:** larger than master brief §5.5 currently states (9 ops + 4 Postgres tables + concurrency machinery, vs. the original "2 ts files"). Still fits the 11-13 day budget because the bulk of the surface area is small Postgres operations with thin shell wrappers; the heavy code is in `concurrency.ts` and `update.ts` which together are ~400-600 lines.
- **Timing:** weeks 11-13 still hold, **provided** the Week 1 prerequisites (renderer, concurrency document, shared helpers) land on time.
- **Earlier work needed:** Postgres schema and the entity_graph→entities+entity_links rename move to Week 0 Day 4 (this week, already planned per master brief §6).

---

## Spec gaps surfaced during design — consolidated

| ID | Where | What's missing | Recommended resolution | Blocks v1.0? |
|---|---|---|---|---|
| **§1.7-A** | Master brief §8 silent on renderer | No mechanism for translating the IFOS Agent Bundle v2 layout (`${repo}/agents/recruitment/<name>/`) into the cortextOS-shaped per-agent directory the daemon reads from (`${projectRoot}/orgs/<org>/agents/<name>/`) | ADR-003 in Week 1 + companion `docs/architecture/agent-bundle-renderer-design.md`. Adopt R2 (bundle-only, no `.claude/skills/` tree). | **Yes** — without it, no IFOS agent can run. Week 1 prerequisite. |
| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
| **2.1-B** | `_decisions/` directory (Ultraplan §5.1) overlapping with Postgres `decision_log` table | Two candidates for "where agent history lives" | Resolved in §2.4.2: `_decisions/` is for founder-written end-of-quarter narratives only; agent decisions live exclusively in Postgres `decision_log`. Update Ultraplan §5.1 wording. | No |
| **2.1-C** | `wiki/compiled/playbooks/` (master brief §5.1 line 331) collides with `/vault/{tenant}/_playbooks/` (Ultraplan §5.1) | Same folder name at two paths with different intended uses | **Recommendation:** drop `wiki/compiled/playbooks/`. Playbooks live at `/vault/{tenant}/_playbooks/` only. Update master brief §5.1 to remove the `playbooks/` line from the `wiki/compiled/` tree. | No |
| **2.2-A** | Master brief §5 silent on rename safety | No mechanism for keeping wiki-links stable when an entity's display_name changes | Resolved in §2.6.3: `update-entity` triggers eventually-consistent `rewrite-backlinks` cascade with Postgres as truth, per-file optimistic concurrency. Documented in companion vault-concurrency.md. | No |
| **2.2-B** | Master brief §5.1 lines 325-332 silent on filename format under each directory | No file-naming convention specified | Resolved in §2.2.7: `{slug}.md` where slug = id minus entity-type prefix; numeric suffix for collisions. | No |
| **2.4-A** | Master brief / Ultraplan silent on git for tenant vault | No backup-via-git mechanism specified | `git init` at tenant provisioning (`provision-tenant.sh` Ultraplan §5.5 step 2). Founder commits via Obsidian Git plugin; agents don't commit. | No — commit cadence can be decided Week 1+. |
| **2.4-B** | Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`" | Single-table model insufficient for the JSONB GIN + trigram + adjacency mix v1.0 needs | Split into `entities` + `entity_links` per §2.4.2. Update master brief §3.3 / Ultraplan §5.1 wording. **Roll into Week 0 Day 4 Postgres provisioning.** | **Tight** — Day 4 of Week 0 (this week). |
| **2.4-C** | Master brief / Ultraplan silent on embedding model | No model specified for voice_samples_embedded or future compiled/ embeddings | Adopt `gemini-embedding-001` (3072 dims) — matches cortextOS's KB substrate per kb-setup.sh migration target. Same `GEMINI_API_KEY` serves both. Revisit if a sharply better model ships before Week 11. | No |
| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` lands Week 1-2. New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. | No — needs to land before Week 5 multi-agent test. |
| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |

**Five gaps are already resolved inline in this design** (2.1-B, 2.1-C, 2.2-A, 2.2-B, 2.6 with mechanisms in §2.6.x). **Three need master-brief / Ultraplan edits in the atomic correction commit** (2.1-A wording reconciliation, 2.4-B / 3.4-B Postgres table-rename, 3.4-A v1.0 brain wording rewrite). **Two are Week-1 prerequisite artefacts** (§1.7-A renderer ADR-003 + `agent-bundle-renderer-design.md`; 2.6 companion `vault-concurrency.md`). **Two are operational defaults** that the founder can either ratify or override at any later point (2.4-A git init at provisioning; 2.4-C `gemini-embedding-001` model choice).

## Impact on master brief §5.5 build sequence — closing paragraph

**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.

End of design.
