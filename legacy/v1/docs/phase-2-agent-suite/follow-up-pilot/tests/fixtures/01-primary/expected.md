# Golden output — Follow-Up Pilot fixture 01

*Four files produced. Email 1 shown in full; others summarised.*

---

## Email 1 — Day 0 (full)

**File:** `/vault/clients/loopcatch/follow-up/2026-05-09-email-01.md`

```markdown
---
type: follow-up-email
prospect: Loopcatch
prospect_email: marcus@loopcatch.io
sequence_position: 1
suggested_send_date: 2026-05-09
subject: "Re: Loopcatch proposal — one thing worth revisiting"
stall_reason: budget-comparison
references_from_prior:
  - "I lost a lot paying less for less"
  - "last agency we used, six months in, we'd spent £40k"
word_count: 94
drafted_at: 2026-05-09T09:12:00Z
drafted_by: follow-up-pilot@1.0.0
status: draft-in-gmail
---

Marcus,

You said on the call that what killed the last agency was paying less for less. The proposal I sent you had that in mind — the Growth tier's at the top of your range because the cheaper shape wouldn't have solved the voice-match problem, which is what actually went wrong before.

If comparing to others made that trade-off clearer, I'd rather know where we stand than chase. Reply with a time if worth a 15-minute call. "Not right now" is a fine answer too.

Jordan
```

---

## Email 2 — Day 12 (shape)

**File:** `/vault/clients/loopcatch/follow-up/2026-05-09-email-02.md`

*No ask. Value only.* Short (90 words). References a specific pattern — how B2B SaaS founders under £1M ARR tend to undersolve for content voice specifically, linking to one credible external source on content-founder-fit challenges. Doesn't mention the proposal. Doesn't mention price. Just useful.

Subject: "Something worth your inbox — the founder-voice trap"

## Email 3 — Day 21 (shape)

**File:** `/vault/clients/loopcatch/follow-up/2026-05-09-email-03.md`

Closing email, 78 words. Structure:

> Marcus — last nudge on our conversation. You're busy, I respect the inbox.
>
> If you want to pick this up, reply with a time. If it's "not right now," I'll park it and check in around Q3. If it's "not at all," no is a good answer — I'd rather know.
>
> Either way, thanks for the original call. It was a good conversation.
>
> Jordan

## Sequence plan

**File:** `/vault/clients/loopcatch/follow-up/2026-05-09-sequence-plan.md`

```yaml
---
type: follow-up-sequence-plan
prospect: Loopcatch
prospect_email: marcus@loopcatch.io
stall_reason: budget-comparison
sequence_start: 2026-05-09
sequence_emails:
  - path: /vault/clients/loopcatch/follow-up/2026-05-09-email-01.md
    scheduled_send: 2026-05-09
    status: draft-in-gmail
  - path: /vault/clients/loopcatch/follow-up/2026-05-09-email-02.md
    scheduled_send: 2026-05-21
    status: draft-in-gmail
  - path: /vault/clients/loopcatch/follow-up/2026-05-09-email-03.md
    scheduled_send: 2026-05-30
    status: draft-in-gmail
drafted_at: 2026-05-09T09:14:00Z
drafted_by: follow-up-pilot@1.0.0
status: draft-awaiting-review
---
```

## HubSpot actions

- Note attached to the Loopcatch deal: "Follow-Up Pilot drafted 3-email sequence (stall reason: budget-comparison). Day 0 / 12 / 21. Gmail drafts ready."
- Deal stage: unchanged (stays `Unconverted` until a human advances it).

## Gmail drafts created

Three drafts in Jordan's drafts folder, subjects prefixed `[FOLLOW-UP DRAFT — 1/3]`, `[2/3]`, `[3/3]`.
