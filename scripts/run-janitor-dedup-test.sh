#!/usr/bin/env bash
# Janitor — dedup fixture test (spec-001 §7).
#
# Part A: matcher unit asserts against bin/dedup-pairs.sh (pure jq; zero DB):
#   band→action table per spec-001 §4 (auto / review-by-confidence /
#   review-by-recency / unknown-activity hold / silent drop), the required
#   strong-identifier rule (name-only pairs never pair), and UK +44/0 phone
#   equivalence.
#
# Part B: E2E over seeded `entities` rows — register a throwaway tenant
# (decision_log FK; DELETE cascades entities + tenant_adapters + decision_log),
# seed the fixture-01/02 candidate pool + a contractor pair + a client missing
# industry/CRN + recent_edit rows, run cycle.sh --mode full-cleanup with the
# documented fixture hooks (no network, no LLM, no live CH), then assert the
# decision_log marker rows + yellow action rows + ESC_DUPLICATE_DETECTED holds.
#
# cycle.sh opens its OWN DB connections, so fixtures are COMMITTED then cleaned
# up (CC test idiom). recent_edit has no tenants FK → owner-side cleanup.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="janitor-dedup-fixture-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
TMPD="$(mktemp -d)"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${TMPD}/vault"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/janitor"
export CTX_AGENT_NAME="janitor" CTX_TENANT_SLUG="${TENANT}"
export IFOS_JANITOR_NO_LLM=1 IFOS_JANITOR_RETRY_DELAY_S=0
export IFOS_FORCE_BULLHORN_CORPORATION_ID="9876"
export IFOS_FORCE_JANITOR_DEDUP_THRESHOLD="0.85"
export IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID="-100200300"
export IFOS_FORCE_FIRM_DOMAIN_WHITELIST="janitor-firm.test"
readonly MATCHER="${CTX_AGENT_DIR}/bin/dedup-pairs.sh"
readonly OWNER_DB="${IFOS_OWNER_DB:-ifos_v2_dev}"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
command -v jq >/dev/null 2>&1 || { _fail "jq not on PATH"; exit 1; }
[[ -f "${MATCHER}" ]] || { _fail "dedup-pairs.sh missing"; exit 1; }

appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }

# shellcheck disable=SC2329  # invoked indirectly via `trap cleanup EXIT`
cleanup() {
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  psql -U "${USER}" -d "${OWNER_DB}" -q >/dev/null 2>&1 <<SQL || true
BEGIN; SET LOCAL app.current_tenant = '${TENANT}';
DELETE FROM recent_edit WHERE tenant_slug = '${TENANT}';
COMMIT;
SQL
  rm -rf "${TMPD}"
}
trap cleanup EXIT

fails=0
assert_eq() {  # label got want
  if [[ "$2" == "$3" ]]; then _ok "$1 ($2)"; else _fail "$1: got '$2', want '$3'"; fails=$((fails + 1)); fi
}

printf '\033[1;34m── Janitor dedup fixture test ──\033[0m\n'
printf '\n\033[1mPart A — matcher unit asserts (bin/dedup-pairs.sh)\033[0m\n'

# A1: full 4-dim match, both stale → auto
OUT="$(echo '[
 {"entity_id":"1001","name":"Jane Doe","email":"jane.doe@x.test","phone":"+447700900001","linkedin_url":"https://linkedin.com/in/jane-doe","last_activity_days":180},
 {"entity_id":"1002","name":"Jane Doe","email":"jane.doe@x.test","phone":"+447700900001","linkedin_url":"https://linkedin.com/in/jane-doe","last_activity_days":200}
]' | bash "${MATCHER}")"
assert_eq "A1 auto band (4-dim match, both stale)" "$(jq -r '.auto' <<<"${OUT}")" "1"
assert_eq "A1 confidence 1.0" "$(jq -r '.pairs[0].confidence' <<<"${OUT}")" "1"

# A2: UK +44/0 phone equivalence matches the phone dimension
OUT="$(echo '[
 {"entity_id":"2001","name":"John Smith","email":"","phone":"+447700900002","last_activity_days":300},
 {"entity_id":"2002","name":"John Smith","email":"","phone":"07700900002","last_activity_days":300}
]' | bash "${MATCHER}")"
assert_eq "A2 UK +44/0 phone equivalence → auto" "$(jq -r '.auto' <<<"${OUT}")" "1"
assert_eq "A2 phone dim matched" "$(jq -r '.pairs[0].dims | index("phone") != null' <<<"${OUT}")" "true"

# A3: name-only collision → NO pair (required strong identifier)
OUT="$(echo '[
 {"entity_id":"3001","name":"Sam Only","email":"sam.a@x.test","last_activity_days":300},
 {"entity_id":"3002","name":"Sam Only","email":"sam.b@y.test","last_activity_days":300}
]' | bash "${MATCHER}")"
assert_eq "A3 name-only never pairs (strong-identifier rule)" \
  "$(jq -r '.auto + .review + .dropped' <<<"${OUT}")" "0"

# A4: email matches but name+phone differ → 0.4/0.9 = 0.44 → silent drop
OUT="$(echo '[
 {"entity_id":"4001","name":"Mid Band","email":"shared@x.test","phone":"+447700900009","last_activity_days":300},
 {"entity_id":"4002","name":"Other Person","email":"shared@x.test","phone":"+440000000000","last_activity_days":300}
]' | bash "${MATCHER}")"
assert_eq "A4 sub-0.70 silent drop" "$(jq -r '.dropped' <<<"${OUT}")" "1"
assert_eq "A4 dropped pairs not listed" "$(jq -r '.pairs | length' <<<"${OUT}")" "0"

# A5: 0.70-0.85 review band by confidence (name+email match, phone differs → 0.7/0.9 = 0.78)
OUT="$(echo '[
 {"entity_id":"5001","name":"Pat Band","email":"pat@x.test","phone":"+447700900011","last_activity_days":300},
 {"entity_id":"5002","name":"Pat Band","email":"pat@x.test","phone":"+447700900099","last_activity_days":300}
]' | bash "${MATCHER}")"
assert_eq "A5 review band by confidence (0.78)" "$(jq -r '.review' <<<"${OUT}")" "1"
assert_eq "A5 reason confidence_band" "$(jq -r '.pairs[0].reason' <<<"${OUT}")" "confidence_band_0.70_to_threshold"

# A6: ≥0.85 with recent activity on one side → review by recency (pair MIN in reason)
OUT="$(echo '[
 {"entity_id":"6001","name":"Recent One","email":"r@x.test","last_activity_days":150},
 {"entity_id":"6002","name":"Recent One","email":"r@x.test","last_activity_days":20}
]' | bash "${MATCHER}")"
assert_eq "A6 review by recency" "$(jq -r '.review' <<<"${OUT}")" "1"
assert_eq "A6 reason carries pair MIN days" "$(jq -r '.pairs[0].reason' <<<"${OUT}")" "recent_activity_days:20"

# A7: unknown activity → conservative review hold (never auto)
OUT="$(echo '[
 {"entity_id":"7001","name":"Unknown Act","email":"u@x.test","last_activity_days":null},
 {"entity_id":"7002","name":"Unknown Act","email":"u@x.test","last_activity_days":400}
]' | bash "${MATCHER}")"
assert_eq "A7 unknown activity holds for review" "$(jq -r '.review' <<<"${OUT}")" "1"
assert_eq "A7 reason conservative hold" "$(jq -r '.pairs[0].reason' <<<"${OUT}")" "activity_unknown_conservative_hold"

printf '\n\033[1mPart B — E2E band→action over seeded entities (cycle.sh full-cleanup)\033[0m\n'

if ! psql "${IFOS_DB_URL}" -tAc 'SELECT 1' >/dev/null 2>&1; then
  _fail "no reachable IFOS_DB_URL — E2E section cannot run"
  exit 1
fi

# Register tenant + seed config / entities / recent_edit.
appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Janitor dedup fixture test')
  ON CONFLICT (tenant_slug) DO NOTHING;
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled) VALUES
  (:'tenant', 'janitor', '{"janitor_dedup_threshold": 0.85, "operator_telegram_chat_id": "-100200300", "bullhorn_corporation_id": "9876"}', true)
ON CONFLICT (tenant_slug, adapter_name) DO UPDATE SET config = EXCLUDED.config;
INSERT INTO entities (tenant_slug, entity_type, entity_id, data) VALUES
  -- fixture-01 Jane pair: 4-dim match, both stale → AUTO
  (:'tenant','candidate','1001','{"name":"Jane Doe","email":"jane.doe@example.test","phone":"+447700900001","linkedin_url":"https://linkedin.com/in/jane-doe","last_activity_days":"180"}'),
  (:'tenant','candidate','1002','{"name":"Jane Doe","email":"jane.doe@example.test","phone":"+447700900001","linkedin_url":"https://linkedin.com/in/jane-doe","last_activity_days":"200"}'),
  -- fixture-02 John pair: high confidence BUT 20d activity → REVIEW (ESC_DUPLICATE_DETECTED)
  (:'tenant','candidate','2001','{"name":"John Smith","email":"john.smith@example.test","phone":"+447700900002","last_activity_days":"150"}'),
  (:'tenant','candidate','2002','{"name":"John Smith","email":"john.smith@example.test","phone":"07700900002","last_activity_days":"20"}'),
  -- contractor pair (separate entity_type; same matcher) → AUTO
  (:'tenant','contractor','7001','{"name":"Carl Contractor","email":"carl@example.test","last_activity_days":"300"}'),
  (:'tenant','contractor','7002','{"name":"Carl Contractor","email":"carl@example.test","last_activity_days":"120"}'),
  -- client missing industry + CRN → Step 5 queue → Step 6 CH fixture backfill
  (:'tenant','client','5001','{"name":"Acme Tech Ltd","industry":null,"size_employees":"50","companies_house_number":null}')
ON CONFLICT (tenant_slug, entity_type, entity_id) DO UPDATE SET data = EXCLUDED.data;
COMMIT;
SQL
psql -U "${USER}" -d "${OWNER_DB}" -q >/dev/null <<SQL
BEGIN; SET LOCAL app.current_tenant = '${TENANT}';
INSERT INTO recent_edit (tenant_slug, agent_name, action_type, target_entity_type, target_entity_id, original_text, edited_text, resolution, resolved_at) VALUES
  ('${TENANT}','scribe','note_rewrite','candidate','1001','o1','e1','approved_after_edit', now() - interval '3 days'),
  ('${TENANT}','concierge','status_change','contact','9001','o2','e2','approved_after_edit', now() - interval '10 days');
COMMIT;
SQL

# CH fixture map (Step 6 — zero network).
cat > "${TMPD}/ch-fixture.json" <<'EOF'
[{"query": "Acme Tech Ltd", "crn": "12345678", "industry": "62020", "source_confidence": 0.9}]
EOF
export IFOS_JANITOR_FIXTURE_CH="${TMPD}/ch-fixture.json"

# context.sh smoke (own process; CTX exports for cycle.sh come from the
# IFOS_FORCE_* env above — the bus owns env propagation in production).
if bash "${CTX_AGENT_DIR}/context.sh" >/dev/null 2>&1; then
  _ok "context.sh exits 0 (hydration + session_start row)"
else
  _fail "context.sh failed"; fails=$((fails + 1))
fi
export CTX_JANITOR_DEDUP_THRESHOLD="0.85" CTX_BULLHORN_CORPORATION_ID="9876"
export CTX_OPERATOR_TELEGRAM_CHAT_ID="-100200300" CTX_VOICE_CORPUS_STATE="absent"
export CTX_FIRM_DOMAIN_WHITELIST="janitor-firm.test"

if bash "${CTX_AGENT_DIR}/cycle.sh" --mode full-cleanup --tenant "${TENANT}" >/dev/null 2>&1; then
  _ok "cycle.sh full-cleanup exits 0"
else
  _fail "cycle.sh full-cleanup failed"; fails=$((fails + 1))
fi

dlq() {  # sql fragment after WHERE agent_name='janitor' AND
  appq <<SQL 2>/dev/null
BEGIN; SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM decision_log WHERE tenant_slug = :'tenant' AND agent_name = 'janitor' AND $1;
COMMIT;
SQL
}

assert_eq "B1 janitor_scan marker (spec-001 §3 contract name)" \
  "$(dlq "phase='output' AND payload->>'output_type'='janitor_scan'")" "1"
assert_eq "B2 dedup_candidate_pass auto:1 review:1" \
  "$(dlq "phase='output' AND payload->>'output_type'='dedup_candidate_pass' AND reason='auto_merges:1; review_band:1; dropped:0'")" "1"
assert_eq "B3 dedup_contractor_pass auto:1" \
  "$(dlq "phase='output' AND payload->>'output_type'='dedup_contractor_pass' AND reason='auto_merges:1; review_band:0; dropped:0'")" "1"
assert_eq "B4 ESC_DUPLICATE_DETECTED hold (John pair; amended catalogue payload shape)" \
  "$(dlq "phase='gating_failed' AND outcome='ESC_DUPLICATE_DETECTED' AND payload->>'entity_a_id'='2001' AND payload->>'entity_b_id'='2002' AND payload->>'entity_type'='candidate' AND payload->>'match_basis'='name+email+phone' AND payload->>'hold_reason'='recency_hold_90d' AND payload->>'hold_detail' LIKE 'recent_activity_days:20%'")" "1"
assert_eq "B5 bullhorn_candidate_dedupe yellow action rows (Jane + Carl)" \
  "$(dlq "phase='action' AND payload->>'action_type'='bullhorn_candidate_dedupe' AND payload->>'tier'='yellow'")" "2"
assert_eq "B6 bullhorn_field_backfill action row (CH fixture)" \
  "$(dlq "phase='action' AND payload->>'action_type'='bullhorn_field_backfill'")" "1"
assert_eq "B7 bullhorn_note_attach rows (2 recent_edit groups)" \
  "$(dlq "phase='action' AND payload->>'action_type'='bullhorn_note_attach'")" "2"
assert_eq "B8 writes honestly deferred (no Bullhorn creds; never faked)" \
  "$(dlq "phase='action' AND payload->>'payload_preview' LIKE '%write_state:deferred%'")" "5"
assert_eq "B9 janitor_tacit_note_harvest marker (contract name)" \
  "$(dlq "phase='output' AND payload->>'output_type'='janitor_tacit_note_harvest' AND reason LIKE '%voice_score:unscored%'")" "1"
assert_eq "B10 janitor_run_complete green action row" \
  "$(dlq "phase='action' AND payload->>'action_type'='janitor_run_complete' AND payload->>'tier'='green'")" "1"

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all dedup assertions passed (7 matcher units + 10 E2E)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
