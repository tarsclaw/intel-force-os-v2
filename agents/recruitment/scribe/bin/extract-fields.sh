#!/usr/bin/env bash
# Scribe — Step 5 field extraction (agent.md §4 Step 5; spec-002 §4 row 5).
#
# Prints a JSON array of {field_name, value, confidence} to stdout for ONE
# call transcript + resolved entity_type. Two paths:
#
#   1. DETERMINISTIC (default; CC templated-draft precedent) — fixed regex
#      patterns over the transcript with per-pattern confidence CONSTANTS
#      (a heuristic of pattern specificity, NOT a probabilistic score: an
#      explicitly-labelled value scores higher than an inferred one). Same
#      input always yields the same output → fixture-reproducible without
#      any LLM and without ANTHROPIC_API_KEY.
#
#   2. LLM (opt-in: IFOS_SCRIBE_USE_LLM=1 AND ANTHROPIC_API_KEY set) —
#      Claude messages API with a JSON-schema-constrained output. ANY
#      failure (network, parse, empty) falls back to path 1 so the run
#      stays deterministic-safe. Fixtures MUST NOT set IFOS_SCRIBE_USE_LLM.
#
# Field names + types are the vertical-schema canonical set (v0.1 + v0.3
# supplement) — see bin/validate-fields.sh for the authoritative allowlist;
# Step 7 re-validates everything this script emits.
#
# Usage:
#   extract-fields.sh --transcript <path> --entity-type <candidate|contact|brief|placement|opportunity> \
#     [--call-id <id>] [--vault-path </vault/...md>]
#
# --vault-path: the canonical tacit-note pointer for placement
# week_1_status_vault_path (deterministic from call_id+date; cycle.sh passes it).

set -euo pipefail

TRANSCRIPT="" ENTITY_TYPE="" VAULT_PATH=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --transcript)  TRANSCRIPT="${2:-}"; shift 2 ;;
    --entity-type) ENTITY_TYPE="${2:-}"; shift 2 ;;
    --call-id)     shift 2 ;;   # accepted for call-site symmetry; not needed for extraction
    --vault-path)  VAULT_PATH="${2:-}"; shift 2 ;;
    *) printf 'extract-fields.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done
if [[ -z "${TRANSCRIPT}" || ! -f "${TRANSCRIPT}" || -z "${ENTITY_TYPE}" ]]; then
  printf 'extract-fields.sh: --transcript <existing file> and --entity-type required\n' >&2
  exit 2
fi
command -v jq >/dev/null 2>&1 || { printf 'extract-fields.sh: jq required\n' >&2; exit 2; }

TEXT="$(cat "${TRANSCRIPT}")"

# Accumulate fields as JSON objects (one per line) → assembled with jq -s.
FIELDS_TMP="$(mktemp -t scribe-fields-XXXXXX)"
trap 'rm -f "${FIELDS_TMP}"' EXIT
: > "${FIELDS_TMP}"

_emit_str()  { jq -nc --arg f "$1" --arg v "$2" --argjson c "$3" '{field_name:$f,value:$v,confidence:$c}' >> "${FIELDS_TMP}"; }
_emit_num()  { jq -nc --arg f "$1" --argjson v "$2" --argjson c "$3" '{field_name:$f,value:$v,confidence:$c}' >> "${FIELDS_TMP}"; }
_emit_list() { jq -nc --arg f "$1" --arg v "$2" --argjson c "$3" '{field_name:$f,value:($v | split(",") | map(gsub("^\\s+|\\s+$";"")) | map(select(length>0))),confidence:$c}' >> "${FIELDS_TMP}"; }

# Salary-range helper: "£85k to £95k" / "£70k-£80k" → "85000 95000".
_salary_range() {
  printf '%s\n' "${TEXT}" \
    | sed -nE 's/.*£([0-9]+)[kK][^£0-9]*£?([0-9]+)[kK].*/\1 \2/p' | head -1
}

# ── LLM path (opt-in; deterministic fallback on ANY failure) ─────────────
_llm_extract() {
  [[ "${IFOS_SCRIBE_USE_LLM:-0}" == "1" && -n "${ANTHROPIC_API_KEY:-}" ]] || return 1
  local schema body resp text
  schema='{"type":"object","properties":{"fields":{"type":"array","items":{"type":"object","properties":{"field_name":{"type":"string"},"value":{},"confidence":{"type":"number"}},"required":["field_name","value","confidence"],"additionalProperties":false}}},"required":["fields"],"additionalProperties":false}'
  body=$(jq -nc --arg model "claude-opus-4-8" --arg et "${ENTITY_TYPE}" --arg tx "${TEXT}" --argjson schema "${schema}" '{
    model: $model, max_tokens: 4096,
    output_config: {format: {type: "json_schema", schema: $schema}},
    messages: [{role:"user", content: ("Extract structured recruitment fields for entity type \"" + $et + "\" from this UK recruitment call transcript. Use ONLY canonical vertical-schema field names (candidate: location,current_role,notice_period_weeks,salary_expectation_min,salary_expectation_max,employment_type,key_skills; contact: preferred_channel,next_action_target_date; brief: salary_min,salary_max,role_type,must_haves,nice_to_haves,deal_breakers; placement: placement_status,satisfaction_signal; opportunity: headcount_growth_signal_text,hiring_velocity_band,decision_window_text). Include a 0-1 confidence per field; omit fields you cannot ground in the transcript.\n\nTRANSCRIPT:\n" + $tx)}]
  }') || return 1
  resp=$(curl -sS --max-time 60 https://api.anthropic.com/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: ${ANTHROPIC_API_KEY}" \
    -H "anthropic-version: 2023-06-01" \
    -d "${body}" 2>/dev/null) || return 1
  text=$(printf '%s' "${resp}" | jq -r '.content[]? | select(.type=="text") | .text' 2>/dev/null) || return 1
  [[ -n "${text}" ]] || return 1
  printf '%s' "${text}" | jq -e '.fields | type=="array" and length>0' >/dev/null 2>&1 || return 1
  printf '%s' "${text}" | jq -c '.fields'
  return 0
}

if _llm_out="$(_llm_extract)"; then
  printf '%s\n' "${_llm_out}"
  exit 0
fi

# ── Deterministic path ────────────────────────────────────────────────────
case "${ENTITY_TYPE}" in
  candidate)
    _loc="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Bb]ased in ([A-Z][A-Za-z-]+( [A-Z][A-Za-z-]+)?).*/\1/p' | head -1)"
    [[ -z "${_loc}" ]] && _loc="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Ll]ocation:?[[:space:]]+([A-Z][A-Za-z, -]+[A-Za-z]).*/\1/p' | head -1)"
    [[ -n "${_loc}" ]] && _emit_str "location" "${_loc}" 0.78
    _role="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Cc]urrently an? ([A-Z][A-Za-z ]+[a-z]) at .*/\1/p' | head -1)"
    [[ -z "${_role}" ]] && _role="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Cc]urrent role:?[[:space:]]+([A-Z][A-Za-z ]+[a-z]).*/\1/p' | head -1)"
    [[ -n "${_role}" ]] && _emit_str "current_role" "${_role}" 0.85
    # shellcheck disable=SC1112  # the unicode apostrophe is an intentional literal alternative
    _np="$(printf '%s\n' "${TEXT}" | sed -nE "s/.*[^0-9]([0-9]{1,2}) weeks?['’]? notice.*/\1/p" | head -1)"
    [[ -z "${_np}" ]] && _np="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Nn]otice period:?[[:space:]]+([0-9]{1,2}).*/\1/p' | head -1)"
    [[ -n "${_np}" ]] && _emit_num "notice_period_weeks" "${_np}" 0.88
    _sr="$(_salary_range)"
    if [[ -n "${_sr}" ]]; then
      read -r _smin _smax <<<"${_sr}"
      _emit_num "salary_expectation_min" "$((_smin * 1000))" 0.82
      _emit_num "salary_expectation_max" "$((_smax * 1000))" 0.82
    fi
    if printf '%s' "${TEXT}" | grep -qi "outside ir35"; then
      _emit_str "employment_type" "contract_outside_ir35" 0.80
    elif printf '%s' "${TEXT}" | grep -qi "inside ir35"; then
      _emit_str "employment_type" "contract_inside_ir35" 0.80
    elif printf '%s' "${TEXT}" | grep -qiE "permanent (role|position)"; then
      _emit_str "employment_type" "perm" 0.72
    elif printf '%s' "${TEXT}" | grep -qi "day rate"; then
      _emit_str "employment_type" "day_rate" 0.72
    fi
    _skills="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Kk]ey skills:?[[:space:]]+([A-Za-z0-9+#., -]+[A-Za-z0-9+#]).*/\1/p' | head -1)"
    [[ -n "${_skills}" ]] && _emit_list "key_skills" "${_skills}" 0.86
    ;;
  contact)
    _ch="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Pp]refers? (email|phone|sms|teams|slack)\b.*/\1/p' | head -1 | tr '[:upper:]' '[:lower:]')"
    [[ -n "${_ch}" ]] && _emit_str "preferred_channel" "${_ch}" 0.80
    _dt="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Ff]ollow up (on|by) ([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\2/p' | head -1)"
    [[ -n "${_dt}" ]] && _emit_str "next_action_target_date" "${_dt}" 0.85
    # NOTE: decision_authority is R-only for Scribe (v0.3 §2 access matrix) — never extracted for write.
    ;;
  brief)
    if printf '%s' "${TEXT}" | grep -qiE "permanent (role|position|hire)"; then
      _emit_str "role_type" "permanent" 0.80
    elif printf '%s' "${TEXT}" | grep -qiE "contract (role|position)"; then
      _emit_str "role_type" "contract" 0.80
    elif printf '%s' "${TEXT}" | grep -qi "retained"; then
      _emit_str "role_type" "retained_search" 0.78
    elif printf '%s' "${TEXT}" | grep -qiE "\btemp\b"; then
      _emit_str "role_type" "temp" 0.72
    fi
    _sr="$(_salary_range)"
    if [[ -n "${_sr}" ]]; then
      read -r _smin _smax <<<"${_sr}"
      _emit_num "salary_min" "$((_smin * 1000))" 0.82
      _emit_num "salary_max" "$((_smax * 1000))" 0.82
    fi
    _mh="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Mm]ust[- ]haves?:?[[:space:]]+([A-Za-z0-9+#., -]+[A-Za-z0-9+#]).*/\1/p' | head -1)"
    [[ -n "${_mh}" ]] && _emit_list "must_haves" "${_mh}" 0.90
    _nh="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Nn]ice[- ]to[- ]haves?:?[[:space:]]+([A-Za-z0-9+#., -]+[A-Za-z0-9+#]).*/\1/p' | head -1)"
    [[ -n "${_nh}" ]] && _emit_list "nice_to_haves" "${_nh}" 0.90
    _db="$(printf '%s\n' "${TEXT}" | sed -nE 's/.*[Dd]eal[- ]breakers?:?[[:space:]]+([A-Za-z0-9+#., -]+[A-Za-z0-9+#]).*/\1/p' | head -1)"
    [[ -n "${_db}" ]] && _emit_list "deal_breakers" "${_db}" 0.90
    ;;
  placement)
    if printf '%s' "${TEXT}" | grep -qiE "(first week|started|settling in|week one)"; then
      _emit_str "placement_status" "active" 0.85
    elif printf '%s' "${TEXT}" | grep -qiE "(hasn'?t started|starts on|start date pushed)"; then
      _emit_str "placement_status" "pending_start" 0.80
    elif printf '%s' "${TEXT}" | grep -qiE "(handed in|terminated|left the role)"; then
      _emit_str "placement_status" "terminated_early" 0.75
    fi
    if printf '%s' "${TEXT}" | grep -qiE "(going well|supportive|great|really happy|enjoying)"; then
      _emit_str "satisfaction_signal" "positive" 0.85
    elif printf '%s' "${TEXT}" | grep -qiE "(unhappy|frustrated|struggling|concerns?|regret)"; then
      _emit_str "satisfaction_signal" "negative" 0.80
    elif printf '%s' "${TEXT}" | grep -qiE "how('s| is) (the|your) (first|new)"; then
      _emit_str "satisfaction_signal" "unclear" 0.55   # weak cue — below the 0.6 Gate A bar by design
    fi
    # Pointer to THIS call's tacit-note (ADR-002: pointer in Postgres, narrative in vault).
    [[ -n "${VAULT_PATH}" ]] && _emit_str "week_1_status_vault_path" "${VAULT_PATH}" 0.95
    ;;
  opportunity)
    _hg="$(printf '%s\n' "${TEXT}" | grep -iE "hiring [0-9]+|growing the team|headcount" | head -1 | sed -E 's/^\[[0-9:]+\] [^:]*: //' | cut -c1-280)"
    [[ -n "${_hg}" ]] && _emit_str "headcount_growth_signal_text" "${_hg}" 0.75
    if printf '%s' "${TEXT}" | grep -qiE "(urgent|asap|immediately|yesterday)"; then
      _emit_str "hiring_velocity_band" "urgent" 0.80
    elif printf '%s' "${TEXT}" | grep -qiE "(this quarter|next month|coming weeks)"; then
      _emit_str "hiring_velocity_band" "fast" 0.72
    elif printf '%s' "${TEXT}" | grep -qiE "(next year|no rush|eventually)"; then
      _emit_str "hiring_velocity_band" "slow" 0.72
    fi
    _dw="$(printf '%s\n' "${TEXT}" | grep -iE "decision (by|within|in)" | head -1 | sed -E 's/^\[[0-9:]+\] [^:]*: //' | cut -c1-280)"
    [[ -n "${_dw}" ]] && _emit_str "decision_window_text" "${_dw}" 0.75
    ;;
  *)
    printf 'extract-fields.sh: unknown entity-type %s\n' "${ENTITY_TYPE}" >&2
    exit 2 ;;
esac

jq -sc '.' "${FIELDS_TMP}"
