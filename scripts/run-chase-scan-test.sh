#!/usr/bin/env bash
# Cash Conductor — deterministic chase-scan ladder fixture test (P4a).
#
# Exercises agents/recruitment/cash-conductor/sql/chase-scan.sql (the SAME file
# cycle.sh Step 7 runs) against crafted invoices that deterministically cover the
# §3.2 escalation ladder + every exclusion rule. All fixtures seed under a
# throwaway tenant inside ONE transaction that ROLLBACKs — nothing persists, RLS
# scopes every read/write.
#
# Usage:
#   IFOS_DB_URL=postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev \
#     bash scripts/run-chase-scan-test.sh
# (IFOS_DB_URL defaults to the local dev DB if unset.)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly SCAN_SQL="${REPO_ROOT}/agents/recruitment/cash-conductor/sql/chase-scan.sql"
readonly TEST_TENANT="chase-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
[[ -f "${SCAN_SQL}" ]] || { _fail "scan SQL missing: ${SCAN_SQL}"; exit 1; }

printf '\033[1;34m── Chase-scan ladder fixture test ──\033[0m\n'

# Seed → run scan → emit candidate lines → ROLLBACK. due_at is relative to now()
# so the ladder thresholds (7/14/21/30d) are exercised deterministically.
RAW_OUT="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TEST_TENANT}" <<SQL
BEGIN;
SET LOCAL app.current_tenant = :'tenant';

INSERT INTO cash_conductor_invoices
  (tenant_slug, invoice_id, accounting_provider, invoice_number, issued_at, due_at,
   amount_total, amount_paid, status, last_chase_position, client_contact_id, client_billing_email) VALUES
  -- draftable ladder positions 1-3 + operator-review position 4
  (:'tenant','P1','quickbooks','INV-P1', now()-interval '40 days', now()-interval '10 days', 500,0,'open',0,'c1','p1@x.co'),
  (:'tenant','P2','quickbooks','INV-P2', now()-interval '46 days', now()-interval '16 days', 500,0,'open',1,'c2','p2@x.co'),
  (:'tenant','P3','quickbooks','INV-P3', now()-interval '53 days', now()-interval '23 days', 500,0,'open',2,'c3','p3@x.co'),
  (:'tenant','P4','quickbooks','INV-P4', now()-interval '65 days', now()-interval '35 days', 500,0,'open',3,'c4','p4@x.co'),
  -- exclusions
  (:'tenant','WAIT','quickbooks','INV-WAIT', now()-interval '40 days', now()-interval '10 days', 500,0,'open',1,'c5','w@x.co'),   -- pos-1 sent, not yet 14d for pos 2
  (:'tenant','DONE','quickbooks','INV-DONE', now()-interval '70 days', now()-interval '40 days', 500,0,'open',4,'c6','d@x.co'),   -- ladder exhausted
  (:'tenant','MATCHED','quickbooks','INV-MATCHED', now()-interval '50 days', now()-interval '20 days', 500,0,'open',0,'c7','m@x.co'), -- reconciled
  (:'tenant','NOTOVERDUE','quickbooks','INV-NOD', now()-interval '33 days', now()-interval '3 days', 500,0,'open',0,'c8','n@x.co'),   -- <7d overdue
  (:'tenant','PAID','quickbooks','INV-PAID', now()-interval '50 days', now()-interval '20 days', 500,500,'open',0,'c9','pd@x.co');   -- fully paid → amount_due 0

INSERT INTO cash_conductor_transactions
  (tenant_slug, transaction_id, posted_at, amount, bank_provider, match_status, matched_invoice_id) VALUES
  (:'tenant','TXM', now()-interval '5 days', 500, 'truelayer', 'matched', 'MATCHED');

\\i ${SCAN_SQL}

ROLLBACK;
SQL
)"

# Parse "invoice_id|...|next_pos|..." → map of id→next_pos for the returned candidates.
declare -A GOT=()
while IFS='|' read -r id _num _amt _days pos _contact _email; do
  [[ -z "${id}" ]] && continue
  GOT["${id}"]="${pos}"
done <<<"${RAW_OUT}"

fails=0
assert_present() {  # <id> <expected-next_pos>
  if [[ "${GOT[$1]:-MISSING}" == "$2" ]]; then
    _ok "$1 → next_pos $2"
  else
    _fail "$1: expected next_pos $2, got '${GOT[$1]:-MISSING}'"
    fails=$((fails + 1))
  fi
}
assert_absent() {  # <id> <why>
  if [[ -z "${GOT[$1]:-}" ]]; then
    _ok "$1 excluded ($2)"
  else
    _fail "$1: should be excluded ($2) but appeared at next_pos ${GOT[$1]}"
    fails=$((fails + 1))
  fi
}

assert_present P1 1
assert_present P2 2
assert_present P3 3
assert_present P4 4
assert_absent  WAIT       "pos-1 sent, <14d"
assert_absent  DONE       "ladder exhausted (pos 4 already)"
assert_absent  MATCHED    "reconciled"
assert_absent  NOTOVERDUE "<7d overdue"
assert_absent  PAID       "amount_due 0"

# Exactly the 4 expected candidates, no extras.
if [[ "${#GOT[@]}" -eq 4 ]]; then
  _ok "candidate count = 4 (no extras)"
else
  _fail "candidate count = ${#GOT[@]} (expected 4)"
  fails=$((fails + 1))
fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all chase-scan ladder assertions passed (positions 1-4 + 5 exclusions)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
