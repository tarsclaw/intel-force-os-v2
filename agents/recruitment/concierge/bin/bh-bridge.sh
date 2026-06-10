#!/usr/bin/env bash
# Concierge — bh-bridge.sh (local Bullhorn shim; W10-13 build slice)
#
# WHY THIS EXISTS (parallel-conflict rule): packages/mcp-connectors/bullhorn is
# owned by the sibling Janitor branch this build cycle (unmerged) — Concierge
# MUST NOT modify it. ALL Concierge Bullhorn calls route through this shim,
# which is the SINGLE RECONCILIATION POINT: this live branch is reconciled to
# the AGREED @ifos/bullhorn CLI contract (orchestrator ruling,
# docs/features/agent-build/04-reviews/review-scribe.md) + the Janitor
# branch's ACTUAL cli.ts surface (read 2026-06-10).
#
# ── ACTUAL CONNECTOR CLI SURFACE (Janitor branch cli.ts; reconciled) ──────
#   node dist/cli.js check-auth
#     → {ok, creds_present, tokens_present, corporation_id, region}
#       NETWORK-FREE readiness probe. ok=true only when creds AND a token
#       bundle are both present (a refresh could succeed). This shim uses it
#       for mode resolution: not-provisioned → fixture mode + refresh reason
#       "unavailable" (NO ESC); provisioned-but-failed refresh → reason
#       "failed" (context.sh fires ESC_BULLHORN_AUTH).
#   node dist/cli.js refresh
#     → {ok, oauth_expires_at_ms, token_state:"refreshed"|"fresh"}
#   node dist/cli.js list-candidates|list-contacts|list-clients
#       [--since <ISO>] [--start N] [--count N]
#     → bare array of {entity_type, entity_id, data} normalised rows
#   node dist/cli.js update-entity --entity-type Candidate|ClientContact|
#       JobOrder|Placement --id <N> --patch <json>
#     → {ok, updated, entity_type, id}                       STATE-CHANGING
#   node dist/cli.js create-note (--person-id <N> | --entity-type <T>
#       --entity-id <N>) (--comments <text> | --body-file <path>)
#       [--title <text>] [--action Note]
#     → {ok, note_id}; unsupported entity → {ok:false,
#       reason:"unsupported_entity"}                          STATE-CHANGING
#
# Live-mode requirements (connector contract): Bullhorn ids are NUMERIC
# (callers pass numeric strings; fixture ids like "CAND-R" are fixture-only).
# Token bundle path: <IFOS_TOKEN_DIR | ~/.ifos-local-vault/dev-sandbox>/
# bullhorn-tokens-<corporation_id>.json — IFOS_TOKEN_DIR is the per-tenant
# token-path mechanism per the agreed contract.
#
# ── SHIM-SIDE MAPPINGS (Concierge verb → connector command) ───────────────
#   get-candidate --id N   → list-candidates, id-filtered shim-side (--count
#   get-client    --id N   → list-clients     500 single page; see extension
#   get-contact   --id N   → list-contacts    note below)
#   create-activity-log --candidate N --note T
#                          → create-note --entity-type Candidate --entity-id N
#                            --body-file <tmp> --action Note; note_id parsed →
#                            reported as activity_id
#   patch-state --type candidate|placement --id N --state S
#                          → update-entity --entity-type Candidate|Placement
#                            --id N --patch {"status":S}; {ok,updated} parsed
#
# ── REQUIRED CONNECTOR EXTENSIONS (honest — NO equivalent exists today) ───
#   1. get-by-id convenience — no direct single-entity GET; the shim filters
#      a single list-* page (--count 500) by entity_id, which misses entities
#      outside that page. A real get-by-id (Lucene id: query) is required
#      before live Concierge volume.
#   2. Placement read — the connector has NO Placement fetch surface at all
#      (list or get). get-placement serves the Postgres `entities` cache in
#      BOTH modes until a list-placements/get-placement command lands.
#   3. list-state-changes --since <ISO> — lifecycle state-transition events;
#      no connector equivalent. Served from the `entities` cache
#      (lifecycle_event rows) in BOTH modes.
#   4. list-nurture-due — 7/30/90-day post-start nurture sweep; no connector
#      equivalent. Served from the `entities` cache (placement rows) in BOTH
#      modes.
#   None of these are invented here — each is named, served honestly from the
#   cache, and queued as a connector extension (tracked in STATUS post-merge).
#
# ── MODES ─────────────────────────────────────────────────────────────────
# live    — connector dist/cli.js present AND the NETWORK-FREE `check-auth`
#           probe returns ok=true (creds in env + token bundle on disk).
#           Commands route to the connector per the mappings above. Creds are
#           EMPTY in the dev sandbox (verified 2026-06-10) so this branch is
#           built but unexercised against live Bullhorn.
# fixture — otherwise: serve from / write to the seeded `entities` rows
#           (the Bullhorn cache per spec-004 §2) in Postgres under RLS.
#           Fixtures prove all Concierge logic against these rows — the
#           proven path.
#
# Env: CTX_TENANT_SLUG (required), IFOS_DB_URL (fixture/cache commands),
#      IFOS_REPO_ROOT, IFOS_TOKEN_DIR (live token bundle dir override).
# Output: one JSON document on stdout. Exit 0 ok; 3 = entity not found;
#         2 = usage/env error; 1 = backend failure.

set -uo pipefail

if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf '{"ok":false,"error":"CTX_TENANT_SLUG unset"}\n' >&2
  exit 2
fi

CMD="${1:-}"
shift || true

_BH_CLI="${IFOS_REPO_ROOT:-}/packages/mcp-connectors/bullhorn/dist/cli.js"

# Mode resolution via the NETWORK-FREE check-auth probe (agreed contract):
# live only when the CLI exists AND check-auth says a refresh could succeed.
_BH_MODE="fixture"
_BH_AUTH_JSON="{}"
if [[ -f "${_BH_CLI}" ]] && command -v node >/dev/null 2>&1; then
  _BH_AUTH_JSON="$(node "${_BH_CLI}" check-auth 2>/dev/null || echo '{}')"
  if [[ "$(printf '%s' "${_BH_AUTH_JSON}" | jq -r '.ok // false' 2>/dev/null)" == "true" ]]; then
    _BH_MODE="live"
  fi
fi
# Test override (fixture suites force fixture mode even if a CLI appears later).
[[ "${IFOS_BH_FORCE_FIXTURE:-0}" == "1" ]] && _BH_MODE="fixture"

# Tiny arg parser: --key value pairs into ARGS[<key>] (dashes → underscores).
declare -A ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --*)
      _k="${1#--}"; _k="${_k//-/_}"
      ARGS["${_k}"]="${2:-}"
      shift 2 || break ;;
    *) shift ;;
  esac
done

# RLS-scoped psql for cache-backed commands (fixture mode + the documented
# REQUIRED-CONNECTOR-EXTENSION commands in both modes). All SQL on stdin;
# tenant + args via psql vars (no injection).
_need_db() {
  if [[ -z "${IFOS_DB_URL:-}" ]] || ! command -v psql >/dev/null 2>&1; then
    printf '{"ok":false,"error":"cache-backed command needs IFOS_DB_URL + psql","mode":"%s"}\n' "${_BH_MODE}" >&2
    exit 2
  fi
}
_q() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" "$@"; }

# Cache read shared by fixture-mode get-* and the no-connector-equivalent
# get-placement (REQUIRED CONNECTOR EXTENSION 2).
_cache_get() {  # <entity_type> <entity_id>
  _need_db
  local _row
  _row="$(_q --set=etype="$1" --set=eid="$2" <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT data::text FROM entities
WHERE entity_type = :'etype' AND entity_id = :'eid'
LIMIT 1;
COMMIT;
SQL
)" || { printf '{"ok":false,"error":"db_query_failed"}\n' >&2; exit 1; }
  _row="$(printf '%s\n' "${_row}" | grep -m1 '^{' || true)"
  if [[ -z "${_row}" ]]; then
    printf '{}\n'
    exit 3
  fi
  printf '%s\n' "${_row}"
}

case "${CMD}" in

  refresh)
    if [[ "${_BH_MODE}" == "live" ]]; then
      # Provisioned (check-auth ok=true) → real refresh. Pass the agreed
      # shape through: {ok, oauth_expires_at_ms, token_state}.
      _out="$(node "${_BH_CLI}" refresh 2>/dev/null || true)"
      if [[ "$(printf '%s' "${_out}" | jq -r '.ok // false' 2>/dev/null)" == "true" ]]; then
        printf '%s\n' "${_out}"
      else
        # Provisioned but the refresh FAILED — a REAL auth failure.
        # context.sh maps reason=failed → CTX_BULLHORN_TOKEN_STATE=failed +
        # ESC_BULLHORN_AUTH (blocking).
        printf '{"ok":false,"reason":"failed","mode":"live"}\n'
      fi
    else
      # Not provisioned (CLI absent or check-auth ok=false) → unavailable.
      # Honest degraded answer; NO ESC fires for the known-absent case.
      _cp="$(printf '%s' "${_BH_AUTH_JSON}" | jq -r '.creds_present // false' 2>/dev/null || echo false)"
      _tp="$(printf '%s' "${_BH_AUTH_JSON}" | jq -r '.tokens_present // false' 2>/dev/null || echo false)"
      printf '{"ok":false,"reason":"unavailable","mode":"fixture","creds_present":%s,"tokens_present":%s}\n' \
        "${_cp}" "${_tp}"
    fi
    exit 0
    ;;

  get-candidate|get-client|get-contact)
    _etype="${CMD#get-}"
    _eid="${ARGS[id]:-}"
    if [[ -z "${_eid}" ]]; then
      printf '{"ok":false,"error":"--id required"}\n' >&2; exit 2
    fi
    if [[ "${_BH_MODE}" == "live" ]]; then
      # Id-filter over the EXISTING list-* commands (no get-by-id in the
      # connector — REQUIRED CONNECTOR EXTENSION 1; single --count 500 page).
      # Live ids are NUMERIC per the connector contract.
      case "${CMD}" in
        get-candidate) _list_cmd="list-candidates" ;;
        get-client)    _list_cmd="list-clients" ;;
        get-contact)   _list_cmd="list-contacts" ;;
      esac
      _row="$(node "${_BH_CLI}" "${_list_cmd}" --count 500 2>/dev/null \
        | jq -c --arg id "${_eid}" '[ .[] | select(.entity_id == $id) ][0].data // empty' 2>/dev/null || true)"
      if [[ -z "${_row}" ]]; then
        printf '{}\n'
        exit 3
      fi
      printf '%s\n' "${_row}"
    else
      _cache_get "${_etype}" "${_eid}"
    fi
    ;;

  get-placement)
    # REQUIRED CONNECTOR EXTENSION 2: the connector has NO Placement read
    # surface — serve the entities cache in BOTH modes (honest, documented).
    _eid="${ARGS[id]:-}"
    if [[ -z "${_eid}" ]]; then
      printf '{"ok":false,"error":"--id required"}\n' >&2; exit 2
    fi
    _cache_get "placement" "${_eid}"
    ;;

  create-activity-log)
    _cand="${ARGS[candidate]:-}"
    _note="${ARGS[note]:-}"
    if [[ -z "${_cand}" || -z "${_note}" ]]; then
      printf '{"ok":false,"error":"--candidate and --note required"}\n' >&2; exit 2
    fi
    if [[ "${_BH_MODE}" == "live" ]]; then
      # Map to the connector's create-note (agreed contract): the activity
      # log is a Bullhorn Note on the Candidate. Live ids are NUMERIC.
      _tmp_note="$(mktemp)" || { printf '{"ok":false,"error":"mktemp_failed"}\n' >&2; exit 1; }
      chmod 0600 "${_tmp_note}" 2>/dev/null || true
      printf '%s' "${_note}" > "${_tmp_note}"
      _out="$(node "${_BH_CLI}" create-note --entity-type Candidate \
        --entity-id "${_cand}" --body-file "${_tmp_note}" --action Note 2>/dev/null || true)"
      rm -f "${_tmp_note}" 2>/dev/null || true
      if [[ "$(printf '%s' "${_out}" | jq -r '.ok // false' 2>/dev/null)" == "true" ]]; then
        _nid="$(printf '%s' "${_out}" | jq -r '.note_id // ""' 2>/dev/null)"
        printf '{"ok":true,"activity_id":"%s","mode":"live"}\n' "${_nid}"
      else
        printf '{"ok":false,"error":"create_note_failed"}\n' >&2; exit 1
      fi
    else
      _need_db
      _alid="al-$(date -u +%Y%m%dT%H%M%SZ)-$$"
      _q --set=alid="${_alid}" --set=cand="${_cand}" --set=note="${_note}" <<'SQL' >/dev/null || {
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
INSERT INTO entities (tenant_slug, entity_type, entity_id, data)
VALUES (:'tenant', 'bullhorn_activity_log', :'alid',
        jsonb_build_object('candidate_id', :'cand', 'note', :'note',
                           'written_at', now()::text, 'mode', 'fixture'))
ON CONFLICT (tenant_slug, entity_type, entity_id) DO NOTHING;
COMMIT;
SQL
        printf '{"ok":false,"error":"activity_log_insert_failed"}\n' >&2; exit 1; }
      printf '{"ok":true,"activity_id":"%s","mode":"fixture"}\n' "${_alid}"
    fi
    ;;

  patch-state)
    _etype="${ARGS[type]:-candidate}"
    _eid="${ARGS[id]:-}"
    _state="${ARGS[state]:-}"
    if [[ -z "${_eid}" || -z "${_state}" ]]; then
      printf '{"ok":false,"error":"--id and --state required"}\n' >&2; exit 2
    fi
    if [[ "${_BH_MODE}" == "live" ]]; then
      # Map to the connector's update-entity (agreed contract). Live ids are
      # NUMERIC; the state patch targets Bullhorn's `status` field.
      case "${_etype}" in
        candidate) _bh_et="Candidate" ;;
        placement) _bh_et="Placement" ;;
        *)
          printf '{"ok":false,"error":"patch-state --type must be candidate|placement"}\n' >&2; exit 2 ;;
      esac
      _patch="$(jq -nc --arg s "${_state}" '{status:$s}')"
      _out="$(node "${_BH_CLI}" update-entity --entity-type "${_bh_et}" \
        --id "${_eid}" --patch "${_patch}" 2>/dev/null || true)"
      if [[ "$(printf '%s' "${_out}" | jq -r '.ok // false' 2>/dev/null)" == "true" \
            && "$(printf '%s' "${_out}" | jq -r '.updated // false' 2>/dev/null)" == "true" ]]; then
        printf '{"ok":true,"mode":"live"}\n'
      else
        printf '{"ok":false,"error":"patch_state_failed"}\n' >&2; exit 1
      fi
    else
      _need_db
      _q --set=etype="${_etype}" --set=eid="${_eid}" --set=newstate="${_state}" <<'SQL' >/dev/null || {
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE entities
SET data = jsonb_set(data, '{state}', to_jsonb(:'newstate'::text)),
    version = version + 1, updated_at = now()
WHERE entity_type = :'etype' AND entity_id = :'eid';
COMMIT;
SQL
        printf '{"ok":false,"error":"patch_state_failed"}\n' >&2; exit 1; }
      printf '{"ok":true,"mode":"fixture"}\n'
    fi
    ;;

  list-state-changes)
    # REQUIRED CONNECTOR EXTENSION 3: no connector equivalent — entities
    # cache (lifecycle_event rows) serves BOTH modes.
    _need_db
    _since="${ARGS[since]:-1970-01-01T00:00:00Z}"
    _out="$(_q --set=since="${_since}" <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(jsonb_agg(data ORDER BY (data->>'event_timestamp_iso')), '[]'::jsonb)::text
FROM entities
WHERE entity_type = 'lifecycle_event'
  AND (data->>'event_timestamp_iso')::timestamptz > (:'since')::timestamptz;
COMMIT;
SQL
)" || { printf '{"ok":false,"error":"db_query_failed"}\n' >&2; exit 1; }
    printf '%s\n' "$(printf '%s\n' "${_out}" | grep -m1 '^\[' || echo '[]')"
    ;;

  list-nurture-due)
    # REQUIRED CONNECTOR EXTENSION 4: no connector equivalent — placements
    # whose start_date is exactly 7/30/90 days ago, from the entities cache
    # in BOTH modes.
    _need_db
    _out="$(_q <<'SQL'
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(jsonb_agg(jsonb_build_object(
  'event_type', (current_date - (data->>'start_date')::date)::int || '-day-check-in',
  'candidate_id', data->>'candidate_id',
  'placement_id', entity_id,
  'contact_id', data->>'contact_id',
  'client_id', data->>'client_id',
  'state_from', coalesce(data->>'state',''),
  'state_to', coalesce(data->>'state',''),
  'event_timestamp_iso', to_char(now() AT TIME ZONE 'utc','YYYY-MM-DD"T"HH24:MI:SS"Z"')
)), '[]'::jsonb)::text
FROM entities
WHERE entity_type = 'placement'
  AND data ? 'start_date'
  AND (current_date - (data->>'start_date')::date) IN (7, 30, 90);
COMMIT;
SQL
)" || { printf '{"ok":false,"error":"db_query_failed"}\n' >&2; exit 1; }
    printf '%s\n' "$(printf '%s\n' "${_out}" | grep -m1 '^\[' || echo '[]')"
    ;;

  *)
    printf '{"ok":false,"error":"unknown command: %s"}\n' "${CMD}" >&2
    exit 2
    ;;
esac
