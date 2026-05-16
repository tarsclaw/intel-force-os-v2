# Current priorities

**Week:** Week 0 (pre-build)
**Today's task:** Day 3 — sequencing target + Brain UI scope per master brief §6 Day 3

## This week's gate

Clear all seven days of master brief §6 by Sunday. Five-of-five yeses on the
§6 Day 7 single-sentence test gates entry to Week 1.

## Open

- [ ] Day 3: Confirm or revise Ultraplan §9 "close first 3 pilots fastest" (`.agents/decisions/sequencing-target.md`); Brain UI v1.0 scope decision (`.agents/decisions/brain-ui-scope.md`); hire #1 status one-liner
- [ ] Day 4: Hetzner UK VPS + Postgres 16 + LUKS + RLS isolation test. **Postgres table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (split from `entity_graph` per ADR-002 Edit 3). **Plus:** add `_secrets.env` to `provision-tenant.sh` vault skeleton per ADR-003 design §3.3 spec gap §2.1-C
- [ ] Day 5: auto-send safety policy + kill criterion. **Day 2 carry-forward:** Concierge's Bullhorn Note auto-send is the sensitive surface (per bullhorn-integration-path.md §4.1 + §6.3)
- [ ] Day 6: vertical schema v0.1 (`docs/verticals/recruitment/vertical-schema.yaml`)
- [ ] Day 7: single-sentence test review + first Codex ratification run

## Founder commercial conversations queued (Sunday/Monday)

Three named outreach paths from bullhorn-integration-path.md §1.3 — flips Sub-decisions A and B from Proposed to Accepted:

- **Bullhorn partnerships team** (`partnerships@bullhorn.com` or named contact if any) — Sub-decision A questions: marketplace partner programme requirement for production tenants? Cost delta at 3-tenant scale? ETA: Sunday outreach, response 2-5 business days
- **Bullhorn developer support** (via `developer.bullhorn.com` portal contact or partnerships rep) — Sub-decision B questions: auth-code flow specifics, sandbox / dev tenant model, per-entity OAuth scope granularity (§3.1-B), refresh-token rotation atomicity. ETA: Monday outreach
- **Design partner #1** (founder runs design-partner conversation 2) — what ATS does pilot #1 use? Sub-decisions A and C scope to that answer. ETA: Sunday

## Shipped today (Day 1, Day 1 evening extension, Day 2 — all 2026-05-16)

### Day 1 main session (commit e0e223f)

CortexOS primitive audit + brain-system design:
- `docs/architecture/cortexos-primitive-status.md` — 7-primitive audit
- `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` — Accepted Option A
- `docs/architecture/cortexos-kb-surface-investigation.md` — kb-setup contract; investigation paused
- `docs/architecture/second-brain-design.md` — 12 spec gaps; Option α recommended
- `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` — Accepted Option α

### Day 1 evening extension (commit 3e73c71)

Week-1 prerequisite pulled forward:
- `docs/architecture/agent-bundle-renderer-design.md` — 5 sections, 22 spec gaps, R2 commitment, Concierge worked example
- `docs/decisions/ADR-003-agent-bundle-renderer.md` — Accepted; 4 decisions; 3 master-brief edits authorised
- Master brief §4.1 Edit A applied (`packages/agent-renderer/` added); §8.3 Edit B applied (renderer step in working pattern)

### Day 2 (this commit)

Bullhorn integration path decision document:
- `docs/decisions/bullhorn-integration-path.md` — 505 lines, 7 sections
  - **Sub-decision A** (marketplace vs direct): **Proposed** — direct API for v1.0, marketplace v1.1+; three commercial reduction triggers named
  - **Sub-decision B** (OAuth flow): **Proposed** — auth-code grant for production + IFOS-owned dev tenant; client_credentials foreclosed by Bullhorn docs; four commercial reduction triggers named
  - **Sub-decision C** (v1.0 endpoint surface): **Accepted** — 4 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W); pull-only at v1.0 (Bullhorn public REST docs confirm no webhook/subscription mechanism); refresh-loop architecture for the 10-min access token TTL
  - 10 spec gaps surfaced and bucketed (4 resolved inline, 1 master-brief edit, 6 Week-1 prereqs, 5 operational defaults)

## Week 1 prerequisites — status

**1 of 3 closed:** ADR-003 + design (Day 1 evening extension).

**2 remaining:**
- `docs/architecture/vault-concurrency.md` — companion document; resolves Spec gap 2.6 in `second-brain-design.md`. Owner: Claude Code, Week 1-2.
- `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh` per master brief §8.1 Changes 1 + 2. **Now includes `ESC_BULLHORN_AUTH` wiring** per bullhorn-integration-path.md §6.1. Owner: Claude Code, Week 1-2.

**Day 2 added Week-1 prerequisites:**
- Bullhorn client_id + client_secret obtained via support ticket per bullhorn-integration-path.md §2.2 (commercial action, founder Sunday/Monday)
- IFOS-owned Bullhorn dev tenant provisioned (commercial action, founder Sunday/Monday)
- Bullhorn MCP connector scaffolded at `packages/mcp-connectors/bullhorn/` per bullhorn-integration-path.md §6.1 (Claude Code, Week 1-2)
- Refresh-loop implementation per bullhorn-integration-path.md §4.5 (ships with connector)

## Day 4 tightening (this week)

- Postgres table rename `entity_graph` → `entities` + `entity_links` per ADR-002 Edit 3 + design Spec gap 2.4-B
- `_secrets.env` added to `provision-tenant.sh` vault skeleton per ADR-003 design Spec gap §2.1-C

## Atomic master-brief correction commit (deferred to end of Week 0 / early Week 1)

**Six-edit manifest** — updated Day 2:

1. **ADR-001** — Master brief §2.4 row 3: `chokidar watcher` → `FastChecker poll loop`
2. **ADR-001** — Ultraplan §3.2: 4-agent pipeline latency reframe to "3-5 seconds end-to-end"
3. **ADR-002 Edit 1** — Master brief §3.4: brain-replacement seam wording (shadow → parallel)
4. **ADR-002 Edit 2** — Master brief §5.5: v1.0 brain build wording (9 wrappers + 9 lib modules + 4 tables + pgvector)
5. **ADR-003 Edit C** — Master brief §8: footnote referencing the renderer + naming `cortextos-ifos add-agent` as NOT the IFOS path
6. **Bullhorn decision §6.6 (NEW Day 2)** — Master brief §6 Day 2 line 466: `service-account for dev` → `authorization-code grant against an IFOS-owned Bullhorn dev tenant` (client_credentials foreclosed by Bullhorn OAuth docs)

Commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn decision spec drifts`. Single Codex ratification on Day 7.

**Not in this commit (lands separately):** ADR-002 Edit 3 (Postgres `entity_graph` → `entities` + `entity_links`) + ADR-003 design Spec gap §2.1-C (`_secrets.env` in `provision-tenant.sh`) at Day 4 Postgres provisioning; ADR-003 Edits A + B already applied in evening-extension commit.

## Queued for Codex ratification (Day 7)

Per master brief §10.6 first ratification run — Day 2 added one item, now ~10:

1. `docs/architecture/cortexos-primitive-status.md` (the audit document)
2. `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` (Accepted Option A)
3. `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` (Accepted Option α)
4. `docs/architecture/second-brain-design.md` — reference; ADR-002 is the binding artefact
5. `docs/architecture/agent-bundle-renderer-design.md` — reference; ADR-003 is the binding artefact
6. `docs/decisions/ADR-003-agent-bundle-renderer.md` (Accepted)
7. **`docs/decisions/bullhorn-integration-path.md`** (Sub-decision C Accepted; A and B Proposed pending commercial — flips on Sunday/Monday) — NEW Day 2
8. The atomic master-brief correction commit (when it lands, end of Week 0 / early Week 1) — now 6-edit manifest
9. The Day 4 Postgres provisioning artefact (with `entities` + `entity_links` split + `_secrets.env` skeleton addition)
10. Plus the remaining Week 0 artefacts (sequencing + Brain UI scope Day 3; auto-send safety policy + kill criterion Day 5; vertical schema v0.1 Day 6)

## Stuck

(nothing — Day 2 closed cleanly; Sub-decisions A and B Status: Proposed is the intended state pending commercial verification)

## Notes

- Day 0 setup notes: IFOS dashboard credentials in `~/.cortextos/ifos-v2/dashboard.env`, 1Password "IFOS dashboard admin"; personal install undisturbed at `~/.cortextos/default/`
- **Day 2 verified Bullhorn finding** (load-bearing for Week 1-2): Bullhorn public REST API documentation describes **no webhook / subscription / event-stream mechanism** — pull-only model for v1.0. Per-tenant 5-minute polling cycle is the Concierge default per bullhorn-integration-path.md §4.2. Marketplace-tier subscription verification is a v1.1+ commercial track
- **Day 2 verified Bullhorn finding**: 10-minute access token TTL forced refresh-loop architecture into v1.0 design per §4.5. Connector ships with per-agent 8-minute refresh background task; not lazy refresh on 401
- Day 3 carry-forward: sequencing decision (`.agents/decisions/sequencing-target.md`) interacts with bullhorn-integration-path.md §2.4 Sub-decision A — if first design partner ATS is non-Bullhorn, sequencing target may shift
