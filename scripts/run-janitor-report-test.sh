#!/usr/bin/env bash
# Janitor — day-30 report fixture test (spec-001 §7).
#
# Seeds decision_log action/gating rows + entities under a registered
# throwaway tenant, then runs cycle.sh --mode report-only and asserts:
#   1. the 8-section report shape (agent.md §3 Output 1)
#   2. the two-threshold Gate B logic — BOTH must pass, NOT a composite
#      (scenario A: both met → gate_b_met:true; scenario B: completeness met
#       but dedup missed → gate_b_met:false AND gate_b_both_missed:false)
#   3. ESC_GATE_B_MISS fires ONLY on 3 consecutive both-missed runs (+ exit 1)
#
# cycle.sh opens its OWN DB connections, so fixtures are COMMITTED then cleaned
# up (tenant DELETE cascades decision_log/entities/tenant_adapters; decision_log
# row pruning between scenarios goes through the owner — append-only for the app).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="janitor-report-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
TMPD="$(mktemp -d)"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${TMPD}/vault"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/janitor"
export CTX_AGENT_NAME="janitor" CTX_TENANT_SLUG="${TENANT}"
export CTX_JANITOR_DEDUP_THRESHOLD="0.85" CTX_BULLHORN_CORPORATION_ID="9876"
export CTX_OPERATOR_TELEGRAM_CHAT_ID="unset" CTX_VOICE_CORPUS_STATE="absent"
export IFOS_JANITOR_NO_LLM=1 IFOS_JANITOR_RETRY_DELAY_S=0
readonly CYCLE="${CTX_AGENT_DIR}/cycle.sh"
readonly OWNER_DB="${IFOS_OWNER_DB:-ifos_v2_dev}"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
[[ -f "${CYCLE}" ]] || { _fail "cycle.sh missing"; exit 1; }

appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }
ownq() { psql -U "${USER}" -d "${OWNER_DB}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }

# shellcheck disable=SC2329  # invoked indirectly via `trap cleanup EXIT`
cleanup() {
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  ownq <<'SQL' >/dev/null 2>&1 || true
BEGIN; SET LOCAL app.current_tenant = :'tenant';
DELETE FROM recent_edit WHERE tenant_slug = :'tenant';
COMMIT;
SQL
  rm -rf "${TMPD}"
}
trap cleanup EXIT

fails=0
assert_eq() {  # label got want
  if [[ "$2" == "$3" ]]; then _ok "$1 ($2)"; else _fail "$1: got '$2', want '$3'"; fails=$((fails + 1)); fi
}

# Seed one synthetic janitor action row (phase=action) with the given action_type.
seed_action() {  # action_type count
  local at="$1" n="$2" i
  for ((i = 0; i < n; i++)); do
    appq <<SQL >/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload)
VALUES (:'tenant', 'janitor', 'action', 'yellow', 'seeded fixture row',
        ('{"action_type": "${at}", "tier": "yellow"}')::jsonb);
COMMIT;
SQL
  done
}

# Latest day_30_report reason (Gate B payload string).
report_reason() {
  appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT reason FROM decision_log
WHERE tenant_slug = :'tenant' AND agent_name = 'janitor'
  AND phase = 'output' AND payload->>'output_type' = 'day_30_report'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
}

printf '\033[1;34m── Janitor day-30 report fixture test ──\033[0m\n'

if ! psql "${IFOS_DB_URL}" -tAc 'SELECT 1' >/dev/null 2>&1; then
  _fail "no reachable IFOS_DB_URL"; exit 1
fi

# Register tenant + minimal entities corpus (1 missing field → completeness
# denominators stay small + deterministic) + recent_edit coverage rows.
appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Janitor report fixture test')
  ON CONFLICT (tenant_slug) DO NOTHING;
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO entities (tenant_slug, entity_type, entity_id, data) VALUES
  (:'tenant','candidate','1001','{"name":"Jane Doe","email":"jane@x.test","location":"London"}'),
  (:'tenant','candidate','1002','{"name":"Ann Other","email":"ann@x.test","location":"Leeds"}'),
  (:'tenant','client','5001','{"name":"Acme Tech Ltd","industry":null,"size_employees":"50","companies_house_number":"12345678"}')
ON CONFLICT (tenant_slug, entity_type, entity_id) DO UPDATE SET data = EXCLUDED.data;
COMMIT;
SQL
ownq <<'SQL' >/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO recent_edit (tenant_slug, agent_name, action_type, target_entity_type, target_entity_id, original_text, edited_text, resolution, resolved_at) VALUES
  (:'tenant','scribe','note_rewrite','candidate','1001','o','e','approved_after_edit', now() - interval '2 days'),
  (:'tenant','scribe','note_rewrite','candidate','1002','o','e','rejected', now() - interval '2 days');
COMMIT;
SQL

# ── Scenario A — both thresholds met ─────────────────────────────────────
# dedup: 3 merges / (3 + 1 review) = 75% ≥ 15 · completeness: 2 backfills /
# (2 + 1 missing) = 66.7% ≥ 10 → Gate B MET.
seed_action "bullhorn_candidate_dedupe" 3
seed_action "bullhorn_field_backfill" 2
seed_action "bullhorn_note_attach" 1
appq <<'SQL' >/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload)
VALUES (:'tenant', 'janitor', 'gating_failed', 'ESC_DUPLICATE_DETECTED', '',
        '{"escalation_code": "ESC_DUPLICATE_DETECTED", "review_band_reason": "recent_activity_days:20"}');
COMMIT;
SQL

bash "${CYCLE}" --mode report-only >/dev/null 2>&1; _rc=$?
assert_eq "A: report-only exits 0" "${_rc}" "0"

REPORT="$(find "${TMPD}/vault/${TENANT}/janitor-reports" -name 'day-30-*.md' 2>/dev/null | head -1)"
if [[ -n "${REPORT}" && -f "${REPORT}" ]]; then
  _ok "A: report written to vault (${REPORT##*/})"
else
  _fail "A: report file missing"; fails=$((fails + 1))
fi
_sections="$(grep -cE '^## [1-8]\.' "${REPORT}" 2>/dev/null || echo 0)"
assert_eq "A: 8 sections present (agent.md §3 Output 1)" "${_sections}" "8"
_reason="$(report_reason)"
case "${_reason}" in
  *"dedup_pct:75.0"*) _ok "A: dedup_pct 75.0 (3 merges / 4 pairs)" ;;
  *) _fail "A: dedup_pct wrong in '${_reason}'"; fails=$((fails + 1)) ;;
esac
case "${_reason}" in
  *"completeness_pct:66.7"*) _ok "A: completeness_pct 66.7 (2 backfills / 3)" ;;
  *) _fail "A: completeness_pct wrong in '${_reason}'"; fails=$((fails + 1)) ;;
esac
case "${_reason}" in
  *"gate_b_met:true"*) _ok "A: Gate B MET (both thresholds)" ;;
  *) _fail "A: gate_b_met not true in '${_reason}'"; fails=$((fails + 1)) ;;
esac
if grep -q 'Gate B: MET' "${REPORT}" 2>/dev/null; then
  _ok "A: report section 6 shows Gate B MET"
else
  _fail "A: report section 6 missing Gate B MET"; fails=$((fails + 1))
fi

# ── Scenario B — completeness met, dedup missed → NOT met, NOT both-missed ─
# Proves two independent thresholds (AND), not a composite: a strong
# completeness score cannot cover for a failed dedup score.
ownq <<'SQL' >/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
DELETE FROM decision_log
WHERE tenant_slug = :'tenant' AND agent_name = 'janitor'
  AND payload->>'action_type' = 'bullhorn_candidate_dedupe';
COMMIT;
SQL

bash "${CYCLE}" --mode report-only >/dev/null 2>&1; _rc=$?
assert_eq "B: report-only exits 0 (single-threshold miss is not an error)" "${_rc}" "0"
_reason="$(report_reason)"
case "${_reason}" in
  *"dedup_pct:0.0"*"gate_b_met:false"*) _ok "B: dedup missed → Gate B NOT met (no composite covering)" ;;
  *) _fail "B: expected dedup_pct:0.0 + gate_b_met:false in '${_reason}'"; fails=$((fails + 1)) ;;
esac
case "${_reason}" in
  *"gate_b_both_missed:false"*) _ok "B: both_missed:false (completeness still met) — no ESC path" ;;
  *) _fail "B: expected gate_b_both_missed:false in '${_reason}'"; fails=$((fails + 1)) ;;
esac

# ── Scenario C — 3 consecutive both-missed runs → ESC_GATE_B_MISS + exit 1 ─
# Remove the backfills too (both metrics now 0) + seed 2 prior both-missed
# day_30_report rows; the current run's row is the 3rd consecutive.
ownq <<'SQL' >/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
DELETE FROM decision_log
WHERE tenant_slug = :'tenant' AND agent_name = 'janitor'
  AND payload->>'action_type' IN ('bullhorn_field_backfill', 'bullhorn_note_attach');
COMMIT;
SQL
for _i in 1 2; do
  appq <<'SQL' >/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload)
VALUES (:'tenant', 'janitor', 'output', 'produced',
        'Gate-B: dedup_pct:0.0; completeness_pct:0.0; gate_b_met:false; gate_b_both_missed:true; sections:8',
        '{"output_type": "day_30_report", "artefact_ref": "seeded-prior-run"}');
COMMIT;
SQL
done

bash "${CYCLE}" --mode report-only >/dev/null 2>&1; _rc=$?
assert_eq "C: 3rd consecutive both-missed run exits 1" "${_rc}" "1"
_esc="$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase = 'gating_failed'
  AND outcome = 'ESC_GATE_B_MISS';
COMMIT;
SQL
)"
assert_eq "C: ESC_GATE_B_MISS fired exactly once" "${_esc}" "1"
# The run-complete row still lands on the failing path (audit completeness).
_rcomp="$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase = 'action'
  AND payload->>'action_type' = 'janitor_run_complete';
COMMIT;
SQL
)"
assert_eq "C: janitor_run_complete rows for all 3 report-only runs" "${_rcomp}" "3"

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all report assertions passed (8 sections + AND-threshold Gate B + 3-consecutive ESC_GATE_B_MISS)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
