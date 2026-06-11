#!/usr/bin/env bash
# Concierge — routing fixture test (spec-004 §7): event_type → escalation
# position (Step 6) + template selection incl. tenant→shared→bundled fallback
# (Step 5). Also proves the 12-event-taxonomy gate (ESC_LIFECYCLE_STATE_UNKNOWN
# warn + skip) and the full ESC route on addressee mismatch (Step 4).
#
# Mirrors the CC fixture pattern: registered throwaway tenant; FK-aware
# cleanup (tenants delete cascades decision_log + entities + tone_rule).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="concierge-routing-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
TEST_VAULT="$(mktemp -d)"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${TEST_VAULT}"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/concierge"
export CTX_AGENT_NAME="concierge" CTX_TENANT_SLUG="${TENANT}"
export CTX_CONCIERGE_MODE="webhook" IFOS_BH_FORCE_FIXTURE=1 IFOS_CONCIERGE_NO_LLM=1
export IFOS_SECRETS_FILE=/dev/null
readonly CYCLE="${CTX_AGENT_DIR}/cycle.sh"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
[[ -f "${CYCLE}" ]] || { _fail "cycle.sh missing"; exit 1; }

appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}" "$@"; }

# shellcheck disable=SC2329  # invoked indirectly via `trap cleanup EXIT`
cleanup() {
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  rm -rf "${TEST_VAULT}"
}
trap cleanup EXIT

printf '\033[1;34m── Concierge routing (Steps 4-6) fixture test ──\033[0m\n'

appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Concierge routing test')
  ON CONFLICT (tenant_slug) DO NOTHING;
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO entities (tenant_slug, entity_type, entity_id, data) VALUES
  (:'tenant','candidate','CAND-R','{"id":"CAND-R","name":"Rosa Diaz","email":"rosa@example.com"}'),
  (:'tenant','placement','PLAC-HI','{"id":"PLAC-HI","role":"CTO","client_id":"CL-1","placement_value":15000}'),
  (:'tenant','placement','PLAC-LO','{"id":"PLAC-LO","role":"Engineer","client_id":"CL-1","placement_value":5000}'),
  (:'tenant','client','CL-1','{"id":"CL-1","company":"Acme Tech Ltd"}')
ON CONFLICT (tenant_slug, entity_type, entity_id) DO NOTHING;
COMMIT;
SQL

fails=0
pass() { _ok "$1"; }
flunk() { _fail "$1"; fails=$((fails + 1)); }

run_cycle() {  # event_type placement_id [extra_env...]
  local ev="$1" plac="$2"
  CTX_WEBHOOK_PAYLOAD="$(printf '{"event_type":"%s","candidate_id":"CAND-R","placement_id":"%s","client_id":"CL-1","state_from":"a","state_to":"b","event_timestamp_iso":"%s"}' \
      "${ev}" "${plac}" "$(date -u +%Y-%m-%dT%H:%M:%SZ)")" \
    CTX_STEPS_OVERRIDE="0,1,3,4,5,6" bash "${CYCLE}" >/dev/null 2>&1
}
last_marker_reason() {  # output_type
  appq --set=ot="$1" <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT reason FROM decision_log
WHERE tenant_slug = :'tenant' AND phase='output' AND payload->>'output_type' = :'ot'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
}
assert_position() {  # label event placement want_position
  if ! run_cycle "$2" "$3"; then flunk "$1: cycle failed"; return; fi
  local r; r="$(last_marker_reason escalation_position_set)"
  if [[ "${r}" == *"position:$4"* ]]; then
    pass "$1 → position $4"
  else
    flunk "$1: expected position:$4, got '${r}'"
  fi
}

# ── Step 6: event_type → escalation position ────────────────────────────
assert_position "rejection (sensitive)"             rejection            PLAC-LO 3
assert_position "withdrawal (sensitive)"            withdrawal           PLAC-LO 3
assert_position "on-hold, placement £15k (>£10k)"   on-hold              PLAC-HI 3
assert_position "on-hold, placement £5k (status)"   on-hold              PLAC-LO 2
assert_position "offer-extended (placement-pos.)"   offer-extended       PLAC-LO 2
assert_position "offer-accepted (placement-pos.)"   offer-accepted       PLAC-LO 2
assert_position "start-date-confirmed"              start-date-confirmed PLAC-LO 2
assert_position "interview-booked (standard)"       interview-booked     PLAC-LO 1
assert_position "7-day-check-in (nurture)"          7-day-check-in       PLAC-LO 1
assert_position "application-received"              application-received PLAC-LO 1

# ── Step 5: template selection fallback chain ───────────────────────────
# (a) nothing deployed → bundled (in-repo canonical copy)
run_cycle interview-booked PLAC-LO
_r="$(last_marker_reason template_selected)"
if [[ "${_r}" == *"source:bundled"* && "${_r}" == *"template_id:shared-interview-booked-candidate-v1"* ]]; then
  pass "template fallback: bundled copy selected with correct template_id"
else flunk "template fallback bundled: got '${_r}'"; fi

# (b) shared library deployed under the vault root → source:shared
mkdir -p "${TEST_VAULT}/shared"
cp "${CTX_AGENT_DIR}/templates/common-comms-templates.yaml" "${TEST_VAULT}/shared/common-comms-templates.yaml"
run_cycle interview-booked PLAC-LO
_r="$(last_marker_reason template_selected)"
if [[ "${_r}" == *"source:shared"* ]]; then
  pass "template fallback: vault shared/common-comms-templates.yaml wins over bundled"
else flunk "template fallback shared: got '${_r}'"; fi

# (c) tenant override present → source:tenant (highest precedence)
mkdir -p "${TEST_VAULT}/${TENANT}/concierge-templates"
printf 'subject: Tenant-special interview prep\nHi {{candidate_first_name}},\n\nTenant-specific interview prep body.\n' \
  > "${TEST_VAULT}/${TENANT}/concierge-templates/interview-booked-candidate.md"
run_cycle interview-booked PLAC-LO
_r="$(last_marker_reason template_selected)"
if [[ "${_r}" == *"source:tenant"* && "${_r}" == *"template_id:tenant-interview-booked-candidate"* ]]; then
  pass "template fallback: tenant override wins over shared"
else flunk "template fallback tenant: got '${_r}'"; fi

# ── Step 1: 12-event taxonomy gate ──────────────────────────────────────
run_cycle made-up-event PLAC-LO
_r="$(last_marker_reason lifecycle_event_detected)"
_esc="$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT outcome FROM decision_log WHERE tenant_slug = :'tenant' AND phase='gating_failed'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
if [[ "${_r}" == *"UNKNOWN"* && "${_esc}" == "ESC_LIFECYCLE_STATE_UNKNOWN" ]]; then
  pass "unknown event → ESC_LIFECYCLE_STATE_UNKNOWN warn + skip"
else flunk "taxonomy gate: marker '${_r}' esc '${_esc}'"; fi

# ── Step 4: addressee mismatch ESC route (cycle-side gate) ──────────────
CTX_WEBHOOK_PAYLOAD="$(printf '{"event_type":"interview-booked","candidate_id":"CAND-R","placement_id":"PLAC-LO","client_id":"CL-1","state_from":"a","state_to":"b","event_timestamp_iso":"%s"}' "$(date -u +%Y-%m-%dT%H:%M:%SZ)")" \
  CTX_STEPS_OVERRIDE="0,1,3,4" IFOS_FORCE_RECIPIENT_EMAIL="stranger@evil.example" \
  bash "${CYCLE}" >/dev/null 2>&1
rc=$?
_esc="$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT outcome FROM decision_log WHERE tenant_slug = :'tenant' AND phase='gating_failed'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
if [[ "${rc}" -ne 0 && "${_esc}" == "ESC_ADDRESSEE_MISMATCH" ]]; then
  pass "forced wrong recipient → exit ${rc} + ESC_ADDRESSEE_MISMATCH (blocking)"
else flunk "addressee route: exit ${rc}, esc '${_esc}'"; fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all routing assertions passed (10 position routes + 3-stage template fallback + taxonomy gate + addressee ESC)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
