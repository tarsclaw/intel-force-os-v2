#!/usr/bin/env bash
# Sourcing Scout — cross-source dedupe + provenance fixture test (spec-003 §7).
#
# Two layers:
#   A. Matcher-unit asserts against bin/fuzzy-match.sh (the carried Janitor
#      matcher: name·0.3+email·0.4+phone·0.2+linkedin·0.1; ≥0.85): merge on
#      name+email, merge on name+phone (UK +44/0 prefix equivalence), NO merge
#      on name-only (strong-identifier requirement), provenance annotation.
#   B. End-to-end cycle.sh run over the fixture-01 candidate pool (8 Bullhorn
#      + 6 Reed + 4 CV-Library via IFOS_SCOUT_FIXTURE_* deterministic files):
#      assert aggregate_dedupe pre:18→post:15, dnc_filter dropped:2 kept:13,
#      per-candidate candidate_proposed rows (13 included + 2 DNC drops),
#      Gate A PASS, vault report written.
#
# cycle.sh + validate.sh open their OWN DB connections, so fixture rows are
# COMMITTED then cleaned up. The test tenant is registered in `tenants` first
# because decision_log has a FK → tenants (ON DELETE CASCADE) — deleting the
# tenant row cascades the decision_log cleanup. (Mirrors run-gate-a-test.sh.)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="scout-dedupe-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
TMPD="$(mktemp -d)"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${TMPD}/vault"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/sourcing-scout"
export CTX_AGENT_NAME="sourcing-scout" CTX_TENANT_SLUG="${TENANT}"
export IFOS_SECRETS_FILE=/dev/null   # no creds in test runs — fixture paths only
readonly MATCHER="${CTX_AGENT_DIR}/bin/fuzzy-match.sh"
readonly CYCLE="${CTX_AGENT_DIR}/cycle.sh"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
command -v jq >/dev/null 2>&1 || { _fail "jq not on PATH"; exit 1; }
[[ -f "${MATCHER}" && -f "${CYCLE}" ]] || { _fail "agent bundle files missing"; exit 1; }

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

printf '\033[1;34m── Sourcing Scout dedupe + provenance fixture test ──\033[0m\n'

fails=0
assert_eq() {  # label got want
  if [[ "$2" == "$3" ]]; then _ok "$1 ($2)"; else _fail "$1: got '$2', want '$3'"; fails=$((fails + 1)); fi
}

# ── Layer A: matcher-unit asserts ─────────────────────────────────────────
cat > "${TMPD}/unit.json" <<'EOF'
[
 {"ref":"bullhorn:1","source":"bullhorn","name":"Alice Anderson","email":"alice.a@x.test","phone":"+447700900001","linkedin_url":null},
 {"ref":"reed:1","source":"reed","name":"Alice Anderson","email":"alice.a@x.test","phone":null,"linkedin_url":"https://linkedin.com/in/alice"},
 {"ref":"bullhorn:2","source":"bullhorn","name":"Carol Chen","email":"carol@x.test","phone":"+447700900003","linkedin_url":null},
 {"ref":"cvlibrary:2","source":"cvlibrary","name":"Carol Chen","email":null,"phone":"0770 0900003","linkedin_url":null},
 {"ref":"reed:9","source":"reed","name":"John Smith","email":"john.s@a.test","phone":null,"linkedin_url":null},
 {"ref":"cvlibrary:9","source":"cvlibrary","name":"John Smith","email":"john.smith@b.test","phone":"+447700900050","linkedin_url":null}
]
EOF
UNIT_OUT="$(bash "${MATCHER}" < "${TMPD}/unit.json")"
assert_eq "A1: pre_dedupe"  "$(printf '%s' "${UNIT_OUT}" | jq -r '.pre_dedupe')"  "6"
assert_eq "A2: post_dedupe (Alice name+email merge; Carol name+phone merge w/ UK prefix; Johns stay split)" \
  "$(printf '%s' "${UNIT_OUT}" | jq -r '.post_dedupe')" "4"
assert_eq "A3: Alice provenance = bullhorn+reed" \
  "$(printf '%s' "${UNIT_OUT}" | jq -r '.candidates[] | select(.name == "Alice Anderson") | .sources | join(",")')" \
  "bullhorn,reed"
assert_eq "A4: merged Alice carries phone (bullhorn) AND linkedin (reed)" \
  "$(printf '%s' "${UNIT_OUT}" | jq -r '.candidates[] | select(.name == "Alice Anderson") | [(.phone != null and .phone != ""), (.linkedin_url != null and .linkedin_url != "")] | join(",")')" \
  "true,true"
assert_eq "A5: name-only John Smiths NOT merged (strong-identifier requirement; <0.85)" \
  "$(printf '%s' "${UNIT_OUT}" | jq -r '[.candidates[] | select(.name == "John Smith")] | length')" "2"

# ── Layer B: end-to-end over the fixture-01 pool ──────────────────────────
cat > "${TMPD}/bullhorn.json" <<'EOF'
[
 {"ref":"bullhorn:1001","source":"bullhorn","name":"Alice Anderson","email":"alice.a@example.test","phone":"+447700900001","linkedin_url":null,"headline":"Senior React Engineer","location":"London"},
 {"ref":"bullhorn:1002","source":"bullhorn","name":"Bob Brown","email":"bob.b@example.test","phone":"+447700900002","linkedin_url":null,"headline":"React Developer","location":"London"},
 {"ref":"bullhorn:1003","source":"bullhorn","name":"Carol Chen","email":"carol.c@example.test","phone":"+447700900003","linkedin_url":null,"headline":"Frontend Lead","location":"London"},
 {"ref":"bullhorn:1004","source":"bullhorn","name":"Dave Davis","email":"dave.d@example.test","phone":"+447700900004","linkedin_url":null,"headline":null,"location":"Reading"},
 {"ref":"bullhorn:1005","source":"bullhorn","name":"Eve Edwards","email":"eve.e@example.test","phone":"+447700900005","linkedin_url":null,"headline":"Full-stack Engineer","location":"London"},
 {"ref":"bullhorn:1006","source":"bullhorn","name":"Frank Fisher","email":"frank.f@example.test","phone":"+447700900006","linkedin_url":null,"headline":"React Native Engineer","location":"Brighton"},
 {"ref":"bullhorn:1007","source":"bullhorn","name":"Grace Green","email":"blocked.candidate@example.test","phone":"+447700900007","linkedin_url":null,"headline":"UI Engineer","location":"London"},
 {"ref":"bullhorn:1008","source":"bullhorn","name":"Henry Hall","email":"henry.h@example.test","phone":"+447700900099","linkedin_url":null,"headline":"Web Engineer","location":"London"}
]
EOF
cat > "${TMPD}/reed.json" <<'EOF'
[
 {"ref":"reed:reed-001","source":"reed","name":"Iris Ito","email":"iris.i@example.test","phone":null,"linkedin_url":"https://linkedin.com/in/iris-ito","headline":"Senior Frontend Engineer","location":"London"},
 {"ref":"reed:reed-002","source":"reed","name":"Jack Jones","email":"jack.j@example.test","phone":null,"linkedin_url":"https://linkedin.com/in/jack-jones","headline":"React Engineer","location":"Cambridge"},
 {"ref":"reed:reed-003","source":"reed","name":"Alice Anderson","email":"alice.a@example.test","phone":null,"linkedin_url":"https://linkedin.com/in/alice-anderson","headline":"Senior React Engineer","location":"London"},
 {"ref":"reed:reed-004","source":"reed","name":"Karen Khan","email":"karen.k@example.test","phone":null,"linkedin_url":"https://linkedin.com/in/karen-khan","headline":"Frontend Developer","location":"London"},
 {"ref":"reed:reed-005","source":"reed","name":"Liam Lee","email":"liam.l@example.test","phone":null,"linkedin_url":"https://linkedin.com/in/liam-lee","headline":"JavaScript Engineer","location":"London"},
 {"ref":"reed:reed-006","source":"reed","name":"Bob Brown","email":"bob.b@example.test","phone":null,"linkedin_url":"https://linkedin.com/in/bob-brown","headline":"React Developer","location":"London"}
]
EOF
cat > "${TMPD}/cvlibrary.json" <<'EOF'
[
 {"ref":"cvlibrary:cv-001","source":"cvlibrary","name":"Mia Martinez","email":"mia.m@example.test","phone":"+447700900020","linkedin_url":null,"headline":"Senior React Engineer","location":"London"},
 {"ref":"cvlibrary:cv-002","source":"cvlibrary","name":"Noah Ng","email":"noah.n@example.test","phone":"+447700900021","linkedin_url":null,"headline":"Frontend Engineer","location":"London"},
 {"ref":"cvlibrary:cv-003","source":"cvlibrary","name":"Carol Chen","email":"carol.c@example.test","phone":"+447700900003","linkedin_url":null,"headline":"Frontend Lead","location":"London"},
 {"ref":"cvlibrary:cv-004","source":"cvlibrary","name":"Olivia O'Brien","email":"olivia.o@example.test","phone":"+447700900022","linkedin_url":null,"headline":"React Engineer","location":"London"}
]
EOF

# Register the tenant (FK target for decision_log).
appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scout dedupe fixture test')
  ON CONFLICT (tenant_slug) DO NOTHING;
SQL

export IFOS_SCOUT_FIXTURE_BULLHORN="${TMPD}/bullhorn.json"
export IFOS_SCOUT_FIXTURE_REED="${TMPD}/reed.json"
export IFOS_SCOUT_FIXTURE_CVLIBRARY="${TMPD}/cvlibrary.json"
export CTX_DNC_BLOCKED_RECIPIENTS='["blocked.candidate@example.test","+447700900099"]'
export CTX_FIRM_DOMAIN_WHITELIST="${TENANT}.test"
export CTX_VOICE_CORPUS_STATE="absent"

bash "${CYCLE}" --mode cli --brief-id 12345 \
  --description "Senior React Engineer, London, £100k-£120k, hybrid" \
  > "${TMPD}/cycle.log" 2>&1
assert_eq "B1: cycle.sh exit code (Gate A PASS)" "$?" "0"

marker() {  # output_type → reason of latest row
  appq <<SQL 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(reason, '') FROM decision_log
WHERE tenant_slug = :'tenant' AND payload->>'output_type' = '$1'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
}
assert_eq "B2: aggregate_dedupe marker pre/post" \
  "$(marker aggregate_dedupe | grep -oE 'pre:[0-9]+; post:[0-9]+')" "pre:18; post:15"
assert_eq "B3: dnc_filter marker dropped/kept" \
  "$(marker dnc_filter | grep -oE 'dropped:[0-9]+; kept:[0-9]+')" "dropped:2; kept:13"
assert_eq "B4: candidate_proposed rows (13 included + 2 DNC drops)" \
  "$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND payload->>'output_type' = 'candidate_proposed';
COMMIT;
SQL
)" "15"
assert_eq "B5: DNC drops carry included:false + drop_reason" \
  "$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log
WHERE tenant_slug = :'tenant' AND payload->>'output_type' = 'candidate_proposed'
  AND reason LIKE '%included:false; drop_reason:dnc_filter%';
COMMIT;
SQL
)" "2"
assert_eq "B6: cross-source provenance row exists (Alice via bullhorn,reed)" \
  "$(appq <<'SQL' 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) > 0 FROM decision_log
WHERE tenant_slug = :'tenant' AND payload->>'output_type' = 'candidate_proposed'
  AND reason LIKE 'source:bullhorn,reed%';
COMMIT;
SQL
)" "t"
assert_eq "B7: scout_report marker (Gate A PASS)" \
  "$(marker scout_report | grep -oE 'gate_a:PASS')" "gate_a:PASS"
REPORT_FILE="$(find "${IFOS_VAULT_ROOT}/${TENANT}/sourcing-scout-reports" -name '*.md' 2>/dev/null | head -1)"
if [[ -n "${REPORT_FILE}" ]]; then
  _ok "B8: vault report written (${REPORT_FILE##*/})"
  assert_eq "B9: report carries 13 ranked candidates" \
    "$(grep -cE '^### [0-9]+\.' "${REPORT_FILE}")" "13"
  assert_eq "B10: report source-breakdown shows LinkedIn deferred" \
    "$(grep -c 'deferred to v1.1+; vendor pending' "${REPORT_FILE}")" "2"
else
  _fail "B8: vault report missing"; fails=$((fails + 1))
fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all dedupe + provenance assertions passed (5 matcher-unit + 10 end-to-end)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
