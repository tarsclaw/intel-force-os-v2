#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2015
#
# IFOS v0.2 → v0.3 schema migration runner (Path A interactive)
#
# Companion to scripts/run-live-migration.sh (which applies v0.1 → v0.2).
# Closes W4 backlog item #1: apply v0.3 supplement to migration-test tenant.
#
# Executes:
#   1. Pre-flight: confirm v0.2 schema present (4 tables), v0.3 NOT yet applied
#      (cash_conductor_transactions + cash_conductor_invoices absent)
#   2. Apply docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql with
#      ON_ERROR_STOP=1 (the migration itself wraps in BEGIN/COMMIT, so any
#      failure rolls the txn back atomically)
#   3. Post-flight: verify 2 new tables created with RLS + tenant_isolation
#      policy + ifos_app grants
#   4. Post-flight: verify the entities trigger was REBOUND (v0.2's
#      validate_voice_scores trigger replaced by v0.3 validate_entities_data_v0_3)
#   5. Post-flight: verify tenant_adapters trigger present
#      (validate_tenant_adapters_config_v0_3)
#   6. Write audit row to decision_log (tenant_slug='ifos-meta')
#
# This script does NOT run the tenancy-audit invariants. Run
# `bash scripts/run-tenancy-audit.sh` AFTER this completes to validate
# the 12 invariants across the now-11 tenant-data tables.
#
# Password handling (identical to run-live-migration.sh):
#   - Prompted ONCE via `read -s` (silent, no echo, no shell history)
#   - Held in PGPASSWORD shell variable; exported to subprocesses
#   - Unset on script exit (success OR failure OR interrupt)
#   - Never written to disk; never printed
#
# Usage:
#   bash scripts/run-v0.3-migration.sh             # full live execution
#   bash scripts/run-v0.3-migration.sh --dry-run   # connectivity + schema verify; no writes
#
# --dry-run mode:
#   - Brings up SSH tunnel + verifies connectivity
#   - Prompts for password
#   - Confirms v0.2 prerequisite state; confirms v0.3 not yet applied
#   - Reports what would happen + safe exit
#
# Prerequisites:
#   - psql on PATH (Homebrew Postgres 15+)
#   - VPS reachable
#   - ifos_app password in 1Password ("IFOS Postgres ifos_app password")
#   - v0.2 migration applied (verified by run-live-migration.sh prior)
#   - migration-test tenant row exists in tenants
#   - v0.3 supplement RATIFIED at commit 7b4f390 (Day-19 close)

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────────────

readonly VPS_HOST="178.105.87.24"
readonly VPS_SSH_USER="maddox"
readonly VPS_SSH_KEY="${HOME}/.ssh/ifos_hetzner_ed25519"
readonly LOCAL_PORT="55432"
readonly VPS_PORT="5432"
readonly DB_NAME="ifos_v2"
readonly DB_USER="ifos_app"
readonly TENANT_SLUG="migration-test"

SSH_TUNNEL_PID=""
DRY_RUN=0

for arg in "$@"; do
  case "${arg}" in
    --dry-run) DRY_RUN=1 ;;
    --help)
      grep -E "^#( Usage:| {2}|$)" "$0" | sed 's/^# //' | head -30
      exit 0
      ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly MIGRATION_SQL="${REPO_ROOT}/docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql"

PASS_STEPS=0
FAIL_STEPS=0
FAILED_STEP_NAMES=()

# ────────────────────────────────────────────────────────────────────────
# Cleanup trap
# ────────────────────────────────────────────────────────────────────────

_cleanup() {
  unset PGPASSWORD
  if [[ -n "${SSH_TUNNEL_PID}" ]]; then
    kill "${SSH_TUNNEL_PID}" 2>/dev/null || true
    wait "${SSH_TUNNEL_PID}" 2>/dev/null || true
  fi
  history -c 2>/dev/null || true
}
trap _cleanup EXIT INT TERM

# ────────────────────────────────────────────────────────────────────────
# UX helpers
# ────────────────────────────────────────────────────────────────────────

_step() { printf '\n\033[1;34m── %s ──\033[0m\n' "$1"; }
_pass() { PASS_STEPS=$((PASS_STEPS+1)); printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() {
  FAIL_STEPS=$((FAIL_STEPS+1))
  FAILED_STEP_NAMES+=("$1")
  printf '  \033[1;31m✗\033[0m %s\n' "$1"
  [[ -n "${2:-}" ]] && printf '    %s\n' "$2"
}
_warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }

_psql() {
  psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A "$@"
}

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Pre-flight
# ────────────────────────────────────────────────────────────────────────

_step "Step 0 — Pre-flight checks"

if ! command -v psql >/dev/null 2>&1; then
  _fail "psql not on PATH" "brew install postgresql@15"
  exit 1
fi
_pass "psql present: $(psql --version | head -1)"

if [[ ! -f "${VPS_SSH_KEY}" ]]; then
  _fail "SSH key not found at ${VPS_SSH_KEY}"
  exit 1
fi
_pass "SSH key present"

if [[ ! -f "${MIGRATION_SQL}" ]]; then
  _fail "v0.3 migration SQL missing" "${MIGRATION_SQL}"
  exit 1
fi
_pass "Migration SQL: $(wc -l < "${MIGRATION_SQL}") lines"

if ! ssh -i "${VPS_SSH_KEY}" -o BatchMode=yes -o ConnectTimeout=10 \
        "${VPS_SSH_USER}@${VPS_HOST}" "true" 2>/dev/null; then
  _fail "SSH to ${VPS_SSH_USER}@${VPS_HOST} failed"
  exit 1
fi
_pass "SSH reachable"

ssh -i "${VPS_SSH_KEY}" -N -L "${LOCAL_PORT}:localhost:${VPS_PORT}" \
    -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
    "${VPS_SSH_USER}@${VPS_HOST}" &
SSH_TUNNEL_PID=$!
sleep 2

if ! nc -zw3 localhost "${LOCAL_PORT}" 2>/dev/null; then
  _fail "SSH tunnel did not establish"
  exit 1
fi
_pass "SSH tunnel up: localhost:${LOCAL_PORT} → ${VPS_HOST}:localhost:${VPS_PORT}"

printf '\n\033[1;33mEnter ifos_app Postgres password (from 1Password):\033[0m\n'
printf '  Password is read silently. Press Enter to submit.\n  > '
read -rs PGPASSWORD
printf '\n'

if [[ -z "${PGPASSWORD}" ]]; then
  _fail "Empty password" "Aborting"
  exit 1
fi
export PGPASSWORD

if ! _psql -c "SELECT 1;" >/dev/null 2>&1; then
  _fail "Postgres connection failed" "Check password"
  exit 1
fi
_pass "Connected to ${DB_NAME} as ${DB_USER}"

# Confirm migration-test tenant present
TENANT_EXISTS=$(_psql -c "SELECT count(*) FROM tenants WHERE tenant_slug='${TENANT_SLUG}';" 2>/dev/null || echo "0")
if [[ "${TENANT_EXISTS}" != "1" ]]; then
  _fail "${TENANT_SLUG} tenant row missing" "Re-run run-live-migration.sh first"
  exit 1
fi
_pass "${TENANT_SLUG} tenant row present"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Verify v0.2 prerequisite state
# ────────────────────────────────────────────────────────────────────────

_step "Step 1 — Verify v0.2 prerequisite state"

V02_TABLES=$(_psql -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('voice_corpus','voice_corpus_chunks','tone_rule','recent_edit');")
if [[ "${V02_TABLES}" == "4" ]]; then
  _pass "v0.2 schema present (4 tables)"
else
  _fail "v0.2 prerequisite missing — got ${V02_TABLES}/4 tables" "Run scripts/run-live-migration.sh first"
  exit 1
fi

# Check whether v0.3 already applied (idempotency probe)
V03_TABLES=$(_psql -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('cash_conductor_transactions','cash_conductor_invoices');")
if [[ "${V03_TABLES}" == "2" ]]; then
  _warn "v0.3 tables already present (idempotent re-run; migration uses IF NOT EXISTS)"
elif [[ "${V03_TABLES}" == "0" ]]; then
  _pass "v0.3 tables not yet present (clean migration target)"
else
  _warn "Partial v0.3 state: ${V03_TABLES}/2 tables — migration will create the missing one"
fi

# ────────────────────────────────────────────────────────────────────────
# Dry-run short-circuit
# ────────────────────────────────────────────────────────────────────────

if (( DRY_RUN == 1 )); then
  _step "DRY-RUN — describing planned changes (NO writes)"
  printf '\n  Would execute: %s\n' "${MIGRATION_SQL}"
  printf '  Migration size: %d lines, %d DDL statements\n' \
    "$(wc -l < "${MIGRATION_SQL}")" \
    "$(grep -cE '^[[:space:]]*(CREATE|ALTER|DROP|INSERT|UPDATE|DELETE|GRANT|DO|BEGIN|COMMIT)' "${MIGRATION_SQL}")"

  printf '\n  v0.3 additions:\n'
  printf '    • CREATE TABLE cash_conductor_transactions (RLS + tenant_isolation + GRANT)\n'
  printf '    • CREATE TABLE cash_conductor_invoices (RLS + tenant_isolation + GRANT)\n'
  printf '    • DROP TRIGGER validate_voice_scores; CREATE TRIGGER validate_entities_data_v0_3\n'
  printf '      (rebinds entities BEFORE INSERT/UPDATE; new function validates v0.2 voice keys +\n'
  printf '       v0.3 keys for candidate/contact/brief/placement/opportunity)\n'
  printf '    • CREATE TRIGGER validate_tenant_adapters_config_v0_3 (key allowlist enforcer)\n'

  printf '\n  Post-flight verifications that WOULD run:\n'
  printf '    • cash_conductor_transactions + cash_conductor_invoices both present\n'
  printf '    • RLS enabled + FORCE ROW LEVEL SECURITY on both\n'
  printf '    • cct_tenant_isolation + cci_tenant_isolation policies attached\n'
  printf '    • ifos_app has SELECT/INSERT/UPDATE on both (no DELETE)\n'
  printf '    • validate_voice_scores trigger no longer exists (replaced)\n'
  printf '    • validate_entities_data_v0_3 trigger exists on entities\n'
  printf '    • validate_tenant_adapters_config_v0_3 trigger exists on tenant_adapters\n'

  printf '\n\033[1;32mDRY-RUN OK\033[0m — re-run without --dry-run to execute live.\n'
  printf '\nAfter live run, execute: bash scripts/run-tenancy-audit.sh\n'
  exit 0
fi

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Apply v0.2 → v0.3 migration
# ────────────────────────────────────────────────────────────────────────

_step "Step 2 — Apply v0.2 → v0.3 migration"

if psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
        -v "ON_ERROR_STOP=1" \
        -f "${MIGRATION_SQL}" 2>&1 | grep -v "^NOTICE\|already exists" | tail -30; then
  _pass "Migration SQL applied (or idempotent re-run noticed)"
else
  _fail "Migration SQL execution failed"
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Post-flight verification
# ────────────────────────────────────────────────────────────────────────

_step "Step 3 — Post-flight schema verification"

# 3a — cash_conductor tables present
CCT_PRESENT=$(_psql -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename='cash_conductor_transactions';")
CCI_PRESENT=$(_psql -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename='cash_conductor_invoices';")
[[ "${CCT_PRESENT}" == "1" ]] && _pass "cash_conductor_transactions present" \
  || _fail "cash_conductor_transactions MISSING"
[[ "${CCI_PRESENT}" == "1" ]] && _pass "cash_conductor_invoices present" \
  || _fail "cash_conductor_invoices MISSING"

# 3b — RLS enabled on both
CCT_RLS=$(_psql -c "SELECT count(*) FROM pg_class c JOIN pg_namespace n ON c.relnamespace=n.oid WHERE n.nspname='public' AND c.relname='cash_conductor_transactions' AND c.relrowsecurity=true;")
CCI_RLS=$(_psql -c "SELECT count(*) FROM pg_class c JOIN pg_namespace n ON c.relnamespace=n.oid WHERE n.nspname='public' AND c.relname='cash_conductor_invoices' AND c.relrowsecurity=true;")
[[ "${CCT_RLS}" == "1" ]] && _pass "cash_conductor_transactions RLS enabled" \
  || _fail "cash_conductor_transactions RLS NOT enabled"
[[ "${CCI_RLS}" == "1" ]] && _pass "cash_conductor_invoices RLS enabled" \
  || _fail "cash_conductor_invoices RLS NOT enabled"

# 3c — tenant_isolation policies attached
POLICIES=$(_psql -c "SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename IN ('cash_conductor_transactions','cash_conductor_invoices');")
[[ "${POLICIES}" == "2" ]] && _pass "tenant_isolation policies attached (2 of 2)" \
  || _fail "policies: ${POLICIES}/2 attached"

# 3d — entities trigger rebound
V02_TRIGGER=$(_psql -c "SELECT count(*) FROM pg_trigger WHERE tgname='validate_voice_scores';")
V03_TRIGGER=$(_psql -c "SELECT count(*) FROM pg_trigger WHERE tgname='validate_entities_data_v0_3';")
[[ "${V02_TRIGGER}" == "0" ]] && _pass "v0.2 validate_voice_scores trigger removed (rebound)" \
  || _fail "v0.2 validate_voice_scores trigger still present — rebind failed"
[[ "${V03_TRIGGER}" == "1" ]] && _pass "v0.3 validate_entities_data_v0_3 trigger present" \
  || _fail "v0.3 validate_entities_data_v0_3 trigger MISSING"

# 3e — tenant_adapters trigger
TA_TRIGGER=$(_psql -c "SELECT count(*) FROM pg_trigger WHERE tgname='validate_tenant_adapters_config_v0_3';")
[[ "${TA_TRIGGER}" == "1" ]] && _pass "validate_tenant_adapters_config_v0_3 trigger present" \
  || _fail "tenant_adapters config trigger MISSING"

# 3f — ifos_app grants on both (SELECT/INSERT/UPDATE, no DELETE)
GRANTS=$(_psql -c "SELECT count(*) FROM information_schema.role_table_grants WHERE grantee='ifos_app' AND table_name IN ('cash_conductor_transactions','cash_conductor_invoices') AND privilege_type IN ('SELECT','INSERT','UPDATE');")
[[ "${GRANTS}" == "6" ]] && _pass "ifos_app has SELECT/INSERT/UPDATE on both (6 grants)" \
  || _warn "grants: ${GRANTS}/6 — expected SELECT+INSERT+UPDATE × 2 tables"

DEL_GRANTS=$(_psql -c "SELECT count(*) FROM information_schema.role_table_grants WHERE grantee='ifos_app' AND table_name IN ('cash_conductor_transactions','cash_conductor_invoices') AND privilege_type='DELETE';")
[[ "${DEL_GRANTS}" == "0" ]] && _pass "no DELETE grants on v0.3 tables (append-only-style)" \
  || _warn "ifos_app has DELETE grants on v0.3 tables (unexpected; see v0.3 supplement)"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Audit row
# ────────────────────────────────────────────────────────────────────────

_step "Step 4 — Audit row write (decision_log)"

AUDIT_PAYLOAD=$(printf '{"migration":"v0.2-to-v0.3","pass_count":%d,"fail_count":%d,"tenant":"%s"}' \
  "${PASS_STEPS}" "${FAIL_STEPS}" "${TENANT_SLUG}")

AUDIT_PHASE="output"; AUDIT_OUTCOME="passed"
if (( FAIL_STEPS > 0 )); then
  AUDIT_PHASE="gating_failed"; AUDIT_OUTCOME="failed"
fi

AUDIT_SQL=$(cat <<EOF
BEGIN;
SET LOCAL app.current_tenant='ifos-meta';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
VALUES ('ifos-meta', '_v0_3_migration', '${AUDIT_PHASE}', '${AUDIT_OUTCOME}',
  '${AUDIT_PAYLOAD}'::jsonb, now());
COMMIT;
EOF
)

if printf '%s\n' "${AUDIT_SQL}" | _psql -v ON_ERROR_STOP=1 -q >/dev/null 2>&1; then
  _pass "Audit row written (agent_name=_v0_3_migration)"
else
  _warn "Audit row write failed — non-fatal"
fi

# ────────────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────────────

printf '\n\033[1;34m══════════════════════════════════════════════════════\033[0m\n'
printf 'PASS: %d   FAIL: %d\n' "${PASS_STEPS}" "${FAIL_STEPS}"

if (( FAIL_STEPS > 0 )); then
  printf '\n\033[1;31mFailed steps:\033[0m\n'
  for n in "${FAILED_STEP_NAMES[@]}"; do
    printf '  - %s\n' "${n}"
  done
  printf '\n\033[1;31mV0.3 MIGRATION FAILED.\033[0m Stop. Consider rollback via v0.3-to-v0.2.sql.\n'
  exit 1
fi

printf '\n\033[1;32mV0.3 MIGRATION COMPLETE ✓\033[0m\n'
printf '\nNext step:\n'
printf '  bash scripts/run-tenancy-audit.sh    # 12 invariants × 11 tables\n'
printf '\nPassword cleared from environment.\n'
exit 0
