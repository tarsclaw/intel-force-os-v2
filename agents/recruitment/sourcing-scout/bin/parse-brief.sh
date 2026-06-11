#!/usr/bin/env bash
# Sourcing Scout — deterministic free-text brief parser (agent.md §4 Step 1).
#
# Extracts the key dimensions (role / location / salary_band / work_mode /
# seniority / sector) from a free-text role description and prints a JSON
# brief object + key_dims count. cycle.sh fires ESC_BRIEF_AMBIGUITY when
# key_dims < 3 (per agent.md §6 + escalation-codes §2.5).
#
# v1.0 scope note (mirrors Cash Conductor's templated-draft fallback): this is
# a DETERMINISTIC keyword/regex extractor so fixtures reproduce without
# network/LLM. LLM parse polish is the documented enhancement — the same JSON
# contract holds when it lands, so cycle.sh doesn't change.
#
# Usage: parse-brief.sh --description "<free text>"
# Output: {"role":...,"location":...,"salary_band":...,"work_mode":...,
#          "seniority":...,"sector":...,"key_dims":N,"source":"deterministic_parse"}

set -euo pipefail

DESCRIPTION=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --description) DESCRIPTION="${2:-}"; shift 2 ;;
    *)             printf 'parse-brief.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done
if [[ -z "${DESCRIPTION}" ]]; then
  printf 'parse-brief.sh: --description required\n' >&2
  exit 2
fi

command -v jq >/dev/null 2>&1 || { printf 'parse-brief.sh: jq required\n' >&2; exit 2; }

_lc="$(printf '%s' "${DESCRIPTION}" | tr '[:upper:]' '[:lower:]')"

# Role: first comma-separated segment when it contains letters (the UK-agency
# convention "Senior React Engineer, London, £120k, hybrid" leads with role).
ROLE="$(printf '%s' "${DESCRIPTION}" | cut -d',' -f1 | sed 's/^ *//; s/ *$//')"
[[ "${ROLE}" =~ [A-Za-z] ]] || ROLE=""

# Location: match against the common UK recruitment-market cities + "remote".
LOCATION=""
for _city in london manchester birmingham leeds bristol glasgow edinburgh \
             liverpool newcastle sheffield cardiff belfast nottingham reading \
             cambridge oxford brighton milton\ keynes; do
  if printf '%s' "${_lc}" | grep -qw "${_city}"; then
    LOCATION="$(printf '%s' "${_city}" | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2)}}1')"
    break
  fi
done
if [[ -z "${LOCATION}" ]] && printf '%s' "${_lc}" | grep -qw "remote"; then
  LOCATION="Remote (UK)"
fi

# Salary band: £NNNk / £NN,NNN / NNNk forms; capture range when present.
SALARY_BAND="$(printf '%s' "${DESCRIPTION}" \
  | grep -oE '£[0-9]+([,.][0-9]+)?k?([[:space:]]*[-–][[:space:]]*£?[0-9]+([,.][0-9]+)?k?)?' \
  | head -1 || true)"
if [[ -z "${SALARY_BAND}" ]]; then
  SALARY_BAND="$(printf '%s' "${_lc}" | grep -oE '[0-9]{2,3}k' | head -1 || true)"
fi

# Work mode keyword.
WORK_MODE=""
for _wm in hybrid remote onsite on-site office-based; do
  if printf '%s' "${_lc}" | grep -qw "${_wm}"; then WORK_MODE="${_wm}"; break; fi
done

# Seniority keyword.
SENIORITY=""
for _sn in senior junior lead principal head mid-level graduate; do
  if printf '%s' "${_lc}" | grep -qw "${_sn}"; then SENIORITY="${_sn}"; break; fi
done

# Sector keyword (UK recruitment verticals).
SECTOR=""
for _sc in fintech healthcare legal construction engineering education retail \
           logistics pharma energy insurance banking; do
  if printf '%s' "${_lc}" | grep -qw "${_sc}"; then SECTOR="${_sc}"; break; fi
done

KEY_DIMS=0
for _v in "${ROLE}" "${LOCATION}" "${SALARY_BAND}" "${WORK_MODE}" "${SENIORITY}" "${SECTOR}"; do
  [[ -n "${_v}" ]] && KEY_DIMS=$((KEY_DIMS + 1))
done

jq -n \
  --arg role "${ROLE}" --arg location "${LOCATION}" --arg salary "${SALARY_BAND}" \
  --arg work_mode "${WORK_MODE}" --arg seniority "${SENIORITY}" --arg sector "${SECTOR}" \
  --argjson dims "${KEY_DIMS}" \
  '{role: $role, location: $location, salary_band: $salary, work_mode: $work_mode,
    seniority: $seniority, sector: $sector, key_dims: $dims,
    source: "deterministic_parse"}'
