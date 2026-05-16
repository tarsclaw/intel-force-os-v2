---
name: phase-5-business-legal
description: Phase 5 Business and Legal — brand identity, trademark, MSA/DPA/SLA/AUP/Privacy/ToS templates, pricing spec, Stripe integration, REST API spec, sales and case study playbooks. Use this skill whenever working on commercial terms, legal documents, pricing questions, customer contracts, brand guidelines, landing page content, billing, API design, or sales collateral. Also triggers on: MSA, DPA, SLA, pricing, contract, legal, billing, Stripe, brand, trademark, Intel Corp risk.
---

# Phase 5 — Business & Legal Skill

**Pack status:** Active reference. These documents get used per customer, per deal, per commercial decision.

## Where the spec lives

`docs/phase-5-business-legal/` — 14 files, ~6,508 lines

| File | When to use |
|---|---|
| `README.md` | Pack orientation |
| `brand-identity.md` | Any customer-facing asset, copy, design |
| `trademark-brief.md` | Trademark attorney consult, Intel Corp risk review |
| `landing-page-spec.md` | Building/updating intelforce.ai |
| `msa-template.md` | Any deal requiring a formal contract |
| `dpa-template.md` | Customer with DPA requirement (most enterprise) |
| `sla-template.md` | Customer asking for SLA |
| `aup-template.md` | Standard terms (applies to every customer) |
| `privacy-policy-template.md` | Website/app GDPR compliance |
| `terms-of-service-template.md` | Website/app ToS |
| `pricing-spec.md` | Any pricing conversation, invoicing, tier decision |
| `stripe-integration-spec.md` | Implementing subscription billing |
| `rest-api-spec.md` | Customer asks about API access |
| `sales-and-case-study-playbook.md` | Every customer call, case study construction |

## The commercial context

Intel Force OS is positioned as a premium SME AI service, not a cheap SaaS:
- £400-£4,500/month pricing range
- White-glove onboarding (manual in v1)
- Per-customer MSA + DPA for anything above Founding tier
- Monthly rolling contracts for Founding; annual for higher tiers

## Pricing — the source of truth

File: `pricing-spec.md`

### The tiers

| Tier | Price | Scope | Contract |
|---|---|---|---|
| **Founding** | £400/month flat | HR agent only, first 10 customers | Monthly rolling, 12-month price lock |
| **Starter** | £450/month | One agent, <100 employees | Monthly rolling |
| **Growth** | £1,800/month | All agents, <300 employees | Annual (15% discount if paid upfront) |
| **Scale** | £4,500/month | All agents + custom development | Annual |
| **Enterprise** | £10,000+ bespoke | Dedicated infra (Phase 3) | 1-3 year terms |
| **Agency Partner** | Bespoke | Multi-entity customers like Rigby | 1-3 year terms |

### The Agency Partner model

For customers like Rigby Group (parent with multiple group companies):
- Intel Force OS deployed across group entities
- Central Agency Partner Portal (Phase 4, built on demand)
- Pricing: £3,000-£8,000/month depending on entity count
- Contract: 1-3 year terms typical

See `pricing-spec.md` §5.

### Pricing anti-patterns

Don't do any of these:
- ❌ Discount Founding tier below £400
- ❌ Add per-seat pricing (confuses the flat proposition)
- ❌ Offer >14-day free trial
- ❌ Give tier features (e.g. multi-agent) to Starter customers "just this once"
- ❌ Negotiate price without value exchange (annual pre-pay, long commitment, case study participation)

## Legal documents — when to use which

### Every customer gets
- Acceptable Use Policy (AUP)
- Privacy Policy (shown at install)
- Terms of Service (agreed at install)

### Founding / Starter tier customers additionally get
- **Service Agreement** — simplified one-page agreement (see `pricing-spec.md` appendix)

### Growth tier and above get
- **MSA** (Master Service Agreement) — full legal agreement
- **DPA** (Data Processing Agreement) — GDPR-specific data protection
- **SLA** (Service Level Agreement) — uptime + response time commitments

### Templates are starting points, not final docs

The templates in this pack are solicitor-review-ready drafts. For any contract over £3,000/month or any enterprise deal, get actual solicitor review before signing. The templates save time; they don't replace legal advice.

## The brand

File: `brand-identity.md`

### Name evolution
- Started as "Clawd" (retained as internal reference)
- Renamed to **Intel Force OS** in Phase 5
- **Intel Corp trademark risk:** real but manageable — Intel Force Ltd operates in distinct goods/services class, but a watch list and defensive brand registration are recommended

See `trademark-brief.md` for full analysis.

### Visual identity
- Primary: emerald green `#10b981`
- Secondary: amber `#f59e0b` (used for escalation/attention)
- Neutral: zinc palette
- Font: system sans-serif (no custom font in v1)
- Tone: direct, warm, British

### Tagline
**"Drafts every reply. Sends nothing without you."**

This tagline is the product's core promise. It must appear on:
- Landing page hero
- Teams app description
- First page of any MSA
- Every demo introduction

Don't A/B test this tagline. It works.

## Stripe integration

File: `stripe-integration-spec.md`

### v1 (manual)
- Stripe Dashboard, one-off invoices per customer
- Subscription via Stripe Billing
- Manual payment reminders

### v1.5 (semi-automated)
- Self-serve Founding/Starter signup flow at intelforce.ai
- Stripe Customer Portal for customer to manage card
- Webhook into Cloudflare Worker: Stripe events → tenant config update

### v2 (Teams App Store billing)
- Microsoft Commercial Marketplace billing (20% Microsoft cut)
- Customer never leaves Teams to pay
- Integrated self-serve trial + conversion

Phase-appropriate: use v1 until ~3 customers. v1.5 around customer 5.

## The REST API (future)

File: `rest-api-spec.md`

A public REST API is specced for future customer integrations. Deferred because:
- No customer has asked for it yet
- v1 has the Worker as the "API" (internal only)
- Adding public API doubles attack surface

**When to activate:** specific customer request for programmatic integration. Typically Growth tier and up.

## Sales playbook

File: `sales-and-case-study-playbook.md`

### Demo structure (from §3)
1. Context setting (60s)
2. Three-scenario live demo (6 min)
3. Q&A (5 min)
4. Close for next step (always)

### Objection handling (from §4)
Standard responses for: price, trust, scope, timeline, competing tools, internal resistance.

Do NOT improvise objection responses. Use the scripts. If an objection isn't in the playbook, note it and add it.

### Case study template (from §6)
- Baseline metrics (pre-Intel Force OS)
- Implementation narrative
- Week 1 metrics
- Month 1 quote
- Ongoing quantitative impact
- Customer reference permission

First case study should be ready by the end of customer 1's first month live.

## Cross-references

- **Pricing** flows to `gtm-execution` skill (pricing sheet for prospect conversations)
- **Legal templates** referenced by `teams-hr-agent/04-deployment-guide.md` (customer onboarding)
- **DPA** flows to Phase 6 ops runbooks (GDPR DSAR handling)
- **Brand identity** flows to every UI skill (Adaptive Cards, landing page, dashboard)

## The honest state

Phase 5 is in excellent shape on paper. The gap is **execution**, specifically:
- Landing page hero (Pack 8) is shippable — deploy it
- MSA template is solicitor-review-ready — get it reviewed if not done
- Stripe integration spec is thorough — implement v1 when customer 1 signs
- Case study template is ready — requires a live customer

None of these need more specification. They need deployment.

## When NOT to use this skill

- For implementation code: `teams-hr-agent` skill
- For prospect acquisition tactics: `gtm-execution` skill
- For operational runbooks: `phase-6-ops-runbooks` skill

## One-sentence summary

Phase 5 is the commercial and legal backbone — templates and specs you consult per deal, per customer, per pricing conversation.
