#!/usr/bin/env bash
# Cash Conductor — weekly-report metrics fixture test (P5).
#
# Exercises agents/recruitment/cash-conductor/sql/weekly-report-metrics.sql (the
# SAME metrics cycle.sh Step 13 assembles into the §3 Output 3 report) against
# crafted invoices + a receipt, asserting each metric. ROLLBACK'd transaction,
# RLS-scoped to a throwaway tenant.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly METRICS_SQL="${REPO_ROOT}/agents/recruitment/cash-conductor/sql/weekly-report-metrics.sql"
readonly TENANT="wr-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
[[ -f "${METRICS_SQL}" ]] || { _fail "metrics SQL missing"; exit 1; }
printf '\033[1;34m── Weekly-report metrics fixture test ──\033[0m\n'

RAW="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}" <<SQL
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
INSERT INTO cash_conductor_invoices
  (tenant_slug, invoice_id, accounting_provider, invoice_number, issued_at, due_at,
   amount_total, amount_paid, status, last_chase_position) VALUES
  (:'tenant','A','quickbooks','3001', now()-interval '40 days',  now()-interval '10 days', 1000,0,  'open',1),
  (:'tenant','B','quickbooks','3002', now()-interval '50 days',  now()-interval '45 days',  500,0,  'open',2),
  (:'tenant','C','quickbooks','3003', now()-interval '110 days', now()-interval '100 days', 300,0,  'open',0),
  (:'tenant','D','quickbooks','3004', now()-interval '30 days',  now()-interval '20 days',  200,200,'paid',0),
  (:'tenant','E','quickbooks','3005', now()-interval '2 days',   now()+interval '10 days',  400,0,  'open',0);
INSERT INTO cash_conductor_transactions
  (tenant_slug, transaction_id, posted_at, amount, bank_provider, match_status) VALUES
  (:'tenant','RX', now()-interval '3 days', 250, 'truelayer', 'unmatched');
\\i ${METRICS_SQL}
ROLLBACK;
SQL
)"

mget() { printf '%s\n' "${RAW}" | grep -m1 "^$1|" | cut -d'|' -f2; }
fails=0
assert_metric() {  # key expected
  local got; got="$(mget "$1")"
  if [[ "${got}" == "$2" ]]; then _ok "$1 = ${got}"; else _fail "$1: got '${got}' want '$2'"; fails=$((fails+1)); fi
}

assert_metric ar_open        2200.00   # A+B+C+E outstanding (D paid, excluded)
assert_metric total_credit   2400.00   # all five invoices
assert_metric open_count     4
assert_metric paid_count     1
assert_metric issued_7d      1         # only E issued in last 7d
assert_metric bucket_0_30    1400.00   # A (10d overdue) + E (not yet due)
assert_metric bucket_31_60   500.00    # B (45d)
assert_metric bucket_61_90   0
assert_metric bucket_90_plus 300.00    # C (100d)
assert_metric chase_pos1     1
assert_metric chase_pos2     1
assert_metric chase_pos3     0
assert_metric forecast_4w    400.00    # only E due within 28d
assert_metric receipts_7d    250.00
assert_metric unmatched_count 1
assert_metric ambiguous_count 0

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all weekly-report metrics assertions passed (16 metrics)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
