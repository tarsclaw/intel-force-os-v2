# Content Creator

**Purpose:** Produce long-form content (800–2,500 words) in the client's voice from a topic brief.

**Trigger:** Weekly cron (default Mondays 08:00 local) + manual with brief from dashboard.

**Output:** Long-form markdown in `/vault/content/long-form/` + Gmail draft to sales lead for review. Triggers Repurposer on save.

**Tier availability:** Growth+.

---

## What it does

Content Creator takes a brief (from Client Onboarder's "first content brief" or a manual dashboard submission) and produces a single long-form piece — an article, guide, essay, or thought-leadership post. It researches the topic via web search (citing sources), outlines in the client's structural preferences, drafts in the client's voice, and self-checks against the voice profile before saving.

The output is deliberately an unfinished draft — ready for the client to take the last 10% of polish. The aim is not "publish-ready"; it's "the human doesn't have to start from a blank page."

On every save, Repurposer fires automatically as a chained agent, converting the long-form into social + email + optional thread.

## What it needs

- `/vault/brand/voice-profile.md` — the voice bible
- `/vault/content/long-form/` — past high-performing pieces (retrieved via pgvector for voice anchoring)
- `/vault/brand/positioning.md` — so the piece fits the brand's broader narrative
- A brief (either from `/vault/content/briefs/` or inline from trigger payload)
- Web search access for research
- Optional: Ahrefs/SEMrush MCP for SEO intent signals (v1.1)

## What it doesn't do

- Publish — everything drafts to vault, sales lead reviews and publishes
- Write in a voice it doesn't have reference material for — escalates if voice profile incomplete
- Write about topics outside the client's zone of expertise/authority (escalates as `CONTROVERSIAL_TOPIC`)
- Fabricate statistics, case studies, or quotes

## Cost per run

~£1.20–£2.00 per run (longer context window + web search calls + output tokens). Scales with brief complexity.

## Related

- **Client Onboarder** (produces first brief)
- **Repurposer** (chains off Content Creator saves — shares this agent's output)
- **Reporting Engine** (reports on content engagement monthly)
