#!/usr/bin/env bash
# Sourcing Scout — Gate A (validate.sh) fixture test (spec-003 §7).
#
# Exercises agents/recruitment/sourcing-scout/validate.sh against hand-crafted
# proposal JSONs covering the PASS path + each hard fail class, asserting exit
# codes AND the ESC routing per class:
#   G1 count <5 / >15, G2 missing/invalid contact, G3 rationale <50w,
#   G7 source-floor, G5 DNC re-check → ESC_AGENT_OUTPUT_SHAPE
#   G4 scored voice <0.75                → ESC_VOICE_DRIFT
#   G6 PII outside firm boundary         → ESC_PII_LEAKAGE_RISK (blocking;
#                                          takes precedence over other classes)
# plus the mandatory validate_gate_a_fail action row on every failure.
#
# validate.sh opens its OWN DB connection, so the test tenant is registered in
# `tenants` first (decision_log FK; ON DELETE CASCADE cleans up).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="scout-gate-a-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
TMPD="$(mktemp -d)"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${TMPD}/vault"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/sourcing-scout"
export CTX_AGENT_NAME="sourcing-scout" CTX_TENANT_SLUG="${TENANT}"
export CTX_FIRM_DOMAIN_WHITELIST="scout-firm.test"
export CTX_DNC_BLOCKED_RECIPIENTS='[]'
readonly VALIDATE="${CTX_AGENT_DIR}/validate.sh"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
command -v jq >/dev/null 2>&1 || { _fail "jq not on PATH"; exit 1; }
[[ -f "${VALIDATE}" ]] || { _fail "validate.sh missing"; exit 1; }

appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }

# shellcheck disable=SC2329  # invoked indirectly via `trap cleanup EXIT`
cleanup() {
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  rm -rf "${TMPD}"
}
trap cleanup EXIT

printf '\033[1;34m── Sourcing Scout Gate A (validate.sh) fixture test ──\033[0m\n'

appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scout Gate A fixture test')
  ON CONFLICT (tenant_slug) DO NOTHING;
SQL

# Base proposal generator: N candidates, all-green shape (email contacts on
# the people.test domain; 60-word rationales; voice unscored).
mkproposal() {  # out_path n_candidates
  jq -n --argjson n "$2" '
    {brief_id: "fix-9", tenant_slug: "scout-gate-a-fixture-test",
     brief: {role: "Senior React Engineer", location: "London", key_dims: 4},
     candidates: [range($n) | {
       candidate_id: "cvlibrary:c\(.)", source: "cvlibrary", sources: ["cvlibrary"],
       name: "Candidate \(.)",
       contact_method: {type: "email", value: "c\(.)@people.test"},
       confidence: 0.8, voice_score: "unscored", voice_reason: "no_corpus",
       rationale_body_preview: ([range(60) | "word"] | join(" ")),
       rationale_word_count: 60}],
     sources_active: 1, sources_degraded: ["bullhorn", "reed"],
     source_stats: {
       bullhorn:  {queried: false, returned: 0,  note: "degraded: credentials absent"},
       linkedin:  {queried: false, returned: 0,  note: "deferred to v1.1+; vendor pending"},
       reed:      {queried: false, returned: 0,  note: "degraded: credentials absent"},
       cvlibrary: {queried: true,  returned: $n, note: "fixture: \($n) candidates"}}}' > "$1"
}

fails=0
run_case() {  # label expected_exit proposal_path
  local label="$1" want="$2" path="$3" got
  bash "${VALIDATE}" "${path}" >/dev/null 2>&1 && got=0 || got=$?
  if [[ "${got}" -eq "${want}" ]]; then
    _ok "${label} (exit ${got})"
  else
    _fail "${label}: exit ${got}, want ${want}"; fails=$((fails + 1))
  fi
}
assert_esc() {  # expected ESC code on the latest gating_failed row
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

# PASS path (8 candidates, everything green; voice unscored = warn only).
mkproposal "${TMPD}/pass.json" 8
run_case "PASS: 8 green candidates" 0 "${TMPD}/pass.json"

# G1 low: 4 candidates.
mkproposal "${TMPD}/low.json" 4
run_case "FAIL G1: count 4 < 5" 1 "${TMPD}/low.json"
assert_esc ESC_AGENT_OUTPUT_SHAPE

# G1 high: 16 candidates.
mkproposal "${TMPD}/high.json" 16
run_case "FAIL G1: count 16 > 15" 1 "${TMPD}/high.json"
assert_esc ESC_AGENT_OUTPUT_SHAPE

# G2: one candidate loses its contact method.
mkproposal "${TMPD}/contact.json" 8
jq '.candidates[3].contact_method = {type: "missing", value: ""}' \
  "${TMPD}/contact.json" > "${TMPD}/contact2.json"
run_case "FAIL G2: missing contact method" 1 "${TMPD}/contact2.json"
assert_esc ESC_AGENT_OUTPUT_SHAPE

# G2: malformed E.164 phone.
mkproposal "${TMPD}/phone.json" 8
jq '.candidates[2].contact_method = {type: "phone", value: "0770 090 0001"}' \
  "${TMPD}/phone.json" > "${TMPD}/phone2.json"
run_case "FAIL G2: non-E.164 phone" 1 "${TMPD}/phone2.json"

# G3: one rationale below 50 words.
mkproposal "${TMPD}/words.json" 8
jq '.candidates[1].rationale_body_preview = "too short" | .candidates[1].rationale_word_count = 2' \
  "${TMPD}/words.json" > "${TMPD}/words2.json"
run_case "FAIL G3: rationale 2 words < 50" 1 "${TMPD}/words2.json"
assert_esc ESC_AGENT_OUTPUT_SHAPE

# G4: scored voice below threshold (unscored never fails; numeric does).
mkproposal "${TMPD}/voice.json" 8
jq '.candidates[0].voice_score = 0.42' "${TMPD}/voice.json" > "${TMPD}/voice2.json"
run_case "FAIL G4: scored voice 0.42 < 0.75" 1 "${TMPD}/voice2.json"
assert_esc ESC_VOICE_DRIFT

# G5: DNC re-check hit (defence-in-depth; env-injected blocked list).
mkproposal "${TMPD}/dnc.json" 8
CTX_DNC_BLOCKED_RECIPIENTS='["c2@people.test"]' \
  bash "${VALIDATE}" "${TMPD}/dnc.json" >/dev/null 2>&1 && _g5=0 || _g5=$?
if [[ "${_g5}" -eq 1 ]]; then _ok "FAIL G5: DNC re-check hit (exit 1)"; else _fail "FAIL G5: exit ${_g5}, want 1"; fails=$((fails + 1)); fi
assert_esc ESC_AGENT_OUTPUT_SHAPE

# G6: PII outside firm boundary in a rationale → BLOCKING class, and it takes
# precedence even when another class also fails (count low here too).
mkproposal "${TMPD}/pii.json" 4
jq '.candidates[0].rationale_body_preview += " reach them at private.person@gmail.com"' \
  "${TMPD}/pii.json" > "${TMPD}/pii2.json"
run_case "FAIL G6: external email in rationale (+ G1 low)" 1 "${TMPD}/pii2.json"
assert_esc ESC_PII_LEAKAGE_RISK

# G7: live source queried, returned 0, no degradation note.
mkproposal "${TMPD}/floor.json" 8
jq '.source_stats.reed = {queried: true, returned: 0, note: ""} | .sources_degraded = ["bullhorn"]' \
  "${TMPD}/floor.json" > "${TMPD}/floor2.json"
run_case "FAIL G7: live source returned 0 without degradation note" 1 "${TMPD}/floor2.json"
assert_esc ESC_AGENT_OUTPUT_SHAPE

# Mandatory audit row: every failure emitted a validate_gate_a_fail action row
# (9 failing validate.sh invocations above: G1 low, G1 high, G2 missing, G2
# phone, G3, G4, G5, G6, G7).
_n_fail_cases=9
_n_action_rows="$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase = 'action'
  AND payload->>'action_type' = 'validate_gate_a_fail';
COMMIT;
SQL
)"
if [[ "${_n_action_rows}" == "${_n_fail_cases}" ]]; then
  _ok "validate_gate_a_fail action row emitted for every failure (${_n_action_rows}/${_n_fail_cases})"
else
  _fail "validate_gate_a_fail rows: ${_n_action_rows}, want ${_n_fail_cases}"; fails=$((fails + 1))
fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all Gate A assertions passed (pass + 9 fail classes + ESC routes + mandatory audit rows)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
