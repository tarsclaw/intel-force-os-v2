#!/usr/bin/env bash
# shellcheck disable=SC2329  # test helpers called via && chains
#
# Offline test harness for agents/_shared/voice-loader.sh.
# Exercises fallback mode (no live Postgres). Verifies JSON shape contracts.
#
# Run: bash agents/_shared/tests/test-voice-loader.sh
# Exit 0 = pass; 1 = fail.

set -uo pipefail

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

_assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "${haystack}" == *"${needle}"* ]]; then
    return 0
  fi
  printf '    needle %q not found in: %q\n' "${needle}" "${haystack}" >&2
  return 1
}

_assert_valid_json() {
  local input="$1"
  if printf '%s' "${input}" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
    return 0
  fi
  printf '    invalid JSON: %q\n' "${input}" >&2
  return 1
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
LOADER="${REPO_ROOT}/agents/_shared/voice-loader.sh"

TMP_ROOT="$(mktemp -d -t voice-loader-test.XXXXXXXX)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

export CTX_TENANT_SLUG="test-tenant"
export CTX_AGENT_NAME="concierge"
export CTX_AGENT_DIR="${TMP_ROOT}/agent-dir"
export IFOS_VAULT_ROOT="${TMP_ROOT}/vault"
unset IFOS_DB_URL
unset IFOS_VL_QUERY_VECTOR

mkdir -p "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_voice"

# shellcheck source=/dev/null
source "${LOADER}"

# ────────────────────────────────────────────────────────────────────────

printf '\n[1] hh_load_tone_rules returns valid JSON in fallback mode\n'
test_tone_rules_empty() {
  local out
  out=$(hh_load_tone_rules)
  _assert_valid_json "${out}" && _assert_contains "${out}" '"rules":[]'
}
_test_run "tone_rules fallback (no DB, no file): empty rules" test_tone_rules_empty

printf '\n[2] hh_load_tone_rules reads tone-rules.yaml fallback path\n'
test_tone_rules_fallback() {
  cat > "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_voice/tone-rules.yaml" <<EOF
rules:
  - rule_id: no-finds-you-well
    severity: block
EOF
  local out
  out=$(hh_load_tone_rules)
  _assert_valid_json "${out}" && _assert_contains "${out}" '"source":"fallback"'
}
_test_run "tone_rules fallback: fallback_path surfaced" test_tone_rules_fallback

printf '\n[3] hh_load_voice_samples returns valid JSON in fallback mode\n'
test_voice_samples_no_db() {
  local out
  out=$(hh_load_voice_samples "candidate-outreach")
  _assert_valid_json "${out}" && _assert_contains "${out}" '"task_context":"candidate-outreach"'
}
_test_run "voice_samples fallback (no DB): valid JSON with task_context" test_voice_samples_no_db

printf '\n[4] hh_load_voice_samples surfaces style guide when present\n'
test_voice_samples_style_guide() {
  echo "# Voice style" > "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_voice/style-guide.md"
  local out
  out=$(hh_load_voice_samples "candidate-outreach")
  _assert_valid_json "${out}" \
    && _assert_contains "${out}" '"source":"fallback"' \
    && _assert_contains "${out}" '"style_guide_path"'
}
_test_run "voice_samples fallback: style_guide_path surfaced" test_voice_samples_style_guide

printf '\n[5] hh_load_voice_samples top_k validation clamps to 10\n'
test_voice_samples_invalid_top_k() {
  local out
  out=$(hh_load_voice_samples "task" "abc")  # non-numeric → 10
  _assert_valid_json "${out}"
  out=$(hh_load_voice_samples "task" "999")  # over cap → 10
  _assert_valid_json "${out}"
  out=$(hh_load_voice_samples "task" "0")    # zero → 10
  _assert_valid_json "${out}"
}
_test_run "voice_samples top_k validation: non-numeric/over-cap/zero accepted" test_voice_samples_invalid_top_k

printf '\n[6] hh_load_recent_edits returns valid JSON in fallback mode\n'
test_recent_edits_no_db() {
  local out
  out=$(hh_load_recent_edits)
  _assert_valid_json "${out}" \
    && _assert_contains "${out}" '"edits":[]' \
    && _assert_contains "${out}" '"lookback_days":30'
}
_test_run "recent_edits fallback: empty array + default 30 days" test_recent_edits_no_db

printf '\n[7] hh_load_recent_edits accepts custom lookback_days\n'
test_recent_edits_custom_lookback() {
  local out
  out=$(hh_load_recent_edits 7 "concierge")
  _assert_valid_json "${out}" \
    && _assert_contains "${out}" '"lookback_days":7'
}
_test_run "recent_edits accepts 7-day lookback + agent_name" test_recent_edits_custom_lookback

printf '\n[8] hh_load_recent_edits lookback_days validation clamps to 30\n'
test_recent_edits_invalid_lookback() {
  local out
  out=$(hh_load_recent_edits "abc")  # non-numeric → 30
  _assert_valid_json "${out}" && _assert_contains "${out}" '"lookback_days":30'
  out=$(hh_load_recent_edits "999")   # over cap → 30
  _assert_valid_json "${out}" && _assert_contains "${out}" '"lookback_days":30'
  out=$(hh_load_recent_edits "0")     # zero → 30
  _assert_valid_json "${out}" && _assert_contains "${out}" '"lookback_days":30'
}
_test_run "recent_edits lookback validation: non-numeric/over-cap/zero clamp to 30" test_recent_edits_invalid_lookback

printf '\n[9] All three helpers emit single-line JSON (one document per call)\n'
test_single_line_json() {
  local out1 out2 out3
  out1=$(hh_load_tone_rules | wc -l | tr -d ' ')
  out2=$(hh_load_voice_samples "task" | wc -l | tr -d ' ')
  out3=$(hh_load_recent_edits | wc -l | tr -d ' ')
  [[ "${out1}" == "1" ]] && [[ "${out2}" == "1" ]] && [[ "${out3}" == "1" ]]
}
_test_run "all three helpers emit exactly 1 line of JSON" test_single_line_json

# ────────────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────────────

printf '\n──────────────────────────────────────────────────────\n'
printf 'Tests run:    %d\n' "${TESTS_RUN}"
printf 'Tests passed: %d\n' "${TESTS_PASSED}"
printf 'Tests failed: %d\n' "${TESTS_FAILED}"
if (( TESTS_FAILED > 0 )); then
  printf '\nFailed:\n'
  for name in "${FAILED_NAMES[@]}"; do
    printf '  - %s\n' "${name}"
  done
  exit 1
fi
printf '\nALL PASS ✓\n'
exit 0
