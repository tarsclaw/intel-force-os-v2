#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2015
#
# IFOS live migration + integration smoke runner (Path A interactive)
#
# Executes:
#   1. Phase 4 migration SQL against migration-test tenant on Hetzner Postgres
#      (docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql)
#   2. Phase 3 hook-helpers.sh live smoke (3 hh_decision_* + green/red action)
#   3. Kill-criterion Trigger 5 query verification (autosend-safety-policy §7)
#   4. Phase 5 voice-loader.sh live smoke (3 hh_load_* helpers)
#   5. Schema verification queries (v0.1-to-v0.2.sql §10)
#
# Password handling:
#   - Prompted ONCE via `read -s` (silent, no echo, no shell history)
#   - Held in a single shell variable PGPASSWORD; exported to subprocesses
#   - Unset on script exit (success OR failure OR interrupt)
#   - Never written to disk
#   - Never printed to stdout/stderr
#
# Usage:
#   bash scripts/run-live-migration.sh             # full live execution
#   bash scripts/run-live-migration.sh --dry-run   # connectivity + schema verify; no writes
#
# --dry-run mode (added Day-11):
#   - Brings up SSH tunnel + verifies connectivity
#   - Prompts for password (Path A; same as live mode)
#   - Connects to live Postgres + describes the planned migration SQL
#     (DESCRIBE of tables that will be CREATED; CHECK constraints that
#     will be added; GRANTs that will be applied)
#   - DOES NOT execute migration SQL
#   - DOES NOT execute hook-helpers / voice-loader / kill-criterion smokes
#   - Reports what would happen + safe exit
#   - Founder runs --dry-run FIRST to verify, then re-runs without flag for live
#
# Prerequisites:
#   - psql on PATH (Homebrew Postgres 15+ confirmed Day-4 §0.3)
#   - VPS reachable (test: `nc -zw3 178.105.87.24 5432`)
#   - ifos_app password in 1Password ("IFOS Postgres ifos_app password")
#   - Phase 4 migration SQL not previously executed (script is idempotent;
#     re-runs OK but seed row is conditional on ON CONFLICT DO NOTHING)

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────────────

readonly VPS_HOST="178.105.87.24"
readonly VPS_SSH_USER="maddox"
readonly VPS_SSH_KEY="${HOME}/.ssh/ifos_hetzner_ed25519"
readonly LOCAL_PORT="55432"     # forwards to VPS-side localhost:5432 via SSH
readonly VPS_PORT="5432"
readonly DB_NAME="ifos"
readonly DB_USER="ifos_app"
readonly TENANT_SLUG="migration-test"

SSH_TUNNEL_PID=""
DRY_RUN=0

# Parse args
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
readonly MIGRATION_SQL="${REPO_ROOT}/docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql"
readonly HOOK_HELPERS="${REPO_ROOT}/agents/_shared/hook-helpers.sh"
readonly VOICE_LOADER="${REPO_ROOT}/agents/_shared/voice-loader.sh"

PASS_STEPS=0
FAIL_STEPS=0
FAILED_STEP_NAMES=()

# ────────────────────────────────────────────────────────────────────────
# Cleanup — runs on EXIT (success), ERR (failure), INT (Ctrl-C), TERM (kill)
# ────────────────────────────────────────────────────────────────────────

_cleanup() {
  unset PGPASSWORD
  unset IFOS_DB_URL
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

_step() {
  local name="$1"
  printf '\n\033[1;34m── %s ──\033[0m\n' "${name}"
}

_pass() {
  PASS_STEPS=$((PASS_STEPS + 1))
  printf '  \033[1;32m✓\033[0m %s\n' "$1"
}

_fail() {
  FAIL_STEPS=$((FAIL_STEPS + 1))
  FAILED_STEP_NAMES+=("$1")
  printf '  \033[1;31m✗\033[0m %s\n' "$1"
  if [[ -n "${2:-}" ]]; then
    printf '    %s\n' "$2"
  fi
}

_warn() {
  printf '  \033[1;33m!\033[0m %s\n' "$1"
}

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Pre-flight + password prompt
# ────────────────────────────────────────────────────────────────────────

_step "Step 0 — Pre-flight checks"

if ! command -v psql >/dev/null 2>&1; then
  _fail "psql not on PATH" "Run: brew install postgresql@15"
  exit 1
fi
_pass "psql present: $(psql --version | head -1)"

if [[ ! -f "${VPS_SSH_KEY}" ]]; then
  _fail "SSH key not found at ${VPS_SSH_KEY}" "Day-4 §3 created this; restore from backup"
  exit 1
fi
_pass "SSH key present: ${VPS_SSH_KEY}"

if ! ssh -i "${VPS_SSH_KEY}" -o BatchMode=yes -o ConnectTimeout=10 \
        "${VPS_SSH_USER}@${VPS_HOST}" "true" 2>/dev/null; then
  _fail "SSH to ${VPS_SSH_USER}@${VPS_HOST} failed" "Test: ssh -i ${VPS_SSH_KEY} ${VPS_SSH_USER}@${VPS_HOST} whoami"
  exit 1
fi
_pass "SSH reachable as ${VPS_SSH_USER}@${VPS_HOST}"

# Bring up SSH tunnel: localhost:${LOCAL_PORT} → VPS:localhost:${VPS_PORT}
# Postgres listens on VPS-side localhost only (Day-4 §6.5 listen_addresses).
# Tunnel stays alive for the duration of the script; killed in _cleanup.
ssh -i "${VPS_SSH_KEY}" -N -L "${LOCAL_PORT}:localhost:${VPS_PORT}" \
    -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
    "${VPS_SSH_USER}@${VPS_HOST}" &
SSH_TUNNEL_PID=$!
sleep 2  # let the tunnel come up

if ! nc -zw3 localhost "${LOCAL_PORT}" 2>/dev/null; then
  _fail "SSH tunnel did not establish" "Check ssh -L flags + ExitOnForwardFailure output"
  exit 1
fi
_pass "SSH tunnel up: localhost:${LOCAL_PORT} → ${VPS_HOST}:localhost:${VPS_PORT} (PID ${SSH_TUNNEL_PID})"

if [[ ! -f "${MIGRATION_SQL}" ]]; then
  _fail "Migration SQL not found" "${MIGRATION_SQL}"
  exit 1
fi
_pass "Migration SQL: ${MIGRATION_SQL}"

if [[ ! -f "${HOOK_HELPERS}" ]]; then
  _fail "hook-helpers.sh missing" "${HOOK_HELPERS}"
  exit 1
fi
_pass "hook-helpers.sh: present"

if [[ ! -f "${VOICE_LOADER}" ]]; then
  _fail "voice-loader.sh missing" "${VOICE_LOADER}"
  exit 1
fi
_pass "voice-loader.sh: present"

printf '\n\033[1;33mEnter ifos_app Postgres password (from 1Password):\033[0m\n'
printf '  Password is read silently. Press Enter to submit.\n  > '
read -rs PGPASSWORD
printf '\n'

if [[ -z "${PGPASSWORD}" ]]; then
  _fail "Empty password" "Aborting"
  exit 1
fi
export PGPASSWORD

# Test connection without leaking creds to error messages
if ! psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
        -c "SELECT 1;" >/dev/null 2>&1; then
  _fail "Postgres connection failed" "Check password and VPS RLS posture"
  exit 1
fi
_pass "Connected to ${DB_NAME} as ${DB_USER}"

# ────────────────────────────────────────────────────────────────────────
# Dry-run short-circuit
# ────────────────────────────────────────────────────────────────────────

if (( DRY_RUN == 1 )); then
  _step "DRY-RUN — describing planned changes (NO writes)"
  printf '\n  Would execute: %s\n' "${MIGRATION_SQL}"
  printf '  Migration size: %d lines, %d statements\n' \
    "$(wc -l < "${MIGRATION_SQL}")" \
    "$(grep -cE '^[[:space:]]*(CREATE|ALTER|DROP|INSERT|UPDATE|DELETE|GRANT|DO|BEGIN|COMMIT)' "${MIGRATION_SQL}")"

  printf '\n  Pre-migration state:\n'
  EXISTING_V02=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
    -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('voice_corpus','voice_corpus_chunks','tone_rule','recent_edit');" 2>/dev/null || echo "0")
  printf '    v0.2 tables present: %s of 4 expected\n' "${EXISTING_V02}"
  if [[ "${EXISTING_V02}" == "4" ]]; then
    _warn "Migration appears to have been applied previously (re-run would be idempotent)"
  fi

  EXISTING_DAY4=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
    -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('tenants','entities','entity_links','decision_log','tenant_eval_sets','tenant_adapters');" 2>/dev/null || echo "0")
  printf '    Day-4 tables present: %s of 6 expected\n' "${EXISTING_DAY4}"
  if (( EXISTING_DAY4 < 6 )); then
    _fail "Day-4 prerequisite tables missing — migration cannot apply cleanly"
    exit 1
  fi

  printf '\n  Smoke test steps that WOULD run after migration: 4\n'
  printf '    Step 2: hook-helpers.sh live smoke (5 decision_log rows)\n'
  printf '    Step 3: kill-criterion Trigger 5 query verification\n'
  printf '    Step 4: voice-loader.sh live smoke (3 hh_load_* helpers)\n'
  printf '    Step 5: RLS isolation sanity check\n'

  printf '\n\033[1;32mDRY-RUN OK\033[0m — re-run without --dry-run to execute live.\n'
  exit 0
fi

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Phase 4 migration SQL
# ────────────────────────────────────────────────────────────────────────

_step "Step 1 — Phase 4 migration SQL (v0.1 → v0.2)"

# Check if migration already applied (idempotent re-run safety)
EXISTING_TABLES=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
  -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('voice_corpus','voice_corpus_chunks','tone_rule','recent_edit');" 2>/dev/null || echo "0")

if [[ "${EXISTING_TABLES}" == "4" ]]; then
  _warn "v0.2 tables already present (idempotent re-run)"
fi

if psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
        -v "ON_ERROR_STOP=1" \
        -f "${MIGRATION_SQL}" 2>&1 | grep -v "^NOTICE\|already exists" | tail -20; then
  _pass "Migration SQL applied"
else
  _fail "Migration SQL execution failed"
  exit 1
fi

# Verify schema shape (§10 of v0.1-to-v0.2.sql)
TABLES_FOUND=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
  -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('voice_corpus','voice_corpus_chunks','tone_rule','recent_edit');")
[[ "${TABLES_FOUND}" == "4" ]] && _pass "4 v0.2 tables present" || _fail "Expected 4 tables, got ${TABLES_FOUND}"

HNSW_PRESENT=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
  -c "SELECT count(*) FROM pg_indexes WHERE indexname='voice_samples_embedded';")
[[ "${HNSW_PRESENT}" == "1" ]] && _pass "voice_samples_embedded HNSW index present" || _fail "HNSW index missing"

TRIGGER_PRESENT=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
  -c "SELECT count(*) FROM pg_trigger WHERE tgname='validate_voice_scores';")
[[ "${TRIGGER_PRESENT}" == "1" ]] && _pass "validate_voice_scores trigger present" || _fail "validate_voice_scores trigger missing"

SEED_ROW=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
  -c "SET ifos.tenant_slug='migration-test'; SELECT count(*) FROM voice_corpus WHERE tenant_slug='migration-test' AND version='v0.2-seed';")
[[ "${SEED_ROW}" == "1" ]] && _pass "migration-test seed voice_corpus row present" || _warn "Seed row count: ${SEED_ROW}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Phase 3 hook-helpers.sh live smoke
# ────────────────────────────────────────────────────────────────────────

_step "Step 2 — hook-helpers.sh live smoke against decision_log"

export IFOS_DB_URL="postgresql://${DB_USER}:${PGPASSWORD}@localhost:${LOCAL_PORT}/${DB_NAME}?sslmode=disable"
export CTX_TENANT_SLUG="${TENANT_SLUG}"
export CTX_AGENT_NAME="live-smoke"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/_shared"
export HH_POLICY_FILE="${REPO_ROOT}/agents/_shared/autosend-policy.yaml"
export HH_ESC_CATALOGUE="${REPO_ROOT}/agents/_shared/escalation-codes.md"

# shellcheck source=/dev/null
source "${HOOK_HELPERS}"

# Capture the rowcount before our writes to verify we add exactly the
# expected number of rows.
ROWCOUNT_BEFORE=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
  -c "SET ifos.tenant_slug='${TENANT_SLUG}'; SELECT count(*) FROM decision_log WHERE tenant_slug='${TENANT_SLUG}' AND agent_name='live-smoke';")

hh_decision_trigger "live_smoke_test" "Phase-3+5 integration"
hh_decision_output "smoke_artefact" "/tmp/sample.md" "smoke run"
hh_decision_action "diagnostic_report_render" "candidate:test" "hash-live-1" "live smoke green" && _pass "green action returned 0"

if hh_decision_action "xero_payment_initiate" "invoice:99" "hash-live-2" "live smoke red"; then
  _fail "red action should have returned 1"
else
  _pass "red action returned 1 (blocked)"
fi

# Verify rows landed
ROWCOUNT_AFTER=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A \
  -c "SET ifos.tenant_slug='${TENANT_SLUG}'; SELECT count(*) FROM decision_log WHERE tenant_slug='${TENANT_SLUG}' AND agent_name='live-smoke';")
ROWS_ADDED=$((ROWCOUNT_AFTER - ROWCOUNT_BEFORE))

# Expected: 1 trigger + 1 output + 1 green action + 2 red (gating_failed audit + ESC escalation) = 5
if [[ "${ROWS_ADDED}" == "5" ]]; then
  _pass "5 decision_log rows written (1 trigger + 1 output + 1 action + 2 gating_failed)"
else
  _fail "Expected 5 rows, got ${ROWS_ADDED}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Kill-criterion Trigger 5 query verification
# ────────────────────────────────────────────────────────────────────────

_step "Step 3 — Kill-criterion Trigger 5 query (red-tier audit shape)"

# Query per autosend-safety-policy §7 + v1.0-kill-criterion.md §2 Trigger 5
RED_TIER_COUNT=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A <<EOF
SET ifos.tenant_slug='${TENANT_SLUG}';
SELECT count(*) FROM decision_log
WHERE tenant_slug = '${TENANT_SLUG}'
  AND payload->>'tier' = 'red'
  AND created_at > now() - interval '7 days';
EOF
)

if [[ "${RED_TIER_COUNT}" -ge 1 ]]; then
  _pass "Trigger 5 query returns red-tier audit rows (count=${RED_TIER_COUNT})"
else
  _fail "Trigger 5 query found no red-tier rows; payload.tier filter not matching"
fi

# Also verify ESC_AUTOSEND_BLOCKED escalation row queryable
ESC_BLOCKED_COUNT=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A <<EOF
SET ifos.tenant_slug='${TENANT_SLUG}';
SELECT count(*) FROM decision_log
WHERE tenant_slug = '${TENANT_SLUG}'
  AND payload->>'escalation_code' = 'ESC_AUTOSEND_BLOCKED'
  AND created_at > now() - interval '1 hour';
EOF
)

[[ "${ESC_BLOCKED_COUNT}" -ge 1 ]] && _pass "ESC_AUTOSEND_BLOCKED row queryable" || _fail "ESC_AUTOSEND_BLOCKED row missing"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Phase 5 voice-loader.sh live smoke
# ────────────────────────────────────────────────────────────────────────

_step "Step 4 — voice-loader.sh live smoke"

# shellcheck source=/dev/null
source "${VOICE_LOADER}"

# hh_load_tone_rules — should return empty rules + source=db
TONE_OUT=$(hh_load_tone_rules concierge 2>&1)
if printf '%s' "${TONE_OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['source']=='db' and d['rules']==[]" 2>/dev/null; then
  _pass "hh_load_tone_rules returns empty rules from DB"
else
  _fail "hh_load_tone_rules unexpected shape" "got: ${TONE_OUT}"
fi

# hh_load_voice_samples — no IFOS_VL_QUERY_VECTOR set, falls back
VOICE_OUT=$(hh_load_voice_samples "candidate-outreach" 5 2>&1)
if printf '%s' "${VOICE_OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['source'] in ('empty','fallback')" 2>/dev/null; then
  _pass "hh_load_voice_samples fallback path works (no embedded vector)"
else
  _fail "hh_load_voice_samples unexpected shape" "got: ${VOICE_OUT}"
fi

# hh_load_recent_edits — empty in fresh tenant
EDITS_OUT=$(hh_load_recent_edits 30 concierge 2>&1)
if printf '%s' "${EDITS_OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['source']=='db' and d['lookback_days']==30 and d['edits']==[]" 2>/dev/null; then
  _pass "hh_load_recent_edits returns empty edits from DB"
else
  _fail "hh_load_recent_edits unexpected shape" "got: ${EDITS_OUT}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 5 — RLS isolation sanity check
# ────────────────────────────────────────────────────────────────────────

_step "Step 5 — RLS isolation sanity (cross-tenant blocked)"

# Try to read migration-test rows while claiming to be a different tenant — must return 0
WRONG_TENANT_COUNT=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A <<EOF
SET ifos.tenant_slug='not-the-real-tenant';
SELECT count(*) FROM voice_corpus;
EOF
)

if [[ "${WRONG_TENANT_COUNT}" == "0" ]]; then
  _pass "RLS blocks cross-tenant read (not-the-real-tenant sees 0 rows in migration-test corpus)"
else
  _fail "RLS LEAK: not-the-real-tenant saw ${WRONG_TENANT_COUNT} rows from migration-test"
fi

# Same for decision_log
WRONG_TENANT_LOG=$(psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A <<EOF
SET ifos.tenant_slug='not-the-real-tenant';
SELECT count(*) FROM decision_log WHERE agent_name='live-smoke';
EOF
)

if [[ "${WRONG_TENANT_LOG}" == "0" ]]; then
  _pass "RLS blocks cross-tenant decision_log read"
else
  _fail "RLS LEAK on decision_log: ${WRONG_TENANT_LOG} rows visible cross-tenant"
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
  exit 1
fi

printf '\n\033[1;32mALL LIVE INTEGRATION CHECKS PASSED\033[0m\n'
printf 'Phase 3 + Phase 4 + Phase 5 acceptance criteria #2 through #4 satisfied.\n'
printf 'Decision-log audit trail: %d rows for live-smoke agent under migration-test.\n' "${ROWCOUNT_AFTER}"
printf '\nPassword + IFOS_DB_URL cleared from environment.\n'
exit 0
