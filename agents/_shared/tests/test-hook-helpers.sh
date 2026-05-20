#!/usr/bin/env bash
# shellcheck disable=SC2329  # test/assert helpers called via && chains (false-positive)
#
# Offline test harness for agents/_shared/hook-helpers.sh.
# Exercises every public helper via fallback-mode (no live Postgres needed).
#
# Run: bash agents/_shared/tests/test-hook-helpers.sh
# Exit code 0 = all pass; 1 = any fail.

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Test harness primitives
# ────────────────────────────────────────────────────────────────────────

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_NAMES=()

_test_run() {
  local name="$1"
  shift
  TESTS_RUN=$((TESTS_RUN + 1))
  if "$@"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    printf '  ✓ %s\n' "${name}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_NAMES+=("${name}")
    printf '  ✗ %s\n' "${name}"
  fi
}

_assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="${3:-}"
  if [[ "${expected}" == "${actual}" ]]; then
    return 0
  fi
  printf '    [%s] expected=%q actual=%q\n' "${label}" "${expected}" "${actual}" >&2
  return 1
}

_assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "${haystack}" == *"${needle}"* ]]; then
    return 0
  fi
  printf '    haystack missing needle=%q\n' "${needle}" >&2
  return 1
}

_assert_rc() {
  local expected="$1"
  local actual="$2"
  local label="${3:-}"
  if [[ "${expected}" == "${actual}" ]]; then
    return 0
  fi
  printf '    [%s] expected_rc=%s actual_rc=%s\n' "${label}" "${expected}" "${actual}" >&2
  return 1
}

# ────────────────────────────────────────────────────────────────────────
# Setup
# ────────────────────────────────────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
HELPERS="${REPO_ROOT}/agents/_shared/hook-helpers.sh"

TMP_ROOT="$(mktemp -d -t hook-helpers-test.XXXXXXXX)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

export CTX_TENANT_SLUG="test-tenant"
export CTX_AGENT_NAME="test-agent"
export CTX_AGENT_DIR="${TMP_ROOT}/agent-dir"
export IFOS_VAULT_ROOT="${TMP_ROOT}/vault"
export IFOS_DECISION_LOG_FALLBACK="${TMP_ROOT}/decision-log.jsonl"
export HH_POLICY_FILE="${REPO_ROOT}/agents/_shared/autosend-policy.yaml"
export HH_ESC_CATALOGUE="${REPO_ROOT}/agents/_shared/escalation-codes.md"
unset IFOS_DB_URL

mkdir -p "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}"

# shellcheck source=/dev/null
source "${HELPERS}"

# ────────────────────────────────────────────────────────────────────────
# Tests
# ────────────────────────────────────────────────────────────────────────

printf '\n[1] hh_decision_trigger writes a phase=trigger row\n'
test_trigger() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  hh_decision_trigger "session_start" "boot"
  local row
  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
  _assert_contains "${row}" '"phase":"trigger"' \
    && _assert_contains "${row}" '"trigger_type":"session_start"'
}
_test_run "phase=trigger row written" test_trigger

printf '\n[2] hh_decision_output writes a phase=output row\n'
test_output() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  hh_decision_output "diagnostic_report" "/vault/x/y.md"
  local row
  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
  _assert_contains "${row}" '"phase":"output"' \
    && _assert_contains "${row}" '"output_type":"diagnostic_report"'
}
_test_run "phase=output row written" test_output

printf '\n[3] autosend_policy_lookup resolves each tier\n'
test_lookup_green() { local t; t=$(autosend_policy_lookup "diagnostic_report_render"); _assert_eq "green" "${t}" "green"; }
test_lookup_yellow() { local t; t=$(autosend_policy_lookup "bullhorn_candidate_dedupe"); _assert_eq "yellow" "${t}" "yellow"; }
test_lookup_orange() { local t; t=$(autosend_policy_lookup "bullhorn_note_customer_visible"); _assert_eq "orange" "${t}" "orange"; }
test_lookup_red() { local t; t=$(autosend_policy_lookup "xero_payment_initiate"); _assert_eq "red" "${t}" "red"; }
test_lookup_unknown() { autosend_policy_lookup "nonexistent_action" >/dev/null 2>&1; _assert_rc "1" "$?" "unknown"; }
_test_run "policy_lookup → green" test_lookup_green
_test_run "policy_lookup → yellow" test_lookup_yellow
_test_run "policy_lookup → orange (CANONICAL)" test_lookup_orange
_test_run "policy_lookup → red" test_lookup_red
_test_run "policy_lookup unknown → rc=1" test_lookup_unknown

printf '\n[4] hh_decision_action — green tier emits action row, rc=0\n'
test_action_green() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
  local rc=$?
  local row
  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
  _assert_rc "0" "${rc}" "action_rc" \
    && _assert_contains "${row}" '"tier":"green"' \
    && _assert_contains "${row}" '"phase":"action"'
}
_test_run "green action: rc=0 + phase=action + tier=green" test_action_green

printf '\n[5] hh_decision_action — red tier emits gating_failed row, rc=1\n'
test_action_red() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  hh_decision_action "xero_payment_initiate" "invoice:42" "def456" "test"
  local rc=$?
  local row
  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
  _assert_rc "1" "${rc}" "rejected_rc" \
    && _assert_contains "${row}" '"tier":"red"' \
    && _assert_contains "${row}" '"phase":"gating_failed"' \
    && _assert_contains "${row}" '"escalation_code":"ESC_AUTOSEND_BLOCKED"'
}
_test_run "red action: rc=1 + phase=gating_failed + ESC_AUTOSEND_BLOCKED" test_action_red

printf '\n[6] hh_decision_action — orange tier with test-mode approve → rc=0\n'
test_action_orange_approve() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  HH_AWAIT_TEST_MODE=approve hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash1" "preview"
  local rc=$?
  local row
  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
  _assert_rc "0" "${rc}" "orange_approve_rc" \
    && _assert_contains "${row}" '"tier":"orange"' \
    && _assert_contains "${row}" '"approval_status":"approval_pending"' \
    && _assert_contains "${row}" '"escalation_code":"ESC_AUTOSEND_NEEDS_REVIEW"'
}
_test_run "orange action approved: rc=0 + ESC_AUTOSEND_NEEDS_REVIEW row + tier=orange" test_action_orange_approve

printf '\n[7] hh_decision_action — orange tier with test-mode reject → rc=1\n'
test_action_orange_reject() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  HH_AWAIT_TEST_MODE=reject hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash2" "preview"
  local rc=$?
  _assert_rc "1" "${rc}" "orange_reject_rc"
}
_test_run "orange action rejected: rc=1" test_action_orange_reject

printf '\n[8] hh_decision_action — unknown action_type → ESC_AUTOSEND_POLICY_LOOKUP_FAILED\n'
test_action_unknown() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  hh_decision_action "nonexistent_action" "x" "hash3" "preview"
  local rc=$?
  local row
  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
  _assert_rc "1" "${rc}" "unknown_rc" \
    && _assert_contains "${row}" '"escalation_code":"ESC_AUTOSEND_POLICY_LOOKUP_FAILED"'
}
_test_run "unknown action: rc=1 + ESC_AUTOSEND_POLICY_LOOKUP_FAILED" test_action_unknown

printf '\n[9] autosend_apply_tenant_override — elevation allowed\n'
test_override_elevate() {
  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
  mkdir -p "$(dirname "${override_file}")"
  cat > "${override_file}" <<EOF
tier_overrides:
  bullhorn_note_internal: orange
EOF
  local result
  result=$(autosend_apply_tenant_override "green" "bullhorn_note_internal" "${CTX_TENANT_SLUG}")
  _assert_eq "orange" "${result}" "elevation"
}
_test_run "tenant override elevate green → orange" test_override_elevate

printf '\n[10] autosend_apply_tenant_override — demotion refused\n'
test_override_demote() {
  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
  mkdir -p "$(dirname "${override_file}")"
  cat > "${override_file}" <<EOF
tier_overrides:
  bullhorn_note_customer_visible: green
EOF
  autosend_apply_tenant_override "orange" "bullhorn_note_customer_visible" "${CTX_TENANT_SLUG}" >/dev/null 2>&1
  _assert_rc "1" "$?" "demotion_refused"
}
_test_run "tenant override demote refused (orange → green)" test_override_demote

printf '\n[11] autosend_apply_tenant_override — red is absolute\n'
test_override_red_floor() {
  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
  mkdir -p "$(dirname "${override_file}")"
  cat > "${override_file}" <<EOF
tier_overrides:
  xero_payment_initiate: green
EOF
  local result
  result=$(autosend_apply_tenant_override "red" "xero_payment_initiate" "${CTX_TENANT_SLUG}")
  _assert_eq "red" "${result}" "red_floor"
  rm -f "${override_file}"
}
_test_run "red tier override ignored (red is absolute)" test_override_red_floor

printf '\n[12] autosend_escalate — unknown ESC code → meta-escalation\n'
test_escalate_unknown() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  autosend_escalate "ESC_NONEXISTENT_CODE" 2>/dev/null
  local rc=$?
  local row
  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
  _assert_rc "1" "${rc}" "unknown_esc_rc" \
    && _assert_contains "${row}" "esc_code_unknown"
}
_test_run "unknown ESC code → meta-escalation" test_escalate_unknown

printf '\n[13] autosend_should_sample — yellow tier with high rate eventually returns 0\n'
test_should_sample() {
  # bullhorn_candidate_dedupe has sample_rate 10; over 200 draws we should get a sample
  local hit=0
  local i
  for i in {1..200}; do
    if autosend_should_sample "bullhorn_candidate_dedupe" "${CTX_TENANT_SLUG}"; then
      hit=1
      break
    fi
  done
  _assert_eq "1" "${hit}" "sampled_at_least_once"
}
_test_run "yellow tier sampling fires within 200 draws" test_should_sample

printf '\n[14] autosend_spot_check_enqueue writes idempotent markdown\n'
test_spot_check_enqueue() {
  rm -rf "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/spot-checks"
  autosend_spot_check_enqueue "bullhorn_candidate_dedupe" "candidate:foo" "abc123def456" "merge preview" "${CTX_TENANT_SLUG}"
  local count
  count=$(find "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/spot-checks" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  _assert_eq "1" "${count}" "one_spot_check"
}
_test_run "spot-check enqueue writes markdown file" test_spot_check_enqueue

printf '\n[15] hh_decision_action — yellow tier emits row + may enqueue spot-check\n'
test_action_yellow() {
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  hh_decision_action "bullhorn_candidate_dedupe" "candidate:foo" "hash9" "preview"
  local rc=$?
  local row
  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
  _assert_rc "0" "${rc}" "yellow_rc" \
    && _assert_contains "${row}" '"tier":"yellow"' \
    && _assert_contains "${row}" '"phase":"action"'
}
_test_run "yellow action: rc=0 + phase=action + tier=yellow" test_action_yellow

printf '\n[16] Kill-criterion Trigger 5 verification: red-tier audit query shape\n'
test_kill_criterion_trigger5() {
  # Insert 4 synthetic red-tier actions. Each emits 2 gating_failed rows:
  # (a) the autosend_emit_decision_log audit row with payload.tier='red'
  # (b) the autosend_escalate ESC_AUTOSEND_BLOCKED escalation row
  # Kill-criterion Trigger 5 monitoring query filters by payload.tier='red'
  # specifically, so the audit row is the load-bearing count.
  : > "${IFOS_DECISION_LOG_FALLBACK}"
  local i
  for i in 1 2 3 4; do
    hh_decision_action "xero_payment_initiate" "invoice:${i}" "hashred${i}" "amount: £100"
  done
  local red_audit_count gating_failed_count blocked_esc_count
  red_audit_count=$(grep -c '"tier":"red"' "${IFOS_DECISION_LOG_FALLBACK}")
  gating_failed_count=$(grep -c '"phase":"gating_failed"' "${IFOS_DECISION_LOG_FALLBACK}")
  blocked_esc_count=$(grep -c '"escalation_code":"ESC_AUTOSEND_BLOCKED"' "${IFOS_DECISION_LOG_FALLBACK}")
  _assert_eq "4" "${red_audit_count}" "red_audit_count" \
    && _assert_eq "8" "${gating_failed_count}" "gating_failed_count (4 audit + 4 escalation)" \
    && _assert_eq "4" "${blocked_esc_count}" "blocked_esc_count"
}
_test_run "kill-criterion Trigger 5: red-tier rows queryable by tier+phase" test_kill_criterion_trigger5

# ────────────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────────────

printf '\n──────────────────────────────────────────────────────\n'
printf 'Tests run:    %d\n' "${TESTS_RUN}"
printf 'Tests passed: %d\n' "${TESTS_PASSED}"
printf 'Tests failed: %d\n' "${TESTS_FAILED}"
if (( TESTS_FAILED > 0 )); then
  printf '\nFailed tests:\n'
  for name in "${FAILED_NAMES[@]}"; do
    printf '  - %s\n' "${name}"
  done
  exit 1
fi
printf '\nALL PASS ✓\n'
exit 0
