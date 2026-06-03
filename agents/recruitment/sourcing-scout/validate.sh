#!/usr/bin/env bash
# shellcheck disable=SC2329
# (_fail + _warn are not invoked in the W5 Day-33 skeleton — TODO(W9)
#  blocks invoke them when the per-check impl lands. Keeping them defined
#  so the skeleton matches the final shape + the build-slice author can fill
#  the TODOs without re-declaring helpers.)
#
# Sourcing Scout agent — validate.sh (Gate A enforcement; W5 Day-33 SKELETON)
#
# Status: Proposed (W5 Day-33 SKELETON; W9 build slice completes the impl).
# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
# hard-fail gate that runs BETWEEN cycle.sh Step 9 (rationale generation) and
# Step 10 (output assembly + vault write). If any check fails, validate.sh
# exits non-zero + emits an ESC_* row to decision_log; the meeting's vault
# write is held to /tmp instead of /vault; cycle.sh exits 1.
#
# Invocation contract:
#   bash validate.sh <proposal_json>
#
# Inputs:
#   - $1: path to JSON describing the proposed Sourcing Scout output. Shape:
#         {
#           "brief_id": "<bullhorn_brief_id_or_slug>",
#           "tenant_slug": "<slug>",
#           "candidates": [
#             {
#               "candidate_id": "<bullhorn_id_or_external_ref>",
#               "source": "bullhorn | reed | cv-library",
#               "name": "...",
#               "contact_method": {
#                 "type": "email" | "phone" | "linkedin" | "bullhorn_internal",
#                 "value": "..."
#               },
#               "confidence": <0.0-1.0>,
#               "voice_score": <0.0-1.0>,
#               "rationale_word_count": <int>,
#               "rationale_body_preview": "..."   // first 500 chars for PII regex pass
#             }
#           ],
#           "sources_active": <int>,    // count of sources NOT in degraded mode
#           "sources_degraded": ["bullhorn"|"reed"|"cv-library"]
#         }
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
#          CTX_BULLHORN_CORPORATION_ID, CTX_FIRM_DOMAIN_WHITELIST,
#          CTX_DNC_BLOCKED_RECIPIENTS (JSON array; loaded by context.sh from
#          tenant_adapters.config.blocked_recipients)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to Step 10 vault write
#   1  At least one check failed; ESC_* row emitted; cycle.sh writes partial
#      draft to /tmp + exits 1
#   2  validate.sh invocation error (bad args, missing file, etc.)
#
# Checks (per agent.md §5 Gate A + ULTRAPLAN A5 line 552 verbatim):
#   G1 — Candidate count within [5, 15] inclusive
#   G2 — Every candidate has a working contact method (email matches
#         RFC-5322ish regex AND domain MX check OR E.164 phone OR LinkedIn URL
#         OR bullhorn_internal with bullhorn_id-with-contact)
#   G3 — Every candidate rationale ≥50 words
#   G4 — Every candidate rationale voice classifier ≥0.75
#   G5 — No candidate matches tenant DNC list (defence-in-depth; Step 8
#         already filtered but re-check at validate-time)
#   G6 — No PII outside firm boundary in any rationale (regex pass against
#         CTX_FIRM_DOMAIN_WHITELIST)
#   G7 — At least one source contributed (defence against all-source-failure
#         silently producing empty report when no degradation was recorded)

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  printf 'sourcing-scout/validate.sh: usage: validate.sh <proposal_json>\n' >&2
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

# Thresholds (per ULTRAPLAN A5 line 552)
readonly MIN_CANDIDATES="5"
readonly MAX_CANDIDATES="15"
readonly MIN_RATIONALE_WORDS="50"
readonly VOICE_SCORE_THRESHOLD="0.75"

# ────────────────────────────────────────────────────────────────────────
# G1 — Candidate count within [5, 15]
# Per ULTRAPLAN A5 line 552 verbatim ("5–15 candidates returned per brief").
# Below 5 → ESC_AGENT_OUTPUT_SHAPE (insufficient match diversity).
# Above 15 → ESC_AGENT_OUTPUT_SHAPE (consultant cognitive overload; brief
# under-specified OR ranking algorithm too permissive).
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): jq -r '.candidates | length' "$PROPOSAL"
# if count < 5 OR count > 15: _fail + ESC_AGENT_OUTPUT_SHAPE (warn-tier;
# operator_chat_id per catalogue line 184) via hh_decision_action validate_gate_a_fail.
_ok "G1: candidate count within [${MIN_CANDIDATES}, ${MAX_CANDIDATES}] — SKELETON (W9 wires jq parse + count check)"

# ────────────────────────────────────────────────────────────────────────
# G2 — Every candidate has working contact method
# Per ULTRAPLAN A5 line 552 verbatim ("each has a working contact method").
# Acceptable: email with valid format + MX OR E.164 phone OR LinkedIn URL
# OR bullhorn_internal (means bullhorn_id can resolve a contact server-side).
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): for each candidate (jq iteration): inspect .contact_method.type;
# - email → regex RFC-5322 simplified + DNS MX query for the domain
# - phone → E.164 format regex '^\+[1-9][0-9]{1,14}$'
# - linkedin → URL match '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
# - bullhorn_internal → assume valid (server-side resolution; tests cover separately)
# On any candidate failing: _fail + ESC_AGENT_OUTPUT_SHAPE.
_ok "G2: every candidate has working contact method — SKELETON (W9 wires per-type validators)"

# ────────────────────────────────────────────────────────────────────────
# G3 — Every rationale ≥50 words
# Per ULTRAPLAN A5 line 552 verbatim ("each has rationale ≥ 50 words").
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): jq -r '.candidates[].rationale_word_count' "$PROPOSAL" → compare
# each to MIN_RATIONALE_WORDS; on fail: _fail + ESC_AGENT_OUTPUT_SHAPE.
# Sourcing Scout §9 Q4 notes 50 words may be too short for high-quality
# explanations; v1.0 honors ULTRAPLAN floor (=50); founder may bump to 100
# after first-pilot consultant feedback.
_ok "G3: every candidate rationale ≥${MIN_RATIONALE_WORDS} words — SKELETON (W9 wires per-candidate word count check)"

# ────────────────────────────────────────────────────────────────────────
# G4 — Every rationale voice classifier ≥0.75
# Per agent.md §7. Below threshold (after 3 retries in cycle.sh Step 9) → drop
# candidate from final list + flag in exception list — that path is in
# cycle.sh; validate.sh re-checks final list at validation time.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): jq -r '.candidates[].voice_score' "$PROPOSAL" → for each compare
# to 0.75; on any fail: _fail + ESC_VOICE_DRIFT warn-tier (catalogue lines
# 120-125; operator_chat_id) via hh_decision_action validate_gate_a_fail.
# Sourcing Scout's per-run ESC_VOICE_DRIFT only; aggregate _TENANT is canary
# cron territory (per agent.md §7).
_ok "G4: every rationale voice classifier ≥${VOICE_SCORE_THRESHOLD} — SKELETON (W9 wires)"

# ────────────────────────────────────────────────────────────────────────
# G5 — No candidate matches tenant DNC list (defence-in-depth)
# Step 8 in cycle.sh already filtered against tenant_adapters.config.blocked_recipients;
# validate.sh re-checks at final assembly time to catch any post-Step-8
# additions (rare but possible if Step 9 inadvertently re-included a dropped
# candidate via rationale-generation side-effect).
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): for each candidate's contact_method.value: check against
# CTX_DNC_BLOCKED_RECIPIENTS (JSON array from tenant_adapters.config.blocked_recipients;
# loaded by context.sh; v0.3-allowlisted + LIVE on VPS post v0.4 migration).
# On match: _fail + ESC_AGENT_OUTPUT_SHAPE (per agent.md §5 — output-shape
# constraint; NOT ESC_DNC_FILTER_HIT which is reserved for outbound refusal
# per catalogue §2.10).
_ok "G5: no candidate in DNC list — SKELETON (W9 wires defence-in-depth re-check)"

# ────────────────────────────────────────────────────────────────────────
# G6 — No PII outside firm boundary in any rationale (regex pass)
# Per agent.md §5 + §7 tone rules. Blocking severity per catalogue §2.5.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): jq -r '.candidates[].rationale_body_preview' "$PROPOSAL" →
# grep for email patterns NOT matching CTX_FIRM_DOMAIN_WHITELIST; pattern-match
# full names not in known-candidates set; if any hit: _fail +
# ESC_PII_LEAKAGE_RISK blocking-tier (operator + ifos_oncall_chat_id routing).
# Per catalogue §2.5 — distinct from G1-G5 warn-tier; PII is blocking.
_ok "G6: no PII outside firm boundary — SKELETON (W9 wires firm-domain whitelist + regex pass)"

# ────────────────────────────────────────────────────────────────────────
# G7 — At least one source contributed (defence against silent all-source-failure)
# Per agent.md §5 + §4 Step 2 catalogue interpretation. If no source produced
# results AND no degradation note was recorded, that's a Gate A floor violation
# (the per-source ESC fires already covered legitimate degradations).
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): jq -r '.sources_active' "$PROPOSAL" → if 0 AND sources_degraded
# is empty: _fail + ESC_AGENT_OUTPUT_SHAPE warn-tier; this should never happen
# in practice since cycle.sh Step 2 emits degradation notes per source failure,
# but the defence-in-depth check catches a code-path bug where degradation
# logging is skipped + the agent silently produces an empty report.
_ok "G7: at least one source contributed (or degradation recorded) — SKELETON (W9 wires)"

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nSourcing Scout validate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # TODO(W9): per-failure routing — different ESC code per failure class:
  # - G1+G2+G3+G5+G7 → ESC_AGENT_OUTPUT_SHAPE (warn; operator_chat_id per
  #   catalogue line 184)
  # - G4 → ESC_VOICE_DRIFT (warn; operator_chat_id)
  # - G6 → ESC_PII_LEAKAGE_RISK (blocking; operator + ifos_oncall)
  # hh_decision_action "validate_gate_a_fail" "brief:$(jq -r .brief_id "$PROPOSAL")" payload_hash \
  #   "ESC_<class>; agent_name:sourcing-scout; failures:${#FAILURES[@]}"
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
