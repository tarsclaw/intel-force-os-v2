# Codex Round 2 remediation — autonomous prompt

**Status:** Reference (operations artefact)
**Date:** 2026-05-22 (Day 11 PM — post Round-2 close at `0b32047`)
**Purpose:** Drop-in autonomous prompt that fixes the 6 mechanical rejections from Round 2, flags the 3 founder-decision-bound items explicitly, runs Round 3 ratification on the corrected subset, and commits.

**Pre-flight (founder, 1 min):**

```bash
cd ~/code/CortexOS
codex             # enter interactive mode
```

Paste the prompt below. Walk away for ~3-4 hours. Cost: ~$40-60.

---

## The remediation prompt (paste verbatim)

```
You are running Codex Round 2 remediation for the Intel Force OS (IFOS) codebase.
Your working directory is the IFOS repo root. Round 2 ratification closed at
commit 0b32047 with 17 RATIFIED / 9 REJECTED. This run fixes 6 mechanical
rejections autonomously, flags 3 founder-decision-bound items, runs Round 3
ratification on the corrected subset, and commits.

═══════════════════════════════════════════════════════════════════
BINDING SPECIFICATIONS
═══════════════════════════════════════════════════════════════════

Source-of-truth artefacts to read first:
  1. logs/codex-ratification/round-2-autonomous/SUMMARY.md (the 9 rejections)
  2. logs/codex-ratification/round-2-autonomous/<slug>.output.md (per-item
     fix proposals from Codex Round 2 itself — these are your fix specs)
  3. docs/operations/codex-round-2-handoff.md §6 (outcome classes)
  4. docs/build-brief/00-MASTER-BRIEF.md §10.3 (≤2 round-trip ceiling —
     Round 3 is the last automated round)
  5. docs/architecture/tenancy-invariants.md (the 12 invariants that must
     survive every fix)

═══════════════════════════════════════════════════════════════════
EXECUTION SEQUENCE
═══════════════════════════════════════════════════════════════════

STEP 1 — Read context + create run log (10 min)

mkdir -p logs/codex-ratification/round-3-remediation/

Read SUMMARY.md §1-§6 in full. List each of the 9 rejections in
logs/codex-ratification/round-3-remediation/RUN-LOG.md with the proposed fix
quoted verbatim from the Round-2 output file. This proves grounding before
making changes.

STEP 2 — Fix 6 mechanical rejections autonomously

Per-rejection fix specs follow. Each is concrete and verifiable. Apply them
in this order (foundation first, runtime next, docs last).

  ─────────────────────────────────────────────────────────
  FIX 1 — v0.1-to-v0.2.sql line 231 (pg_constraint.consrc removed in PG 12+)
  ─────────────────────────────────────────────────────────
  File: docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
  Issue: line 231 SELECT consrc INTO existing_check — column removed in PG 12
  Fix: replace `consrc` with `pg_get_constraintdef(c.oid)`
  Verify: grep -n "consrc" docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
          → expect 0 hits after fix

  ─────────────────────────────────────────────────────────
  FIX 2 — v0.2-to-v0.3-pii-purge.sql add DROP NOT NULL before CHECK constraint
  ─────────────────────────────────────────────────────────
  File: docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
  Issue: v0.2 declares original_text NOT NULL; v0.3 adds CHECK requiring
         original_text IS NULL when purged. Migration would fail at first purge.
  Fix: in §1 of the v0.3 migration, add BEFORE the column ADD:

      ALTER TABLE recent_edit ALTER COLUMN original_text DROP NOT NULL;

  And in §3 (the CHECK constraint section), add an explanatory comment:
      -- original_text NOT NULL dropped in §1 to allow purge to set NULL

  Also update v0.3-to-v0.2-pii-purge.sql (rollback) to add:
      ALTER TABLE recent_edit ALTER COLUMN original_text SET NOT NULL;
  as the FIRST step (must run before any data has been purged to NULL).
  Note: if rollback runs after purge has executed, this re-SET will FAIL
  on NULL rows; add a comment warning that rollback requires either
  (a) running BEFORE any purge, or (b) backfilling text from snapshots first.

  Verify: grep -c "ALTER COLUMN original_text DROP NOT NULL" v0.2-to-v0.3-pii-purge.sql
          → expect 1
          grep -c "ALTER COLUMN original_text SET NOT NULL" v0.3-to-v0.2-pii-purge.sql
          → expect 1

  ─────────────────────────────────────────────────────────
  FIX 3 — scripts/ifos-pii-purge.sh transaction wrap + exit code check
  ─────────────────────────────────────────────────────────
  File: scripts/ifos-pii-purge.sh
  Issue 1: SET LOCAL outside BEGIN/COMMIT (audit row write)
  Issue 2: psql exit code not checked
  Fix: wrap the audit row write block in BEGIN; SET LOCAL ...; INSERT ...; COMMIT;
       and capture psql exit code. If non-zero, exit the script with code 2 +
       log to stderr.

  Reference pattern (apply to all psql heredocs in this script):

      audit_sql=$(cat <<EOF
      BEGIN;
      SET LOCAL ifos.tenant_slug='ifos-meta';
      INSERT INTO decision_log (...) VALUES (...);
      COMMIT;
      EOF
      )
      if ! printf '%s\n' "${audit_sql}" | psql ... ; then
        echo "FATAL: audit row write failed" >&2
        exit 2
      fi

  Verify: shellcheck -s bash scripts/ifos-pii-purge.sh → exit 0
          grep -c "BEGIN;" scripts/ifos-pii-purge.sh → expect ≥ 1

  ─────────────────────────────────────────────────────────
  FIX 4 — scripts/run-tenancy-audit.sh transaction wrap + T4 INSERT probe
  ─────────────────────────────────────────────────────────
  File: scripts/run-tenancy-audit.sh
  Issue 1: SET LOCAL audit row outside transaction (lines 524-535)
  Issue 2: T4 test only SELECTs; doesn't probe missing-SET-LOCAL WRITE
  Fix 1: wrap audit row write in BEGIN; SET LOCAL ...; INSERT ...; COMMIT; with
         exit code check (same pattern as Fix 3).
  Fix 2: Add to T4 step an adversarial INSERT/ROLLBACK probe (keep the
         existing SELECT as the T11 read-isolation check):

      # T4 — adversarial: INSERT without SET LOCAL ifos.tenant_slug.
      # Expected: RLS rejects (returns 0 rows affected) OR insert succeeds
      # with NULL tenant_slug then RLS blocks read. Both are safe outcomes.
      _step "T4 — Missing-SET-LOCAL adversarial WRITE"

      T4_WRITE_RESULT=$(_psql_local <<EOF 2>&1
      BEGIN;
      -- DO NOT set ifos.tenant_slug
      INSERT INTO decision_log (tenant_slug, agent_name, phase, payload, created_at)
      VALUES ('rls-probe-tenant', '_t4_probe', 'trigger', '{}'::jsonb, now());
      SELECT count(*) FROM decision_log
        WHERE agent_name='_t4_probe' AND tenant_slug='rls-probe-tenant';
      ROLLBACK;
      EOF
      )

      if echo "${T4_WRITE_RESULT}" | grep -qE "^0\s*$"; then
        _pass "Missing-SET-LOCAL INSERT then SELECT returns 0 rows (RLS structural block)"
      else
        _fail "T4: Missing-SET-LOCAL INSERT path returned ${T4_WRITE_RESULT} rows — possible leak"
      fi

  Verify: shellcheck -s bash scripts/run-tenancy-audit.sh → exit 0
          grep -c "ROLLBACK" scripts/run-tenancy-audit.sh → expect ≥ 1

  ─────────────────────────────────────────────────────────
  FIX 5 — Cross-cutting SET LOCAL fix in 3 runtime helpers
  ─────────────────────────────────────────────────────────
  Per Codex Round-2 SUMMARY.md §5 item 1 (Risk #11): the SET LOCAL outside
  transaction pattern also appears in:
    - agents/_shared/hook-helpers.sh (every decision_log write)
    - agents/_shared/voice-loader.sh (every voice corpus read)
    - scripts/run-codex-ratification.sh (every audit row write)

  These are higher-stakes than the audit scripts because they run on every
  agent invocation. Apply the BEGIN; SET LOCAL; ...; COMMIT; pattern to
  every psql heredoc/string in these 3 files.

  Specifically in hook-helpers.sh::_hh_emit_row: wrap the existing sql
  variable content in BEGIN; ...; COMMIT;.

  Specifically in voice-loader.sh::_vl_psql_query: wrap the wrapped SQL
  similarly.

  Specifically in run-codex-ratification.sh::_write_audit_row: wrap the
  INSERT block.

  Run the existing test suites after the fix:
    bash agents/_shared/tests/test-hook-helpers.sh
    bash agents/_shared/tests/test-voice-loader.sh

  Both should still report 20/20 + 9/9 PASS (the tests run in fallback
  mode so they don't exercise the SET LOCAL path; but they will fail if
  you accidentally broke the JSON output format).

  Verify: shellcheck -s bash agents/_shared/hook-helpers.sh
                              agents/_shared/voice-loader.sh
                              scripts/run-codex-ratification.sh
          → all exit 0

  ─────────────────────────────────────────────────────────
  FIX 6 — bullhorn-integration-path.md line 95 + Gate Hierarchy subsection
  ─────────────────────────────────────────────────────────
  File: docs/decisions/bullhorn-integration-path.md
  Issue: line 95 wording is too broad (allows connector code scaffolding
         pre A+B). Disagreement doc proposed sharpening but it didn't land.
  Fix: replace line 95 with the wording from
       docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
       §"Proposed line 95 sharpening" block. Specifically:

      **Status: Sub-decisions A+B can remain Proposed without blocking
      Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema,
      voice-loader — none of which reference Bullhorn). A+B MUST flip
      to Accepted before Janitor (W5) build starts per
      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
      A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate.

  Then add a new "Gate hierarchy" subsection (per Codex's recommended fix
  in the disagreement-doc rejection):

  ### §X.Y — Gate hierarchy (Day-11 clarification)

  Three distinct gates govern Bullhorn-touching work, in temporal order:

  | Gate | Trigger | Status |
  |---|---|---|
  | Week-1 prereq code | None — substrate is ATS-agnostic | DONE (Phases 1-5 landed Day 8) |
  | Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (sequencing-target §2.1) | Awaits Q1 LOI |
  | Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |

  Pick a §-number that doesn't conflict with existing sections. After the
  edit also update the disagreement doc to mark the source-document
  sharpening as LANDED.

  ─────────────────────────────────────────────────────────
  FIX 7 — codex-disagreement-bullhorn-week-1-gate.md closure update
  ─────────────────────────────────────────────────────────
  File: docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
  Issue: doc said sharpening already shipped; Codex caught that it hadn't.
  Fix: update §5 Founder decision to note the sharpening LANDED in THIS
       remediation commit (refer to the commit SHA as
       <SELF-COMMIT-SHA-WILL-BE-RESOLVED-AT-COMMIT-TIME>; you can use the
       phrase "this commit" since the doc is part of the same atomic
       commit that lands the bullhorn-integration-path.md fix).
       Mark Resolution: Counter-argued + sharpen wording as [x] Incorporated.

  ─────────────────────────────────────────────────────────
  FIX 8 — autosend-approval-bridge-spec.md category mapping rewrite
  ─────────────────────────────────────────────────────────
  File: docs/decisions/autosend-approval-bridge-spec.md
  Issue 1: maps to invented categories (customer_message, email_send,
           state_change) that don't exist in cortextOS ApprovalCategory
  Issue 2: new autosend_approval_mappings table not added to
           tenancy-invariants.md inventory

  Fix 1: rewrite §3.3 category mapping table using actual cortextOS enum
         (from packages/harness/cortextos/src/types/index.ts lines 117-121):
           external-comms | financial | deployment | data-deletion | other

         Proposed mapping:
           bullhorn_note_customer_visible      → external-comms
           gmail_outlook_send_to_candidate     → external-comms
           twilio_sms_send                     → external-comms
           calendar_invite_send                → external-comms
           email_summary_to_customer           → external-comms
           xero_reminder_send_customer         → financial
           diagnostic_email_send               → external-comms
           diagnostic_calendar_invite          → external-comms
           linkedin_inmail_send                → external-comms
           bullhorn_placement_terminate        → data-deletion
            (placement-terminate destroys/closes a placement record;
             arguably "other" but data-deletion captures the destructive
             nature of the action)

  Fix 2: add a §3.2.1 "Tenancy invariants update" subsection naming the
         new autosend_approval_mappings table as the 10th tenant-data
         table. Reference: docs/architecture/tenancy-invariants.md §1
         enumeration. Note that the bridge implementation slice (Week 9)
         must also update tenancy-invariants.md §1 + run-tenancy-audit.sh
         TENANT_TABLES array to include this new table — both are deferred
         to the bridge build, not done in this remediation slice (because
         the bridge doesn't exist yet; only the spec is being corrected).

  ─────────────────────────────────────────────────────────
  FIX 9 — pii-purge-operational-pattern.md mark Proposed pending D3
  ─────────────────────────────────────────────────────────
  File: docs/runbooks/pii-purge-operational-pattern.md
  Issue 1: incompatible with NOT NULL schema — addressed by FIX 2
  Issue 2: D3 not actually confirmed yet
  Fix: update §2 "Default retention window" to make the 90-day default
       explicitly "Proposed pending D2/D3 advisor confirmation" rather
       than "v1.0 default confirmed by Founder Decision D3".

       Also update §11 pre-deployment checklist to make explicit:
         - D2 SeedLegals advisor input required BEFORE applying migration
         - D3 founder confirmation required BEFORE first cron run

       Status field in §12 stays "Proposed" (already correct).

STEP 3 — Flag 3 founder-decision-bound items (DO NOT FIX)

For these 3 items, write a brief annotation in the artefact file
explaining what the founder decision unblocks. Do NOT change the artefact
content beyond the annotation.

  ─────────────────────────────────────────────────────────
  FLAG 1 — autosend-safety-policy.md tier contradiction
  ─────────────────────────────────────────────────────────
  Add to §1 "Scope" subsection a closing paragraph:

  > **Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0
  > tier semantics in this document define orange as approval-gated. §9
  > says v1.0 ships green + red only. These are contradictory until D1
  > resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-
  > decisions.md` §D1 for options + Claude's recommended path (D1-B with
  > the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`).
  > Until D1 resolves, treat this policy as "Proposed for D1-B; subset
  > In Force for green + red only".

  ─────────────────────────────────────────────────────────
  FLAG 2 — autosend-safety-policy.md legal placeholder
  ─────────────────────────────────────────────────────────
  Add to §10 (the legal placeholder section) a closing paragraph:

  > **Founder Decision D2 + D3 pending (Codex Round 2 rejection).** This
  > section is non-binding placeholder language. First pilot LOI signing
  > is BLOCKED until counsel-reviewed language replaces this section. See
  > `docs/operations/seedlegals-engagement-queries.md` for the founder's
  > engagement queries + `docs/decisions/2026-05-20-codex-round-1-
  > founder-decisions.md` §D2 + §D3 for the founder decision framing.

  ─────────────────────────────────────────────────────────
  FLAG 3 — vertical-schema.v0.2-supplement.yaml indefinite retention
  ─────────────────────────────────────────────────────────
  In §6 Q13 (the PII retention open question), update the v0_2_default
  field from "A (Indefinite retention)" to:

  v0_2_default: |
    Pending D2/D3 resolution. v0.2 ships with text fields stored verbatim
    but production deployment + first pilot LOI BLOCKED until D2 SeedLegals
    advisor input + D3 founder decision land. Recommended default per
    Claude analysis: D3-B (90-day text purge + indefinite metadata) with
    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
    Implementation pre-written: scripts/ifos-pii-purge.sh +
    docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql (post
    Round-2 remediation fix).

STEP 4 — Update tenancy-invariants.md (auxiliary)

If FIX 2 added DROP NOT NULL to recent_edit.original_text, the invariant
T11 (RLS structural block) is unaffected but the column nullability is
now a new invariant. Update docs/architecture/tenancy-invariants.md §2 T1
to note:

  Subtle case: recent_edit.original_text was originally TEXT NOT NULL in
  v0.2; v0.3 (post Round-2 remediation) drops the NOT NULL to allow
  PII purge to set NULL. Tenant_slug remains NOT NULL on this table.

Also add to §6 (Open questions) a new entry:

  Q5: When autosend_approval_mappings ships in v0.3 with the bridge
  implementation (per docs/decisions/autosend-approval-bridge-spec.md),
  must T1-T3 + T11 + T12 update the table inventory + audit script?
  Resolution path: bridge implementation slice (Week 9) updates §2
  enumeration AND scripts/run-tenancy-audit.sh TENANT_TABLES array.

STEP 5 — Add Risk #11 + #12 to RISK-REGISTER

Per Codex Round-2 SUMMARY.md §6, add two new risks to
docs/RISK-REGISTER.md. Follow the existing Day-1-surfaced-risks table
shape.

Risk #11: Transactionless SET LOCAL usage in runtime helpers + scripts
  Probability: High (pre-remediation); → Low post-remediation
  Impact: High (silent RLS bypass or audit-row failure under load)
  Tripwire: any psql call with SET LOCAL not bracketed by BEGIN/COMMIT
  Mitigation: FIX 3-5 of this remediation wraps every SET LOCAL in a
              transaction. Verify post-remediation by re-running 29 tests.
  Status: Mitigated in this commit; verify after Round 3 close.

Risk #12: PII purge cannot execute against current schema
  Probability: ~~High~~ → Low post-remediation
  Impact: ~~High~~ → Low (production cron would have failed at first run)
  Tripwire: v0.2-to-v0.3-pii-purge.sql executed without DROP NOT NULL
  Mitigation: FIX 2 of this remediation adds ALTER COLUMN DROP NOT NULL
              before the CHECK constraint.
  Status: Mitigated in this commit; remains pending D2/D3 founder
          decisions before production deployment.

Also add a 2026-05-22 update-log entry summarising the remediation +
Round-3 verdict.

STEP 6 — Run Round 3 ratification on the 7 corrected items

For each of the 7 items fixed in Step 2 + Step 4, re-ratify against the
appropriate skill:

  Apply review-architecture-decision:
    - bullhorn-integration-path.md  (FIX 6)
    - codex-disagreement-bullhorn-week-1-gate.md  (FIX 7)
    - autosend-approval-bridge-spec.md  (FIX 8)
    - pii-purge-operational-pattern.md  (FIX 9)
    - tenancy-invariants.md  (STEP 4 update)

  Apply review-postgres-migration:
    - v0.1-to-v0.2.sql  (FIX 1)
    - v0.2-to-v0.3-pii-purge.sql  (FIX 2)

  Apply review-architecture-decision (script-as-artefact):
    - ifos-pii-purge.sh  (FIX 3)
    - run-tenancy-audit.sh  (FIX 4)
    - hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh  (FIX 5)

Write each Round-3 verdict to:
  logs/codex-ratification/round-3-remediation/<slug>.output.md

Per master brief §10.3 step 5: Round 3 is the LAST automated round.
Anything REJECTED at Round 3 escalates to founder.

For the 3 founder-decision-bound items (FLAG 1, 2, 3):
  Do NOT include in Round 3 ratification. They're explicitly pending
  founder input. Mark their manifest status as "Founder-escalated pending
  D1 / D2 / D3" rather than RATIFIED/REJECTED.

STEP 7 — Write SUMMARY.md

logs/codex-ratification/round-3-remediation/SUMMARY.md

Required sections:
  §1 Headline counts (X RATIFIED / Y REJECTED of N items in Round 3)
  §2 Per-fix verification table:
     Fix # | File | Verification command | Result
  §3 Per-item Round-3 verdicts table:
     Item | Round-2 verdict | Round-3 verdict | Notes
  §4 Founder-escalated items (the 3 flagged):
     Item | Decision required | Path to resolution
  §5 Cross-cutting verification:
     - All shellcheck runs clean (scripts/*.sh + agents/_shared/*.sh)
     - All test suites still pass (hook-helpers 20/20 + voice-loader 9/9 +
       renderer 30/30)
     - No new lint warnings
  §6 Hard-ceiling check:
     Per master brief §10.3, this is the last automated round. Confirm
     any remaining REJECTED items are escalated to founder explicitly.

STEP 8 — Update Codex manifest queue

Edit docs/decisions/2026-05-18-codex-ratification-manifest.md.

Add §1.8 "Codex Round 3 remediation verdicts (2026-05-22)" mirroring
§1.7 shape. Per-item Round-3 verdict + disposition.

For Round-2 REJECTED items that flipped to RATIFIED:
  Disposition: "Mechanical remediation incorporated at <SHA>; Round-3
                RATIFIED."

For Round-2 REJECTED items that became FLAG 1/2/3 founder escalations:
  Disposition: "Founder-escalated pending D1 / D2 / D3."

Update the headline totals at the top of §1 to reflect final state.

STEP 9 — Update state files

.agents/current-priorities.md:
  - Today's task → "Round-2 remediation closed at <SHA>"
  - Add Day-11 evening Shipped section for the remediation work
  - Update backlog: R15 + R16 marked closed; D1+D2+D3 elevated to "blocks
    next-step founder action"

docs/RISK-REGISTER.md:
  - Step 5 already added Risk #11 + #12; update their status to
    "Mitigated post-commit; awaiting Round-3 verification"
  - 2026-05-22 update-log entry

STEP 10 — Commit + push (single atomic commit)

Stage everything: the 6 mechanical fixes + 3 founder-decision annotations +
auxiliary updates (tenancy-invariants + RISK-REGISTER) + Round-3 logs +
manifest + state files.

git add agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh \
        docs/decisions/autosend-approval-bridge-spec.md \
        docs/decisions/autosend-safety-policy.md \
        docs/decisions/bullhorn-integration-path.md \
        docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md \
        docs/runbooks/pii-purge-operational-pattern.md \
        docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql \
        docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql \
        docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql \
        docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml \
        docs/architecture/tenancy-invariants.md \
        scripts/ifos-pii-purge.sh \
        scripts/run-tenancy-audit.sh \
        scripts/run-codex-ratification.sh \
        docs/decisions/2026-05-18-codex-ratification-manifest.md \
        .agents/current-priorities.md \
        docs/RISK-REGISTER.md \
        logs/codex-ratification/round-3-remediation/

Commit message (HEREDOC):

  fix(codex-round-2-remediation): 6 mechanical fixes + 3 founder-escalated + Round 3

  Closes Codex Round-2 rejection set (9 items from manifest §1.7).
  6 mechanical fixes incorporated + verified; 3 items founder-escalated
  pending D1 / D2 / D3.

  Mechanical fixes (autonomous, this commit):
    - v0.1-to-v0.2.sql: consrc → pg_get_constraintdef (PG 12+ compat)
    - v0.2-to-v0.3-pii-purge.sql: ALTER COLUMN DROP NOT NULL before CHECK
    - ifos-pii-purge.sh: BEGIN/COMMIT wrap + exit code check
    - run-tenancy-audit.sh: BEGIN/COMMIT wrap + T4 INSERT/ROLLBACK probe
    - hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh:
      BEGIN/COMMIT wrap on every SET LOCAL psql call (Risk #11 mitigation)
    - bullhorn-integration-path.md: line 95 sharpened + Gate hierarchy
      subsection added (matches disagreement doc spec)
    - codex-disagreement-bullhorn-week-1-gate.md: closure update marking
      source-doc sharpening LANDED in this commit
    - autosend-approval-bridge-spec.md: category mapping rewritten using
      actual cortextOS enum (external-comms | financial | deployment |
      data-deletion | other)
    - pii-purge-operational-pattern.md: marked Proposed pending D2/D3

  Founder-escalated (annotations only, no content fix):
    - autosend-safety-policy.md §1 + §10: D1 + D2/D3 blocker annotations
    - vertical-schema.v0.2-supplement.yaml §6 Q13: indefinite retention
      blocked pending D2/D3

  Auxiliary:
    - tenancy-invariants.md §2 T1: recent_edit.original_text nullability
      subtle case + §6 Q5 autosend_approval_mappings table inventory
    - RISK-REGISTER: Risk #11 (SET LOCAL discipline) + Risk #12 (PII
      purge schema) added; both marked Mitigated post-commit

  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
  re-ratified; <X> RATIFIED / <Y> REJECTED. Full report at
  logs/codex-ratification/round-3-remediation/SUMMARY.md.

  Manifest §1.8 appended with Round-3 verdicts + dispositions.

  Co-Authored-By: Codex (gpt-5-codex)

Then: git push origin main

STEP 11 — Final status to stdout

  ═══════════════════════════════════════════════════════════════════
  CODEX ROUND 2 REMEDIATION COMPLETE — <timestamp>
  ═══════════════════════════════════════════════════════════════════

  Mechanical fixes applied: 9 across X files
  Founder-escalated: 3 items (D1, D2+D3 bundle)

  Round 3 ratification: <X> RATIFIED / <Y> REJECTED of 10 corrected items
  Commit: <SHA>
  Pushed to: origin/main

  REMAINING FOUNDER ACTION:
  - Resolve D1 autosend orange-tier v1.0 path
  - Engage SeedLegals (D2 + D3 bundle)
  - Apply D3-confirmed retention to scripts/ifos-pii-purge.sh
    (no schema work needed — Fix 2 already cleared the path)

  Next: bash scripts/run-live-migration.sh --dry-run
        (Risk #11 + #12 now mitigated; migration safe to dry-run)

  ═══════════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════════
AUTONOMOUS-EXECUTION RULES (same as Round 2 prompt + additions)
═══════════════════════════════════════════════════════════════════

1. DO NOT stop and ask for clarification mid-run.

2. DO modify artefact files this time. (Different from Round 2 prompt.)
   But ONLY make the fixes named in this prompt. Do NOT make additional
   "improvements" or refactors. Conservative scope.

3. For ambiguity in a fix (e.g., "where to put Gate hierarchy section"):
   pick the cleanest placement + note your choice in SUMMARY.md §2.

4. For founder-decision-bound items (FLAG 1, 2, 3): ANNOTATE only.
   Do NOT make founder decisions. Do NOT change content beyond the
   annotation paragraph.

5. After each FIX completes, run the verification command named.
   If verification fails, retry the fix once. If second attempt fails,
   log it in SUMMARY.md §2 + continue to next fix.

6. Run shellcheck after every shell script edit. If shellcheck regresses
   (new warnings vs baseline), retry the edit; if persistent, document
   in SUMMARY.md §2.

7. Re-run agents/_shared/tests/test-hook-helpers.sh + test-voice-loader.sh
   AFTER editing those scripts. Both must still report PASS counts
   matching pre-edit baseline (20/20 + 9/9).

8. Final commit + push at Step 10 is atomic — all fixes + escalations
   + Round 3 + state files + manifest in ONE commit. If anything fails
   mid-pipeline, log it + still commit the partial state with explicit
   "PARTIAL" prefix in the commit message.

9. DO NOT run scripts that need live VPS credentials:
   - scripts/run-live-migration.sh
   - scripts/run-tenancy-audit.sh (against live VPS — local fallback fine)
   - scripts/ifos-pii-purge.sh (production cron only)
   These remain founder Path-A actions.

═══════════════════════════════════════════════════════════════════
BEGIN NOW
═══════════════════════════════════════════════════════════════════

Start with Step 1 (read SUMMARY.md + Round-2 output files + create RUN-LOG.md).
Confirm grounding by listing the 9 rejections + proposed fixes in your
RUN-LOG before making any code changes. Then proceed through Steps 2-11
without pausing for founder input.

Expected runtime: 3-4 hours. The founder is walking away during the run.

Begin.
```

---

## What this prompt produces

**6 mechanical fixes (autonomous):**
1. v0.1-to-v0.2.sql `consrc` → `pg_get_constraintdef`
2. v0.2-to-v0.3-pii-purge.sql + `ALTER COLUMN DROP NOT NULL`
3. ifos-pii-purge.sh transaction wrapping + exit code check
4. run-tenancy-audit.sh transaction wrapping + T4 INSERT/ROLLBACK probe
5. hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh transaction wrapping (Risk #11 mitigation across all runtime helpers)
6. bullhorn-integration-path.md line 95 sharpening + Gate hierarchy subsection + disagreement doc closure + autosend-approval-bridge-spec.md category mapping rewrite + pii-purge-operational-pattern.md "Proposed pending D3"

**3 founder-decision-bound flags (annotations only):**
- FLAG 1: autosend-safety-policy.md §1 D1 annotation
- FLAG 2: autosend-safety-policy.md §10 D2+D3 annotation
- FLAG 3: vertical-schema.v0.2-supplement.yaml §6 Q13 indefinite-retention block

**Auxiliary updates:**
- tenancy-invariants.md §2 T1 (nullability subtle case) + §6 Q5 (autosend_approval_mappings inventory)
- RISK-REGISTER #11 + #12 added + marked Mitigated post-commit

**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.

**Single atomic commit** with everything bundled.

## What it doesn't do

- Touch the 3 founder-decision-bound items beyond annotations (D1 needs you; D2/D3 bundle waits on SeedLegals)
- Run live VPS scripts (Path A founder-only)
- Make any architectural decisions

## After Codex finishes

When you return:

1. Read `logs/codex-ratification/round-3-remediation/SUMMARY.md`
2. Verify the commit on `origin/main`
3. If Round 3 returns 10/10 RATIFIED → foundation is fully ratified except for the 3 founder decisions
4. If any item still REJECTED at Round 3 → that's the hard-ceiling escalation; you decide directly

Cost: ~$40-60 OpenAI + ~3-4h Codex runtime + 0h founder time during the run + ~20 min review post-run.

*End of remediation prompt.*
