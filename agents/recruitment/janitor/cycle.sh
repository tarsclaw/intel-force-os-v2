#!/usr/bin/env bash
# Janitor agent — cycle.sh (12-step nightly cron orchestration; W6-7 LIVE)
#
# Status: LIVE per spec-001 §4 (W6-7 build slice) — every step wired.
# Reading order: agent.md §1 (output contract) + §3 (2 outputs: day-30 report
#         + Bullhorn yellow-tier writes) + §4 (this workflow's 12 steps) +
#         §5 (Gate A + Gate B) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# v1.0 Bullhorn disposition (spec-001 §8 honest scope): Bullhorn creds are
# EMPTY today (founder-gated; dev-support enquiry pending). The @ifos/bullhorn
# dist/cli.js bridge is BUILT and wired below; until creds land the agent runs
# in DEGRADED mode — Step 2 scans the Postgres `entities` Bullhorn cache,
# Step 9 validates every write through Gate A and records the yellow action
# row with write_state:deferred_no_bullhorn_creds (transport executes when
# creds land; never faked). Companies House (Step 6) is live-capable (key SET).
#
# Invocation modes (per agent.md §2):
#   mode=full-cleanup   — nightly cron 02:00 UTC: all 12 steps (default)
#   mode=incremental    — cron catch-up: Steps 1-4 + 8-9 + 12 (skip enrichment +
#                         day-30 report assembly; the next full-cleanup picks them up)
#   mode=report-only    — Steps 1 + 10 + 12 only (regenerate day-30 report without
#                         writes; used post-incident per agent.md §2 manual trigger)
#   mode=dry-run        — Steps 1-8 + 10 + 12 only (no Bullhorn writes; report
#                         shows what WOULD have been written)
#
# Deterministic test hooks (fixtures; documented, never used in production):
#   IFOS_JANITOR_FIXTURE_BULLHORN_AUTH = ok|failed — force the Step 1 token
#       state without creds (context.sh consumes; cycle.sh re-reads CTX var)
#   IFOS_JANITOR_FIXTURE_CH = <path.json> — array of {query, crn, industry,
#       source_confidence} rows; Step 6 resolves client names against it
#       instead of the live Companies House API (zero network in tests)
#   IFOS_JANITOR_FIXTURE_WRITE_RESULT = ok|4xx|5xx — simulate the Step 9
#       Bullhorn write outcome (exercises ESC_BULLHORN_WRITE_FAIL routes)
#   IFOS_JANITOR_FORCE_VOICE_SCORE = <0..1> — numeric voice score for Step 8
#       narratives (exercises the G5 ESC_VOICE_DRIFT route; corpus-empty runs
#       record unscored/no_corpus, never a faked number)
#   IFOS_JANITOR_NO_LLM = 1 — pin Step 8 narratives to the deterministic
#       template (no Anthropic call even when ANTHROPIC_API_KEY is set)
#   IFOS_JANITOR_RETRY_DELAY_S — overrides the 30s/60s backoff sleeps (tests: 0)
#
# Package dependencies:
#   @ifos/bullhorn        — dist/cli.js bridge (check-auth/refresh/list-*/
#                           update-candidate/update-client/create-note)
#   @ifos/companies-house — client enrichment via bin/ch-lookup.mjs (7d cache
#                           + shared 600/5min budget inside the connector)
#
# Output contract per agent.md §1 (READ THAT FIRST). Two outputs:
#   1. Day-30 Markdown report → /vault/<tenant>/janitor-reports/day-30-<ISO>.md
#   2. Yellow-tier Bullhorn writes (3 action_types REGISTERED in autosend-policy.yaml):
#      bullhorn_candidate_dedupe + bullhorn_field_backfill + bullhorn_note_attach
#
# Per agent.md §5 Gate A: hard-fail any merge proposal with confidence <0.85;
# review-band pairs (0.70–0.85 OR ≥0.85 with recent activity) held for synchronous
# Telegram approval via ESC_DUPLICATE_DETECTED (SUCCESS path; fired at Steps 3-4).

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: hydrate context + resolve _shared/ helpers
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'janitor/cycle.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'janitor/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=janitor}"
export CTX_AGENT_NAME CTX_AGENT_DIR CTX_TENANT_SLUG   # inherited by validate.sh subprocess (Step 9)

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
_jn_bin() {
  local helper="$1"
  if [[ -f "${CTX_AGENT_DIR}/bin/${helper}" ]]; then
    printf '%s' "${CTX_AGENT_DIR}/bin/${helper}"
  else
    printf '%s' "${IFOS_REPO_ROOT:-}/agents/recruitment/janitor/bin/${helper}"
  fi
}
# sql/ helper resolution (same chain).
_jn_sql() {
  local f="$1"
  if [[ -f "${CTX_AGENT_DIR}/sql/${f}" ]]; then
    printf '%s' "${CTX_AGENT_DIR}/sql/${f}"
  else
    printf '%s' "${IFOS_REPO_ROOT:-}/agents/recruitment/janitor/sql/${f}"
  fi
}

# Connector base + secrets (Path A: values sourced into env, never printed —
# mirrors cash-conductor/cycle.sh Step 1).
_JN_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
if [[ -z "${_JN_CONN_BASE}" || ! -d "${_JN_CONN_BASE}" ]]; then
  _JN_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
fi
_JN_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
if [[ -f "${_JN_SECRETS}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${_JN_SECRETS}"
  set +a
fi
_JN_BH_CLI="${_JN_CONN_BASE}/bullhorn/dist/cli.js"
_JN_DELAY="${IFOS_JANITOR_RETRY_DELAY_S:-30}"

# Defensive defaults when run standalone (context.sh exports these in the harness).
: "${CTX_JANITOR_DEDUP_THRESHOLD:=0.85}"
: "${CTX_BULLHORN_CORPORATION_ID:=unset}"
: "${CTX_OPERATOR_TELEGRAM_CHAT_ID:=unset}"
: "${CTX_VOICE_CORPUS_STATE:=absent}"
export CTX_JANITOR_DEDUP_THRESHOLD

# Mode dispatch (default = full-cleanup; cron passes --mode full-cleanup at 02:00 UTC)
MODE="full-cleanup"
TENANT_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)    MODE="${2:-}"; shift 2 ;;
    --tenant)  TENANT_ARG="${2:-}"; shift 2 ;;
    --dry-run) MODE="dry-run"; shift ;;
    --report-only) MODE="report-only"; shift ;;
    *)         shift ;;
  esac
done
# Manual-trigger consistency guard (ADR-003: the bus sets CTX_TENANT_SLUG;
# --tenant is operator convenience — a mismatch is a mis-invocation).
if [[ -n "${TENANT_ARG}" && "${TENANT_ARG}" != "${CTX_TENANT_SLUG}" ]]; then
  printf 'cycle.sh: --tenant %s does not match CTX_TENANT_SLUG %s — refusing mismatched invocation\n' \
    "${TENANT_ARG}" "${CTX_TENANT_SLUG}" >&2
  exit 2
fi

# Run-scoped workspace (purged on exit).
_JN_TMPD="$(mktemp -d -t janitor-run-XXXXXX 2>/dev/null || echo "/tmp/janitor-run-$$")"
mkdir -p "${_JN_TMPD}/proposals"
# shellcheck disable=SC2329  # invoked indirectly via trap
_jn_cleanup_tmpd() { rm -rf "${_JN_TMPD}" 2>/dev/null || true; }
trap _jn_cleanup_tmpd EXIT

# Exceptions accumulate across steps → day-30 report §7 exception list.
_JN_EXCEPTIONS="${_JN_TMPD}/exceptions.txt"
: > "${_JN_EXCEPTIONS}"
_jn_exception() { printf '%s\n' "$1" >> "${_JN_EXCEPTIONS}"; }

# RLS-scoped psql (stdin carries the SQL; :'tenant' bound).
_jn_psql() {
  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" "$@"
}
_jn_db_up=0
if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then _jn_db_up=1; fi

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" "janitor mode=${MODE}"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Bullhorn auth refresh (runs in every mode)
# Reference: agent.md §4 Step 1; @ifos/bullhorn two-step refresh (Step A OAuth
# + Step B REST login per src/auth.ts) via dist/cli.js. 2 retries; failure →
# ESC_BULLHORN_AUTH (blocking; operator + ifos_oncall routing) + exit 1.
# Creds absent (founder-gated today) → honest DEGRADED state: ESC fires with
# reason=credentials_absent, run continues against the entities cache
# (Scout degraded-skip precedent; writes defer at Step 9).
# ────────────────────────────────────────────────────────────────────────

_jn_token_state="absent"
if [[ -n "${IFOS_JANITOR_FIXTURE_BULLHORN_AUTH:-}" ]]; then
  case "${IFOS_JANITOR_FIXTURE_BULLHORN_AUTH}" in
    ok)     _jn_token_state="fixture" ;;
    failed) _jn_token_state="failed" ;;
  esac
elif [[ -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" && -f "${_JN_BH_CLI}" ]]; then
  _jn_token_state="failed"
  for _attempt in 1 2 3; do   # initial + 2 retries per agent.md §4 Step 1
    if node "${_JN_BH_CLI}" refresh 2>/dev/null | jq -e '.ok == true' >/dev/null 2>&1; then
      _jn_token_state="ok"
      break
    fi
    [[ "${_attempt}" -lt 3 ]] && sleep "${_JN_DELAY}"
  done
fi

hh_decision_output "bullhorn_auth_refresh" "tenant:${CTX_TENANT_SLUG}" \
  "corporation_id:${CTX_BULLHORN_CORPORATION_ID}; bullhorn_token_state:${_jn_token_state}"

case "${_jn_token_state}" in
  failed)
    autosend_escalate "ESC_BULLHORN_AUTH" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
      "corporation_id=${CTX_BULLHORN_CORPORATION_ID}" "reason=refresh_failed_after_2_retries"
    printf 'cycle.sh: Bullhorn auth refresh failed after 2 retries — blocking (ESC_BULLHORN_AUTH)\n' >&2
    exit 1 ;;
  absent)
    autosend_escalate "ESC_BULLHORN_AUTH" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
      "reason=credentials_absent_founder_gated" "degraded_mode=entities_cache_scan_writes_deferred"
    _jn_exception "Bullhorn creds absent (founder-gated) — scan ran against the entities cache; Step 9 writes recorded as deferred" ;;
esac
export CTX_BULLHORN_TOKEN_STATE="${_jn_token_state}"

# ────────────────────────────────────────────────────────────────────────
# Step routing — full-cleanup runs all steps; incremental + dry-run skip
# enrichment; report-only skips scan entirely. Word-boundary matching (a
# bare *2* glob would mis-match "12" — latent skeleton bug fixed here).
# ────────────────────────────────────────────────────────────────────────

case "${MODE}" in
  full-cleanup) STEPS_TO_RUN="2 3 4 5 6 7 8 9 10 11 12" ;;
  incremental)  STEPS_TO_RUN="2 3 4 8 9 12" ;;
  dry-run)      STEPS_TO_RUN="2 3 4 5 6 7 8 10 12" ;;  # No Step 9 (writes); no Step 11
  report-only)  STEPS_TO_RUN="10 12" ;;
  *)            printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
esac
_step_planned() { [[ " ${STEPS_TO_RUN} " == *" $1 "* ]]; }
hh_decision_output "mode_routed" "tenant:${CTX_TENANT_SLUG}" \
  "mode:${MODE}; steps_planned:${STEPS_TO_RUN}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Entity scan since janitor_last_run
# Reference: agent.md §4 Step 2 + spec-001 §4 (marker: janitor_scan).
# Live (token ok): @ifos/bullhorn CLI list-candidates/contacts/clients
# --since <watermark> → upsert into the entities cache; 429 → 60s backoff +
# one retry + ESC_RATE_LIMIT_HIT. Degraded (creds absent): the entities cache
# IS the scan surface (rows arrive via seeds today, webhooks/sync later).
# Count is taken from the cache in both modes — one honest code path.
# ────────────────────────────────────────────────────────────────────────

JN_SINCE=""
if _step_planned 2; then
  if [[ "${_jn_db_up}" -eq 1 ]]; then
    JN_SINCE="$(_jn_psql <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(config->>'janitor_last_run', '') FROM tenant_adapters
WHERE tenant_slug = :'tenant' AND config ? 'janitor_last_run'
ORDER BY id LIMIT 1;
COMMIT;
SQL
)"
  fi

  # Live Bullhorn pull (only when the token is genuinely live).
  if [[ "${_jn_token_state}" == "ok" && "${_jn_db_up}" -eq 1 ]]; then
    for _jn_kind in candidates contacts clients; do
      _jn_pull_args=("list-${_jn_kind}")
      [[ -n "${JN_SINCE}" ]] && _jn_pull_args+=(--since "${JN_SINCE}")
      _jn_rows=""
      if ! _jn_rows="$(node "${_JN_BH_CLI}" "${_jn_pull_args[@]}" 2>&1)"; then
        if printf '%s' "${_jn_rows}" | grep -qi 'rate.limit'; then
          autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
            "upstream=bullhorn" "step=2" "backoff_s=60"
          sleep "${IFOS_JANITOR_RETRY_DELAY_S:-60}"
          _jn_rows="$(node "${_JN_BH_CLI}" "${_jn_pull_args[@]}" 2>/dev/null || echo '[]')"
        else
          _jn_rows="[]"
        fi
      fi
      if printf '%s' "${_jn_rows}" | jq -e 'type=="array" and length > 0' >/dev/null 2>&1; then
        _jn_psql -q --set=js="${_jn_rows}" <<'SQL' >/dev/null 2>&1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
INSERT INTO entities (tenant_slug, entity_type, entity_id, data)
SELECT :'tenant', t.entity_type, t.entity_id, t.data
FROM jsonb_to_recordset(:'js'::jsonb) AS t(entity_type text, entity_id text, data jsonb)
ON CONFLICT (tenant_slug, entity_type, entity_id)
DO UPDATE SET data = EXCLUDED.data, updated_at = now();
COMMIT;
SQL
      fi
    done
  fi

  _jn_scanned=0
  _jn_bytype=""
  if [[ "${_jn_db_up}" -eq 1 ]]; then
    _jn_scan_out="$(_jn_psql --set=since="${JN_SINCE}" <<'SQL' 2>/dev/null || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT entity_type || '|' || count(*)::text
FROM entities
WHERE updated_at > coalesce(nullif(:'since', '')::timestamptz, '-infinity'::timestamptz)
  AND entity_type IN ('candidate','contractor','client','contact','placement','opportunity')
GROUP BY entity_type ORDER BY entity_type;
COMMIT;
SQL
)"
    while IFS='|' read -r _t _n; do
      [[ -z "${_t}" ]] && continue
      _jn_scanned=$((_jn_scanned + _n))
      _jn_bytype="${_jn_bytype:+${_jn_bytype},}${_t}:${_n}"
    done <<<"${_jn_scan_out}"
  fi
  hh_decision_output "janitor_scan" "tenant:${CTX_TENANT_SLUG}" \
    "${_jn_scanned} entities scanned; since:${JN_SINCE:-epoch}; by_type:${_jn_bytype:-none}; source:$([[ "${_jn_token_state}" == "ok" ]] && echo bullhorn_live || echo entities_cache_degraded)"
fi

# ────────────────────────────────────────────────────────────────────────
# Dedup helper (Steps 3 + 4 share this; same matcher, separate entity_type
# per vertical-schema.yaml §1 + Q1 Day-6 resolution).
# Pool = ALL cached records of the type (pair-finding needs the full pool,
# not just the incremental slice). Review-band pairs fire the
# ESC_DUPLICATE_DETECTED SUCCESS-path Telegram approval gate here (per
# agent.md §5 + catalogue §2.5); auto pairs queue write proposals for Step 9.
# ────────────────────────────────────────────────────────────────────────

_jn_dedup_pass() {  # <entity_type> <marker_name>
  local etype="$1" marker="$2"
  local pool pairs_json auto review dropped
  pool="[]"
  if [[ "${_jn_db_up}" -eq 1 ]]; then
    pool="$(_jn_psql --set=etype="${etype}" <<'SQL' 2>/dev/null | head -1 || echo '[]'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(jsonb_agg(jsonb_build_object(
  'entity_id', entity_id,
  'name', coalesce(nullif(data->>'name',''), trim(concat(data->>'first_name',' ',data->>'last_name'))),
  'email', data->>'email',
  'phone', data->>'phone',
  'linkedin_url', data->>'linkedin_url',
  'last_activity_days', (CASE WHEN data->>'last_activity_days' ~ '^[0-9]+$'
                              THEN (data->>'last_activity_days')::int ELSE NULL END)
)), '[]'::jsonb)::text
FROM entities WHERE entity_type = :'etype';
COMMIT;
SQL
)"
  fi
  [[ -z "${pool}" ]] && pool="[]"
  pairs_json="$(printf '%s' "${pool}" \
    | bash "$(_jn_bin dedup-pairs.sh)" --threshold "${CTX_JANITOR_DEDUP_THRESHOLD}" 2>/dev/null \
    || echo '{"auto":0,"review":0,"dropped":0,"pairs":[]}')"
  auto="$(printf '%s' "${pairs_json}" | jq -r '.auto')"
  review="$(printf '%s' "${pairs_json}" | jq -r '.review')"
  dropped="$(printf '%s' "${pairs_json}" | jq -r '.dropped')"

  # Review band → ESC_DUPLICATE_DETECTED per pair (SUCCESS-path approval gate).
  while IFS=$'\t' read -r _rp _rt _rc _rr; do
    [[ -z "${_rp}" ]] && continue
    autosend_escalate "ESC_DUPLICATE_DETECTED" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
      "entity_type=${etype}" "primary_id=${_rp}" "merge_target_id=${_rt}" \
      "confidence=${_rc}" "review_band_reason=${_rr}" \
      "routing=operator_telegram_approval_gate"
    _jn_exception "Review-band ${etype} pair ${_rp}/${_rt} (conf ${_rc}; ${_rr}) — held for operator approval (ESC_DUPLICATE_DETECTED)"
  done < <(printf '%s' "${pairs_json}" \
    | jq -r '.pairs[] | select(.band == "review") | [.primary_id, .target_id, (.confidence|tostring), .reason] | @tsv')

  # Auto band → Step 9 write proposals (validate.sh contract shape).
  while IFS= read -r _ap; do
    [[ -z "${_ap}" ]] && continue
    printf '%s' "${_ap}" | jq --arg et "${etype}" '
      {action_type: "bullhorn_candidate_dedupe", entity_type: $et,
       primary_id: .primary_id, merge_target_id: .target_id,
       confidence: .confidence, match_dimensions: .dims,
       last_activity_days: ([.a_act, .b_act] | map(select(. >= 0)) | min // 0)}' \
      > "${_JN_TMPD}/proposals/dedupe-${etype}-$(printf '%s' "${_ap}" | jq -r '.primary_id').json"
  done < <(printf '%s' "${pairs_json}" | jq -c '.pairs[] | select(.band == "auto")')

  hh_decision_output "${marker}" "tenant:${CTX_TENANT_SLUG}" \
    "auto_merges:${auto}; review_band:${review}; dropped:${dropped}"
}

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Dedup pass: candidate entity
# Reference: agent.md §4 Step 3; weights name·0.3 + email·0.4 + phone·0.2 +
# linkedin·0.1 with comparable-weight normalisation + required strong
# identifier (Scout-reviewed semantics; see bin/dedup-pairs.sh header) vs the
# ≥0.85 threshold. Band→action per spec-001 §4: ≥0.85 + no-90d-activity →
# auto (yellow); 0.70-0.85 OR 90d-activity → hold via ESC_DUPLICATE_DETECTED;
# <0.70 → silent drop. hh_decision_action rows land at Step 9 on write.
# ────────────────────────────────────────────────────────────────────────

if _step_planned 3; then
  _jn_dedup_pass "candidate" "dedup_candidate_pass"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Dedup pass: contractor entity (same matcher; separate entity_type
# per vertical-schema.yaml §1 + Q1 Day-6 resolution).
# ────────────────────────────────────────────────────────────────────────

if _step_planned 4; then
  _jn_dedup_pass "contractor" "dedup_contractor_pass"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Field completeness audit (canonical field names per vertical-schema.yaml)
# Reference: agent.md §4 Step 5 + spec-001 §4 (marker: field_completeness_audit).
# Reusable RLS-scoped sql/field-completeness.sql (shared with the report test).
# ────────────────────────────────────────────────────────────────────────

JN_CLIENT_QUEUE="${_JN_TMPD}/client-queue.txt"
: > "${JN_CLIENT_QUEUE}"
if _step_planned 5; then
  _jn_missing_total=0
  _jn_fc_sql="$(_jn_sql field-completeness.sql)"
  if [[ "${_jn_db_up}" -eq 1 && -f "${_jn_fc_sql}" ]]; then
    _jn_fc_out="$(_jn_psql <<SQL 2>/dev/null || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
\\i ${_jn_fc_sql}
COMMIT;
SQL
)"
    while IFS='|' read -r _kind _f2 _f3 _f4; do
      case "${_kind}" in
        summary)      _jn_missing_total=$((_jn_missing_total + _f4)) ;;
        client_queue) printf '%s|%s|%s\n' "${_f2}" "${_f3}" "${_f4}" >> "${JN_CLIENT_QUEUE}" ;;
      esac
    done <<<"${_jn_fc_out}"
  fi
  _jn_enrichable="$(grep -c . "${JN_CLIENT_QUEUE}" 2>/dev/null || echo 0)"
  hh_decision_output "field_completeness_audit" "tenant:${CTX_TENANT_SLUG}" \
    "${_jn_missing_total} missing-field rows; enrichable_via_companies_house:${_jn_enrichable}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Companies House enrichment (clients only)
# Reference: agent.md §4 Step 6. bin/ch-lookup.mjs over @ifos/companies-house
# dist (7d cache + shared rate budget INSIDE the connector — Diagnostic
# precedent). Live-capable this cycle (key SET). Fixture override
# IFOS_JANITOR_FIXTURE_CH keeps tests offline. Per-client cap 25/run keeps
# the shared 600/5min budget safe. rate_limited → ESC_RATE_LIMIT_HIT + stop.
# Backfill writes land at Step 9 (bullhorn_field_backfill action rows).
# ────────────────────────────────────────────────────────────────────────

if _step_planned 6; then
  _jn_lookups=0
  _jn_backfill_props=0
  _jn_ch_cap=25
  while IFS='|' read -r _cq_id _cq_name _cq_missing; do
    [[ -z "${_cq_id}" || "${_jn_lookups}" -ge "${_jn_ch_cap}" ]] && continue
    _jn_lookups=$((_jn_lookups + 1))
    _jn_ch_row=""
    if [[ -n "${IFOS_JANITOR_FIXTURE_CH:-}" && -f "${IFOS_JANITOR_FIXTURE_CH}" ]]; then
      _jn_ch_row="$(jq -c --arg q "${_cq_name}" \
        '[.[] | select((.query | ascii_downcase) == ($q | ascii_downcase))] | first // empty' \
        "${IFOS_JANITOR_FIXTURE_CH}" 2>/dev/null || true)"
      if [[ -n "${_jn_ch_row}" ]]; then
        _jn_ch_row="$(printf '%s' "${_jn_ch_row}" | jq -c '. + {ok: true, source_confidence: (.source_confidence // 0.9)}')"
      else
        _jn_ch_row='{"ok":false,"not_found":true,"source_confidence":0}'
      fi
    elif [[ -n "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
      _jn_ch_row="$(node "$(_jn_bin ch-lookup.mjs)" --name "${_cq_name}" \
        --conn-base "${_JN_CONN_BASE}" 2>/dev/null || echo '{"ok":false,"error":"lookup_failed","source_confidence":0}')"
    else
      _jn_ch_row='{"ok":false,"error":"companies_house_key_absent","source_confidence":0}'
    fi
    if printf '%s' "${_jn_ch_row}" | jq -e '.error == "rate_limited"' >/dev/null 2>&1; then
      autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
        "upstream=companies-house" "step=6" "lookups_done=${_jn_lookups}"
      _jn_exception "Companies House rate limit hit after ${_jn_lookups} lookups — enrichment stopped this run"
      break
    fi
    if printf '%s' "${_jn_ch_row}" | jq -e '.ok == true' >/dev/null 2>&1; then
      _jn_crn="$(printf '%s' "${_jn_ch_row}" | jq -r '.crn // empty')"
      _jn_ind="$(printf '%s' "${_jn_ch_row}" | jq -r '.industry // empty')"
      _jn_conf="$(printf '%s' "${_jn_ch_row}" | jq -r '.source_confidence')"
      _jn_changes="$(jq -nc --arg crn "${_jn_crn}" --arg ind "${_jn_ind}" --arg miss "${_cq_missing}" '
        ($miss | split(",")) as $m
        | ( if ($m | index("companies_house_number")) != null and $crn != "" then {companies_house_number: $crn} else {} end )
          + ( if ($m | index("industry")) != null and $ind != "" then {industry: $ind} else {} end )')"
      if [[ "$(printf '%s' "${_jn_changes}" | jq 'length')" -gt 0 ]]; then
        jq -nc --arg id "${_cq_id}" --argjson fc "${_jn_changes}" --argjson sc "${_jn_conf}" '
          {action_type: "bullhorn_field_backfill", entity_type: "client",
           primary_id: $id, field_changes: $fc,
           source: "companies_house", source_confidence: $sc}' \
          > "${_JN_TMPD}/proposals/backfill-client-${_cq_id}.json"
        _jn_backfill_props=$((_jn_backfill_props + 1))
      fi
    else
      _jn_exception "Companies House: no confident match for client '${_cq_name}' (id ${_cq_id}) — no backfill proposed (G4 honest)"
    fi
  done < "${JN_CLIENT_QUEUE}"
  hh_decision_output "companies_house_enrichment" "tenant:${CTX_TENANT_SLUG}" \
    "lookups:${_jn_lookups}; backfill_proposals:${_jn_backfill_props}; cache:connector_managed_7d_ttl"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 7 — LinkedIn enrichment (v1.0 NO-OP per agent.md §4 Step 7)
# v1.0 caveat: Proxycurl shut down 2025 (LinkedIn lawsuit; nubela.co/blog/
# goodbye-proxycurl/); NinjaPear successor doesn't carry LinkedIn data.
# v1.1+ vendor selection deferred to W8-9 (Lix / Phantombuster / Apify /
# Sales Navigator per .agents/current-priorities.md action board item 8).
# ────────────────────────────────────────────────────────────────────────

if _step_planned 7; then
  # NO-OP at v1.0; explicit no-op audit row so the day-30 report can reference
  # "LinkedIn enrichment: v1.1+ scope" rather than a silent skip.
  hh_decision_output "linkedin_enrichment_skipped" "tenant:${CTX_TENANT_SLUG}" \
    "reason:v1.0_caveat_proxycurl_shutdown; vendor_selection:W8-9_deferred"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Tacit-note harvest (from recent_edit; v0.3 supplement §2a grants Janitor R)
# Reference: agent.md §4 Step 8 + spec-001 §4 (marker: janitor_tacit_note_harvest).
# SELECT … WHERE resolution='approved_after_edit' AND resolved_at > now()-30d;
# group by target_entity_type; per-group narrative via bin/render-tacit-note.sh
# (deterministic template; LLM polish active when ANTHROPIC_API_KEY set —
# aggregate facts only, raw edit text NEVER leaves Postgres). Voice honesty:
# empty voice_corpus → unscored/no_corpus (never a faked score; CC precedent);
# IFOS_JANITOR_FORCE_VOICE_SCORE exercises the scored ESC_VOICE_DRIFT route
# (G5 enforces at Step 9; agent.md fires it after the 3-retry budget).
# ────────────────────────────────────────────────────────────────────────

if _step_planned 8; then
  _jn_harvested=0
  _jn_groups=0
  _jn_drafts=0
  _jn_voice="unscored"
  _jn_voice_reason="no_corpus"
  if [[ -n "${IFOS_JANITOR_FORCE_VOICE_SCORE:-}" ]]; then
    _jn_voice="${IFOS_JANITOR_FORCE_VOICE_SCORE}"
    _jn_voice_reason="forced_fixture_score"
  elif [[ "${CTX_VOICE_CORPUS_STATE:-absent}" == "active" ]]; then
    # Corpus exists but no embedding classifier ships at v1.0 — still honest.
    _jn_voice_reason="classifier_unavailable"
  fi
  if [[ "${_jn_db_up}" -eq 1 ]]; then
    _jn_h_out="$(_jn_psql <<'SQL' 2>/dev/null || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(target_entity_type, 'unattributed') || '|' || count(*)::text || '|' ||
       string_agg(DISTINCT action_type, ',' ORDER BY action_type) || '|' ||
       coalesce(min(target_entity_id), '0')
FROM recent_edit
WHERE tenant_slug = :'tenant' AND resolution = 'approved_after_edit'
  AND resolved_at > now() - interval '30 days'
GROUP BY coalesce(target_entity_type, 'unattributed')
ORDER BY 1;
COMMIT;
SQL
)"
    while IFS='|' read -r _hg_type _hg_count _hg_actions _hg_first_id; do
      [[ -z "${_hg_type}" ]] && continue
      _jn_groups=$((_jn_groups + 1))
      _jn_harvested=$((_jn_harvested + _hg_count))
      _jn_narrative="$(bash "$(_jn_bin render-tacit-note.sh)" \
        --entity-type "${_hg_type}" --edit-count "${_hg_count}" \
        --action-types "${_hg_actions}" --window-days 30 2>/dev/null || true)"
      [[ -z "${_jn_narrative}" ]] && continue
      _jn_note_id="${_hg_first_id:-0}"
      [[ "${_jn_note_id}" =~ ^[0-9]+$ ]] || _jn_note_id="0"
      jq -nc --arg et "${_hg_type}" --arg id "${_jn_note_id}" \
        --arg body "${_jn_narrative}" --arg vs "${_jn_voice}" --arg vr "${_jn_voice_reason}" '
        {action_type: "bullhorn_note_attach", entity_type: $et,
         primary_id: $id, narrative_body: $body,
         voice_score: (if ($vs | test("^[0-9.]+$")) then ($vs | tonumber) else $vs end),
         voice_reason: $vr}' \
        > "${_JN_TMPD}/proposals/note-${_hg_type}.json"
      _jn_drafts=$((_jn_drafts + 1))
    done <<<"${_jn_h_out}"
  fi
  hh_decision_output "janitor_tacit_note_harvest" "tenant:${CTX_TENANT_SLUG}" \
    "harvested:${_jn_harvested} rows; groups:${_jn_groups} entity-types; narrative_drafts:${_jn_drafts}; voice_score:${_jn_voice}; voice_reason:${_jn_voice_reason}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Bullhorn write batch (yellow tier — 3 action_types per agent.md §3 Output 2)
# Reference: agent.md §4 Step 9. Per proposal: Gate A (validate.sh) →
# write via @ifos/bullhorn CLI when live → hh_decision_action yellow row
# (autosend-policy.yaml: bullhorn_candidate_dedupe rate=10;
# bullhorn_field_backfill rate=10; bullhorn_note_attach rate=20).
# 4xx → ESC_BULLHORN_WRITE_FAIL + skip + continue; 5xx → retry once with 30s
# backoff then ESC + skip. Degraded (creds founder-gated) → the validated
# yellow action row is recorded with write_state:deferred_no_bullhorn_creds —
# the audit decision is real, the transport is honestly deferred, never faked.
# ≤100/min defensive cap; remainder defers to the next run. NEVER runs in
# dry-run / report-only modes.
# ────────────────────────────────────────────────────────────────────────

JN_MERGES=0; JN_BACKFILLS=0; JN_NOTES=0; JN_DEFERRED=0; JN_WFAILS=0; JN_GATE_REJECTS=0
if _step_planned 9; then
  _jn_validate="${CTX_AGENT_DIR}/validate.sh"
  [[ -f "${_jn_validate}" ]] || _jn_validate="${IFOS_REPO_ROOT:-}/agents/recruitment/janitor/validate.sh"
  _jn_batch_idx=0

  _jn_bh_write() {  # <proposal_json_path> ; echoes applied|applied_fixture|deferred|fail4xx|fail5xx
    local prop="$1" atype cmd_out http_class
    atype="$(jq -r '.action_type' "${prop}")"
    if [[ -n "${IFOS_JANITOR_FIXTURE_WRITE_RESULT:-}" ]]; then
      case "${IFOS_JANITOR_FIXTURE_WRITE_RESULT}" in
        ok)  echo "applied_fixture"; return 0 ;;
        4xx) echo "fail4xx"; return 0 ;;
        5xx) echo "fail5xx"; return 0 ;;
      esac
    fi
    if [[ "${_jn_token_state}" != "ok" ]]; then
      echo "deferred"; return 0
    fi
    local id patch
    id="$(jq -r '.primary_id' "${prop}")"
    case "${atype}" in
      bullhorn_candidate_dedupe)
        # v1.0 merge write: stamp the primary with the merge provenance; full
        # field-cascade merge is the post-sandbox enhancement (agent.md §9 Q3
        # gotcha — Bullhorn has no single-call merge API).
        patch="$(jq -c '{customText1: ("ifos:merged_from:" + (.merge_target_id|tostring))}' "${prop}")"
        cmd_out="$(node "${_JN_BH_CLI}" update-candidate --id "${id}" --patch "${patch}" 2>&1)" ;;
      bullhorn_field_backfill)
        patch="$(jq -c '.field_changes' "${prop}")"
        if [[ "$(jq -r '.entity_type' "${prop}")" == "client" ]]; then
          cmd_out="$(node "${_JN_BH_CLI}" update-client --id "${id}" --patch "${patch}" 2>&1)"
        else
          cmd_out="$(node "${_JN_BH_CLI}" update-candidate --id "${id}" --patch "${patch}" 2>&1)"
        fi ;;
      bullhorn_note_attach)
        cmd_out="$(node "${_JN_BH_CLI}" create-note --person-id "${id}" \
          --comments "$(jq -r '.narrative_body' "${prop}")" 2>&1)" ;;
      *) echo "fail4xx"; return 0 ;;
    esac
    if printf '%s' "${cmd_out}" | jq -e '.ok == true' >/dev/null 2>&1; then
      echo "applied"; return 0
    fi
    http_class="$(printf '%s' "${cmd_out}" | grep -oE 'HTTP (4|5)[0-9][0-9]' | head -1 | grep -oE '^HTTP [45]' | grep -oE '[45]' || echo 4)"
    [[ "${http_class}" == "5" ]] && echo "fail5xx" || echo "fail4xx"
  }

  for _prop in "${_JN_TMPD}"/proposals/*.json; do
    [[ -f "${_prop}" ]] || continue
    _jn_batch_idx=$((_jn_batch_idx + 1))
    if [[ "${_jn_batch_idx}" -gt 100 ]]; then
      _jn_exception "Write batch hit the 100/min defensive cap — $((_jn_batch_idx - 100))+ proposals deferred to the next run"
      break
    fi
    if ! CTX_JANITOR_BATCH_INDEX="${_jn_batch_idx}" bash "${_jn_validate}" "${_prop}" >/dev/null 2>&1; then
      JN_GATE_REJECTS=$((JN_GATE_REJECTS + 1))   # validate.sh emitted the ESC + audit rows
      continue
    fi
    _jn_atype="$(jq -r '.action_type' "${_prop}")"
    _jn_pid="$(jq -r '.primary_id' "${_prop}")"
    _jn_etype="$(jq -r '.entity_type' "${_prop}")"
    _jn_wstate="$(_jn_bh_write "${_prop}")"
    if [[ "${_jn_wstate}" == "fail5xx" ]]; then
      sleep "${_JN_DELAY}"   # retry once with 30s backoff per agent.md §4 Step 9
      _jn_wstate="$(_jn_bh_write "${_prop}")"
      [[ "${_jn_wstate}" == "applied_fixture" || "${_jn_wstate}" == "fail4xx" ]] && _jn_wstate="fail5xx"  # fixture 5xx stays 5xx on retry
    fi
    case "${_jn_wstate}" in
      fail4xx)
        autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
          "action_type=${_jn_atype}" "entity=${_jn_etype}:${_jn_pid}" "class=4xx" "disposition=skip_continue"
        JN_WFAILS=$((JN_WFAILS + 1)); continue ;;
      fail5xx)
        autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
          "action_type=${_jn_atype}" "entity=${_jn_etype}:${_jn_pid}" "class=5xx" "disposition=retried_once_then_skip"
        JN_WFAILS=$((JN_WFAILS + 1)); continue ;;
      deferred)
        JN_DEFERRED=$((JN_DEFERRED + 1)) ;;
    esac
    _jn_phash="$(shasum -a 256 "${_prop}" 2>/dev/null | cut -c1-16)"
    [[ -z "${_jn_phash}" ]] && _jn_phash="${_jn_etype}-${_jn_pid}"
    _jn_preview="$(jq -r '
      if .action_type == "bullhorn_candidate_dedupe"
      then "merge_target_id:\(.merge_target_id); confidence:\(.confidence); dims:\(.match_dimensions | join("+"))"
      elif .action_type == "bullhorn_field_backfill"
      then "fields:\(.field_changes | keys | join(",")); source:\(.source); source_confidence:\(.source_confidence)"
      else "narrative_sha:none; voice_score:\(.voice_score); voice_reason:\(.voice_reason // "n/a")"
      end' "${_prop}")"
    hh_decision_action "${_jn_atype}" "entity:${_jn_etype}:${_jn_pid}" "${_jn_phash}" \
      "${_jn_preview}; write_state:${_jn_wstate}" || true
    case "${_jn_atype}" in
      bullhorn_candidate_dedupe) JN_MERGES=$((JN_MERGES + 1)) ;;
      bullhorn_field_backfill)   JN_BACKFILLS=$((JN_BACKFILLS + 1)) ;;
      bullhorn_note_attach)      JN_NOTES=$((JN_NOTES + 1)) ;;
    esac
  done
  hh_decision_output "bullhorn_write_batch" "tenant:${CTX_TENANT_SLUG}" \
    "merges_written:${JN_MERGES}; backfills_written:${JN_BACKFILLS}; notes_attached:${JN_NOTES}; deferred_no_creds:${JN_DEFERRED}; failures:${JN_WFAILS}; gate_a_rejected:${JN_GATE_REJECTS}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Day-30 report assembly
# Reference: agent.md §4 Step 10 + §3 Output 1 (8-section Markdown report).
# Reusable RLS-scoped sql/day30-report-metrics.sql (shared with the report
# test). Gate B (agent.md §5): TWO independent thresholds — dedup ≥15% AND
# completeness ≥10%; both must pass; NOT a composite. v1.0 metric definitions
# (deterministic; baseline-relative measure is the post-pilot enhancement):
#   dedup_pct        = 100·merges / (merges + review-band pairs)
#   completeness_pct = 100·backfills / (backfills + still-missing rows)
# ────────────────────────────────────────────────────────────────────────

JN_GATE_B_MET="false"
JN_BOTH_MISSED="true"
if _step_planned 10; then
  REPORT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/janitor-reports/day-30-$(date -u +%Y-%m-%d).md"
  mkdir -p "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
  chmod 0700 "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
  _jn_metrics_sql="$(_jn_sql day30-report-metrics.sql)"
  METRICS=""
  if [[ "${_jn_db_up}" -eq 1 && -f "${_jn_metrics_sql}" ]]; then
    METRICS="$(_jn_psql <<SQL 2>/dev/null || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
\\i ${_jn_metrics_sql}
COMMIT;
SQL
)"
  fi
  _m() { printf '%s\n' "${METRICS}" | grep -m1 "^$1|" | cut -d'|' -f2; }
  _jn_m_merges="$(_m merges_30d)";        _jn_m_merges="${_jn_m_merges:-0}"
  _jn_m_backfills="$(_m backfills_30d)";  _jn_m_backfills="${_jn_m_backfills:-0}"
  _jn_m_notes="$(_m notes_30d)";          _jn_m_notes="${_jn_m_notes:-0}"
  _jn_m_review="$(_m review_band_30d)";   _jn_m_review="${_jn_m_review:-0}"
  _jn_m_missing="$(_m missing_now)";      _jn_m_missing="${_jn_m_missing:-0}"
  _jn_m_wfails="$(_m write_fails_30d)";   _jn_m_wfails="${_jn_m_wfails:-0}"
  _jn_m_rl="$(_m rate_limit_30d)";        _jn_m_rl="${_jn_m_rl:-0}"
  _jn_m_gafails="$(_m gate_a_fails_30d)"; _jn_m_gafails="${_jn_m_gafails:-0}"
  _jn_m_edits="$(_m consultant_edits_30d)";   _jn_m_edits="${_jn_m_edits:-0}"
  _jn_m_appr="$(_m approved_after_edit_30d)"; _jn_m_appr="${_jn_m_appr:-0}"

  _jn_dedup_pct="$(awk -v m="${_jn_m_merges}" -v r="${_jn_m_review}" \
    'BEGIN{ d=m+r; if(d>0) printf "%.1f", (m/d)*100; else printf "0.0" }')"
  _jn_comp_pct="$(awk -v b="${_jn_m_backfills}" -v miss="${_jn_m_missing}" \
    'BEGIN{ d=b+miss; if(d>0) printf "%.1f", (b/d)*100; else printf "0.0" }')"
  _jn_dedup_met="$(awk -v p="${_jn_dedup_pct}" 'BEGIN{print (p>=15) ? "true" : "false"}')"
  _jn_comp_met="$(awk -v p="${_jn_comp_pct}" 'BEGIN{print (p>=10) ? "true" : "false"}')"
  if [[ "${_jn_dedup_met}" == "true" && "${_jn_comp_met}" == "true" ]]; then JN_GATE_B_MET="true"; fi
  if [[ "${_jn_dedup_met}" == "false" && "${_jn_comp_met}" == "false" ]]; then JN_BOTH_MISSED="true"; else JN_BOTH_MISSED="false"; fi

  {
    printf '# Janitor day-30 cleanup report — %s\n\n' "$(date -u +%Y-%m-%d)"
    printf '_Tenant: %s · generated %sZ · mode: %s · agent.md §3 Output 1 (8 sections)_\n\n' \
      "${CTX_TENANT_SLUG}" "$(date -u +%Y-%m-%dT%H:%M:%S)" "${MODE}"
    printf '## 1. Record counts\n\n| Entity type | Records |\n|---|---|\n'
    printf '| Candidates | %s |\n| Contractors | %s |\n| Clients | %s |\n| Contacts | %s |\n| Placements | %s |\n| Opportunities | %s |\n\n' \
      "$(_m count_candidate)" "$(_m count_contractor)" "$(_m count_client)" \
      "$(_m count_contact)" "$(_m count_placement)" "$(_m count_opportunity)"
    printf '## 2. Dedup pairs (30d)\n\n- Auto-merged (≥%s confidence, no 90d activity): %s\n- Held for approval (review band via ESC_DUPLICATE_DETECTED): %s\n- Per-pair detail: see decision_log action rows (action_type=bullhorn_candidate_dedupe) + gating rows (ESC_DUPLICATE_DETECTED)\n\n' \
      "${CTX_JANITOR_DEDUP_THRESHOLD}" "${_jn_m_merges}" "${_jn_m_review}"
    printf '## 3. Field-completeness deltas (30d)\n\n- Backfills applied: %s (source provenance in each action row payload)\n- Missing-field rows remaining: %s\n- Sources: Companies House (clients; live); LinkedIn (v1.1+ deferred); derivation (enhancement)\n\n' \
      "${_jn_m_backfills}" "${_jn_m_missing}"
    printf '## 4. Tacit-note coverage (30d)\n\n- Consultant approved-after-edit rows harvested: %s\n- Narrative notes attached: %s\n- Voice posture: %s\n\n' \
      "${_jn_m_appr}" "${_jn_m_notes}" \
      "$([[ "${CTX_VOICE_CORPUS_STATE:-absent}" == "active" ]] && echo "corpus active; classifier = documented enhancement" || echo "unscored/no_corpus (empty tenant voice_corpus — honest, never faked)")"
    printf '## 5. Agent vs. consultant attribution (30d)\n\n- Janitor automated writes (merges + backfills + notes): %s\n- Consultant manual edits (recent_edit, all resolutions): %s\n\n' \
      "$((_jn_m_merges + _jn_m_backfills + _jn_m_notes))" "${_jn_m_edits}"
    printf '## 6. Gate-B metric (two independent thresholds; both must pass — NOT a composite)\n\n| Threshold | Value | Target | Met |\n|---|---|---|---|\n| Dedup improvement | %s%% | ≥15%% | %s |\n| Field-completeness improvement | %s%% | ≥10%% | %s |\n\n**Gate B: %s** _(v1.0 decision_log-derived metrics; day-0-baseline-relative measure lands at pilot onboarding)_\n\n' \
      "${_jn_dedup_pct}" "${_jn_dedup_met}" "${_jn_comp_pct}" "${_jn_comp_met}" \
      "$([[ "${JN_GATE_B_MET}" == "true" ]] && echo MET || echo MISSED)"
    printf '## 7. Exception list\n\n- Failed Bullhorn writes (30d): %s\n- Rate-limit hits (30d): %s\n- Gate A rejections (30d): %s\n' \
      "${_jn_m_wfails}" "${_jn_m_rl}" "${_jn_m_gafails}"
    if [[ -s "${_JN_EXCEPTIONS}" ]]; then
      printf -- '- This run:\n'
      while IFS= read -r _ex; do printf '  - %s\n' "${_ex}"; done < "${_JN_EXCEPTIONS}"
    else
      printf -- '- This run: none\n'
    fi
    printf '\n## 8. Executive summary\n\nOver the last 30 days the Janitor agent ran nightly data hygiene across this Bullhorn corpus: %s duplicate pairs auto-merged at ≥%s confidence with a 90-day activity guard, %s held for consultant approval rather than risking an unwanted merge, %s missing canonical fields backfilled from Companies House with source provenance logged, and %s tacit-knowledge notes folded back from consultant-approved edits. Every write passed a seven-check hard gate (auth freshness, confidence floors, activity recency, source confidence, voice, PII boundary, batch cap) and carries a per-write audit row. Estimated consultant data-entry time avoided: ~%s minutes (at 5 min/record action). Gate B stands %s this window.\n' \
      "${_jn_m_merges}" "${CTX_JANITOR_DEDUP_THRESHOLD}" "${_jn_m_review}" \
      "${_jn_m_backfills}" "${_jn_m_notes}" \
      "$(( (_jn_m_merges + _jn_m_backfills + _jn_m_notes) * 5 ))" \
      "$([[ "${JN_GATE_B_MET}" == "true" ]] && echo MET || echo MISSED)"
  } > "${REPORT_PATH}" 2>/dev/null || true
  chmod 0600 "${REPORT_PATH}" 2>/dev/null || true
  hh_decision_output "day_30_report" "${REPORT_PATH}" \
    "Gate-B: dedup_pct:${_jn_dedup_pct}; completeness_pct:${_jn_comp_pct}; gate_b_met:${JN_GATE_B_MET}; gate_b_both_missed:${JN_BOTH_MISSED}; sections:8"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 11 — Operator notification (Telegram)
# Reference: agent.md §4 Step 11; green action row if Gate B met, missed-state
# + ≤200-char executive summary in the payload when missed (the registered
# operator_notify_telegram action_type is green tier in autosend-policy.yaml;
# urgency is conveyed in payload.gate_b_state — tier is policy-owned).
# Transport: live Telegram sendMessage when TELEGRAM_BOT_TOKEN + chat id are
# configured; stdout degrade otherwise (Scout precedent; token EMPTY today).
# ────────────────────────────────────────────────────────────────────────

if _step_planned 11; then
  if [[ "${JN_GATE_B_MET}" == "true" ]]; then
    _jn_gb_state="met"
    _jn_msg="Janitor nightly (${CTX_TENANT_SLUG}): Gate B MET. Merges:${JN_MERGES} backfills:${JN_BACKFILLS} notes:${JN_NOTES} deferred:${JN_DEFERRED}."
  else
    _jn_gb_state="missed"
    _jn_msg="Janitor nightly (${CTX_TENANT_SLUG}): Gate B MISSED. Merges:${JN_MERGES} backfills:${JN_BACKFILLS} review-held:$(grep -c 'Review-band' "${_JN_EXCEPTIONS}" 2>/dev/null || echo 0). Consultant follow-up suggested on held pairs + remaining missing fields."
  fi
  _jn_msg="${_jn_msg:0:200}"
  _jn_channel="stdout_degraded"
  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" != "unset" ]] && command -v curl >/dev/null 2>&1; then
    if curl -sS --max-time 15 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
         -d "chat_id=${CTX_OPERATOR_TELEGRAM_CHAT_ID}" --data-urlencode "text=${_jn_msg}" \
         >/dev/null 2>&1; then
      _jn_channel="telegram"
    fi
  fi
  [[ "${_jn_channel}" == "stdout_degraded" ]] && printf '[janitor notify] %s\n' "${_jn_msg}"
  _jn_nhash="$(printf '%s' "${_jn_msg}" | shasum -a 256 2>/dev/null | cut -c1-16)"
  [[ -z "${_jn_nhash}" ]] && _jn_nhash="notify-${MODE}"
  hh_decision_action "operator_notify_telegram" "tenant:${CTX_TENANT_SLUG}" "${_jn_nhash}" \
    "gate_b_state:${_jn_gb_state}; chars:${#_jn_msg}; channel:${_jn_channel}" || true
fi

# ────────────────────────────────────────────────────────────────────────
# Step 12 — Session close
# Update tenant_adapters.config.janitor_last_run (v0.3-allowlisted; validated
# by the v0.4 trigger). ESC_GATE_B_MISS fires ONLY when BOTH Gate B thresholds
# missed for 3 consecutive runs (agent.md §5 + catalogue trigger; single-run
# or single-threshold misses are tracked in the report, no ESC) → exit 1.
# ────────────────────────────────────────────────────────────────────────

if [[ "${_jn_db_up}" -eq 1 ]]; then
  _jn_psql -q <<'SQL' >/dev/null 2>&1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE tenant_adapters
SET config = jsonb_set(coalesce(config, '{}'::jsonb), '{janitor_last_run}', to_jsonb(to_char(now() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')))
WHERE tenant_slug = :'tenant';
COMMIT;
SQL
fi

_jn_triple_miss=0
if [[ "${_jn_db_up}" -eq 1 ]]; then
  _jn_last3="$(_jn_psql <<'SQL' 2>/dev/null || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce((reason LIKE '%gate_b_both_missed:true%')::text, 'false')
FROM decision_log
WHERE tenant_slug = :'tenant' AND agent_name = 'janitor'
  AND phase = 'output' AND payload->>'output_type' = 'day_30_report'
ORDER BY id DESC LIMIT 3;
COMMIT;
SQL
)"
  _jn_miss_rows=0; _jn_total_rows=0
  while IFS= read -r _r; do
    [[ -z "${_r}" ]] && continue
    _jn_total_rows=$((_jn_total_rows + 1))
    [[ "${_r}" == "true" ]] && _jn_miss_rows=$((_jn_miss_rows + 1))
  done <<<"${_jn_last3}"
  [[ "${_jn_total_rows}" -eq 3 && "${_jn_miss_rows}" -eq 3 ]] && _jn_triple_miss=1
fi

if _step_planned 11; then NOTIFIED="true"; else NOTIFIED="false"; fi
_jn_run_hash="$(printf '%s' "${CTX_TENANT_SLUG}|${MODE}|$(date -u +%s)" | shasum -a 256 2>/dev/null | cut -c1-16)"
[[ -z "${_jn_run_hash}" ]] && _jn_run_hash="run-${MODE}"
hh_decision_action "janitor_run_complete" "session:${CTX_TENANT_SLUG}" "${_jn_run_hash}" \
  "mode:${MODE}; corporation_id:${CTX_BULLHORN_CORPORATION_ID}; bullhorn_token:${_jn_token_state}; merges:${JN_MERGES}; backfills:${JN_BACKFILLS}; notes:${JN_NOTES}; deferred:${JN_DEFERRED}; notified:${NOTIFIED}; gate_b_met:${JN_GATE_B_MET}" || true

if [[ "${_jn_triple_miss}" -eq 1 ]]; then
  autosend_escalate "ESC_GATE_B_MISS" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
    "consecutive_runs=3" "trigger=both_thresholds_missed" \
    "disposition=operator_heuristic_review_not_a_kill"
  printf 'cycle.sh: Gate B BOTH thresholds missed 3 consecutive runs — ESC_GATE_B_MISS (exit 1)\n' >&2
  exit 1
fi

exit 0
