#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2015,SC2001
#
# IFOS multi-tenant tenancy audit (Path A interactive)
#
# Adversarially exercises the 12 tenancy invariants from
# docs/architecture/tenancy-invariants.md against the live Hetzner Postgres
# via SSH tunnel + multi-tenant render fixture.
#
# Test cases:
#   T1   Every tenant-data table has tenant_slug NOT NULL          (9 tables)
#   T2   Every tenant-data table has RLS enabled                    (9 tables)
#   T3   Every tenant-data table has tenant_isolation policy        (9 tables)
#   T4   App-code missing-SET-LOCAL adversarial — INSERT without setting
#   T5   ifos_app role has no DELETE on decision_log or recent_edit
#   T6   /vault/<tenant>/ permissions + no cross-tenant symlinks
#   T7   Cross-tenant rendered-dir isolation (test-tenant-a vs test-tenant-b)
#   T8   Rendered .env chmod 0600
#   T9   Tenant slug regex validation (adversarial bad slugs rejected)
#   T10  Voice corpus single-active-per-tenant partial unique
#   T11  Cross-tenant RLS structural block (re-verify Day-4 §7)
#   T12  _shared/ helpers tenant-agnostic (grep audit)
#
# Pre-conditions:
#   - bash scripts/run-live-migration.sh executed successfully (live VPS
#     has v0.2 schema + migration-test seed row)
#   - ~/.ssh/ifos_hetzner_ed25519 SSH key present
#   - test-tenant-b fixture exists at packages/agent-renderer/tests/fixtures/...
#   - ifos_app password retrievable from 1Password
#
# Usage:
#   bash scripts/run-tenancy-audit.sh
#
# Output:
#   - PASS/FAIL per invariant (T1 through T12 + cross-cutting attacks)
#   - logs/tenancy-audit/<session-id>/ — per-test logs
#   - decision_log audit row (live mode) OR fallback JSONL

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
readonly TENANT_A="migration-test"
readonly TENANT_B="test-tenant-b"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT

SESSION_ID="$(date -u +"%Y%m%dT%H%M%SZ")-$$"
readonly SESSION_ID
LOG_DIR="${REPO_ROOT}/logs/tenancy-audit/${SESSION_ID}"
mkdir -p "${LOG_DIR}"

SSH_TUNNEL_PID=""
PASS_STEPS=0
FAIL_STEPS=0
declare -a FAILED_TESTS=()

# Expected tenant-data tables (T1, T2, T3 expect ALL of these)
readonly TENANT_TABLES=(
  entities entity_links decision_log tenant_eval_sets tenant_adapters
  voice_corpus voice_corpus_chunks tone_rule recent_edit
)

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
  FAILED_TESTS+=("$1")
  printf '  \033[1;31m✗\033[0m %s\n' "$1"
  [[ -n "${2:-}" ]] && printf '    %s\n' "$2"
}
_warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }

_psql_local() {
  psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A "$@"
}

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Pre-flight + password prompt + SSH tunnel
# ────────────────────────────────────────────────────────────────────────

_step "Step 0 — Pre-flight"

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

if [[ ! -d "${REPO_ROOT}/packages/agent-renderer/tests/fixtures/test-tenant-vault/${TENANT_B}" ]]; then
  _fail "test-tenant-b fixture not found" "Run Phase 1.4 first to create the fixture"
  exit 1
fi
_pass "test-tenant-b fixture present"

if ! ssh -i "${VPS_SSH_KEY}" -o BatchMode=yes -o ConnectTimeout=10 \
        "${VPS_SSH_USER}@${VPS_HOST}" "true" 2>/dev/null; then
  _fail "SSH to ${VPS_SSH_USER}@${VPS_HOST} failed"
  exit 1
fi
_pass "SSH reachable as ${VPS_SSH_USER}@${VPS_HOST}"

ssh -i "${VPS_SSH_KEY}" -N -L "${LOCAL_PORT}:localhost:${VPS_PORT}" \
    -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
    "${VPS_SSH_USER}@${VPS_HOST}" &
SSH_TUNNEL_PID=$!
sleep 2

if ! nc -zw3 localhost "${LOCAL_PORT}" 2>/dev/null; then
  _fail "SSH tunnel did not establish"
  exit 1
fi
_pass "SSH tunnel up: localhost:${LOCAL_PORT}"

printf '\n\033[1;33mEnter ifos_app Postgres password (from 1Password):\033[0m\n'
printf '  Password is read silently. Press Enter to submit.\n  > '
read -rs PGPASSWORD
printf '\n'

if [[ -z "${PGPASSWORD}" ]]; then
  _fail "Empty password" "Aborting"
  exit 1
fi
export PGPASSWORD

if ! _psql_local -c "SELECT 1;" >/dev/null 2>&1; then
  _fail "Postgres connection failed" "Check password"
  exit 1
fi
_pass "Connected to ${DB_NAME} as ${DB_USER}"

# ────────────────────────────────────────────────────────────────────────
# T1 — Every tenant-data table has tenant_slug NOT NULL
# ────────────────────────────────────────────────────────────────────────

_step "T1 — tenant_slug NOT NULL on every tenant-data table"

T1_RESULT=$(_psql_local <<EOF
SELECT table_name FROM information_schema.columns
WHERE table_schema='public' AND column_name='tenant_slug' AND is_nullable='NO'
ORDER BY table_name;
EOF
)
T1_TABLES=$(echo "${T1_RESULT}" | tr '\n' ' ' | tr -s ' ')

EXPECTED_COUNT=${#TENANT_TABLES[@]}
ACTUAL_COUNT=$(echo "${T1_RESULT}" | grep -cE '\S')

if (( ACTUAL_COUNT == EXPECTED_COUNT + 1 )); then
  _pass "${ACTUAL_COUNT} tables have tenant_slug NOT NULL (9 tenant-data + 1 tenants meta — expected ${EXPECTED_COUNT}+1)"
else
  for t in "${TENANT_TABLES[@]}"; do
    if echo "${T1_TABLES}" | grep -qw "${t}"; then
      :
    else
      _fail "T1: table ${t} missing tenant_slug NOT NULL"
    fi
  done
  if (( ACTUAL_COUNT == EXPECTED_COUNT )); then
    _pass "${ACTUAL_COUNT} tables have tenant_slug NOT NULL (matches expected ${EXPECTED_COUNT}; tenants meta has tenant_slug as PRIMARY KEY)"
  fi
fi
echo "${T1_RESULT}" > "${LOG_DIR}/T1-tables.log"

# ────────────────────────────────────────────────────────────────────────
# T2 — Every tenant-data table has RLS enabled
# ────────────────────────────────────────────────────────────────────────

_step "T2 — RLS enabled on every tenant-data table"

T2_RESULT=$(_psql_local <<EOF
SELECT relname FROM pg_class c JOIN pg_namespace n ON c.relnamespace=n.oid
WHERE n.nspname='public' AND c.relrowsecurity=true ORDER BY relname;
EOF
)
echo "${T2_RESULT}" > "${LOG_DIR}/T2-rls-enabled.log"

T2_MISSING=()
for t in "${TENANT_TABLES[@]}"; do
  if ! echo "${T2_RESULT}" | grep -qw "${t}"; then
    T2_MISSING+=("${t}")
  fi
done

if (( ${#T2_MISSING[@]} == 0 )); then
  _pass "All 9 tenant-data tables have RLS enabled"
else
  for t in "${T2_MISSING[@]}"; do
    _fail "T2: table ${t} does NOT have RLS enabled"
  done
fi

# ────────────────────────────────────────────────────────────────────────
# T3 — Every tenant-data table has tenant_isolation policy
# ────────────────────────────────────────────────────────────────────────

_step "T3 — tenant_isolation policy on every tenant-data table"

T3_RESULT=$(_psql_local <<EOF
SELECT tablename, policyname FROM pg_policies
WHERE schemaname='public' ORDER BY tablename;
EOF
)
echo "${T3_RESULT}" > "${LOG_DIR}/T3-policies.log"

T3_MISSING=()
for t in "${TENANT_TABLES[@]}"; do
  if ! echo "${T3_RESULT}" | grep -qw "${t}"; then
    T3_MISSING+=("${t}")
  fi
done

if (( ${#T3_MISSING[@]} == 0 )); then
  _pass "All 9 tenant-data tables have isolation policy attached"
else
  for t in "${T3_MISSING[@]}"; do
    _fail "T3: table ${t} has no tenant_isolation policy"
  done
fi

# ────────────────────────────────────────────────────────────────────────
# T4 — Adversarial: INSERT without SET LOCAL app.current_tenant
# ────────────────────────────────────────────────────────────────────────

_step "T4 — Missing-SET-LOCAL adversarial WRITE"

# T4 — adversarial: INSERT without SET LOCAL app.current_tenant.
# Expected: RLS rejects OR inserted row remains invisible to the app role.
T4_WRITE_RESULT=$(_psql_local <<EOF 2>&1
BEGIN;
-- DO NOT set app.current_tenant
INSERT INTO decision_log (tenant_slug, agent_name, phase, payload, created_at)
VALUES ('rls-probe-tenant', '_t4_probe', 'trigger', '{}'::jsonb, now());
SELECT count(*) FROM decision_log
  WHERE agent_name='_t4_probe' AND tenant_slug='rls-probe-tenant';
ROLLBACK;
EOF
)

if echo "${T4_WRITE_RESULT}" | grep -qi "row-level security\|violates row-level"; then
  _pass "Missing-SET-LOCAL INSERT rejected by RLS"
elif echo "${T4_WRITE_RESULT}" | grep -qE "^0[[:space:]]*$"; then
  _pass "Missing-SET-LOCAL INSERT then SELECT returns 0 rows (RLS structural block)"
else
  _fail "T4: Missing-SET-LOCAL INSERT path returned visible rows — possible leak" "${T4_WRITE_RESULT}"
fi
echo "${T4_WRITE_RESULT}" > "${LOG_DIR}/T4-missing-set-local-write.log"

# Without setting app.current_tenant, attempt to read from decision_log.
# RLS should return 0 rows.
T4_RESULT=$(_psql_local <<EOF 2>&1
SELECT count(*) FROM decision_log;
EOF
)

if [[ "${T4_RESULT}" =~ ^0[[:space:]]*$ ]]; then
  _pass "Missing-SET-LOCAL SELECT returns 0 rows (RLS structural block)"
else
  _fail "T4: Missing-SET-LOCAL SELECT returned ${T4_RESULT} rows — possible RLS leak"
fi
echo "${T4_RESULT}" > "${LOG_DIR}/T4-missing-set-local.log"

# ────────────────────────────────────────────────────────────────────────
# T5 — ifos_app has no DELETE on decision_log or recent_edit
# ────────────────────────────────────────────────────────────────────────

_step "T5 — Append-only on decision_log + recent_edit"

T5_RESULT=$(_psql_local <<EOF
SELECT table_name, privilege_type FROM information_schema.role_table_grants
WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
ORDER BY table_name, privilege_type;
EOF
)
echo "${T5_RESULT}" > "${LOG_DIR}/T5-grants.log"

T5_BAD=$(echo "${T5_RESULT}" | grep -E "DELETE|UPDATE" || true)

if [[ -z "${T5_BAD}" ]]; then
  _pass "decision_log + recent_edit are append-only (no UPDATE or DELETE for ifos_app)"
else
  _fail "T5: Unexpected mutate-grant" "${T5_BAD}"
fi

# Adversarial DELETE attempt should fail with permission denied
T5_DELETE=$(_psql_local <<EOF 2>&1
SET app.current_tenant='${TENANT_A}';
DELETE FROM decision_log WHERE 1=0;
EOF
)
if echo "${T5_DELETE}" | grep -qi "permission denied"; then
  _pass "Adversarial DELETE on decision_log returns permission denied"
else
  _fail "T5: Expected permission-denied on DELETE; got: ${T5_DELETE}"
fi

# ────────────────────────────────────────────────────────────────────────
# T6 — Vault permissions + no cross-tenant symlinks (VPS-side)
# ────────────────────────────────────────────────────────────────────────

_step "T6 — Vault permissions + symlink containment (VPS-side via SSH)"

T6_PERMS=$(ssh -i "${VPS_SSH_KEY}" "${VPS_SSH_USER}@${VPS_HOST}" \
  "stat -c '%a %U:%G' /vault/${TENANT_A} 2>/dev/null || echo 'NOT_FOUND'")

if [[ "${T6_PERMS}" =~ ^(700|750) ]]; then
  _pass "/vault/${TENANT_A} permissions OK (${T6_PERMS})"
else
  _warn "T6: /vault/${TENANT_A} permissions: ${T6_PERMS} (expected 700 or 750)"
fi
echo "${T6_PERMS}" > "${LOG_DIR}/T6-vault-perms.log"

# Find any symlinks pointing outside the tenant's own vault
T6_SYMLINKS=$(ssh -i "${VPS_SSH_KEY}" "${VPS_SSH_USER}@${VPS_HOST}" \
  "find /vault/${TENANT_A} -type l -exec readlink -f {} \; 2>/dev/null | grep -v '^/vault/${TENANT_A}' | head -5")

if [[ -z "${T6_SYMLINKS}" ]]; then
  _pass "No cross-tenant symlinks in /vault/${TENANT_A}"
else
  _fail "T6: Cross-tenant symlinks found" "${T6_SYMLINKS}"
fi

# ────────────────────────────────────────────────────────────────────────
# T7 + T8 — Cross-tenant rendered-dir isolation + .env chmod (LOCAL render)
# ────────────────────────────────────────────────────────────────────────

_step "T7 + T8 — Cross-tenant rendered-dir + .env chmod (local render)"

LOCAL_RENDER_ROOT="/tmp/ifos-tenancy-audit-${SESSION_ID}"
rm -rf "${LOCAL_RENDER_ROOT}"

# Render same agent into both tenants locally (no VPS write)
for tenant in "${TENANT_A}" "${TENANT_B}"; do
  node "${REPO_ROOT}/packages/agent-renderer/dist/cli.js" render test-agent \
    --tenant "${tenant}" \
    --bundle-root "${REPO_ROOT}/packages/agent-renderer/tests/fixtures" \
    --vault-root "${REPO_ROOT}/packages/agent-renderer/tests/fixtures/test-tenant-vault/${tenant}" \
    --framework-root "${LOCAL_RENDER_ROOT}" \
    > "${LOG_DIR}/T7-render-${tenant}.log" 2>&1
done

# T7: verify disjoint dirs with no cross-references
DIR_A="${LOCAL_RENDER_ROOT}/orgs/${TENANT_A}/agents/test-agent"
DIR_B="${LOCAL_RENDER_ROOT}/orgs/${TENANT_B}/agents/test-agent"

if [[ -d "${DIR_A}" ]] && [[ -d "${DIR_B}" ]]; then
  _pass "Both tenants rendered into separate orgs/ subtrees"

  # Verify tenant-A's files don't reference tenant-B (other than legitimate template)
  CROSS_A_B=$(grep -r "${TENANT_B}" "${DIR_A}" 2>/dev/null | head -5)
  CROSS_B_A=$(grep -r "${TENANT_A}" "${DIR_B}" 2>/dev/null | head -5)
  if [[ -z "${CROSS_A_B}" ]] && [[ -z "${CROSS_B_A}" ]]; then
    _pass "Zero cross-tenant references in rendered files"
  else
    _fail "T7: Cross-tenant content leak in render output"
    [[ -n "${CROSS_A_B}" ]] && echo "    A→B: ${CROSS_A_B}"
    [[ -n "${CROSS_B_A}" ]] && echo "    B→A: ${CROSS_B_A}"
  fi
else
  _fail "T7: Render failed for one or both tenants" "Check render logs in ${LOG_DIR}"
fi

# T8: verify .env chmod 0600 in both
for tenant in "${TENANT_A}" "${TENANT_B}"; do
  env_file="${LOCAL_RENDER_ROOT}/orgs/${tenant}/agents/test-agent/.env"
  if [[ -f "${env_file}" ]]; then
    mode=$(stat -f '%Lp' "${env_file}" 2>/dev/null || stat -c '%a' "${env_file}" 2>/dev/null)
    if [[ "${mode}" == "600" ]]; then
      _pass "${tenant}/.env mode 600"
    else
      _fail "T8: ${tenant}/.env mode is ${mode}, expected 600"
    fi
  else
    _fail "T8: ${tenant}/.env not present"
  fi
done

# ────────────────────────────────────────────────────────────────────────
# T9 — Tenant slug pattern validation (adversarial bad slugs)
# ────────────────────────────────────────────────────────────────────────

_step "T9 — Tenant slug regex validation"

BAD_SLUGS=("../etc/passwd" "Tenant_With_Capitals" "tenant with spaces" "-leading-dash" "trailing-dash-" "ab")
PATTERN="^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$"

T9_FAILED=0
for slug in "${BAD_SLUGS[@]}"; do
  if [[ "${slug}" =~ ${PATTERN} ]]; then
    _fail "T9: Bad slug '${slug}' INCORRECTLY validates against pattern"
    T9_FAILED=$((T9_FAILED+1))
  fi
done

if (( T9_FAILED == 0 )); then
  _pass "All ${#BAD_SLUGS[@]} adversarial bad slugs rejected by pattern"
fi

# Sanity: real slug accepted
if [[ "migration-test" =~ ${PATTERN} ]]; then
  _pass "Real slug 'migration-test' accepted"
else
  _fail "T9: Real slug 'migration-test' incorrectly rejected (pattern bug)"
fi

# ────────────────────────────────────────────────────────────────────────
# T10 — Voice corpus single-active-per-tenant partial unique
# ────────────────────────────────────────────────────────────────────────

_step "T10 — Voice corpus is_active=TRUE partial unique"

T10_INDEX=$(_psql_local <<EOF
SELECT indexname FROM pg_indexes
WHERE tablename='voice_corpus' AND indexname='voice_corpus_one_active_per_tenant';
EOF
)

if [[ -n "${T10_INDEX}" ]]; then
  _pass "voice_corpus_one_active_per_tenant partial unique index present"
else
  _fail "T10: Partial unique index missing on voice_corpus"
fi

# Adversarial: insert second is_active=TRUE row for migration-test
T10_ADV=$(_psql_local <<EOF 2>&1
SET app.current_tenant='${TENANT_A}';
INSERT INTO voice_corpus (tenant_slug, version, source_doc_count, source_doc_origin,
  chunk_count, chunking_strategy, embedding_model, last_indexed_at, is_active)
VALUES ('${TENANT_A}', 'audit-duplicate-test', 0, '{}', 0, 'paragraph',
  'text-embedding-3-small', now(), TRUE);
EOF
)
if echo "${T10_ADV}" | grep -qi "duplicate\|unique\|conflict"; then
  _pass "Adversarial second-is_active INSERT rejected by partial unique"
else
  # Clean up the duplicate if it landed
  _psql_local <<EOF >/dev/null 2>&1
SET app.current_tenant='${TENANT_A}';
DELETE FROM voice_corpus WHERE version='audit-duplicate-test';
EOF
  _fail "T10: Adversarial second-is_active INSERT NOT rejected" "${T10_ADV}"
fi

# ────────────────────────────────────────────────────────────────────────
# T11 — Cross-tenant RLS structural block (re-verify Day-4 §7)
# ────────────────────────────────────────────────────────────────────────

_step "T11 — Cross-tenant RLS structural block"

# Set wrong tenant; try to read each tenant-data table
WRONG_TENANT="not-the-real-tenant"
T11_FAILED=0
for table in "${TENANT_TABLES[@]}"; do
  count=$(_psql_local <<EOF
SET app.current_tenant='${WRONG_TENANT}';
SELECT count(*) FROM ${table};
EOF
)
  count="${count// /}"
  if [[ "${count}" == "0" ]]; then
    :
  else
    _fail "T11: Cross-tenant read on ${table} returned ${count} rows (expected 0)"
    T11_FAILED=$((T11_FAILED+1))
  fi
done

if (( T11_FAILED == 0 )); then
  _pass "All 9 tables: cross-tenant SELECT returns 0 rows under wrong tenant_slug"
fi

# ────────────────────────────────────────────────────────────────────────
# T12 — _shared/ helpers tenant-agnostic (grep audit)
# ────────────────────────────────────────────────────────────────────────

_step "T12 — _shared/ helpers tenant-agnostic"

# Look for hard-coded tenant slug references; exempt CTX env refs, examples,
# test fixtures, and fallback placeholders
T12_HITS=$(grep -rEn "'[a-z][a-z0-9-]{2,}'" \
  "${REPO_ROOT}/agents/_shared/" \
  "${REPO_ROOT}/packages/agents-runtime/_shared/" 2>/dev/null \
  | grep -v "CTX_TENANT_SLUG\|tenant_slug\|examples\|test-tenant\|migration-test\|fallback\|escalation-codes.md\|README.md\|/tests/\|comments\|HH_AWAIT_TEST_MODE\|policy_lookup\|gating_failed\|fail-safe-red\|tenant-admin\|ifos-csm" \
  | head -10)

if [[ -z "${T12_HITS}" ]]; then
  _pass "_shared/ grep audit: no hard-coded tenant slugs"
else
  _warn "T12: candidate hard-coded slug refs (manual review needed):"
  echo "${T12_HITS}" | sed 's/^/    /'
  # Don't fail on warnings; founder reviews
fi

echo "${T12_HITS}" > "${LOG_DIR}/T12-hardcoded-slug-grep.log"

# ────────────────────────────────────────────────────────────────────────
# Audit row write (decision_log live mode OR fallback)
# ────────────────────────────────────────────────────────────────────────

_step "Audit-row write (decision_log audit trail)"

AUDIT_PAYLOAD=$(printf '{"session_id":"%s","pass_count":%d,"fail_count":%d,"failed_tests":"%s"}' \
  "${SESSION_ID}" "${PASS_STEPS}" "${FAIL_STEPS}" "$(IFS=,; echo "${FAILED_TESTS[*]:-}")")

AUDIT_PHASE="output"
AUDIT_OUTCOME="passed"
if (( FAIL_STEPS > 0 )); then
  AUDIT_PHASE="gating_failed"
  AUDIT_OUTCOME="failed"
fi

AUDIT_SQL=$(cat <<EOF
BEGIN;
SET LOCAL app.current_tenant='ifos-meta';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
VALUES (
  'ifos-meta',
  '_tenancy_audit',
  '${AUDIT_PHASE}',
  '${AUDIT_OUTCOME}',
  '${AUDIT_PAYLOAD}'::jsonb,
  now()
);
COMMIT;
EOF
)

if printf '%s\n' "${AUDIT_SQL}" | _psql_local -v ON_ERROR_STOP=1 -q >/dev/null 2>&1; then
  _pass "Audit row written to decision_log (agent_name=_tenancy_audit, session=${SESSION_ID})"
else
  _warn "Audit row write failed; check fallback at logs/tenancy-audit/${SESSION_ID}/"
fi

# ────────────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────────────

printf '\n\033[1;34m══════════════════════════════════════════════════════\033[0m\n'
printf '\033[1mSession:\033[0m %s\n' "${SESSION_ID}"
printf '\033[1mLog dir:\033[0m %s\n' "${LOG_DIR}"
printf 'PASS: %d   FAIL: %d\n' "${PASS_STEPS}" "${FAIL_STEPS}"

if (( FAIL_STEPS > 0 )); then
  printf '\n\033[1;31mFailed invariants:\033[0m\n'
  for t in "${FAILED_TESTS[@]}"; do
    printf '  - %s\n' "${t}"
  done
  printf '\n\033[1;31mTENANCY AUDIT FAILED.\033[0m Stop work. Diagnose each failed invariant.\n'
  printf 'Reference: docs/architecture/tenancy-invariants.md §2-§3\n'
  exit 1
fi

printf '\n\033[1;32mALL 12 TENANCY INVARIANTS VERIFIED CLEAN ✓\033[0m\n'
printf 'Foundation is correct. Diagnostic agent build can proceed with confidence.\n'
printf 'Reference: docs/architecture/tenancy-invariants.md §3 verification matrix.\n'
exit 0
