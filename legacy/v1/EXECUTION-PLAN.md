# Intel Force OS — Full Execution Plan

_Written 2026-04-24. Based on complete read-through of all 172 spec files._
_Current state: zero code, zero customers, zero revenue._

---

## How to read this plan

**Two tracks run in parallel throughout:**
- **BUILD TRACK** — code, infrastructure, product
- **COMMERCIAL TRACK** — name, legal, GTM, customers

Neither track waits for the other to finish. You build while you sell. You sell while you build. Sessions that touch only one track for more than a week are drifting.

**The product has two layers:**
- **Layer 1 (the wedge):** Teams HR Agent — a Teams bot that drafts HR replies. This is what gets the first 10 customers and proves the model. Build this first, entirely.
- **Layer 2 (the platform):** The full Clawd multi-agent OS — Docker containers, Postgres, Temporal, 9 agents for agencies. This is what you build once Layer 1 has 10+ paying customers and revenue to justify it.

Do not start Layer 2 until Layer 1 exits. The specifications for Layer 2 are complete and waiting — they don't need more planning work.

---

## GATE 0 — Decisions that block everything (this week, before any code)

These are decisions, not tasks. Each takes less than a day. All are blocking.

### G0.1 — Lock the product name
**Decision needed:** Is the name "Clawd" or not?

The Phase 5 brand spec already did the analysis. "IntelForce" has active trademark conflicts (intelforce.org cybersecurity company, IntelForce GPT on ChatGPT store, Intel Corp risk). "Clawd" is the recommendation.

**Action:** Run a free UKIPO search at search.ipo.gov.uk for "clawd" in classes 9 and 42. Takes 10 minutes. If clear:
- Buy `clawd.ai` + `clawd.co.uk` + `clawd.app` (~£60 total, same day)
- Secure @clawd / @clawdai on X, LinkedIn, GitHub org `clawd-ai`
- Budget £150 for a 30-min CITMA trademark attorney call to confirm filing strategy

If "Clawd" is conflicted: propose an alternative immediately. Do not continue operating as "IntelForce OS" — it has real legal exposure.

**Exit criteria:** Name is locked. Domains are purchased. All subsequent specs, legal docs, and marketing use the final name.

---

### G0.2 — Lock the agent runtime
**Decision needed:** Relevance AI or Anthropic API direct?

The plan for the custom Anthropic path is already written (`.claude/plans/when-we-build-out-synchronous-haven.md`). The trade-offs from the read-through:

| | Relevance AI | Anthropic API direct |
|---|---|---|
| Build time to Stage E | ~2 hours (existing agent works) | ~3-5 days (write agent.md, build claude.ts, solve handbook retrieval) |
| Handbook retrieval | Managed — included | Must be built (add 1-3 days OR inject full text in v1) |
| Cost at 50 customers | ~£2,000/mo (dominant cost) | ~£150-400/mo with prompt caching |
| Data residency | US-based, not in DPA | Anthropic EU endpoint available |
| Agent prompt location | Relevance AI dashboard (not Git-tracked) | Git-tracked agent.md in this repo |
| Swap-later cost | 1 file change — designed for it | Already done |

**Recommendation:** Custom Anthropic path. The build cost is real but the data residency problem with Relevance AI is a pre-customer blocker for any UK SME that asks. Do it once now rather than rushing a migration when you have 5 customers.

**Exit criteria:** Runtime decision recorded. If custom: confirm Anthropic API workspace is set up with a paid API key (not the Max subscription — the API key).

---

### G0.3 — Fix the DPA sub-processors
**Decision needed:** Which sub-processors are in Annex B of the DPA?

Current Phase 5 DPA was written for Architecture A (Hetzner, AWS, Cohere, Clerk etc.) — none of which are in the Teams HR Agent stack. The actual sub-processors for the Teams HR Agent are:

- **Anthropic** (Claude API — inference) — if custom runtime
- **Cloudflare** (Workers, KV, D1 — routing, storage, audit)
- **Microsoft** (Bot Framework, Entra ID — authentication, Teams protocol)
- ~~Relevance AI~~ — remove if going custom; add if keeping

**Action:** Edit `docs/phase-5-business-legal/legal/dpa-template.md` Annex B (note: docs/ is read-only for Claude Code — you do this edit yourself). You cannot sign a customer contract with an inaccurate sub-processor list.

**Exit criteria:** DPA Annex B matches the actual stack. Document is signable.

---

## PHASE 1 — Teams HR Agent v1 (Weeks 1-3)
_Exit criteria: one paying customer using the bot in production._

### BUILD TRACK

#### Stage B — Azure bootstrap (30 min, one time, ever)
**Spec:** `docs/teams-hr-agent/03-azure-bootstrap-via-claude-code.md`
**What gets built:** Entra ID multi-tenant app registration + Azure Bot Service (F0, free) in resource group `intelforce-rg` (UK South). Bot messaging endpoint set to `https://bot.intelforce.ai/api/messages`. Teams channel enabled.
**Output:** `.env.local` with `MICROSOFT_APP_ID`, `MICROSOFT_APP_PASSWORD`, `BOT_MESSAGING_ENDPOINT`.
**How:** Claude Code drives the `az` CLI commands. You approve each one.
**Cost:** £0 to set up. £0/month at this scale.

#### Stage C — Cloudflare Worker scaffold + deploy (2-3 hrs)
**Spec:** Stage C prompt in `docs/teams-hr-agent/07-claude-code-prompts.md`
**What gets built:** `wrangler.toml`, `package.json`, `tsconfig.json`, full `src/` directory structure with TypeScript stubs, KV namespace, D1 database, Worker deployed to Cloudflare, `bot.intelforce.ai` routed.
**Output:** `curl https://bot.intelforce.ai/health → 200 OK`
**Dependencies:** Stage B complete (need `MICROSOFT_APP_ID` for secrets), Cloudflare account on paid plan ($5/mo).

#### Stage — Write the HR agent system prompt (half day)
**Spec:** Pattern from `docs/phase-2-agent-suite/00-PATTERN-REFERENCE.md`
**What gets built:** `docs/phase-2-agent-suite/hr-agent/agent.md` — the brain.

This file does not exist and is the single most important missing artifact. It defines:
- Role and loyalty (drafts replies for the HR Lead; never sends; employee is not the trust anchor)
- Sensitivity classification rules (categories: grievance, resignation, mental_health, harassment, health, low_confidence; threshold ≥ 0.7 = escalate, produce holding message only)
- Workflow (classify → ground in handbook → draft → structure output)
- Output specification (`draft_reply`, `sensitivity_score`, `sensitivity_category`, `confidence`, `handbook_citations`, `escalation_recommended`)
- Quality gates (no invented policies; handbook citations required; holding message on escalation, not an attempted answer)
- Escalation codes (registered in `_shared/escalation-codes.md`)

**Who writes it:** Claude Code drafts it; you review and iterate. One session.

#### Stage D+G — Bot auth + D1 schema + KV storage (4-8 hrs)
**Spec:** Stage D + G prompts in `07-claude-code-prompts.md`
**What gets built:**
- `src/bot/auth.ts` — JWT verification against Microsoft signing keys, with 24h in-memory key cache
- `src/bot/handler.ts` — message handler skeleton (conversationUpdate → capture conversation ref → KV; message → route to agent; slash commands)
- `migrations/0001_initial.sql` — full D1 schema from `02-component-design.md §6.1` applied
- `src/storage/config.ts` — `getTenantConfig`, `setTenantConfig`, `getHrLeadConversationRef`, `getAllTenants`
- `src/storage/audit.ts` — `logMessage`, `logApproval`, `getAuditRecord`, `getWeeklyStats`, `deleteEmployeeData`, `exportEmployeeData`
- `src/utils/redact.ts` — PII redaction (UK phone, NHS number, email patterns)

**Output:** Sideload Teams app in dev tenant; bot receives messages and stores conversation references in KV; D1 has schema applied.

#### Stage E — Anthropic API integration (1-2 days)
**Spec:** `.claude/plans/when-we-build-out-synchronous-haven.md` (saved plan)
**What gets built:**
- `src/agents/types.ts` — `AgentInput`, `AgentResponse`, `ESCALATION_FALLBACK`
- `src/agents/tools.ts` — Anthropic tool-use format: `submit_draft_for_approval` (required output tool), `lookup_handbook_policy`, `get_breathe_hr_employee_info` (v1 stub)
- `src/agents/prompt.ts` — `buildSystemPrompt(config, handbookText)` — wraps `agent.md` content with per-tenant context
- `src/agents/tool-executor.ts` — executes tool calls; v1 handbook lookup uses keyword search over inline text
- `src/agents/claude.ts` — `callClaudeAgent()` — Anthropic SDK client with tool-call loop, prompt caching, 25s timeout, fallback to `ESCALATION_FALLBACK` on any failure

**v1 handbook retrieval:** Inject full handbook text into system prompt with `cache_control: {type: "ephemeral"}`. Works for any real HR handbook. Handbook stored in KV at `handbook_text:{tenantId}` (up to 25MB). This is not the ideal long-term solution but ships v1 without building a vector index.

**Output:** DM bot "what's the holiday carry-over policy?" → real draft reply from Anthropic within 10 seconds.

#### Stage F — Adaptive Cards + full approval flow (3-4 hrs)
**Spec:** Stage F prompt in `07`, card templates in `06-adaptive-card-examples.json`
**What gets built:**
- All 6 card modules: `src/cards/approval.ts`, `escalation.ts`, `report.ts`, `config.ts`, `welcome.ts`, `error.ts`
- Full `handleCardAction()`: approve → post draft in original thread; edit → post edited version; reject → holding message; acknowledge → mark escalation handled
- `src/bot/proactive.ts` — `sendProactiveCard()` using `CloudAdapter.continueConversationAsync`
- `postReplyInOriginalThread()` — post approved draft as thread reply

**Output:** Full approval loop working in dev tenant — employee message → approval card in HR Lead DM → tap Approve → reply in original channel.

#### Stage G — Weekly report cron (1 hr)
**Spec:** Stage H prompt in `07`
**What gets built:**
- `sendWeeklyReport()` — iterates all tenants, builds stats from D1, sends report card
- Rule-based priority insight (approval rate, escalation rate patterns)
- Cron: `"0 8 * * 1"` (Monday 08:00 UTC = 09:00 BST)

**Output:** Manually trigger cron in dev, report card arrives in HR Lead DM.

#### Stage I — Teams manifest + sideload (1 hr)
**Spec:** Stage I prompt in `07`
**What gets built:**
- `teams-app/manifest.json` — correct app UUID, bot UUID from `.env.local`, scopes: personal/team/groupchat, command list
- `teams-app/color.png` (192×192) + `teams-app/outline.png` (32×32) — placeholder icons
- `npm run package` → `dist/intel-force-os-v1.0.0.zip`

**Output:** Sideload succeeds in dev tenant. Welcome card appears.

#### Stage J — End-to-end smoke tests (1-2 hrs)
**Spec:** `04-deployment-guide.md §6` — 8-scenario test matrix

All 8 must pass before declaring any customer live:
1. Simple policy question → correct draft + citation
2. Out-of-handbook question → low confidence → escalation
3. Sensitive question → holding reply to employee + escalation card to HR Lead
4. HR Lead approves → reply in channel within 3s
5. HR Lead edits → edited version sent; audit log shows `edited_reply`
6. HR Lead rejects → holding message sent
7. Message in unconfigured channel → "I'm only listening to #hr"
8. Unknown tenant → auth rejection, no data leak

#### Stage K — Customer onboarding script (2 hrs)
**Spec:** Stage K prompt in `07`
**What gets built:**
- `onboarding/new-tenant.ts` — interactive CLI: collect tenantId, company name, domain, HR Lead AAD ID, channels, tone, approval mode, handbook file path → convert handbook to text → write to KV
- `onboarding/offboard-tenant.ts` — GDPR deletion: delete KV keys + D1 rows for tenant
- `onboarding/list-tenants.ts` — show all configured tenants + status

**Output:** `npm run onboard` provisions a test tenant, bot responds correctly for that tenant.

#### Stage L — CI/CD + monitoring (1 hr)
**Spec:** Stage L prompt in `07`
**What gets built:**
- `.github/workflows/deploy.yml` — typecheck + test + `wrangler deploy` on push to main
- `.github/workflows/preview.yml` — deploy preview Worker on PR
- Sentry integration (`@sentry/cloudflare`)
- Better Uptime monitoring on `/health`

**Output:** Push to main → auto-deploys. PR → preview URL in comment. `/health` monitored externally.

---

### COMMERCIAL TRACK (runs parallel to BUILD TRACK)

#### C1 — Landing page (deploy within days of name lock)
**Spec:** `docs/phase-5-business-legal/marketing/landing-page-spec.md`, `docs/gtm-pack/02-landing-page-hero.html` (ready-to-deploy HTML prototype)
**What:** Deploy the existing HTML landing page from the GTM pack to `intelforce.ai` (or `clawd.ai` once name is locked). It's already written — it needs icons + a Cal.com link + domain DNS. 30 minutes.

#### C2 — Loom demo (record once build has a working demo)
**Spec:** `docs/gtm-pack/01-demo-script.md` — 3-minute Loom script with exact words and 3 scenarios
**What:** Record screen-share of the dev tenant end-to-end: employee sends message → approval card arrives in HR Lead DM → Approve tapped → reply in channel. The script is written. You just record it.

#### C3 — Prospect list (build during Stages C-F)
**Spec:** `docs/gtm-pack/03-prospecting-framework.md`, `03-prospect-tracker-template.csv`
**What:** 20 UK SMEs, 20-200 employees, on Breathe HR or similar, visible HR/Ops lead on LinkedIn. ICP is "Sarah Chen" — HR Lead at 40-80 person UK company, M365 user, doing HR admin manually. Use LinkedIn Sales Navigator or manual research. The framework and tracker are ready.

#### C4 — Outreach (start sending during Stages D-E)
**Spec:** `docs/gtm-pack/04-outreach-templates.md` — 10 message variants
**What:** LinkedIn connection requests to HR Leads at ICP companies using Template A. Follow-up with Template B post-connection. 20 messages sent per week. Target: 2-3 discovery calls booked.

#### C5 — Legal docs (sign before first customer, not before first demo)
**Spec:** Phase 5 legal templates — already written
**What:** Get the simple service agreement from `docs/gtm-pack/06-pricing-sheet.md` signed digitally (DocuSign or email acceptance). For first 10 customers, this is sufficient. Phase 5 MSA+DPA+SLA is for Growth/Scale tier customers.

#### C6 — Stripe billing (before first invoice)
**Spec:** `docs/phase-5-business-legal/billing/stripe-integration-spec.md`
**What:** Set up Stripe account, create Products + Prices for the tiers, send invoices. First customer: £400/month manual Stripe invoice. Automated billing via webhooks comes in Phase 2.

---

## PHASE 2 — First Customers + Stability (Month 2-3)
_Exit criteria: 3 paying customers, all live >30 days, first case study published._

### What changes in the build

The Worker code is stable by now. Phase 2 work is refinement, not new features.

- **Prompt iteration** — based on real approval/edit patterns from D1 audit log. Which queries get edited most? That signals prompt weakness.
- **Handbook re-indexing** — customers update their handbooks. Build a re-index CLI step.
- **Breathe HR integration (real)** — `get_breathe_hr_employee_info` moves from stub to real Breathe HR API calls. Requires Breathe HR API key per tenant, stored in KV as a Worker secret. Enables: leave balance lookups, employee start date, department. Spec: define in `docs/phase-2-agent-suite/hr-agent/tools.yaml` (to be created).
- **Escalation acknowledgement timer** — if HR Lead doesn't acknowledge an escalation within 2 hours during UK business hours, send a follow-up ping. Currently described in spec; not yet built.
- **Multi-channel monitoring** — basic internal dashboard (Cloudflare Workers dashboard + D1 query) showing per-tenant message volume, approval rate, escalation rate, error rate.

### Commercial track in Phase 2

- **First case study** — interview format, published within 30 days of customer going live. Template in `docs/phase-5-business-legal/playbooks/case-study-playbook.md`.
- **Pricing discipline** — founding tier is £400/month, locked for 12 months. Do not discount. Do not do free trials. Month-to-month with 7-day cancellation is the risk reduction.
- **Monthly review calls** — 30-minute call with each customer. Track approval rate, escalation rate, HR Lead satisfaction. This data feeds the case study and the product roadmap.

---

## PHASE 3 — Multi-Agent Expansion (Month 4-6)
_Trigger: 3 paying HR customers, all live >30 days, you're spending <15 hrs/week on delivery._

### What gets added to the build

**Sales agent** is the second agent. All the specs exist in `docs/phase-2-agent-suite/`:
- Relevant bundles: `lead-hunter/`, `follow-up-pilot/`, `content-creator/`, `repurposer/` — these are for Architecture A (the Clawd agency platform). For the Teams HR Agent architecture, the equivalent is a new agent that handles sales-related queries routed from a #sales channel.
- **Architecture:** same Worker, new route in `handleBotMessage()` based on channel or command prefix, new `agent.md` for the Sales agent, new tool set.
- **Manifest:** bump to 1.1.0, add `sales` command to `commandLists`.
- **Tenant config:** `agents.sales.enabled`, `agents.sales.channels`.

**Pricing moves to Phase 5 tiers:**
- Starter £450/month (HR only)
- Growth £1,800/month (HR + Sales)
- New customers no longer get founding £400/month rate

### Commercial track in Phase 3

- **Teams App Store submission** — requires Microsoft Partner Center account (£80/year), privacy policy + ToS live at a URL, app validation (1-2 weeks). Start submission process at month 4; expect live at month 6. Enables self-serve install — customers find the app in Teams without you doing a manual sideload.
- **Agency Partner plan** — if Rigby Group or similar asks: platform fee + sub-tenant pricing. The Agency Partner Portal spec is in Phase 4; for now, manage manually via separate tenant configs.

---

## PHASE 4 — Dashboard + Self-Serve (Month 7-9)
_Trigger: 10+ customers asking for out-of-Teams visibility, OR Teams App Store listing is live._

**Spec:** `docs/phase-4-dashboard/` — 11 files, fully specced.

**What gets built:**
- Next.js 15 + tRPC + Prisma web app at `app.clawd.ai` (or `app.intelforce.ai`)
- Auth via Clerk (EU data, org primitive)
- Operations Control view — "what's pending my approval" at a glance
- Activity log — full audit trail with filters
- Brain view — the agent's reasoning and handbook citations, rendered
- Agency Partner portal — portfolio of sub-tenants for agencies
- Settings — tenant configuration without needing to call Maddox

**Tech choices locked in spec:** Dark mode default, dense data-table UI, Server-Sent Events for real-time updates, tRPC not REST, RSC by default. No re-architecting these.

**Cost:** ~£140-290/month infrastructure at 10-50 tenants. 12 dev-weeks solo or 6 with two engineers.

---

## PHASE 5 — Full Platform (Month 10-12 and beyond)
_Trigger: 30+ customers OR first enterprise deal requiring dedicated infrastructure._

**What this means:** Migrating from Cloudflare KV/D1 to the Phase 3 platform architecture.

**Spec:** `docs/phase-3-platform/` — 9 files, fully specced.

**What gets built:**
- Postgres cluster (Hetzner UK) replacing D1 — per-tenant schemas, RLS, pgvector for semantic handbook search
- Temporal provisioning — automated tenant onboarding without manual CLI scripts
- Secrets Vault — per-tenant KMS CMKs replacing Wrangler secrets
- Observability — Loki + Prometheus + Grafana replacing `wrangler tail`
- Escalation Notifier — sidecar service replacing in-Worker escalation logic

**Important:** Do not start this phase early. The Phase 3 specs themselves say "Prerequisites: Phase 1 POC validated." That means: Teams HR Agent has paying customers and proven architecture. Build Phase 5 when you have revenue to fund it and customer demand to justify it.

---

## The full spec coverage map

Everything in `docs/` has a home in this plan:

| Spec pack | Status in this plan |
|---|---|
| `docs/phase-0-strategic/` | Architecture reference; strategic docs inform priorities. `ARCHITECTURE-OVERVIEW.md` describes the Phase 5 target state. |
| `docs/phase-1-poc-stack/` | Proposal Builder POC — never executed. Superseded by Teams HR Agent. Keep as reference for the Clawd agency platform later. |
| `docs/phase-2-agent-suite/` | HR agent bundle needs to be created. Other agent bundles (lead-hunter etc.) are for Phase 3+ agency platform. `_shared/` is the pattern reference. |
| `docs/phase-3-platform/` | Phase 5 build target (month 10+). Fully specced. Don't touch until 30+ customers. |
| `docs/phase-4-dashboard/` | Phase 4 build target (month 7-9). Fully specced. |
| `docs/phase-5-business-legal/` | DPA fix is immediate (Gate 0). MSA/SLA for first customers. Pricing spec for Phase 3 tier pricing. Landing page for this week. |
| `docs/phase-6-ops-runbooks/` | Read `incident-response-runbook.md` before customer 1 goes live. Rest activates as customers accumulate. |
| `docs/teams-hr-agent/` | Phase 1 build spec. Everything in Stages B-L. |
| `docs/gtm-pack/` | Active now: landing page, demo script, prospecting, outreach, pricing. |
| `docs/build-kit/` | The Claude Code config for the Teams HR Agent build. Needs path fixes (references `docs/architecture/` which doesn't exist). |

---

## Time and milestone summary

| Week | Build milestone | Commercial milestone |
|---|---|---|
| 1 | Gate 0 decisions locked. Azure bootstrap. Worker deployed at `bot.intelforce.ai`. | Name locked. Domains purchased. Landing page live. |
| 2 | HR agent `agent.md` written. Anthropic integration (claude.ts) built. Auth + storage working. | Loom demo recorded. 20 prospects identified. Outreach started. |
| 3 | Full approval loop working. Cards rendering. Escalation flow working. Cron delivering reports. | First 3-5 discovery calls. |
| 4 | Onboarding script. CI/CD. All 8 smoke tests pass. Customer 1 install-ready. | First customer signed. Install call booked. |
| 5-8 | Prompt iteration. Breathe HR real integration. Customer 2 + 3 live. | 3 customers, weekly cadence. First case study. |
| 9-12 | Sales agent built. Multi-agent routing. Teams App Store submitted. | Pricing moves to tiers. 5-8 customers. |
| 13-18 | Dashboard v1.5. Self-serve install. | 10-15 customers. First Agency Partner. |
| 19-24 | Phase 5 platform if triggered. | 20-30 customers. Series A readiness or revenue target met. |

---

## How to run sessions against this plan

**Before each session:** Run `/session-start`. State which phase and which stage you're in. Get exit criteria confirmed before writing code.

**After each stage:** Commit with conventional commit message. Do not start the next stage until the current one's acceptance test passes.

**Weekly rhythm (from `docs/gtm-pack/05-manual-service-runbook.md`):**
- Monday: check weekly reports, respond to any weekend messages, review D1 audit log for each live tenant
- Tuesday-Thursday: build sessions
- Friday: customer check-ins, outreach batch, review metrics

**The signal that something is wrong:** A week ends with no new code committed AND no customer conversations initiated. That's drift. Act on it immediately.

---

## What to do in the next 2 hours

1. Run the UKIPO search for "clawd" — 10 min
2. Tell me the result and confirm the runtime decision (Anthropic API)
3. I run Stage B (Azure bootstrap) with you approving each `az` command — 30 min
4. I run Stage C (Cloudflare Worker scaffold + deploy) — 2-3 hrs
5. End of session: `curl https://bot.intelforce.ai/health → 200 OK`

That's the first milestone. Everything else flows from there.
