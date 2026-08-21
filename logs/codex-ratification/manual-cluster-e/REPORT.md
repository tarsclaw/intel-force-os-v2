# IFOS Week-3 v1.0 Re-Ratification Report — Manual Cluster E

## Round 3 — 2026-05-31

### agents/recruitment/diagnostic/agent.md

RATIFIED
Advisory: `ESC_AUTOSEND_*` and `ESC_VAULT_*` remain negative-scope wildcard mentions, not active unregistered escalation codes.

### agents/recruitment/janitor/agent.md

RATIFIED
Advisory: `ESC_BULLHORN_OAUTH_REVOKED` is explicitly framed as a non-existent removed code, with active revocation handling folded into registered `ESC_BULLHORN_AUTH`.

### agents/recruitment/scribe/agent.md

RATIFIED
Advisory: `ESC_BULLHORN_OAUTH_REVOKED` and `scribe_gate_a_fail` appear only in build-state remediation notes; active runtime references use registered catalogue codes and `validate_gate_a_fail`.

### agents/recruitment/cash-conductor/agent.md

RATIFIED
Advisory: `ESC_RECONCILIATION_LOW_CONFIDENCE` is still unregistered, but both occurrences explicitly frame it as a W4-polish backlog option rather than an active ESC fire.

### agents/recruitment/sourcing-scout/agent.md

RATIFIED
Advisory: `ESC_SOURCING_DNC_FILTER` is explicitly W4-polish backlog; the active v1.0 DNC path logs drops in the shortlist exception list without firing an unregistered code.

### agents/recruitment/concierge/agent.md

RATIFIED
Advisory: Scaffold ratification remains conditional for Accepted status; §10 line 435 correctly keeps ADR-007 ratification as a Proposed → Accepted blocker.

### docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md

RATIFIED
Advisory: Round 2 citation drift is fixed; line 24 now cites Concierge §6 line 326, which is the live `ESC_CONCIERGE_SLA_MISS` row.

### docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml

RATIFIED
Advisory: Round 2 Sourcing Scout R+W drift is fixed; the field-narrowing example now uses Janitor R+W, while Sourcing Scout remains R-only in the entity matrix and amendments.

### docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql

REJECTED

1. Rollback `v0.3-to-v0.2.sql` lines 29-30 select from `cash_conductor_transactions` and `cash_conductor_invoices` before proving those tables exist. This means a second rollback, an already-rolled-back database, or a partial state with either table missing fails before the later `DROP TABLE IF EXISTS` safeguards run. Fix: guard the row-count prompt with `to_regclass(...) IS NOT NULL` checks, or move existence-safe drops before any table reads.

Rejected artefacts: docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql

RATIFIED: 8/9   REJECTED: 1/9

---

## Round 2 — 2026-05-31

### agents/recruitment/diagnostic/agent.md

RATIFIED
Advisory: The wildcard mentions of `ESC_AUTOSEND_*` and `ESC_VAULT_*` are framed as non-use/negative scope, not bare missing-code references.
Advisory: Existing sibling scripts were checked for the cited gate surface; no Composio/AgentMail boundary violation found in the bundle files searched.

### agents/recruitment/janitor/agent.md

RATIFIED
Advisory: The prior `ESC_BULLHORN_OAUTH_REVOKED` concern is now framed as a removed/non-existent code path, while the active Bullhorn auth escalation uses the registered catalogue code.

### agents/recruitment/scribe/agent.md

RATIFIED
Advisory: The `scribe_gate_a_fail` mention is historical rename context only; active action_type usage resolves to registered autosend policy entries.

### agents/recruitment/cash-conductor/agent.md

RATIFIED
Advisory: §1 now states the D1/Concierge-bridge unresolved fallback as drafts-only, so `xero_reminder_send_customer` is no longer overstated as unconditionally v1.0-ready.
Advisory: The `recent_edit` citation now points at the live supplement block including line 729, and `ESC_RECONCILIATION_LOW_CONFIDENCE` is explicitly W4-polish backlog rather than an active bare code.

### agents/recruitment/sourcing-scout/agent.md

RATIFIED
Advisory: `blocked_recipients` citations now point to the live migration allowlist block, and the source-abstraction ADR is no longer misnumbered as ADR-006.
Advisory: `ESC_SOURCING_DNC_FILTER` is explicitly W4-polish backlog, not an active unregistered escalation code.

### agents/recruitment/concierge/agent.md

RATIFIED
Advisory: This remains scaffold-ratified only; §10 line 435 correctly keeps ADR-007 ratification as a Proposed → Accepted blocker.

### docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md

REJECTED

1. Line 24 has citation drift: it claims Concierge `agent.md` §6 line 320 registers `ESC_CONCIERGE_SLA_MISS`, but current Concierge line 320 is `ESC_LIFECYCLE_STATE_UNKNOWN` and `ESC_CONCIERGE_SLA_MISS` is line 326. Fix: change line 24 to cite Concierge `agent.md` §6 line 326.

### docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml

REJECTED

1. Lines 351-356 still use "broader Sourcing Scout R+W" as the field-narrowing example, but the corrected entity matrix now makes Sourcing Scout `candidate` access R-only. Fix: replace the stale example with a live R+W agent such as Scribe, or remove the "broader Sourcing Scout R+W" clause.

### docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql

REJECTED

1. Rollback `v0.3-to-v0.2.sql` line 62 creates `validate_voice_scores` without first dropping an existing trigger of the same name, so rerunning rollback after a partial/previous rollback is not idempotent. Fix: add `DROP TRIGGER IF EXISTS validate_voice_scores ON entities;` immediately before line 62.
2. Forward migration lines 183-201 introduce `set_updated_at()` and two triggers, but rollback lines 42-43 drop only the cash tables and never drops the helper function. Fix: add `DROP FUNCTION IF EXISTS set_updated_at();` after the cash tables are dropped, or rename the helper to a v0.3-owned function and drop that name on rollback.

Rejected artefacts: docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md; docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml; docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql

RATIFIED: 6/9   REJECTED: 3/9

---

## agents/recruitment/diagnostic/agent.md

RATIFIED
Advisory: `bash -n` passes for `validate.sh`, `cycle.sh`, `context.sh`, and `cleanup.sh`; shellcheck was not run in this pass.
Advisory: v0 voice-classifier and PII upstream-unavailable behaviour is honestly documented as warn-only pending W4 polish, so this is accepted as an honest scaffold/full-bundle state rather than a hidden Gate A weakening.

## agents/recruitment/janitor/agent.md

RATIFIED
Advisory: §3 line 68 says "new entries are flagged for catalogue addition" even though the three listed action_types already exist in `agents/_shared/autosend-policy.yaml`; tighten wording at next touch.

## agents/recruitment/scribe/agent.md

RATIFIED
Advisory: §6 lines 273 and 280 cite catalogue line numbers that have drifted after catalogue expansion, but the referenced ESC codes exist and the trigger meanings match; refresh anchors at next touch.

## agents/recruitment/cash-conductor/agent.md

REJECTED

1. Line 372 has citation drift for Cash Conductor `recent_edit` access. It claims `vertical-schema.v0.3-supplement.yaml` line 723 grants Cash Conductor W-only access, but line 723 is a comment and the actual Cash Conductor row is line 729. Fix: change the citation to `vertical-schema.v0.3-supplement.yaml` lines 721-730 or line 729 specifically.

2. Lines 18 and 121 depend on `xero_reminder_send_customer` being Cash Conductor-owned, which is true in `autosend-policy.yaml` line 263, but §8 lines 396 and 405 make the send path depend on a future Concierge autosend bridge. This is acceptable as a dependency, but the output contract should explicitly state the fallback mode from §8 line 406 in the same paragraph so the primary output does not overstate v1.0 readiness. Fix: add "if D1/bridge is unresolved, v1.0 is drafts-only and does not write `xero_reminder_send_customer` rows" to §1.

## agents/recruitment/sourcing-scout/agent.md

REJECTED

1. Lines 7 and 200 cite `migrations/v0.2-to-v0.3.sql` line 397 for `blocked_recipients`, but line 397 is only the allowlist comment; the actual key appears on line 398. Citation drift is a gate failure. Fix: update both citations to line 398 or cite the surrounding allowlist block lines 396-406.

2. Line 372 says "New ADR-006 at W9 build start" even though `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` already exists and the same §10 later has to clarify "new ADR — not the same as ADR-006" at line 396. Fix: replace line 372 with "a new ADR number assigned at authoring time".

## agents/recruitment/concierge/agent.md

RATIFIED
Advisory: §1 line 17 contains duplicated wording "agent-identity email adapter (deferred) deferred"; wording-only cleanup.
Advisory: The artefact is scaffold-ratified only if ADR-007 is separately accepted; §10 correctly keeps ADR-007 ratification as a Proposed → Accepted blocker.

## docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md

REJECTED

1. Lines 21-24 cite current `agents/recruitment/concierge/agent.md` sections with stale line anchors. The referenced Gate A exclusion is now at Concierge lines 280-291 and the SLA workflow is lines 212-222, not ADR-007's cited §5 lines 269-280. Fix: update the references to the current Concierge line ranges.

2. Line 7 says the current Concierge §10 Accepted criteria omits an ADR blocker, but the current Concierge §10 includes the ADR-007 blocker at lines 433-435. This is now a historical finding, not a live state. Fix: reframe line 7 as "the earlier R3 scaffold omitted..." and cite the current closure line 435.

## docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml

REJECTED

1. Lines 421-428 grant Sourcing Scout `R+W` on candidate and contractor, while lines 547-563 explicitly say Sourcing Scout stays R-only and proposed matches live in the shortlist artefact. The same schema cannot define both dispositions. Fix: make §2 `agent_access_matrix.sourcing_scout.candidate` and `.contractor` R-only, or change the later v0_1_entity_access_amendments to match and justify the write surface.

2. Lines 297-299 describe Sourcing Scout writing "proposed-candidate rows" as a v0.3 amendment, contradicting the artefact's later Bullhorn-read-only framing at lines 551-554 and the Sourcing Scout agent contract. Fix: replace "writes proposed-candidate rows" with "writes shortlist artefacts/audit rows, not Bullhorn-backed candidate entities" or add a separate schema-backed proposed_candidate entity/table.

## docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql

REJECTED

1. Lines 102-104 and 161-163 use bare `CREATE POLICY` statements. The migration is not idempotent: re-running it after a partial or successful apply will fail because the policies already exist. Fix: add `DROP POLICY IF EXISTS ...` before each `CREATE POLICY`, or wrap policy creation in an existence-check DO block.

2. Lines 107 and 166 grant only `USAGE` on BIGSERIAL sequences, but the migration skill requires `GRANT USAGE, SELECT ON SEQUENCE ... TO ifos_app`. Fix: grant both `USAGE, SELECT` for `cash_conductor_transactions_id_seq` and `cash_conductor_invoices_id_seq`.

3. Lines 377-380 attach `validate_entities_data_v0_3` to every `entities` row without a `WHEN` clause. The migration skill rejects triggers that validate every entity row rather than restricting to relevant entity_types. Fix: add `WHEN (NEW.entity_type IN ('candidate','contact','brief','placement','opportunity'))`.

4. Lines 62-89 and 113-145 create the two Cash Conductor tables with no `updated_at`/version or audit mutation fields despite granting `UPDATE` to `ifos_app` at lines 106 and 165. This is not an explicit type-skill hard fail, but it weakens auditability for mutable structured state. Fix: add `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()` plus an update trigger, or document why accounting provider audit IDs are sufficient.

RATIFIED: 4/9   REJECTED: 5/9
Rejected artefacts: agents/recruitment/cash-conductor/agent.md; agents/recruitment/sourcing-scout/agent.md; docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md; docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml; docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
