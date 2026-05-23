# UK SaaS legal setup — first-time founder guide

**Status:** Reference (operations playbook for a founder who has never done business legal before)
**Date:** 2026-05-23 (Day 12)
**Audience:** Maddox / founder; first-time business legal posture
**Author:** Claude Code (NOT a lawyer; this guide is research + framing, not legal advice)
**Replaces:** the simpler `seedlegals-engagement-queries.md` guide which assumed prior knowledge.

**The most important sentence in this document:** I am not a lawyer, this is not legal advice, and you should not sign any document — pilot LOI, DPA, NDA, customer agreement — without an actual UK-qualified solicitor reviewing it first. The cost of legal review is far less than the cost of getting GDPR or liability wrong.

---

## §1 — What you're actually building (legal lens)

Intel Force OS is a B2B SaaS that:

1. **Processes personal data** (candidate names, contact details, salary information, free-text edits) on behalf of UK recruitment agencies. This makes you a **data processor** under UK GDPR Article 28.
2. **Takes autonomous actions** on behalf of recruitment agencies (LinkedIn messages, Bullhorn writes, payment reminders). This creates **professional liability** — if your AI sends a wrong payment chase to a settled invoice, the agency may be liable to the candidate; they may seek to pass that liability to you.
3. **Will hold pilot customer data on Hetzner Germany** (already provisioned). Cross-border data processing under UK GDPR — the data leaves the UK to the EU, which is currently OK under the UK-EU adequacy decision but requires documentation.
4. **Will sign pilot LOIs and eventually customer agreements.** These are commercial contracts under English law (assuming UK customers); standard SaaS clauses apply.

**Three legal pillars you need to set up:**

| # | Pillar | Why | When needed |
|---|---|---|---|
| 1 | **ICO data controller registration** | Legally required if you process personal data. Cheap (£40-£60/year). Easy to do online. | NOW (before first pilot processes any data) |
| 2 | **GDPR Art. 28 DPA** (Data Processing Agreement) | Legally required for B2B data processing. Your pilot customers will demand one. | Before first pilot signs |
| 3 | **Pilot LOI / commercial agreement** with liability cap + auto-send liability split | Defines the commercial relationship. Without it, all liability defaults to "whoever the court finds responsible" — usually expensive. | Before first pilot signs |

**Two things you'll need shortly after (not blocking pilot signature):**

| # | What | Why |
|---|---|---|
| 4 | **Professional indemnity (PI) insurance** | Real cover for AI mistakes. Pilot tenants will likely require this as a clause in the LOI. Expect £600-£1,500/year minimum for £1-2m cover. |
| 5 | **Customer-grade SaaS subscription agreement** | For when pilots convert to paid customers. Heavier than the LOI; can wait. |

---

## §2 — What "doing this correctly" actually looks like

You have three real paths. Pick one, not all.

### Path A — Cheap + fast (SeedLegals + one solicitor review)

| Step | What | Cost | Time |
|---|---|---|---|
| 1 | Free 30-min consultation with 2-3 UK SaaS solicitors. Goal: understand if SeedLegals templates are sufficient for *your* specific data-processing posture, OR if you need bespoke drafting. Most solicitors offer a free first call. | £0 | ~1.5 hours of your time across 2-3 calls |
| 2 | If they say SeedLegals is fine for pilot stage → engage SeedLegals (the existing `seedlegals-engagement-queries.md` guide). | £500 | 1 week wall-clock |
| 3 | When SeedLegals delivers the templates, pay one solicitor to spend 1 hour reviewing them. They'll either bless the documents or flag specific clauses to amend. | £150-£300 | 2-3 days wall-clock |
| 4 | Register with ICO (data controller) | £40-£60 | 15 min online |
| 5 | Talk to a PI insurance broker (separate workstream) | Initial quote free | 1 week |

**Total cash to first pilot signature: ~£700 + £40 ICO fee + insurance premium.**

This is what most pre-seed UK SaaS founders do. SeedLegals templates are real, drafted by solicitors, and used by thousands of UK startups. The risk: their templates are generic — they may not capture the specific liability nuances of *autonomous AI agent action*. Step 3 (the solicitor review) closes that gap.

### Path B — Comprehensive (specialist tech solicitor, full bespoke)

| Step | What | Cost | Time |
|---|---|---|---|
| 1 | Free 30-min consultation with 2-3 UK tech/SaaS solicitors | £0 | ~1.5 hours of your time |
| 2 | Engage one to draft the full package: DPA + LOI + Mutual NDA + early customer agreement template. Bespoke for IFOS's AI autonomy posture. | £1,500-£4,000 | 2-4 weeks |
| 3 | Register with ICO | £40-£60 | 15 min |
| 4 | PI insurance broker | Quote free | 1 week |

**Total cash to first pilot signature: ~£2,000-£4,500 + £40 + insurance.**

Heavier upfront but the documents are tailored to your specific risk profile (AI agents, autonomous actions, multi-tenant data processing). Worth it if Path A's solicitor review (Step 3) surfaces multiple concerns about template fitness.

### Path C — Hybrid (recommended for a first-time founder building AI SaaS)

1. **Free consultations first** — talk to 3 solicitors. This is non-negotiable for a first-time founder. You learn what UK SaaS legal infrastructure actually looks like for free.
2. **Make an informed choice between A and B based on the consultations.** If 2-of-3 solicitors say "SeedLegals is fine for pilot stage," Path A. If 2-of-3 say "your AI autonomy posture needs bespoke drafting," Path B.
3. **Don't skip the consultations** even if Path A looks attractive. The consultations themselves are the most valuable step — they tell you what you don't know.

**My recommendation: Path C, executing toward Path A unless the consultations push you to Path B.** This is the lowest-risk-highest-learning path for a first-time founder.

---

## §3 — Who to talk to (specific UK firms)

These are public firms with known UK tech/SaaS focus. **I have NOT independently verified their current quality, pricing, or availability.** Names provided so you have starting points; do your own diligence.

### Generalist UK tech/SaaS solicitors (free consultation likely)

- **Bowers Anderson** (bowersanderson.com) — UK SaaS specialists, mid-market clients. Tech contracts focus.
- **Ashfords LLP** (ashfords.co.uk) — tech sector group; mid-tier firm with startup-friendly hourly rates.
- **Bird & Bird** (twobirds.com) — bigger firm but their fintech/SaaS group does pre-seed work; ask for their "early-stage tech" rate card.
- **Sparqa Legal** (sparqa.com) — online + solicitor hybrid; cheaper than traditional firms.

### GDPR / data-protection specialists (worth one consultation if your data posture worries you)

- **Bristows LLP** (bristows.com) — IP + data protection specialists.
- **Linklaters Sigma** (linklaters.com) — large-firm "lite" service for tech.
- **Privacy Helper** (privacyhelper.io) — DPO-as-a-service, useful if you need ongoing GDPR cover at scale.

### Faster online options (template-driven, lower review depth)

- **SeedLegals** (seedlegals.com) — the cheapest fastest path, used by thousands of UK startups. Their templates are real but generic.
- **Pocketlaw** (pocketlaw.com) — similar shape to SeedLegals, slightly more enterprise.
- **LawBite** (lawbite.co.uk) — UK-focused, solicitor-backed online platform.

### Insurance brokers (PI insurance specialists)

- **Hiscox** (hiscox.co.uk) — well-known UK SaaS PI provider.
- **Vouch** (getvouch.com) — newer, startup-focused, online quotes.
- **Markel** (markel.com) — UK SaaS PI, well-regarded.
- **PolicyBee** (policybee.co.uk) — startup-friendly broker; aggregates quotes from multiple insurers.

---

## §4 — What to ask in the free consultations

Bring this list. Most solicitors will give you a 30-min free initial call. Cover as many as you can.

### Questions about your data posture (Pillar 1 + 2)

1. *"I'm processing recruitment candidate data (names, contact, salary) on behalf of UK recruitment agencies. I'm a data processor under UK GDPR. Do I need anything beyond a standard Art. 28 DPA template — given my data is processed on Hetzner Germany under the UK-EU adequacy decision?"*
2. *"My AI agents make autonomous edits to candidate-facing communications and trigger autonomous actions (LinkedIn sends, Bullhorn writes, payment chases). Where does liability sit for AI mistakes? What's the standard liability split — and do SeedLegals or off-the-shelf templates capture it?"*
3. *"My pilot tenants will store free-text edits from consultants reviewing AI drafts. These edits may contain candidate PII. I'm planning a 90-day raw-text retention then bounded purge. Is 90 days defensible under UK GDPR Art. 5(1)(e) data minimisation for this use case?"*
4. *"Do I need ICO data controller registration, processor registration, or both?"*

### Questions about pilot LOIs (Pillar 3)

5. *"What's a standard liability cap for a pre-revenue UK SaaS pilot? I'm thinking £10k cap mutual. Is that defensible if a pilot tenant suffers AI-caused damage?"*
6. *"My pilot agreement will need to address auto-send liability — if my AI sends an incorrect payment reminder, who's liable: me, my tenant, or the candidate? How do I structure that?"*
7. *"What's the difference between a Letter of Intent (LOI) and a binding pilot agreement? Do I need both?"*

### Questions about insurance (Pillar 4)

8. *"What level of professional indemnity insurance is standard for a UK SaaS pre-revenue, expected 3-6 pilots in 2026 H2? I'm budgeting £1m PI + £1m public liability."*
9. *"Should I also carry cyber liability separately?"*

### Questions about the path forward (Path A vs B)

10. *"Given my situation, is SeedLegals sufficient for my pilot-stage legal setup, or should I engage you (or another solicitor) for bespoke drafting?"*
11. *"If I use SeedLegals for templates, would you do a one-hour review of the delivered documents for £150-£300?"*
12. *"What's your hourly rate, and do you offer fixed-fee packages for startup legal setup?"*

---

## §5 — The order of operations (next 7 days, realistic)

This is what I'd actually do, in order, if I were you with zero legal background.

**Today (2026-05-23, Saturday — book emails for Monday):**

1. ICO registration (15 min online): https://ico.org.uk/for-organisations/data-protection-fee/self-assessment/ — you'll need basic company info. £40-£60.
2. Email 3-4 solicitors from §3 above asking for a 30-minute free consultation. Template email below.
3. Email 1-2 PI insurance brokers asking for a quote — same template structure.

**Monday-Wednesday next week (2026-05-25 to 27):**

4. Hold the 3 free consultations. Take notes during each.
5. Decide Path A or Path B based on what 2-of-3 solicitors recommend.
6. If Path A: engage SeedLegals on Wednesday following the existing guide.
7. If Path B: engage the most-aligned solicitor.

**Thursday-Sunday (2026-05-28 to 31):**

8. Wait for templates to arrive.
9. Get PI insurance quotes back; pick a broker.
10. Save all responses to `docs/operations/legal-setup-*.md` and update Risk #10 status.

**Following Monday (2026-06-01):**

11. Templates back from either SeedLegals (Path A) or solicitor (Path B).
12. If Path A: pay the £150-£300 hourly fee to one solicitor for a 1-hour review of the delivered templates.

**Total wall-clock: ~10 days. Total cash: £200-£4,500 depending on Path A/B.**

---

## §6 — Solicitor outreach email template

Copy this, customise the firm name + your details, send to each:

> Subject: Free consultation request — UK B2B SaaS legal setup (recruitment AI)
>
> Hi [Firm name] team,
>
> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — a B2B SaaS that integrates AI agents into UK recruitment agencies' workflows. We're pre-revenue, planning to sign our first pilot agreements in the next 4-6 weeks.
>
> I'm a first-time founder and need to set up the legal foundations correctly before pilots start processing data. Specifically:
>
> 1. A GDPR Art. 28 DPA template (we're a data processor; pilot customers are data controllers)
> 2. A pilot LOI / agreement with liability cap + AI-action liability split
> 3. ICO data controller / processor registration confirmation
> 4. Mutual NDA for pilot conversations
> 5. Guidance on professional indemnity insurance requirements
>
> Our specific risk profile includes autonomous AI agents making bounded edits to candidate communications and triggering actions in third-party systems (Bullhorn, LinkedIn, payment systems). I want to ensure liability is appropriately allocated.
>
> Would you be open to a 30-minute free initial consultation in the next week to discuss whether your firm could support our setup, your hourly rates, and your view on the right approach?
>
> Available times this week: [your availability]
>
> Best,
> Maddox Rigby
> Founder, Intel Force Ltd
> [your email]
> [your phone]

---

## §7 — PI insurance broker email template

Same shape:

> Subject: Professional indemnity quote — UK B2B SaaS (recruitment AI agents)
>
> Hi [Broker name],
>
> I'm Maddox Rigby, founder of Intel Force Ltd, a pre-revenue UK B2B SaaS building AI agents for UK recruitment agencies. We're targeting our first 3-6 pilot agreements in 2026 H2 and need professional indemnity cover before signing.
>
> Our risk profile:
> - AI agents make autonomous actions on behalf of pilot customers (LinkedIn messages, Bullhorn data writes, payment reminders)
> - All bounded by tier-based safety policies; high-risk actions require human approval; lowest-risk actions can be unsupervised
> - Pilot customers are UK recruitment agencies; we process candidate PII on their behalf
> - Hosted on UK-EU infrastructure (Hetzner Germany, UK-EU adequacy decision applies)
>
> Initial coverage targets:
> - £1m professional indemnity (errors/omissions for AI-caused damage)
> - £1m public liability
> - Cyber liability — would appreciate your recommendation on level
>
> Would you provide a quote? Happy to share more about our autosend-safety-policy on a call.
>
> Best,
> Maddox Rigby
> Founder, Intel Force Ltd

---

## §8 — What to do RIGHT NOW (the absolute minimum today)

If you only do one thing today: **register with ICO**. It's £40-£60, takes 15 minutes online, and you legally need it before processing any UK personal data. This includes Hetzner-stored candidate PII in your test tenant.

URL: https://ico.org.uk/for-organisations/data-protection-fee/self-assessment/

You'll answer a few self-assessment questions, pick the right tier (small SaaS = tier 1 typically), and pay online. Save the confirmation as `docs/operations/ico-registration-2026-05-XX.md`.

After that: send the solicitor emails Monday morning. The free consultations are the single highest-value step.

---

## §9 — What I (Claude) will track

When you complete each step, tell me. I'll:

- Update D2 / D3 / R3 / Risk #10 status in `RISK-REGISTER.md`
- Save responses + correspondence to `docs/operations/legal-*.md` files (audit trail)
- Update `bullhorn-integration-path.md` with any UK-data-residency confirmations from solicitors
- Cross-reference with `tenant-lifecycle.md` §4 (Offboard) which has UK GDPR right-to-erasure pattern
- Flag any contradictions between solicitor advice and our existing architecture

**I will NOT:**
- Make legal recommendations beyond research framing
- Tell you which solicitor to pick
- Vouch that any template is sufficient for your specific situation
- Replace actual legal review

---

## §10 — Status

**Reference.** First-time-founder legal setup guide. Replaces `seedlegals-engagement-queries.md` as the primary playbook (the queries doc remains useful — it's pre-drafted questions for SeedLegals once you've chosen that path).

**Founder action sequence:**
1. ICO registration today (15 min, ~£50)
2. Solicitor consultation emails Monday morning (~30 min to draft + send)
3. PI insurance broker emails Monday morning (~20 min)
4. Free consultations Mon-Wed next week (~3 hours)
5. Path A or B decision Wed-Thu
6. Templates arrive following week (~5-10 days wall)
7. Solicitor review of templates (1 hour, £150-£300) if Path A

**Total founder time: ~6-8 hours over 10 days. Total cash: £200-£4,500 + ICO fee + insurance premium.**

*End of legal setup guide.*
