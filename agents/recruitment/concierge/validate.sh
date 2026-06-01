#!/usr/bin/env bash
# shellcheck disable=SC2329
# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W10-13)
#  blocks invoke them when the per-check impl lands. Keeping them defined
#  so the skeleton matches the final shape + the build-slice author can fill
#  the TODOs without re-declaring helpers.)
#
# Concierge agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
#
# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice completes the impl).
# Reading order: agent.md §5 (Gate A) + §6 (16 ESC codes) + §1 Gate A thresholds
# in the output contract first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is
# the hard-fail gate that runs BETWEEN draft generation (cycle.sh Step 7) and
# the autosend-bridge propose call (Step 11). If any check fails, validate.sh
# exits non-zero + emits an ESC_* escalation row to decision_log; the draft
# does NOT route to the bridge; cycle.sh aborts the draft pipeline.
#
# Invocation contract:
#   bash validate.sh <draft_path>
#
# Inputs:
#   - $1: path to the vault concierge-draft file (cycle.sh Step 7 wrote it)
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
#          CTX_VOICE_CORPUS_ID, CTX_TONE_RULES (json string)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to Step 8 action row + Step 11
#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts the draft
#   2  validate.sh invocation error (bad args, missing draft, env unset)
#
# Checks (per agent.md §5 Gate A):
#   G1 — voice classifier score ≥ position-specific threshold
#        (position 1: ≥0.75 ; position 2: ≥0.78 ; position 3: ≥0.82)
#   G2 — addressee resolution: recipient matches candidate_id whose lifecycle
#        is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed
#        under another's name")
#   G3 — no block-severity tone-rule violation
#   G4 — no PII outside firm boundary (other candidates, competitors, comp specifics)
#   G5 — anti-duplicate: no prior concierge_email_draft for same (candidate_id,
#        event_type) in last 24h that already completed send

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  printf 'concierge/validate.sh: usage: validate.sh <draft_path>\n' >&2
  exit 2
fi

readonly DRAFT="$1"

if [[ ! -f "${DRAFT}" ]]; then
  printf 'validate.sh: draft not found at %s\n' "${DRAFT}" >&2
  exit 2
fi

if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi

# Resolve _shared/ helpers (4-candidate fallback; matches sibling pattern
# post d7d52c5 smoke-hotfix).
_SHARED_DIR=""
for _candidate in \
  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
  "${IFOS_REPO_ROOT:-}/agents/_shared" \
  "${CTX_AGENT_DIR}/../../_shared" \
  "${CTX_AGENT_DIR}/../_shared" ; do
  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    _SHARED_DIR="${_candidate}"
    break
  fi
done
if [[ -z "${_SHARED_DIR}" ]]; then
  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
  exit 2
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# Track failures + warnings across all checks (collect all before exit for
# richer audit; same pattern as cash-conductor/validate.sh).
declare -a FAILURES=()
declare -a WARNINGS=()

_fail() {
  FAILURES+=("$1")
  printf '  ✗ %s\n' "$1" >&2
}
_warn() {
  WARNINGS+=("$1")
  printf '  ! %s\n' "$1" >&2
}
_ok() {
  printf '  ✓ %s\n' "$1"
}

# ────────────────────────────────────────────────────────────────────────
# G1 — voice classifier score ≥ position-specific threshold
# Position 1 ≥0.75 ; Position 2 ≥0.78 ; Position 3 ≥0.82
# Reference: agent.md §5 Gate A + §4 Step 8 + ULTRAPLAN A6 line 566 (amended)
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): parse draft YAML frontmatter for voice_score + escalation_position;
# compare against position-specific threshold; on fail emit ESC_VOICE_DRIFT
# (warn per catalogue lines 120-125; routes operator_chat_id for ALL positions —
# position-specific paging would need a catalogue amendment) AND emit
# hh_decision_action "validate_gate_a_fail" so cycle.sh aborts.
_ok "G1: voice classifier position-threshold — SKELETON (W10-13 wires)"

# ────────────────────────────────────────────────────────────────────────
# G2 — addressee resolution: recipient matches candidate_id whose lifecycle
# is changing. ULTRAPLAN A6 line 566 verbatim: "no candidates emailed under
# another's name". Reference: agent.md §4 Step 4 + §5 Gate A.
# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on fail.
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): parse draft YAML for recipient + candidate_id; cross-check
# against bullhorn.get_candidate(candidate_id).email; on mismatch:
# hh_decision_action "validate_gate_a_fail" "candidate:<id>" "<hash>" \
#   "ESC_ADDRESSEE_MISMATCH; recipient:<email>; expected:<candidate-email>"
_ok "G2: addressee resolution — SKELETON (W10-13 wires Bullhorn cross-check)"

# ────────────────────────────────────────────────────────────────────────
# G3 — no block-severity tone-rule violation
# Reference: agent.md §4 Step 8 + §6 ESC_TONE_RULE_VIOLATION (blocking;
# operator + ifos_oncall).
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): @ifos/tone-rules apply_rules(draft_body, tenant_tone_rules);
# on block-severity hit: hh_decision_action "validate_gate_a_fail" ... \
#   "ESC_TONE_RULE_VIOLATION; rule_id:<id>; matched_text:<excerpt>"
_ok "G3: block-severity tone-rules — SKELETON (W10-13 wires rule engine)"

# ────────────────────────────────────────────────────────────────────────
# G4 — no PII outside firm boundary
# Reference: agent.md §4 Step 10 + §6 ESC_PII_LEAKAGE_RISK (blocking).
# Three classes: other-candidate PII, competitor-client PII, compensation
# specifics outside candidate's record.
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): regex sweep against firm-domain whitelist + competitor list
# + candidate-record allowlist; on hit emit ESC_PII_LEAKAGE_RISK +
# validate_gate_a_fail with payload.class IN ('other_candidate'|'competitor'|'comp_specifics')
_ok "G4: PII boundary check — SKELETON (W10-13 wires firm + competitor lists)"

# ────────────────────────────────────────────────────────────────────────
# G5 — anti-duplicate: no prior concierge_email_draft for same
# (candidate_id, event_type) in last 24h with send-completed status.
# Reference: agent.md §4 Step 2. Defence-in-depth: Step 2 already checked,
# but a webhook re-fire between Step 2 and validate.sh could insert a new
# row in the window — re-check at validate time prevents the race.
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): SELECT from decision_log per Step 2 query but at validate time;
# on hit emit ESC_AUTOSEND_RACE warn-tier + validate_gate_a_fail
_ok "G5: anti-duplicate re-check — SKELETON (W10-13 wires SQL)"

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nValidate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # TODO(W10-13): per-failure routing — different ESC code per failure class:
  #   G1 → ESC_VOICE_DRIFT (warn)
  #   G2 → ESC_ADDRESSEE_MISMATCH (blocking)
  #   G3 → ESC_TONE_RULE_VIOLATION (blocking)
  #   G4 → ESC_PII_LEAKAGE_RISK (blocking)
  #   G5 → ESC_AUTOSEND_RACE (warn; race_class=duplicate_payload)
  # hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" payload_hash \
  #   "ESC_<class>; agent_name:concierge; failures:${#FAILURES[@]}"
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
