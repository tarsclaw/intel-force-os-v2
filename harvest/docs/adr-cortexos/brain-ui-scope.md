# Brain UI scope — decision document

**Date:** 2026-05-16 (Week 0, Day 3)
**Status:** Proposed — revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch)
**Author:** Claude Code, with founder review pending
**Surfaced by:** Master brief §6 Day 3 line 472 — "Brain UI v1.0 scope decision" + ADR-002 §3.4 closing paragraph (Brain UI explicitly forward-deferred to v1.1) + `second-brain-design.md` §3.4 ("Brain UI minimal v1 is built as a thin read-only page over `decision_log` — no new wiki API needed").
**Submodule SHA referenced:** `c21fbfe991a0030ea055bd8e2389a0801a424383`

**Reading order:** master brief §5.5 (Brain UI build sequence stages) + ADR-002 (parallel-not-shadow + v1.0 brain build wording correction) + `second-brain-design.md` §3.4 closing paragraph (Brain UI v1.0+ scope) first; then this document end-to-end.

---

## Section 1 — Context

Per master brief §5.5 (lines 416-424) after ADR-002 Edit 2 applies in the atomic correction commit, the staged Brain UI build is:

- **v1.0 minimum (weeks 11-13):** wiki API + Postgres tables (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector voice samples + 9 `wiki-*.sh` parallel wrappers + 9 `wiki/lib/*.ts` modules. **No Brain UI** — operational access via Obsidian + CLI + psql.
- **v1.1:** Brain UI today-view + backlinks panel + wiki-find UI.
- **v1.2:** graph view (cytoscape force-directed, master brief §5.3 line 396).
- **v2.0:** second-brain-at-scale features (reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views per master brief §5.5).

This document scopes the **v1.1 Brain UI work without committing to implementation details.** The decision deferral is by design — at v1.1 phase start, founder + Claude Code will have observed v1.0 actual wiki usage patterns and can scope sub-features and implementation choices against real evidence rather than speculation.

**Revisit trigger:** start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2 v1.1 timing). Three v1.0 observations will inform the v1.1 scoping session:

1. Which wiki operations get hit hardest in v1.0 (decision_log queries vs entity reads vs entity_links traversals) — informs which feature lands first in v1.1.
2. How often founder accesses the vault via Obsidian vs CLI in v1.0 ops — informs whether founder-tooling or design-partner-facing-UI is the v1.1 priority.
3. What the first paying design partner asks for after Concierge ships in v1.0 — direct user-research input.

---

## Section 2 — v1.1 Brain UI features

Three features named in master brief §5.5 (post-ADR-002-Edit-2 wording) + `second-brain-design.md` §3.4. Each feature scoped here without implementation commitment.

### 2.1 — Today view

**What it does (v1.1 scope):**

- Surfaces entity activity in the last 24h across the brain — recently-updated entities (Candidates, Clients, Briefs, Placements, Contacts per `second-brain-design.md` §2.2).
- Shows recent `decision_log` entries with phase + outcome filtering (`trigger | output | action | gating_failed | agent_handoff` per `sequencing-target.md` §5.3 + §6.5 enum extension).
- Highlights pending approvals (Concierge auto-send escalations per `bullhorn-integration-path.md` §4.1 row 4).
- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
- Per-tenant scoped via RLS per ADR-002 §3 Decision 3; multi-tenant founder view aggregates across tenant_slugs.

**What it doesn't do in v1.1:**

- No real-time streaming (polling-based refresh, likely 30-60s default; deferred to v1.2+).
- No historical analytics or aggregation beyond the 24h window.
- No editing or writing — strictly read-only.
- No mobile-optimised layout (desktop-first per master brief §5.3 line 397 framework choice).

**Likely implementation surface:** Next.js route at `/brain/today` (or equivalent), reading Postgres `decision_log` + `entities` + filesystem mtime on `/vault/<tenant>/wiki/raw/`. Auth model deferred to §3.

**Dependency on v1.0:** wiki API live + `decision_log` populated per ADR-002 §3 Decision 3 + extended phase enum per `sequencing-target.md` §6.5.

### 2.2 — Backlinks panel

**What it does (v1.1 scope):**

- For any entity, shows all entities that reference it via wiki-link.
- Implements the `wiki-links.sh` backlinks read API per ADR-003 §"Decision 3" + design §2.1 — v1.1 release of the wrapper.
- Bidirectional traversal: forward links (`linked_entities` frontmatter field) + backlinks (Postgres `entity_links` reverse lookup).
- Per-tenant scoped via RLS.

**What it doesn't do in v1.1:**

- No graph visualisation (text / list format only — graph view is v1.2 per master brief §5.5).
- No filtering by relationship type beyond simple entity-type match.
- No editing of relationships from the panel.

**Likely implementation surface:** Next.js route at `/brain/entity/<id>` with backlinks pane. Reads Postgres `entity_links` table per `second-brain-design.md` §2.4.2 schema. Reuses `wiki-links.sh` API (v1.1 wrapper per ADR-003).

**Dependency on v1.0:** `entity_links` table live + populated by v1.0 wiki ingest paths (`wiki/lib/update.ts` rewrite-backlinks cascade per `second-brain-design.md` §2.6.3).

### 2.3 — Wiki-find UI

**What it does (v1.1 scope):**

- Graphical query builder for `wiki-find.sh` search-by-attribute API (v1.1 wrapper per ADR-003 §"Decision 3" + design §2.3 row 4).
- Converts JSONB GIN queries on `entities.frontmatter` (per `second-brain-design.md` §2.4.2 + §2.5 row 4) into user-friendly form fields — typeahead on `entity_type`, attribute dropdowns sourced from common-*.json schemas.
- Per-tenant scoped via RLS.

**What it doesn't do in v1.1:**

- No saved queries or query history.
- No advanced operators beyond what `wiki-find.sh` supports (i.e. JSONB containment + trigram fuzzy match per design §2.5).
- No export functionality (CSV / JSON output deferred to v1.2+).

**Likely implementation surface:** Next.js route at `/brain/find` with query builder + result list. Calls `wiki-find.sh` (v1.1 wrapper) backend. Uses `entities` + `entity_links` Postgres tables.

**Dependency on v1.0:** `wiki-find.sh` shipped in v1.1 itself (the wrapper isn't a v1.0 deliverable per ADR-003 §"Decision 3" wrapper table); `decision_log` + `entities` populated in v1.0.

---

## Section 3 — Implementation surface (deferred to v1.1 planning)

Two options. **Neither chosen in v1.0.** Trade-offs documented for the v1.1 planning session.

### 3.1 — Option α — Extend cortextOS dashboard

Add `/brain/*` routes to the existing cortextOS Next.js 14 dashboard at `packages/harness/cortextos/dashboard/`. Master brief §5.3 lines 380-403 already names this pattern: "**same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point" at `packages/dashboard-ext/src/app/(dashboard)/brain/`.

- Reuses cortextOS dashboard auth, layout, navigation.
- Tight coupling to cortextOS submodule (`packages/harness/cortextos/dashboard/`) — submodule boundary per master brief §3.1 must hold; the `dashboard-ext` integration point is the cortextOS-blessed extension surface, not a fork.

### 3.2 — Option β — Standalone IFOS Brain UI

A new IFOS-owned Next.js app at `packages/brain-ui/`. Independent of cortextOS dashboard.

- Cleaner separation from cortextOS submodule (no coupling to dashboard schemas).
- Needs IFOS-owned auth — WorkOS AuthKit per master brief §5.3 line 401 ("Auth: WorkOS AuthKit (per memory: founder already uses this)").
- Per-tenant deployable on independent versioning cadence.

### 3.3 — Preliminary trade-offs (to revisit at v1.1)

| Criterion | Option α (cortextOS dashboard extension) | Option β (standalone IFOS Brain UI) |
|---|---|---|
| Time-to-ship in v1.1 | Faster — reuses dashboard chrome + auth | Slower — auth integration + chrome scaffolding from scratch |
| Coupling to cortextOS submodule | Tight (dashboard-ext integration point) | Loose (independent app) |
| Auth model | cortextOS dashboard auth | WorkOS AuthKit per master brief §5.3 line 401 |
| cortextOS-submodule-upgrade risk | High — submodule SHA bump may break dashboard-ext | Low — independent versioning |
| Mobile / responsive design | Inherits dashboard's responsive model | Owned by IFOS, designable for product spec §2.1.3 "looks stunning" requirement |
| Multi-tenant isolation in UI | Inherits dashboard's tenant model | Designed for IFOS multi-tenant from start |

**Recommendation deferred to v1.1 planning.** Master brief §5.3 lines 379-380 currently favours Option α: "**The strategy: same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point." That's the canonical-master-brief stance and is the default unless v1.0 ops surface a reason to deviate. This document does not bind the decision in v1.0 — it's revisited with v1.0-actual-usage evidence.

---

## Section 4 — Consequences

### 4.1 — For v1.0 (weeks 11-13)

No UI work. Wiki API + Postgres + pgvector + filesystem is the v1.0 deliverable per ADR-002 Edit 2 + `second-brain-design.md` §3.4 closing paragraph. Master brief §5.5 already correctly scopes this (post-Edit-2). No new constraint from this document.

### 4.2 — For founder operations (v1.0 ops)

Founder accesses v1.0 wiki via three channels:

- **Obsidian** against `/vault/<tenant-slug>/wiki/` directly per `second-brain-design.md` §2.1 + §2.6.2 — primary read access; respects the `human_editing: true` flag concurrency mechanism per design §2.6.2.
- **`wiki-*.sh` CLI** per ADR-003 §"Decision 3" wrapper table — programmatic queries for ad-hoc lookups.
- **`psql` against Postgres `decision_log`** for escalation review + audit trail — direct SQL queries, no UI layer.

No UI needed for v1.0 internal ops. Acknowledged operational constraint; trades founder ergonomics for v1.0 ship speed.

### 4.3 — For first design partner (v1.0 sales)

The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:

- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
- **Vault directory directly** if curious — Obsidian-rendered markdown, design partner sees the raw entity-document model.
- **`decision_log` audit trail** if asked — `psql` query showing per-agent decisions over time.

**No Brain UI tour in v1.0 sales motion.** Brain UI is a forward-feature, not a v1.0 sales asset. The closing demo is the agent outputs landing in the design partner's existing tools — the wedge per master brief §0 paragraph 1. Brain UI joins the sales asset list at v1.1.

### 4.4 — For v1.1 planning

This document is the input to v1.1 phase planning. At start of v1.1 phase:

1. **Validate** that the three v1.1 features (today view, backlinks panel, wiki-find UI) are still the right priorities given v1.0 actual usage patterns.
2. **Decide α vs β** implementation surface based on (a) cortextOS submodule upgrade frequency observed in v1.0, (b) founder UX-preference signal from observed ops, (c) first design partner's UI requirements if any.
3. **Scope sub-features** and weekly build plan for the v1.1 Brain UI work — likely 4-6 weeks per feature based on §2 surface estimates, but revised against actual evidence.

The three §1 revisit-trigger inputs (which wiki operations get hit hardest; how often founder accesses Obsidian vs CLI; what first design partner asks for) are the empirical inputs.

### 4.5 — For atomic correction commit (8th edit)

Per pre-write check: master brief §6 Day 3 line 472 contains **three drifts** bundled into a single-line rewrite.

**Current** (master brief §6 Day 3 line 472 verbatim):

> "- [ ] **Brain UI v1.0 scope decision.** Per §5.5, v1.0 ships the `bus-overrides/kb-*.sh` shadow + ingest/search lib + the `/brain` today-view. The full wiki rendering is v1.1, the graph is v1.2. **Confirm this in `.agents/decisions/brain-ui-scope.md`** — or document the deviation."

**Proposed:**

> "- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation."

Three drifts corrected in one rewrite:

1. **Path** `.agents/decisions/brain-ui-scope.md` → `docs/decisions/brain-ui-scope.md` (same convention drift as line 471, fixed in `sequencing-target.md` §6.8 as the 7th edit).
2. **`kb-*` shadow language** → `wiki-*` parallel system (corrects against ADR-002 Edit 1 §3.4 brain-replacement seam wording).
3. **`/brain` today-view as v1.0 deliverable** → today-view is v1.1 (corrects against ADR-002 Edit 2 §5.5 v1.0 brain build wording).

**Joins the atomic correction commit as the 8th edit.** Updated 8-edit manifest:

1. ADR-001 §2.4 row 3: chokidar → FastChecker
2. ADR-001 Ultraplan §3.2: latency reframe
3. ADR-002 Edit 1 §3.4: shadow → parallel
4. ADR-002 Edit 2 §5.5: v1.0 brain build wording
5. ADR-003 Edit C §8: renderer footnote
6. `bullhorn-integration-path.md` §6.6: §6 Day 2 line 466 OAuth wording
7. `sequencing-target.md` §6.8: §6 Day 3 line 471 path convention
8. **`brain-ui-scope.md` §4.5: §6 Day 3 line 472 three-drift rewrite** (NEW Day 3)

Single Codex ratification on Day 7.

### 4.6 — For Codex Day-7 ratification

This document joins the queue. Codex reviews:

- §1 (forward-deferral framing — Status: Proposed is structurally appropriate because v1.0 actual-usage evidence is the input v1.1 planning needs).
- §2 (three features scoped without implementation commitment — adequate granularity for v1.1-planning-session input).
- §3 (α vs β both Proposed — preliminary trade-off table; not binding).
- §4.4 (v1.1 revisit trigger with three named empirical inputs).
- §4.5 (8th atomic-correction edit with verbatim before/after).

---

## Section 5 — Spec gaps (single bucket — deferred to v1.1 planning)

All operational defaults below are revisited at v1.1 planning session start. None blocks v1.0; none requires master-brief edit beyond the 8th edit captured in §4.5.

| Deferred item | Where it lands at v1.1 |
|---|---|
| Specific Next.js routes per feature (`/brain/today`, `/brain/entity/<id>`, `/brain/find`) | v1.1 planning session — routes finalised against Option α vs β choice |
| Auth model integration with WorkOS AuthKit (Option β only) | v1.1 planning — only if Option β chosen; Option α inherits cortextOS dashboard auth |
| Real-time vs polling for today view refresh (default polling 30-60s) | v1.1 planning — based on observed v1.0 escalation frequency; if `ESC_*` rate is high, real-time may matter |
| Mobile / responsive design support | v1.2+ — explicitly deferred per §2.1 "no mobile-optimised layout" |
| Multi-tenant aggregation view for founder (cross-tenant rollup) | v1.2+ — single-tenant per-page is sufficient for v1.1 |
| Graph visualisation for backlinks panel (cytoscape force-directed) | v1.2 per master brief §5.5 — explicitly v1.2 milestone, not v1.1 |
| Editing-from-UI capability (vs read-only) | v2.0+ — v1.1 is strictly read-only |
| Saved queries / query history for wiki-find UI | v1.2+ — explicitly deferred per §2.3 "no saved queries" |
| Export functionality (CSV / JSON from wiki-find UI) | v1.2+ — explicitly deferred per §2.3 "no export functionality" |

---

## Status

**Proposed.** Revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2). At revisit, founder + Claude Code:

1. Validate three v1.1 features (today view, backlinks panel, wiki-find UI) remain priorities against three §1 revisit-trigger empirical inputs.
2. Decide α (cortextOS dashboard extension) vs β (standalone IFOS Brain UI) implementation surface per §3.
3. Scope sub-features and weekly build plan for v1.1 Brain UI work — likely Q4 2026 sprints, exact weekly slots TBD against the v1.1 master-brief sequence.

End of brain-ui-scope decision document.
