# Intel Force OS — Master Specification Index

**Complete catalog of all 163 specification files across the Intel Force OS system. Use this as a lookup table when you need to find which document covers what.**

**How to use:**
- **Search first:** `/search-specs "keyword"` finds mentions across all docs faster than browsing
- **Navigate by pack:** each pack below lists its files with one-line descriptions and trigger conditions ("consult when...")
- **Follow cross-references:** some files depend on others; those dependencies are flagged
- **Respect status:** "Active" means currently in use; "Reference" means consulted on demand; "Deferred" means post-v1

---

## Quick navigation

- [Pack 0 — Strategic Foundation](#pack-0--strategic-foundation)
- [Pack 1 — POC Stack](#pack-1--poc-stack)
- [Pack 2 — Agent Suite](#pack-2--agent-suite)
- [Pack 3 — Platform Infrastructure](#pack-3--platform-infrastructure)
- [Pack 4 — Dashboard](#pack-4--dashboard)
- [Pack 5 — Business & Legal](#pack-5--business--legal)
- [Pack 6 — Operations Runbooks](#pack-6--operations-runbooks)
- [Pack 7 — Teams HR Agent](#pack-7--teams-hr-agent)
- [Pack 8 — HR Agent GTM](#pack-8--hr-agent-gtm)

---

## Pack 0 — Strategic Foundation

**Location:** `docs/phase-0-strategic/`  
**Files:** 6 | **Lines:** ~2,300 | **Status:** Reference (completed)  
**Purpose:** Establish the thesis, business model, and 18-month strategic plan for Intel Force OS

| File | What it covers | Consult when |
|---|---|---|
| `strategic-plan.md` | 18-month strategic plan (June 2026–Dec 2027), £100k ARR target, agent progression | Quarterly planning, major pivot decisions |
| `technical-strategy-v2.md` | Platform thesis, build vs buy decisions, infrastructure choices | Reviewing platform decisions, considering stack changes |
| `build-plan.md` | Phased build plan from POC through platform | Sequencing work across multiple phases |
| `dashboard-jsx-prototype.jsx` | Early dashboard visual prototype | Visual reference for Phase 4 dashboard |
| `execution-plan.md` | 95 artifacts mapped, 18 Open Decisions (OD-PX-Y) with status | Finding a specific Open Decision, tracking artifact progress |
| `planning-phase-brief.md` | The brief that generated this whole system | Onboarding someone new; re-grounding if scope creeps |

**Key concepts in this pack:**
- The "one Teams app, many agents" thesis
- Agency Partner play (Rigby Group, Allect, SCC)
- The £100k ARR math (10 customers × £1,000 avg)
- Open Decisions framework (OD codes reference back to this pack)

---

## Pack 1 — POC Stack

**Location:** `docs/phase-1-poc-stack/`  
**Files:** 16 | **Lines:** ~4,800 | **Status:** Dormant (never executed)  
**Purpose:** Minimum viable stack to prove Intel Force OS works for one customer

| File | What it covers | Consult when |
|---|---|---|
| `README.md` | Pack orientation, read order | Starting in Phase 1 |
| `proposal-builder/proposal-builder-spec.md` | Agent spec for generating sales proposals | Considering a proposal-generation agent |
| `proposal-builder/proposal-builder-prompt.md` | Relevance AI prompt for proposal builder | Implementing proposal builder |
| `proposal-builder/proposal-builder-example-inputs.md` | Sample input data | Testing proposal builder |
| `proposal-builder/proposal-builder-example-outputs.md` | Expected outputs | Evaluating proposal builder |
| `platform/tenant-container-spec.md` | Per-tenant isolated environment design | Phase 3 migration planning |
| `platform/webhook-receiver-spec.md` | Generic webhook receiver for agent inputs | Designing new agent input paths |
| `platform/minimal-vault-spec.md` | Per-tenant secrets storage | Phase 3 secrets design |
| `week-1-experiment-runbook.md` | The unfulfilled POC — real Fathom call → proposal | Can be retired; superseded by Teams HR Agent |
| ... (other bundle files for proposal-builder)| Supporting spec files | As needed during proposal-builder work |

**Status note:** This pack was built assuming the POC would be proposal-builder with real sales call data. The project pivoted to HR-first via Teams. This pack is a reference for future agents but not active work.

**Key concepts:**
- Per-tenant container architecture (conceptual, not implemented)
- Webhook receiver pattern (lives in Teams HR Agent now)
- Week-1 experiment methodology

---

## Pack 2 — Agent Suite

**Location:** `docs/phase-2-agent-suite/`  
**Files:** 78 | **Lines:** ~12,400 | **Status:** Reference (templates for future agents)  
**Purpose:** Specs for 10 agents covering the full Intel Force OS roadmap

Each agent has a 7-file bundle:
1. `{agent}-spec.md` — what the agent does, boundaries
2. `{agent}-prompt.md` — Relevance AI system prompt
3. `{agent}-input-schema.md` — expected input structure
4. `{agent}-output-schema.md` — structured output format
5. `{agent}-example-inputs.md` — sample inputs
6. `{agent}-example-outputs.md` — expected outputs
7. `{agent}-escalation-codes.md` — sensitivity categories

### The 10 agents

| Agent | Status | Bundle location | When to consult |
|---|---|---|---|
| 1. **HR Agent** | In production (Relevance AI) | `phase-2-agent-suite/hr-agent/` | Implementing Teams HR Agent |
| 2. **Sales Agent** | Deferred | `phase-2-agent-suite/sales-agent/` | After 3 HR customers; building Sales |
| 3. **Recruiting Agent** | Deferred | `phase-2-agent-suite/recruit-agent/` | After Sales live |
| 4. **Ops Agent** | Deferred | `phase-2-agent-suite/ops-agent/` | Year 2 |
| 5. **Finance Agent** | Deferred | `phase-2-agent-suite/finance-agent/` | Year 2 |
| 6. **Marketing Agent** | Deferred | `phase-2-agent-suite/marketing-agent/` | Market-driven |
| 7. **Legal Agent** | Deferred (risky domain) | `phase-2-agent-suite/legal-agent/` | Tier above SME only |
| 8. **IT Support Agent** | Deferred | `phase-2-agent-suite/it-support-agent/` | Enterprise upsell |
| 9. **Customer Success Agent** | Deferred | `phase-2-agent-suite/customer-success-agent/` | When customer's own customers matter |
| 10. **Exec Assistant Agent** | Deferred | `phase-2-agent-suite/exec-assistant-agent/` | High-touch/high-price tier |

### Shared helpers

- `_shared/escalation-codes.md` — master list of sensitivity categories across all agents
- `_shared/agent-template.md` — standard structure all agent bundles follow
- `_shared/prompt-patterns.md` — reusable prompt patterns for structured output, tone matching, etc.

**When to read this pack:**
- Implementing a new agent: read the full bundle for that agent
- Cross-agent design (e.g. how do HR and Recruit interact?): read `_shared/`
- Relevance AI prompt engineering: see `_shared/prompt-patterns.md`

---

## Pack 3 — Platform Infrastructure

**Location:** `docs/phase-3-platform/`  
**Files:** 9 | **Lines:** ~3,287 | **Status:** Deferred (v2 target — customer 10+)  
**Purpose:** Multi-tenant platform infrastructure for scaling beyond v1

| File | What it covers | Consult when |
|---|---|---|
| `README.md` | Pack orientation | Starting Phase 3 work |
| `postgres-schema.md` | Per-tenant Postgres schemas, migrations, RLS | Migrating from Cloudflare D1 |
| `provisioning-via-temporal.md` | Temporal workflows for new tenant setup | Automating customer onboarding at scale |
| `secrets-vault-with-aws-kms.md` | Per-tenant CMK-based secrets | Replacing Wrangler secrets |
| `observability-spec.md` | Structured logs, metrics, traces, alerting | Setting up Datadog/Grafana |
| `escalation-notifier-service.md` | Standalone service for escalation routing | When escalation logic outgrows Worker |
| `vault-search-spec.md` | Full-text search over customer vaults | When customers need "search my history" |
| `disaster-recovery-runbook.md` | Backup verification, restore procedures | DR drills (cross-reference Phase 6) |
| `PHASE-3-SUMMARY.md` | Pack summary | Quick orientation |

**Key concepts:**
- Per-tenant Postgres schemas (`tenant_{id}.messages`, etc.)
- Temporal workflows for provisioning
- KMS-backed per-tenant secrets
- Cross-references to Phase 6 for DR + incident response

**Trigger to activate:** 30+ customers, OR first enterprise deal requiring dedicated infra, OR data residency requirement Cloudflare can't meet.

---

## Pack 4 — Dashboard

**Location:** `docs/phase-4-dashboard/`  
**Files:** 11 | **Lines:** ~4,543 | **Status:** Deferred (v1.5 target)  
**Purpose:** Web dashboard for customer-side visibility outside Teams

| File | What it covers | Consult when |
|---|---|---|
| `README.md` | Pack orientation | Starting Phase 4 work |
| `tech-stack.md` | Next.js 15 + tRPC + Prisma + Clerk auth | Scaffolding the dashboard |
| `operations-control-view.md` | "What's pending my approval" view | Building the main HR Lead view |
| `brain-view.md` | Agent reasoning + tuning interface | Power-user tier feature |
| `agency-partner-portal.md` | Multi-tenant view for agencies (Rigby-style customers) | Agency Partner plan implementation |
| `auth-and-sso.md` | Teams SSO for Tabs, OAuth for web | Setting up auth |
| `database-access-patterns.md` | How dashboard reads from shared D1/Postgres | Implementing data access |
| `ui-components-library.md` | Component spec (buttons, tables, cards) | Design system work |
| `admin-panel.md` | Intel Force-side customer management | Internal ops portal |
| `reporting-views.md` | Metrics, SLA tracking, billing | Subscription management |
| `PHASE-4-SUMMARY.md` | Pack summary | Orientation |

**Trigger to activate:** 15+ customers asking for out-of-Teams visibility, OR a customer needs a dashboard for their own reporting.

**Key concepts:**
- Teams Tab (SSO via Microsoft) as primary surface
- Standalone web (OAuth) as secondary
- Reads from same storage as Worker (consistency)

---

## Pack 5 — Business & Legal

**Location:** `docs/phase-5-business-legal/`  
**Files:** 14 | **Lines:** ~6,508 | **Status:** Active reference (used per customer)  
**Purpose:** Legal docs, pricing, sales collateral

| File | What it covers | Consult when |
|---|---|---|
| `README.md` | Pack orientation | Starting commercial work |
| `brand-identity.md` | Intel Force OS brand (evolved from Clawd) | Any customer-facing asset |
| `trademark-brief.md` | Intel Corp risk analysis, mitigation | Trademark attorney consultation |
| `landing-page-spec.md` | intelforce.ai landing page structure | Building/updating landing page |
| `msa-template.md` | Master Service Agreement | Any enterprise deal |
| `dpa-template.md` | Data Processing Agreement (GDPR) | Customer has DPA requirement |
| `sla-template.md` | SLA tiers (Starter/Growth/Scale) | Customer asks for SLA |
| `aup-template.md` | Acceptable Use Policy | Standard terms |
| `privacy-policy-template.md` | GDPR-compliant privacy policy | Website/app compliance |
| `terms-of-service-template.md` | ToS | Website/app compliance |
| `pricing-spec.md` | £400 founding / £450 Starter / £1,800 Growth / £4,500 Scale | Pricing decisions, invoicing |
| `stripe-integration-spec.md` | Subscription billing via Stripe | Implementing billing |
| `rest-api-spec.md` | Public API spec (future) | Customer asking for API access |
| `sales-and-case-study-playbook.md` | Demo script, objection handling, case study template | Every customer call |

**When to read this pack:**
- First customer contract: `msa-template.md` + `sla-template.md` + `dpa-template.md`
- Pricing question: `pricing-spec.md`
- Any customer-facing copy: `brand-identity.md`
- GDPR question: `dpa-template.md` + `privacy-policy-template.md`

---

## Pack 6 — Operations Runbooks

**Location:** `docs/phase-6-ops-runbooks/`  
**Files:** 13 | **Lines:** ~6,366 | **Status:** Dormant until customer 1 live  
**Purpose:** What to do when things go wrong

| File | What it covers | Consult when |
|---|---|---|
| `incident-response-runbook.md` | Severity classification, initial response | Something's on fire |
| `on-call-handbook.md` | Solo-founder on-call rotation, handoff | First on-call shift |
| `severity-classification-and-comms.md` | SEV1/2/3 definitions, customer comms templates | During an incident |
| `postgres-incidents.md` | DB-specific incidents (Phase 3) | Postgres problem (v2) |
| `platform-service-incidents.md` | Worker/KV/D1 incidents | Cloudflare-side issue |
| `tenant-incidents.md` | Per-tenant issues (e.g. single customer broken) | One customer's bot is down |
| `deploy-and-rollback.md` | Safe deploy procedures, rollback steps | Deploying or rolling back |
| `cost-governance-runbook.md` | Managing Cloudflare + Relevance AI costs | Monthly cost review, unexpected spike |
| `secret-rotation-runbook.md` | Quarterly secret rotation process | Every 3 months or on suspected compromise |
| `backup-verification-and-dr-drills.md` | Testing backups actually restore | Quarterly DR drill |
| `gdpr-dsar-and-deletion-runbook.md` | GDPR Art. 15 and 17 fulfilment | Customer DSAR/deletion request |
| `breach-response-runbook.md` | Data breach response procedures | Suspected or confirmed breach |
| `PHASE-6-SUMMARY.md` | Pack summary | Orientation |

**When to read this pack:**
- Before customer 1 goes live: skim `incident-response-runbook.md` + `on-call-handbook.md`
- Quarterly: `secret-rotation-runbook.md`, `backup-verification-and-dr-drills.md`
- On customer request: `gdpr-dsar-and-deletion-runbook.md`
- In a panic: `incident-response-runbook.md` first, always

---

## Pack 7 — Teams HR Agent Architecture

**Location:** `docs/teams-hr-agent/`  
**Files:** 8 | **Lines:** ~4,742 | **Status:** Active (v1 build target)  
**Purpose:** Build-ready architecture for the Teams HR Agent — the current active build

| File | What it covers | Consult when |
|---|---|---|
| `README.md` | Pack orientation, 3 core choices | Starting Teams work |
| `01-architecture-overview.md` | Problem, 5 options evaluated, recommended arch | Architectural review; explaining to prospects |
| `02-component-design.md` | Every component in detail with code sketches | Implementing any component |
| `03-azure-bootstrap-via-claude-code.md` | 30-min one-time Azure setup | Running Stage B |
| `04-deployment-guide.md` | Per-customer 30-45 min onboarding | First customer install, subsequent installs |
| `05-productisation-playbook.md` | Scaling to 50 customers, Teams App Store | Month 6+ planning |
| `06-adaptive-card-examples.json` | Working Adaptive Card templates | Implementing any card |
| `07-claude-code-prompts.md` | Literal prompts for each build stage | Running build stages A-L with Claude Code |

**Key sections to remember:**
- `01 §4.1` — the core architecture diagram
- `01 §5` — design decisions and rationale
- `02 §2.4` — full message handler pseudocode
- `02 §4.1-4.2` — Relevance AI HTTP contract
- `02 §5.2` — TenantConfig interface
- `02 §6.1` — D1 schema
- `04 §6` — 8-scenario smoke test matrix
- `07` — build-stage prompts for Claude Code

**Cross-references:**
- Phase 5 for legal (MSA, DPA per customer)
- Phase 6 for ops (deploy, incident)
- Phase 2 HR agent bundle for Relevance AI prompt details
- GTM pack for commercial motion around installs

---

## Pack 8 — HR Agent GTM

**Location:** `docs/gtm-pack/`  
**Files:** 9 | **Lines:** ~2,089 | **Status:** Active (customer acquisition)  
**Purpose:** Getting from 0 to 3 paying customers

| File | What it covers | Consult when |
|---|---|---|
| `README.md` | 30-day execution plan | Starting outreach |
| `01-demo-script.md` | 3-minute Loom script with 3 scenarios | Recording demo, doing live demos |
| `02-landing-page-hero.html` | Shippable Tailwind landing page | Deploying intelforce.ai |
| `02-landing-page-hero-notes.md` | Deployment notes, copy rationale | Updating landing page |
| `03-prospecting-framework.md` | ICP (Sarah Chen archetype), targeting criteria | Finding prospects |
| `03-prospect-tracker-template.csv` | 15-column CRM spreadsheet | Tracking prospects |
| `04-outreach-templates.md` | 10 message variants (LinkedIn, email, follow-ups) | Sending outreach |
| `05-manual-service-runbook.md` | Weekly rhythm, break-point to Phase 3 | First-customer service delivery |
| `06-pricing-sheet.md` | £400/mo founding tier, objection scripts | Pricing conversations |

**When to read this pack:**
- Every Monday morning: `05-manual-service-runbook.md` weekly rhythm
- Before each outreach batch: `04-outreach-templates.md`
- Before each demo: `01-demo-script.md`
- Pricing objection: `06-pricing-sheet.md`

---

## Cross-pack relationships

Critical relationships between packs that matter for implementation:

### The HR agent implementation stack
- **Spec:** Phase 2 `hr-agent/` bundle (prompt, escalation codes)
- **Architecture:** Pack 7 (Teams HR Agent)
- **Commercial:** Pack 5 (pricing, MSA) + Pack 8 (GTM)
- **Operations:** Pack 6 (runbooks once live)

### The "everything drafts" invariant
Defined in Phase 0 `strategic-plan.md`, enforced in every agent bundle in Phase 2, implemented in Pack 7 `02-component-design.md` §2.4 handler pseudocode, documented to customers in Pack 5 `brand-identity.md`, tested in Pack 7 `04-deployment-guide.md` §6 scenario 3.

### Open Decisions (OD-PX-Y codes)
All Open Decisions are tracked in Phase 0 `execution-plan.md`. When a decision is referenced by code (e.g. "per OD-P3-7"), that's the file to check. Example ODs:
- OD-P1-3: POC experiment methodology
- OD-P3-7: Per-tenant isolation strategy
- OD-P5-2: Pricing structure
- OD-P7-1: Teams vs email primary channel

### Shared helpers
- Phase 2 `_shared/escalation-codes.md` — used by every agent bundle AND Teams HR Agent Pack 7 §3.2
- Phase 3 `observability-spec.md` — referenced by Phase 6 runbooks
- Phase 5 `dpa-template.md` — referenced by Pack 7 compliance notes

---

## How to find things fast

### By topic

| I need info about... | Start here |
|---|---|
| The commercial pitch | Pack 8 `01-demo-script.md` |
| How the bot works technically | Pack 7 `01-architecture-overview.md` |
| A specific API / function | Pack 7 `02-component-design.md` (organised by component) |
| Prompt engineering for an agent | Phase 2 `_shared/prompt-patterns.md` + specific agent's prompt.md |
| Pricing | Pack 5 `pricing-spec.md` + Pack 8 `06-pricing-sheet.md` |
| Legal | Pack 5 templates (MSA, DPA, SLA) |
| What to do in an incident | Pack 6 `incident-response-runbook.md` |
| The overall strategy | Phase 0 `strategic-plan.md` |
| Open Decisions | Phase 0 `execution-plan.md` |

### By phase status

- **Building right now:** Pack 7, Pack 8, Pack 5 (referenced per-customer)
- **Consulting for specific tasks:** Phase 2, Phase 6
- **Deferred but relevant:** Phase 3, Phase 4
- **Historical / foundational:** Phase 0, Phase 1

---

## Maintenance — keeping this index current

This index reflects the state of specifications as of **April 2026**. When specs change, update this index:

- **New file added to a pack:** add a row to that pack's table
- **File status changes (e.g. deferred → active):** update the Status column at pack level + this file's relevant section
- **File removed or merged:** remove row, note in commit message
- **New pack added:** add section + update the quick-nav at top

Commit these changes alongside spec changes. The index gets stale fast if not maintained.
