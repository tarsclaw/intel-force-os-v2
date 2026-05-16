# Golden output — Repurposer fixture 01

*Four files produced. LinkedIn post shown in full as the primary; other three summarised.*

---

## LinkedIn post (full)

**File:** `/vault/content/social/2026-05-05-what-to-look-for-private-dentist-2026-linkedin.md`

```markdown
---
type: social-post-linkedin
source_piece: /vault/content/long-form/2026-05-05-what-to-look-for-private-dentist-2026.md
platform: linkedin
word_count: 218
character_count: 1402
drafted_at: 2026-05-05T08:48:15Z
drafted_by: repurposer@1.0.0
status: draft-awaiting-review
tags: [social, short-form, draft, linkedin]
---

Most advice about choosing a private dentist is written by someone trying to sell you dentistry.

I own a private practice. So am I.

But here's what I tell friends when they ask — the stuff that doesn't make it into marketing:

Red flags to avoid:
— "Perfect smile in one visit." No. Good dentistry takes planning and healing time.
— Price as the headline. If the first thing a practice mentions is cost, you're being sold, not consulted.
— Pressure to decide today. Emergencies aside, dental work rarely needs a same-day decision.
— Before-and-after marketing dominating their feed. That practice has chosen its priority. Make sure it matches yours.

The harder question most people don't ask: is NHS actually worse?

Not necessarily. A good NHS dentist in a well-run practice often beats a rushed "budget private" one. The question isn't NHS-vs-private — it's whether you can get continuity of care from a dentist who knows your history.

That's the thing that matters more than anything else, and it matters more as you age.

If you want the longer version — 1,500 words, specific questions to ask on a first consultation, what good looks like — I wrote it up here: [link]

Not a pitch. Just what I'd want my parents to know.
```

---

## Instagram caption (shape)

**File:** `/vault/content/social/2026-05-05-what-to-look-for-private-dentist-2026-instagram.md`

~120 words, different opening beat than LinkedIn — leads with the "most advice is selling you" frame but in shorter, more personal lines. Whitespace-heavy. 7 hashtags at the end (`#privatedentist #dentalhealth #didsbury #southmanchester #dentist #dentalcare #manchesterbusiness`). Subject-line style opener, not a formal first paragraph.

## Email segment (shape)

**File:** `/vault/content/email/2026-05-05-what-to-look-for-private-dentist-2026-email.md`

Subject: "The thing no one tells you about private dentistry"

~420 words. Opens with a specific hook — "Had three patients this month who told me they'd almost signed with another practice." Body unpacks one red flag in detail (price-as-headline) with a specific anecdote-like framing. Closes with "Reply to this email if you've got questions I should add to the full guide" — invites a conversation rather than just linking to the long-form.

## Atomisation index

**File:** `/vault/content/social/2026-05-05-what-to-look-for-private-dentist-2026-atomisation.md`

```yaml
---
type: atomisation-index
source_piece: /vault/content/long-form/2026-05-05-what-to-look-for-private-dentist-2026.md
derivatives_produced:
  - /vault/content/social/2026-05-05-what-to-look-for-private-dentist-2026-linkedin.md
  - /vault/content/social/2026-05-05-what-to-look-for-private-dentist-2026-instagram.md
  - /vault/content/email/2026-05-05-what-to-look-for-private-dentist-2026-email.md
platforms_attempted: [linkedin, instagram, email]
platforms_produced: [linkedin, instagram, email]
platforms_skipped: []
drafted_at: 2026-05-05T08:48:30Z
drafted_by: repurposer@1.0.0
status: draft-awaiting-review
---

# Atomisation Index

Source long-form was 1,487 words. Extracted 4 stand-alone ideas:
1. "Most dental advice is written by someone selling dentistry" — used as LinkedIn hook, Instagram hook, email subject angle
2. Red flags checklist — primary body of LinkedIn post
3. NHS vs private is the wrong question — secondary body of LinkedIn, expanded in email
4. Continuity of care matters more with age — saved for email elaboration

Not produced: Twitter (platform disabled in tenant config), Thread (include_thread=false).
```

---

## Telemetry emitted

- `repurpose_started`: source_path, source_word_count=1487
- `repurpose_completed`: derivatives_produced=3, platforms=["linkedin","instagram","email"], duration_ms=~4200
