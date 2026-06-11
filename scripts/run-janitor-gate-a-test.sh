#!/usr/bin/env bash
# Janitor — Gate A (validate.sh) fixture test (spec-001 §7).
#
# Exercises agents/recruitment/janitor/validate.sh against hand-crafted write
# proposals covering the PASS paths + each hard fail class, asserting exit
# codes AND the per-class ESC routing (spec-001 §5):
#   G2 confidence < threshold, G4 source_confidence < 0.7,
#   G7 batch index > 100                  → ESC_AGENT_OUTPUT_SHAPE
#   G3 recent/unknown activity            → ESC_DUPLICATE_DETECTED (SUCCESS path)
#   G5 scored voice < 0.75                → ESC_VOICE_DRIFT
#   G6 PII outside firm boundary          → ESC_PII_LEAKAGE_RISK (blocking;
#                                            precedence over other classes)
# plus the mandatory validate_gate_a_fail action row on every failure and the
# warn-not-fail honesty paths (voice unscored; degraded auth state).
#
# validate.sh opens its OWN DB connection, so the test tenant is registered in
# `tenants` first (decision_log FK; ON DELETE CASCADE cleans up).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="janitor-gate-a-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
TMPD="$(mktemp -d)"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${TMPD}/vault"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/janitor"
export CTX_AGENT_NAME="janitor" CTX_TENANT_SLUG="${TENANT}"
export CTX_JANITOR_DEDUP_THRESHOLD="0.85"
export CTX_FIRM_DOMAIN_WHITELIST="janitor-firm.test"
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

printf '\033[1;34m── Janitor Gate A (validate.sh) fixture test ──\033[0m\n'

appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Janitor Gate A fixture test')
  ON CONFLICT (tenant_slug) DO NOTHING;
SQL

mkdedupe() {  # out conf days
  jq -n --argjson c "$2" --argjson d "$3" \
    '{action_type: "bullhorn_candidate_dedupe", entity_type: "candidate",
      primary_id: "1001", merge_target_id: "1002", confidence: $c,
      match_dimensions: ["name","email","phone"], last_activity_days: $d}' > "$1"
}
mkbackfill() {  # out source_confidence
  jq -n --argjson sc "$2" \
    '{action_type: "bullhorn_field_backfill", entity_type: "client",
      primary_id: "5001", field_changes: {industry: "62020"},
      source: "companies_house", source_confidence: $sc}' > "$1"
}
mknote() {  # out voice_score body
  jq -n --arg vs "$2" --arg body "$3" \
    '{action_type: "bullhorn_note_attach", entity_type: "candidate",
      primary_id: "1001", narrative_body: $body,
      voice_score: (if ($vs | test("^[0-9.]+$")) then ($vs | tonumber) else $vs end),
      voice_reason: "fixture"}' > "$1"
}

fails=0
run_case() {  # label expected_exit proposal_path [batch_index]
  local label="$1" want="$2" path="$3" idx="${4:-1}" got
  CTX_JANITOR_BATCH_INDEX="${idx}" bash "${VALIDATE}" "${path}" >/dev/null 2>&1 && got=0 || got=$?
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

mkdedupe  "${TMPD}/ok-dedupe.json"   0.92 120
run_case "PASS: dedupe (conf 0.92; 120d stale)"                0 "${TMPD}/ok-dedupe.json"

mkbackfill "${TMPD}/ok-backfill.json" 0.9
run_case "PASS: backfill (source_confidence 0.9)"              0 "${TMPD}/ok-backfill.json"

mknote "${TMPD}/ok-note.json" "unscored" "Internal data-hygiene note. Consultants approved 3 edits; no personal data reproduced."
run_case "PASS: note (voice unscored → warn-not-fail honesty)" 0 "${TMPD}/ok-note.json"

mkdedupe "${TMPD}/g2.json" 0.80 120
run_case "FAIL G2: confidence 0.80 < 0.85"                     1 "${TMPD}/g2.json"
assert_esc ESC_AGENT_OUTPUT_SHAPE

mkdedupe "${TMPD}/g3.json" 0.92 20
run_case "FAIL G3: 20d recent activity (auto-write rejected)"  1 "${TMPD}/g3.json"
assert_esc ESC_DUPLICATE_DETECTED

jq 'del(.last_activity_days)' "${TMPD}/g3.json" > "${TMPD}/g3b.json"
run_case "FAIL G3: UNKNOWN activity (conservative hold)"       1 "${TMPD}/g3b.json"
assert_esc ESC_DUPLICATE_DETECTED

mkbackfill "${TMPD}/g4.json" 0.5
run_case "FAIL G4: source_confidence 0.5 < 0.7"                1 "${TMPD}/g4.json"
assert_esc ESC_AGENT_OUTPUT_SHAPE

mknote "${TMPD}/g5.json" "0.5" "Internal data-hygiene note. Consultants approved 3 edits."
run_case "FAIL G5: scored voice 0.5 < 0.75"                    1 "${TMPD}/g5.json"
assert_esc ESC_VOICE_DRIFT

mknote "${TMPD}/g6.json" "unscored" "Reach the candidate at private.person@gmail.com for details."
run_case "FAIL G6: external email in narrative (PII)"          1 "${TMPD}/g6.json"
assert_esc ESC_PII_LEAKAGE_RISK

mknote "${TMPD}/g6ok.json" "unscored" "Boundary check: ops@janitor-firm.test reviewed this note."
run_case "PASS G6: firm-domain email allowed"                  0 "${TMPD}/g6ok.json"

mknote "${TMPD}/g6prec.json" "0.5" "Simultaneous fails: voice low AND external pii@evil.example here."
run_case "FAIL G6+G5: PII precedence over voice class"         1 "${TMPD}/g6prec.json"
assert_esc ESC_PII_LEAKAGE_RISK

mkdedupe "${TMPD}/g7.json" 0.92 120
run_case "FAIL G7: batch index 101 > 100/min cap"              1 "${TMPD}/g7.json" 101
assert_esc ESC_AGENT_OUTPUT_SHAPE

# Mandatory validate_gate_a_fail action row per failure (8 failures above).
_ga_rows="$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase = 'action'
  AND payload->>'action_type' = 'validate_gate_a_fail';
COMMIT;
SQL
)"
if [[ "${_ga_rows}" == "8" ]]; then
  _ok "validate_gate_a_fail action row emitted for all 8 failures"
else
  _fail "validate_gate_a_fail rows: got '${_ga_rows}', want 8"; fails=$((fails + 1))
fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all Gate A assertions passed (4 pass paths + 8 fail classes + ESC routes + audit rows)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
