#!/usr/bin/env bash
# Scribe — SLA bucket + ESC_SCRIBE_SLA_MISS fixture test (spec-002 §7).
#
# Part 1 (pure): bin/sla-class.sh threshold logic at every boundary —
#   ≤300 under_5_min · ≤600 info · ≤1800 Gate-B 10-min miss (NO ESC) ·
#   ≤3600 ESC summary_render · >3600 ESC note_attach (agent.md §4 Step 10 +
#   catalogue §2.10 — the master-brief 10-min product promise and the
#   catalogue 30-min/1h alerting thresholds are different scopes, both kept).
#
# Part 2 (DB-backed integration): cycle.sh replay with seeded meetings whose
# end_time is in the past — asserts the ESC_SCRIBE_SLA_MISS gating_failed
# rows carry the right sla_type, that the Gate-B 10-min miss fires NO ESC,
# and that scribe_run_complete records the sla_class. CC fixture pattern:
# registered throwaway tenant; tenant delete cascades decision_log/entities.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="scribe-sla-fixture"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/scribe"
export CTX_AGENT_NAME="scribe" CTX_TENANT_SLUG="${TENANT}"
export CTX_BULLHORN_CORPORATION_ID="9876" CTX_GRANOLA_WORKSPACE_ID="ws-sla-1"
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

printf '\033[1;34m── Scribe SLA bucket fixture test ──\033[0m\n'

fails=0

# ── Part 1: pure threshold logic (boundary values included) ───────────────
assert_bucket() {  # <elapsed> <want_line>
  local got
  got="$(bash "${CTX_AGENT_DIR}/bin/sla-class.sh" --elapsed "$1")"
  if [[ "${got}" == "$2" ]]; then
    _ok "elapsed $1s → ${got}"
  else
    _fail "elapsed $1s: got '${got}', want '$2'"; fails=$((fails + 1))
  fi
}
assert_bucket 0    "under_5_min||"
assert_bucket 240  "under_5_min||"
assert_bucket 300  "under_5_min||"
assert_bucket 301  "info_5_10_min||"
assert_bucket 600  "info_5_10_min||"
assert_bucket 601  "gate_b_10min_miss||"
assert_bucket 1800 "gate_b_10min_miss||"
assert_bucket 1801 "summary_render_miss|ESC_SCRIBE_SLA_MISS|summary_render"
assert_bucket 3600 "summary_render_miss|ESC_SCRIBE_SLA_MISS|summary_render"
assert_bucket 3601 "note_attach_miss|ESC_SCRIBE_SLA_MISS|note_attach"
assert_bucket 7200 "note_attach_miss|ESC_SCRIBE_SLA_MISS|note_attach"

# ── Part 2: DB-backed integration through cycle.sh ─────────────────────────
appq <<'SQL' >/dev/null || { _fail "tenant/entity seed failed"; exit 1; }
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scribe SLA fixture')
  ON CONFLICT (tenant_slug) DO NOTHING;
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO entities (tenant_slug, entity_type, entity_id, data) VALUES
  (:'tenant','candidate','1001','{"email":"jane.doe@example.test"}')
ON CONFLICT (tenant_slug, entity_type, entity_id) DO UPDATE SET data = EXCLUDED.data;
COMMIT;
SQL

cat > "${TMPD}/transcript.txt" <<'EOF'
[00:12] jane.doe@example.test: I'm based in Manchester.
[00:25] jane.doe@example.test: Currently a Senior Backend Engineer at MyCo Ltd. 8 weeks notice.
[00:45] jane.doe@example.test: Salary expectation around £85k to £95k.
EOF
export IFOS_SCRIBE_TRANSCRIPT_FILE="${TMPD}/transcript.txt"

_ago_iso() {  # <minutes-ago>
  date -u -v-"$1"M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "$1 minutes ago" +%Y-%m-%dT%H:%M:%SZ
}

run_sla_case() {  # <call_id> <minutes_ago> <want_sla_class> <want_esc_sla_type|none>
  local cid="$1" ago="$2" want_class="$3" want_esc="$4" end got_class got_esc
  end="$(_ago_iso "${ago}")"
  jq -nc --arg id "${cid}" --arg end "${end}" '[{id:$id,title:"SLA case",end_time:$end,duration_minutes:30,
    attendees:["founder@acme.test","jane.doe@example.test"],has_transcript:true,notes_markdown:""}]' \
    > "${TMPD}/meetings-${cid}.json"
  IFOS_SCRIBE_MEETINGS_FILE="${TMPD}/meetings-${cid}.json" \
    bash "${CTX_AGENT_DIR}/cycle.sh" --mode replay --call-id "${cid}" >/dev/null 2>&1 || true

  got_class="$(appq <<SQL 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT substring(payload->>'payload_preview' from 'sla_class:([a-z0-9_]+)')
FROM decision_log WHERE tenant_slug = :'tenant' AND phase='action'
  AND payload->>'action_type'='scribe_run_complete'
  AND payload->>'payload_preview' LIKE '%${cid}%' ESCAPE '\\'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
  # scribe_run_complete targets call:<id>; preview carries the class — fall back to latest row.
  if [[ -z "${got_class}" ]]; then
    got_class="$(appq <<'SQL' 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT substring(payload->>'payload_preview' from 'sla_class:([a-z0-9_]+)')
FROM decision_log WHERE tenant_slug = :'tenant' AND phase='action'
  AND payload->>'action_type'='scribe_run_complete'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
  fi
  if [[ "${got_class}" == "${want_class}" ]]; then
    _ok "cycle.sh ${cid} (${ago}m ago): sla_class ${got_class}"
  else
    _fail "cycle.sh ${cid}: sla_class '${got_class}', want '${want_class}'"; fails=$((fails + 1))
  fi

  got_esc="$(appq <<SQL 2>/dev/null | tail -1
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(payload->>'sla_type','') FROM decision_log
WHERE tenant_slug = :'tenant' AND phase='gating_failed' AND outcome='ESC_SCRIBE_SLA_MISS'
  AND payload->>'call' = '${cid}'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
  if [[ "${want_esc}" == "none" ]]; then
    if [[ -z "${got_esc}" ]]; then
      _ok "  → no ESC_SCRIBE_SLA_MISS (correct for ${want_class})"
    else
      _fail "  → unexpected ESC_SCRIBE_SLA_MISS (${got_esc})"; fails=$((fails + 1))
    fi
  else
    if [[ "${got_esc}" == "${want_esc}" ]]; then
      _ok "  → ESC_SCRIBE_SLA_MISS sla_type=${got_esc}"
    else
      _fail "  → expected ESC_SCRIBE_SLA_MISS sla_type=${want_esc}, got '${got_esc}'"; fails=$((fails + 1))
    fi
  fi
}

run_sla_case "sla-fast"   4   "under_5_min"          none
run_sla_case "sla-10min"  12  "gate_b_10min_miss"    none
run_sla_case "sla-render" 35  "summary_render_miss"  summary_render
run_sla_case "sla-attach" 120 "note_attach_miss"     note_attach

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all SLA assertions passed (11 boundary buckets + 4 integration cases)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
