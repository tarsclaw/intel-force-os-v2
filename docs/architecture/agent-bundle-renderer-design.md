# IFOS Agent Bundle v2 renderer — design specification

**Date:** 2026-05-16 (Week 0, Day 1 evening — Week-1-prerequisite pull-forward)
**Status:** Design specification (not a decision record). Recommendations become binding via ADR-003.
**Surfaced by:** `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §"For Week 1 work" — declared the renderer the load-bearing Week-1 prerequisite.
**Prior work referenced:** master brief §8 (bundle spec); `docs/architecture/second-brain-design.md` §1.7 (R2 inheritance recommendation); `docs/architecture/cortexos-primitive-status.md` Primitive 1 (PTY/PM2 spawn mechanism).
**Submodule SHA audited:** `c21fbfe991a0030ea055bd8e2389a0801a424383`

**Reading order:** ADR-002 first, then this design, then ADR-003.

---

## Section 1 — What we're translating from and to

### 1.1 — Source: IFOS Agent Bundle v2 layout

Master brief §8 (lines 545-568) specifies the bundle verbatim:

```
agents/recruitment/{agent-name}/
├── README.md                           # 2-min overview for humans
├── agent.md                            # Output contract FIRST, then workflow, gates, escalation
├── config.schema.json                  # Per-tenant config (extends common-*.json)
├── tools.yaml                          # MCP servers + scopes + degraded modes
├── validate.sh                         # Gate A — sources _shared/hook-helpers.sh
├── context.sh                          # Hydrates CONTEXT via context-assembly API
└── tests/
    └── fixtures/
        ├── 01-primary/                 # Happy path. The demo example.
        │   ├── input.json
        │   └── expected.md
        ├── 02-edge-case-{name}/        # ≥1 required.
        │   ├── input.json
        │   └── expected.md
        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
            ├── input.json
            └── expected.md
```

| File / directory | Contents | Downstream reader | Static vs dynamic |
|---|---|---|---|
| `README.md` (line 551) | 2-minute human overview of what the agent does and how it ships value | humans (PRs, code review, on-call); not read at runtime | **Static** — founder writes once per agent |
| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
| `config.schema.json` (line 553) | Per-tenant JSON Schema, extending `common-*.json` shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) | the renderer (materialises to `config.json` per §2.1); per-tenant onboarding wizard at Product Spec §5.2 Day 4 fills schema fields | **Static schema; dynamic materialisation** per tenant |
| `tools.yaml` (line 554) | MCP servers + scopes + degraded modes for external execution backends (Bullhorn, Companies House, Microsoft Graph etc. per master brief §3.2 first-party MCP list) | the renderer (passes through to rendered agent dir); agent uses it via Claude Code's MCP loading at PTY spawn time | **Static** — founder writes once per agent |
| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
| `tests/fixtures/01-primary/` (line 559) | Happy-path input.json + expected.md. The demo example. | CI fixture runner (master brief §8.3 line 628 "Test against fixtures"); not read at runtime | **Static** — author once, regenerate `expected.md` after intentional behaviour changes |
| `tests/fixtures/02-edge-case-{name}/` (line 562) | At least one edge case. From workflow analysis. | CI fixture runner | **Static** — same as 01 |
| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |

**Spec gaps in §1.1:**

- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.

### 1.2 — Target: cortextOS-shaped per-agent directory

cortextOS's daemon discovers and starts agents from a specific layout. Verified against SHA `c21fbfe`:

**Discovery mechanism** (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`):

```typescript
private discoverAgents(): Array<{ name: string; dir: string; org: string; config: AgentConfig }> {
  // line 909: orgsBase = join(this.frameworkRoot, 'orgs');
  // line 921-934: for each org dir, list agents/<name>/ subdirs, loadAgentConfig per dir
}
```

The daemon scans `${frameworkRoot}/orgs/{org}/agents/{name}/`. Each `<name>` subdirectory is an agent. No manifest file is required — directory presence is the registration. `${ctxRoot}/config/enabled-agents.json` (line 82) is read to honour explicit enable/disable choices but is not required for discovery — agents not listed default to enabled (line 86 fallback `{}`).

**Required files** (from cortextOS source line cites):

| File | Required? | Read by | Cite |
|---|---|---|---|
| `config.json` | **Practically required** | `loadAgentConfig` at line 946-956 returns `{}` if missing, so technically optional. But fields drive behaviour: `enabled` (line 59), `runtime` (line 117 of agent-process.ts), `model`, `max_session_seconds` (255600 = 71h default per agent-process.ts:598), `working_directory`, `telegram_polling` (line 315), `max_crashes_per_day`, `startup_delay`, `timezone`, `ctx_warning_threshold`, `ctx_handoff_threshold` | `agent-manager.ts:946-956` + `agent-process.ts:597-639` |
| `CLAUDE.md` or `AGENTS.md` | **Practically required** | Claude Code's session-start protocol reads `CLAUDE.md` in the agent's working directory. Without it, the agent boots into a Claude Code session with no IFOS context. Daemon doesn't read it directly. | `agent-pty.ts:146-152` spawns `claude` binary in `cwd = config.working_directory \|\| agentDir \|\| process.cwd()` (line 63); Claude Code's discovery is downstream of that |
| `.env` | Required iff Telegram is enabled for this agent | `agent-manager.ts:202-243` reads `BOT_TOKEN`, `CHAT_ID`, `ALLOWED_USER`; `agent-pty.ts:100-111` sources the rest into the PTY environment | `agent-manager.ts:208-211`, `agent-pty.ts:100-111` |
| `goals.json` | Optional — created with empty placeholder by `add-agent.ts:131-140`; agent-process.ts doesn't strictly require it | The agent itself reads it via its own bootstrap protocol (cortextOS template CLAUDE.md instructs the agent to read GOALS.md / goals.json) | Not daemon-read |
| `IDENTITY.md`, `SOUL.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md` | Optional — cortextOS templates ship them and instruct the agent to read them via session-start protocol | The agent itself, never the daemon | `agent-pty.ts` does not parse these |
| `.claude/skills/` | Optional — cortextOS templates ship 24 skills here (per `docs/architecture/second-brain-design.md` §1.7) | Claude Code's skill discovery at session start | Daemon-agnostic |

**Optional but daemon-aware paths:**

- `${ctxRoot}/state/{name}/crons.json` — daemon's `CronScheduler` reads cron definitions from this path, NOT from the agent directory (per `CRONS_MIGRATION_GUIDE.md` and CHANGELOG 0.2.0). Created lazily by `cortextos bus add-cron`.
- `${ctxRoot}/state/{name}/heartbeat.json`, `.daemon-stop`, `.daemon-crashed`, `.force-fresh`, `.handoff-doc-path` — runtime state markers, daemon-managed, not part of scaffold.
- `${ctxRoot}/logs/{name}/{stdout,stderr,activity,restarts}.log` — daemon writes; not part of scaffold.

**Env vars surfaced to the PTY** (`agent-pty.ts:66-78, 113-137`):

`CTX_INSTANCE_ID`, `CTX_ROOT`, `CTX_FRAMEWORK_ROOT`, `CTX_AGENT_NAME`, `CTX_ORG`, `CTX_AGENT_DIR`, `CTX_PROJECT_ROOT`, plus backward-compat `CRM_AGENT_NAME` and `CRM_TEMPLATE_ROOT`. Optional based on tenant config: `CTX_TELEGRAM_CHAT_ID`, `CTX_TIMEZONE`, `TZ`, `CTX_ORCHESTRATOR_AGENT`.

**PTY spawn invariant:** `agent-pty.ts:144-152` spawns the `claude` binary with `cwd = config.working_directory || agentDir`. The agent boots into Claude Code with the rendered agent directory as its working directory.

### 1.3 — The translation problem in one paragraph

The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.

---

## Section 2 — Translation contract

### 2.1 — File-by-file mapping

Every file from §1.1 to every file at §1.2's target.

| IFOS source | cortextOS target | Transformation | Synthesis inputs | Verification |
|---|---|---|---|---|
| `agents/recruitment/<name>/agent.md` | `orgs/<org>/agents/<name>/CLAUDE.md` | **Synthesis** | (1) `agent.md` body verbatim; (2) **cortextOS preamble template** — spec gap §2.1-A; (3) per-tenant footer (resolved tenant_slug, current `_voice/style-guide.md` path, decision_log Postgres role); (4) hook invocation block referencing `.claude/hooks/{validate,context}.sh` paths | Lint pass: no unresolved `{{tenant_slug}}` / `{{...}}` placeholders survive; preamble matches the renderer's canonical preamble version (hash check); CLAUDE.md is non-empty and parses as valid markdown |
| `agents/recruitment/<name>/config.schema.json` | `orgs/<org>/agents/<name>/config.json` | **Synthesis** | (1) `config.schema.json` (the JSON Schema itself, used for validation); (2) `/vault/{tenant-slug}/_config.yaml` per Ultraplan §5.1 line 220 (provides per-tenant values that fill schema fields); (3) bundle-level defaults from any `default` keys in the schema; (4) common-*.json shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) — spec gap §2.1-B on where common schemas live | Materialised JSON validates clean against the source schema using Ajv (or equivalent) before the renderer writes; required fields all populated; no extra fields beyond schema. Daemon-required fields (per §1.2): `enabled` defaults true, `runtime` defaults `claude-code`, `max_session_seconds` defaults 255600, `working_directory` defaults to the rendered agent dir |
| `agents/recruitment/<name>/tools.yaml` | `orgs/<org>/agents/<name>/tools.yaml` | **Passthrough** | None (verbatim) | YAML parses; declared MCP servers correspond to entries in the credentials map used for `.env` synthesis (see next row) |
| `agents/recruitment/<name>/validate.sh` | `orgs/<org>/agents/<name>/.claude/hooks/validate.sh` | **Verbatim copy** | None | `chmod 0755` on write; the script's `source` paths resolve (i.e. `.claude/hooks/_shared/hook-helpers.sh` exists at write time per §1.1-B) — spec gap §1.1-A flagged; renderer's choice of `.claude/hooks/` is the resolution |
| `agents/recruitment/<name>/context.sh` | `orgs/<org>/agents/<name>/.claude/hooks/context.sh` | **Verbatim copy** | None | Same as `validate.sh`: `chmod 0755`; `source` paths resolve |
| `agents/recruitment/<name>/README.md` | `orgs/<org>/agents/<name>/README.md` | **Verbatim copy** | None | Non-empty |
| `agents/recruitment/<name>/tests/fixtures/{01-primary,02-edge-case-*,99-voice-drift-canary}/` | **Not rendered** | **Stays in source** | n/a | n/a — fixtures live in the IFOS repo at `agents/recruitment/<name>/tests/fixtures/`; CI fixture runner (master brief §8.3 line 628) reads them there; runtime does not need them |
| _(no IFOS source)_ | `orgs/<org>/agents/<name>/.env` | **Synthesis** | (1) `tools.yaml` MCP server list (declares which credentials are needed: `BULLHORN_OAUTH_TOKEN`, `MS_GRAPH_TOKEN`, etc.); (2) `/vault/{tenant-slug}/_secrets.env` — spec gap §2.1-C (Ultraplan §5.1 doesn't enumerate this file but it's the natural place for per-tenant credentials); (3) the agent's per-bot Telegram credentials from the same secrets file (`BOT_TOKEN`, `CHAT_ID`, `ALLOWED_USER`) per cortextOS Primitive 5 contract | All MCP server tokens declared in `tools.yaml` resolve to a non-empty value; `BOT_TOKEN` matches `/^\d+:[A-Za-z0-9_-]+$/` per `agent-manager.ts:218`; `ALLOWED_USER` is numeric per `agent-manager.ts:224`; file written `chmod 0600` (credentials) |
| _(no IFOS source)_ | `orgs/<org>/agents/<name>/goals.json` | **Synthesis (empty placeholder)** | None | Materialised as `{ "focus": "", "goals": [], "bottleneck": "", "updated_at": "", "updated_by": "" }` per `add-agent.ts:131-140`. Rationale: cortextOS's analyst / orchestrator workflows may read this file via their own bootstrap; absent it, some cortextOS skills throw. Cost of creating it is zero. Per Q1.5 / §2.2 below, IFOS agents do NOT invoke those skills, so the file is dead weight — but harmless dead weight that maintains daemon-side compatibility |
| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
| _(no IFOS source — cortextOS templates ship 24 skills)_ | `.claude/skills/{activity-channel, agent-browser, ..., worker-agents}` (24 dirs) | **Drop** | n/a | n/a — the R2 commitment per design §1.7 + ADR-002 Decision 1. Detailed itemisation in §2.2 below |

**Spec gaps surfaced in §2.1:**

- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
- **§2.1-C:** Ultraplan §5.1 line 220 names `_voice/`, `_playbooks/`, `_decisions/`, `_config.yaml` under `/vault/{tenant}/` but does not enumerate `_secrets.env`. Recommended resolution: add `_secrets.env` to the per-tenant vault skeleton; created at tenant provisioning (Ultraplan §5.5 line 263 `provision-tenant.sh {slug}` step 2). Mode `0600` owned by `ifos-tenant-{slug}`. Per Master Brief §3.3 "structured data lives in Postgres" applies to entity data; per-tenant *secrets* are the canonical exception that lives on the filesystem.

### 2.2 — What's NOT inherited (the R2 commitment)

**The renderer does NOT copy `packages/harness/cortextos/templates/agent/.claude/skills/`.** None of the 24 cortextOS-template skills land in the IFOS agent's rendered directory.

Justification anchored to:

- **ADR-002 Decision 1** — cortextOS KB stays untouched; IFOS agents don't call `kb-*`. Inheriting `knowledge-base` and `memory` skills would mean IFOS agents have on-disk documentation telling them to invoke commands that, per ADR-002, they must not invoke.
- **Master brief §1 Rule 3 (Reuse before build)** — "Every agent uses `agents/_shared/` modules… No agent writes its own logging, voice handling, or approval gate." `_shared/` is the IFOS reuse surface. Inheriting a parallel reuse surface (cortextOS's `.claude/skills/`) creates two reuse vocabularies — confusing and error-prone.
- **Master brief §3.1 (submodule boundary stays intact)** — the §3.1 exception for the four `bus/kb-*.sh` shadow points is already a dead clause per ADR-002. Inheriting cortextOS skills would introduce a new implicit "shadow" — IFOS agents would carry skill documentation that points back into cortextOS's surface — undoing the cleanliness ADR-002 established.

**Per-skill inheritance gap — the five highest-stakes:**

| cortextOS skill | What it does in cortextOS | IFOS equivalent |
|---|---|---|
| `knowledge-base` | Calls `kb-query` / `kb-ingest` / `kb-collections` / `kb-setup` against cortextOS's mmrag/ChromaDB KB | IFOS uses `wiki-*` parallel bus wrappers against `/vault/{tenant}/wiki/` + Postgres `entities` / `entity_links` per ADR-002 Decision 2 and design §2.3 / §2.4 |
| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
| `approvals` | cortextOS's per-action approval-gate skill — agent creates an approval entry, blocks until human resolves via Telegram inline buttons | IFOS uses the same primitive 4 approval gates (cortextOS primitive — `src/bus/approval.ts`), but the approval *categories* and *escalation routing* are declared in `tools.yaml` + `agent.md` per master brief §3.2, not via inherited skill documentation |
| `tasks` | cortextOS task management — `create-task` / `update-task` / `complete-task` against the `orgs/{org}/tasks/` directory | IFOS uses Postgres `decision_log` for the "what did this agent do" trail and the wiki for the "what's the state of this entity" view. The cortextOS task store is unused by IFOS agents (parallel to the KB-untouched decision per ADR-002 Decision 1) |
| `heartbeat` | cortextOS heartbeat cadence — periodic `update-heartbeat` writes to `${ctxRoot}/heartbeats/{name}.json` so the dashboard sees "alive" status | IFOS agents emit heartbeats too (the daemon's fast-checker writes them per `agent-process.ts:597-639` session timer), but the *cadence* and *what the agent does at each heartbeat* is specced per-agent in `agent.md` (Concierge always-on; Janitor cron-driven; etc.). The cortextOS-template `heartbeat/SKILL.md` is a default playbook — IFOS replaces with per-agent specifics |

**The remaining 19 cortextOS skills also not inherited by default:**

`activity-channel`, `agent-browser`, `agent-management`, `auto-skill`, `autoresearch`, `bus-reference`, `comms`, `cron-management`, `env-management`, `event-logging`, `guardrails-reference`, `human-tasks`, `m2c1-worker`, `onboarding`, `soul-philosophy`, `system-diagnostics`, `tool-registration`, `worker-agents` — 18 above, plus the `memory-management` skill referenced from `agent/.claude/skills/onboarding/SKILL.md:42` that I haven't catalogued individually.

The blanket position: **per-skill opt-in is deferred to per-agent bundle authoring.** Each IFOS bundle's `tools.yaml` may reference cortextOS-template skills it wants to inherit explicitly; the renderer reads the opt-in list, materialises only those skills into `.claude/skills/<name>/` in the rendered output, and copies the source `SKILL.md` from `packages/harness/cortextos/templates/agent/.claude/skills/<name>/`. **Default is exclusion. Opt-in is the only mechanism.** This is the structural opposite of `cortextos-ifos add-agent`, which default-includes all 24.

**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:

```yaml
cortextos_skills:
  - bus-reference     # agent needs the cortextos bus CLI cheat-sheet
  - comms             # agent needs the Telegram message format reference
```

Renderer reads this; copies named skills only; emits a Codex-ratifiable diff for each opt-in (since each one is a §3.1 boundary-near decision).

### 2.3 — Worked example: rendering Concierge (A6)

Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.

#### (a) Source bundle layout — `agents/recruitment/concierge/`

```
agents/recruitment/concierge/
├── README.md
├── agent.md
├── config.schema.json
├── tools.yaml
├── validate.sh
├── context.sh
└── tests/fixtures/
    ├── 01-primary/
    ├── 02-edge-case-rejection-tone/
    └── 99-voice-drift-canary/
```

**`README.md` (10 lines abbreviated):**

```markdown
# Concierge

Tier-1 always-on candidate-lifecycle agent. No candidate ghosted, no client
check-in missed, every comms in firm voice.

## Output contract
Every lifecycle event → draft within 30 minutes, voice score ≥ 0.75, correct
addressee resolution. See agent.md.

## Build wave: v1.0 weeks 10-13
```

**`agent.md` (frontmatter + first 15 body lines abbreviated):**

```markdown
---
agent: concierge
tier: 1
build_wave: v1.0
output_contract: |
  Every lifecycle event for an active candidate produces a drafted comm
  within 30 minutes in firm voice (classifier score ≥ 0.75), addressed to
  the correct recipient resolved via wiki-search.
voice_anchors:
  - "_voice/style-guide.md"
  - "_voice/samples (3 nearest neighbors via voice-loader)"
gate_a_checks:
  - banned_phrase_check
  - length_bounds_check
  - voice_classifier_score >= 0.75
  - schema_check
  - pii_boundary_check
escalation_codes:
  - ESC_VOICE_DRIFT
  - ESC_PII_LEAKAGE_RISK
  - ESC_DUPLICATE_DETECTED
---

# Concierge — agent definition

## Workflow

On every ATS state change (Bullhorn webhook) or scheduled lifecycle event
(cron-driven nurture sweep):

1. Resolve candidate via `wiki-get` by candidate_id from the webhook payload
2. Resolve client via `wiki-get` by client_id
3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
   --task-type candidate-{event-type}` + `hh_load_recent_edits`
...
```

**`config.schema.json` (abbreviated to schema skeleton):**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Concierge per-tenant configuration",
  "allOf": [
    { "$ref": "common-voice.json" },
    { "$ref": "common-notifications.json" },
    { "$ref": "common-ats.json" }
  ],
  "properties": {
    "nurture_cadence": {
      "type": "object",
      "properties": {
        "post_interview_chase_hours": { "type": "integer", "default": 24 },
        "post_rejection_care_hours": { "type": "integer", "default": 4 },
        "post_placement_checkin_days": {
          "type": "array",
          "items": { "type": "integer" },
          "default": [7, 30, 90, 180, 365, 730]
        }
      }
    },
    "auto_send_enabled_categories": {
      "type": "array",
      "items": { "enum": ["candidate-acknowledgement", "interview-confirmation", "rejection-care", "post-placement-checkin"] },
      "default": []
    },
    "escalation_recipients": {
      "type": "object",
      "properties": {
        "ESC_VOICE_DRIFT": { "type": "string", "format": "telegram-chat-id" }
      }
    }
  },
  "required": ["nurture_cadence", "auto_send_enabled_categories"]
}
```

**`tools.yaml` (abbreviated to 3 MCP server declarations):**

```yaml
mcp_servers:
  bullhorn:
    scope: [read_candidate, read_client, write_activity]
    degraded_mode: drafts_only
    credentials_required: [BULLHORN_OAUTH_TOKEN]
  microsoft-graph:
    scope: [send_mail]
    degraded_mode: drafts_only
    credentials_required: [MS_GRAPH_DELEGATED_TOKEN]
  agentmail:
    scope: [send_via_agent_identity]
    degraded_mode: skip
    credentials_required: [AGENTMAIL_API_KEY]
    v_minimum: v1.1
cortextos_skills: []
```

Note: `wiki-*` bus operations are NOT declared in `tools.yaml` per ADR-002 Decision 2 — they're internal bus commands. `cortextos_skills:` is empty per the R2 default (§2.2).

**`validate.sh` (10 lines abbreviated):**

```bash
#!/usr/bin/env bash
set -euo pipefail
source "${CTX_AGENT_DIR}/.claude/hooks/_shared/hook-helpers.sh"

# Gate A: hard-fail on missing hh_decision_* calls in this run
hh_assert_decision_trigger_called
hh_assert_decision_output_called

# Banned-phrase + length + voice classifier + schema + PII checks
hh_run_gate_a_checks
```

**`context.sh` (10 lines abbreviated):**

```bash
#!/usr/bin/env bash
set -euo pipefail
source "${CTX_AGENT_DIR}/.claude/hooks/_shared/voice-loader.sh"

hh_load_tone_rules
hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"

# Hydrate via context-assembly API per master brief §9
ifos-context-assembly --agent "${CTX_AGENT_NAME}" --tenant "${CTX_TENANT_SLUG}"
```

#### (b) Rendered output — `orgs/acme/agents/concierge/`

After `cortextos-ifos render-agent concierge --tenant acme`:

```
orgs/acme/agents/concierge/
├── CLAUDE.md                                ← synthesised
├── config.json                              ← synthesised
├── goals.json                               ← empty placeholder
├── .env                                     ← synthesised (chmod 0600)
├── tools.yaml                               ← passthrough
├── README.md                                ← verbatim copy
└── .claude/
    └── hooks/
        ├── validate.sh                      ← verbatim copy of bundle's validate.sh
        ├── context.sh                       ← verbatim copy of bundle's context.sh
        └── _shared/                         ← symlink → ../../_shared/ (org-level)
```

The org-level `_shared/` resolves to `orgs/acme/agents/_shared/`, containing `hook-helpers.sh`, `voice-loader.sh`, `escalation-codes.md`, `common-*.json` schemas. The `_shared/` origination question (founder's carry-forward from §1) is addressed in §3.3.

**`CLAUDE.md` (~25 lines — draft cortextOS preamble per §2.1-A, then agent.md verbatim, then per-tenant footer):**

```markdown
# Concierge — Acme Recruitment

## Session start protocol

You are running under cortextOS as agent `concierge` for tenant `acme`. On
every session start:

1. Run `bash ${CTX_AGENT_DIR}/.claude/hooks/context.sh` to hydrate context
2. Confirm `${CTX_TENANT_SLUG}` is set: `echo $CTX_TENANT_SLUG` → must print `acme`
3. Resume operations per the workflow below

Before any tool invocation that produces output for a human, call:
   `bash ${CTX_AGENT_DIR}/.claude/hooks/validate.sh`
A non-zero exit from validate.sh blocks the action (Gate A; master brief §1 Rule 4).

Decision-log calls are mandatory per master brief §8.1 Change 2:
   `hh_decision_trigger` at start of every run
   `hh_decision_output` before producing the artefact
   `hh_decision_action` when the human resolves

## Environment

- CTX_INSTANCE_ID=ifos-v2
- CTX_TENANT_SLUG=acme
- CTX_AGENT_NAME=concierge
- CTX_ORCHESTRATOR_AGENT=(none in v1.0)
- Operating window: 24/7 (Tier 1)
- Voice anchor: /vault/acme/_voice/style-guide.md (importance threshold 0.75)

---

[agent.md body verbatim from `agents/recruitment/concierge/agent.md`]

---

## Tenant footer

You operate exclusively for tenant `acme` (Acme Recruitment Ltd). Cross-tenant
PII is a `ESC_PII_LEAKAGE_RISK` escalation. Voice samples and tone rules in
`/vault/acme/_voice/`. Decision log writes go to Postgres role
`ifos_tenant_acme` (RLS-enforced).
```

The preamble is the §2.1-A spec-gap resolution draft — pin this verbatim (or revise) before Week 11.

**`config.json` (materialised per the schema + `/vault/acme/_config.yaml`):**

```json
{
  "agent_name": "concierge",
  "enabled": true,
  "runtime": "claude-code",
  "model": "claude-sonnet-4-6",
  "max_session_seconds": 255600,
  "working_directory": "/Users/madsadmin/.cortextos/ifos-v2/orgs/acme/agents/concierge",
  "telegram_polling": true,
  "max_crashes_per_day": 10,
  "startup_delay": 0,
  "timezone": "Europe/London",
  "ctx_warning_threshold": 70,
  "ctx_handoff_threshold": 80,
  "tenant_slug": "acme",
  "nurture_cadence": {
    "post_interview_chase_hours": 24,
    "post_rejection_care_hours": 4,
    "post_placement_checkin_days": [7, 30, 90, 180, 365, 730]
  },
  "auto_send_enabled_categories": ["candidate-acknowledgement"],
  "escalation_recipients": {
    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
  }
}
```

**`.env` (synthesised from `/vault/acme/_secrets.env` + `tools.yaml` MCP server list):**

```bash
# Telegram (per Concierge's per-agent bot per cortextOS Primitive 5)
BOT_TOKEN=<acme/concierge bot token>
CHAT_ID=<acme operator chat id>
ALLOWED_USER=<acme operator numeric user id>

# MCP server credentials (per tools.yaml declaration)
BULLHORN_OAUTH_TOKEN=<acme Bullhorn OAuth bearer>
MS_GRAPH_DELEGATED_TOKEN=<acme MS Graph delegated send token>
# AGENTMAIL_API_KEY deferred to v1.1

# Convenience aliases (per agent-pty.ts:113-137)
CTX_TENANT_SLUG=acme
```

File chmod `0600`.

**`tools.yaml`** — verbatim passthrough from the bundle.

**`README.md`** — verbatim copy from the bundle.

**`.claude/hooks/validate.sh` and `.claude/hooks/context.sh`** — verbatim copies of the bundle versions, `chmod 0755`. Their `source` paths (`${CTX_AGENT_DIR}/.claude/hooks/_shared/...`) resolve at run time because the symlink `.claude/hooks/_shared/ → ../../_shared/` lands `_shared/` content under each rendered agent dir.

**`.claude/hooks/_shared/`** — symbolic link to `orgs/acme/agents/_shared/`. `ls -la .claude/hooks/_shared` shows the symlink target. The org-level `_shared/` itself originates from `${repo}/agents/_shared/` — copy vs symlink question addressed in §3.3.

**`goals.json`** — empty placeholder per `add-agent.ts:131-140` pattern: `{ "focus": "", "goals": [], "bottleneck": "", "updated_at": "", "updated_by": "" }`. Dead weight but harmless; preserves daemon-side compatibility with any cortextOS tooling that reads it.

---

## Section 3 — Renderer mechanism

### 3.1 — Where the renderer lives

**Decision: `packages/agent-renderer/` (Node, TypeScript).**

Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.

Tooling stack chosen for cortextOS consistency (verified against `packages/harness/cortextos/package.json`):

- **Build system:** `tsup` (matches `cortextos@0.1.1` `scripts.build: "tsup"` at line 11).
- **Test framework:** `vitest` (matches cortextos `test: "vitest run"` at line 13).
- **CLI library:** `commander` (matches cortextOS's bus CLI which uses commander throughout — verified in earlier audit reading `src/cli/add-agent.ts:1` and `src/cli/bus.ts`).

Alternatives weighed and rejected:

- `packages/brain/agent-cli/` — extending the brain CLI; rejected because the brain CLI is wiki ops (per ADR-002 Decision 2), and bundle rendering is not a wiki concern. Coupling two distinct CLIs into one package raises lock-in cost.
- `scripts/render-agent.sh` — bash; rejected because the renderer reads YAML schema (`config.schema.json`'s allOf $refs), validates via JSON Schema (Ajv), parses YAML config, and synthesises preamble templates with variable substitution — all easier in TypeScript than in shell.
- Brand new top-level dir — rejected for cohesion with master brief §4.1's existing `packages/` convention.

### 3.2 — When the renderer runs

**Decision for v1.0: manual developer invocation.** Command shape per §3.3.

Rationale anchored to three considerations:

1. **Day-1 cadence is founder + Claude Code in a session.** A render is something Claude Code triggers after editing the source bundle, or after the founder edits per-tenant config. Manual invocation matches the conversational rhythm; automation creates surprise.
2. **Per-tenant scope.** One source bundle materialises into N rendered agents (one per tenant). Each render carries a tenant-slug argument. Manual invocation makes the tenant dimension explicit at every render — no ambient state.
3. **Hand-off boundary is clean.** Developer writes/edits bundle → renderer materialises → daemon discovers (on its next start or IPC restart). Three distinct steps, three distinct invocation surfaces. Automation conflates them.

Alternatives' one-sentence trade-offs:

- **Git pre-push hook:** fires too late — the push lands the bundle source in git, but the target tenant filesystem is on a different host (Hetzner UK VPS per Ultraplan §5.1 line 218), so a pre-push hook on a dev laptop has no access to the tenant vault to render against. v1.1+ if a hook integrates with a CI runner that has tenant access.
- **CI step on PR merge:** wrong tenant scope — CI runs in IFOS's repo context, not in any tenant's vault. Same reachability problem.
- **Daemon auto-renders on bundle change (filesystem watcher inside cortextOS daemon):** rejected because cortextOS daemon is read-only on the submodule (master brief §3.1), and adding render logic to the daemon would couple bundle synthesis to runtime supervision. Two concerns, one process — wrong.

### 3.3 — Renderer's I/O contract

#### 3.3.1 — CLI signature

```bash
cortextos-ifos render-agent <agent-name> --tenant <slug> [flags]
```

| Position / flag | Required | Default | Meaning |
|---|---|---|---|
| `<agent-name>` | yes | — | Bundle name; resolved to `agents/recruitment/<agent-name>/` unless `--bundle-path` overrides |
| `--tenant <slug>` | yes | — | Target tenant; must match a `/vault/<slug>/` that exists |
| `--bundle-path <path>` | no | `agents/recruitment/<agent-name>/` | Override source bundle location (for v1.1+ Temp agents under `agents/temp/` or future verticals) |
| `--dry-run` | no | false | Compute the render plan, print to stdout, write nothing |
| `--force-overwrite-non-rendered` | no | false | Override the §5.1 marker-file refusal; lets renderer overwrite a target that was not previously rendered by this tool |
| `--verbose` | no | false | Print each file's source/target path during render |
| `--org <name>` | no | resolved from tenant→org map in `tenants` Postgres table | Override org (rare; only needed during multi-org transitions) |

Output formats:

- **stdout:** human-readable progress with `[OK]` / `[WARN]` / `[ERR]` markers (matches cortextOS `kb-setup.sh:41-95` convention).
- **structured log:** one JSONL line per render appended to `${frameworkRoot}/orgs/<org>/_meta/render-log.jsonl`. Fields: `timestamp`, `agent`, `tenant`, `bundle_sha` (git SHA of the source bundle dir, computed via `git hash-object -t tree`), `render_outcome` (one of `success | no-op | failed`), `exit_code`, `duration_ms`, optional `error` string on failure.

Exit codes:

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Schema-validation failure (config.schema.json vs /vault/<tenant>/_config.yaml) |
| 2 | Bundle missing or malformed (per §1.1 file inventory) |
| 3 | Daemon collision (target directory locked, see §4.5) |
| 4 | Atomic-rename failure |
| 5 | `_shared/` helpers missing (per §4.2) |
| 6 | Tenant not provisioned (no `/vault/<slug>/`) |
| 7 | Non-rendered-target collision (per §5.1; resolved by `--force-overwrite-non-rendered`) |

#### 3.3.2 — Inputs

The renderer reads exactly:

- **Source bundle:** `agents/recruitment/<agent-name>/` (or `--bundle-path`). All six files per §1.1.
- **Per-tenant config:** `/vault/<tenant>/_config.yaml` per Ultraplan §5.1 line 220.
- **Per-tenant secrets:** `/vault/<tenant>/_secrets.env` per spec gap §2.1-C resolution (added to `provision-tenant.sh` skeleton).
- **Schema refs:** `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` per spec gap §2.1-B and Ultraplan §5.3 line 357-364.
- **cortextOS preamble template:** `packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A.
- **Existing render log** at `${frameworkRoot}/orgs/<org>/_meta/render-log.jsonl` (read for idempotency check per §3.4; created on first render).

#### 3.3.3 — `_shared/` origination — resolved

The §1 carry-forward. Three options weighed in the prompt; **Option γ (hybrid) chosen.**

**Mechanism (Option γ):**

1. IFOS repo is the canonical source: `agents/_shared/{voice-loader.sh, hook-helpers.sh, escalation-codes.md, common-*.json, ...}`.
2. On every render, the renderer ensures the org-level copy is current: `cp -r agents/_shared/ ${frameworkRoot}/orgs/<org>/agents/_shared/` (atomic via `_shared.tmp.<pid>/` then rename). This runs once per render invocation, before the per-agent materialisation step.
3. The per-agent render creates a symlink: `${frameworkRoot}/orgs/<org>/agents/<name>/.claude/hooks/_shared` → `../../_shared` (relative).
4. Result: every agent in an org points at the same `_shared/` snapshot; renders within the same org-render-batch see consistent helper versions; cross-org installs (multi-tenant on the same machine) get independent snapshots.

Rationale per the founder's three weight axes:

- **Version consistency across agents in an org:** ✅ Option γ wins. All agents in `orgs/acme/agents/*/` symlink to the same `_shared/` snapshot. A re-render of any one agent triggers the snapshot refresh, lifting every agent to the same version atomically (because the snapshot is the symlink target).
- **Renderer simplicity:** Option α (per-agent copy) is marginally simpler but loses version consistency. Option β (org-level only) requires a separate `cortextos-ifos sync-shared` command. Option γ folds the sync into every render — slightly more renderer code, but no separate command, and consistency is guaranteed.
- **Daemon discoverability:** all three are daemon-agnostic. The daemon doesn't read `_shared/`; only agent-internal hook scripts source from it.

The cost of Option γ: a re-render of any agent triggers an org-wide `_shared/` refresh, even if `_shared/` hasn't changed. Mitigation: compute SHA of `agents/_shared/` once per render-invocation, compare to the org's last-snapshot SHA stored in `orgs/<org>/_meta/shared-sha`; skip the copy if unchanged. Adds ~5 lines of renderer code; saves ~50ms per render.

#### 3.3.4 — Outputs

The renderer writes:

- **Target directory:** `${frameworkRoot}/orgs/<org>/agents/<name>/`, contents per §2.1 file-by-file mapping.
- **Org-level `_shared/`** (per §3.3.3): `${frameworkRoot}/orgs/<org>/agents/_shared/`, refreshed if SHA differs.
- **Render log entry:** appended to `${frameworkRoot}/orgs/<org>/_meta/render-log.jsonl` (line per §3.3.1 fields).
- **Marker file:** `${frameworkRoot}/orgs/<org>/agents/<name>/.rendered-by-ifos-renderer` containing the render-log JSON line for this render. Written last; presence is the §5.1 non-rendered-target detection signal.
- **No daemon notification.** The renderer writes to disk; the cortextOS daemon's existing `discoverAndStart()` polling picks up new agents on next daemon start (or via `cortextos-ifos enable <agent>` IPC). For brand-new agents the renderer's stdout prints: `Render complete. To activate: pm2 restart ifos-daemon`. For re-renders of existing agents, stdout prints: `Render complete. To pick up new config: cortextos-ifos bus self-restart <agent>`.

**Atomicity:**

1. Renderer writes the full target to `${frameworkRoot}/orgs/<org>/agents/<name>.tmp.<pid>/`.
2. If `${frameworkRoot}/orgs/<org>/agents/<name>/` exists, rename to `<name>.prev.<timestamp>/` (kept as one-render rollback).
3. Rename `<name>.tmp.<pid>/` to `<name>/` (single inode operation; atomic on POSIX).
4. Delete any `<name>.prev.<...>/` older than the most recent (one-render history only — disk hygiene).
5. If any step fails, clean up `<name>.tmp.<pid>/` and exit with code 4.

Daemon collision mitigation per §4.5 below; the atomic rename ensures the daemon's filesystem poller never sees a half-rendered directory.

#### 3.3.5 — Logging

- **stdout:** human-readable progress; goes to terminal during interactive use, captured by PM2 if the renderer is later automated.
- **structured render log:** `${frameworkRoot}/orgs/<org>/_meta/render-log.jsonl` — append-only, one JSONL line per render. Per §3.3.1 fields.
- **No master log path.** v1.0 keeps everything in the org's `_meta/` directory; eliminates a per-machine logfile that would need its own rotation and permissions story. v1.2+ may add a global log if multi-org operational visibility becomes a need.

### 3.4 — Idempotency and re-rendering

**Decision: overwrite, no merge.**

Re-render replaces target directory verbatim. Hand-edits to rendered output are lost. Discipline: hand-edits go to source bundle, then re-render. Stated explicitly in renderer stdout banner: `WARN: This will overwrite ${target}; any hand-edits will be lost. Edit the source bundle and re-render instead.`

Alternatives rejected:

- **Merge with conflict markers:** rejected for v1.0. Renderer doesn't have a three-way-merge semantic (source bundle, last-render, current rendered output). Building it adds substantial complexity for a workflow nobody asked for; the master brief §1 Rule 1 ("output before architecture") favours the simple overwrite model.
- **Refuse if target exists:** rejected because re-renders are the dominant flow — every per-tenant config edit triggers a re-render. A `--force` flag on every invocation is friction without benefit. The §5.1 non-rendered-target check covers the dangerous case (accidental overwrite of a `cortextos-ifos add-agent` scaffold); that's the actual risk.

**SHA check for no-op detection:**

1. Renderer hashes the source bundle directory: `git hash-object -t tree <bundle-path>` produces a stable SHA over the bundle's contents.
2. Renderer reads the most recent JSONL line for this (agent, tenant) pair from `orgs/<org>/_meta/render-log.jsonl`.
3. If `bundle_sha` matches AND the rendered output's marker file timestamp matches AND `/vault/<tenant>/_config.yaml` mtime hasn't changed AND `agents/_shared/` SHA matches the org's last-snapshot SHA:
   - Renderer exits 0 with stdout: `No-op: bundle, tenant config, and shared helpers unchanged since last render.`
   - JSONL line appended with `render_outcome: no-op`.
4. If any of those differ, render runs.

This makes re-runs cheap and accurate. A founder editing only `agents/recruitment/concierge/agent.md` and re-rendering all tenants gets a no-op on tenants whose config hasn't moved, and a real render on tenants whose `_config.yaml` was touched.

### 3.5 — Multi-tenant loop

**Decision for v1.0: per-tenant per-agent invocation only.**

`cortextos-ifos render-agent <agent-name> --tenant <slug>` — one render per call. To render Concierge across three tenants, three invocations. Scriptable via bash `for tenant in acme bravo charlie; do cortextos-ifos render-agent concierge --tenant "$tenant"; done`.

v1.1+ ergonomic additions (out of v1.0 scope but planned):

- `cortextos-ifos render-agent <agent-name> --all-tenants` — iterates over all rows of the `tenants` Postgres table where `status = 'active'`. Used after an `agent.md` edit to propagate to every tenant.
- `cortextos-ifos render-all` — iterates over the cross-product `<agents/recruitment/*> × <active tenants>`. Used for initial multi-tenant onboarding and post-major-refactor reprocessing.

The v1.0 minimum keeps the renderer's CLI surface small (one mode, two required args) and defers cross-tenant orchestration to bash. The Postgres `tenants` table dependency (v1.0 Day 4 per master brief §6) is what unblocks `--all-tenants`; until then there's no programmatic source of truth for "the list of active tenants."

---

## Section 4 — Failure modes and recovery

For each mode: detection mechanism + exit code + recovery + escalation.

### 4.1 — Schema-validation failure

**Detection:** Renderer runs Ajv (or equivalent JSON Schema validator) against `/vault/<tenant>/_config.yaml` materialised through the schema's `allOf $ref` resolution chain. Validation fails on missing required fields, type mismatches, or unrecognised keys (`additionalProperties: false`).

**Exit:** code 1.

**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.

**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `phase='render'`, `human_action='schema-validation-failure'`. If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.

### 4.2 — Missing `_shared/` helpers

**Detection:** Preflight check — before any writes, renderer verifies the source paths referenced by `agents/_shared/` are present and contain expected entry points (`voice-loader.sh`, `hook-helpers.sh`, `common-*.json`).

**Exit:** code 5.

**Recovery:** stderr lists missing paths. Founder scaffolds the missing helpers (Week-1 prerequisite per ADR-002). Re-runs.

**Escalation:** same `ESC_RENDERER_FAILED` row; reason field `shared-helpers-missing`.

### 4.3 — Bundle malformed

**Detection:** Renderer checks `agents/recruitment/<name>/` exists; lists files; verifies all six required files from §1.1 are present (README.md, agent.md, config.schema.json, tools.yaml, validate.sh, context.sh).

**Exit:** code 2.

**Recovery:** stderr lists which files are missing. Founder or Claude Code writes them. Re-runs.

**Escalation:** `ESC_RENDERER_FAILED`; reason `bundle-malformed`.

### 4.4 — Tenant doesn't exist

**Detection:** `/vault/<tenant>/` doesn't exist OR `/vault/<tenant>/_config.yaml` is missing.

**Exit:** code 6.

**Recovery:** stderr: `Tenant <slug> not provisioned. Run: bash scripts/provision-tenant.sh <slug>`. Founder runs `provision-tenant.sh` per Ultraplan §5.5 step 2. Re-runs render.

**Escalation:** `ESC_RENDERER_FAILED`; reason `tenant-not-provisioned`.

### 4.5 — Mid-render daemon collision

**Detection:** The cortextOS daemon's `AgentManager.discoverAndStart()` only runs at daemon startup (per `agent-manager.ts:47-78` audit). There is no continuous filesystem polling for new agent directories. So the collision risk is narrower than "race against a watcher": it's the case where the daemon is mid-boot and the renderer is mid-write of the *same* agent dir.

**Mitigation:** the renderer's atomic-rename pattern (§3.3.4) ensures the daemon never sees a half-rendered directory:

1. Renderer writes to `${frameworkRoot}/orgs/<org>/agents/<name>.tmp.<pid>/` — daemon's `discoverAgents()` filters by directory name pattern (`<name>` not `<name>.tmp.<pid>`); the `.tmp.<pid>/` directory is invisible to discovery.
2. Renderer renames atomically — single inode operation on POSIX. The daemon either sees the old directory (pre-rename) or the new (post-rename); never both, never partial.
3. If `<name>/` already exists (re-render), renderer moves it to `<name>.prev.<timestamp>/` *before* the new rename. The window where neither `<name>/` nor `<name>.tmp.<pid>/` exists is bounded to one `rename(2)` call — microseconds. Daemon discovery during that window misses the agent on this scan; next scan picks it up.

**Renderer-daemon interaction protocol:**

- Renderer does not notify the daemon.
- Daemon's existing `discoverAndStart()` polling discovers the rendered agent (a) on next daemon restart or (b) on explicit `cortextos-ifos enable <name>` IPC call (`add-agent.ts:287-309` writes `enabled-agents.json`, but this is the *add* path; for *re-discover*, the daemon needs restart).
- For brand-new agents: renderer's stdout instructs `pm2 restart ifos-daemon`.
- For re-renders of running agents: renderer's stdout instructs `cortextos-ifos bus self-restart <name>` — the agent picks up new config on session refresh per Primitive 2.

**Exit:** code 3 only if the atomic rename itself fails (e.g. permission error, filesystem full).

### 4.6 — Renderer crash mid-execution

**Detection:** Renderer killed by SIGKILL (OOM, manual `kill -9`, container terminate) between writing the `.tmp.<pid>/` and the atomic rename. The `.tmp.<pid>/` directory is left orphaned.

**Recovery:**

- Next renderer invocation runs a preflight sweep: any `${frameworkRoot}/orgs/<org>/agents/*.tmp.*` directory older than 5 minutes is deleted as stale.
- Manual recovery: `rm -rf orgs/<org>/agents/<name>.tmp.*` — safe at any time because `.tmp.<pid>/` is never the live target.

**No exit code** — this is a recovery case, not a detection-during-this-run case.

### 4.7 — How failures escalate

New escalation code added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3:

- **`ESC_RENDERER_FAILED`** — renderer exited non-zero. Carries `reason` substring (`schema-validation-failure`, `bundle-malformed`, `shared-helpers-missing`, `tenant-not-provisioned`, `atomic-rename-failed`, `non-rendered-target`).

Escalation path:

- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='render'`, `human_action` field carries the reason. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'`.
- **Telegram:** if `--notify-on-failure` is set (default true for v1.0), single message to the founder's operator chat with structured fields: tenant, agent, exit code, reason, stderr first line.
- **stdout:** in the developer terminal, always — regardless of `--notify-on-failure`.

---

## Section 5 — Integration with the broader build

### 5.1 — Renderer vs add-agent.ts

The cortextOS `cortextos-ifos add-agent` command (`packages/harness/cortextos/src/cli/add-agent.ts:18-316`) is **unchanged**. IFOS does **not** use it for IFOS-owned agents. The R2 commitment per ADR-002 §1.7-A drives this.

**What happens if a developer accidentally runs `cortextos-ifos add-agent concierge --template agent --org acme`:**

Per `add-agent.ts:88-110` plus the §1.7 analysis:

1. Scaffolds a cortextOS-shaped agent at `${frameworkRoot}/orgs/acme/agents/concierge/`.
2. Copies the entire `templates/agent/` tree, including all 24 `.claude/skills/` (per `copyTemplateFiles` at line 382-402).
3. Creates `goals.json`, `config.json`, `.env` placeholder.
4. Registers in `enabled-agents.json`.
5. The daemon discovers it and starts it.
6. The agent runs as a **cortextOS-template agent**, NOT as IFOS Concierge. It has `MEMORY.md`, `IDENTITY.md`, `knowledge-base` skill, etc. — none of which IFOS expects.

**The protection: marker-file detection in the renderer's preflight.**

Renderer's preflight before any write:

```
if target_dir exists:
    if target_dir/.rendered-by-ifos-renderer exists:
        proceed (normal re-render flow)
    else:
        if --force-overwrite-non-rendered:
            warn, proceed
        else:
            exit 7: "Target exists but was not created by this renderer. The directory was likely created by `cortextos-ifos add-agent` and inheriting the cortextOS-template surface. Either delete it manually (rm -rf <target>) or re-run with --force-overwrite-non-rendered to discard and re-render."
```

This is the structural guard against accidental cortextOS-template inheritance. It fires before any writes; no partial damage possible.

**The marker file** `.rendered-by-ifos-renderer` is written as the **last** step of every successful render (per §3.3.4). Contents: the render-log JSONL line for this render. Absence of the marker is the unambiguous signal that the directory came from somewhere else.

### 5.2 — Renderer in the v1.0 build sequence

Per `second-brain-design.md` §3.4 closing paragraph: "the renderer (ADR-003) must be live by start of week 11 so agents can actually be scaffolded against the wiki API."

Concrete prerequisites for week 11:

| Prerequisite | Owner | Target week |
|---|---|---|
| ADR-003 (this design ratified) | founder + Claude Code | **Week 1** |
| Renderer implementation under `packages/agent-renderer/` | Claude Code | **Weeks 1-2** (after ADR-003 lands) |
| `packages/agents-runtime/_shared/{voice-loader,hook-helpers}.sh` (per ADR-002 prerequisite) | Claude Code | Weeks 1-2 |
| `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` (per spec gap §2.1-B) | Claude Code | Weeks 1-2 |
| `packages/agent-renderer/templates/claude-md-preamble.md` (per spec gap §2.1-A, draft in §2.3) | Claude Code | Week 1 (alongside renderer impl) |
| `_secrets.env` added to `provision-tenant.sh` skeleton (per spec gap §2.1-C) | Claude Code | Day 4 of Week 0 (alongside the Postgres provisioning) |
| Postgres `decision_log` table live (per master brief §6 Day 4) | founder | Day 4 of Week 0 (already scheduled) |
| 5 v1.0 agent bundles authored at `agents/recruitment/<name>/` | founder + Claude Code | Weeks 3-10 (in parallel with other work) |

**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.

### 5.3 — Master brief edits authorised

Three edits flagged. The first two land in their own ADR-003 commit alongside the design and ADR-003 (this batch's session-close commit); the third joins the atomic correction commit that ADR-001 + ADR-002 already queue.

**Edit A — Master brief §4.1 directory listing:**

**Current** (master brief §4.1 line 195-204): "Create the operative directory structure" followed by an `mkdir -p` command listing `packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}`.

**Proposed:** add `agent-renderer` to the list:

```bash
mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
```

Plus a one-line footnote: "`agent-renderer/` — the IFOS Agent Bundle v2 → cortextOS-shaped per-agent directory renderer, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`."

**Edit B — Master brief §8.3 working pattern:**

**Current** (master brief §8.3 lines 614-630): the `bash` block showing the bundle authoring workflow ends with: "Test against fixtures; iterate; commit; PR; merge."

**Proposed:** add a final step after "merge":

```bash
# After merge, render the bundle for each tenant that uses this agent:
cortextos-ifos render-agent {name} --tenant <slug>
# For all active tenants (v1.1+): cortextos-ifos render-agent {name} --all-tenants
# Activate: pm2 restart ifos-daemon  (for new agents)
#       OR: cortextos-ifos bus self-restart {name}  (for re-renders of running agents)
```

**Edit C — Master brief §8.1 add renderer reference:**

**Current** (master brief §8 lines 545-568): bundle file list with no reference to renderer.

**Proposed:** add a one-paragraph footnote at the end of §8 (before §8.1): "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per ADR-003) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant)."

Edit A and Edit B land in this batch's commit alongside ADR-003. Edit C joins the atomic correction commit (it's a substantive wording change, parallel to ADR-002 Edit 1 and Edit 2; ratified together by Codex on Day 7).

### 5.4 — Spec gaps surfaced during design (consolidated)

Six gaps surfaced or referenced in this design. Bucketed per the second-brain-design.md four-bucket pattern.

**Resolved inline in this design:**

- **§1.1-A** (invocation mechanism for validate.sh / context.sh) — resolved in §2.1: render to `.claude/hooks/`; CLAUDE.md preamble (§2.3) references them.
- **§1.1-B** (`_shared/` location in rendered output) — resolved in §3.3.3 Option γ: org-level `${frameworkRoot}/orgs/<org>/agents/_shared/` symlinked into each agent's `.claude/hooks/_shared/`.
- **§2.1-A** (cortextOS preamble template content) — resolved with draft preamble in §2.3 and pinned location in §3.3 (`packages/agent-renderer/templates/claude-md-preamble.md`).
- **§2.1-B** (where common-*.json shared schemas live) — resolved in §3.3.2: `packages/agents-runtime/_shared/common-*.json`.
- **§2.2-A** (`cortextos_skills:` opt-in syntax in tools.yaml) — resolved in §2.2 with YAML block example.

**Master brief edits needed** (per §5.3 above):

- **Edit A:** §4.1 directory listing — add `packages/agent-renderer/`. Lands this batch.
- **Edit B:** §8.3 working pattern — add render step. Lands this batch.
- **Edit C:** §8 footnote referencing the renderer. Joins atomic correction commit.

**Week-1+ prerequisite artefacts** (load-bearing for first production render):

- `packages/agent-renderer/templates/claude-md-preamble.md` (the canonical preamble — pinned location, content drafted in §2.3).
- `packages/agents-runtime/_shared/common-*.json` (the schema $ref targets — seven files per Ultraplan §5.3 line 357-364).
- `_secrets.env` added to `provision-tenant.sh` skeleton — Day 4 of Week 0 (alongside the Postgres `entity_graph` rename per ADR-002 Edit 3).
- Renderer implementation under `packages/agent-renderer/` itself — Weeks 1-2.

**Operational defaults** (founder can override later without rework):

- Build system: `tsup`.
- Test framework: `vitest`.
- CLI library: `commander`.
- Invocation mode: manual developer invocation (v1.0); auto-render and `--all-tenants` are v1.1+ additions.
- `_shared/` origination: Option γ (hybrid).
- Re-render policy: overwrite, no merge.
- Multi-tenant loop: per-tenant per-agent for v1.0.
- Daemon notification on render: none — stdout instructs founder/operator on the appropriate restart command.
- Non-rendered target detection: marker file `.rendered-by-ifos-renderer` written as last render step.
- One-render rollback: `<name>.prev.<timestamp>/` retained until next render.

End of design.
