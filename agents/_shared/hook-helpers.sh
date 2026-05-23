#!/usr/bin/env bash
#
# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
#
# Sourced by every rendered agent's .claude/hooks/validate.sh and
# .claude/hooks/context.sh via the per-tenant `_shared/` symlink resolved at
# render time (ADR-003 §3.3.3 Option γ).
#
# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
# Offline-mode writes:     JSON-line append to $IFOS_DECISION_LOG_FALLBACK
#                          (defaults to /vault/<tenant>/decision-log.jsonl)
#
# The dual-mode design means: agents in degraded mode (Hetzner unreachable)
# still produce an audit trail; the trail replays into Postgres when
# connectivity returns. See agents/_shared/README.md §"Degraded mode".
#
# Shellcheck-clean: this file passes `shellcheck -s bash -S style`.
# Side-effects: appends to decision_log table OR fallback JSONL; never reads
# raw PII into shell vars (payload_preview must be sanitised by caller).

# shellcheck shell=bash

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Internal: paths, table names, sanity guards
# ────────────────────────────────────────────────────────────────────────

_HH_HELPERS_VERSION="0.1.0"
_HH_POLICY_FILE="${HH_POLICY_FILE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/autosend-policy.yaml}"
_HH_ESC_CATALOGUE="${HH_ESC_CATALOGUE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/escalation-codes.md}"

# Fallback file used when IFOS_DB_URL is unset OR psql is unavailable.
# Resolved at first call to _hh_emit_row().
_hh_resolve_fallback_path() {
  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
    return 0
  fi
  local tenant="${CTX_TENANT_SLUG:-unknown}"
  local vault_root="${IFOS_VAULT_ROOT:-/vault}"
  printf '%s/%s/decision-log.jsonl' "${vault_root}" "${tenant}"
}

# JSON escape a single string for inclusion in a JSON value.
# Use this when BUILDING a JSON document from plain text.
_hh_json_escape() {
  local input="$1"
  input="${input//\\/\\\\}"
  input="${input//\"/\\\"}"
  input="${input//$'\n'/\\n}"
  input="${input//$'\r'/\\r}"
  input="${input//$'\t'/\\t}"
  printf '%s' "${input}"
}

# SQL escape a string for inclusion in a single-quoted SQL string literal.
# Use this when EMBEDDING values in psql SQL. Doubles single quotes;
# leaves everything else (incl. backslashes, JSON internal " characters)
# alone — Postgres standard_conforming_strings=on (default since 9.1)
# treats backslash as literal.
_hh_sql_escape() {
  local input="$1"
  printf '%s' "${input//\'/\'\'}"
}

# Current ISO-8601 UTC timestamp with millisecond precision.
_hh_now_iso() {
  if date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" >/dev/null 2>&1; then
    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
  else
    # macOS BSD date lacks %3N; fall back to whole seconds.
    date -u +"%Y-%m-%dT%H:%M:%SZ"
  fi
}

# Validate that ESC code exists in the catalogue.
# Returns 0 if known, 1 otherwise. Catalogue absent → permissive (return 0).
_hh_validate_esc_code() {
  local code="$1"
  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
    return 0
  fi
  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then
    return 0
  fi
  return 1
}

# ────────────────────────────────────────────────────────────────────────
# Core decision-log writer
# ────────────────────────────────────────────────────────────────────────

# _hh_emit_row <phase> <outcome> <reason> <payload_json>
#
# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
# INSERT via psql -v ON_ERROR_STOP=1. Offline mode: append JSON line to
# fallback file. The two formats are reconcilable by the sync worker.
_hh_emit_row() {
  local phase="$1"
  local outcome="${2:-}"
  local reason="${3:-}"
  local payload_json="${4:-{\}}"

  local tenant agent created_at
  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
  agent="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
  created_at="$(_hh_now_iso)"

  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    local sql
    sql=$(cat <<EOF
BEGIN;
SET LOCAL app.current_tenant = '$(_hh_sql_escape "${tenant}")';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
VALUES (
  '$(_hh_sql_escape "${tenant}")',
  '$(_hh_sql_escape "${agent}")',
  '$(_hh_sql_escape "${phase}")',
  $([ -z "${outcome}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${outcome}")"),
  $([ -z "${reason}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${reason}")"),
  '$(_hh_sql_escape "${payload_json}")'::jsonb,
  '${created_at}'::timestamptz
);
COMMIT;
EOF
)
    local psql_err
    psql_err=$(printf '%s\n' "${sql}" | psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" 2>&1)
    if [[ $? -eq 0 ]]; then
      return 0
    fi
    # psql failed — fall through to fallback append + emit warning to stderr
    printf 'hh_emit_row: psql write failed; appending to fallback\n' >&2
    printf 'hh_emit_row: psql error: %s\n' "${psql_err}" >&2
  fi

  local fallback
  fallback="$(_hh_resolve_fallback_path)"
  mkdir -p "$(dirname "${fallback}")" 2>/dev/null || true

  local row
  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
    "$(_hh_json_escape "${tenant}")" \
    "$(_hh_json_escape "${agent}")" \
    "$(_hh_json_escape "${phase}")" \
    "$([ -z "${outcome}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${outcome}")")" \
    "$([ -z "${reason}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason}")")" \
    "${payload_json}" \
    "${created_at}" \
    "${_HH_HELPERS_VERSION}")

  printf '%s\n' "${row}" >> "${fallback}"
}

# ────────────────────────────────────────────────────────────────────────
# 3 hh_decision_* contracts (master brief §8.1 Change 2)
# ────────────────────────────────────────────────────────────────────────

# hh_decision_trigger <trigger_type> [<reason>]
# Writes phase='trigger' row at session start. Required first call of every run.
hh_decision_trigger() {
  local trigger_type="${1:-session_start}"
  local reason="${2:-}"
  local payload
  payload=$(printf '{"trigger_type":"%s","helpers_version":"%s"}' \
    "$(_hh_json_escape "${trigger_type}")" "${_HH_HELPERS_VERSION}")
  _hh_emit_row "trigger" "" "${reason}" "${payload}"
}

# hh_decision_output <output_type> <artefact_ref> [<reason>]
# Writes phase='output' row per artefact produced. Required before producing
# a customer-visible artefact (Gate B per master brief §1 Rule 4).
hh_decision_output() {
  local output_type="$1"
  local artefact_ref="$2"
  local reason="${3:-}"
  local payload
  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
    "$(_hh_json_escape "${output_type}")" "$(_hh_json_escape "${artefact_ref}")")
  _hh_emit_row "output" "produced" "${reason}" "${payload}"
}

# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
# Writes phase='action' or phase='gating_failed' row depending on tier.
# Returns 0 if action allowed; 1 if blocked or approval rejected.
hh_decision_action() {
  local action_type="$1"
  local target="$2"
  local payload_hash="$3"
  local payload_preview="$4"

  local tenant tier
  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"

  if ! tier=$(autosend_policy_lookup "${action_type}"); then
    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
      "${target}" "${payload_hash}" "unknown_action_type"
    return 1
  fi

  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
      "${target}" "${payload_hash}" "override_resolution_failed"
    return 1
  fi

  case "${tier}" in
    green)
      autosend_emit_decision_log "action" "green" "${action_type}" \
        "${target}" "${payload_hash}" "${payload_preview}" ""
      return 0
      ;;
    yellow)
      autosend_emit_decision_log "action" "yellow" "${action_type}" \
        "${target}" "${payload_hash}" "${payload_preview}" ""
      if autosend_should_sample "${action_type}" "${tenant}"; then
        autosend_spot_check_enqueue "${action_type}" "${target}" \
          "${payload_hash}" "${payload_preview}" "${tenant}"
      fi
      return 0
      ;;
    orange)
      autosend_emit_decision_log "action" "orange" "${action_type}" \
        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
        "${target}" "${payload_hash}" "${payload_preview}"
      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
      return $?
      ;;
    red)
      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
        "${target}" "${payload_hash}" "red_tier_classification"
      return 1
      ;;
    *)
      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
        "${target}" "${payload_hash}" "unknown_tier:${tier}"
      return 1
      ;;
  esac
}

# ────────────────────────────────────────────────────────────────────────
# 7 autosend_* helpers (autosend-safety-policy §4)
# ────────────────────────────────────────────────────────────────────────

# autosend_policy_lookup <action_type>
# Prints the tier (green|yellow|orange|red) to stdout; returns 0 if found,
# 1 if action_type missing from policy file.
autosend_policy_lookup() {
  local action_type="$1"
  if [[ ! -f "${_HH_POLICY_FILE}" ]]; then
    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
    return 1
  fi
  # YAML lookup via awk — finds the action_type key, then reads tier:
  # one line below. Safer than yq/python deps at agent runtime.
  local tier
  tier=$(awk -v key="${action_type}" '
    $0 ~ "^  " key ":" { in_block = 1; next }
    in_block && /^    tier: / { sub(/^    tier: /, ""); print; exit }
    in_block && /^  [a-z]/ { in_block = 0 }
  ' "${_HH_POLICY_FILE}")
  if [[ -z "${tier}" ]]; then
    return 1
  fi
  printf '%s' "${tier}"
}

# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
# Tenants can ELEVATE only (green→yellow→orange→red); red is the floor.
autosend_apply_tenant_override() {
  local base_tier="$1"
  local action_type="$2"
  local tenant_slug="$3"

  # Red is absolute — no override possible.
  if [[ "${base_tier}" == "red" ]]; then
    printf '%s' "red"
    return 0
  fi

  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
  if [[ ! -f "${override_file}" ]]; then
    printf '%s' "${base_tier}"
    return 0
  fi

  local override
  override=$(awk -v key="${action_type}" '
    $0 ~ "^  " key ":" { sub(/^  [^:]+: */, ""); print; exit }
  ' "${override_file}")

  if [[ -z "${override}" ]]; then
    printf '%s' "${base_tier}"
    return 0
  fi

  # Enforce elevation-only ordering.
  local base_rank override_rank
  case "${base_tier}" in green) base_rank=0;; yellow) base_rank=1;; orange) base_rank=2;; red) base_rank=3;; *) return 1;; esac
  case "${override}" in green) override_rank=0;; yellow) override_rank=1;; orange) override_rank=2;; red) override_rank=3;; *) return 1;; esac

  if (( override_rank < base_rank )); then
    printf 'autosend_apply_tenant_override: refusing to demote %s → %s for %s/%s\n' \
      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
    return 1
  fi
  printf '%s' "${override}"
}

# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
# Emits the standard autosend decision_log row with payload.tier set.
autosend_emit_decision_log() {
  local phase="$1"
  local tier="$2"
  local action_type="$3"
  local target="$4"
  local payload_hash="$5"
  local payload_preview="$6"
  local reason_or_status="${7:-}"

  local payload
  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
    "$(_hh_json_escape "${tier}")" \
    "$(_hh_json_escape "${action_type}")" \
    "$(_hh_json_escape "${target}")" \
    "$(_hh_json_escape "${payload_hash}")" \
    "$(_hh_json_escape "${payload_preview}")" \
    "$([ -z "${reason_or_status}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason_or_status}")")" \
    "$([ "${tier}" = "red" ] || [ "${tier}" = "fail-safe-red" ] && printf '"%s"' "$(_hh_json_escape "${reason_or_status}")" || echo "null")" \
    "${HH_POLICY_VERSION_SHA:-unknown}")
  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
}

# autosend_escalate <ESC_CODE> [<key=value>...]
# Writes the ESC row + dispatches Telegram via primitive-5 helper. Catalogue
# lookup is permissive — unknown codes are emitted with phase='gating_failed'
# + ESC_AUTOSEND_POLICY_LOOKUP_FAILED meta-escalation.
autosend_escalate() {
  local code="$1"
  shift

  if ! _hh_validate_esc_code "${code}"; then
    printf 'autosend_escalate: unknown ESC code: %s\n' "${code}" >&2
    local meta_payload
    meta_payload=$(printf '{"unknown_code":"%s","helpers_version":"%s"}' \
      "$(_hh_json_escape "${code}")" "${_HH_HELPERS_VERSION}")
    _hh_emit_row "gating_failed" "fail-safe-red" "esc_code_unknown" "${meta_payload}"
    return 1
  fi

  local escaped_code
  escaped_code="$(_hh_json_escape "${code}")"
  local payload="{\"escalation_code\":\"${escaped_code}\""
  local arg
  for arg in "$@"; do
    if [[ "${arg}" == *"="* ]]; then
      local k="${arg%%=*}"
      local v="${arg#*=}"
      payload+=",\"$(_hh_json_escape "${k}")\":\"$(_hh_json_escape "${v}")\""
    fi
  done
  payload+="}"

  _hh_emit_row "gating_failed" "${code}" "" "${payload}"

  # Telegram dispatch is a separate primitive — for v0.1 the row is the
  # signal. Dispatcher (autosend-syncer) reads recent gating_failed rows and
  # routes to operator chat per common-notifications.json.
}

# autosend_should_sample <action_type> <tenant_slug>
# Returns 0 if this invocation should produce a spot-check (1-in-N draw);
# 1 otherwise. Sample rate read from autosend-policy.yaml (sample_rate field);
# tenant override via tenant_adapters.config.sampling_rates.
autosend_should_sample() {
  local action_type="$1"
  # tenant_slug reserved for future per-tenant rate override; currently unused
  local rate
  rate=$(awk -v key="${action_type}" '
    $0 ~ "^  " key ":" { in_block = 1; next }
    in_block && /^    sample_rate: / { sub(/^    sample_rate: /, ""); print; exit }
    in_block && /^  [a-z]/ { in_block = 0 }
  ' "${_HH_POLICY_FILE}")

  if [[ -z "${rate}" || ! "${rate}" =~ ^[0-9]+$ || "${rate}" -le 0 ]]; then
    return 1
  fi

  local draw
  draw=$(( RANDOM % rate ))
  if (( draw == 0 )); then
    return 0
  fi
  return 1
}

# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
# Writes spot-check artefact under /vault/<tenant>/spot-checks/ for operator
# review. Idempotent on payload_hash — duplicate enqueues become single file.
autosend_spot_check_enqueue() {
  local action_type="$1"
  local target="$2"
  local payload_hash="$3"
  local payload_preview="$4"
  local tenant_slug="$5"

  local spot_dir="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/spot-checks"
  mkdir -p "${spot_dir}" 2>/dev/null || {
    printf 'autosend_spot_check_enqueue: cannot mkdir %s\n' "${spot_dir}" >&2
    return 1
  }

  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H%M%SZ")"
  local outfile="${spot_dir}/${timestamp}-${action_type}-${payload_hash:0:12}.md"

  if [[ -f "${outfile}" ]]; then
    return 0
  fi

  {
    printf '# Spot check — %s\n\n' "${action_type}"
    printf -- '- **Tenant:** %s\n' "${tenant_slug}"
    printf -- '- **Agent:** %s\n' "${CTX_AGENT_NAME:-unknown}"
    printf -- '- **Target:** %s\n' "${target}"
    printf -- '- **Payload hash:** %s\n' "${payload_hash}"
    printf -- '- **Timestamp:** %s\n\n' "${timestamp}"
    printf '## Preview\n\n%s\n' "${payload_preview}"
  } > "${outfile}"
}

# autosend_await_approval <action_type> <target> <payload_hash>
# Blocks until cortextOS approval gate resolves OR timeout fires.
# Returns 0 on approval, 1 on rejection or timeout-rejection.
#
# v0.1 implementation: writes pending-approval marker to vault + polls.
# v1.1 will integrate with cortextOS primitive 4 directly (out-of-band signal).
autosend_await_approval() {
  local action_type="$1"
  local target="$2"
  local payload_hash="$3"

  local timeout_iso
  timeout_iso=$(awk -v key="${action_type}" '
    $0 ~ "^  " key ":" { in_block = 1; next }
    in_block && /^    timeout: / { sub(/^    timeout: /, ""); print; exit }
    in_block && /^  [a-z]/ { in_block = 0 }
  ' "${_HH_POLICY_FILE}")
  timeout_iso="${timeout_iso:-PT4H}"

  # Convert ISO-8601 duration to seconds (supports PT<N>{M|H|S}; trivial parser).
  local timeout_s=14400  # 4h default
  if [[ "${timeout_iso}" =~ ^PT([0-9]+)S$ ]]; then
    timeout_s="${BASH_REMATCH[1]}"
  elif [[ "${timeout_iso}" =~ ^PT([0-9]+)M$ ]]; then
    timeout_s=$(( BASH_REMATCH[1] * 60 ))
  elif [[ "${timeout_iso}" =~ ^PT([0-9]+)H$ ]]; then
    timeout_s=$(( BASH_REMATCH[1] * 3600 ))
  fi

  local tenant="${CTX_TENANT_SLUG:?}"
  local pending_dir="${IFOS_VAULT_ROOT:-/vault}/${tenant}/pending-approvals"
  mkdir -p "${pending_dir}" 2>/dev/null || true
  local marker="${pending_dir}/${payload_hash}.pending"
  local approved="${pending_dir}/${payload_hash}.approved"
  local rejected="${pending_dir}/${payload_hash}.rejected"

  {
    printf 'action_type=%s\n' "${action_type}"
    printf 'target=%s\n' "${target}"
    printf 'payload_hash=%s\n' "${payload_hash}"
    printf 'pending_since=%s\n' "$(_hh_now_iso)"
    printf 'timeout_seconds=%s\n' "${timeout_s}"
  } > "${marker}"

  # Test-mode short-circuit: HH_AWAIT_TEST_MODE skips real polling so unit
  # tests don't block. Values: "approve"|"reject"|"timeout".
  if [[ -n "${HH_AWAIT_TEST_MODE:-}" ]]; then
    case "${HH_AWAIT_TEST_MODE}" in
      approve)
        rm -f "${marker}"
        printf 'approved at %s\n' "$(_hh_now_iso)" > "${approved}"
        return 0
        ;;
      reject)
        rm -f "${marker}"
        printf 'rejected at %s\n' "$(_hh_now_iso)" > "${rejected}"
        return 1
        ;;
      timeout|*)
        rm -f "${marker}"
        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
          "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"
        return 1
        ;;
    esac
  fi

  # Production poll loop. Sleep step grows from 5s to 60s. Caller's PTY is
  # preserved by primitive 1 even if the agent process blocks indefinitely.
  local elapsed=0
  local step=5
  while (( elapsed < timeout_s )); do
    if [[ -f "${approved}" ]]; then
      return 0
    fi
    if [[ -f "${rejected}" ]]; then
      return 1
    fi
    sleep "${step}"
    elapsed=$(( elapsed + step ))
    if (( step < 60 )); then
      step=$(( step * 2 ))
      (( step > 60 )) && step=60
    fi
  done

  # Timed out — convert to ESC_AUTOSEND_NEEDS_REVIEW with timeout marker.
  rm -f "${marker}"
  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
    "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"
  return 1
}

# ────────────────────────────────────────────────────────────────────────
# Self-test helpers (invoked by tests/test-hook-helpers.sh)
# ────────────────────────────────────────────────────────────────────────

# Exported so tests can introspect.
export _HH_HELPERS_VERSION
