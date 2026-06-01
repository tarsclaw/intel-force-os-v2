#!/usr/bin/env bash
# Cash Conductor agent — cycle.sh (14-step orchestration)
#
# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
#         full package wiring per agent.md §4).
# Reading order: agent.md §1 (output contract) + §3 (3 outputs) + §4 (this
#         workflow's 14 steps) + §5 (Gate A) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# Invocation modes (per agent.md §2):
#   mode=webhook       — Open Banking / accounting webhook event-driven (primary)
#   mode=daily-sweep   — cron 07:00 UTC: bank-feed catch-up + invoice age scan
#   mode=weekly-report — cron Mon 06:00 UTC: cash-flow report regeneration
#   mode=manual        — ifosctl cash-conductor reconcile|draft-chase|weekly-report
#
# Package dependencies (W4 Day-25/26 scaffolded; v0.1.0 fixture-first):
#   @ifos/xero            — Xero accounting provider
#   @ifos/quickbooks      — QuickBooks accounting provider
#   @ifos/open-banking    — TrueLayer + Plaid UK bank-feed
#   @ifos/companies-house — addressee resolution (cached Bullhorn placement client lookup)
#
# Output contract per agent.md §1 (READ THAT FIRST). Triple write surface:
#   1. Reconciliation rows → accounting system (yellow tier accounting_reconciliation_write)
#   2. Chase drafts → vault + decision_log (yellow xero_reminder_draft_internal;
#      Cash Conductor OWNS the orange xero_reminder_send_customer action_type
#      per autosend-policy.yaml line 263; Concierge handles approval-bridge transport
#      per D1-B Telegram shim — docs/decisions/2026-05-31-d1-founder-decision.md)
#   3. Weekly cash-flow report → /vault/<tenant>/cash-conductor-reports/weekly-<ISO>.md

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: hydrate context + resolve _shared/ helpers
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'cash-conductor/cycle.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'cash-conductor/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=cash-conductor}"

# Resolve _shared/ helpers (rendered location OR repo source-tree fallback —
# 4-candidate chain copied from agents/recruitment/diagnostic/validate.sh per
# the smoke-hotfix pattern landed at commit d7d52c5).
_SHARED_DIR=""
for _candidate in \
  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
  "${IFOS_REPO_ROOT:-}/agents/_shared" \
  "${CTX_AGENT_DIR}/../../_shared" \
  "${CTX_AGENT_DIR}/../_shared" ; do
  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    _SHARED_DIR="${_candidate}"
    break
  fi
done
if [[ -z "${_SHARED_DIR}" ]]; then
  printf 'cycle.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# Mode dispatch (default = manual; tools.yaml capability invocation passes --mode)
MODE="manual"
INVOICE_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)     MODE="${2:-}"; shift 2 ;;
    --invoice)  INVOICE_ARG="${2:-}"; shift 2 ;;
    *)          shift ;;
  esac
done
# INVOICE_ARG: parsed for future per-invoice scoped runs (manual mode); not yet
# consumed by the W4 Day-26 skeleton — wired at W7-8 build slice.
export INVOICE_ARG

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" "cash-conductor mode=${MODE}"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Provider auth refresh (accounting + Open Banking)
# Reference: agent.md §4 Step 1; emits ESC_ACCOUNTING_AUTH /
# ESC_OPEN_BANKING_AUTH / ESC_OPEN_BANKING_TOKEN_AGING (staged) on failure.
# W7-8 wires: @ifos/xero (or quickbooks) refreshTokens +
#             @ifos/open-banking refreshTokens (with getTokenAgeStage check).
# ────────────────────────────────────────────────────────────────────────

# TODO(W7-8): replace this STUB with actual provider refresh calls. Skeleton
# emits the audit row shape that the full implementation will preserve.
hh_decision_output "auth_refresh_complete" "tenant:${CTX_TENANT_SLUG}" \
  "accounting:STUB; open_banking:STUB; token_aging_stage:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Event router (mode-dependent)
# ────────────────────────────────────────────────────────────────────────

case "${MODE}" in
  webhook)        STEPS_TO_RUN="3 4 5 6 7 8 9 10 11 12 14" ;;
  daily-sweep)    STEPS_TO_RUN="3 4 5 6 7 8 9 10 11 14" ;;
  weekly-report)  STEPS_TO_RUN="13 14" ;;
  manual)         STEPS_TO_RUN="3 4 5 6 7 8 9 10 11 14" ;;
  *)              printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
esac
hh_decision_output "mode_routed" "tenant:${CTX_TENANT_SLUG}" \
  "mode:${MODE}; steps_planned:${STEPS_TO_RUN}"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Bank transaction ingest (mode=webhook from Open Banking)
# Reference: agent.md §4 Step 3 + ADR-002 vault/Postgres split.
# W7-8 wires: @ifos/open-banking listTransactionsSince — store in Postgres
#             cash_conductor_transactions (v0.3 schema; applied 2026-05-31).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *3* ]]; then
  # TODO(W7-8): @ifos/open-banking listTransactionsSince(since=last_ingested_at)
  #             → normalise → INSERT INTO cash_conductor_transactions
  hh_decision_output "transactions_ingested" "tenant:${CTX_TENANT_SLUG}" \
    "STUB rows since=STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Invoice register ingest (mode=webhook from accounting OR daily-sweep)
# Reference: agent.md §4 Step 4. W7-8 wires: @ifos/xero or @ifos/quickbooks
# listOpenInvoices → INSERT INTO cash_conductor_invoices.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *4* ]]; then
  # TODO(W7-8): provider-aware (tenant_adapters.config.accounting_provider)
  #             listOpenInvoices → store in Postgres cash_conductor_invoices
  hh_decision_output "invoices_ingested" "tenant:${CTX_TENANT_SLUG}" "STUB rows"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Reconciliation pass (5-stage match algorithm per agent.md §3 Output 1)
# Stage 1-2 auto-write yellow tier; Stage 3 single low-confidence flagged;
# Stage 4 fuzzy multi-candidate → ESC_RECONCILIATION_AMBIGUOUS; Stage 5 unmatched.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *5* ]]; then
  # TODO(W7-8): match algorithm per agent.md §3 stages 1-5. SQL JOIN against
  #             cash_conductor_invoices + cash_conductor_transactions.
  hh_decision_output "reconciliation_pass" "tenant:${CTX_TENANT_SLUG}" \
    "stage1_2:STUB; stage3:STUB; stage4:STUB; stage5:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Reconciliation write (yellow tier per match)
# Reference: agent.md §3 Output 1. W7-8 wires: @ifos/xero writePaymentReceived
# or @ifos/quickbooks writePaymentReceived; atomic per write; rollback on 4xx/5xx.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *6* ]]; then
  # TODO(W7-8): per-match: accounting.writePaymentReceived(...) → emit per write
  # hh_decision_action "accounting_reconciliation_write" "invoice:<id>" payload_hash payload_preview
  # On failure: ESC_ACCOUNTING_WRITE_FAIL via hh_decision_action validate_gate_a_fail
  :
fi

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Chase generation pass (for overdue, unmatched invoices)
# Reference: agent.md §4 Step 7. Read cash_conductor_invoices.last_chase_position
# (v0.3 schema-backed). Position 4 = operator review (no auto-draft).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *7* ]]; then
  # TODO(W7-8): SELECT overdue invoices; determine chase position 1-4 per §3.2;
  #             if position=4 → hh_decision_output "chase_position_4_operator_review" + STOP
  hh_decision_output "chase_pass_complete" "tenant:${CTX_TENANT_SLUG}" "STUB candidates"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 8 — LLM chase-draft generation (per overdue invoice)
# Reference: agent.md §4 Step 8 + §3.2 escalation ladder (position thresholds).
# Voice classifier ≥0.75 for position 1-2; ≥0.80 for position 3.
# Per agent.md §3 line 117: draft body written to VAULT FIRST (ADR-002
# vault/Postgres split); decision_log carries METADATA only (vault_path +
# body_sha256 + voice_score + escalation_position + days_overdue + amount_due).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *8* ]]; then
  # TODO(W7-8): LLM call → write draft body to vault → emit:
  # hh_decision_output "chase_draft_generated" "invoice:<id>" \
  #   "vault_path:<path>; body_sha256:<hash>; escalation_position:<N>; voice_score:<N>; ..."
  :
fi

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Chase-draft validation (Gate A specifics; validate.sh)
# Reference: agent.md §5 (Gate A); §6 ESC mapping.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *9* ]]; then
  # TODO(W7-8): per draft → bash validate.sh <draft_path>; exit on fail.
  :
fi

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Chase-draft queue to Concierge (opens orange-tier approval bridge)
# Reference: agent.md §4 Step 10 + D1-B (2026-05-31 founder decision).
# Cash Conductor OWNS xero_reminder_send_customer action_type per autosend-policy.yaml
# line 263; Concierge handles autosend-bridge-telegram approval routing + transport.
# Drafts-only graceful degradation when autosend-bridge-telegram package absent
# (per agent.md §1 readiness caveat).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *10* ]]; then
  # Emit yellow-tier internal draft row (always)
  # hh_decision_action "xero_reminder_draft_internal" "invoice:<id>" payload_hash payload_preview
  # If autosend-bridge-telegram package PRESENT: emit orange row + route to bridge
  #   hh_decision_action "xero_reminder_send_customer" "invoice:<id>" ...
  # If autosend-bridge-telegram package ABSENT (D1-B not yet shipped):
  #   STOP at drafts-only; log + DO NOT emit orange row
  if [[ -d "${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist" ]]; then
    : # TODO(W7-8): orange-tier emit + bridge call
  else
    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
      "autosend-bridge-telegram package not built — D1-B Concierge W10 ships it; drafts retained in vault for manual consultant pickup"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 11 — (After operator approves) Send execution — orange-tier
# Reference: agent.md §4 Step 11 + D1-B doc §"Implementation surface".
# Cash Conductor receives webhook from Concierge after transport completes;
# updates cash_conductor_invoices.last_chase_position + last_chase_sent_at.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *11* ]]; then
  # TODO(W7-8): webhook-driven; UPDATE cash_conductor_invoices SET ...
  # hh_decision_output "cash_conductor_chase_sent_recorded" "invoice:<id>" "position:<N>; sent_at:<ISO>"
  :
fi

# ────────────────────────────────────────────────────────────────────────
# Step 12 — Re-trigger eligibility check (mode=webhook only)
# Reference: agent.md §4 Step 12. Cancels chase-drafts on race conditions
# (paid-since-draft-but-before-send) → ESC_AUTOSEND_RACE.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *12* ]]; then
  # TODO(W7-8): re-query Step 5 for paid-since detection; ESC_AUTOSEND_RACE
  # hh_decision_output "chase_cancellation_check" "invoice:<id>" "cancelled:<bool>"
  :
fi

# ────────────────────────────────────────────────────────────────────────
# Step 13 — Weekly report assembly (mode=weekly-report; Mondays 06:00 UTC)
# Reference: agent.md §4 Step 13 + §3 Output 3 (6-section Markdown report).
# DSO metric (Gate B tracking) per ULTRAPLAN A4 line 539.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *13* ]]; then
  # TODO(W7-8): SELECT decision_log + cash tables for 7-day window; compute
  # DSO; assemble Markdown; write to /vault/<tenant>/cash-conductor-reports/
  REPORT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/cash-conductor-reports/weekly-$(date -u +%Y-%m-%d).md"
  mkdir -p "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
  printf '# Weekly cash-flow report — STUB\n\nTODO(W7-8): full §3 Output 3 6-section report.\n' > "${REPORT_PATH}" 2>/dev/null || true
  hh_decision_output "weekly_report" "${REPORT_PATH}" \
    "dso_delta_days:STUB; sections:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 14 — Session close
# ────────────────────────────────────────────────────────────────────────

# tenant_adapters.config.cash_conductor_last_run (declared in v0.3 supplement; validated
# by validate_tenant_adapters_config_v0_3 trigger landed 2026-05-31).
# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')

if [[ "${STEPS_TO_RUN}" == *13* ]]; then REPORT_RAN="true"; else REPORT_RAN="false"; fi
hh_decision_action "cash_conductor_run_complete" "session:${CTX_TENANT_SLUG}" "stub-hash" \
  "mode:${MODE}; matches:STUB; chases:STUB; report:${REPORT_RAN}"

exit 0
