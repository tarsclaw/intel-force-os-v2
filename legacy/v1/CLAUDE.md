# Intel Force OS — System-Level Project Context

**This file is loaded by Claude Code at the start of every session. Read it first.** It's the top-level map of Intel Force OS — what it is, what exists, where everything lives, and how to navigate.

---

## What Intel Force OS is

**Intel Force OS** is a multi-agent AI platform delivered primarily as a Microsoft Teams app, serving UK small and medium enterprises (20–200 employees). The platform hosts a suite of AI agents — HR is first, Sales/Recruiting/Operations follow — each operating under a consistent governance model: **everything drafts, nothing sends without human approval.**

**Operating entity:** Intel Force Ltd (UK) | **Primary domain:** intelforce.ai  
**Target:** £100k ARR by month 12; scaling to £1M ARR by month 24  
**Current state:** 0 paying customers, fully specified platform, working Relevance AI HR agent

### The product thesis in one paragraph

UK SMEs have Microsoft 365 deployed but almost no AI-assisted operations. Enterprise AI tools are too expensive and too complex for them; consumer AI (ChatGPT) is too generic and has no governance. Intel Force OS sits in the gap: Teams-native, governed (approvals + audit), specialised (HR first, expanding), priced for SME (£400-£4,500/month tiers), and delivered as a service rather than a tool. The wedge is HR (clear ROI, universal need, clean integration with Breathe HR). The expansion is horizontal: Sales, Recruiting, Ops agents share the same Teams app and governance rails.

### The non-negotiable invariants

1. **Everything drafts, nothing sends without human approval.** Applies to every agent. Holding replies for escalations are the only auto-sent messages.
2. **Sensitive queries never get AI-drafted answers.** Sensitivity ≥ 0.7 always routes to human-only handling.
3. **The human decision-maker is the trust anchor**, not the employee/prospect/candidate. Features serve their confidence.
4. **One Teams app, many agents.** Customers install Intel Force OS once and new agents light up over time.
5. **Customer side: zero Azure.** Install = upload app zip + click admin consent.
6. **Data residency:** customer data passes through Cloudflare (UK/EU) and Relevance AI (US with UK-US data bridge). Audit central in D1. GDPR-documented deletion + export procedures.

---

## The full scope of Intel Force OS — 163 files across 8 packs

The complete specification exists in `docs/` — **do not duplicate anything here; always reference docs by path.**

### Pack summary

| Pack | Location | Files | Lines | Status |
|---|---|---|---|---|
| **Strategic foundation** | `docs/phase-0-strategic/` | 6 | ~2,300 | Complete |
| **Phase 1 — POC stack** | `docs/phase-1-poc-stack/` | 16 | ~4,800 | Complete, never executed |
| **Phase 2 — Agent suite** | `docs/phase-2-agent-suite/` | 78 | ~12,400 | Complete |
| **Phase 3 — Platform** | `docs/phase-3-platform/` | 9 | ~3,287 | Complete, v2 target |
| **Phase 4 — Dashboard** | `docs/phase-4-dashboard/` | 11 | ~4,543 | Complete, v1.5 target |
| **Phase 5 — Business/Legal** | `docs/phase-5-business-legal/` | 14 | ~6,508 | Complete |
| **Phase 6 — Ops Runbooks** | `docs/phase-6-ops-runbooks/` | 13 | ~6,366 | Complete |
| **Teams HR Agent** | `docs/teams-hr-agent/` | 8 | ~4,742 | Complete, v1 build target |
| **GTM HR Agent** | `docs/gtm-pack/` | 9 | ~2,089 | Complete, active |

**Total: ~40,600 lines of specifications.**

Full catalog with file-by-file detail: `MASTER-INDEX.md` (at project root).

### Which packs are active right now

- **GTM Pack** (active) — customer acquisition, pricing, onboarding scripts
- **Teams HR Agent pack** (active) — the v1 build target
- **Phase 5 Business/Legal** (reference) — MSA, DPA, pricing spec used per customer
- **Phase 6 Ops Runbooks** (dormant) — kicks in when customer 1 is live

### Which packs are deferred

- **Phase 1 POC** (never executed; may be retired if Teams HR Agent pack supersedes)
- **Phase 2 Agent Suite** (templates for agents 2-10; consult when building Sales agent, etc.)
- **Phase 3 Platform** (v2 architecture — Postgres, Temporal, multi-tenant infra; consult at customer 10+)
- **Phase 4 Dashboard** (v1.5 — web dashboard; consult when Tab experience is needed)

---

## Repository layout

```
intel-force-os/
├── CLAUDE.md                          ← You're reading this
├── MASTER-INDEX.md                    ← Full catalog of specs
├── .claude/
│   ├── settings.json                  ← MCP server config
│   ├── skills/                        ← Navigational + domain skills (13 files)
│   │   ├── intel-force-os-system/
│   │   ├── teams-hr-agent/
│   │   ├── gtm-execution/
│   │   ├── phase-1-poc/
│   │   ├── phase-2-agents/
│   │   ├── phase-3-platform/
│   │   ├── phase-4-dashboard/
│   │   ├── phase-5-business-legal/
│   │   ├── phase-6-ops-runbooks/
│   │   ├── relevance-ai/
│   │   ├── adaptive-cards/
│   │   ├── bot-framework-teams/
│   │   └── cloudflare-intel-force/
│   ├── commands/                      ← Slash commands (8 files)
│   └── agents/                        ← Subagent specs (2 files)
├── docs/
│   ├── phase-0-strategic/             ← Foundational strategy docs
│   ├── phase-1-poc-stack/             ← POC experiment artifacts
│   ├── phase-2-agent-suite/           ← All 10 agent specs
│   ├── phase-3-platform/              ← Multi-tenant platform spec
│   ├── phase-4-dashboard/             ← Dashboard spec
│   ├── phase-5-business-legal/        ← Legal, pricing, sales
│   ├── phase-6-ops-runbooks/          ← Incident, DR, compliance runbooks
│   ├── teams-hr-agent/                ← Teams HR Agent architecture pack
│   └── gtm-pack/                      ← Go-to-market for first customers
├── src/                               ← Worker code (Teams HR Agent)
│   ├── index.ts
│   ├── bot/
│   ├── cards/
│   ├── agents/
│   ├── storage/
│   └── utils/
├── teams-app/                         ← Teams app manifest + icons
├── migrations/                        ← D1 schema migrations
├── onboarding/                        ← Per-customer CLI tools
├── tests/
└── dist/                              ← Build output (git-ignored)
```

**Critical principle:** everything under `docs/` is read-only reference material. Do not modify spec files during implementation unless explicitly asked. If the implementation diverges from the spec, surface the divergence as a question — don't silently "fix" the spec to match.

---

## Current build state tracker

**Update this section as work progresses. It's the fastest way for a new session to know where you are.**

### Active build: Teams HR Agent v1

Build slices (from `docs/teams-hr-agent/07-claude-code-prompts.md`):

| Slice | Description | Status |
|---|---|---|
| Stage A | Environment setup | [x] |
| Stage B | Azure bootstrap (Entra ID + bot registration) | [ ] — **needs `az login` + your credentials** |
| Stage C | Cloudflare Worker scaffold | [x] |
| Stage D | Bot auth + message handler | [x] |
| Stage E | Anthropic API integration (custom runtime — Relevance AI retired) | [x] |
| Stage F | Adaptive Cards + approval flow | [x] |
| Stage G | Storage (KV + D1) | [x] |
| Stage H | Weekly report cron | [x] |
| Stage I | Teams manifest + sideload | [x] — **needs real icons + Azure bot ID** |
| Stage J | End-to-end smoke tests | [ ] — **needs deployed Worker + dev tenant** |
| Stage K | Per-customer onboarding script | [x] |
| Stage L | CI/CD + monitoring | [x] |

**Agent runtime:** Anthropic API direct via `@anthropic-ai/sdk`. Relevance AI fully retired.
**To deploy:** complete Stage B → paste KV/D1 IDs into `wrangler.toml` → `wrangler secret put` × 3 → `wrangler deploy`.

### Dashboard build: `apps/dashboard/`

| View | Route | Status |
|---|---|---|
| Shell (sidebar + mobile bottom bar) | layout | [x] — Fraunces font, Phase 0 tokens |
| Overview | `/t/[slug]` | [x] — greeting, KPI tiles, approvals preview, activity, system status |
| Approvals queue | `/t/[slug]/approvals` | [x] — full approval cards, approve/edit/reject/escalate |
| Agents hierarchy | `/t/[slug]/agents` | [x] — SVG hierarchy visualization |
| Activity timeline | `/t/[slug]/activity` | [x] — date-grouped, Phase 0 styled |
| Analytics | `/t/[slug]/analytics` | [x] — recharts volume/cost/severity/summary |
| Knowledge | `/t/[slug]/knowledge` | [x] — handbook + Breathe HR status |
| Settings | `/t/[slug]/settings` | [x] — 7 panels (pre-existing) |
| Worker `/api/approve` | src/index.ts | [x] — web portal approval sends Teams reply |

**New env vars needed (dashboard):**
- `WORKER_URL` — Cloudflare Worker base URL (e.g. `https://intel-force-os-bot.workers.dev`)
- `PORTAL_API_KEY` — shared secret (also set as `wrangler secret put PORTAL_API_KEY`)

**Deployment target:** `dashboard.intelforce.ai`

### Parallel business track

| Milestone | Status |
|---|---|
| 10 prospects contacted | [ ] |
| 3 demos booked | [ ] |
| First paying customer (£400 MRR) | [ ] |
| First case study published | [ ] |

### Deferred (revisit triggers)

- **Sales agent** — trigger: 3 HR customers live, one asks for Sales
- **Phase 3 platform migration** — trigger: 30+ customers OR enterprise deal requiring per-tenant infra
- **Phase 4 dashboard polish** — framer-motion transitions, cmdk command palette, nuqs URL state
- **Teams App Store listing** — trigger: 10 customers, self-serve onboarding viable
- **Slack variant** — trigger: 3 prospects lost to "we're not on Teams"

---

## How Claude Code should work across this system

### Progressive disclosure principle

Do NOT attempt to load all 40,600 lines of specs into context. Context window is finite; filling it with specs means no room for code.

Instead:
- **CLAUDE.md** (this file) gives the map
- **Skills** load topic-specific context when description matches the task
- **Specific spec files** are read on demand when Claude Code needs them for a concrete task
- **Search tools** (Cloudflare docs MCP, code-aware search) retrieve targeted snippets

When you (Claude Code) face a question, the navigation order is:

1. Can I answer from what I already have loaded? Yes → answer.
2. Is there a skill whose description matches? If so, load it and re-check.
3. Is the answer in a specific spec file? Read the minimal section needed (use `view` with `view_range`, don't load whole files unless small).
4. Is the answer external (Cloudflare, Microsoft, Relevance AI)? Use docs MCPs or web fetch.
5. Still stuck? Ask the user for clarification before guessing.

### When starting a new session

1. **Always** start with `/session-start` — it scopes the session and prevents drift.
2. Identify which pack the work belongs to (Teams HR Agent? GTM? Phase 3?). This tells you which skill should be active.
3. Read the "Current build state tracker" above to know where the previous session left off.
4. State the scope back to the user before taking action.

### When navigating packs

Use the `/load-phase` command to pull the right context for a specific phase. Example:

- Working on platform scaling? `/load-phase phase-3`
- Designing a new agent? `/load-phase phase-2`
- Legal review? `/load-phase phase-5`

See also `MASTER-INDEX.md` for the lookup table of every file.

### When searching across specs

Use `/search-specs "keyword"` to find mentions across all docs. Often faster than reading multiple files.

---

## Tech stack — the current and planned

### v1 (Teams HR Agent — active build)

| Layer | Tech | Why |
|---|---|---|
| Bot runtime | Cloudflare Workers | Free tier, edge, no Azure App Service |
| Language | TypeScript strict | Bot Framework protocol has quirks; types help |
| Bot SDK | `botbuilder` | Microsoft official |
| Card rendering | `adaptivecards-templating` | Schema 1.5 universal |
| Config store | Cloudflare KV | Per-tenant config |
| Audit log | Cloudflare D1 | SQLite at edge, cheap |
| Agent brain | Relevance AI | Existing work; swap to Claude later |
| Deployment | `wrangler deploy` | One-command |
| Tests | Vitest | Workers-compatible |

### v1.5 (Tab dashboard — deferred)

| Layer | Tech | Notes |
|---|---|---|
| Web app | Next.js 15 | Per Phase 4 spec |
| Auth | Teams SSO | Free for Tabs |
| Database | Same Cloudflare D1 | Shared with Worker |
| Hosting | Cloudflare Pages | Stays in Cloudflare |

### v2 (Phase 3 platform — deferred)

| Layer | Tech | Notes |
|---|---|---|
| Orchestration | Temporal Cloud | Per Phase 3 spec |
| Database | Postgres (Neon / Supabase) | Per-tenant schemas |
| Agent runtime | Cloudflare Workers + possibly Fly.io for longer-running tasks | Split hot/cold paths |
| Secrets | AWS KMS per Phase 3 spec | Replaces Wrangler secrets |
| Observability | Datadog / Grafana | Per Phase 3 §observability |

---

## Code conventions (apply everywhere)

### TypeScript
- Strict mode always; `noImplicitAny`, `strictNullChecks`
- Named exports over default exports
- No `any`. If widening needed, propose it and justify
- Interfaces for data shapes; types for unions
- Async/await over promise chains

### File organisation
- One concept per file
- Pure functions where practical
- Side effects concentrated in `src/bot/`, `src/storage/`, `src/agents/`
- No circular imports (enforce via ESLint)

### Testing
- After any change to `src/`, run `npm run typecheck` and `npm test`
- Do not declare a task complete until both pass
- New business logic requires a test
- Integration tests go in `tests/integration/`; unit tests co-located (`*.test.ts` next to source)

### Git
- Small commits, one logical change per commit
- Conventional commit format: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- Never commit `.env*` files or wrangler secrets
- Never force-push to `main`

### Secrets
- NEVER log environment variables or secret values
- NEVER commit `.env.local`
- Production secrets via `wrangler secret put`
- Dev secrets in `.env.local` (gitignored)

### Documentation
- Code comments for WHY, not WHAT (what should be obvious from the code)
- ADRs (Architecture Decision Records) for significant choices — place in `docs/adr/`
- Keep CLAUDE.md current; stale context is worse than no context

---

## Commands available in this project

### Slash commands (in Claude Code)

- `/session-start` — scope the session, establish goals
- `/phase-status` — show current state across all phases
- `/load-phase <n>` — load phase-specific context
- `/search-specs <query>` — search across all spec files
- `/review-against-spec` — check implementation against spec
- `/deploy` — deploy Worker safely
- `/tail` — live Worker logs with filtering
- `/new-customer` — run customer onboarding script

### NPM scripts

- `npm run dev` — local Worker with hot reload
- `npm run typecheck` — TypeScript check
- `npm test` — run all tests
- `npm run deploy` — deploy to production
- `npm run deploy:preview` — deploy to preview environment
- `npm run package` — build Teams app zip
- `npm run tail` — tail production logs
- `npm run onboard` — interactive customer provisioning
- `npm run offboard` — customer offboarding + data deletion

---

## Subagents available

- `phase-architect` — deep architectural review against a specific phase spec
- `customer-support-copilot` — troubleshoot a specific customer's issue

Invoke via natural language ("have the phase-architect review this against Phase 3 §4") or via the `/agents` command.

---

## MCP servers configured

- **cloudflare-docs** (`https://docs.mcp.cloudflare.com/mcp`) — authoritative Cloudflare docs
- **cloudflare-observability** (`https://observability.mcp.cloudflare.com/mcp`) — Worker logs and metrics
- **cloudflare-api** (via Cloudflare Skills plugin) — Workers / KV / D1 API access

See `.claude/settings.json` for the full configuration.

---

## Things Claude Code should NEVER do

- Modify files under `docs/` (they are the spec; flag divergences as questions)
- Install new npm packages without asking first
- Auto-commit without showing the diff
- Deploy to production without running the pre-flight checks in `/deploy`
- Log customer PII at INFO level
- Loosen TypeScript strictness to shut up the compiler
- Generate new architecture documents or planning files — the plans exist; we're in execution mode
- Work on multiple build slices simultaneously (finish one, commit, start next)
- Weaken the "everything drafts, nothing sends without approval" invariant
- Add Azure resources beyond: one Entra ID app, one bot registration, one resource group (`intelforce-rg`)

---

## When you're stuck — escalation path

1. Check the relevant skill (see `.claude/skills/` — there's probably one that applies)
2. Read the specific spec file for the component you're working on
3. Use the Cloudflare docs MCP for Workers/KV/D1/platform questions
4. Use web search for Bot Framework / Microsoft Graph / Teams questions
5. If architectural question: invoke the `phase-architect` subagent
6. If none of the above resolve it: ask the user. Don't guess and ship.

---

## The meta-rule (repeating because it matters)

**Intel Force OS is over-specified and under-executed.**

The risk in this project is not a missing plan. The risk is spending another week planning instead of shipping. Every session should end with either:
- More code written and tested, OR
- More customer conversations initiated

If a session ended with neither, something drifted.

The only exception is genuine architectural review — and even then, only in service of an imminent implementation decision, not exploratory.

Close the map. Open the code. Ship something.
