# Current priorities

**Week:** Week 0 (pre-build)
**Today's task:** Day 5 — auto-send safety policy + v1.0 kill criterion per master brief §6 Day 5 (with Day-2 + Day-3 carry-forwards — see Open)
**Most recent close:** Day 4 — Hetzner NBG1 VPS + LUKS + Postgres 16 + RLS gate passed (executed 2026-05-17, see Shipped)

## This week's gate

Clear all seven days of master brief §6 by Sunday. Five-of-five yeses on the
§6 Day 7 single-sentence test gates entry to Week 1.

## Open

- [ ] Day 5: auto-send safety policy + kill criterion. **Day 2 carry-forward:** Concierge's Bullhorn Note auto-send is the sensitive surface (per `bullhorn-integration-path.md` §4.1 + §6.3). **Day 3 carry-forward:** v1.0 kill criterion must reference `sequencing-target.md` §6.6 three failure conditions (Diagnostic doesn't render W3; Janitor Bullhorn auth fails W5; 2× scope-cut activations)
- [ ] Day 6: vertical schema v0.1 (`docs/verticals/recruitment/vertical-schema.yaml`) — 8 core entities per master brief §6 Day 6 line 490
- [ ] Day 7: single-sentence test review + first Codex ratification run

## Operational debts from Day 4 (non-blocking, retrieve when convenient)

Three founder actions deferred from Day 4 close. None block Day 5-7 work. **One is high-priority** (LUKS new-passphrase retrieval before next reboot).

- **(high-priority)** **LUKS new-passphrase retrieval** — `sudo cat /root/.new_luks_passphrase.tmp` → overwrite leaked value in 1Password "IFOS LUKS passphrase" → `sudo rm /root/.new_luks_passphrase.tmp`. **Must be done before next reboot** — without 1Password update, `ifos-unlock` invocations fail because old passphrase already invalidated by Day-4 §11 rotation. Outside `/vault` so recoverable from locked state.
- **ifos_app password retrieval** — `sudo cat /vault/.ifos_app_password.tmp` → save to 1Password "IFOS Postgres ifos_app — production" → `sudo rm`. Not compromised (generated on VPS via Path D, never entered chat context). Any time before agent code starts referencing the password.
- **Hetzner Console snapshot** — Take Snapshot of `ifos-v2-prod-01` labelled `day-4-clean-verified-2026-05-17`. Not blocking — Hetzner weekly auto-backups already enabled. Founder click action.

## Founder commercial conversations queued (Sunday/Monday)

Three named outreach paths from `bullhorn-integration-path.md` §1.3 — flips Sub-decisions A and B from Proposed to Accepted:

- **Bullhorn partnerships team** (`partnerships@bullhorn.com` or named contact if any) — Sub-decision A questions: marketplace partner programme requirement for production tenants? Cost delta at 3-tenant scale? ETA: Sunday outreach, response 2-5 business days
- **Bullhorn developer support** (via `developer.bullhorn.com` portal contact or partnerships rep) — Sub-decision B questions: auth-code flow specifics, sandbox / dev tenant model, per-entity OAuth scope granularity (§3.1-B), refresh-token rotation atomicity. ETA: Monday outreach
- **Design partner #1** (founder runs design-partner conversation 2) — what ATS does pilot #1 use? Sub-decisions A and C scope to that answer. ETA: Sunday

## Shipped

### Day 4 (2026-05-17) — Hetzner VPS + LUKS + Postgres 16 + RLS gate passed

Single execution session, runbook-driven. All 9 sections complete; §7 RLS isolation gate passed all 5 conditions; 22 of 22 §9 automated checks passed.

**Infrastructure landed:**

- Hetzner Cloud VPS `ifos-v2-prod-01` at 178.105.87.24, **Nuremberg (NBG1) — FSN1 unavailable at provisioning, equivalent Schrems II EU zone**. CX22 (2 vCPU, 4 GB RAM, 38.1 GB OS disk) + 50 GB encrypted Block Storage volume `ifos-v2-data-01`.
- Ubuntu 24.04.4 LTS kernel 6.8.0-117-generic (apt upgrade triggered reboot for kernel update; clean 25s downtime).
- SSH hardening: ed25519 key auth only, root login disabled, password auth disabled, `AllowUsers maddox`, UFW (deny in / allow 22+80+443 IPv4+IPv6), fail2ban sshd jail (5 retries / 10 min / 1 h ban).
- LUKS2 volume `/dev/mapper/ifos_data` — aes-xts-plain64, 512-bit key, argon2id KDF, `noauto` per §0.4 Option β. Three bind mounts: `/mnt/ifos_data`, `/vault`, `/var/lib/postgresql`. `ifos-unlock` script at `/usr/local/bin/` (Postgres-tolerant conditional per §4.7 deviation 12).
- Postgres 16.14 + pgvector 0.8.2 on the LUKS volume; data directory on `/dev/mapper/ifos_data`; service `is-enabled: disabled` at boot (LUKS-noauto conflict per §5.2 deviation 14); `ifos-unlock` starts it post-mount.
- pg_dump nightly cron at 02:30 UTC, 14-day retention, manual test passed (26K dump with 83 TOC entries).
- `/vault` git repo baseline with expanded `.gitignore` (secrets + `*.tmp` + vault state paths).

**Schema landed — all 4 tightenings:**

1. **Tightening 1** (ADR-002 Edit 3): `entity_graph` split into `entities` + `entity_links` — verified at `\d entities` + `\d entity_links`, separate tables, foreign-keyed to `tenants` with cascade.
2. **Tightening 2** (ADR-003 §2.1-C): `provision-tenant.sh` installed at `/usr/local/bin/` (1521 bytes, mode 0755, syntax-OK) with `_secrets.env` skeleton (mode 0600 owned by `ifos-tenant-{slug}`).
3. **Tightening 3** (`sequencing-target.md` §5-A): `decision_log_phase_check CHECK (phase = ANY (ARRAY['trigger', 'output', 'action', 'gating_failed', 'agent_handoff']))` — exactly 5 authoritative values, no speculative additions.
4. **Tightening 4** (`vault-concurrency.md` §3.1): `entities.version INT NOT NULL DEFAULT 0` — verified at `\d entities`. Postgres optimistic-concurrency mechanism unblocked for Week-1-2 `wiki/lib/concurrency.ts`.

**RLS gate (the load-bearing security property) PASSED all 5 conditions:**

- Default-deny: no-context query returns 0 ✓
- Own-tenant: INSERT + SELECT count = 1 ✓
- Cross-tenant isolation: switched context returns 0 ✓
- WITH CHECK adversarial: INSERT claiming foreign tenant_slug → `ERROR: new row violates row-level security policy` ✓
- Post-test integrity: own-tenant data unaffected = 1 ✓

Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser which bypasses RLS). RLS + FORCE + `tenant_isolation` policy (USING + WITH CHECK) on all 5 data tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`.

**Path B closure (LUKS rotation):** Founder authorised Path B (passphrase via SSH stdin) for §4.8 ifos-unlock end-to-end test, exposing the passphrase to chat context. Mitigation executed post-§9: `cryptsetup luksChangeKey` with VPS-generated new passphrase + `--test-passphrase` verification confirming OLD rejected, NEW accepted. Leaked passphrase in transcript is cryptographically invalid. New passphrase at `/root/.new_luks_passphrase.tmp` pending founder retrieval.

**State files updated (this commit):**

- `docs/runbooks/day-4-provisioning.md` — frontmatter `status: Executed`, `executed_against_ipv4`, `execution_outcome` populated; full §12 execution log (20 deviations + 8 v1.1 revisions catalogued)
- `docs/RISK-REGISTER.md` — Risk #7 edit count 8 → 9 (Hetzner NBG1 wording); new Risk #8 LUKS manual unlock single-point-of-failure (Low/Medium-High, v1.2+ TPM/key-server mitigation); 2026-05-17 log entry
- `.agents/current-priorities.md` — Day 4 → Shipped; Open updated to Day 5-7; operational debts section added

### Days 1, 1-evening, 2, 3, 3-evening (all 2026-05-16)

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

## Day 4 tightening (landed 2026-05-17, see Shipped)

All four consolidated tightenings applied in §6 + §7 of Day 4 execution. Verified at `\dt` + `\d entities` + `\d decision_log` + `ls -la /usr/local/bin/provision-tenant.sh` + RLS gate pass.

## Atomic master-brief correction commit (deferred to end of Week 0 / early Week 1)

**Nine-edit manifest** — Day-4 execution added Edit 9 (Hetzner NBG1 wording per runbook §0.1 + §12 deviation 3):

1. **ADR-001** — Master brief §2.4 row 3: `chokidar watcher` → `FastChecker poll loop`
2. **ADR-001** — Ultraplan §3.2: 4-agent pipeline latency reframe to "3-5 seconds end-to-end"
3. **ADR-002 Edit 1** — Master brief §3.4: brain-replacement seam wording (shadow → parallel)
4. **ADR-002 Edit 2** — Master brief §5.5: v1.0 brain build wording (9 wrappers + 9 lib modules + 4 tables + pgvector)
5. **ADR-003 Edit C** — Master brief §8: footnote referencing the renderer + naming `cortextos-ifos add-agent` as NOT the IFOS path
6. **Bullhorn decision §6.6** — Master brief §6 Day 2 line 466: OAuth wording (auth-code-against-IFOS-dev-tenant; client_credentials foreclosed)
7. **Sequencing decision §6.8** — Master brief §6 Day 3 line 471: path convention `.agents/decisions/` → `docs/decisions/`
8. **Brain UI scope §4.5** — Master brief §6 Day 3 line 472: three-drift bundled rewrite (path + `kb-*` shadow → `wiki-*` parallel + `/brain` today-view as v1.0 → as v1.1)
9. **Hetzner location (NEW Day 4 2026-05-17)** — Master brief §6 Day 4 line 477 + §10.4: "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations". Verified during Day-4 execution: Hetzner has no UK data centre; NBG1 used because FSN1 was unavailable at provisioning time. Source: Day-4 runbook §0.1 + §12 deviation 3.

Commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Single Codex ratification on Day 7.

**Day-4 Postgres provisioning tightenings landed in §6 of Day-4 execution (separate commit) — not part of the master-brief reconciliation commit.**

## Queued for Codex ratification (Day 7)

Per master brief §10.6 first ratification run — Day 4 added items 11 + 12, now 15:

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
11. **`docs/runbooks/day-4-provisioning.md`** (Reference status pre-execution; Executed status post-execution) — NEW Day 4 morning
12. **Day 4 close commit** — runbook §12 deviation log (20 deviations + 8 v1.1 revisions) + RISK-REGISTER #8 LUKS-unlock-SPOF + state-file updates — NEW Day 4 evening 2026-05-17
13. The atomic master-brief correction commit (9-edit manifest, end of Week 0 / early Week 1)
14. The Day 4 Postgres provisioning artefact (4 consolidated tightenings landed in §6 of Day-4 close commit)
15. Plus the remaining Week 0 artefacts (Day 5 auto-send safety policy + kill criterion; Day 6 vertical schema v0.1)

## Stuck

(nothing — Day 4 closed cleanly with 22/22 verification + RLS gate pass; Sub-decisions A and B Status: Proposed in `bullhorn-integration-path.md` is the intended state pending Sunday/Monday commercial verification; three operational debts from Day 4 listed above are non-blocking founder-convenience items)

## Notes

- Day 0 setup notes: IFOS dashboard credentials in `~/.cortextos/ifos-v2/dashboard.env`, 1Password "IFOS dashboard admin"; personal install undisturbed at `~/.cortextos/default/`
- **Day 2 verified Bullhorn finding** (load-bearing for Week 1-2): Bullhorn public REST API documentation describes **no webhook / subscription / event-stream mechanism** — pull-only model for v1.0. Per-tenant 5-minute polling cycle is the Concierge default. Marketplace-tier subscription verification is a v1.1+ commercial track
- **Day 2 verified Bullhorn finding**: 10-minute access token TTL forced refresh-loop architecture into v1.0 design per `bullhorn-integration-path.md` §4.5. Connector ships with per-agent 8-minute refresh background task; not lazy refresh on 401
- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
- **Day 3 finding**: line 472 has three drifts (path + `kb-*` shadow + v1.0/v1.1 placement) bundled into single 8th atomic-correction edit
- **Day 3 evening finding**: `vault-concurrency.md` surfaces 4th Day-4 tightening (`entities.version` column required for Postgres optimistic-concurrency). Without it, `wiki/lib/concurrency.ts` in Week 1-2 references a column that doesn't exist
- Day 4 carry-forward: ~~four consolidated Postgres tightenings~~ **LANDED 2026-05-17** in §6 of Day-4 execution (see Shipped)
- Day 5 carry-forward: v1.0 kill criterion must reference Day 3 §6.6 three failure conditions + Day 2 §4.1 Concierge Bullhorn Note auto-send sensitivity
- **Day 4 finding (2026-05-17):** Hetzner has no UK data centre — NBG1 used as equivalent. Surfaced as 9th atomic-correction edit. Functionally equivalent: same Hetzner eu-central zone, Schrems II EU jurisdiction, ~25-30ms UK latency.
- **Day 4 LUKS rotation pattern (2026-05-17):** Path B exposure (LUKS passphrase entered chat for ifos-unlock end-to-end test) closed via `cryptsetup luksChangeKey` with VPS-generated new passphrase + `--test-passphrase` verification. Pattern documented in runbook §12 deviation 20. v1.1 runbook revision: investigate paste-once-and-cache helper that doesn't require chat exposure. Lesson: Path A protocol cost (~90s of founder time per interactive step) is the right trade-off vs Path B (chat exposure + post-hoc rotation).
- **Day 4 Path D pattern (2026-05-17):** New protocol for VPS-side credential generation that never enters chat context. Used for ifos_app password in §5.4: `openssl rand -base64 24` on VPS → `/vault/.ifos_app_password.tmp` (LUKS-encrypted, mode 0600) → `CREATE ROLE` via psql stdin heredoc → founder retrieves at convenience. Reusable for future password generation operations.
