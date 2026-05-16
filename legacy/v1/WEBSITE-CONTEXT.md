# Intel Force OS — Website Context Pack

**Single source of truth for rebuilding intelforce.ai. Self-contained — does not reference other files. Hand this to a fresh Claude Code session and it has everything it needs to build the site.**

---

## 0. How to use this file

This file contains:
1. The business — what we are, who we serve, what we sell
2. The brand — name, voice, visual identity, things we never say
3. The site — page-by-page structure, copy, CTAs, conversion logic
4. Trust & legal — security claims, footer content, jurisdictions
5. The build — stack, deployment target, performance budget, analytics
6. The hero animation — camera/cinematic direction (see §28)

If something here contradicts older copy in `docs/gtm-pack/02-landing-page-hero.html` or `docs/phase-5-business-legal/`, **this file wins** — it represents the current intent.

---

## 1. The company

### 1.1 Legal entity
- **Company:** Intel Force Ltd
- **Jurisdiction:** Registered in England and Wales
- **Registered address:** [TODO — registered address goes in footer]
- **VAT status:** [TODO — confirm at time of build; if registered, add VAT number to footer]

### 1.2 Founder
- **Maddox Rigby** — sole founder, builds and sells. Email: `madsrigby@outlook.com` (personal); customer-facing should be `hello@intelforce.ai`.
- Founder-led sales for the first 10 customers. No sales team.

### 1.3 Operating mode (today)
- **Stage:** pre-revenue, fully built product, no live customers.
- **Sales model:** founder-led, manual onboarding, founding-customer cohort of 10.
- **Domain:** intelforce.ai is the primary. Keep `intelforce.co.uk` as a fallback alias if owned.

### 1.4 Trading-name decision (open)
The brand-identity spec recommends renaming the product to **Clawd** for commercial launch — punchier, available, free of trademark conflicts (intelforce.org is an active cybersecurity company; "IntelForce GPT" exists in the ChatGPT store). The current build, copy, and domain still use "Intel Force OS". If/when renamed, Intel Force Ltd remains the legal entity and "Clawd" becomes a trading name.

**For this rebuild: assume "Intel Force OS" unless the founder explicitly tells you to switch.** Both names are valid; Intel Force OS is the shipping name.

---

## 2. The product in one paragraph

Intel Force OS is a multi-agent AI platform for UK SMEs (20–200 employees) and agencies. It operates as a workforce of specialised agents — HR, proposals, content, follow-up, lead research, reporting — that draft work end-to-end from real triggers (a sales call ending, a message arriving, a deal closing). Every output is a draft. Nothing leaves the customer's account without a human approving. The wedge is HR (the active build target — first agent in production); the platform is the full ten-agent suite.

---

## 3. Positioning

### 3.1 Category
Not a chatbot. Not a workflow tool. **A managed agent workforce.** Priced and pitched against headcount, not against SaaS.

### 3.2 Headline positioning statements
- **One-liner:** "The agents that do your operations — drafts, leads, content, follow-up, reporting — while you handle the bits humans are for."
- **For HR-first prospects (current wedge):** "Your HR inbox, handled."
- **For agency prospects:** "Your team's shadow workforce."
- **Three-word promise:** "Draft. Review. Send."

### 3.3 The three differentiators (hammered everywhere)
1. **It uses your data.** Every agent starts with what you already wrote — past proposals, your brand voice, your handbook. Not a generic template with your name pasted in.
2. **It runs on triggers, not prompts.** A call ends, an email arrives, a deal closes — Intel Force OS notices and produces a draft. You don't type anything. Automation, not assistance.
3. **It escalates when uncertain.** When the data is weak, the policy unclear, or the output might embarrass you, it stops and asks. Honest uncertainty, not false confidence.

### 3.4 The non-negotiable invariant (lead with this on every page)
**Everything drafts, nothing sends without human approval.**
- Applies to every agent across every tenant.
- The only auto-sent messages are holding replies for escalations ("a human will respond shortly").
- Sensitivity ≥ 0.7 always routes to human-only handling — no AI draft offered.

### 3.5 What we are not
- Not "AI-powered" anything (banned phrase — see voice rules)
- Not autonomous agents that act unsupervised
- Not a chatbot widget bolted onto your site
- Not a productivity app for individuals (we sell to companies, not seats)
- Not a developer platform — the customer is an HR/Ops/Agency operator, not an engineer

---

## 4. Audience

### 4.1 Primary ICP — current wedge (HR)
| Attribute | Spec |
|---|---|
| Country | UK only (England/Scotland/Wales/NI) |
| Headcount | 20–200 employees |
| HR system | Breathe HR (preferred) or BambooHR / PeopleHR / CharlieHR |
| Persona | 1 dedicated HR person OR Ops/Office Manager doing HR |
| Industry | Professional services, tech/SaaS, agencies, healthcare (non-NHS), manufacturing |
| Revenue | £1M–£20M |
| Buying signal | Recent HR hire, recent HR-tool purchase, LinkedIn post about being overwhelmed |

**Archetype prospect:** Sarah Chen, People & Operations Manager at a 65-person Manchester tech consultancy on Breathe HR. Joined 18 months ago, posts occasionally about "wearing many hats," reports to the COO, gets the same twelve HR questions a week. Take her 30 minutes and she'll book.

### 4.2 Secondary ICP — agency operators
Small-to-mid agencies (£300k–£10M revenue), principal-led, with repeatable workflows (proposals, content, reporting, follow-up). Buyer is the founder/MD or COO, not a marketing manager.

### 4.3 Anti-ICP (do not market to, do not optimise the page for)
- <20 employees — not enough volume to justify pricing
- \>500 employees — they have Workday/HiBob and won't consider us
- NHS / public sector — 9–18 month procurement cycles
- US/international — we can't service across timezones in v1
- Recruitment agencies — different workflow
- Companies where the CEO is the HR lead — won't adopt a tool for their own work
- Heavily regulated (law firms, big finance) — need compliance evidence we don't yet have

### 4.4 Visitor segments (in order of volume)
1. **Cold inbound** — found us via outreach, podcast mention, referral
2. **Warm inbound** — heard the founder talk about it, came to verify we're real
3. **Signed-off buyers** — already decided, here to confirm the company exists
4. **Existing customers** — looking for support links / status

Segments 1 and 2 are the conversion targets. Segment 3 converts by not putting obstacles in their way. Segment 4 needs footer/nav discoverability.

---

## 5. The product — what we actually sell

### 5.1 The ten agents
| # | Agent | What it does | Tier from |
|---|---|---|---|
| 1 | **HR Agent** | Reads inbound HR messages, drafts replies from the handbook, escalates anything sensitive | Starter (current wedge) |
| 2 | **Proposal Builder** | Drafts proposals from sales-call transcripts (Fathom etc.) using your pricing and voice | Growth |
| 3 | **Lead Hunter** | Finds prospects matching your ICP across Companies House + Prospeo + Kaspr | Growth |
| 4 | **Client Onboarder** | Runs the first-week welcome sequence — kickoff packet, agenda, access checklist | Starter |
| 5 | **Content Creator** | Drafts long-form articles in your brand voice with cited sources | Growth |
| 6 | **Repurposer** | Turns one long-form asset into 8 derivatives — email, X, LinkedIn, YouTube description | Growth |
| 7 | **Caption Writer** | 3–5 caption variants for visual assets in your voice | Starter |
| 8 | **Follow-Up Pilot** | 21-day nurture sequences for unconverted enquiries | Growth |
| 9 | **Reporting Engine** | Pulls monthly client reports from your data | Starter |
| 10 | **SOP Writer** | Turns a screen recording into a written, versioned SOP | Scale |

Plus the **Librarian** — runs nightly behind the scenes, keeps the vault tidy so every other agent retrieves cleanly. Hidden from the marketing page (we don't sell vault tagging to a customer; we sell the work it makes possible).

### 5.2 What every agent has in common
- Reads your data (vault: handbook, voice profile, past work)
- Draft-only output — no agent has send-to-external-recipient permission
- Escalates with a named code when uncertain
- Logs every action in an auditable trail (7-year retention)

### 5.3 Integrations (current and supported)
- **Microsoft Teams** (primary delivery surface for HR Agent)
- **Breathe HR** (HR Agent — handbook + employee context)
- **Fathom / Otter.ai** (Proposal Builder — call transcripts)
- **HubSpot** (deal triggers, contact data)
- **Gmail / Microsoft 365** (inbound messages, draft outputs)
- **Stripe** (Reporting Engine, billing)
- **GA4** (Reporting Engine)
- **Slack** (notifications, Slack-side approval channel)

---

## 6. Brand identity

### 6.1 Name
- **Product name in current copy:** Intel Force OS
- **Recommended commercial name (open decision):** Clawd
- **Legal entity:** Intel Force Ltd (unchanged regardless of trading name)
- For this build: use **Intel Force OS** unless the founder explicitly switches.

### 6.2 Tagline options (designer/A-B choice)
Hero-eligible:
- "Draft. Review. Send." — describes the contract in three words
- "Your HR inbox, handled." — current HR-wedge hero
- "The agents that actually ship." — contrast against demo-ware AI
- "Your team's shadow workforce." — agency positioning
- "Runs your operations while you sleep." — UK B2B-services fit

Recommended primary: **"Draft. Review. Send."** for the platform site; **"Your HR inbox, handled."** if the rebuild is HR-only.

### 6.3 Colour palette
Same tokens as the dashboard — single source of truth, no separate "marketing palette".

| Token | Hex | Use |
|---|---|---|
| Emerald 500 (primary) | `#10b981` | Primary buttons, accent text, brand mark |
| Emerald 400 | `#34d399` | Hover states, gradient companion |
| Emerald 600 | `#059669` | Pressed states |
| Amber 500 (secondary) | `#f59e0b` | Attention, warning, "needs you" indicators |
| Amber 400 | `#fbbf24` | Lighter accent |
| Anchor / bg | `#09090b` (or `#0a0a0a`) | Body background — dark mode default |
| Bg elevated | `#141414` | Cards, panels |
| Border | `#262626` | Hairlines |
| Neutral 200 | `#e5e5e5` | Body text |
| Neutral 400 | `#a3a3a3` | Secondary text |
| Neutral 500 | `#737373` | Tertiary text |

**Dark mode is the default.** Most B2B SaaS pages are white; dark signals technical sophistication and product-led identity. White-mode optional later, not v1.

### 6.4 Typography
- **Headline & body sans:** Inter (variable, weights 400/500/600/700) — load via `@next/font` or Google Fonts with `display: swap`
- **Mono accent:** JetBrains Mono — used for trust microcopy ("UK-based · GDPR-ready · …") and code-like labels
- **No serif fonts on the marketing site.** (The dashboard uses Fraunces in places; that's a product touch, not a brand touch.)

### 6.5 Imagery rules
- **Yes:** screenshots of the actual product, schematic diagrams, type-heavy hero compositions, restrained abstract patterns in palette colours, real-customer photography (when we have customers).
- **No:**
  - Stock photos of people in offices
  - Staged handshakes, laptops-open-in-cafés
  - AI-cliché gradients (purple-to-pink, neon)
  - Animal mascots, paw imagery (we are not a pet app)
  - Beer-label logo aesthetics (badges, stamps, ribbons)

### 6.6 Iconography
- **Lucide icons** throughout. No custom set. Stroke width 1.5–2px.
- One custom SVG allowed (a `HandshakeIcon` from the dashboard design system).
- Icons used in nav, agent cards, "how it works" steps, security checklist.

### 6.7 Voice & tone (enforced everywhere)
**Voice pillars:**
- **Direct.** "Intel Force OS runs your agents. You review what it produces."
- **Specific.** Numbers, examples, named features. "Drafts a proposal 4 minutes after the Fathom call ends," not "save time."
- **Honest about limits.** "Nothing sends without you." Not "Fully autonomous workforce."
- **Quiet confidence.** No hype superlatives.
- **British English.** "Optimise", "behaviour", "catalogue", "personalise".

**Banned phrases (zero exceptions):**
- "AI-powered" — implicit and dilutive; say what it does
- "Revolutionary", "cutting-edge", "game-changing", "unleash your potential"
- "Leverage" (as a verb)
- "In today's fast-paced world…"
- Generic SaaS exclamation: "Save time! Boost productivity! 🚀"
- "Users" — they're customers, tenants, or operators

**Punctuation rules:**
- No exclamation marks in body copy. (Allowed in transactional UI: "Tenant live!" is fine.)
- One em-dash per paragraph maximum
- Serial comma — yes (improves readability)
- Verbs up front: "Draft. Review. Send." not "Drafting, reviewing, and sending simplified"

**Two examples of the same message in three voices:**

❌ Generic SaaS:
> 🚀 Revolutionise your agency with AI-powered workflow automation! Our cutting-edge platform leverages advanced artificial intelligence to save you countless hours every week.

❌ Bro-founder:
> Ship faster. Stop wasting time on proposals. We built the thing that finally works.

✅ Intel Force OS:
> A sales call ends at 4:47 PM. By 4:51, Intel Force OS has drafted the proposal — with your pricing, your voice, and the specific objections raised on the call. You read it, adjust two lines, send. Your 9 PM is freed up.

### 6.8 Naming conventions inside copy
| Thing | Canonical form |
|---|---|
| Company legal name | Intel Force Ltd |
| Product name | Intel Force OS |
| Individual agents | Title Case — Proposal Builder, Lead Hunter, etc. |
| The customer's deployment | "your Intel Force OS" (informal) or "your tenant" (technical) |
| Agent runs | "runs" (customer-facing), "invocations" (internal) |
| The vault | "Brain" (customer-facing), "vault" (technical) |
| Sensitive flagging | "escalations" |

---

## 7. Site structure

### 7.1 Routes
```
/                      Home (this is the headline page)
/product               Deeper agent-by-agent walkthrough
/pricing               Tier comparison + FAQ
/for-agencies          Agency-partner positioning subpage
/case-studies          Empty at launch; populated when first study ships
/security              Abridged DPA / TOMs for procurement DD
/docs                  Public subset of customer docs
/blog                  Empty; one founder note as first post
/contact               Form + email + calendar link
/privacy               Privacy Policy
/terms                 Terms of Service
/aup                   Acceptable Use Policy
/login                 Redirect to dashboard auth
/status                Redirect to status.intelforce.ai
```

### 7.2 Top navigation (5 items maximum)
- **Product** (dropdown: Agents, For Agencies, How it works)
- **Pricing**
- **Customers** (placeholder; renames to "Case Studies" when first one is live)
- **Docs**
- Right side: **Sign in** + **Start trial** (primary CTA)

### 7.3 Footer (multi-column)
- **Product:** Agents · Pricing · Security · Status
- **Company:** About · Blog · Contact
- **Resources:** Docs · Changelog · API reference
- **Legal:** Privacy · Terms · AUP · DPA (sample)
- **Bottom row:**
  - "© 2026 Intel Force Ltd. Registered in England and Wales."
  - Registered office address
  - Contact emails: hello@intelforce.ai · support@intelforce.ai · security@intelforce.ai
  - Social links: X, LinkedIn

---

## 8. Home page — section by section

Target vertical scroll: ~2,400px desktop, 6–7 screen-heights. Every section must earn its place.

### Section 1 — Hero (above the fold)

**Status badge (small, top of hero):**
`● Onboarding founding customers — 10 places`
(Pulsing emerald dot. Remove badge once 7+ founding customers signed.)

**H1 (headline):**
> **Draft. Review. Send.**
>
> *Or, for the HR-only variant:* **Your HR inbox, handled.**

**Subhead:**
> The agents that do your agency's operations — drafts, leads, content, follow-up, reporting — while you handle the bits humans are for.
>
> *Or, for HR-only:* An AI assistant that reads every HR message, drafts every reply, and flags what needs your judgement. Built for UK SMEs on Breathe HR.

**Primary CTA:** `Start 14-day trial →` (or `Book a 30-minute call` for HR-wedge)
**Secondary CTA:** `Watch 3-min demo` (scrolls to embed) or `Book a demo`

**Trust microcopy under CTAs (mono font, neutral-500):**
`UK-based · GDPR-ready · Built on Claude · Nothing sends without you`

**Visual:** real screenshot of the dashboard's Operations Control view showing demo data — multiple escalations visible, cost panel showing healthy numbers, one agent running. **No abstract gradient hero.** A screenshot.

### Section 2 — Demo embed (Loom)

```
See it in action
Three real scenarios in three minutes.

[Loom embed — 16:9, bordered, dark background]
```

The Loom video is the founder's 3-minute walkthrough. Currently scripted in the GTM pack — replace placeholder ID `REPLACE_WITH_LOOM_VIDEO_ID` with the live one.

### Section 3 — Social proof bar (slim)

**Recommendation: omit at launch.** Empty logo strips look worse than no logos. Add it the moment we have 3 logos with permission.

If we need to fill the space: a single line in mono — `Built in the UK. Hosted in the UK. Answering to the UK.` — but only if visual rhythm demands it.

### Section 4 — How it works (3-card)

```
How Intel Force OS works
One principle, three behaviours.

01  Reads everything
    Every message that hits your HR inbox — holiday questions, policy
    asks, payroll queries, the lot. No rules to maintain, no keyword
    filters to tune.

02  Drafts every reply  [highlighted as "core"]
    Pulls from your actual handbook and company tone. You see every
    draft before anything leaves your name. Approve, edit, or reject
    — one click.

03  Flags what needs you
    Grievances, resignations, anything sensitive — escalated to you
    immediately with a gentle holding reply. The judgement calls
    stay yours.
```

For the platform-wide version (not HR-only):

```
01  Plug in your tools.
    Fathom, HubSpot, Gmail, Stripe, Microsoft 365. Whatever you
    already use. Intel Force OS listens.

02  Agents do the work.   [highlighted]
    A sales call ends. Intel Force OS drafts the proposal. A blog
    post goes live. Intel Force OS repurposes it into eight
    variations. A prospect goes quiet. Intel Force OS drafts the
    follow-up.

03  You review and send.
    Everything Intel Force OS produces is a draft. You approve what
    goes out. Humans stay in charge of every decision that reaches
    a client.
```

Icons (Lucide): `Plug`, `Loader` (or `Bot`), `Send`. Bold first line per card; explanation in neutral-400.

### Section 5 — The agents grid

```
Ten agents, working together.

[3 × 3 grid of cards — each card has: icon, agent name, one-line description]

Proposal Builder       Lead Hunter           Client Onboarder
Drafts proposals       Finds prospects       Runs first-week
from sales-call        matching your ICP     welcome sequences
transcripts.           across LinkedIn,      for new clients.
                       web data, CRM.

Content Creator        Repurposer            Caption Writer
Drafts long-form       Turns one asset       Writes social
articles from your     into eight: email,    captions in your
brand voice.           X, LI, YouTube...     voice for posts.

Follow-Up Pilot        Reporting Engine      SOP Writer
Drafts follow-ups      Pulls monthly         Turns a screen
for prospects who      client reports        recording into a
went quiet.            from your data.       written SOP.

(+ Librarian — keeps everything tidy behind the scenes)

[See all agents →]   (links to /product)
```

Each card links to `/product#agent-slug` for the deep version.

### Section 6 — Why Intel Force OS (differentiators)

Three stacked panels, one paragraph each. Addresses "why not just use ChatGPT?" head-on.

```
Why Intel Force OS (not a chat window)

┌─────────────────────────────────────────────────────────┐
│  It uses YOUR data.                                     │
│                                                         │
│  Every agent starts with what you already wrote — past │
│  proposals, your brand voice, your services. Not a     │
│  generic template with your name pasted in.            │
│                                                         │
│  → Your writing, at scale.                              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  It runs on triggers, not prompts.                      │
│                                                         │
│  A sales call ends. An email arrives. A deal closes.   │
│  Intel Force OS notices and produces a draft — you     │
│  don't type anything. It's work happening, not a tool  │
│  you use.                                               │
│                                                         │
│  → Automation, not assistance.                          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  It escalates when it's uncertain.                      │
│                                                         │
│  When the data is weak, the policy is unclear, or the  │
│  output might embarrass you — Intel Force OS stops and │
│  asks. Not every agent vendor will tell you that.      │
│                                                         │
│  → Honest uncertainty, not false confidence.            │
└─────────────────────────────────────────────────────────┘
```

Pull-quote line at end of each panel in emerald accent.

### Section 7 — Pricing teaser

Single highlighted card. Full detail at `/pricing`.

```
Pricing that matches what you'd pay for a team.

Growth — £1,800/month
The full agent workforce: 9 agents, 5 integrations, 3 seats.
Less than a week of a junior account manager.

[See all plans →]   [Start 14-day trial →]
```

For the founding-phase wedge (HR-only at £400/mo), use:

```
One price, one product. £400 a month.
Founding-customer rate, locked for 12 months.
Includes everything: agent setup, weekly reports, escalation handling,
Slack access, monthly review calls.

[Book a 30-minute call →]
```

### Section 8 — Security & trust

```
Where your data lives

✓  UK-hosted.   Cloudflare UK/EU edge primary.
✓  Encrypted.   At rest with per-tenant keys; in transit with TLS 1.3.
✓  Isolated.    One customer can never see another's data. Row-level
                security and tenant containers.
✓  Auditable.   Every action is logged. 7-year retention for
                compliance.
✓  GDPR-ready.  Full DPA and Sub-processor list available on request.

[Security overview →]   (links to /security)
```

No exaggerations. Each line corresponds to a real architectural choice.

### Section 9 — For agencies teaser

Half-width block linking to the agency-partner subpage.

```
Running multiple brands? You need an agency partner account.

A portfolio view across all your sub-brands. Roll-up billing.
Shared team. Onboarding queue. Built for agencies from day one.

[Agency partner pricing →]
```

### Section 10 — FAQ (compact accordion, 6 questions)

1. **Who is Intel Force OS for?** — UK-based agencies, professional services firms, and consultancies with repeatable workflows. Not a consumer tool, not a chatbot widget.
2. **Does it replace my team?** — No. It gives them superpowers on the repetitive bits. You still need humans for judgement, relationships, and what Intel Force OS escalates on.
3. **How does it handle our brand voice?** — We extract a voice profile from samples you provide — 5+ pieces of your writing. Every agent references it. Adjustable; improves over time.
4. **Can I trust it not to send something bad?** — "Everything drafts, nothing sends" is our design principle. Intel Force OS writes; you approve. Nothing leaves your account without a human saying yes.
5. **What if the AI makes a mistake?** — It will, occasionally. You're reviewing. Validation hooks on every agent catch common errors before they reach you. And the agent escalates when it's uncertain.
6. **How fast can I go live?** — Growth-tier onboarding is 24–48 hours once your first integrations are connected. Operator-led, so you're not figuring anything out alone.

### Section 11 — Final CTA

```
Ready to see your drafts at 9am tomorrow?

[Start 14-day trial →]   [Book a demo]
```

Or for the founding-phase HR variant:

```
Stop reading twelve of the same questions every week.

Book a 30-minute call. If it's a fit, we'll talk pricing. If not,
you've seen the fastest-improving AI in production — worthwhile
either way.

[Book your call →]

Replies within 24 hours · No sales team · Founder-led
```

---

## 9. /pricing page

### 9.1 Hero
> **Pricing that matches what you'd pay for a team.**
>
> A full agent suite costs less than one junior account manager — and drafts more proposals, more content, more follow-ups, every week.

Toggle: `[Monthly] [Annual (2 months free)]`

### 9.2 Tier cards (current platform pricing — post-founding phase)

| Tier | Price | Headline | Subhead |
|---|---|---|---|
| **Starter** | £450/mo | "For solo operators trying Intel Force OS." | Core agents, one user, enough to prove the model works. |
| **Growth** *(Most Popular)* | £1,800/mo | "The full agent workforce." | Everything most agencies need: drafts, leads, content, follow-up. |
| **Scale** | £4,500/mo | "Productised agency, in a box." | Growth plus SOP Writer, priority support, standards for bigger teams. |
| **Enterprise** | From £10,000/mo | "Custom-fit for regulated or complex deployments." | Dedicated infrastructure, custom terms, custom agents. |

### 9.3 Founding-phase pricing (current actual price — first 10 customers)
**One price. One product. No tiers.**

> **£400 per month.** Billed monthly, cancel anytime. Includes everything: agent configuration, prompt tuning, all of the founder's time, weekly reports, escalation handling, Slack access, monthly review calls. No setup fees. First 10 customers locked at £400/mo for 12 months.
>
> Annual option: **£4,000/year** (~17% discount, effectively 2 months free).

This pricing block appears for the HR-wedge build. Once we cross 10 customers, switch the page to the four-tier grid above.

### 9.4 Feature matrix

| Feature | Starter | Growth | Scale | Enterprise |
|---|---|---|---|---|
| Proposal Builder | ✓ | ✓ | ✓ | ✓ |
| Client Onboarder | ✓ | ✓ | ✓ | ✓ |
| Reporting Engine | ✓ | ✓ | ✓ | ✓ |
| Caption Writer | ✓ | ✓ | ✓ | ✓ |
| HR Agent | ✓ | ✓ | ✓ | ✓ |
| Lead Hunter | — | ✓ | ✓ | ✓ |
| Content Creator | — | ✓ | ✓ | ✓ |
| Repurposer | — | ✓ | ✓ | ✓ |
| Follow-Up Pilot | — | ✓ | ✓ | ✓ |
| SOP Writer | — | — | ✓ | ✓ |
| User seats | 1 | 3 | 10 | Unlimited |
| Integrations | 3 | 5 | Unlimited | Unlimited |
| Agent runs / month | 100 | 500 | 2,000 | Custom |
| Platform cost budget | £150 | £550 | £1,200 | Custom |
| SLA | 99.0% | 99.5% | 99.5% | 99.9% |
| Support | Email, biz hours | Slack + email | Priority | 24/7 + named AM |
| White-label | — | — | Optional | Included |
| Custom agents | — | — | — | Available |
| Dedicated infrastructure | — | — | — | Included |

### 9.5 CTAs per tier
- **Starter:** "Start 14-day trial" → signup
- **Growth:** "Start 14-day trial" → signup (badge: Most Popular)
- **Scale:** "Book a demo" → Cal.com link
- **Enterprise:** "Contact sales" → email form

### 9.6 Pricing-page FAQ (8 questions)
1. What's included in each plan?
2. Can I change plans later? — Yes, any time, pro-rated.
3. What if I go over my usage allowance? — We email; soft caps; overages discussed before any hard stop.
4. How does the 14-day trial work? — Credit card required; auto-converts to paid unless cancelled before day 14.
5. Discounts for annual commitments? — Yes, 2 months free.
6. Agencies managing multiple brands? — Agency Partner pricing — contact us.
7. Can I cancel anytime? — Monthly month-to-month; annual cancellable at next renewal.
8. Is my data safe? — Link to /security and DPA summary.

### 9.7 Footnote (small print under grid)
> Usage-based costs (AI inference, data providers) are included in each tier's budget allocation. Going over the budget triggers a warning, not a bill — you can raise the budget or let us know in support. We never surprise you with a monthly charge.
>
> Prices shown are in GBP, exclusive of VAT where applicable.

### 9.8 Anchor link at bottom
`Agency managing multiple brands? [Agency Partner pricing →]` (links to `/for-agencies`)

### 9.9 What NOT to put on /pricing
- Negative framing ("Starter does NOT include…") — let the tick-mark tell the story
- Countdown timers, "only 3 left" urgency
- Fake discounts (no "was £3,000, now £1,800")
- Hidden fees — disclose every cost component on the page

---

## 10. /product page (deeper agent walkthrough)

One section per agent, each with the same structure:

```
Agent name
What it does (one paragraph)
What it needs (integrations, data, vault files)
What it produces (sample output, blurred or anonymised)
When it runs (triggers — webhook? cron? human request?)
How it escalates (named escalation codes, what they mean)
```

Use Intel Force OS dashboard screenshots wherever possible. Anchor links per agent: `/product#proposal-builder`, etc.

---

## 11. /for-agencies page

### 11.1 Hero
> **One login, every brand.**
>
> Intel Force OS Agency Partner gives you a portfolio view across every sub-brand you manage. Roll-up billing. Shared team. Onboarding queue. Built for agencies from day one.

### 11.2 Sections to include
- **The portfolio view** (screenshot of the agency dashboard)
- **Roll-up billing** (one invoice, allocations per sub-brand)
- **Shared team / per-brand permissions** (how access works)
- **Pricing model:** platform fee (£2k–£5k/mo) + per-sub-tenant at 30–40% off Growth/Scale standalone
- **Worked example** (Rigby Group shape, anonymised): 3 sub-tenants, total ~£8k/mo
- **CTA:** "Talk to us about agency pricing" → contact form

---

## 12. /security page

Procurement-DD-friendly. Abridged DPA Annex A (TOMs). Sections:

1. **Where your data lives** — UK / EU edge; sub-processor list (Anthropic, Cloudflare, possibly Stripe, AWS for backup, Resend for transactional email)
2. **Encryption** — TLS 1.3 in transit; at-rest with per-tenant keys
3. **Isolation** — row-level security, tenant containers
4. **Audit & retention** — every action logged, 7-year retention
5. **Identity & access** — Clerk for auth (or whatever's wired); MFA; SSO available on Scale/Enterprise
6. **Incident response** — published RTO/RPO; breach notification within 72 hours per UK GDPR
7. **Compliance roadmap** — SOC 2 Type II in progress (mention only when in flight); ISO 27001 (later)
8. **Sub-processor list** — table with vendor, purpose, location
9. **Downloads:** DPA template (PDF), Security overview (PDF), Sub-processor list (live page)

Don't claim certifications we don't have. Don't quote SLA % we don't measure yet.

---

## 13. /docs (public subset)

A small, focused subset of the customer dashboard's docs. Topics:
- "What is Intel Force OS" — 1-page overview
- "How agents work" — the draft-review-send model
- "Connecting your tools" — integrations setup at a glance
- "The Brain" — what the vault is, what goes in it
- "Approvals" — how the approval queue works
- "Escalations" — what gets escalated and why

Deep admin topics stay behind login. Public docs are designed to help a prospect kick the tyres.

---

## 14. /blog

Ships empty. First post timed with launch:

**"Why we built Intel Force OS"** — founder note explaining the inbox-tax thesis, why drafts not sends, why HR first.

Second post when the first case study is live. No promised cadence — only post when there's something to say.

---

## 15. /contact

Three things on the page:
1. **Contact form:** name, email, company, message — server-action submission, sends to `hello@intelforce.ai` via Resend, honeypot for spam
2. **Direct emails:** hello@, support@, security@
3. **Calendar booking:** Cal.com (preferred) or Calendly link — events: "15-min intro", "30-min demo"

Plus footer-level address and registered-company info.

---

## 16. Legal pages — what they say

These need solicitor sign-off before going live, but the structure is fixed.

### 16.1 /privacy
- Data controller: Intel Force Ltd
- DPO contact: privacy@intelforce.ai (or security@)
- Lawful bases for processing
- Data we collect (visitor analytics via Plausible — anonymous)
- Data we don't collect (no GA, no Hotjar, no session replay)
- Cookies: only essential ones; no consent banner needed since Plausible is cookieless
- Subject access rights (right to access, rectification, erasure, portability)
- How to exercise rights (email request to privacy@)
- International transfers (Anthropic via UK-US data bridge)
- Retention period
- Last updated date

### 16.2 /terms
Standard SaaS terms — services description, fees, term/termination, IP, warranties (limited), liability cap (fees paid in preceding 3 months), governing law (England and Wales), dispute resolution.

### 16.3 /aup
Acceptable Use Policy — no using Intel Force OS for: spam/cold-call automation against suppression lists, regulated-industry decisions without human review (medical, legal, financial advice), generating content that violates laws, etc.

---

## 17. CTAs and conversion strategy

### 17.1 Primary conversion goals (ranked)
1. **Demo booking** — highest LTV target (Growth/Scale/Enterprise)
2. **Trial signup** — volume path (Starter/Growth)
3. **Contact form / sales inquiry** — Enterprise + agency partner leads
4. **Newsletter signup** — weak; only for visitors not ready to buy

### 17.2 What we are NOT optimising for
- Vanity metrics (time on page, scroll depth)
- Broad SEO (we don't have the budget to win there)
- "Awareness" at the expense of conversion

### 17.3 CTA hierarchy on every page
- **Primary CTA** — solid emerald button, white/dark text, always present in nav and at section-end
- **Secondary CTA** — outlined or ghost, paired with primary
- Repeated 3–4 times on the home page (hero, mid-page, final section)
- Never use "Get Started" (too generic) or "Click here" (banned)

### 17.4 Trial mechanics (when self-serve is live)
- 14-day free trial
- Credit card required at signup (reduces tyre-kickers; Stripe collects but doesn't charge until trial end)
- Auto-converts to paid unless cancelled before day 14
- Starter and Growth are trial-eligible; Scale and Enterprise are demo-first

### 17.5 What's NOT on the page (deliberate omissions)
- Third-party chat widgets (Intercom, Drift) — anti-pattern, dated, analytics we don't want
- Live chat — not resourced for v1
- Pop-up exit-intent modals — destroys trust
- Cookie-hungry analytics — Plausible only
- Social-login buttons — confuses signup vs trial intent
- ROI calculators / interactive tools — distraction from the main CTA
- Testimonials we don't have — leave the section empty rather than fake it
- Logos we don't have permission to use — same

---

## 18. Trust microcopy library

Reusable lines that appear across the site:

- `UK-based · GDPR-ready · Built on Claude · Nothing sends without you` — under hero CTAs
- `14-day trial · Secure UK hosting · GDPR-ready · Cancel anytime` — pricing-page CTAs
- `Replies within 24 hours · No sales team · Founder-led` — final-CTA section (founding phase)
- `No credit card surprises · Soft usage caps · Cancel anytime` — pricing footnote
- `Built in the UK. Hosted in the UK. Answering to the UK.` — alternative to a logo strip

All in JetBrains Mono, neutral-500.

---

## 19. The four-objection framework (lives in microcopy)

Every HR/Ops leader has the same four objections in the first five seconds of seeing the page:

| Objection | Microcopy that pre-handles it |
|---|---|
| "Is this some US startup that'll disappear?" | UK-based |
| "Is this GDPR-safe?" | GDPR-ready / GDPR-compliant |
| "Is this OpenAI junk that hallucinates?" | Built on Claude (recognised premium AI brand among B2B buyers) |
| "Will it send something stupid to my employees?" | Nothing sends without you |

**Always lead with these four under the hero CTAs.** Three seconds of mono text earn the rest of the page.

---

## 20. Technical build

### 20.1 Stack
- **Framework:** Next.js 15, App Router
- **Language:** TypeScript strict
- **Styling:** Tailwind CSS, same tokens as dashboard (share via `packages/ui/` if monorepo)
- **Rendering:** Static generation (SSG) for everything except the contact form (server action)
- **Forms:** Server actions only — graceful JS-disabled fallback
- **Email:** Resend, sender domain `intelforce.ai` (DMARC/SPF/DKIM configured)
- **Calendar:** Cal.com (preferred — open-source, signals alignment) or Calendly
- **Analytics:** Plausible (£9/mo, EU-hosted, cookieless, no banner needed)
- **Auth:** none on the marketing site; `/login` redirects to dashboard's Clerk flow
- **Status page:** `status.intelforce.ai` — Atlassian Statuspage or Better Stack

### 20.2 Repo location
- Separate Next.js app in the monorepo: `apps/marketing/`
- Different deploy cadence from the dashboard (`apps/dashboard/`)
- Different perf budget — the marketing site can aggressive-cache and ship daily; the dashboard ships when needed

### 20.3 Hosting
- **Recommended:** Cloudflare Pages — free at our scale, same provider as our DNS/WAF, simpler vendor footprint
- **Acceptable alternative:** Vercel — fine, slightly nicer DX, not a material difference
- **No Netlify** unless setting up GitHub feels like friction today (you'll need it anyway)

### 20.4 Performance budget
- Lighthouse mobile: 90+ on Performance, Accessibility, Best Practices, SEO
- LCP < 1.5s
- FID < 100ms
- CLS < 0.1
- Hero image: inline-preloaded, WebP/AVIF via `next/image` with explicit width/height
- Fonts: `@next/font` with `display: swap`; no blocking font load
- CSS: Tailwind purge + critical CSS inlined in head
- No JavaScript-dependent CTAs (every link works without JS)

### 20.5 SEO essentials
- Title tag, meta description, OG tags per page
- Sitemap.xml + robots.txt
- Structured data (Organization, Product) on home and product pages
- Canonical URLs for every page
- 404 page that's helpful (links to home, contact, docs)

### 20.6 Security headers
- CSP (strict, no inline scripts unless nonce'd)
- X-Frame-Options: DENY (we are not embeddable)
- Referrer-Policy: strict-origin-when-cross-origin
- HSTS preload
- HTTPS only

---

## 21. Pre-launch checklist

Before flipping DNS to make intelforce.ai live:

- [ ] All sections copy-complete and signed off
- [ ] Legal pages (Privacy, Terms, AUP) reviewed by solicitor
- [ ] Screenshots free of customer data — demo tenant only
- [ ] Mobile responsive tested on iOS Safari + Android Chrome
- [ ] Accessibility: keyboard navigation, screen-reader smoke test, colour contrast pass
- [ ] Core Web Vitals green on PageSpeed Insights
- [ ] All forms tested end-to-end (submit → email received at hello@)
- [ ] Calendar booking flow tested end-to-end
- [ ] Trial signup → Clerk → dashboard flow tested
- [ ] Security headers in place
- [ ] HTTPS + HSTS preload
- [ ] Sitemap.xml + robots.txt
- [ ] OG tags rendering correctly on LinkedIn, X, Slack previews
- [ ] Favicons (all sizes)
- [ ] 404 page
- [ ] Internal link-check (no broken routes)
- [ ] Status page subdomain set up
- [ ] DMARC / SPF / DKIM configured for email sender domain
- [ ] hello@intelforce.ai active and monitored
- [ ] Cal.com event types created and tested
- [ ] Loom demo recorded, unlisted, embedded
- [ ] Plausible analytics installed before traffic flips on
- [ ] Founder reviews on 5 browsers (Chrome, Safari, Firefox, Chrome-mobile, Safari-mobile)

---

## 22. Post-launch iteration

### 22.1 Month 1
- Weekly analytics review (uniques, CTA click-through, demo bookings)
- Log every pre-sales objection a prospect raises; add to FAQ or address in hero
- Replace demo screenshots with real-customer screenshots (anonymised) once first paying customer is live
- A/B test hero headline (2–3 variants) via Plausible goal tracking

### 22.2 Month 3
- First case study live, replacing "Customers" placeholder in nav
- Refreshed copy based on 3 months of sales calls
- Possibly: logo strip if 3+ customers comfortable with usage

### 22.3 Month 6+
- Activate /blog if there's 1h/week consistently for 3 posts
- Revisit hero copy with hindsight on what converts
- Add 90-second product video if the founder can record cleanly

---

## 23. Open decisions the rebuild may surface

- **OD-W-1:** Is the brand name still "Intel Force OS" or are we switching to "Clawd"? — Default: Intel Force OS until founder confirms switch.
- **OD-W-2:** Which hero variant — platform ("Draft. Review. Send.") or HR-wedge ("Your HR inbox, handled.")? — Default: HR-wedge until we have non-HR customers.
- **OD-W-3:** Show the four-tier pricing grid or the founding-phase £400 single-price block? — Default: founding-phase block until customer #11.
- **OD-W-4:** Logo strip on the home page? — Default: omit until 3+ logos with permission.
- **OD-W-5:** Marketing site on Cloudflare Pages or Vercel? — Default: Cloudflare Pages.
- **OD-W-6:** Cal.com or Calendly? — Default: Cal.com.

---

## 24. Things never to do (red lines)

- Never claim certifications we don't hold (SOC 2, ISO 27001) until we hold them
- Never put logos of customers we don't have
- Never write "AI-powered" anywhere
- Never use exclamation marks in body copy
- Never weaken the "everything drafts, nothing sends" line — it is the product
- Never fabricate testimonials or "founder favourites"
- Never put a chat widget on the page (ironic, dated, analytics we don't want)
- Never run a cookie-banner-requiring analytics tool (no GA4, no Hotjar)
- Never quote pricing on the home page in a way that contradicts /pricing
- Never bullet-list "Features" on the home page — show the work, not the spec sheet
- Never use beer-label / stamp / badge logo styles
- Never use stock photos of people in offices

---

## 25. Quick-reference: copy library

For copy/paste into the build.

### 25.1 Hero (platform variant)
> **Draft. Review. Send.**
>
> The agents that do your agency's operations — drafts, leads, content, follow-up, reporting — while you handle the bits humans are for.
>
> [Start 14-day trial →] [Book a demo]
>
> *14-day trial · Secure UK hosting · GDPR-ready · Cancel anytime*

### 25.2 Hero (HR variant)
> **Your HR inbox, handled.**
>
> An AI assistant that reads every HR message, drafts every reply, and flags what needs your judgement. Built for UK SMEs on Breathe HR.
>
> [Book a 30-minute call →] [Watch 3-min demo]
>
> *UK-based · GDPR-compliant · Built on Claude · Nothing sends without you*

### 25.3 Final CTA (platform)
> **Ready to see your drafts at 9am tomorrow?**
>
> [Start 14-day trial →] [Book a demo]

### 25.4 Final CTA (HR)
> **Stop reading twelve of the same questions every week.**
>
> Book a 30-minute call. If it's a fit, we'll talk pricing. If not, you've seen the fastest-improving AI in production — worthwhile either way.
>
> [Book your call →]
>
> *Replies within 24 hours · No sales team · Founder-led*

### 25.5 Status badge (founding phase)
`● Onboarding founding customers — 10 places`

### 25.6 OG tags
- **og:title:** Intel Force OS — Your HR inbox, handled
- **og:description:** AI for UK SME HR teams. Drafts every reply. Sends nothing without approval.
- **og:type:** website
- **og:url:** https://intelforce.ai
- **og:image:** dashboard-screenshot or branded composition (1200×630)

### 25.7 Footer block
```
© 2026 Intel Force Ltd. Registered in England and Wales.

Privacy · Terms · AUP · DPA
hello@intelforce.ai · support@intelforce.ai · security@intelforce.ai

[Registered office address]
[VAT number, if registered]
```

---

## 26. Asset inventory needed

Before launch:
- [ ] Logo: wordmark + favicon + 1:1 social profile square
- [ ] OG image (1200×630) for link previews
- [ ] Hero screenshot of the dashboard Operations view (demo data)
- [ ] One screenshot per agent for /product page
- [ ] Loom 3-min demo video, unlisted, embeddable
- [ ] Founder headshot (small, for /contact and /blog if used)
- [ ] Brand-guide PDF (4–6 pages: colours, typography, dos/don'ts) — designer or DIY

Nice-to-have first month:
- [ ] Social profile art (X banner, LinkedIn banner)
- [ ] Email signature template
- [ ] Pitch/demo slide template

Do not bother with at launch:
- T-shirts, swag
- Custom illustration style
- Animated hero asset (static works fine)

---

## 27. The meta-rule

Intel Force OS is over-specified and under-shipped. This rebuild needs to **launch fast** with the founding-phase HR-wedge copy and the four-objection microcopy in place. The platform-wide variant is a flip-of-a-feature once we have non-HR customers. Don't build for the future state — build for "today, the founder runs HR for SMEs and needs a page that converts on that thesis."

If a section in this doc feels redundant against shipping speed, cut it. If a piece of copy contradicts what the founder said in the last call, the founder wins.

Close the spec. Open the editor. Ship something.

---

*This file is the only context the rebuild needs. If you find yourself wanting to read other docs, add the missing piece to this file instead — it should always be self-contained.*

---

## 28. Hero animation — camera & cinematic direction

The hero scene includes a moving camera that traverses the agent-roster column (the "director column" — the vertical list/stack showing each agent role: HR, Sales, Recruiting, Ops, Finance, etc., as if from a director's call-sheet or org-chart view). Founder feedback on the current draft:

### 28.1 Pacing — slower and more cinematic
- The current camera move is too fast. Slow it down materially.
- Treat each role card as a beat the camera lingers on, not a frame it passes through.
- Default easing: long ease-in-out (cubic or sine), not linear, not snap.
- Aim for the whole pass to feel like a slow tracking shot — closer to a film opener than a SaaS scroll-jack.
- Suggested timings to start from (tune in build):
  - Total camera traverse of the column: **8–12 seconds**, not 2–3
  - Per-role dwell: **~1.2–1.5 seconds**
  - Smooth deceleration into each role; smooth acceleration out

### 28.2 Showcase the director column properly
The column is the hero's centrepiece — it visualises "the agents that work for you." It must be **legible and felt**, not glanced at.

- Camera should travel **along** the column (vertical truck or dolly), framing one role at a time near centre
- Each role card subtly highlights as the camera arrives (slight scale-up or glow, not a flash)
- Keep the surrounding frame quiet — depth-of-field blur on off-centre roles, sharp focus on the active one
- Avoid simultaneous parallax on multiple axes — one dominant motion (vertical) with restrained secondary motion only

### 28.3 The Sales → HR jolt
The cinematic flow is intentionally broken at one point — a directed jolt from Sales to HR — to signal that HR is the wedge / the active product.

- Camera moves **slowly and cinematically** through the column up to and including **Sales**
- Then a **jolt to HR** — fast cut or sharp whip-pan that breaks the slow rhythm
- After landing on HR, hold the frame longer than other roles (dwell ~2–3 seconds) — HR is where the page wants the eye to rest
- The jolt is the punctuation mark: every other role glides past, HR is the one that arrives. That contrast is the message.

### 28.4 What to avoid
- Smooth, even-paced traverse with no emphasis (defeats the wedge framing)
- Multiple jolts — one is rhythm; two is gimmick
- Bouncy / spring physics on the camera — feels like a slide deck, not cinema
- Over-blurred motion — keep frames legible; we're showing a roster, not abstract motion
- Auto-looping the animation aggressively — let it play once on load, then settle. A scroll-triggered replay is fine; a constant loop is exhausting.

### 28.5 Reduced-motion fallback
- Respect `prefers-reduced-motion: reduce` — render the column statically with HR pre-highlighted
- The static fallback should still communicate the wedge (HR card visually weighted heavier than the others)

### 28.6 Open questions for the rebuild session
- What is the column built in — Three.js / R3F, plain CSS/Framer Motion, Lottie, video? Animation direction above is medium-agnostic; tune the timing primitives to whichever is in use.
- Is the camera literal (3D scene) or metaphorical (CSS scroll/transform)? The "jolt to HR" reads either way.
- Confirm the role order in the column — current intent is roughly: Recruiting → Ops → Finance → Marketing → Legal → IT → Customer Success → Exec → **Sales → [JOLT] → HR**, so HR lands last and stickiest. Adjust if the column order differs in the build.
