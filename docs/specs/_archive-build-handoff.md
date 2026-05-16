# Intel Force OS on CortexOS — Build Handoff for Claude Code

**Document type:** Operational handoff. Everything Claude Code needs to know to start the v1.0 build on top of CortexOS without re-deriving context.
**Audience:** You (Maddox) running Claude Code locally. Drop this file into the repo root before running `/onboarding`. The first Claude Code session will read it.
**Date:** 15 May 2026
**Authoritative source documents (read these in this order if anything is unclear):**
1. `intelforce-os-recruitment-final-product-spec.md` — what to build
2. `intelforce-os-ultraplan.md` — how to build, in what order
3. `intelforce-os-cortexos-24-7-upgrade-directive.md` — why the runtime is what it is
4. `intelforce-os-internal-business-plan.md` — commercial and strategic envelope
5. `00-PATTERN-REFERENCE.md` — the agent-bundle file pattern
6. `intelforce-os-composio-and-agentmail-adoption.md` — the adapter boundary

If any of those conflict with this handoff on *how to proceed today*, this handoff wins. If they conflict on *what the product is*, the spec wins.

---

## 0. The 60-second version

You ran `curl -fsSL https://raw.githubusercontent.com/grandamenium/cortextos/main/install.mjs | node`. That installs CortexOS into `~/cortextos`, links the `cortextos` CLI, installs PM2 and jq, ensures Claude Code is authenticated, then drops you at a prompt that tells you to do two things:

```
1. claude ~/cortextos
2. /onboarding
```

**Do not do that yet.** That command path is the right one for *building inside CortexOS itself*. You are doing something different: you are building **Intel Force OS as a product layer that consumes CortexOS as a runtime**. That distinction governs the next 50 decisions.

The correct setup is:

1. Create a new repo: `intelforce-os/` (your product code lives here)
2. Add CortexOS as a git submodule at `packages/cortex-os/`
3. Put this handoff document, the product spec, and the ultraplan into `intelforce-os/docs/` and `intelforce-os/CLAUDE.md`
4. Open `intelforce-os/` in Claude Code — not `~/cortextos`
5. Work the Week 0 checklist before any agent code gets written

§3 of this document walks through that. §4 onwards is the Claude Code working context.

---

## 1. The boundary you must hold

This is the single most important thing in this document. Re-read it whenever a decision feels ambiguous.

**CortexOS is the runtime. Intel Force OS is the product.**

The architecture is layered like this (per Ultraplan §3.3 and Business Plan §5.2):

```
┌─────────────────────────────────────────────────────────┐
│ INTEL FORCE OS (your product layer — you build & own)   │
│                                                         │
│  • Vertical schema (docs/verticals/recruitment/…)       │
│  • Agent bundles (18 × 6-file bundles)                  │
│  • MCP connectors (Bullhorn, MS Graph, Companies House) │
│  • Vault syncer & contract                              │
│  • Entity graph service (Postgres + pgvector)           │
│  • Decision log service                                 │
│  • Brain UI (extends CortexOS dashboard)                │
│  • Onboarding wizard                                    │
└──────────────────────────┬──────────────────────────────┘
                           │ consumes
┌──────────────────────────▼──────────────────────────────┐
│ CORTEXOS (runtime — you consume, never modify)          │
│                                                         │
│  • PM2 process supervision                              │
│  • File bus (inter-agent handoff)                       │
│  • Telegram approval surface                            │
│  • Approval gate state machine                          │
│  • 71-hour context rotation                             │
│  • Orchestrator template                                │
└─────────────────────────────────────────────────────────┘
```

**The rule (Ultraplan §3.4):** if you need something CortexOS doesn't have, contribute it upstream. Don't fork. The exception is anything recruitment-vertical-specific — that stays in your layer.

**The test:** would another industry's product also benefit from this? If yes → upstream. If no → yours.

**What this means in practice today:**
- You do **not** edit files in `~/cortextos` or `packages/cortex-os/`
- You do **not** add recruitment-specific code to CortexOS templates
- You **do** add CortexOS as a submodule, pin it to a known-good commit, and treat it as a library
- You **do** put every line of Intel Force OS code outside `packages/cortex-os/`

If a Claude Code session ever proposes editing CortexOS internals, stop and either (a) ship it as an upstream contribution PR, or (b) wrap it in your own adapter layer. There is no third option.

---

## 2. What the installer just did, and what state you're in

The installer (the one you ran) executed these steps in order:

1. Verified Node.js ≥20, npm, git, Python 3, build tools (Xcode CLI on macOS, build-essential on Linux, MSVC on Windows)
2. Installed Claude Code globally if not present, prompted for `claude login` if not authenticated
3. Installed jq (required for the agent file-bus scripts)
4. Cloned `grandamenium/cortextos` to `~/cortextos` (or `$CORTEXTOS_DIR` if you set it)
5. Renamed the git remote `origin` → `upstream` so future updates pull from canonical
6. Ran `npm install` and `npm run build` inside `~/cortextos`
7. Ran `npm link` so the `cortextos` CLI is on your PATH globally
8. Installed PM2 globally
9. Ran `node dist/cli.js install` inside `~/cortextos` for any one-time CortexOS setup

**Your current state:**
- `~/cortextos/` exists with the canonical CortexOS code, built and ready
- `cortextos` is a globally-available CLI command
- `pm2` is a globally-available CLI command
- Claude Code is installed; authentication may or may not be done (run `claude auth status` to check)
- You have **not** yet created the Intel Force OS repo

**What you should NOT do:**
- Run `/onboarding` inside `~/cortextos` — that initialises CortexOS *as the project*, which is the wrong layer for you
- Start writing recruitment agents inside `~/cortextos/agents/` — they'll be in the wrong repo
- Modify `~/cortextos/` files at all — you'll have nothing to pull when CortexOS releases updates

---

## 3. The seven-day pre-build window — what to do before any agent code is written

This is Ultraplan §11, restated as a Claude Code work plan. Each day is a session or two of Claude Code. End every day by committing what you have.

### Day 0 (today) — Repo setup and CLAUDE.md

Open a terminal and run:

```bash
# Create the monorepo
mkdir -p ~/code/intelforce-os && cd ~/code/intelforce-os
git init
git branch -m main

# Standard directories per Business Plan §5.4
mkdir -p docs/{architecture,verticals/recruitment,verticals/_future,runbooks,decisions}
mkdir -p packages/{platform,brain-ui,mcp-connectors}
mkdir -p agents/_shared
mkdir -p infrastructure/{docker,terraform,pm2}
mkdir -p tests/{unit,integration,eval-sets}
mkdir -p .agents/{decisions,learnings}

# CortexOS as a submodule, pinned (you can update the pin later via git submodule update --remote)
git submodule add https://github.com/grandamenium/cortextos.git packages/cortex-os
cd packages/cortex-os && git checkout main && cd ../..

# README placeholder
echo "# Intel Force OS" > README.md
echo "node_modules/" > .gitignore
echo "dist/" >> .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore

# Initial commit
git add -A
git commit -m "chore: initial monorepo scaffold with CortexOS submodule"
```

Then **copy three documents into the repo**, in these locations:

```
intelforce-os/
├── CLAUDE.md                                          ← top-level Claude Code instructions (next step)
├── docs/
│   ├── INTERNAL-BUSINESS-PLAN.md
│   ├── PRODUCT-SPEC.md                                ← copy of recruitment-final-product-spec.md
│   ├── ULTRAPLAN.md                                   ← copy of intelforce-os-ultraplan.md
│   ├── CORTEXOS-24-7-DIRECTIVE.md
│   ├── COMPOSIO-AGENTMAIL-ADOPTION.md
│   └── PATTERN-REFERENCE.md                           ← copy of 00-PATTERN-REFERENCE.md
└── .agents/
    └── README.md
```

Then create `CLAUDE.md` at the repo root. This is the first thing every Claude Code session reads. Use this as the starting content:

```markdown
# Intel Force OS — Claude Code instructions

## What this repo is
Intel Force OS is a recruitment operations product for UK agencies. It runs on
top of CortexOS (`packages/cortex-os/`, vendored as a git submodule) as the
persistent agent runtime. You build the product. You do not modify CortexOS.

## Architecture
See `docs/INTERNAL-BUSINESS-PLAN.md` §5.

## Build sequence
See `docs/ULTRAPLAN.md` §9 for the 14-week v1.0 sprint plan.

## Product spec
See `docs/PRODUCT-SPEC.md` — the agent suite, output contracts, tier mapping.

## The five rules (Ultraplan §1 — non-negotiable)
1. Output before architecture — every agent ships with its output contract written first.
2. Schema before code — customer-specific data lives in vertical-schema.yaml, config.schema.json, or vault. Never in agent prompts.
3. Reuse before build — agents use _shared/ modules. No agent writes its own logging, voice handling, or approval gate.
4. Quality gates before features — Gate A working > extra features.
5. Honest signal before optimistic projection — the risk register (Ultraplan §10) is the truth-telling instrument.

## The boundary
You do not edit `packages/cortex-os/`. If CortexOS lacks something we need:
- If another industry would also benefit → upstream contribution PR
- If it's recruitment-specific → build it in our layer (`packages/`, `agents/`)

## Agent bundle pattern (v2)
See `docs/PATTERN-REFERENCE.md` and Ultraplan §4. Every agent has exactly:
- README.md, agent.md, config.schema.json, tools.yaml, validate.sh, context.sh
- tests/fixtures/01-primary/, 02-edge-case-*/, 99-voice-drift-canary/

## Current priorities
See `.agents/current-priorities.md`.

## Working pattern
- One agent at a time, in isolation, before integration
- Write the output contract first (in agent.md), then validate.sh, then everything else
- Run fixtures in CI on every commit; <100% pass blocks merge
- Decision log writes are required (Rule 4)
```

Commit. That's Day 0 done.

### Day 1 (Monday) — CortexOS primitive audit

The single most important Day-1 task. Per Ultraplan §11, write `docs/architecture/cortexos-primitive-status.md` with one line per primitive:

```markdown
# CortexOS primitive status — audit YYYY-MM-DD

| # | Primitive | Status | Notes |
|---|---|---|---|
| 1 | Persistent PTY via PM2 | shipped and tested / shipped but flaky / documented not built / aspirational | |
| 2 | 71-hour context rotation with auto-restart | … | |
| 3 | Inter-agent file bus | … | |
| 4 | Approval gates with standing authorisations | … | |
| 5 | Telegram + iOS approval surface | … | |
| 6 | Overnight autoresearch | … | |
| 7 | Multi-agent orchestrator template | … | |
```

How to find out: read `packages/cortex-os/README.md`, scan the source, run `cortextos --help`, and if needed, ask Claude Code to inspect the repo with you. The CortexOS install also created an example org structure under `~/cortextos/`; inspecting that gives you the operational reality of each primitive.

**The Ultraplan assumes primitives 1, 4, 5 are working at v1.0 start; 2, 3, 6, 7 may land during the build window.** Your audit either confirms this or triggers a re-cut of §9 of the Ultraplan.

Also Day 1: have your first design-partner sales conversation. The Ultraplan §10 risk register lists "no signed LOI by end of week 0" as a v1.0-killer risk. Sales conversations start now.

### Day 2 — Bullhorn integration path

Per Ultraplan §11, decide and document in `docs/decisions/bullhorn-integration-path.md`:
- Bullhorn Marketplace (vetted, slower onboarding, may have revenue share) vs Direct API (faster, requires per-tenant OAuth setup)
- OAuth model: browser-dance for production tenants vs service-account credentials for dev

Bullhorn is the critical path for 18-of-18 agents. Get this right.

### Day 3 — Sequencing optimisation target

Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.

Also Day 3: confirm Brain UI v1.0 scope is "the minimal what-did-the-agents-do-today view" — not a full dashboard rebuild. Per Business Plan §5.3 this view extends CortexOS's existing Next.js dashboard rather than replaces it.

### Day 4 — Infrastructure

Provision the production Hetzner UK VPS per Ultraplan §5.1 / §5.2:
- Hetzner UK location
- LUKS-encrypted volume for `/vault/`
- Postgres 16
- RLS policy template tested with two synthetic tenant roles trying to read each other's data (the kernel-stops-cross-tenant test)
- PgBouncer pinned to per-session tenant roles

Also Day 4: scope the first MCP server (Bullhorn) — document the `tools.yaml` shape per the Pattern Reference and the Composio/AgentMail adoption doc §3.5. Note: per the adoption doc, Bullhorn is **first-party MCP** (vertical-specific). Composio is *not* the path for it.

### Day 5 — Safety policy and kill criterion

Two artefacts:

`docs/auto-send-safety-policy.md` (Q11 from the Ultraplan's source Q&A):
- The full categorical list of what may auto-send vs what is draft-only per tier
- The standing-authorisation contract per agent
- The escalation cascade when auto-send produces a complaint
- Pilot-agreement language defining liability

`docs/v1-kill-criterion.md` (Q12):
- The explicit condition under which v1.0 stops shipping (e.g., "If after 3 pilots the average Gate B revenue uplift is <£20k/year per tenant, the wedge is dead and we pivot")

These are the structural protections against shipping bad product. Write them now while you can think clearly.

### Day 6 (light day) — Vertical schema v0.1

Start `docs/verticals/recruitment/vertical-schema.yaml` with the 8 core entities:
- Candidate
- Contractor (subtype of candidate, with extra contract fields)
- Client (company)
- Contact (person at client)
- Role / Brief
- Placement
- Opportunity (pre-brief BD)
- Timesheet (Temp tier only)

For each: every field, every relationship, every data source, every workflow that touches it. Per Business Plan §6.1 this is the most defensible IP. Don't rush it; don't perfect it either. v0.1 today, v0.2 next month after the first pilot conversation.

### Day 7 (Sunday) — Review

The single-sentence test (Ultraplan §12):
1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"? Y/N
2. Does the CortexOS submodule give us primitives 1, 4, and 5 working today? Y/N
3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path? Y/N
4. Have we scoped the Agent Bundle v2 refactor and is the work <5 days? Y/N
5. Have we drafted the vertical schema v0.1 with the 8 core entities? Y/N

**Five yeses → Week 1 starts Monday. Anything less → Week 0 extends by however long it takes to close the no.**

Update `.agents/current-priorities.md`. Update Ultraplan §10 risk register with anything new. Commit.

---

## 4. How to actually use Claude Code on this repo

Open the repo in Claude Code:

```bash
claude ~/code/intelforce-os
```

Claude Code reads `CLAUDE.md` first. The file you created in Day 0 tells it: the boundary with CortexOS, the five rules, the agent bundle pattern, where the priorities live.

### Working pattern — agents in isolation

Per the user memory and Ultraplan §4.4, every agent is built in isolation before integration. The pattern for any new agent:

```bash
# Branch off main for the agent
git checkout -b agent/bullhorn-mcp        # or agent/janitor, agent/scribe, etc.

# Create the bundle directory
mkdir -p agents/janitor/tests/fixtures/{01-primary,02-edge-case-merged-duplicates,99-voice-drift-canary}

# In Claude Code, work the bundle through the 6 files in order:
# 1. README.md (2-minute overview for humans)
# 2. agent.md (the prompt — output contract first, then workflow, then quality gates, then escalation)
# 3. config.schema.json (what the wizard collects)
# 4. tools.yaml (MCP servers + scopes + degraded modes)
# 5. validate.sh (Gate A structural checks; sources _shared/hook-helpers.sh)
# 6. context.sh (hydrates the CONTEXT block from vault + decision log via pgvector)

# Then the fixtures (01-primary, 02-edge-case, 99-voice-drift-canary) with golden outputs.

# Test against the fixture; iterate; commit; PR; merge to main.
```

The Phase 2 bundles in your project files are working examples — read one (the Proposal Builder is the most complete) before writing your first new one.

### What Claude Code is good at on this project

- Writing `agent.md` files given an output contract — long, structured, opinionated prompts are its sweet spot
- Implementing `_shared/hook-helpers.sh` extensions (voice loader, decision-log writer)
- Building MCP connectors — give it the OpenAPI spec and the `tools.yaml` shape from the Pattern Reference
- Writing test fixtures (input.json + expected.md pairs)
- Reviewing your YAML schemas for consistency with `vertical-schema.yaml`

### What Claude Code is NOT good at (and you should do yourself)

- Deciding what the output contract should be — that's a sales/product call, made with a real prospect in mind
- Picking which agent to build next — that's the Ultraplan §9 sprint plan and depends on pilot conversations
- Negotiating Bullhorn marketplace terms — that's a phone call
- The single-sentence test — that's your honest answer, not Claude's optimistic one

### The /onboarding command

The CortexOS install script ends by telling you to run `claude ~/cortextos` then `/onboarding`. **That command is for someone setting up CortexOS as their primary product**. You're not doing that.

If you ever want to see what `/onboarding` does, run it inside `~/cortextos` in a sandbox session — but don't commit any of its output. The Intel Force OS repo has its own onboarding shape (per Business Plan §5.4 / Ultraplan §5.5) which is what you build into the wizard at v1.0.

---

## 5. The agent build order — v1.0 only

Per Ultraplan §9, v1.0 ships six agents in the Starter and Boutique tiers. In order:

| Order | Agent | Build weeks | Key dependency | Why it's first |
|---|---|---|---|---|
| 1 | **Diagnostic** | 3–4 | LinkedIn + Companies House + web scrape | Sales tool — needed for pitch before any other agent matters |
| 2 | **Janitor** | 5 | Bullhorn MCP (read + write) | First demoable inside-the-ATS result; day-30 before/after report closes deals |
| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |

After Concierge ships, the first pilot converts to paid (Week 14 milestone). v1.1 then layers Triage, Brief Decoder, Competitor Interception, Night Sourcer, and the Temp agents T5 + T3.

**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).

---

## 6. The Composio/AgentMail boundary — critical for tools.yaml

Per `intelforce-os-composio-and-agentmail-adoption.md`:

**Composio adopted for commodity SaaS only:**
- Gmail, Outlook, Slack, HubSpot, DocuSign, Calendly, Notion
- These appear behind an adapter, never named in `tools.yaml` directly

**Composio rejected for vertical systems:**
- Bullhorn, Vincere, Voyager Infinity, Acturis, Open GI, SSP, Applied Epic
- Companies House, Xero, QuickBooks, FreeAgent, Sage, HMRC MTD
- These are first-party MCP servers under `packages/mcp-connectors/`

**AgentMail adopted as the inbox layer for one agent only:**
- Inbound Triage (v1.1)
- All other agents continue to use Microsoft Graph delegated send for consultant-identity outbound

**The architectural rule (§3 of that document):** agents call adapters, adapters call execution backends. No `agent.md`, no `tools.yaml` `required:` block, no eval fixture references Composio or AgentMail by name. The adapter boundary is enforced in code review.

**For Day 4 (first MCP scope):** Bullhorn is first-party. Composio is not the path. Build the connector at `packages/mcp-connectors/bullhorn/` per the Pattern Reference's `tools.yaml` shape.

---

## 7. The five rules — say them out loud once a week

These are Ultraplan §1. Pin them above your desk:

1. **Output before architecture** — every agent ships with its output contract written first. If you can't write the output contract as a screenshot description in one paragraph, the agent isn't ready to start.
2. **Schema before code** — anything that varies between customers lives in `vertical-schema.yaml`, `config.schema.json`, or the tenant vault. Never in agent prompts. A code review that finds a customer-specific string in code is rejected on that basis alone.
3. **Reuse before build** — every agent uses shared `_shared/` modules. No agent writes its own logging, its own voice handling, its own approval gate.
4. **Quality gates before features** — an agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not.
5. **Honest signal before optimistic projection** — when something doesn't work, log it and re-plan. The risk register in Ultraplan §10 is the truth-telling instrument; updated weekly, by name, with no hedging.

---

## 8. Things you'll forget without writing them down

Stuff that's true but not obvious, in no particular order:

- **CortexOS submodule pinning.** When you `git submodule add`, you're pinning to a specific commit. To update: `cd packages/cortex-os && git pull upstream main && cd ../.. && git add packages/cortex-os && git commit -m "chore: bump cortex-os to <sha>"`. Test before merging the bump.
- **The `.agents/` directory at the repo root** is the markdown brain for the monorepo itself (per Business Plan §5.4 footnote). Priorities, decisions, learnings, open questions. Claude Code reads this. It's also a useful artefact independent of CortexOS — the low-cost pre-experiment validation rig from your user memory.
- **Decision logging is required** (Ultraplan §4.2 change 2). Every agent run writes three log entries via `hh_decision_trigger`, `hh_decision_output`, `hh_decision_action`. Missing calls = hard fail in validate.sh. This is what enables the per-tenant LoRA pipeline at v2.0.
- **The 99-voice-drift-canary fixture** is new in v2. Every agent has one. Run weekly in CI; output diffed against historical baselines. This is your structural early-warning for voice rot as the corpus grows.
- **Tenant isolation is belt and braces:** POSIX permissions (kernel-enforced) + Postgres RLS (database-enforced). Application code does not filter by tenant; the kernel and database do.
- **You are not allowed to market 99.9% uptime.** The honest number is 99.5% and the customer agreement says so (Ultraplan §3.5).
- **The vertical schema is the most defensible piece of IP** (Business Plan §6.1, §14). Treat it as the most important artefact in the repo. Build the agents because they are what the customer sees and pays for. But the real work, the work that compounds, is the work of writing, refining, and extending the schema.

---

## 9. What to do if something feels wrong

If a Claude Code session proposes any of these, stop and re-read the relevant section:

| Symptom | Re-read |
|---|---|
| "Let me edit `packages/cortex-os/...`" | §1 of this doc |
| "Let me hardcode the client's name as 'Acme'..." | Five Rules — Rule 2 |
| "Let me have this agent log directly..." | Five Rules — Rule 3 |
| "Let me skip the test fixtures for now..." | Ultraplan §4.3 |
| "Let me build Triage first because it's the most exciting..." | Ultraplan §9 |
| "Let me use Composio for the Bullhorn connector..." | §6 of this doc |
| "Let me ship without the kill criterion documented..." | Ultraplan §11 Day 5 |

If you find yourself making the same mistake twice, add the symptom to `.agents/learnings/` so future you reads it.

---

## 10. The single command that starts everything

After Day 0 setup (§3) is complete, the command that starts your build life is:

```bash
cd ~/code/intelforce-os && claude .
```

Then, inside the Claude Code session, give it this first prompt:

> Read `CLAUDE.md`, then `docs/ULTRAPLAN.md` §1, §3, §4, §9, §11. Confirm you understand the five rules and the boundary with CortexOS. Then look at `.agents/current-priorities.md` and tell me what we're doing today.

That's it. The system from there is just doing the work, one day at a time, against the Ultraplan §11 checklist and then the §9 sprint plan.

---

## 11. The contract with future you

When you read this document again in three months, you will be tempted to:
- Skip the Week 0 checklist because "we've already started building"
- Edit CortexOS internals because "it'll be faster than upstreaming"
- Ship an agent without a 99-voice-drift-canary fixture because "we'll add it later"
- Drop a customer name into a prompt because "it's just this one tenant"
- Mark the kill criterion as "soft" because "the pilot is going well"

Don't. Each of those is a Phase 2 of someone else's startup post-mortem. The five rules and the boundary with CortexOS are what keep this thing buildable by one person, then two, then ten.

The structural moat is not the agents. It's the schema, the pattern, the boundary, and the gates. Hold those, and the agents are exercises in execution.

---

*End of handoff. Drop this in `intelforce-os/docs/BUILD-HANDOFF.md` after the Day 0 scaffold is up. Re-read §1, §7, and §9 weekly.*
