#!/usr/bin/env bash
# shellcheck disable=SC2029
#
# IFOS v0.2 → v0.3 schema migration runner — POSTGRES SUPERUSER variant.
#
# WHY: the v0.2-to-v0.3.sql migration needs to DROP / CREATE triggers on the
# `entities` table. Per Day-12 ownership corrections, `entities` is owned by
# `postgres` and ifos_app has TRIGGER privilege (CREATE only — DROP TRIGGER
# requires table ownership, not just TRIGGER privilege). The existing
# scripts/run-v0.3-migration.sh runs as ifos_app and fails at line 409.
#
# This script applies the same migration but as `postgres` via SSH + `sudo -u
# postgres` peer auth on the VPS — peer auth bypasses the postgres password
# entirely (no postgres credential needed; you only enter your VPS sudo
# password, which is your normal maddox-user password).
#
# WHEN TO USE: only when run-v0.3-migration.sh fails with "must be owner of
# relation entities" or similar. This is the standard pattern for any future
# migration that needs DDL on postgres-owned tables.
#
# Usage:
#   bash scripts/run-v0.3-migration-as-postgres.sh             # full live apply
#   bash scripts/run-v0.3-migration-as-postgres.sh --dry-run   # connectivity verify only
#
# Pre-conditions:
#   - SSH key ~/.ssh/ifos_hetzner_ed25519 (same as ifos_app variant)
#   - VPS reachable
#   - Your sudo password on the VPS (in 1Password — likely "IFOS VPS maddox" or similar)
#   - v0.2-to-v0.3.sql migration ready at docs/verticals/recruitment/migrations/
#
# Path A discipline:
#   - postgres superuser password is NEVER touched (peer auth bypasses it)
#   - Your sudo password is entered interactively by you on the VPS shell;
#     never echoed, never logged, never seen by this script
#   - Migration SQL is copied to /tmp on VPS mode 0600 then deleted post-apply

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly VPS_HOST="178.105.87.24"
readonly VPS_USER="maddox"
readonly SSH_KEY="${HOME}/.ssh/ifos_hetzner_ed25519"
readonly MIGRATION_LOCAL="${REPO_ROOT}/docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql"
readonly SESSION_TAG="$(date -u +"%Y%m%dT%H%M%SZ")-$$"
readonly MIGRATION_REMOTE="/tmp/v0.3-migration-${SESSION_TAG}.sql"

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

if [[ $DRY_RUN -eq 1 ]]; then
  _step "DRY-RUN OK — connectivity verified"
  _ok "Re-run without --dry-run to apply"
  _ok "Migration will be: scp ${MIGRATION_LOCAL} -> ${VPS_HOST}:${MIGRATION_REMOTE}"
  _ok "Then: ssh ${VPS_USER}@${VPS_HOST} 'sudo -u postgres psql ifos_v2 -f ${MIGRATION_REMOTE}'"
  exit 0
fi

_step "Step 1 — Copy migration SQL to VPS (mode 0600)"

scp -i "${SSH_KEY}" -q "${MIGRATION_LOCAL}" "${VPS_USER}@${VPS_HOST}:${MIGRATION_REMOTE}"
ssh -i "${SSH_KEY}" "${VPS_USER}@${VPS_HOST}" "chmod 600 ${MIGRATION_REMOTE}"
_ok "Copied to ${VPS_HOST}:${MIGRATION_REMOTE}"

_step "Step 2 — Apply as postgres via sudo (you may be prompted for your VPS sudo password)"

# -t allocates a tty so sudo can prompt for password
# ON_ERROR_STOP=1 + the migration's own BEGIN/COMMIT wrap = atomic rollback on any error
APPLY_RC=0
ssh -i "${SSH_KEY}" -t "${VPS_USER}@${VPS_HOST}" \
  "sudo -u postgres psql -d ifos_v2 -v ON_ERROR_STOP=1 -f ${MIGRATION_REMOTE}" \
  || APPLY_RC=$?

# Cleanup the temp file on VPS regardless of outcome
ssh -i "${SSH_KEY}" "${VPS_USER}@${VPS_HOST}" "rm -f ${MIGRATION_REMOTE}" || true
_ok "Cleaned up ${MIGRATION_REMOTE} on VPS"

if [[ ${APPLY_RC} -ne 0 ]]; then
  _fail "Migration apply failed (rc=${APPLY_RC})" "BEGIN/COMMIT wrapping the SQL means changes rolled back atomically; safe to retry after fix"
fi
_ok "Migration applied successfully"

_step "Step 3 — Verify new objects present (read-only; runs as postgres on VPS)"

VERIFY_OUT=$(ssh -i "${SSH_KEY}" -t "${VPS_USER}@${VPS_HOST}" "sudo -u postgres psql -d ifos_v2 -tA -c \"
SELECT 'cct_table:' || count(*) FROM information_schema.tables WHERE table_name='cash_conductor_transactions';
SELECT 'cci_table:' || count(*) FROM information_schema.tables WHERE table_name='cash_conductor_invoices';
SELECT 'cct_owner:' || tableowner FROM pg_tables WHERE tablename='cash_conductor_transactions';
SELECT 'cci_owner:' || tableowner FROM pg_tables WHERE tablename='cash_conductor_invoices';
SELECT 'trigger_entities_v0_3:' || count(*) FROM pg_trigger WHERE tgname='validate_entities_data_v0_3';
SELECT 'trigger_voice_scores_gone:' || count(*) FROM pg_trigger WHERE tgname='validate_voice_scores';
SELECT 'trigger_tenant_adapters:' || count(*) FROM pg_trigger WHERE tgname='validate_tenant_adapters_config_v0_3';
\"" 2>/dev/null)

echo "${VERIFY_OUT}" | grep -E "^(cct_table|cci_table|cct_owner|cci_owner|trigger_)" | while IFS=: read -r key val; do
  case "${key}" in
    cct_table|cci_table|trigger_entities_v0_3|trigger_tenant_adapters)
      [[ "${val}" == "1" ]] && _ok "${key} = 1" || _warn "${key} = ${val} (expected 1)" ;;
    trigger_voice_scores_gone)
      [[ "${val}" == "0" ]] && _ok "${key} = 0 (replaced)" || _warn "${key} = ${val} (expected 0)" ;;
    cct_owner|cci_owner)
      [[ "${val}" == "postgres" ]] && _ok "${key} = postgres (per Day-12 lesson)" || _warn "${key} = ${val} (expected postgres)" ;;
  esac
done

_step "Done"
_ok "v0.3 migration applied as postgres; cash_conductor tables owned by postgres (Day-12 compliant); entities trigger rebound"
printf '\nNext step: run \033[1;34mbash scripts/run-tenancy-audit.sh\033[0m to verify the 12 invariants across 11 tenant-data tables.\n'
printf 'Tenancy audit uses ifos_app via SSH tunnel + your 1Password ifos_app password (same as before).\n'
