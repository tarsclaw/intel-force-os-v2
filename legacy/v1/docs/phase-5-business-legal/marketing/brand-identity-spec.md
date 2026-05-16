# Brand & Identity Specification

**The product name, logo direction, voice, and visual identity that ties every tenant-facing touchpoint together.**

> **Audience:** the founder deciding on naming; the designer producing logo/identity; anyone writing copy in the dashboard, emails, or landing page.
>
> **Status:** v1.0. Name decision is still open as of this spec's writing — see §1 for the recommendation and §2 for the decision brief. Every other section assumes the recommended name is adopted; if another name is chosen, this spec is trivially find-and-replaced.
>
> **Commercial stakes:** this decision blocks trademark filing, domain registration, landing page build, logo design, and the opening-month of marketing. It needs locking before Phase 5 legal documents are executed.

---

## 1. Recommendation: Clawd

### 1.1 Why this name

- **Phonetic punch.** One syllable. Hard C. Easy to say over a phone call. Reads well as a heading. No awkwardness in voicemails ("hi, I'm calling from Clawd").
- **Category fit.** "Claw" suggests grasp, precision, handling — reasonable for an agentic system that works on your behalf. The "d" modifier leans it toward modern-tech.
- **Differentiation.** Not another "AI-sounding" name (no -ai suffix, no portmanteau of tech words, no Greek gods). Stands out in a category crowded with similar-sounding startups.
- **Self-referential in-product credibility.** Tasteful nod to Claude (the model underneath) without being derivative. A sophisticated customer will notice and connect the dots; an unsophisticated one won't be confused.
- **Domain + trademark availability** (needs verification — see §2).

### 1.2 Why not "IntelForce"

- **Trademark conflict with intelforce.org** (cybersecurity company, active)
- **ChatGPT store has "IntelForce GPT"** (smaller, but existent)
- **intelforce.com** for sale at a speculator price (adds cost + friction)
- Sounds generic — "Intel" + "Force" is a 2015-vibe brand
- No natural verb form (people say "run Clawd"; no-one says "run IntelForce")

The "IntelForce" naming was a working title inherited from earlier planning. It served while we built technical specs. For commercial launch it's actively hostile.

### 1.3 Other candidates considered

| Candidate | Verdict |
|---|---|
| Clawd | ✅ Recommended |
| Concierge AI | Too generic; crowded category; also many existing trademarks |
| Workbench | Generic; trademarked in dozens of adjacent categories |
| Forge | Generic + multiple existing products (AI Forge, Forge AI) |
| Pantry | Generic food connotation; poor fit |
| Sentinel | Overused in cybersecurity |
| Loom | Taken (Loom video) |
| Lex | Taken (Amazon Lex, Apple Lex) |
| Quill | Taken (many writing/AI products) |
| Compound | Too generic; already used in AI agents space |

Naming research was opportunistic, not exhaustive. If Clawd clears trademark checks, stop looking.

### 1.4 The "IntelForce" placeholder in the artifact set

All Phase 1–4 documents reference "IntelForce AI OS" as a working name. When Clawd (or chosen final name) is locked, a global find-and-replace across the artifact set takes ~30 minutes. Until locked, placeholder stays.

---

## 2. Decision brief — what to verify before locking

Before committing to Clawd, verify the following. Ideally same-day turnarounds so the name is locked within a week.

### 2.1 Trademark searches

- **UKIPO (UK):** search `clawd` across class 9 (software), class 42 (SaaS), class 41 (educational services if we ever do training). Free search at search.ipo.gov.uk.
- **EUIPO (EU):** search via euipo.europa.eu — same classes.
- **USPTO (US):** tsdr.uspto.gov — planning ahead for US expansion.
- **Common-law search:** Google "clawd ai", "clawd software", "clawd.com", "clawd.co", social handles on X, LinkedIn, Instagram.

Verdict needed: trademark available or not in each jurisdiction. Record findings in a shared doc with screenshots.

### 2.2 Domain availability

- **clawd.ai** — primary target
- **clawd.co.uk** — UK fallback
- **clawd.app** — consumer-facing alternative
- **clawd.io** — tech fallback
- **clawd.com** — ideal but likely taken or speculated

Check via a registrar (Namecheap, Gandi). Buy all available variants same-day as decision. Budget: ~£150 for 2–3 year reservations.

### 2.3 Social handles

Secure at minimum:
- X: @clawd or @clawdai or @useclawd
- LinkedIn company page
- GitHub organisation: `clawd-ai`
- Product Hunt

Cost: £0. Time to grab: 30 minutes.

### 2.4 Companies House

If "Clawd Ltd" is desired as the legal name (rather than "Intel Force Ltd" continuing to own the product):
- Search Companies House for "Clawd"
- If available and preferred, register Clawd Ltd (~£12) and make it the operating entity, with Intel Force Ltd as the holding company
- If Intel Force Ltd remains the operating entity, Clawd is just a trading/product name (simpler, no corporate restructuring needed)

Recommendation: keep Intel Force Ltd as legal entity. Operate "Clawd" as trading name. Saves legal/accounting complexity for MVP phase. Restructure if/when there's a material reason.

---

## 3. Visual identity (direction, not final)

### 3.1 Logo concept

Not prescribing a specific logo — that's designer work. Direction:

- **Wordmark over symbol.** Four letters, punchy — "Clawd" renders well as pure typography.
- **Custom letterforms welcome.** The "d" is the fingerprint — a slight swoop, a subtle curve — can make the mark ownable without a separate symbol.
- **Avoid:**
  - Claw imagery (too literal, cliche)
  - AI-cliché gradients (purple-to-pink, neon)
  - Animal mascots (pets, paws — we're not a consumer app)
  - Stamp/badge aesthetic (too many SaaS logos already look like beer labels)

### 3.2 Colour palette

Aligned with the dashboard design system (`phase-4-dashboard/architecture/design-system-spec.md` §2):

- **Primary:** Emerald `#10b981` — growth, action, success
- **Secondary:** Amber `#f59e0b` — attention, warmth
- **Anchor:** Black `#09090b` — seriousness, operator tool
- **Accent/neutral:** Zinc grey scale

The dashboard palette and the brand palette are the same. One source of truth. No separate "brand colours" divorced from the product.

### 3.3 Typography

- **Headline:** Inter Display (or Inter variable at heavier weight)
- **Body:** Inter
- **Monospace:** JetBrains Mono

Same as dashboard. No split between marketing-site type and product type.

### 3.4 Photography / imagery

- **Avoid stock-photo people in offices.** Everyone does this; it says nothing.
- **Prefer:** screenshots of the product itself, schematic diagrams, type-heavy layouts, restrained abstract patterns in brand palette.
- **If using photography:** real customers in real settings. No staged handshakes, no laptop-open-on-a-cafe-table.

### 3.5 Icon system

Lucide icons throughout. No custom icon set. One custom SVG (`HandshakeIcon` — covered in design-system spec). Consistent between dashboard and landing page.

---

## 4. Voice and tone

### 4.1 Voice pillars

- **Direct.** "Clawd runs your agents. You review what it produces." Not "Our cutting-edge AI-powered workflow automation platform revolutionises..."
- **Specific.** Numbers, examples, named features. "Your Proposal Builder drafts a proposal 4 minutes after the Fathom call ends." Not "Save time with automation."
- **Honest about limits.** "Everything drafts, nothing sends. A human approves before anything leaves your account." Not "Fully autonomous workforce."
- **Quiet confidence.** No hype superlatives. No "game-changing," "revolutionary," "unprecedented." The product is good; the copy doesn't need to sell harder than the product performs.
- **British English.** "Optimise", "behaviour", "catalogue". Serial comma optional. This is a UK product first.

### 4.2 What we don't do

- Exclamation marks in body copy. (Allowed in transactional UI: "Tenant live!" is fine.)
- Em-dashes-as-rhythm-beats. One per paragraph at most.
- Two-word sentences. Punchy. For effect. (We don't do this.)
- Apologetic deflection. "We're so sorry you're having trouble!" — not our voice. "That broke. Here's what happened and what we're doing about it." — our voice.
- "AI-powered." It's implicit and dilutive. Say what the product actually does.
- Calling customers "users." They're customers or tenants or operators, depending on context.

### 4.3 Example copy — same message in three voices

**Generic SaaS voice (avoid):**
> 🚀 Revolutionise your agency with AI-powered workflow automation! Our cutting-edge platform leverages advanced artificial intelligence to save you countless hours every week. Join hundreds of agencies already unlocking their potential! ✨

**Bro-founder voice (avoid):**
> Ship faster. Stop wasting time on proposals. We built the thing that finally works.

**Clawd voice (target):**
> A sales call ends at 4:47 PM. By 4:51, Clawd has drafted the proposal — with your pricing, your voice, and the specific objections raised on the call. You read it, adjust two lines, send. Your 9 PM is freed up.

---

## 5. Brand architecture

### 5.1 Single product, single brand

Clawd is the product. Clawd is the brand. No sub-product names (no "Clawd Agents", no "Clawd Studio" — just Clawd, with features named naturally: the Proposal Builder, the Brain view, the Operations dashboard).

### 5.2 Agents have names for utility, not branding

Proposal Builder, Lead Hunter, Client Onboarder, etc. — these are utility names. They describe what they do. They're not brand sub-personas with backstories. Avoid anthropomorphising beyond the job title.

### 5.3 Agency partners can co-brand (v1.1)

Agency partners (Rigby Group etc.) may want their sub-tenants to see their brand alongside or instead of Clawd's. Design system's white-label work is in Phase 4 Settings spec §9.3 and Agency Portal spec §15 — deferred to v1.1, but the architecture supports it: custom logo, custom email sender domain, custom support URL. Core brand remains Clawd unless contractually white-labelled.

---

## 6. Key taglines

Options for the landing page hero (designer's choice + A/B test later):

- **"The agents that actually ship."** — Contrasts with demo-ware AI tools that don't do real work.
- **"Your team's shadow workforce."** — Positioning against headcount vs positioning against tools.
- **"Draft. Review. Send."** — Describes the core promise in three words.
- **"Runs your operations while you sleep."** — UK-B2B professional services fit.
- **"The operating system for your agency's agents."** — Platform positioning (more ambitious).

Recommendation: start with "Draft. Review. Send." as the hero — it's concrete, describes the contract between Clawd and the customer (Clawd drafts, customer reviews, customer sends), and positions us away from the "autonomous agents" overclaim.

---

## 7. Naming conventions — within product + comms

| Thing | Canonical name |
|---|---|
| Company legal name | Intel Force Ltd (UK) |
| Product name | Clawd |
| Platform (all components collectively) | Clawd |
| The dashboard | Clawd dashboard |
| Individual agents | Proposal Builder, Lead Hunter, etc. (Title Case) |
| Tenant | "your Clawd" (informal), "the tenant" (technical) |
| Agent runs | "invocations" (internal), "runs" (customer-facing) |
| Escalations | "escalations" (consistent) |
| Vault | "Brain" (customer-facing), "vault" (technical) |

Note "Brain" is the customer-facing name for the vault, matching the dashboard view name (`/t/[slug]/brain`). We use "Brain" in marketing and in-product UI. "Vault" only appears in technical documentation.

---

## 8. Asset checklist

When the name locks:

### 8.1 Must-have before launch
- [ ] Logo (wordmark + favicon + 1:1 social profile square)
- [ ] Primary domain + SSL
- [ ] Email sender identity: hello@clawd.ai, security@clawd.ai, support@clawd.ai
- [ ] OG image for social link previews
- [ ] Landing page with hero + pricing + contact
- [ ] Basic brand-guide PDF (colours, typography, dos/don'ts) — 4–6 pages is plenty

### 8.2 Nice-to-have first month
- [ ] Social profile art (banner images for X, LinkedIn)
- [ ] Case study template (visual)
- [ ] Email signature template
- [ ] Deck template (Keynote/Figma)
- [ ] Pitch/demo video (2–3 minutes)
- [ ] Animated hero asset for landing page (optional — static works fine)

### 8.3 Deferred
- [ ] T-shirts, stickers, swag — not until paying customers
- [ ] Custom illustration style — expensive; not differentiating at our stage
- [ ] Branded merchandise — not until we have a reason

---

## 9. Identity design budget

Realistic budget for a designer to produce core identity:

| Scope | Budget |
|---|---|
| Logo + wordmark (3–5 iterations, final AI file) | £800–£2,000 |
| Brand guide PDF | £400–£800 |
| Landing page design (Figma, desktop + mobile) | £1,500–£4,000 |
| Social profile art | £200–£400 |
| **Total starter identity** | **£3,000–£7,000** |

Recommendation: work with one competent solo designer (not an agency). Agencies add overhead we don't need at this size. Good independents on Upwork, Dribbble, or Twitter — 2–3 week turnaround. Budget £5,000; expect £4,000 actual.

Alternative: do it internally. If Maddox (or Jack as web-design partner) wants to ship the first version, a Figma hero + a wordmark in Inter Bold gets you to launch. Hire a designer later when the product is proven. This is the lower-cost, more-iteration-feasible path. Recommended for true MVP.

---

## 10. When to revisit the brand

**Do not revisit within first 12 months of launch.** Brand iteration is a time-sink that substitutes for product work. The brand needs to live in the market for customers to even have opinions on it.

Trigger to revisit:
- Rebrand driven by a specific commercial need (enterprise deal requires a more "serious" look; new category positioning; merger)
- Clear customer feedback that the name/look is actively costing deals
- Expansion beyond UK where the name has cultural issues

None of these apply on day one. Ship the first identity; iterate based on actual data, not aesthetic debates.

---

## 11. Open decisions

**OD-P5-1:** Is the recommendation Clawd accepted? Decide within 7 days.
- If yes: proceed with trademark searches, domain purchase, identity design
- If no: propose alternative; return to §2 verification process

**OD-P5-2:** Intel Force Ltd as operating entity or spin up Clawd Ltd?
- **Recommendation:** Intel Force Ltd continues as operating entity; Clawd is trading name only. Revisit at Series A or first enterprise deal.

**OD-P5-3:** DIY identity vs paid designer for launch?
- **Recommendation:** DIY first version (wordmark in Inter Bold + palette from design system). Pay £3k–£5k for a designer within 3 months of launch once we've seen how the brand lives in market.

**OD-P5-4:** Register Clawd.ai or Clawd.co.uk as primary?
- **Recommendation:** Clawd.ai as primary (global, tech-native, clearly modern), Clawd.co.uk as alias (UK SEO + fallback), both must be owned.

---

## 12. Related

- `phase-4-dashboard/architecture/design-system-spec.md` — visual tokens that apply to the brand too
- `phase-5-business-legal/marketing/trademark-filing-brief.md` — what to file once the name is locked
- `phase-5-business-legal/marketing/landing-page-spec.md` — where the brand lives publicly
- `intelforce-ai-os-strategic-plan.md` (Session 0) — original positioning (now updated implicitly by this spec)
