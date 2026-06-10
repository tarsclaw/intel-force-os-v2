#!/usr/bin/env bash
# Sourcing Scout agent — validate.sh (Gate A enforcement; W9 build slice LIVE)
#
# Status: LIVE per spec-003 §5 (W9 build slice).
# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
# hard-fail gate that runs BETWEEN cycle.sh Step 9 (rationale generation) and
# Step 10's vault write. If any check fails, validate.sh emits the mandatory
# hh_decision_action("validate_gate_a_fail", ...) audit row carrying the
# dominant ESC class + the autosend_escalate ESC row, then exits non-zero;
# cycle.sh holds the draft at /tmp instead of /vault and exits 1.
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
#               "source": "bullhorn | reed | cvlibrary",
#               "name": "...",
#               "contact_method": { "type": "email"|"phone"|"linkedin"|"bullhorn_internal",
#                                   "value": "..." },
#               "confidence": <0.0-1.0>,
#               "voice_score": <0.0-1.0> | "unscored",
#               "rationale_word_count": <int>,
#               "rationale_body_preview": "..."   // first 500 chars for PII regex pass
#             }
#           ],
#           "sources_active": <int>,    // count of sources NOT in degraded mode
#           "sources_degraded": ["bullhorn"|"reed"|"cvlibrary"],
#           "source_stats": { "<source>": {queried, returned, note}, ... }
#         }
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
#          CTX_FIRM_DOMAIN_WHITELIST (comma-separated),
#          CTX_DNC_BLOCKED_RECIPIENTS (JSON array; loaded by context.sh from
#          tenant_adapters.config.blocked_recipients)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to the Step 10 vault write
#   1  At least one check failed; validate_gate_a_fail + ESC_* rows emitted;
#      cycle.sh writes partial draft to /tmp + exits 1
#   2  validate.sh invocation error (bad args, missing file, etc.)
#
# Checks (per agent.md §5 Gate A + ULTRAPLAN A5 line 552 verbatim):
#   G1 — Candidate count within [5, 15] inclusive
#   G2 — Every candidate has a working contact method (email regex [+ MX
#         best-effort] OR E.164 phone OR LinkedIn URL OR bullhorn_internal)
#   G3 — Every candidate rationale ≥50 words
#   G4 — Every candidate rationale voice classifier ≥0.75
#         (hard when scored; WARN when unscored/no_corpus — spec-003 §5)
#   G5 — No candidate matches tenant DNC list (defence-in-depth re-check)
#   G6 — No PII outside firm boundary in any rationale (BLOCKING)
#   G7 — No enabled live source returned 0 WITHOUT a degradation note; and at
#         least one source contributed or recorded a degradation

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
command -v jq >/dev/null 2>&1 || { printf 'validate.sh: jq required\n' >&2; exit 2; }
if ! jq -e . "${PROPOSAL}" >/dev/null 2>&1; then
  printf 'validate.sh: proposal is not valid JSON\n' >&2
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

# Dominant failure class for ESC routing (first hard fail wins, EXCEPT
# G6 PII which is blocking and always takes precedence).
ESC_CLASS=""
_set_class() {
  if [[ "$1" == "ESC_PII_LEAKAGE_RISK" ]]; then
    ESC_CLASS="ESC_PII_LEAKAGE_RISK"
  else
    ESC_CLASS="${ESC_CLASS:-$1}"
  fi
}

# Thresholds (per ULTRAPLAN A5 line 552)
readonly MIN_CANDIDATES="5"
readonly MAX_CANDIDATES="15"
readonly MIN_RATIONALE_WORDS="50"
readonly VOICE_SCORE_THRESHOLD="0.75"

BRIEF_ID="$(jq -r '.brief_id // "unknown"' "${PROPOSAL}")"
N_CANDIDATES="$(jq -r '.candidates | length' "${PROPOSAL}")"

# ────────────────────────────────────────────────────────────────────────
# G1 — Candidate count within [5, 15]
# Below 5 → insufficient match diversity; above 15 → consultant cognitive
# overload. Both → ESC_AGENT_OUTPUT_SHAPE (warn-tier; catalogue line 184).
# ────────────────────────────────────────────────────────────────────────

if [[ "${N_CANDIDATES}" -lt "${MIN_CANDIDATES}" || "${N_CANDIDATES}" -gt "${MAX_CANDIDATES}" ]]; then
  _fail "G1: candidate count ${N_CANDIDATES} outside [${MIN_CANDIDATES}, ${MAX_CANDIDATES}]"
  _set_class "ESC_AGENT_OUTPUT_SHAPE"
else
  _ok "G1: candidate count ${N_CANDIDATES} within [${MIN_CANDIDATES}, ${MAX_CANDIDATES}]"
fi

# ────────────────────────────────────────────────────────────────────────
# G2 — Every candidate has a working contact method
# email: RFC-5322-simplified regex (+ best-effort MX when IFOS_SCOUT_MX_CHECK=1
#        and `host` is available — DNS lookups are skipped by default so the
#        gate stays deterministic offline; documented honest scope)
# phone: E.164 '^\+[1-9][0-9]{1,14}$'
# linkedin: '^https://([a-z]{2,3}\.)?linkedin\.com/in/...'
# bullhorn_internal: bullhorn_id resolves a contact server-side → accepted
# ────────────────────────────────────────────────────────────────────────

_g2_bad=0
while IFS=$'\t' read -r _c_id _c_type _c_value; do
  [[ -z "${_c_id}" ]] && continue
  case "${_c_type}" in
    email)
      if [[ "${_c_value}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        if [[ "${IFOS_SCOUT_MX_CHECK:-0}" == "1" ]] && command -v host >/dev/null 2>&1; then
          _dom="${_c_value##*@}"
          if ! host -t MX "${_dom}" >/dev/null 2>&1; then
            _g2_bad=$((_g2_bad + 1))
            _fail "G2: ${_c_id} email domain '${_dom}' has no MX record"
          fi
        fi
      else
        _g2_bad=$((_g2_bad + 1))
        _fail "G2: ${_c_id} email fails format check"
      fi ;;
    phone)
      if [[ ! "${_c_value}" =~ ^\+[1-9][0-9]{1,14}$ ]]; then
        _g2_bad=$((_g2_bad + 1))
        _fail "G2: ${_c_id} phone not E.164"
      fi ;;
    linkedin)
      if [[ ! "${_c_value}" =~ ^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9_-]+/?$ ]]; then
        _g2_bad=$((_g2_bad + 1))
        _fail "G2: ${_c_id} linkedin URL fails format check"
      fi ;;
    bullhorn_internal)
      if [[ -z "${_c_value}" ]]; then
        _g2_bad=$((_g2_bad + 1))
        _fail "G2: ${_c_id} bullhorn_internal with empty bullhorn id"
      fi ;;
    *)
      _g2_bad=$((_g2_bad + 1))
      _fail "G2: ${_c_id} has no working contact method (type='${_c_type}')" ;;
  esac
done < <(jq -r '.candidates[] | [.candidate_id, (.contact_method.type // "missing"), (.contact_method.value // "")] | @tsv' "${PROPOSAL}")
if [[ "${_g2_bad}" -gt 0 ]]; then
  _set_class "ESC_AGENT_OUTPUT_SHAPE"
else
  _ok "G2: every candidate has a working contact method"
fi

# ────────────────────────────────────────────────────────────────────────
# G3 — Every rationale ≥50 words
# Recomputes from rationale_body_preview when present (never trusts the
# self-reported count alone); falls back to rationale_word_count.
# ────────────────────────────────────────────────────────────────────────

_g3_bad=0
while IFS=$'\t' read -r _c_id _c_count; do
  [[ -z "${_c_id}" ]] && continue
  if [[ ! "${_c_count}" =~ ^[0-9]+$ ]] || [[ "${_c_count}" -lt "${MIN_RATIONALE_WORDS}" ]]; then
    _g3_bad=$((_g3_bad + 1))
    _fail "G3: ${_c_id} rationale ${_c_count:-0} words < ${MIN_RATIONALE_WORDS}"
  fi
done < <(jq -r '
  .candidates[]
  | [ .candidate_id,
      ( if (.rationale_body // .rationale_body_preview // "") != ""
        then ((.rationale_body // .rationale_body_preview) | [splits("\\s+") | select(. != "")] | length)
        else (.rationale_word_count // 0) end ) ]
  | @tsv' "${PROPOSAL}")
if [[ "${_g3_bad}" -gt 0 ]]; then
  _set_class "ESC_AGENT_OUTPUT_SHAPE"
else
  _ok "G3: every candidate rationale ≥${MIN_RATIONALE_WORDS} words"
fi

# ────────────────────────────────────────────────────────────────────────
# G4 — Every rationale voice classifier ≥0.75
# Hard when a numeric score is present; WARN when unscored (empty tenant
# voice_corpus → a score cannot be honestly computed; spec-003 §5
# "hard (warn-when-unscored)" + §8 never-fake disposition).
# ────────────────────────────────────────────────────────────────────────

_g4_bad=0
_g4_unscored=0
while IFS=$'\t' read -r _c_id _c_voice; do
  [[ -z "${_c_id}" ]] && continue
  if [[ "${_c_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    if ! awk -v s="${_c_voice}" -v t="${VOICE_SCORE_THRESHOLD}" 'BEGIN{exit !(s>=t)}'; then
      _g4_bad=$((_g4_bad + 1))
      _fail "G4: ${_c_id} voice_score ${_c_voice} < ${VOICE_SCORE_THRESHOLD}"
    fi
  else
    _g4_unscored=$((_g4_unscored + 1))
  fi
done < <(jq -r '.candidates[] | [.candidate_id, (.voice_score | tostring)] | @tsv' "${PROPOSAL}")
if [[ "${_g4_bad}" -gt 0 ]]; then
  _set_class "ESC_VOICE_DRIFT"
elif [[ "${_g4_unscored}" -gt 0 ]]; then
  _warn "G4: ${_g4_unscored} rationale(s) unscored (no tenant voice_corpus) — threshold not enforceable (documented enhancement)"
else
  _ok "G4: every rationale voice classifier ≥${VOICE_SCORE_THRESHOLD}"
fi

# ────────────────────────────────────────────────────────────────────────
# G5 — No candidate matches tenant DNC list (defence-in-depth)
# Step 8 already filtered against tenant_adapters.config.blocked_recipients;
# re-check the FINAL list against CTX_DNC_BLOCKED_RECIPIENTS (email lowercase,
# phone digits-normalised, name lowercase — same matching as Step 8).
# ────────────────────────────────────────────────────────────────────────

_DNC_JSON="${CTX_DNC_BLOCKED_RECIPIENTS:-[]}"
if ! printf '%s' "${_DNC_JSON}" | jq -e 'type == "array"' >/dev/null 2>&1; then
  _DNC_JSON="[]"
fi
_g5_hits="$(jq -r --argjson dnc "${_DNC_JSON}" '
  def nphone: gsub("[^0-9]"; "") | if length > 10 then .[-10:] else . end;
  ($dnc | map(ascii_downcase)) as $dl
  | ($dnc | map(nphone) | map(select(. != ""))) as $dp
  | [ .candidates[]
      | select(
          (((.contact_method.value // "") | ascii_downcase) as $v | ($dl | index($v)) != null)
          or ((((.email // "") | ascii_downcase) as $e | $e != "" and ($dl | index($e)) != null))
          or ((((.phone // "") | nphone) as $p | $p != "" and ($dp | index($p)) != null))
          or ((((.name // "") | ascii_downcase) as $n | $n != "" and ($dl | index($n)) != null)) )
      | .candidate_id ]
  | length' "${PROPOSAL}" 2>/dev/null || echo 0)"
if [[ "${_g5_hits}" =~ ^[0-9]+$ && "${_g5_hits}" -gt 0 ]]; then
  _fail "G5: ${_g5_hits} candidate(s) match the tenant DNC list (post-Step-8 re-check)"
  _set_class "ESC_AGENT_OUTPUT_SHAPE"
else
  _ok "G5: no candidate in DNC list (defence-in-depth re-check)"
fi

# ────────────────────────────────────────────────────────────────────────
# G6 — No PII outside firm boundary in any rationale (BLOCKING per
# catalogue §2.5). Regex pass: any email address in a rationale whose domain
# is not in CTX_FIRM_DOMAIN_WHITELIST → ESC_PII_LEAKAGE_RISK.
# ────────────────────────────────────────────────────────────────────────

_g6_bad=0
_FIRM_DOMAINS=",$(printf '%s' "${CTX_FIRM_DOMAIN_WHITELIST:-}" | tr '[:upper:]' '[:lower:]' | tr -d ' '),"
while IFS=$'\t' read -r _c_id _c_body; do
  [[ -z "${_c_id}" || -z "${_c_body}" ]] && continue
  while IFS= read -r _em; do
    [[ -z "${_em}" ]] && continue
    _em_dom="$(printf '%s' "${_em##*@}" | tr '[:upper:]' '[:lower:]')"
    if [[ "${_FIRM_DOMAINS}" != *",${_em_dom},"* ]]; then
      _g6_bad=$((_g6_bad + 1))
      _fail "G6: ${_c_id} rationale contains an email outside the firm boundary (domain '${_em_dom}')"
    fi
  done < <(printf '%s' "${_c_body}" | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)
done < <(jq -r '.candidates[] | [.candidate_id, ((.rationale_body // .rationale_body_preview // "") | gsub("[\\n\\t]"; " "))] | @tsv' "${PROPOSAL}")
if [[ "${_g6_bad}" -gt 0 ]]; then
  _set_class "ESC_PII_LEAKAGE_RISK"
else
  _ok "G6: no PII outside firm boundary in any rationale"
fi

# ────────────────────────────────────────────────────────────────────────
# G7 — Source floor: no enabled live source returned 0 WITHOUT a degradation
# note, and at least one source contributed or recorded a degradation
# (defence against silent all-source-failure producing an empty report).
# ────────────────────────────────────────────────────────────────────────

_g7_bad="$(jq -r '
  (.sources_degraded // []) as $deg
  | [ (.source_stats // {}) | to_entries[]
      | select(.key != "linkedin")                       # v1.0 NO-OP, never live
      | select(.value.queried == true)
      | select((.value.returned // 0) == 0)
      | select(((.value.note // "") | test("degrad|429|rate[_-]?limit|cached"; "i")) | not)
      | select((.key as $k | $deg | index($k)) == null)
      | .key ]
  | length' "${PROPOSAL}" 2>/dev/null || echo 0)"
_g7_any="$(jq -r '
  ([ (.source_stats // {}) | to_entries[] | select((.value.returned // 0) > 0) ] | length) as $contrib
  | ((.sources_degraded // []) | length) as $deg
  | if ($contrib > 0 or $deg > 0) then "yes" else "no" end' "${PROPOSAL}" 2>/dev/null || echo no)"
if [[ "${_g7_bad}" =~ ^[0-9]+$ && "${_g7_bad}" -gt 0 ]]; then
  _fail "G7: ${_g7_bad} enabled live source(s) returned 0 without a recorded degradation note"
  _set_class "ESC_AGENT_OUTPUT_SHAPE"
elif [[ "${_g7_any}" == "no" ]]; then
  _fail "G7: no source contributed and no degradation was recorded (silent all-source failure)"
  _set_class "ESC_AGENT_OUTPUT_SHAPE"
else
  _ok "G7: source floor honoured (contributions or degradation notes present)"
fi

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nSourcing Scout validate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # Per-failure-class ESC routing (agent.md §5):
  #   G1/G2/G3/G5/G7 → ESC_AGENT_OUTPUT_SHAPE (warn; operator_chat_id)
  #   G4             → ESC_VOICE_DRIFT (warn; operator_chat_id)
  #   G6             → ESC_PII_LEAKAGE_RISK (BLOCKING; operator + ifos_oncall)
  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
  _ss_phash="$(printf '%s' "${BRIEF_ID}|${N_CANDIDATES}|${FAILURES[0]}" | shasum -a 256 2>/dev/null | cut -c1-16)"
  [[ -z "${_ss_phash}" ]] && _ss_phash="gate-a-${BRIEF_ID}"
  # Mandatory audit row per master brief §8.1 Change 2 + autosend-policy.yaml
  # validate_gate_a_fail (green tier, registered).
  hh_decision_action "validate_gate_a_fail" "brief:${BRIEF_ID}" "${_ss_phash}" \
    "${ESC_CLASS}; agent_name:sourcing-scout; failures:${#FAILURES[@]}; first:${FAILURES[0]}" || true
  autosend_escalate "${ESC_CLASS}" "agent=sourcing-scout" \
    "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_ID}" \
    "candidate_count=${N_CANDIDATES}" "failures=${#FAILURES[@]}"
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
