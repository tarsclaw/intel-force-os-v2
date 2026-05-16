---
description: Search across all Intel Force OS spec files. Use when you need to find where something is documented but don't know which pack.
---

# /search-specs {query}

Search all 163 spec files across 8 packs for mentions of a keyword or phrase.

## Usage

```
/search-specs "escalation"
/search-specs "Adaptive Card"
/search-specs "Sarah Chen"
/search-specs "MSA"
/search-specs "AWS KMS"
```

## What I do

1. Run `grep -r -l -i "{query}" docs/` to find files containing the query
2. For each matching file, run `grep -n -i "{query}" {file} | head -5` to get context
3. Group results by pack
4. Return a ranked list with the most relevant files first

## Output format

```
Query: "escalation"

Results across 14 files:

=== Pack 7: Teams HR Agent (active) ===
docs/teams-hr-agent/02-component-design.md
  Line 234:  ### 3.2 Escalation card rendering
  Line 389:  If escalation_recommended, route to HR Lead DM
  Line 512:  The escalation category maps to sensitivity_score

docs/teams-hr-agent/01-architecture-overview.md
  Line 167:  Escalations never get AI drafts, per §5.3 invariants

=== Pack 2: Agent Suite (reference) ===
docs/phase-2-agent-suite/_shared/escalation-codes.md
  [entire file is about escalation]

docs/phase-2-agent-suite/hr-agent/hr-agent-escalation-codes.md
  Line 12:  HR-specific always-escalate categories
  [etc]

=== Pack 6: Ops Runbooks (dormant) ===
docs/phase-6-ops-runbooks/severity-classification-and-comms.md
  Line 89:  Incident escalation (distinct from agent escalation)
  
=== Pack 3: Platform v2 (deferred) ===
docs/phase-3-platform/escalation-notifier-service.md
  [entire file]

Suggested starting points based on current pack (Teams HR Agent):
  1. docs/teams-hr-agent/02-component-design.md §3.2 — implementation
  2. docs/phase-2-agent-suite/_shared/escalation-codes.md — canonical categories
```

## Search tips for this project

### Common query patterns that work

- **Concept search:** `/search-specs "approval flow"` — finds all references across packs
- **Decision search:** `/search-specs "OD-P3"` — finds Open Decisions referencing Phase 3
- **Invariant search:** `/search-specs "never sends"` — finds the nothing-sends-without-approval invariant
- **Proper noun search:** `/search-specs "Rigby"` — finds Agency Partner references

### Refining the search

If you get too many results:
- Add context: `/search-specs "escalation card"` (more specific than "escalation")
- Add a pack constraint: `/search-specs "escalation" --pack=teams-hr-agent`
- Add exclusion: `/search-specs "audit" --exclude=phase-6`

## Also try

- **`/load-phase {pack}`** — if you know which pack, load it directly
- **`MASTER-INDEX.md`** — topical lookup table
- Direct file reading — if you know the path

## When NOT to use this command

- For code search (use `grep` or `rg` on `src/` directly)
- For memory of what was discussed in past sessions (spec docs won't have it)
- For external docs (Cloudflare, Microsoft — use the MCPs instead)

## One caveat

Sometimes a topic is mentioned across 30+ files because it's foundational (e.g. "escalation," "tenant," "Teams"). The grep approach returns everything. I'll summarise rather than list if there are too many hits.
