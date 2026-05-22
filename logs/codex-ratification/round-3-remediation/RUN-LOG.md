# Codex Round 3 remediation run log

**Run date:** 2026-05-22
**Purpose:** Grounding log before Round-2 remediation edits. Round 3 is the last automated round under master brief §10.3.

## Context read

- `logs/codex-ratification/round-2-autonomous/SUMMARY.md`
- The 9 Round-2 `REJECTED` output files under `logs/codex-ratification/round-2-autonomous/`
- `docs/operations/codex-round-2-handoff.md` outcome protocol context
- `docs/build-brief/00-MASTER-BRIEF.md` §10.3 ratification loop ceiling
- `docs/architecture/tenancy-invariants.md` T1-T12
- `docs/operations/codex-round-2-remediation-prompt.md`

## The 9 Round-2 rejections and proposed fixes

1. `docs/decisions/bullhorn-integration-path.md`

   Proposed fix quoted from Round-2 output:
   > replace line 95 with the explicit prereq-code-only text from `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` lines 64-70, and state that any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.

2. `docs/decisions/autosend-safety-policy.md`

   Proposed fix quoted from Round-2 output:
   > choose and encode one v1.0 behavior. Either D1-A: mark all orange action_types red in v1.0; D1-B: update §9 to say orange approval is in scope via the bridge; or D1-C: model ad-hoc approval as a named v1.0 tier/policy path with exact helper semantics.

   Proposed fix quoted from Round-2 output:
   > mark first pilot LOI signing blocked until counsel-reviewed language replaces §10, or move the placeholder out of the ratified policy into a non-binding appendix with the blocker tracked in the kill criterion.

   Round-3 handling: founder-decision-bound; annotate only, do not decide D1/D2/D3.

3. `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml`

   Proposed fix quoted from Round-2 output:
   > replace `consrc` with `pg_get_constraintdef(c.oid)` in `v0.1-to-v0.2.sql`, or remove the defensive CHECK probe if the Day-4 schema guarantees no link_type constraint.

   Proposed fix quoted from Round-2 output:
   > either update v0.2 to D3-B now by making text-body purge part of the schema contract, or mark production/pilot use blocked until D2/D3 are resolved and the purge migration/script are executable.

   Round-3 handling: mechanical SQL fix plus founder-decision-bound retention annotation.

4. `scripts/run-tenancy-audit.sh`

   Proposed fix quoted from Round-2 output:
   > wrap the audit-row block in `BEGIN; SET LOCAL ifos.tenant_slug='ifos-meta'; INSERT ...; COMMIT;`, or use a single helper that always emits `BEGIN/COMMIT` around `SET LOCAL` + tenant-data writes.

   Proposed fix quoted from Round-2 output:
   > add a harmless INSERT/ROLLBACK probe without `SET LOCAL` and require it to fail, while keeping the existing SELECT as the T11 read-isolation check.

5. `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`

   Proposed fix quoted from Round-2 output:
   > either update `bullhorn-integration-path.md` line 95 to the exact text proposed here, or amend this disagreement doc to say the sharpening is still pending and the original Codex rejection remains open.

   Proposed fix quoted from Round-2 output:
   > add a small "Gate hierarchy" subsection to the Bullhorn decision that distinguishes Week-1 substrate, Diagnostic W3-4, and Janitor W5 before re-running ratification.

6. `docs/decisions/autosend-approval-bridge-spec.md`

   Proposed fix quoted from Round-2 output:
   > rewrite the mapping table to use the actual cortextOS categories, probably `external-comms` for customer/email/social messages, `financial` for payment reminders if money-moving, and `other` only as an explicit fallback.

   Proposed fix quoted from Round-2 output:
   > add the table to `docs/architecture/tenancy-invariants.md`, `scripts/run-tenancy-audit.sh` `TENANT_TABLES`, and the v0.3 migration acceptance criteria, or explicitly choose SQLite state to avoid a new tenant-data table.

   Round-3 handling: spec-only correction; defer table inventory/script changes to bridge implementation slice because the table does not exist yet.

7. `docs/runbooks/pii-purge-operational-pattern.md`

   Proposed fix quoted from Round-2 output:
   > update the forward migration to `ALTER TABLE recent_edit ALTER COLUMN original_text DROP NOT NULL;` before any purge cron can run, and update the schema supplement so post-purge rows are a first-class shape.

   Proposed fix quoted from Round-2 output:
   > either record a real D3 resolution, or change this runbook to "Proposed 90-day default pending D2/D3" throughout and make production cron deployment blocked.

8. `scripts/ifos-pii-purge.sh`

   Proposed fix quoted from Round-2 output:
   > fix the v0.3 migration first, then keep the script's UPDATE; or change the script to overwrite with a non-PII sentinel value if the column intentionally remains NOT NULL.

   Proposed fix quoted from Round-2 output:
   > wrap the audit row in `BEGIN; SET LOCAL ...; INSERT ...; COMMIT;`, check the `psql` exit code, and fail the cron if the audit row cannot be written.

9. `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql`

   Proposed fix quoted from Round-2 output:
   > add `ALTER TABLE recent_edit ALTER COLUMN original_text DROP NOT NULL;` before the CHECK constraint, and update verification queries to assert `original_text` is nullable after migration.

   Proposed fix quoted from Round-2 output:
   > either implement override reads before ratifying the migration/runbook bundle, or change the migration comment to reserve the JSONB key for a later migration.
