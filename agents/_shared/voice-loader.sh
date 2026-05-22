#!/usr/bin/env bash
#
# IFOS voice-loader — implements the 3 hh_load_* helpers per master brief
# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
# voice corpus, tone rules, and recent edits into the agent's context bundle.
#
# Requires:
#   - vertical-schema.v0.2-supplement.yaml schema migrated (Phase 4 SQL)
#   - IFOS_DB_URL set + psql on PATH for live queries
#   - Falls back to /vault/<tenant>/_voice/ markdown files if DB unavailable
#
# Helpers (3):
#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
#   hh_load_recent_edits   — query recent_edit for last N days
#
# Each helper writes its result to stdout as a single JSON document. Caller
# (context.sh) typically pipes into `jq` to inject into context bundle.
#
# shellcheck shell=bash

set -uo pipefail

_VL_VERSION="0.1.0"
_VL_HELPERS_PATH="${_VL_HELPERS_PATH:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/hook-helpers.sh}"

# Try to source hook-helpers.sh so we can _hh_json_escape + _hh_emit_row
# (helpers may not be loaded yet if voice-loader is called standalone).
if [[ -z "${_HH_HELPERS_VERSION:-}" ]] && [[ -f "${_VL_HELPERS_PATH}" ]]; then
  # shellcheck source=/dev/null
  source "${_VL_HELPERS_PATH}"
fi

# Minimal fallback if hook-helpers.sh wasn't loadable (e.g. running standalone
# in tests). Functions here mirror the helpers' behaviour with no DB writes.
if ! declare -f _hh_json_escape >/dev/null 2>&1; then
  _hh_json_escape() {
    local input="$1"
    input="${input//\\/\\\\}"
    input="${input//\"/\\\"}"
    input="${input//$'\n'/\\n}"
    input="${input//$'\r'/\\r}"
    input="${input//$'\t'/\\t}"
    printf '%s' "${input}"
  }
fi

# ────────────────────────────────────────────────────────────────────────
# Internal: Postgres query helpers
# ────────────────────────────────────────────────────────────────────────

# Returns 0 if live DB mode is available, 1 if fallback should be used.
_vl_db_available() {
  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

# _vl_psql_query <SQL> → stdout (rows), or empty on failure
_vl_psql_query() {
  local sql="$1"
  local tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
  local wrapped
  wrapped="BEGIN;
SET LOCAL app.current_tenant = '$(_hh_json_escape "${tenant}")';
${sql}
COMMIT;"
  psql -v ON_ERROR_STOP=1 -q -t -A -F $'\t' "${IFOS_DB_URL}" <<<"${wrapped}" 2>/dev/null
}

# ────────────────────────────────────────────────────────────────────────
# hh_load_tone_rules [<agent_name>]
# ────────────────────────────────────────────────────────────────────────
# Returns active tone_rule rows filtered to agent_name (or all rules if
# agent_name absent). JSON shape:
#   { "rules": [ { "rule_id":..., "rule_text":..., "severity":...,
#                  "examples_positive":[...], "examples_negative":[...] }, ... ] }
hh_load_tone_rules() {
  local agent_name="${1:-${CTX_AGENT_NAME:-}}"

  if _vl_db_available; then
    local sql
    if [[ -n "${agent_name}" ]]; then
      sql="SELECT rule_id, rule_text, severity, COALESCE(examples_positive, '{}'), COALESCE(examples_negative, '{}')
           FROM tone_rule
           WHERE enabled = TRUE
             AND (cardinality(applies_to_agents) = 0 OR '$(_hh_json_escape "${agent_name}")' = ANY(applies_to_agents))
           ORDER BY severity DESC, rule_id ASC;"
    else
      sql="SELECT rule_id, rule_text, severity, COALESCE(examples_positive, '{}'), COALESCE(examples_negative, '{}')
           FROM tone_rule
           WHERE enabled = TRUE
           ORDER BY severity DESC, rule_id ASC;"
    fi
    local rows
    rows="$(_vl_psql_query "${sql}")"
    _vl_render_tone_rules_json "${rows}"
    return 0
  fi

  # Fallback: read /vault/<tenant>/_voice/tone-rules.yaml
  local fallback_file="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/_voice/tone-rules.yaml"
  if [[ -f "${fallback_file}" ]]; then
    printf '{"rules":[],"source":"fallback","fallback_path":"%s","note":"DB unavailable; YAML fallback not yet parsed in v0.1 — caller should read file directly"}\n' \
      "$(_hh_json_escape "${fallback_file}")"
    return 0
  fi
  printf '{"rules":[],"source":"empty","reason":"db_unavailable_and_no_fallback_file"}\n'
}

# Internal: convert TSV rows from psql into JSON.
_vl_render_tone_rules_json() {
  local rows="$1"
  if [[ -z "${rows}" ]]; then
    printf '{"rules":[],"source":"db","count":0}\n'
    return 0
  fi
  printf '{"rules":['
  local first=1
  while IFS=$'\t' read -r rule_id rule_text severity examples_pos examples_neg; do
    [[ -z "${rule_id}" ]] && continue
    if (( first )); then first=0; else printf ','; fi
    printf '{"rule_id":"%s","rule_text":"%s","severity":"%s","examples_positive":"%s","examples_negative":"%s"}' \
      "$(_hh_json_escape "${rule_id}")" \
      "$(_hh_json_escape "${rule_text}")" \
      "$(_hh_json_escape "${severity}")" \
      "$(_hh_json_escape "${examples_pos}")" \
      "$(_hh_json_escape "${examples_neg}")"
  done <<<"${rows}"
  printf '],"source":"db"}\n'
}

# ────────────────────────────────────────────────────────────────────────
# hh_load_voice_samples <task_context> [<top_k>]
# ────────────────────────────────────────────────────────────────────────
# Runs pgvector ANN against voice_corpus_chunks for the active voice_corpus
# pack. Requires task_context to be embedded externally and supplied as a
# vector literal via IFOS_VL_QUERY_VECTOR env var (because shell can't
# generate embeddings). Callers from Python/Node embed first, then exec
# voice-loader with the literal vector pre-encoded.
#
# Falls back to /vault/<tenant>/_voice/style-guide.md when DB or query vector
# unavailable (returns the style guide path; agent reads directly).
#
# Output JSON shape:
#   { "samples": [ { "chunk_index": N, "text_chunk": "...",
#                    "source_doc_ref": "...", "distance": 0.123 }, ... ],
#     "voice_corpus_version": "v0.2-seed",
#     "source": "db" | "fallback" }
hh_load_voice_samples() {
  local task_context="${1:-}"
  local top_k="${2:-10}"

  # Validate top_k
  if ! [[ "${top_k}" =~ ^[0-9]+$ ]] || (( top_k <= 0 )) || (( top_k > 50 )); then
    top_k=10
  fi

  if _vl_db_available && [[ -n "${IFOS_VL_QUERY_VECTOR:-}" ]]; then
    # Live mode: run HNSW ANN query against active voice_corpus
    local sql
    sql="SELECT vcc.chunk_index, vcc.text_chunk, COALESCE(vcc.source_doc_ref, ''), (vcc.embedding <=> '${IFOS_VL_QUERY_VECTOR}'::vector) AS distance
         FROM voice_corpus_chunks vcc
         JOIN voice_corpus vc ON vc.id = vcc.voice_corpus_id
         WHERE vc.is_active = TRUE
         ORDER BY vcc.embedding <=> '${IFOS_VL_QUERY_VECTOR}'::vector
         LIMIT ${top_k};"
    local rows
    rows="$(_vl_psql_query "${sql}")"
    local version
    version="$(_vl_psql_query "SELECT version FROM voice_corpus WHERE is_active = TRUE LIMIT 1;")"
    _vl_render_voice_samples_json "${rows}" "${version:-unknown}" "db" "${task_context}"
    return 0
  fi

  # Fallback: return style guide path
  local style_guide="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/_voice/style-guide.md"
  if [[ -f "${style_guide}" ]]; then
    printf '{"samples":[],"voice_corpus_version":"fallback","source":"fallback","style_guide_path":"%s","task_context":"%s","reason":"%s"}\n' \
      "$(_hh_json_escape "${style_guide}")" \
      "$(_hh_json_escape "${task_context}")" \
      "$([[ -z "${IFOS_VL_QUERY_VECTOR:-}" ]] && printf 'no_query_vector' || printf 'db_unavailable')"
    return 0
  fi
  printf '{"samples":[],"voice_corpus_version":"empty","source":"empty","task_context":"%s","reason":"no_db_no_style_guide"}\n' \
    "$(_hh_json_escape "${task_context}")"
}

# Internal: render psql TSV → JSON for voice samples.
_vl_render_voice_samples_json() {
  local rows="$1"
  local version="$2"
  local source="$3"
  local task_context="$4"

  if [[ -z "${rows}" ]]; then
    printf '{"samples":[],"voice_corpus_version":"%s","source":"%s","task_context":"%s","count":0}\n' \
      "$(_hh_json_escape "${version}")" \
      "$(_hh_json_escape "${source}")" \
      "$(_hh_json_escape "${task_context}")"
    return 0
  fi

  printf '{"samples":['
  local first=1
  while IFS=$'\t' read -r chunk_index text_chunk source_doc_ref distance; do
    [[ -z "${chunk_index}" ]] && continue
    if (( first )); then first=0; else printf ','; fi
    printf '{"chunk_index":%s,"text_chunk":"%s","source_doc_ref":"%s","distance":%s}' \
      "${chunk_index}" \
      "$(_hh_json_escape "${text_chunk}")" \
      "$(_hh_json_escape "${source_doc_ref}")" \
      "${distance}"
  done <<<"${rows}"
  printf '],"voice_corpus_version":"%s","source":"%s","task_context":"%s"}\n' \
    "$(_hh_json_escape "${version}")" \
    "$(_hh_json_escape "${source}")" \
    "$(_hh_json_escape "${task_context}")"
}

# ────────────────────────────────────────────────────────────────────────
# hh_load_recent_edits [<lookback_days>] [<agent_name>]
# ────────────────────────────────────────────────────────────────────────
# Returns recent_edit rows from the last <lookback_days> for <agent_name>
# (or all agents if not specified).
#
# Output JSON shape:
#   { "edits": [ { "id": N, "action_type": "...", "edit_distance": N,
#                  "resolution": "...", "tone_rules_triggered": [...],
#                  "resolved_at": "..." }, ... ],
#     "lookback_days": N, "source": "db" | "fallback" }
hh_load_recent_edits() {
  local lookback_days="${1:-30}"
  local agent_name="${2:-${CTX_AGENT_NAME:-}}"

  # Validate lookback_days
  if ! [[ "${lookback_days}" =~ ^[0-9]+$ ]] || (( lookback_days <= 0 )) || (( lookback_days > 365 )); then
    lookback_days=30
  fi

  if _vl_db_available; then
    local sql
    if [[ -n "${agent_name}" ]]; then
      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
           FROM recent_edit
           WHERE agent_name = '$(_hh_json_escape "${agent_name}")'
             AND resolved_at > now() - interval '${lookback_days} days'
           ORDER BY resolved_at DESC
           LIMIT 200;"
    else
      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
           FROM recent_edit
           WHERE resolved_at > now() - interval '${lookback_days} days'
           ORDER BY resolved_at DESC
           LIMIT 200;"
    fi
    local rows
    rows="$(_vl_psql_query "${sql}")"
    _vl_render_recent_edits_json "${rows}" "${lookback_days}"
    return 0
  fi

  printf '{"edits":[],"lookback_days":%s,"source":"fallback","reason":"db_unavailable"}\n' "${lookback_days}"
}

# Internal: render psql TSV → JSON for recent edits.
_vl_render_recent_edits_json() {
  local rows="$1"
  local lookback_days="$2"

  if [[ -z "${rows}" ]]; then
    printf '{"edits":[],"lookback_days":%s,"source":"db","count":0}\n' "${lookback_days}"
    return 0
  fi

  printf '{"edits":['
  local first=1
  while IFS=$'\t' read -r id action_type edit_distance resolution tone_rules resolved_at; do
    [[ -z "${id}" ]] && continue
    if (( first )); then first=0; else printf ','; fi
    printf '{"id":%s,"action_type":"%s","edit_distance":%s,"resolution":"%s","tone_rules_triggered":"%s","resolved_at":"%s"}' \
      "${id}" \
      "$(_hh_json_escape "${action_type}")" \
      "$([[ -z "${edit_distance}" ]] && echo "null" || echo "${edit_distance}")" \
      "$(_hh_json_escape "${resolution}")" \
      "$(_hh_json_escape "${tone_rules}")" \
      "$(_hh_json_escape "${resolved_at}")"
  done <<<"${rows}"
  printf '],"lookback_days":%s,"source":"db"}\n' "${lookback_days}"
}

# Exported so tests can introspect.
export _VL_VERSION
