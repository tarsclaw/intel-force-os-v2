# Harvest manifest — what leaves CortexOS, in what form, and when

**Written:** 2026-08-21. **Purpose:** the single list that guarantees nothing of value is lost when CortexOS
freezes. Every asset appears exactly once, with a destination, a phase, and an honest statement of whether it
moves as code, as data, or only as knowledge.

Companion to `SESSION-HANDOFF-cortexos-to-ifos.md` (why) and `ESTATE-DECISIONS-repo-freeze-vps.md` (D1–D4).

**The governing fact:** Phase A builds the harness against a **fixture brain**. It needs no connectors and no
live agency data. So harvest is phased, not big-bang — only rows marked **Phase A** must be resolved before the
new repo starts. Everything else waits for the phase that consumes it.

---

## 1. Needed for Phase A — resolve these before/at WP-0

| # | Asset | Where it is now | Destination | Form |
|---|---|---|---|---|
| A1 | **Action vocabulary — ~20 real action names** | `hh_decision_action(...)` calls across all six bundles | `actions/*.yaml` (founder-authored) | **Knowledge → seeds the six definitions** |
| A2 | **Risk-tier system (green/yellow/orange/red)** | ~160 references across bundles and specs | `packages/authoriser` tier model | **Knowledge → design input** |
| A3 | **Escalation-code catalogue — 82 distinct codes** | `ESC_*` across `agents/`, `docs/`, `packages/` | `docs/registers/escalation-codes.md` | **Data → merge with scaffold file** |
| A4 | **Schema baseline** | `docs/verticals/recruitment/migrations/v0.1→v0.4` (1,848 lines total incl. v0.5) | `migrations/0000_baseline.sql` | **Code, squashed** |
| A5 | **Live Postgres + RLS + tenant data** | Hetzner VPS `178.105.87.24` | unchanged — same server becomes the estate's one Postgres | **Infrastructure, stays put** |
| A6 | **Local dev-DB harness** | `scripts/setup-local-dev-db.sh` + runbook | `scripts/` | **Code, near-verbatim** |

### A1 is the important row

The estate documents repeatedly warn that the six action definitions are "the item most likely to be delegated by
accident," and treat authoring them as a blank-page task for the founder. **It is not a blank page.** CortexOS is
already running a real action ontology, empirically derived from six agents doing real work:

```
accounting_reconciliation_write      bullhorn_activity_log_write
bullhorn_candidate_dedupe            bullhorn_note_append_summary
bullhorn_note_customer_visible       bullhorn_scribe_field_write
concierge_approval_routed            concierge_email_draft
concierge_send_complete              diagnostic_report_render
gmail_outlook_send_to_candidate      linkedin_cache_purge_fail
operator_notify_telegram             validate_gate_a_fail
xero_payment_initiate                xero_reminder_draft_internal
xero_reminder_send_customer          (+ per-agent run_complete markers)
```

Paired with A2's four-band risk tiering (`xero_reminder_draft_internal` is yellow; `xero_reminder_send_customer`
is orange), this is a **working draft of the action ontology the new authoriser needs.** It converts the founder's
authoring task from writing six definitions cold into editing and pruning a list that has already survived contact
with real systems. This is the single highest-value extraction in the manifest and it should be done before WP-2.

---

## 2. Needed for Phase B — do not touch until the phase opens

| # | Asset | Size | Destination |
|---|---|---|---|
| B1 | Bullhorn connector | 1,799 src / 1,125 test | `packages/ingest-connectors/bullhorn` |
| B2 | Granola connector | 1,609 / 681 | `packages/ingest-connectors/granola` |
| B3 | Open Banking connector | 1,051 / 704 | `packages/ingest-connectors/open-banking` |
| B4 | QuickBooks connector | 1,087 / 617 | `packages/ingest-connectors/quickbooks` |
| B5 | Xero connector | 1,045 / 655 | `packages/ingest-connectors/xero` |
| B6 | WorkOS connector | 984 / 399 | `packages/ingest-connectors/workos` |
| B7 | Reed connector | 731 / 295 | `packages/ingest-connectors/reed` |
| B8 | CV-Library connector | 722 / 285 | `packages/ingest-connectors/cv-library` |
| B9 | Companies House connector | 446 / 211 | `packages/ingest-connectors/companies-house` |
| B10 | OAuth dance tooling + runbook | `scripts/oauth-preflight.sh`, `run-oauth-dances.sh`, `docs/operations/oauth-sandbox-app-setup-runbook.md` | `scripts/` |

**9,474 lines of source and 4,972 of tests move wholesale.** These are architecture-neutral — they talk to third-party
APIs and that contract does not change. The hard-won knowledge in them (scope encoding, redirect-URI port matching,
Xero granular scopes) is documented in the runbook and travels with them.

---

## 3. Rebuilt, not moved — the honest rework column

| # | Asset | Size | Fate |
|---|---|---|---|
| C1 | Cash Conductor bundle | 1,413 shell / 262 sql / 506 md | Logic is the spec; rebuilt in TS inside the harness |
| C2 | Concierge bundle | 2,033 / 0 / 578 | as above |
| C3 | Scribe bundle | 2,185 / 0 / 529 | as above |
| C4 | Janitor bundle | 1,863 / 138 / 398 | as above |
| C5 | Sourcing Scout bundle | 1,848 / 0 / 474 | as above |
| C6 | Diagnostic bundle | 789 / 0 / 337 | as above |

~10,100 lines of shell and ~2,800 of specification. **This is real rework, measured in weeks, not a copy.** What
survives is the thinking: Cash Conductor's five-stage reconciliation match (with its `sql/reconciliation-match.sql`
as a directly reusable artefact), the §3.2 chase ladder, the Gate A/B validation rules, and each `agent.md`'s
behavioural spec. Preserve the `sql/` and `agent.md` files verbatim as reference; the shell does not travel.

---

## 4. Discarded

| # | Asset | Size | Why |
|---|---|---|---|
| D1 | `packages/agent-renderer` | 756 src | The bundle→runtime render model is replaced by the three-tool `mcp-seam`. Never successfully ran (all six bundles fail preflight on a missing `config.schema.json`) |
| D2 | `packages/diagnostic-generator` | 1,009 src | Superseded by the same seam change |

**1,765 lines. That is the entire loss column** against ~38,000 lines of source in the repo.

---

## 5. Stays behind as reference (not harvested, not deleted)

`docs/` — 34,525 lines of markdown. Mostly session history, Codex ratification trails, and decision logs specific
to the CortexOS build. The new repo starts a clean `docs/canonical/` estate per MONOREPO §7. **Do not bulk-copy**;
the CortexOS `docs/decisions/` ADR series collides with the IFOS one (`ADR-006` here is `diagnostic-gate-a-hybrid`,
`ADR-004` is `renderer-implementation-deviations`) and merging them would silently corrupt Tier 1.

---

## 6. Completion test

Harvest is complete for a given phase when every row tagged with that phase is either landed in the new repo or
explicitly deferred with a reason recorded here. **Phase A completion = A1–A6 resolved.** CortexOS may not be
retired until every row in §1, §2 and §3 is resolved — target is after thickening pass 2 (WP-12).
