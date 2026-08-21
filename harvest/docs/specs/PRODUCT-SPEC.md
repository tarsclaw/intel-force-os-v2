# Intel Force OS — The Final Recruitment Product Spec

**Document type:** Authoritative product spec — what we are building, what each agent delivers, how it makes money, how it configures per client at scale
**Audience:** Maddox; co-founder candidate; future Head of CS; sales asset behind closed doors
**Date:** 14 May 2026
**Status:** Final. Supersedes the agent specs scattered across the internal business plan, the CortexOS 24/7 directive, and the temp deep dive on points of conflict. Where this contradicts an earlier doc, this wins.
**Source documents synthesised:**
- `intelforce-os-internal-business-plan.md` (9 May 2026)
- `intelforce-os-cortexos-24-7-upgrade-directive.md` (12 May 2026)
- `intelforce-os-temp-contract-deep-dive.md` (8 May 2026)
- `intelforce-os-recruitment-workflow-analysis.md`

---

## 0. The one-paragraph version

Intel Force OS is the always-on operating system for UK recruitment agencies. It runs on CortexOS as the persistent agent runtime, lives inside each firm's existing stack (Bullhorn / Vincere / Voyager Infinity, Xero / Sage, Microsoft 365 / Google Workspace), and ships as two coordinated product lines — **IntelForce Recruit** for the front office and **IntelForce Temp** for the back office. Together they replace the operational drag of an entire junior team and, more importantly, generate revenue: surfaced BD opportunities, intercepted competitor briefs, faster cash collection, dormant-candidate reactivation, and post-placement nurture that compounds into referrals. The firm pays £499–£6,950/month per front-office tier and a separate £1,950–£5,950/month for the temp sub-platform. Every agent is pitched against a single, quantified outcome the buyer can verify within 90 days. Configuration scales because the moat is the per-vertical schema, not per-customer plumbing — onboarding becomes a 5-day wizard, not a 5-week project.

---

## 1. The product philosophy — three commitments that drive every design choice

These are non-negotiable. Every agent, every screen, every onboarding step is checked against them.

### 1.1 Output, not feature

A customer pays for what lands on their screen, not the agent that produced it. Every agent in this spec is defined by its **output contract**: what artefact appears where, when, in what format, with what quality bar. The agent name is for internal use; what the customer sees is "5 BD opportunities, every Monday, with named contacts and drafted outreach". If we can't write the output contract in one sentence, the agent isn't ready to ship.

### 1.2 Revenue first, time second

Every agent has two ROI axes:
- **Revenue created** — placements landed, BD meetings booked, cash accelerated, churn intercepted, JSL liability avoided
- **Time saved** — hours of operational drag eliminated per consultant per week

We lead with revenue because that's what gets the contract signed at a £3,250/mo Growth tier. Time savings close the deal at Solo (£499/mo). Both numbers are quantified in the agent spec; both are measured in the customer's first 90 days.

### 1.3 Always-on is the spine — but only where it earns the cost

Eight Tier 1 agents are genuinely always-on and structurally need CortexOS primitives. The rest are scheduled, batch, or webhook-driven and live inside the same runtime to share infrastructure but are not marketed as 24/7. This is the structural integrity rule that keeps the product credible with FD-level buyers.

---

## 2. The complete agent suite — final specification

### 2.1 The two product lines

| Product line | What it serves | Number of agents | Tier range |
|---|---|---|---|
| **IntelForce Recruit** | Front office — sales, sourcing, candidate comms, BD, cash | 13 agents | Solo £499 → Scale £6,950 |
| **IntelForce Temp** | Back office — compliance, timesheets, IR35, JSL due diligence | 6 agents | Compliance Core £1,950 → Full £5,950 |
| **Combined (Scale + Full Temp)** | The flagship 50-person mixed agency deal | 19 agents | £11,610/mo (10% combined-bundle discount) |

### 2.2 IntelForce Recruit — the 13 front-office agents

Listed in priority of revenue contribution to a typical 12-person agency, not in build order. Each agent has the same fixed structure:

- **Output contract** — what lands on the consultant's screen
- **Revenue story** — the one quantified outcome the buyer signs against
- **Time saved** — the operational drag eliminated
- **Always-on?** — Tier 1 (CortexOS-required) vs Tier 2 (scheduled / batch)
- **Tier availability** — which subscription tier unlocks it
- **Per-tenant config keys** — the 4–8 things the onboarding wizard collects

#### R1. Inbound Triage — the front door that never closes

- **Output contract:** Every email, LinkedIn InMail, and website contact-form submission gets a personalised reply within 60 seconds, in firm voice, at any hour. Draft for sensitive categories, auto-send for pre-approved categories. A single Telegram message at 09:00 surfaces overnight inbounds the consultant should look at first.
- **Revenue story:** "We win the candidates and clients you currently lose overnight to Hudson, Robert Walters, and PageGroup." Modelled: 2–4 additional placements/year per consultant from candidates who would otherwise have replied to whoever responded first.
- **Time saved:** 6–10 hours/week per consultant of inbox triage.
- **Always-on?** Tier 1.
- **Tier availability:** Solo (drafts-only, no auto-send) / Boutique+ (full auto-send).
- **Per-tenant config:** mailbox OAuth list, auto-send approval categories, escalation thresholds, voice profile path, firm-specific suppressions (named recruiters whose emails always escalate).

#### R2. Real-Time Cash Conductor — the FD's evenings back

- **Output contract:** Every invoice has a live status — sent, opened, escalating, paid. Payment lands → consultant gets the commission notification within minutes. Aged debt sweep runs at 07:00 with three drafted chase emails per debtor (soft, firm, escalation) ready for one-click approval.
- **Revenue story:** "DSO drops by 15+ days. £40k–£120k of working capital unlocked for a mid-sized agency. One bad debt caught per quarter pays for the entire suite."
- **Time saved:** 4–8 hours/week of FD/credit-controller drag.
- **Always-on?** Tier 1.
- **Tier availability:** Boutique+.
- **Per-tenant config:** accounting OAuth (Xero / QuickBooks / Sage), bank-feed connection, chase-cadence rules, escalation-threshold pounds, FD's mobile for Telegram approval.

#### R3. Client Hunter (with Competitor Interception split) — the BD-pipeline machine

- **Output contract (digest mode):** Monday 06:00 — 5–8 named BD opportunities with hiring signal, decision-maker identified, relationship history checked, salary benchmark, and drafted outreach in firm voice. Every Friday — a one-pager review of the week's BD outcomes.
- **Output contract (Competitor Interception, real-time):** Within 5 minutes of a target-patch company posting a role through Hudson, Robert Walters, or any other competitor agency: Telegram fires — "Greenstone, you've placed there twice, 3 candidates ready, drafted outreach. Send tonight?"
- **Revenue story:** "30+ qualified BD opportunities per month with named contacts and ready-to-send drafts. One closed retainer covers 6 months of the suite." Modelled: 2–5 net-new retainers per year per agency.
- **Time saved:** Replaces 15–20 hours/week of BD research effort that most agencies don't do at all today.
- **Always-on?** Digest is Tier 2 (cron). Competitor Interception is Tier 1.
- **Tier availability:** Boutique (digest) / Growth+ (Competitor Interception).
- **Per-tenant config:** target patch (sectors, geography, company size), competitor list (the agencies whose postings to watch), preferred outreach channel, named-consultant routing rules, signal-weighting overrides.

#### R4. The Night Sourcer — overnight sourcing while you sleep

- **Output contract:** Every weekday morning at 06:30, every live brief has 8–12 reviewed candidates in the consultant's inbox: name, summary, one-line rationale against the brief, drafted InMail or email, and a confidence score. Consultant approves from her phone on the train.
- **Revenue story:** "We do a full evening of sourcing on every brief in your pipeline, every night. You walk in to a day of outreach already drafted instead of a day of sourcing." Modelled: time-to-shortlist drops from 5 days to 2 days; 30% more briefs run concurrently per consultant.
- **Time saved:** 8–15 hours/week per consultant of sourcing drag.
- **Always-on?** Tier 1 (overnight autoresearch is the canonical use case).
- **Tier availability:** Growth+.
- **Per-tenant config:** sourcing playbook path, source budget (LinkedIn / Reed / CV Library / GitHub / sector-specific), candidate-rejection patterns, must-haves vs nice-to-haves taxonomy, draft tone overrides per role family.

#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day

- **Output contract:** Consultant pings "find me 5 candidates for this brief" via the Brain UI or Telegram → 10–15 minute turnaround → ranked shortlist with sourcing rationale, source link, and any prior interaction history with each candidate.
- **Revenue story:** Same as the Night Sourcer for daytime urgency. Modelled: cuts intake-call-to-first-shortlist time from same-week to same-hour for urgent briefs.
- **Time saved:** Eliminates the "I'll get back to you with a shortlist by end of week" tax.
- **Always-on?** Tier 2 (request-response).
- **Tier availability:** Boutique+.
- **Per-tenant config:** shared with Night Sourcer (same playbook, same source budget).

#### R6. The Scribe — the call-to-context engine

- **Output contract:** Every call (Fathom, Fireflies, Ringover) gets parsed into ATS structured fields *and* tacit notes that don't fit any field: "client said they'd never hire from Bank X because of a 2019 grudge", "candidate's actual reason for leaving is the new line manager, not the salary". Tacit notes power every other agent's voice and judgement.
- **Revenue story:** "Your firm's institutional memory finally lives somewhere. The senior consultant's 20 years of judgement compound across the whole team." Modelled: reduces the "founder-as-bottleneck" tax in firms where one senior person holds the relationship knowledge.
- **Time saved:** 30–60 min/day per consultant on call notes. The bigger value is the unlock for every other agent.
- **Always-on?** Tier 2 (webhook-driven).
- **Tier availability:** All tiers including Solo. This is the data spine.
- **Per-tenant config:** transcript-source OAuth, ATS field-mapping rules, tacit-note retention policy, banned-extraction patterns (anything sensitive that shouldn't be captured).

#### R7. The Concierge — no candidate ghosted, no client check-in missed

- **Output contract:** Every active candidate and every placed client gets the right comms at the right time, in firm voice, drafted (Solo/Boutique) or auto-sent (Growth+): post-interview chase, post-rejection care, post-placement check-ins at week 1 / month 1 / month 3 / month 6 / month 12 / month 24. Plus referral-extraction prompts every 6 months for the first 24 months post-placement.
- **Revenue story:** "Every placement generates 1.3 future placements over 24 months instead of 0.4. Post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table." Modelled: 15–25% lift in placement-driven referral revenue.
- **Time saved:** Eliminates the "I keep meaning to check in with X" guilt-debt.
- **Always-on?** Tier 1 (downstream handoff target from Triage; needs persistent state across the candidate lifecycle).
- **Tier availability:** Boutique+.
- **Per-tenant config:** nurture cadence per stage, voice tone per stage, referral-prompt templates, lifecycle-stage to comms-template mapping, do-not-contact flags.

#### R8. Real-Time Pulse — the relationship watcher

- **Output contract:** Continuous health score per client across email engagement, LinkedIn activity at the company, Companies House filings, placed-candidate signals (a placed candidate posting "new chapter" → likely about to leave). Within hours of a critical signal, the senior consultant gets a Telegram nudge with context and drafted re-engagement.
- **Revenue story:** "Catches a churning client 6 weeks before the PSL email arrives. Saves 1–2 client relationships per year that are typically worth £30k–£100k each in annual fees." Cross-sell signals (a placed candidate getting promoted into a hiring role) drive net-new placements at zero acquisition cost.
- **Time saved:** Replaces the QBR review process most agencies don't actually run.
- **Always-on?** Tier 1.
- **Tier availability:** Growth+.
- **Per-tenant config:** client portfolio scope, signal-weighting overrides, account-team routing rules, escalation thresholds per client tier (key account vs occasional).

#### R9. The Janitor — the database becomes an asset

- **Output contract:** Day-1 cleanup report (the closing artefact in sales): "Your Bullhorn has 47,000 records, 18% duplicates, 31% with stale contact details, 12% past your retention window, 23% with empty right-to-work fields." Day-30 before/after report. Then continuous: every new record cleaned, deduplicated, enriched, and compliance-checked as it lands.
- **Revenue story:** "Your sourcing runs become 3× more productive against clean data. One reactivated dormant-but-clean candidate per month covers the tier price." Plus: removes the compliance liability of stale records.
- **Time saved:** Currently you don't do this. Time saved = the time you should be spending on it but aren't.
- **Always-on?** Tier 2 (scheduled nightly batch).
- **Tier availability:** Solo+ (with one-off £1,500 setup-cleanup fee on Starter/Growth, waived on Scale).
- **Per-tenant config:** ATS connector, retention-policy rules, dedup-confidence threshold, field-completeness targets, deletion approval flow (always human-in-loop for v1).

#### R10. The Brief Decoder — turn a brief into an action plan in 90 minutes

- **Output contract:** Within 60 seconds of a brief arriving (email, LinkedIn message, ATS update): parsed brief → 3 ambiguity flags ("they said senior but the salary suggests mid") → drafted intake-call agenda → 5 pre-shortlisted candidates from the ATS → suggested fee structure based on firm precedent → all of it landed on Telegram by the time the consultant is making their next coffee.
- **Revenue story:** "Brief-to-first-shortlist time drops from 3 days to 90 minutes. You're back to the client with candidates before your competitor has read the email." Modelled: 1.5× win-rate on contested briefs.
- **Time saved:** Eliminates the half-day of intake-prep work per brief.
- **Always-on?** Tier 1.
- **Tier availability:** Growth+.
- **Per-tenant config:** firm fee-structure library, intake-call template, ambiguity-detection thresholds, role-family taxonomy.

#### R11. Spec Pitcher — the candidate database as a revenue engine

- **Output contract:** Weekly batch — for every placement-ready bench candidate, identifies 3–5 target companies based on the candidate's profile and the firm's target patch, generates anonymised CV one-pagers, drafts per-target outreach, lands the lot in the senior consultant's drafts folder.
- **Revenue story:** "Converts the candidate database from a storage cost to a revenue stream. Spec pitches generate 1–3 net-new briefs per month." Modelled: 8–15% of placement-ready candidates land roles via spec pitch in firms that do this well.
- **Time saved:** This is currently not done in most agencies, so the gain is pure revenue creation.
- **Always-on?** Tier 2 (scheduled weekly batch).
- **Tier availability:** Growth+.
- **Per-tenant config:** target-patch definition (shared with Client Hunter), anonymisation rules, fee structure templates per pitch type, do-not-pitch flags per candidate.

#### R12. Recruitment Reporting — the FD's monthly close, automated

- **Output contract:** First of every month, by 09:00 — a board pack with placements, GP, time-to-fill, fee-earner comparisons, pipeline coverage, cash position, and a one-page narrative that explains last month and forecasts next. Plus per-consultant weekly digests showing their own pipeline health.
- **Revenue story:** "Replaces the FD's Excel hell." Indirect revenue impact: better decisions when the FD can see the numbers in time to act on them.
- **Time saved:** 6–10 hours per month of FD/founder reporting drag.
- **Always-on?** Tier 2 (scheduled monthly cron).
- **Tier availability:** Growth+.
- **Per-tenant config:** report-template path, KPI definitions, fee-earner roster, board-meeting cadence, target benchmarks per metric.

#### R13. The Diagnostic — the sales motion, productised

- **Output contract:** Pre-sales — runs against any UK recruitment firm's public footprint (Companies House, careers page, public ATS data, LinkedIn signals). Produces a 12-page audit identifying the firm's specific operational pain. Used as the cold-outreach hook and the discovery-call agenda.
- **Revenue story:** Internal — this is our sales engine, not a customer product. Drives qualified pipeline.
- **Always-on?** Tier 2 (request-driven; runs on demand).
- **Tier availability:** Free pre-sales tool for prospects; not on the customer pricing card.

### 2.3 IntelForce Temp — the 6 back-office agents

Triggered by the April 2026 regulatory window — Joint & Several Liability for umbrella PAYE, six-year holiday-pay record-keeping, Fair Work Agency standing up. Different buyer (FD / Compliance Officer / Operations Director), different sales conversation, separate SKU. Same Intel Force OS platform.

#### T1. Onboarding Concierge — contractor onboarding done right, once

- **Output contract:** Every new contractor placement triggers a fully tracked onboarding workflow — RTW check, IR35 SDS request to client, contract execution, umbrella selection support, document collection, day-1 induction comms. Status visible to FD on a single dashboard.
- **Revenue story:** "First 2 weeks of every contract done correctly, every time. No PAYE surprises in week 6 because RTW was checked on day 1." Avoids £5k–£40k per botched onboarding (back-claimed PAYE plus penalties).
- **Time saved:** 2–4 hours per contractor onboarding.
- **Always-on?** Tier 2.
- **Tier availability:** Compliance + Operations and above.

#### T2. Sunday-Evening Timesheet Ranger — close the Friday-cutoff gap

- **Output contract:** Friday 17:00 cutoff. Sunday 19:00–21:00 — Ranger sends soft, personalised nudges to outstanding contractors in firm voice. Monday 09:00 — harder sweep on the residual with client-approver Cc. Per-contractor history informs the tone (holiday vs serial offender vs slow-approver client).
- **Revenue story:** "100-contractor desk saves £800–£1,600/month in off-cycle pay-run processing fees. Plus restores Monday morning to actual work."
- **Time saved:** 4–8 hours/week of FD/payroll-team firefighting on Mondays.
- **Always-on?** Tier 1 (off-hours work is the entire arbitrage).
- **Tier availability:** Compliance + Operations and above.

#### T3. Compliance Watchtower — the agent that never blinks

- **Output contract:** Per-contractor live state machine — AWR qualifying-week counter, RTW expiry clock, DBS / certification refresh schedule, contract end date, holiday-pay record completeness, NMW edge-case watcher. Drafts comparator-pay requests, rate-uplift letters, RTW renewals before every deadline.
- **Revenue story:** "Per-contractor compliance liability avoided: £2k–£20k per missed deadline. For a 50-contractor desk: £30k–£150k/year of expected-value risk eliminated." Plus the holiday-pay 6-year evidence pack is automatically built.
- **Time saved:** Replaces a half-FTE compliance role.
- **Always-on?** Tier 1.
- **Tier availability:** Compliance Core (T5 only) doesn't include T3. Compliance + Operations and above includes it.

#### T4. IR35 Coordinator — SDS request and adequacy management

- **Output contract:** On new contract or extension: triggers SDS request to client, parses the returned SDS for adequacy (CEST factors), flags risk patterns, drafts pushback letter if SDS appears inadequate. Re-runs on every extension.
- **Revenue story:** "Inside-IR35 misclassification per contractor: £15k–£60k of back-claimed PAYE liability per HMRC enquiry. We avoid one of these per year per 30-contractor desk."
- **Time saved:** 1–3 hours per IR35 cycle per contractor.
- **Always-on?** Tier 2 (scheduled per contract event).
- **Tier availability:** Full Temp Sub-Platform.

#### T5. Supply Chain Auditor — the JSL agent (the highest-leverage SKU in the entire portfolio)

- **Output contract:** Continuous umbrella due diligence — FCSA accreditation watching, RTI submission spot-checks, payslip audit sampling, complaint-volume monitoring across the supply chain. Quarterly audit pack ready for HMRC enquiry, no scrambling. Pre-onboarding diligence on any proposed new umbrella before the agency uses them.
- **Revenue story:** "JSL exposure per umbrella failure: £58k–£480k+ per incident, with no statutory defence. One avoided incident pays for 8+ years of this subscription. This is risk capital, not opex."
- **Time saved:** Eliminates a half-day of quarterly due diligence per umbrella in the supply chain.
- **Always-on?** Tier 1 (continuous monitoring).
- **Tier availability:** Compliance Core (sold standalone) and Full Temp.

#### T6. Pay & Bill Reconciler — daily three-way reconciliation

- **Output contract:** Every day: hours-to-agency vs hours-to-umbrella vs hours-to-client, charge-rate vs pay-rate vs invoice-amount, employer-NIC vs margin. Flags discrepancies to FD with one-click correction draft.
- **Revenue story:** "Margin leakage from reconciliation drift: £200–£800/contractor/year. A 100-contractor desk recovers £20k–£80k/year in invisible margin."
- **Time saved:** Replaces 1–2 days/week of FD/bookkeeper reconciliation drag.
- **Always-on?** Tier 2.
- **Tier availability:** Full Temp.

---

## 3. The revenue case — pinned per tier

This is what the buyer signs against. Every number is in §2 already; this section consolidates them into the single ROI promise the salesperson and the customer agree on.

### 3.1 IntelForce Recruit — front-office ROI promise

| Tier | Monthly | Agents included | The single ROI promise |
|---|---|---|---|
| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
| **Growth** (11–25 fee earners) | £3,250 | All Boutique + Night Sourcer, Brief Decoder, Spec Pitcher, Real-Time Pulse, Competitor Interception, Recruitment Reporting | "5–10 net-new retainers/year from BD + Competitor Interception. 30%+ more briefs per consultant via Night Sourcer. 1–2 saved client relationships/year worth £30k–£100k each." |
| **Scale** (26–50 fee earners) | £6,950 | All Growth + per-firm LoRA adapter + Sovereign-tier inference (UK on-prem) + priority support | "Half a junior recruiter replaced per consultant in operational drag. Per-firm voice that's genuinely indistinguishable from your top performer. £820k–£1.4M of demonstrable annual value created." |

### 3.2 IntelForce Temp — back-office ROI promise

| Tier | Monthly | Agents included | The single ROI promise |
|---|---|---|---|
| **Compliance Core** | £1,950 | T5 Supply Chain Auditor only (pre-bundled with onboarding due diligence + audit pack) | "One avoided JSL incident pays for 8+ years. Insurance against the most asymmetric risk on your balance sheet." |
| **Compliance + Operations** | £3,450 | T5 + T2 Timesheet Ranger + T3 Compliance Watchtower | "Half-FTE compliance role replaced. £30k–£150k/year of expected-value risk eliminated. Sunday-evening timesheet capture saves Monday firefighting." |
| **Full Temp Sub-Platform** | £5,950 | T1–T6 complete | "Two FTEs of back-office drag replaced. £20k–£80k/year of margin leakage recovered through reconciliation. Full IR35 + JSL + holiday-pay evidence pack always audit-ready." |

### 3.3 Combined deal — the flagship 50-person mixed agency

Scale + Full Temp = £10,900/mo gross, **£9,810/mo with 10% combined-bundle discount**. Annual: £117,720. Modelled value created: £1.2M–£2.0M/year. Capture ratio: 6–10%. This is the deal we close in Q2 2027 with the case-study customer.

---

## 4. The compounding moat — why every agent makes the next one better

This is the story we tell on call 3, when the prospect asks "why not just buy point tools?".

```
                  ┌──────────────────────────────────────────┐
                  │      The Vertical Schema (the moat)      │
                  │  canonical entities, voice, escalations  │
                  └──────────────────────────────────────────┘
                                     │
                                     ▼
       ┌──────────────────────────────────────────────────────────┐
       │                The Vault (per-firm second brain)         │
       │  voice profile, playbooks, candidate/client/brief data   │
       └──────────────────────────────────────────────────────────┘
                       │                              │
                       ▼                              ▼
        ┌──────────────────────────┐    ┌──────────────────────────┐
        │   The Scribe captures    │    │  The Janitor keeps it    │
        │     into the Vault       │    │  clean and trustworthy   │
        └──────────────────────────┘    └──────────────────────────┘
                              │
                              ▼
          ┌────────────────────────────────────────────┐
          │  Every other agent reads from the Vault    │
          │  and writes its decisions back to it       │
          └────────────────────────────────────────────┘
                              │
                              ▼
       ┌──────────────────────────────────────────────────────────┐
       │     The Decision Log (every agent action, every          │
       │     human override, every outcome) → SFT corpus →        │
       │     per-firm LoRA adapter → Scale-tier moat              │
       └──────────────────────────────────────────────────────────┘
```

The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**

This is the answer to "why not just use ChatGPT" — ChatGPT doesn't know your placements, your voice, your decisions, or your firm's specific judgement patterns. The Vault + Decision Log + per-firm LoRA stack does.

---

## 5. Per-tenant configuration at scale — the operational playbook

This is the section that determines whether we can profitably onboard 100 customers without it eating the founder.

### 5.1 The principle: configuration is per-tenant data, not per-tenant code

We never fork the agent prompts or the agent logic per customer. Everything that varies between tenants lives in two places:

1. **The per-tenant `config.schema.json` for each agent** — schema-validated JSON the wizard fills.
2. **The per-tenant `/vault/{tenant}/` directory** — voice profile, playbooks, ICP definition, target patch, brand templates, banned phrases, customer-specific suppression lists.

If a customer asks for behaviour we don't already support, the answer is one of three:
- It belongs in their `config.schema.json` → we add a config field, not a special case.
- It belongs in their vault → we update their `/vault/brand/` markdown, not the code.
- It needs new agent logic → we build it as a Vertical feature, not a per-customer fork. If they're the only customer asking, the answer is "not yet".

### 5.2 The onboarding wizard — a 5-day flow, not a 5-week project

Five days, not weeks, because the moat is the schema, not the plumbing. The onboarding sequence:

**Day 1 — Discovery + signed pre-sale**
- 90-minute discovery call (driven by the Diagnostic output).
- Buyer signs the contract; first payment lands.
- Wizard email goes out: "5 things we need from you this week".

**Day 2 — OAuth + vault provisioning**
- Customer clicks 5 OAuth buttons in the wizard: ATS (Bullhorn / Vincere / Voyager), accounting (Xero / Sage / QuickBooks), Microsoft 365 or Google Workspace, transcript source (Fathom / Fireflies / Ringover), LinkedIn.
- Vault provisioned at `/vault/{tenant}/` with directory skeleton.
- Decision log row 1 written: tenant provisioned.

**Day 3 — Voice profile capture**
- AI-guided wizard: customer pastes 10–20 sample emails from their top performer; system extracts voice profile, tone rules, banned phrases.
- Customer reviews the extracted profile in the Brain UI; edits in place.
- `/vault/{tenant}/_voice/style-guide.md` saved.

**Day 4 — Playbook capture**
- Wizard prompts for structured business facts: target patch (sectors / geography / company size), fee structure, escalation rules, named-consultant routing, do-not-contact list.
- These populate the per-agent `config.schema.json` files automatically.
- Customer reviews the populated configs in the Brain UI.

**Day 5 — First-run evals + dry run**
- Janitor runs against the ATS — produces the day-1 cleanup report.
- Cash Conductor runs against historical invoices — produces the DSO baseline.
- Inbound Triage runs in shadow mode for 24 hours — drafts only, no auto-send, customer reviews quality.
- End-of-day call: 30 minutes, walk through outputs, confirm voice quality.

**Day 8 — Live**
- Auto-send enabled for agreed categories.
- Customer added to weekly check-in cadence for first 90 days.

### 5.3 What the wizard collects — the master config template

Every agent's `config.schema.json` follows the same pattern (we already have this for Phase 2 agents). The cross-agent shared keys live in `common-*.json` shared schemas:

- `common-client.json` — firm slug, legal name, primary contact, tier, sovereign-vs-cloud preference
- `common-voice.json` — paths to voice profile, banned phrases, tone rules
- `common-notifications.json` — Telegram chat ID, escalation thresholds, approval surface (Telegram / email / iOS)
- `common-vault.json` — vault root, brand paths, playbook paths
- `common-ats.json` — ATS choice, OAuth ref, field mapping overrides
- `common-accounting.json` — accounting OAuth, chase cadence, escalation threshold
- `common-target-patch.json` — sectors, geography, size, named-company allowlist/blocklist

Each per-agent config then has only its agent-specific keys (e.g., the Night Sourcer's source budget allocation, Pulse's signal weights). This means a typical agent's `config.schema.json` is 30 lines, not 300. Scales.

### 5.4 The "100 customers by end of 2027" stress test

How do we onboard 100 customers without it eating the team?

- **Onboarding cost per customer: <8 hours of human time.** Discovery call (1.5h) + Day-5 review call (0.5h) + ad-hoc support (6h ceiling for first 90 days). Everything else is wizard-driven and self-service.
- **Customer Success ratio: 1 CSM per 30 customers.** The Brain UI surfaces every active customer's health metrics — adoption per agent, override rate, time-to-first-value. CSM intervenes only on red signals.
- **Customer-specific code: zero.** If anything customer-specific shows up in a code review, it's bounced back to the schema or the vault.
- **Per-customer compute cost: ~£200/month for full Tier 1 deployment** (per the CortexOS directive's unit-economics work). At Boutique £1,495/mo this is 13% COGS; at Growth £3,250/mo this is 6%; healthy at every tier above Solo's three-agent gate.

### 5.5 The escalation contract — when a customer hits "we need something custom"

Three possible answers, in this order:

1. **"It's already a config field — let me show you where."** This is the answer 60% of the time. The wizard hides depth that's available to customers who know to ask.
2. **"Add it to your vault as a markdown file — the agents will read it on next run."** This is the answer for tone, voice, playbook, suppression-list, and similar text-based asks. ~25% of the time.
3. **"Genuinely new feature — let me see how many other customers want this."** This goes on the roadmap. We never build it for one customer unless they pay materially extra for it (typically Scale-tier customers only). ~15% of the time.

This contract is in the customer agreement at signing. It sets expectations and protects the team.

---

## 6. The CortexOS harness — what we actually depend on

This section is for the technical co-founder candidate and the senior engineer hire. It documents what CortexOS uniquely provides that the agent suite depends on, so the build doesn't drift away from leveraging it.

### 6.1 The seven CortexOS primitives every Tier 1 agent uses

Restated from the 24/7 directive for the spec record:

| # | Primitive | Used by |
|---|---|---|
| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
| 2 | 71-hour context rotation with auto-restart | Concierge (cross-week candidate conversations), Watchtower (per-contractor state), Pulse (multi-source watching) |
| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
| 5 | Telegram + iOS approval surface | Every Tier 1 agent's escalation path |
| 6 | Overnight autoresearch — long sessions against rate-limited APIs | Night Sourcer, Spec Pitcher (batch overnight runs) |
| 7 | Multi-agent orchestrator — supervisor agent that watches the others | Brief Decoder's 4-agent pipeline; the JSL Watchtower's daily recalc |

Webhook + Lambda + queue can clumsily fake primitives 1, 2, and 6. It cannot do 3, 4, or 7. That's the structural moat against a competitor reproducing the suite with off-the-shelf orchestration.

### 6.2 What we build on top of CortexOS, not inside it

CortexOS is the agent runtime. Intel Force OS is the recruitment-vertical product. The architectural separation:

- **CortexOS layer:** PM2, agent process supervision, file bus, Telegram surface, approval gates, context rotation, orchestrator template.
- **Intel Force OS layer:** vertical schema, agent definitions (the `agent.md` files), MCP connectors to ATS / accounting / Microsoft Graph / Companies House, vault syncer, decision log, per-tenant adapter training pipeline, Brain UI.

We do not modify CortexOS. We consume it as a submodule. If CortexOS lacks something we need, we either build it in our layer or contribute upstream — never fork.

### 6.3 The deployment topology

- **Per-tenant container:** one Docker container per tenant, running the CortexOS runtime + all enabled agents + the tenant's vault mounted in.
- **Shared services:** Postgres (vault index, entity graph, decision log), Hetzner UK VPS, MCP connector pool.
- **Sovereign tier:** inference routed to the on-prem Mac Studio cluster (per the sovereign compute plan); cloud APIs (Anthropic, Moonshot) handle non-Sovereign tiers and overflow.
- **Per-firm LoRA adapter (Scale tier only):** trained on cloud GPUs, served from the cluster at inference time.

---

## 7. What's missing from the previous documents — the 20% we just added

Cross-referencing this spec against the four source documents, here's what's new or sharpened.

**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".

**2. The output contract is now the spec, not the agent architecture.** Previous docs led with the workflow and the architecture. This spec leads with what literally lands on the consultant's screen, in what format, when. The architecture is downstream of that.

**3. The single ROI promise per tier is pinned.** Previous docs had pricing and had value modelling but the "single sentence the salesperson uses" was scattered. Section 3 fixes this.

**4. The compounding moat story is told as a customer-facing narrative.** §4 of this spec is the "every agent makes every other agent smarter" story. Previously this was implicit in the data layer architecture; now it's the headline answer to "why not just buy point tools".

**5. The 5-day onboarding wizard is fully specified.** Previous docs talked about onboarding cost in the abstract; §5.2 specifies the actual 8-day flow and what the wizard collects.

**6. The "100 customers by 2027" stress test is specified.** §5.4 puts hard numbers on onboarding cost per customer, CSM ratio, per-customer compute cost, and customer-specific code (zero). This is the scaling answer for any investor question.

**7. The CortexOS harness contract is specified.** §6 documents what CortexOS uniquely provides, what we build on top, and what we never do. This protects the build from drifting away from leveraging the runtime.

**8. The escalation contract is specified.** §5.5 — what we say when a customer asks for custom behaviour. This is the operational answer to the "death by a thousand customisations" risk.

---

## 8. What we are explicitly NOT building

This is the discipline section. Things that came up across the documents and the workflow analysis that we are explicitly leaving out of the recruitment product, with the reason.

- **No general-purpose AI assistant features.** No "chat with your firm". No "ask Intel Force anything". The product is structured workflows with structured outputs. The Brain UI has a console but it's a debugging surface for the founder, not a customer-facing chat.
- **No ATS replacement.** We sit on top of Bullhorn / Vincere / Voyager. We do not become the system of record. This is non-negotiable for two reasons: customer switching cost is too high to replace the ATS, and our defensible IP is the schema layer, not the data store.
- **No verticals other than recruitment in v1.** Accountancy and insurance are real markets and are sequenced for 2027+. We do not chase them while recruitment is at <15 paid customers.
- **No usage-based billing.** Flat monthly per tenant. The buyer needs predictable cost; we need predictable cash flow.
- **No per-seat pricing in Starter/Growth.** This rewards the wrong behaviour — we want adoption across the whole firm, not gating at the founder.
- **No three-year contracts in v1.** Six and twelve-month terms with auto-renewal. Three-year is a Stage 5 lever once Sovereign tier exists and the data-sovereignty story is the close.
- **No free pilots beyond the structured 14-day Janitor cleanup trial.** Free pilots train customers to expect free.
- **No 24/7 human support.** The agents work 24/7. Our humans work 09:00–18:00 UK with on-call for Scale only. Sales collateral makes this explicit.

---

## 9. The build sequence — what gets built when, against this spec

Reconciling the four source documents into one ordered build plan.

### 9.1 v1.0 (now → end of Q3 2026) — the closeable front office

Ships in time for the first 3 paid pilots in Q3 2026.

- The Diagnostic (sales tool; already drafted)
- The Janitor (the wedge agent; lowest risk, highest visible value)
- The Scribe (the data spine)
- Cash Conductor (real-time mode)
- Concierge (Solo drafts-only, Boutique auto-send)
- Sourcing Scout (daytime form)

Six agents. The Solo tier is fully shippable. The Boutique tier is fully shippable. Growth and Scale come in v1.1.

### 9.2 v1.1 (Q4 2026 → Q1 2027) — the always-on suite at full strength

Per the 24/7 directive's revised build order:

1. **Inbound Triage** (4 weeks) — the front door
2. **Brief Decoder** (2 weeks) — pairs with Triage
3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
4. **Competitor Interception** (2 weeks) — split out of Client Hunter
5. **Client Hunter digest mode** (already drafted, ships alongside the split)

Plus the temp critical path:

6. **T5 Supply Chain Auditor** (priority 1 — the JSL window)
7. **T3 Compliance Watchtower** (priority 2 — holiday-pay evidence pack)

The Growth tier becomes fully shippable. Compliance Core SKU launches.

### 9.3 v1.2 (Q2 2027 onwards) — the completion layer

- Real-Time Pulse
- Spec Pitcher
- Recruitment Reporting
- T1 Onboarding Concierge
- T2 Sunday-Evening Timesheet Ranger

Scale tier becomes fully shippable. Full Temp Sub-Platform launches.

### 9.4 v2.0 (Q3 2027 onwards) — the deep extensions

- T4 IR35 Coordinator
- T6 Pay & Bill Reconciler
- The per-firm LoRA adapter pipeline (Scale tier unlock)
- The Sovereign-tier on-prem cluster (Scale tier unlock)

This is also the window in which the accountancy and insurance verticals begin.

---

## 10. The single sentence each agent earns the right to be in this suite

Final integrity check. If an agent can't be reduced to one sentence the buyer would pay for, it doesn't belong here. The list:

1. **Inbound Triage** — "Win the candidates you currently lose overnight."
2. **Real-Time Cash Conductor** — "DSO drops by 15+ days, working capital unlocked."
3. **Client Hunter + Competitor Interception** — "5 named BD opportunities every Monday, plus we beat Hudson to the punch when they post a role for your patch."
4. **Night Sourcer** — "Walk in to 27 reviewed candidates across your live briefs every morning."
5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
6. **The Scribe** — "Your firm's institutional memory finally lives somewhere."
7. **Concierge** — "No candidate ghosted, no client check-in missed, every comms in your voice."
8. **Real-Time Pulse** — "Catch a churning client 6 weeks before the PSL email arrives."
9. **The Janitor** — "Your sourcing runs become 3× more productive against clean data."
10. **Brief Decoder** — "Brief-to-first-shortlist in 90 minutes."
11. **Spec Pitcher** — "Candidate database becomes a revenue stream."
12. **Recruitment Reporting** — "Board pack ready for the 1st, no Excel hell."
13. **T1 Onboarding Concierge** — "First 2 weeks of every contract done correctly, every time."
14. **T2 Timesheet Ranger** — "Sunday-evening capture, no Monday firefighting."
15. **T3 Compliance Watchtower** — "Half-FTE compliance role replaced, audit-ready always."
16. **T4 IR35 Coordinator** — "SDS adequacy managed, IR35 misclassification avoided."
17. **T5 Supply Chain Auditor** — "JSL liability monitored continuously, audit pack always ready."
18. **T6 Pay & Bill Reconciler** — "£20k–£80k/year of margin leakage recovered for a 100-contractor desk."

Eighteen agents, eighteen sentences. Every one of them is what the buyer signs against.

---

## 11. Document control

| Version | Date | Author | Notes |
|---|---|---|---|
| 1.0 | 14 May 2026 | Maddox + Claude | Final synthesis of internal business plan + 24/7 directive + temp deep dive + workflow analysis |

This document is the authoritative product spec for the recruitment vertical. Where it conflicts with prior documents, this wins. The internal business plan remains authoritative on ICP, GTM motion, and revenue trajectory. The 24/7 directive remains authoritative on the CortexOS runtime contract. The temp deep dive remains authoritative on the regulatory analysis. The workflow analysis remains the long-form reference for individual workflow detail.

End of spec.
