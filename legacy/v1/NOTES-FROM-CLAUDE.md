# Notes from Claude — Session 1 Read-Through

_Generated 2026-04-24. Read-only pass across the full Intel Force OS repo — every spec, every skill, every command._

---

## 1. Ground truth

### File counts: actual vs. claimed

| Directory | CLAUDE.md claims | Actual |
|---|---|---|
| `docs/phase-0-strategic/` | 6 files | **7 files** (CLAUDE.md undercounts by 1) |
| `docs/phase-1-poc-stack/` | 16 files | 16 files ✓ |
| `docs/phase-2-agent-suite/` | 78 files | 78 files ✓ |
| `docs/phase-3-platform/` | 9 files | 9 files ✓ |
| `docs/phase-4-dashboard/` | 11 files | 11 files ✓ |
| `docs/phase-5-business-legal/` | 14 files | 14 files ✓ |
| `docs/phase-6-ops-runbooks/` | 13 files | 13 files ✓ |
| `docs/teams-hr-agent/` | 8 files | 8 files ✓ |
| `docs/gtm-pack/` | 9 files | 9 files ✓ |
| `docs/build-kit/` | **not mentioned** | **7 files** (entire directory absent from CLAUDE.md and MASTER-INDEX.md) |

**Total in docs/:** 172 files. CLAUDE.md says "163 files" — discrepancy of 9 (build-kit accounts for 7 of those; the Phase 0 extra file accounts for 1; the Phase 0 file count being off accounts for the remainder).

### Files referenced that don't exist

| Referenced in | Claims to exist | Reality |
|---|---|---|
| `MASTER-INDEX.md` line 97 | `docs/phase-2-agent-suite/hr-agent/` — HR agent bundle directory | **Does not exist.** No `hr-agent/` directory in `phase-2-agent-suite/`. |
| `docs/build-kit/CLAUDE.md` line 28 | `docs/architecture/` — architecture pack | **Does not exist.** The architecture pack is at `docs/teams-hr-agent/`, not `docs/architecture/`. |
| `.claude/skills/relevance-ai/SKILL.md` line 152 | `docs/agent-prompts/hr-agent-system.md` — ASCII copy of the agent prompt | **Does not exist.** No `docs/agent-prompts/` directory. |
| `.claude/skills/relevance-ai/SKILL.md` via `build-kit` version | Same | Same. |

### Files on disk that no index mentions

- **`docs/build-kit/`** — 7-file directory with its own `.claude/` subdirectory (commands: `deploy.md`, `session-start.md`, `tail.md`; skills: `intel-force-os/SKILL.md`, `relevance-ai/SKILL.md`; plus `00-HOW-TO-PROCEED.md`, `CLAUDE.md`). This is the Teams HR Agent build-specific context pack. Neither CLAUDE.md nor MASTER-INDEX.md mention it.
- **`docs/build-kit/CLAUDE.md`** — A second CLAUDE.md for Claude Code. More focused than the root one; covers the 6 build slices, architecture, conventions. References `docs/architecture/` which doesn't exist.
- **`docs/phase-0-strategic/intelforce-planning-phase-brief.md`** — A 7th file in phase-0 not counted in CLAUDE.md.

### Code state: zero

`src/` does not exist. `migrations/`, `tests/`, `teams-app/`, `onboarding/`, `dist/` do not exist. The repo contains exactly: two markdown files at root (`CLAUDE.md`, `MASTER-INDEX.md`), two orientation files (`00-HOW-TO-USE-THIS-KIT.md`, `01-HOW-TO-PROCEED.md`), a `.claude/` config directory, and `docs/`. No code has been written.

---

## 2. The product in one paragraph (my own words)

This repo contains specs for two conceptually different products that have been given the same name. **Product A** (the original, making up most of the spec volume) is a multi-agent AI operations platform for UK marketing and sales agencies — "Clawd" in the Phase 5 naming spec — where each paying agency gets a Docker container running Claude Code headless, with an Obsidian vault as memory, webhook receivers feeding tasks to agents that draft proposals, hunt leads, write content, and follow up on prospects. **Product B** (the active build target, documented in `docs/teams-hr-agent/` and the GTM pack) is a Microsoft Teams bot for UK SMEs that reads HR messages in Teams channels, drafts replies using Relevance AI, and presents them to an HR Lead for one-tap approval. These two products share a parent company (Intel Force Ltd), a brand-level invariant ("everything drafts, nothing sends"), and a founder — but they use different architectures, target different buyers, price differently, and require completely different infrastructure to build. The "Intel Force OS" umbrella in CLAUDE.md treats them as the same thing. They are not.

---

## 3. The invariants

These appear across multiple packs and are non-negotiable regardless of which product is being built.

1. **Everything drafts, nothing sends without human approval.** Stated in: `docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md` (§1), `docs/teams-hr-agent/01-architecture-overview.md` (§1.3 R1), `docs/build-kit/CLAUDE.md` (last section), `.claude/skills/teams-hr-agent/SKILL.md` ("never do" list), `docs/phase-5-business-legal/legal/acceptable-use-policy.md`, brand tagline "Draft. Review. Send." The only exception is the holding reply sent immediately during escalation — that is pre-approved policy, not agent initiative.

2. **Sensitivity ≥ 0.7 routes to human-only handling — no AI draft.** Stated in: `docs/teams-hr-agent/01-architecture-overview.md` §4.4, `docs/teams-hr-agent/02-component-design.md` §4.3, `.claude/skills/relevance-ai/SKILL.md` validation rules. If the model returns sensitivity ≥ 0.7, the draft is a holding message only; the HR Lead handles from there.

3. **Customer-side: zero Azure infrastructure.** Stated in: `docs/teams-hr-agent/01-architecture-overview.md` R3, `docs/teams-hr-agent/README.md` §architecture table. Customer IT admin uploads one zip and clicks admin consent. That's it. No App Service, no Key Vault, no resource groups on the customer's Azure subscription.

4. **One Teams app, many agents.** Stated in: `docs/teams-hr-agent/01-architecture-overview.md` §5.7, `docs/teams-hr-agent/README.md` choice 3. New agents are routes inside the existing Worker and commands inside the existing manifest — not new installs.

5. **Audit everything.** Every message, every approval, every rejection, every escalation written to D1 before any user-facing action. Stated in: `docs/teams-hr-agent/02-component-design.md` §6, `.claude/skills/phase-architect.md` invariants checklist, `docs/phase-5-business-legal/legal/sla-spec.md`.

6. **GDPR baseline — deletion and export must be mechanically possible.** Stated in: `docs/teams-hr-agent/02-component-design.md` §6.4, `docs/phase-6-ops-runbooks/compliance/gdpr-dsar-and-deletion-runbook.md`. The D1 schema is designed to support `DELETE WHERE tenant_id = ? AND employee_aad_id = ?`.

---

## 4. The v1 scope — Teams HR Agent

### What v1 does

- **Teams bot** installed per customer M365 tenant via sideloaded app zip — no App Store listing required.
- **Listens** to designated channels (typically `#hr`); ignores everything else.
- **Calls Relevance AI** (or, if the pivot completes, Anthropic API) for each message and receives a structured response: `draft_reply`, `sensitivity_score`, `confidence`, `escalation_recommended`, `handbook_citations`.
- **Routes by sensitivity:**
  - < threshold → Adaptive Card sent to HR Lead DM for approve/edit/reject
  - ≥ 0.7 → holding reply sent immediately to employee; escalation card sent to HR Lead
- **Approval loop:** HR Lead taps Approve → bot posts reply in original thread. Edit → edited version sent. Reject → holding message sent.
- **D1 audit log:** every message, sensitivity score, decision, actor, and timestamp logged.
- **KV tenant config:** per-customer settings including HR Lead AAD ID, channel IDs, conversation references, approval mode, sensitivity threshold.
- **Weekly report:** cron (Monday 09:00 BST) sends stats card to HR Lead DM.
- **Proactive messaging:** bot DMing users without them initiating (requires conversation reference captured at install).
- **Per-customer onboarding script** (`onboarding/new-tenant.ts`) provisions KV config in ~30 minutes on a call.
- **Six Adaptive Card types:** approval, escalation, weekly report, config, welcome, error — templates in `docs/teams-hr-agent/06-adaptive-card-examples.json`.

### What v1 explicitly does NOT do

From `docs/teams-hr-agent/01-architecture-overview.md` §6:
- No self-serve Teams App Store listing (requires Microsoft Partner Center, 1-2 week validation — deferred to ~customer 10)
- No SSO Tab dashboard (deferred to v1.5)
- No bot-initiated DMs beyond the approval/escalation cards (proactive DM initiation needs per-user conversation refs — partially there)
- No Slack, Google Chat, or other channels
- No HRIS integrations beyond handbook retrieval (Breathe HR API — v1.1)
- No customer-facing web dashboard (Phase 4 — deferred to 15+ customers)
- No multi-agent (Sales, Recruiting) until HR is proven
- No multi-language support

### External dependencies required to ship

**Azure / Microsoft (one-time setup):**
1. Microsoft 365 Developer Program sandbox tenant (dev/test) — free, 90-day renewable
2. Entra ID multi-tenant app registration — one, ever, created via Teams Developer Portal or `az` CLI
3. Azure Bot Service registration (F0 free tier) in resource group `intelforce-rg` — one, ever
4. `az` CLI — local tooling

**Cloudflare:**
5. Cloudflare account with Workers paid plan — **$5/month required from customer 1** (free tier 10ms CPU limit exceeded by Relevance AI/Anthropic API call latency)
6. Cloudflare KV namespace — tenant config
7. Cloudflare D1 database — audit log
8. `bot.intelforce.ai` subdomain routed to Worker via Cloudflare DNS + Worker route
9. `intelforce.ai` domain registered and in Cloudflare DNS

**Agent brain (pick one):**
10. Relevance AI account + API key + existing HR agent (if keeping) — OR —
10. Anthropic API key (`claude-sonnet-4-6`) if going custom

**Per-customer (each onboarding):**
11. Customer's M365 tenant ID
12. Customer's HR handbook as PDF/DOCX
13. Customer HR Lead's Entra ID object ID

**Development tooling:**
14. Node.js 18+, npm, `wrangler` CLI
15. TypeScript + Vitest
16. `botbuilder` npm package (Bot Framework SDK)
17. GitHub + GitHub Actions (Stage L CI/CD)

### What's fully specified vs. needs a decision

**Fully specified (sufficient to code directly):**
- D1 schema for `audit_log` + `tenant_stats_daily` — complete SQL in `02-component-design.md §6.1`
- `TenantConfig` TypeScript interface — `02 §5.2` (with caveat: two fields obsolete if going custom)
- KV key schema — `02 §5.1`
- Worker file/directory structure — `02 §2.1`
- `wrangler.toml` structure — `02 §2.2`
- Teams app manifest JSON — `02 §1.2`
- Bot message handler pseudocode — `02 §2.4` (line-by-line, translatable directly)
- All six Adaptive Card templates — `06-adaptive-card-examples.json`
- Azure bootstrap CLI sequence — `03-azure-bootstrap-via-claude-code.md`
- Build stage prompts A-L — `07-claude-code-prompts.md` (Stage E needs rewrite for custom path)
- GDPR deletion + DSAR export — `02 §6.4`
- Error handling table — `02 §9`
- 8-scenario smoke test matrix — `04-deployment-guide.md §6`
- Proactive messaging pattern — `02 §7`

**Needs a decision before coding:**
1. **Agent runtime: Relevance AI or Anthropic API direct.** This is the central unresolved question. See §5 below.
2. **HR agent system prompt (`agent.md`) doesn't exist.** The `docs/phase-2-agent-suite/hr-agent/` directory is absent. If going custom, the system prompt, tool definitions, escalation rules, and output format must be written before Stage E.
3. **Handbook retrieval mechanism for custom path.** Relevance AI provides managed knowledge-base semantic search. If dropped, a replacement must be chosen (see §5).
4. **TenantConfig fields for custom path.** `relevanceAgentId` and `handbookKbId` become obsolete; replacement fields need to be defined before `storage/config.ts` is written.
5. **Conversation history management.** Each Teams message is currently treated as a stateless Anthropic call. Multi-turn HR conversations need either (a) per-conversation history in D1 or (b) accept that each message is independent. Affects D1 schema before migration is applied.

---

## 5. The Relevance AI question

### Every reference, with location

**Group A — Runtime dependencies (must change if going custom):**

`CLAUDE.md` (root):
- Tech stack table: "Agent brain | Relevance AI | Existing work; swap to Claude later"

`docs/teams-hr-agent/README.md`:
- Line 5: title "How to turn the Relevance AI HR agent into a productised Microsoft Teams app"
- Lines 39, 59-63: choice 2 "Relevance AI brain stays where it is"
- Line 110: prerequisite "Your existing Relevance AI agent with a callable HTTP endpoint (you have this)"

`docs/teams-hr-agent/01-architecture-overview.md`:
- Lines 8-9: problem statement assumes Relevance AI HR agent exists
- Lines 34-35: R5 requirement "Reuse Relevance AI agent work"
- Lines 95-102: Option D calls Relevance AI over HTTP
- Lines 195-199, 222-231: architecture diagram and data flow
- Lines 346-355: §5.4 "Relevance AI stays as the agent brain (for now)"
- Lines 437-442: cost table with Relevance AI as dominant cost

`docs/teams-hr-agent/02-component-design.md`:
- Line 16: component table listing "Relevance AI integration"
- Lines 184-190, 285: `callRelevanceAgent()` call
- Lines 471-559: §4 entire (HTTP contract, response shape, prompt rules, fallback, swap-to-Claude note)
- Lines 581-587: `TenantConfig.relevanceAgentId` and `handbookKbId`
- Lines 651-665: provisioning step creates Relevance AI agent clone
- Line 185: `wrangler.toml` `RELEVANCE_BASE_URL` var
- Line 208: `Env` interface `RELEVANCE_API_KEY`

`docs/teams-hr-agent/03-azure-bootstrap-via-claude-code.md`:
- Stage A prompt: "calling a Relevance AI agent as the intelligence backend"
- Stage C prompt: `wrangler.toml` `RELEVANCE_BASE_URL`, `Env.RELEVANCE_API_KEY`

`docs/teams-hr-agent/04-deployment-guide.md`:
- Line 50: pre-onboarding checklist "Create per-tenant Relevance AI agent (clone from template)"
- Lines ~113-120: onboarding script prompts for Relevance AI agent ID
- Lines ~127-134: §3.5 handbook upload to Relevance AI knowledge base
- Lines ~271-275: offboarding deletes Relevance AI agent and knowledge base

`docs/teams-hr-agent/05-productisation-playbook.md`:
- Lines 97-107: multi-agent routing uses `callRelevanceAgent`
- Lines 116-121: `TenantConfig` v2 has `relevanceAgentId` per agent
- Lines 162-167: "Build agent in Relevance AI" for new agent rollout
- Lines 261-262: enterprise requirements mention "Dedicated Relevance AI / Claude capacity"
- Lines 333-340: §7.3 "Versioning the Relevance AI agent"

`docs/teams-hr-agent/07-claude-code-prompts.md`:
- Stage A prompt: "calling a Relevance AI agent as the intelligence backend"
- Stage E (lines 293-342): entire section — `RELEVANCE_API_KEY`, HTTP contract, retry logic (this stage is entirely wrong for custom path and needs to be replaced)
- Debugging appendix: "Check Relevance AI agent {relevanceAgentId} is responding via curl"

`.claude/skills/relevance-ai/SKILL.md` (root):
- Entire file — HTTP contract, retry pattern, per-tenant cloning, debugging guide, migration path

`docs/build-kit/CLAUDE.md`:
- Tech stack table: "Agent | Relevance AI (existing) | Existing agent + knowledge base"

`docs/build-kit/.claude/skills/relevance-ai/SKILL.md`:
- Entire file — same content as root skills version, slightly different wording

`docs/gtm-pack/06-pricing-sheet.md`:
- Service agreement template ~line 167: "Sub-processors: Anthropic (Claude API), Relevance AI"

`docs/gtm-pack/README.md`:
- Line 64: prerequisites "The HR agent on Relevance AI is working end-to-end (it is)"

`MASTER-INDEX.md`:
- Line 97: "HR Agent | In production (Relevance AI) | `phase-2-agent-suite/hr-agent/`"
- Line 228: "cost-governance-runbook.md | Managing Cloudflare + Relevance AI costs"
- Lines 270-271: cross-reference "Phase 2 HR agent bundle for Relevance AI prompt details"

**Group B — References only (context / history, not runtime):**
- `docs/phase-5-business-legal/pricing/pricing-spec.md` §7.1: competitor comparison table lists Relevance AI as a competitor
- `docs/phase-0-strategic/intelforce-technical-strategy-v2.md`: mentions Relevance AI in context of explaining alternatives

### Honest assessment: custom vs. Relevance AI

**What going custom costs in build time:** The primary code cost is Stage E — implementing `src/agents/claude.ts` with the Anthropic SDK, including tool-call loop, prompt caching, structured output via tool use, and handbook retrieval. Realistically 1-2 focused days to build and test. The secondary cost is writing the HR agent `agent.md` system prompt from scratch (there is no existing spec; the `docs/phase-2-agent-suite/hr-agent/` directory is absent). That's another half-day of careful writing and a further 1-2 days of prompt iteration against real queries before quality is acceptable. Total realistic cost: 3-5 days, not 2 hours.

**What going custom saves:** At claude-sonnet-4-6 API rates with prompt caching (system prompt cached at 10% of input rate), inference cost at 50 customers × 200 messages/day is roughly £100-400/month — compared to Relevance AI's projected £2,000/month at that scale shown in `01-architecture-overview.md §8`. Data residency improves (Anthropic EU endpoint available; no US-based Relevance AI). The agent prompt is now Git-tracked and auditable rather than living in a dashboard.

**What going custom risks for v1 specifically:** Relevance AI provides managed knowledge-base semantic search — chunking, embedding, and retrieval of the customer's HR handbook. This is the core of what makes the HR agent useful. Replacing it for v1 is not trivial. The simplest v1 replacement (inject the full handbook text into the system prompt) works for handbooks up to ~150k tokens but adds £0.50-2.00 per request in uncached tokens on the first request. A real retrieval solution (Cloudflare Vectorize, Pinecone, etc.) adds at least 2-3 weeks of additional build time. Shipping a custom runtime with no handbook retrieval is not a viable product — an HR agent that can't answer "what's the holiday policy?" from the handbook is not worth £400/month.

**Bottom line:** If you want to ship v1 in under 2 weeks from today, keep Relevance AI for now and migrate later as the spec already suggests. If data residency or cost at scale is the priority and you're willing to add 3-5 days of build time plus solve handbook retrieval, go custom and do it properly. Don't go halfway — a half-built custom runtime is worse than either option.

---

## 6. Architecture map

This is the actual v1 Teams HR Agent architecture derived from `docs/teams-hr-agent/`. Note: this is NOT the Phase 0/1/2/3 architecture (see §8 for that distinction).

```
CUSTOMER'S MICROSOFT 365 TENANT
─────────────────────────────────────────────────────────────────
  Employee sends HR message in #hr Teams channel
  OR Employee DMs the Intel Force OS bot
           │
           │  Bot Framework protocol (HTTPS)
           │  JWT-signed by Entra ID app
           ▼
INTEL FORCE OS INFRASTRUCTURE (Cloudflare global edge)
─────────────────────────────────────────────────────────────────
  ┌─────────────────────────────────────────────────────────┐
  │  Cloudflare Worker — bot.intelforce.ai                  │
  │                                                         │
  │  POST /api/messages  →  handleBotMessage()              │
  │    1. verifyJWT (jose — check Microsoft signing keys)   │
  │    2. extract tenantId from channelData.tenant.id       │
  │    3. load TenantConfig from KV                         │
  │    4. call agent brain (see below)                      │
  │    5. if sensitivity ≥ 0.7:                             │
  │         → reply holding message to employee             │
  │         → send escalation card to HR Lead DM            │
  │       else:                                             │
  │         → send approval card to HR Lead DM              │
  │    6. log to D1 audit_log                               │
  │                                                         │
  │  POST /api/card-action  →  handleCardAction()           │
  │    approve → post draft reply in original thread        │
  │    edit    → post edited reply in original thread       │
  │    reject  → post holding message to employee           │
  │    ack     → mark escalation acknowledged               │
  │                                                         │
  │  Cron (Monday 08:00 UTC)  →  sendWeeklyReport()         │
  │    → send stats Adaptive Card to each HR Lead DM        │
  └───────┬─────────────────┬────────────────────┬──────────┘
          │                 │                    │
          ▼                 ▼                    ▼
  Cloudflare KV       Cloudflare D1        Agent brain
  tenant_config       audit_log table      (pick one):
  :{tenantId}         tenant_stats_daily   ┌──────────────────┐
  hr_lead_convo       (7-year retention)   │ Relevance AI     │
  :{tenantId}:{aadId}                      │ HTTP endpoint    │
                                           │ (per-tenant      │
                                           │ agent clone,     │
                                           │ handbook KB)     │
                                           └──────────────────┘
                                                  OR
                                           ┌──────────────────┐
                                           │ Anthropic API    │
                                           │ claude-sonnet-4-6│
                                           │ tool-call loop   │
                                           │ (handbook from   │
                                           │ KV context or    │
                                           │ vector search)   │
                                           └──────────────────┘
          │                 │
          ▼                 ▼
  Bot Framework      Bot Framework proactive messaging
  reply to employee  → HR Lead's 1:1 DM with bot
  via Teams          (Adaptive Cards: approval / escalation
                      / weekly report / welcome)

ONE-TIME AZURE INFRASTRUCTURE (Intel Force side)
─────────────────────────────────────────────────
  Entra ID app registration (multi-tenant)
  Azure Bot Service (F0, intelforce-rg, uksouth)
  → Teams channel enabled
  → messaging endpoint: bot.intelforce.ai/api/messages

CUSTOMER SIDE
─────────────
  Zero Azure. Install = upload manifest.zip + admin consent.
```

---

## 7. The agent runtime contract (Phase 2 bundle pattern)

**Source files:** `docs/phase-2-agent-suite/00-PATTERN-REFERENCE.md`, `docs/phase-2-agent-suite/client-onboarder/`, `docs/phase-0-strategic/ARCHITECTURE-OVERVIEW.md`

**Important caveat first:** The Phase 2 bundle pattern was designed for Architecture A (Claude Code container runtime), NOT for the Teams HR Agent (Architecture B). `validate.sh` and `context.sh` are Claude Code session hooks. The vault filesystem paths (`/tenant/vault/`) assume the Docker container structure. Tools in `tools.yaml` are MCP server declarations for Claude Code's MCP client — not Anthropic API tool-use schemas. What DOES translate to the Teams HR Agent custom runtime: `agent.md` (system prompt) and `tools.yaml` (tool definitions, which can be translated to Anthropic tool-use schema).

### The 7-file bundle

Every agent in `docs/phase-2-agent-suite/{name}/` has exactly these files:

**`README.md`** — Human-readable 2-minute overview. Describes what the agent does, who uses it, cost per run, related agents. Not loaded by the runtime; for humans and sales.

**`agent.md`** — The production system prompt. Required sections in order: YAML frontmatter (name, description, model, tools, permission_mode, version), Role (2-3 paragraphs), Context block (populated by `context.sh` at session start with vault content), Workflow (numbered steps, no skipping), Output Specification (required sections in order), Quality Gates (structural checks pre-save), Escalation Conditions (each with a `SCREAMING_SNAKE_CASE` code from `_shared/escalation-codes.md`), Internal quality notes. All client references use `{{client.name}}` templating. Zero hardcoded client data. See: `docs/phase-2-agent-suite/client-onboarder/agent.md`.

**`config.schema.json`** — JSON Schema (draft-07) defining what the Configuration Wizard must collect per tenant to activate this agent. Top-level sections always include `client`, `sales_lead`, integration-specific sections, `notifications`, `output`, `behaviour`. See: `docs/phase-2-agent-suite/client-onboarder/config.schema.json`.

**`tools.yaml`** — Declares MCP server dependencies. Required fields: `agent`, `version`, `required[]` (each with `name`, `purpose`, `mcp_server`, `auth.secret_ref`, `tools_used[]`, `scopes_required[]`, `degraded_mode`), `optional[]`, `preflight_checks[]`, `telemetry` (events + cost budget). See: `docs/phase-2-agent-suite/client-onboarder/tools.yaml`.

**`validate.sh`** — PostToolUse bash hook. Runs after every agent write. Sources `_shared/hook-helpers.sh`, exits early if the written file isn't one this agent cares about, runs structural checks (section presence, word count, no placeholders, banned phrases), and injects pass/fail back into Claude's context for self-correction. Does NOT perform semantic quality evaluation — that's v1.1 LLM-as-judge territory.

**`context.sh`** — SessionStart bash hook. Runs when a Claude Code session opens for this agent. Reads the trigger payload, loads vault files (voice profile, service catalogue, signed proposal, etc.), optionally calls `hh_retrieve()` (the `vault-search` CLI) for semantic retrieval, builds the CONTEXT block, and injects it into `agent.working.md` (session-scoped copy of `agent.md`). This is how every session starts fresh but with current memory.

**`tests/fixtures/01-primary/`** — Two files: `input.json` (the trigger payload) and `expected.md` (golden output). Used for directional validation — not pixel-perfect, but the key decisions (tier recommended, escalation raised, scope items) must match. A PR that changes `agent.md` without updating fixtures fails code review.

### How `config.schema.json` + `tools.yaml` + `agent.md` combine at runtime (Architecture A)

1. Provisioning System collects config per the schema, writes to Postgres `tenants` table and per-tenant secrets vault
2. When a trigger fires (webhook → Webhook Receiver → supervisor), `cc-invoke {agent-name} --trigger {path}` is called
3. `context.sh` (SessionStart hook) reads the trigger payload, loads vault files, builds context, injects into `agent.working.md`
4. Claude Code starts with `agent.working.md` as system prompt, tools from `.claude/mcp.json` (populated from `tools.yaml` + secrets from vault)
5. Agent executes workflow steps, calls MCP tools as needed
6. After each Write, `validate.sh` (PostToolUse hook) checks output quality; failures fed back to Claude
7. Agent writes final output to vault, Claude Code exits
8. Vault Syncer picks up the new file, commits, pushes to GitHub

### How it translates to the Teams HR Agent (Architecture B, custom path)

- `agent.md` → system prompt passed to `client.messages.create()` in `@anthropic-ai/sdk`
- `tools.yaml` tool names + descriptions → Anthropic tool-use schema (`{name, description, input_schema}[]`)
- `validate.sh` → NOT applicable; quality enforcement happens via structured output tool (`submit_draft_for_approval`)
- `context.sh` → NOT applicable; handbook text injected inline into system prompt
- `config.schema.json` → fields map to `TenantConfig` KV JSON (not a Provisioning System)

---

## 8. Inconsistencies and contradictions

**1. Two completely different architectures in one repo, conflated as the same product.**

The `docs/phase-0-strategic/ARCHITECTURE-OVERVIEW.md` describes a platform with Docker containers per tenant, a Fastify Webhook Receiver, Postgres + pgvector, self-hosted Loki/Prometheus/Grafana on Hetzner UK, Temporal for provisioning, and GitHub-synced Obsidian vaults. This is what Phase 1, 2, 3, 4, and 6 specs are built for.

The `docs/teams-hr-agent/` pack describes a single Cloudflare Worker, Bot Framework over HTTPS, Cloudflare KV + D1, Adaptive Cards, and Relevance AI (or Claude API) called over HTTP.

These cannot coexist — they are different systems for different buyers. CLAUDE.md and MASTER-INDEX.md treat them as "phases" of the same product. They are not. The Teams HR Agent is the current build target; the Phase 0-4 specs describe a product that has not been validated and may or may not be the future. This conflation is the most significant source of confusion in the repo.

**Canonical recommendation:** Treat `docs/teams-hr-agent/` + `docs/gtm-pack/` as the active product. Treat `docs/phase-0-strategic/ARCHITECTURE-OVERVIEW.md` and `docs/phase-1-poc-stack/` through `docs/phase-4-dashboard/` as the speculative platform (Architecture A) — reference material for a future that depends on things that haven't happened.

**2. Product name is unresolved, but the later specs already assumed "Clawd."**

`docs/phase-5-business-legal/marketing/brand-identity-spec.md` recommends "Clawd" (one syllable, hard C) and explicitly calls IntelForce "actively hostile" for commercial launch. The Phase 5 pricing spec, DPA, MSA, and REST API spec all use "Clawd" and `clawd.ai`. The root CLAUDE.md, GTM pack, and Teams HR Agent specs use "Intel Force OS" and `intelforce.ai`. There are now two names for the same product in the same repo, with Phase 5 being the later and more considered judgment.

**Canonical recommendation:** Phase 5 brand spec is correct. Treat all Phase 5+ references to "Clawd" as the target name. The Phase 1-7 references to "IntelForce OS" / "Intel Force OS" are the working title that needs global find-and-replace. This is OD-P5-1, still open.

**3. Pricing structures for two different stages, both in the repo.**

`docs/gtm-pack/06-pricing-sheet.md`: £400/month, manual service, one HR agent, 10 founding customers. This is pre-platform, founder-led.

`docs/phase-5-business-legal/pricing/pricing-spec.md`: £450 Starter / £1,800 Growth / £4,500 Scale / £10k+ Enterprise. These are for the full Clawd platform (Architecture A) with multiple agents.

Neither is wrong — they're for different stages. But they'll confuse any session that reads both without understanding the distinction.

**Canonical recommendation:** GTM £400 is the current price for the Teams HR Agent v1. Phase 5 tiers are the target for the platform phase. The Phase 5 spec acknowledges "founding customers" at 30% off Growth/Scale for first 12 months, which bridges the gap.

**4. MASTER-INDEX.md line 97 claims an hr-agent bundle that doesn't exist.**

"HR Agent | In production (Relevance AI) | `phase-2-agent-suite/hr-agent/` | Implementing Teams HR Agent" — the directory `docs/phase-2-agent-suite/hr-agent/` does not exist. The Phase 2 bundles are for Architecture A agents (lead-hunter, client-onboarder, etc.), not the HR agent. The HR agent prompt lives in Relevance AI's dashboard, outside this repo.

**Canonical recommendation:** Either create `docs/phase-2-agent-suite/hr-agent/` with a proper agent bundle (agent.md, tools.yaml, etc.) as part of the custom runtime build — or remove the MASTER-INDEX.md reference and note that the HR agent prompt lives in Relevance AI.

**5. `docs/build-kit/CLAUDE.md` references `docs/architecture/` which doesn't exist.**

Line 28 of the build-kit CLAUDE.md: "Full architecture: `docs/architecture/01-architecture-overview.md`". The architecture pack is at `docs/teams-hr-agent/`, not `docs/architecture/`. This would cause Claude Code to fail to find the architecture if the build-kit CLAUDE.md were loaded.

**Canonical recommendation:** Fix `docs/build-kit/CLAUDE.md` to reference `docs/teams-hr-agent/01-architecture-overview.md`. Also update to remove the Relevance AI references.

**6. `docs/phase-5-business-legal/legal/dpa-template.md` sub-processors list does not include Relevance AI.**

The DPA sub-processors (Annex B) lists: Anthropic, Hetzner, AWS, Cohere, Clerk, Stripe, Cloudflare, StatusPage, PagerDuty. Relevance AI is absent. But `docs/gtm-pack/06-pricing-sheet.md`'s simple service agreement template explicitly lists "Sub-processors: Anthropic (Claude API), Relevance AI."

This is because the Phase 5 DPA was written for Architecture A (which doesn't use Relevance AI), while the GTM pricing sheet reflects the actual Teams HR Agent v1 runtime. They cannot both be correct.

**Canonical recommendation:** The DPA must include Relevance AI if it's used in production. Add it to Annex B, or remove it from the service agreement if going custom.

**7. Phase 3 platform states "Prerequisites: Phase 1 POC validated."**

`docs/phase-3-platform/PHASE-3-SUMMARY.md` (line 8): "Prerequisites: Phase 1 POC validated (Proposal Builder works end-to-end on a real Fathom call)." The Phase 1 POC has never been executed (`docs/phase-1-poc-stack/SESSION-SUMMARY.md` and `week-1-experiment-runbook.md` confirm it's a plan, not a completed run). Phase 3 spec is therefore building on a prerequisite that doesn't exist.

**8. Phase 3 cost envelope assumes Hetzner; Phase 6 runbooks assume Postgres.**

Phase 3 is scoped to Hetzner UK dedicated servers + AWS for backups + Temporal. Phase 6 runbooks include `postgres-incidents.md`. These are entirely for Architecture A and are irrelevant to the Teams HR Agent, which runs on Cloudflare. Someone reading Phase 6 runbooks to prepare for v1 launch will find procedures for a stack they haven't built.

**9. The Phase 0 ARCHITECTURE-OVERVIEW.md references "Cohere EU embeddings."**

`docs/phase-0-strategic/ARCHITECTURE-OVERVIEW.md` key design decisions table: "Cohere EU embeddings | UK/EU data sovereignty sales story | 5x cost vs OpenAI". But the Phase 2 Librarian agent (which does the embedding) runs nightly via cron. The Teams HR Agent has no embedding step in v1. Cohere is only relevant if Architecture A's Librarian agent is built. Not relevant for v1.

**10. Build-kit directory has its own `.claude/` subdirectory, creating potential config confusion.**

`docs/build-kit/.claude/` contains commands and skills that partially duplicate what's in the root `.claude/`. Claude Code may not load these (they're inside `docs/`, which is a deny-listed path for Writes but not necessarily for config loading). The root `.claude/settings.json` is the active config; the build-kit one appears to be documentation of what the config should look like, not actual config.

---

## 9. Risks, gaps, and open questions

### Specs that reference things that don't exist

- `docs/phase-2-agent-suite/hr-agent/` — referenced in MASTER-INDEX; doesn't exist. **Blocking for custom runtime.**
- `docs/agent-prompts/hr-agent-system.md` — referenced in both relevance-ai SKILL.md files as where to keep an ASCII copy of the HR agent prompt; doesn't exist. **Not blocking but creates maintenance debt.**
- `docs/architecture/` — referenced in build-kit CLAUDE.md; doesn't exist (correct path is `docs/teams-hr-agent/`). **Will break Claude Code sessions loaded from build-kit CLAUDE.md.**
- Phase 2 `_shared/prompt-patterns.md` — referenced in MASTER-INDEX line 117 "Relevance AI prompt engineering: see `_shared/prompt-patterns.md`"; does not exist in `_shared/` (only `escalation-codes.md`, `hook-helpers.sh`, `universal-banned-phrases.txt` are present). **Minor gap.**

### Open decisions still open

From `docs/phase-0-strategic/intelforce-execution-plan.md` and Phase 5 (18 open decisions tracked):

- **OD-P5-1**: Is "Clawd" the name? Not formally decided. Every Phase 5 document assumes yes; everything else assumes Intel Force OS. **Critical — blocks trademark, landing page, legal docs.**
- **OD-P5-2**: Intel Force Ltd as operating entity or spin up Clawd Ltd? Recommendation in brand spec: keep Intel Force Ltd.
- **Agent runtime**: Relevance AI or Anthropic API direct? Not formally captured as an OD but is the central build decision.
- **First vertical**: HR is chosen. But the Phase 0 strategic plan positions sales/marketing agencies as the ICP, not HR departments at SMEs. These are genuinely different markets.

### Technical risks

1. **No handbook retrieval solution specified for custom runtime.** The HR agent's core value proposition is grounding answers in the customer's handbook. Relevance AI provides this. A custom runtime without a retrieval solution produces an agent that makes up HR policy — which would be worse than no agent. This is a v1 blocker, not a v1.1 enhancement. Options: inject full handbook text in system prompt (simplest; breaks down for very large handbooks), Cloudflare Vectorize (adds 2-3 weeks), third-party service (adds a dependency). Must be decided and built before the first customer.

2. **Cloudflare Workers 30s CPU limit (paid plan) vs. multi-round tool-call loop.** Each Anthropic API call can take 2-8 seconds. Multiple tool-call rounds (handbook lookup + employee data + submit draft) could approach the 30-second limit. The spec acknowledges this for Relevance AI (1-3 seconds); direct Claude could be faster or similar. This needs profiling against real HR queries before committing to the custom path.

3. **Proactive messaging requires conversation reference captured at install.** Bot can't DM HR Lead without a stored conversation reference. Reference is captured when HR Lead sends the first message to the bot (or from `conversationUpdate` when bot is added). If HR Lead never opens the 1:1 chat, approval cards can't be delivered. The onboarding script needs to include a step that forces HR Lead to initiate the 1:1 chat. Spec covers this in `02 §7.1` but it's easy to miss in practice.

4. **Single Entra ID app registration = single point of compromise.** `01 §5.5` acknowledges: "if the single Entra ID app is ever compromised, all customers are affected." Mitigations listed are secret rotation, IP allow-listing, audit logging. Acceptable for v1 with 10 customers; revisit before enterprise.

5. **The Phase 2 agent bundles are not written for the Teams HR Agent.** All 9 Phase 2 bundles (lead-hunter, client-onboarder, etc.) are for Architecture A (Claude Code containers, Obsidian vault, marketing agencies). They cannot be used as-is for the Teams HR Agent. The user's intent to "use the Phase 2 bundle pattern" for the HR agent means writing a new bundle from scratch, following the pattern. That's the right move; just be clear that the existing Phase 2 bundles are templates, not starting points.

### Business risks

1. **"Intel Force" trademark conflict.** `docs/phase-5-business-legal/marketing/brand-identity-spec.md` §1.2 explicitly states: trademark conflict with `intelforce.org` (cybersecurity company, active) and ChatGPT store "IntelForce GPT". If continuing to trade as "Intel Force OS" without resolving this, there's legal exposure. The spec recommends "Clawd" specifically to avoid this.

2. **"IntelForce" conflicts with Intel Corporation.** Separate from `intelforce.org`, there's a risk Intel Corp (chips) views "IntelForce" as dilutive to their mark. The trademark brief (`docs/phase-5-business-legal/marketing/trademark-filing-brief.md`) acknowledges this risk and budgets £870-£1,170 for CITMA attorney review.

3. **Relevance AI data residency.** The Teams HR Agent currently routes customer HR data (message text, employee names) through Relevance AI, which is US-headquartered. The current Phase 5 DPA was written for Architecture A (UK/EU-resident stack via Hetzner) and does not correctly cover the Relevance AI data flow. Customers who ask about GDPR compliance currently have no compliant DPA to sign. This is a pre-customer blocker.

4. **Single founder, single point of failure.** Phase 6 on-call handbook assumes Maddox + Jack on a weekly rotation. Jack's role is undefined in the primary specs — who is Jack? Mentioned several times in the specs (backup HR Lead, on-call backup, design) but never introduced. If Jack is a co-founder or employee, their role needs to be in the legal docs.

5. **0 paying customers, 0 in pilot.** The Phase 3 platform assumes "Phase 1 POC validated." The GTM pack targets "first customer in 30 days." The Week 1 experiment runbook was never executed. There is no market validation for either product (Architecture A or B). The risk is that the carefully specified product doesn't match what customers actually need — a risk that only customer conversations can resolve.

### Missing specs for a v1 launch

- **HR agent system prompt** — no `agent.md` exists for the HR agent. The agent's core logic, escalation codes, output format, and tone rules are not written down anywhere in this repo.
- **Breathe HR API client** — mentioned throughout as "the pilot tool suite" but no tools.yaml for the HR agent and no client code specified.
- **Handbook ingestion workflow** — how a customer's handbook gets from PDF → searchable form is unspecified for any runtime other than "upload to Relevance AI."
- **The `docs/agent-prompts/` directory** — two skill files reference it as where the HR agent system prompt ASCII copy should live. It doesn't exist.
- **Customer-facing status page** — Phase 5 mentions `status.intelforce.ai` via Statuspage.io. Not provisioned.

---

## 10. Recommended next 5 moves

**Move 1: Decide on agent runtime (Relevance AI vs. custom Anthropic API).**
_Why:_ Everything downstream depends on this. Wrangler.toml, TenantConfig schema, Stage E implementation, the HR agent system prompt, the handbook retrieval approach — all branch on this decision. Make it once, explicitly, and record it.
_Complexity:_ S (decision, not code).
_Blockers:_ Your call. No external dependency.

**Move 2: Write the HR agent system prompt (`docs/phase-2-agent-suite/hr-agent/agent.md`).**
_Why:_ This is the brain of the product and it doesn't exist in the repo. Whether you use Relevance AI or Anthropic API, you need the agent's logic, escalation conditions, output format, and quality gates written down. For Relevance AI, it becomes the basis for updating the Relevance AI dashboard prompt. For the custom path, it IS the system prompt.
_Complexity:_ M (a day of careful writing + iteration).
_Blockers:_ Move 1 (need to know the output format the runtime expects).

**Move 3: Lock the product name and start the trademark check.**
_Why:_ Blocks trademark filing, landing page, legal docs, domain purchase, logo design. The Phase 5 brand spec already did the analysis — "Clawd" is the recommendation. Spend one afternoon running UKIPO and EUIPO searches. If clear, lock it. If not, iterate. Every week of delay on the name is a week of delay on legal docs and marketing.
_Complexity:_ S (research + decision, not code).
_Blockers:_ None. Can happen today.

**Move 4: Stage C — scaffold the Cloudflare Worker and prove the deploy pipeline.**
_Why:_ The only file in the repo that generates real assets is `wrangler.toml` (which doesn't exist yet). You need a deployed Worker at `bot.intelforce.ai` to do anything — including connecting the Teams bot, testing cards, and verifying the JWT auth. This is the first 2-3 hours of actual coding and the foundation everything else builds on. The Stage C prompt in `07-claude-code-prompts.md` is fully written and works as-is.
_Complexity:_ S (2-3 hours).
_Blockers:_ Azure bot registration (Stage B) must come first — 30 minutes, fully specified in `03-azure-bootstrap-via-claude-code.md`.

**Move 5: Update the DPA to reflect the actual current sub-processors.**
_Why:_ You cannot sign any customer contract without a compliant GDPR DPA. The current Phase 5 DPA was written for Architecture A and doesn't include Relevance AI (or doesn't include the correct stack for Architecture B). Before the first customer conversation gets commercial, you need a DPA that reflects: Anthropic (Claude API), Cloudflare (Workers/KV/D1), and either Relevance AI (if keeping) or just the above (if going custom). This is a business blocker, not a technical one.
_Complexity:_ S (30-minute legal edit once the runtime is decided).
_Blockers:_ Move 1 (need to know if Relevance AI is a sub-processor).

---

## 11. Questions for Maddox before any code gets written

1. **Confirm or deny: agent runtime = Cloudflare Worker + Anthropic API direct, Relevance AI fully retired.** If yes: confirm that the existing Relevance AI HR agent prompt can be ported to `agent.md`. If no: confirm Relevance AI stays for v1.

2. **Confirm or deny: the product name for commercial launch is "Clawd," `clawd.ai` as primary domain.** If yes: ready to execute OD-P5-1 now (UKIPO search, domain purchase, brand guide). If no: what's the alternative and what's blocking the Clawd decision?

3. **Confirm or deny: the current v1 build target is the Teams HR Agent only (HR inbox drafting for UK SMEs).** The Phase 0 strategic plan positions a sales/marketing agency platform as the primary product. Is that dead, deferred indefinitely, or still parallel? Need clarity to know whether Phase 2-4 specs are "might build someday" or "planning for the eventual merge."

4. **Who is Jack?** Mentioned as a backup HR Lead, on-call secondary, and design partner across multiple specs. Is Jack a co-founder, a contractor, or a placeholder name? If co-founder, their involvement should be in the MSA and on-call handbook. If designer: what's his availability for the Teams app icons and eventual brand identity?

5. **Has the existing Relevance AI HR agent actually been tested against the three smoke-test scenarios** (simple policy question, medium complexity, escalation-worthy question)? The GTM README says "it is" working — but the Teams HR Agent spec §11 asks you to answer this honestly before building. Knowing its actual quality level determines whether it's a worthwhile starting point for the custom path prompt.

6. **Is Breathe HR integration required for v1, or is "handbook text only" acceptable for the first customer?** The spec repeatedly calls Breathe HR "the pilot tool suite" but the deployment guide doesn't require a live Breathe HR API key to onboard a customer. Clarifying this sets the scope for what tools need to be in `tools.yaml`.

7. **Where is the customer?** The GTM pack targets "first customer in 30 days" from when it was written (likely April 2026). Are there any warm prospects, booked demos, or interested parties right now? The spec-to-customer gap is the existential risk, and the answer changes what to prioritise (build more, or sell more).

8. **Confirm the current Anthropic API access level.** The Phase 0 technical strategy mentions "Claude Max 20x subscription." The custom runtime path requires Anthropic API (workspace API key, billed per token), not the Max subscription. Are both in place? What's the current rate limit tier?

9. **Data residency requirement: UK-only, UK+EU, or EU is fine?** The Cloudflare Workers region selection and the Anthropic EU endpoint availability determine the GDPR data residency story you can tell customers. The current Cloudflare Workers "smart placement" mode doesn't guarantee UK/EU. If customers will ask, you need an explicit answer.

10. **Is the `docs/build-kit/CLAUDE.md` the CLAUDE.md you intend Claude Code to load for the Teams HR Agent build?** It's in `docs/build-kit/`, which is a write-denied path, and it references `docs/architecture/` which doesn't exist. Should it be moved to root or replaced by the root CLAUDE.md? Right now Claude Code will load the root CLAUDE.md (correct) but the build-kit version is out of date and its own `.claude/` subdirectory won't be picked up by Claude Code.
