#!/usr/bin/env bash
# Concierge — Step 2 anti-duplicate guard fixture test (spec-004 §7).
#
# Seeds prior draft/send decision_log rows and asserts the 24h anti-duplicate
# guard per agent.md §4 Step 2 + Q7 disposition:
#   fresh                     → duplicate_status:fresh; pipeline proceeds
#   found + completed send    → true duplicate; SKIP (no context fetch)
#   found + NO completed send → fresh-allow; pipeline proceeds (Q7)
#
# cycle.sh runs with CTX_STEPS_OVERRIDE so only Steps 0-3 execute (the guard
# + the step after it, proving proceed-vs-skip). FK-aware cleanup: deleting
# the tenants row cascades decision_log + entities.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="concierge-antidup-test"
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

printf '\033[1;34m── Concierge anti-duplicate guard (Step 2) fixture test ──\033[0m\n'

appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Concierge antidup test')
  ON CONFLICT (tenant_slug) DO NOTHING;
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO entities (tenant_slug, entity_type, entity_id, data) VALUES
  (:'tenant','candidate','CAND-X','{"id":"CAND-X","name":"Xena Ward","email":"xena@example.com"}'),
  (:'tenant','candidate','CAND-Y','{"id":"CAND-Y","name":"Yusuf Adeyemi","email":"yusuf@example.com"}'),
  (:'tenant','candidate','CAND-Z','{"id":"CAND-Z","name":"Zara Bell","email":"zara@example.com"}')
ON CONFLICT (tenant_slug, entity_type, entity_id) DO NOTHING;
-- CAND-X: prior draft row AND completed send within 24h (TRUE DUPLICATE).
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at) VALUES
  (:'tenant','concierge','action','yellow',
   jsonb_build_object('action_type','concierge_email_draft','target','candidate:CAND-X:interview-booked','tier','yellow'),
   now() - interval '2 hours'),
  (:'tenant','concierge','action','orange',
   jsonb_build_object('action_type','gmail_outlook_send_to_candidate','target','candidate:CAND-X','tier','orange'),
   now() - interval '1 hour'),
-- CAND-Y: prior draft row but NO completed send (FRESH-ALLOW per Q7).
  (:'tenant','concierge','action','yellow',
   jsonb_build_object('action_type','concierge_email_draft','target','candidate:CAND-Y:interview-booked','tier','yellow'),
   now() - interval '2 hours'),
-- CAND-Z: a STALE draft+send pair OUTSIDE the 24h window (must read fresh).
  (:'tenant','concierge','action','yellow',
   jsonb_build_object('action_type','concierge_email_draft','target','candidate:CAND-Z:interview-booked','tier','yellow'),
   now() - interval '30 hours'),
  (:'tenant','concierge','action','orange',
   jsonb_build_object('action_type','gmail_outlook_send_to_candidate','target','candidate:CAND-Z','tier','orange'),
   now() - interval '29 hours');
COMMIT;
SQL

fails=0
_payload() {  # candidate_id
  printf '{"event_type":"interview-booked","candidate_id":"%s","state_from":"applied","state_to":"interview-scheduled","event_timestamp_iso":"%s"}' \
    "$1" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
run_cycle() {  # candidate_id steps → exit code in $?, marker rows queryable
  CTX_WEBHOOK_PAYLOAD="$(_payload "$1")" CTX_STEPS_OVERRIDE="$2" bash "${CYCLE}" >/dev/null 2>&1
}
last_antidup_reason() {  # candidate_id
  appq --set=cid="$1" <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT reason FROM decision_log
WHERE tenant_slug = :'tenant' AND phase='output'
  AND payload->>'output_type'='anti_duplicate_check'
  AND payload->>'artefact_ref' = 'candidate:' || :'cid' || ':interview-booked'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
}
context_fetch_count() {  # candidate_id
  appq --set=cid="$1" <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase='output'
  AND payload->>'output_type'='bullhorn_context_fetched'
  AND payload->>'artefact_ref' = 'candidate:' || :'cid';
COMMIT;
SQL
}
pass() { _ok "$1"; }
flunk() { _fail "$1"; fails=$((fails + 1)); }

# Case 1 — TRUE DUPLICATE (CAND-X): guard skips; Step 3 never runs.
if run_cycle CAND-X "0,1,2,3"; then pass "true-dup: cycle exits 0 (graceful skip)"; else flunk "true-dup: cycle exit non-zero"; fi
_r="$(last_antidup_reason CAND-X)"
if [[ "${_r}" == *"duplicate_status:found"* && "${_r}" == *"prior_send_completed:true"* ]]; then
  pass "true-dup: duplicate_status:found + prior_send_completed:true"
else flunk "true-dup: marker reason was '${_r}'"; fi
if [[ "$(context_fetch_count CAND-X)" == "0" ]]; then
  pass "true-dup: context fetch SKIPPED (no Step 3 row)"
else flunk "true-dup: Step 3 ran despite true duplicate"; fi

# Case 2 — FRESH-ALLOW (CAND-Y): prior draft, no send → pipeline proceeds.
if run_cycle CAND-Y "0,1,2,3"; then pass "fresh-allow: cycle exits 0"; else flunk "fresh-allow: cycle exit non-zero"; fi
_r="$(last_antidup_reason CAND-Y)"
if [[ "${_r}" == *"duplicate_status:found"* && "${_r}" == *"prior_send_completed:false"* ]]; then
  pass "fresh-allow: duplicate_status:found + prior_send_completed:false"
else flunk "fresh-allow: marker reason was '${_r}'"; fi
if [[ "$(context_fetch_count CAND-Y)" == "1" ]]; then
  pass "fresh-allow: pipeline PROCEEDED to Step 3 (context fetched)"
else flunk "fresh-allow: Step 3 did not run"; fi

# Case 3 — STALE pair outside 24h (CAND-Z): window respected → fresh.
if run_cycle CAND-Z "0,1,2,3"; then pass "24h-window: cycle exits 0"; else flunk "24h-window: cycle exit non-zero"; fi
_r="$(last_antidup_reason CAND-Z)"
if [[ "${_r}" == *"duplicate_status:fresh"* ]]; then
  pass "24h-window: 30h-old draft+send reads duplicate_status:fresh"
else flunk "24h-window: marker reason was '${_r}'"; fi
if [[ "$(context_fetch_count CAND-Z)" == "1" ]]; then
  pass "24h-window: pipeline PROCEEDED to Step 3"
else flunk "24h-window: Step 3 did not run"; fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all anti-duplicate assertions passed (true-dup skip / Q7 fresh-allow / 24h window)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
