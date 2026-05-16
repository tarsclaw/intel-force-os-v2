---
name: gtm-execution
description: Customer acquisition, prospecting, demos, outreach, pricing conversations, and commercial motion for Intel Force OS. Use this skill when working on landing page copy, outreach messages, demo scripts, prospect tracking, pricing objection handling, first-customer onboarding, case studies, LinkedIn posts, or any customer-facing commercial activity. Also triggers on: prospect, customer, demo, pitch, outreach, LinkedIn, pricing, MRR, ARR, ICP, Sarah Chen, Rigby Group, the first customer.
---

# GTM Execution Skill

This skill is active when working on commercial motion — getting from 0 to 3 paying customers and beyond.

## Where the GTM spec lives

Pack 8: `docs/gtm-pack/`

| File | When to use |
|---|---|
| `README.md` | 30-day execution plan overview |
| `01-demo-script.md` | Recording demos or doing live demos |
| `02-landing-page-hero.html` | Deploying/updating intelforce.ai |
| `02-landing-page-hero-notes.md` | Deployment notes, copy rationale |
| `03-prospecting-framework.md` | Defining ICP, finding prospects |
| `03-prospect-tracker-template.csv` | Tracking prospects |
| `04-outreach-templates.md` | Every outreach message starts from here |
| `05-manual-service-runbook.md` | First-customer service delivery |
| `06-pricing-sheet.md` | Pricing conversations, objections |

Also cross-reference Pack 5: `docs/phase-5-business-legal/` for legal (MSA, SLA, DPA templates), pricing spec, brand identity.

## The commercial reality right now

- **0 paying customers**
- **Target: 3 customers live by month 3, £1,200 MRR**
- **Customer acquisition cost goal: <£500 (manual outreach; no paid ads)**
- **Average deal cycle: 2-3 weeks from first contact to installed**

## The ICP (Ideal Customer Profile)

**Sarah Chen archetype** — 32-year-old HR Lead at a 20-200 employee UK SME on Microsoft 365. Handles 15-30 HR messages daily. Uses Breathe HR. 7 years HR experience. Sceptical of AI; the "nothing sends without you" promise is what converts her.

Full detail: `docs/gtm-pack/03-prospecting-framework.md`

### ICP criteria (all four must be true)

1. **Company size:** 20-200 employees
2. **Geography:** UK
3. **Tech stack:** Microsoft 365 (Teams deployed)
4. **HR maturity:** has a dedicated HR Lead or HR-savvy Operations Manager; uses a formal HRIS (Breathe HR ideal, BambooHR / PeopleHR acceptable)

### ICP disqualifiers (any one = walk away)

- Non-M365 (Google Workspace, Slack-only)
- No HR function at all (too small)
- Enterprise (>500 employees — we're not ready)
- Regulated industry requiring specific certifications we don't have (financial services, healthcare, defence)
- "Need it for legal/compliance only" — wrong buyer

## The outreach motion

### Templates (use verbatim, then personalise)

Every outreach message starts from `docs/gtm-pack/04-outreach-templates.md`. There are 10 variants:

1. LinkedIn connection request
2. Post-connect DM
3. Cold email
4. First follow-up (day 3)
5. Second follow-up (day 7)
6. Third follow-up (day 14 — "closing the loop")
7. Reply to "not right now"
8. Reply to "we use X tool"
9. Reply to "send me info"
10. Reply to "interested — when can we talk"

**When composing new outreach:** start from the closest template, adapt minimally. Don't invent new messages from scratch.

### Cadence

- **Week 1 of outreach:** 10-15 prospects via LinkedIn + email
- **Follow-ups:** automated via templates above; manual personalisation
- **Response rate target:** 15% reply rate, 5% demo rate
- **Demo-to-close rate target:** 30-40% (high because it's a warm pitch)

### Daily commercial activities (non-negotiable during acquisition phase)

- **Monday:** batch send 10 new outreach messages
- **Tuesday:** follow-ups from last week; demo prep if demos booked
- **Wednesday:** demos (typically 2-3 per week)
- **Thursday:** demos + prospect conversations
- **Friday:** weekly review, pipeline update, plan next week

**If 3 consecutive days have zero prospect activity, something has drifted.**

## The demo

Script: `docs/gtm-pack/01-demo-script.md`

### The three-scenario demo (~8 minutes)

1. **Simple policy question** (2 min) — show the "green path"
2. **Semi-complex question** requiring handbook retrieval (3 min) — show depth
3. **Escalation (grievance language)** (3 min) — the money shot, proves governance

### The flow

- Open: "I'll show you how Intel Force OS handles three common HR messages in the way Sarah Chen's day actually works."
- Demo the three scenarios live (prepared dev tenant)
- Close: "So here's what a week looks like for you with Intel Force OS..."
- Q&A

### Demo dev tenant setup

You need a Microsoft 365 Developer Program sandbox tenant (free, 90-day renewable) with:
- A fake "Acme Consulting Ltd" company
- Fake "Sarah Chen" HR Lead account
- Fake "Jordan Rivera" employee account
- Intel Force OS installed
- Sample handbook indexed in Relevance AI
- The 3 demo questions pre-tested

Never demo from a production tenant with real customer data.

## Pricing

Full spec: `docs/phase-5-business-legal/pricing-spec.md`  
Quick sheet: `docs/gtm-pack/06-pricing-sheet.md`

### Tiers (as of April 2026)

| Tier | Price | Who it's for | Limits |
|---|---|---|---|
| **Founding** | £400/month flat | First 10 customers (early adopter) | HR agent only, 12-month price lock |
| **Starter** | £450/month | Post-founding SMEs | One agent, <100 employees |
| **Growth** | £1,800/month | Multi-agent SMEs | All agents, <300 employees |
| **Scale** | £4,500/month | Larger mid-market | All agents + custom, <1,000 employees |
| **Enterprise** | £10,000+ bespoke | Large orgs | Per-agreement |

### Common objections and scripts

Don't invent responses; use the scripts in `docs/gtm-pack/06-pricing-sheet.md`:

- **"Too expensive"** → script in §3.1 (pivots to ROI vs part-time HR assistant)
- **"We'll try ChatGPT instead"** → script in §3.2 (governance argument)
- **"Let me think about it"** → script in §3.3 (time-boxed follow-up)
- **"Can you go lower?"** → script in §3.4 (annual discount available at 15%, no tier discount for founding)
- **"Our HR team is resistant"** → script in §3.5 (positions as AI assisting not replacing)

### What NOT to do on pricing

- Don't discount the Founding tier below £400 — destroys the anchor
- Don't offer a free trial beyond 14 days (discipline customers to value it)
- Don't add seats-based pricing — confuses the £400 flat proposition
- Don't include custom development in any standard tier

## First customer onboarding

Service runbook: `docs/gtm-pack/05-manual-service-runbook.md`  
Technical install: `docs/teams-hr-agent/04-deployment-guide.md`

The first 72 hours after install are critical:
- Check every AI draft manually
- Daily customer check-in
- Retune prompts aggressively based on feedback
- Capture quotable moments for case study

Full weekly rhythm in §2 of the service runbook.

## Writing commercial copy

### Tone guide (applies to all customer-facing copy)

From `docs/phase-5-business-legal/brand-identity.md`:

- **Direct, not corporate.** "We flagged this" not "The system has identified..."
- **Trust-building, not hype.** "Drafts every reply. Sends nothing without you." beats "Revolutionise HR with AI."
- **British English.** Colour, organise, favour, summarise.
- **Avoid "just".** "Just click here" sounds diminutive.
- **Human voice in everything.** Even error messages feel like a person wrote them.

### Subject lines that work

From `docs/gtm-pack/04-outreach-templates.md` analysis:
- "Intel Force OS — HR drafts for [company]" (43% open rate in pilot)
- "Does [HR Lead first name] have 2 minutes?" (38%)
- "Built for UK SME HR — want a look?" (35%)

### Subject lines that don't
- Generic AI/productivity subjects (<15%)
- Curiosity gaps ("This changes HR forever...") — dismissed as marketing
- Fake urgency ("Last chance...") — unprofessional for SME buyers

## Landing page (intelforce.ai)

Spec: `docs/phase-5-business-legal/landing-page-spec.md`  
Hero HTML: `docs/gtm-pack/02-landing-page-hero.html`

The hero block is shippable today. Deploy it even if you don't have the rest of the page. An incomplete landing page that clearly says what Intel Force OS is beats a complete page you've been procrastinating on.

### The one essential element

Every landing page iteration must keep:

> **Drafts every reply. Sends nothing without you.**

Under that: one video (demo Loom), one CTA (book a demo). Everything else is optional.

## Case study construction

First case study template: `docs/phase-5-business-legal/sales-and-case-study-playbook.md` §4

Elements to capture during first customer's week 1-4:
- Baseline: "before Intel Force OS, HR Lead spent X hours on HR messages"
- Implementation: "took 45 minutes to set up"
- Week 1 metrics: messages handled, approval rate, time saved
- Month 1 quote: "What's changed for you in the last month?"
- Month 3 reference-ability: "would you talk to a prospect for 15 min?"

Don't wait for "perfect" metrics; ship case study at month 1 with whatever you have.

## The Agency Partner play

Mentioned in: `docs/phase-0-strategic/strategic-plan.md` + `docs/phase-5-business-legal/pricing-spec.md` §5

Rigby Group-style opportunity: sell Intel Force OS to a group company (SCC, Allect, Eden Hotel Collection) via your existing relationship. One deal could equal 5 standard customer deals.

- Pricing: bespoke, typically £3,000-£8,000/month across multiple group entities
- Structure: Intel Force OS serves group entities but Rigby/parent has central visibility
- Tech: requires the Agency Partner Portal from Phase 4 (deferred) OR manual delivery in interim

Don't build the Phase 4 portal before closing the deal. Run it manually if Rigby Group commits.

## The commercial invariants

1. **Never sell to a disqualified ICP** — time sink with low close rate
2. **Never undercut Founding tier price** — £400/month is the floor, ever
3. **Never promise features not yet built** — confirmed product only
4. **Never skip the 72-hour hand-holding** for a new customer
5. **Always close for next step** on every call — demo → install, install → renewal, etc.
6. **Always capture customer quotes** — they're the best marketing asset you have

## When to push back (against yourself)

- If you're about to spend a day writing landing page copy instead of outreach, stop. Ship the existing copy and do outreach.
- If you're about to negotiate a £300/month deal "to get the first customer," stop. The customer who won't pay £400 won't pay £450 later. Walk.
- If you're about to build a feature for one prospect's specific ask, stop. Ship the v1 product; decline if they need something that's not in the roadmap.
- If you're about to defer outreach "until the product is better," stop. The product is good enough. Outreach today.

## The honest state of the GTM work

The GTM pack is built and good. What's missing is execution volume. Specifically:
- LinkedIn outreach: needs to happen daily, not "when I feel like it"
- Demo recordings: need 3 variations recorded (one per ICP sub-segment)
- Case study: requires first customer, which requires outreach

**The GTM bottleneck is effort, not artefacts.**
