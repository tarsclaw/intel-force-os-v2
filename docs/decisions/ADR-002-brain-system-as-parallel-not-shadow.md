# ADR-002 — Brain system as parallel, not shadow

**Date:** 2026-05-16 (Week 0, Day 1)
**Author:** Claude Code, with founder review pending
**Surfaced by:** `docs/architecture/cortexos-kb-surface-investigation.md` (data-model mismatch) + `docs/architecture/second-brain-design.md` (full design analysis)
**Submodule SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
**Status:** Accepted — Option α. Founder decision logged 2026-05-16.

---

## Context

Master brief §3.4 (line 167) frames the cortextOS / IFOS seam as a shadow:

> "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**." (master brief §3.4 line 167)

Master brief §5.1 line 304-308 names the four files: `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`.

The Day-1 cortextOS primitive audit (`docs/architecture/cortexos-primitive-status.md` — Primitive 3) surfaced that **none of those four files exist at SHA `c21fbfe`**. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. Reading `kb-setup.sh` revealed the substrate underneath: `mmrag.py` over ChromaDB with Gemini embeddings and 1000-char chunks (`docs/architecture/cortexos-kb-surface-investigation.md` §"What is cortextOS's KB substrate"). That data model is incompatible with the IFOS wiki's entity-document model in master brief §5.2.

The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.

## Decision

### Decision 1 — Brain system is parallel to cortextOS, not shadowed

cortextOS's `bus/kb-*.sh` surface and the `mmrag.py` / ChromaDB / Gemini stack at `packages/harness/cortextos/knowledge-base/` remain **untouched**. IFOS agents do **not** invoke `kb-query`, `kb-ingest`, `kb-collections`, or `kb-setup`. The §3.1 "edit-exception for four `bus/kb-*.sh` shadow points" in the master brief becomes a **dead clause**: there is no shadowing, the exception is never exercised, and §3.1's "never edit `packages/harness/cortextos/*`" stands without qualifier.

cortextOS's KB stays in place at `$HOME/.cortextos/ifos-v2/orgs/<org>/knowledge-base/` for any cortextOS-template agent ever scaffolded inside the `ifos-v2` instance (debug, probe, worker spawn — per investigation doc §1.5). It is parallel infrastructure, not deprecated.

### Decision 2 — Interface is Option α (shell wrappers at `packages/brain/bus-overrides/wiki-*.sh`)

Per `second-brain-design.md` §3.3, the agent-to-brain interface is shell wrappers that match cortextOS's existing 47-script `bus/` convention. v1.0 ships **9 wrappers + 1 v1.1 stub**, each a thin shim execing into a Node CLI at `packages/brain/wiki-cli/dist/cli.js`, which dispatches to a library at `packages/brain/wiki/lib/`.

The wrappers:

| Wrapper | Op (per design §2.3) | Release |
|---|---|---|
| `wiki-search.sh` | search-by-name | v1.0 |
| `wiki-get.sh` | search-by-id | v1.0 |
| `wiki-links.sh` | search-by-relationship + backlinks | v1.0 (relationship), v1.1 (backlinks read API) |
| `wiki-ingest.sh` | ingest-entity | v1.0 |
| `wiki-update.sh` | update-entity (+ rewrite-backlinks cascade per design §2.6.3) | v1.0 |
| `wiki-append.sh` | append-to-narrative | v1.0 |
| `wiki-list.sh` | list-by-type-and-tenant | v1.0 |
| `wiki-history.sh` | entity-history (reads `decision_log`) | v1.1 |
| `wiki-find.sh` | search-by-attribute (JSONB GIN) | v1.1 |
| `wiki-archive.sh` | soft-delete via `wiki/compiled/archive/` | v1.2+ placeholder |

Library code organised as `wiki/lib/{ingest, update, search, append, list, backlinks, history, concurrency, frontmatter}.ts` — 9 modules. Concurrency mechanisms (`flock(2)` + Postgres optimistic concurrency + Obsidian-aware mtime debounce + rewrite-backlinks cascade) live in `wiki/lib/concurrency.ts` per design §2.6.

Rationale per design §3.3, anchored to:

- **Master brief §3.1** — Option α uses the boundary's vocabulary (parallel `bus-overrides/` directory) without exercising its kb-* exception.
- **Master brief §8** — wiki ops are internal to IFOS; treating them as bus commands keeps `tools.yaml` clean of internal-surface declarations, reserving it for external MCP execution backends per §3.2.
- **Master brief §3.5 + Product Spec §5.4** — α adds zero per-customer infrastructure; the 100-customer stress test passes without operational drag.

Options β (MCP server) and γ (Claude Code skill) are rejected on the grounds documented in design §3.2 (rubric) and §3.3 (recommendation rationale).

### Decision 3 — Storage substrate per `second-brain-design.md` §2.4

- **Filesystem markdown** at `/vault/{tenant-slug}/wiki/` per design §2.1 (POSIX 0700 / 0644, per-tenant OS user `ifos-tenant-{slug}` per Ultraplan §5.1 line 218).
- **Postgres tables (v1.0):** `tenants`, `entities`, `entity_links`, `decision_log` — schemas in design §2.4.2. RLS by tenant_slug on every table except `tenants`. The Ultraplan §5.1 line 227 single `entity_graph` table is **split** into `entities` (one row per entity) and `entity_links` (adjacency) — see Spec gap 2.4-B in the design doc.
- **pgvector index (v1.0):** `voice_samples_embedded` only — embedding model `gemini-embedding-001` (3072 dimensions), matching cortextOS's KB substrate for forward-compatibility per design §2.4.3.
- **cortextOS KB at `$HOME/.cortextos/ifos-v2/orgs/<org>/knowledge-base/`** — untouched; used only by cortextOS-template-derived agents.

### Decision 4 — v1.2+ semantic-search-over-raw hook is left open

The one operation where cortextOS's mmrag/ChromaDB substrate could still serve IFOS is **semantic-search-over-raw** against `/vault/{tenant}/wiki/raw/` content (per design §2.3 row 9). That operation is **v1.2+ deferred**. ADR-002 explicitly **does not commit** to either cortextOS-substrate or IFOS-pgvector-native for the eventual implementation. The decision is deferred to a future ADR (likely in v1.2 planning) so it can be made against then-current evidence: actual raw/ volume, actual query patterns, actual cost data on Gemini embeddings, and whether Anthropic or OpenAI has shipped a sharply better embedding model by then.

The forward-compatibility hook is: **do not dismantle cortextOS's KB tooling**. The submodule keeps the mmrag.py engine, the ChromaDB index, and the `bus/kb-*.sh` scripts. If v1.2+ chooses cortextOS-substrate for semantic-search-over-raw, the path is intact.

## Master brief edits authorised by this ADR

Three edits, two in the atomic correction commit alongside ADR-001's `chokidar → FastChecker` edits, one in the Day 4 Postgres provisioning task.

### Edit 1 — Master brief §3.4 brain-replacement seam wording

**Current** (master brief §3.4 line 167-176): "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**. … 1. Vendored copy at `packages/harness/cortextos/bus/kb-*.sh` is left untouched. 2. Our overrides live at `packages/brain/bus-overrides/kb-*.sh`. 3. PM2 `ecosystem.config.js` sets `PATH` so our overrides are picked up first…"

**Proposed:** "IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 'four `bus/kb-*.sh` shadow points' edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/architecture/second-brain-design.md` for the full design."

### Edit 2 — Master brief §5.5 v1.0 brain build wording

**Current** (master brief §5.5 lines 416-420):

> "v1.0 minimum (weeks 11-13) — `bus-overrides/kb-*.sh` shadow + `wiki/lib/{ingest,search}.ts` — agents can write and search but no UI yet"

**Proposed** (per design §3.4):

> "v1.0 minimum (weeks 11-13) — 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; no Brain UI yet. Total v1.0 effort ~11-13 person-days. v1.1 adds `wiki-find.sh` + `wiki-history.sh` + Brain UI today-view and backlinks panel."

### Edit 3 — Master brief §6 Day 4 Postgres table list

**Current** (master brief §6 Day 4 line 478):

> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"

**Proposed:**

> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."

This edit lands on **Day 4 of Week 0 (this week)** as part of the Postgres provisioning task per master brief §6 Day 4, **not** in the brain-ADR atomic commit. ADR-002 authorises the split; Day 4 implements it.

## Consequences

**For the v1.0 brain build (weeks 11-13).** Reference `second-brain-design.md` §3.4 closing paragraph. Weeks 11-13 hold; scope is materially clarified (9 wrappers + 9 library modules + 4 tables + pgvector voice index vs. the original "shadow four files + 2 .ts files" framing). v1.0 effort estimated at 11-13 person-days, fitting the 15-day budget.

**For Week 1 work.** ADR-002 makes three Week-1 prerequisites load-bearing:

1. **ADR-003 + `docs/architecture/agent-bundle-renderer-design.md`** — resolves Spec gap §1.7-A (no documented translation from IFOS Agent Bundle v2 layout to cortextOS-shaped per-agent directory). Without it, no IFOS agent can run. Design recommends R2 (bundle-only, no `.claude/skills/` inheritance) per design §1.7.
2. **`docs/architecture/vault-concurrency.md`** companion document — resolves Spec gap 2.6. Documents the `flock(2)` + Postgres optimistic concurrency + Obsidian `human_editing` debounce + rewrite-backlinks cascade per design §2.6.1-§2.6.3. Lands by Week 1-2 so concurrency code in `wiki/lib/concurrency.ts` is reviewable before week-5 multi-agent testing.
3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.

**For Day 4 this week (Postgres provisioning).** The `entity_graph` → `entities` + `entity_links` split per Spec gap 2.4-B / 3.4-B must land in the Day 4 migration. This is the only immediate-week impact of ADR-002.

**For cortextOS upstream.** No PR upstreamable from this ADR. cortextOS code is untouched; the submodule pin (`c21fbfe991a0030ea055bd8e2389a0801a424383`) stays. The brain-replacement boundary in master brief §3.1 simply isn't exercised — that's not a bug in cortextOS, it's an IFOS-side decision to use a parallel surface.

**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1 and 2 above — §3.4 wording and §5.5 v1.0 brain build wording) land together. Single commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 spec drifts`. Queued for Codex ratification on Day 7 alongside the other six Week 0 artefacts per master brief §10.6.

**For future ADRs.** ADR-002 explicitly defers three decisions:

- **ADR-003 (renderer, R1 vs R2)** — design recommends R2; binding choice deferred to a separate ADR in Week 1.
- **Future v1.2+ ADR (semantic-search-over-raw substrate)** — cortextOS mmrag vs IFOS-pgvector-native; decision made then on then-current evidence per Decision 4 above.
- **Future v1.1+ ADR (Brain UI implementation choice)** — Next.js routes extending the cortextOS dashboard per master brief §5.3 vs. standalone — out of scope for Q3.

## Status

**Accepted — Option α.** Founder decision logged 2026-05-16. Next steps:

1. ADR-001 + ADR-002 master-brief edits land in one atomic correction commit (deferred to end of Week 0 or early Week 1).
2. Edit 3 (Postgres table split, `entity_graph` → `entities` + `entity_links`) lands as part of the Day 4 Postgres provisioning task, this week.
3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
