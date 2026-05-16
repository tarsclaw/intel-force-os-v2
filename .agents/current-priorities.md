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
- [ ] Day 4: Hetzner UK VPS + Postgres 16 + LUKS + RLS isolation test. **Postgres table list updated:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (split from `entity_graph` per ADR-002 Edit 3)
- [ ] Day 5: auto-send safety policy + kill criterion
- [ ] Day 6: vertical schema v0.1 (`docs/verticals/recruitment/vertical-schema.yaml`)
- [ ] Day 7: single-sentence test review + first Codex ratification run

## Shipped today (Day 1, 2026-05-16)

CortexOS primitive audit + brain-system design decisions, all artefacts ratifiable for Day 7:

- `docs/architecture/cortexos-primitive-status.md` — 7-primitive audit against SHA `c21fbfe`, with `shipped and tested` / `shipped but flaky` / `aspirational` classifications, IFOS dependency mapping per v1.0 agent, and concrete verification commands. Two master-brief drifts surfaced (chokidar, kb-* filenames).
- `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` — **Accepted Option A** (accept the 3-5 second pipeline floor; rewrite Ultraplan §3.2; do not tune `pollInterval`).
- `docs/architecture/cortexos-kb-surface-investigation.md` — kb-setup contract preserved verbatim; substrate identified as mmrag.py + ChromaDB + Gemini-embedding chunked vector RAG; investigation paused after kb-setup once substrate-vs-IFOS-data-model mismatch became clear.
- `docs/architecture/second-brain-design.md` — full second-brain design. Q1 cortextOS internal KB use cases inventory; Q1.7 renderer-inheritance investigation (R2 recommended); Q2 vault layout + entity types + 12 operations + Postgres schemas + pgvector + concurrency mechanism; Q3 three options evaluated against eight-criterion rubric, **Option α recommended**. 12 spec gaps surfaced and bucketed (resolved inline / master-brief edits / Week 1 prerequisites / operational defaults).
- `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` — **Accepted Option α** (parallel `packages/brain/bus-overrides/wiki-*.sh` surface; cortextOS KB untouched; §3.1 four-file exception becomes dead clause; v1.2+ semantic-search-over-raw hook left open).

## Week 1 prerequisites flagged from Day 1 design work

Tracked for sequencing — NOT on Day 2's plate.

- **ADR-003 + `docs/architecture/agent-bundle-renderer-design.md`** (resolves Spec gap §1.7-A). Design recommends R2 (bundle-only, no `.claude/skills/` inheritance). Without it, no IFOS agent can run because the daemon's `AgentManager.discoverAndStart()` reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/`. **Owner:** founder + Claude Code, Week 1.
- **`docs/architecture/vault-concurrency.md`** companion document (resolves Spec gap 2.6). Documents `flock(2)` + Postgres optimistic concurrency + Obsidian `human_editing` debounce + rewrite-backlinks cascade per design §2.6.1-§2.6.3. Lands Week 1-2 so `wiki/lib/concurrency.ts` is reviewable before week-5 multi-agent test. **Owner:** Claude Code, Week 1-2.
- **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1 + **`agents/_shared/hook-helpers.sh`** per master brief §8.1 Change 2. Wiki library calls `hh_decision_*` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. **Owner:** Claude Code, Week 1-2.

## Day 4 tightening (this week)

- Postgres table rename `entity_graph` → `entities` + `entity_links` (Spec gap 2.4-B / 3.4-B per design doc + ADR-002 Edit 3). Lands in Day 4 Postgres provisioning task, NOT in the atomic correction commit. ADR-002 authorises it.

## Atomic master-brief correction commit (deferred to end of Week 0 or early Week 1)

Bundles:
- ADR-001 §2.4 row 3: `chokidar watcher` → `FastChecker poll loop` wording correction
- ADR-001 + Ultraplan §3.2: 4-agent pipeline latency reframe ("3-5 seconds end-to-end", no "sub-second handoff" claim)
- ADR-002 Edit 1: master brief §3.4 brain-replacement seam wording (shadow → parallel)
- ADR-002 Edit 2: master brief §5.5 v1.0 brain build wording (9 wrappers + 9 lib modules + 4 tables + pgvector)

Single commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 spec drifts`. Single Codex ratification on Day 7.

## Queued for Codex ratification (Day 7)

Per master brief §10.6 first ratification run:

1. `docs/architecture/cortexos-primitive-status.md` (the audit document)
2. `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` (Accepted Option A)
3. `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` (Accepted Option α)
4. `docs/architecture/second-brain-design.md` — design doc is reference; ADR-002 is the binding artefact. Codex review can scope to the §3.3 recommendation rationale + §3.4 build sequence impact + 12-gap consolidated table.
5. The atomic master-brief correction commit (when it lands)
6. The Day 4 Postgres provisioning artefact (with `entity_graph` → `entities` + `entity_links` split)
7. Plus the remaining seven Week 0 artefacts (Bullhorn integration path Day 2; sequencing + Brain UI scope Day 3; auto-send safety policy + kill criterion Day 5; vertical schema v0.1 Day 6)

## Stuck

(nothing — Day 1 closed cleanly)

## Notes

- Day 0 setup notes: IFOS dashboard credentials in `~/.cortextos/ifos-v2/dashboard.env`, 1Password "IFOS dashboard admin"; personal install undisturbed at `~/.cortextos/default/`
- Day-1 carry-forward useful for Day 2 (Bullhorn): master brief §3.2 row "Bullhorn, Vincere, Voyager Infinity → first-party MCP at `packages/mcp-connectors/{name}/`" — Bullhorn is NOT behind Composio; first-party MCP server required. OAuth research is the Day 2 critical-path
- Day-1 carry-forward for Day 4 (Postgres): four IFOS tables now specified with schemas in design §2.4.2 (`tenants`, `entities`, `entity_links`, `decision_log`). Add `tenant_eval_sets` + `tenant_adapters` per master brief §6 Day 4 line 478
