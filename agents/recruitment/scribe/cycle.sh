#!/usr/bin/env bash
# Scribe agent — cycle.sh (10-step per-call orchestration; W6 build slice LIVE)
#
# Status: built (W6 build slice; the W5 Day-32 skeleton TODO(W6-7) markers are
#         replaced with live implementation per spec-002-scribe.md §4 + §5 and
#         agent.md §3-§6).
# Reading order: agent.md §1 (output contract) + §3 (2 outputs: Bullhorn
#         structured-field writes + tacit-note vault + Bullhorn note attach) +
#         §4 (this workflow's 10 steps) + §5 (Gate A + Gate B) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# VENDOR (Day-29 pivot, spec-002 §8): the transcript vendor is GRANOLA
# (@ifos/granola). agent.md §4 Step 3's Fathom/Fireflies text is PRE-PIVOT —
# every transcript-fetch path here is Granola. Granola does NOT publish
# webhooks, so the operational trigger is the poll-sweep; the generic v1.0
# webhook surface (agent.md §2; HMAC/bearer-verified) is ALSO implemented
# (mode=webhook) per spec-002 §4 Step 1 + Gate A webhook-sig.
#
# Invocation modes:
#   mode=poll-sweep   — 5-min cron: list meetings since last_poll → process
#                       Steps 2-10 per new meeting (default)
#   mode=replay       — manual: process one meeting (--call-id <id>) per
#                       agent.md §2 "ifosctl scribe replay --call-id <id>"
#   mode=webhook      — generic per-call webhook: --payload <json file> plus
#                       --signature sha256=<hex> (HMAC-SHA256, secret from
#                       $SCRIBE_WEBHOOK_SECRET) or --bearer <token>
#   mode=dry-run      — poll-sweep + Steps 0-7 only (no Step 8/9 writes)
#
# Step map (spec-002 §4 — markers are the downstream contract):
#   0  session start                       trigger session_start
#   1  webhook signature verify / poll     webhook_verified (+ granola_meetings_polled)
#   2  Bullhorn auth refresh               bullhorn_auth_refreshed   ESC_BULLHORN_AUTH
#   3  Granola transcript fetch → /tmp     transcript_fetched        ESC_PROVIDER_FETCH_FAIL
#   4  participant → entity resolution     entity_resolved           ESC_AGENT_OUTPUT_SHAPE
#   5  field extraction (≥3 ≥0.6)          fields_extracted          ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
#   6  tacit-note → vault (0600)           tacit_note_rendered       ESC_VOICE_DRIFT (via Gate A)
#   7  schema validation + Gate A          fields_validated          ESC_SCHEMA_VIOLATION
#   8  Bullhorn field write (yellow)       bullhorn_scribe_field_write  ESC_BULLHORN_WRITE_FAIL
#   9  Bullhorn note attach (yellow)       bullhorn_note_append_summary ESC_BULLHORN_WRITE_FAIL (+rollback of 8)
#   10 session close + SLA                 scribe_run_complete       ESC_SCRIBE_SLA_MISS
#
# Bullhorn calls route through bin/bh-bridge.sh ONLY (parallel-conflict rule:
# Janitor owns packages/mcp-connectors/bullhorn this cycle; the shim is the
# single reconciliation point). Granola live calls expect the @ifos/granola
# CLI (node packages/mcp-connectors/granola/dist/cli.js list-meetings|
# get-transcript) which is NOT BUILT YET — fixture/seeded sources
# (IFOS_SCRIBE_MEETINGS_FILE / IFOS_SCRIBE_TRANSCRIPT_FILE / _DIR) carry the
# fixture suites; live smoke is founder-gated (creds + ≥1 recorded meeting).
#
# Output contract per agent.md §1: two outputs per meeting —
#   1. ≥3 Bullhorn structured-field writes (yellow bullhorn_scribe_field_write;
#      IFOS-cached entities row is ALWAYS written; the Bullhorn PATCH push is
#      deferred while the CLI bridge is unavailable — recorded on the row)
#   2. Tacit-note markdown → vault (canonical, ADR-002) + Bullhorn Note attach

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: hydrate context + resolve _shared/ helpers
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'scribe/cycle.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'scribe/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=scribe}"
export CTX_AGENT_NAME CTX_AGENT_DIR CTX_TENANT_SLUG   # inherited by validate.sh subprocess (Step 7)

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

command -v jq >/dev/null 2>&1 || { printf 'cycle.sh: jq required\n' >&2; exit 2; }

_BIN="${CTX_AGENT_DIR}/bin"
[[ -d "${_BIN}" ]] || _BIN="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/bin"

# Mode dispatch
MODE="poll-sweep"
CALL_ID_ARG="" PAYLOAD_FILE="" SIGNATURE="" BEARER=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)      MODE="${2:-}"; shift 2 ;;
    --call-id)   CALL_ID_ARG="${2:-}"; shift 2 ;;
    --payload)   PAYLOAD_FILE="${2:-}"; shift 2 ;;
    --signature) SIGNATURE="${2:-}"; shift 2 ;;
    --bearer)    BEARER="${2:-}"; shift 2 ;;
    --tenant)    shift 2 ;;  # tenant set via CTX_TENANT_SLUG by bus
    --dry-run)   MODE="dry-run"; shift ;;
    *)           shift ;;
  esac
done

case "${MODE}" in
  poll-sweep|dry-run) : ;;
  replay)
    if [[ -z "${CALL_ID_ARG}" ]]; then
      printf 'cycle.sh: --call-id required for mode=replay\n' >&2; exit 2
    fi ;;
  webhook)
    if [[ -z "${PAYLOAD_FILE}" || ! -f "${PAYLOAD_FILE}" ]]; then
      printf 'cycle.sh: --payload <json file> required for mode=webhook\n' >&2; exit 2
    fi ;;
  *) printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
esac

# Defensive defaults if context.sh wasn't run (standalone invocation)
: "${CTX_GRANOLA_PLAN_TIER:=paid}"
: "${CTX_GRANOLA_WORKSPACE_ID:=unset}"
: "${CTX_BULLHORN_CORPORATION_ID:=unset}"
: "${CTX_FIRM_DOMAIN_WHITELIST:=${CTX_TENANT_SLUG}.test}"
: "${CTX_GRANOLA_LAST_POLL:=1970-01-01T00:00:00Z}"
: "${CTX_VOICE_CORPUS_ID:=none}"
export CTX_GRANOLA_PLAN_TIER CTX_GRANOLA_WORKSPACE_ID CTX_BULLHORN_CORPORATION_ID \
       CTX_FIRM_DOMAIN_WHITELIST CTX_VOICE_CORPUS_ID

SESSION_START_EPOCH="$(date -u +%s)"
VAULT_PHYS_ROOT="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}"
GRANOLA_CLI="${IFOS_GRANOLA_CLI:-${IFOS_REPO_ROOT:-}/packages/mcp-connectors/granola/dist/cli.js}"
FETCH_RETRY_DELAY="${SCRIBE_FETCH_RETRY_DELAY:-30}"

# ISO-8601 (UTC, Z) → epoch seconds; BSD + GNU date. Empty on parse failure.
_iso_to_epoch() {
  local ts="$1"
  [[ -z "${ts}" ]] && { echo ""; return 0; }
  date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "${ts}" +%s 2>/dev/null \
    || date -u -d "${ts}" +%s 2>/dev/null \
    || echo ""
}

# RLS-scoped psql wrapper (stdin SQL; --set tenant pre-bound). Best-effort.
_psql_t() {
  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" "$@"
}

# Session counters (Step 10)
CALLS_PROCESSED=0
CALLS_SKIPPED=0
FIELD_WRITES=0
NOTE_ATTACHES=0
WORST_SLA_CLASS="n/a"

# Severity rank for SLA classes (bin/sla-class.sh output set) — Step 10
# records the WORST class across a multi-meeting sweep, not the last
# (review F5). Higher = worse.
_sla_rank() {
  case "$1" in
    note_attach_miss)    echo 5 ;;
    summary_render_miss) echo 4 ;;
    gate_b_10min_miss)   echo 3 ;;
    info_5_10_min)       echo 2 ;;
    under_5_min)         echo 1 ;;
    *)                   echo 0 ;;   # n/a (no call completed yet)
  esac
}

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" "scribe mode=${MODE} call_id=${CALL_ID_ARG:-NA}"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Webhook signature verification (mode=webhook) / poll discovery
# Reference: spec-002 §4 Step 1 (marker webhook_verified; ESC_INPUT_VALIDATION_FAIL
# reject = the 401 path) + agent.md §2. In poll-sweep/replay there is no
# external webhook input to verify (Granola publishes none) — the marker is
# emitted honestly with method:poll|manual_replay + signature:not_applicable;
# Gate A G1 accepts {verified, not_applicable} and hard-fails {invalid, missing}.
# ────────────────────────────────────────────────────────────────────────

WEBHOOK_SIG_STATE="not_applicable"
MEETINGS_JSON="[]"

if [[ "${MODE}" == "webhook" ]]; then
  WEBHOOK_SIG_STATE="invalid"
  if [[ -n "${SIGNATURE}" && -n "${SCRIBE_WEBHOOK_SECRET:-}" ]] && command -v openssl >/dev/null 2>&1; then
    _want="${SIGNATURE#sha256=}"
    _got="$(openssl dgst -sha256 -hmac "${SCRIBE_WEBHOOK_SECRET}" "${PAYLOAD_FILE}" 2>/dev/null | awk '{print $NF}')"
    [[ -n "${_got}" && "${_got}" == "${_want}" ]] && WEBHOOK_SIG_STATE="verified"
  elif [[ -n "${BEARER}" && -n "${SCRIBE_WEBHOOK_SECRET:-}" ]]; then
    [[ "${BEARER}" == "${SCRIBE_WEBHOOK_SECRET}" ]] && WEBHOOK_SIG_STATE="verified"
  fi
  _wh_call_id="$(jq -r '.call_id // "unknown"' "${PAYLOAD_FILE}" 2>/dev/null || echo unknown)"
  if [[ "${WEBHOOK_SIG_STATE}" != "verified" ]]; then
    # Reject (the HTTP layer maps this to 401) — per agent.md §4 Step 1.
    autosend_escalate "ESC_INPUT_VALIDATION_FAIL" "agent=scribe" \
      "tenant=${CTX_TENANT_SLUG}" "call=${_wh_call_id}" "reason=webhook_signature_mismatch"
    hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
      "provider:granola; method:hmac_sha256; result:invalid; rejected:401"
    exit 1
  fi
  hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
    "provider:granola; method:$( [[ -n "${SIGNATURE}" ]] && echo hmac_sha256 || echo bearer ); result:verified"
  # Webhook payload IS the meeting metadata (agent.md §2 shape).
  MEETINGS_JSON="$(jq -c '[{id: (.call_id // "unknown"), title: (.metadata.title // ""),
      end_time: (.metadata.end_time // .received_at // ""),
      duration_minutes: ((.duration_seconds // 0) / 60 | floor),
      attendees: (.participants // []), has_transcript: true,
      notes_markdown: (.metadata.notes_markdown // "")}]' "${PAYLOAD_FILE}" 2>/dev/null || echo '[]')"
else
  hh_decision_output "webhook_verified" "call:${CALL_ID_ARG:-sweep}" \
    "provider:granola; method:$( [[ "${MODE}" == "replay" ]] && echo manual_replay || echo poll ); signature:not_applicable"

  # Poll discovery (poll-sweep/dry-run) or single-meeting hydrate (replay).
  # Source order: fixture file → @ifos/granola CLI (expected surface:
  # `node dist/cli.js list-meetings --since <ISO>` → JSON array) → empty.
  if [[ -n "${IFOS_SCRIBE_MEETINGS_FILE:-}" && -f "${IFOS_SCRIBE_MEETINGS_FILE}" ]]; then
    MEETINGS_JSON="$(jq -c '.' "${IFOS_SCRIBE_MEETINGS_FILE}" 2>/dev/null || echo '[]')"
  elif [[ -f "${GRANOLA_CLI}" ]] && command -v node >/dev/null 2>&1; then
    MEETINGS_JSON="$(node "${GRANOLA_CLI}" list-meetings --since "${CTX_GRANOLA_LAST_POLL}" 2>/dev/null || echo '[]')"
    jq -e 'type=="array"' <<<"${MEETINGS_JSON}" >/dev/null 2>&1 || MEETINGS_JSON="[]"
  fi
  if [[ "${MODE}" == "replay" ]]; then
    _m="$(jq -c --arg id "${CALL_ID_ARG}" '[.[] | select(.id == $id)] | first // empty' <<<"${MEETINGS_JSON}" 2>/dev/null || true)"
    if [[ -n "${_m}" ]]; then
      MEETINGS_JSON="[${_m}]"
    else
      MEETINGS_JSON="$(jq -nc --arg id "${CALL_ID_ARG}" '[{id: $id, title: "", end_time: "", duration_minutes: 0, attendees: [], has_transcript: true, notes_markdown: ""}]')"
    fi
  fi
  _n_meet="$(jq 'length' <<<"${MEETINGS_JSON}")"
  _n_tx="$(jq '[.[] | select(.has_transcript == true)] | length' <<<"${MEETINGS_JSON}")"
  hh_decision_output "granola_meetings_polled" "tenant:${CTX_TENANT_SLUG}" \
    "mode:${MODE}; meetings:${_n_meet}; meetings_with_transcripts:${_n_tx}; since:${CTX_GRANOLA_LAST_POLL}; workspace_id:${CTX_GRANOLA_WORKSPACE_ID}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn auth refresh (session-level; via bin/bh-bridge.sh)
# Reference: agent.md §4 Step 2; 2 retries then ESC_BULLHORN_AUTH (blocking;
# operator + ifos_oncall). Bridge-unavailable (exit 3) is recorded honestly —
# Gate A G7 then blocks Bullhorn writes (no creds → no writes; never faked).
# ────────────────────────────────────────────────────────────────────────

BH_TOKEN_STATE="failed"
for _attempt in 1 2 3; do
  _rc=0
  _out="$(bash "${_BIN}/bh-bridge.sh" refresh 2>/dev/null)" || _rc=$?
  if [[ "${_rc}" -eq 0 ]]; then
    BH_TOKEN_STATE="$(jq -r '.token_state // "refreshed"' <<<"${_out}" 2>/dev/null || echo refreshed)"
    break
  elif [[ "${_rc}" -eq 3 ]]; then
    BH_TOKEN_STATE="unavailable"   # bridge not built / creds not provisioned — no point retrying
    break
  fi
  [[ "${_attempt}" -lt 3 ]] && sleep 1
done
hh_decision_output "bullhorn_auth_refreshed" "tenant:${CTX_TENANT_SLUG}" \
  "corporation_id:${CTX_BULLHORN_CORPORATION_ID}; result:${BH_TOKEN_STATE}"
if [[ "${BH_TOKEN_STATE}" == "failed" ]]; then
  autosend_escalate "ESC_BULLHORN_AUTH" "agent=scribe" \
    "tenant=${CTX_TENANT_SLUG}" "corporation_id=${CTX_BULLHORN_CORPORATION_ID}" "retries=2"
fi
export SCRIBE_BH_TOKEN_STATE="${BH_TOKEN_STATE}"   # validate.sh G7 reads decision_log; exported for trace only

# ────────────────────────────────────────────────────────────────────────
# Per-call processing — Steps 3-9 (+ per-call SLA input for Step 10).
# Returns 0 = processed to completion (writes done or honestly deferred);
#         1 = call skipped (Gate A fail / fetch fail / no entity).
# ────────────────────────────────────────────────────────────────────────

process_call() {
  local meeting="$1"
  local call_id title end_time duration attendees notes_md has_tx
  call_id="$(jq -r '.id' <<<"${meeting}")"
  title="$(jq -r '.title // ""' <<<"${meeting}")"
  end_time="$(jq -r '.end_time // ""' <<<"${meeting}")"
  duration="$(jq -r '.duration_minutes // 0' <<<"${meeting}")"
  attendees="$(jq -r '(.attendees // []) | join(",")' <<<"${meeting}")"
  notes_md="$(jq -r '.notes_markdown // ""' <<<"${meeting}")"
  has_tx="$(jq -r '.has_transcript // false' <<<"${meeting}")"

  local today vault_dir_phys note_file_phys vault_path_logical tmp_tx
  today="$(date -u +%Y-%m-%d)"
  vault_dir_phys="${VAULT_PHYS_ROOT}/${CTX_TENANT_SLUG}/scribe-notes"
  note_file_phys="${vault_dir_phys}/${call_id}-${today}.md"
  vault_path_logical="/vault/${CTX_TENANT_SLUG}/scribe-notes/${call_id}-${today}.md"
  tmp_tx="/tmp/scribe-${CTX_TENANT_SLUG}-${call_id}.txt"

  # ── Step 3 — Granola transcript fetch → /tmp 0600 ─────────────────────
  # Source order: seeded fixture file/dir → @ifos/granola CLI (expected
  # surface: `node dist/cli.js get-transcript --meeting <id>` → JSON
  # {segments:[{start_seconds,speaker,text}]}) → notes_markdown degraded
  # fallback (Free-tier guard / has_transcript=false). Paid-plan pre-guard:
  # transcript fetch is a PAID_PLAN_TOOLS call — on a free workspace it is
  # skipped BEFORE any wire round-trip and the run degrades to notes-only
  # ingest. (ESC_GRANOLA_PLAN_TIER is QUEUED for catalogue registration; the
  # degradation is recorded on the audit rows until it lands — never a fake
  # ESC through an unregistered code.)
  # DECLARED DEVIATION 10 (review F2): spec-002 §4 row 3 lists a transcript-
  # side ESC_PII_LEAKAGE_RISK at this step; NOT implemented by design.
  # Transcripts inherently contain third-party contact data (every external
  # attendee email is "PII outside the firm boundary" by the gate's own
  # definition), so a transcript-wide scan would fire on every call. The
  # transcript never leaves the firm boundary: it lives at /tmp mode 0600 and
  # is purged ≤24h by cleanup.sh. The correct control point for what DOES
  # leave (the note body Step 9 exports to Bullhorn) is Gate A G6's
  # full-note-body scan in validate.sh.
  local tx_source="" ingest_mode="transcript"
  rm -f "${tmp_tx}" 2>/dev/null || true

  _try_fetch_transcript() {
    if [[ -n "${IFOS_SCRIBE_TRANSCRIPT_FILE:-}" && -f "${IFOS_SCRIBE_TRANSCRIPT_FILE}" ]]; then
      tx_source="${IFOS_SCRIBE_TRANSCRIPT_FILE}"; return 0
    fi
    if [[ -n "${IFOS_SCRIBE_TRANSCRIPT_DIR:-}" && -f "${IFOS_SCRIBE_TRANSCRIPT_DIR}/${call_id}.txt" ]]; then
      tx_source="${IFOS_SCRIBE_TRANSCRIPT_DIR}/${call_id}.txt"; return 0
    fi
    if [[ -f "${GRANOLA_CLI}" ]] && command -v node >/dev/null 2>&1; then
      local _gj
      if _gj="$(node "${GRANOLA_CLI}" get-transcript --meeting "${call_id}" 2>/dev/null)" \
           && jq -e '.segments | type=="array"' <<<"${_gj}" >/dev/null 2>&1; then
        # Normalise granola segments → "[MM:SS] speaker: text" lines.
        # 0600 from birth (umask 177 subshell — review F4): the normalised
        # transcript never exists on disk with default perms.
        if ! ( umask 177
               jq -r '.segments[] | "[" + ((.start_seconds // 0) / 60 | floor | tostring) + ":" +
                      (((.start_seconds // 0) % 60 | floor | tostring) | if length < 2 then "0" + . else . end) + "] " +
                      (.speaker // "unknown") + ": " + (.text // "")' <<<"${_gj}" > "${tmp_tx}.cli" 2>/dev/null ); then
          return 1
        fi
        tx_source="${tmp_tx}.cli"; return 0
      fi
      return 1
    fi
    return 1
  }

  if [[ "${CTX_GRANOLA_PLAN_TIER}" != "paid" || "${has_tx}" != "true" ]]; then
    ingest_mode="notes_only_degraded"
  else
    if ! _try_fetch_transcript; then
      sleep "${FETCH_RETRY_DELAY}"           # retry once, 30s backoff (agent.md §4 Step 3)
      if ! _try_fetch_transcript; then
        ingest_mode="notes_only_degraded"
        autosend_escalate "ESC_PROVIDER_FETCH_FAIL" "agent=scribe" \
          "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "upstream=granola" "retries=1"
      fi
    fi
  fi

  ( umask 177
    if [[ "${ingest_mode}" == "transcript" ]]; then
      cp "${tx_source}" "${tmp_tx}"
    else
      printf '%s\n' "${notes_md}" > "${tmp_tx}"
    fi
  )
  rm -f "${tmp_tx}.cli" 2>/dev/null || true
  chmod 0600 "${tmp_tx}" 2>/dev/null || true
  if [[ ! -s "${tmp_tx}" ]]; then
    # No transcript AND no notes — nothing to ingest for this call.
    autosend_escalate "ESC_PROVIDER_FETCH_FAIL" "agent=scribe" \
      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "upstream=granola" "reason=no_transcript_and_no_notes"
    rm -f "${tmp_tx}" 2>/dev/null || true
    return 1
  fi
  local tx_bytes
  tx_bytes="$(wc -c < "${tmp_tx}" | tr -d ' ')"
  hh_decision_output "transcript_fetched" "call:${call_id}" \
    "provider:granola; bytes:${tx_bytes}; tmp_path:${tmp_tx}; ingest_mode:${ingest_mode}; plan_tier:${CTX_GRANOLA_PLAN_TIER}"

  # ── Step 4 — Participant → entity inference (IFOS-cached entities) ────
  # Match non-firm participant emails against the RLS-scoped entities cache;
  # priority placement > brief > opportunity > contact > candidate (the most
  # context-specific entity wins — a placed candidate's check-in call should
  # resolve to the Placement, not the Candidate).
  local ext_emails="" e
  for e in ${attendees//,/ }; do
    [[ -z "${e}" ]] && continue
    local dom="${e##*@}" is_firm=0 fd
    for fd in ${CTX_FIRM_DOMAIN_WHITELIST//,/ }; do
      [[ "${dom,,}" == "${fd,,}" ]] && is_firm=1
    done
    [[ "${is_firm}" -eq 0 ]] && ext_emails+="${ext_emails:+,}${e,,}"
  done

  local resolved="" entity_type="" bullhorn_id="" confidence="0"
  if [[ -n "${ext_emails}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    resolved="$(_psql_t --set=emails="${ext_emails}" <<'SQL' 2>/dev/null | grep -E '\|' | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT entity_type || '|' || entity_id
FROM entities
WHERE tenant_slug = :'tenant'
  AND ( lower(coalesce(data->>'email',''))           = ANY (string_to_array(:'emails', ','))
     OR lower(coalesce(data->>'candidate_email','')) = ANY (string_to_array(:'emails', ',')) )
ORDER BY array_position(ARRAY['placement','brief','opportunity','contact','candidate'], entity_type)
LIMIT 1;
COMMIT;
SQL
)"
  fi
  if [[ -z "${resolved}" ]]; then
    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=scribe" \
      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "reason=no_resolvable_target_entity"
    hh_decision_action "validate_gate_a_fail" "call:${call_id}" "no-entity-${call_id}" \
      "ESC_AGENT_OUTPUT_SHAPE; agent_name:scribe; step:4; participants:${ext_emails:-none}" || true
    return 1
  fi
  entity_type="${resolved%%|*}"
  bullhorn_id="${resolved#*|}"
  confidence="0.95"   # exact email match against the cached entity (deterministic resolver)
  hh_decision_output "entity_resolved" "${entity_type}:${bullhorn_id}" \
    "call:${call_id}; confidence:${confidence}; match:email_exact"

  # ── Step 5 — Field extraction (≥3 fields ≥0.6 per Gate A) ─────────────
  local fields_file="${tmp_tx%.txt}-fields.json"
  if ! bash "${_BIN}/extract-fields.sh" --transcript "${tmp_tx}" --entity-type "${entity_type}" \
        --call-id "${call_id}" --vault-path "${vault_path_logical}" > "${fields_file}" 2>/dev/null; then
    printf '[]\n' > "${fields_file}"
  fi
  chmod 0600 "${fields_file}" 2>/dev/null || true
  local n_above
  n_above="$(jq '[.[] | select(.confidence >= 0.6)] | length' "${fields_file}" 2>/dev/null || echo 0)"
  hh_decision_output "fields_extracted" "${entity_type}:${bullhorn_id}" \
    "call:${call_id}; fields_above_threshold:${n_above}; extractor:$( [[ "${IFOS_SCRIBE_USE_LLM:-0}" == "1" && -n "${ANTHROPIC_API_KEY:-}" ]] && echo llm_with_deterministic_fallback || echo deterministic ); ingest_mode:${ingest_mode}"
  if [[ "${n_above}" -lt 3 ]]; then
    autosend_escalate "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE" "agent=scribe" \
      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "fields_above_threshold=${n_above}" "required=3"
    hh_decision_action "validate_gate_a_fail" "${entity_type}:${bullhorn_id}" "lowconf-${call_id}" \
      "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE; agent_name:scribe; step:5; fields:${n_above}" || true
    rm -f "${fields_file}" 2>/dev/null || true
    return 1
  fi
  # Drop sub-threshold fields before Step 7 (agent.md §4 Step 5).
  jq '[.[] | select(.confidence >= 0.6)]' "${fields_file}" > "${fields_file}.f" && mv "${fields_file}.f" "${fields_file}"

  # ── Step 6 — Tacit-note generation → vault 0600 (canonical per ADR-002) ─
  # Voice score resolution (HONEST — never faked):
  #   IFOS_FORCE_VOICE_SCORE  → numeric (fixture/test hook + future classifier wire-in)
  #   active voice_corpus     → unscored/no_classifier (corpus exists; the
  #                             classifier microservice is W4-5 polish, not built)
  #   no corpus               → unscored/no_corpus (CC precedent)
  # The 3-retry loop of agent.md §4 Step 6 only makes sense for a
  # non-deterministic (LLM) generator; the deterministic renderer emits one
  # canonical rendering, so retries:0 is recorded.
  local voice_score voice_reason needs_review="" retries=0
  if [[ -n "${IFOS_FORCE_VOICE_SCORE:-}" ]]; then
    voice_score="${IFOS_FORCE_VOICE_SCORE}"
    voice_reason="forced_test_score"
    retries="${IFOS_FORCE_VOICE_RETRIES:-0}"
    if awk -v s="${voice_score}" 'BEGIN{exit !(s < 0.75)}'; then
      needs_review="--needs-review"
    fi
  elif [[ "${CTX_VOICE_CORPUS_ID}" != "none" ]]; then
    voice_score="unscored"; voice_reason="no_classifier"
  else
    voice_score="unscored"; voice_reason="no_corpus"
  fi

  mkdir -p "${vault_dir_phys}" 2>/dev/null || true
  chmod 0700 "${vault_dir_phys}" 2>/dev/null || true
  local render_args=(--call-id "${call_id}" --date "${today}" --transcript "${tmp_tx}"
    --participants "${attendees}" --duration-min "${duration}"
    --voice-score "${voice_score}" --voice-reason "${voice_reason}")
  [[ -n "${title}" ]] && render_args+=(--context "${title}")
  [[ -n "${needs_review}" ]] && render_args+=("${needs_review}")
  if ! bash "${_BIN}/render-tacit-note.sh" "${render_args[@]}" > "${note_file_phys}.tmp" 2>/dev/null; then
    rm -f "${note_file_phys}.tmp" 2>/dev/null || true
    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=scribe" \
      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "reason=tacit_note_render_failed"
    return 1
  fi
  mv "${note_file_phys}.tmp" "${note_file_phys}"
  chmod 0600 "${note_file_phys}" 2>/dev/null || true
  local body_sha words
  body_sha="$(shasum -a 256 "${note_file_phys}" 2>/dev/null | cut -c1-16)"
  [[ -z "${body_sha}" ]] && body_sha="na"
  words="$(wc -w < "${note_file_phys}" | tr -d ' ')"
  # ADR-002: metadata ONLY — {vault_path, body_sha256, voice_score}; body NEVER in payload.
  hh_decision_output "tacit_note_rendered" "${vault_path_logical}" \
    "vault_path:${vault_path_logical}; body_sha256:${body_sha}; voice_score:${voice_score}; voice_reason:${voice_reason}; words:${words}; retries:${retries}"

  # ── Step 7 — Schema validation (names + types/ranges) + Gate A ────────
  local vres valid_count dropped_count
  vres="$(bash "${_BIN}/validate-fields.sh" --entity-type "${entity_type}" --fields-file "${fields_file}" 2>/dev/null || echo '{"valid":[],"dropped":[],"valid_count":0}')"
  valid_count="$(jq -r '.valid_count' <<<"${vres}")"
  dropped_count="$(jq -r '.dropped | length' <<<"${vres}")"
  if [[ "${valid_count}" -lt 3 ]]; then
    autosend_escalate "ESC_SCHEMA_VIOLATION" "agent=scribe" \
      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "valid=${valid_count}" "dropped=${dropped_count}"
    hh_decision_action "validate_gate_a_fail" "${entity_type}:${bullhorn_id}" "schema-${call_id}" \
      "ESC_SCHEMA_VIOLATION; agent_name:scribe; step:7; valid:${valid_count}; dropped:${dropped_count}" || true
    rm -f "${fields_file}" 2>/dev/null || true
    return 1
  fi
  hh_decision_output "fields_validated" "${entity_type}:${bullhorn_id}" \
    "call:${call_id}; valid:${valid_count} of $(jq 'length' "${fields_file}") extracted; dropped:${dropped_count}"

  # Build the Gate A proposal + run validate.sh (hard gate between Step 7 and 8).
  # narrative_body_preview (first 500 chars) is the AUDIT ROW artefact only —
  # validate.sh G6 scans the FULL physical body it resolves from
  # tacit_note.vault_path (review F1 fix; Step 9 exports the full body).
  local proposal="${tmp_tx%.txt}-proposal.json" preview
  preview="$(sed -n '/^---$/,/^---$/!p' "${note_file_phys}" | head -c 500 | tr '\n' ' ')"
  jq -nc --arg call_id "${call_id}" --arg et "${entity_type}" --arg bid "${bullhorn_id}" \
     --arg sig "${WEBHOOK_SIG_STATE}" --argjson fields "$(jq -c '.valid' <<<"${vres}")" \
     --arg vp "${vault_path_logical}" --arg sha "${body_sha}" --arg vs "${voice_score}" \
     --arg vr "${voice_reason}" --argjson words "${words}" --arg pv "${preview}" '{
       call_id: $call_id, entity_type: $et, bullhorn_id: $bid,
       webhook_sig_state: $sig, fields_extracted: $fields,
       tacit_note: { vault_path: $vp, body_sha256: $sha, voice_score: $vs,
                     voice_reason: $vr, narrative_word_count: $words,
                     narrative_body_preview: $pv } }' > "${proposal}"
  chmod 0600 "${proposal}" 2>/dev/null || true

  local _validate="${CTX_AGENT_DIR}/validate.sh"
  [[ -f "${_validate}" ]] || _validate="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/validate.sh"
  if ! bash "${_validate}" "${proposal}" >/dev/null 2>&1; then
    # validate.sh already emitted the ESC + validate_gate_a_fail rows.
    # Transcript stays in /tmp (auto-purged 24h by cleanup.sh); vault note is
    # flagged needs_consultant_review by Step 6 when the voice path failed.
    rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
    return 1
  fi

  if [[ "${MODE}" == "dry-run" ]]; then
    hh_decision_output "dry_run_writes_skipped" "call:${call_id}" \
      "would_write_field_count:${valid_count}; would_attach_note:true"
    rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
    return 0
  fi

  # ── Step 8 — Bullhorn field write (yellow, atomic; rollback snapshot) ──
  # The IFOS-cached entities row is the write target (defence-in-depth: the
  # validate_entities_data_v0_3 trigger re-enforces shapes at write time);
  # the Bullhorn PATCH push goes through bh-bridge.sh. opportunity is
  # IFOS-cache ONLY per agent.md §3 (no v1.0 Bullhorn endpoint).
  local field_map prior_data="" push_state="cache_only_by_design" bh_type=""
  field_map="$(jq -c '.valid | map({(.field_name): .value}) | add' <<<"${vres}")"
  case "${entity_type}" in
    candidate) bh_type="Candidate" ;;
    contact)   bh_type="ClientContact" ;;
    brief)     bh_type="JobOrder" ;;
    placement) bh_type="Placement" ;;
    opportunity) bh_type="" ;;
  esac

  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    prior_data="$(_psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT data::text FROM entities
WHERE tenant_slug = :'tenant' AND entity_type = :'et' AND entity_id = :'eid' LIMIT 1;
COMMIT;
SQL
)"
    if ! _psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" --set=fm="${field_map}" >/dev/null 2>&1 <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE entities
SET data = data || :'fm'::jsonb, version = version + 1, updated_at = now()
WHERE tenant_slug = :'tenant' AND entity_type = :'et' AND entity_id = :'eid';
COMMIT;
SQL
    then
      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=scribe" \
        "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "entity=${entity_type}:${bullhorn_id}" "surface=entities_cache_update"
      rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
      return 1
    fi
  fi

  if [[ -n "${bh_type}" ]]; then
    local _prc=0
    bash "${_BIN}/bh-bridge.sh" update-entity --type "${bh_type}" --id "${bullhorn_id}" \
      --fields "${field_map}" >/dev/null 2>&1 || _prc=$?
    case "${_prc}" in
      0) push_state="pushed" ;;
      3) push_state="deferred_bridge_unavailable" ;;
      *) # Bullhorn PATCH hard-failed → roll the cache back; do NOT proceed to Step 9.
         if [[ -n "${prior_data}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
           _psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" --set=pd="${prior_data}" >/dev/null 2>&1 <<'SQL' || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE entities SET data = :'pd'::jsonb, version = version + 1, updated_at = now()
WHERE tenant_slug = :'tenant' AND entity_type = :'et' AND entity_id = :'eid';
COMMIT;
SQL
         fi
         autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=scribe" \
           "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "entity=${entity_type}:${bullhorn_id}" "surface=bullhorn_patch"
         rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
         return 1 ;;
    esac
  fi

  local payload_hash
  payload_hash="$(printf '%s' "${call_id}|${entity_type}|${bullhorn_id}|${field_map}" | shasum -a 256 2>/dev/null | cut -c1-16)"
  [[ -z "${payload_hash}" ]] && payload_hash="${call_id}"
  hh_decision_action "bullhorn_scribe_field_write" "${entity_type}:${bullhorn_id}" "${payload_hash}" \
    "call:${call_id}; fields_written:${valid_count}; bullhorn_push:${push_state}; ingest_mode:${ingest_mode}" || true
  FIELD_WRITES=$((FIELD_WRITES + 1))

  # Gate B edit-rate basis (spec-002 §3 downstream contract): one recent_edit
  # row per field write, resolution='deferred' until a consultant reviews.
  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    _psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" --set=fm="${field_map}" >/dev/null 2>&1 <<'SQL' || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
INSERT INTO recent_edit (tenant_slug, agent_name, action_type, target_entity_type,
                         target_entity_id, original_text, resolution, resolved_at)
VALUES (:'tenant', 'scribe', 'bullhorn_scribe_field_write', :'et', :'eid', :'fm', 'deferred', now());
COMMIT;
SQL
  fi

  # ── Step 9 — Bullhorn note attach (yellow); rollback Step 8 on hard fail ─
  local _nrc=0
  if [[ -n "${bh_type}" ]]; then
    bash "${_BIN}/bh-bridge.sh" create-note --entity-type "${bh_type}" --entity-id "${bullhorn_id}" \
      --body-file "${note_file_phys}" --title "Scribe tacit notes — ${call_id}" >/dev/null 2>&1 || _nrc=$?
  else
    _nrc=4   # opportunity: cache-only entity, no Bullhorn Note target at v1.0
  fi
  case "${_nrc}" in
    0)
      hh_decision_action "bullhorn_note_append_summary" "${entity_type}:${bullhorn_id}" "${body_sha}" \
        "call:${call_id}; vault_path:${vault_path_logical}; note_payload_hash:${body_sha}; words:${words}" || true
      NOTE_ATTACHES=$((NOTE_ATTACHES + 1)) ;;
    3)
      # Bridge unavailable: NO Bullhorn state changed → no yellow action row
      # (honest signal); the vault note is the canonical artefact and a
      # consultant attaches manually until the bridge lands.
      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
        "call:${call_id}; vault_path:${vault_path_logical}; reason:bridge_unavailable" ;;
    4)
      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
        "call:${call_id}; vault_path:${vault_path_logical}; reason:opportunity_cache_only_no_note_endpoint" ;;
    *)
      # Note attach hard-failed → best-effort rollback of Step 8 (agent.md §4
      # Step 9 + §9 Q5 documented mid-state risk).
      if [[ -n "${prior_data}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
        _psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" --set=pd="${prior_data}" >/dev/null 2>&1 <<'SQL' || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE entities SET data = :'pd'::jsonb, version = version + 1, updated_at = now()
WHERE tenant_slug = :'tenant' AND entity_type = :'et' AND entity_id = :'eid';
COMMIT;
SQL
      fi
      if [[ -n "${bh_type}" && -n "${prior_data}" ]]; then
        local prior_subset
        prior_subset="$(jq -c --argjson fm "${field_map}" '. as $p | $fm | keys | map({(.): ($p[.] // null)}) | add' <<<"${prior_data}" 2>/dev/null || echo '{}')"
        bash "${_BIN}/bh-bridge.sh" update-entity --type "${bh_type}" --id "${bullhorn_id}" \
          --fields "${prior_subset}" >/dev/null 2>&1 || true
      fi
      # Review F6: the Step-8 recent_edit 'deferred' row belongs to a write we
      # just rolled back — remove it so Gate B's edit-rate denominator isn't
      # inflated by a write that never landed.
      if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
        _psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" --set=fm="${field_map}" >/dev/null 2>&1 <<'SQL' || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
DELETE FROM recent_edit
WHERE id = (SELECT id FROM recent_edit
            WHERE tenant_slug = :'tenant' AND agent_name = 'scribe'
              AND action_type = 'bullhorn_scribe_field_write'
              AND target_entity_type = :'et' AND target_entity_id = :'eid'
              AND resolution = 'deferred' AND original_text = :'fm'
            ORDER BY id DESC LIMIT 1);
COMMIT;
SQL
      fi
      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=scribe" \
        "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "entity=${entity_type}:${bullhorn_id}" \
        "surface=note_attach" "rollback=step8_reversed_best_effort"
      rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
      return 1 ;;
  esac

  rm -f "${fields_file}" "${proposal}" 2>/dev/null || true

  # ── Per-call SLA input (Step 10) — elapsed since call end ──────────────
  local end_epoch now_epoch elapsed sla_line sla_class esc_code sla_type
  end_epoch="$(_iso_to_epoch "${end_time}")"
  [[ -z "${end_epoch}" ]] && end_epoch="${SESSION_START_EPOCH}"
  now_epoch="$(date -u +%s)"
  elapsed=$(( now_epoch - end_epoch )); (( elapsed < 0 )) && elapsed=0
  sla_line="$(bash "${_BIN}/sla-class.sh" --elapsed "${elapsed}")"
  IFS='|' read -r sla_class esc_code sla_type <<<"${sla_line}"
  if [[ -n "${esc_code}" ]]; then
    autosend_escalate "${esc_code}" "agent=scribe" \
      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "sla_type=${sla_type}" "elapsed_seconds=${elapsed}"
  fi
  if (( $(_sla_rank "${sla_class}") > $(_sla_rank "${WORST_SLA_CLASS}") )); then
    WORST_SLA_CLASS="${sla_class}"
  fi
  LAST_CALL_ELAPSED="${elapsed}"
  return 0
}

# ────────────────────────────────────────────────────────────────────────
# Steps 3-9 — per-meeting loop (poll-sweep iterates; replay/webhook = 1 call)
# ────────────────────────────────────────────────────────────────────────

LAST_CALL_ELAPSED=0
LAST_CALL_ID="${CALL_ID_ARG:-NA}"
GATE_FAILED=0
while IFS= read -r _meeting; do
  [[ -z "${_meeting}" ]] && continue
  LAST_CALL_ID="$(jq -r '.id' <<<"${_meeting}")"
  if process_call "${_meeting}"; then
    CALLS_PROCESSED=$((CALLS_PROCESSED + 1))
  else
    CALLS_SKIPPED=$((CALLS_SKIPPED + 1))
    GATE_FAILED=1
  fi
done < <(jq -c '.[]' <<<"${MEETINGS_JSON}")

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Session close + SLA metric
# Reference: agent.md §4 Step 10 (threshold scopes) + catalogue §2.10.
# Per-call ESC_SCRIBE_SLA_MISS already fired inside the loop (elapsed is
# per call-end); this action row closes the session trace.
# ────────────────────────────────────────────────────────────────────────

_run_hash="$(printf '%s' "${CTX_TENANT_SLUG}|${MODE}|$(date -u +%s)" | shasum -a 256 2>/dev/null | cut -c1-16)"
[[ -z "${_run_hash}" ]] && _run_hash="run-${MODE}"
hh_decision_action "scribe_run_complete" "call:${LAST_CALL_ID}" "${_run_hash}" \
  "mode:${MODE}; calls_processed:${CALLS_PROCESSED}; calls_skipped:${CALLS_SKIPPED}; field_writes:${FIELD_WRITES}; note_attaches:${NOTE_ATTACHES}; elapsed_seconds:${LAST_CALL_ELAPSED}; sla_class:${WORST_SLA_CLASS}" || true

# Exit semantics: replay/webhook surface a per-call gate failure as exit 1;
# poll-sweep/dry-run always exit 0 (skips are logged + ESC-routed per call).
if [[ "${MODE}" == "replay" || "${MODE}" == "webhook" ]] && [[ "${GATE_FAILED}" -eq 1 ]]; then
  exit 1
fi
exit 0
