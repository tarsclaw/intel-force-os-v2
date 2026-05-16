# Current priorities

**Week:** Week 0 (pre-build)
**Today's task:** Day 2 — Bullhorn integration path per master brief §6 Day 2

## This week's gate

Clear all seven days of master brief §6 by Sunday. Five-of-five yeses on the
§6 Day 7 single-sentence test gates entry to Week 1.

## Open

- [ ] Day 2: Bullhorn integration path decision (`docs/decisions/bullhorn-integration-path.md`) — marketplace vs direct API, OAuth flow (browser dance for production, service-account for dev), scope of v1.0 surface (read endpoints minimum; write endpoints for Janitor/Concierge)
- [ ] Day 2: founder runs design-partner sales conversation 2 (founder track, not a Claude Code task)
- [ ] Day 3: sequencing target + Brain UI scope decisions (`docs/decisions/`); hire #1 status one-liner
- [ ] Day 4: Hetzner UK VPS + Postgres 16 + LUKS + RLS isolation test. **Postgres table list updated:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (split from `entity_graph` per ADR-002 Edit 3). **Plus:** add `_secrets.env` to `provision-tenant.sh` vault skeleton per ADR-003 design §3.3 spec gap §2.1-C
- [ ] Day 5: auto-send safety policy + kill criterion
- [ ] Day 6: vertical schema v0.1 (`docs/verticals/recruitment/vertical-schema.yaml`)
- [ ] Day 7: single-sentence test review + first Codex ratification run

## Shipped today (Day 1, 2026-05-16)

### Day 1 main session (commit e0e223f)

CortexOS primitive audit + brain-system design decisions, all artefacts ratifiable for Day 7:

- `docs/architecture/cortexos-primitive-status.md` — 7-primitive audit against SHA `c21fbfe`, with `shipped and tested` / `shipped but flaky` / `aspirational` classifications, IFOS dependency mapping per v1.0 agent, and concrete verification commands. Two master-brief drifts surfaced (chokidar, kb-* filenames).
- `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` — **Accepted Option A** (accept the 3-5 second pipeline floor; rewrite Ultraplan §3.2; do not tune `pollInterval`).
- `docs/architecture/cortexos-kb-surface-investigation.md` — kb-setup contract preserved verbatim; substrate identified as mmrag.py + ChromaDB + Gemini-embedding chunked vector RAG; investigation paused after kb-setup once substrate-vs-IFOS-data-model mismatch became clear.
- `docs/architecture/second-brain-design.md` — full second-brain design. Q1 cortextOS internal KB use cases inventory; Q1.7 renderer-inheritance investigation (R2 recommended); Q2 vault layout + entity types + 12 operations + Postgres schemas + pgvector + concurrency mechanism; Q3 three options evaluated against eight-criterion rubric, **Option α recommended**. 12 spec gaps surfaced and bucketed.
- `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` — **Accepted Option α** (parallel `packages/brain/bus-overrides/wiki-*.sh` surface; cortextOS KB untouched; §3.1 four-file exception becomes dead clause; v1.2+ semantic-search-over-raw hook left open).

### Day 1 evening extension (this session's commit)

Week-1 prerequisite pulled forward (no Day 2 blocker on Bullhorn commercial conversation tonight; renderer has no external dependencies):

- `docs/architecture/agent-bundle-renderer-design.md` — 5-section renderer design. §1 source-vs-target layout (12-row file mapping); §2 translation contract + R2 commitment (24 cortextOS skills enumerated and excluded; opt-in only via `tools.yaml cortextos_skills:` block) + Concierge worked example (preamble draft, materialised config.json, synthesised .env, hook symlink resolution); §3 six mechanism decisions (`packages/agent-renderer/` with tsup/vitest/commander, manual developer invocation, Option γ for `_shared/` origination, overwrite-no-merge re-render, per-tenant per-agent invocation for v1.0); §4 seven failure modes with exit codes 0-7 and `ESC_RENDERER_FAILED` escalation; §5 integration (marker file `.rendered-by-ifos-renderer` as structural guard against accidental `cortextos-ifos add-agent`, 3 master-brief edits, 4-bucket spec gap consolidation). **22 spec gaps surfaced**.
- `docs/decisions/ADR-003-agent-bundle-renderer.md` — **Accepted** (165 lines, well inside 200-300 target). 4 decisions ratified, 3 master-brief edits authorised. Edits A + B applied this commit; Edit C joins atomic correction commit.
- `docs/build-brief/00-MASTER-BRIEF.md` — Edit A applied (§4.1 line 196: `agent-renderer` added to `packages/` list); Edit B applied (§8.3 lines 631-636: `cortextos-ifos render-agent` step added after merge).

## Week 1 prerequisites — status

**1 of 3 closed:** ADR-003 + design doc (this session).

**2 remaining:**

- **`docs/architecture/vault-concurrency.md`** companion document — resolves Spec gap 2.6 in `second-brain-design.md`. Documents `flock(2)` + Postgres optimistic concurrency + Obsidian `human_editing` debounce + rewrite-backlinks cascade per design §2.6.1-§2.6.3. Lands Week 1-2 so `wiki/lib/concurrency.ts` is reviewable before week-5 multi-agent test. **Owner:** Claude Code, Week 1-2. **Source:** ADR-002.
- **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1 + **`agents/_shared/hook-helpers.sh`** per master brief §8.1 Change 2. Wiki library invokes `hh_decision_*` from `hook-helpers.sh`; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. ADR-003 design §5.2 makes this load-bearing for first production render (Week 4 Diagnostic). **Owner:** Claude Code, Week 1-2.

## Day 4 tightening (this week)

- Postgres table rename `entity_graph` → `entities` + `entity_links` (Spec gap 2.4-B / 3.4-B per design + ADR-002 Edit 3). Lands in Day 4 Postgres provisioning task, NOT in atomic correction commit. ADR-002 authorises.
- `_secrets.env` added to `provision-tenant.sh` vault skeleton (per ADR-003 design §3.3 spec gap §2.1-C resolution). Mode `0600`, owned by `ifos-tenant-{slug}`. Lands in Day 4 Postgres provisioning task.

## Atomic master-brief correction commit (deferred to end of Week 0 / early Week 1)

**Five-edit manifest** confirmed 2026-05-16:

1. **ADR-001 — Master brief §2.4 row 3:** `chokidar watcher` → `FastChecker poll loop` wording correction
2. **ADR-001 — Ultraplan §3.2:** 4-agent pipeline latency reframe ("3-5 seconds end-to-end", no "sub-second handoff" claim)
3. **ADR-002 Edit 1 — Master brief §3.4:** brain-replacement seam wording (shadow → parallel)
4. **ADR-002 Edit 2 — Master brief §5.5:** v1.0 brain build wording (9 wrappers + 9 lib modules + 4 tables + pgvector)
5. **ADR-003 Edit C — Master brief §8:** footnote referencing the renderer + naming `cortextos-ifos add-agent` as NOT the IFOS path

Commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 spec drifts`. Single Codex ratification on Day 7.

**Not in this commit (lands separately):** ADR-002 Edit 3 (Postgres `entity_graph` → `entities` + `entity_links`) at Day 4 Postgres provisioning; ADR-003 Edits A + B already applied in tonight's commit.

## Queued for Codex ratification (Day 7)

Per master brief §10.6 first ratification run — updated count:

1. `docs/architecture/cortexos-primitive-status.md` (the audit document)
2. `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` (Accepted Option A)
3. `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` (Accepted Option α)
4. `docs/architecture/second-brain-design.md` — reference; ADR-002 is the binding artefact
5. `docs/architecture/agent-bundle-renderer-design.md` — reference; ADR-003 is the binding artefact
6. `docs/decisions/ADR-003-agent-bundle-renderer.md` (Accepted)
7. The atomic master-brief correction commit (when it lands, end of Week 0 / early Week 1)
8. The Day 4 Postgres provisioning artefact (with `entities` + `entity_links` split + `_secrets.env` skeleton addition)
9. Plus the remaining Week 0 artefacts (Bullhorn integration path Day 2; sequencing + Brain UI scope Day 3; auto-send safety policy + kill criterion Day 5; vertical schema v0.1 Day 6)

## Stuck

(nothing — Day 1 + evening extension closed cleanly)

## Notes

- Day 0 setup notes: IFOS dashboard credentials in `~/.cortextos/ifos-v2/dashboard.env`, 1Password "IFOS dashboard admin"; personal install undisturbed at `~/.cortextos/default/`
- Day 1 carry-forward for Day 2 (Bullhorn): master brief §3.2 row "Bullhorn, Vincere, Voyager Infinity → first-party MCP at `packages/mcp-connectors/{name}/`" — Bullhorn is NOT behind Composio; first-party MCP server required. OAuth research is the Day 2 critical-path
- Day 1 carry-forward for Day 4 (Postgres): four IFOS tables now specified with schemas in `second-brain-design.md` §2.4.2 (`tenants`, `entities`, `entity_links`, `decision_log`); add `tenant_eval_sets` + `tenant_adapters` per master brief §6 Day 4 line 478; new `_secrets.env` vault file per ADR-003 design §3.3
- Evening extension carry-forward for Week 1 renderer impl: ADR-003 + design doc are the spec; preamble template at `packages/agent-renderer/templates/claude-md-preamble.md` has a draft in design §2.3 to pin verbatim; `_shared/` origination is Option γ (hybrid) with SHA-skip optimisation; non-rendered-target detection is marker file `.rendered-by-ifos-renderer`
