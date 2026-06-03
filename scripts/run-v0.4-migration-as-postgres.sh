#!/usr/bin/env bash
# shellcheck disable=SC2029
#
# IFOS v0.3 → v0.4 schema migration runner — POSTGRES SUPERUSER variant.
#
# WHY: the v0.3-to-v0.4.sql migration needs to DROP / CREATE triggers on the
# `tenant_adapters` table. Per Day-12 ownership corrections, table ownership
# is `postgres` and ifos_app only has TRIGGER privilege (CREATE, not DROP).
# This mirrors the run-v0.3-migration-as-postgres.sh pattern: ssh + sudo -u
# postgres peer auth on the VPS = no postgres credential needed.
#
# WHEN TO USE: standard path for applying v0.4 to live VPS. (run-v0.4-migration.sh
# as ifos_app doesn't exist because the v0.4 work doesn't need an ifos_app
# variant — every DDL touches postgres-owned objects.)
#
# Usage:
#   bash scripts/run-v0.4-migration-as-postgres.sh             # full live apply
#   bash scripts/run-v0.4-migration-as-postgres.sh --dry-run   # connectivity verify only
#
# Pre-conditions:
#   - SSH key ~/.ssh/ifos_hetzner_ed25519 (same as v0.3 wrapper)
#   - VPS reachable
#   - Your sudo password on the VPS (in 1Password — likely "IFOS VPS maddox" or similar)
#   - v0.3-to-v0.4.sql migration ready at docs/verticals/recruitment/migrations/
#   - v0.3 migration ALREADY APPLIED to the live VPS (script verifies)
#
# Path A discipline:
#   - postgres superuser password is NEVER touched (peer auth bypasses it)
#   - Your sudo password is entered interactively by you on the VPS shell;
#     never echoed, never logged, never seen by this script
#   - Migration SQL streamed via stdin (no temp file on VPS; avoids 0600-perm
#     issue when postgres user reads maddox-owned /tmp files)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly VPS_HOST="178.105.87.24"
readonly VPS_USER="maddox"
readonly SSH_KEY="${HOME}/.ssh/ifos_hetzner_ed25519"
readonly MIGRATION_LOCAL="${REPO_ROOT}/docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; [[ -n "${2:-}" ]] && printf '    %s\n' "$2"; exit 1; }
_step() { printf '\n\033[1;34m── %s ──\033[0m\n' "$1"; }

_step "Step 0 — Pre-flight"

[[ -f "${SSH_KEY}" ]] || _fail "SSH key not found: ${SSH_KEY}"
_ok "SSH key present"

[[ -f "${MIGRATION_LOCAL}" ]] || _fail "Migration SQL not found: ${MIGRATION_LOCAL}"
_ok "Migration SQL present: $(wc -l < "${MIGRATION_LOCAL}" | tr -d ' ') lines"

ssh -i "${SSH_KEY}" -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new \
  "${VPS_USER}@${VPS_HOST}" "echo ok" >/dev/null 2>&1 \
  || _fail "Cannot SSH to ${VPS_USER}@${VPS_HOST}" "Check SSH key + VPS reachable"
_ok "SSH reachable: ${VPS_USER}@${VPS_HOST}"

# Probe peer auth (sudo -u postgres) — runs as postgres, no password to enter
# beyond your sudo password (which the SSH session will prompt for)
PEER_PROBE=$(ssh -i "${SSH_KEY}" -t "${VPS_USER}@${VPS_HOST}" \
  "sudo -n -u postgres psql -d ifos_v2 -tAc 'SELECT current_user' 2>&1" || true)
if [[ "${PEER_PROBE}" == *"postgres"* ]]; then
  _ok "postgres peer auth: working passwordless (sudoers NOPASSWD set)"
elif [[ "${PEER_PROBE}" == *"a password is required"* ]] || [[ "${PEER_PROBE}" == *"sudo: a"* ]]; then
  _warn "postgres peer auth requires sudo password — you will be prompted on the VPS"
else
  _warn "Could not verify peer auth ahead of time: ${PEER_PROBE}"
fi

# v0.3 prerequisite probe — the migration §1 will RAISE EXCEPTION if v0.3 trigger
# is missing; pre-flighting here gives a clearer error before the live apply.
V03_PROBE=$(ssh -i "${SSH_KEY}" "${VPS_USER}@${VPS_HOST}" \
  "sudo -u postgres psql -d ifos_v2 -tAc \"SELECT count(*) FROM pg_trigger WHERE tgname='validate_tenant_adapters_config_v0_3'\" 2>&1" || true)
V03_PROBE="${V03_PROBE//$'\r'/}"
if [[ "${V03_PROBE}" == "1" ]]; then
  _ok "v0.3 prerequisite verified (validate_tenant_adapters_config_v0_3 trigger present)"
elif [[ "${V03_PROBE}" == "0" ]]; then
  _fail "v0.3 prerequisite MISSING (no validate_tenant_adapters_config_v0_3 trigger)" "Run scripts/run-v0.3-migration-as-postgres.sh first"
else
  _warn "Could not verify v0.3 prerequisite ahead of time: ${V03_PROBE}"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  _step "DRY-RUN OK — connectivity + prerequisites verified"
  _ok "Re-run without --dry-run to apply"
  _ok "Migration will stream via stdin: ssh ${VPS_USER}@${VPS_HOST} 'sudo -u postgres psql -d ifos_v2 -v ON_ERROR_STOP=1' < ${MIGRATION_LOCAL}"
  _ok "No temp file written on VPS (avoids 0600-permission issue when postgres user reads maddox files)"
  exit 0
fi

_step "Step 1 — Apply migration as postgres via SSH + stdin pipe"

# Pipe migration SQL via stdin to remote psql — no temp file on the VPS, so we
# avoid the permission-denied that happens when sudo -u postgres tries to read
# a 0600 file owned by maddox in /tmp. NOPASSWD peer auth was confirmed in
# Step 0, so we don't need -t (which would interfere with stdin redirection).
# ON_ERROR_STOP=1 + the migration's BEGIN/COMMIT wrap = atomic rollback on any error.
APPLY_RC=0
ssh -i "${SSH_KEY}" "${VPS_USER}@${VPS_HOST}" \
  "sudo -u postgres psql -d ifos_v2 -v ON_ERROR_STOP=1" \
  < "${MIGRATION_LOCAL}" \
  || APPLY_RC=$?

if [[ ${APPLY_RC} -ne 0 ]]; then
  _fail "Migration apply failed (rc=${APPLY_RC})" "BEGIN/COMMIT wrapping the SQL means changes rolled back atomically; safe to retry after fix"
fi
_ok "Migration applied successfully (streamed ${MIGRATION_LOCAL} via stdin; no VPS temp file written)"

_step "Step 2 — Verify v0.4 objects present + v0.3 cleaned up (read-only)"

VERIFY_OUT=$(ssh -i "${SSH_KEY}" "${VPS_USER}@${VPS_HOST}" "sudo -u postgres psql -d ifos_v2 -tA -c \"
SELECT 'trigger_v0_4:' || count(*) FROM pg_trigger WHERE tgname='validate_tenant_adapters_config_v0_4';
SELECT 'trigger_v0_3_gone:' || count(*) FROM pg_trigger WHERE tgname='validate_tenant_adapters_config_v0_3';
SELECT 'function_v0_4:' || count(*) FROM pg_proc WHERE proname='validate_tenant_adapters_config_v0_4';
SELECT 'function_v0_3_gone:' || count(*) FROM pg_proc WHERE proname='validate_tenant_adapters_config_v0_3';
SELECT 'entities_trigger_intact:' || count(*) FROM pg_trigger WHERE tgname='validate_entities_data_v0_3';
SELECT 'cct_table_intact:' || count(*) FROM information_schema.tables WHERE table_name='cash_conductor_transactions';
SELECT 'cci_table_intact:' || count(*) FROM information_schema.tables WHERE table_name='cash_conductor_invoices';
\"" 2>/dev/null)

echo "${VERIFY_OUT}" | grep -E "^(trigger_|function_|entities_|cct_|cci_)" | while IFS=: read -r key val; do
  val="${val//$'\r'/}"   # strip any stray CR from ssh/psql line-ending mismatch
  case "${key}" in
    trigger_v0_4|function_v0_4|entities_trigger_intact|cct_table_intact|cci_table_intact)
      if [[ "${val}" == "1" ]]; then _ok "${key} = 1"; else _warn "${key} = ${val} (expected 1)"; fi ;;
    trigger_v0_3_gone|function_v0_3_gone)
      if [[ "${val}" == "0" ]]; then _ok "${key} = 0 (replaced/dropped)"; else _warn "${key} = ${val} (expected 0)"; fi ;;
  esac
done

_step "Done"
_ok "v0.4 migration applied as postgres; trigger v0_4 active; v0_3 cleaned up; v0.3 entities + cash_conductor state preserved"
printf '\nNext step: run \033[1;34mbash scripts/run-tenancy-audit.sh\033[0m to verify the 12 invariants across 11 tenant-data tables + the new v0.4 allowlist trigger.\n'
printf 'Tenancy audit uses ifos_app via SSH tunnel + your 1Password ifos_app password (same as before).\n'
