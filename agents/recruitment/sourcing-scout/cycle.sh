#!/usr/bin/env bash
# Sourcing Scout agent — cycle.sh (11-step per-brief orchestration; W9 LIVE)
#
# Status: LIVE per spec-003 §4 (W9 build slice).
# Reading order: agent.md §1 (output contract) + §3 (Markdown report shape) +
#         §4 (this workflow's 11 steps) + §5 (Gate A + Gate B) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# v1.0 source disposition (spec-003 §8 honest scope):
#   Bullhorn  — READ-ONLY agent; creds EMPTY today → per-source degraded-skip
#               (ESC_BULLHORN_AUTH; never faked). Live path wired behind the
#               @ifos/bullhorn CLI surface (lands with creds).
#   LinkedIn  — NO-OP at v1.0 (Proxycurl shut down 2025; vendor selection
#               deferred to v1.1+). Step 4 emits an explicit no-op audit row.
#   Reed      — creds EMPTY today → degraded-skip (ESC_REED_AUTH).
#   CV-Library— the live source. Wired through @ifos/cv-library dist/cli.js
#               search-candidates; the orchestrator runs the live smoke
#               post-build. Fixture override (IFOS_SCOUT_FIXTURE_CVLIBRARY)
#               keeps every test deterministic without network/LLM.
#
# Source-abstraction layer (ULTRAPLAN A5 line 555 gotcha): Steps 3/5/6 all go
# through ONE _scout_query_source() path over per-source mapping config; the
# downstream aggregate/dedupe/rank/report logic is source-agnostic. Night
# Sourcer (v1.1) reuses this shape.
#
# Deterministic test hooks (fixtures; documented, never used in production):
#   IFOS_SCOUT_FIXTURE_BULLHORN / _REED / _CVLIBRARY — path to a JSON file
#       carrying a unified-candidate array (or {ok, candidates}) for that
#       source; marks the source live for the run without network.
#   IFOS_SCOUT_FORCE_429_<SOURCE> = 1 — simulate a 429 on an otherwise-live
#       source (ESC_RATE_LIMIT_HIT route; degraded cached_only).
#   IFOS_SCOUT_FORCE_VOICE_SCORE — numeric voice score override for the Step 9
#       voice-drift drop route (no classifier exists yet; corpus-empty runs
#       record unscored/no_corpus, never a faked number).
#
# Invocation modes (per agent.md §2):
#   mode=brain-ui | telegram | cli (default)  — take --brief-id OR --description
#   mode=webhook — DEFERRED to v1.1+ (auto_source_on_brief_create not allowlisted)
#
# Output contract per agent.md §1 (READ THAT FIRST). One output per brief:
#   Markdown report → /vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO>.md
#   with ranked 5-15 candidates + per-candidate ≥50-word rationale +
#   source breakdown + diagnostic exception list. Gate A failure → partial
#   draft held at /tmp + exit 1 BEFORE the scout_report row.

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: hydrate context + resolve _shared/ helpers
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'sourcing-scout/cycle.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'sourcing-scout/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=sourcing-scout}"
export CTX_AGENT_NAME CTX_AGENT_DIR CTX_TENANT_SLUG   # inherited by validate.sh subprocess (Step 10)

command -v jq >/dev/null 2>&1 || { printf 'cycle.sh: jq required\n' >&2; exit 2; }

# Resolve _shared/ helpers (4-candidate chain per smoke-hotfix commit d7d52c5
# mirrored from sibling agent bundles).
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
  printf 'cycle.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# bin/ helper resolution (agent dir first, repo source-tree fallback).
_ss_bin() {
  local helper="$1"
  if [[ -f "${CTX_AGENT_DIR}/bin/${helper}" ]]; then
    printf '%s' "${CTX_AGENT_DIR}/bin/${helper}"
  else
    printf '%s' "${IFOS_REPO_ROOT:-}/agents/recruitment/sourcing-scout/bin/${helper}"
  fi
}

# Connector base + secrets (Path A: values sourced into env, never printed —
# mirrors cash-conductor/cycle.sh Step 1).
_SS_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
if [[ -z "${_SS_CONN_BASE}" || ! -d "${_SS_CONN_BASE}" ]]; then
  _SS_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
fi
_SS_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
if [[ -f "${_SS_SECRETS}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${_SS_SECRETS}"
  set +a
fi

# Mode dispatch (default = cli; brain-ui/telegram pass --mode + --brief-id)
MODE="cli"
BRIEF_ID_ARG=""
DESCRIPTION_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)        MODE="${2:-}"; shift 2 ;;
    --brief-id)    BRIEF_ID_ARG="${2:-}"; shift 2 ;;
    --description) DESCRIPTION_ARG="${2:-}"; shift 2 ;;
    --tenant)      shift 2 ;;  # tenant set via CTX_TENANT_SLUG by bus
    *)             shift ;;
  esac
done
export BRIEF_ID_ARG DESCRIPTION_ARG

# Validate mode + brief-input args
case "${MODE}" in
  brain-ui|telegram|cli)
    if [[ -z "${BRIEF_ID_ARG}" && -z "${DESCRIPTION_ARG}" ]]; then
      printf 'cycle.sh: either --brief-id or --description required\n' >&2
      exit 2
    fi ;;
  webhook)
    printf 'cycle.sh: webhook mode DEFERRED to v1.1+ (auto_source_on_brief_create config not yet allowlisted)\n' >&2
    exit 2 ;;
  *) printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
esac

# Run-scoped workspace (purged on exit; partial drafts go to /tmp separately).
_SS_TMPD="$(mktemp -d -t scout-run-XXXXXX 2>/dev/null || echo "/tmp/scout-run-$$")"
mkdir -p "${_SS_TMPD}"
# shellcheck disable=SC2329  # invoked indirectly via trap
_ss_cleanup_tmpd() { rm -rf "${_SS_TMPD}" 2>/dev/null || true; }
trap _ss_cleanup_tmpd EXIT

# Exceptions accumulate across steps → §3 diagnostic + exception list.
_SS_EXCEPTIONS="${_SS_TMPD}/exceptions.txt"
: > "${_SS_EXCEPTIONS}"
_ss_exception() { printf '%s\n' "$1" >> "${_SS_EXCEPTIONS}"; }

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start
# ────────────────────────────────────────────────────────────────────────

# Filesystem-safe brief slug for vault paths + markers.
BRIEF_SLUG="$(printf '%s' "${BRIEF_ID_ARG:-${DESCRIPTION_ARG:0:30}}" \
  | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//; s/-*$//')"
[[ -z "${BRIEF_SLUG}" ]] && BRIEF_SLUG="untitled"
hh_decision_trigger "session_start" "sourcing-scout mode=${MODE} brief=${BRIEF_SLUG}"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Brief ingestion (per agent.md §4 Step 1)
# brief_id → Postgres entities read (entity_type='brief'; the Bullhorn-synced
# brief record per spec-003 §2 upstream contract). Free-text → deterministic
# bin/parse-brief.sh (LLM parse = documented enhancement; same JSON contract).
# <3 key dimensions → ESC_BRIEF_AMBIGUITY + validate_gate_a_fail + exit 1.
# ────────────────────────────────────────────────────────────────────────

BRIEF_JSON="${_SS_TMPD}/brief.json"
_ss_input_type=""
if [[ -n "${BRIEF_ID_ARG}" ]]; then
  _ss_input_type="brief_id"
  _ss_brief_row=""
  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    _ss_brief_row="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
      --set=tenant="${CTX_TENANT_SLUG}" --set=bid="${BRIEF_ID_ARG}" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT data::text FROM entities
WHERE tenant_slug = :'tenant' AND entity_type = 'brief' AND entity_id = :'bid'
LIMIT 1;
COMMIT;
SQL
)"
  fi
  if [[ -n "${_ss_brief_row}" ]] && printf '%s' "${_ss_brief_row}" | jq -e . >/dev/null 2>&1; then
    # Map the brief entity onto the parse-brief.sh JSON contract.
    printf '%s' "${_ss_brief_row}" | jq '
      { role:        (.title // .role // ""),
        location:    (.location // ""),
        salary_band: ( if .salary_band then .salary_band
                       elif .salary_min and .salary_max then "£\(.salary_min)-£\(.salary_max)"
                       elif .salary_min then "£\(.salary_min)+"
                       else "" end ),
        work_mode:   (.work_mode // .role_type // ""),
        seniority:   (.seniority // ""),
        sector:      (.sector // ""),
        source:      "entities_brief_read" }
      | .key_dims = ([.role, .location, .salary_band, .work_mode, .seniority, .sector]
                     | map(select(. != "")) | length)' > "${BRIEF_JSON}"
  elif [[ -n "${DESCRIPTION_ARG}" ]]; then
    # brief_id unresolvable but a free-text description was also supplied.
    _ss_input_type="brief_id_fallback_free_text"
    bash "$(_ss_bin parse-brief.sh)" --description "${DESCRIPTION_ARG}" > "${BRIEF_JSON}"
  else
    # Audit trail: autosend_escalate writes the gating_failed decision_log row.
    # No validate_gate_a_fail action row here — that action_type is reserved
    # for Gate A itself (deviation 4, sourcing-scout-summary.md).
    autosend_escalate "ESC_BRIEF_AMBIGUITY" "agent=sourcing-scout" \
      "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" "reason=brief_id_not_found_in_entities"
    exit 1
  fi
else
  _ss_input_type="free_text"
  bash "$(_ss_bin parse-brief.sh)" --description "${DESCRIPTION_ARG}" > "${BRIEF_JSON}"
fi

_ss_key_dims="$(jq -r '.key_dims // 0' "${BRIEF_JSON}")"
if [[ "${_ss_key_dims}" -lt 3 ]]; then
  # Audit trail via autosend_escalate only; validate_gate_a_fail is reserved
  # for Gate A itself (deviation 4, sourcing-scout-summary.md).
  autosend_escalate "ESC_BRIEF_AMBIGUITY" "agent=sourcing-scout" \
    "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" "key_dims=${_ss_key_dims}"
  exit 1
fi
hh_decision_output "brief_ingested" "brief:${BRIEF_SLUG}" \
  "input_type:${_ss_input_type}; key_dims:${_ss_key_dims}"

BRIEF_ROLE="$(jq -r '.role // ""' "${BRIEF_JSON}")"
BRIEF_LOCATION="$(jq -r '.location // ""' "${BRIEF_JSON}")"
BRIEF_SALARY="$(jq -r '.salary_band // ""' "${BRIEF_JSON}")"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Multi-source auth refresh; per-source degraded mode on fail
# Per-source state: fixture override → live; else creds presence + CLI
# surface (long-lived keys for Reed/CV-Library; Bullhorn OAuth refresh needs
# the not-yet-built @ifos/bullhorn CLI). Degraded source → catalogue ESC +
# skip, NEVER exit 1 (Sourcing-Scout-specific interpretation, agent.md §4
# Step 2). All live sources gone → ESC_AGENT_OUTPUT_SHAPE (<5 obtainable).
# ────────────────────────────────────────────────────────────────────────

declare -A SOURCE_STATE SOURCE_NOTE
_ss_resolve_source() {  # <source> <fixture_env_value> <creds_present 0|1> <cli_path> <esc_code>
  local src="$1" fixture="$2" creds="$3" cli="$4" esc="$5"
  if [[ -n "${fixture}" && -f "${fixture}" ]]; then
    SOURCE_STATE[${src}]="live"
    SOURCE_NOTE[${src}]="fixture"
    return 0
  fi
  if [[ "${creds}" -eq 1 && -f "${cli}" ]]; then
    SOURCE_STATE[${src}]="live"
    SOURCE_NOTE[${src}]="live_cli"
    return 0
  fi
  SOURCE_STATE[${src}]="degraded"
  if [[ "${creds}" -eq 0 ]]; then
    SOURCE_NOTE[${src}]="degraded: credentials absent"
  else
    SOURCE_NOTE[${src}]="degraded: connector CLI not built"
  fi
  autosend_escalate "${esc}" "agent=sourcing-scout" "tenant=${CTX_TENANT_SLUG}" \
    "brief=${BRIEF_SLUG}" "reason=${SOURCE_NOTE[${src}]// /_}" "degraded_mode=skip_${src}_source"
  _ss_exception "Source '${src}' degraded (${SOURCE_NOTE[${src}]}) — skipped this run (${esc})"
}

_ss_bh_creds=0
[[ -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" ]] && _ss_bh_creds=1
_ss_reed_creds=0
[[ -n "${REED_API_KEY:-}" ]] && _ss_reed_creds=1
_ss_cvl_creds=0
[[ -n "${CVLIBRARY_API_KEY:-}" || -n "${CVLIBRARY_ACCESS_TOKEN:-}" ]] && _ss_cvl_creds=1

_ss_resolve_source "bullhorn"  "${IFOS_SCOUT_FIXTURE_BULLHORN:-}"  "${_ss_bh_creds}"   "${_SS_CONN_BASE}/bullhorn/dist/cli.js"   "ESC_BULLHORN_AUTH"
_ss_resolve_source "reed"      "${IFOS_SCOUT_FIXTURE_REED:-}"      "${_ss_reed_creds}" "${_SS_CONN_BASE}/reed/dist/cli.js"       "ESC_REED_AUTH"
_ss_resolve_source "cvlibrary" "${IFOS_SCOUT_FIXTURE_CVLIBRARY:-}" "${_ss_cvl_creds}"  "${_SS_CONN_BASE}/cv-library/dist/cli.js" "ESC_CVLIBRARY_AUTH"

SOURCES_DEGRADED=""
_ss_live_count=0
for _src in bullhorn reed cvlibrary; do
  if [[ "${SOURCE_STATE[${_src}]}" == "live" ]]; then
    _ss_live_count=$((_ss_live_count + 1))
  else
    SOURCES_DEGRADED="${SOURCES_DEGRADED:+${SOURCES_DEGRADED},}${_src}"
  fi
done
hh_decision_output "auth_refresh_complete" "tenant:${CTX_TENANT_SLUG}" \
  "sources_ok:${_ss_live_count}/4; degraded:${SOURCES_DEGRADED:-none}; linkedin:v1.0_no_op"

if [[ "${_ss_live_count}" -eq 0 ]]; then
  # No live source can contribute → the Gate A 5-candidate floor is already
  # unobtainable. Escalate now; continue so the run still produces the
  # partial report + Gate A audit trail (agent.md §4 Step 2).
  autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=sourcing-scout" \
    "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" \
    "reason=all_sources_degraded_floor_unobtainable" "required_min=5"
  _ss_exception "All sources degraded — Gate A 5-candidate floor unobtainable this run"
fi

# ────────────────────────────────────────────────────────────────────────
# Source-abstraction query layer (Steps 3/5/6 share this; ULTRAPLAN A5
# line 555). Per-source mapping config lives in the CLI normalisation +
# fixture files; this function is source-agnostic.
# Writes ${_SS_TMPD}/<source>.json (unified-candidate array, ≤30) and sets
# _SS_QUERIED / _SS_RETURNED for the caller's marker.
# ────────────────────────────────────────────────────────────────────────

_scout_query_source() {  # <source> <fixture_path> <force_429 0|1> <cli_path> <cli_args...>
  local src="$1" fixture="$2" force429="$3" cli="$4"
  shift 4
  local out="${_SS_TMPD}/${src}.json"
  printf '[]' > "${out}"
  _SS_QUERIED="false"
  _SS_RETURNED=0

  if [[ "${SOURCE_STATE[${src}]}" != "live" ]]; then
    return 0   # degraded-skip; Step 2 already escalated + recorded the note
  fi
  _SS_QUERIED="true"

  if [[ "${force429}" -eq 1 ]]; then
    # Simulated/observed 429 → ESC_RATE_LIMIT_HIT (warn) + cached-only
    # degraded mode. v1.0 ships without a warm cache → 0 results.
    autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=sourcing-scout" \
      "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" "upstream=${src}" \
      "degraded_mode=cached_only"
    SOURCE_STATE[${src}]="degraded"
    SOURCE_NOTE[${src}]="degraded: 429 rate-limit; cached_only (cold cache → 0 results)"
    SOURCES_DEGRADED="${SOURCES_DEGRADED:+${SOURCES_DEGRADED},}${src}"
    _ss_exception "Source '${src}' hit a 429 rate limit — cached-only degraded mode; 0 results (cold cache)"
    return 0
  fi

  if [[ -n "${fixture}" && -f "${fixture}" ]]; then
    # Deterministic fixture path (no network/LLM; spec-003 honest scope).
    if jq -e 'type == "array"' "${fixture}" >/dev/null 2>&1; then
      jq '.[0:30]' "${fixture}" > "${out}"
    else
      jq '(.candidates // [])[0:30]' "${fixture}" > "${out}"
    fi
  elif [[ -f "${cli}" ]]; then
    # Live CLI path (the orchestrator's post-build smoke exercises this).
    local cli_out
    if cli_out="$(node "${cli}" "$@" 2>/dev/null)" \
         && printf '%s' "${cli_out}" | jq -e '.ok == true' >/dev/null 2>&1; then
      printf '%s' "${cli_out}" | jq '(.candidates // [])[0:30]' > "${out}"
    else
      local cli_err
      cli_err="$(printf '%s' "${cli_out:-}" | jq -r '.error // "query_failed"' 2>/dev/null || echo query_failed)"
      if [[ "${cli_err}" == "rate_limit" ]]; then
        autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=sourcing-scout" \
          "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" "upstream=${src}" \
          "degraded_mode=cached_only"
        SOURCE_NOTE[${src}]="degraded: 429 rate-limit; cached_only"
      else
        SOURCE_NOTE[${src}]="degraded: query failed (${cli_err})"
      fi
      SOURCE_STATE[${src}]="degraded"
      SOURCES_DEGRADED="${SOURCES_DEGRADED:+${SOURCES_DEGRADED},}${src}"
      _ss_exception "Source '${src}' query failed (${cli_err}) — 0 results this run"
    fi
  fi
  _SS_RETURNED="$(jq 'length' "${out}")"
  if [[ "${SOURCE_STATE[${src}]}" == "live" ]]; then
    SOURCE_NOTE[${src}]="${SOURCE_NOTE[${src}]}: ${_SS_RETURNED} candidates"
  fi
}

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Bullhorn passive-match query (READ-ONLY; agent.md §4 Step 3)
# Filter contract: status='active' AND date_last_modified_at < now()-90d
# ("passive" is derived, not a schema enum). ≤30 hits.
# ────────────────────────────────────────────────────────────────────────

_scout_query_source "bullhorn" "${IFOS_SCOUT_FIXTURE_BULLHORN:-}" \
  "${IFOS_SCOUT_FORCE_429_BULLHORN:-0}" "${_SS_CONN_BASE}/bullhorn/dist/cli.js" \
  search-candidates --query "status:active AND dateLastModified:<now-90d" \
  --keywords "${BRIEF_ROLE}" --location "${BRIEF_LOCATION}" --limit 30
hh_decision_output "bullhorn_query" "brief:${BRIEF_SLUG}" \
  "results:${_SS_RETURNED}; queried:${_SS_QUERIED}; filter:'status:active+modified<90d'"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — LinkedIn search — NO-OP at v1.0 (Proxycurl shutdown caveat)
# Explicit no-op audit row per the Janitor Step 7 pattern; v1.1+ vendor
# selection (Lix / Phantombuster / Apify / Sales Navigator) pending.
# ────────────────────────────────────────────────────────────────────────

printf '[]' > "${_SS_TMPD}/linkedin.json"
hh_decision_output "linkedin_query" "brief:${BRIEF_SLUG}" \
  "results:0; no_op; reason:v1.0_caveat_proxycurl_shutdown; vendor_selection:v1.1_deferred"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Reed query (≤30; ESC_REED_AUTH / ESC_RATE_LIMIT_HIT)
# ────────────────────────────────────────────────────────────────────────

_scout_query_source "reed" "${IFOS_SCOUT_FIXTURE_REED:-}" \
  "${IFOS_SCOUT_FORCE_429_REED:-0}" "${_SS_CONN_BASE}/reed/dist/cli.js" \
  search-candidates --keywords "${BRIEF_ROLE}" --location "${BRIEF_LOCATION}" \
  --salary-band "${BRIEF_SALARY}" --limit 30
hh_decision_output "reed_query" "brief:${BRIEF_SLUG}" \
  "results:${_SS_RETURNED}; queried:${_SS_QUERIED}"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — CV-Library query (≤30; the v1.0 live source)
# Live path via @ifos/cv-library dist/cli.js search-candidates (normalised
# unified shape). No live call is made in this build slice — fixture path in
# tests; creds + orchestrator smoke gate the live call.
# ────────────────────────────────────────────────────────────────────────

_scout_query_source "cvlibrary" "${IFOS_SCOUT_FIXTURE_CVLIBRARY:-}" \
  "${IFOS_SCOUT_FORCE_429_CVLIBRARY:-0}" "${_SS_CONN_BASE}/cv-library/dist/cli.js" \
  search-candidates --keywords "${BRIEF_ROLE}" --location "${BRIEF_LOCATION}" --limit 30
hh_decision_output "cvlibrary_query" "brief:${BRIEF_SLUG}" \
  "results:${_SS_RETURNED}; queried:${_SS_QUERIED}"

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Aggregate + dedupe across sources (bin/fuzzy-match.sh — carried
# Janitor matcher: name·0.3+email·0.4+phone·0.2+linkedin·0.1; ≥0.85) +
# source provenance annotation.
# ────────────────────────────────────────────────────────────────────────

AGGREGATE_JSON="${_SS_TMPD}/aggregate.json"
jq -s 'add' "${_SS_TMPD}/bullhorn.json" "${_SS_TMPD}/reed.json" \
  "${_SS_TMPD}/cvlibrary.json" "${_SS_TMPD}/linkedin.json" \
  | bash "$(_ss_bin fuzzy-match.sh)" > "${AGGREGATE_JSON}"
_ss_pre="$(jq -r '.pre_dedupe' "${AGGREGATE_JSON}")"
_ss_post="$(jq -r '.post_dedupe' "${AGGREGATE_JSON}")"
_ss_xsrc="$(jq -r '[.candidates[] | select((.sources | length) > 1)] | length' "${AGGREGATE_JSON}")"
hh_decision_output "aggregate_dedupe" "brief:${BRIEF_SLUG}" \
  "pre:${_ss_pre}; post:${_ss_post}; cross_source_matches:${_ss_xsrc}"

# ────────────────────────────────────────────────────────────────────────
# Step 8 — DNC filter (pre-outbound sourcing filter; NOT outbound refusal)
# tenant_adapters.config.blocked_recipients (v0.3-allowlisted) via
# CTX_DNC_BLOCKED_RECIPIENTS (context.sh; IFOS_FORCE_* fixture fallback).
# Drops → exception list ONLY; no ESC fire (catalogue §2.10 reserves
# ESC_DNC_FILTER_HIT for outbound send refusal; W4-polish backlog:
# ESC_SOURCING_DNC_FILTER). Dropped candidates still get their
# candidate_proposed row (included=false) at Step 9 per spec-003 §3.
# ────────────────────────────────────────────────────────────────────────

_DNC_JSON="${CTX_DNC_BLOCKED_RECIPIENTS:-${IFOS_FORCE_DNC_BLOCKED_RECIPIENTS:-[]}}"
if ! printf '%s' "${_DNC_JSON}" | jq -e 'type == "array"' >/dev/null 2>&1; then
  _DNC_JSON="[]"
fi
KEPT_JSON="${_SS_TMPD}/kept.json"
DNC_DROPPED_JSON="${_SS_TMPD}/dnc-dropped.json"
jq --argjson dnc "${_DNC_JSON}" '
  def nphone: gsub("[^0-9]"; "") | if length > 10 then .[-10:] else . end;
  ($dnc | map(ascii_downcase)) as $dl
  | ($dnc | map(nphone) | map(select(. != ""))) as $dp
  | def hit:
      ((((.email // "") | ascii_downcase) as $e | $e != "" and ($dl | index($e)) != null))
      or ((((.phone // "") | nphone) as $p | $p != "" and ($dp | index($p)) != null))
      or ((((.name // "") | ascii_downcase) as $n | $n != "" and ($dl | index($n)) != null));
  .candidates | map(select(hit | not))' "${AGGREGATE_JSON}" > "${KEPT_JSON}"
jq --argjson dnc "${_DNC_JSON}" '
  def nphone: gsub("[^0-9]"; "") | if length > 10 then .[-10:] else . end;
  ($dnc | map(ascii_downcase)) as $dl
  | ($dnc | map(nphone) | map(select(. != ""))) as $dp
  | def hit:
      ((((.email // "") | ascii_downcase) as $e | $e != "" and ($dl | index($e)) != null))
      or ((((.phone // "") | nphone) as $p | $p != "" and ($dp | index($p)) != null))
      or ((((.name // "") | ascii_downcase) as $n | $n != "" and ($dl | index($n)) != null));
  .candidates | map(select(hit))' "${AGGREGATE_JSON}" > "${DNC_DROPPED_JSON}"
_ss_dropped="$(jq 'length' "${DNC_DROPPED_JSON}")"
_ss_kept="$(jq 'length' "${KEPT_JSON}")"
if [[ "${_ss_dropped}" -gt 0 ]]; then
  _ss_exception "${_ss_dropped} candidate(s) filtered against the tenant DNC list (blocked_recipients) at Step 8"
fi
hh_decision_output "dnc_filter" "brief:${BRIEF_SLUG}" \
  "dropped:${_ss_dropped}; kept:${_ss_kept}; source:tenant_adapters.config.blocked_recipients"

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Ranking + per-candidate rationale generation (top 15)
# Deterministic templated rationale (bin/render-rationale.sh — the CC Step 8
# templated-draft pattern; LLM polish = documented enhancement). Voice
# honesty (spec-003 §8): empty voice_corpus → unscored/no_corpus, never a
# faked score; a real numeric score <0.75 after 3 retries → drop +
# ESC_VOICE_DRIFT. ONE candidate_proposed row PER candidate, including
# dropped (included=false + drop_reason).
# ────────────────────────────────────────────────────────────────────────

RANKED_JSON="${_SS_TMPD}/ranked.json"
jq 'sort_by(-(.confidence // 0))' "${KEPT_JSON}" > "${RANKED_JSON}"
FINAL_JSON="${_SS_TMPD}/final.json"
printf '[]' > "${FINAL_JSON}"

_ss_voice_state="${CTX_VOICE_CORPUS_STATE:-absent}"
_ss_force_voice="${IFOS_SCOUT_FORCE_VOICE_SCORE:-}"
_ss_voice_drops=0
_ss_rank=0
_ss_total_ranked="$(jq 'length' "${RANKED_JSON}")"

while IFS= read -r _cand_b64; do
  [[ -z "${_cand_b64}" ]] && continue
  _cand="$(printf '%s' "${_cand_b64}" | base64 -d)"
  _c_ref="$(printf '%s' "${_cand}" | jq -r '.ref // .refs[0] // "unknown"')"
  _c_name="$(printf '%s' "${_cand}" | jq -r '.name // "unknown"')"
  _c_sources="$(printf '%s' "${_cand}" | jq -r '(.sources // [.source]) | join(",")')"
  _c_conf="$(printf '%s' "${_cand}" | jq -r '.confidence // 0')"
  _ss_rank=$((_ss_rank + 1))

  if [[ "${_ss_rank}" -gt 15 ]]; then
    hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
      "source:${_c_sources}; confidence:${_c_conf}; voice_score:n/a; included:false; drop_reason:rank_cutoff_top15"
    continue
  fi

  # Rationale (deterministic ≥50 words; tone-rule compliant; no PII).
  _c_headline="$(printf '%s' "${_cand}" | jq -r '.headline // ""')"
  _c_location="$(printf '%s' "${_cand}" | jq -r '.location // ""')"
  _c_rationale="$(bash "$(_ss_bin render-rationale.sh)" \
    --name "${_c_name}" --sources "${_c_sources}" --confidence "${_c_conf}" \
    --brief-role "${BRIEF_ROLE:-the brief role}" --brief-location "${BRIEF_LOCATION}" \
    --brief-salary "${BRIEF_SALARY}" --headline "${_c_headline}" \
    --candidate-location "${_c_location}")"
  _c_words="$(printf '%s' "${_c_rationale}" | wc -w | tr -d ' ')"

  # Voice scoring honesty (spec-003 §8).
  _c_voice="unscored"
  _c_voice_reason="no_corpus"
  if [[ -n "${_ss_force_voice}" ]]; then
    _c_voice="${_ss_force_voice}"
    _c_voice_reason="forced_test_hook"
  elif [[ "${_ss_voice_state}" == "active" ]]; then
    # Corpus exists but the embedding classifier microservice is not built
    # yet — recording unscored is the honest signal (never fake a number).
    _c_voice_reason="classifier_unavailable"
  fi
  if [[ "${_c_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]] \
       && ! awk -v s="${_c_voice}" 'BEGIN{exit !(s>=0.75)}'; then
    # 3 deterministic retries of a templated rationale produce the same
    # score → drop after retry budget per agent.md §4 Step 9.
    _ss_voice_drops=$((_ss_voice_drops + 1))
    autosend_escalate "ESC_VOICE_DRIFT" "agent=sourcing-scout" \
      "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" \
      "candidate=${_c_ref}" "voice_score=${_c_voice}" "retries=3"
    _ss_exception "Candidate ${_c_name} dropped: rationale voice score ${_c_voice} < 0.75 after 3 retries (ESC_VOICE_DRIFT)"
    hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
      "source:${_c_sources}; confidence:${_c_conf}; voice_score:${_c_voice}; included:false; drop_reason:voice_drift"
    continue
  fi

  # Contact method preference: email > phone > linkedin > bullhorn_internal.
  _c_entry="$(printf '%s' "${_cand}" | jq \
    --arg rationale "${_c_rationale}" --arg words "${_c_words}" \
    --arg voice "${_c_voice}" --arg voice_reason "${_c_voice_reason}" '
    . + {
      candidate_id: (.ref // .refs[0] // "unknown"),
      contact_method:
        ( if ((.email // "") != "")        then {type: "email",    value: .email}
          elif ((.phone // "") != "")       then {type: "phone",    value: .phone}
          elif ((.linkedin_url // "") != "") then {type: "linkedin", value: .linkedin_url}
          elif ((.ref // "") | startswith("bullhorn:")) then {type: "bullhorn_internal", value: .ref}
          else {type: "missing", value: ""} end ),
      voice_score: (if ($voice | test("^[0-9.]+$")) then ($voice | tonumber) else $voice end),
      voice_reason: $voice_reason,
      rationale_body: $rationale,
      rationale_body_preview: ($rationale | .[0:500]),
      rationale_word_count: ($words | tonumber)
    }')"
  jq --argjson c "${_c_entry}" '. + [$c]' "${FINAL_JSON}" > "${FINAL_JSON}.tmp" \
    && mv "${FINAL_JSON}.tmp" "${FINAL_JSON}"
  hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
    "source:${_c_sources}; confidence:${_c_conf}; voice_score:${_c_voice}; included:true"
done < <(jq -r '.[] | @base64' "${RANKED_JSON}")

# candidate_proposed rows for the Step 8 DNC drops (included=false per spec-003 §3).
while IFS= read -r _d_b64; do
  [[ -z "${_d_b64}" ]] && continue
  _d="$(printf '%s' "${_d_b64}" | base64 -d)"
  hh_decision_output "candidate_proposed" \
    "candidate:$(printf '%s' "${_d}" | jq -r '.ref // .refs[0] // "unknown"')" \
    "source:$(printf '%s' "${_d}" | jq -r '(.sources // [.source]) | join(",")'); confidence:$(printf '%s' "${_d}" | jq -r '.confidence // 0'); voice_score:n/a; included:false; drop_reason:dnc_filter"
done < <(jq -r '.[] | @base64' "${DNC_DROPPED_JSON}")

[[ "${_ss_total_ranked}" -gt 15 ]] \
  && _ss_exception "$((_ss_total_ranked - 15)) candidate(s) below the top-15 rank cutoff (logged with included=false)"

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Output assembly + Gate A validation (validate.sh) → vault report
# Gate A failure: partial draft to /tmp + validate_gate_a_fail + ESC row
# (validate.sh emits both) + exit 1 BEFORE the scout_report row.
# ────────────────────────────────────────────────────────────────────────

PROPOSAL_JSON="${_SS_TMPD}/proposal.json"
_ss_bh_stats="$(jq -c -n --arg note "${SOURCE_NOTE[bullhorn]}" \
  --argjson queried "$([[ "${SOURCE_STATE[bullhorn]}" == "live" || "${SOURCE_NOTE[bullhorn]}" == *429* ]] && echo true || echo false)" \
  --argjson returned "$(jq 'length' "${_SS_TMPD}/bullhorn.json")" \
  '{queried: $queried, returned: $returned, note: $note}')"
_ss_reed_stats="$(jq -c -n --arg note "${SOURCE_NOTE[reed]}" \
  --argjson queried "$([[ "${SOURCE_STATE[reed]}" == "live" || "${SOURCE_NOTE[reed]}" == *429* ]] && echo true || echo false)" \
  --argjson returned "$(jq 'length' "${_SS_TMPD}/reed.json")" \
  '{queried: $queried, returned: $returned, note: $note}')"
_ss_cvl_stats="$(jq -c -n --arg note "${SOURCE_NOTE[cvlibrary]}" \
  --argjson queried "$([[ "${SOURCE_STATE[cvlibrary]}" == "live" || "${SOURCE_NOTE[cvlibrary]}" == *429* ]] && echo true || echo false)" \
  --argjson returned "$(jq 'length' "${_SS_TMPD}/cvlibrary.json")" \
  '{queried: $queried, returned: $returned, note: $note}')"

_ss_live_now=0
for _src in bullhorn reed cvlibrary; do
  [[ "${SOURCE_STATE[${_src}]}" == "live" ]] && _ss_live_now=$((_ss_live_now + 1))
done

jq -n \
  --arg brief_id "${BRIEF_ID_ARG:-${BRIEF_SLUG}}" \
  --arg tenant "${CTX_TENANT_SLUG}" \
  --slurpfile brief "${BRIEF_JSON}" \
  --slurpfile candidates "${FINAL_JSON}" \
  --argjson sources_active "${_ss_live_now}" \
  --arg degraded "${SOURCES_DEGRADED}" \
  --argjson bh "${_ss_bh_stats}" --argjson reed "${_ss_reed_stats}" --argjson cvl "${_ss_cvl_stats}" \
  --rawfile exceptions "${_SS_EXCEPTIONS}" \
  '{ brief_id: $brief_id, tenant_slug: $tenant, brief: $brief[0],
     candidates: $candidates[0],
     sources_active: $sources_active,
     sources_degraded: ($degraded | if . == "" then [] else split(",") end | unique),
     source_stats: {
       bullhorn: $bh,
       linkedin: {queried: false, returned: 0, note: "deferred to v1.1+; vendor pending"},
       reed: $reed,
       cvlibrary: $cvl },
     exceptions: ($exceptions | split("\n") | map(select(. != ""))) }' \
  > "${PROPOSAL_JSON}"

_ss_final_count="$(jq '.candidates | length' "${PROPOSAL_JSON}")"
_ss_sources_used="$(jq '[.source_stats | to_entries[] | select(.value.returned > 0)] | length' "${PROPOSAL_JSON}")"

_ss_validate="${CTX_AGENT_DIR}/validate.sh"
[[ -f "${_ss_validate}" ]] || _ss_validate="${IFOS_REPO_ROOT:-}/agents/recruitment/sourcing-scout/validate.sh"

GATE_A="FAIL"
if bash "${_ss_validate}" "${PROPOSAL_JSON}"; then
  GATE_A="PASS"
fi

if [[ "${GATE_A}" != "PASS" ]]; then
  # Partial draft to /tmp (NOT the vault) with the partial banner +
  # degradation notes; validate.sh already emitted validate_gate_a_fail +
  # the ESC row. Exit 1 BEFORE the scout_report row (agent.md §4 Step 10).
  PARTIAL_PATH="/tmp/sourcing-scout-${CTX_TENANT_SLUG}-${BRIEF_SLUG}-partial.md"
  bash "$(_ss_bin render-scout-report.sh)" "${PROPOSAL_JSON}" --partial > "${PARTIAL_PATH}" 2>/dev/null || true
  chmod 0600 "${PARTIAL_PATH}" 2>/dev/null || true
  printf 'cycle.sh: Gate A FAIL — partial draft at %s\n' "${PARTIAL_PATH}" >&2
  hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" \
    "$(printf '%s' "${CTX_TENANT_SLUG}|${BRIEF_SLUG}|fail" | shasum -a 256 2>/dev/null | cut -c1-16)" \
    "mode:${MODE}; tenant:${CTX_TENANT_SLUG}; gate_a:FAIL; candidates_final:${_ss_final_count}; sources_used:${_ss_sources_used}; partial_draft:${PARTIAL_PATH}" || true
  exit 1
fi

REPORT_DIR="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/sourcing-scout-reports"
REPORT_PATH="${REPORT_DIR}/${BRIEF_SLUG}-$(date -u +%Y-%m-%d).md"
mkdir -p "${REPORT_DIR}" 2>/dev/null || true
chmod 0700 "${REPORT_DIR}" 2>/dev/null || true
bash "$(_ss_bin render-scout-report.sh)" "${PROPOSAL_JSON}" > "${REPORT_PATH}"
chmod 0600 "${REPORT_PATH}" 2>/dev/null || true
hh_decision_output "scout_report" "${REPORT_PATH}" \
  "${_ss_final_count} candidates from ${_ss_sources_used} sources; gate_a:PASS"

# ────────────────────────────────────────────────────────────────────────
# Step 11 — Session close + operator notification (per invocation source)
# Telegram when configured (green-tier operator_notify_telegram); Brain UI
# mode notifies via the internal API (stdout note until the Brain UI in-app
# channel lands); cli mode → stdout.
# ────────────────────────────────────────────────────────────────────────

_ss_notified="stdout"
if [[ "${MODE}" == "telegram" && -n "${TELEGRAM_BOT_TOKEN:-}" \
      && -n "${CTX_OPERATOR_TELEGRAM_CHAT_ID:-}" && "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" != "unset" ]] \
     && command -v curl >/dev/null 2>&1; then
  if curl -fsS -m 10 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
       --data-urlencode "chat_id=${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
       --data-urlencode "text=Sourcing Scout: ${_ss_final_count} candidates for brief ${BRIEF_SLUG} → ${REPORT_PATH}" \
       >/dev/null 2>&1; then
    _ss_notified="telegram"
    hh_decision_action "operator_notify_telegram" "chat:${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
      "$(printf '%s' "${REPORT_PATH}" | shasum -a 256 2>/dev/null | cut -c1-16)" \
      "scout report complete; brief:${BRIEF_SLUG}; report:${REPORT_PATH}" || true
  fi
fi
printf '[sourcing-scout cycle.sh] gate_a=PASS candidates=%s sources_used=%s report=%s notify=%s\n' \
  "${_ss_final_count}" "${_ss_sources_used}" "${REPORT_PATH}" "${_ss_notified}"

_ss_run_hash="$(printf '%s' "${CTX_TENANT_SLUG}|${BRIEF_SLUG}|$(date -u +%s)" | shasum -a 256 2>/dev/null | cut -c1-16)"
[[ -z "${_ss_run_hash}" ]] && _ss_run_hash="run-${BRIEF_SLUG}"
hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" "${_ss_run_hash}" \
  "mode:${MODE}; tenant:${CTX_TENANT_SLUG}; gate_a:PASS; candidates_final:${_ss_final_count}; sources_used:${_ss_sources_used}; report_path:${REPORT_PATH}; notify:${_ss_notified}" || true

exit 0
