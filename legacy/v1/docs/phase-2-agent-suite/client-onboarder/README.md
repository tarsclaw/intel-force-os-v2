# Client Onboarder

**Purpose:** Generate the Week 1–2 kickoff collateral for newly-signed clients.

**Trigger:** HubSpot deal stage change to "Won" + manual "Run Now" from dashboard.

**Output:** Full onboarding packet in vault + Gmail drafts queued for review.

**Tier availability:** All tiers.

---

## What it does

When a prospect signs, the next 14 days decide whether the relationship starts well or starts with friction. Client Onboarder produces everything that normally gets done by a stressed account manager at 11pm:

- Welcome email draft (in client's voice, referencing the specific commitments made in the proposal)
- Kickoff call agenda (60 minutes, specific to the deliverables signed for)
- Loom video script (5–7 minutes, "here's what happens next")
- Access checklist (what logins and accounts we need from them)
- First content brief (so by Week 2 there's a real deliverable in flight)
- Internal kickoff note for the delivery team (scope summary, red flags from the original discovery call, contact preferences)

Everything lands as drafts in the sales lead's inbox. Nothing sends automatically — human sign-off is the point.

## What it needs

- The signed proposal file (retrieved from `/vault/clients/{slug}/proposals/` — the file with `status: signed`)
- The original discovery call transcript (for tone reference)
- `/vault/brand/voice-profile.md`
- `/vault/brand/onboarding-templates.md` (optional — if client has specific templates)
- `/vault/brand/service-catalogue.md` (for deliverable definitions)
- HubSpot MCP (deal metadata, stage update)
- Gmail MCP (draft delivery)
- Loom MCP or script output (optional)

## What it doesn't do

- Send anything — every output is a draft
- Schedule the kickoff call (Calendly link is included; prospect books)
- Complete access setup — produces the checklist, doesn't execute it
- Contract work — assumes MSA is already signed via a separate process

## Cost per run

~£0.50 per run (one-shot, runs ~10–30 times/month per agency-tier tenant)

## Related

- **Proposal Builder** (the input — its signed output becomes this agent's context)
- **Content Creator** (receives the first content brief this agent produces)
- **Reporting Engine** (builds off the kickoff baseline this agent establishes)
