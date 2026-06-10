#!/usr/bin/env bash
# Concierge — bh-bridge.sh (local Bullhorn shim; W10-13 build slice)
#
# WHY THIS EXISTS (parallel-conflict rule): packages/mcp-connectors/bullhorn is
# owned by the sibling Janitor branch this build cycle (unmerged) — Concierge
# MUST NOT modify it. ALL Concierge Bullhorn calls route through this shim,
# which is the SINGLE RECONCILIATION POINT at review: when the Janitor branch
# merges its connector CLI, only the `live` branch below gets reconciled.
#
# ── EXPECTED CONNECTOR CLI SURFACE (the contract to reconcile) ────────────
# Mirrors the cash-conductor connector-CLI invocation pattern
# (node packages/mcp-connectors/<pkg>/dist/cli.js <cmd> [args] → one JSON doc
# on stdout; .ok / entity payload; non-zero exit on hard failure):
#
#   node dist/cli.js refresh
#     → {"ok":true|false}                                  (OAuth refresh)
#   node dist/cli.js get-candidate   --id <bullhorn-id>
#     → {"id","name","email","state","comms_history":[...]}
#   node dist/cli.js get-placement   --id <bullhorn-id>
#     → {"id","role","client_id","start_date","placement_value",...}
#   node dist/cli.js get-client      --id <bullhorn-id>
#     → {"id","company","primary_contact_id",...}
#   node dist/cli.js get-contact     --id <bullhorn-id>
#     → {"id","name","email",...}
#   node dist/cli.js create-activity-log --candidate <id> --note <text>
#     → {"ok":true,"activity_id":"<bullhorn-activity-id>"}  (POST; green tier)
#   node dist/cli.js patch-state     --type <candidate|placement> --id <id> --state <next>
#     → {"ok":true}                                         (conditional PATCH)
#   node dist/cli.js list-state-changes --since <ISO>
#     → [{"event_type","candidate_id","placement_id","contact_id","client_id",
#         "state_from","state_to","event_timestamp_iso"}, ...]
#   node dist/cli.js list-nurture-due
#     → same array shape (event_type ∈ 7-day/30-day/90-day check-ins)
#
# ── MODES ─────────────────────────────────────────────────────────────────
# live    — connector dist/cli.js present AND BULLHORN_CLIENT_ID non-empty in
#           the environment → exec the connector CLI verbatim (args passed
#           through 1:1). BLOCKED today: Bullhorn creds are EMPTY in the dev
#           sandbox (verified 2026-06-10) and the Janitor-branch CLI is
#           unmerged — the live branch is built but unexercised.
# fixture — otherwise: serve from / write to the seeded `entities` rows
#           (the Bullhorn cache per spec-004 §2) in Postgres under RLS.
#           Fixtures prove all Concierge logic against these rows.
#
# Env: CTX_TENANT_SLUG (required), IFOS_DB_URL (fixture mode), IFOS_REPO_ROOT.
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

# Mode resolution: live needs BOTH the built CLI and non-empty creds.
_BH_MODE="fixture"
if [[ -f "${_BH_CLI}" && -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" ]]; then
  _BH_MODE="live"
fi
# Test override (fixture suites force fixture mode even if a CLI appears later).
[[ "${IFOS_BH_FORCE_FIXTURE:-0}" == "1" ]] && _BH_MODE="fixture"

if [[ "${_BH_MODE}" == "live" ]]; then
  # Live branch: pass through verbatim. get-entity convenience verbs map 1:1.
  exec node "${_BH_CLI}" "${CMD}" "$@"
fi

# ── Fixture mode (entities-cache-backed) ─────────────────────────────────

if [[ -z "${IFOS_DB_URL:-}" ]] || ! command -v psql >/dev/null 2>&1; then
  printf '{"ok":false,"error":"fixture mode needs IFOS_DB_URL + psql","mode":"fixture"}\n' >&2
  exit 2
fi

# RLS-scoped psql: all SQL on stdin; tenant + args via psql vars (no injection).
_q() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" "$@"; }

# Tiny arg parser: --key value pairs into _ARG_<KEY> (dashes → underscores).
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

case "${CMD}" in

  refresh)
    # No live Bullhorn in fixture mode — honest degraded answer; the caller
    # records token_state accordingly (never a faked "ok").
    printf '{"ok":false,"mode":"fixture","reason":"bullhorn_creds_absent"}\n'
    exit 0
    ;;

  get-candidate|get-placement|get-client|get-contact)
    _etype="${CMD#get-}"
    _eid="${ARGS[id]:-}"
    if [[ -z "${_eid}" ]]; then
      printf '{"ok":false,"error":"--id required"}\n' >&2; exit 2
    fi
    _row="$(_q --set=etype="${_etype}" --set=eid="${_eid}" <<'SQL'
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
    ;;

  create-activity-log)
    _cand="${ARGS[candidate]:-}"
    _note="${ARGS[note]:-}"
    if [[ -z "${_cand}" || -z "${_note}" ]]; then
      printf '{"ok":false,"error":"--candidate and --note required"}\n' >&2; exit 2
    fi
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
    ;;

  patch-state)
    _etype="${ARGS[type]:-candidate}"
    _eid="${ARGS[id]:-}"
    _state="${ARGS[state]:-}"
    if [[ -z "${_eid}" || -z "${_state}" ]]; then
      printf '{"ok":false,"error":"--id and --state required"}\n' >&2; exit 2
    fi
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
    ;;

  list-state-changes)
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
    # Placements whose start_date is exactly 7/30/90 days ago (fixture-grade
    # nurture sweep; live mode delegates the windowing to the connector).
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
