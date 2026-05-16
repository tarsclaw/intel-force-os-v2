# IntelForce AI OS — Build Artifact Execution Plan
**Every document you still need, sequenced into phases you can tick off until Claude Code has everything it needs to build.**

> *This is your master checklist. Work through it top to bottom. Each artifact has a suggested prompt, its dependencies, and a rough effort estimate. When the last box in Phase 6 is ticked, you have a complete developer-ready specification.*

---

## Contents

- **Part A** — Audit: what we already have
- **Part B** — The Gap Map: every category of missing artifact
- **Part C** — Open Decisions Log: things to decide, not just document
- **Part D** — Phased Execution Plan: seven phases, every artifact as a checklist item with a prompt to generate it
- **Part E** — How to work this document

---

# PART A — AUDIT: WHAT WE HAVE

Three strategic documents and one dashboard prototype, totalling 2,675 lines:

| Artifact | Lines | What it covers | What it DOESN'T cover |
|---|---|---|---|
| **Strategic Plan v1** | 499 | Positioning, ICP, pricing, GTM, IP, 10-week business roadmap, 30-day kickoff | Any specific prompts, technical implementation, actual agent definitions |
| **Technical Strategy v2** | 595 | Claude Code as runtime, sub-agents, operator pattern, 24/7 triggers, memory architecture, Obsidian brain, revised ICP (agencies + course sellers), agency white-label | Per-agent implementation, platform component engineering specs, business/legal artifacts |
| **Build Plan** | 1,581 | Architecture for every agent + platform component, engineering-grade specs, 14-week build sequence | The actual agent.md files, the validation scripts, the provisioning code, the wizard UX copy, legal templates, GTM playbooks, brand assets |
| **Dashboard prototype** | React component | Visual proof of product — hierarchy, activity log, configuration centre, agent detail | Brain view, Approvals view, Billing, Audit, Integrations, Settings, Mobile responsive, white-label layer, full design system |

**What this means:** you have a complete set of *what* to build and *why*. You do not yet have a complete set of *what the code reads from* (the actual prompts, specs, copy, schemas, scripts). That's the gap this doc maps.

---

# PART B — THE GAP MAP

Twelve categories of artifact still to produce. Every item in Part D lives in one of these.

### B1. Agent Implementation Bundles (14 agents × ~6 files each)
For every agent: `agent.md`, `config.schema.json`, `tools.yaml`, `validate.sh`, `context.sh`, test fixtures + golden outputs. These are the files Claude Code actually reads to run the agent. **This is the single biggest block of missing work.**

### B2. Platform Component Engineering Specs
The Build Plan described each component's purpose and architecture. For each one, you need a *developer-ready spec* — concrete enough that a dev can open a cursor and start writing the code without further back-and-forth. Twelve components total.

### B3. Dashboard Full Specs
Prototype shows 3 views. You have 10 in the production plan. Need: full view-by-view specs with interaction states, empty states, error states, and a proper design system doc.

### B4. Provisioning & Configuration Specs
The wizard flow (five steps, with copy), the provisioning orchestrator (state machine, rollback paths), the voice ingestion pipeline (past proposals → voice profile). These are IP-critical — worth extra engineering depth.

### B5. Memory System Specs
Vault structure per client, git-backed sync implementation, retrieval pipeline with embeddings, the Librarian's specific hygiene rules, CLAUDE.md template per tenant.

### B6. Integration Specs (one per MCP server / API)
For every integration — official MCP, community MCP (forked), or built-from-scratch wrapper — you need: auth setup, required scopes, exact capabilities used, fallback behaviour, test checklist. ~15 integrations at launch.

### B7. Business / Commercial Artifacts
MSA template, DPA template, sub-processor list, pricing page copy, terms of service, cookie/privacy policy, refund policy, founding-customer agreement.

### B8. Go-to-Market Playbook
Cold outbound email sequences, Visual Blueprint demo script, sales call framework, objection handbook, founding-customer pitch deck, case study template.

### B9. Operations Runbooks
Support playbook (how L1 answers common issues), incident response (what happens when Proposal Builder breaks mid-demo), monitoring playbook (alert → action), per-tenant health check procedure.

### B10. Brand & Marketing Assets
Logo + variants, colour + typography lock, brand voice guide (yours, not clients'), marketing site copy (homepage, pricing, about, case studies stub), social media presence plan.

### B11. Vertical Packs
Dental: Dentally/R4/Sensei integration specs, dental-specific agent prompt overrides, dental pricing framework reference. Agency: agency operator-mode agents. Later: hospitality.

### B12. Quality / Testing Framework
Golden-output fixtures per agent, LLM-as-judge rubrics codified, regression test suite, performance benchmarks (cost-per-invocation ceilings).

---

# PART C — OPEN DECISIONS LOG

Before producing the artifacts in Part D, these decisions need to be made. Some change specs downstream. **Tick these off before starting Phase 1.**

### C1. Strategic (this week)
- [ ] **C1a.** Entity structure: IntelForce AI OS under Intel Force Ltd, or separate company? *(Tax, liability, brand separation implications.)*
- [ ] **C1b.** First vertical focus: Dental (deep research, harder integrations) vs. Agencies (tribal distribution, faster close, white-label angle) — **pick one for weeks 1–12.**
- [ ] **C1c.** Founding customer: name the specific 3 businesses you'll pitch first. Not "dental practices" — actual names.
- [ ] **C1d.** Developer hire: confirm 1-week paid trial structure. Trial spec = ship Proposal Builder agent.md + validation to working state.
- [ ] **C1e.** Pricing lock: confirm the four tiers in Strategic Plan §8.3 are the ones you go to market with, or adjust now.

### C2. Technical (this week)
- [ ] **C2a.** Anthropic API tenancy: your Org or the client's Org? *(Recommended: your Org with per-tenant tags for v1; migrate to client-Org in v2 for enterprise.)*
- [ ] **C2b.** Tenant isolation: shared image with mounted config (recommended for v1) or per-tenant Docker image (for v2).
- [ ] **C2c.** Vault sync default: Git-backed (recommended, free, auditable) or Obsidian Sync (£10/mo, simpler for non-technical clients).
- [ ] **C2d.** Embedding provider: Cohere (EU-hosted, sovereignty story) or OpenAI (cheaper, wider ecosystem). **Recommended: Cohere.**
- [ ] **C2e.** Infrastructure: Hetzner UK / UpCloud LON / AWS London / Azure UK South. **Recommended: Hetzner UK for cost, AWS London for enterprise sales credibility.** Pick one.
- [ ] **C2f.** Control plane framework: Next.js (recommended, same codebase as dashboard) or split (Next.js front + NestJS API). **Recommended: monorepo, single Next.js.**

### C3. Brand (this week)
- [ ] **C3a.** Product name lock: "IntelForce AI OS" final, or variant ("IntelForce OS", "IntelForce Agentic", etc.)?
- [ ] **C3b.** Primary domain: intelforce.ai / intelforce.os / intelforceai.com — check availability, buy now before any branding.
- [ ] **C3c.** Colour palette lock: confirm the deep-black + emerald + amber from the prototype, or propose change now.
- [ ] **C3d.** Typography lock: Fraunces (display) + Geist (body) from prototype — confirm or change.

### C4. Legal (before first contract signed)
- [ ] **C4a.** Solicitor engaged for MSA/DPA review (budget £500–800).
- [ ] **C4b.** Insurance: public liability + professional indemnity quotes obtained.
- [ ] **C4c.** Trademark "IntelForce AI OS" filed at UK IPO (£170).
- [ ] **C4d.** GDPR registration with ICO (£40/year for most SMEs — confirm your obligation level).

### C5. Ops (before week 12)
- [ ] **C5a.** Support tool: Plain, Intercom, or just shared inbox → Slack? **Recommended: shared inbox + dashboard for v1.**
- [ ] **C5b.** Incident comms: status.intelforce.ai or informal Slack? **Recommended: status page before first enterprise client.**
- [ ] **C5c.** On-call: solo vs rotated with dev. **Recommended: solo for first 10 clients, rotate from client #11.**

---

# PART D — PHASED EXECUTION PLAN

Seven phases. Each has a goal, a checklist of artifacts, and a "done when" criterion. For each artifact: purpose, dependency, estimated effort (C = Claude session count, a single focused session), and a suggested prompt to generate it.

Work linearly. Do not start Phase 2 before Phase 1 is ≥90% complete.

---

## PHASE 1 — The Proof-of-Concept Stack (target: end of week 1)

**Goal:** everything needed to run the Proposal Builder end-to-end on one real Fathom call, in one real tenant container. This is the week-1 experiment from Technical Strategy v2 §7.

**Done when:** a real discovery call between you and a friendly prospect produces a drafted proposal in a Gmail inbox within 120 seconds of call end, entirely automated.

### Artifacts

- [ ] **1.1 — Proposal Builder `agent.md` v1** (flagship)
  - *Purpose:* the actual production prompt the agent reads. THE most important document in the entire repo.
  - *Depends on:* C-series decisions locked
  - *Effort:* 2C + 3–5 iterations against real calls
  - *Prompt:* "Write the full production v1 of `proposal-builder/agent.md` per the spec in Build Plan §6. Include YAML frontmatter, role, dynamic context section (with the specific injection markers `context.sh` will fill), the full 9-step Workflow, Output Specification with all 9 required sections, the 7-point Quality Gates checklist, and the 8 Escalation conditions. Write as if committing to production today."

- [ ] **1.2 — Proposal Builder `config.schema.json`**
  - *Purpose:* JSON schema for what the wizard collects to configure this agent per tenant (pricing framework, sales lead email, sign-off block, tier thresholds, disqualifiers).
  - *Depends on:* 1.1
  - *Effort:* 1C
  - *Prompt:* "Write `proposal-builder/config.schema.json` — the exact JSON Schema (draft-07) for what the Configuration Centre wizard collects per tenant to configure this agent. Cover all fields referenced in 1.1's prompt. Include descriptions, examples, and validation rules."

- [ ] **1.3 — Proposal Builder `tools.yaml`**
  - *Purpose:* declares required MCP servers + fallback behaviour if any are unavailable.
  - *Depends on:* 1.1
  - *Effort:* 0.5C
  - *Prompt:* "Write `proposal-builder/tools.yaml` declaring required MCP servers (Fathom, HubSpot, DocuSign, Notion, Gmail), their read/write scopes, and the degraded-mode behaviour when any is unreachable."

- [ ] **1.4 — Proposal Builder `validate.sh`**
  - *Purpose:* PostToolUse hook that validates output structure before it's considered complete. The first line of defence.
  - *Depends on:* 1.1
  - *Effort:* 1C
  - *Prompt:* "Write `proposal-builder/validate.sh` — the PostToolUse hook script that runs after the agent writes a proposal. Implement all 7 structural checks from Build Plan §6 output validation (file exists, markdown parses, 9 sections present, price format, no placeholders, length bounds, transcript quote present). Exit 0 on pass; print failure details to stdout and exit 1 on fail so Claude sees the errors and self-corrects."

- [ ] **1.5 — Proposal Builder `context.sh`**
  - *Purpose:* SessionStart hook that hydrates CLAUDE.md with retrieved past proposals + pricing framework + voice profile.
  - *Depends on:* 1.1, provisional vault structure (1.9)
  - *Effort:* 1C
  - *Prompt:* "Write `proposal-builder/context.sh` — the SessionStart hook that: (1) parses the trigger payload to identify the prospect, (2) queries the pgvector index for 3 most similar past winning proposals, (3) loads the brand voice profile and pricing framework, (4) appends all this into CLAUDE.md's Context section. Assume the vault is at /tenant/vault and pgvector is accessible via a simple CLI wrapper `vault-search`."

- [ ] **1.6 — Proposal Builder test fixtures**
  - *Purpose:* 3 anonymised real-world Fathom transcripts + their golden-output proposals. Regression test harness.
  - *Depends on:* 1.1–1.5 complete
  - *Effort:* 1C + data prep
  - *Prompt:* "Write 3 synthetic but realistic Fathom call transcripts representing: (a) a clear-fit dental practice prospect, (b) an ambiguous scope multi-service prospect, (c) an edge-case prospect with mismatched budget signals. For each, write the golden proposal the agent should produce. Save as `proposal-builder/tests/fixtures/{01-03}.{transcript.json,expected.md}`."

- [ ] **1.7 — Tenant Container Structure Spec**
  - *Purpose:* the Docker image + filesystem layout every tenant runs in. Base primitive for everything downstream.
  - *Depends on:* C2b decision
  - *Effort:* 2C
  - *Prompt:* "Write the Tenant Container Structure Specification: the Dockerfile, base image, filesystem layout (/tenant/.claude/, /tenant/vault/, /tenant/intake/, /tenant/outbox/, /tenant/logs/), environment variables required (ANTHROPIC_API_KEY, tenant ID, integration tokens), runtime permissions, startup/shutdown hooks, and health check. Target: one tenant runnable from a single `docker run` with a config-volume mount."

- [ ] **1.8 — Fathom Webhook Receiver Spec**
  - *Purpose:* the minimum webhook service to receive a Fathom `recording.complete` event and trigger Proposal Builder.
  - *Depends on:* 1.7
  - *Effort:* 1C
  - *Prompt:* "Write the Fathom Webhook Receiver Specification: a Node/Fastify service that receives `POST /hooks/:tenant/fathom`, verifies HMAC signature, persists payload to `/tenant/intake/fathom/{call-id}.json`, invokes Claude Code via child_process (`claude -p ...`), returns 200 within 2s. Include the exact signature verification code, the dispatching command, error handling, and logging format."

- [ ] **1.9 — Minimal Vault Structure**
  - *Purpose:* the starting file tree and templates that a new tenant's vault initialises with.
  - *Depends on:* C2c (vault sync decision)
  - *Effort:* 1C
  - *Prompt:* "Write the Minimal Vault Structure Specification: the starting directory tree for a new tenant's Obsidian vault (/vault/clients, /vault/brand, /vault/sops, /vault/content, /vault/daily, /vault/archive), the seed files with templates (CLAUDE.md, brand/voice-profile.md, brand/pricing.md — all with `[INSERT-FROM-WIZARD]` tokens), the frontmatter conventions (required tags, date formats), and the initial .gitignore + README.md explaining the vault to the client."

- [ ] **1.10 — Week-1 Experiment Runbook**
  - *Purpose:* step-by-step procedure you follow to prove the POC works. Not a spec — an execution guide.
  - *Depends on:* all of 1.1–1.9
  - *Effort:* 1C
  - *Prompt:* "Write the Week-1 Experiment Runbook: exact step-by-step commands to (1) spin up a test tenant container on a local Mac, (2) configure test API keys, (3) run a real test Fathom call, (4) verify the webhook fires, (5) verify Claude Code runs with Proposal Builder, (6) verify output lands in Gmail drafts, (7) measure end-to-end time. Include the pass/fail criteria, expected token spend (with target range), and the specific failure modes to debug first."

**Phase 1 Done When:** artifact 1.10 has been executed successfully with a real call. One working Proposal Builder end-to-end on real infrastructure. ~2 weeks realistic effort with 1 developer.

---

## PHASE 2 — The Full Agent Suite (target: end of week 4)

**Goal:** all 9 core agents + The Librarian fully specified as ship-ready agent bundles, plus the agent template library structure that holds them.

**Done when:** every core agent has its 6-file bundle committed to the agent library repo, and the first 3 (sales trio) are running in a test tenant.

### Artifacts

- [ ] **2.1 — Agent Library Repo Structure**
  - *Purpose:* the private GitHub repo that holds all agent templates, with CI, versioning, and release procedures.
  - *Depends on:* 1.1 template established
  - *Effort:* 1C
  - *Prompt:* "Write the Agent Library Repo Structure Specification: repo layout (agents/, addons/, verticals/, shared/), versioning convention (semver per agent folder), CHANGELOG.md pattern, CI workflow that runs every agent's test suite on PR, and release procedure (how pushing agents/proposal-builder@2.1 flows through to tenant rollouts)."

- [ ] **2.2 — Lead Hunter full bundle** (6 files) — `agent.md`, schema, tools, validate, context, fixtures
  - *Prompt per file same pattern as 1.1–1.6, following the spec in Build Plan §5. Bundle as one prompt:*
  - *Prompt:* "Produce the full Lead Hunter agent bundle per Build Plan §5: `agent.md` (Haiku-targeted, ICP-rubric-driven prompt), `config.schema.json` (ICP definition schema with industry SIC codes, employee bands, geography, revenue, disqualifiers), `tools.yaml` (Companies House, Prospeo, Kaspr, HubSpot — declare as UK-context stack, NOT Apollo), `validate.sh` (JSON schema + dedup + completeness checks), `context.sh` (no heavy retrieval — inject current CRM record hashes for dedup), 3 test fixtures + golden lead outputs."
  - *Effort:* 3C

- [ ] **2.3 — Follow-Up Pilot full bundle** (6 files) — Build Plan §7. *Effort: 2.5C*
- [ ] **2.4 — Content Creator full bundle** (6 files) — Build Plan §8. *Effort: 3C (voice profile integration is heavier)*
- [ ] **2.5 — Repurposer full bundle** (6 files) — Build Plan §9. *Effort: 2.5C*
- [ ] **2.6 — Caption Writer full bundle** (6 files) — Build Plan §10. *Effort: 2C (simpler agent)*
- [ ] **2.7 — Client Onboarder full bundle** (6 files) — Build Plan §11. *Effort: 3C (many integrations)*
- [ ] **2.8 — Reporting Engine full bundle** (6 files) — Build Plan §12. *Effort: 3C (data pipelines)*
- [ ] **2.9 — SOP Writer full bundle** (6 files) — Build Plan §13. *Effort: 2.5C*
- [ ] **2.10 — The Librarian full bundle** (6 files) — Build Plan §18. *Effort: 2.5C*

- [ ] **2.11 — Standard sub-agent template (blank)**
  - *Purpose:* the scaffold a new agent starts from. Copy-paste-rename to create the 11th agent later.
  - *Depends on:* 2.2 pattern established
  - *Effort:* 1C
  - *Prompt:* "Produce a blank Standard Sub-Agent Template with placeholder content in every file (agent.md, config.schema.json, tools.yaml, validate.sh, context.sh, tests/README.md) and a CREATING_A_NEW_AGENT.md guide that walks through filling it in."

- [ ] **2.12 — LLM-as-Judge Rubric Library**
  - *Purpose:* every agent's quality rubric codified as prompts for the Haiku grader.
  - *Depends on:* 2.2–2.10 complete
  - *Effort:* 2C
  - *Prompt:* "Write the LLM-as-Judge Rubric Library: one rubric prompt per agent (10 total including Librarian) following the 0–5 scoring pattern in Build Plan §2.2. Each rubric is a standalone file (`rubrics/{agent-name}.md`) with: the exact grader system prompt, the 4–5 scoring dimensions, the passing threshold, the feedback-on-fail format."

**Phase 2 Done When:** every agent bundle exists in the repo. Sales trio (Proposal Builder, Lead Hunter, Follow-Up Pilot) actually running in the test tenant. Remaining 7 agents specified but not necessarily running yet.

---

## PHASE 3 — Platform Engineering Specs (target: end of week 7)

**Goal:** developer-ready specifications for every platform component. Enough detail that a competent engineer starts coding without asking clarifying questions.

**Done when:** every component has a spec the dev can build from. Provisioning system and wizard actually operational.

### Artifacts

- [ ] **3.1 — Provisioning System Engineering Spec**
  - *Purpose:* the state machine and orchestrator that turns "wizard complete" → "9 agents running in 15 minutes". Your core IP.
  - *Depends on:* 2.2–2.10 (needs all agent schemas)
  - *Effort:* 3C
  - *Prompt:* "Write the Provisioning System Engineering Specification per Build Plan §19: the full state machine (every step as a state with entry/exit conditions), the exact data flow from `wizard.config.json` through template rendering → secret encryption → vault initialisation → voice ingestion trigger → embedding index → container start → cron install → webhook register → smoke tests → dashboard go-live. Cover: idempotency, atomic rollback on any failure, versioning of every output, observability hooks, the exact CLI commands. Target: a senior dev can implement in 2 weeks from this spec alone."

- [ ] **3.2 — Configuration Centre Wizard Full UX Spec**
  - *Purpose:* every step of the 5-step wizard with copy, interaction states, and client-facing logic.
  - *Depends on:* 2.2–2.10 (config schemas feed into this), C1 decisions
  - *Effort:* 4C + UX iteration
  - *Prompt:* "Write the Configuration Centre Wizard Full UX Specification: each of the 5 steps (Company Profile, Integrations, Agent Selection, Voice & Context Training, Go-Live) as its own section covering: every field on the screen with label + placeholder + help text + validation rules, the interaction flow, the error states, the empty states, the progress indicators, autosave behaviour, the resume-mid-flow behaviour, the step-to-step navigation logic. Include the copy voice — warm, confident, never condescending, UK-English spellings. This doc feeds a designer and a dev in parallel."

- [ ] **3.3 — Voice Ingestion Pipeline Spec**
  - *Purpose:* the critical pipeline where uploaded past proposals → structured voice profile. Quietly one of the highest-leverage components.
  - *Depends on:* 1.9, C2d (embedding provider)
  - *Effort:* 2C
  - *Prompt:* "Write the Voice Ingestion Pipeline Specification: the pipeline that takes client-uploaded documents (PDFs of past proposals, brand guidelines, sample emails — up to 50MB mixed formats) and produces: (1) a structured `voice-profile.md` with tone descriptors + banned phrases + rhythm analysis + signature turns-of-phrase, (2) a `pricing-framework.md` extracted from past proposals, (3) chunked + embedded vault entries for retrieval. Cover: document parsing (mammoth for docx, pypdf for PDF, plaintext for rest), chunking strategy (semantic not fixed-size), embedding call batching, the LLM pipeline that produces the voice profile (Sonnet 4.6 reading 5–20 samples and writing the profile), validation checkpoint where client reviews and edits before approving. Include edge cases (document in non-English, mixed formats in one upload, corrupt PDFs)."

- [ ] **3.4 — Vault Service Engineering Spec**
  - *Purpose:* how the Obsidian vault is stored, synced, accessed by three surfaces (Claude Code, dashboard, client's Obsidian).
  - *Depends on:* C2c decision
  - *Effort:* 2C
  - *Prompt:* "Write the Vault Service Engineering Specification per Build Plan §25: git-backed sync architecture (private repo per tenant, auto-commit on agent writes, branching strategy, conflict handling), file-watcher → WebSocket → dashboard flow for live updates, the server-side renderer for the dashboard Brain view, security model (encryption at rest, per-tenant access control), backup strategy (UK-only retention), and the client-side Obsidian setup doc."

- [ ] **3.5 — Webhook Receiver Engineering Spec** (expanded from 1.8)
  - *Purpose:* the full multi-integration webhook service (not just Fathom).
  - *Depends on:* 1.8 established pattern
  - *Effort:* 2C
  - *Prompt:* "Expand 1.8 into the full Webhook Receiver Engineering Specification covering all integrations in Build Plan §22: per-integration signature verification (Fathom HMAC, Stripe signature+timestamp, HubSpot HMAC, DocuSign HMAC, Loom — document each one explicitly with code snippets), per-tenant rate limiting, dead-letter queue design (Redis-backed), replay UX for DLQ items, BullMQ enqueue pattern, and the router that maps `/{tenant}/{integration}` to the right agent invocation."

- [ ] **3.6 — Scheduler Engineering Spec**
  - *Purpose:* BullMQ-based cron replacement that runs per-tenant, centralised, observable.
  - *Depends on:* 1.7 (tenant model)
  - *Effort:* 1.5C
  - *Prompt:* "Write the Scheduler Engineering Specification per Build Plan §23: BullMQ + Redis setup (single repeatable queue per tenant, priority queues for critical agents like Proposal Builder), tenant schedule loading from Postgres on boot + on config change, per-agent cron expressions (list them all for a reference tenant), retry policies (exponential backoff per agent type), pause/resume per tenant, dashboard integration for visibility."

- [ ] **3.7 — MCP Integration Layer Spec**
  - *Purpose:* how MCP servers are managed per-tenant, health-monitored, OAuth-refreshed.
  - *Depends on:* 1.7, 3.1 (provisioning writes mcp.json)
  - *Effort:* 2C
  - *Prompt:* "Write the MCP Integration Layer Specification per Build Plan §24: per-tenant `mcp.json` generation, OAuth refresh service (background worker that refreshes tokens 1h before expiry), MCP server health monitoring (ping + response time), degraded-mode behaviour when a server fails (queue for retry, or fallback to API wrapper), auto-update policy for MCP server versions. Also: the MCP Inventory table with 15 integrations listing status (official/community/build-your-own), decision on which approach for each."

- [ ] **3.8 — Individual Integration Specs (one per MCP server/API)**
  - *Purpose:* the implementation recipe for each of the 15 integrations at launch.
  - *Depends on:* 3.7 pattern established
  - *Effort:* ~0.75C each = 12C total across 15 integrations
  - *Prompt per integration:* "Write the {Integration Name} Integration Specification: the MCP server choice (fork X / build from Y spec / official), auth setup (OAuth flow or API key), the scopes/permissions required and why, the specific operations used by agents (read leads, write deals, fetch transcript, etc.), fallback behaviour on failure, test checklist, rate limit handling. Priority 1 integrations: Fathom, HubSpot, Gmail, Slack, Notion, DocuSign. Priority 2: Companies House, Prospeo, Kaspr, Stripe, GA4, Meta Ads, Cal.com, Loom, Google Drive."

- [ ] **3.9 — Observability Stack Spec**
  - *Purpose:* logging, metrics, tracing, alerts end-to-end.
  - *Depends on:* 3.1, 3.5, 3.6
  - *Effort:* 2C
  - *Prompt:* "Write the Observability Stack Engineering Specification per Build Plan §26: structured log format (JSON schema for agent invocations, errors, webhook events), Vector.dev shipping config, Postgres partitioned storage schema, the 3 Grafana dashboards (operator cross-tenant, per-tenant client-facing, cost trends), the alert rules (exact thresholds for: error rate, cost overrun, integration down, vault write failures, LLM-judge drift), tracing setup (OpenTelemetry), and the trace-id propagation through webhook → queue → Claude → MCP."

- [ ] **3.10 — Cost & Billing System Spec**
  - *Purpose:* per-tenant cost allocation, Stripe subscriptions, overage handling.
  - *Depends on:* 3.9 (uses cost data)
  - *Effort:* 2C
  - *Prompt:* "Write the Cost & Billing System Engineering Specification per Build Plan §27: the Anthropic API metadata tagging pattern for per-tenant attribution, the third-party API cost tracking table schema, the infra cost allocation formula, Stripe subscription setup (price IDs per tier, metered overages, setup fees as one-off invoices), the dashboard view that shows clients their current usage against allowance, the operator view that shows gross margin per tenant + anomaly detection."

- [ ] **3.11 — Audit & Compliance Spec**
  - *Purpose:* GDPR flows, audit log design, UK sovereignty posture.
  - *Depends on:* 3.4, 3.9
  - *Effort:* 2C
  - *Prompt:* "Write the Audit & Compliance Engineering Specification per Build Plan §28: the immutable audit log design (append-only Postgres with INSERT-only trigger, event schema), the DSAR flow (the 'export everything on this person' SQL + file-system queries + zip packaging), the right-to-erasure flow with its caveats (what you can and can't delete), the sub-processor list (Anthropic, Cohere/OpenAI, Stripe, AWS/Hetzner, GitHub, every MCP provider in use), the 7-year retention policy implementation, the UK-sovereignty attestation (regions, providers, data flows)."

- [ ] **3.12 — Human-in-the-Loop Approval System Spec**
  - *Purpose:* the queue, the UI, the SLA policies, the client configurability.
  - *Depends on:* Dashboard specs (Phase 4), but this spec can be written in parallel
  - *Effort:* 2.5C
  - *Prompt:* "Write the Human-in-the-Loop Approval System Engineering Specification per Build Plan §29: queue item schema, the state machine per item (created → pending → approved / rejected / edited / escalated → executed / cancelled), SLA policy engine (thresholds per agent type, urgency escalation, breach notifications), the UI interaction spec (list view, detail view, inline edit, batch select, keyboard shortcuts), client-configurable policy rules, auto-approval rule engine, integration into agent workflows (how an agent hands off to the queue and resumes after approval)."

**Phase 3 Done When:** every spec in §3 is committed to docs repo. The Provisioning System is actually operational. The Wizard UX is in Figma or coded.

---

## PHASE 4 — Dashboard Production Build (target: end of week 9)

**Goal:** full production dashboard covering all 10 views with a proper design system, across desktop and mobile.

**Done when:** a tenant can log in to a production dashboard at `app.intelforce.ai`, see every view, perform every action, and the dashboard never looks like "the prototype".

### Artifacts

- [ ] **4.1 — Design System Doc**
  - *Purpose:* the tokens (colour, spacing, typography, motion) that every view uses. Written once, referenced forever.
  - *Depends on:* C3c, C3d (brand locks)
  - *Effort:* 2C
  - *Prompt:* "Write the IntelForce AI OS Design System Specification: colour tokens (primary, secondary, accent, semantic — success/warning/error/info — neutral scale, with light + dark theme variants), typography scale (headings/body/mono with line heights and letter spacing), spacing scale, border radius scale, shadow scale, motion curves + durations, component patterns (buttons, inputs, cards, tables, modals, toasts, badges). Written as CSS variable declarations AND as human-readable rationale for each choice."

- [ ] **4.2 — Information Architecture + Navigation Spec**
  - *Purpose:* sitemap, URL structure, navigation patterns, breadcrumbs, mobile nav.
  - *Depends on:* 4.1
  - *Effort:* 1C
  - *Prompt:* "Write the IntelForce AI OS Information Architecture and Navigation Specification: the full sitemap (every view + sub-view), URL structure (e.g. `/app/{tenant}/agents/proposal-builder`), navigation patterns (top-bar for tenant/account, left-rail for primary nav, contextual secondary nav), breadcrumbs, mobile navigation (bottom tab bar with 5 items max), state preservation when navigating, deep-linking behaviour."

- [ ] **4.3 — Home / Hierarchy View full spec** (the prototype, productionised)
  - *Effort:* 1C
  - *Prompt:* "Expand the Home / Hierarchy view from the prototype into the production Engineering + UX Specification: real-time data flow, zoom/pan interactions, layout algorithm for N agents (current is hardcoded for 9), click-to-detail interaction, loading states, empty states, error states, export-as-image, keyboard navigation for accessibility."

- [ ] **4.4 — Activity Log View full spec**
  - *Effort:* 1C
  - *Prompt:* "Write the Activity Log View Specification: table columns, filter chips (by agent, by status, by date range, by approval state), search behaviour, pagination (virtualised for 10k+ entries), export (CSV + JSON), row-click to invocation detail, real-time streaming at the top, indicators for items requiring human review."

- [ ] **4.5 — Agents View full spec**
  - *Purpose:* per-agent configuration page, run history, cost trend.
  - *Effort:* 1.5C
  - *Prompt:* "Write the Agents View Specification: the list layout, per-agent detail page (config editor with diff-view vs template defaults, run history with outcome filters, cost trend chart, test-run button with sandbox execution, version pinning UI, pause/resume controls), changes-require-approval flow when editing config."

- [ ] **4.6 — Brain View full spec (the Obsidian vault graph rendered in-app)**
  - *Purpose:* the sales-differentiator view. A force-directed graph of the client's knowledge.
  - *Depends on:* 3.4 (vault service)
  - *Effort:* 2.5C
  - *Prompt:* "Write the Brain View full Engineering + UX Specification: the D3 force-simulation rendering (nodes = notes, edges = wikilinks, colour = category), node-click to preview panel, search across all notes (client-side fuzzy + server-side semantic fallback), filter by tag/agent/date, inline edit from preview, 'create new note' flow, performance budgets for 10k+ notes (virtualised rendering, lazy edge computation), export-as-PNG. This is the view you'll demo most — spec it as your hero UX."

- [ ] **4.7 — Approvals View full spec**
  - *Purpose:* the HITL queue in the dashboard.
  - *Depends on:* 3.12
  - *Effort:* 1.5C
  - *Prompt:* "Write the Approvals View Specification: the queue list (filterable by agent, SLA, client), the item detail page with inline preview + edit, batch-select UI, keyboard shortcuts (Approve = A, Reject = R, Edit = E), the 'edit and send' flow with diff against agent output, the reject-with-reason modal, real-time updates, mobile layout with stack of cards."

- [ ] **4.8 — Integrations View full spec**
  - *Effort:* 1C
  - *Prompt:* "Write the Integrations View Specification: grid of connected integrations with health indicators, per-integration detail (OAuth status, last sync, scope, usage stats), reconnect flow, test connection button, add-integration flow."

- [ ] **4.9 — Billing View full spec**
  - *Depends on:* 3.10
  - *Effort:* 1C
  - *Prompt:* "Write the Billing View Specification: current plan + next invoice, current-month usage against allowance with forecast, invoice history + download, payment method management (Stripe Customer Portal link), plan upgrade/downgrade flow, overage projection alerts."

- [ ] **4.10 — Team View full spec**
  - *Effort:* 0.5C
  - *Prompt:* "Write the Team View Specification: user list with roles, invite flow, role-permission matrix (owner/admin/viewer/integration-manager), transfer-ownership flow, audit log of role changes."

- [ ] **4.11 — Audit Log View full spec**
  - *Depends on:* 3.11
  - *Effort:* 0.5C
  - *Prompt:* "Write the Audit Log View Specification: immutable event list, filters by actor/action/resource, signed export format, search, retention display."

- [ ] **4.12 — Settings View full spec**
  - *Effort:* 0.5C
  - *Prompt:* "Write the Settings View Specification: tenant-wide config (brand voice re-training trigger, notification preferences, approval policies, working hours, data residency info), danger-zone (pause all agents, archive tenant, delete data)."

- [ ] **4.13 — Mobile Responsive Design Spec**
  - *Purpose:* how every view collapses gracefully on mobile.
  - *Effort:* 1.5C
  - *Prompt:* "Write the Mobile Responsive Design Specification: breakpoints (320/480/768/1024), mobile navigation pattern (bottom tabs), per-view mobile layouts (Home → stacked metrics + simplified hierarchy, Activity → card stream, Brain → simplified graph with pan+zoom, Approvals → swipe-to-approve card), gesture interactions, PWA installability."

**Phase 4 Done When:** all 13 specs written, design system codified as CSS variables, first 5 views (Home, Activity, Brain, Approvals, Agents) actually built and deployed to a staging environment.

---

## PHASE 5 — Business & Commercial Artifacts (target: end of week 11)

**Goal:** everything needed to charge money, close a contract, and market the product.

**Done when:** you have signed legal documents, a live pricing page, and cold outbound sequences running.

### Artifacts

- [ ] **5.1 — Master Services Agreement (MSA) template**
  - *Purpose:* the core commercial contract with every client.
  - *Depends on:* C4a (solicitor engaged)
  - *Effort:* 1C draft + solicitor review
  - *Prompt:* "Draft an MSA template for IntelForce AI OS: parties, scope of services referencing the 9 core agents + add-ons, service levels (uptime target, response time targets), fees + payment terms (monthly retainer + setup + overages), term + termination (rolling monthly with 30 day notice, immediate for material breach), IP (client retains their data + voice profile; IntelForce retains the platform + agent templates), confidentiality, warranties, liability caps, indemnification, UK law + England jurisdiction. Mark solicitor-review-required clauses clearly. Written in plain English with legal precision, not dense legalese."

- [ ] **5.2 — Data Processing Agreement (DPA) template**
  - *Depends on:* 3.11
  - *Effort:* 1C draft + solicitor review
  - *Prompt:* "Draft a GDPR-compliant DPA template per Article 28: parties as controller/processor, nature + purpose of processing (AI agents executing on client data to produce business outputs), categories of data subjects + personal data, security measures (reference 3.11), sub-processors list (Anthropic, Cohere, Stripe, Hetzner, every MCP provider), sub-processor change notification policy (30 day notice, right to object), data subject rights assistance, breach notification (72h), audit rights, return/deletion on termination, UK addendum for international transfers."

- [ ] **5.3 — Sub-Processor List (published, public)**
  - *Depends on:* 5.2
  - *Effort:* 0.5C
  - *Prompt:* "Produce the public-facing IntelForce AI OS Sub-Processor List as a markdown page: table of every third-party service processing client data, their role, data categories, location, privacy policy link. Include the 30-day notification policy statement."

- [ ] **5.4 — Terms of Service (self-serve tier)**
  - *Effort:* 0.5C
  - *Prompt:* "Draft the IntelForce AI OS Terms of Service for self-serve sign-ups (not the MSA clients). Cover: acceptable use, prohibited uses (generating spam, circumventing rate limits, reverse engineering), account responsibilities, termination, fees, warranty disclaimers, liability limits, UK law."

- [ ] **5.5 — Privacy Policy + Cookie Policy**
  - *Effort:* 1C
  - *Prompt:* "Draft the IntelForce AI OS Privacy Policy and Cookie Policy in line with UK GDPR + PECR: what data we collect (from clients + from visitors), why, lawful basis, retention, rights, cookies used (strictly necessary, analytics, none third-party marketing), DPO contact, ICO registration number."

- [ ] **5.6 — Founding Customer Agreement**
  - *Purpose:* short-form side-agreement for the first 5 discounted customers.
  - *Effort:* 0.5C
  - *Prompt:* "Draft the Founding Customer Agreement: 40% discount on setup, 20% discount on retainer, locked for 12 months, in exchange for: (1) video case study rights, (2) logo use on marketing site, (3) written testimonial, (4) 1 referral intro within 6 months. Terms + signature block."

- [ ] **5.7 — Pricing Page Copy**
  - *Depends on:* C1e (pricing locked)
  - *Effort:* 1C
  - *Prompt:* "Write the IntelForce AI OS Pricing Page Copy: four tiers (Starter, Growth, Scale, Enterprise) with the exact price, the 'what's included' bullet list, the addons table, the FAQ section (10 questions), the comparison table, the 'not sure which tier?' CTA → audit call. Tone: confident, specific, never needs to shout. UK English."

- [ ] **5.8 — Marketing Site Copy — Homepage**
  - *Effort:* 1C
  - *Prompt:* "Write the IntelForce AI OS Homepage Copy: hero (headline + subhead + dual CTAs), 'What it is' section (3-column or narrative), 'The 9 Agents' section (interactive card list), 'Why it's different' (the UK-sovereign + agency-white-label + Rigby credibility triangle), social proof strip, 'How it works' (4 steps), final CTA. Tone matches Pricing Page — confident, specific, lifestyle-adjacent without being fluffy."

- [ ] **5.9 — Marketing Site Copy — About + Case Studies stub**
  - *Effort:* 0.5C
  - *Prompt:* "Write the About page and Case Studies page shell. About covers the IntelForce thesis, Maddox's background, Rigby Group connection (appropriately referenced), the team (starting with Maddox + dev). Case Studies shell has the structure but with 3 placeholder entries to be filled post-founding customers."

- [ ] **5.10 — Cold Outbound Email Sequences (Dental vertical)**
  - *Depends on:* C1b (vertical choice)
  - *Effort:* 1C + testing
  - *Prompt:* "Write the Cold Outbound Email Sequence for UK Dental Practices: 5-email sequence, first one is 90 words max, each subsequent one adds specific proof/value, sequence ends in 'final friendly close', Loom demo link in email 3, cal.com in email 5. Variant A: Visual Blueprint hook. Variant B: ROI hook (missed call cost). Include subject lines, send cadence, personalisation tokens."

- [ ] **5.11 — Cold Outbound Email Sequences (Agency vertical)**
  - *Depends on:* C1b
  - *Effort:* 1C
  - *Prompt:* "Write the Cold Outbound Email Sequence for UK Marketing Agencies: same structure as 5.10, angle is 'stop selling workflows you can't build — use and resell the platform that runs your agency AND your clients' businesses'. Emphasise agency partner white-label angle."

- [ ] **5.12 — Visual Blueprint Demo Script**
  - *Purpose:* the 45-minute live screen-share that closes prospects.
  - *Effort:* 1.5C
  - *Prompt:* "Write the Visual Blueprint Demo Script: the 45-minute call flow — opening (5 min), discovery Qs (10 min), live configuration of a fake tenant with their branding (15 min — the 'wow moment'), running a fake Proposal Builder end-to-end (5 min), pricing walkthrough (5 min), close (5 min). Include the exact talk-track per section, the objection hooks, the moments to pause for reaction, the close language."

- [ ] **5.13 — Sales Objection Handbook**
  - *Effort:* 1C
  - *Prompt:* "Write the Sales Objection Handbook for IntelForce AI OS: 15 most likely objections with the framework for handling each (acknowledge → clarify → address → confirm), covering: pricing sticker shock, 'AI will replace my team', data security fears, 'we tried ChatGPT already', 'we don't have the tools you integrate with', 'we don't do sales like this', implementation effort, vendor lock-in, what-happens-if-Anthropic-raises-prices, Claude vs ChatGPT, AI hallucination trust, GDPR concerns, off-shore processing concerns, ROI proof demand, 'I need to think about it'."

- [ ] **5.14 — Founding Customer Pitch Deck**
  - *Effort:* 1.5C
  - *Prompt:* "Write the Founding Customer Pitch Deck: 10–12 slides covering vision, the 9 agents, live demo reference, founding-customer offer specifics, timeline, founding customer commitments (case study + testimonial + referrals), next step. Narrative order, slide titles + bullet contents + speaker notes. Design-friendly (not text-dense)."

- [ ] **5.15 — Case Study Template**
  - *Effort:* 0.5C
  - *Prompt:* "Write the Case Study Template: structure for future case studies (problem, before-state, the implementation, results in numbers, client quote, duration, agents-enabled, outcome hero). Written to be filled in within 90 minutes of a 1-hour founding customer interview."

**Phase 5 Done When:** legal docs signed off by solicitor, marketing site live (can be static HTML), first 50 cold outbound emails sent.

---

## PHASE 6 — Operations & Launch Readiness (target: end of week 13)

**Goal:** everything needed to support paying clients without embarrassing yourself.

**Done when:** first founding customer has onboarded and there's documented procedure for every support/incident scenario you've encountered.

### Artifacts

- [ ] **6.1 — Client Onboarding Human-Hours Playbook**
  - *Purpose:* the 4-hour human time spec per tenant — exactly what YOU do during their onboarding.
  - *Depends on:* 3.2
  - *Effort:* 1C
  - *Prompt:* "Write the Client Onboarding Human-Hours Playbook: the exact 4-hour breakdown across the 72-hour window: pre-wizard 30-min kickoff call script, mid-wizard voice-profile review (60 min), smoke-test review (30 min), go-live call (90 min), week-1 check-in (30 min). Each with: objectives, agenda, artefacts produced, what 'success' looks like."

- [ ] **6.2 — Support Playbook (L1 runbook)**
  - *Effort:* 1.5C
  - *Prompt:* "Write the IntelForce AI OS Support Playbook: the 20 most likely client support tickets (agent produced bad output, integration disconnected, can't log in, need user added, billing question, want to pause agent, want to rename agent, want new capability, approval queue stuck, question about a log entry, invoice dispute, want to downgrade, want to upgrade, data export request, GDPR DSAR, cancellation request, 'it's not working' vague, hallucination complaint, proposal draft was wrong, voice is drifting). Per ticket: diagnostic questions, resolution steps, escalation path, expected resolution time, template response."

- [ ] **6.3 — Incident Response Runbook**
  - *Effort:* 1.5C
  - *Prompt:* "Write the Incident Response Runbook for IntelForce AI OS: incident severity levels (SEV1 data loss or breach / SEV2 multi-tenant outage / SEV3 single-tenant agent broken / SEV4 cosmetic), the response flow per severity, communication templates (status page entries, client notification emails), the incident review template (blameless postmortem), the retro cadence."

- [ ] **6.4 — Monitoring & Alert Playbook**
  - *Depends on:* 3.9
  - *Effort:* 1C
  - *Prompt:* "Write the Monitoring & Alert Playbook: every alert the observability stack fires, with for each: the condition that triggers it, the likely root causes, the diagnostic commands, the resolution steps, the escalation rules. Organise by severity tier."

- [ ] **6.5 — Agency Partner Onboarding Playbook**
  - *Depends on:* 3.12-equivalent for Agency Partner, Phase 7 eventually
  - *Effort:* 1C
  - *Prompt:* "Write the Agency Partner Onboarding Playbook: the differentiated onboarding for agencies who are reselling (vs direct clients). Covers: partner agreement signing, white-label setup, their own wizard training, first sub-tenant co-onboarding, ongoing partner support cadence, quarterly partner reviews."

- [ ] **6.6 — Dev Setup / Runtime Operations Guide**
  - *Purpose:* the 'day 1 at IntelForce' doc for a new dev.
  - *Effort:* 1C
  - *Prompt:* "Write the Dev Setup / Runtime Operations Guide: everything a new engineer needs in week 1 — local dev environment setup, staging environment access, the test tenant, how to run an agent locally, how to debug a failed webhook, how to inspect a vault, how to query a tenant's logs, how to deploy an agent library update, emergency procedures (rolling back, pausing a tenant, failing over)."

- [ ] **6.7 — Status Page Setup**
  - *Depends on:* C5b
  - *Effort:* 0.5C + config
  - *Prompt:* "Write the Status Page Setup Specification: platform choice (recommend Instatus or Statuspage), what to monitor (API, each core integration, control plane, vault service), incident communication templates, subscriber notification policy."

**Phase 6 Done When:** first founding customer live for 30+ days without catastrophic issue, all learnings fed back into the playbooks.

---

## PHASE 7 — Post-Launch Expansion (months 4–6)

**Goal:** vertical packs, add-ons, and the Agency Partner white-label fully operational.

### Artifacts

- [ ] **7.1 — Dental Vertical Pack** (agents, integrations, pricing reference)
  - *Effort:* 4C across multiple sub-artefacts
  - *Prompt:* "Produce the complete Dental Vertical Pack: (a) Dentally MCP server spec (build from their API docs), (b) R4/Sensei/SOE Exact middleware spec, (c) dental-specific agent prompt overrides (Content Creator tone for clinical safety, Lead Hunter ICP for UK private practices, Proposal Builder with treatment-plan format), (d) dental pricing framework reference (typical treatment prices, retainer structures), (e) dental case studies template, (f) dental-specific compliance notes (GDC, CQC, medical confidentiality)."

- [ ] **7.2 — Agency Vertical Pack**
  - *Effort:* 3C
  - *Prompt:* "Produce the complete Agency Vertical Pack: agency-specific agent prompt overrides (Proposal Builder knows agency scope patterns, Reporting Engine produces white-labelled client reports), the Agency Partner white-label architecture deep dive, sub-tenant provisioning flow for partners, partner billing model."

- [ ] **7.3 — Voice Receptionist Full Spec (Vapi architecture)**
  - *Depends on:* Build Plan §14
  - *Effort:* 3C
  - *Prompt:* "Write the Voice Receptionist Full Specification: the Vapi platform configuration (assistants, tools, actions), the pre-call context injection (practice info, FAQs, protocols), the in-call escalation triggers, the post-call Claude Code agent that processes the call outcome, the Calendly/Cal.com booking flow, the FAQ training pipeline, the edge cases (accents, complaints, emergencies, out-of-hours), the testing framework (100+ test calls before launch)."

- [ ] **7.4 — HR Agent Full Spec**
  - *Depends on:* Build Plan §15
  - *Effort:* 1.5C
  - *Prompt:* "Write the HR Agent Full Specification per Build Plan §15."

- [ ] **7.5 — SEO Brief Generator Full Spec**
  - *Depends on:* Build Plan §16
  - *Effort:* 1.5C
  - *Prompt:* "Write the SEO Brief Generator Full Specification per Build Plan §16."

- [ ] **7.6 — Paid Ads Copywriter Full Spec**
  - *Depends on:* Build Plan §17
  - *Effort:* 1.5C
  - *Prompt:* "Write the Paid Ads Copywriter Full Specification per Build Plan §17."

- [ ] **7.7 — Hospitality Vertical Pack** (post-dental, post-agency)
  - *Effort:* 3C
  - *Prompt:* "Produce the complete Hospitality Vertical Pack for boutique hotels and Eden-adjacent properties: booking engine integrations (Mews, Cloudbeds), hospitality-specific agents (concierge assistant, guest-experience reporter), voice receptionist tuning, luxury brand voice patterns."

- [ ] **7.8 — Affiliate / Referral Program Spec**
  - *Effort:* 1C
  - *Prompt:* "Design the IntelForce AI OS Affiliate/Referral Program: commission structure (one-off vs recurring, typical 20% year-one / 10% year-two), tracking mechanism (Rewardful / FirstPromoter / built-in), payout process, affiliate onboarding, marketing kit."

**Phase 7 Done When:** first vertical pack deployed to 3+ clients. Voice Receptionist live with first dental client. Agency Partner program has closed its first partner.

---

# PART E — HOW TO WORK THIS DOCUMENT

### E1. Work order
Do **Open Decisions (Part C) first.** Every item is blocking or information-shaping. Get them done in a single focused day — the whole rest of the plan depends on them.

Then work **phases in strict order.** Phase 2 cannot start productively before Phase 1 proves the runtime. Phase 3 can't be finalised without Phase 2's agents being real.

Within a phase, order items by the dependency markers. 1.1 before 1.4 before 1.6. Unblock parallel tracks where the *Depends on* line has nothing upstream.

### E2. Effort unit — the "C"
"C" = one focused Claude session (roughly 30–60 minutes of generation + iteration). These estimates are for generating the *first draft* of an artifact. Add 20–50% for revisions, human review, and real-world validation.

Total effort estimate across all 7 phases: **~135 C sessions.**

At 3–5 C sessions per day with review interleaved, that's **6–9 weeks of concentrated work**. Aligns well with your 14-week build plan when paralleled with development.

### E3. Two types of artifact
Every item is one of:
- **Spec** — a document for a human (dev, designer, lawyer, writer) to consume
- **Artifact** — a file that gets committed directly into the product (agent.md, validate.sh, CSS variables, copy)

Both use the same prompt pattern, but artifacts need more precision and should be reviewed against real use before being "done".

### E4. What I should generate versus what you should do
- **Claude generates:** all specs, all copy drafts, all technical artifacts, all code templates, all schemas.
- **You decide:** the Open Decisions (Part C), the tone nuances, the vertical choice, which founding customers.
- **Human professionals:** solicitor reviews MSA/DPA (5.1, 5.2), designer polishes the dashboard specs (4.1, 4.6), voice-over artist records the Voice Receptionist greetings (7.3).

### E5. Resist scope creep
The single biggest risk to this plan is you reading the Build Plan again, getting excited about some new idea, and bolting a 47th agent onto the spec. **Freeze scope at the end of Phase 3.** Anything new goes into "v1.1 backlog" — a single markdown file you add ideas to. You look at that backlog quarterly, not weekly.

### E6. When you get stuck
The artifacts that commonly block:
- **Voice profile** — takes real past proposals. If you don't have 3+ from a founding customer, the voice profile is speculative. Do the founding customer discovery first.
- **LLM-as-judge rubrics** — impossible to tune without seeing real outputs fail. Ship the agent first, tune the rubric second.
- **Sales scripts** — need real demo feedback. Do 5 demos with the rough script, rewrite based on objections actually heard.

When blocked on these, skip forward to an unblocked item. Come back.

### E7. Definition of ready-for-Claude-Code
You're ready to hand this to Claude Code for heads-down build when:
- [ ] Every artifact in Phases 1–3 is committed to a private docs repo
- [ ] The dev hire is onboarded and has read every doc in Phases 1–3
- [ ] Open Decisions are fully resolved
- [ ] The MSA + DPA from Phase 5 are drafted (don't need to be solicitor-signed yet)
- [ ] The founding customer is lined up (verbal commit, even if contract not signed)
- [ ] Your development and staging environments exist
- [ ] The first agent library repo exists with Phase 2 bundles committed

When all seven boxes above are ticked: Claude Code has every input it needs. The remaining Phases 4–7 happen alongside and after the build, not before.

### E8. The single most important thing in this whole document
**Do not produce these in order just to feel productive.** The only artifact that matters in the first 3 weeks is 1.10 — the Week-1 Experiment Runbook, executed successfully. Everything in Phases 2–7 is worthless if that fails.

Produce Phase 1 in order. Stop. Execute 1.10. Only then continue.

---

## Master Checklist Summary

| Phase | Artifacts | Effort (C) | Weeks | Blocks on |
|---|---|---|---|---|
| **C. Decisions** | 18 decisions | 0 (decide, don't write) | 1 week | Nothing |
| **1. POC Stack** | 10 artifacts | ~14C | Weeks 1–2 | C complete |
| **2. Full Agent Suite** | 12 artifacts | ~30C | Weeks 3–4 | Phase 1 done |
| **3. Platform Specs** | 12 artifacts | ~27C | Weeks 5–7 | Phase 2 agents specified |
| **4. Dashboard Build** | 13 artifacts | ~15C | Weeks 8–9 | Phase 3 done |
| **5. Business/Legal** | 15 artifacts | ~14C | Weeks 10–11 | Decisions C1, C4 |
| **6. Ops Runbooks** | 7 artifacts | ~7C | Weeks 12–13 | Phases 1–5 done |
| **7. Post-Launch** | 8 artifacts | ~18C | Months 4–6 | Phase 6 done |
| **TOTAL** | **95 artifacts** | **~125C** | **14 weeks + ongoing** | |

*(95 artifacts + 18 decisions = 113 total ticks.)*

---

## The one paragraph summary

You have strategy, architecture, and a working prototype. You are missing the *stuff a developer actually reads* — 95 discrete documents and decisions, organised into 7 sequenced phases. Start with the 18 Open Decisions this week. Then Phase 1's 10 artifacts until one real Proposal Builder works end-to-end. Then Phase 2's 12 agent bundles. Then Phase 3's 12 platform specs. By week 7 you have everything Claude Code needs to build; Phases 4–7 happen in parallel with and after the build. Tick boxes. Resist scope creep. Ship.
