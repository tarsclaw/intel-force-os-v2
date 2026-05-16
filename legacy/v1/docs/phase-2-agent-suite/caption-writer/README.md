# Caption Writer

**Purpose:** Generate 3–5 caption variants for a pre-existing asset (photo, video, screenshot) the client uploads.

**Trigger:** Manual dashboard upload + watch folder (`/tenant/intake/manual/captions/`).

**Output:** Caption variants saved to `/vault/content/social/captions/` + Slack message to client with the variants.

**Tier availability:** All tiers.

---

## What it does

The client takes a photo, records a short video, screenshots a testimonial, or otherwise has a visual asset they want to post — but can't be bothered to write the caption. Caption Writer takes the asset, analyses it, and produces 3–5 caption variants in the client's voice, each targeting a different angle or platform register.

Unlike Repurposer (which derives from long-form written content), Caption Writer works from visual media and context notes. It's the quickest-to-value agent in the suite — the agency dropping one asset in the intake folder gets five captions back in 30 seconds.

## What it needs

- The uploaded asset (image or short video — platform limits apply)
- Optional context note from the uploader ("this is for Instagram, we just hit 100 clients" or "Dr Patel's birthday post")
- `/vault/brand/voice-profile.md`
- Image analysis capability (Claude's native vision or an MCP tool)

## What it doesn't do

- Edit or manipulate the asset — captions only
- Add hashtags beyond the voice profile's guidance
- Post anywhere — drafts to vault, Slack message to client, client posts
- Handle NSFW content (escalates)
- Handle copyrighted logos or brands in the image without context confirming permission

## Cost per run

~£0.15 per run. Vision input + small output.

## Related

- **Content Creator / Repurposer** (different kind of short-form — those atomise long-form written pieces; Caption Writer works from visual assets)
