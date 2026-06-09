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
export CTX_AGENT_NAME CTX_AGENT_DIR CTX_TENANT_SLUG   # inherited by validate.sh subprocess (Step 9)

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
  # W7 LIVE: run the 5-stage match (agent.md §3 Output 1) as one RLS-scoped
  # statement. The reusable SQL lives at sql/reconciliation-match.sql (shared
  # with scripts/run-reconciliation-recon-test.sh) and contains no transaction
  # control / tenant literal — we wrap it here. It UPDATEs match_status /
  # match_confidence / matched_invoice_id / match_dimensions over unmatched,
  # positive-amount transactions and returns "s12|s3|s4|s5|ambiguous" counts.
  _cc_s12=0; _cc_s3=0; _cc_s4=0; _cc_s5=0; _cc_amb=0
  _cc_recon_sql="${CTX_AGENT_DIR}/sql/reconciliation-match.sql"
  [[ -f "${_cc_recon_sql}" ]] || _cc_recon_sql="${IFOS_REPO_ROOT:-}/agents/recruitment/cash-conductor/sql/reconciliation-match.sql"
  if [[ -n "${IFOS_DB_URL:-}" && -f "${_cc_recon_sql}" ]] && command -v psql >/dev/null 2>&1; then
    _cc_recon_out="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<SQL
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
\\i $(printf '%s' "${_cc_recon_sql}")
COMMIT;
SQL
)" || _cc_recon_out=""
    # Last non-empty line is the count tuple (psql -tAq emits only the SELECT).
    _cc_recon_row="$(printf '%s\n' "${_cc_recon_out}" | grep -E '^[0-9]+\|[0-9]+\|[0-9]+\|[0-9]+\|[0-9]+$' | tail -1)"
    if [[ -n "${_cc_recon_row}" ]]; then
      IFS='|' read -r _cc_s12 _cc_s3 _cc_s4 _cc_s5 _cc_amb <<<"${_cc_recon_row}"
    fi
  fi
  hh_decision_output "reconciliation_pass" "tenant:${CTX_TENANT_SLUG}" \
    "stage1_2:${_cc_s12}; stage3:${_cc_s3}; stage4:${_cc_s4}; stage5:${_cc_s5}; ambiguous:${_cc_amb}"

  # Stage 4 / multi-candidate matches are written as match_status='ambiguous'
  # (agent.md §4 Step 5 + §6 ESC_RECONCILIATION_AMBIGUOUS, catalogue §2.10).
  if [[ "${_cc_amb}" =~ ^[0-9]+$ && "${_cc_amb}" -gt 0 ]]; then
    autosend_escalate "ESC_RECONCILIATION_AMBIGUOUS" "agent=cash-conductor" \
      "tenant=${CTX_TENANT_SLUG}" "ambiguous_count=${_cc_amb}"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Reconciliation write (yellow tier per match)
# Reference: agent.md §3 Output 1. W7-8 wires: @ifos/xero writePaymentReceived
# or @ifos/quickbooks writePaymentReceived; atomic per write; rollback on 4xx/5xx.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *6* ]]; then
  # W7 LIVE: write Stage 1-2 matches (match_status='matched', conf ≥0.85) to the
  # accounting system via the provider write-payment CLI. Idempotent: only
  # not-yet-written rows are selected (reconciliation_written_at IS NULL, v0.5
  # schema), and on success the row is stamped with the returned payment id so a
  # re-run never double-pays. Stage 3 (unmatched/review) + Stage 4/ambiguous are
  # NOT auto-written. STATE-CHANGING on the tenant's books — yellow tier.
  _cc_acct_cli="${_CC_CONN_BASE:-}/${CTX_ACCOUNTING_PROVIDER}/dist/cli.js"
  if [[ -n "${IFOS_DB_URL:-}" && -f "${_cc_acct_cli}" ]] && command -v psql >/dev/null 2>&1; then
    _cc_writeq="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
      --set=tenant="${CTX_TENANT_SLUG}" --set=prov="${CTX_ACCOUNTING_PROVIDER}" <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT t.transaction_id || '|' || t.matched_invoice_id || '|' || t.amount::text || '|' ||
       to_char(t.posted_at, 'YYYY-MM-DD') || '|' || coalesce(i.client_contact_id, '') || '|' ||
       coalesce(t.match_confidence::text, '')
FROM cash_conductor_transactions t
JOIN cash_conductor_invoices i
  ON i.invoice_id = t.matched_invoice_id AND i.accounting_provider = :'prov'
WHERE t.match_status = 'matched' AND t.reconciliation_written_at IS NULL;
COMMIT;
SQL
)"
    while IFS='|' read -r _cc_txn _cc_inv _cc_amt _cc_date _cc_cust _cc_conf; do
      [[ -z "${_cc_txn}" ]] && continue
      case "${CTX_ACCOUNTING_PROVIDER}" in
        xero)
          _cc_wp_args=(write-payment --invoice "${_cc_inv}" --amount "${_cc_amt}"
            --date "${_cc_date}" --account "${XERO_PAYMENT_ACCOUNT_CODE:-}" --reference "${_cc_txn}") ;;
        quickbooks)
          _cc_wp_args=(write-payment --invoice "${_cc_inv}" --amount "${_cc_amt}"
            --date "${_cc_date}" --customer "${_cc_cust}" --reference "${_cc_txn}") ;;
        *)
          autosend_escalate "ESC_ACCOUNTING_WRITE_FAIL" "agent=cash-conductor" \
            "tenant=${CTX_TENANT_SLUG}" "invoice=${_cc_inv}" \
            "reason=unsupported_provider:${CTX_ACCOUNTING_PROVIDER}"
          continue ;;
      esac
      if _cc_wp_out=$(node "${_cc_acct_cli}" "${_cc_wp_args[@]}" 2>/dev/null) \
           && [[ "$(printf '%s' "${_cc_wp_out}" | jq -r '.ok // false' 2>/dev/null)" == "true" ]]; then
        _cc_pid="$(printf '%s' "${_cc_wp_out}" | jq -r '.payment_id // ""')"
        _cc_phash="$(printf '%s' "${_cc_inv}|${_cc_amt}|${_cc_pid}" | shasum -a 256 2>/dev/null | cut -c1-16)"
        [[ -z "${_cc_phash}" ]] && _cc_phash="${_cc_txn}"
        # Yellow-tier action row (autosend-policy.yaml accounting_reconciliation_write).
        hh_decision_action "accounting_reconciliation_write" "invoice:${_cc_inv}" "${_cc_phash}" \
          "txn:${_cc_txn}; amount:${_cc_amt}; payment_id:${_cc_pid}; confidence:${_cc_conf}" || true
        # Stamp written (idempotency guard repeated in the UPDATE predicate).
        psql "${IFOS_DB_URL}" -q -v ON_ERROR_STOP=1 \
          --set=tenant="${CTX_TENANT_SLUG}" --set=txn="${_cc_txn}" --set=pid="${_cc_pid}" <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE cash_conductor_transactions
SET reconciliation_written_at = now(), accounting_payment_id = :'pid'
WHERE transaction_id = :'txn' AND match_status = 'matched' AND reconciliation_written_at IS NULL;
COMMIT;
SQL
      else
        _cc_wperr="$(printf '%s' "${_cc_wp_out:-}" | jq -r '.error // "write_failed"' 2>/dev/null || echo write_failed)"
        autosend_escalate "ESC_ACCOUNTING_WRITE_FAIL" "agent=cash-conductor" \
          "tenant=${CTX_TENANT_SLUG}" "invoice=${_cc_inv}" \
          "provider=${CTX_ACCOUNTING_PROVIDER}" "error=${_cc_wperr}"
      fi
    done <<<"${_cc_writeq}"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Chase generation pass (for overdue, unmatched invoices)
# Reference: agent.md §4 Step 7. Read cash_conductor_invoices.last_chase_position
# (v0.3 schema-backed). Position 4 = operator review (no auto-draft).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *7* ]]; then
  # W7 LIVE: scan overdue, unmatched, still-owing invoices and compute the next
  # chase ladder position (§3.2) via the reusable RLS-scoped sql/chase-scan.sql
  # (shared with scripts/run-chase-scan-test.sh). Draftable candidates (pos 1-3)
  # are written to a run-scoped temp file consumed by Steps 8-10; position 4 →
  # operator review (no auto-draft, per agent.md §3.2 kill-switch).
  CC_CHASE_CANDIDATES="$(mktemp -t cc-chase-XXXXXX 2>/dev/null || echo "/tmp/cc-chase-$$")"
  export CC_CHASE_CANDIDATES
  : > "${CC_CHASE_CANDIDATES}"
  _cc_p1=0; _cc_p2=0; _cc_p3=0; _cc_p4=0
  _cc_chase_sql="${CTX_AGENT_DIR}/sql/chase-scan.sql"
  [[ -f "${_cc_chase_sql}" ]] || _cc_chase_sql="${IFOS_REPO_ROOT:-}/agents/recruitment/cash-conductor/sql/chase-scan.sql"
  if [[ -n "${IFOS_DB_URL:-}" && -f "${_cc_chase_sql}" ]] && command -v psql >/dev/null 2>&1; then
    _cc_scan_out="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<SQL
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
\\i $(printf '%s' "${_cc_chase_sql}")
COMMIT;
SQL
)" || _cc_scan_out=""
    while IFS='|' read -r _ci_id _ci_num _ci_amt _ci_days _ci_pos _ci_contact _ci_email; do
      [[ -z "${_ci_id}" ]] && continue
      case "${_ci_pos}" in
        4)
          _cc_p4=$((_cc_p4 + 1))
          hh_decision_output "chase_position_4_operator_review" "invoice:${_ci_id}" \
            "age_days:${_ci_days}; prior_chases:3" ;;
        1|2|3)
          printf '%s\n' "${_ci_id}|${_ci_num}|${_ci_amt}|${_ci_days}|${_ci_pos}|${_ci_contact}|${_ci_email}" \
            >> "${CC_CHASE_CANDIDATES}"
          case "${_ci_pos}" in
            1) _cc_p1=$((_cc_p1 + 1)) ;;
            2) _cc_p2=$((_cc_p2 + 1)) ;;
            3) _cc_p3=$((_cc_p3 + 1)) ;;
          esac ;;
      esac
    done <<<"${_cc_scan_out}"
  fi
  hh_decision_output "chase_pass_complete" "tenant:${CTX_TENANT_SLUG}" \
    "pos1:${_cc_p1}; pos2:${_cc_p2}; pos3:${_cc_p3}; pos4_operator:${_cc_p4}"
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
  # W7 LIVE: per Step-7 candidate, render a position-appropriate chase draft and
  # write it to the vault FIRST (chmod 0600) per ADR-002; decision_log carries
  # METADATA only. v1.0 uses deterministic templated drafts (bin/render-chase-draft.sh);
  # LLM polish + an embedding voice classifier scored against a seeded tenant
  # voice_corpus is the documented enhancement — dev-sandbox corpus is empty, so
  # voice_score is recorded honestly as unscored/no_corpus (never a faked number).
  _cc_render="${CTX_AGENT_DIR}/bin/render-chase-draft.sh"
  [[ -f "${_cc_render}" ]] || _cc_render="${IFOS_REPO_ROOT:-}/agents/recruitment/cash-conductor/bin/render-chase-draft.sh"
  _cc_drafts_dir="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/cash-conductor-drafts"
  _cc_drafts_made=0
  if [[ -n "${CC_CHASE_CANDIDATES:-}" && -s "${CC_CHASE_CANDIDATES}" && -f "${_cc_render}" ]]; then
    mkdir -p "${_cc_drafts_dir}" 2>/dev/null || true
    chmod 0700 "${_cc_drafts_dir}" 2>/dev/null || true
    while IFS='|' read -r _ci_id _ci_num _ci_amt _ci_days _ci_pos _ci_contact _ci_email; do
      [[ -z "${_ci_id}" ]] && continue
      _cc_draft_id="cc-${_ci_id}-p${_ci_pos}"   # stable per (invoice,position) → idempotent re-runs
      _cc_draft_path="${_cc_drafts_dir}/${_cc_draft_id}.md"
      if bash "${_cc_render}" --draft-id "${_cc_draft_id}" --invoice-id "${_ci_id}" \
           --invoice-number "${_ci_num}" --amount "${_ci_amt}" --days-overdue "${_ci_days}" \
           --position "${_ci_pos}" --contact-email "${_ci_email}" > "${_cc_draft_path}.tmp" 2>/dev/null; then
        mv "${_cc_draft_path}.tmp" "${_cc_draft_path}"
        chmod 0600 "${_cc_draft_path}" 2>/dev/null || true
        _cc_body_sha="$(shasum -a 256 "${_cc_draft_path}" 2>/dev/null | cut -c1-16)"
        [[ -z "${_cc_body_sha}" ]] && _cc_body_sha="na"
        _cc_drafts_made=$((_cc_drafts_made + 1))
        hh_decision_output "chase_draft_generated" "invoice:${_ci_id}" \
          "vault_path:${_cc_draft_path}; body_sha256:${_cc_body_sha}; escalation_position:${_ci_pos}; voice_score:unscored; voice_reason:no_corpus; days_overdue:${_ci_days}; amount_due:${_ci_amt}"
      else
        rm -f "${_cc_draft_path}.tmp" 2>/dev/null || true
      fi
    done < "${CC_CHASE_CANDIDATES}"
  fi
  export CC_DRAFTS_DIR="${_cc_drafts_dir}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Chase-draft validation (Gate A specifics; validate.sh)
# Reference: agent.md §5 (Gate A); §6 ESC mapping.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *9* ]]; then
  # W7 LIVE: run Gate A (validate.sh) on each generated draft. Passed drafts are
  # recorded to a run-scoped file consumed by Step 10; failed drafts already had
  # their ESC row emitted by validate.sh and are NOT queued (the draft stays in
  # the vault for operator review).
  CC_VALIDATED="$(mktemp -t cc-validated-XXXXXX 2>/dev/null || echo "/tmp/cc-validated-$$")"
  export CC_VALIDATED
  : > "${CC_VALIDATED}"
  _cc_validate="${CTX_AGENT_DIR}/validate.sh"
  [[ -f "${_cc_validate}" ]] || _cc_validate="${IFOS_REPO_ROOT:-}/agents/recruitment/cash-conductor/validate.sh"
  _cc_drafts_base="${CC_DRAFTS_DIR:-${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/cash-conductor-drafts}"
  _cc_passed=0; _cc_failed=0
  if [[ -n "${CC_CHASE_CANDIDATES:-}" && -s "${CC_CHASE_CANDIDATES}" && -f "${_cc_validate}" ]]; then
    while IFS='|' read -r _ci_id _ci_num _ci_amt _ci_days _ci_pos _ci_contact _ci_email; do
      [[ -z "${_ci_id}" ]] && continue
      _cc_dpath="${_cc_drafts_base}/cc-${_ci_id}-p${_ci_pos}.md"
      [[ -f "${_cc_dpath}" ]] || continue
      if bash "${_cc_validate}" "${_cc_dpath}" >/dev/null 2>&1; then
        _cc_passed=$((_cc_passed + 1))
        printf '%s\n' "${_ci_id}|${_ci_pos}|${_cc_dpath}" >> "${CC_VALIDATED}"
        hh_decision_output "chase_draft_validated" "invoice:${_ci_id}" "passed; position:${_ci_pos}"
      else
        _cc_failed=$((_cc_failed + 1))   # validate.sh already emitted the ESC row
      fi
    done < "${CC_CHASE_CANDIDATES}"
  fi
  hh_decision_output "chase_validation_pass" "tenant:${CTX_TENANT_SLUG}" \
    "passed:${_cc_passed}; failed:${_cc_failed}"
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
  # W7 LIVE: emit the YELLOW-tier internal-draft action row per VALIDATED draft —
  # the audit record that the draft exists in vault, independent of the orange
  # send path. autosend-policy.yaml: xero_reminder_draft_internal = yellow.
  if [[ -n "${CC_VALIDATED:-}" && -s "${CC_VALIDATED}" ]]; then
    while IFS='|' read -r _vi_id _vi_pos _vi_path; do
      [[ -z "${_vi_id}" ]] && continue
      _vi_hash="$(shasum -a 256 "${_vi_path}" 2>/dev/null | cut -c1-16)"
      [[ -z "${_vi_hash}" ]] && _vi_hash="${_vi_id}"
      hh_decision_action "xero_reminder_draft_internal" "invoice:${_vi_id}" "${_vi_hash}" \
        "vault_path:${_vi_path}; position:${_vi_pos}" || true
    done < "${CC_VALIDATED}"
  fi

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
  # W7 LIVE (webhook-driven): after Concierge transports an approved chase it webhooks
  # back invoice+position; CC records the state mutation. The Concierge chase_sent
  # webhook lands in the W10-13 build slice; until then (drafts-only) nothing triggers
  # this, so the mutation is wired + tested but inert unless the signal is present.
  if [[ -n "${CC_CHASE_SENT_INVOICE:-}" && -n "${CC_CHASE_SENT_POSITION:-}" && -n "${IFOS_DB_URL:-}" ]] \
       && command -v psql >/dev/null 2>&1; then
    psql "${IFOS_DB_URL}" -q -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" \
      --set=inv="${CC_CHASE_SENT_INVOICE}" --set=pos="${CC_CHASE_SENT_POSITION}" <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE cash_conductor_invoices
SET last_chase_position = :'pos'::int, last_chase_sent_at = now()
WHERE invoice_id = :'inv';
COMMIT;
SQL
    hh_decision_output "cash_conductor_chase_sent_recorded" "invoice:${CC_CHASE_SENT_INVOICE}" \
      "position:${CC_CHASE_SENT_POSITION}; sent_at:$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 12 — Re-trigger eligibility check (mode=webhook only)
# Reference: agent.md §4 Step 12. Cancels chase-drafts on race conditions
# (paid-since-draft-but-before-send) → ESC_AUTOSEND_RACE.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *12* ]]; then
  # W7 LIVE (webhook mode only): re-query each in-flight chase draft's invoice. If it
  # was paid since the draft (amount_due now ≤ 0), cancel the chase (do NOT send) →
  # ESC_AUTOSEND_RACE. Guards the paid-since-draft-but-before-send race (agent.md §4 Step 12).
  if [[ -n "${CC_VALIDATED:-}" && -s "${CC_VALIDATED}" && -n "${IFOS_DB_URL:-}" ]] \
       && command -v psql >/dev/null 2>&1; then
    while IFS='|' read -r _rc_id _rc_pos _rc_path; do
      [[ -z "${_rc_id}" ]] && continue
      _rc_due="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
        --set=tenant="${CTX_TENANT_SLUG}" --set=inv="${_rc_id}" <<'SQL' 2>/dev/null
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT (amount_total - amount_paid)::text FROM cash_conductor_invoices WHERE invoice_id = :'inv' LIMIT 1;
COMMIT;
SQL
)"
      _rc_due="$(printf '%s' "${_rc_due}" | grep -E '^-?[0-9.]+$' | head -1)"
      if [[ -n "${_rc_due}" ]] && awk -v d="${_rc_due}" 'BEGIN{exit !(d<=0)}'; then
        autosend_escalate "ESC_AUTOSEND_RACE" "agent=cash-conductor" \
          "tenant=${CTX_TENANT_SLUG}" "invoice=${_rc_id}"
        hh_decision_output "chase_cancellation_check" "invoice:${_rc_id}" \
          "cancelled:true; reason:paid_since_draft"
      else
        hh_decision_output "chase_cancellation_check" "invoice:${_rc_id}" "cancelled:false"
      fi
    done < "${CC_VALIDATED}"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 13 — Weekly report assembly (mode=weekly-report; Mondays 06:00 UTC)
# Reference: agent.md §4 Step 13 + §3 Output 3 (6-section Markdown report).
# DSO metric (Gate B tracking) per ULTRAPLAN A4 line 539.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *13* ]]; then
  # W7 LIVE: assemble the §3 Output 3 6-section cash-flow report from the reusable
  # RLS-scoped sql/weekly-report-metrics.sql, compute DSO (Gate B), write to vault.
  REPORT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/cash-conductor-reports/weekly-$(date -u +%Y-%m-%d).md"
  mkdir -p "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
  chmod 0700 "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
  _cc_metrics_sql="${CTX_AGENT_DIR}/sql/weekly-report-metrics.sql"
  [[ -f "${_cc_metrics_sql}" ]] || _cc_metrics_sql="${IFOS_REPO_ROOT:-}/agents/recruitment/cash-conductor/sql/weekly-report-metrics.sql"
  METRICS=""
  if [[ -n "${IFOS_DB_URL:-}" && -f "${_cc_metrics_sql}" ]] && command -v psql >/dev/null 2>&1; then
    METRICS="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<SQL
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
\\i $(printf '%s' "${_cc_metrics_sql}")
COMMIT;
SQL
)" || METRICS=""
  fi
  _m() { printf '%s\n' "${METRICS}" | grep -m1 "^$1|" | cut -d'|' -f2; }
  _cc_ar="$(_m ar_open)"; _cc_ar="${_cc_ar:-0}"
  _cc_credit="$(_m total_credit)"; _cc_credit="${_cc_credit:-0}"
  _cc_dso="$(awk -v ar="${_cc_ar}" -v c="${_cc_credit}" 'BEGIN{ if(c+0>0) printf "%.1f",(ar/c)*30; else printf "n/a" }')"
  _cc_open="$(_m open_count)"; _cc_open="${_cc_open:-0}"
  {
    printf '# Weekly cash-flow report — %s\n\n' "$(date -u +%Y-%m-%d)"
    printf '_Tenant: %s · generated %sZ · Cash Conductor §3 Output 3_\n\n' "${CTX_TENANT_SLUG}" "$(date -u +%Y-%m-%dT%H:%M:%S)"
    printf '## 1. Week summary\n\n- Invoices issued (7d): %s\n- Invoices paid (to date): %s\n- Open invoices: %s\n- Receipts received (7d): £%s\n- New chase drafts (this run): %s\n\n' \
      "$(_m issued_7d)" "$(_m paid_count)" "${_cc_open}" "$(_m receipts_7d)" "${_cc_drafts_made:-0}"
    printf '## 2. DSO trend (Gate B)\n\n- AR outstanding: £%s\n- Total credit extended: £%s\n- **DSO (snapshot): %s days**\n- Month-0 baseline: _pending onboarding capture_ (Gate B target = baseline − 12 days)\n\n' \
      "${_cc_ar}" "${_cc_credit}" "${_cc_dso}"
    printf '## 3. Aged debtors\n\n| Bucket | Outstanding |\n|---|---|\n| 0–30 days | £%s |\n| 31–60 days | £%s |\n| 61–90 days | £%s |\n| 90+ days | £%s |\n\n' \
      "$(_m bucket_0_30)" "$(_m bucket_31_60)" "$(_m bucket_61_90)" "$(_m bucket_90_plus)"
    printf '## 4. Chase pipeline\n\n- Position 1 sent: %s\n- Position 2 sent: %s\n- Position 3 sent: %s\n- Drafts generated this run: %s (drafts-only mode — manual consultant pickup until autosend-bridge live)\n\n' \
      "$(_m chase_pos1)" "$(_m chase_pos2)" "$(_m chase_pos3)" "${_cc_drafts_made:-0}"
    printf '## 5. Cash-flow forecast (4 weeks)\n\n- Outstanding due in next 28 days: £%s\n\n' "$(_m forecast_4w)"
    printf '## 6. Exception list\n\n- Unmatched bank receipts (review queue): %s\n- Ambiguous matches: %s\n' \
      "$(_m unmatched_count)" "$(_m ambiguous_count)"
  } > "${REPORT_PATH}" 2>/dev/null || true
  chmod 0600 "${REPORT_PATH}" 2>/dev/null || true
  hh_decision_output "weekly_report" "${REPORT_PATH}" \
    "dso_days:${_cc_dso}; sections:6; ar_open:${_cc_ar}; open_invoices:${_cc_open}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 14 — Session close
# ────────────────────────────────────────────────────────────────────────

# tenant_adapters.config.cash_conductor_last_run (declared in v0.3 supplement; validated
# by validate_tenant_adapters_config_v0_3 trigger landed 2026-05-31).
# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')

if [[ "${STEPS_TO_RUN}" == *13* ]]; then REPORT_RAN="true"; else REPORT_RAN="false"; fi

# W7 LIVE: stamp tenant_adapters.config.cash_conductor_last_run (validated key per
# the v0.3/v0.4 trigger). Best-effort — a missing tenant_adapters row is a no-op.
if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  psql "${IFOS_DB_URL}" -q -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE tenant_adapters
SET config = jsonb_set(coalesce(config, '{}'::jsonb), '{cash_conductor_last_run}', to_jsonb(now()::text))
WHERE tenant_slug = :'tenant';
COMMIT;
SQL
fi

_cc_run_hash="$(printf '%s' "${CTX_TENANT_SLUG}|${MODE}|$(date -u +%s)" | shasum -a 256 2>/dev/null | cut -c1-16)"
[[ -z "${_cc_run_hash}" ]] && _cc_run_hash="run-${MODE}"
hh_decision_action "cash_conductor_run_complete" "session:${CTX_TENANT_SLUG}" "${_cc_run_hash}" \
  "mode:${MODE}; matches:${_cc_s12:-0}; chases:${_cc_drafts_made:-0}; report:${REPORT_RAN}" || true

exit 0
