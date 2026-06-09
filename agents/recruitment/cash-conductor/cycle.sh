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

# W7 LIVE: refresh accounting (xero|quickbooks) + Open Banking tokens via the
# connector CLI bins (node dist/cli.js refresh). Path A: creds sourced into env
# from the tenant/sandbox _secrets.env (never cat'd); the CLIs read process.env +
# on-disk token bundles and print JSON {ok,...} — never a token value.
# Defensive defaults (context.sh exports these in the harness; cycle.sh must not
# crash under set -u if run standalone — mirrors the v1.0 single-provider default).
: "${CTX_ACCOUNTING_PROVIDER:=xero}"
: "${CTX_OPEN_BANKING_PROVIDER:=truelayer}"
_CC_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
if [[ -z "${_CC_CONN_BASE}" || ! -d "${_CC_CONN_BASE}" ]]; then
  _CC_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
fi
_CC_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
if [[ -f "${_CC_SECRETS}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${_CC_SECRETS}"
  set +a
fi

# Refresh one connector via its CLI; echoes "ok" | "fail" (never aborts the run).
_cc_refresh() {
  local cli="${_CC_CONN_BASE}/$1/dist/cli.js" out
  [[ -f "${cli}" ]] || { echo "fail"; return 0; }
  if out=$(node "${cli}" refresh 2>/dev/null) \
       && [[ "$(printf '%s' "${out}" | jq -r '.ok // false' 2>/dev/null)" == "true" ]]; then
    echo "ok"
  else
    echo "fail"
  fi
}

_cc_acct_status="$(_cc_refresh "${CTX_ACCOUNTING_PROVIDER}")"
_cc_ob_status="$(_cc_refresh "open-banking")"
_cc_ob_stage="unknown"
if [[ -f "${_CC_CONN_BASE}/open-banking/dist/cli.js" ]]; then
  _cc_ob_stage="$(node "${_CC_CONN_BASE}/open-banking/dist/cli.js" token-stage 2>/dev/null \
                  | jq -r '.stage // "unknown"' 2>/dev/null || echo unknown)"
fi

hh_decision_output "auth_refresh_complete" "tenant:${CTX_TENANT_SLUG}" \
  "accounting:${_cc_acct_status}; open_banking:${_cc_ob_status}; token_aging_stage:${_cc_ob_stage}"

# ESC routing per agent.md §4 Step 1 / §6.
if [[ "${_cc_acct_status}" != "ok" ]]; then
  autosend_escalate "ESC_ACCOUNTING_AUTH" "agent=cash-conductor" \
    "tenant=${CTX_TENANT_SLUG}" "provider=${CTX_ACCOUNTING_PROVIDER}"
fi
if [[ "${_cc_ob_status}" != "ok" ]]; then
  autosend_escalate "ESC_OPEN_BANKING_AUTH" "agent=cash-conductor" "tenant=${CTX_TENANT_SLUG}"
elif [[ "${_cc_ob_stage}" == "blocking" ]]; then
  autosend_escalate "ESC_OPEN_BANKING_TOKEN_AGING" "agent=cash-conductor" \
    "tenant=${CTX_TENANT_SLUG}" "stage=blocking"
fi

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
  # W7 LIVE: OB list-transactions since the last ingested posted_at → bulk INSERT
  # into cash_conductor_transactions under RLS (jsonb_to_recordset; ON CONFLICT on
  # the (tenant,provider,transaction_id) unique key makes re-ingest idempotent).
  # OB returns the provider-agnostic normalised shape, so no per-provider mapping.
  _cc_tx_count=0
  _cc_since="n/a"
  _ob_cli="${_CC_CONN_BASE:-}/open-banking/dist/cli.js"
  if [[ -n "${IFOS_DB_URL:-}" && -f "${_ob_cli}" ]] && command -v psql >/dev/null 2>&1; then
    _cc_since="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
      -c "BEGIN; SET LOCAL app.current_tenant='${CTX_TENANT_SLUG}'; SELECT coalesce(to_char(max(posted_at),'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'),'') FROM cash_conductor_transactions WHERE bank_provider='${CTX_OPEN_BANKING_PROVIDER}'; COMMIT;" \
      2>/dev/null | grep -vE '^$' | head -1 || true)"
    if [[ -z "${_cc_since}" ]]; then
      _cc_since="$(date -u -v-89d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '89 days ago' +%Y-%m-%dT%H:%M:%SZ)"
    fi
    _cc_tx_json="$(node "${_ob_cli}" list-transactions --since "${_cc_since}" 2>/dev/null || echo '[]')"
    if [[ "$(printf '%s' "${_cc_tx_json}" | jq -e 'type=="array"' 2>/dev/null)" == "true" ]]; then
      _cc_tx_count="$(printf '%s' "${_cc_tx_json}" | jq 'length')"
      if [[ "${_cc_tx_count}" -gt 0 ]]; then
        psql "${IFOS_DB_URL}" -q -v ON_ERROR_STOP=1 \
          --set=tenant="${CTX_TENANT_SLUG}" --set=prov="${CTX_OPEN_BANKING_PROVIDER}" --set=js="${_cc_tx_json}" <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
INSERT INTO cash_conductor_transactions
  (tenant_slug, transaction_id, posted_at, amount, currency, payee_name_raw, description, bank_provider, raw_payload)
SELECT :'tenant', t.transaction_id, t.posted_at, t.amount, coalesce(t.currency,'GBP'),
       coalesce(t.reference, t.description), t.description, :'prov', t.raw_provider_payload
FROM jsonb_to_recordset(:'js'::jsonb)
  AS t(transaction_id text, posted_at timestamptz, amount numeric, currency text,
       description text, reference text, raw_provider_payload jsonb)
ON CONFLICT (tenant_slug, bank_provider, transaction_id) DO NOTHING;
COMMIT;
SQL
      fi
    fi
  fi
  hh_decision_output "transactions_ingested" "tenant:${CTX_TENANT_SLUG}" \
    "${_cc_tx_count} rows since=${_cc_since} provider=${CTX_OPEN_BANKING_PROVIDER}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Invoice register ingest (mode=webhook from accounting OR daily-sweep)
# Reference: agent.md §4 Step 4. W7-8 wires: @ifos/xero or @ifos/quickbooks
# listOpenInvoices → INSERT INTO cash_conductor_invoices.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *4* ]]; then
  # W7 LIVE: provider-aware (CTX_ACCOUNTING_PROVIDER=xero|quickbooks) list-open-invoices
  # → bulk UPSERT into cash_conductor_invoices under RLS. ON CONFLICT DO UPDATE
  # refreshes amount_paid/status as payments arrive (but never touches the
  # agent-managed last_chase_position/last_chase_sent_at). The CLI emits the
  # unified normalised shape, so this INSERT is provider-agnostic.
  _cc_inv_count=0
  _acct_cli="${_CC_CONN_BASE:-}/${CTX_ACCOUNTING_PROVIDER}/dist/cli.js"
  if [[ -n "${IFOS_DB_URL:-}" && -f "${_acct_cli}" ]] && command -v psql >/dev/null 2>&1; then
    _cc_inv_json="$(node "${_acct_cli}" list-open-invoices 2>/dev/null || echo '[]')"
    if [[ "$(printf '%s' "${_cc_inv_json}" | jq -e 'type=="array"' 2>/dev/null)" == "true" ]]; then
      _cc_inv_count="$(printf '%s' "${_cc_inv_json}" | jq 'length')"
      if [[ "${_cc_inv_count}" -gt 0 ]]; then
        psql "${IFOS_DB_URL}" -q -v ON_ERROR_STOP=1 \
          --set=tenant="${CTX_TENANT_SLUG}" --set=prov="${CTX_ACCOUNTING_PROVIDER}" --set=js="${_cc_inv_json}" <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
INSERT INTO cash_conductor_invoices
  (tenant_slug, invoice_id, accounting_provider, invoice_number, issued_at, due_at,
   amount_total, amount_paid, currency, status, client_contact_id, raw_payload)
SELECT :'tenant', t.invoice_id, :'prov', t.invoice_number, t.issued_at, t.due_at,
       t.amount_total, coalesce(t.amount_paid,0), coalesce(t.currency,'GBP'),
       coalesce(t.status,'open'), t.client_contact_id, t.raw
FROM jsonb_to_recordset(:'js'::jsonb)
  AS t(invoice_id text, invoice_number text, issued_at timestamptz, due_at timestamptz,
       amount_total numeric, amount_paid numeric, currency text, status text,
       client_contact_id text, raw jsonb)
ON CONFLICT (tenant_slug, accounting_provider, invoice_id) DO UPDATE SET
  amount_paid = EXCLUDED.amount_paid, status = EXCLUDED.status,
  amount_total = EXCLUDED.amount_total, updated_at = now();
COMMIT;
SQL
      fi
    fi
  fi
  hh_decision_output "invoices_ingested" "tenant:${CTX_TENANT_SLUG}" \
    "${_cc_inv_count} rows provider=${CTX_ACCOUNTING_PROVIDER}"
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
  # Always emit the YELLOW-tier internal-draft row first — this is the audit
  # record that the draft exists in vault regardless of whether the orange
  # send-approval path fires.
  # TODO(W7-8): per draft iteration:
  #   hh_decision_action "xero_reminder_draft_internal" "invoice:${INVOICE_ID}" \
  #     "${PAYLOAD_HASH}" "vault_path:${DRAFT_PATH}; position:${CHASE_POSITION}"

  if [[ -d "${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist" ]]; then
    # Bridge package PRESENT — route each draft through the D1-B Telegram shim.
    # Per D1-B doc §"Implementation surface" items 1 + 3 (Cash Conductor consumer).
    #
    # Production-shape call site (SKELETON; W7-8 build slice wires the per-draft
    # loop + the tsx CLI entrypoints — they live alongside the package at
    # packages/utilities/autosend-bridge-telegram/bin/{propose,await}.ts and
    # are intentionally NOT in the v0.1 scaffold per the package README §
    # "Out of scope (v1.0)" line on CLI wrappers).
    #
    # Per-draft flow:
    #
    # 1. proposeApproval — posts to operator Telegram, returns approval-id +
    #    deadline. Package: @ifos/autosend-bridge-telegram (proposeApproval).
    #
    #    PROPOSE_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/propose.ts" \
    #      --action xero_reminder_send_customer \
    #      --tenant "${CTX_TENANT_SLUG}" \
    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
    #      --target "${DRAFT_CONTACT_EMAIL}" \
    #      --preview "${DRAFT_PREVIEW_500_CHARS}" \
    #      --vault-path "${DRAFT_PATH}" \
    #      --timeout-seconds 14400)
    #    APPROVAL_ID=$(printf '%s' "${PROPOSE_JSON}" | jq -r .approval_id)
    #    EXPIRES_AT_ISO=$(printf '%s' "${PROPOSE_JSON}" | jq -r .expires_at_iso)
    #
    # 2. Emit ORANGE-tier audit row — Cash Conductor OWNS xero_reminder_send_customer
    #    per autosend-policy.yaml line 263.
    #
    #    hh_decision_action "xero_reminder_send_customer" "invoice:${INVOICE_ID}" \
    #      "${PAYLOAD_HASH}" \
    #      "approval_id:${APPROVAL_ID}; expires_at:${EXPIRES_AT_ISO}; position:${CHASE_POSITION}; vault:${DRAFT_PATH}"
    #
    # 3. awaitApprovalDecision — block until decision or PT4H deadline.
    #    Package: @ifos/autosend-bridge-telegram (awaitApprovalDecision).
    #
    #    AWAIT_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/await.ts" \
    #      --approval-id "${APPROVAL_ID}" \
    #      --expires-at "${EXPIRES_AT_ISO}")
    #    OUTCOME=$(printf '%s' "${AWAIT_JSON}" | jq -r .outcome)
    #    DECIDED_BY=$(printf '%s' "${AWAIT_JSON}" | jq -r '.decided_by // ""')
    #
    # 4. Branch on outcome:
    #    case "${OUTCOME}" in
    #      approved)
    #        # Step 11 transport proceeds (webhook-driven from Concierge after send)
    #        : ;;
    #      rejected)
    #        hh_decision_output "approval_rejected" "invoice:${INVOICE_ID}" \
    #          "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}; rationale:operator_rejected" ;;
    #      timeout)
    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
    #        # lines 348-353: warn-tier; operator + ifos_oncall_chat_id routing;
    #        # action converts to manual reconciliation; operator handles offline.
    #        hh_decision_action "validate_gate_a_fail" "invoice:${INVOICE_ID}" \
    #          "${PAYLOAD_HASH}" \
    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
    #    esac
    : # TODO(W7-8): wire the per-draft loop above (steps 1–4); tsx CLI entrypoints land alongside in the same build slice
  else
    # Bridge package ABSENT (dist/ missing) — drafts-only graceful degradation.
    # DO NOT emit the orange row; Cash Conductor's chase pipeline halts at the
    # vault-draft stage and a consultant picks the drafts up manually.
    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
      "autosend-bridge-telegram package dist/ not present — drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable the D1-B send path"
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
