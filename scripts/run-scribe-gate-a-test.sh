#!/usr/bin/env bash
# Scribe — Gate A (validate.sh) fixture test (spec-002 §7).
#
# Exercises agents/recruitment/scribe/validate.sh against hand-crafted
# proposals covering the PASS path + each fail class (webhook-sig,
# field-count, voice, schema name, schema type, PII, auth, word-cap),
# asserting exit codes AND the per-class ESC routing in decision_log.
#
# CC fixture pattern (run-gate-a-test.sh): the test tenant is registered in
# `tenants` first because decision_log has a FK → tenants (ON DELETE CASCADE)
# — the ESC rows validate.sh writes need it, and deleting the tenant row
# cascades the decision_log cleanup.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="scribe-gate-a-fixture"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/scribe"
export CTX_AGENT_NAME="scribe" CTX_TENANT_SLUG="${TENANT}"
export CTX_FIRM_DOMAIN_WHITELIST="acme.test"
readonly VALIDATE="${CTX_AGENT_DIR}/validate.sh"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
command -v jq   >/dev/null 2>&1 || { _fail "jq not on PATH"; exit 1; }
[[ -f "${VALIDATE}" ]] || { _fail "validate.sh missing"; exit 1; }
TMPD="$(mktemp -d)"

appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }

# shellcheck disable=SC2329  # invoked via trap
cleanup() {
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  rm -rf "${TMPD}"
}
trap cleanup EXIT

printf '\033[1;34m── Scribe Gate A (validate.sh) fixture test ──\033[0m\n'

appq <<'SQL' >/dev/null || { _fail "tenant seed failed"; exit 1; }
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scribe Gate A fixture')
  ON CONFLICT (tenant_slug) DO NOTHING;
SQL

fails=0
run_case() {  # <label> <expected_exit> <proposal_path>
  local label="$1" want="$2" path="$3" got
  bash "${VALIDATE}" "${path}" >/dev/null 2>&1 && got=0 || got=$?
  if [[ "${got}" -eq "${want}" ]]; then
    _ok "${label} (exit ${got})"
  else
    _fail "${label}: exit ${got}, want ${want}"; fails=$((fails + 1))
  fi
}
assert_esc() {  # <expected_code>
  local want="$1" got
  got="$(appq <<'SQL' 2>/dev/null | tail -1
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

# Proposal builder. Args: file sig_state voice_score word_count preview fields_json
mkproposal() {
  local file="$1" sig="$2" voice="$3" words="$4" preview="$5" fields="$6"
  jq -nc --arg sig "${sig}" --arg voice "${voice}" --argjson words "${words}" \
     --arg pv "${preview}" --argjson fields "${fields}" '{
    call_id: "meeting-ga", entity_type: "candidate", bullhorn_id: "1001",
    webhook_sig_state: $sig, fields_extracted: $fields,
    tacit_note: { vault_path: "/vault/scribe-gate-a-fixture/scribe-notes/meeting-ga-2026-06-10.md",
                  body_sha256: "abc123", voice_score: $voice, voice_reason: "test",
                  narrative_word_count: $words, narrative_body_preview: $pv } }' > "${file}"
}

GOOD_FIELDS='[{"field_name":"location","value":"Leeds","confidence":0.9},
              {"field_name":"current_role","value":"Engineer","confidence":0.85},
              {"field_name":"notice_period_weeks","value":4,"confidence":0.8},
              {"field_name":"salary_expectation_min","value":70000,"confidence":0.8}]'

# ── G7 first: NO fresh bullhorn_auth_refreshed row yet → auth hard-fail ───
mkproposal "${TMPD}/noauth.json" verified 0.82 200 "clean text" "${GOOD_FIELDS}"
run_case "FAIL G7: no fresh auth row"          1 "${TMPD}/noauth.json"
assert_esc ESC_BULLHORN_AUTH

# Seed the fresh auth row every later case relies on (what cycle.sh Step 2 emits).
appq <<'SQL' >/dev/null || { _fail "auth row seed failed"; exit 1; }
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload)
VALUES (:'tenant', 'scribe', 'output', 'produced',
        'corporation_id:9876; result:refreshed',
        '{"output_type":"bullhorn_auth_refreshed","artefact_ref":"tenant:scribe-gate-a-fixture"}');
COMMIT;
SQL

# ── PASS path (all 8 checks green; voice scored above threshold) ──────────
mkproposal "${TMPD}/pass.json" verified 0.82 200 "clean narrative text" "${GOOD_FIELDS}"
run_case "PASS: verified sig + 4 fields + voice 0.82 + clean preview"  0 "${TMPD}/pass.json"

# PASS variant: poll-trigger (not_applicable) + unscored voice → warn, not fail.
mkproposal "${TMPD}/pass-poll.json" not_applicable unscored 200 "clean narrative text" "${GOOD_FIELDS}"
run_case "PASS: poll trigger (sig n/a) + voice unscored (warn-when-unscored)" 0 "${TMPD}/pass-poll.json"

# ── G1: webhook signature invalid ──────────────────────────────────────────
mkproposal "${TMPD}/badsig.json" invalid 0.82 200 "clean text" "${GOOD_FIELDS}"
run_case "FAIL G1: webhook signature invalid"  1 "${TMPD}/badsig.json"
assert_esc ESC_INPUT_VALIDATION_FAIL

# ── G2: <3 fields ≥0.6 confidence ─────────────────────────────────────────
LOW_FIELDS='[{"field_name":"location","value":"Leeds","confidence":0.9},
             {"field_name":"current_role","value":"Engineer","confidence":0.55},
             {"field_name":"notice_period_weeks","value":4,"confidence":0.41}]'
mkproposal "${TMPD}/lowconf.json" verified 0.82 200 "clean text" "${LOW_FIELDS}"
run_case "FAIL G2: only 1 field ≥0.6"          1 "${TMPD}/lowconf.json"
assert_esc ESC_FIELD_EXTRACTION_LOW_CONFIDENCE

# ── G3: voice score below 0.75 ─────────────────────────────────────────────
mkproposal "${TMPD}/voice.json" verified 0.61 200 "clean text" "${GOOD_FIELDS}"
run_case "FAIL G3: voice 0.61 < 0.75"          1 "${TMPD}/voice.json"
assert_esc ESC_VOICE_DRIFT

# ── G4: field name not in schema ───────────────────────────────────────────
BAD_NAME_FIELDS='[{"field_name":"location","value":"Leeds","confidence":0.9},
                  {"field_name":"current_role","value":"Engineer","confidence":0.85},
                  {"field_name":"notice_period_weeks","value":4,"confidence":0.8},
                  {"field_name":"made_up_field","value":"x","confidence":0.9}]'
mkproposal "${TMPD}/badname.json" verified 0.82 200 "clean text" "${BAD_NAME_FIELDS}"
run_case "FAIL G4: unknown field name"         1 "${TMPD}/badname.json"
assert_esc ESC_SCHEMA_VIOLATION

# ── G5: type/range violation (enum miss drops it below 3 valid) ───────────
BAD_TYPE_FIELDS='[{"field_name":"location","value":"Leeds","confidence":0.9},
                  {"field_name":"employment_type","value":"freelance","confidence":0.85},
                  {"field_name":"notice_period_weeks","value":"four","confidence":0.8}]'
mkproposal "${TMPD}/badtype.json" verified 0.82 200 "clean text" "${BAD_TYPE_FIELDS}"
run_case "FAIL G5: enum + integer type violations" 1 "${TMPD}/badtype.json"
assert_esc ESC_SCHEMA_VIOLATION

# ── G6: PII outside firm boundary in narrative preview ────────────────────
mkproposal "${TMPD}/pii.json" verified 0.82 200 \
  "candidate mentioned reach me at random.person@gmail.com about the role" "${GOOD_FIELDS}"
run_case "FAIL G6: external email in narrative" 1 "${TMPD}/pii.json"
assert_esc ESC_PII_LEAKAGE_RISK

# ── G8: tacit-note word count over the 800 cap ─────────────────────────────
mkproposal "${TMPD}/longnote.json" verified 0.82 1200 "clean text" "${GOOD_FIELDS}"
run_case "FAIL G8: 1200 words > 800 cap"       1 "${TMPD}/longnote.json"
assert_esc ESC_AGENT_OUTPUT_SHAPE

# Every FAIL case must also have written a validate_gate_a_fail action row.
GF_COUNT="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log WHERE tenant_slug = :'tenant'
  AND phase = 'action' AND payload->>'action_type' = 'validate_gate_a_fail';
COMMIT;
SQL
)"
if [[ "${GF_COUNT:-0}" -ge 8 ]]; then
  _ok "validate_gate_a_fail action row written for all ${GF_COUNT} fail cases"
else
  _fail "expected ≥8 validate_gate_a_fail rows, got ${GF_COUNT:-0}"; fails=$((fails + 1))
fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all Gate A assertions passed (2 pass paths + 8 fail classes + ESC routes)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
