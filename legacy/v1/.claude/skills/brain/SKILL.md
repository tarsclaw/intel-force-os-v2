---
name: brain
description: Intel Force OS Brain System — the markdown vault that powers all agents. Covers vault structure, session tracking, token reduction mechanism, skill files, and the Knowledge dashboard visualisation. Use this skill when working on knowledge management, session logging, token optimisation, vault storage, or the Knowledge page of the dashboard.
---

# Intel Force OS — Brain System Skill

**Full plan:** `BRAIN-PLAN.md` at project root.

## What the brain is

A markdown vault stored in Cloudflare KV. Every piece of knowledge, every session, every decision, every agent skill is a `.md` file. Agents load only what they need — 2–4k tokens instead of 40–50k. This is the Karpathy LLM wiki principle applied to an HR AI agent.

## Three layers

```
Layer 3: Agent skills    skills/hr-policy-lookup.md  (~800 tokens each)
Layer 2: Session memory  sessions/YYYY-MM-DD.md       (auto-written per day)
Layer 1: Knowledge base  handbook/leave-holiday.md    (written once, retrieved on demand)
```

## KV key patterns

```
brain:{tenantId}:skills:{skillName}          → compact agent context file
brain:{tenantId}:handbook:{section}          → individual policy page
brain:{tenantId}:sessions:{YYYY-MM-DD}       → append-only session log
brain:{tenantId}:decisions:{date}-{ref}      → immutable decision record
brain:{tenantId}:client-profile              → company profile, tone, ICP
brain:{tenantId}:vault-index                 → JSON index of all files
```

## Token reduction

Without brain: 40–200k tokens (full handbook loaded every call)  
With brain: 2–4k tokens (skill + 1-2 relevant policy sections)  
Reduction: 11–71× depending on handbook size

## File format rules

Every vault file MUST have YAML frontmatter with: `type`, `title`, `tags`, `related` (wikilinks).  
Policy files MUST include an `## Agent instructions` section at the bottom.  
Session files are append-only — never overwrite, always append.  
Decision files are immutable after write.  
All employee references in vault files use anonymised ref codes, never names.

## Wikilink convention

Use `[[filename]]` (no path, no extension) for links between vault files.  
These are parsed to build the knowledge graph in the dashboard.  
Every policy file should link to: its related sections, its approval-flow implications.

## Agent integration pattern

```typescript
// In claude.ts, replace full handbook load with:
const skill = await getSkill(kv, tenantId, 'hr-policy-lookup');
const policies = await searchPolicies(kv, tenantId, query);
const context = [skill, ...policies.map(p => p.content)].join('\n\n---\n\n');
```

## Dashboard Knowledge section

Three-panel layout: file tree (left) · markdown viewer (centre) · D3 force graph (right).  
Session timeline at bottom.  
Wikilinks in viewer are clickable — navigate the vault without leaving the browser.  
Graph nodes: policy (emerald) · session (amber) · decision (sky) · skill (purple).  
No redirect to Obsidian — everything renders in-dashboard.

## Session tracking (iron clad)

1. Worker receives message → `brain.sessionOpen()` → creates/appends `sessions/YYYY-MM-DD.md`
2. Agent runs → tools execute
3. Decision made → `brain.writeDecision()` → immutable `decisions/` file
4. `brain.sessionClose()` → finalises session entry
5. D1 dual-write always runs alongside (source of truth for billing/audit)

## Prisma model needed

`VaultFile` in `ops` schema: id, tenantId, path, type (POLICY|SKILL|SESSION|DECISION), title, tags[], wikilinks[], coverage (int), tokenCount, kvKey.

## Build order

Phase 1: vault.ts KV helpers + skill files for all 14 agents + handbook ingestion  
Phase 2: Session + decision logging wired into Worker  
Phase 3: Agent integration (swap full handbook for skill+pages)  
Phase 4: Dashboard visualisation (file tree + markdown viewer + D3 graph)  
Phase 5: Polish (skill stats, coverage scoring, vault export)

## Decisions — all resolved

1. **Handbook ingestion:** Microsoft MarkItDown (Python microservice, Docker, FastAPI wrapper at `services/markitdown/`). PDF upload → POST /convert → markdown → section parser splits on headings → KV. Supports PDF, Word, PowerPoint, Excel.
2. **Employee data:** Hybrid. Leave balances = always live from Breathe HR. Dept structure = cached in `employees/_index.md` (anonymised, refreshed 4h). No names ever in vault.
3. **Skill file editing:** Platform admin (Maddox) writes/edits skill files and `## Agent instructions` blocks. HR Lead can upload docs, view vault, add notes, edit hand-corrected policy text — NOT skill/routing logic.
4. **Graph layout:** D3 force-directed, Obsidian aesthetic. Node size = citation count. Pulse on files cited today. Grain texture, emerald glows, #07090b canvas. Filter pills + search.
5. **Session timeline:** Today = SSE real-time (same stream as escalations). Historical = paginated by week, loaded on demand. Shows token count per invocation (displays reduction vs baseline).
