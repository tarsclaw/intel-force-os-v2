# Phase 6 — Operations Runbooks

**Everything we need written down to run the platform day-to-day. Incident response, on-call rotations, specific-component runbooks, deploy discipline, cost governance, secret rotation, backup verification, GDPR compliance, breach response.**

> **Status:** v1.0, shipped 23 April 2026.
>
> **Prerequisites:** Phase 3 (platform infrastructure) needs to exist as a target for these runbooks. If Phase 3 isn't built yet, these are reference material for the build — they describe the ops posture we're building toward.
>
> **Philosophy:** ops maturity comes from writing things down and reading them under pressure. The goal isn't having "ops processes"; the goal is having procedures that work when you're tired, when it's 3am, when the person in front of the keyboard is a new hire who joined last Tuesday.

---

## What's in this phase

### Incident response (3 files)

| # | File | Purpose |
|---|---|---|
| 1 | `incident-response/incident-response-runbook.md` | The general pattern — what counts as an incident, severity, roles (IC / comms lead / tech lead / scribe), the incident flow, containment before resolution, post-incident monitoring, postmortem template, anti-patterns, game days, solo-on-call constraints |
| 2 | `incident-response/on-call-handbook.md` | Rotation model (V1 Maddox+Jack primary+secondary weekly, scaled to V2), Monday 09:00 handoff ritual, paging rules, first-5-minutes checklist, tools access (16 systems), first-day training, weekly review tasks, escalation tree, compensation/sanity, solo on-call scenarios |
| 3 | `incident-response/severity-classification-and-comms.md` | 4 severities with examples, three-question decision test, upgrade/downgrade patterns, provider-outage handling, status page mapping, full update templates, customer email templates for SEV-1 in-progress + resolved, internal Slack conventions, post-incident comms |

### Specific-component runbooks (4 files)

| # | File | Purpose |
|---|---|---|
| 4 | `runbooks/postgres-incidents.md` | Cluster topology recap, runbooks for: primary unreachable + failover, replica lag, connection exhaustion, data corruption + PITR, RLS policy bypass (SEV-1 breach), pgvector degradation + REINDEX CONCURRENTLY, disk full, migration gone wrong, autovacuum runaway, saved monitoring queries, "never do" list |
| 5 | `runbooks/platform-service-incidents.md` | Common patterns (restart trap, fallback modes, backlog replay); specific: Escalation Notifier, Secrets Vault (CMK deletion is SEV-1 past 7-day window), Provisioning System (Temporal workflow stuck), Webhook Receiver, Dashboard (including sign-in + CSRF suspicions), cross-service patterns |
| 6 | `runbooks/tenant-incidents.md` | Common shape, customer comms escalating faster than severity; specific: tenant container stalled, cost runaway (severity ladder by magnitude; containment via `tenants.suspend()`; credit-back policy by fault), agent misbehaviour, integration provider outage, OAuth expired, webhook URL misconfig, suspicious tenant activity (breach-adjacent), escalation storm, "my tenant is slow" pattern, commercial-layer coordination |
| 7 | `runbooks/deploy-and-rollback.md` | What counts as a deploy, environments (local / preview / staging / production with 30min staging soak, 24h for migrations), 9-item pre-deploy checklist, Friday-14:00 no-deploy policy, regular deploy flow (GitHub Actions → staging auto → manual prod approval → blue-green 10min overlap → smoke tests → 15min watch), migration rules, rollback (application-level fast; migration rollback forward-fix / PITR / surgery), hotfix flow, infrastructure deploys, feature flags, agent-version deploys, quarterly rollback exercises |

### Operational routines (3 files)

| # | File | Purpose |
|---|---|---|
| 8 | `routines/cost-governance-runbook.md` | Weekly Monday 45-min rhythm with checklist + report template, healthy metrics (>70% margin Starter/Growth/Scale, >45% Enterprise, <20% WoW variance), real-time alert catalogue, three-level drill-down investigation with SQL queries, common anomaly patterns, per-tenant budget enforcement (soft_alert vs hard_stop), platform-level cost levers (immediate/medium/long-term), per-tenant P&L tracking, platform-wide budget by month M1-M12, Anthropic-specifics (prompt caching >60%, model routing), customer-facing cost comms, quarterly optimisations, simple forecast model |
| 9 | `routines/secret-rotation-runbook.md` | Full secret inventory (per-tenant / platform-level / infrastructure), quarterly rotation checklist, dual-window mechanics, per-secret rotation procedures (Postgres / Anthropic / Stripe / Clerk / Cloudflare / GitHub / per-tenant provider keys / OAuth), emergency rotation (skip dual-window), offboarding, vault backup/restore, rotation health monitoring, quarterly rotation template |
| 10 | `routines/backup-verification-and-dr-drills.md` | What we back up (Postgres WAL + nightly + cross-region, tenant git repos, DynamoDB, audit logs, IaC), what we don't, weekly automated restore test (Monday 09:30, 45-60min), quarterly DR drill rotating through scenarios (Postgres catastrophic / region outage / single-tenant / full rebuild), drill roles + half-day agenda + after-action template, evidence capture, annual full-platform rebuild stress test, cold-backups via Backblaze B2 against ransomware |

### Compliance (2 files)

| # | File | Purpose |
|---|---|---|
| 11 | `compliance/gdpr-dsar-and-deletion-runbook.md` | All 7 DSAR types (access / rectification / erasure / restriction / portability / objection / automated-decision), 30-day clock, acknowledgement within 72 hours, identity verification, system-by-system data gathering (14 systems), response format JSON + PDF, erasure scope including third parties + backup handling (natural expiration + re-process-on-restore), tenant off-boarding bulk deletion, complex scenarios (mixed-tenant data, deceased subjects, law enforcement, adversarial requesters), 90-day extension under Article 12(3), evidence record-keeping |
| 12 | `compliance/breach-response-runbook.md` | What counts as a breach, suspected vs confirmed, 72-hour ICO clock, first hour (declare SEV-1, page Maddox+Jack+legal counsel, #breach-YYYY-MM-DD private channel, evidence preservation BEFORE containment, then containment), first 24 hours (scope assessment, legal counsel drives regulatory, ICO notification, Article 34 high-risk individual notification, 24-hour DPA tenant notification), full notification templates, internal comms hygiene, forensics firm engagement, emergency rotation, post-breach long tail (postmortem, remediation tracking, regulator follow-up, customer relationship work, media/PR, cyber insurance), special scenarios (ransomware / insider threat / sub-processor breach / physical theft), preventive controls recap |

### Summary

| # | File | Purpose |
|---|---|---|
| 13 | `PHASE-6-SUMMARY.md` | This document |

**Total: 13 files, ~6,400 lines across ops discipline.**

---

## The shape of the phase

Phase 6 is organised around three time horizons:

```
         ┌──────────────────────────────────────────────┐
         │  REACTIVE — when something is broken         │
         │                                              │
         │  incident-response-runbook.md  (general)     │
         │  on-call-handbook.md           (who + how)   │
         │  severity-classification.md    (language)    │
         │  ↓                                           │
         │  postgres-incidents.md                       │
         │  platform-service-incidents.md               │
         │  tenant-incidents.md                         │
         │  deploy-and-rollback.md                      │
         │  breach-response-runbook.md    (when severe) │
         └──────────────────────────────────────────────┘
         ┌──────────────────────────────────────────────┐
         │  ROUTINE — scheduled ops work                │
         │                                              │
         │  cost-governance-runbook.md    (weekly)      │
         │  secret-rotation-runbook.md    (quarterly)   │
         │  backup-verification-and-dr-drills.md        │
         │                                (weekly+quart)│
         └──────────────────────────────────────────────┘
         ┌──────────────────────────────────────────────┐
         │  COMPLIANCE — when prompted by outside       │
         │                                              │
         │  gdpr-dsar-and-deletion-runbook.md           │
         │  breach-response-runbook.md    (extends      │
         │                                 incident rb) │
         └──────────────────────────────────────────────┘
```

Runbooks reference each other extensively. The general incident flow ingests the specific component runbook; breach response invokes secret rotation emergency flow; cost governance detects anomalies that become tenant incidents.

---

## Key operational decisions locked in this phase

### 1. Four-severity scheme (SEV-1 critical / SEV-2 major / SEV-3 minor / SEV-4 informational)
Consistent across PagerDuty, Slack, status page, postmortems. The three-question decision test (data at risk? multi-tenant? trust at risk?) keeps classification deterministic under pressure.

### 2. Weekly on-call rotation with formal 09:00 Monday handoff
Shift length is a calendar week. Handoff is live video (or Loom if unavoidable); skipping is not acceptable. For v1 that's Maddox + Jack; splits to platform/agent rotations at 3+ engineers.

### 3. "Evidence preservation before fix" during breaches
First 10 minutes of a suspected breach go to evidence capture (audit_log snapshots, Loki log copies, process snapshots, affected session IDs). Only then containment. Fighting the instinct matters — evidence captured late is often no evidence.

### 4. 30-minute staging soak minimum; 24-hour for migrations
Pre-deploy gate that catches a lot. Friday-14:00 no-deploy policy on top. Weekend incidents from Friday-evening deploys are preventable by policy.

### 5. Blue-green deploys with 10-minute overlap window
Fast rollback option for 10 min post-deploy; beyond that, full redeploy of old tag (2-3 min). Smoke tests auto-run post-deploy; 15-minute watch is mandatory for the deployer.

### 6. Weekly Monday cost review as the primary margin-protection mechanism
45 minutes, structured checklist, output as a Slack post to #ops. Real-time alerts are complementary but won't catch slow-bleeding margin erosion.

### 7. Quarterly secret rotation rhythm with dual-window mechanics
Every platform-level secret rotates at least yearly; many quarterly. Dual-window default (brief emergency rotations excepted) means rotations are boring — the correct outcome.

### 8. Weekly automated restore tests + quarterly DR drills
Weekly proves the backup works; quarterly proves we can actually execute recovery. Annual Q4 drill is full-platform rebuild — the stress test that exposes unwritten assumptions.

### 9. 72-hour ICO clock is non-negotiable
Breach response runbook is built around the 72-hour awareness-to-ICO notification window. Pre-engaged legal counsel + pre-drafted notification templates make it meetable.

### 10. "Everything drafts, nothing sends" reduces breach blast radius
Because the platform drafts content for human review instead of auto-sending, most DSARs about Clawd-generated data are about drafts that never left the customer's control. Easier to erase; less to notify on.

### 11. Single-person on-call is acknowledged, not pretended-away
V1 reality: one person covers a shift. Runbooks explicitly handle solo constraints — SEV-1 requires pulling in a second human; vacations require explicit pre-arranged coverage; connectivity loss (yacht, remote travel) is an incident in itself if unplanned.

### 12. Forensics firm on retainer before first breach
~Few hours/year retainer with UK digital forensics firm reduces mobilisation time from days to hours. Engagement terms pre-negotiated. Cheaper than the alternative.

### 13. Backblaze B2 cold backups against ransomware
Critical backups mirrored weekly to a separate cloud provider with different credentials, not rotated with AWS secrets. Ransomware attacks on backup infrastructure are a real 2024/2025 pattern; this is the mitigation.

---

## What Phase 6 enables

- **A credible SLA.** The 99.0%–99.9% commitments in Phase 5's SLA spec are backed by actual operational procedures now. Availability isn't aspirational.
- **Breach-ready posture.** 72-hour ICO notification + DPA-obligated tenant notification within 24h are executable, not theoretical.
- **Small-team sustainability.** Solo-on-call scenarios are handled honestly; the phase doesn't assume a 24/7 SRE team we don't have.
- **Cost margin protection.** Weekly reviews + real-time alerts catch cost anomalies before they eat multi-month margin.
- **Actual disaster recovery.** Weekly restore tests + quarterly drills + annual full rebuild mean RPO/RTO claims are evidence-backed, not hope-backed.
- **GDPR operational readiness.** Any DSAR that lands at privacy@clawd.ai is handleable within the 30-day window without panic.
- **Deploy discipline.** Production deploys are boring. Boring is the goal.

---

## What Phase 6 does NOT deliver

- **Penetration testing.** Annual pentest is v2/post-launch roadmap, not v1 ops.
- **SOC 2 certification.** Out of scope until Enterprise tier customers demand it (year 2+).
- **ISO 27001.** Same; needed only when enterprise procurement demands.
- **Bug bounty programme.** v2; post-launch after platform is stable.
- **Chaos engineering framework.** v1.5 consideration; today's game days are manual exercises, not automated chaos.
- **24/7 follow-the-sun coverage.** v1 is UK-hours primary with extended on-call; follow-the-sun requires multi-region team.
- **Dedicated security team.** v1 is "everyone is a security engineer"; dedicated headcount is year 2+.
- **Compliance automation platform** (Vanta, Drata, etc.) — useful for SOC 2 prep; deferred until that's the goal.
- **Intrusion detection / SIEM.** v1 is Loki + Prometheus with manual review; SIEM (Datadog Security, Panther) is post-launch.
- **Automated DSAR self-service portal.** v1 is email + manual gather; automation in v2.

---

## Dependency ordering for operationalisation

If building ops maturity from zero (what v1 actually looks like):

1. **Week 1 — Incident response foundations**
   - Set up PagerDuty, Slack #incidents, Statuspage.io
   - Read the incident-response + on-call + severity docs
   - Laminate the first-5-minutes checklist, put in on-call bag

2. **Week 2 — Deploy discipline**
   - Set up GitHub Actions deploy workflow
   - Staging + production environments standing
   - First deploy run through the 9-item pre-deploy checklist end-to-end

3. **Week 3 — Routine observability**
   - Grafana "Platform Economics" dashboard per cost governance runbook
   - Alert catalogue from cost governance + platform-service runbooks
   - First Monday weekly cost review run

4. **Week 4 — Game day one**
   - Run the first staged incident (e.g., "Escalation Notifier stopped writing to Slack")
   - Practice the response flow in staging
   - After-action report; tune runbooks based on what was unclear

5. **Month 2 — Secret rotation first pass**
   - First quarterly rotation run (even if nothing's overdue)
   - Work the dual-window mechanics
   - Document friction for runbook improvement

6. **Month 2 — First restore test**
   - Manual run of weekly restore test
   - Automate the script for weekly recurrence
   - Verify the Backblaze B2 cold backups exist and restore

7. **Month 3 — Legal counsel engagement for breach readiness**
   - Engage the data protection solicitor (same one used for MSA/DPA in Phase 5)
   - Pre-draft ICO notification template
   - Retain forensics firm
   - Table-top breach exercise

8. **Month 3 — First DR drill (Q1 scenario: Postgres primary failure)**
   - Execute the drill
   - Produce after-action report
   - Action items into Linear

9. **Month 6 — Annual full-platform rebuild drill**
   - Q4 drill scenario
   - Expect 48-72 hours first time; 24 hours subsequent times
   - This is the drill that reveals the most gaps

**From zero to full ops maturity: ~6 months elapsed alongside other work. v1 launches without all of this; it gets built progressively.**

---

## Cost envelope

### Tools and services

| Item | Monthly |
|---|---|
| PagerDuty (team plan) | £40 |
| Statuspage.io | £25 |
| Backblaze B2 cold storage | £8–25 (capacity-dependent) |
| 1Password Teams | £15 |
| Cyber liability insurance (year 2 onwards) | £150 (year 2 est.) |
| **Total (year 1 without insurance)** | **£88–105/mo** |

### One-time / occasional

| Item | Cost |
|---|---|
| Forensics firm retainer (year 1) | £1,000 retainer + hours at engagement |
| Legal counsel DSAR/breach template drafting | Covered in Phase 5 £4k solicitor pack |
| DR drill overhead (labour) | Included in team time |

### Cost of downtime (incurred during incidents)

Not a Phase 6 spend per se, but worth stating the math:
- SEV-1 with service credit triggered on a Growth tier customer: up to 50% of monthly fee = ~£900 credit per affected customer
- SEV-1 lasting 2 hours platform-wide: ~£2,000–4,000 aggregate credits at 20 customers
- Reputational cost: typically larger than the credit itself

Ops maturity is the insurance premium. £105/mo in tools vs £4,000 in a single bad incident's credits isn't a tradeoff — it's an obvious spend.

---

## Phase 6 open decisions

Unlike earlier phases (Phase 4's 7 open decisions, Phase 5's 18), Phase 6 is mostly recommendation-locked because the operational patterns are well-established industry practice. A few decisions remain:

### OD-P6-1 — Forensics firm retainer
**Decision:** engage a forensics firm on retainer before v1 launch?
**Rec:** yes, but modest — few hours/year retainer, not full-bore. ~£1,000/year. Worth it the first time we need them.

### OD-P6-2 — Cyber liability insurance
**Decision:** buy cyber insurance in year 1, or defer to year 2?
**Rec:** defer to year 2 when we have 10+ customers and meaningful revenue to protect. Year 1, retained legal counsel is primary defence. ~£150/mo when we do buy.

### OD-P6-3 — SIEM / intrusion detection
**Decision:** Loki + Prometheus manual review, or a proper SIEM?
**Rec:** Loki + Prometheus for v1; SIEM (Panther, Datadog Security) evaluated at tenant #20+ when audit burden justifies.

### OD-P6-4 — 24/7 paging
**Decision:** expand on-call to genuinely 24/7, or stick with current "paged during UK night if SEV-1/2" model?
**Rec:** stick with current model until Enterprise customers require 24/7 SLA. Saves operator sanity.

### OD-P6-5 — Compliance automation platform (Vanta / Drata)
**Decision:** adopt for SOC 2 / ISO 27001 readiness?
**Rec:** defer until SOC 2 is on the near-term roadmap (year 2+). £400-800/mo isn't free.

### OD-P6-6 — External postmortem publishing
**Decision:** publish SEV-1 postmortems externally (for trust) or keep internal (for confidentiality)?
**Rec:** case-by-case. Low-sensitivity SEV-1s published externally; breach-adjacent ones internal-only. Builds trust over time.

### OD-P6-7 — Annual security training vendor
**Decision:** DIY training, or vendor (KnowBe4 etc.)?
**Rec:** DIY for year 1 (small team; we can do a 2-hour session ourselves). Vendor at 5+ team members.

---

## Where Phase 6 meets earlier phases

Every Phase 6 runbook builds on earlier specs. Key dependencies:

| Phase 6 file | Depends on |
|---|---|
| incident-response-runbook.md | Phase 3 observability (alert sources), Phase 5 SLA (targets we're defending) |
| on-call-handbook.md | Phase 4 auth (platform_admin access), Phase 3 secrets vault (operator credentials) |
| postgres-incidents.md | Phase 3 Postgres schema + DR runbook |
| platform-service-incidents.md | Phase 3 service specs (escalation notifier, secrets vault, provisioning, webhook receiver), Phase 4 dashboard architecture |
| tenant-incidents.md | Phase 2 agent specs (agent misbehaviour), Phase 3 cost accounting (budget enforcement), Phase 4 Settings view |
| deploy-and-rollback.md | Phase 4 dashboard architecture §9, Phase 3 migration patterns |
| cost-governance-runbook.md | Phase 5 pricing + tier margins, Phase 3 cost ingestion |
| secret-rotation-runbook.md | Phase 3 secrets vault spec |
| backup-verification-and-dr-drills.md | Phase 3 DR runbook, Phase 5 SLA RPO/RTO |
| gdpr-dsar-and-deletion-runbook.md | Phase 5 DPA + Privacy Policy |
| breach-response-runbook.md | Phase 5 DPA (notification timelines), Phase 3 audit log |

Phase 6 is almost purely consumer — it operationalises what Phases 3-5 specified. Without Phase 3, most of this is theoretical.

---

## The three persistent blockers (still unchanged)

Phase 6 did not resolve any of the three fundamental blockers. All still need attention, and one of them (the POC runbook) has grown more important:

### 1. POC runbook still unrun
**Urgency: highest.** Every Phase 6 runbook is predicated on Phase 3 platform services existing to operationalise. If the POC (Phase 1 Week-1 experiment) shows the agent model doesn't work, Phase 3 is wrong-shaped and therefore Phase 6 runbooks are wrong-target. Run the POC before Phase 3 build kicks off in earnest.

### 2. Product naming (C3a / OD-P5-1)
Clawd recommendation still outstanding. No further progress in Phase 6. The Phase 6 runbooks all use "Clawd" as the working name (consistent with Phase 5); lock it or we do a search-and-replace later.

### 3. First customer dev trial
Unchanged — webhook receiver spec is still the best 5-day binary pass/fail brief.

---

## The artifact set so far

At end of Phase 6:

| Category | Files |
|---|---|
| Navigation & meta | 3 |
| Strategic & business | 6 |
| Phase 1 POC | 16 |
| Phase 2 agent suite | 78 |
| Phase 3 platform | 9 |
| Phase 4 dashboard | 11 |
| Phase 5 business & legal | 14 |
| Phase 6 ops runbooks | 13 |
| **Total shipped** | **150** |
| Future phases pending | ~40 |

Only Phase 7 (post-launch loops) remains on the current plan. Phase 7 starts when Customer #1 crosses 30 days live — case studies, onboarding feedback loops, version migration, first DR drill retrospective in production. Between now and Phase 7 is the actual build-and-launch window.

---

## What to do this week (concrete next steps)

Distinct from Phase 5's commercial-lock list. Phase 6 week-1 actions are operational setup:

1. **Stand up PagerDuty** — import the rotation schedule, integrate with Prometheus alerts, test-page yourself to confirm receipt
2. **Create #incidents Slack channel** and pin the declaration template
3. **Register statuspage.io** at status.clawd.ai with the 5 component categories from incident-response-runbook §6
4. **Run the first weekly cost review** — even if only on staging data, to practice the rhythm
5. **Laminate the first-5-minutes checklist** — seriously, a physical card. Test it by reading it mock-style.
6. **Schedule the first game day** — 4 weeks out. Pick a scenario; announce in advance; run the exercise.

Six actions, spread across ~10 hours of work. Enough to go live with functional incident response before the first real paying customer.

---

## Phase 7 preview

Future phases pending (not yet built):

**Phase 7 — Post-launch loops (starts at Customer #1 + 30 days live)**
- Case studies in production — running the Phase 5 case study playbook against real customers
- Onboarding feedback loops — what did the Configuration Wizard get wrong; iterate
- Version migration patterns — first agent-version upgrade with real customers running older versions
- First DR drill retrospective in production — lessons from running drills with actual data
- Growth-phase ops maturity — how does the rotation change when we're at 10, 20, 30 tenants?
- First penetration test engagement
- Evaluation of SIEM / compliance automation as customer count grows

Phase 7 is entirely shaped by real data from first customers. Can't be pre-specified in detail; the runbooks that emerge depend on what actually breaks.

---

## Where the platform stands

With Phase 6 complete, the Clawd platform has documented specifications for:
- **Identity and strategy** (Session 0, 6 files)
- **Proof-of-concept validation** (Phase 1, 16 files)
- **Every agent in the suite** (Phase 2, 78 files)
- **Platform infrastructure** (Phase 3, 9 files)
- **Dashboard and customer-facing UX** (Phase 4, 11 files)
- **Business, legal, commercial** (Phase 5, 14 files)
- **Operational discipline** (Phase 6, 13 files)

Total: 150 files across 7 phases, ~45,000 lines of specification.

This is everything needed to build the platform, launch it commercially, run it day-to-day, and respond when things go wrong. The remaining work is: **build it**.
