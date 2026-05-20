# Intel Force OS v2 — Master Brief for Claude Code

**Drop location:** `~/code/CortexOS/CLAUDE.md` (the working repo) and `~/code/CortexOS/docs/build-brief/00-MASTER-BRIEF.md`.

**Synthesis stance:** First principles. The build pack in `docs/build-pack/` is **ignored** per founder instruction. The CLAUDE.md currently in the repo describes paths, remotes, and red lines — those are kept. Everything else in this brief is rebuilt from the verified state of the two upstream repos (`grandamenium/cortextos`, `tarsclaw/intel-force-os-v2`), Karpathy's LLM-wiki pattern, and the recruitment product spec, ultraplan, and 24/7 directive.

**Verified on:** 16 May 2026 against `cortextos@0.1.1` and the `intel-force-os-v2` repo HEAD.

**Reading order in Claude Code:**
1. This document — read in full at session start
2. `docs/specs/PRODUCT-SPEC.md` — what gets built (the 18-agent suite)
3. `docs/specs/ULTRAPLAN.md` — how, in what order
4. The §-references below to other primary docs

If anything in `docs/build-pack/` conflicts with this brief, **this brief wins**. The build pack stays in-tree as historical record; the master brief is operative.

---

## 0. The thirty-second version

You are building **Intel Force OS v2 (IFOS)**, an operations product for UK recruitment agencies, on top of **cortextOS** — the persistent 24/7 Claude Code agent runtime by `grandamenium/cortextos`.

Three repositories are in play:

```
~/code/CortexOS/                     ← v2 codebase (this one). The product.
├── packages/harness/cortextos/      ← cortextOS vendored at a pinned SHA. READ-ONLY.
│                                       Only the four bus/kb-*.sh files are overridable
│                                       per §3.4. Everything else: hands off.
├── packages/...                     ← Our product code lives here.
└── docs/...

~/code/intel-force-os/               ← v1 codebase. ALIVE, do not modify.
                                       Source of inheritance only. Read it,
                                       lift the artefacts named in §7.

~/code/cortex-os-upstream/           ← Upstream cortextOS clone, read-only.
                                       For reference grep when the vendored copy
                                       isn't enough. Tracks main.
```

CortexOS gives us PM2 process supervision, persistent PTY agents, 71-hour context rotation, file-bus inter-agent handoff, a Telegram approval surface, an orchestrator template, and a Next.js dashboard. We **consume**, never modify.

We add: a vertical schema for UK recruitment; 18 agents in the v2 bundle pattern; an Obsidian-style wiki + graphify second brain that **replaces** cortextOS's stock knowledge-base behind the `bus/kb-*.sh` boundary; MCP connectors for Bullhorn/Companies House/Xero/Microsoft Graph; an entity-graph + decision-log Postgres layer with RLS; a per-tenant LoRA pipeline (v2.0 work); and a five-day onboarding wizard.

The five rules in §1 govern every decision. The boundary in §3 governs every file. The Week 0 list in §6 is the only thing to do this week. Read all three before writing any agent code.

---

## 1. The five rules (non-negotiable)

If anything anywhere in this brief, in any other document, or in your own session reasoning violates one of these, the rule wins.

1. **Output before architecture.** Every agent ships with its output contract written first, as a one-paragraph screenshot description. If you can't write it, the agent isn't ready to start.
2. **Schema before code.** Anything that varies per customer lives in `docs/verticals/recruitment/vertical-schema.yaml`, the agent's `config.schema.json`, or the tenant's `/vault/{tenant}/`. Never in agent prompts. Never in agent code. A code review that finds a customer-specific string in code is rejected on that basis alone.
3. **Reuse before build.** Every agent uses `agents/_shared/` modules: voice loader, decision-log writer, validate primitives, escalation router. No agent writes its own logging, voice handling, or approval gate. If the shared module is missing, build the module first, then the agent.
4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
5. **Honest signal before optimistic projection.** When something doesn't work, log it in `.agents/learnings/` and re-plan. The risk register at `docs/RISK-REGISTER.md` is updated weekly with no hedging.

Recite these on Monday morning before the standup. The rules drift first.

---

## 2. The verified state of cortextOS — what we actually depend on

Everything in this section is verified against `grandamenium/cortextos@main` as of 16 May 2026. The handoff doc was right in spirit but had two assumptions that are wrong; corrections inlined.

### 2.1 Package facts

- **npm:** `cortextos@0.1.1`, CommonJS, MIT-licensed
- **Engine:** Node ≥20
- **Runtime deps (small, deliberate):** `node-pty` (PTY primitive), `chokidar` (file-bus watcher), `commander` (CLI), `@inquirer/prompts` (interactive setup), `chalk`/`ora` (TTY), `strip-ansi`
- **Build:** `tsup`, ships `dist/` + `templates/` in the npm tarball
- **Dashboard:** `dashboard/` is its own Next.js 14 app, not part of the published npm package — vendored together inside the cortextos repo

### 2.2 Verified repo layout

```
cortextos/
├── .claude/commands/         # slash commands incl. /onboarding
├── bus/                      # ★ shell wrappers that delegate to dist/cli.js bus
│                                kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh
│                                are the four overrides we shadow — see §3.4
├── community/                # community skills + agent catalog mount point
├── dashboard/                # Next.js 14 web dashboard (workflows, approvals, etc.)
├── docs/
├── knowledge-base/scripts/   # the mmrag.py stock knowledge-base implementation
│                                — REPLACED by our wiki-brain. See §5
├── scripts/
├── skills/                   # core skills (per-runtime)
├── src/                      # TypeScript: bus, cli, daemon, hooks, types, utils
├── templates/                # agent, orchestrator, analyst (no agent-codex yet on main)
├── tests/
├── ecosystem.config.js       # PM2 ecosystem stub
├── install.mjs               # curl-pipe-node bootstrap
├── CHANGELOG.md
├── CRONS_MIGRATION_GUIDE.md  # confirms crons live at ${CTX_ROOT}/state/{agent}/crons.json
└── package.json
```

### 2.3 Corrections to my earlier synthesis

Two facts I asserted earlier that need correcting because they were wrong against the verified repo:

1. **There is no `templates/agent-codex` directory on `main` today.** I previously implied Codex-runtime agent templates ship with cortextos. They don't. The `runtime` field discussion exists in some forks/PRs but is not in the published v0.1.1. **Consequence:** the Codex ratification loop in §10 runs Codex CLI as an **external tool**, not as a cortextOS agent runtime. We can revisit if/when codex-app-server lands upstream.

2. **CortexOS state lives at `${CTX_ROOT}/state/{agent}/`, not at `~/cortextos/orgs/{org}/agents/{agent}/`.** The README example uses `orgs/myorg/agents/...` for the *workspace* (where you scaffold), but at runtime the daemon writes to `${CTX_ROOT}/state/{agent}/` — confirmed in the CRONS_MIGRATION_GUIDE. `CTX_ROOT` defaults to `~/.cortextos/${CTX_INSTANCE_ID}`. **Consequence:** tenant-isolation plans that assume one filesystem path per tenant need to use `CTX_INSTANCE_ID` as the per-tenant boundary.

### 2.4 The seven primitives we actually use

| # | Primitive | What cortextOS provides | What we layer on |
|---|---|---|---|
| 1 | Persistent PTY via PM2 | `node-pty` + `ecosystem.config.js` regen via `cortextos ecosystem` | Per-tenant ecosystem entries via `cortextos init <tenant>` |
| 2 | 71-hour context rotation | Daemon auto-restarts session before context-limit | Pre-rotation hook to checkpoint agent state to vault |
| 3 | Inter-agent file bus | `bus/` shell wrappers (47 shims execing `node dist/cli.js bus <command>`) + `FastChecker` poll loop in daemon (default 1000ms via `pollInterval` in agent config, configurable per agent) | Our agents drop typed files into the bus; IFOS implements a parallel `wiki-*` surface (see §3.4) rather than overriding `kb-*` |
| 4 | Approval gates | Daemon enforces explicit approval before external action; `manualFireDisabled` flag on crons | Standing approval categories per tenant config |
| 5 | Telegram + iOS approval surface | Bot per agent, `.env` carries `BOT_TOKEN / CHAT_ID / ALLOWED_USER` | Our agents route escalations through this surface; we never build a parallel one |
| 6 | Overnight autoresearch (theta wave) | Analyst-template agents schedule overnight experiments | Night Sourcer + Spec Pitcher use this |
| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |

The dashboard at `/workflows/...`, with test-fire buttons and execution history, is shipped and mature. We **extend** it via additional routes; we do not rebuild it.

---

## 3. The boundary contract — what you must never do

### 3.1 The vendored-submodule rule

`packages/harness/cortextos/` is the cortextOS source code, vendored at a pinned SHA via git submodule. **No file in this tree gets edited.**

Exception, exactly four files: the override pattern in §3.4 below permits us to shadow `bus/kb-search.sh`, `bus/kb-add.sh`, `bus/kb-update.sh`, `bus/kb-list.sh` via our own implementations *in our packages*, while leaving the originals untouched. We never modify the originals.

If you need behaviour the runtime doesn't have, three options in this order:

1. **Build it in our product layer.** Recruitment-specific (a candidate-deduplication helper, an SDS-adequacy parser) → `packages/<our-package>/`. Done.
2. **Open a PR upstream.** Cross-vertical primitive (a better file-bus locking mechanism, a new approval-gate type) → branch off `~/code/cortex-os-upstream/main`, fix it there, open the PR. Do **not** merge to our `packages/harness/cortextos/` SHA until the PR is merged or rejected.
3. **Temporary monkey-patch.** Only if (1) and (2) would block a paying customer this week. Lives in `packages/harness-patches/`, must include a `WHY.md` with the upstream PR link and an expiry date. Quarterly sweep removes anything past expiry.

The test for "cross-vertical": would an accountancy product, an insurance-broker product, or a generic sales-ops product also benefit from this exact change? If yes, PR. If only recruitment benefits, ours.

### 3.2 The Composio/AgentMail adapter boundary

This is the rule that protects the vertical-schema moat from erosion by managed middleware. **Agents call adapters; adapters call execution backends.**

Composio and AgentMail appear ONLY behind the adapter boundary at `packages/vertical-adapters/recruitment/`. No `agent.md`, no `tools.yaml` `required:` block, no eval fixture, no vault file references either tool directly.

| Backend | Path | Why |
|---|---|---|
| Bullhorn, Vincere, Voyager Infinity | `packages/mcp-connectors/{name}/` first-party MCP | Vertical-specific; our moat |
| Acturis, Open GI, SSP, Applied Epic (future) | `packages/mcp-connectors/{name}/` first-party MCP | Same, for insurance |
| Companies House, Xero, QuickBooks, FreeAgent, Sage, HMRC MTD | `packages/mcp-connectors/{name}/` first-party MCP | Vertical-specific or UK-specific |
| Gmail, Outlook, Slack, HubSpot, DocuSign, Calendly, Notion | Via Composio, behind adapter | Commodity SaaS, no vertical specificity |
| AgentMail | v1.1 Inbound Triage only, behind adapter | Inbox provisioning for agent-identity sends |

If a code review finds `composio.gmail.send_email` in an `agent.md` or `tools.yaml`, it's rejected. The adapter speaks vertical vocabulary (`candidate`, `placement`, `brief`); the execution layer is a black box behind it.

### 3.3 The vault / Postgres split

- **Markdown lives in the vault.** Anything human-readable, voice-related, narrative, playbook-like, or that an agent edits and a human reviews.
- **Structured data lives in Postgres.** Anything that needs foreign-key relationships, cross-tenant aggregation queries (read-only, audit-only — RLS still enforces isolation), or that the agent reasons about as state (not content).
- **pgvector indexes over both.** Voice corpus, playbook chunks, decision-log retrieved-context — all embedded.

The vault is the source of truth for voice and playbooks. Postgres is the source of truth for state and provenance. The Brain UI reads both via the `context-assembly` API (the single audit-logged surface).

### 3.4 The brain-replacement boundary — parallel system, not shadow

IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 "four `bus/kb-*.sh` shadow points" edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` + `docs/architecture/second-brain-design.md` for the full design.

This is the single point where the brain swap-out happens. Every other agent, every dashboard route, every approval gate is unchanged. See §5 for the brain itself.

---

## 4. The repo scaffold — Day 0 commands, verbatim

The repo at `~/code/CortexOS/` already exists with `.claude/`, `docs/build-pack/`, `legacy/v1/`, and a partial CLAUDE.md. The Day 0 task is to align the scaffold to this brief's structure without destroying existing work.

### 4.1 Reconcile the existing scaffold

```bash
cd ~/code/CortexOS

# Preserve the existing build pack — it stays as historical context
mv docs/build-pack docs/_archive-build-pack
echo "Archived: see ~/code/CortexOS/docs/_archive-build-pack/ for the prior pack." \
     > docs/_archive-build-pack/README.md

# Create the operative directory structure
mkdir -p docs/{specs,architecture,verticals/recruitment,verticals/_future,decisions,runbooks,build-brief,risk}
mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
mkdir -p packages/brain/{bus-overrides,wiki,graphify,brain-ui}
mkdir -p packages/agents-runtime/_shared/{hooks,fixtures}
mkdir -p agents/recruitment
mkdir -p infrastructure/{docker,terraform,pm2,postgres}
mkdir -p tests/{unit,integration,eval-sets}
mkdir -p .agents/{decisions,learnings,priorities}
mkdir -p .codex/{ratification,evals,scratch}

# Vendor cortextOS as a git submodule at a pinned SHA
git submodule add https://github.com/grandamenium/cortextos.git packages/harness/cortextos
cd packages/harness/cortextos
HARNESS_SHA=$(git rev-parse HEAD)
cd ../../..

# Record the pinned SHA
cat > packages/harness/PINNED-SHA.md <<EOF
# cortextOS pinned commit

Repo: github.com/grandamenium/cortextos
SHA: ${HARNESS_SHA}
Date pinned: $(date -I)
Verified at: ${HARNESS_SHA}

## Updating
\`\`\`
cd packages/harness/cortextos
git fetch origin
git checkout <new-sha>
cd ../../..
git add packages/harness/cortextos packages/harness/PINNED-SHA.md
git commit -m "harness: bump cortextos to <new-sha-short>"
\`\`\`

After every bump: run full test suite + Codex ratification (see §10).
EOF

# .gitignore additions for this repo
cat >> .gitignore <<'EOF'
node_modules/
dist/
.next/
.env.local
.env.*.local
.codex/scratch/
docs/_archive-build-pack/  # the old pack is referenced but not actively part of build
EOF

git add -A
git commit -m "chore: reconcile scaffold against master brief; vendor cortextos@${HARNESS_SHA:0:7}"
```

### 4.2 Copy the operative spec documents in

Drop these (provided in `/mnt/user-data/uploads/` from the founder):

```bash
cd ~/code/CortexOS

# From wherever the .md files currently live
SRCDIR="$HOME/Downloads"  # adjust

cp "$SRCDIR/intelforce-os-recruitment-final-product-spec.md"  docs/specs/PRODUCT-SPEC.md
cp "$SRCDIR/intelforce-os-ultraplan.md"                        docs/specs/ULTRAPLAN.md
cp "$SRCDIR/intelforce-os-cortexos-build-handoff.md"           docs/specs/_archive-build-handoff.md
cp "$SRCDIR/intelforce-os-cortexos-24-7-upgrade-directive.md"  docs/specs/CORTEXOS-24-7-DIRECTIVE.md

# This brief itself is operative
cp /tmp/IFOS-V2-CLAUDE-CODE-BRIEF.md docs/build-brief/00-MASTER-BRIEF.md

git add docs/specs docs/build-brief
git commit -m "docs: import authoritative specs + master brief"
```

If you also have these in your local copies of the planning set (from the prior Claude session output), pull them in too:

- `intelforce-os-internal-business-plan.md` → `docs/specs/INTERNAL-BUSINESS-PLAN.md`
- `intelforce-os-data-layer-and-local-inference.md` → `docs/architecture/DATA-LAYER.md`
- `intelforce-os-composio-and-agentmail-adoption.md` → `docs/architecture/COMPOSIO-AGENTMAIL-ADOPTION.md`
- `intelforce-os-temp-contract-deep-dive.md` → `docs/specs/TEMP-DEEP-DIVE.md`
- `intelforce-os-sovereign-compute-plan.md` → `docs/architecture/SOVEREIGN-COMPUTE.md`
- `00-PATTERN-REFERENCE.md` → `docs/architecture/PATTERN-REFERENCE.md`

### 4.3 The four mandatory Day 0 artefacts

These are created in Claude Code on Day 0 before any code:

| File | Purpose | Source |
|---|---|---|
| `CLAUDE.md` (root) | What Claude Code reads first every session | §13 of this doc, verbatim |
| `.agents/current-priorities.md` | What we're doing this week | `Week 0: clear the §6 checklist` |
| `docs/RISK-REGISTER.md` | Truth-telling instrument, updated weekly | Copy of Ultraplan §10 |
| `docs/architecture/cortexos-primitive-status.md` | One-line audit per primitive | Day 1 task per §6 |

---

## 5. The Obsidian-style wiki + graphify second brain

This is the structural differentiator the founder asked for: cortextOS's stock memory system gets replaced (behind the `bus/kb-*.sh` boundary, see §3.4) with an Obsidian-compatible markdown wiki + graphify graph view. The pattern is Karpathy's LLM-wiki: ingestion → compilation → reflection → query, with the wiki as a git-backed markdown directory and a force-directed graph as the marquee UI surface.

### 5.1 The four-piece structure

```
packages/brain/
├── bus-overrides/                ← The shadow surface (§3.4)
│   ├── kb-search.sh              ← Replaces cortextos/bus/kb-search.sh
│   ├── kb-add.sh                 ← Replaces cortextos/bus/kb-add.sh
│   ├── kb-update.sh              ← Replaces cortextos/bus/kb-update.sh
│   └── kb-list.sh                ← Replaces cortextos/bus/kb-list.sh
│
├── wiki/                         ← The brain's data layer (per-tenant)
│   ├── lib/                      ← TypeScript: ingest, compile, reflect, lint, search
│   │   ├── ingest.ts             ← `kb-add` calls this
│   │   ├── compile.ts            ← LLM-driven raw→wiki transformation
│   │   ├── reflect.ts            ← Health check: contradictions, stale claims, orphans
│   │   ├── lint.ts               ← Frontmatter validation, wiki-link integrity
│   │   ├── search.ts             ← Hybrid: PG FTS + pgvector via RRF
│   │   └── frontmatter-schema.ts ← YAML frontmatter contract
│   │
│   └── per-tenant layout (at /vault/{tenant}/wiki/):
│       ├── raw/                  ← staged source content
│       │   ├── inbox-emails/     ← from email ingestion
│       │   ├── calls/            ← from Fathom/Fireflies transcripts
│       │   ├── briefs/           ← from inbound brief detection
│       │   ├── notes/            ← freeform consultant notes
│       │   └── ats-snapshots/    ← Bullhorn entity snapshots
│       │
│       ├── compiled/             ← LLM-owned, agent-managed
│       │   ├── index.md          ← master index, one-line summary per page
│       │   ├── candidates/       ← one .md per candidate entity
│       │   ├── clients/          ← one .md per client entity
│       │   ├── briefs/           ← one .md per brief
│       │   ├── placements/       ← one .md per placement
│       │   ├── people/           ← contacts at clients, decision-makers
│       │   ├── concepts/         ← firm-specific domain concepts
│       │   │                       (sectors, target patches, fee structures)
│       │   ├── playbooks/        ← firm SOPs and processes
│       │   └── archive/          ← absorbed pages
│       │
│       └── .wiki/                ← compilation state
│           ├── manifest.json     ← per-raw-file compilation status
│           ├── reflect-state.json
│           └── graph.json        ← cached graph for fast UI loads
│
├── graphify/                     ← The graph layer
│   ├── extract.ts                ← Parse [[wiki-links]] from compiled/ into edges
│   ├── enrich.ts                 ← Merge with Postgres entity-graph relationships
│   ├── layout.ts                 ← cytoscape-fcose pre-layout caching
│   └── export.ts                 ← Produce graph.json for the UI
│
└── brain-ui/                     ← The Next.js front-end
    ├── (extends cortextos dashboard/ via additional routes — see §5.3)
    └── (deployable standalone too — same workspace, separate build target)
```

### 5.2 The Karpathy LLM-wiki pattern, adapted for recruitment

The pipeline is **ingest → compile → reflect → search**, with the wiki as authoritative compiled knowledge and the agents as the readers.

1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).

2. **Compile.** A scheduled compile job (per-tenant nightly cron via cortextos `bus add-cron`) reads `raw/*` newer than the last compile, calls Claude (via the runtime; voice-loaded for the tenant), and either creates new pages in `compiled/{type}/{slug}.md` or extends existing ones. Every compiled page has wiki-link backrefs (`[[Candidate: Sarah Bowen]]`) and YAML frontmatter:
   ```yaml
   ---
   id: candidate_sarah_bowen
   entity_type: candidate
   tenant_id: ifos_tenant_acme
   created_at: 2026-05-16T14:32:00Z
   updated_at: 2026-05-16T14:32:00Z
   provenance: [scribe-agent:call-2026-05-16-1432, janitor:bullhorn-2026-05-15]
   importance_score: 0.83
   linked_entities: [[Client: Aragon Labs]], [[Brief: Senior PM Role]]
   ---
   ```

3. **Reflect.** A weekly cron runs the reflect skill — Claude reads sample pages, flags contradictions, stale claims (older than threshold), orphan pages (no inbound links), and missing concepts (mentioned across pages but no canonical page exists). Output goes to `outputs/reflect-{date}.md` and surfaces in the Brain UI as a "wiki health" panel.

4. **Search.** `kb-search "<query>"` is the agent-facing read API. Implementation: Postgres FTS keyword query → pgvector semantic query → reciprocal rank fusion → results returned as JSON. **This is the function every agent calls instead of grepping the vault.** No agent reads `compiled/*.md` directly; everything goes through the search API for cache, RLS, and audit.

### 5.3 The Brain UI — Next.js routes that extend the cortextOS dashboard

cortextOS's existing dashboard at `dashboard/` ships at `localhost:3000` with `/workflows/...` for cron management and execution history. We add routes — we do not rebuild.

The strategy: **same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point.

```
packages/dashboard-ext/
└── src/app/(dashboard)/brain/   ← lives in the cortextos dashboard tree at build time
    ├── page.tsx                  ← /brain — today's decisions feed
    ├── vault/[...path]/page.tsx  ← /brain/vault/<path> — markdown renderer
    ├── entity/[type]/[slug]/     ← /brain/entity/<type>/<slug> — entity profile
    ├── graph/page.tsx            ← /brain/graph — the cytoscape force-directed view
    ├── search/page.tsx           ← /brain/search — full-text + semantic
    ├── decisions/page.tsx        ← /brain/decisions — decision-log browser
    └── health/page.tsx           ← /brain/health — wiki health from reflect.ts
```

Technical stack:

| Concern | Choice | Why |
|---|---|---|
| Framework | Next.js 14 App Router (matches cortextos dashboard) | Drop-in compatible, no version mismatch |
| Markdown render | `react-markdown` + `remark-wiki-link` + `remark-frontmatter` + `rehype-katex` | Honours `[[wiki-links]]`, Obsidian-compatible |
| Graph view | `cytoscape.js` + `cytoscape-fcose` | Mature, fast, handles 10k+ nodes; the marquee view |
| Search | PG FTS + pgvector hybrid via RRF | Already in the data layer; no new service |
| Auth | WorkOS AuthKit (per memory: founder already uses this) | Don't add a second auth system |
| Styling | Tailwind + shadcn/ui + Obsidian-inspired dark theme | "Looks stunning" requirement; matches cortextos dashboard convention |
| Realtime | SSE from `decision_log` writes | No websocket complexity |

### 5.4 What makes it look stunning (concrete UI rules)

The "looks stunning" requirement is a feature. Pin these:

- **Dual-pane Obsidian layout.** Left rail: vault tree + recent searches. Centre: current document/entity. Right rail: backlinks + linked-mentions. Resizable. Collapsible.
- **First-class wiki-link styling.** `[[Candidate: Sarah Bowen]]` renders as a hoverable pill. Hover reveals a 3-line preview popover with entity importance score, last-seen date, and a one-line snippet from the entity's compiled page. Click navigates.
- **The graph view as the closing-demo asset.** Open `/brain/graph` filtered to "everyone we've placed in fintech in the last 12 months". Filter by entity type, time window, importance score. Hover reveals entity cards. Click selects + filters to ego-graph. This is what justifies the Scale tier visually.
- **The "today" page.** Default landing. Timeline feed of every agent decision in the last 24h, colour-coded by agent, expandable to show the drafted output and the consultant's action. Each entry deep-links to `/brain/decisions/{id}`.
- **The voice-quality strip.** Persistent footer showing the rolling 4-week voice classifier score. Green ≥ 0.80, amber 0.70–0.80, red < 0.70. Click for trend graph + recent-edit-pattern callouts. **Voice quality is structurally visible, never hidden.**
- **Dark mode by default.** Obsidian aesthetic. Light mode is a toggle.

### 5.5 The build sequence for the brain

| Stage | When | Scope |
|---|---|---|
| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
| **v1.1 — the wiki proper + today-view** | Q4 2026 | `/brain` (decisions feed) + `/brain/vault/[...path]` (read-only markdown render) + backlinks panel + `wiki-find.sh` + `wiki-history.sh` + `compile.ts` + `lint.ts` + full entity profile pages + wiki-link rendering + search UI |
| **v1.2 — the graph** | Q1 2027 | `graphify/*`, `/brain/graph`, cytoscape rendering — becomes the closing demo |
| **v2.0 — the second brain at scale** | Q3 2027 | Reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views |

### 5.6 Why this isn't an upstream contribution to cortextOS

A wiki/graph brain is recruitment (and eventually accountancy, insurance) product differentiator territory — not structurally cross-vertical runtime. Per §3.1's test: an analyst-style dashboard might be upstream-PRable; a vertical-specific knowledge architecture is product, not runtime. Build it in our layer. The bus-override pattern in §3.4 keeps the boundary clean.

### 5.7 The contract between agents and the brain

- **Agents never read `compiled/*.md` directly.** Always via `kb-search` → JSON results.
- **Agents never write to `compiled/*.md` directly.** They write to `raw/{category}/` and `compile.ts` lifts.
- **The Brain UI never writes.** Reads only, via `context-assembly` API.
- **Humans write to `compiled/*.md`.** Via the Brain UI's markdown editor (v1.2+); via direct git for the founder in v1.0–v1.1.
- **The decision log is append-only** from agents (and from `human_action` telemetry). The Brain UI surfaces it; it does not modify it.

---

## 6. Week 0 — the only thing that matters this week

Per Ultraplan §11. Do not write any agent code until all of these are cleared.

### Day 0 (today) — repo reconciliation

- [ ] Run §4.1 commands; scaffold aligned, cortextos vendored at pinned SHA
- [ ] Run §4.2; specs copied into `docs/specs/`
- [ ] Create root `CLAUDE.md` from §13 of this brief
- [ ] Create `.agents/current-priorities.md`: single line `Week 0: clear the §6 checklist`
- [ ] Initial commit; push to `tarsclaw/intel-force-os-v2`

### Day 1 — Monday — CortexOS primitive audit

The single most important Week 0 task.

- [ ] Write `docs/architecture/cortexos-primitive-status.md`. One line per primitive (1–7 from §2.4). Status: `shipped and tested` / `shipped but flaky` / `documented not built` / `aspirational`. Method:
  - Read `packages/harness/cortextos/README.md`, `CHANGELOG.md`, `CRONS_MIGRATION_GUIDE.md`
  - Scan `packages/harness/cortextos/src/{daemon,bus,hooks}/`
  - Run `cortextos --help`, `cortextos doctor`, `cortextos status` against a freshly-installed instance
  - Have Claude Code do the inspection with you
- [ ] First design-partner sales conversation (pilot candidate A) — founder does this, not Claude
- [ ] If audit reveals primitives 1, 4, or 5 are NOT working today → re-cut Ultraplan §9 sprint plan tomorrow

### Day 2 — Tuesday — Bullhorn integration path

- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: authorization-code grant for production tenants; authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (Bullhorn does not support `client_credentials` grant for tenant-scoped data per Bullhorn OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`). Document in `docs/decisions/bullhorn-integration-path.md`.
- [ ] Design-partner conversation 2

### Day 3 — Wednesday — Sequencing + Brain UI scope

- [ ] Confirm or revise Ultraplan §9's "close first 3 pilots fastest" → `docs/decisions/sequencing-target.md`
- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation.
- [ ] Hire #1 status one-liner

### Day 4 — Thursday — Infrastructure

- [ ] Hetzner Falkenstein (FSN1) or Nuremberg (NBG1) VPS provisioned, LUKS-encrypted volume mounted at `/vault/`. Both are Hetzner eu-central locations with Schrems II EU jurisdiction; either acceptable. Hetzner has no UK data centre as of 2026-05-17 verification per `docs/runbooks/day-4-provisioning.md` §0.1.
- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
- [ ] **RLS test:** two synthetic tenant roles attempt to read each other's data. Kernel-stops-cross-tenant test passes.
- [ ] PgBouncer pinned to per-session tenant roles
- [ ] First MCP connector scoped: `packages/mcp-connectors/bullhorn/tools.yaml` shape documented per `docs/architecture/PATTERN-REFERENCE.md`

### Day 5 — Friday — Safety policy + kill criterion

- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
- [ ] `docs/decisions/v1.0-kill-criterion.md` — the explicit condition under which v1.0 stops shipping (e.g., "If after 3 pilots the average Gate B revenue uplift is <£20k/year per tenant, the wedge is dead and we pivot")

### Day 6 — Saturday (light day) — vertical schema v0.1

- [ ] `docs/verticals/recruitment/vertical-schema.yaml` with the 8 core entities: Candidate, Contractor, Client, Contact, Role/Brief, Placement, Opportunity, Timesheet. Every field, every relationship, every data source.

### Day 7 — Sunday — review

Single-sentence test (Ultraplan §12). Answer each Y/N:

1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"?
2. Does the CortexOS submodule give us primitives 1, 4, and 5 working today?
3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
4. Have we scoped the Agent Bundle v2 refactor and is the work <5 days?
5. Have we drafted the vertical schema v0.1 with the 8 core entities?

**Five yeses → Week 1 starts Monday. Anything less → Week 0 extends.**

Update `.agents/current-priorities.md`, update `docs/RISK-REGISTER.md`, commit.

---

## 7. What to harvest from `intel-force-os-v2` legacy/v1

The v1 codebase at `~/code/intel-force-os/` and the `legacy/v1/` mirror in the v2 repo contain a usable scaffold — but it predates cortextOS and the recruitment vertical. The instinct to "start fresh" is right. Several pieces are still valuable; we harvest them with structural adjustments.

### 7.1 Harvest — bring these across (refactored to v2)

| From v1 (`~/code/intel-force-os/` and `legacy/v1/`) | What it is | New location | Refactor needed |
|---|---|---|---|
| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
| `phase-2-agent-suite/_shared/escalation-codes.md` | Escalation codes | `packages/agents-runtime/_shared/escalation-codes.md` | Expand to recruitment vocabulary |
| `phase-2-agent-suite/_shared/universal-banned-phrases.txt` | AI-tell phrases | `packages/agents-runtime/_shared/universal-banned-phrases.txt` | Verbatim |
| `phase-1-poc-stack/platform-specs/minimal-vault-structure.md` | Vault layout | `docs/architecture/vault-structure.md` | Update to recruitment frontmatter schema |
| `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md` | Fastify webhook router | `packages/webhook-receiver/` | Routing logic adapted to bus-drop instead of Unix socket |
| `00-PATTERN-REFERENCE.md` | 6-file agent bundle pattern | `docs/architecture/PATTERN-REFERENCE.md` | Update to v2: `99-voice-drift-canary` fixture required |
| Proposal Builder bundle (entire) | Most-complete pattern example | `agents/_reference/proposal-builder/` | REFERENCE-ONLY (we read it, we don't ship it) |
| v1 dashboard's TypeScript components (whatever lifts cleanly) | Some primitives may be salvageable | `packages/dashboard-ext/src/components/` | Audit case-by-case; mostly rebuild |

### 7.2 Leave behind — these do not get migrated

| From v1 | Why not |
|---|---|
| The 9-agent consulting suite (Lead Hunter, Content Creator, Repurposer, etc.) | Different vertical, different prompts, different output contracts. Reference only. |
| The v1 dashboard as a whole app | Replaced by `packages/dashboard-ext/` extending the cortextos dashboard. |
| The v1 provisioning system | The 5-day onboarding wizard (Spec §5.2) is the new shape. |
| `vault-syncer` (v1) | Needs to coordinate with the file-bus contract. Build fresh. |
| `cc-invoke` | CortexOS PM2-supervised PTY replaces per-invocation-spawn. |

### 7.3 The "skeleton-ready" principle

Per founder pattern: build documentation at skeleton-ready level (SQL schemas, Python pseudocode, worked examples) before code.

- Every agent bundle: `README.md` + `agent.md` (output contract first) before the four supporting files
- Every MCP connector: `tools.yaml` + OpenAPI spec walkthrough before code
- Every Postgres table: `CREATE TABLE` + RLS policy + indexes in `docs/architecture/postgres-schema.sql` before migration runs

---

## 8. The agent bundle v2 pattern

Every agent — front-office and temp — is exactly these files. No exceptions.

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
        ├── 02-edge-case-{name}/        # ≥1 required. From workflow analysis.
        │   ├── input.json
        │   └── expected.md
        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
            ├── input.json              # Same input, run weekly in CI
            └── expected.md             # Output diffed against historical
```

**The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly.** The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The `cortextos-ifos add-agent` command is **NOT** the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want.

### 8.1 The three v2 changes (Ultraplan §4.2)

**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.

**Change 2 — Decision logging is enforced.** Three required calls per agent run:

```bash
hh_decision_trigger   # at start; logs trigger
hh_decision_output    # on output; logs the artefact
hh_decision_action    # when human acts; logs the action
```

`validate.sh` hard-fails on missing calls. This is what enables the v2.0 LoRA pipeline — no decision log, no SFT corpus, no Scale-tier moat.

**Change 3 — Escalation codes expand to recruitment vocabulary.** ~20–30 codes. Examples:

- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
- `ESC_BULLHORN_AUTH` — OAuth token expired/revoked
- `ESC_DUPLICATE_DETECTED` — high-confidence dedup needs human review
- `ESC_JSL_RED_FLAG` — Supply Chain Auditor detected red flag
- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
- `ESC_SCHEMA_VIOLATION` — agent produced output violating vertical schema

Build the catalogue in Week 0. New codes only when production demands one.

### 8.2 The build order — v1.0 only

| # | Agent | Weeks | Key dependency | Why this order |
|---|---|---|---|---|
| 1 | Diagnostic | 3–4 | LinkedIn + Companies House + scrape | Sales tool — needed before any other agent matters |
| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |

After Concierge ships, week 14 milestone: first pilot converts to paid.

**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).

### 8.3 The working pattern in Claude Code

For any new agent:

```bash
git checkout -b agent/{name}                       # e.g. agent/janitor
mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}

# In Claude Code, work the bundle through 6 files in this order:
# 1. README.md (2-min overview)
# 2. agent.md (OUTPUT CONTRACT FIRST, then workflow, then gates, then escalation)
# 3. config.schema.json (what the wizard collects)
# 4. tools.yaml (MCP servers + scopes + degraded modes)
# 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
# 6. context.sh (hydrates CONTEXT via context-assembly API)

# Then the three fixtures with golden outputs.
# Test against fixtures; iterate; commit; PR; merge.

# After merge, render the bundle for each tenant that uses this agent:
cortextos-ifos render-agent {name} --tenant <slug>
# For all active tenants (v1.1+): cortextos-ifos render-agent {name} --all-tenants
# Activate: pm2 restart ifos-daemon   (for new agents)
#       OR: cortextos-ifos bus self-restart {name}   (for re-renders of running agents)
```

The Proposal Builder bundle (v1) is the canonical reference. **Read it before writing your first new agent.**

---

## 9. The data layer in one diagram

```
                                                  ┌──────────────────────────────┐
                                                  │  BRAIN UI                    │
                                                  │  packages/dashboard-ext/     │
                                                  │  → extends cortextos         │
                                                  │     dashboard at /brain/*    │
                                                  │  Next.js 14, cytoscape,      │
                                                  │  react-markdown +            │
                                                  │  remark-wiki-link            │
                                                  └──────────────┬───────────────┘
                                                                 │ read only
                                                                 ▼
                                            ┌──────────────────────────────────────┐
                                            │  CONTEXT-ASSEMBLY API                │
                                            │  packages/context-assembly/          │
                                            │  Only thing that reads data layer.   │
                                            │  Audit-logged. RLS-aware.            │
                                            └──┬──────────┬──────────┬─────────────┘
                                               │          │          │
                  ┌────────────────────────────┘          │          └────────────────────────────┐
                  ▼                                       ▼                                       ▼
        ┌─────────────────┐                  ┌────────────────────────┐                  ┌────────────────────┐
        │ THE VAULT       │                  │ ENTITY GRAPH (PG)      │                  │ DECISION LOG (PG)  │
        │ /vault/{tenant}/│                  │ entities +             │                  │ tenant_decisions   │
        │ Includes wiki/  │                  │ entity_relationships   │                  │ tenant_eval_sets   │
        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
        │ Obsidian-       │                  │ pgvector embeddings    │                  │ RLS-isolated       │
        │ compatible MD + │                  └─────────┬──────────────┘                  └─────────┬──────────┘
        │ frontmatter     │                            │                                           │
        │ POSIX 0700      │                            │                                           │
        │ git-backed      │                            │                                           │
        └────────┬────────┘                            │                                           │
                 │                                     │                                           │
                 │ writes via kb-add                   │ writes via                                │ writes via
                 │  → bus-overrides                    │   entity-graph svc                        │   hh_decision_*
                 │                                     │                                           │
        ┌────────┴─────────────────────────────────────┴───────────────────────────────────────────┴────────┐
        │                                                                                                  │
        │                                         AGENTS                                                   │
        │   Run under PM2 process groups managed by cortextOS daemon                                       │
        │                                                                                                  │
        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
        │   v1.1 (+7): Inbound Triage, Brief Decoder, Night Sourcer, Competitor Interception,              │
        │              Client Hunter digest, T5 Supply Chain Auditor, T3 Compliance Watchtower             │
        │   v1.2 (+5): Real-Time Pulse, Spec Pitcher, Reporting, T1 Onboarding Concierge, T2 Timesheet     │
        │   v2.0 (+3): T4 IR35, T6 Pay & Bill, per-firm LoRA pipeline                                      │
        │                                                                                                  │
        └────────┬─────────────────────────────────────────────────────────────────────────────────────────┘
                 │ tools via tools.yaml
                 ▼
        ┌────────────────────────────────────────────────────────────────────────────────────────────┐
        │  VERTICAL ADAPTERS   packages/vertical-adapters/recruitment/                               │
        │  Speak canonical vocabulary (candidate, placement, brief). Translate to backends.          │
        └────────┬───────────────────────────────────────────────────────────────────────────────────┘
                 ▼
        ┌────────────────────────────────────────────────────────────────────────────────────────────┐
        │  EXECUTION BACKENDS                                                                        │
        │  • First-party MCP  packages/mcp-connectors/: Bullhorn, Companies House, Xero, etc.        │
        │  • Composio (commodity SaaS): Gmail, Outlook, Slack, HubSpot                               │
        │  • AgentMail (v1.1 Triage only): agent-identity inbox                                      │
        │  • Direct vendor API: Microsoft Graph delegated send, Proxycurl LinkedIn                   │
        └────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 10. The Codex ratification loop — second-pair every critical decision

The founder asked specifically to ratify work through Codex and feed back to Claude Code. Because cortextOS does not (yet) have a first-class Codex runtime upstream, we run Codex as an **external CLI tool**, not as a cortextOS agent.

### 10.1 Why this loop matters

For a one-shot build of this size, single-model reasoning is risky. Claude and Codex (`gpt-5-codex`) catch different classes of mistakes:

- Claude tends to over-elaborate on architecture; Codex is more conservative
- Codex catches type/build issues more reliably; Claude catches semantic/specification issues
- **Disagreements between them are the most valuable signal** — that's where the spec is ambiguous and needs founder decision

### 10.2 Setup (Day 0–1)

Install Codex CLI as part of the dev environment, not cortextOS. Drop the ratification skills under `.codex/ratification/`:

| File | Purpose |
|---|---|
| `SKILL.md` | Top-level "what does ratify mean" — checks against the five rules + the boundary |
| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
| `review-mcp-connector.md` | Specific checklist for a new MCP connector |
| `review-schema-change.md` | Specific checklist for `vertical-schema.yaml` edits |
| `review-postgres-migration.md` | Specific checklist for new tables, RLS policy changes |
| `review-architecture-decision.md` | Specific checklist for ADRs in `docs/decisions/` |
| `review-harness-bump.md` | Specific checklist when bumping the pinned cortextos SHA |

Each skill has the same shape: takes a diff or file set, checks against the five rules + the relevant spec doc, returns either `RATIFIED` (with optional minor notes) or `REJECTED` (with concrete issues numbered).

### 10.3 The working loop

Per change of meaningful size:

1. **Claude Code** produces the artefact on a feature branch
2. **You** run: `codex review --skill .codex/ratification/review-{type}.md --target {path-or-diff}`
3. **Codex** returns RATIFIED or REJECTED with concrete issues
4. **Claude Code** reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)
5. After ≤ 2 round-trips, merge. Still disagreeing? Escalate to founder to decide.

### 10.4 What never goes through ratification

- Comment-only changes
- Test fixture additions (fixtures themselves are the ratification)
- Documentation typos
- Build/deps version bumps
- Anything entirely inside `.agents/` (working notes)

### 10.5 What ALWAYS goes through ratification

- Every new `agent.md` before merge
- Every change to `docs/verticals/recruitment/vertical-schema.yaml`
- Every new MCP connector
- Every Postgres migration touching tenant data
- Every change to `agents/_shared/`
- Every change to `packages/brain/bus-overrides/`
- Every architectural decision record
- Every bump of the pinned cortextos SHA
- Every change to this brief itself (yes, recursive — Codex reviews changes to its own instructions)

### 10.6 The ratification timeline

For Week 0:
- Day 1: build the `.codex/ratification/*.md` skills (Claude does this; we don't ratify the ratification skills until Day 7)
- Day 7: Codex reviews the seven Week 0 artefacts (primitive audit, Bullhorn path, Brain UI scope, infra checklist, safety policy, kill criterion, vertical schema v0.1) — first ratification run

After Week 0:
- Every agent bundle is ratified before merge (mean cost: 20–30 min including round-trip)
- Every schema change is ratified before merge (mean cost: 10–15 min)
- Weekly ratification of risk register changes (informal — 5 min spot-check)

---

## 11. Working patterns in Claude Code

### 11.1 What Claude Code is good at on this project

- `agent.md` files given an output contract — long, structured, opinionated prompts are its sweet spot
- `_shared/` shell helpers (voice loader, decision-log writer, validate primitives)
- MCP connectors given OpenAPI spec + `tools.yaml` shape
- Test fixtures (input.json + expected.md pairs)
- YAML schema review for consistency with `vertical-schema.yaml`
- Postgres migrations from `CREATE TABLE` in `docs/architecture/postgres-schema.sql`
- Runbooks (`docs/runbooks/`) for operational scenarios
- Customer-facing docs once agents are stable
- `packages/brain/wiki/lib/*.ts` — the wiki ingest/compile/reflect pipeline

### 11.2 What Claude Code is NOT good at on this project

Do these yourself:

- Deciding the output contract — sales/product call, made with a real prospect
- Picking which agent to build next — depends on pilot conversations (Ultraplan §9)
- Negotiating Bullhorn marketplace terms — phone call
- The single-sentence test — your honest answer, not Claude's optimistic one
- Anything where the temptation is "let me just edit `packages/harness/cortextos/...`" — stop, re-read §3.1

### 11.3 The session-start ritual

First prompt of every Claude Code session:

> Read `CLAUDE.md`, then `docs/build-brief/00-MASTER-BRIEF.md` §1, §3, §6, §8, §10. Confirm understanding of:
> 1. The five rules
> 2. The cortextOS boundary (no edits to `packages/harness/cortextos/`)
> 3. The Composio/AgentMail adapter boundary
> 4. The brain-replacement boundary (the four `bus/kb-*.sh` overrides; everything else hands off)
> 5. The agent bundle v2 pattern
> 6. The Codex ratification loop
>
> Then read `.agents/current-priorities.md` and propose the concrete plan for today.

### 11.4 The session-end ritual

Last prompt of every working session:

> Update `.agents/current-priorities.md` with what shipped, what's stuck, what changed. If anything new goes on the risk register, update `docs/RISK-REGISTER.md`. Commit with a sensible message. If anything is queued for Codex ratification, list it.

### 11.5 The error-signal table

| If Claude proposes... | Re-read |
|---|---|
| "Let me edit `packages/harness/cortextos/...`" | §3.1 |
| "Let me hardcode the client's name as 'Acme'..." | Rule 2 in §1 |
| "Let me have this agent log directly..." | Rule 3 in §1 |
| "Let me skip the test fixtures for now..." | §8 |
| "Let me build Triage first because it's the most exciting..." | §8.2 |
| "Let me use Composio for the Bullhorn connector..." | §3.2 |
| "Let me ship without the kill criterion documented..." | §6 Day 5 |
| "Let me modify the cortextos stock knowledge base..." | §3.4, §5 |
| "Let me skip the Codex ratification — it's a small change..." | §10.5 |

Same mistake twice → write the symptom into `.agents/learnings/` so future-you reads it.

---

## 12. The risk register — the four that could kill v1.0

Verbatim from Ultraplan §10. Full register at `docs/RISK-REGISTER.md`, weekly updates.

| # | Risk | Tripwire | Mitigation |
|---|---|---|---|
| 1 | CortexOS primitives 3 or 4 are flaky in production | Daily orchestrator health check flags > 1 incident/week | Every Tier-1 agent has a degraded-mode fallback (drafts-only, scheduled retry) that runs if cortextOS state is unhealthy; manual file-bus handoff documented |
| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
| 3 | First design partner not signed by end of Week 0 | Week 0 ends without LOI | Sales conversations start before Week 0. Do NOT begin agent code until first LOI lands. |
| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |

---

## 13. The condensed `CLAUDE.md` for the repo root

Drop this verbatim at `~/code/CortexOS/CLAUDE.md`. It supersedes the existing CLAUDE.md (which keeps the path table and red lines, but defers all build-pack references to this master brief).

```markdown
# Intel Force OS v2 — Claude Code Instructions

**Loaded by Claude Code at the start of every session. Read first.**

## What this is
Recruitment-operations product for UK agencies, built on cortextOS (`packages/harness/cortextos/`,
vendored git submodule at a pinned SHA, READ-ONLY). Multi-tenant. 18 agents at full strength,
6 in v1.0. Obsidian-style wiki + graph second brain replaces the stock cortextOS knowledge base
behind the four `bus/kb-*.sh` shell entrypoints.

## Master brief
`docs/build-brief/00-MASTER-BRIEF.md` — the operative one-stop brief. Read in full at session
start. The build pack at `docs/_archive-build-pack/` is historical; the master brief wins on
every point of conflict.

## The five rules — NON-NEGOTIABLE
1. Output before architecture
2. Schema before code
3. Reuse before build
4. Quality gates before features
5. Honest signal before optimistic projection

## The boundary
- Never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` files we shadow via
  `packages/brain/bus-overrides/`. The originals stay untouched.
- Cross-vertical primitive fix? → PR to `~/code/cortex-os-upstream/`, then bump our pin.
- Recruitment-specific? → our `packages/`, `agents/recruitment/`.
- Never reference Composio or AgentMail in `agent.md`, `tools.yaml`, vault files, or fixtures —
  they live behind `packages/vertical-adapters/`.

## Canonical paths
| What | Path |
|---|---|
| v2 codebase (this one) | `~/code/CortexOS/` |
| v1 codebase (alive, no modify) | `~/code/intel-force-os/` |
| cortextOS upstream reference | `~/code/cortex-os-upstream/` |

## Current state
**Phase:** pre-Phase-0. Founder must clear Week 0 checklist
(`docs/build-brief/00-MASTER-BRIEF.md` §6) before agent code starts.
**Next slice:** Day 0 — scaffold reconcile + spec import per §4.

## This week
See `.agents/current-priorities.md`.

## The agent bundle pattern (v2)
6 files + 3 fixtures per agent. See `docs/architecture/PATTERN-REFERENCE.md`.
The Proposal Builder bundle in `agents/_reference/` is the canonical example.

## The Codex ratification loop
Every new agent.md, every schema change, every connector, every ADR, every harness SHA bump
goes through `codex review --skill .codex/ratification/review-{type}.md --target {path}` before
merge. See master brief §10.

## Session-start ritual
1. Read this file, then master brief §1, §3, §6, §8, §10
2. Confirm the five rules + the four boundaries
3. Read `.agents/current-priorities.md`
4. Propose today's plan

## Session-end ritual
1. Update `.agents/current-priorities.md`
2. Update `docs/RISK-REGISTER.md` if anything new emerged
3. List anything queued for Codex ratification
4. Commit with a sensible message

## On being stuck
1. Check the master brief §-references first
2. Check `.agents/learnings/` for prior solutions to the same symptom
3. Check Codex's prior ratifications for related artefacts
4. Ask the founder. Don't guess.

## Never (red lines)
- Don't modify `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points
- Don't modify v1 at `~/code/intel-force-os/`
- Don't modify cortextOS upstream at `~/code/cortex-os-upstream/`
- Don't add features without a corresponding slice in the master brief
- Don't skip Codex ratification at phase boundaries
- Don't relitigate the master brief without writing the disagreement to `docs/decisions/`
```

---

## 14. The first prompt Claude Code receives, verbatim

After §4.1 and §4.2 are run, open Claude Code in the repo:

```bash
cd ~/code/CortexOS && claude .
```

Paste this as the first message:

> Read `CLAUDE.md`, then `docs/build-brief/00-MASTER-BRIEF.md` in full. Then read `docs/specs/PRODUCT-SPEC.md` §0–§4 and §10 (the single-sentence list), and `docs/specs/ULTRAPLAN.md` §1, §3, §4, §9, §11. Skim `docs/architecture/PATTERN-REFERENCE.md`.
>
> Confirm in your response:
> 1. You can list the five rules
> 2. You understand the cortextOS submodule boundary
> 3. You understand the Composio/AgentMail adapter boundary
> 4. You understand the brain-replacement boundary (the four `bus/kb-*.sh` overrides)
> 5. You understand the agent bundle v2 pattern (6 files + 3 fixtures, incl. 99-voice-drift-canary)
> 6. You understand the Codex ratification loop and which artefacts always go through it
>
> Then read `.agents/current-priorities.md` and propose the concrete plan for today. We are on Week 0; today's task is whichever Day in §6 we're on. **Do not write any agent code until Week 0 is cleared per the §6 Day 7 test.**

From there, the build is just doing the work one day at a time: §6 this week, then Ultraplan §9 for the 14 weeks of v1.0, then Spec §9 for v1.0 → v2.0.

---

## 15. The contract with future-you

When you read this brief again in three months, you will be tempted to:

- Skip Week 0 because "we've already started building"
- Edit `packages/harness/cortextos/...` because "it'll be faster than upstreaming"
- Ship an agent without a 99-voice-drift-canary because "we'll add it later"
- Drop a customer name into a prompt because "it's just this one tenant"
- Mark the kill criterion as "soft" because "the pilot is going well"
- Use Composio for Bullhorn because "the catalogue says they have it" (they don't, and even if they did, see §3.2)
- Skip ratifying a change through Codex because "it's only a small change"
- Modify the stock cortextOS knowledge base directly because "shadowing is more complicated than it needs to be"

Don't. Each is a post-mortem chapter waiting to be written. The five rules, the four boundaries (submodule, adapter, vault/PG split, brain-replacement), and the ratification loop are what keep this thing buildable by one person, then two, then ten.

The structural moat is not the agents. It is:

1. **The vertical schema** — recruitment vocabulary, never CRM vocabulary
2. **The agent bundle pattern** — compounding reusability across 18 agents
3. **The decision log + per-firm LoRA pipeline** — Scale-tier defensibility
4. **The boundary with cortextOS** — we get the moat, they keep building runtime
5. **The wiki + graph brain** — the visible "second brain" that closes Scale-tier deals
6. **The quality gates** — Gate A binary per-run, Gate B 90-day, Gate C weekly voice classifier

Hold those, and the agents are exercises in execution.

---

## Document control

| Version | Date | Author | Notes |
|---|---|---|---|
| 1.0 | 16 May 2026 | Maddox + Claude | First-principles synthesis: verified against `cortextos@0.1.1` and `tarsclaw/intel-force-os-v2` HEAD; ignores the inherited build pack per founder instruction; integrates the Karpathy LLM-wiki pattern as the second-brain blueprint; corrects two earlier assertions about cortextOS internals; specifies the four-file `bus/kb-*.sh` shadow as the single brain-replacement seam. |

*End of master brief. Drop at `docs/build-brief/00-MASTER-BRIEF.md`. Re-read §1, §3, §6, and §10 weekly.*
