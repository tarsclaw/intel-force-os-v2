#!/usr/bin/env bash
# Sourcing Scout — per-source degraded-mode fixture test (spec-003 §7).
#
# Scenario A (mirrors fixtures/02-edge-case-degraded-sources.yaml):
#   Bullhorn creds absent (IFOS_SECRETS_FILE=/dev/null, no fixture) → Step 2
#   degraded-skip + ESC_BULLHORN_AUTH. Reed live at refresh (fixture file
#   present) then 429s at Step 5 (IFOS_SCOUT_FORCE_429_REED) →
#   ESC_RATE_LIMIT_HIT + cached_only 0 results. CV-Library fixture returns 3.
#   3 < 5 floor → Gate A G1 FAIL → validate_gate_a_fail + ESC_AGENT_OUTPUT_SHAPE
#   + partial draft at /tmp + exit 1 + NO vault report.
#
# Scenario B: ALL sources degraded → Step 2 fires the <5-obtainable
#   ESC_AGENT_OUTPUT_SHAPE floor escalation immediately (all_sources_degraded)
#   and the run still exits 1 through Gate A with the full audit trail.
#
# cycle.sh + validate.sh open their OWN DB connections → tenant registered in
# `tenants` first (decision_log FK; ON DELETE CASCADE cleans up).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="scout-degraded-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
TMPD="$(mktemp -d)"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${TMPD}/vault"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/sourcing-scout"
export CTX_AGENT_NAME="sourcing-scout" CTX_TENANT_SLUG="${TENANT}"
export IFOS_SECRETS_FILE=/dev/null   # all creds absent — the degraded premise
export CTX_FIRM_DOMAIN_WHITELIST="${TENANT}.test"
export CTX_DNC_BLOCKED_RECIPIENTS='[]'
export CTX_VOICE_CORPUS_STATE="absent"
readonly CYCLE="${CTX_AGENT_DIR}/cycle.sh"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
command -v jq >/dev/null 2>&1 || { _fail "jq not on PATH"; exit 1; }
[[ -f "${CYCLE}" ]] || { _fail "cycle.sh missing"; exit 1; }

appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }

# shellcheck disable=SC2329  # invoked indirectly via `trap cleanup EXIT`
cleanup() {
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  rm -f "/tmp/sourcing-scout-${TENANT}-"*.md 2>/dev/null || true
  rm -rf "${TMPD}"
}
trap cleanup EXIT

printf '\033[1;34m── Sourcing Scout degraded-mode fixture test ──\033[0m\n'

appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scout degraded fixture test')
  ON CONFLICT (tenant_slug) DO NOTHING;
SQL

fails=0
assert_eq() {  # label got want
  if [[ "$2" == "$3" ]]; then _ok "$1 ($2)"; else _fail "$1: got '$2', want '$3'"; fails=$((fails + 1)); fi
}
esc_count() {  # ESC code → row count
  appq <<SQL 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase = 'gating_failed' AND outcome = '$1';
COMMIT;
SQL
}
marker() {  # output_type → reason of latest row
  appq <<SQL 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(reason, '') FROM decision_log
WHERE tenant_slug = :'tenant' AND payload->>'output_type' = '$1'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
}

# ── Scenario A: bullhorn auth-absent + reed 429 + cvlibrary 3 candidates ──
cat > "${TMPD}/reed.json" <<'EOF'
[ {"ref":"reed:r1","source":"reed","name":"Never Returned","email":"nr@example.test","phone":null,"linkedin_url":null} ]
EOF
cat > "${TMPD}/cvlib3.json" <<'EOF'
[
 {"ref":"cvlibrary:cv-001","source":"cvlibrary","name":"Mia Martinez","email":"mia.m@example.test","phone":"+447700900020","linkedin_url":null,"headline":"Senior React Engineer","location":"London"},
 {"ref":"cvlibrary:cv-002","source":"cvlibrary","name":"Noah Ng","email":"noah.n@example.test","phone":"+447700900021","linkedin_url":null,"headline":"Frontend Engineer","location":"London"},
 {"ref":"cvlibrary:cv-004","source":"cvlibrary","name":"Olivia O'Brien","email":"olivia.o@example.test","phone":"+447700900022","linkedin_url":null,"headline":"React Engineer","location":"London"}
]
EOF

IFOS_SCOUT_FIXTURE_REED="${TMPD}/reed.json" IFOS_SCOUT_FORCE_429_REED=1 \
IFOS_SCOUT_FIXTURE_CVLIBRARY="${TMPD}/cvlib3.json" \
  bash "${CYCLE}" --mode cli --description "Senior React Engineer, London, £100k" \
  > "${TMPD}/cycleA.log" 2>&1
assert_eq "A1: cycle.sh exit code (Gate A floor FAIL)" "$?" "1"
assert_eq "A2: auth_refresh marker (reed live at refresh; bullhorn degraded)" \
  "$(marker auth_refresh_complete | grep -oE 'sources_ok:[0-9]/4; degraded:[a-z,]*')" \
  "sources_ok:2/4; degraded:bullhorn"
assert_eq "A3: ESC_BULLHORN_AUTH fired once (degraded-skip, not exit)" \
  "$(esc_count ESC_BULLHORN_AUTH)" "1"
assert_eq "A4: bullhorn_query marker records the skip" \
  "$(marker bullhorn_query | grep -oE 'results:0; queried:false')" "results:0; queried:false"
assert_eq "A5: ESC_RATE_LIMIT_HIT fired for the reed 429" \
  "$(esc_count ESC_RATE_LIMIT_HIT)" "1"
assert_eq "A6: reed_query returned 0 (cached_only, cold cache)" \
  "$(marker reed_query | grep -oE 'results:0')" "results:0"
assert_eq "A7: cvlibrary_query returned 3" \
  "$(marker cvlibrary_query | grep -oE 'results:3')" "results:3"
assert_eq "A8: linkedin_query is the explicit v1.0 no-op row" \
  "$(marker linkedin_query | grep -oE 'results:0; no_op')" "results:0; no_op"
assert_eq "A9: Gate A G1 floor → validate_gate_a_fail action row" \
  "$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase = 'action'
  AND payload->>'action_type' = 'validate_gate_a_fail'
  AND payload->>'payload_preview' LIKE 'ESC_AGENT_OUTPUT_SHAPE%';
COMMIT;
SQL
)" "1"
assert_eq "A10: ESC_AGENT_OUTPUT_SHAPE row present" \
  "$(esc_count ESC_AGENT_OUTPUT_SHAPE)" "1"
# NB: glob, not find — /tmp is a symlink on macOS and find won't descend it.
PARTIAL=""
for _p in "/tmp/sourcing-scout-${TENANT}-"*"-partial.md"; do
  [[ -f "${_p}" ]] && PARTIAL="${_p}" && break
done
if [[ -n "${PARTIAL}" ]]; then
  _ok "A11: partial draft held at /tmp (${PARTIAL##*/})"
  assert_eq "A12: partial draft carries the degradation exception notes" \
    "$(grep -c "degraded" "${PARTIAL}" | awk '{print ($1 > 0) ? "yes" : "no"}')" "yes"
else
  _fail "A11: partial draft missing from /tmp"; fails=$((fails + 1))
fi
assert_eq "A13: NO vault report written on Gate A failure" \
  "$(find "${IFOS_VAULT_ROOT}/${TENANT}/sourcing-scout-reports" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')" "0"
assert_eq "A14: scout_run_complete closes the session with gate_a:FAIL" \
  "$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND payload->>'action_type' = 'scout_run_complete'
  AND payload->>'payload_preview' LIKE '%gate_a:FAIL%';
COMMIT;
SQL
)" "1"

# ── Scenario B: ALL sources degraded → Step-2 floor escalation ────────────
bash "${CYCLE}" --mode cli --description "Senior React Engineer, London, £100k" \
  > "${TMPD}/cycleB.log" 2>&1
assert_eq "B1: cycle.sh exit code (all sources degraded)" "$?" "1"
assert_eq "B2: auth_refresh marker shows 0/4 live" \
  "$(marker auth_refresh_complete | grep -oE 'sources_ok:0/4')" "sources_ok:0/4"
assert_eq "B3: Step-2 <5-obtainable floor ESC fired (all_sources_degraded)" \
  "$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase = 'gating_failed'
  AND outcome = 'ESC_AGENT_OUTPUT_SHAPE'
  AND payload->>'reason' = 'all_sources_degraded_floor_unobtainable';
COMMIT;
SQL
)" "1"
assert_eq "B4: per-source auth ESCs fired for reed + cvlibrary too" \
  "$(printf '%s+%s' "$(esc_count ESC_REED_AUTH)" "$(esc_count ESC_CVLIBRARY_AUTH)")" "1+1"

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all degraded-mode assertions passed (14 scenario-A + 4 scenario-B)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
