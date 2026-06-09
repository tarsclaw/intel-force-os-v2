#!/usr/bin/env bash
# Cash Conductor — deterministic reconciliation-match fixture test (P3b).
#
# Exercises agents/recruitment/cash-conductor/sql/reconciliation-match.sql (the
# SAME file cycle.sh Step 5 runs) against crafted transaction × invoice rows
# that deterministically hit each match stage 1-5 plus the multi-candidate
# ambiguous path. The live dev data is unrelated cross-sandbox (mostly Stage 5),
# so stages 1-4 + the status mapping are proven HERE.
#
# Isolation: all fixtures are seeded under a throwaway tenant inside ONE
# transaction that ROLLBACKs at the end — nothing persists, no real tenant data
# is touched, and RLS scopes every read/write to the fixture tenant.
#
# Usage:
#   IFOS_DB_URL=postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev \
#     bash scripts/run-reconciliation-recon-test.sh
# (IFOS_DB_URL defaults to the local dev DB if unset.)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly MATCH_SQL="${REPO_ROOT}/agents/recruitment/cash-conductor/sql/reconciliation-match.sql"
readonly TEST_TENANT="recon-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
[[ -f "${MATCH_SQL}" ]] || { _fail "match SQL missing: ${MATCH_SQL}"; exit 1; }

printf '\033[1;34m── Reconciliation match fixture test ──\033[0m\n'

# One transaction: seed → run match → emit ROW|/count lines → ROLLBACK.
RAW_OUT="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TEST_TENANT}" <<SQL
BEGIN;
SET LOCAL app.current_tenant = :'tenant';

INSERT INTO cash_conductor_invoices
  (tenant_slug, invoice_id, accounting_provider, invoice_number, issued_at, due_at,
   amount_total, amount_paid, status, raw_payload) VALUES
  (:'tenant','A900','quickbooks','INV-900','2026-06-01','2026-07-01',1000.00,0,'open','{"CustomerRef":{"name":"Acme Ltd"}}'),
  (:'tenant','B901','quickbooks','INV-901','2026-06-01','2026-07-01', 500.00,0,'open','{"CustomerRef":{"name":"Beta Corp"}}'),
  (:'tenant','C902','quickbooks','INV-902','2026-05-15','2026-06-14', 250.00,0,'open','{"CustomerRef":{"name":"Gamma LLP"}}'),
  (:'tenant','D903','quickbooks','INV-903','2026-06-01','2026-07-01', 800.00,0,'open','{"CustomerRef":{"name":"Delta Inc"}}'),
  (:'tenant','E904','quickbooks','INV-904','2026-06-01','2026-07-01', 333.00,0,'open','{"CustomerRef":{"name":"Echo One Ltd"}}'),
  (:'tenant','E905','quickbooks','INV-905','2026-06-01','2026-07-01', 333.00,0,'open','{"CustomerRef":{"name":"Echo Two Ltd"}}');

INSERT INTO cash_conductor_transactions
  (tenant_slug, transaction_id, posted_at, amount, bank_provider, payee_name_raw, description) VALUES
  (:'tenant','T1','2026-06-10',1000.00,'truelayer','Acme Ltd','Payment for INV-900 thank you'),
  (:'tenant','T2','2026-06-10', 500.00,'truelayer','Beta Corp','BACS credit'),
  (:'tenant','T3','2026-06-10', 250.00,'truelayer','Unknown Payer','ref 0001'),
  (:'tenant','T4','2026-06-10', 798.00,'truelayer','Delta Inc','transfer'),
  (:'tenant','T5','2026-06-10',99999.99,'truelayer','Nobody','random'),
  (:'tenant','T6','2026-06-10', 333.00,'truelayer','Zeta Holdings','wire');

\\i ${MATCH_SQL}

SELECT 'ROW|' || transaction_id || '|' || match_status || '|' ||
       coalesce(match_confidence::text,'NULL') || '|' ||
       coalesce(matched_invoice_id,'NULL')
FROM cash_conductor_transactions
WHERE transaction_id IN ('T1','T2','T3','T4','T5','T6')
ORDER BY transaction_id;

-- Step 6 (P3c) write-queue idempotency: matched + not-yet-written are the
-- write candidates. Marking one written (simulating a successful payment write)
-- must drop it from a re-scan — the double-pay guard.
SELECT 'STEP6A|' || coalesce(string_agg(transaction_id, ',' ORDER BY transaction_id),'')
FROM cash_conductor_transactions
WHERE match_status='matched' AND reconciliation_written_at IS NULL;

UPDATE cash_conductor_transactions
SET reconciliation_written_at=now(), accounting_payment_id='PMT-TEST-1'
WHERE transaction_id='T1';

SELECT 'STEP6B|' || coalesce(string_agg(transaction_id, ',' ORDER BY transaction_id),'')
FROM cash_conductor_transactions
WHERE match_status='matched' AND reconciliation_written_at IS NULL;

ROLLBACK;
SQL
)"

# Expected per-row outcomes (transaction_id → status|confidence|matched_invoice_id).
declare -A EXPECT=(
  [T1]="matched|0.98|A900"     # Stage 1: exact amount + invoice_number in memo
  [T2]="matched|0.85|B901"     # Stage 2: exact amount + payee-name match
  [T3]="unmatched|0.70|C902"   # Stage 3: exact amount + within-90d single (review queue + suggestion)
  [T4]="ambiguous|0.65|D903"   # Stage 4: fuzzy amount (±0.5%) + payee match
  [T5]="unmatched|NULL|NULL"   # Stage 5: no candidate
  [T6]="ambiguous|0.70|NULL"   # multi-candidate (two £333 invoices) → ambiguous
)
readonly EXPECTED_COUNTS="2|2|1|1|2"   # s12|s3|s4|s5|ambiguous

fails=0

# Per-row assertions.
for txn in T1 T2 T3 T4 T5 T6; do
  line="$(printf '%s\n' "${RAW_OUT}" | grep -E "^ROW\|${txn}\|" || true)"
  got="${line#ROW|"${txn}"|}"
  want="${EXPECT[${txn}]}"
  if [[ "${got}" == "${want}" ]]; then
    _ok "${txn}: ${got}"
  else
    _fail "${txn}: got '${got}' want '${want}'"
    fails=$((fails + 1))
  fi
done

# Stage-bucket count assertion (the match SQL's own returned tuple).
counts="$(printf '%s\n' "${RAW_OUT}" | grep -E '^[0-9]+\|[0-9]+\|[0-9]+\|[0-9]+\|[0-9]+$' | tail -1)"
if [[ "${counts}" == "${EXPECTED_COUNTS}" ]]; then
  _ok "counts s12|s3|s4|s5|amb = ${counts}"
else
  _fail "counts: got '${counts}' want '${EXPECTED_COUNTS}'"
  fails=$((fails + 1))
fi

# Step 6 write-queue idempotency assertions.
assert_line() {  # <label> <expected-after-prefix>
  local got
  got="$(printf '%s\n' "${RAW_OUT}" | grep -E "^$1\|" | head -1)"
  got="${got#"$1"|}"
  if [[ "${got}" == "$2" ]]; then
    _ok "$1: ${got:-<empty>}"
  else
    _fail "$1: got '${got}' want '$2'"
    fails=$((fails + 1))
  fi
}
assert_line "STEP6A" "T1,T2"   # both matched txns are write candidates
assert_line "STEP6B" "T2"      # after T1 marked written, only T2 remains (no double-pay)

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all reconciliation assertions passed (6 stages + counts + Step 6 idempotency)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
