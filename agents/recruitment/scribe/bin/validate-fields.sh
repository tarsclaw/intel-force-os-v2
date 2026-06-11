#!/usr/bin/env bash
# Scribe — Step 7 / Gate A field-name + type/range validator (single source
# for cycle.sh Step 7 AND validate.sh G-field-names + G-field-types).
#
# Validates a JSON array of {field_name, value, confidence} against the
# SCRIBE-WRITABLE subset of the canonical vertical schema. The allowlist
# below is derived from the SCHEMA FILES (not agent.md prose):
#   docs/verticals/recruitment/vertical-schema.yaml            (v0.1/v0.2 base)
#   docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
# and mirrors the DB-side validate_entities_data_v0_3() trigger constraints
# (enum sets, array caps, vault-path pattern) — verified 2026-06-10.
#
# R-only-for-Scribe fields are EXCLUDED from the writable set per the v0.3 §2
# access matrix: contact.decision_authority, brief.start_date_target.
#
# Output (stdout, single JSON object):
#   { "valid": [ {field_name,value,confidence}, ... ],
#     "dropped": [ {field_name, reason}, ... ],
#     "valid_count": N }
# Exit 0 always (the CALLER enforces the ≥3-valid Gate A bar); exit 2 = usage.
#
# Usage: validate-fields.sh --entity-type <t> --fields-file <json-array path>

set -euo pipefail

ENTITY_TYPE="" FIELDS_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --entity-type) ENTITY_TYPE="${2:-}"; shift 2 ;;
    --fields-file) FIELDS_FILE="${2:-}"; shift 2 ;;
    *) printf 'validate-fields.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done
if [[ -z "${ENTITY_TYPE}" || -z "${FIELDS_FILE}" || ! -f "${FIELDS_FILE}" ]]; then
  printf 'validate-fields.sh: --entity-type and --fields-file <existing file> required\n' >&2
  exit 2
fi
command -v jq >/dev/null 2>&1 || { printf 'validate-fields.sh: jq required\n' >&2; exit 2; }
jq -e 'type=="array"' "${FIELDS_FILE}" >/dev/null 2>&1 || {
  printf 'validate-fields.sh: fields file is not a JSON array\n' >&2; exit 2; }

# Writable-field spec per entity: "field|kind|constraint"
# kinds: str | str280 | num | int | bool | date | enum:<a,b,c> | list:<max> | vaultpath
case "${ENTITY_TYPE}" in
  candidate) SPEC="location|str current_role|str current_employer|str desired_role|str salary_expectation_min|num salary_expectation_max|num willing_to_relocate|bool notice_period_weeks|int employment_type|enum:perm,contract,contract_inside_ir35,contract_outside_ir35,day_rate,hybrid key_skills|list:20" ;;
  contact)   SPEC="preferred_channel|enum:email,phone,sms,teams,slack,in_person,unknown next_action_target_date|date" ;;
  brief)     SPEC="salary_min|num salary_max|num role_type|enum:permanent,contract,temp,retained_search must_haves|list:15 nice_to_haves|list:50 deal_breakers|list:50" ;;
  placement) SPEC="start_date|date placement_status|enum:pending_start,active,completed,terminated_early,on_hold,cancelled week_1_status_vault_path|vaultpath satisfaction_signal|enum:positive,neutral,negative,unclear" ;;
  opportunity) SPEC="headcount_growth_signal_text|str280 hiring_velocity_band|enum:slow,moderate,fast,urgent,unknown decision_window_text|str280" ;;
  *) printf 'validate-fields.sh: unknown entity-type %s\n' "${ENTITY_TYPE}" >&2; exit 2 ;;
esac

VALID_TMP="$(mktemp -t scribe-valid-XXXXXX)"
DROP_TMP="$(mktemp -t scribe-drop-XXXXXX)"
trap 'rm -f "${VALID_TMP}" "${DROP_TMP}"' EXIT
: > "${VALID_TMP}"; : > "${DROP_TMP}"

_drop() { jq -nc --arg f "$1" --arg r "$2" '{field_name:$f,reason:$r}' >> "${DROP_TMP}"; }

while IFS= read -r row; do
  fname="$(jq -r '.field_name // empty' <<<"${row}")"
  if [[ -z "${fname}" ]]; then _drop "(missing)" "no field_name"; continue; fi

  # G-field-names: name must exist in the writable schema subset.
  kind=""
  for entry in ${SPEC}; do
    if [[ "${entry%%|*}" == "${fname}" ]]; then kind="${entry#*|}"; break; fi
  done
  if [[ -z "${kind}" ]]; then
    _drop "${fname}" "not in ${ENTITY_TYPE} writable schema (vertical-schema v0.1+v0.3)"; continue
  fi

  # G-field-types: per-field type + range check.
  ok=1; reason=""
  case "${kind}" in
    str)
      jq -e '.value | type=="string" and length>0' <<<"${row}" >/dev/null 2>&1 || { ok=0; reason="expected non-empty string"; } ;;
    str280)
      jq -e '.value | type=="string" and length>0 and length<=280' <<<"${row}" >/dev/null 2>&1 || { ok=0; reason="expected string ≤280 chars"; } ;;
    num)
      jq -e '.value | type=="number" and . >= 0' <<<"${row}" >/dev/null 2>&1 || { ok=0; reason="expected number ≥0"; } ;;
    int)
      jq -e '.value | type=="number" and . >= 0 and (. == (. | floor))' <<<"${row}" >/dev/null 2>&1 || { ok=0; reason="expected integer ≥0"; } ;;
    bool)
      jq -e '.value | type=="boolean"' <<<"${row}" >/dev/null 2>&1 || { ok=0; reason="expected boolean"; } ;;
    date)
      jq -e '.value | type=="string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")' <<<"${row}" >/dev/null 2>&1 || { ok=0; reason="expected ISO-8601 date (YYYY-MM-DD)"; } ;;
    enum:*)
      allowed="${kind#enum:}"
      val="$(jq -r '.value // empty' <<<"${row}")"
      ok=0; reason="value '${val}' not in enum [${allowed}]"
      IFS=',' read -ra _opts <<<"${allowed}"
      for _o in "${_opts[@]}"; do [[ "${val}" == "${_o}" ]] && { ok=1; reason=""; break; }; done ;;
    list:*)
      maxn="${kind#list:}"
      jq -e --argjson m "${maxn}" '.value | type=="array" and length>0 and length<=$m and all(.[]; type=="string")' <<<"${row}" >/dev/null 2>&1 \
        || { ok=0; reason="expected string array (1..${maxn} items)"; } ;;
    vaultpath)
      # Pattern per v0.3 supplement placement.week_1_status_vault_path (≤200 chars).
      jq -e '.value | type=="string" and length<=200 and test("^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\\.md$")' <<<"${row}" >/dev/null 2>&1 \
        || { ok=0; reason="does not match /vault/<tenant>/scribe-notes/<id>.md pattern"; } ;;
  esac

  if [[ "${ok}" -eq 1 ]]; then
    jq -c '.' <<<"${row}" >> "${VALID_TMP}"
  else
    _drop "${fname}" "${reason}"
  fi
done < <(jq -c '.[]' "${FIELDS_FILE}")

jq -nc --slurpfile v <(jq -sc '.' "${VALID_TMP}") --slurpfile d <(jq -sc '.' "${DROP_TMP}") \
  '{valid: $v[0], dropped: $d[0], valid_count: ($v[0] | length)}'
