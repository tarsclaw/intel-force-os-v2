# IntelForce AI OS — Strategic Plan & Build Blueprint
**The UK's first sovereign agentic operating system for SMEs and enterprise**

> *Prepared for Maddox Rigby, Founder, Intel Force*
> *Target launch: first paying client within 10 weeks*

---

## 1. Executive Summary

You are not building an AI consultancy anymore. You are building **a productized agentic platform** — IntelForce AI OS — that a client can log into, watch a workforce of AI agents run their business in real-time, and pay a predictable monthly fee for. Services revenue funds the platform build. The platform becomes the IP.

The core insight from Nick Puru's model is this: **he is not selling AI — he is selling a dashboard**. The dashboard is the product. The agents behind it are commoditising. The IP is the productization, the configuration layer, and the brand wrapped around a repeatable deployment system.

You have three advantages Nick doesn't:
1. **UK-sovereign positioning** — OpenClaw as a UK-built orchestration layer (GDPR, data residency, and genuine anti-hyperscaler story that Brits care about)
2. **Rigby Group access** — SCC (5,000+ employees), Eden Hotels, Allect. Enterprise proof points that no US creator can touch
3. **Vertical depth** — you've already done market research on UK dental, luxury hospitality, IT services. Pre-built agent packs per vertical > generic horizontal product

The plan below is honest about what is hard, what you can ship in 10 weeks, and what you should *not* try to build in v1.

---

## 2. Positioning & Market

### 2.1 What IntelForce AI OS actually is (the one-liner)

> *"A 24/7 agentic workforce for your business — sales, marketing, and operations — deployed in 72 hours, managed from a single dashboard, running on UK-sovereign infrastructure."*

Sub-line for enterprise: *"The OpenClaw orchestration layer. UK-built. Enterprise-grade. Your data never leaves your tenant."*

### 2.2 ICP (drawn from Nick's proven list + your UK reality)

**Tier 1 — Core SME (priced £3–8k setup + £500–£2,000/mo retainer):**
- Dental practices (UK — your existing research moat)
- Private clinics (aesthetic, physio, private GP)
- Law firms (SMB / regional)
- Accountancy practices (SMB / regional)
- Design/creative studios (Allect-adjacent)

**Tier 2 — Specialist vertical (priced £8–20k setup + £2k–5k/mo):**
- Boutique hotels & small hotel groups (Eden-adjacent)
- Commercial real estate firms
- B2B SaaS (UK, pre-Series A, founder-led sales)
- Wealth management / boutique financial advisors
- Marketing agencies (meta-sale: selling them the system they'd wish they could build)

**Tier 3 — Enterprise (priced £50k–250k setup + £5k–20k/mo):**
- Rigby Group divisions (SCC, Eden, Allect) — start here
- Mid-market PE portfolio companies
- UK government adjacencies (via the Sovereign AI / Innovate UK route you were exploring)

**Kill list** — do not take on these in year one, they will destroy your unit economics:
- E-commerce brands (too promo-heavy, won't pay retainer)
- Solo creators / influencers (high support, low revenue)
- Crypto (regulatory mess)
- US clients (timezone, support burden, no Rigby angle)

### 2.3 Positioning against Nick Puru

Nick is selling to US creators/entrepreneurs who watched his reel. You are selling to UK business owners. Lean into what Nick cannot credibly claim:

| Axis | Nick | You |
|---|---|---|
| Sovereignty | US-based, AWS-hosted | UK-built, OpenClaw, data in UK/EU |
| Reference clients | Unnamed | SCC, Eden Hotel Collection, Allect (Rigby Group) |
| Verticalisation | Generic horizontal | Pre-built packs: dental, hospitality, IT services |
| Setup time | Unclear, bespoke | Productized 72-hour deployment |
| Pricing | $5–15k + retainer | £3–20k + retainer (tiered, transparent) |
| Voice layer | Not shown in reel | Native voice receptionist agent |

---

## 3. The Product (what you actually build and sell)

### 3.1 The core offer: "The Nine"

Every IntelForce AI OS deployment ships with the same nine agents. This is non-negotiable. **Variable scope kills productization.** Nick knows this. The nine are adapted from his blueprint but tightened for UK SME reality.

**Sales Division** (reports to Sales Director agent)
1. **Lead Hunter** — scrapes + qualifies leads (Apollo, Clay, Companies House), writes to CRM with enrichment
2. **Proposal Builder** — the signature agent. Fathom call ends → draft proposal in inbox within 90 seconds
3. **Follow-Up Pilot** — monitors CRM dormancy, sends on-brand follow-ups, books meetings into Cal.com / Calendly

**Marketing Division** (reports to Marketing Director agent)
4. **Content Creator** — trained on client voice docs, produces long-form content from one-line briefs
5. **Repurposer** — one pillar piece → LinkedIn, IG carousel, YouTube Short script, email, thread
6. **Caption Writer** — platform-native social captions with CTAs, posting via Buffer/Later

**Operations Division** (reports to Operations Director agent)
7. **Client Onboarder** — fires on contract signature: welcome sequence, intake form, Slack/Teams channel, kickoff invite
8. **Reporting Engine** — pulls from Stripe, GA4, Meta Ads, CRM. Delivers weekly briefing in-Slack + PDF
9. **SOP Writer** — ingests Loom recordings, outputs Notion-formatted SOPs

### 3.2 The add-on layer (upsell, not default)

Keep the core nine fixed. Sell these as **productized add-ons** — each one is itself productized, not bespoke:

| Add-on | Monthly | One-off |
|---|---|---|
| Voice Receptionist (Vapi / Retell, trained on practice FAQs) | £400–800/mo | £750 |
| HR Agent (sits in Teams/Slack, handles leave, policy Qs, onboarding docs) | £500/mo | £1,000 |
| SEO Brief Generator (keyword research → content briefs for Content Creator) | £300/mo | £500 |
| Paid Ads Copywriter (Meta/Google copy variants + A/B tracking) | £400/mo | £750 |
| Custom Vertical Agent (bespoke, capped at 20 hours) | £750/mo | £2,500 |

**The rule**: if you build a custom agent for a client, it goes into the template library the next quarter and becomes a productized add-on. You never build the same thing twice.

### 3.3 What you are explicitly *not* selling

- Chatbots (low perceived value, race to the bottom)
- Generic ChatGPT wrappers
- One-off automations (your competition is n8n freelancers at £30/hr)
- Anything that requires you to be in the loop for it to work

---

## 4. Technical Architecture — the honest version

This section is the one you need to get right. The rest is marketing; this is where the platform actually lives or dies.

### 4.1 The runtime problem — and the hard truth about Claude Code

You floated Claude Code CLI + your Max 20x subscription as the production runtime. **Do not do this.** Three reasons:

1. **Anthropic has already blocked OAuth tokens from being used outside Claude Code** (January 2026 change). They will keep tightening. Your whole business breaks the day they do.
2. **ToS violation risk** — running paying clients' production workloads through your personal Max subscription is exactly what Anthropic is actively preventing. You cannot build a UK-sovereign compliance story on top of a ToS violation.
3. **Max 20x is rate-limited to ~900 messages per 5-hour window.** One client at scale maxes this out. You cannot multi-tenant across it.

**Use Max 20x for what it's designed for**: your own development work, building the platform, R&D, internal tooling. Keep it. It's worth £25k+/mo in equivalent API value for *your* build.

### 4.2 Recommended runtime stack

```
┌─────────────────────────────────────────────────────────────┐
│  CLIENT-FACING DASHBOARD (Next.js 14, Vercel or UK VPS)     │
│  - Auth: Clerk or Supabase Auth                             │
│  - Real-time: Supabase Realtime / Pusher                    │
│  - Node visualisation: React Flow                           │
│  - UI: Tailwind + shadcn/ui (customised)                    │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  CONFIGURATION + CONTROL PLANE (Node/TypeScript on UK VPS)  │
│  - Client tenancy, API key vault (encrypted, KMS-backed)    │
│  - Agent template library (the 9 + add-ons)                 │
│  - Deployment orchestrator                                  │
│  - Billing hooks (Stripe)                                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  AGENT RUNTIME LAYER (multi-tenant, always-on)              │
│                                                             │
│   Option A: OpenClaw (your path) — one instance per tenant │
│             running in isolated Docker container on your VPS│
│                                                             │
│   Option B: Lightweight orchestrator you own (recommended  │
│             for v1): Node worker that calls Anthropic API  │
│             directly per-agent, with a simple state machine│
│             (LangGraph-style) and cron triggers            │
│                                                             │
│   Model routing:                                            │
│   - Primary: Claude Sonnet 4.6 via API (£3/£15 per M tok)  │
│   - Heavy reasoning: Claude Opus 4.7 (reserved tier)       │
│   - Batch/low-stakes: Kimi K2.5 or Haiku 4.5 (cost saver)  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  INTEGRATION LAYER                                          │
│  - MCP servers for: HubSpot, Fathom, Gmail, Slack, DocuSign,│
│    Notion, GA4, Meta Ads, Stripe, Calendly, Dentally        │
│  - n8n fallback for integrations without MCP yet            │
│  - Webhook receivers for real-time triggers                 │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 The single most important architectural decision

**Do not use OpenClaw as the production runtime for v1.**

Here's why, honestly: you have open configuration issues, the Discord/Telegram channel bits are fragile, and you cannot ship a paying product on a runtime you're still troubleshooting. Instead:

- **v1 runtime**: a minimal orchestrator *you build* in Node/TypeScript that does four things — (1) receives triggers, (2) runs the right agent with Anthropic API, (3) writes state to Postgres, (4) pushes updates to the dashboard via WebSocket. Roughly 2,000 lines of code, buildable in two weeks.
- **v2 runtime**: OpenClaw-native, once you've stabilised OpenClaw and can use the UK-sovereign angle genuinely.
- **Position OpenClaw publicly as the future state** — "IntelForce AI OS runs on the OpenClaw orchestration layer" — but ship v1 on a boring, reliable stack.

This is the difference between a product you can sell in 10 weeks and one you'll still be debugging in 10 months.

### 4.4 Cost model (per-client, per-month)

For a typical Tier 1 SME client running the nine agents:

| Line item | Cost to you |
|---|---|
| Anthropic API (Sonnet 4.6, ~15M tok/mo) | ~£200 |
| Infra (shared VPS, per-tenant allocation) | ~£30 |
| Third-party APIs (Apollo share, Vapi etc) | ~£80 |
| Stripe + tooling | ~£15 |
| **Total COGS per client** | **~£325/mo** |
| **Retainer (Tier 1)** | **£800–£2,000/mo** |
| **Gross margin** | **60–83%** |

This works. At £1,500 average retainer × 40 clients = £60k MRR = **£720k ARR**, well past your £100k goal.

---

## 5. The Dashboard — your actual IP

The dashboard is the product. Not the agents. The agents are increasingly commodity; anyone can wire up Claude API to write a proposal. What people pay for is:

1. **Visibility** — "I can see my AI workforce operating in real-time"
2. **Control** — "I can pause, configure, retrain from one place"
3. **Trust** — "I can audit what the AI did and why"
4. **Beauty** — "This thing is expensive and I'm proud of it on my laptop"

### 5.1 Dashboard core views (v1 scope)

1. **Home / Hierarchy** — the node graph. Directors → sub-agents. Real-time status. This is the screenshot people see and want.
2. **Agent Activity Log** — live tail of every agent action, outputs linked, errors flagged
3. **Agent Detail** — the "Proposal Builder" card Nick shows. What it does, what it's connected to, recent activity, Configure / Run Now buttons
4. **Revenue/Outcome Panel** — "£84,200 in proposals drafted this month", "38 leads surfaced", "17 SOPs written". This is what justifies the retainer.
5. **Configuration Center** — covered in §6, the single biggest lever for scaling
6. **Audit Log** — every agent decision, timestamped, exportable (GDPR + enterprise requirement)

### 5.2 What makes yours different visually from Nick's

- **Typography hierarchy** — use a distinctive serif for headlines (Fraunces or Instrument Serif), not Inter
- **Accent color** — move away from his purple. Use a deep emerald or UK-flag-adjacent cobalt/crimson — *own* the "British AI" aesthetic
- **Motion language** — agents "pulse" when active, data flows animate along connection lines (subtle, not gaming)
- **Enterprise polish** — audit logs, permission layers, export buttons (things Nick's consumer-aimed dashboard won't have)

A working prototype of this dashboard is delivered alongside this plan.

---

## 6. The Configuration Center — the key to scaling

This is the part most people get wrong. If onboarding a new client takes you two weeks of custom work, you cannot scale. The Configuration Center is what turns IntelForce from a consultancy into a product.

### 6.1 The 72-hour deployment goal

From signed contract to live dashboard: **72 hours, maximum 4 hours of your time.**

The client does most of the work themselves through a guided wizard:

```
Step 1: Company Profile (client fills in)
  - Business name, industry, website
  - Team members (for @mentions in outputs)
  - Brand voice (upload docs or paste examples)
  - ICP description
  - Current stack (checkboxes: HubSpot? Fathom? Gmail?)

Step 2: Integration Connection (OAuth flows)
  - Click "Connect HubSpot" → OAuth redirect → done
  - Same for Fathom, Gmail, Slack, Calendly, Stripe, etc.
  - Any missing integration → "Skip and configure later"

Step 3: Agent Selection
  - All 9 core agents toggled on by default
  - Any add-ons they purchased pre-enabled
  - Per-agent config (e.g. Proposal Builder: which Fathom folder?
    which DocuSign template? whose name at the bottom?)

Step 4: Voice & Context Training
  - Upload: past winning proposals, brand guidelines, SOPs,
    email examples, sales scripts
  - System ingests to vector store (Supabase pgvector)
  - Client reviews auto-generated "Voice Profile" summary
    and approves / edits

Step 5: Go-Live Checklist
  - Test run each agent with sample input
  - Client approves outputs
  - Flip the switch → agents go live
```

Your role: review the Voice Profile approval and do a 30-minute kickoff call. That's it. The system does the rest.

### 6.2 How this is built (the reusable scaffold)

```
/platform
  /templates          ← the 9 agents, parameterised
    /proposal-builder
      agent.yaml      ← prompt, model, tools, triggers
      tools.yaml      ← which MCP/API connections needed
      config-schema.json  ← what client needs to provide
  /tenants
    /{client-id}
      config.json     ← their answers from the wizard
      voice-profile.json
      deployment.json ← which agents enabled, with their configs
      secrets.vault   ← encrypted API keys
```

When a new client completes the wizard, the deployment orchestrator:
1. Reads their `config.json`
2. For each enabled agent, takes the template + their config → generates a runnable agent instance
3. Writes to their tenant DB
4. Starts the triggers (webhooks, cron, etc.)
5. Pushes "live" status to their dashboard

**You configure once, deploy infinitely.** This is the IP.

---

## 7. Build Roadmap — 10 weeks to first paying client

You have 2–3 months. Here's how you actually use them. This assumes you + one developer (hire the guy you mentioned, or a UK/EE contractor at £40–60/hr for ~20 hrs/week).

### Weeks 1–2: Foundations
- [ ] **You**: Incorporate cleanly, open Stripe business account, trademark "IntelForce AI OS" (UK IPO, £170)
- [ ] **You**: Write the 9 agent prompts (v1) using your Max 20x — iterate hard, this is your craft
- [ ] **Dev**: Set up the monorepo: Next.js dashboard + Node control plane + Postgres + Docker
- [ ] **Dev**: Auth (Clerk), base tenant model, basic dashboard shell
- [ ] **You**: Design system + component library (use the prototype delivered with this doc as starting point)

**Milestone**: you can log in to a tenant and see an empty dashboard.

### Weeks 3–4: Core runtime + first 3 agents
- [ ] **Dev**: Agent runtime v1 — Node worker, Claude API integration, state persistence
- [ ] **Dev**: Trigger system (webhooks, cron via BullMQ)
- [ ] **You + Dev**: Ship the three signature agents first:
  - Proposal Builder (this is your demo agent — polish it)
  - Follow-Up Pilot (easy win, shows real ROI fast)
  - Lead Hunter (highest-visibility output)
- [ ] **Dev**: Real-time dashboard updates (WebSocket / Supabase Realtime)

**Milestone**: the Proposal Builder agent actually takes a Fathom call and drafts a proposal. End-to-end.

### Weeks 5–6: Full agent suite + integrations
- [ ] **Dev**: Remaining 6 agents (Content Creator, Repurposer, Caption Writer, Client Onboarder, Reporting Engine, SOP Writer)
- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
- [ ] **You**: Voice ingestion pipeline (upload docs → vector store → voice profile)

**Milestone**: all 9 agents running in a test tenant with real data.

### Weeks 7–8: Configuration Center + onboarding
- [ ] **Dev**: Build the 5-step configuration wizard
- [ ] **Dev**: OAuth flows for all integrations
- [ ] **Dev**: Deployment orchestrator (config → running agents)
- [ ] **You**: Design + write all onboarding copy (this is a sales document disguised as a form)

**Milestone**: deploy a brand new tenant in <72 hours from a cold start.

### Week 9: Polish, billing, audit
- [ ] **Dev**: Stripe subscriptions wired to dashboard tiers
- [ ] **Dev**: Audit log + GDPR export
- [ ] **Dev**: Error recovery (agent retries, circuit breakers)
- [ ] **You**: Marketing site, pricing page, case study template

**Milestone**: charge someone money for this.

### Week 10: First paying client
- [ ] Onboard one of your existing dental practice contacts (a "design partner" — half price, 6-month commit, in exchange for a video case study)
- [ ] Document every friction point of the onboarding
- [ ] Ship v1.1 fixes as they surface

**Milestone**: £X in the bank. Case study in the can.

### Stretch (weeks 11–16)
- Voice Receptionist add-on (Vapi integration)
- Vertical pack for dental (UK-specific: Dentally, R4, SOE Exact integrations)
- First enterprise pilot (Rigby Group division)
- Affiliate / referral program

---

## 8. Go-to-Market (weeks 8–12, overlapping with build)

### 8.1 The sales motion

**Step 1 — Free AI Audit (you, 30 min)**
- Prospect books via calendar link
- You ask 10 questions about their business, deliver a "here's where AI can save you X hours/week" report
- No sell, just value

**Step 2 — Visual Blueprint (you, 45 min, £0 or £250 deposit)**
- Live screen-share where you configure a *fake* tenant live for them
- They watch the dashboard populate with *their* logo, *their* agents, *their* industry
- This is the close. They're looking at their own business run by AI on their screen.

**Step 3 — Phased Build (paid, starts in 72hrs)**
- Sign contract, pay 50% setup fee upfront
- 72-hour deployment
- Week 1: go-live with 3 agents (highest ROI)
- Week 4: full 9 agents + training
- Month 2+: retainer kicks in

### 8.2 Channels, ranked by realistic ROI for you

1. **Rigby Group warm intros** — start here. One SCC/Eden/Allect division = case study gold. Your single biggest unfair advantage.
2. **Dental practices (your existing research)** — cold email your already-mapped list with a Loom video showing the dashboard running on their fake data.
3. **Content marketing with your existing playbook** — the Ian Gadzhi-style content strategy you've been building. Your yacht/lifestyle content now has a product behind it. Stop selling abstract AI; start selling the dashboard with "I just shipped this for [client] — watch me configure it in 10 mins".
4. **Partnership with Jack's web design agency** — Jack sells websites, bundles IntelForce AI OS on top. You pay him 20% recurring.
5. **Paid (LinkedIn Ads → video case study → audit funnel)** — only after 10+ case studies. Don't burn money here in v1.

### 8.3 Pricing anchors (for your sales page)

| Tier | Setup | Monthly | What's included |
|---|---|---|---|
| **Starter** | £3,500 | £800 | 3 agents (Sales dept), dashboard, standard integrations |
| **Growth** | £7,500 | £1,500 | Full 9 agents, dashboard, all integrations, voice training |
| **Scale** | £15,000 | £3,000 | 9 agents + 2 add-ons, priority support, quarterly strategy |
| **Enterprise** | from £50,000 | from £5,000 | Custom, white-label, on-prem option, SLA |

Offer founding-client pricing (–40%) for the first 5 clients in exchange for a case study. These become your proof.

---

## 9. The IP strategy — what makes this defensible

At the surface level, anyone can copy the 9 agents. Here's what they can't copy, in order of durability:

1. **Case studies with named UK enterprise clients (Rigby Group divisions)** — the single most moat-y asset. Nick cannot get these. Your family network can.
2. **Vertical context libraries** — every dental client you onboard improves your dental voice profile, your dental SOP templates, your dental integration library. Network effect per-vertical.
3. **The Configuration Center as code** — repo, not just an idea. Hard to replicate well.
4. **OpenClaw as platform positioning** — UK-sovereign story that is genuinely differentiated. Keep contributing to it; it's your "infra" credibility angle for VC conversations / Sovereign AI fund applications.
5. **Brand + distribution** — the Ian-Gadzhi-style personal brand content, your UK-market focus, the aesthetic. Harder to replicate than code.

**Register as IP where you can:**
- UK trademark on "IntelForce AI OS" (~£170, file yourself via IPO gov.uk)
- Software copyright is automatic under UK law — keep repo private and keep commit history
- Consider a provisional patent on the Configuration Center orchestration method if it's genuinely novel by v2 (talk to an IP solicitor once revenue justifies the £3–5k spend)

---

## 10. Risks and reality checks

Being honest so you don't get blindsided:

### 10.1 Technical risks

- **Claude Code CLI runtime gambit** — already covered. Don't do it.
- **OpenClaw instability** — you're still fixing config issues. Treat OpenClaw as v2, not v1 runtime. Build on boring reliable stack first.
- **Integration fragility** — MCP is still early, some tools have poor APIs (R4/Sensei is a nightmare). Budget 2x the integration time you think you need.
- **Model cost inflation** — price your retainers assuming a 20% token-cost buffer. Use Haiku/Kimi for batch work aggressively.

### 10.2 Business risks

- **You try to build everything** (voice + SEO + ads + HR + custom) — this kills you. **Ship 9 agents. Nothing else until month 4.** Write this on your wall.
- **Scope creep from one client** — a client asks for "one little thing". You build it custom. Three weeks gone. Never build one-off custom agents. Put every custom request into the add-on roadmap with "available in Q3".
- **Hiring the wrong dev** — if the "guy you have" hasn't shipped production multi-tenant SaaS before, he will be slower than you think. Interview him with a real spec (give him the Proposal Builder agent to build in a week as a trial).
- **Support burden** — with 20 live tenants, you will spend 15 hours/week on support by default. Build monitoring + self-healing from week 1. Hire a junior ops person at client #15.

### 10.3 The thing that will actually kill this

**Not shipping.** Spending the 2-3 months planning, designing, iterating the dashboard UI, tweaking the OpenClaw config, and ending with zero paying clients.

Force yourself to onboard one friendly client at week 6 (half-built, half-manual behind the scenes). Their pain will teach you more than any plan.

---

## 11. The 30-day kickoff checklist

Print this. Do it this week.

**Legal/Admin**
- [ ] Register IntelForce AI OS trademark (UK IPO, £170)
- [ ] Get public liability + professional indemnity insurance (~£400/yr)
- [ ] Draft MSA + DPA templates (hire a solicitor for £500–800, Rocket Lawyer template is a starting point)
- [ ] Decide on entity — keep it under Intel Force Ltd, or spin up a subsidiary?

**Technical foundation**
- [ ] Set up GitHub org with private repos
- [ ] Register domain (intelforce.ai or intelforce.os — check availability)
- [ ] Spin up: Vercel (dashboard), a UK VPS (Hetzner UK / UpCloud for sovereignty story), Supabase (EU region), Stripe
- [ ] Apply for Anthropic API + get approved for higher rate limits (apply via Claude for Startups if eligible, you'd already applied for Claude for Open Source)

**Product**
- [ ] Write v1 prompts for all 9 agents (do this yourself, in Claude Code, using your Max sub — this is the highest-leverage thing you can do this week)
- [ ] Spec the Configuration Center wizard as a Figma flow
- [ ] Decide on brand palette + typography (lock it, don't redesign in week 4)

**Team**
- [ ] Interview the dev — give him a 1-week paid trial building the Proposal Builder
- [ ] Decide whether Jack is partner, co-founder, or channel partner — write it down
- [ ] Line up one friendly pilot client (a dental practice you know) — verbal commit, not signed yet

**Sales**
- [ ] Record the "Visual Blueprint" demo using the prototype delivered with this plan
- [ ] Write the cold outbound email for dental practices (one version only — you'll A/B after 50 sends)
- [ ] Book 5 discovery calls this month

---

## 12. Final note

You are not building Nick Puru's offer. You are building the UK enterprise version of it, on top of OpenClaw-as-sovereign-infrastructure, with the Rigby Group as your trojan horse into mid-market. That's a fundamentally better business than what he's selling — *if* you ship.

The single sentence to repeat to yourself when you start building a 10th agent, or redesigning the dashboard for the third time, or going down an OpenClaw debugging rabbit hole:

> **Nine agents. One dashboard. Seventy-two hours. Ship it.**

Everything else is year two.
