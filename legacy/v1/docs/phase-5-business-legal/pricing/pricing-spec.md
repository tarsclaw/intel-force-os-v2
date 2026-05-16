# Pricing Specification

**The commercial terms for Clawd: four tiers, what each includes, what each costs, the economics behind the numbers, and the landing-page copy that communicates them.**

> **Audience:** founder setting final pricing; sales lead using tier details in conversations; designer producing the pricing page.
>
> **Status:** v1.0. Refines the four-tier structure from Session 0's `intelforce-ai-os-strategic-plan.md` and aligns with what Phase 2–4 infrastructure actually supports.
>
> **Philosophy:** pricing reflects value delivered, not cost-plus. But unit economics must work at every tier. Don't offer tiers that lose money, don't offer tiers customers won't buy.

---

## 1. Pricing strategy

### 1.1 Positioning

Clawd is positioned against **agency headcount**, not against other SaaS tools. The question we answer is: "What does it cost to have an AI workforce that does the jobs of a junior account manager, a content writer, a researcher, a follow-up coordinator, and a reporting analyst?"

Benchmark: a UK junior account manager costs £30–£45k/year fully loaded. A content writer on retainer: £2,000–£4,000/month. A BD researcher with data tools: £1,500–£3,000/month.

Clawd Growth tier is £1,800/month and does (a subset of) all of these jobs at once — with the human operator providing judgement where judgement matters. Against that comparable, Clawd is cheap.

Against other AI SaaS tools (ChatGPT Teams, Copilot, Jasper), Clawd is expensive — those tools are individual productivity aids. Different product, different price point.

### 1.2 Value anchors (what the customer buys)

- **Starter (£450/month):** one agent working one daily workflow. Proof that the model works.
- **Growth (£1,800/month):** the core agent suite. Real agency operations.
- **Scale (£4,500/month):** the full suite + custom SOPs + priority support. Productised agency in a box.
- **Enterprise (£10,000+/month):** bespoke integration, dedicated infrastructure, negotiated SLA. For regulated or data-residency-sensitive customers.

### 1.3 Price psychology

- Round numbers on primary price, no £1,799.99-style nonsense
- Annual commitment discount: 2 months free on annual prepay (equivalent to ~17% discount). Encourages longer term, improves cashflow.
- No free tier beyond a 14-day trial. Clawd isn't for tire-kickers; the infrastructure cost of genuine use is too high for free.

---

## 2. Tier definitions

### 2.1 Starter — £450/month

**Target customer:** solo operator or two-person consultancy wanting to validate Clawd before going deeper.

**Included:**
- Proposal Builder (primary agent)
- Client Onboarder
- Caption Writer
- Reporting Engine (monthly)
- Librarian (hidden, runs nightly)
- Up to 3 integrations (from: Fathom, Gmail, HubSpot, Stripe, GA4, basic CRMs)
- 1 user seat
- 100 agent invocations/month (soft cap — goes over, we email)
- £150 platform cost budget/month (soft alert)
- Standard support (business hours email)
- 99.0% SLA commitment

**Not included:**
- Lead Hunter, Content Creator, Repurposer, Follow-Up Pilot, SOP Writer
- Custom integrations
- Dedicated support
- White-label

**Why this tier exists:**
- Onboarding ramp for customers uncertain about committing to Growth
- Validation revenue while building the full agent suite
- Low-friction first sale

**Economic floor (per month):**
- Platform infrastructure allocation: ~£40
- AI inference (avg tenant usage): ~£40
- Support allocation: ~£30
- Total cost to serve: ~£110
- **Gross margin: ~£340, or 76%**

Starter is the tier where margin is tightest. Don't discount it below £450.

### 2.2 Growth — £1,800/month

**Target customer:** small-to-mid agency (£300k–£2M revenue), principal-led operation, ready to automate repeatable workflows.

**Included:**
- All Starter agents PLUS Lead Hunter, Content Creator, Repurposer, Follow-Up Pilot
- Up to 5 integrations
- 3 user seats
- 500 agent invocations/month (soft cap)
- £550 platform cost budget/month (soft alert)
- Priority email support + Slack channel
- Monthly 30-min check-in call
- 99.5% SLA commitment

**Not included:**
- SOP Writer
- Custom integrations
- Dedicated infrastructure
- Enterprise-specific legal terms

**Why this is the primary tier:**
- Matches the product's central value prop — a functional agent workforce
- Matches a £2k-ish/month "obvious-value" ceiling many small agencies instinctively accept
- Unit economics comfortable

**Economic floor (per month):**
- Platform infrastructure: ~£60
- AI inference: ~£250
- Data provider costs (Prospeo, Kaspr): ~£80
- Support allocation: ~£80
- Total cost to serve: ~£470
- **Gross margin: ~£1,330, or 74%**

### 2.3 Scale — £4,500/month

**Target customer:** mid-tier agency (£2M–£10M revenue) with formalised processes, or fast-growth consultancy ready to standardise operations.

**Included:**
- All Growth agents PLUS SOP Writer
- Unlimited integrations (subject to availability)
- 10 user seats
- 2,000 agent invocations/month
- £1,200 platform cost budget/month
- Priority support with 4-hour P2 response
- Quarterly strategy review
- White-label option available (additional setup fee)
- Agency partner option for customers with sub-brands
- 99.5% SLA commitment (with option to negotiate 99.9% for additional cost)

**Not included:**
- Custom agent development
- Dedicated infrastructure
- Custom legal terms without solicitor engagement

**Economic floor (per month):**
- Platform infrastructure: ~£100
- AI inference: ~£650
- Data provider costs: ~£150
- Support allocation: ~£200 (includes quarterly calls)
- Total cost to serve: ~£1,100
- **Gross margin: ~£3,400, or 75%**

### 2.4 Enterprise — starting £10,000/month

**Target customer:** large agencies, holding companies (Rigby Group shape), or regulated-industry customers requiring custom terms.

**Included:**
- Everything in Scale
- Dedicated infrastructure (separate Postgres instance, isolated container pool)
- 99.9% SLA commitment
- 24/7 P1 support with named account manager
- Quarterly on-site/virtual strategy reviews
- Custom agent development (scoped)
- Custom integrations
- Custom legal terms via MSA negotiation
- White-label included
- Data residency guarantees
- Annual penetration test report shared

**Pricing:**
- Base: £10,000/month
- Plus: custom agent development if scoped (typically £5,000–£25,000 per custom agent)
- Plus: usage beyond allocations (negotiated)

**Economic floor:**
- Platform infrastructure (dedicated): ~£500
- AI inference: ~£2,000
- Data provider costs: ~£300
- Support allocation: ~£2,000 (named AM)
- Custom engineering time: variable
- **Gross margin: ~£5,200+ at base, 52%+ (lower % than other tiers but higher absolute)**

Enterprise deals often include significant services revenue (onboarding, custom development, training) with better margin than base subscription.

### 2.5 Agency Partner tier — bespoke

**Target customer:** companies managing multiple related tenants (like Rigby Group).

**Pricing model:**
- Platform fee: £2,000–£5,000/month depending on size
- Plus: per-sub-tenant fee at a 30–40% discount vs standalone Growth/Scale tiers
- Plus: roll-up billing option

Example: Rigby Group with 3 sub-tenants (SCC at Scale equivalent, Allect + Eden at Growth equivalent):
- Platform fee: £2,500/month
- SCC sub-tenant: £3,000 (vs £4,500 standalone = 33% discount)
- Allect sub-tenant: £1,200 (vs £1,800 = 33% discount)
- Eden sub-tenant: £1,200 (vs £1,800 = 33% discount)
- **Total: £7,900/month** vs £8,100 if each bought separately — modest discount, but shared platform fee + consolidated billing + agency portal

The Agency Partner discount isn't huge in percentage terms — the real value is platform features (portfolio view, roll-up billing, agency-level team) and negotiated flexibility.

---

## 3. Pricing page — design spec

### 3.1 Placement

- URL: `clawd.ai/pricing`
- Linked from main nav and landing-page hero
- Visible to unauthenticated visitors

### 3.2 Layout

```
─────────────────────────────────────────────────────────────
  Hero copy:
  "Pricing that matches what you'd pay for a team."

  Tab: [Monthly] [Annual (2 months free)]  →  toggle

  ┌─────────┬──────────┬─────────┬──────────────┐
  │ STARTER │  GROWTH  │  SCALE  │  ENTERPRISE  │
  │         │  (POP.)  │         │              │
  │  £450   │  £1,800  │  £4,500 │  From        │
  │  /mo    │  /mo     │  /mo    │  £10,000/mo  │
  │         │          │         │              │
  │ [CTA]   │  [CTA]   │ [CTA]   │  [Contact]   │
  │         │          │         │              │
  │ List of │  List of │ List of │  List of     │
  │ features│  features│ features│  features    │
  │         │          │         │              │
  └─────────┴──────────┴─────────┴──────────────┘

  FAQ below: 6-8 questions

  Small note:
  "Agency managing multiple brands? [Agency Partner pricing →]"
─────────────────────────────────────────────────────────────
```

### 3.3 Feature matrix (for the comparison grid)

| Feature | Starter | Growth | Scale | Enterprise |
|---|---|---|---|---|
| Proposal Builder | ✓ | ✓ | ✓ | ✓ |
| Client Onboarder | ✓ | ✓ | ✓ | ✓ |
| Reporting Engine | ✓ | ✓ | ✓ | ✓ |
| Caption Writer | ✓ | ✓ | ✓ | ✓ |
| Lead Hunter | — | ✓ | ✓ | ✓ |
| Content Creator | — | ✓ | ✓ | ✓ |
| Repurposer | — | ✓ | ✓ | ✓ |
| Follow-Up Pilot | — | ✓ | ✓ | ✓ |
| SOP Writer | — | — | ✓ | ✓ |
| User seats | 1 | 3 | 10 | Unlimited |
| Integrations | 3 | 5 | Unlimited | Unlimited |
| Agent runs/month | 100 | 500 | 2,000 | Custom |
| Platform cost budget | £150 | £550 | £1,200 | Custom |
| SLA | 99.0% | 99.5% | 99.5% | 99.9% |
| Support | Email, biz hours | Slack + email | Priority | 24/7 + named AM |
| White-label | — | — | Optional | Included |
| Custom agents | — | — | — | Available |
| Dedicated infrastructure | — | — | — | Included |

### 3.4 CTAs per tier

- **Starter:** "Start 14-day trial" → sign-up flow
- **Growth:** "Start 14-day trial" → sign-up flow (marked "Most Popular")
- **Scale:** "Book a demo" → Calendly to founder
- **Enterprise:** "Contact sales" → email form

### 3.5 Trial mechanics

- 14-day free trial
- Credit card required at signup (reduces tyre-kickers; Stripe collects but doesn't charge until trial end)
- Auto-converts to paid unless cancelled before day 14
- Starter and Growth are trial-eligible; Scale and Enterprise are demo-first

### 3.6 FAQ section

Cover the predictable questions:
1. What's included in each plan?
2. Can I change plans later? (Yes, any time, pro-rated)
3. What happens if I go over my usage allowance? (We email; soft caps; overages are discussed before any hard stop)
4. How does the 14-day trial work?
5. Do you offer discounts for annual commitments? (Yes, 2 months free on annual)
6. What about agencies managing multiple brands? (Agency Partner pricing, link to contact)
7. Can I cancel anytime? (Yes, monthly plans month-to-month; annual plans can cancel for next renewal)
8. Is my data safe? (Link to Security page and DPA summary)

### 3.7 What NOT to include on the pricing page

- Feature comparisons framed negatively ("Starter does NOT include...") — show the feature, let the tick-mark tell the story
- Countdown timers, "only 3 left" urgency tactics — we're not a consumer app, and this undermines trust
- Fake discount "was £3,000, now £1,800" — never. Price is what it is.
- Hidden fees (all costs disclosed on the pricing page, including usage-based components)

---

## 4. Pricing page copy

### 4.1 Hero headline

> **Pricing that matches what you'd pay for a team.**

Subhead:
> A full agent suite costs less than one junior account manager — and drafts more proposals, more content, more follow-ups, every week.

### 4.2 Plan card copy

**Starter:**
- Badge: (none; not marked as anything special)
- Headline: "For solo operators trying Clawd."
- Subhead: "Core agents, one user, enough to prove the model works."

**Growth** (marked "Most Popular"):
- Badge: "Most Popular"
- Headline: "The full agent workforce."
- Subhead: "Everything most agencies need: drafts, leads, content, follow-up."

**Scale:**
- Headline: "Productised agency, in a box."
- Subhead: "Growth plus SOP Writer, priority support, and standards for bigger teams."

**Enterprise:**
- Headline: "Custom-fit for regulated or complex deployments."
- Subhead: "Dedicated infrastructure, custom terms, custom agents."

### 4.3 Footnote copy

Below the pricing grid:

> Usage-based costs (AI inference, data providers) are included in each tier's budget allocation. Going over the budget triggers a warning, not a bill — you can raise the budget or let us know in support. We never surprise you with a monthly charge.

> Prices shown are in GBP, exclusive of VAT where applicable.

---

## 5. Discounting policy

### 5.1 Standard discounts

- **Annual prepay:** 2 months free (16.7% effective discount)
- **Agency Partner:** 30–40% on sub-tenant fees
- **Multi-year commitment:** negotiable for Scale/Enterprise only

### 5.2 No-discount-under policy

- Never discount below the tier's economic floor (see §2)
- Starter is never discounted — it's already the entry point
- Growth can be modestly flexible for strong strategic wins (e.g., anchor customers who'll provide case studies), never below 20% off
- Discounts require approval from founder; no "sales" discretion unless agreed in advance

### 5.3 Founding customers programme (first 10)

The first 10 paying customers (starting from Phase 5 launch) get:
- 30% off Growth or Scale tier for the first 12 months
- Grandfathered pricing for the next 12 months (protected against any price increases)
- Named "Founding Customer" status (internal; no special branding)
- Monthly 1:1 call with founder for feedback

This is explicit, time-limited, and publicised. Stops at customer 11 regardless of remaining trial pipeline.

### 5.4 When NOT to discount

- "We'll sign if you go lower" — if the customer is price-sensitive at tier, they're a bad fit; the product isn't a commodity
- Resellers or affiliates asking for margin share — not our business model
- Enterprise negotiation is different — there discounts happen alongside commitment (longer term, bigger committed usage)

---

## 6. Payment & billing details

### 6.1 Payment methods

- Credit/debit card via Stripe (default)
- Direct debit / BACS for UK customers (annual plans only; saves Stripe fees)
- Bank transfer for Enterprise (invoiced)

### 6.2 Billing cadence

- Monthly plans: billed on the same day each month, 30-day terms
- Annual plans: billed upfront, 30-day terms
- Usage-based fees: billed monthly in arrears

### 6.3 Currency

- Default: GBP
- EUR and USD available on request (displayed from Stripe with current exchange rate)
- No dynamic-by-geo pricing — same price everywhere for now

### 6.4 VAT / tax

- UK customers: VAT at prevailing rate
- EU customers: reverse-charge mechanism (customer handles VAT); need valid VAT number
- Other countries: no VAT added (customer's responsibility for local tax)

### 6.5 Stripe specifics

Full technical spec in `billing/stripe-integration-spec.md`.

---

## 7. Competitive pricing context (for internal use)

### 7.1 What competitors charge

| Competitor | Model | Typical price | Position |
|---|---|---|---|
| Relevance AI | Multi-agent platform | £500–£2,500/month | Narrower ICP; we're tighter on UK ops |
| Jasper | Content generation | £80–£500/month | Single-function; doesn't overlap our positioning |
| Writer | Enterprise writing | £1,000+/month | Enterprise-focused content |
| Zapier with GPT | DIY workflows | £50–£500/month | Tool, not platform; not really comparable |
| Agency Analytics | Reporting | £100–£400/month | Single function |
| Copy.ai + HubSpot | Mass production | Variable | Volume play, different ICP |

We're priced higher than single-function tools, in line with multi-agent platforms, cheaper than pure enterprise AI vendors.

### 7.2 Psychological anchoring on the pricing page

The comparison to make (implicit, not explicit): "£1,800/month is one junior account manager for a week." That framing makes Growth feel obviously valuable to the target customer.

Avoid making direct comparisons to competitor products on the pricing page — creates unnecessary friction with competitors, dates the page, and invites pricing-driven buyers.

---

## 8. Price changes

### 8.1 Increase frequency

- Maximum once per 12-month period for any tier
- At least 60 days' notice to existing customers
- Customers on annual contracts keep their rate until renewal

### 8.2 Automatic uplift

- Built into MSA — up to 10% per year without triggering termination right
- Above 10% = customer can terminate effective on the change date

### 8.3 First 12 months post-launch

No price increases in the first 12 months. Gives early customers stability; gives us time to validate that tier structure is right.

---

## 9. When to revisit pricing

Trigger for formal review:
- 12 months post-launch
- Customer count milestones (10, 50, 200)
- Material change in AI model costs (especially Anthropic-side)
- Competitor moves that shift market pricing
- Evidence of leaving money on the table (consistent easy closes at sticker price)
- Evidence of pricing-driven losses (prospects consistently bouncing at sticker price)

---

## 10. Open decisions

**OD-P5-15:** Starter tier at £450 or £600?
- **Recommendation:** £450. Less friction for the first sale. Margin is enough. Growth is where the real money is.

**OD-P5-16:** Annual prepay discount — 2 months free or 3?
- **Recommendation:** 2 months (16.7% effective). 3 months (25%) is too aggressive for early-stage; don't train customers to expect steep discounts.

**OD-P5-17:** Free tier?
- **Recommendation:** No. Use 14-day trial as the free exposure mechanism. Free tier forever is mis-aligned with the cost of AI inference.

**OD-P5-18:** Credit card required at trial signup?
- **Recommendation:** Yes. Reduces tyre-kickers, improves trial-to-paid conversion, and lets Stripe handle trial-end charge automatically. Stripe doesn't charge until trial ends.

---

## 11. Related

- `msa-template.md` — the contractual layer
- `sla-spec.md` — service-level commitments by tier
- `billing/stripe-integration-spec.md` — technical implementation
- `marketing/landing-page-spec.md` — the page this pricing is displayed on
- `intelforce-ai-os-strategic-plan.md` (Session 0) — original pricing framework

---

*Pricing is a commercial decision that must be revisited based on market feedback. This spec locks v1 to remove ambiguity for launch.*
