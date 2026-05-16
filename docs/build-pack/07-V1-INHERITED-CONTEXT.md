# 07 · V1-Inherited Context

**Product knowledge v2 inherits without rethinking. ICP, pricing, brand voice, invariants, agent catalogue, integrations, compliance posture. So strategic work doesn't get re-relitigated during the build. Treat this file as canon — if v2 needs to deviate, that's a separate decision recorded in `08-OPEN-DECISIONS.md`.**

---

## 1. Company

| Fact | Value |
|---|---|
| Legal entity | Intel Force Ltd |
| Jurisdiction | England and Wales |
| Founder | Maddox Rigby |
| Customer-facing emails | hello@ · support@ · security@ · privacy@ at the chosen product domain |
| Domain (v1) | intelforce.ai |
| Domain (v2) | TBD — see `08-OPEN-DECISIONS.md` §2 |

---

## 2. Product positioning

**Category:** A managed agent workforce for UK service businesses. Priced and pitched against headcount, not against other SaaS tools.

**One-liner (platform):** *Ten agents that run your operations — drafts, leads, content, follow-up, reporting — while you handle the bits humans are for.*

**One-liner (HR wedge, when leading with HR):** *Your HR inbox, handled.*

**Three differentiators:**
1. It uses YOUR data (handbook, past replies, voice profile — not a generic template)
2. It runs on triggers, not prompts (call ends, message arrives, deal closes — agent acts)
3. It escalates when uncertain (sensitivity ≥ 0.7 = humans-only, no AI draft)

---

## 3. The non-negotiable invariants

These survive v1 → v2 unchanged. v2 enforces them at the architectural level, not just the policy level.

1. **Everything drafts, nothing sends without human approval.** Every agent output goes through the approval queue. The only auto-sent messages are holding replies for escalations.
2. **Sensitivity ≥ 0.7 never gets AI-drafted.** Grievance, resignation, salary, illness disclosure — escalate with a holding reply, no draft offered.
3. **The human decision-maker is the trust anchor**, not the employee/prospect/candidate. Features serve the operator's confidence.
4. **One product, many agents.** Customers install once; new agents light up over time. No multi-product fragmentation.
5. **Customer side: zero Azure / minimal cloud-vendor exposure.** Install = open the dashboard, click connect on integrations.
6. **Data residency:** UK-hosted at edge, Postgres in UK region, vault in UK region. Anthropic transfers via UK-US data bridge.
7. **Seven-year audit retention** for compliance.

These map to concrete v2 architecture (see `03-ARCHITECTURE.md` and `04-DATA-MODEL.md`). The build plan enforces them in Phase 1 (governance package), Phase 2 (UI surfaces them), and Phase 3 (DPA wording reuses v1's).

---

## 4. The 11 agents (canonical catalogue)

Lifted from `/Users/madsadmin/code/intel-force-os/apps/dashboard/lib/agent-catalog.ts`. Identical names, directors, descriptions, integrations. v2 ports verbatim to `packages/agents/catalog.ts`.

| # | Agent | Director | Schedule | Output | Integrations |
|---|---|---|---|---|---|
| 01 | HR Assistant | HR | On-demand | Drafts ready for review | MS Teams, Slack, Email, Breathe HR, Company handbook |
| 02 | Email Handler | HR | On email | Inbox triaged | Email, Breathe HR |
| 03 | Proposal Builder | Sales | On call-end | £24,200 engagement | Fathom, HubSpot, Notion |
| 04 | Lead Hunter | Sales | Daily 08:00 | 38 qualified leads | HubSpot, Companies House, Clay |
| 05 | Follow-Up Pilot | Sales | Hourly | 21 sends · 7 replies | Gmail, HubSpot, Calendly |
| 06 | Content Creator | Marketing | On-brief | 4 drafts queued | Notion, Google Docs |
| 07 | Repurposer | Marketing | On pillar publish | 9 derivative pieces | Notion, Buffer |
| 08 | Caption Writer | Marketing | Daily 07:00 | 17 captions ready | Buffer, Google Drive |
| 09 | Client Onboarder | Operations | On contract sign | 2 in progress | DocuSign, Slack, ClickUp |
| 10 | Reporting Engine | Operations | Friday 07:00 | Weekly briefing | Stripe, GA4, Meta Ads, Slack |
| 11 | SOP Writer | Operations | On Loom upload | 34 SOPs in library | Loom, Notion |

Per-agent full descriptions in v1's `lib/agent-catalog.ts`. Used unchanged in v2 except for prompt files (which need adaptation to cortextOS's agent template format — see `06-BUILD-PLAN.md` Phase 2).

Plus a **12th hidden agent**: Orchestrator (the "Boss"). cortextOS-native role, not in v1. Talks to the founder via Telegram, decomposes goals, schedules cron jobs, routes work to the eleven specialists.

---

## 5. Pricing

### Founding-phase (first 10 customers)

- **£400/month, billed monthly, cancel anytime**
- Annual prepay option: £4,000/year (~17% effective discount)
- Founding customer rate locked for 12 months from signup
- "In exchange for founding rate: (a) honest feedback, (b) reference/testimonial willingness after 3 months"

### Post-founding tiers (customers 11+)

| Tier | £/mo | Agents | Seats | Integrations | Runs/mo |
|---|---|---|---|---|---|
| Starter | £450 | 5 (HR Assistant, Email Handler, Proposal Builder*, Client Onboarder, Reporting Engine, Caption Writer) | 1 | 3 | 100 |
| Growth | £1,800 | + Lead Hunter, Content Creator, Repurposer, Follow-Up Pilot | 3 | 5 | 500 |
| Scale | £4,500 | + SOP Writer | 10 | Unlimited | 2,000 |
| Enterprise | From £10,000 | All | Unlimited | Unlimited | Custom |

v2 preserves the pricing model. Migration of founding customers to v2 happens at their existing £400/mo rate; new customers signed up to v2 use the post-founding tiers.

---

## 6. ICP

### Primary (HR wedge / first agent)

| Attribute | Spec |
|---|---|
| Country | UK (not Ireland, not Channel Islands) |
| Headcount | 20–200 employees |
| HR system | Breathe HR (preferred), BambooHR, PeopleHR, CharlieHR |
| Persona | 1 dedicated HR person OR Ops/Office Manager doing HR |
| Industry | Professional services, tech/SaaS, agencies, healthcare (non-NHS), manufacturing |
| Revenue | £1M–£20M |
| Buying signal | Recent HR hire, recent HR-tool purchase, LinkedIn post about being overwhelmed |

### Secondary (agency operators, full agent suite)

Small-to-mid agencies (£300k–£10M revenue), principal-led, with repeatable workflows. Buyer is founder/MD/COO.

### Anti-ICP

- <20 emp
- \>500 emp (have Workday/HiBob)
- NHS / public sector
- US/international
- Recruitment agencies
- CEO-as-HR-lead orgs
- Heavily regulated (big finance, law) without v2 having SOC 2

---

## 7. Brand identity (v1 canon)

### Voice pillars
- Direct: "Intel Force OS runs your agents. You review what it produces."
- Specific: "Drafts a proposal 4 minutes after the Fathom call ends."
- Honest about limits: "Nothing sends without you."
- Quiet confidence: no hype superlatives.
- British English: optimise, behaviour, catalogue, personalise.

### Banned phrases (zero exceptions)
- "AI-powered"
- "Revolutionary" / "cutting-edge" / "game-changing"
- "Leverage" (as a verb)
- "In today's fast-paced world…"
- Exclamation marks in body copy
- "Users" (they're customers/tenants/operators)

### Visual identity

| Token | Value |
|---|---|
| Primary | Emerald 500 `#10b981` |
| Hover | Emerald 400 `#34d399` |
| Pressed | Emerald 600 `#059669` |
| Secondary | Amber 500 `#f59e0b` |
| Anchor bg | `#09090b` (dark mode default) |
| Elevated bg | `#141414` |
| Border | `#262626` |
| Headline + body | Inter (variable, 400/500/600/700) |
| Mono | JetBrains Mono |

No serifs in the marketing site. Dark mode is the default. The dashboard inherits these tokens.

---

## 8. The four-objection microcopy

Every UK HR/Ops leader has the same four objections in the first five seconds. v1's microcopy answers all four:

| Objection | Answer (mono, neutral-500, under hero CTAs) |
|---|---|
| "Is this a US startup that'll disappear?" | UK-based |
| "Is this GDPR-safe?" | GDPR-ready |
| "Is this OpenAI junk that hallucinates?" | Built on Claude |
| "Will it send something stupid to my employees?" | Nothing sends without you |

Always lead with these four under the hero CTAs. v2 inherits unchanged.

---

## 9. Compliance posture

| Domain | v1 commitment | v2 commitment |
|---|---|---|
| Data residency | UK-hosted edge | UK-hosted edge (Neon UK-East, Cloudflare R2 EU/UK, Fly.io LHR region) |
| Encryption at rest | Per-tenant keys | Per-tenant DB encryption + R2 SSE-KMS for vault |
| Encryption in transit | TLS 1.3 | TLS 1.3 |
| Audit retention | 7 years | 7 years (governance.audit_log + immutable R2 archive) |
| GDPR | Ready (DPA template exists) | Ready (same DPA, jurisdiction unchanged) |
| Sub-processors | Anthropic, Cloudflare, Resend, Clerk, Stripe | + Neon, Fly.io. List published at /security |
| SOC 2 | In progress, target late 2026 | Inherited target |
| ISO 27001 | Scoped for 2027 | Inherited target |
| Sensitivity threshold | ≥ 0.7 = humans-only | Same |

---

## 10. Integrations expected at GA

Lifted unchanged from v1. Each is an adapter agents call through; the wiki+graphify brain ingests data from them on connect.

- Microsoft Teams (HR Agent surface, primary v1)
- Slack (HR Agent + general agent-to-operator)
- Telegram (v2-primary control surface)
- Gmail / Microsoft 365 (HR Agent, Email Handler, Follow-Up Pilot)
- Breathe HR (HR Agent, Email Handler)
- HubSpot (Proposal Builder, Lead Hunter, Follow-Up Pilot, Client Onboarder)
- Fathom (Proposal Builder)
- Notion (Proposal Builder, Content Creator, Repurposer, SOP Writer)
- Stripe (Reporting Engine, billing)
- GA4 (Reporting Engine)
- Companies House (Lead Hunter)
- Clay (Lead Hunter)
- DocuSign (Client Onboarder)
- ClickUp (Client Onboarder)
- Calendly (Follow-Up Pilot)
- Loom (SOP Writer)
- Buffer (Repurposer, Caption Writer)
- Google Drive (Caption Writer, Content Creator)

---

## 11. Customer journey (lifted from v1, will need adaptation)

```
DISCOVER          → marketing site (intelforce.ai or new domain)
                  → 3-min demo Loom + book a call CTA
DEMO CALL         → 30 minutes with founder
                  → connect sandbox to their tools live
                  → show real piece of work happening (proposal / HR reply)
SIGN              → MSA + DPA (PDF, e-signed)
                  → £400/mo (founding) or tier price
ONBOARD (24-72h)  → wizard: tools connect, voice profile, integrations
                  → first agent goes live (HR Assistant usually)
                  → operator co-reviews first 200 outputs
GROW              → weekly performance report
                  → monthly review call
                  → additional agents layered in
COMPOUND          → by month 3 the system reads like the operator
                  → by month 6 the Brain density is markedly higher
                  → by month 12 the moat is real
```

v2 preserves this flow. The wizard step changes to include Telegram bot creation + brain initial ingest.

---

## 12. v1 surfaces that v2 inherits without modification

Lift unchanged in product terms:

- The MSA, DPA, SLA, AUP, Privacy Policy, Terms of Service templates from `intel-force-os/docs/phase-5-business-legal/legal/`
- The pricing FAQ from `intel-force-os/docs/phase-5-business-legal/pricing/pricing-spec.md`
- The sales playbook from `intel-force-os/docs/phase-5-business-legal/playbooks/sales-playbook.md`
- The case-study playbook from `intel-force-os/docs/phase-5-business-legal/playbooks/case-study-playbook.md`
- The trademark filing brief
- The DPA sub-processor list (extend with Neon, Fly.io)

These are non-engineering artefacts but they're part of "context v2 inherits".

---

## 13. The strategic plan v2 inherits without revising

From `intel-force-os/docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md`:

- **Year 1 target**: £100k ARR
- **Year 2 target**: £1M ARR
- **Founding-cohort programme**: first 10 customers @ £400/mo, 12-month rate lock, expected to provide testimonials at month 3
- **Geographic focus**: UK first, EU later, US never (or not for years)
- **Channel**: founder-led sales, no sales team, no paid acquisition until month 6+

These remain canon for v2. The question is not "should we revisit this strategy" but "does v2 enable us to actually hit it" — and the answer is yes, more so than v1 did, because the brain visualisation and Telegram control surface materially improve the demo.

---

## 14. What this file does NOT lock

- The product *name* (Intel Force OS continues? something else? see `08-OPEN-DECISIONS.md` §2)
- The post-Phase-3 roadmap (iOS, theta-wave UX, multi-region)
- The migration order of v1 customers (who goes first; who never migrates)
- Whether the marketing site rebrands

These remain open and live in `08-OPEN-DECISIONS.md`.
