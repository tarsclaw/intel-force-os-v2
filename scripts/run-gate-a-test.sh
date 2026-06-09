#!/usr/bin/env bash
# Cash Conductor — Gate A (validate.sh) fixture test (P4c).
#
# Exercises agents/recruitment/cash-conductor/validate.sh against hand-crafted
# drafts covering the PASS path + each hard fail class, asserting exit codes AND
# the ESC routing (ESC_AGENT_OUTPUT_SHAPE vs ESC_ADDRESSEE_MISMATCH).
#
# validate.sh opens its OWN DB connection, so fixtures are COMMITTED then cleaned
# up. The test tenant is registered in `tenants` first because decision_log has a
# FK → tenants (ON DELETE CASCADE) — the ESC rows validate.sh writes need it, and
# deleting the tenant row cascades the decision_log cleanup. Invoices have no such
# FK + ifos_app lacks DELETE on them, so they are seeded idempotently (ON CONFLICT)
# and removed best-effort as the local owner.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="gate-a-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/cash-conductor"
export CTX_AGENT_NAME="cash-conductor" CTX_TENANT_SLUG="${TENANT}"
readonly VALIDATE="${CTX_AGENT_DIR}/validate.sh"
readonly OWNER_DB="${IFOS_OWNER_DB:-ifos_v2_dev}"   # local owner connection for invoice cleanup

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
[[ -f "${VALIDATE}" ]] || { _fail "validate.sh missing"; exit 1; }
TMPD="$(mktemp -d)"

# RLS-scoped psql as ifos_app (no extra args; all queries arrive on stdin).
appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }

# shellcheck disable=SC2329  # invoked indirectly via `trap cleanup EXIT`
cleanup() {
  # tenants delete cascades decision_log; invoices need the owner (ifos_app has no DELETE).
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  psql -U "${USER}" -d "${OWNER_DB}" -q >/dev/null 2>&1 <<SQL || true
BEGIN; SET LOCAL app.current_tenant = '${TENANT}';
DELETE FROM cash_conductor_invoices WHERE tenant_slug = '${TENANT}';
COMMIT;
SQL
  rm -rf "${TMPD}"
}
trap cleanup EXIT

printf '\033[1;34m── Gate A (validate.sh) fixture test ──\033[0m\n'

# Register the tenant (FK target for decision_log) + seed invoices idempotently.
appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Gate A fixture test')
  ON CONFLICT (tenant_slug) DO NOTHING;
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO cash_conductor_invoices
  (tenant_slug, invoice_id, accounting_provider, invoice_number, issued_at, due_at,
   amount_total, amount_paid, status, client_billing_email) VALUES
  (:'tenant','INV-OK','quickbooks','1099', now()-interval '40 days', now()-interval '10 days', 500,0,'open','ap@acme.co'),
  (:'tenant','INV-PAID','quickbooks','1098', now()-interval '40 days', now()-interval '10 days', 500,500,'open','ap@acme.co')
ON CONFLICT (tenant_slug, accounting_provider, invoice_id) DO UPDATE SET
  amount_total = EXCLUDED.amount_total, amount_paid = EXCLUDED.amount_paid,
  status = EXCLUDED.status, client_billing_email = EXCLUDED.client_billing_email;
COMMIT;
SQL

mkdraft() {  # file invoice_id number amount contact pos body_extra
  cat > "$1" <<EOF
---
draft_id: t-$2-p$6
invoice_id: $2
invoice_number: $3
contact_email: $5
subject: "test"
amount_due: $4
days_overdue: 10
escalation_ladder_position: $6
voice_score: unscored
voice_reason: no_corpus
---

Hi,

Friendly reminder about your invoice. $7

Thanks
EOF
}

fails=0
run_case() {  # label expected_exit draft_path
  local label="$1" want="$2" path="$3" got
  bash "${VALIDATE}" "${path}" >/dev/null 2>&1 && got=0 || got=$?
  if [[ "${got}" -eq "${want}" ]]; then
    _ok "${label} (exit ${got})"
  else
    _fail "${label}: exit ${got}, want ${want}"; fails=$((fails + 1))
  fi
}
assert_esc() {  # expected_code
  local want="$1" got
  got="$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT outcome FROM decision_log WHERE tenant_slug = :'tenant' AND phase = 'gating_failed'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
  if [[ "${got}" == "${want}" ]]; then
    _ok "  → ${want}"
  else
    _fail "  → expected ${want}, got '${got}'"; fails=$((fails + 1))
  fi
}

mkdraft "${TMPD}/ok.md"         INV-OK   1099 500 ap@acme.co       1 ""
run_case "PASS: matching draft"            0 "${TMPD}/ok.md"

mkdraft "${TMPD}/badamt.md"     INV-OK   1099 999 ap@acme.co       1 ""
run_case "FAIL G1: amount mismatch"        1 "${TMPD}/badamt.md"
assert_esc ESC_AGENT_OUTPUT_SHAPE

mkdraft "${TMPD}/badnum.md"     INV-OK   9999 500 ap@acme.co       1 ""
run_case "FAIL G1: invoice# mismatch"      1 "${TMPD}/badnum.md"

mkdraft "${TMPD}/badcontact.md" INV-OK   1099 500 stranger@evil.co 1 ""
run_case "FAIL G1: contact mismatch"       1 "${TMPD}/badcontact.md"
assert_esc ESC_ADDRESSEE_MISMATCH

mkdraft "${TMPD}/paid.md"       INV-PAID 1098 0   ap@acme.co       1 ""
run_case "FAIL G2: invoice settled"        1 "${TMPD}/paid.md"

mkdraft "${TMPD}/pii.md"        INV-OK   1099 500 ap@acme.co       1 "Contact me at random.person@gmail.com"
run_case "FAIL G4: external PII in body"   1 "${TMPD}/pii.md"

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all Gate A assertions passed (pass + 5 fail classes + 2 ESC routes)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
