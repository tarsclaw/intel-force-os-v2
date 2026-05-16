# Librarian

**Purpose:** Keep the vault tidy, current, and retrievable. Runs nightly. Other agents depend on its output.

**Trigger:** Nightly cron (04:00 UTC) + manual "Force re-index" from dashboard.

**Output:** Updated pgvector index + tag corrections + daily rollup (`/vault/daily/{YYYY-MM-DD}.md`) + archive movements + flags-for-human in `/outbox/librarian/`.

**Tier availability:** All tiers — hidden (clients don't see it in the agent list; it's infrastructure).

---

## What it does

Librarian is the agent that nobody sees and everyone benefits from. Every night at 04:00 UTC it:

- **Scans** every file modified in the last 24h
- **Tags** new content with the correct taxonomy (checks existing tag patterns, assigns based on path + content analysis)
- **Embeds** new text content via Cohere EU, upserts into pgvector for retrieval
- **Writes** the daily rollup note summarising yesterday's agent activity, human edits, and things needing attention
- **Archives** content older than N days that hasn't been accessed or updated (configurable, default 90)
- **Flags** inconsistencies — tag drift, broken internal links, SOPs past their `last_verified` deadline, stale client records
- **Reports** its own health — index size, disk usage, embedding costs

Without Librarian, the vault gradually becomes messy, retrieval degrades, and every other agent's quality drops. With Librarian, the vault stays usable indefinitely.

## What it needs

- Full vault read+write access (tenant-scoped)
- Cohere EU API (embeddings)
- pgvector (per-tenant schema)
- Filesystem access to disk usage stats

## What it doesn't do

- Delete anything — archiving moves to `/vault/archive/`, never deletes
- Change the content of files (only frontmatter tags, when correcting)
- Overwrite human edits — agent-written content is re-indexed on change; human-written content is indexed once
- Handle the actual retrieval — that's `vault-search` CLI called by other agents' `context.sh`

## Cost per run

- Cohere embeddings: ~£0.10/day (embeds only new/changed content)
- Sonnet (for tag correction + rollup writing): ~£0.50/day
- **Total: ~£18/month per tenant**

Highest-value agent in the suite on a cost-adjusted basis — enables every other agent's retrieval quality.

## Related

- **Every other agent** — they all depend on Librarian's indexing and tagging
- **Reporting Engine** — reads Librarian's daily rollups to synthesise monthly reports
