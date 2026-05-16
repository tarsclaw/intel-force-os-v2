# Landing Page Specification

**The public front door of Clawd. What visitors see at clawd.ai. Structure, copy, conversion design, technical build.**

> **Audience:** founder approving copy; designer + frontend engineer building it; anyone writing marketing content that links to the site.
>
> **Status:** v1.0. Copy-complete; designer will refine on implementation.
>
> **Principle:** the landing page is a sales tool, not an art project. Every section exists to move a specific visitor segment one step closer to a trial signup or demo booking.

---

## 1. Audience and conversion goals

### 1.1 Who visits clawd.ai

Rough segments, in order of volume:

1. **Cold inbound** — found us via content, podcast mention, referral link
2. **Warm inbound** — heard Maddox talk about Clawd, came to investigate
3. **Signed-off buyers** — already decided; verifying we're real before booking
4. **Existing customers** — looking for support links, status page, docs

Segments 1 + 2 are the conversion targets. Segment 3 converts by not putting obstacles in their way. Segment 4 needs footer/nav discoverability of their actual destination.

### 1.2 Primary conversion goals (ranked)

1. **Demo booking** (highest value) — Growth/Scale/Enterprise tier target, higher LTV
2. **Trial signup** (volume) — Starter/Growth tier, self-serve path
3. **Contact form / sales inquiry** — Enterprise and agency partner leads
4. **Newsletter signup** (weak) — only for visitors not ready to buy

Every major section has a clear next step. No "dead-end" sections that admire themselves without offering a path forward.

### 1.3 What we're NOT optimising for

- **Vanity metrics** — time on page, scroll depth. Don't care.
- **SEO on broad keywords** — not our acquisition channel for v1; we'd lose to deep-pocketed competitors anyway
- **"Awareness"** at the expense of conversion — every section earns its place

---

## 2. Site structure

```
/ (home)                            ← this spec focuses here
/pricing                            ← see pricing-spec.md §3
/product                            ← deeper walkthrough of agents
/for-agencies                       ← agency partner landing subpage
/case-studies                       ← empty at launch; populated when first study ships
/docs                               ← public docs (subset of full docs)
/blog                               ← ships empty; grows organically
/security                           ← what we do on security (abridged DPA + TOMs)
/contact                            ← form + calendar link
/privacy                            ← Privacy Policy
/terms                              ← Terms of Service
/aup                                ← Acceptable Use Policy
/login                              ← redirects to dashboard Clerk flow
/status                             ← redirects to status.clawd.ai
```

### 2.1 Navigation (top)

Simple, 5 items maximum:
- **Product** (dropdown: Agents, For Agencies, How it works)
- **Pricing**
- **Customers** (empty at launch; renames to Case Studies when first study ships)
- **Docs**
- **Sign in** | **Start trial** (both on right, "Start trial" as the primary CTA)

### 2.2 Footer

Multiple columns:

- **Product:** Agents, Pricing, Security, Status
- **Company:** About, Blog, Contact
- **Resources:** Docs, Changelog, API reference
- **Legal:** Privacy, Terms, AUP, DPA (sample)

Plus:
- Copyright line: "© 2026 Intel Force Ltd. Clawd is a trading name of Intel Force Ltd, registered in England and Wales."
- Office address
- Email addresses: hello@, support@, security@
- Social links (X, LinkedIn)

---

## 3. Home page — section by section

Target: ~2,400px vertical on desktop; maybe 6–7 screen-heights scrolled.

### 3.1 Section 1 — Hero (above the fold)

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  [Clawd logo]                 Product  Pricing  Docs  Sign in  [CTA] │
│                                                                      │
│                                                                      │
│        Draft. Review. Send.                                          │
│                                                                      │
│        The agents that do your agency's operations —                 │
│        drafts, leads, content, follow-up, reporting —                │
│        while you handle the bits humans are for.                     │
│                                                                      │
│        [Start 14-day trial →]    [Book a demo]                       │
│                                                                      │
│        No credit card needed · 14 days · cancel anytime              │
│                                                                      │
│                                                                      │
│        [PRODUCT VISUAL — screenshot of dashboard,                    │
│         operations view with escalation feed]                        │
│                                                                      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

Copy:

**Headline:** `Draft. Review. Send.`

**Subhead:** `The agents that do your agency's operations — drafts, leads, content, follow-up, reporting — while you handle the bits humans are for.`

**Primary CTA:** `Start 14-day trial →` (links to Clerk signup with `intent=trial`)
**Secondary CTA:** `Book a demo` (opens Calendly)

**Trust line below CTAs:** `No credit card needed for trial · Cancel anytime · UK-hosted · GDPR-ready`

Actually — reconsidering trust line. "No credit card needed" contradicts §6.3.5 of pricing-spec which requires credit card at trial to reduce tyre-kickers. Resolve: keep credit card requirement; trust line becomes:

`14-day trial · Secure UK hosting · GDPR-ready · Cancel anytime`

**Visual:** high-fidelity screenshot of the Operations Control view showing real-looking but obviously-demo data. Multiple escalations visible, cost module showing healthy numbers, running-now showing one agent active. Not a gradient-background abstract — a screenshot.

### 3.2 Section 2 — Social proof bar (slim)

Right under the hero. Just a quiet band of logos or, if we don't have logos yet, a quieter placeholder:

```
─────────────────────────────────────────────────────────────
  Trusted by UK agencies and professional services teams
  [logo] [logo] [logo] [logo] [logo] [logo]
─────────────────────────────────────────────────────────────
```

At launch we won't have logos. Alternatives:

- **Omit this section entirely** until we have 3+ real customers to display (honest)
- **Replace with a quieter stat**: "Built in the UK. Hosted in the UK. Answering to the UK." (if we want something to fill the space without misrepresenting)

**Recommendation:** omit until we have logos. The absence is less awkward than "used by 100+ agencies" with no proof.

### 3.3 Section 3 — The 3-step promise

```
─────────────────────────────────────────────────────────────

  How Clawd works

  1.  Plug in your tools.
      Fathom, HubSpot, Gmail, Stripe. Whatever you already use.
      Clawd listens.

  2.  Agents do the work.
      A sales call ends. Clawd drafts the proposal. A blog post
      goes live. Clawd repurposes it into eight variations.
      A prospect goes quiet. Clawd drafts the follow-up.

  3.  You review and send.
      Everything Clawd produces is a draft. You approve what
      goes out. Humans stay in charge of every decision that
      reaches a client.

─────────────────────────────────────────────────────────────
```

Visual: three columns, one per step. Icons (Lucide `Plug`, `Loader`, `Send`) at the top of each. Bold first line, smaller explanation below. No "watch a 3-minute video" CTA — the video lives on the product page.

### 3.4 Section 4 — The agents

Grid of cards introducing each agent. One line per agent.

```
─────────────────────────────────────────────────────────────

  Ten agents, working together.

  ┌────────────────────┬────────────────────┬────────────────────┐
  │ Proposal Builder   │ Lead Hunter        │ Client Onboarder   │
  │ Drafts proposals   │ Finds prospects    │ Runs first-week    │
  │ from sales-call    │ matching your ICP  │ welcome sequences  │
  │ transcripts.       │ across LinkedIn,   │ for new clients.   │
  │                    │ web data, CRM.     │                    │
  ├────────────────────┼────────────────────┼────────────────────┤
  │ Content Creator    │ Repurposer         │ Caption Writer     │
  │ Drafts long-form   │ Turns one asset    │ Writes social      │
  │ articles from your │ into eight: email, │ captions in your   │
  │ brand voice.       │ X, LI, YouTube…   │ voice for posts.   │
  ├────────────────────┼────────────────────┼────────────────────┤
  │ Follow-Up Pilot    │ Reporting Engine   │ SOP Writer         │
  │ Drafts follow-ups  │ Pulls monthly      │ Turns a screen     │
  │ for prospects who  │ client reports     │ recording into a   │
  │ went quiet.        │ from your data.    │ written SOP.       │
  └────────────────────┴────────────────────┴────────────────────┘

  (+ Librarian — keeps everything tidy behind the scenes)

  [See all agents →]

─────────────────────────────────────────────────────────────
```

Visual: dense card grid. Each card has agent icon (from Phase 4 design system §6.1), agent name as heading, one-line description.

Linking: each card links to `/product#[agent-slug]` — the deep product page has a fuller section per agent.

### 3.5 Section 5 — Why Clawd (differentiator)

Three blocks, one paragraph each. Addresses the "why not just use ChatGPT?" question head-on.

```
─────────────────────────────────────────────────────────────

  Why Clawd (not a chat window)

  ┌─────────────────────────────────────────────────────────┐
  │  It uses YOUR data.                                     │
  │                                                         │
  │  Every agent starts with what you already wrote —       │
  │  past proposals, your brand voice, your services.      │
  │  Not a generic template with your name pasted in.      │
  │                                                         │
  │  Your writing, at scale.                                │
  └─────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────┐
  │  It runs on triggers, not prompts.                      │
  │                                                         │
  │  A sales call ends. An email arrives. A deal closes.    │
  │  Clawd notices and produces a draft — you don't type    │
  │  anything. It's work happening, not a tool you use.    │
  │                                                         │
  │  Automation, not assistance.                            │
  └─────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────┐
  │  It escalates when it's uncertain.                      │
  │                                                         │
  │  When the data is weak, the policy is unclear, or the   │
  │  output might embarrass you — Clawd stops and asks.     │
  │  Not every agent vendor will tell you that.             │
  │                                                         │
  │  Honest uncertainty, not false confidence.              │
  └─────────────────────────────────────────────────────────┘

─────────────────────────────────────────────────────────────
```

Visual: three stacked panels. Light divider between them. First-line copy in larger weight; body paragraph below; pull-quote line at end in accent colour.

### 3.6 Section 6 — Pricing teaser

A single card with the Growth tier highlighted. CTA to full pricing page.

```
─────────────────────────────────────────────────────────────

  Pricing that matches what you'd pay for a team.

  Growth — £1,800/month
  The full agent workforce: 9 agents, 5 integrations, 3 seats.
  Less than a week of a junior account manager.

  [See all plans →]  [Start 14-day trial →]

─────────────────────────────────────────────────────────────
```

Keep this short. Full detail lives at `/pricing`.

### 3.7 Section 7 — Security & trust

```
─────────────────────────────────────────────────────────────

  Where your data lives

  ✓  UK-hosted.   Hetzner UK primary, AWS London secondary.
  ✓  Encrypted.   At rest with per-tenant keys; in transit
                  with TLS 1.3.
  ✓  Isolated.    One customer can never see another's data.
                  Row-level security and tenant containers.
  ✓  Auditable.   Every action is logged. 7-year retention
                  for compliance.
  ✓  GDPR-ready.  Full DPA and Sub-processor list available
                  on request.

  [Security overview →]  (links to /security page)

─────────────────────────────────────────────────────────────
```

No exaggerations. Everything here is real per Phase 3 specs.

### 3.8 Section 8 — For agencies teaser

Half-width block inviting agency partners to the dedicated page.

```
─────────────────────────────────────────────────────────────

  Running multiple brands? You need an agency partner account.

  A portfolio view across all your sub-brands. Roll-up billing.
  Shared team. Onboarding queue. Built for agencies from day one.

  [Agency partner pricing →]

─────────────────────────────────────────────────────────────
```

Links to `/for-agencies`.

### 3.9 Section 9 — FAQ (compact)

6 questions, accordion style. No multi-paragraph answers — keep it scannable.

1. **Who is Clawd for?** — UK-based agencies, professional services firms, and consultancies with repeatable workflows (proposals, reporting, content). Not a consumer tool; not a chatbot.

2. **Does it replace my team?** — No. It gives them superpowers on the repetitive bits. You still need humans for judgement, relationships, and things Clawd escalates on.

3. **How does it handle our brand voice?** — We extract a voice profile from samples you provide — 5+ pieces of your writing. Every agent references it. Adjustable; improves over time.

4. **Can I trust it not to send something bad?** — "Everything drafts, nothing sends" is our design principle. Clawd writes, you approve. Nothing leaves your account without a human saying yes.

5. **What if the AI makes a mistake?** — It will, occasionally. You're reviewing. We also have validation hooks on every agent that catch common errors before they reach you. And the agent escalates when it's uncertain.

6. **How fast can I go live?** — Growth-tier onboarding is 24–48 hours once you have your first integrations connected. Operator-led, so you're not figuring anything out alone.

### 3.10 Section 10 — Final CTA

```
─────────────────────────────────────────────────────────────

  Ready to see your drafts at 9am tomorrow?

  [Start 14-day trial →]    [Book a demo]

─────────────────────────────────────────────────────────────
```

Repeated primary/secondary CTAs. Last chance before footer.

---

## 4. Copy principles (enforced across all sections)

From `brand-identity-spec.md §4`, reiterated because landing page is where voice lives most visibly:

- **No exclamation marks** anywhere in body copy
- **No "revolutionary", "cutting-edge", "game-changing", "unleash your potential"** — not negotiable
- **No "AI-powered"** — say what it does
- **British English** — "optimise", "colour", "behaviour", "personalise"
- **Serial comma** — yes (readability in business copy)
- **Numbers over adjectives** — "10 agents" not "many agents"; "£1,800/month" not "affordable"
- **Verbs up front** — "Draft. Review. Send." not "Drafting, reviewing, and sending simplified"
- **No testimonial fabrication** — leave review sections empty until we have real quotes

---

## 5. Mobile considerations

- Hero: headline wraps gracefully; subhead truncates if needed; CTAs stack vertically
- Agent grid: 3 cols → 1 col on `<640px`
- FAQ: always accordion; expanded state shows full answer
- Sticky nav: logo + "Start trial" CTA remain visible on scroll (nav items collapse to hamburger)
- Product screenshot in hero: switches to a mobile-friendly crop (not a shrunken desktop shot)

Performance target: Lighthouse score 90+ on mobile. Hero image inline-preload'd. No web fonts loaded blocking (system fallback → Inter swap).

---

## 6. Technical build

### 6.1 Stack

Separate Next.js app: `apps/marketing/` in the monorepo (per Phase 4 OD-P4-B).

- Next.js 15, App Router
- Static generation (SSG) where possible — pricing, home, security, all static content
- Only contact form uses a server action (submits to a lightweight API route that emails hello@)
- Tailwind CSS, same tokens as dashboard (design system shared via `packages/ui/`)
- Deployed to Cloudflare Pages or Vercel — both work for a marketing site; we do NOT self-host this one (no data residency concern for the static site)

### 6.2 Why separate from dashboard

- Marketing ships weekly; dashboard ships when needed — different cadences
- Marketing can aggressive-cache; dashboard can't
- Marketing perf budget different from dashboard perf budget
- Marketing experiments (A/B copy tests, different hero variants) don't touch production platform

### 6.3 What's intentionally NOT on the landing page

- Third-party chat widgets (Intercom, Drift) — add friction, look dated, often contain analytics we don't want
- Live chat — not resourced for v1; use contact form
- Pop-up exit intent / "wait, don't go!" modals — anti-pattern, destroys trust
- Cookie-hungry marketing analytics — Plausible is enough (see §8)
- Social-login buttons — confuses signup vs trial intent
- Calculators or ROI tools — nice-to-have, distraction from the main CTA

### 6.4 Forms

Two forms:
- **Contact form** (`/contact`) — name, email, company, message. Honeypot for spam. Sends to hello@clawd.ai via Resend.
- **Newsletter signup** (footer only) — email address. Creates a contact in our email marketing tool (whatever we use — probably a basic Buttondown or ConvertKit).

Both forms use server actions, not JavaScript-dependent client-side submission. Graceful degradation.

### 6.5 Calendar booking

- Embedded or linked Calendly (or Cal.com, which some customers will see as better-aligned given Cal.com is open-source)
- Events: "15-min intro", "30-min demo"
- Time zone awareness
- Available slots controlled by Maddox's calendar

### 6.6 Performance

- Core Web Vitals all green on mobile + desktop
- LCP < 1.5s; FID < 100ms; CLS < 0.1
- Images: Next/Image with WebP, AVIF; explicit width/height
- Fonts: Inter loaded via `@next/font` with `display: swap`
- CSS: Tailwind purge + critical CSS inlined in head

---

## 7. Content updates

### 7.1 Who owns what

- **Copy** (headlines, body text, FAQ): founder. Revise frequently based on what prospects ask in sales calls.
- **Visuals** (screenshots, icons): designer or screenshot-ops; weekly refresh acceptable as product evolves
- **Legal links** (footer): founder + solicitor; update when legal docs update
- **Blog**: ships empty; build organically from actual customer insight or technical deep-dives

### 7.2 Iteration cadence

Month 1–3 post-launch: expect 2–4 significant copy iterations as we see what prospects actually react to. Track:
- Hero CTA click-through rate (trial vs demo)
- Pricing page visit rate
- Contact form submission rate
- Time-to-contact vs time-to-trial (which comes first tells us buyer shape)

Month 4+: stabilise; iterate based on specific data rather than intuition.

---

## 8. Analytics

### 8.1 Minimum viable telemetry

- Plausible Analytics (privacy-friendly, EU-hosted, no cookie banner needed) — page views, referrers, aggregate journeys
- Server logs (via Vercel/Cloudflare) — for ops
- Stripe Checkout events — conversion funnel from trial start → paid

No Google Analytics, no Hotjar, no session replay. Creates privacy obligations and cookie-banner complexity for minor insight.

### 8.2 Key metrics to watch

Month 1 targets (post-launch):
- 500+ unique visitors/month (modest; we're not running paid)
- 3%+ visitor-to-trial conversion
- 0.5%+ visitor-to-demo-booking conversion
- 40%+ trial-to-paid conversion

These are educated guesses, not promises. Calibrate after first month's data.

---

## 9. Launch checklist

Pre-launch, before flipping DNS to make clawd.ai live:

- [ ] All sections copy-complete and signed off by founder
- [ ] Legal pages (Privacy, Terms, AUP) reviewed by solicitor
- [ ] Screenshots free of customer data (use demo tenant only)
- [ ] Mobile responsive tested on iOS Safari, Android Chrome
- [ ] Accessibility: keyboard navigation, screen-reader smoke test, colour contrast pass
- [ ] Core Web Vitals green on PageSpeed Insights
- [ ] All forms tested (submit → email received)
- [ ] Calendar booking flow tested end-to-end
- [ ] Trial signup → Clerk → dashboard flow tested
- [ ] Security headers (CSP, X-Frame-Options, Referrer-Policy)
- [ ] HTTPS + HSTS preload
- [ ] Sitemap.xml and robots.txt
- [ ] OG tags for link previews (LinkedIn, X, Slack)
- [ ] Favicons (all sizes)
- [ ] 404 page
- [ ] Internal link-check (no broken routes)
- [ ] Status page subdomain set up (`status.clawd.ai`)
- [ ] DMARC/SPF/DKIM configured for email sender domain

---

## 10. Post-launch iteration

### 10.1 First month

- Weekly review of analytics
- Log every pre-sales objection a prospect raises; add to FAQ or address in hero
- Replace demo screenshots with real-customer screenshots (anonymised) once first paying customer is live
- A/B test hero headline (ideally 2–3 variants) via Plausible goal tracking

### 10.2 Month 3 milestone

- First case study: live, linked from homepage, replacing "Customers" nav placeholder
- Refreshed copy based on 3 months of sales calls
- Possibly: logo strip if we have 3+ customers comfortable with logo usage

### 10.3 Month 6

- Consider if blog deserves activation (if the founder has 1h/week consistently for 3 posts)
- Revisit hero copy with hindsight on what converts
- Add video (90-second product tour) if the founder can record one cleanly

---

## 11. What goes on each secondary page (brief)

### /product
Deeper agent-by-agent walkthrough. Each agent has:
- What it does
- What it needs (integrations, data)
- What it produces (example outputs, blurred)
- When it runs (triggers)
- How it escalates

### /for-agencies
Agency partner positioning. Different hero, same structure:
- Portfolio view screenshot
- "One login, every brand"
- Rigby-Group-style case (anonymised) if available
- CTA: "Talk to us about agency pricing"

### /pricing
Per `pricing-spec.md §3`.

### /security
Abridged version of DPA Annex A (TOMs), suitable for customer procurement due diligence. Includes sub-processor list, certifications (as earned), downloadable summary PDF.

### /docs
Public subset of the customer-facing dashboard docs. Focused on "what's Clawd, how does it work" rather than deep admin topics (those stay behind login).

### /blog
Empty at launch. First post: "Why we built Clawd" or similar founder note. Second post timed with first case study.

### /contact
Form + email addresses + office address + calendar link.

### /privacy, /terms, /aup
Per `legal/` files.

---

## 12. Open decisions

**OD-P5-19:** Marketing site on Vercel or Cloudflare Pages?
- **Recommendation:** Cloudflare Pages. Free at our scale, same provider as our WAF and DNS, simpler vendor footprint. Vercel is fine; not a material difference.

**OD-P5-20:** Logo strip now or wait for real logos?
- **Recommendation:** Wait. Leaving the section empty is more honest than placeholder logos.

**OD-P5-21:** Blog at launch?
- **Recommendation:** Ship `/blog` route with a single "Why we built Clawd" post; don't promise a cadence we can't keep.

---

## 13. Related

- `brand-identity-spec.md` — voice, palette, typography
- `pricing-spec.md` — full pricing page spec
- `legal/*` — Privacy, Terms, AUP linked from footer
- `playbooks/sales-playbook.md` — demo-booking CTA goes here
- `phase-4-dashboard/architecture/design-system-spec.md` — shared tokens

---

*This spec gets the landing page launched. It will change — fast — as soon as we start seeing real visitor behaviour.*
