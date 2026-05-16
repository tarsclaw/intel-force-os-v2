# Golden output — Client Onboarder fixture 01

*This fixture's expected output is a set of six files. For brevity, this document shows the primary artefact (the welcome email) in full and summarises the shape of the other five. A real test run produces all six files in the vault.*

---

## Artefact 1 — Welcome email (full)

**File:** `/vault/clients/meadowlane-dental/onboarding/01-welcome-email.md`

```markdown
---
type: welcome-email
prospect: Meadow Lane Dental
drafted_at: 2026-04-25T14:30:00Z
drafted_by: client-onboarder@1.0.0
status: draft
recipient: priya@meadowlane-dental.co.uk
subject: "You're on — welcome to Acme, Priya"
---

Hi Priya,

Welcome on. You said on our first call that what keeps you up at night is watching a third of ad-driven enquiries never become consultations — that 40% drop-off from phone call to chair. That's what everything starting Monday is aimed at.

Here's the short version of week one:

- **Monday** — Laura gets an hour of her life back. Voice Receptionist goes live, taking every inbound call, booking consultations straight into Dentally, escalating anything clinical to the team.
- **Wednesday** — Kickoff call with you, me, and the delivery team. 60 minutes. I've attached the agenda so you can sanity-check it.
- **Friday** — First content brief in your inbox for approval. The long-form engine starts next week.

To hit Monday, we need a short list of things from you — logins, brand assets, a couple of intros. That's in the access checklist, also attached. It looks longer than it is; most of it is "add this email as an admin in that account." Laura can handle 80% of it.

Two things worth knowing up front:
1. Everything we do is drafted first, approved by you before it goes anywhere. Nothing ships without your sign-off in Month 1.
2. The August quiet period is our hard deadline for the funnel. Working back from there, every week counts — we'll flag if anything risks slipping.

Looking forward to Wednesday.

Jordan
```

---

## Artefact 2 — Kickoff agenda (shape)

**File:** `/vault/clients/meadowlane-dental/onboarding/02-kickoff-agenda.md`

60-minute agenda, time-marked in 5-minute blocks. Specific sections: scope confirmation (15 min), team introductions with named owners per deliverable (15 min), first deliverable dry-run — Voice Receptionist setup walkthrough (15 min), communication plan + Q&A (15 min). References the signed proposal by date.

---

## Artefact 3 — Loom script (shape)

**File:** `/vault/clients/meadowlane-dental/onboarding/03-loom-script.md`

~950 words, ~6:30 runtime. Six marked sections: greeting + problem reference (0:00–0:30), scope in plain English (0:30–1:30), week-by-week walkthrough (1:30–3:00), meet-the-team (3:00–4:30), how-we-work (4:30–5:30), what-we-need-this-week (5:30–6:30). Stage directions: `[on screen: the scope slide]`, `[show access checklist]`, etc.

---

## Artefact 4 — Access checklist (shape)

**File:** `/vault/clients/meadowlane-dental/onboarding/04-access-checklist.md`

13 items grouped by priority. Day-1 items (voice system provisioning, Dentally API credentials, domain DNS for call routing). Day-3 items (Google Ads + Meta ads manager access). Day-7 items (brand assets, Instagram admin, five past clinical content pieces for voice profile reference). Each item includes the exact UI path for granting access.

---

## Artefact 5 — First content brief (shape)

**File:** `/vault/clients/meadowlane-dental/content/briefs/01-meadowlane-dental-first-brief.md`

First long-form piece. Topic: "What to look for in a private dentist in 2026 — an honest guide." Target audience: middle-aged Didsbury residents considering going private. Objective: consideration-stage content that filters for their ideal patient (values quality + relationship, not cheapest option). Must-include points sourced from Priya's own practice differentiators as discussed on the discovery call. Tone references: two existing blog posts from Priya's old site she said she wanted to recapture. Deadline: Friday of Week 2.

---

## Artefact 6 — Internal kickoff note (shape)

**File:** `/vault/clients/meadowlane-dental/00-context.md`

Delivery team brief. Key flags: Priya is warm but specific and hates fluff — match that in every client-facing touch. She pushed back hard on price initially but signed Growth when the numbers were framed against her annual marketing spend — don't re-open pricing conversations. August is a hard deadline. Laura is the execution lead for access, Priya is the decision. Voice profile extraction top priority Week 1. 30/60/90 view: Week 4 missed-call recovery baseline, Week 8 follow-up engine live and content cadence steady, Week 12 pre-August full funnel review.

---

## HubSpot actions performed

- Deal `hs_deal_74821` stage changed: `Won` → `Onboarding`
- Note attached: "Onboarding packet drafted by Client Onboarder. 4 Gmail drafts ready for Jordan's review. Kickoff target: 2026-05-02."
- Deal property `onboarding_packet_url`: `/vault/clients/meadowlane-dental/onboarding/`

## Gmail drafts created

1. To priya@meadowlane-dental.co.uk — Welcome email (subject, body as above)
2. To delivery-team@acme-agency.co.uk — Internal handoff with links to all 6 artefacts
3. To priya@meadowlane-dental.co.uk cc laura@meadowlane-dental.co.uk — Access checklist cover email
4. To content-team@acme-agency.co.uk — First content brief assignment
