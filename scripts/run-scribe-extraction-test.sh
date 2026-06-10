#!/usr/bin/env bash
# Scribe — deterministic extraction + schema-validation fixture test (spec-002 §7).
#
# Covers: seeded transcript + seeded entity → cycle.sh replay end-to-end
# (Steps 1-10 markers in decision_log + entities cache write), direct
# extract-fields/validate-fields assertions (≥3 fields ≥0.6; name + type/range
# drop-invalid), and the <3-valid Gate A fail path
# (ESC_FIELD_EXTRACTION_LOW_CONFIDENCE + validate_gate_a_fail + replay exit 1).
#
# CC fixture pattern: registered throwaway tenant (decision_log/entities FK →
# tenants ON DELETE CASCADE makes the tenant delete the cleanup); recent_edit
# has no FK so it is deleted best-effort. No live Bullhorn/Granola:
# BH_BRIDGE_TEST_MODE=ok proves the green path through bin/bh-bridge.sh
# (spec-002 §8 — creds are founder-gated; never faked outside the test hook).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="scribe-extract-fixture"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/scribe"
export CTX_AGENT_NAME="scribe" CTX_TENANT_SLUG="${TENANT}"
export CTX_BULLHORN_CORPORATION_ID="9876" CTX_GRANOLA_WORKSPACE_ID="ws-fix-1"
export CTX_GRANOLA_PLAN_TIER="paid" CTX_FIRM_DOMAIN_WHITELIST="acme.test" CTX_VOICE_CORPUS_ID="none"
export BH_BRIDGE_TEST_MODE="ok" SCRIBE_FETCH_RETRY_DELAY="0"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
command -v jq   >/dev/null 2>&1 || { _fail "jq not on PATH"; exit 1; }

TMPD="$(mktemp -d)"
export IFOS_VAULT_ROOT="${TMPD}/vault"

appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }

# shellcheck disable=SC2329  # invoked via trap
cleanup() {
  appq <<'SQL' >/dev/null 2>&1 || true
BEGIN; SET LOCAL app.current_tenant = :'tenant';
DELETE FROM recent_edit WHERE tenant_slug = :'tenant';
COMMIT;
SQL
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  rm -rf "${TMPD}" "/tmp/scribe-${TENANT}-"* 2>/dev/null
}
trap cleanup EXIT

printf '\033[1;34m── Scribe extraction + schema-validation fixture test ──\033[0m\n'

# Register tenant + seed the candidate entity the resolver must hit.
appq <<'SQL' >/dev/null || { _fail "tenant/entity seed failed"; exit 1; }
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scribe extraction fixture')
  ON CONFLICT (tenant_slug) DO NOTHING;
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO entities (tenant_slug, entity_type, entity_id, data) VALUES
  (:'tenant','candidate','1001','{"email":"jane.doe@example.test","first_name":"Jane"}')
ON CONFLICT (tenant_slug, entity_type, entity_id) DO UPDATE SET data = EXCLUDED.data;
COMMIT;
SQL

# Seeded transcript (rich: 6 extractable candidate fields).
cat > "${TMPD}/transcript-rich.txt" <<'EOF'
[00:05] founder@acme.test: Hi Jane, thanks for taking the call.
[00:12] jane.doe@example.test: Happy to be here. I'm based in Manchester.
[00:25] jane.doe@example.test: Currently a Senior Backend Engineer at MyCo Ltd. 8 weeks notice.
[00:45] jane.doe@example.test: Salary expectation around £85k to £95k.
[01:02] jane.doe@example.test: Key skills: Python, Postgres, Kafka.
[01:20] founder@acme.test: Are you available for interview week of June 16?
EOF
END_TS="$(date -u -v-4M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '4 minutes ago' +%Y-%m-%dT%H:%M:%SZ)"
jq -nc --arg end "${END_TS}" '[{id:"meeting-001",title:"Discovery call — Jane Doe",end_time:$end,duration_minutes:45,
  attendees:["founder@acme.test","jane.doe@example.test"],has_transcript:true,notes_markdown:""}]' \
  > "${TMPD}/meetings.json"

fails=0

# ── 1. Direct extractor: ≥3 fields with confidence ≥0.6 ───────────────────
EX="$(bash "${CTX_AGENT_DIR}/bin/extract-fields.sh" --transcript "${TMPD}/transcript-rich.txt" --entity-type candidate)"
N_CONF="$(jq '[.[] | select(.confidence >= 0.6)] | length' <<<"${EX}")"
if [[ "${N_CONF}" -ge 3 ]]; then
  _ok "extractor: ${N_CONF} fields ≥0.6 confidence (≥3 required)"
else
  _fail "extractor: only ${N_CONF} fields ≥0.6"; fails=$((fails + 1))
fi
for f in location current_role notice_period_weeks salary_expectation_min; do
  if jq -e --arg f "$f" '[.[] | select(.field_name == $f)] | length == 1' <<<"${EX}" >/dev/null; then
    _ok "extractor: field ${f} present"
  else
    _fail "extractor: field ${f} missing"; fails=$((fails + 1))
  fi
done

# ── 2. Schema validator: name + type/range checks, drop-invalid ───────────
cat > "${TMPD}/bad-fields.json" <<'EOF'
[{"field_name":"location","value":"Leeds","confidence":0.9},
 {"field_name":"bogus_field","value":"x","confidence":0.9},
 {"field_name":"notice_period_weeks","value":"eight","confidence":0.9},
 {"field_name":"employment_type","value":"freelance","confidence":0.9},
 {"field_name":"salary_expectation_min","value":-5,"confidence":0.9}]
EOF
VR="$(bash "${CTX_AGENT_DIR}/bin/validate-fields.sh" --entity-type candidate --fields-file "${TMPD}/bad-fields.json")"
if [[ "$(jq -r '.valid_count' <<<"${VR}")" == "1" ]]; then
  _ok "validator: drop-invalid (1 valid of 5; bad name + bad int + bad enum + negative number dropped)"
else
  _fail "validator: expected valid_count 1, got $(jq -r '.valid_count' <<<"${VR}")"; fails=$((fails + 1))
fi
if jq -e '.dropped | map(.field_name) | sort == ["bogus_field","employment_type","notice_period_weeks","salary_expectation_min"]' \
  <<<"${VR}" >/dev/null; then
  _ok "validator: dropped set is exactly the 4 invalid fields"
else
  _fail "validator: unexpected dropped set: $(jq -c '.dropped' <<<"${VR}")"; fails=$((fails + 1))
fi

# ── 3. End-to-end replay: every spec-002 §3 marker lands in decision_log ──
export IFOS_SCRIBE_MEETINGS_FILE="${TMPD}/meetings.json"
export IFOS_SCRIBE_TRANSCRIPT_FILE="${TMPD}/transcript-rich.txt"
if bash "${CTX_AGENT_DIR}/cycle.sh" --mode replay --call-id meeting-001 >/dev/null 2>&1; then
  _ok "cycle.sh replay: exit 0 (happy path)"
else
  _fail "cycle.sh replay: non-zero exit on happy path"; fails=$((fails + 1))
fi

assert_marker() {  # <phase> <type-json-key> <name>
  local got
  got="$(appq <<SQL 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND phase = '$1' AND payload->>'$2' = '$3';
COMMIT;
SQL
)"
  if [[ "${got}" == *1* || "${got}" -ge 1 ]] 2>/dev/null; then
    _ok "marker: $1/$3"
  else
    _fail "marker: $1/$3 missing"; fails=$((fails + 1))
  fi
}
assert_marker trigger trigger_type session_start
assert_marker output output_type webhook_verified
assert_marker output output_type bullhorn_auth_refreshed
assert_marker output output_type transcript_fetched
assert_marker output output_type entity_resolved
assert_marker output output_type fields_extracted
assert_marker output output_type tacit_note_rendered
assert_marker output output_type fields_validated
assert_marker action action_type bullhorn_scribe_field_write
assert_marker action action_type bullhorn_note_append_summary
assert_marker action action_type scribe_run_complete

# Entities cache got the field write (≥3 new keys) + recent_edit deferred row.
N_KEYS="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM jsonb_object_keys((SELECT data FROM entities WHERE tenant_slug=:'tenant' AND entity_id='1001')) k
WHERE k IN ('location','current_role','notice_period_weeks','salary_expectation_min','salary_expectation_max','key_skills');
COMMIT;
SQL
)"
if [[ "${N_KEYS:-0}" -ge 3 ]]; then
  _ok "entities cache: ${N_KEYS} extracted fields written"
else
  _fail "entities cache: only ${N_KEYS:-0} fields written"; fails=$((fails + 1))
fi
RE="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM recent_edit WHERE tenant_slug=:'tenant' AND agent_name='scribe' AND resolution='deferred';
COMMIT;
SQL
)"
if [[ "${RE:-0}" -ge 1 ]]; then
  _ok "recent_edit: deferred Gate-B row written"
else
  _fail "recent_edit: no deferred row"; fails=$((fails + 1))
fi

# Tacit note in vault, 0600.
NOTE="$(find "${IFOS_VAULT_ROOT}/${TENANT}/scribe-notes" -name 'meeting-001-*.md' 2>/dev/null | head -1)"
if [[ -n "${NOTE}" && "$(stat -f '%Lp' "${NOTE}" 2>/dev/null || stat -c '%a' "${NOTE}" 2>/dev/null)" == "600" ]]; then
  _ok "vault tacit-note written mode 0600"
else
  _fail "vault tacit-note missing or wrong mode"; fails=$((fails + 1))
fi

# ── 3b. Bridge-contract paths (agreed @ifos/bullhorn CLI contract;
#        review-scribe.md orchestrator ruling — proven WITHOUT the live CLI) ─
BB="${CTX_AGENT_DIR}/bin/bh-bridge.sh"

# Shim: entity-scoped create-note hitting unsupported_entity → exit 5 + reason.
OUT="$(BH_BRIDGE_TEST_MODE=note-unsupported bash "${BB}" create-note \
  --entity-type JobOrder --entity-id 42 --body-file /dev/null 2>/dev/null)" && rc=0 || rc=$?
if [[ "${rc}" -eq 5 && "$(jq -r '.reason // ""' <<<"${OUT}")" == "unsupported_entity" ]]; then
  _ok "shim: unsupported_entity → exit 5 with contract reason"
else
  _fail "shim: expected exit 5 + reason unsupported_entity, got exit ${rc}: ${OUT}"; fails=$((fails + 1))
fi

# Shim: person-scoped create-note succeeds under the same mode (the fallback leg).
if BH_BRIDGE_TEST_MODE=note-unsupported bash "${BB}" create-note \
  --person-id 42 --body-file /dev/null >/dev/null 2>&1; then
  _ok "shim: person-scoped create-note succeeds (fallback leg)"
else
  _fail "shim: person-scoped create-note failed under note-unsupported mode"; fails=$((fails + 1))
fi

# Shim: numeric-id guard (agreed contract: ids numeric) → usage error exit 2.
BH_BRIDGE_TEST_MODE=ok bash "${BB}" update-entity --entity-type Candidate \
  --id not-a-number --patch '{}' >/dev/null 2>&1 && rc=0 || rc=$?
if [[ "${rc}" -eq 2 ]]; then
  _ok "shim: non-numeric --id rejected (exit 2)"
else
  _fail "shim: expected exit 2 for non-numeric id, got ${rc}"; fails=$((fails + 1))
fi

# cycle.sh Step 9: unsupported_entity on a person entity → person-resolution
# fallback succeeds; yellow row records fallback:person_scoped.
if BH_BRIDGE_TEST_MODE=note-unsupported bash "${CTX_AGENT_DIR}/cycle.sh" \
  --mode replay --call-id meeting-001 >/dev/null 2>&1; then
  _ok "cycle.sh replay (note-unsupported): exit 0 via person fallback"
else
  _fail "cycle.sh replay (note-unsupported): non-zero exit"; fails=$((fails + 1))
fi
FB="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log WHERE tenant_slug=:'tenant' AND phase='action'
  AND payload->>'action_type'='bullhorn_note_append_summary'
  AND payload->>'payload_preview' LIKE '%fallback:person_scoped%';
COMMIT;
SQL
)"
if [[ "${FB:-0}" -ge 1 ]]; then
  _ok "cycle.sh: bullhorn_note_append_summary row carries fallback:person_scoped"
else
  _fail "cycle.sh: no fallback:person_scoped note row"; fails=$((fails + 1))
fi

# cycle.sh Step 9 hard fail → Step-8 rollback INCLUDING the recent_edit
# 'deferred' row (review F6: Gate B denominator not inflated by a rolled-back
# write). Deferred count must be unchanged across the failed run.
RE_BEFORE="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM recent_edit WHERE tenant_slug=:'tenant' AND agent_name='scribe' AND resolution='deferred';
COMMIT;
SQL
)"
BH_BRIDGE_TEST_MODE=note-fail bash "${CTX_AGENT_DIR}/cycle.sh" \
  --mode replay --call-id meeting-001 >/dev/null 2>&1 && rc=0 || rc=$?
if [[ "${rc}" -eq 1 ]]; then
  _ok "cycle.sh replay (note-fail): exit 1 (note attach hard-failed)"
else
  _fail "cycle.sh replay (note-fail): expected exit 1, got ${rc}"; fails=$((fails + 1))
fi
RE_AFTER="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM recent_edit WHERE tenant_slug=:'tenant' AND agent_name='scribe' AND resolution='deferred';
COMMIT;
SQL
)"
if [[ "${RE_AFTER:-x}" == "${RE_BEFORE:-y}" ]]; then
  _ok "rollback: recent_edit deferred count unchanged (${RE_BEFORE} → ${RE_AFTER}; F6)"
else
  _fail "rollback: recent_edit deferred count ${RE_BEFORE} → ${RE_AFTER} (F6 row not removed)"; fails=$((fails + 1))
fi
ESC9="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT outcome FROM decision_log WHERE tenant_slug=:'tenant' AND phase='gating_failed' ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
if [[ "${ESC9}" == "ESC_BULLHORN_WRITE_FAIL" ]]; then
  _ok "rollback: ESC_BULLHORN_WRITE_FAIL routed for the note-attach failure"
else
  _fail "rollback: expected ESC_BULLHORN_WRITE_FAIL, got '${ESC9}'"; fails=$((fails + 1))
fi

# ── 4. <3-fields Gate A fail (sparse transcript → ESC + gate row + exit 1) ─
cat > "${TMPD}/transcript-sparse.txt" <<'EOF'
[00:05] founder@acme.test: Hi Jane, quick one.
[00:12] jane.doe@example.test: I'm based in Manchester. Got to run, sorry!
EOF
jq -nc --arg end "${END_TS}" '[{id:"meeting-002",title:"Short call",end_time:$end,duration_minutes:2,
  attendees:["founder@acme.test","jane.doe@example.test"],has_transcript:true,notes_markdown:""}]' \
  > "${TMPD}/meetings2.json"
export IFOS_SCRIBE_MEETINGS_FILE="${TMPD}/meetings2.json"
export IFOS_SCRIBE_TRANSCRIPT_FILE="${TMPD}/transcript-sparse.txt"
bash "${CTX_AGENT_DIR}/cycle.sh" --mode replay --call-id meeting-002 >/dev/null 2>&1 && rc=0 || rc=$?
if [[ "${rc}" -eq 1 ]]; then
  _ok "<3-fields: replay exits 1"
else
  _fail "<3-fields: expected exit 1, got ${rc}"; fails=$((fails + 1))
fi
ESC="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT outcome FROM decision_log WHERE tenant_slug=:'tenant' AND phase='gating_failed' ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
if [[ "${ESC}" == "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE" ]]; then
  _ok "<3-fields: ESC_FIELD_EXTRACTION_LOW_CONFIDENCE routed"
else
  _fail "<3-fields: expected ESC_FIELD_EXTRACTION_LOW_CONFIDENCE, got '${ESC}'"; fails=$((fails + 1))
fi
GF="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log WHERE tenant_slug=:'tenant' AND phase='action'
  AND payload->>'action_type'='validate_gate_a_fail';
COMMIT;
SQL
)"
if [[ "${GF:-0}" -ge 1 ]]; then
  _ok "<3-fields: validate_gate_a_fail action row written"
else
  _fail "<3-fields: no validate_gate_a_fail row"; fails=$((fails + 1))
fi
NO_WRITE="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log WHERE tenant_slug=:'tenant' AND phase='action'
  AND payload->>'action_type'='bullhorn_scribe_field_write' AND payload->>'payload_preview' LIKE '%meeting-002%';
COMMIT;
SQL
)"
if [[ "${NO_WRITE:-1}" -eq 0 ]]; then
  _ok "<3-fields: NO Bullhorn write for the failed call"
else
  _fail "<3-fields: unexpected write row for meeting-002"; fails=$((fails + 1))
fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all extraction + schema-validation assertions passed"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
