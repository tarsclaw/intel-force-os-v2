# Current priorities

**Week:** Week 0 (pre-build)
**Today's task:** Day 4 — Hetzner UK VPS + Postgres 16 + LUKS + RLS isolation test per master brief §6 Day 4 (with **four** consolidated tightenings — see Open)

## This week's gate

Clear all seven days of master brief §6 by Sunday. Five-of-five yeses on the
§6 Day 7 single-sentence test gates entry to Week 1.

## Open

- [ ] Day 4: Hetzner UK VPS + Postgres 16 + LUKS + RLS isolation test per master brief §6 Day 4. **Four consolidated tightenings** per `sequencing-target.md` §6.5 + `vault-concurrency.md` §7 Bucket 3:
  - **Postgres table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (split from `entity_graph` per ADR-002 Edit 3)
  - **`_secrets.env` vault provisioning** in `provision-tenant.sh` skeleton per ADR-003 design §3.3 spec gap §2.1-C (mode `0600`, owned by `ifos-tenant-{slug}`)
  - **`decision_log.phase` enum extension** per `sequencing-target.md` §5-A: `ALTER TABLE decision_log ADD CONSTRAINT decision_log_phase_check CHECK (phase IN ('trigger', 'output', 'action', 'gating_failed', 'agent_handoff'))`
  - **`entities.version` column** per `vault-concurrency.md` §3.1 + §7 Bucket 3 (NEW): `ALTER TABLE entities ADD COLUMN version INT NOT NULL DEFAULT 0` — required for Postgres optimistic-concurrency mechanism per `wiki/lib/concurrency.ts` Week-1-2 implementation
  - **RLS test:** two synthetic tenant roles attempt to read each other's data; kernel-stops-cross-tenant test passes per master brief §6 Day 4 line 479
- [ ] Day 5: auto-send safety policy + kill criterion. **Day 2 carry-forward:** Concierge's Bullhorn Note auto-send is the sensitive surface (per `bullhorn-integration-path.md` §4.1 + §6.3). **Day 3 carry-forward:** v1.0 kill criterion must reference `sequencing-target.md` §6.6 three failure conditions (Diagnostic doesn't render W3; Janitor Bullhorn auth fails W5; 2× scope-cut activations)
- [ ] Day 6: vertical schema v0.1 (`docs/verticals/recruitment/vertical-schema.yaml`) — 8 core entities per master brief §6 Day 6 line 490
- [ ] Day 7: single-sentence test review + first Codex ratification run

## Founder commercial conversations queued (Sunday/Monday)

Three named outreach paths from `bullhorn-integration-path.md` §1.3 — flips Sub-decisions A and B from Proposed to Accepted:

- **Bullhorn partnerships team** (`partnerships@bullhorn.com` or named contact if any) — Sub-decision A questions: marketplace partner programme requirement for production tenants? Cost delta at 3-tenant scale? ETA: Sunday outreach, response 2-5 business days
- **Bullhorn developer support** (via `developer.bullhorn.com` portal contact or partnerships rep) — Sub-decision B questions: auth-code flow specifics, sandbox / dev tenant model, per-entity OAuth scope granularity (§3.1-B), refresh-token rotation atomicity. ETA: Monday outreach
- **Design partner #1** (founder runs design-partner conversation 2) — what ATS does pilot #1 use? Sub-decisions A and C scope to that answer. ETA: Sunday

## Shipped today (Days 1, 1-evening, 2, 3, 3-evening — all 2026-05-16)

### Day 1 main session (commit e0e223f)

- `docs/architecture/cortexos-primitive-status.md` — 7-primitive audit
- `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` — Accepted Option A
- `docs/architecture/cortexos-kb-surface-investigation.md` — kb-setup contract; investigation paused
- `docs/architecture/second-brain-design.md` — 12 spec gaps; Option α recommended
- `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` — Accepted Option α

### Day 1 evening extension (commit 3e73c71)

- `docs/architecture/agent-bundle-renderer-design.md` — 5 sections, 22 spec gaps, R2 commitment
- `docs/decisions/ADR-003-agent-bundle-renderer.md` — Accepted; 4 decisions; 3 master-brief edits authorised
- Master brief §4.1 Edit A applied (`packages/agent-renderer/` added); §8.3 Edit B applied (renderer step in working pattern)

### Day 2 (commit 64cd3af)

- `docs/decisions/bullhorn-integration-path.md` — 505 lines, 7 sections
  - Sub-decision A (marketplace vs direct): **Proposed**
  - Sub-decision B (OAuth flow): **Proposed** (client_credentials foreclosed)
  - Sub-decision C (v1.0 endpoint surface): **Accepted**
  - 10 spec gaps; first verified finding (Bullhorn public REST docs confirm no webhook/subscription mechanism)

### Day 3 (commit 299108d)

- `docs/decisions/sequencing-target.md` — 522 lines, 7 sections. **Accepted** Option Alpha (master brief §8.2 ratified)
- `docs/decisions/brain-ui-scope.md` — 235 lines, 5 sections. **Proposed** pending v1.1 phase

### Day 3 evening (this commit)

- `docs/architecture/vault-concurrency.md` — 455 lines, 7 sections. **Reference document** (no Proposed/Accepted lifecycle):
  - 4 concurrency mechanisms with TypeScript worked examples: `flock(2)` per-entity locks (§2), Postgres optimistic concurrency (§3), Obsidian-aware mtime debounce (§4), rewrite-backlinks cascade (§5)
  - Lock-ordering rule explicit (alphabetical by `entity_id` within `entity_type`, then by `entity_type`) — prevents cascade deadlock
  - flock+Postgres sequencing rule explicit (flock first, Postgres check second, write third)
  - v1.0 filesystem-vs-Postgres atomicity gap honestly documented; v1.2+ write-ahead-log pattern deferred
  - **5 new `ESC_VAULT_*` escalation codes** consolidated for `_shared/hook-helpers.sh` wiring
  - 5 operational defaults named with override semantics
  - Bucket 3 surfaces **1 new Day-4 tightening:** `entities.version` column (4th tightening on Day 4 task)

## Week 1 prerequisites — status

**2 of 3 closed** (was 1 of 3 at Day 3 close):

- **Closed:** ADR-003 + `agent-bundle-renderer-design.md` (Day 1 evening at `3e73c71`).
- **Closed (NEW this commit):** `docs/architecture/vault-concurrency.md` — resolves `second-brain-design.md` Spec gap 2.6. `wiki/lib/concurrency.ts` Week-1-2 implementation now has its reviewable spec.

**1 remaining:**

- `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh` per master brief §8.1 Changes 1 + 2. **Full ESC_* wiring scope now specified across prior documents:**
  - `ESC_BULLHORN_AUTH` per `bullhorn-integration-path.md` §6.1
  - `ESC_RENDERER_FAILED` per `agent-bundle-renderer-design.md` §4.7
  - **5 new `ESC_VAULT_*` codes** per `vault-concurrency.md` §6: `ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_VERSION_MISMATCH`, `ESC_VAULT_HUMAN_EDIT_BLOCKED`, `ESC_VAULT_CASCADE_PARTIAL_FAILURE`, `ESC_VAULT_CASCADE_TIMEOUT`
  - Owner: Claude Code, Week 1-2

**Day 2 added Week-1 prerequisites:** Bullhorn client_id + client_secret obtained via support ticket; IFOS-owned Bullhorn dev tenant provisioned; Bullhorn MCP connector scaffolded at `packages/mcp-connectors/bullhorn/`; refresh-loop implementation per `bullhorn-integration-path.md` §4.5.

**Day 3 added Week-1 prerequisites:** Diagnostic agent bundle authored at `agents/recruitment/diagnostic/` (Week-3 build prerequisite per `sequencing-target.md` §4.1 + §6.2).

**Day 3 evening (this commit) added Week-1-2 prerequisites:** `wiki/lib/concurrency.ts` implementation against `vault-concurrency.md` spec; `entities.version` column on Day 4 (4th tightening).

## Day 4 tightening (this week)

**Four consolidated tightenings** in one Day-4 Postgres provisioning task:

1. **Postgres table rename** `entity_graph` → `entities` + `entity_links` per ADR-002 Edit 3 + `second-brain-design.md` Spec gap 2.4-B
2. **`_secrets.env` vault skeleton** in `provision-tenant.sh` per ADR-003 design Spec gap §2.1-C
3. **`decision_log.phase` enum extension** to include `gating_failed` + `agent_handoff` per `sequencing-target.md` §5-A
4. **`entities.version` column** (NEW Day 3 evening) per `vault-concurrency.md` §3.1: `ALTER TABLE entities ADD COLUMN version INT NOT NULL DEFAULT 0` — required for Postgres optimistic-concurrency mechanism

All four land in Day 4 Postgres provisioning; one atomic provisioning task.

## Atomic master-brief correction commit (deferred to end of Week 0 / early Week 1)

**Eight-edit manifest** — unchanged from Day 3 close (`vault-concurrency.md` is reference synthesis; surfaces no new master-brief drifts):

1. **ADR-001** — Master brief §2.4 row 3: `chokidar watcher` → `FastChecker poll loop`
2. **ADR-001** — Ultraplan §3.2: 4-agent pipeline latency reframe to "3-5 seconds end-to-end"
3. **ADR-002 Edit 1** — Master brief §3.4: brain-replacement seam wording (shadow → parallel)
4. **ADR-002 Edit 2** — Master brief §5.5: v1.0 brain build wording (9 wrappers + 9 lib modules + 4 tables + pgvector)
5. **ADR-003 Edit C** — Master brief §8: footnote referencing the renderer + naming `cortextos-ifos add-agent` as NOT the IFOS path
6. **Bullhorn decision §6.6** — Master brief §6 Day 2 line 466: OAuth wording (auth-code-against-IFOS-dev-tenant; client_credentials foreclosed)
7. **Sequencing decision §6.8** — Master brief §6 Day 3 line 471: path convention `.agents/decisions/` → `docs/decisions/`
8. **Brain UI scope §4.5** — Master brief §6 Day 3 line 472: three-drift bundled rewrite (path + `kb-*` shadow → `wiki-*` parallel + `/brain` today-view as v1.0 → as v1.1)

Commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts`. Single Codex ratification on Day 7.

**Not in this commit (lands separately):** all four Day-4 Postgres provisioning tightenings — entity_graph split + `_secrets.env` skeleton + `decision_log.phase` enum extension + `entities.version` column.

## Queued for Codex ratification (Day 7)

Per master brief §10.6 first ratification run — Day 3 evening added one item, now ~13:

1. `docs/architecture/cortexos-primitive-status.md` (the audit document)
2. `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` (Accepted Option A)
3. `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` (Accepted Option α)
4. `docs/architecture/second-brain-design.md` — reference; ADR-002 is the binding artefact
5. `docs/architecture/agent-bundle-renderer-design.md` — reference; ADR-003 is the binding artefact
6. `docs/decisions/ADR-003-agent-bundle-renderer.md` (Accepted)
7. `docs/decisions/bullhorn-integration-path.md` (Sub-decision C Accepted; A and B Proposed pending commercial)
8. `docs/decisions/sequencing-target.md` (Accepted Option Alpha)
9. `docs/decisions/brain-ui-scope.md` (Proposed pending v1.1 phase)
10. **`docs/architecture/vault-concurrency.md`** (Reference) — NEW Day 3 evening
11. The atomic master-brief correction commit (8-edit manifest, end of Week 0 / early Week 1)
12. The Day 4 Postgres provisioning artefact (4 consolidated tightenings)
13. Plus the remaining Week 0 artefacts (Day 5 auto-send safety policy + kill criterion; Day 6 vertical schema v0.1)

## Stuck

(nothing — Day 3 evening closed cleanly; Sub-decisions A and B Status: Proposed in `bullhorn-integration-path.md` is the intended state pending Sunday/Monday commercial verification)

## Notes

- Day 0 setup notes: IFOS dashboard credentials in `~/.cortextos/ifos-v2/dashboard.env`, 1Password "IFOS dashboard admin"; personal install undisturbed at `~/.cortextos/default/`
- **Day 2 verified Bullhorn finding** (load-bearing for Week 1-2): Bullhorn public REST API documentation describes **no webhook / subscription / event-stream mechanism** — pull-only model for v1.0. Per-tenant 5-minute polling cycle is the Concierge default. Marketplace-tier subscription verification is a v1.1+ commercial track
- **Day 2 verified Bullhorn finding**: 10-minute access token TTL forced refresh-loop architecture into v1.0 design per `bullhorn-integration-path.md` §4.5. Connector ships with per-agent 8-minute refresh background task; not lazy refresh on 401
- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
- **Day 3 finding**: line 472 has three drifts (path + `kb-*` shadow + v1.0/v1.1 placement) bundled into single 8th atomic-correction edit
- **Day 3 evening finding**: `vault-concurrency.md` surfaces 4th Day-4 tightening (`entities.version` column required for Postgres optimistic-concurrency). Without it, `wiki/lib/concurrency.ts` in Week 1-2 references a column that doesn't exist
- Day 4 carry-forward: four consolidated Postgres tightenings (entity_graph split + `_secrets.env` skeleton + `decision_log.phase` enum extension + `entities.version` column) all land in one provisioning task
- Day 5 carry-forward: v1.0 kill criterion must reference Day 3 §6.6 three failure conditions + Day 2 §4.1 Concierge Bullhorn Note auto-send sensitivity
