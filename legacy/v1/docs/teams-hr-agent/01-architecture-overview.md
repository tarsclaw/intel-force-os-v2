# 01 — Architecture Overview

**The "what and why" of turning the HR agent into a productised Teams app.**

---

## 1. The problem, stated precisely

You have an HR agent running in Relevance AI, integrated with Breathe HR. Right now its primary surface is email. For a manual-service first customer, email works. For a productised offering across 10–50 UK SMEs, email has three fundamental problems:

1. **It's not where UK SME HR happens.** HR leads at 20–200 person UK companies spend 70%+ of their working day in Teams. Email is the archive format, not the working format. Employees ask HR questions in Teams DMs and #hr channels — they've often already left email for everything except contracts and formal notices.

2. **Email integration is per-customer bespoke.** Forwarding rules, shared mailboxes, Graph Mail API access tokens, spam-filter exceptions — every customer will be different, and you'll spend half your onboarding time troubleshooting their Exchange setup. Teams, by contrast, is uniform: it's the same Microsoft 365 surface everywhere.

3. **Email UI is the wrong shape for approval loops.** The core Intel Force OS promise is *"everything drafts, nothing sends without you."* In email, that approval loop is: agent replies in Drafts folder → HR lead finds the draft → reads it → edits or sends. That's 4 clicks and context-switching to another app. In Teams, the same loop is: agent sends Adaptive Card DM → HR lead sees Approve/Edit/Reject buttons → taps Approve → reply is sent. That's one tap and zero context switching.

**The decision, stated precisely:** Teams is the primary product surface for Intel Force OS. Email is a fallback for customers who specifically request it. Slack (for non-M365 customers) is a sibling product surface with the same architecture pattern.

---

## 2. The requirements for the architecture

Pulled from your brief and the broader Intel Force OS context:

| # | Requirement | Why it matters |
|---|---|---|
| R1 | Real Teams app, not a workflow hack | You're selling a product, not an automation script |
| R2 | Minimal Azure setup; Claude Code drives what's unavoidable | You don't want to learn Azure DevOps; Claude Code can click buttons faster than you |
| R3 | Customer-side: zero Azure involvement | Customer IT admins will not touch Azure Portal for a £400/month SaaS |
| R4 | Multi-tenant without per-tenant infrastructure | One Teams app zip, deployable to any M365 tenant |
| R5 | Reuse Relevance AI agent work | Throwing that away is wasteful; Relevance AI's knowledge-base and prompt design are the actual IP |
| R6 | Data residency: keep customer data in their tenancy when possible | GDPR; enterprise readiness later |
| R7 | Claude Code can build every piece | This is how you're actually building it |
| R8 | Upgradeable to more agents later (Sales, Recruitment, etc.) | The HR agent is the wedge, not the product |
| R9 | Cost: ~£0/month at first-customer scale; scales linearly after | Solo founder margin math |

Every architectural decision below maps to one of these requirements.

---

## 3. The five architecture options I evaluated

### Option A — Power Automate-based (the one in the GTM pack)

Per-customer Power Automate flow listens to Teams messages, calls Relevance AI via HTTP, posts Adaptive Cards back.

**Pros:**
- Zero Azure
- Customer data stays in their tenancy
- Familiar territory for M365 admins

**Cons:**
- **Requires Power Automate Premium licence (~£12/user/month) per customer** — premium HTTP connector is not free
- Per-customer Solution deployment; not truly multi-tenant
- Not a "product" in Teams — it's "a flow that happens to use Teams"
- No branded presence in Teams (no app icon, no @-mention, no tabs)
- Difficult to iterate product-wide: bug fixes require Solution upgrade per customer
- Flow quotas become the bottleneck at scale

**Verdict:** good for automating one specific customer workflow, bad for a multi-tenant productised SaaS. Rejected for v1.

### Option B — Pure Incoming Webhook + Workflows

Customer adds Incoming Webhook connector to #hr channel. Your backend POSTs Adaptive Cards to the webhook URL. Button clicks trigger Workflows (Power Automate lite, now built into Teams).

**Pros:**
- Literally zero setup on Azure side
- 15-minute install per customer
- Free on customer side

**Cons:**
- **One-way communication only** — your backend can post, but cannot read messages without additional setup
- Workflows are limited to simple conditional logic
- No @-mention support; the bot doesn't exist as an entity
- Not a Teams app; cannot be installed as a product, cannot surface in Teams App Catalogue
- No DM capability

**Verdict:** useful as an emergency fallback ("this customer refuses any app install"), but not a primary architecture. Rejected for v1.

### Option C — Teams AI Library + Azure Bot Service (the "proper" way)

Use Microsoft's Teams AI Library (the current sanctioned framework), register a bot in Azure Bot Service, host the backend on Azure App Service.

**Pros:**
- First-class Teams experience: @-mentions, DMs, adaptive cards, messaging extensions, tabs, SSO
- Scales to enterprise
- Official Microsoft support path

**Cons:**
- **Azure App Service + Azure Bot Service + Entra ID app + Key Vault = a lot of Azure surface**
- Ongoing cost: £20–50/month minimum even at low volume
- Deployment complexity: CI/CD from GitHub to App Service, slot-based deployments, managed identities
- Overkill for first-customer scale

**Verdict:** the right answer at 20+ customers or enterprise deal flow. Wrong answer for v1. Will reach this in v2.

### Option D — Teams app with bot registration via Teams Developer Portal, hosted on Cloudflare Workers (⭐ RECOMMENDED)

Register a bot via the friendlier Teams Developer Portal (which creates an Entra ID app under the hood without you touching Azure Portal), point the bot's messaging endpoint at a Cloudflare Worker. Worker handles bot framework protocol, calls Relevance AI, composes Adaptive Cards, sends back.

**Pros:**
- **Real Teams app with @-mentions, DMs, adaptive cards, everything**
- Azure touched only once, ever: one Entra ID app registration via Teams Developer Portal (~30 min)
- Cloudflare Workers free tier: 100k requests/day, enough for ~20 customers averaging 200 messages/day each
- Cloudflare KV (free tier) for tenant config; D1 (free tier) for audit logs
- Customer side: zero Azure work, zero installs beyond the Teams app upload
- Claude Code can drive every step: `az` CLI, `wrangler`, `teamsfx`, TypeScript Worker code
- Upgradeable: same architecture scales to v2 (Azure Bot Service) if needed
- Multi-tenant: one app, one messaging endpoint, tenant context extracted from incoming message `tenantId` field

**Cons:**
- Bot Framework protocol has quirks — Claude Code will handle them but there's a learning curve for 1–2 days
- Cloudflare Workers have 10ms CPU time per request free tier (30 seconds paid) — Relevance AI calls exceed this, so paid plan ($5/month) required from customer 1
- Free tier has 1,000 requests/min limit; probably fine but a real bottleneck at extreme burst load
- Adaptive Card schema learning curve

**Verdict:** recommended for v1.

### Option E — Copilot Studio (Microsoft's LLM bot builder)

Build the bot entirely in Copilot Studio (formerly Power Virtual Agents). Visual designer, LLM-powered topics, direct Teams integration.

**Pros:**
- Almost zero code
- Built-in Teams deployment
- Microsoft handles all the infrastructure

**Cons:**
- **Requires per-user Copilot Studio licence (~£150/month per maker + ~£15/month per consumer)**
- The LLM brain moves to Microsoft — you lose control of the agent logic
- Can't use Relevance AI or Claude directly; the "intelligence" becomes Microsoft's
- Locks Intel Force OS into the Microsoft stack permanently
- Pricing makes it commercially non-viable at £400/month Intel Force pricing

**Verdict:** rejected. The moment you build on Copilot Studio, Intel Force OS becomes a reseller of Microsoft Copilot rather than a distinct product. That destroys the thesis.

---

## 4. Option D in detail

### 4.1 The components

```
┌───────────────────────────────────────────────────────────────────────────┐
│                                                                           │
│  CUSTOMER'S MICROSOFT 365 TENANT                                          │
│  ┌───────────────────────────────────────────────────────────────────┐    │
│  │                                                                   │    │
│  │   #hr channel                 HR Lead's 1:1 chat with             │    │
│  │   ───────────                 Intel Force OS bot                  │    │
│  │   Employee:                   ──────────────────                  │    │
│  │     @Intel Force OS           Bot → Adaptive Card:                │    │
│  │     What's holiday            "New query from Sarah. Draft:       │    │
│  │     carry-over?               ..... [Approve] [Edit] [Reject]"    │    │
│  │                                                                   │    │
│  │   (bot listens)               (HR Lead taps Approve)              │    │
│  │                                                                   │    │
│  │   Intel Force OS bot          Bot posts reply in thread above     │    │
│  │   (via messaging              ───────────────────                 │    │
│  │    endpoint)                                                      │    │
│  │                                                                   │    │
│  └───────────────────────────┬───────────────────────────────────────┘    │
│                              │                                            │
│         Entra ID app         │  Bot Framework                             │
│         (registered by you)  │  protocol over HTTPS                       │
│         provides identity    │                                            │
│                              ▼                                            │
└──────────────────────────────┼────────────────────────────────────────────┘
                               │
                               │
┌──────────────────────────────┼────────────────────────────────────────────┐
│                              ▼                                            │
│  INTEL FORCE OS INFRASTRUCTURE (Cloudflare)                               │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────┐       │
│  │  Cloudflare Worker — bot.intelforce.ai                         │       │
│  │                                                                │       │
│  │  Route: POST /api/messages  ── handles bot protocol            │       │
│  │  Route: POST /api/card-action ── handles card button clicks    │       │
│  │                                                                │       │
│  │  Imports:                                                      │       │
│  │   - botbuilder (Bot Framework SDK)                             │       │
│  │   - adaptivecards-templating                                   │       │
│  │                                                                │       │
│  │  Logic:                                                        │       │
│  │   1. Verify request signature (Entra ID JWT)                   │       │
│  │   2. Extract tenantId from turnContext                         │       │
│  │   3. Look up tenant config in KV                               │       │
│  │   4. Call Relevance AI agent                                   │       │
│  │   5. Compose Adaptive Card                                     │       │
│  │   6. Send to HR Lead DM OR post in channel                     │       │
│  │   7. Log to D1 audit table                                     │       │
│  └────────────────────────────────────────────────────────────────┘       │
│                              │                                            │
│                              ├──▶ Cloudflare KV: tenant_config/{tenantId} │
│                              │                                            │
│                              ├──▶ Cloudflare D1: audit_log table          │
│                              │                                            │
│                              └──▶ Relevance AI agent HTTP endpoint        │
│                                    (or direct Claude API call)            │
└───────────────────────────────────────────────────────────────────────────┘
```

### 4.2 The per-message data flow

```
1. Employee types in #hr channel:
   "@Intel Force OS what's the holiday carry-over policy?"

2. Teams sends message to bot messaging endpoint:
   POST https://bot.intelforce.ai/api/messages
   Body: { type: "message", from: {...}, conversation: {...},
           text: "what's the holiday carry-over policy?",
           tenantId: "abc-123-customer-tenant" }

3. Worker verifies JWT signature, extracts tenantId.

4. Worker looks up tenant config in KV:
   tenant_config:abc-123-customer-tenant
   → { relevance_agent_id: "agent_xyz", hr_lead_email: "sarah@acme.com",
       handbook_kb_id: "kb_abc", approval_mode: "all", ...}

5. Worker calls Relevance AI:
   POST https://api.relevance.ai/agent/{agent_id}/invoke
   Body: { message: "what's the holiday carry-over policy?",
           context: { employee_name: "...", channel: "...",
                      tenant_config: {...} } }

6. Relevance AI returns:
   { draft_reply: "Our carry-over policy allows up to 5 days...",
     sensitivity_score: 0.1,  // non-sensitive
     confidence: 0.9,
     handbook_citations: ["handbook.pdf:p.23"],
     escalation_recommended: false }

7. Worker composes Adaptive Card with draft + [Approve|Edit|Reject] buttons.

8. Worker sends card via proactive messaging to HR Lead's 1:1 chat
   with Intel Force OS bot.

9. Worker writes to audit log (D1):
   INSERT INTO audit_log VALUES (
     tenantId, messageId, employee, query, draft_reply,
     sensitivity, status='pending_approval', timestamp)

10. HR Lead sees Adaptive Card DM within ~2 seconds of original question.

11. HR Lead taps "Approve". Teams POSTs to:
    POST https://bot.intelforce.ai/api/card-action
    Body: { action: "approve", audit_id: 12345, ... }

12. Worker retrieves the draft from audit log, posts it as a reply
    in the original #hr channel thread, updates audit log
    status='approved', records HR Lead actor and timestamp.

13. Employee sees reply in #hr channel, ~5-30 seconds total elapsed
    (depending on HR Lead response time).
```

### 4.3 The per-approval data flow (simpler)

```
Card button click → Worker → audit log lookup → Teams reply → audit update

Latency: <1s for Approve action (no AI call needed)
Latency: 2-3s for Edit action (brief re-generation if user wants AI to rewrite)
Latency: <1s for Reject (holding message posted)
```

### 4.4 The sensitive-escalation flow

```
1. Employee: "I've been having issues with a colleague..."

2-6. Same as normal flow until Relevance AI responds:
   { draft_reply: "I hear you, let me make sure the right
                   person gets this message ASAP.",
     sensitivity_score: 0.95,  // HIGH
     escalation_recommended: true,
     escalation_category: "interpersonal_conflict" }

7. Worker detects escalation_recommended=true.

8. Worker sends the holding reply immediately to the employee
   (no approval loop for the acknowledgement).

9. Worker sends an URGENT Adaptive Card to HR Lead DM with:
   - Original message (not redacted)
   - Category flag: "Interpersonal conflict — human attention required"
   - [Acknowledge — I'll handle] [Request Backup] buttons
   - Red border / amber-flag styling

10. Audit log marked: category='escalation', human_required=true,
    holding_reply_sent=true.

11. If HR Lead doesn't acknowledge within 2 hours during UK business
    hours, a follow-up ping is sent. This is configurable per tenant.
```

---

## 5. Key design decisions and why

### 5.1 Cloudflare Workers over Azure Functions / App Service

**Decision:** host the bot backend on Cloudflare Workers.

**Why:** 
- Free tier covers ~20 customers of HR-agent-scale traffic
- Global edge deployment means bot response latency is <50ms regardless of customer location
- KV and D1 are co-located (zero latency for config lookups and audit writes)
- No cold starts (Workers are always-warm)
- `wrangler` CLI is excellent and Claude Code can drive it fluently
- UK-resident data option available (Cloudflare has data residency controls)

**Trade-off accepted:** Cloudflare Workers have 10ms free-tier CPU limit per invocation. Relevance AI calls exceed this (they take 1–3 seconds). Requires paid plan ($5/mo) from customer 1. Accepted cost.

### 5.2 Bot registration via Teams Developer Portal, not Azure Portal

**Decision:** use `dev.teams.microsoft.com` to register the bot instead of the Azure Portal.

**Why:**
- Same underlying Entra ID app registration happens, but the UI is 10× simpler
- No need to provision an Azure Bot Service resource — bot is registered directly
- Manifest generation is automated
- App testing and sideloading is one-click from the same portal
- `teamsfx` CLI integrates with it for scripted flows

**Trade-off accepted:** some advanced bot scenarios (e.g. Direct Line for embedding in non-Teams UIs) require Azure Bot Service resource. Not needed for v1.

### 5.3 Adaptive Cards over messaging extensions

**Decision:** use Adaptive Cards sent via proactive messaging as the approval UI, not messaging extensions or action commands.

**Why:**
- Adaptive Cards are the primary rich-UI primitive in Teams; universally supported across Teams desktop, web, mobile
- Button actions (Action.Submit) post back to your Worker with full context — clean state management
- Supports inline editing, expandable sections, images, confirmation dialogs
- Can be authored declaratively in JSON; Claude Code generates them cleanly
- Rendering is consistent across clients (unlike HTML-based tabs)

**Trade-off accepted:** Adaptive Cards have a learning curve (element types, styling constraints) but Claude Code handles it. First 2-3 cards take time; subsequent ones are fast.

### 5.4 Relevance AI stays as the agent brain (for now)

**Decision:** the Worker calls Relevance AI over HTTP; does not reimplement the agent logic.

**Why:**
- The agent logic in Relevance AI is already working
- Rewriting it into direct Claude API calls is a 2-3 day detour that produces zero new functionality
- The HTTP call to Relevance AI is a clean abstraction — swap later without breaking the Worker
- Relevance AI handles knowledge-base retrieval, prompt versioning, tool routing — all things you'd have to rebuild

**Trade-off accepted:** Relevance AI adds ~500ms latency vs. direct Claude calls. Acceptable for HR workflows. Revisit if response times become a customer complaint.

### 5.5 No per-tenant Azure app registration

**Decision:** one Entra ID app registration for Intel Force OS across all customers. Customer installation is via Teams app manifest sideload + one-click admin consent.

**Why:**
- Per-tenant app registration would mean ~15 min of Azure work per customer — destroys the productisation story
- Microsoft's multi-tenant app pattern is designed exactly for this: one app, many tenants, each tenant consents to the permissions
- When customer IT admin sideloads the Teams app zip, they're prompted to consent to the bot's permissions (one click)
- Admin consent scoped per tenant; can be revoked anytime by the customer

**Trade-off accepted:** if the single Entra ID app is ever compromised, all customers are affected. Mitigate with secret rotation, IP allow-listing on Worker, and audit logging.

### 5.6 Audit log in Cloudflare D1, not customer-side SharePoint

**Decision:** audit log lives centrally in Intel Force D1 database, not in customer SharePoint Lists.

**Why:**
- D1 is dead-simple SQL, Claude Code manipulates it fluently
- Central audit enables cross-tenant analytics (which you own)
- Customer sees audit entries in the weekly report (derived from D1)
- SharePoint Lists are slow, awkward to query, and couple you to Microsoft's quirks

**Trade-off accepted:** customer data (redacted to message text + metadata) sits in Cloudflare D1, which is a US-origin vendor with UK/EU data residency options. DPA requirement. Add Cloudflare to the Phase 5 DPA sub-processor list (Annex B).

### 5.7 One Teams app, many agents

**Decision:** the Teams app is called "Intel Force OS", not "Intel Force HR Agent". When you build the Sales agent, it's a new route inside the same app, not a new Teams app install.

**Why:**
- Customer installs one app, gets all current and future capabilities
- Upgrades happen seamlessly — customer doesn't notice when Sales agent is added
- Brand consistency in the Teams app catalogue
- Avoids the "which Intel Force app should I install?" confusion

**Trade-off accepted:** the manifest must declare all possible bot commands upfront for best discoverability. When a new agent ships, the manifest needs an update, which means customer IT re-uploads. Acceptable quarterly cadence.

---

## 6. What this architecture does NOT include in v1

Intentionally deferred to v1.5 or v2:

| Feature | Why deferred | When to build |
|---|---|---|
| Personal Tabs with dashboard | Requires SSO, Graph API consent, more Azure surface | v1.5 — when HR Lead wants "show me my week at a glance" |
| Messaging Extensions (type-ahead search, compose extensions) | Nice-to-have, not critical for approval workflow | v1.5 — when customers ask "can I @-mention the agent to find a policy?" |
| Self-serve install from Teams App Store | Requires Microsoft Partner Center (£80/year + validation process) | v2 — around customer 10 |
| Proactive DM initiation (e.g. "good morning, here's your queue") | Requires per-user conversation reference storage | v1.5 — when weekly report via card >> email |
| Slack version (mirror architecture) | Parallel dev effort; start when first non-M365 customer appears | v2 — market-driven |
| Teams Meeting apps (e.g. agent that joins standups) | Different UX pattern | Never unless a real customer asks |
| Multi-language (Welsh, French for CH customers) | Relevance AI handles if prompted; Teams app needs localised strings | v2 — market-driven |

---

## 7. Security and compliance at a glance

Full design in `02-component-design.md` §6. Summary:

- **Authentication:** JWT-based bot framework authentication; Worker verifies every incoming request's JWT against Microsoft's public keys.
- **Authorisation:** bot framework calls include `tenantId`; Worker checks tenant is provisioned before processing.
- **Data in transit:** all HTTPS. No HTTP anywhere.
- **Data at rest:** Cloudflare KV + D1 encrypted at rest by Cloudflare. Secrets in Wrangler secrets store.
- **Data residency:** Cloudflare Workers can be configured to only execute in UK/EU regions; D1 databases created in EU region.
- **PII handling:** message text stored in D1 for audit (7-year retention per Phase 5 audit spec). Redaction of sensitive fields (phone, NHS numbers) before storage.
- **GDPR:** Cloudflare added to Phase 5 DPA as sub-processor. DSAR deletion scripts straightforward (DELETE WHERE tenantId = ? AND employee_id = ?).
- **Secret rotation:** Worker secrets rotated quarterly via `wrangler secret put`.

---

## 8. Cost envelope

At Intel Force OS scale:

| Component | v1 cost | At 10 customers | At 50 customers |
|---|---|---|---|
| Cloudflare Workers (paid plan) | £5/mo | £5/mo | £5/mo (probably) |
| Cloudflare KV | £0 | £0 | £0.50/mo |
| Cloudflare D1 | £0 | £0 | £2/mo |
| Cloudflare Pages (marketing site) | £0 | £0 | £0 |
| Azure Bot registration | £0 (free tier) | £0 | £0 |
| Entra ID app | £0 | £0 | £0 |
| Microsoft 365 Developer tenant (dev) | £0 | £0 | £0 |
| Relevance AI usage | £40/mo | £400/mo | £2,000/mo |
| Total **infra** cost | **£45/mo** | **£405/mo** | **£2,008/mo** |

At 50 customers × £400/mo revenue = £20,000/mo. Infra is 10% of revenue — healthy.

Key insight: **Relevance AI cost dominates**. When it becomes painful (~50 customers), migrate to direct Claude API via Anthropic Workspace, which you already have the Claude Max 20x subscription for. That drops AI cost to ~£0 for inference (within subscription limits) and adds just a bit of engineering work.

---

## 9. What changes vs the existing Phase 3-6 specs

Your existing platform specs (Postgres schema, Temporal provisioning, secrets vault, observability, dashboard) were designed for a PAAS-shaped product where Intel Force runs the infrastructure and customers access their data via a dashboard.

**This architecture is a different shape: delivery via Microsoft Teams, using Microsoft's infrastructure for the UX surface.**

| Phase 3-6 assumption | This architecture |
|---|---|
| Per-tenant Postgres schemas | Per-tenant Cloudflare KV keys |
| Temporal workflows for provisioning | Manual or Claude Code-assisted Teams manifest install |
| Dashboard at app.intelforce.ai | Dashboard becomes secondary (v1.5 Tab), primary UX is Teams |
| Webhook receiver for incoming data | Teams bot messaging endpoint IS the webhook receiver |
| Escalation Notifier as separate service | Escalation notification is a Teams Adaptive Card sent via the bot |
| Tenant container spec | No container per tenant; one Worker handles all tenants |

**The Phase 3-6 platform specs are NOT wasted.** They become the v2 architecture for when you have 30+ customers, enterprise prospects, or multi-agent orchestration that genuinely needs a Postgres-backed multi-tenant platform. The Teams app is the v1 that lets you get to 10 customers fast.

**Think of it as:**
- **v1 (this architecture):** Teams-first, single Worker, Cloudflare for everything, no Phase 3 infra needed
- **v1.5:** Add Teams Tab with a web dashboard (simple Next.js app), basic reporting
- **v2:** Phase 3 platform kicks in — per-tenant Postgres, multi-agent orchestration, enterprise-grade audit and DR
- **v3:** Multi-channel (Slack, Google Chat, web widget), all routing to the same platform

---

## 10. The build plan in one page

| Day | What | Who drives | Key file |
|---|---|---|---|
| 1 AM | Install prerequisites (`node`, `wrangler`, `az`, `teamsfx`), register for Microsoft 365 dev tenant | You, 1h | `03-azure-bootstrap...` |
| 1 AM | Run `az` setup via Claude Code — Entra ID app, bot registration | Claude Code, 30min | `03-azure-bootstrap...` |
| 1 PM | Scaffold Worker project, wire up Bot Framework SDK | Claude Code, 2-3h | `07-claude-code-prompts.md` §A |
| 1 PM | Write `/api/messages` route, call Relevance AI | Claude Code, 2h | `02-component-design.md` §2 |
| 2 AM | Design Adaptive Cards (approval, escalation, config) | Claude Code + you, 3h | `06-adaptive-card-examples.json` |
| 2 PM | Wire up card action handler, audit log, tenant config | Claude Code, 3h | `02-component-design.md` §3-5 |
| 3 AM | Build Teams app manifest, package zip, sideload to dev tenant | Claude Code, 1h | `03-azure-bootstrap...` §3 |
| 3 PM | End-to-end test in dev tenant — all scenarios | You, 2h | `04-deployment-guide.md` §5 |
| 4 | Iteration / bug fixes | You + Claude Code | — |
| 5-7 | Prepare first customer install (onboarding runbook, documentation) | You | `04-deployment-guide.md` |

**Total to first customer-ready build: ~1 week, assuming no day-2 bugs that take 3 days to debug. Plan for 2 weeks realistically.**

---

## 11. The moment you decide to build this

Before going further: answer these four questions honestly.

1. **Do you have any customer currently paying for the HR agent?** If no, building the Teams app prematurely is spec-shaped procrastination. Ship the email version first, get one paying customer, then build the Teams app once that customer is live.
2. **Does the Relevance AI agent actually work?** Can you run the three demo scenarios (simple, semi-complex, escalation) and get correct behaviour from it today, without you hand-editing outputs? If no, fix Relevance AI first.
3. **Is your first customer going to be on M365?** If they're on Google Workspace, this entire architecture is wrong — you want Google Chat integration, which is different. Confirm M365 before committing.
4. **Are you going to use Claude Code throughout?** If you'd rather write TypeScript by hand, the plan changes — it gets slower but more predictable.

**If all four are yes, proceed. If any is no, resolve before Day 1.**

---

Continue to `02-component-design.md` for the build-level detail.
