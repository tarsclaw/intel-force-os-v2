# Follow-Up Pilot

**Purpose:** Draft 21-day nurture email sequences for unconverted enquiries, in the client's voice, referencing the specific prior conversation.

**Trigger:** Weekly cron (default Mondays 09:00 local) + HubSpot stage change to `Unconverted`.

**Output:** 3–5 email drafts per prospect, saved to `/vault/clients/{slug}/follow-up/` and queued as Gmail drafts. Nothing sends automatically.

**Tier availability:** Growth+.

---

## What it does

Every agency has a list of enquiries who didn't convert on the first call and then drift into silence. Follow-Up Pilot systematically picks these up, reads the prior conversation, and drafts a short sequence of emails spread over 21 days — each referencing something specific from the prior exchange, not a generic "just checking in."

The goal is to make the follow-up sound like the sales lead still cares, because they do — they just don't have time to write it. A well-crafted 3-email nurture sequence over 21 days recovers roughly 15–25% of unconverted enquiries. This agent makes that workflow exist.

Every email drafts to the sales lead's Gmail. Sales lead reviews, edits, sends — or kills. Nothing sends automatically, ever.

## What it needs

- HubSpot deal with stage = `Unconverted` and a prior conversation thread
- Gmail thread history (for the prior conversation)
- `/vault/brand/voice-profile.md`
- `/vault/brand/pricing.md` (for scope reference)
- Suppression list — the prospect must not be on it
- Fathom transcript of the original discovery call if available

## What it doesn't do

- Send emails automatically — every email is a Gmail draft
- Reach out to prospects who've opted out, or are on the suppression list
- Nurture prospects with no prior substantive exchange (no "cold follow-up")
- Run more than one active sequence per prospect (agent checks for existing sequences)

## Cost per run

~£0.60 per prospect (a 21-day sequence = 3 emails + sequence plan). Batches of 5–15 prospects per weekly run → ~£5–£10/week.

## Related

- **Proposal Builder** (drafts the proposals; unconverted-at-proposal-stage deals can enter this sequence)
- **Lead Hunter** (the top of the funnel — Lead Hunter creates, Proposal Builder converts some, Follow-Up Pilot recovers some of the rest)
- **Reporting Engine** (monthly reports on follow-up recovery rate)
