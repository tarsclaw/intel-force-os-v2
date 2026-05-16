# Teams HR Agent — Architecture Pack for Intel Force OS

**How to turn the Relevance AI HR agent into a productised Microsoft Teams app, built end-to-end with Claude Code, with minimal Azure setup (~30 minutes, one time, ever).**

This pack is the architecture-level plan for: *"I want my HR agent to live inside Teams as a real product, be multi-tenant deployable, reuse the Relevance AI work, and not be buried in Azure DevOps."*

---

## What this pack is

8 files, designed to be read in order:

| # | File | Purpose |
|---|---|---|
| 0 | `README.md` | Orientation — read this first |
| 1 | `01-architecture-overview.md` | The problem, 5 architecture options evaluated, the recommended architecture, data-flow diagrams |
| 2 | `02-component-design.md` | Every component in detail: manifest, Worker backend, Adaptive Cards, Relevance AI contract, tenant config, audit log |
| 3 | `03-azure-bootstrap-via-claude-code.md` | The 30-minute one-time setup, step-by-step, with Claude Code doing most of the work |
| 4 | `04-deployment-guide.md` | Per-customer 30-minute install procedure |
| 5 | `05-productisation-playbook.md` | Packaging, versioning, Teams App Store path, when to add more agents, Slack fallback for non-M365 customers |
| 6 | `06-adaptive-card-examples.json` | Working Adaptive Card JSON for approval, escalation, weekly report, config |
| 7 | `07-claude-code-prompts.md` | Literal prompts to paste into Claude Code to execute each build step — the "AI agent configures Azure for me" answer, fully expanded |

**Total: ~3,500 lines. Read 00 + 01 for the architecture decision (~1 hour). Read everything for the complete build plan (~2.5 hours).**

---

## The TL;DR architecture

```
 ┌────────────────────────────────────┐        ┌───────────────────────────────────┐
 │ CUSTOMER'S MICROSOFT 365 TENANT    │        │ INTEL FORCE OS INFRASTRUCTURE     │
 │                                    │        │                                   │
 │  Teams app (uploaded once)         │        │  Cloudflare Workers (serverless)  │
 │    ↓                               │        │    - bot messaging endpoint       │
 │  Employee @IntelForce in #hr       │───────▶│    - adaptive card composer       │
 │    ↓                               │        │    - approval handler             │
 │  Bot receives message              │        │    ↓                              │
 │    ↑                               │◀───────│  Relevance AI agent (unchanged)   │
 │  HR Lead gets approval card DM     │        │    ↓                              │
 │    ↓                               │        │  Cloudflare KV: tenant config     │
 │  HR Lead taps Approve              │───────▶│  Cloudflare D1: audit log         │
 │    ↓                               │        │                                   │
 │  Bot posts reply in #hr thread     │        │                                   │
 └────────────────────────────────────┘        └───────────────────────────────────┘

  Azure touched: ONE Entra ID app registration (via Teams Developer Portal, not Azure Portal)
  Customer side Azure: ZERO
```

---

## The three core architectural choices

### 1. Teams app with a bot, backed by Cloudflare Workers — NOT Azure Bot Service hosted

You register a bot (free, via Teams Developer Portal) and point its messaging endpoint at your Cloudflare Worker. Cloudflare hosts the intelligence, Microsoft hosts the user experience. You get a real Teams app — installable, @-mentionable, DM-capable — without ever provisioning an Azure resource group, App Service, or Bot Service resource.

### 2. Relevance AI brain stays where it is

The HR agent you've built in Relevance AI continues to run. The Worker is a thin routing layer that takes Teams messages, calls your Relevance AI agent over HTTP, composes an Adaptive Card, and sends it back. You can swap Relevance AI for direct Claude API calls later without changing the Teams-facing surface.

### 3. One Intel Force OS Teams app, many agents

You build the Teams app once. It declares itself as "Intel Force OS." The HR agent is the first capability. When you build the Sales agent, Recruiting agent, or anything else, they become routes inside the same Worker and commands inside the same Teams app — not separate Teams installs per capability. Customers install Intel Force OS, and new agents light up over time.

---

## How much Azure is actually involved

| Thing | Count | When | Who does it | Via |
|---|---|---|---|---|
| Entra ID app registration | 1 | Once, ever | You | Teams Developer Portal (friendlier than Azure Portal) |
| Bot registration | 1 | Once, ever | You | Teams Developer Portal |
| Azure Bot Service resource | 0 | Never | — | Skipped entirely |
| Azure App Service / Functions | 0 | Never | — | Cloudflare Workers instead |
| Key Vault | 0 | Never | — | Cloudflare KV + Wrangler secrets |
| Resource Groups | 0 | Never | — | Not required |
| Customer-side Azure work | 0 | Never | Customer | Customer IT admin does a one-click consent, that's it |

**Total Azure portal exposure: ~30 minutes, once, ever, driven by Claude Code via `az` CLI commands (so you watch, approve, Claude Code types).**

---

## Why this replaces the Power Automate idea from the GTM pack

The GTM pack suggested the HR agent would be email-triggered. That was right for a manual-service starting point with one customer. For productisation across 10–50 customers, email-based delivery has three problems:

1. **Teams is where UK SME HR actually happens.** Email is where older systems live and where complaints go. HR leads spend their day in Teams, not Outlook.
2. **Email is hard to productise.** Per-customer email integration (forwarding rules, IMAP, Graph Mail API) has enough edge cases that it becomes a support nightmare at 5+ customers.
3. **Teams has Adaptive Cards.** A one-click "Approve" button that posts the reply is a dramatically better UX than replying to an email thread and hoping the right thing happens.

Email-triggered handling can live alongside Teams as a fallback for customers who prefer it, but Teams is the primary product surface.

---

## What Claude Code will actually do for you

Claude Code is your co-pilot through every build step. Specifically:

1. **Scaffold the project** — run `teamsfx new` or manually scaffold, set up folder structure
2. **Configure Azure** — execute `az login`, `az ad app create`, and bot registration commands; you watch and approve
3. **Write the Worker code** — the bot messaging endpoint, adaptive card composer, Relevance AI client
4. **Generate Adaptive Card JSON** — cards render correctly in Teams first time
5. **Build the manifest** — Teams app manifest with all the right permissions, bot IDs, descriptions
6. **Deploy the Worker** — `wrangler deploy` to Cloudflare
7. **Package the app** — zip the manifest and icons for upload
8. **Test** — sideload into your Microsoft 365 dev tenant and run through scenarios
9. **Iterate** — fix, redeploy, re-test

File 07 (`07-claude-code-prompts.md`) contains the exact prompts to paste into Claude Code at each step. This is the "AI agent configures Azure for me" answer, made literal.

---

## Prerequisites before implementation starts

- [ ] Intel Force Ltd domain (intelforce.ai) — see GTM pack
- [ ] Cloudflare account (free tier is enough — Workers, KV, D1 all available)
- [ ] Microsoft 365 Developer Program sandbox tenant (free, 90-day renewable) — sign up at `developer.microsoft.com/microsoft-365/dev-program`
- [ ] Node.js 18+ installed locally
- [ ] `wrangler` CLI (`npm install -g wrangler`) — installed by Claude Code if missing
- [ ] `az` CLI (`brew install azure-cli` on Mac) — installed by Claude Code if missing
- [ ] `teamsfx` CLI (optional, `npm install -g @microsoft/teamsfx-cli`) — installed by Claude Code if needed
- [ ] Your existing Relevance AI agent with a callable HTTP endpoint (you have this)
- [ ] Claude Code installed in VS Code (you have this)

**Time to get prerequisites ready: 1 hour, most of it waiting for installers.**

---

## Timeline expectation

With Claude Code doing the heavy lifting:

| Stage | Effort | Elapsed time |
|---|---|---|
| Prerequisites setup | 1 hour | Day 1 AM |
| Azure one-time bootstrap | 30 min | Day 1 AM |
| Worker backend build | 4-6 hours | Day 1 PM + Day 2 |
| Adaptive Card design | 2-3 hours | Day 2 |
| Teams manifest + packaging | 1 hour | Day 2 |
| First end-to-end test in dev tenant | 1-2 hours | Day 3 AM |
| Onboarding runbook for first customer | 2 hours | Day 3 PM |
| First real customer deployment | 45 min | Day 4 or whenever |

**From "have the idea" to "first customer using Intel Force OS in Teams": ~3–4 working days. Realistically 1–2 weeks with interruptions.**

---

## Honest trade-offs to know before you start

### What this architecture does well
- Real Teams app, not a workflow hack
- Zero ongoing Azure cost at Intel Force's scale (Cloudflare free tier covers 100k req/day)
- Customer has zero Azure involvement
- Reuses all existing Relevance AI work
- Multi-tenant via manifest upload per customer (no complex OAuth flows)
- Claude Code can drive every step

### What it doesn't do (yet)
- **No self-serve Teams App Store listing in v1.** That requires Microsoft Partner Center registration (£80/year), app validation (1–2 weeks), and a polished onboarding flow. Deferred to v2 around customer 10.
- **No SSO into a web dashboard from inside Teams in v1.** Teams Tabs with SSO require more Azure setup than the messaging surface. Tabs are a v1.5 enhancement.
- **No 1:1 DM initiation from the bot.** Bots can reply to DMs but cannot initiate them without proactive messaging, which requires per-user conversation references. This is a v1.5 feature.
- **Not ideal for >1,000 users per customer.** Webhook-based architectures with long approval latencies start getting weird at very high volumes. Fine for 20–200 employee SMEs; revisit for enterprise.

### When you'll outgrow this architecture
Around 50+ customers or 5,000+ messages/day across all tenants, you'll want:
- Proper Azure Bot Service resource (not just registration) for reliability guarantees
- Your own Microsoft Partner Center tenant for self-serve distribution
- Possibly a dedicated Azure region for data residency guarantees with enterprise customers

None of this is relevant for the first year. Defer confidently.

---

## Reading order

### If you want to understand the architecture first
Read: `00-README.md` → `01-architecture-overview.md`
**Time: 1 hour. Outcome: you know if this is the right approach.**

### If you're ready to build
Read: `00` → `01` → `02` → `03` → `07`
**Time: 3 hours. Outcome: you have everything needed to start Day 1 with Claude Code.**

### If you're planning the business around this
Read: `00` → `01` → `05`
**Time: 90 min. Outcome: you know the productisation path, pricing implications, graduation triggers.**

### If you're debugging a specific component
Jump to `02-component-design.md` — organised by component.

---

## What's NOT in this pack

- **Prompt engineering for the HR agent** — your existing Relevance AI work
- **Sales collateral** — GTM pack
- **Legal docs** — Phase 5 pack
- **Multi-tenant Postgres / provisioning infra** — Phase 3 pack (not needed for v1, revisit at customer 10+)
- **Full platform dashboard** — Phase 4 pack (deferred)

This pack is narrowly scoped to: "how does Intel Force OS show up inside Teams, and how do we build it this month."
