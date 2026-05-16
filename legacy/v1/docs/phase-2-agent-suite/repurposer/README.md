# Repurposer

**Purpose:** Atomise a long-form piece into platform-native short-form derivatives — social posts, email, optional thread.

**Trigger:** Chained from Content Creator (fires on every new long-form save) + manual.

**Output:** 3–5 social posts + 1 email + optional Twitter/LinkedIn thread, all in `/vault/content/social/` and `/vault/content/email/`.

**Tier availability:** Growth+.

---

## What it does

Content Creator produces a 1,500-word long-form. Repurposer takes that piece and turns it into shapes that work on platforms where 1,500 words doesn't fly. For each output, the goal is a **stand-alone** asset — a social post should be readable and valuable without clicking through to the long-form.

Default outputs (per long-form):
- 1 LinkedIn post (the primary — 150–300 words)
- 1 Instagram caption (shorter, image-native)
- 1 Twitter/X short post
- 1 Email/newsletter segment (300–500 words)
- Optional: 1 Twitter/X thread (5–10 tweets) if the long-form has a clear sequential argument

Every output is voice-matched and platform-specific. LinkedIn's register is not Instagram's. Instagram's cadence is not Twitter's. Repurposer knows the difference.

## What it needs

- The long-form source piece (passed via chained trigger)
- `/vault/brand/voice-profile.md` with platform-specific voice notes (or falls back to base voice)
- Past high-performing short-form content (retrieved via pgvector) for platform-specific pattern matching

## What it doesn't do

- Schedule posts — just drafts. Posting is a human action.
- Generate images, videos, or graphics — text only
- Write outside the ideas in the source long-form (no new research)

## Cost per run

~£0.30 per run. Fast, small context window.

## Related

- **Content Creator** (source of every chained run)
- **Caption Writer** (overlaps conceptually, but Caption Writer works from assets, not long-form)
