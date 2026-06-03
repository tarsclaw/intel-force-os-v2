#!/usr/bin/env bash
# shellcheck disable=SC2329
# (_fail + _warn are not invoked in the W5 Day-31 skeleton — TODO(W6-7)
#  blocks invoke them when the per-check impl lands. Keeping them defined
#  so the skeleton matches the final shape + the build-slice author can fill
#  the TODOs without re-declaring helpers.)
#
# Janitor agent — validate.sh (Gate A enforcement; W5 Day-31 SKELETON)
#
# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice completes the impl).
# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
# hard-fail gate that runs BETWEEN write batch generation (cycle.sh Step 9
# proposal phase) and the actual @ifos/bullhorn write call. If any check fails,
# validate.sh exits non-zero + emits an ESC_* escalation row to decision_log;
# the proposed write does NOT execute; cycle.sh skips that proposal + continues.
#
# Invocation contract:
#   bash validate.sh <write_proposal_json>
#
# Inputs:
#   - $1: path to a JSON file describing the proposed Bullhorn write. Shape:
#         {
#           "action_type": "bullhorn_candidate_dedupe" | "bullhorn_field_backfill" |
#                          "bullhorn_note_attach",
#           "entity_type": "candidate" | "contractor" | "contact" | "client",
#           "primary_id": <bullhorn_id>,
#           "merge_target_id": <bullhorn_id>,    // only for dedupe action_type
#           "confidence": <float 0.0-1.0>,       // only for dedupe action_type
#           "match_dimensions": ["name", "email", "phone", "linkedin"],
#           "last_activity_days": <int>,         // recency check
#           "voice_score": <float 0.0-1.0>,      // only for note_attach action_type
#           "narrative_body": "...",             // only for note_attach action_type
#           "field_changes": { "<field>": "<new_value>" },  // backfill
#           "source": "companies_house" | "linkedin" | "derivation"  // backfill
#         }
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
#          CTX_BULLHORN_CORPORATION_ID, CTX_JANITOR_DEDUP_THRESHOLD (default 0.85)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to actual write
#   1  At least one check failed; ESC_* row emitted; cycle.sh skips this write
#   2  validate.sh invocation error (bad args, missing file, etc.)
#
# Checks (per agent.md §5 Gate A):
#   G1 — Bullhorn auth refresh succeeded in Step 1 (no stale-token writes)
#   G2 — Dedup proposal: confidence ≥ CTX_JANITOR_DEDUP_THRESHOLD (default 0.85;
#         per ULTRAPLAN A2 line 510 + tenant override range [0.75, 0.95] per
#         vertical-schema v0.3 §4 tenant_adapters_config_additions.janitor_dedup_threshold)
#   G3 — Dedup proposal: NEITHER candidate has Bullhorn activity in last 90 days
#         (per ULTRAPLAN A2 line 510 verbatim). Confidence ≥0.85 BUT recent
#         activity → review-band → ESC_DUPLICATE_DETECTED (SUCCESS-path approval),
#         NOT Gate A failure.
#   G4 — Field-backfill: source confidence ≥0.7 (CH 404 / LinkedIn empty / no
#         derivation source → fail). Backfill action_type only.
#   G5 — Tacit-note narrative: voice classifier ≥0.75 (after 3 retries).
#         Note_attach action_type only.
#   G6 — No PII outside firm boundary in tacit-note narratives (regex pass).
#         Note_attach action_type only.
#   G7 — Write batch size sanity: this single proposal does not exceed 100/min
#         rate-limit defensive cap (per agent.md §5).

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  printf 'janitor/validate.sh: usage: validate.sh <write_proposal_json>\n' >&2
  exit 2
fi

readonly PROPOSAL="$1"

if [[ ! -f "${PROPOSAL}" ]]; then
  printf 'validate.sh: proposal not found at %s\n' "${PROPOSAL}" >&2
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

# Resolve _shared/ helpers (4-candidate fallback; matches sibling agents
# per smoke-hotfix commit d7d52c5).
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

# Track failures + warnings across all checks (collect all before exit for richer audit)
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

# Dedup threshold env (default per ULTRAPLAN A2 line 510 verbatim; per-tenant
# override range [0.75, 0.95] enforced by validate_tenant_adapters_config_v0_3
# trigger on tenant_adapters.config.janitor_dedup_threshold)
readonly DEDUP_THRESHOLD="${CTX_JANITOR_DEDUP_THRESHOLD:-0.85}"

# ────────────────────────────────────────────────────────────────────────
# G1 — Bullhorn auth refresh succeeded in Step 1 (sanity check)
# Sanity check that cycle.sh Step 1 emitted a fresh bullhorn_auth_refresh row.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): SELECT FROM decision_log WHERE action_type='bullhorn_auth_refresh'
# AND tenant_slug=$CTX_TENANT_SLUG AND created_at > now() - interval '10 minutes';
# if no row OR payload.bullhorn_token_state='failed' → _fail + ESC_BULLHORN_AUTH
# (blocking; operator + ifos_oncall per catalogue routing).
_ok "G1: Bullhorn auth refresh fresh — SKELETON (W6-7 wires the decision_log re-query)"

# ────────────────────────────────────────────────────────────────────────
# G2 — Dedup confidence ≥ threshold (default 0.85; per-tenant override range)
# Per ULTRAPLAN A2 line 510. Sub-0.70 silently drops in Step 3 algorithm
# (no proposal reaches here). 0.70-0.85 → review-band ESC_DUPLICATE_DETECTED.
# ≥0.85 → Gate A pass (this check).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): jq -r '.action_type' "$PROPOSAL" — if dedupe action_type, then
# jq -r '.confidence' "$PROPOSAL" → compare to DEDUP_THRESHOLD; if < threshold:
# _fail + ESC_AGENT_OUTPUT_SHAPE (output-shape constraint per catalogue line 184)
# via hh_decision_action validate_gate_a_fail.
_ok "G2: dedup confidence ≥${DEDUP_THRESHOLD} — SKELETON (W6-7 wires jq parse + threshold compare)"

# ────────────────────────────────────────────────────────────────────────
# G3 — No Bullhorn activity in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
# Recent activity = placement / interview / note in last 90d. If EITHER side
# of the dedup pair has recent activity → review-band → ESC_DUPLICATE_DETECTED
# SUCCESS-path approval (NOT Gate A failure). validate.sh treats this as a
# REJECT-this-auto-write signal but the proposal is not erroneous.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): jq -r '.last_activity_days' "$PROPOSAL" → if < 90 (and action_type
# is dedupe): _fail (rejects auto-write) + emit ESC_DUPLICATE_DETECTED warn-tier
# (per catalogue §2.5; SUCCESS-path; routes operator_chat_id via Telegram approval)
# via hh_decision_action with phase='action' action_type='operator_approval_request'.
_ok "G3: no Bullhorn activity in last 90d — SKELETON (W6-7 wires activity-days check)"

# ────────────────────────────────────────────────────────────────────────
# G4 — Field-backfill source confidence ≥0.7
# CH 404 / LinkedIn empty / no derivation source → low-confidence; reject.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): if action_type='bullhorn_field_backfill', read .source +
# .source_confidence from $PROPOSAL; if confidence < 0.7: _fail +
# ESC_AGENT_OUTPUT_SHAPE (output-shape constraint).
_ok "G4: field-backfill source confidence ≥0.7 — SKELETON (W6-7 wires)"

# ────────────────────────────────────────────────────────────────────────
# G5 — Tacit-note voice classifier ≥0.75
# Per agent.md §7. Below threshold after 3 retries → ESC_VOICE_DRIFT warn.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): if action_type='bullhorn_note_attach', read .voice_score from
# $PROPOSAL; if < 0.75: _fail + ESC_VOICE_DRIFT (warn per catalogue lines
# 120-125; operator_chat_id) via hh_decision_action validate_gate_a_fail.
_ok "G5: tacit-note voice classifier ≥0.75 — SKELETON (W6-7 wires)"

# ────────────────────────────────────────────────────────────────────────
# G6 — No PII outside firm boundary in tacit-note narrative
# Regex pass against narrative body; emails NOT matching tenant firm-domain
# whitelist → fail + ESC_PII_LEAKAGE_RISK (blocking; operator + ifos_oncall).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): if action_type='bullhorn_note_attach', grep .narrative_body for
# email patterns NOT in CTX_FIRM_DOMAIN_WHITELIST; if any: _fail +
# ESC_PII_LEAKAGE_RISK (blocking; operator + ifos_oncall_chat_id routing).
_ok "G6: no PII outside firm boundary — SKELETON (W6-7 wires firm-domain whitelist)"

# ────────────────────────────────────────────────────────────────────────
# G7 — Write batch size sanity (this proposal ≤ 100/min remaining budget)
# Defensive — cross-checks @ifos/bullhorn per-corporation_id rate-limit
# (per-corp 600/min hard per src/rate-limit.ts).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): import {rateCheck} from '@ifos/bullhorn'; if shouldBackoff at
# soft (480/min): _warn but continue; if hard (600/min): _fail + skip this
# proposal (caller cycles back to attempt later). Catalogue: ESC_RATE_LIMIT_HIT.
_ok "G7: write batch rate-limit budget ok — SKELETON (W6-7 wires @ifos/bullhorn rateCheck)"

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nJanitor validate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # TODO(W6-7): per-failure routing — different ESC code per failure class
  # (G1 → ESC_BULLHORN_AUTH blocking; G2 → ESC_AGENT_OUTPUT_SHAPE warn;
  #  G3 → ESC_DUPLICATE_DETECTED warn SUCCESS-path approval-gate;
  #  G4 → ESC_AGENT_OUTPUT_SHAPE warn; G5 → ESC_VOICE_DRIFT warn;
  #  G6 → ESC_PII_LEAKAGE_RISK blocking; G7 → ESC_RATE_LIMIT_HIT warn)
  # hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" payload_hash \
  #   "ESC_<class>; agent_name:janitor; failures:${#FAILURES[@]}; proposal:${PROPOSAL}"
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
