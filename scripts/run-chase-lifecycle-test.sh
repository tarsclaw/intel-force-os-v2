#!/usr/bin/env bash
# Cash Conductor — chase lifecycle fixture test (P4d: Steps 11-12).
#
# Step 11 (chase-sent state mutation) + Step 12 (paid-since race cancellation).
# Mirrors the SQL behaviour in cycle.sh Steps 11-12; all fixtures seed inside ONE
# ROLLBACK'd transaction (touches only cash_conductor_invoices — no FK, no commit
# needed), RLS-scoped to a throwaway tenant.

set -uo pipefail

readonly TENANT="lifecycle-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
printf '\033[1;34m── Chase lifecycle fixture test (Steps 11-12) ──\033[0m\n'

RAW="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}" <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
INSERT INTO cash_conductor_invoices
  (tenant_slug, invoice_id, accounting_provider, invoice_number, issued_at, due_at,
   amount_total, amount_paid, status, last_chase_position) VALUES
  (:'tenant','L1','quickbooks','2001', now()-interval '40 days', now()-interval '10 days', 500,0,'open',0),
  (:'tenant','PAID','quickbooks','2002', now()-interval '40 days', now()-interval '10 days', 500,500,'open',1);

-- Step 11: record a chase send (position 2) against L1.
UPDATE cash_conductor_invoices
SET last_chase_position = 2, last_chase_sent_at = now()
WHERE invoice_id = 'L1';
SELECT 'S11|' || last_chase_position || '|' || (last_chase_sent_at IS NOT NULL)
FROM cash_conductor_invoices WHERE invoice_id = 'L1';

-- Step 12: paid-since race check — cancel when amount_due ≤ 0.
SELECT 'S12|' || invoice_id || '|' || ((amount_total - amount_paid) <= 0)
FROM cash_conductor_invoices WHERE invoice_id IN ('L1','PAID') ORDER BY invoice_id;

ROLLBACK;
SQL
)"

fails=0
assert_line() {  # <expected-line> <label>
  if printf '%s\n' "${RAW}" | grep -Fxq "$1"; then _ok "$2"; else _fail "$2 (missing: $1)"; fails=$((fails+1)); fi
}

assert_line "S11|2|true"    "Step 11: last_chase_position→2 + last_chase_sent_at set"
assert_line "S12|L1|false"  "Step 12: unpaid invoice → NOT cancelled"
assert_line "S12|PAID|true" "Step 12: paid-since invoice → cancelled (ESC_AUTOSEND_RACE)"

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all chase lifecycle assertions passed (Step 11 mutation + Step 12 race)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
