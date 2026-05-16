# Lead Hunter

**Purpose:** Generate a ranked list of qualified prospects matching the client's ICP, using a UK-compliant data stack.

**Trigger:** Nightly cron (default 02:00 UTC) + manual "Run Now" from dashboard.

**Output:** Markdown prospect list in vault (`/vault/clients/_prospects/{YYYY-MM-DD}-prospect-list.md`) + HubSpot deals created in "New — Unreviewed" stage.

**Tier availability:** Growth+.

---

## What it does

Lead Hunter is the top-of-funnel workhorse. Every night, it takes the client's ICP criteria (SIC codes, employee range, revenue range, location, technology signals), queries Companies House, Prospeo, and Kaspr, enriches each result with a named decision-maker + verified email + phone, deduplicates against the existing CRM, scores each prospect against fit criteria, and produces a ranked list for morning human review.

The output format is deliberately scannable: 10–30 prospects per run, each with a one-line "why this one" justification, verified contact details, and a direct link to review in HubSpot.

The agent doesn't attempt to contact anyone — it's a qualification and enrichment engine, not an outreach engine. Outreach is a human action (or a different agent: Follow-Up Pilot).

## What it needs

- `/tenant/vault/brand/icp.md` — the ICP definition (SIC codes, size, geography, tech signals, disqualifiers)
- `/tenant/vault/brand/positioning.md` — to generate the "why this one" line in the client's voice
- `/tenant/.claude/tenant-config.json` — integration credentials refs
- Integrations: Companies House (free API, key required), Prospeo (paid, email finder), Kaspr (paid, phone + LinkedIn enrichment), HubSpot (deal creation)
- Previous run's output (for dedup) — read from the most recent prospect list in the same directory

## What it doesn't do

- Cold outreach — no emails sent, no connection requests, no phone calls
- LinkedIn scraping — we use Kaspr's licensed data, not DIY scrapers (compliance)
- Pattern-matching on companies not in our data sources (no "I see a competitor mentioned on Reddit" prospecting)
- Contact people who've previously opted out (check `/tenant/vault/brand/suppression-list.md`)

## Cost per run

- Companies House: free
- Prospeo: ~£0.10 per email verified (we verify top ~30 candidates post-scoring, so ~£3 per run)
- Kaspr: ~£0.15 per phone number (top ~10 enriched for the highest-scored prospects, so ~£1.50 per run)
- Anthropic Sonnet: ~15k tokens input, ~4k tokens output = ~£0.25 per run
- **Total: ~£5 per run, ~£150/month at daily cadence**

This runs at 5% of the margin on a single Growth-tier client — well within economics.

## Related

- **Follow-Up Pilot** (takes unconverted enquiries from prospects who became leads)
- **Proposal Builder** (produces proposals for prospects who book a discovery call)
- **Client Onboarder** (fires when a prospect becomes a client via HubSpot "Won" stage)
