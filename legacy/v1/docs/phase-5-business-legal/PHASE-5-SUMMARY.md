# Phase 5 — Business, Legal & Commercial Specifications

**Everything required to turn the platform into a legally-operating, commercially-credible, revenue-collecting business. Brand, trademark, legal docs, pricing, landing page, billing, external API, and the playbooks for selling and proving value.**

> **Status:** v1.0, shipped 23 April 2026.
>
> **Prerequisites:** none for most of Phase 5 — can run entirely in parallel with Phase 3 (platform) and Phase 4 (dashboard) build. The exception is the Stripe integration + REST API, which need the dashboard's tRPC infrastructure present (Phase 4 CC13) before wiring.

---

## What's in this phase

### Marketing (3 files)

| # | Spec | Purpose |
|---|---|---|
| 1 | `marketing/brand-identity-spec.md` | Name recommendation (Clawd over IntelForce), domain and social handle strategy, palette, typography, voice pillars, DIY identity v1 before designer engagement |
| 2 | `marketing/trademark-filing-brief.md` | UK trademark filing plan — class 9 + 42, CITMA attorney engagement, pre-filing search checklist (UKIPO / EUIPO / USPTO / WIPO Global / Companies House), specification wording samples, timeline, £870–£1,170 UK launch budget |
| 3 | `marketing/landing-page-spec.md` | 10-section home page (hero → final CTA), copy principles, technical stack (separate `apps/marketing/` Next.js app), SEO plan, performance budget, post-launch experimentation framework |

### Legal (5 files)

| # | Spec | Purpose |
|---|---|---|
| 4 | `legal/msa-template.md` | 12-section Master Services Agreement template — definitions / service / use / fees / IP / confidentiality / data protection / warranties / indemnities / liability cap (greater of 12mo fees or £10k) / term / general. AI-specific disclaimers §10.4. Solicitor finalisation £2–5k. |
| 5 | `legal/dpa-template.md` | GDPR Data Processing Addendum — processor/controller model, Annex A (TOMs), Annex B (sub-processor list: Anthropic / Hetzner / AWS / Cohere / Clerk / Stripe / Cloudflare / Statuspage / PagerDuty / GitHub), Annex C (UK Addendum to EU SCCs), 72hr breach notification, annual audit rights |
| 6 | `legal/sla-spec.md` | Tier SLAs — Starter 99.0%, Growth 99.5%, Scale 99.5%, Enterprise 99.9%. Service credits (5–50% capped 50%). Support response times. RPO/RTO matrix aligned with Phase 3 infra. Scheduled maintenance window. |
| 7 | `legal/acceptable-use-policy.md` | Permitted use; prohibited categories (illegal / harmful / AI misuse / CSAM / extremism / security integrity / reselling); "Everything drafts, nothing sends" principle (§5.1); proportionate enforcement; abuse@clawd.ai reporting |
| 8 | `legal/privacy-and-terms-spec.md` | Privacy Policy (GDPR Art 13/14), Terms of Service (free/trial liability cap £1k separate from MSA), cookie consent design (Accept/Reject equally prominent), DSAR 30-day process. Solicitor finalisation £2.1–4.1k. |

### Pricing (1 file)

| # | Spec | Purpose |
|---|---|---|
| 9 | `pricing/pricing-spec.md` | Four tiers: Starter £450 (76% margin), Growth £1,800 (74%), Scale £4,500 (75%), Enterprise £10k+ (52%+). Agency Partner bespoke platform fee + 30–40% sub-tenant discount. Rigby Group example £7,900/mo total. 14-day trial with credit card required. Annual prepay 2 months free. Founding customers programme (first 10 → 30% off 12mo). Full pricing page copy + feature matrix + FAQ. |

### Billing (1 file)

| # | Spec | Purpose |
|---|---|---|
| 10 | `billing/stripe-integration-spec.md` | Stripe Customer/Subscription model, Products + Prices, usage-based items for cost overages, webhook endpoint handling (10 critical events), reverse-charge EU VAT, dunning + payment-failure flows, invoice generation, refund policy, agency roll-up billing via Stripe Invoice Items |

### External API (1 file)

| # | Spec | Purpose |
|---|---|---|
| 11 | `api/rest-api-spec.md` | Public REST API at `api.clawd.ai/v1/*`, scoped API keys (`intel_live_*`), OpenAPI 3.1 spec, endpoints for costs / invocations / escalations / vault search / settings, rate limits (100/min per key), pagination, error codes, versioning + deprecation policy |

### Playbooks (2 files)

| # | Spec | Purpose |
|---|---|---|
| 12 | `playbooks/sales-playbook.md` | ICP definition, BANT-ish qualification, 30–45min discovery call structure, objection handling library (12 common objections), demo framework, pricing conversation, close tactics, post-signature handoff to Configuration Wizard |
| 13 | `playbooks/case-study-playbook.md` | Case study production workflow post-first-customer-live, interview template, metrics capture framework (time saved / revenue impact / escalations avoided), publication formats (long-form / one-pager / testimonial quote), approval-and-edit cycles with customers |

### Summary (this document)

| # | Spec | Purpose |
|---|---|---|
| 14 | `PHASE-5-SUMMARY.md` | Phase 5 tour guide, dependency ordering, cost envelope, open decisions recap |

**Total: 14 specs, ~6,400 lines across legal / commercial / go-to-market surface.**

---

## How the pieces fit together

```
                    ┌─────────────────────────────────┐
                    │  clawd.ai (marketing site)      │
                    │  ── landing page spec           │
                    │  ── pricing page                │
                    │  ── brand identity              │
                    └──────────────┬──────────────────┘
                                   │ sign-up click
                                   ▼
                    ┌─────────────────────────────────┐
                    │  Lead → discovery call          │
                    │  ── sales playbook              │
                    │  ── qualification framework     │
                    └──────────────┬──────────────────┘
                                   │ qualified + demo
                                   ▼
                    ┌─────────────────────────────────┐
                    │  Contract stage                 │
                    │  ── MSA (12 sections)           │
                    │  ── DPA (GDPR)                  │
                    │  ── SLA (tier commitments)      │
                    │  ── AUP (acceptable use)        │
                    │  ── ToS + Privacy (if self-serve)│
                    └──────────────┬──────────────────┘
                                   │ signed + payment setup
                                   ▼
                    ┌─────────────────────────────────┐
                    │  Stripe subscription active     │
                    │  ── Stripe integration spec     │
                    └──────────────┬──────────────────┘
                                   │ operator triggers Wizard
                                   ▼
                    ┌─────────────────────────────────┐
                    │  Configuration Wizard (Phase 4) │
                    │  → TenantOnboard (Phase 3)      │
                    │  → Agents running (Phase 2)     │
                    └──────────────┬──────────────────┘
                                   │ 30+ days live
                                   ▼
                    ┌─────────────────────────────────┐
                    │  Case study produced            │
                    │  ── case study playbook         │
                    │  → feeds back into              │
                    │     landing page social proof   │
                    └─────────────────────────────────┘

                    External consumers (later):
                    ── REST API spec
                    ── API keys issued via Settings view
```

Phase 5 is the connective tissue between product (Phase 1–4) and customer. Every spec has a clear consumer.

---

## Key commercial decisions locked in this phase

### 1. Product name: Clawd (recommended), not IntelForce
Tier-one trademark blockers on IntelForce made it untenable. Clawd is one-syllable, phonetically punchy, self-referential to Claude (which we lean into), and the `.ai` / `.co.uk` / `.app` / `.io` domains are all available. This decision cascades through brand identity, trademark filing, all legal template client-facing text, and the landing page. **This is the biggest unresolved decision in the entire project — see "Three persistent blockers" below.**

### 2. Four-tier pricing with Growth (£1,800) as anchor
Starter £450 proves the model; Growth £1,800 is the main commercial target; Scale £4,500 for agencies; Enterprise £10k+ for regulated or data-sensitive customers. Agency Partner is bespoke on top of this. Rigby Group example works out at ~£7,900/mo across SCC + Allect + Eden. Starter has the tightest margin (76%); Enterprise has the fattest surplus but requires dedicated infrastructure.

### 3. Credit card required at 14-day trial start
No free tier. Friction filters serious prospects. Stripe's auto-convert at trial end means zero-effort renewal for both sides. Cancel-anytime during trial is one click (Stripe-hosted portal).

### 4. CITMA attorney for trademark filing, not DIY
£500–£800 on attorney fees vs DIY is worth it — UK trademark specifications are stricter than they look, and the attorney writes class 9 + 42 wording defensively. Total UK launch budget (attorney + gov fees + domain + social) £870–£1,170. Defer EU trademark until first EU customer; defer US trademark until US pipeline has substance.

### 5. MSA, DPA, SLA as bundled package
Standard contract pack for every Starter/Growth/Scale customer. No redlines — take-it-or-leave-it for sub-Enterprise. Enterprise gets solicitor-drafted custom MSA (£2–5k per deal). Keeps sales cycle friction low for volume customers.

### 6. Intel Force Ltd as operating entity; Clawd as trading name only
No new company formation. Intel Force Ltd (existing) contracts with customers; Clawd is a trading name. Cheapest legal setup; can reverse later if needed (company rename is £8 at Companies House).

### 7. "Everything drafts, nothing sends" as product-wide promise
Codified in AUP §5.1. This is the core risk-mitigation story that makes AI-at-scale tolerable for customers in regulated industries (dental, legal, financial). Every output is a draft for human approval; the platform does not send emails, take meetings, or commit money autonomously.

### 8. Cookie consent: Accept AND Reject equally prominent
GDPR + ICO guidance enforced since 2019 but widely ignored. We do it right. Small cost in conversion; large saving in potential ICO fines. Plausible/Fathom Analytics are cookieless and don't require consent anyway — reduces how often the banner fires.

### 9. Landing page as separate Next.js app (`apps/marketing/`)
Not part of the dashboard monorepo-via-Turborepo's `apps/dashboard/`. Marketing ships on its own cadence, has different performance characteristics (ISR + aggressive edge caching), runs different analytics, and can be owned by non-engineer content operators without risking dashboard stability.

### 10. REST API v1 is read-heavy, write-light
Customers mostly want to pull data out (cost reporting, invocation analytics, escalation integration with their own ticketing). Write endpoints only for actions they explicitly need: resolve/acknowledge escalations, update specific settings. No "fire an agent via API" in v1 — that would be a significant expansion of the threat model.

### 11. Agency Partner pricing: platform fee + sub-tenant discount
Agency pays a platform fee (£2–5k/month bespoke) covering roll-up billing, portfolio reporting, consolidated support. Each sub-tenant under the agency gets 30–40% off its standalone price. Agency captures the margin; we capture predictable MRR from the platform fee. Rigby Group example: £2,500 platform fee + 3 sub-tenants discounted = £7,900 total.

### 12. Founding Customers programme
First 10 paying customers (all tiers) get 30% off their first 12 months, locked in. In exchange they commit to a case study + reference call. Massive ROI — first case studies are worth far more than the discount in marketing value.

---

## What this phase enables

- **A paying customer.** With Phase 5 shipped, a customer can go from landing-page click → discovery call → MSA signature → Stripe subscription → Configuration Wizard (Phase 4) → live tenant (Phase 3) without any hand-coded workarounds.
- **A defensible legal position.** MSA + DPA + SLA + AUP + Privacy + ToS cover every obligation a UK/EU customer will ask about. AI-specific disclaimers + liability cap keep risk bounded.
- **Trademark protection.** Pre-filing searches + UKIPO application prevent someone else grabbing "Clawd" in class 9 + 42.
- **A commercial identity.** Domain, logo direction, voice, palette, typography all locked. Landing page copy written, SEO planned.
- **Agency-partner-shaped revenue.** Rigby Group or similar multi-division customers have a pricing model that works for both sides.
- **Programmatic integration.** Customers who want to pull data into their own reporting can use the REST API v1.
- **A sales process.** Playbook, qualification criteria, discovery structure, objection library — new salespeople can be productive faster.
- **A case study factory.** First customer live → case study produced in a documented workflow → social proof on the landing page → next sale.

---

## What Phase 5 does NOT deliver

- **Paid advertising strategy** — Google Ads, LinkedIn Ads, retargeting pixels. Deferred until we know which channels actually convert (need post-launch analytics data first).
- **Email nurture sequences** — Welcome series, trial-abandoner recovery, monthly-newsletter shell. Valuable but Phase 6 territory.
- **Partnership / reseller programme** — Structured agency programme with tiers and incentives. Deferred until we have 3+ agency customers to learn from.
- **International expansion** — Currency / language / compliance for non-UK markets. UK-English, GBP-primary, UK-law for v1.
- **Affiliate programme** — Some customers will want to refer friends and be paid. Build it when asked, not before.
- **Gated content / lead magnets** — Whitepapers, downloadable reports, benchmark studies. Nice marketing asset but not the first mile.
- **Salesforce or HubSpot CRM integration** — Sales process runs out of Notion / Linear / Gmail for v1. CRM integration is a Phase 7 "once we have volume" project.
- **Live chat / in-app support chat** — Email + scheduled calls for v1. Intercom-style widget is a distraction at <20 customers.

---

## Dependency ordering for commercialisation

If building sequentially (solo founder or very small team), suggested order:

1. **Week 1 — Name + domain + trademark search**
   - Lock Clawd (OD-P5-1)
   - Pre-filing searches (2 hours, DIY)
   - Register clawd.ai / clawd.co.uk / clawd.app / clawd.io
   - Secure @clawd social handles (Twitter/X, LinkedIn, Instagram, TikTok)

2. **Week 2 — Brand identity v1 + trademark filing**
   - DIY identity: palette, typography, logo lockup, basic asset pack
   - Engage CITMA attorney; submit UK application class 9 + 42
   - Set up Intel Force Ltd as "Clawd" trading name

3. **Weeks 3–4 — Legal pack with solicitor**
   - Engage UK commercial solicitor
   - Finalise MSA, DPA, SLA, AUP, Privacy, ToS using Phase 5 templates as starting points
   - Budget: £4–10k total for the pack (one-time)

4. **Weeks 4–5 — Pricing + landing page**
   - Lock pricing (OD-P5-15, OD-P5-16, OD-P5-17, OD-P5-18)
   - Build `apps/marketing/` Next.js app
   - Write final home page copy (use landing page spec as scaffold)
   - Pricing page + about page + legal pages

5. **Week 6 — Stripe integration**
   - Set up Stripe account with UK company verification
   - Create Products + Prices in Stripe matching pricing tiers
   - Wire webhook handler into dashboard (requires Phase 4 CC13 running)
   - Test full flow: trial signup → conversion → invoice → failed payment → dunning

6. **Week 7 — Sales playbook operationalisation**
   - Write playbook tailored to first-50 ICPs (use spec as scaffold)
   - Set up discovery call calendar (Cal.com)
   - Demo environment standing up (a live tenant doing real work to show)

7. **Week 8 — Soft launch**
   - Founding Customers programme announced to first 10 warm prospects
   - Landing page live
   - Legal pack in solicitor's hands for final redline
   - First discovery calls booked

8. **Weeks 9–12 — First 3 paying customers live**
   - Configuration Wizard (Phase 4 CC14) runs for each
   - Tenant onboarding (Phase 3 provisioning) kicks in
   - Weekly check-ins per sales playbook

9. **Month 4 — First case study**
   - Case study playbook workflow runs against first customer
   - Published on landing page + LinkedIn
   - Used as social proof for discovery calls 4+

10. **REST API (when asked)** — not critical-path. First customer who asks for programmatic access triggers build. Budget: 1 week.

**Total time from Phase 5 start → first paying customer live: ~10–12 weeks assuming Phase 3 + 4 build runs in parallel.**

---

## Cost envelope

### One-time costs (Phase 5 launch)

| Item | Cost |
|---|---|
| Domain registration (clawd.ai + .co.uk + .app + .io) | £120 |
| CITMA attorney (UK trademark) | £600 |
| UKIPO gov fees (class 9 + 42) | £340 |
| Social handle premium (if needed) | £0–300 |
| Solicitor (MSA + DPA + SLA + AUP + Privacy + ToS pack) | £4,000 |
| DIY identity tools (Figma, stock assets) | £100 |
| Stripe account setup + verification | £0 |
| **One-time total** | **£5,160–£5,460** |

Optional add-ons:
- Designer engagement for v2 identity (post-launch): £3,000–5,000
- EU trademark filing (when first EU customer closes): £1,200
- US trademark filing (when US pipeline has substance): £1,500

### Recurring commercial costs

| Item | Monthly |
|---|---|
| Stripe fees (1.5% + 20p per transaction, UK) | ~£45 at 10 Growth tenants |
| Plausible/Fathom Analytics | £9–19 |
| Postmark or Resend (transactional email) | £15–40 |
| Statuspage.io | £25 |
| Cal.com (self-hosted on existing infra) | £0 |
| Notion + Linear (ops) | £15 |
| **Recurring total** | **£110–£145/mo** |

At 10 Growth customers (£18k MRR): commercial costs are <1% of revenue. At 50 customers (scaling up): still <1%.

---

## Risks and commercial open questions

### R1 — Naming blocker
Clawd name not yet locked. Every spec in this phase references Clawd as the working name. If the naming decision flips, we rewrite all customer-facing copy (not a huge job — templates + search/replace), BUT we lose the trademark window and the domain/social handles may be gone. Resolve this first.

### R2 — Trademark timeline vs sales velocity
UK trademark takes ~3 months uncontested. If we close first customer in month 2 before trademark is granted, we're still trading under Clawd but without registered protection. Mitigation: contractual passing-off rights suffice short-term; just avoid making "registered trademark" claims until grant.

### R3 — Solicitor timeline risk
UK commercial solicitors are slow — 4–8 weeks is typical for finalising a template pack. If first customer arrives before legal pack is ready, we have two options: delay signing (risky — customer goes cold) OR use the templates as-is with a "legal review pending" note and the solicitor cleans up before invoice #2. The second option is survivable; the templates are defensible even without solicitor polish, but this is a real commercial risk.

### R4 — Pricing elasticity unknown
£450 Starter / £1,800 Growth pricing is modelled from comparable-product benchmarks (UK account manager cost, content writer retainer, BD research tool). We have zero actual pricing-response data. First 3 customers will tell us if we've priced too high, too low, or right. Expect some repricing in month 3–6.

### R5 — Stripe UK verification delay
Stripe UK verification typically takes 1–3 business days but can take weeks if there are issues with company documents. Start the Stripe setup Week 1 to front-load this risk. Cannot invoice until Stripe is verified.

### R6 — First case study timing
Case study playbook assumes a customer 30+ days live with measurable results. If first 3 customers are slow to generate results, we're month 4 before first social proof is ready — slowing sales 4+. Mitigation: aggressive hand-holding of first 3 to make sure they see results fast.

### R7 — Founding customer honesty tax
First 10 customers at 30% off = ~£60k/year of discounted MRR vs full pricing. This is the price of getting case studies + references + early signal. Worth it. But budget accordingly — don't model Year 1 revenue at full pricing.

---

## Open decisions (OD-P5-1 through OD-P5-18)

Full list with recommendations — final lock needed before each spec's downstream work starts.

### Naming + identity
- **OD-P5-1:** Lock "Clawd" as product name — **rec: yes.** Blocks everything else in Phase 5.
- **OD-P5-2:** Intel Force Ltd as operating entity, Clawd as trading name only — **rec: yes.** No new company formation.
- **OD-P5-3:** DIY identity v1, engage designer post-launch for v2 — **rec: yes.** Saves £3–5k until we know the product is working.
- **OD-P5-4:** clawd.ai as primary domain — **rec: yes.** `.ai` is the dominant AI-product TLD convention.

### Trademark
- **OD-P5-5:** CITMA attorney (£500–800) vs DIY UKIPO filing — **rec: CITMA attorney.** Spec-wording precision matters.
- **OD-P5-6:** Defer EU trademark until first EU customer — **rec: yes.** Save £1,200 until needed.
- **OD-P5-7:** File class 9 + 42 only at UK launch; skip class 35 (marketing services) — **rec: yes.** Marketing-services classification invites distraction and we don't compete in that space.

### SLA
- **OD-P5-8:** Start Growth tier SLA at 99.0% for first 3 months before bumping to 99.5% — **rec: yes.** Buys time to prove operational reliability; customers understand early-days caveat.
- **OD-P5-9:** Enterprise 99.9% SLA requires multi-region infrastructure — **rec: yes, priced in.** Quote accordingly; don't promise multi-region on Scale tier.
- **OD-P5-10:** No 24/7 support on Starter tier — **rec: yes, keep.** Business hours support only at Starter; 24/7 P1 starts at Growth+.

### Infrastructure choices
- **OD-P5-11:** Statuspage.io (Atlassian) for public status page — **rec: yes.** Credible, recognised, cheap.
- **OD-P5-12:** Plausible or Fathom Analytics (cookieless) — **rec: yes, either.** Plausible preferred (UK/EU-based, open-source option available).
- **OD-P5-13:** Resend or Postmark for transactional email — **rec: either, prefer Resend.** React-email support matters if we build templated emails with the monorepo's React stack.
- **OD-P5-14:** DIY cookie consent banner matching the design system — **rec: yes.** £0 cost, GDPR-compliant, no third-party cookie-consent provider skimming revenue.

### Pricing
- **OD-P5-15:** Starter at £450/mo (not £299, not £600) — **rec: yes.** Margin math works; price reads "professional, not cheap."
- **OD-P5-16:** 2 months free on annual prepay — **rec: yes.** Standard SaaS discount; improves cash flow.
- **OD-P5-17:** No free tier — **rec: yes.** Free tier customers are expensive to support and rarely convert at our price points.
- **OD-P5-18:** Credit card required at 14-day trial start — **rec: yes.** Friction filters serious prospects; Stripe auto-converts at trial end.

---

## The Rigby Group commercial example (updated)

The agency partner pricing model applied to Rigby Group:

| Component | Monthly |
|---|---|
| Agency Partner platform fee | £2,500 |
| SCC (Scale tier, 30% sub-tenant discount on £4,500) | £3,150 |
| Allect (Growth tier, 30% sub-tenant discount on £1,800) | £1,260 |
| Eden Hotel Collection (Growth tier, 30% discount on £1,800) | £1,260 |
| **Total monthly** | **£8,170** |

Annual contracted value: £98,040 from one customer. That single relationship covers ~98% of the £100k ARR goal Maddox has been working toward.

Implications: closing one strategic agency partner early has outsized impact. Rigby Group is warm — leverage the connection. Phase 5's agency spec was built with this shape in mind.

---

## Where Phase 5 meets Phases 1–4

| Phase 5 spec | Consumes from | Feeds into |
|---|---|---|
| Brand identity | Session 0 dashboard prototype palette | Landing page + dashboard chrome + all customer-facing docs |
| Trademark filing | Brand identity | Nothing downstream (it's protective) |
| Landing page | Brand identity + pricing | Dashboard signup flow (Phase 4 wizard) |
| MSA / DPA / SLA / AUP | Phase 3 platform architecture (sub-processor list, DR capabilities) | Every customer contract |
| Privacy + ToS | All of the above | Self-serve signup, agency portal |
| Pricing | Everything (it's the commercial summary) | Landing page + Stripe integration + sales playbook |
| Stripe integration | Phase 4 tRPC (CC13) + Phase 3 Postgres schema | Dashboard Settings → Billing panel (Phase 4 CC18) |
| REST API | Phase 4 tRPC (same data, different wire format) + Phase 4 API keys infrastructure | External customer integrations |
| Sales playbook | Brand + pricing + legal | Sales ops (people + tools) |
| Case study playbook | Any tenant 30+ days live | Landing page social proof + next sales cycle |

Nothing in Phase 5 lives in isolation. Every spec references artifacts from 1–4 and/or feeds into future customer interactions.

---

## The three persistent blockers (unchanged since Phase 3)

Phase 5 did not resolve any of the three fundamental blockers. All still need attention:

### 1. POC runbook still unrun
The Phase 1 Week-1 experiment runbook needs a real-world run before platform engineering commits further. If Proposal Builder fails on a real Fathom call, Phase 3/4 infrastructure is wrong-shaped. **Highest priority — block Phase 6 until complete.**

### 2. Product naming (C3a / OD-P5-1)
**Phase 5 made this more urgent, not less.** Every Phase 5 spec uses Clawd as the working name. The trademark filing window, the domains, the social handles are all vulnerable to someone else grabbing first. **Lock this decision before starting any Phase 5 implementation work.** If Clawd is wrong, we need to know within a week — not a month.

### 3. First customer dev trial
Phase 1 webhook receiver spec remains the best 5-day binary pass/fail brief. Unchanged recommendation.

---

## The artifact set so far

At end of Phase 5:

| Category | Files |
|---|---|
| Navigation & meta | 3 |
| Strategic & business | 6 |
| Phase 1 POC | 16 |
| Phase 2 agent suite | 78 |
| Phase 3 platform | 9 |
| Phase 4 dashboard | 11 |
| Phase 5 business & legal | 14 |
| **Total shipped** | **137** |
| Future phases pending | ~55 |

Phase 6 (ops runbooks) and Phase 7 (post-launch loops) remain. Phase 6 is valuable once Phase 3 services are actually running. Phase 7 starts when Customer #1 crosses 30 days live.

---

## What to do this week (concrete next steps)

1. **Lock OD-P5-1** (Clawd name). This is the single highest-leverage decision in the whole project right now.
2. **Register domains** (clawd.ai primary, plus .co.uk, .app, .io). £120, 15 minutes.
3. **Secure social handles** (Twitter/X, LinkedIn company page, Instagram, TikTok). Free, 30 minutes.
4. **Start CITMA attorney outreach** — three quote requests, pick one, brief them on the trademark filing brief. 1 hour.
5. **Engage UK commercial solicitor** — three quotes, pick one, send them the MSA/DPA/SLA/AUP/Privacy/ToS templates as starting points. 1 hour.
6. **Book Stripe UK account verification** — start Week 1 to front-load the 1–3 day delay.

If those six are done this week, Phase 5 is unblocked end-to-end. Every subsequent step has a documented spec to work from.
