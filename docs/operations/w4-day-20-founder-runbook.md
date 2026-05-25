# W4 Day-20 founder runbook — v0.3 migration + bilateral pass

**Date:** 2026-05-25 (Day 20)
**Status:** DRAFT — awaiting founder authorization to execute Steps A & B
**Trigger 2 runway:** DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 20 days
**Authored:** Claude Code session-start, after W3 close

This runbook is the founder-action sequence for the first two W4 priorities.
Read top-to-bottom. Steps A and B are independent; A is recommended first
because B depends on a schema state that A produces.

---

## Step A — Apply v0.3 migration to migration-test tenant (~20 min)

### A.0 — Pre-flight (already done by Claude)

- [x] `scripts/run-v0.3-migration.sh` drafted (NEW; companion to the existing v0.2 runner) — passes `bash -n` syntax check + `shellcheck` clean.
- [x] `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` exists (493 lines, COMMIT-wrapped, ratified at commit `7b4f390`).
- [x] `docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql` rollback exists (101 lines).
- [x] `scripts/run-tenancy-audit.sh` already v0.3-aware (TENANT_TABLES includes the 2 new `cash_conductor_*` tables — extended in commit `d5544a4`).
- [x] Live VPS state confirmed v0.2 (2026-05-23 audit log `logs/tenancy-audit/20260523T133042Z-80608/T1-tables.log` shows 10 tables with `tenant_slug NOT NULL`; both `cash_conductor_*` tables absent).
- [x] `migration-test` tenant row present (verified via pre-flight in `run-live-migration.sh` Day-11+).

### A.1 — Codex-ratify the new wrapper script (~5 min)

**Why:** Per master brief §10.5, "every Postgres migration touching tenant
data" requires Codex ratification. The migration SQL is already RATIFIED
(commit `7b4f390`); the wrapper script is a NEW mechanical runner around
that SQL — borderline ratifiable, but treating it as in-scope is the safe
read of §10.5 (it executes DDL against live data).

Run:

```bash
bash scripts/run-codex-ratification.sh postgres-migration scripts/run-v0.3-migration.sh
```

Expected: `RATIFIED` (script is mechanical wrapper; SQL is already ratified).
If `REJECTED`, fix and re-run.

### A.2 — Dry-run the migration (~3 min)

```bash
bash scripts/run-v0.3-migration.sh --dry-run
```

Expected output:
- ✓ psql + SSH + tunnel + password OK
- ✓ `migration-test` tenant present
- ✓ v0.2 schema present (4 tables)
- ✓ v0.3 tables not yet present (clean migration target)
- "DRY-RUN OK"

If dry-run shows v0.3 tables already present → check whether the migration
was applied in a prior session. The migration uses `IF NOT EXISTS`, so a
re-run is idempotent; but verify nothing else needs to happen.

### A.3 — Live migration (~5 min)

```bash
bash scripts/run-v0.3-migration.sh
```

Founder-input required: `ifos_app` Postgres password from 1Password
("IFOS Postgres ifos_app password").

Expected:
- ✓ 2 new tables created with RLS + FORCE ROW LEVEL SECURITY
- ✓ 2 `tenant_isolation` policies attached
- ✓ v0.2 `validate_voice_scores` trigger removed; `validate_entities_data_v0_3` trigger present
- ✓ `validate_tenant_adapters_config_v0_3` trigger present on `tenant_adapters`
- ✓ `ifos_app` has SELECT/INSERT/UPDATE on both v0.3 tables (no DELETE)
- ✓ audit row written to `decision_log` (`agent_name=_v0_3_migration`, `tenant_slug='ifos-meta'`)
- "V0.3 MIGRATION COMPLETE ✓"

### A.4 — Tenancy audit (~5 min)

```bash
bash scripts/run-tenancy-audit.sh
```

Founder-input required: same password (script does not cache).

Expected: **12/12 invariants pass across 11 tables**.

The 11 tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`, `cash_conductor_transactions`, `cash_conductor_invoices`.

If any FAIL: stop. Capture `logs/tenancy-audit/<session>/*.log` and surface to Claude.

### A.5 — Commit results (~2 min)

```bash
git add scripts/run-v0.3-migration.sh docs/operations/w4-day-20-founder-runbook.md
git commit -m "ops(w4): v0.3 migration wrapper + Day-20 founder runbook"
git push
```

---

## Step B — Bilateral pass on 6 agent.md scaffolds (~60-90 min, founder collaborates)

**Goal:** drive all 6 to RATIFIED. Total residual: **24 findings across 6 agents** (Day-19 latest round).

See companion working doc: `docs/operations/w4-bilateral-pass-6-agent-md.md`.

Pass order:
1. Diagnostic (5 findings) — burns down Trigger 2 runway first
2. Janitor (4 findings) — schema-citation cluster, mechanical
3. Sourcing Scout (3 findings) — fewest residuals
4. Cash Conductor (3 findings) — depends on D1 decision documentation
5. Scribe (5 findings) — Ringover scope question is the only non-mechanical
6. Concierge (4 findings) — depends on Concierge-Gate-A ADR (W4 item #3)

For each finding the bilateral choice is:
- **FIX-IN-PLACE** — small surgical edit, apply now
- **FIX-IN-FOLLOW-UP** — defer to a numbered commit later in W4
- **REJECT-CODEX** — counter-argue with rationale, record in `docs/decisions/codex-disagreement-<date>.md`
- **SCOPE-EXPAND** — finding reveals new ADR-worthy decision (e.g., Concierge-Gate-A)

After each agent's findings are dispositioned: rerun
`bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/<agent>/agent.md`.

Expected: 4-6 of 6 close to RATIFIED in this session; remainder pushed to
next-day with concrete blockers documented.

---

## Step C (deferred to next session) — Future ADR + D1 decision

W4 queue items #3 + #4. Concierge-Gate-A 30-min SLA hybrid ADR is needed
before Concierge agent.md can flip Status to Accepted. D1 founder decision
on autosend orange-tier path blocks Concierge build slice. Both are session
prerequisites for the Concierge bundle render; neither blocks Diagnostic.

---

## Gaps surfaced during prep

1. **No v0.3 wrapper existed.** W4 queue note flagged this (`(or wrapper for v0.2→v0.3 specifically)`). Wrapper now drafted at `scripts/run-v0.3-migration.sh`.
2. **PII purge v0.3 migration (`v0.2-to-v0.3-pii-purge.sql`) is separate** — gated on Founder Decision D3 + SeedLegals advisor input on retention period. NOT part of W4 item #1. Out of scope this session.
3. **v0.3 migration loses v0.2 `validate_voice_scores` trigger by name** — wrapper verifies the rebind explicitly. Rollback restores it via `validate_voice_score_fields()` function which v0.2 left in place.
