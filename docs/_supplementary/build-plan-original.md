# IntelForce AI OS — The Full Build Plan
**Engineering-grade specifications for every agent, every platform component, and every supporting system.**

> *Supersedes no prior documents — this sits alongside the Strategic Plan (v1) and Technical Strategy (v2) as the execution specification.*

---

## Contents

**Part I — Foundations**
1. Reference sub-agent architecture (the template every agent inherits)
2. Standard output validation & human-review gates
3. Context injection strategy
4. Cost budgeting per agent invocation

**Part II — The Nine Core Agents**
5. Lead Hunter
6. Proposal Builder *(flagship — deepest spec)*
7. Follow-Up Pilot
8. Content Creator
9. Repurposer
10. Caption Writer
11. Client Onboarder
12. Reporting Engine
13. SOP Writer

**Part III — The Add-Ons**
14. Voice Receptionist
15. HR Agent
16. SEO Brief Generator
17. Paid Ads Copywriter

**Part IV — The Hidden Tenth**
18. The Librarian *(memory hygiene agent)*

**Part V — Platform Components**
19. The Provisioning System
20. The Configuration Centre Wizard
21. The Dashboard
22. The Webhook Receiver
23. The Scheduler
24. The MCP Integration Layer
25. The Vault Service
26. Observability Stack
27. Cost & Billing System
28. Audit & Compliance
29. The Human-in-the-Loop Approval System

**Part VI — The Agency Partner White-Label Layer**
30. Multi-tenant-within-tenant architecture

**Part VII — Build Sequencing**
31. Fourteen-week build plan, ordered by dependency

---

# PART I — FOUNDATIONS

## 1. Reference sub-agent architecture

Every agent in IntelForce AI OS conforms to a single specification. This matters because the provisioning system only works if the agents are uniform. Deviation costs weeks.

### 1.1 File structure per agent

```
/agents/{agent-name}/
  agent.md                ← the sub-agent definition (YAML frontmatter + system prompt)
  config.schema.json      ← what the wizard collects from the client
  tools.yaml              ← required MCP servers + fallbacks
  validate.sh             ← output validation script (runs as PostToolUse hook)
  context.sh              ← context hydration script (runs as SessionStart hook)
  tests/
    fixtures/             ← realistic test inputs
    expected/             ← golden outputs
    run.sh                ← test harness
  README.md               ← human-readable spec
  CHANGELOG.md            ← versioned changes
```

### 1.2 The agent.md template

Every `agent.md` has the same structure:

```
---
name: <kebab-case-name>
description: <one sentence, <160 chars, used by Claude to decide when to dispatch>
model: haiku|sonnet|opus
tools: Read, Write, Edit, <mcp__server__tool>, ...
permission_mode: default|acceptEdits|plan
---

# Role
<2–3 sentences: who this agent is, what outcome they own>

# Context (auto-injected at session start)
<The context.sh hook writes into this section dynamically:
 - Client profile summary
 - Relevant vault notes (retrieved via vector search)
 - Recent activity summary>

# Workflow
1. <step, numbered, explicit, imperative>
2. <step>
3. ...

# Output specification
<exact structure the agent must produce — file path, format, required fields>

# Quality gates (self-check before completing)
- [ ] <checklist item>
- [ ] <checklist item>

# When to escalate
<precise list of conditions under which the agent stops and requests human review>
```

The "Workflow" section is where most of the prompt-engineering craft lives. Rule: every step must be something a human could verify happened.

### 1.3 Versioning

Every agent is versioned (semver in `agent.md` frontmatter). The provisioning system records which version is deployed per tenant. When you ship `proposal-builder@2.1`:

- New tenants get 2.1 on deploy
- Existing tenants on auto-update roll forward overnight
- Pinned tenants (enterprise only) stay on their pinned version
- Rollback is a single command per tenant

Never edit an agent in place on a tenant. Always version-bump and re-deploy.

### 1.4 Testing every agent

Every agent ships with a test harness:

- **Fixture inputs** — real anonymised examples (redacted Fathom transcript, scrubbed lead list)
- **Golden outputs** — the exact proposal/email/report the agent should produce
- **Fuzzy match** — string comparison with tolerance for non-deterministic phrasing
- **Cost budget check** — a run that costs 3x the expected tokens is a regression

`./tests/run.sh` in each agent directory runs the suite. CI blocks a version bump if tests fail. You run this on your dev machine with your Max 20x (remember — Max for YOUR work, API keys for CLIENTS), against a test tenant container.

---

## 2. Standard output validation & human-review gates

Three concentric rings of safety on every agent output.

### 2.1 Structural validation (PostToolUse hook, synchronous)

The `validate.sh` script runs after every Write/Edit tool use. It returns 0 (pass) or non-zero (fail, output injected into context). Standard checks:

- Output is valid markdown/JSON/YAML per schema
- Required sections present (for a proposal: price, timeline, scope, signature block)
- No placeholders left in ("[INSERT CLIENT NAME]" → fail)
- No hallucinated facts where easy to check (prices matching a quoted line item in transcript)
- Length bounds (follow-up email < 200 words, proposal > 500 words, etc.)

If validation fails, Claude sees the failure and self-corrects in the same session. This is the single most impactful reliability lever in the whole system. Do not skip it.

### 2.2 Quality validation (LLM-as-judge, asynchronous)

After structural validation passes, a cheap Haiku call grades the output against a rubric before it's delivered to a human. Rubric varies per agent — for a proposal:

- Scope matches discovery call needs? (0–5)
- Pricing explicitly justified? (0–5)
- Timeline realistic given scope? (0–5)
- Tone matches brand voice profile? (0–5)

Threshold: average ≥ 3.5 → passes to human. Below → regenerates once with the rubric failures as feedback. Two failures → flag for manual review, no auto-send.

This catches the 10% of cases where structure is fine but content is mediocre. Haiku at $1/$5 per M tokens makes this nearly free.

### 2.3 Human review gate

Every external-facing output routes through an approval queue before it sends. This is non-negotiable for trust. Gate behaviours by agent:

| Agent | Gate behaviour |
|---|---|
| Proposal Builder | Hard gate — no auto-send. Always to sales lead's inbox for approval. |
| Follow-Up Pilot | Soft gate — approve-once-per-template, then auto-send subsequent variations |
| Content Creator | Hard gate — drafts go to `/outbox/drafts/` for human review |
| Repurposer | Soft gate |
| Caption Writer | Soft gate |
| Client Onboarder | Mixed — internal Slack channel creation is auto; welcome email is hard gate first time per client type |
| Reporting Engine | No gate — internal-only reports |
| SOP Writer | Soft gate — new SOPs flagged for review before being canonical |
| Lead Hunter | No gate — writes to CRM as "unqualified", human qualifies |
| Voice Receptionist | No gate — live calls (but with strict scope + escalation triggers) |

The approval system (§29) implements this as a queue in the dashboard. One-click approve, reject with comment, or edit-and-send.

---

## 3. Context injection strategy

Bad context is worse than no context. A sloppy dump of the vault into every session balloons cost and degrades output. The injection rules:

### 3.1 Three context tiers

- **Tier 1 (always present)** — `CLAUDE.md` (4KB max). Client name, industry, voice summary, key people, brand do/don'ts. This is the brain stem.
- **Tier 2 (task-specific, retrieved)** — for a Proposal Builder session, pull 3 past winning proposals semantically similar to this prospect's industry and deal size. Retrieved via pgvector query against the vault.
- **Tier 3 (explicit, linked)** — if the triggering event references specific documents (e.g., "draft proposal for the deal at HubSpot deal-id 12345"), pull that deal's full history.

### 3.2 Retrieval mechanics

pgvector stores embeddings of every note in the vault, refreshed on write. At session start, `context.sh` runs:

1. Takes the trigger payload (e.g. Fathom call transcript)
2. Generates embeddings of the key passages
3. Queries the tenant's vault index for top-k similar notes (k=5 typically)
4. Filters by tags (e.g. tag:winning-proposal for Proposal Builder)
5. Writes retrieved note contents into `CLAUDE.md` temporary append

This is how the vault stays useful as it grows. Without retrieval, a 6-month-old vault degrades every agent.

### 3.3 Embedding model choice

Use `text-embedding-3-small` via OpenAI API (~$0.02 per M tokens) or Cohere's `embed-v3` (GDPR-friendly, EU-hosted). For UK-sovereign positioning, Cohere is the right story even if slightly more expensive. Don't use Anthropic for embeddings — they don't expose an embedding endpoint, and your infra is already Anthropic-heavy for text gen.

### 3.4 Context budget

Per agent invocation:
- Tier 1: ~1,500 tokens
- Tier 2: ~3,000 tokens (5 notes × 600 tokens avg)
- Tier 3: ~5,000 tokens when triggered
- Trigger payload: variable (Fathom transcript = 5–15k tokens)

Total context per invocation: 10–25k tokens typical. With prompt caching on the Tier 1 + Tier 2 stuff that's shared across invocations, effective cost is ~10% of input rate. This is how the £80–180/mo per tenant cost target holds.

---

## 4. Cost budgeting per agent invocation

Hard rule: every agent declares its expected cost envelope. Runs that breach the envelope trigger an alert. This is the early-warning system for model regression, prompt bloat, or a runaway loop.

Budget per invocation (target, across Haiku/Sonnet/Opus split):

| Agent | Invocations/month/tenant | Tokens/invocation | Cost/invocation | Monthly cost |
|---|---|---|---|---|
| Lead Hunter | 360 (every 2h) | 3k in / 2k out | £0.02 | £7 |
| Proposal Builder | 20 | 15k in / 8k out | £0.22 | £4 |
| Follow-Up Pilot | 60 | 4k in / 1k out | £0.05 | £3 |
| Content Creator | 40 | 6k in / 5k out | £0.12 | £5 |
| Repurposer | 40 | 10k in / 8k out | £0.18 | £7 |
| Caption Writer | 300 | 2k in / 500 out | £0.01 | £3 |
| Client Onboarder | 4 | 8k in / 6k out | £0.15 | £0.60 |
| Reporting Engine | 4 | 20k in / 6k out | £0.18 | £0.72 |
| SOP Writer | 20 | 12k in / 5k out | £0.15 | £3 |
| Librarian | 30 | 8k in / 2k out | £0.05 | £1.50 |
| **Core total** | | | | **~£35/mo** |

Add ~50% overhead for retries, LLM-as-judge validation, embedding generation: **~£50/mo**. Well under the £100–180 bucket I projected earlier, which leaves comfortable headroom for heavier clients.

Total cost per tenant composed of:
- **API (Anthropic + OpenAI/Cohere embeddings):** £50–100/mo
- **Third-party data APIs (Prospeo/Kaspr lead enrichment, etc.):** £30–80/mo
- **Infra (tenant container slice, Postgres row, storage):** £15–30/mo
- **Grand total COGS:** £95–210/mo against retainer £800–2,000.

Instrumentation: every agent logs cost-per-invocation to `/logs/cost/`. The control plane aggregates. Dashboard shows per-tenant, per-agent monthly spend. Alert at 80% of budget, hard-cap at 100% (agent refuses new invocations until next cycle or budget bump).

---

# PART II — THE NINE CORE AGENTS

Per-agent specs. Every agent follows the foundation above; below each one adds its unique specification.

## 5. Lead Hunter

### Purpose
Turn a client's ICP definition into a steady stream of qualified, enriched, GDPR-compliant leads in their CRM, hourly.

### Outcome metric
Qualified leads added per week, measured by the %-that-receive-first-reply rate from the Follow-Up Pilot. Under 5% reply → Lead Hunter is producing junk → re-tune the ICP filter.

### Trigger
Cron — every 2 hours during UK business hours (07:00–19:00 weekdays). Also manual "Run now" from dashboard.

### Model
**Haiku 4.5.** Qualification is pattern-matching against an ICP schema, not complex reasoning. Don't waste Sonnet on this.

### Inputs & preconditions
- Client's `icp.yaml` (from wizard): industry SIC codes, employee size bands, geography, revenue range, tech stack signals, red flags
- Seed query (keyword, role, or geography cue rotated from a queue)
- Deduplication index (company domains already in CRM)

### Integrations
- **Companies House API** (free, UK-authoritative firmographic data) — primary source for UK SMEs
- **Prospeo API** (£cheap, 98% email accuracy, 7-day refresh) — contact enrichment
- **Kaspr API** — LinkedIn-sourced mobile numbers (Tier 2+ only; not cheap enough for Tier 1)
- **Cognism MCP** — only for Agency Partner and Enterprise tiers (£20k+/year; bakes into their pricing, not yours)
- **HubSpot MCP** — write qualified leads to CRM with proper pipeline stage and lead source tagging
- Fallback: if an integration is down, write to `/intake/leads-pending/` and retry next cycle

### Prompt architecture
System prompt sections:
- **Role** — "You qualify leads against the ICP. Quality over quantity."
- **ICP** — full ICP spec, including explicit disqualifiers ("never flag companies under 5 employees", "never include known past clients")
- **Workflow** — (1) pull candidate list from source, (2) dedupe against CRM, (3) score against ICP rubric, (4) enrich top 10, (5) write to CRM with tags
- **Scoring rubric** — 0–5 per dimension, must hit >3.5 average
- **Output** — structured JSON per lead: `{company, domain, icp_score, qualification_notes, enrichment_status}`
- **Quality gates** — no duplicates, no disqualifiers, every field populated
- **Escalate** — if source APIs return <30% of expected volume for 3 consecutive runs, flag ICP as possibly too narrow

### Output validation
- Schema check (JSON structure)
- Dedup check (hash against existing CRM record hashes)
- Per-lead completeness (all required fields non-null)
- Write to CRM succeeded (MCP returned success)

### Edge cases
- Companies House rate limits (600/5min — respected via in-memory counter)
- Prospeo returns zero emails for a company → still write lead, mark `enrichment_pending`
- ICP rubric consistently fails → agent pauses itself, flags control plane
- CRM temporarily unreachable → queue to disk, retry on next run, alert if 3 consecutive failures
- Duplicate companies at different domain variations (acme.com vs. acmeco.uk) → domain-normalisation lib

### Human review gate
None during write (goes in as "unqualified" stage). SDR or sales lead qualifies in CRM. This is the right boundary — pre-qualification doesn't require human judgement at volume, final accept/reject does.

### Quality metrics
- **Coverage** — leads added per run (target 10–30)
- **Precision** — % of leads that survive human qualification (target >40%)
- **Reply rate downstream** — % from Follow-Up Pilot that get any response (target >5%)
- **Cost per qualified lead** — (total Lead Hunter monthly cost + enrichment API costs) / qualified leads. Track and optimise.

### Build complexity
Medium. The moving parts are the integration wrappers; the agent itself is a thin orchestrator. Budget 5 days to build, 3 to harden.

---

## 6. Proposal Builder — *flagship agent, deepest spec*

This is your demo agent. Get this one perfect. Everything else can be 80% and you're fine. Proposal Builder at 80% kills your trust story.

### Purpose
From a discovery call ending, produce a fully-scoped, on-brand, price-accurate proposal in the sales lead's inbox within 120 seconds — ready for human review and a single-click send.

### Outcome metric
**"Fathom call end" → "proposal in inbox" median time.** Target: <120s. Also: proposal-to-signed-contract conversion rate, measured monthly. Baseline against client's historical rate; target ≥ parity within 60 days.

### Trigger
Fathom webhook `recording.complete` with `include_transcript: true, include_summary: true, include_action_items: true`. Payload lands at `hooks.intelforce.ai/{tenant}/fathom`, persists to `/intake/fathom/{call-id}.json`, triggers the agent.

Manual override from dashboard: "Regenerate proposal for call XYZ."

### Model
**Sonnet 4.6** default. Allow escalation to Opus 4.7 via a `--complex` flag the agent can set itself if the call transcript exceeds 30 minutes or includes >3 distinct workstreams (multi-project scope is Opus territory).

### Inputs & preconditions
- Full call transcript with speaker labels and timestamps
- Fathom AI summary + action items
- Calendar invite metadata (attendees, their company domain, meeting type)
- Tenant's brand voice profile (from vault)
- Top 3 most similar past winning proposals (retrieved from vault via pgvector — "similar" = same industry + similar deal size)
- Client's pricing framework (from vault: day rates, package prices, retainer structures)
- Any explicit references mentioned in the call (case studies, articles, prior work)
- Sales lead's email signature block

### Integrations
- **Fathom MCP** (use `matthewbergvinson/fathom-mcp` or `Dot-Fun/fathom-mcp` as starting point; fork and productize) — transcript, summary, action items
- **HubSpot MCP** — create deal record, associate with contact, set stage to "Proposal Sent"
- **DocuSign MCP** — generate envelope from templated proposal, prepare for send (but don't send; queue for human)
- **Notion MCP** — save canonical proposal to `/vault/clients/{client}/proposals/{date}-{company}.md`
- **Gmail MCP** — draft email to sales lead with proposal attached (do NOT auto-send)

### Prompt architecture — the full structure

```
# Role
You are a senior proposal writer for [client-name]. You've read every winning 
proposal they've ever sent. Your job: produce a tight, specific, on-brand 
proposal from a discovery call transcript. Never pad. Never hedge. 
The recipient is a busy decision-maker who will read this in 4 minutes.

# Context (injected by context.sh)
## Client voice profile
<content of /vault/brand/voice-profile.md>

## Pricing framework  
<content of /vault/brand/pricing.md>

## Three closest past winning proposals
<content of 3 retrieved proposals with metadata: close rate, deal size>

## This deal
Company: [prospect-company]
Attendees: [names and roles]
Meeting type: [discovery/follow-up/closing]
Fathom URL: [link for audit]

## Discovery call
### Summary
<Fathom summary>

### Action items  
<Fathom action items>

### Full transcript
<transcript — truncated to 40k tokens if longer, with a note>

# Workflow
1. Identify the prospect's ACTUAL stated problem (not what they say they want — 
   what they repeated, circled back to, or emphasised). Quote the phrases.
2. Identify constraints: budget cues, timeline cues, decision-maker absences.
3. Propose scope. Three tiers allowed MAX (Good/Better/Best). Don't invent new 
   scope; use the client's pricing framework.
4. Price the scope using the pricing framework. Round to realistic numbers 
   (£4,800 not £4,791). Never leave prices as TBD.
5. Write the proposal per output spec below.
6. Self-check against quality gates.
7. Save to /outbox/proposals/{date}-{company}.md
8. Use Gmail MCP to draft (not send) an email to the sales lead with:
   - Subject: "[DRAFT] Proposal for {company} — ready for your review"
   - Body: 2-sentence summary of the pitch, price, timeline
   - Attachment or link: the proposal doc
9. Update the HubSpot deal record.

# Output specification — the proposal document
The proposal MUST have these sections in this order:

1. **Opening** (3 sentences max) — demonstrates you heard them. References 
   something specific they said.
2. **Their situation** (5 bullets max) — reflects back the problem.
3. **Our approach** (prose, 1-2 paragraphs) — the solution shape.
4. **Scope** (bullet list per tier if tiered, else flat). Specific deliverables.
5. **Timeline** (table: milestone | week | deliverable).
6. **Investment** (clear price per tier, payment structure).
7. **Next step** (one concrete action, dated).
8. **About us / case studies** (1 page max, tailored to their industry if 
   possible — pull from vault).
9. **Signature block** (sales lead's standard block).

# Quality gates (self-check)
- [ ] Every price has a rationale (mapped to the pricing framework)
- [ ] Timeline is realistic (no "1 week" for a 4-week job)
- [ ] Prospect's own words appear at least twice
- [ ] No placeholders, no TBDs, no [INSERT X]
- [ ] Length: 2–4 pages max
- [ ] Tone matches voice profile (run your own rubric check)
- [ ] Case study chosen is actually relevant to their industry

# When to escalate (do not send, flag for human)
- Transcript mentions a budget below the client's minimum threshold
- Prospect indicated they are talking to >3 competitors
- Deal value in discussion >£50k (partner-tier decisions always human)
- Scope includes anything outside the client's normal service list
- Transcript sentiment analysis suggests prospect is skeptical or unconvinced
- Discovery call was <15 minutes (not enough signal)
```

### Output validation (validate.sh)
1. File exists at expected path
2. Markdown parses cleanly
3. All 9 required sections present (regex on headings)
4. Price format matches `£\d{1,3}(,\d{3})*` — no decimals, no "TBD"
5. No placeholder strings
6. Length between 800 and 2,500 words
7. At least one quoted phrase from transcript present verbatim

Fail → injected back into Claude's context → regenerate once → if still failing, escalate to human.

### LLM-as-judge rubric (Haiku pass)
- Specificity (did it read the call, or produce generic text?) 0–5
- Brand voice match 0–5
- Pricing justifiability 0–5
- Timeline realism 0–5
- Hook strength (does the opener demonstrate listening?) 0–5

Threshold: avg ≥ 3.8 (higher than other agents because this is the trust-critical one). Below → regenerate with feedback.

### Edge cases
- Very short call (<10 min transcript) → defer, ask human for context
- Call transcript has no price discussion → produce proposal at the client's "standard" package tier, flag clearly
- Multiple companies on the call (consultant + end client) → agent identifies buyer entity from email domains
- Call in a non-English language → escalate (don't try to translate)
- Fathom summary contradicts transcript → trust transcript, flag contradiction
- Proposal generates successfully but Gmail MCP is down → save to outbox, notify sales lead via dashboard instead
- Prospect is an existing client upselling → pull past deals, reference existing relationship
- Call was recorded but ended with "I'll send this over tomorrow, not now" → agent detects this cue and holds the draft, notifies human

### Human review gate
**Hard.** Always. No exceptions. The sales lead sees the draft in their Gmail, one-click sends or edits. This is the single most important trust boundary in the whole product. **Market this as a feature, not a limitation.**

### Quality metrics
- Generation time (target <120s)
- First-pass acceptance rate (% sent without edits — target 60%+)
- Edit distance (avg chars changed by human — proxy for quality)
- Conversion rate (proposal → signed contract) — against client's historical baseline
- Hallucination incidents (flagged per quarter — target 0, acceptable <2 per 1000)

### Cost profile
Per invocation: Sonnet 15k input / 8k output with caching = ~£0.22. Plus Haiku judge ~£0.01. ~20 invocations/month/tenant = £4.60. Worth every penny.

### Build complexity
**High.** The prompt engineering alone is a full week of iteration against real calls. The integrations (Fathom + HubSpot + DocuSign + Notion + Gmail) are another week. The validation tooling is 3 days. Budget 3 weeks total to get to production quality. You CANNOT rush this one.

### The week-1 experiment
This is your proof point from the v2 strategy. Get Proposal Builder end-to-end with ONE real discovery call → proposal in inbox. If that works, everything else is assembly.

---

## 7. Follow-Up Pilot

### Purpose
Detect dormancy in the sales pipeline and send on-brand, value-adding follow-ups that book meetings or surface disqualifications.

### Outcome metric
**Reactivation rate** = % of dormant deals that get a response within 7 days of Follow-Up Pilot contact. Target: >12%.

### Trigger
Cron — daily 10:00 and 15:00 UK time. On each run, queries HubSpot for deals that:
- Are in an active stage (not Closed Won or Closed Lost)
- Have had no activity for >7 days (Tier 1 clients) or >3 days (aggressive pipelines)
- Have a flagged "next step" in the deal notes

Also event-triggered: HubSpot webhook on stage change that fires "deal went cold" detection.

### Model
**Sonnet 4.6** for email drafting. The prose has to be good; Haiku produces flat text. Haiku only for the dormancy-detection pre-filter.

### Inputs & preconditions
- Deal record from HubSpot
- Full contact history with the prospect (all past emails, call notes)
- Brand voice profile
- Relevant collateral (case studies, articles) from vault
- "Permission level" setting (how aggressive the client wants follow-ups to be)

### Integrations
- **HubSpot MCP** — read deals, write activity log, update last-touched timestamp
- **Gmail MCP** — draft emails (soft-gated — see below)
- **Calendly/Cal.com MCP** — include availability link in follow-ups

### Prompt architecture
- **Role** — "You write follow-ups that add value, not pressure. Every email has ONE reason to exist beyond 'checking in'."
- **Context** — deal history, prospect's stated interests, time since last contact, signals from most recent touch
- **Workflow** — 
  1. Determine WHY you're writing (new relevant news? prospect's own deadline approaching? gentle nudge after 14 days silent?)
  2. Write the email — 60 words max. Plain text. No GIFs, no fluff.
  3. Propose a specific next step (calendar link, deliverable offer, disqualification question)
  4. Draft to Gmail, log in HubSpot
- **Output spec** — email body, subject line, Gmail draft ID, HubSpot activity ID
- **Quality gates** — <60 words, no "just checking in", specific ask, linked asset if relevant
- **Escalate** — if no activity in >60 days or prospect previously said "not now, 6 months" → produce a soft-close email ("mind if I close this out?") and flag

### Output validation
- Word count <60
- Subject line present and not generic ("Re: our chat" is a fail)
- At least one specific detail from deal history
- No banned phrases ("just checking in", "circling back", "bumping this up")
- Calendar link present if trigger = "book meeting"

### Edge cases
- Prospect replied with "unsubscribe" or hostile tone → immediately flag, no further follow-ups, add to exclusion list
- Multiple deals for same prospect → consolidate into one email
- Prospect's email bounced → trigger CRM enrichment via Prospeo to refresh
- Same prospect re-surfacing via different channel (webform) → detect, don't double-touch

### Human review gate
**Soft.** First time a template fires per client setup, human approves. After that, auto-send per template until content drifts (detected by LLM-as-judge confidence dropping below threshold).

### Quality metrics
- Reply rate (overall, and segmented by template)
- Positive vs. negative reply ratio
- Meetings booked per week
- Unsubscribes per month (target <1%)

### Cost profile
~£3/mo per tenant. Cheap.

### Build complexity
Medium-low. 4 days to build, 3 days to tune the templates against real pipelines.

---

## 8. Content Creator

### Purpose
From a one-line brief, produce long-form content (articles, scripts, thought-leadership posts) in the client's voice.

### Outcome metric
**First-pass publish rate** — % of generated drafts that get published without substantive human edits. Target: >50% at month 3. Higher as voice profile matures.

### Trigger
Webhook from a Notion database entry — client adds a row ("Brief: 1200 words on why Invisalign costs what it costs, for our blog") and the agent fires.

Also cron-triggered: a weekly "content backfill" run that generates drafts against an editorial calendar maintained in the vault.

### Model
**Sonnet 4.6** baseline. Opus 4.7 for Tier 2+ clients whose voice is highly distinctive or technical.

### Inputs & preconditions
- The brief (topic, angle, length, format, audience)
- The client's voice profile (≥5 sample pieces, ingested at onboarding)
- Editorial calendar / pillar themes
- Any reference materials linked in the brief
- Retrieval: 3 of the client's own highest-performing past pieces

### Integrations
- **Notion MCP** — source briefs, write drafts, move through editorial status
- **Google Docs MCP** — if client prefers Docs over Notion
- **Web fetch** — research sources (allow-listed domains only; no general web search)

### Prompt architecture
- **Role** — "You are [client-name]'s ghostwriter. You write as them, not about them. You match their rhythm, their quirks, their taboos."
- **Context** — voice profile + 3 retrieved past pieces + brief
- **Workflow** — 
  1. Outline (5–8 headings) — save to draft
  2. Draft section by section, maintaining voice
  3. Self-edit for rhythm (read-aloud check: any awkward clauses?)
  4. Fact-check claims against any cited sources
  5. Add SEO metadata (title, meta description) if brief flags "blog"
  6. Save to Notion with status "Ready for Review"
- **Output spec** — markdown with YAML frontmatter (title, meta, tags, publish-date-target)
- **Quality gates** — length within 10% of brief, no banned phrases from voice profile, no obvious AI tells ("In today's fast-paced world", "Let's dive in", etc.)

### Output validation
- Length check
- Banned-phrases regex (configurable per client)
- Heading structure (min 3, max 10)
- Links resolve (run link checker)
- Reading level matches profile target (Hemingway-score rough check)

### LLM-as-judge rubric
- Voice match (against 3 retrieved pieces) 0–5
- Argument coherence 0–5
- Absence of AI tells 0–5
- Specificity (examples, numbers, names) 0–5

### Edge cases
- Brief is too vague → agent generates a clarifying question back to the brief submitter, doesn't proceed
- Source research returns contradictory info → agent presents both, lets human choose
- Topic overlaps with a past piece — agent detects, links, and angles the new piece differently
- Client-specific taboo word appears in draft → agent auto-rewrites that paragraph

### Human review gate
**Hard.** All content goes to drafts folder for human approval before publish. Non-negotiable for reputational reasons.

### Quality metrics
- First-pass publish rate
- Edit distance post-human
- Engagement metrics if the client shares them back (opens, reads, shares)
- Voice-drift score over time (the LLM-as-judge score trending)

### Cost profile
£5/mo per tenant typical, £15 for heavy content clients.

### Build complexity
Medium. The integrations are light; the voice profile ingestion (§19.3) is where the real engineering goes.

---

## 9. Repurposer

### Purpose
Turn one pillar content piece into 5+ platform-native derivatives.

### Outcome metric
**Derivative engagement rate** — average engagement rate across platforms vs. the client's historical baseline. Target: ≥ parity (we're not trying to beat their own best, we're trying to give them 5x the surface area at same quality).

### Trigger
File-watcher on `/vault/content/pillars/` — new markdown file with status `published` → agent fires. Also manual "repurpose this" from dashboard.

### Model
**Sonnet 4.6** for the text; the format transforms are what matter more than raw reasoning.

### Inputs & preconditions
- The pillar piece (markdown)
- Metadata: what platforms the client publishes to
- Platform format specs (LinkedIn: 1300 chars optimal, IG carousel: 10 slides max, etc.)
- Brand voice profile
- Past high-performing derivatives from vault

### Integrations
- **Buffer MCP / Later MCP** — schedule posts (soft-gated)
- **Notion MCP** — store derivatives under the pillar piece
- **YouTube Data API** — for extracting transcript if pillar is a video (via an MCP wrapper)

### Prompt architecture
One sub-agent, but spawns internally with different "formats" via workflow steps:
1. LinkedIn post (1 hook + 3 points + 1 CTA, <1300 chars)
2. IG carousel (10 slide scripts — title, body, image prompt)
3. YouTube Short script (60s hook + body + end-screen prompt)
4. Email blast (subject + 150 words + link)
5. Twitter thread (hook + 5–8 tweets)

### Output validation
- Per-format length constraints
- Each derivative has a distinct hook (not cut-paste of pillar opening)
- No cross-platform contamination (LinkedIn tone in an IG caption = fail)
- CTA present on all derivatives

### Edge cases
- Pillar piece is evergreen → derivatives should match lifespan, not reference "this week's"
- Pillar piece is very technical → agent produces simpler derivatives + flags the pillar itself might not repurpose well
- Images not provided → agent writes image prompts the client can send to an image generator

### Human review gate
**Soft.** Client can set "auto-schedule" per platform once they've approved 5 sets.

### Cost profile
£7/mo typical.

### Build complexity
Low-medium. 1 week.

---

## 10. Caption Writer

### Purpose
Platform-native social captions for daily posts, with CTAs and posting-ready formatting.

### Outcome metric
**Post-to-engagement ratio vs. client baseline.**

### Trigger
Cron — daily at 16:00 UK time, looking at the next day's content queue.

### Model
**Haiku 4.5.** Pure pattern work. Sonnet is wasted.

### Inputs
- The asset (image / video / carousel) metadata
- Platform
- Caption history (last 50 captions for this client — for non-repetition)
- Brand voice

### Integrations
- **Buffer MCP** — schedule
- **Google Drive MCP** — asset location
- **Instagram Graph API** (via a small wrapper) — optional direct publish

### Prompt arch
- Role: "You write scroll-stopping captions, on-brand, platform-native."
- Workflow: hook (first 3 words), body (max 150 chars before the "more" cut), CTA, hashtags (5–8, not 30).
- Output: `{platform, caption, hashtags, scheduled_time}`

### Edge cases
- Asset is product-focused vs. educational → different CTA patterns
- Caption duplicates recent structure → regenerate
- Hashtag is on a "banned" list (client-specific) → regenerate

### Human review gate
**Soft after first 5 approved.**

### Cost: £3/mo. Build: 3 days.

---

## 11. Client Onboarder

### Purpose
When a client of the client signs a contract, fire the full onboarding sequence automatically: welcome email, intake form, Slack/Teams channel, kickoff invite, folder structure, contract storage.

### Outcome metric
**Time-to-first-value for the new client** — from contract signature to first deliverable action. Benchmark against pre-automation baseline.

### Trigger
DocuSign webhook `envelope-completed` or Stripe webhook `invoice.paid` (whichever signals "new client" in this client's workflow, configured in wizard).

### Model
**Sonnet 4.6** for the welcome email (it's the first impression); **Haiku 4.5** for the admin (folder creation, channel setup).

### Inputs
- Contract document (signed)
- Client CRM record
- Client's onboarding playbook (from vault or wizard)
- Assigned account manager

### Integrations
- **DocuSign MCP** (or Stripe) — trigger
- **Gmail MCP** — welcome email (hard-gated first time per client type)
- **Slack MCP** — create channel, invite team
- **Microsoft Teams MCP** — alternative for Teams-native clients
- **Google Drive MCP / Dropbox MCP** — folder structure
- **Notion MCP** — client workspace creation
- **Calendly/Cal.com MCP** — kickoff meeting invite
- **ClickUp/Asana MCP** — project template instantiation

### Prompt arch
- Role: "You are the client's first impression of working with [company]. Make it feel premium."
- Workflow: 5 parallel subtasks (email, Slack, folders, project, calendar) + 1 sequential wrap-up ("summary in sales lead's inbox").
- Output: structured report of what fired, what's pending, what needs human action.

### Edge cases
- DocuSign fires for a non-client envelope (internal doc) → filter by template ID
- Client already exists in CRM → skip creation, append to existing
- Slack channel name collides → append numeric suffix
- Email lookup fails → escalate to human

### Human review gate
**Mixed.** Welcome email: hard gate on first ever, then approve-per-template. All admin: auto.

### Cost: £0.60/mo. Build: 1 week (lots of integrations).

---

## 12. Reporting Engine

### Purpose
Pull data from every tool the client uses, produce a weekly executive briefing in Slack + a PDF, Friday 07:00.

### Outcome metric
**Client open rate of the report + stated actions taken from it** (measured in quarterly review).

### Trigger
Cron — Friday 07:00 UK time. Also manual.

### Model
**Sonnet 4.6.** This is synthesis, not boilerplate.

### Inputs
- Last 7 days of data from: Stripe, GA4, Meta Ads, Google Ads, HubSpot, CRM, LinkedIn Ads, Shopify (if retail client), Klaviyo, etc.
- Previous week's report (for delta)
- Client's reporting template (from wizard)
- Client's north-star metrics (set at onboarding)

### Integrations
- **Stripe MCP** — revenue metrics
- **GA4 MCP** — traffic + conversion
- **Meta Ads MCP / Google Ads MCP** — paid performance
- **HubSpot MCP** — pipeline metrics
- **Slack MCP** — post the briefing summary
- **Gmail MCP** — email the PDF
- PDF generation via a simple markdown-to-PDF pipeline (Pandoc or Puppeteer)

### Prompt arch
- Role: "Produce an exec briefing a CEO reads in 4 minutes. Lead with deltas, flag anomalies, end with one recommended action."
- Workflow: (1) pull all data, (2) compute deltas, (3) identify top 3 stories (wins, losses, anomalies), (4) write narrative, (5) generate PDF, (6) post.
- Output: PDF + Slack-formatted summary + structured JSON archive in vault.

### Edge cases
- One data source unavailable → report proceeds with that section flagged "data unavailable for this period"
- Anomaly detected (metric >3σ from trend) → surfaced in the "what stands out" section
- Client has <4 weeks of data history → skip deltas, report raw

### Human review gate
None (internal use only).

### Cost: £0.72/mo. Build: 2 weeks (lots of data sources, each with quirks).

---

## 13. SOP Writer

### Purpose
When a team member records a Loom showing how they do something, generate a Notion-formatted SOP from the recording, tagged and linked into the vault.

### Outcome metric
**SOPs published per month + retrieval rate** (how often team members reference them later — tracked via Notion page views where available).

### Trigger
Loom webhook `recording.available` OR cron sweep at 03:00 UK time for new Loom recordings.

### Model
**Opus 4.7.** This is the one place Opus earns its price. Parsing a recording, identifying the procedural flow, distinguishing "background explanation" from "do this next", producing a scannable SOP — that's a real reasoning task.

### Inputs
- Loom transcript (via Loom API)
- Screen recording metadata (click events if available)
- Existing SOP library in vault (for consistency of format + dedupe)

### Integrations
- **Loom API** (no official MCP yet — build a wrapper)
- **Notion MCP** — publish SOP in the client's SOP database

### Prompt arch
- Role: "Turn a loose screen-recording into an SOP a new hire can follow on day one."
- Workflow: (1) parse transcript for procedural structure, (2) extract purpose/when-to-use/prerequisites, (3) write numbered steps with screenshots referenced by timestamp, (4) flag any ambiguities for human to resolve, (5) tag and link to related SOPs.
- Output: markdown with YAML frontmatter (title, category, version, related), published to Notion.

### Edge cases
- Loom is not procedural (it's a meeting recording, not a walkthrough) → skip, don't force-fit
- Steps reference tools the agent doesn't know → surface as "Open question: which tool does step 3 refer to?"
- SOP duplicates existing one → flag for merge, don't auto-create duplicate

### Human review gate
**Soft.** New SOPs are "draft" in Notion until approved once. Afterwards published directly.

### Cost: £3/mo. Build: 1.5 weeks.

---

# PART III — THE ADD-ONS

Each add-on is its own productized mini-product. Same template conventions (frontmatter, validate, test) but standalone. Clients buy add-ons à la carte on top of the core nine.

## 14. Voice Receptionist

### Purpose
Answer inbound calls 24/7, handle FAQs, take appointments, transfer real humans only when needed. Critical for dental, medical, professional services.

### Approach
**Not a Claude Code sub-agent.** Voice-first systems have hard real-time constraints (sub-500ms response) that Claude Code isn't built for. Use a dedicated voice platform:
- **Vapi** (best-in-class developer voice platform, supports Claude via proxy, ~$0.05/min)
- **Retell AI** (similar, slightly cheaper)
- **Bland AI** (cheaper again, slightly less polished)

The Claude Code side handles the **configuration and training**, not the live call. The live call runs on Vapi; when the call ends, Vapi webhooks the transcript and actions to your Claude Code webhook receiver, which triggers a post-call agent that:
1. Parses the call
2. Updates the CRM
3. Creates any booked appointments (Calendly/Cal.com)
4. Flags escalations to the team
5. Saves the transcript to the vault (for training the next iteration)

### Configuration
Per client, from the wizard:
- Greeting script
- FAQ database (pulled from vault)
- Escalation triggers (when does it transfer to a human?)
- Appointment system integration
- Business hours
- Out-of-hours behaviour (voicemail? emergency line?)

### Edge cases (many)
- Caller accent / dialect handling (Vapi handles this, but tune)
- Caller refuses to give name → proceed, tag "anonymous"
- Pricing questions → give ranges, never quotes (always human-approved)
- Medical emergencies → immediate transfer + 999 protocol
- Complaints → escalate to named human
- Background noise / poor line → re-prompt, escalate on 3 failures

### Cost
Vapi: ~$0.05/min × avg call length 2 min × 200 calls/mo = £20–30/client/mo raw cost. Charge £400–800/mo. Margin is huge because reception cost savings for dentist ≈ £2k/mo.

### Build complexity
**High.** Voice is its own skill. 3 weeks to do a production-ready Vapi setup with tight escalation logic. Hire or contract specifically for this. Do NOT ship until it's been through 100+ test calls across edge cases.

---

## 15. HR Agent (Teams/Slack)

### Purpose
Sits in a dedicated Slack/Teams channel. Answers policy questions, handles leave requests, onboards new hires with paperwork. For SMEs that don't have HR software.

### Approach
Claude Code sub-agent exposed as a Slack/Teams bot. Triggered by @mentions and DMs.

### Inputs
- HR policy docs in vault (ingested at onboarding)
- Leave tracker (Google Sheet or Bamboo/Breathe if client has one)
- Onboarding checklist template

### Integrations
- **Slack MCP** / **Teams MCP**
- **Google Sheets MCP** — leave tracker
- **Breathe/BambooHR MCP** — if client has HR software

### Prompt arch
- Role: "Professional, empathetic HR support. Never make policy — only report it."
- Workflow for query: (1) identify query type, (2) retrieve relevant policy, (3) answer with citations, (4) log the interaction
- Workflow for leave request: validate dates, check policy, approve or escalate to manager
- Workflow for onboarding: fire full Client Onboarder flow variant

### Edge cases
- Policy question not covered in docs → "I don't have policy on this, I've flagged @manager"
- Sensitive query (grievance, complaint) → do NOT respond substantively; route to named HR contact immediately
- Leave request in conflict with team coverage → flag manager

### Human gate
**Hard for anything policy-adjacent.** Bot can report policy, never interpret.

### Cost: £5/mo. Build: 1.5 weeks.

---

## 16. SEO Brief Generator

### Purpose
Keyword research → content briefs for the Content Creator. Closes the loop from "what should we write about?" to "here's a brief ready to generate."

### Approach
Standalone Claude Code sub-agent + SEO API integration.

### Integrations
- **Ahrefs / SEMrush API** (paid, passed through to client — OR build against free DataForSEO tier for Tier 1)
- **Google Search Console MCP** — client's own performance
- **Notion MCP** — write briefs

### Workflow
1. Pull client's GSC data — what are they ranking 4–20 for (low-hanging fruit)?
2. Pull competitor top content (Ahrefs)
3. Identify 5 brief opportunities per week
4. For each: target keyword, intent, competitors, suggested angle, target length, internal links
5. Write to Notion brief database, ready for Content Creator

### Cost: £3/mo + SEO API cost passthrough. Build: 4 days.

---

## 17. Paid Ads Copywriter

### Purpose
Generate ad copy variants (Meta, Google) with A/B tracking.

### Approach
Claude Code sub-agent. Produces variants; human still manages campaigns. Does NOT auto-publish (ad spend is too sensitive).

### Workflow
1. Brief: target audience, offer, platform
2. Generate 10 variants (5 headlines, 5 descriptions)
3. Per platform constraints (char limits)
4. Optional: analyze past ad performance for voice/structure that worked
5. Write to Notion or spreadsheet for ad manager to pick

### Human gate
**Hard.** No auto-publish to ad platforms. Ever.

### Cost: £3/mo. Build: 4 days.

---

# PART IV — THE HIDDEN TENTH

## 18. The Librarian

### Purpose
Keep the vault useful as it grows. Prevent memory decay. Every IntelForce tenant has a Librarian running; clients don't know about it (or you mention it as a "self-healing memory system").

### Trigger
Cron — 03:00 UK time daily, plus ad-hoc on-demand (e.g., after a bulk import).

### Model
**Haiku 4.5** for the housekeeping; **Sonnet 4.6** for the weekly rollup.

### Responsibilities
1. **Daily rollup** — take yesterday's activity, create `/vault/daily/{YYYY-MM-DD}.md` summarising what happened.
2. **Tag hygiene** — find notes missing required frontmatter (client, agent, date, status), add them, notify on what was inferred.
3. **Dedupe** — detect near-duplicate notes (embedding similarity >0.95), merge or flag.
4. **Archive** — move raw logs, transcripts older than 30 days, and superseded versions into `/vault/archive/` (still searchable, just out of retrieval).
5. **Broken-link repair** — scan for `[[wikilinks]]` pointing to deleted/renamed notes, fix or flag.
6. **Vault health report** (weekly) — total notes, retrieval query stats, context-per-invocation trend, noise ratio.
7. **Stale content check** — notes tagged as "evergreen" that haven't been edited/viewed in 6+ months → flag for refresh.

### Why it matters
A vault that grows unchecked becomes the limiting factor on agent quality. Every agent that pulls "3 most similar past proposals" gets worse outputs from a noisy vault. The Librarian is what makes the memory story *actually work* at 12+ months of operation, not just at launch.

### Quality metric
**Retrieval precision trend.** Track the LLM-as-judge grades over time. If they dip, the Librarian needs more aggressive pruning.

### Cost: £1.50/mo. Build: 1 week. Easy to defer to week 10 — the vault is small at launch.

---

# PART V — PLATFORM COMPONENTS

## 19. The Provisioning System

### Purpose
The system that turns "wizard completed" into "9 agents running in a fresh tenant container" in under 15 minutes of compute time.

### Architecture

```
Wizard-completed event
         ↓
[Config Validator] — validates every field, fails fast if incomplete
         ↓
[Template Renderer] — for each enabled agent, templates the agent.md with
                      tenant-specific values (names, tools, filters)
         ↓
[Secret Manager] — encrypts client API keys, writes to tenant vault
                   (HashiCorp Vault or Infisical — KMS-backed regardless)
         ↓
[Vault Initialiser] — creates the Obsidian vault structure, seeds with
                      client-specific files from the wizard uploads
         ↓
[Voice Profile Ingester] — processes uploaded brand docs → voice-profile.md
         ↓
[Embedding Indexer] — chunks and embeds all vault files → pgvector
         ↓
[Container Builder] — either (a) builds a tenant Docker image, or 
                      (b) starts a shared image with tenant config mounted
                      Recommendation: (b) until 50+ tenants, then (a) for isolation
         ↓
[Cron Installer] — writes tenant-specific crontab entries
         ↓
[Webhook Registrar] — registers webhook endpoints with each integration
                       (Fathom, Stripe, DocuSign, HubSpot) via their APIs
         ↓
[Smoke Test Runner] — fires a dummy trigger for each agent, verifies output
         ↓
[Dashboard Go-Live] — flips tenant status to "Live", notifies Maddox
```

### Key design decisions

- **Config is declarative, always.** Every piece of tenant state is in the tenant's config.json, vault files, or secrets store. No out-of-band "setup steps" in someone's head.
- **Idempotent provisioning.** Running provision twice on the same tenant must be safe — no duplicate resources, no clobbered secrets.
- **Atomic rollback.** If any step fails, the tenant is left in a clearly-broken state (not half-deployed) with a `provisioning.failed` flag. Manual resume or full rebuild.
- **Versioned.** Every provisioning run logs agent versions, template versions, and toolchain versions. Reproducibility is an audit requirement.

### Build complexity
**High.** This is your IP. Budget 3 weeks of focused engineering. The payoff is immense: every future client is 15-minute provisioning + 4-hour kickoff instead of 2-week custom build.

### Testing
- **Unit tests** per renderer component
- **Integration test** against a "pristine tenant" that gets provisioned, smoke-tested, torn down. Run nightly in CI.
- **Chaos test** — deliberately fail each step, verify rollback is clean.

---

## 20. The Configuration Centre Wizard

### Purpose
Capture every piece of client config the provisioning system needs, in a flow a non-technical founder can complete in 90 minutes.

### The five steps (detailed)

**Step 1 — Company profile (10 min)**
- Business name, legal name, trading name, domain, industry (SIC code picker, not free text)
- Team members with roles + email + whether they're agent @-mention targets
- Office hours, timezone, public holidays (pre-filled by country)
- Brand voice quick-capture: 3 adjectives + 3 banned adjectives + one-sentence "we would never say..."

**Step 2 — Integrations (20 min)**
- Cards for each integration with "Connect" (OAuth flow)
- Client can skip any; skipped integrations disable any agent that depends on them
- Post-connect, test button: "Confirm connection" fires a read operation, shows sample data
- Granular permissions shown honestly ("We will: read your CRM contacts, write new leads. We will not: delete or modify existing records.")

**Step 3 — Agent selection + configuration (25 min)**
- All 9 core agents toggled on by default
- Per-agent: show what it does, key config (cadence, scope)
- Add-ons (see §14–17)
- Pricing summary updates live

**Step 4 — Voice & context training (30 min)** *The magic step*
- Upload: past winning proposals (min 3), brand guidelines, SOPs, sample emails, website content
- System processes (shows progress bar, ~5 min):
  - Chunks + embeds for retrieval
  - Generates draft voice profile
  - Generates draft pricing framework
  - Generates a "summary of what we learned about your business"
- Client reviews the auto-generated summary. Edits inline. Approves.
- This is where the client goes "oh, it actually gets us." Sales gold.

**Step 5 — Go-live checklist (5 min)**
- Per-agent smoke test: "Click to run Proposal Builder on a sample transcript"
- Approve each output
- Final switch: "Go live". Dashboard flips to Live, first real triggers start firing.

### Technical build
- **Frontend** — same Next.js app as the dashboard, a separate route namespace
- **Wizard state** — Zustand store, autosave on every field change to Postgres (so clients can resume)
- **Voice ingestion** — background job, triggered on Step 4 upload, runs for 3–7 minutes
- **Integration OAuth** — a config-driven OAuth flow dispatcher (standard pattern: Clerk-like abstraction)

### Build complexity
**High.** 2.5 weeks. UX is critical — it's the sales pitch in form-factor.

---

## 21. The Dashboard

Covered in detail in the earlier prototype. Key production-grade requirements beyond the prototype:

### Beyond prototype
- **Auth + RBAC** — owner, admin, viewer, integration-manager roles
- **Tenant switcher** — important for agency partners managing sub-tenants
- **Real-time updates** — Supabase Realtime or Pusher Channels for activity log streaming
- **Mobile-responsive** — agency owners check on their phones
- **Export everything** — CSV, JSON, PDF for audit / GDPR / own-records
- **Accessibility (WCAG AA)** — legal minimum plus enterprise-sale requirement

### Views (production)
1. Home — metrics + hierarchy (the prototype)
2. Activity Log — with filters, search, export
3. Agents — configuration per-agent, run history, cost profile
4. Brain — Obsidian vault graph view, search, direct edits
5. Approvals — the human-review queue (§29)
6. Integrations — connected tools, health, re-auth
7. Billing — current month, forecast, invoice history
8. Team — user management
9. Audit log — immutable, exportable
10. Settings — tenant-wide config, notification prefs

### Build complexity
6 weeks end-to-end for all views at production quality. Can MVP in 2 weeks with just views 1–5.

---

## 22. The Webhook Receiver

### Purpose
Per-tenant HTTP endpoints that receive webhooks from every integration and trigger the right Claude Code invocation.

### Architecture
Single Node/Fastify service, multi-tenant, routing by subdomain path:
- `hooks.intelforce.ai/{tenant-id}/{integration}`
- e.g. `hooks.intelforce.ai/elm-row-dental/fathom`

Each tenant's routes are dynamically registered from their config on startup. Service reloads on tenant provisioning.

### Responsibilities
1. Verify signature (every integration has its own: Fathom uses HMAC, Stripe uses stripe-signature, HubSpot has timestamp+signature)
2. Rate-limit per tenant (prevent a misconfigured webhook from DDoSing)
3. Persist the payload to `/intake/{integration}/{id}.json` in the tenant's vault
4. Enqueue a trigger via a job queue (BullMQ on Redis — already running for cron anyway)
5. Respond 200 within 2 seconds (otherwise the sender retries)

### Reliability
- **At-least-once** processing — fine because agent outputs are idempotent by design (same Fathom call ID → same proposal location, overwritten)
- **Dead-letter queue** — payloads that fail 3 retries go to DLQ, flagged to dashboard
- **Replay** — DLQ items can be manually replayed from dashboard

### Build complexity
1 week. The sig-verification code per integration is the bulk of it.

---

## 23. The Scheduler

### Purpose
Fire every cron-triggered agent at the right time, per tenant, reliably.

### Approach
Not system cron (doesn't scale multi-tenant). Use **BullMQ** (Redis-backed) with a single scheduler process that:
1. Reads every tenant's agent schedules from Postgres at startup + on config change
2. Registers repeatable jobs
3. Executes: SSH into tenant container → `claude -p "..."` → capture output → log

Advantages over system cron:
- Centralised visibility
- Per-tenant pausing without touching OS
- Retry policies per job
- Priority queues (Reporting Engine doesn't block Lead Hunter)

### Scale
One scheduler handles hundreds of tenants easily. Redis is the bottleneck, not cron logic. Redis cluster when needed.

### Build complexity
4–5 days.

---

## 24. The MCP Integration Layer

### Purpose
Manage MCP servers per tenant. Handle OAuth refresh. Fallback when servers die.

### Architecture
Each tenant container has its own `.claude/mcp.json`. Management service runs on the control plane:
- Monitors MCP server health per tenant (lightweight ping)
- Refreshes OAuth tokens before expiry
- On failure, marks integration "degraded" on dashboard, starts fallback (queue for retry OR use non-MCP API wrapper)
- Auto-updates MCP server versions (opt-in per tenant)

### The MCP server inventory (priority order)

| Integration | MCP status | Plan |
|---|---|---|
| HubSpot | Official | Use directly |
| Fathom | Community MCP (matthewbergvinson, Dot-Fun) | Fork, harden, productize |
| Gmail | Community | Use |
| Slack | Official | Use |
| Notion | Official | Use |
| DocuSign | No official | Build your own wrapper |
| Stripe | Community | Use |
| GA4 | No official | Build your own wrapper |
| Meta Ads | No official | Build your own wrapper |
| Cal.com / Calendly | Community | Use |
| Companies House | No | Build your own (easy — free API) |
| Prospeo | No | Build your own wrapper |
| Kaspr | No | Build your own wrapper |
| Dentally (UK dental) | No | Build your own — this is part of the dental vertical pack |
| Loom | No | Build your own |

### Your own MCP servers
Anywhere there's no viable community MCP, build a minimal one. Template: 50–100 lines of Python or TypeScript using the MCP SDK. Fork an existing one as a starting skeleton.

This investment pays off forever. Don't skip it by going n8n-as-bridge for everything; your agents get slower and less capable every time you bounce through n8n.

### Build complexity
Ongoing. Week 1–2 get the core 6 working. Every additional integration is 2–5 days of focused work. Budget an integration sprint every quarter.

---

## 25. The Vault Service

### Purpose
Make the Obsidian vault accessible to (a) the Claude Code tenant container, (b) the dashboard Brain view, (c) the client's Obsidian app on their machine.

### Architecture (three surfaces, one source of truth)

**Source of truth:** files in `/tenant/vault/` inside the tenant container (or on shared storage visible to the container).

**Surface 1 — Claude Code access:** direct filesystem, zero middleman. Claude reads/writes markdown files.

**Surface 2 — Dashboard Brain view:** server-side renderer reads the vault, parses `[[wikilinks]]`, renders the graph using D3 force simulation. Updates live via the file-watcher → WebSocket → dashboard.

**Surface 3 — Client Obsidian app:** the vault is synced to the client's devices via one of:
- **Obsidian Sync** ($10/mo paid by client; most polished)
- **Git-backed** (Obsidian Git plugin; free; bit techy)
- **iCloud / Dropbox** (cheap but syncing is lossy sometimes)

Recommended default: **Git-backed** on a private GitHub repo in the client's GitHub org (or yours for clients without one). Every vault write creates a commit. Audit trail built in. Branch per environment. Merge conflicts rare but handled (the vault is append-heavy, not edit-heavy).

### Security
Vault contents are the client's data. Handle accordingly:
- Encryption at rest (filesystem-level; LUKS on the VPS)
- Encryption in transit (TLS for git sync, obviously)
- Access control: only that tenant's container + dashboard service can read
- Never in backups that leave UK jurisdiction (aligns with sovereignty story)

### Build complexity
1.5 weeks for base. Another week for the Brain view.

---

## 26. Observability Stack

### Purpose
Know what every agent is doing, for every tenant, right now. Detect problems before clients do.

### Components

**Logging.** Every `claude -p` invocation writes structured JSON to the tenant's `/logs/`. A log shipper (Vector.dev is the right choice — lightweight, fast, open-source) forwards to a central store.

**Store.** Postgres for structured data (agent invocations, cost per run, errors). ClickHouse if you scale past 100 tenants (Postgres starts hurting on log volume). For now: Postgres with partitioned tables.

**Dashboards.** Two levels:
1. **Per-tenant (visible to client):** activity log, cost, agent health
2. **Cross-tenant (you only):** every tenant's status on one screen, outlier detection, cost anomalies

Grafana for the operator dashboard. Tempo/Loki if you want full observability, but probably overkill v1.

**Alerts.** Rules engine driven by events:
- Agent invocation errors >3 in 10 min for one tenant → Slack
- Tenant monthly cost >80% of budget → Slack + email to client
- Integration down for any tenant >15 min → PagerDuty
- Vault write failures >5 in 1h → Slack
- LLM-as-judge score for an agent drifting downward trend over 30 days → Slack (quality regression)

**Tracing.** Every agent invocation gets a trace ID that follows it through webhook → queue → Claude → MCP calls → output. Essential for debugging "why did this proposal come out weird".

### Build complexity
2 weeks for solid v1. Can ship MVP with just logs+Postgres+a basic metrics view in 4 days.

---

## 27. Cost & Billing System

### Purpose
Know exactly how much each tenant costs you (API + infra + third-party), charge retainer monthly, handle overages gracefully.

### Architecture
- Anthropic API: tag every request with `metadata: {tenant_id, agent_name, invocation_id}` (Anthropic API supports this). Aggregate usage per tenant via Anthropic's usage API.
- Third-party APIs (Prospeo, Cognism, etc.): track per-tenant calls in your own DB, reconcile monthly with provider invoices.
- Infra: allocate based on tenant resource shape (memory/CPU slice → £/day).

### Dashboard visibility
Client sees:
- Current month's retainer
- API usage vs. included allowance (e.g. "Growth plan includes £150/mo API usage; you're at £89")
- Add-ons active
- Next invoice date

You see (cross-tenant):
- Gross margin per tenant
- Cost anomalies (tenant suddenly at 2x typical)
- Churn-risk signal (usage dropping week over week)

### Billing
Stripe Subscriptions. Standard SaaS setup. Pricing model:
- Base retainer (monthly, auto-renew)
- Metered overages (API usage over included → metered billing)
- Setup fees (one-off invoice)

### Build complexity
1.5 weeks. Mostly standard Stripe work + the per-tenant tagging pipeline.

---

## 28. Audit & Compliance

### Purpose
GDPR. SOC 2 readiness (for Agency Partner and Enterprise). A real UK sovereignty story.

### Requirements

**GDPR**
- Data subject access requests (DSAR): one-click export of all data tied to a named person, across vault + logs + CRM-touched records
- Right to erasure: mark-and-purge flow (hard — some data is in integrations you don't own; document what you can and can't delete)
- Processing record: which data, which purpose, which legal basis, documented per agent
- DPA with every client (pre-drafted template, signed at onboarding)
- Sub-processor list (Anthropic, AWS/wherever, every MCP provider) — published

**UK sovereignty**
- All infrastructure in UK regions (Hetzner UK, UpCloud LON, AWS London, Azure UK South)
- Client data never touches US-hosted services for storage (embeddings API the exception — disclose this in the DPA)
- No US data residency (vault content, logs, backups all UK)
- Encryption at rest everywhere

**Audit log**
- Every agent action, every human approval, every config change
- Immutable (append-only ledger — can use Postgres with strict INSERT-only triggers, or purpose-built like Materialize)
- Exportable in signed JSON
- 7-year retention

### Build complexity
2 weeks for v1 (GDPR + audit log). SOC 2 is a 6-month process you start in year 2.

---

## 29. Human-in-the-Loop Approval System

### Purpose
Queue every human-gated output, let the reviewer approve/reject/edit in one place, audit the decision.

### The approval queue

**Sources of items:**
- Proposal Builder drafts
- Content Creator drafts
- First-of-template Follow-Up Pilot emails
- First-of-template welcome emails (Client Onboarder)
- SOPs awaiting canonical approval
- Flagged escalations from any agent

**Queue item structure:**
```
{
  id, agent, tenant, created_at,
  summary,                  // one-liner for the queue list view
  preview,                  // rendered preview for the detail view
  full_output,              // raw output for edit mode
  context_bundle,           // input that produced the output (transcript, brief, etc.)
  suggested_action,         // the agent's proposed action if approved
  risk_flags,               // any auto-detected concerns
  quality_score,            // LLM-as-judge score
  sla_deadline              // when this item becomes urgent
}
```

**Review actions:**
- **Approve** — fire the suggested action (send email, publish content, etc.). Log approval.
- **Approve with edits** — inline edit, then fire. Edits feed back into the voice profile.
- **Reject** — with reason code. Agent retries once with feedback, or flags as unsolvable.
- **Escalate** — route to a more senior reviewer.
- **Batch approve** — select multiple similar items and approve at once (e.g., all today's captions).

### SLA policy
Default: items age into urgency over time. Proposal drafts: SLA 4 hours (sales calls go cold fast). Content drafts: SLA 48 hours. Follow-up drafts: SLA 24 hours.

Breached SLA → dashboard badge + Slack nag.

### Client configurability
Clients set approval policies in settings:
- Who can approve (role-based)
- Auto-approve rules ("approve content drafts under 500 words without review")
- Escalation paths
- Signing authority thresholds (no one but Maddox approves >£25k proposals)

### Build complexity
1.5 weeks.

---

# PART VI — THE AGENCY PARTNER WHITE-LABEL LAYER

## 30. Multi-tenant-within-tenant architecture

### Purpose
Let an agency buy IntelForce, then resell to THEIR clients as sub-tenants, with their branding, their margin, their support — while you do no per-sub-tenant work.

### The data model

Existing: `Tenant` (a single client)

New: `ParentTenant` (an agency) + `SubTenant` (one of the agency's clients, belongs-to a `ParentTenant`).

Behaviours:
- Agency logs into `agency.intelforce.ai` (or their white-label domain)
- Sees all their sub-tenants in a tenant switcher
- Can provision a new sub-tenant themselves via the wizard (reduced version — pre-configured with the agency's defaults)
- Gets wholesale pricing; charges their retail pricing to sub-tenants independently (not your problem)
- Support flows go to the agency first, escalate to you for L2/L3

### White-labelling (surface level)

**Domain.** Agency provides their own CNAME. Dashboard serves on `ai.agency-name.com`. SSL via Let's Encrypt auto.

**Branding.** Logo, colours, fonts, copy in the dashboard UI (CSS variables pattern makes this easy — Tailwind theme per tenant).

**Email.** Transactional emails (welcome, alerts) use their SMTP / SendGrid sending domain.

**Name in UI.** "IntelForce AI OS" references are replaced with the agency's product name where configured.

### White-labelling (deep)

Not doing these at launch:
- Custom agents unique to that agency (this is the Agency+Enterprise boundary)
- Source code access
- Private repositories of their agent tweaks (they can fork-and-maintain at Enterprise)

### Pricing discipline
The Agency Partner tier is structured so you earn per sub-tenant:
- Agency pays £15k setup + £5k/mo base (up to 10 sub-tenants)
- +£300/mo per sub-tenant beyond 10
- Overages on API / third-party costs billed to agency (transparent — they can markup to their client)

### Build complexity
3 weeks **after** core product is live (Don't try to build this simultaneously; it becomes simpler once core architecture is stable.)

---

# PART VII — BUILD SEQUENCING

## 31. Fourteen-week build plan

Every item here has a single owner and a definition-of-done. If an item slips a week, drop scope from a later item before pushing the timeline.

### Weeks 1–2: Foundations
- Week 1: Runtime proof-of-concept — **Proposal Builder end-to-end** in one container, one real Fathom call → proposal in inbox. This is the week-1 experiment from v2. Nothing else.
- Week 2: Agent template library structure (§1.1–1.4), context injection (§3), validation hooks (§2.1)

### Weeks 3–4: Core runtime hardened
- Proposal Builder at production quality (hardened, tested, cost-budgeted)
- Standard sub-agent template finalised
- First 3 agents fully complete: **Proposal Builder, Lead Hunter, Follow-Up Pilot** (the sales trio — the easiest demo)
- Webhook receiver (§22)
- Scheduler (§23)
- Minimal observability (logs + Postgres)

### Weeks 5–6: Full agent suite
- Remaining 6 core agents: Content Creator, Repurposer, Caption Writer, Client Onboarder, Reporting Engine, SOP Writer
- Integration layer (§24) — core 6 MCP servers working
- Vault Service (§25) with git-backed sync
- The Librarian (§18) for memory hygiene

### Weeks 7–8: Configuration Centre
- Wizard (§20) end-to-end
- Voice profile ingestion pipeline
- Provisioning System (§19) — automated 15-min tenant deployment
- Smoke test suite

### Weeks 9–10: Dashboard at production quality
- All 10 dashboard views
- Real-time activity log
- Brain view (Obsidian vault graph)
- Approval queue (§29)
- Billing (§27) with Stripe

### Weeks 11–12: First paying clients
- Onboard 3 founding customers (founding pricing, case studies)
- Every friction point documented → v1.1 backlog
- SOPs for client onboarding + support
- Hire ops person or designated virtual assistant for L1 support

### Weeks 13–14: Stabilise + Agency Partner
- All v1.1 fixes from the first 3 tenants
- Observability v2 (proper alerting, tracing)
- Audit/compliance layer (§28) to GDPR-complete standard
- Agency Partner white-label layer (§30) — ready to close your first agency partner

### Post-v1 (months 4–6)
- Voice Receptionist add-on (Vapi integration)
- HR Agent add-on
- Vertical packs: Dental first (Dentally integration, dental-specific agents), then Agency, then Hospitality
- OpenClaw migration path for Enterprise tier
- SOC 2 Type 1 prep

---

## A note on not doing the whole plan

This document is a map. It is not a command. At every stage, the right question is: **"What's the smallest thing I can ship that proves the next assumption?"** Not: "Let me build section 19 exactly as spec'd."

Three prompts to ask yourself weekly:

1. *Which of these components does a paying client not notice?* (Do those last.)
2. *Which of these components, if they break, does the client notice immediately?* (Those need the most test coverage.)
3. *Which agent produces the single most impressive demo moment?* (That's Proposal Builder. Make it your day-1 experiment. Everything else is leverage around that.)

The goal isn't to build IntelForce AI OS as spec'd. The goal is to get to a business with 15 happy paying clients, one signed agency partner, and a platform that scales without breaking. The spec is a tool, not a deliverable.

---

*End of build plan. Commit to the week-1 experiment. Then the week-2 hardening. Then the rest. The plan exists so you don't waste time arguing about architecture — not so you follow it blindly.*
