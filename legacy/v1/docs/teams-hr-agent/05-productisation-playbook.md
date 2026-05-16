# 05 — Productisation Playbook

**How Intel Force OS scales from "one Teams bot for one customer" to "a multi-agent Teams platform serving 50+ customers." The sequencing, the decisions, the honest trade-offs.**

---

## 1. The product maturity curve

Intel Force OS goes through five stages. Each stage has different priorities, architectures, and constraints.

```
 Stage 1         Stage 2          Stage 3           Stage 4          Stage 5
 ─────────       ─────────        ──────────        ─────────        ─────────
 "HR agent       "Multi-agent     "Self-serve       "Enterprise-     "Multi-
  wedge"          platform"        install"          grade"           channel"
 
 1-5 customers   5-15 customers   15-30 customers   30-50 customers  50+ customers
 Teams only      Teams only       Teams App Store   Phase 3 infra    Teams + Slack
 HR only         HR + Sales +     v1.5 features    Full dashboard   + Google Chat
                 Recruit          Messaging ext.    SLA tiers        + Web widget
 Manual          Manual           Self-serve        White-glove      Channel-agnostic
 onboarding      + template       trial + install   + enterprise     platform
                                                    
 Month 1-3       Month 4-6        Month 7-9         Month 10-12      Year 2+
```

This file covers stages 1–3 in detail, stages 4–5 as orientation.

---

## 2. Stage 1 — HR agent wedge (months 1–3)

**Goal:** 3 paying customers, all on HR agent, all hand-onboarded.

### 2.1 What matters
- One agent that works brilliantly (HR)
- Three references who will say good things on LinkedIn
- Repeatable 45-min onboarding
- Weekly customer-facing cadence (Friday reports)

### 2.2 What doesn't matter yet
- Multiple agents
- Teams App Store listing
- Self-serve trial
- Enterprise SLAs
- Dashboard

### 2.3 Architecture at stage 1
Exactly what's in `02-component-design.md`. Cloudflare Worker + KV + D1, Adaptive Cards, manifest sideloading.

### 2.4 Pricing at stage 1
£400/month flat (per pricing sheet in GTM pack). Single-page service agreement. Monthly rolling.

### 2.5 Key risks
- Too many prompt tweaks per customer → graduates to "custom dev work" not product
- Per-customer Relevance AI agents drift apart → retune cost scales linearly with customers
- You spend >6hrs/customer/week on service layer

### 2.6 Exit criterion for stage 1
- 3 paying customers, all live >30 days
- First case study published
- You're spending <15 hrs/week total on delivery across all customers
- Week 1 onboarding feels scripted, not improvised

**Only move to stage 2 when all four are true.**

---

## 3. Stage 2 — Multi-agent platform (months 4–6)

**Goal:** 5-15 customers, same core platform, HR agent deeply refined, one new agent (probably Sales or Recruiting).

### 3.1 What changes architecturally

#### Same Teams app, new "commands"
The Intel Force OS Teams app already has a `commandLists` in the manifest. Add:

```json
"commands": [
  { "title": "help", "description": "Show what I can do" },
  { "title": "status", "description": "See what's pending approval" },
  { "title": "report", "description": "Get this week's summary" },
  { "title": "hr", "description": "HR agent — messages about leave, policy, people" },
  { "title": "sales", "description": "Sales agent — lead research, outreach drafting" },
  { "title": "recruit", "description": "Recruiting agent — candidate screening, interview prep" }
]
```

Manifest version bumps to 1.1.0; customers get a minor update notification in Teams.

#### Agent routing inside Worker
Messages now route based on command prefix OR channel configuration:

```typescript
// In bot handler
const agent = detectAgent(activity, config);
// Returns: 'hr' | 'sales' | 'recruit'

switch (agent) {
  case 'hr':
    return callRelevanceAgent(env, config.agents.hr, input);
  case 'sales':
    return callRelevanceAgent(env, config.agents.sales, input);
  case 'recruit':
    return callRelevanceAgent(env, config.agents.recruit, input);
}
```

Tenant config extends:

```typescript
interface TenantConfig {
  // ... v1 fields
  
  agents: {
    hr: {
      enabled: boolean;
      relevanceAgentId: string;
      channels: string[];
    };
    sales?: {
      enabled: boolean;
      relevanceAgentId: string;
      channels: string[];
    };
    recruit?: {
      enabled: boolean;
      relevanceAgentId: string;
      channels: string[];
    };
  };
  
  enabledAgents: ('hr' | 'sales' | 'recruit')[];
}
```

#### Pricing evolution
Per pricing spec Phase 5: Intel Force OS moves to tiered pricing around customer 10.

| Tier | Price | Agents included |
|---|---|---|
| Starter | £450/mo | One agent (pick one) |
| Growth | £1,800/mo | All agents available, full suite |
| Scale | £4,500/mo | All agents + custom agent development |

Founding customers grandfathered at £400/mo for 12 months (HR only).

### 3.2 The new-agent decision tree

When adding a second agent, which one?

**Sales agent** — best fit because:
- Clear ROI story (time saved on outreach)
- Maddox has Relevance AI experience + existing Lead Hunter / Caption Writer / Follow-up Pilot specs from Phase 2
- Natural cross-sell to existing HR customers (Ops leaders often wear sales ops hat too)
- Teams integration story is strong (sales happens in #sales channels)

**Recruiting agent** — second choice because:
- Specific — recruiting tools market is already competitive
- HR customers tend to have TA (talent acquisition) as separate function
- Integration targets (ATS systems like Greenhouse, Lever) vary per customer

**Marketing agent** — not recommended:
- Market is saturated with ChatGPT / Jasper alternatives
- No differentiation for Intel Force OS

**Recommendation: HR → Sales → Recruit in that order.**

### 3.3 Rollout mechanics for new agents
1. Build agent in Relevance AI (clone HR agent template, adapt prompts)
2. Add agent routing to Worker (1-2 day change)
3. Update manifest `commandLists` (minor version bump)
4. Release notes: "Intel Force OS v1.1 — now with Sales agent in beta"
5. First 3 customers get Sales agent free for 30 days (feedback loop)
6. Then upgrade pricing to Growth tier

### 3.4 Exit criterion for stage 2
- 10 paying customers, with ≥3 using multi-agent (Growth tier)
- Second agent (Sales) performing at ≥ HR agent quality
- Onboarding time <30 min
- First Marketplace-adjacent signal: customers start asking "can non-admins install this?"

---

## 4. Stage 3 — Self-serve install (months 7–9)

**Goal:** 15-30 customers, Teams App Store listed, customers can trial without calling Maddox.

### 4.1 Teams App Store submission

Required:
- **Microsoft Partner Center account** — £80/year, 1-week verification
- **Privacy policy and terms of service** — solid URLs (Phase 5 legal pack ready)
- **Completed app validation** — Microsoft reviews your app for ~1-2 weeks
- **Self-service install flow** — customer downloads app from in-Teams store, trial starts automatically

### 4.2 What's different about Teams App Store

| Aspect | Sideload (stage 1-2) | Teams App Store (stage 3) |
|---|---|---|
| Customer discovery | Outbound sales | Inbound discovery in Teams |
| Install friction | 10 min with you | 30 seconds self-serve |
| Admin consent | Done during install call | Customer IT admin approves via email prompt |
| Trial flow | Manual coordination | Built-in 14-day trial |
| Billing | Manual Stripe invoice | Stripe + Microsoft commerce integration |

### 4.3 The self-serve onboarding flow

```
1. Customer HR Lead discovers Intel Force OS in Teams App Store
2. Clicks "Add" → requests admin approval if needed
3. Admin approves in email (one click)
4. App installs into their Teams
5. Bot welcome card prompts:
   - "Let's configure. What's your handbook URL?"
   - "Which channel should I listen to?"
   - "What's your company tone like?"
6. Self-serve configuration captures answers, writes to tenant config
7. Guided smoke test: "Try asking me 'what's the holiday policy?'"
8. 14-day trial starts
9. Day 12: "Trial ending in 2 days — continue at £450/mo?" 
10. Customer enters Stripe card → subscription active
```

You are NOT on this call. The whole thing is automated.

### 4.4 What breaks at self-serve scale
- Customers with weird handbooks the agent can't parse
- Customers in non-M365 tenants trying to install (fails silently)
- Customers who want multi-agent but picked Starter trial
- Prompt drift across 20+ customer tenants all slightly different

### 4.5 The quality floor problem
At self-serve scale, you can't hand-tune every customer's agent. Instead:
- Ship a much more robust default agent prompt
- Build customer-facing "retrain" feature — HR Lead flags bad drafts, agent learns from thumbs-up/down
- Accept 80% quality baseline; 95% quality tier becomes "Scale" upgrade

### 4.6 Exit criterion for stage 3
- 30 paying customers, half via self-serve
- Customer acquisition cost <£300 (was £500-1000 in outbound phase)
- 20+ customer references
- First enterprise inquiry (someone asking for custom SLA)

---

## 5. Stage 4 — Enterprise-grade (months 10–12)

**Goal:** 30-50 customers, enterprise tier with dedicated infra.

### 5.1 What enterprise customers want
- Data residency guarantees (specific region)
- Dedicated Relevance AI / Claude capacity (no shared queues)
- Custom agent development
- 99.9% SLA with credits
- SOC 2 Type II (at least in progress)
- Procurement-friendly contracts

### 5.2 When Phase 3 architecture kicks in
The Phase 3 platform specs (Postgres, provisioning, secrets vault, observability) map directly to enterprise requirements:

- Per-tenant Postgres schemas → per-enterprise database isolation
- Temporal provisioning → predictable enterprise onboarding
- Secrets vault with per-tenant CMKs → enterprise-grade key management
- Escalation Notifier as standalone service → SLA-backed alerting

**Enterprise customers pay for Phase 3 infra. They're the reason it exists.**

### 5.3 Pricing evolves again
Enterprise tier: £10k+/month bespoke. Custom contract, custom SLA, dedicated infra.

---

## 6. Stage 5 — Multi-channel (year 2+)

**Goal:** Intel Force OS works everywhere UK SMEs communicate, not just Teams.

### 6.1 Channel priorities
1. **Slack** — for tech-startup customers, marketing/creative agencies (highest overlap with Intel Force OS ICP who aren't on M365)
2. **Google Chat** — for companies fully on Google Workspace
3. **Web widget** — for companies with HR portals who want agent inside their existing intranet

### 6.2 The Slack architecture (mirror of Teams)

Same core architecture, different surface:

| Teams | Slack equivalent |
|---|---|
| Teams app manifest | Slack app manifest (JSON) |
| Bot Framework messaging endpoint | Slack Events API webhook |
| Adaptive Cards | Block Kit |
| Proactive messaging | chat.postMessage API |
| Bot registration (Teams Dev Portal) | Slack app creation (api.slack.com/apps) |
| Admin consent | Slack admin install flow |
| Cloudflare Worker | Same Worker, new `/api/slack` routes |

**The same Relevance AI brain is reused.** The same tenant config schema extends. The same audit log. The Worker grows new endpoints but the architecture is additive.

### 6.3 Why this works
- The Worker was designed channel-agnostic (agent brain is decoupled from UI surface)
- Cloudflare's Workers make adding new HTTP endpoints free
- Per-channel packaging (manifest per channel) is the only per-channel work

### 6.4 When to actually build Slack
**Not before:**
- A customer explicitly asks "do you have Slack?"
- 3 customers have declined because of Teams-only
- Customer acquisition pipeline shows >30% Slack penetration in your ICP

**Rough timeline: 2 weeks to build, 1 week to polish, 1 week to onboard first Slack customer.** Claude Code drives most of it — the patterns from Teams translate directly.

---

## 7. Versioning strategy

### 7.1 Semantic versioning for the Teams app

- **Major version (1.x → 2.x):** breaking changes (e.g. removal of an agent, major manifest restructure). Customer must re-install.
- **Minor version (1.0 → 1.1):** additive features (new agent, new command, new card type). Customer gets "Update available" in Teams; click to update.
- **Patch version (1.0.0 → 1.0.1):** bug fixes only. Silent update pushed via Teams Admin Center.

### 7.2 Versioning the Worker

Cloudflare Workers support native versioning:
- Each `wrangler deploy` creates a new version
- Previous versions are queryable (`wrangler deployments list`)
- Rollback is one command: `wrangler rollback --version-id=xyz`

Recommended workflow:
- Main branch auto-deploys to production Worker on push (via GitHub Action)
- PRs auto-deploy to a preview Worker (`intel-force-os-bot-preview.workers.dev`)
- Smoke tests run against preview before merge

### 7.3 Versioning the Relevance AI agent
Relevance AI has some versioning but it's not git-native. Recommended:
- Treat agent prompts as code: store canonical prompts in `agents/*.md` in your repo
- Script to sync from repo to Relevance AI on deploy
- Every prompt change is a PR, reviewed before deploy
- Relevance AI agent changes are released in lockstep with Worker changes when they're related

### 7.4 The versioning invariant

**At any point in time, the Worker deployed to production must be compatible with both:**
- The current Relevance AI agent version
- The Teams app manifest version customers have installed

If you need to break compatibility (e.g. new required field in Adaptive Card), ship it as v2 (major version bump), get customers to update, then deprecate the old Worker routes.

---

## 8. Monitoring at scale

### 8.1 Per-customer health dashboard

Build a simple internal page (Cloudflare Pages site, not exposed to customers) showing:
- Per-tenant: messages handled (last 7d), approval rate, escalation rate, error rate, latency P95, Worker cost
- Alert thresholds:
  - Error rate >5% → red
  - No messages in 7 days → yellow
  - Approval rate <50% → yellow (customer not engaging with bot)

### 8.2 Per-customer SLA tracking

For paid customers with SLAs (Growth tier and up):
- Uptime measurement: scripted pings to bot endpoint, logged in D1
- Monthly SLA report auto-generated from logs
- Credit calculations automated

### 8.3 Cost per customer tracking

Critical for margin math:
- Worker invocations per tenant → Cloudflare billing
- Relevance AI cost per tenant → API usage reports
- Human support time per tenant → your self-reported tracking

If cost per customer > 30% of price for 2+ months running, that customer is not viable at current price. Either:
- Upgrade them to next tier
- Limit their usage (rate-limit heavier tenants)
- Offboard

---

## 9. Customer success motions

### 9.1 Onboarding (stage 1-2)
Manual, white-glove, 45 min call.

### 9.2 Retention (stage 2+)
- Weekly automated report (Monday 09:00)
- Monthly review call (first Friday, 30 min)
- Quarterly business review for Growth+ customers (60 min, detailed metrics)
- NPS survey at month 3, 6, 12

### 9.3 Expansion (stage 2+)
- HR customer success signals → offer Sales agent trial
- Multi-agent customer signals → upgrade to higher tier
- Multi-office / multi-company customer → Agency Partner plan (from Phase 5)

### 9.4 Churn prevention
If weekly report data shows:
- <50% approval rate for 2 weeks running: something's wrong, proactively check in
- Escalation rate >30%: agent is misclassifying, retune urgently
- Zero messages for 14 days: customer is ignoring the bot, risk of churn

Automated alerts trigger your intervention.

---

## 10. The build/buy decisions yet to make

### 10.1 Identity & SSO
**Build:** not needed in v1 (bot auth via Entra ID is enough)  
**Buy:** when Tab dashboard ships (v1.5), use Microsoft's Teams SSO (free)

### 10.2 Billing
**Build:** you already have Stripe from Phase 5  
**Buy:** Microsoft Commercial Marketplace billing when you list in Teams App Store (takes 20% cut, but adds legitimacy and self-serve trial)

### 10.3 Analytics
**Build:** Cloudflare D1 aggregations for customer-facing metrics  
**Buy:** PostHog or Mixpanel for internal product analytics (not needed until 30+ customers)

### 10.4 Documentation
**Build:** MDX docs site on Cloudflare Pages (same stack, cheap)  
**Buy:** GitBook if docs get complex (month 9+)

### 10.5 Error tracking
**Buy now:** Sentry (free tier generous, essential even at stage 1). Integrates with Cloudflare Workers in 10 min.

### 10.6 Status page
**Buy now:** Statuspage.io per Phase 5 spec

### 10.7 Customer support
**Build:** Slack shared channels per customer (already in GTM pack)  
**Buy:** Intercom / Front when you hit 15+ customers and need ticket tracking

---

## 11. The moment to build the Phase 4 dashboard

You currently have no customer-facing dashboard outside Teams (no web UI, no admin panel).

**Build the dashboard when:**
- Customer requests come up in 3+ weekly reviews ("can I see all pending approvals in one place?")
- You find yourself writing SQL against D1 to answer customer questions weekly
- Teams Tab limitations are actively constraining the product experience
- You're at stage 3+

**Don't build it before:**
- 15 customers
- Clear pain signal
- A week of budget to commit

**Recommended path when you do build:**
- Simple Next.js app on Cloudflare Pages
- SSO via Microsoft Teams Tab SSO
- Reads from the same D1 database as the Worker
- Ships as a Teams Tab initially; standalone web app later

The Phase 4 spec (in the larger project) is the target for this. It's designed for exactly this build.

---

## 12. The honest view: when this architecture stops working

This Teams-app-on-Cloudflare architecture is excellent for stages 1-3. It will start to creak at:

### Scale breakpoint 1: 100+ concurrent customers
- Cloudflare Workers free tier limits
- D1 query performance at millions of audit rows
- Single Worker script becoming unwieldy

**Fix:** split into multiple Workers (one per major function), shard D1 by tenant hash, or migrate to proper Postgres (Phase 3 spec).

### Scale breakpoint 2: Enterprise compliance demands
- Customer demands SOC 2 Type II, ISO 27001, specific data residency
- Penetration test requirements
- Custom DPAs with tenant-specific sub-processor restrictions

**Fix:** Phase 3 platform architecture, dedicated infrastructure per enterprise customer.

### Scale breakpoint 3: Multi-channel truth
- Once Slack + Teams + Google Chat + web are all live, single-Worker routing gets messy
- Different channels have different state requirements (proactive messaging, threading, etc.)

**Fix:** channel-specific Workers (or Durable Objects for stateful conversations), shared Postgres backend.

### Scale breakpoint 4: Custom enterprise agents
- Enterprise asks "can you build us a custom agent for our specific internal process?"
- Per-customer Relevance AI agents diverge from the shared template
- Custom infrastructure per customer

**Fix:** dedicated per-enterprise deployments. This becomes a consulting-plus-platform hybrid. Different business model.

---

## 13. The roadmap in one table

| Month | Key milestone | Architecture changes | Revenue target |
|---|---|---|---|
| 1 | Customer 1 live on HR agent | v1 architecture complete | £400 MRR |
| 2 | Customer 2, first case study | Minor Worker tweaks | £800 MRR |
| 3 | Customer 3, stage 1 complete | Onboarding automation | £1,200 MRR |
| 4 | Sales agent beta | Multi-agent routing in Worker | £1,800 MRR |
| 5 | 5 customers, 2 multi-agent | Tenant config v2 schema | £3,000 MRR |
| 6 | 8 customers, stage 2 complete | Minor version bumps only | £5,000 MRR |
| 7 | Teams App Store submission | Manifest v1.2, validation | £7,500 MRR |
| 8 | Teams App Store listed, first self-serve | Stripe integration hardening | £10,000 MRR |
| 9 | 15 customers, stage 3 complete | Scale testing, monitoring | £12,000 MRR |
| 10 | First enterprise pipeline | Phase 3 platform spec begins | £15,000 MRR |
| 11 | 25 customers, first enterprise signed | Per-tenant Postgres deployed | £18,000 MRR |
| 12 | 30 customers, stage 4 milestone | SOC 2 Type I, formal SLAs | £22,000 MRR |

At month 12: £264k ARR. Significantly exceeds the £100k goal. Driven by:
- Higher tier conversion (customers upgrading HR → multi-agent)
- One or two Agency Partner deals (Rigby Group-shaped)
- First enterprise deal

**This is the productisation roadmap. It makes the GTM pack concrete and the platform spec time-bound.**

---

Continue to `06-adaptive-card-examples.json` for working card JSON you can paste into your Worker.
