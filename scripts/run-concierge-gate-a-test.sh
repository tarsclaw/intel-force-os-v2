#!/usr/bin/env bash
# Concierge — Gate A (validate.sh) fixture test (spec-004 §7).
#
# Exercises agents/recruitment/concierge/validate.sh against hand-crafted
# drafts covering the PASS path + each fail class (addressee mismatch, tone,
# PII, missing-context) + the position-aware voice thresholds, asserting exit
# codes AND the ESC routing (ESC_ADDRESSEE_MISMATCH / ESC_TONE_RULE_VIOLATION /
# ESC_PII_LEAKAGE_RISK / ESC_AGENT_OUTPUT_SHAPE / ESC_VOICE_DRIFT).
#
# Mirrors the CC run-gate-a-test.sh pattern: the throwaway tenant is
# registered in `tenants` first (decision_log + entities + tone_rule all FK →
# tenants ON DELETE CASCADE, so deleting the tenant row cascades ALL cleanup).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly TENANT="concierge-gate-a-test"
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/concierge"
export CTX_AGENT_NAME="concierge" CTX_TENANT_SLUG="${TENANT}"
readonly VALIDATE="${CTX_AGENT_DIR}/validate.sh"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

command -v psql >/dev/null 2>&1 || { _fail "psql not on PATH"; exit 1; }
[[ -f "${VALIDATE}" ]] || { _fail "validate.sh missing"; exit 1; }
TMPD="$(mktemp -d)"

appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }

# shellcheck disable=SC2329  # invoked indirectly via `trap cleanup EXIT`
cleanup() {
  appq <<'SQL' >/dev/null 2>&1 || true
DELETE FROM tenants WHERE tenant_slug = :'tenant';
SQL
  rm -rf "${TMPD}"
  rm -f /tmp/concierge-gate-a-failed-cgt-*.md /tmp/concierge-pii-failed-cgt-*.md 2>/dev/null
}
trap cleanup EXIT

printf '\033[1;34m── Concierge Gate A (validate.sh) fixture test ──\033[0m\n'

# Register tenant + seed the entities Bullhorn-cache rows + a tenant
# block-severity tone rule (examples_negative drives the G3 phrase match).
appq <<'SQL' >/dev/null
INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Concierge Gate A test')
  ON CONFLICT (tenant_slug) DO NOTHING;
BEGIN; SET LOCAL app.current_tenant = :'tenant';
INSERT INTO entities (tenant_slug, entity_type, entity_id, data) VALUES
  (:'tenant','candidate','CAND-A','{"id":"CAND-A","name":"Alice Walker","email":"alice@example.com","state":"interview-scheduled"}'),
  (:'tenant','candidate','CAND-B','{"id":"CAND-B","name":"Bilal Khan","email":"bilal@example.com","state":"applied"}')
ON CONFLICT (tenant_slug, entity_type, entity_id) DO NOTHING;
INSERT INTO tone_rule (tenant_slug, rule_id, rule_text, severity, applies_to_agents, created_by, examples_negative)
VALUES (:'tenant', 'no-circle-back', 'Never use corporate filler like circle back', 'block', '{concierge}', 'tenant-admin', '{"circle back"}')
ON CONFLICT (tenant_slug, rule_id) DO NOTHING;
COMMIT;
SQL

mkdraft() {  # file candidate_id candidate_name recipient voice position body_extra
  cat > "$1" <<EOF
---
draft_id: cgt-$2-$RANDOM
event_type: interview-booked
candidate_id: $2
candidate_name: $3
placement_id: null
recipient: $4
recipient_role: candidate
subject: "Your interview is booked"
voice_score: $5
voice_reason: $([ "$5" = "unscored" ] && echo no_classifier || echo classifier)
addressee_resolution_check: passed
escalation_position: $6
template_id: shared-interview-booked-candidate-v1
template_source: bundled
draft_generator: template
event_timestamp: 2026-06-10T08:00:00Z
words: 42
---

Hi,

Great news — your interview is confirmed. $7

Best regards
EOF
}

fails=0
run_case() {  # label expected_exit draft_path
  local label="$1" want="$2" path="$3" got
  bash "${VALIDATE}" "${path}" >/dev/null 2>&1 && got=0 || got=$?
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

# PASS: matching recipient; real numeric score above position-1 threshold.
mkdraft "${TMPD}/ok.md" CAND-A "Alice Walker" alice@example.com 0.84 1 ""
run_case "PASS: clean draft (voice 0.84 ≥ 0.75 pos 1)" 0 "${TMPD}/ok.md"

# PASS: unscored warn-and-pass (the honest v1.0 no-classifier state).
mkdraft "${TMPD}/unscored.md" CAND-A "Alice Walker" alice@example.com unscored 1 ""
run_case "PASS: unscored voice warn-and-pass (no classifier in v1.0)" 0 "${TMPD}/unscored.md"

# Position-aware voice thresholds (hard-enforced on REAL numeric scores):
mkdraft "${TMPD}/v78p1.md" CAND-A "Alice Walker" alice@example.com 0.78 1 ""
run_case "PASS G1: voice 0.78 ≥ 0.75 at position 1" 0 "${TMPD}/v78p1.md"

mkdraft "${TMPD}/v77p2.md" CAND-A "Alice Walker" alice@example.com 0.77 2 ""
run_case "FAIL G1: voice 0.77 < 0.78 at position 2" 1 "${TMPD}/v77p2.md"
assert_esc ESC_VOICE_DRIFT

mkdraft "${TMPD}/v78p3.md" CAND-A "Alice Walker" alice@example.com 0.78 3 ""
run_case "FAIL G1: voice 0.78 < 0.82 at position 3 (fixture-02 contract)" 1 "${TMPD}/v78p3.md"
assert_esc ESC_VOICE_DRIFT

mkdraft "${TMPD}/v84p3.md" CAND-A "Alice Walker" alice@example.com 0.84 3 ""
run_case "PASS G1: voice 0.84 ≥ 0.82 at position 3" 0 "${TMPD}/v84p3.md"

# G2 addressee mismatch — recipient is ANOTHER candidate's / stranger's email.
mkdraft "${TMPD}/wrongaddr.md" CAND-A "Alice Walker" bilal@example.com 0.84 1 ""
run_case "FAIL G2: addressee mismatch (another candidate's email)" 1 "${TMPD}/wrongaddr.md"
assert_esc ESC_ADDRESSEE_MISMATCH

# G3 tone — built-in block phrase (agent.md §7).
mkdraft "${TMPD}/tone1.md" CAND-A "Alice Walker" alice@example.com 0.84 1 "We regret to inform you of a delay."
run_case "FAIL G3: built-in block phrase ('We regret to inform you')" 1 "${TMPD}/tone1.md"
assert_esc ESC_TONE_RULE_VIOLATION

# G3 tone — tenant tone_rule examples_negative phrase (DB rule path).
mkdraft "${TMPD}/tone2.md" CAND-A "Alice Walker" alice@example.com 0.84 1 "We will circle back next week."
run_case "FAIL G3: tenant block-severity tone rule (examples_negative)" 1 "${TMPD}/tone2.md"
assert_esc ESC_TONE_RULE_VIOLATION

# G4 PII — email address outside the firm boundary in the body.
mkdraft "${TMPD}/pii.md" CAND-A "Alice Walker" alice@example.com 0.84 1 "Contact random.person@gmail.com for details."
run_case "FAIL G4: external PII in body" 1 "${TMPD}/pii.md"
assert_esc ESC_PII_LEAKAGE_RISK

# G6 missing context — candidate has no entities cache row.
mkdraft "${TMPD}/noctx.md" CAND-MISSING "Ghost Person" ghost@example.com 0.84 1 ""
run_case "FAIL G6: missing Bullhorn context (no entities row)" 1 "${TMPD}/noctx.md"
assert_esc ESC_AGENT_OUTPUT_SHAPE

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all Gate A assertions passed (3 pass paths + position-threshold voice + 4 fail classes + ESC routes)"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
