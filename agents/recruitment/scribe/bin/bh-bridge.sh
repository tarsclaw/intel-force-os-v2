#!/usr/bin/env bash
# Scribe — Bullhorn CLI-bridge shim (single reconciliation point).
#
# WHY THIS FILE EXISTS (parallel-conflict rule, W6 build slice):
#   The Janitor sub-agent owns packages/mcp-connectors/bullhorn this cycle, so
#   Scribe must NOT touch that package. ALL of Scribe's Bullhorn calls route
#   through this thin shim instead. This file conforms to the AGREED
#   @ifos/bullhorn CLI contract (orchestrator ruling, recorded in
#   docs/features/agent-build/04-reviews/review-scribe.md) that binds both
#   the Scribe and Janitor fix passes.
#
# AGREED CLI COMMAND SURFACE (node packages/mcp-connectors/bullhorn/dist/cli.js
# <cmd>, reading process.env creds + the on-disk token bundle, printing JSON
# {ok,...} to stdout — NEVER a raw token value):
#
#   check-auth                                              NETWORK-FREE probe
#     → {"ok":bool,"creds_present":bool,"tokens_present":bool,
#        "corporation_id":"...","region":"..."}
#       ok=true only when creds AND tokens are present (a refresh could
#       succeed). The shim runs this BEFORE refresh to distinguish
#       not-provisioned (exit 3 'unavailable' — honest degrade, NO ESC) from
#       a genuine refresh failure (exit 1 'failed' — ESC_BULLHORN_AUTH).
#
#   refresh
#     → {"ok":true,"oauth_expires_at_ms":<ms>,"token_state":"refreshed"|"fresh"}
#       (two-step Step A OAuth + Step B REST login per src/auth.ts;
#       token_state added per the agreed contract — shim defaults it to
#       "refreshed" if a pre-contract CLI omits it)
#
#   update-entity --entity-type <Candidate|ClientContact|JobOrder|Placement> \
#     --id <numeric> --patch '<json field map>'
#     → {"ok":true,"updated":<n>,"entity_type":"<T>","id":<N>}
#       (PATCH /<EntityType>/<id>; existing update-candidate/update-client
#       commands stay Janitor-internal — Scribe uses update-entity only)
#
#   create-note ( --person-id <numeric> |
#                 --entity-type <T> --entity-id <numeric> ) \
#     --body-file <path> [--title <s>]
#     → {"ok":true,"note_id":"<id>"}
#       If Bullhorn cannot attach a Note to the given entity type the CLI
#       returns {"ok":false,"reason":"unsupported_entity"} — the shim maps
#       that to exit 5 so cycle.sh can fall back to person-resolution
#       (or defer honestly). Never faked.
#
# Token path (per-tenant mechanism, agreed contract): the CLI reads its token
# bundle from <token_dir>/bullhorn-tokens-<corporation_id>.json where
# token_dir = $IFOS_TOKEN_DIR if set, else ~/.ifos-local-vault/dev-sandbox.
# Callers select the tenant's token bundle by exporting IFOS_TOKEN_DIR (e.g.
# ~/.ifos-local-vault/<tenant>) before invoking this shim — the shim passes
# the env through untouched.
#
# IDs are NUMERIC: callers pass numeric strings for --id / --entity-id /
# --person-id; the shim rejects non-numeric ids as a usage error (exit 2).
#
# Exit codes (cycle.sh contract):
#   0  command succeeded ({"ok":true} from the CLI)
#   1  bridge CLI ran but the call FAILED ({"ok":false} / non-JSON / non-zero)
#   2  usage error (bad args / non-numeric id)
#   3  bridge UNAVAILABLE (dist/cli.js not built OR node missing OR check-auth
#      reports creds/tokens not provisioned) — the caller degrades honestly
#      (IFOS-cached Postgres write only; push deferred; NO ESC)
#   5  create-note: {"ok":false,"reason":"unsupported_entity"} — caller falls
#      back to person-resolution or defers honestly
#
# Test hook (fixture suites ONLY; mirrors agents/_shared HH_AWAIT_TEST_MODE
# precedent): BH_BRIDGE_TEST_MODE short-circuits before any CLI resolution so
# fixtures prove cycle.sh logic without the live bridge:
#   ok               all commands succeed
#   fail             all commands fail (exit 1)
#   unavailable      bridge unavailable (exit 3)
#   note-fail        create-note hard-fails (exit 1); others succeed
#   note-unsupported create-note WITHOUT --person-id → unsupported_entity
#                    (exit 5); person-scoped create-note + others succeed

set -euo pipefail

if [[ $# -lt 1 ]]; then
  printf 'bh-bridge.sh: usage: bh-bridge.sh <check-auth|refresh|update-entity|create-note> [args]\n' >&2
  exit 2
fi
CMD="$1"
shift

case "${CMD}" in
  check-auth|refresh|update-entity|create-note) ;;
  *) printf 'bh-bridge.sh: unknown command %s\n' "${CMD}" >&2; exit 2 ;;
esac

# ── Numeric-id guard (agreed contract: ids are numeric) ───────────────────
_HAS_PERSON_ID=0
if [[ "${CMD}" == "update-entity" || "${CMD}" == "create-note" ]]; then
  _args=("$@")
  for (( _i=0; _i<${#_args[@]}; _i++ )); do
    case "${_args[$_i]}" in
      --id|--entity-id|--person-id)
        _val="${_args[$((_i+1))]:-}"
        if [[ ! "${_val}" =~ ^[0-9]+$ ]]; then
          printf 'bh-bridge.sh: %s must be a numeric id (got %s)\n' "${_args[$_i]}" "${_val:-<empty>}" >&2
          exit 2
        fi
        [[ "${_args[$_i]}" == "--person-id" ]] && _HAS_PERSON_ID=1
        ;;
    esac
  done
fi

# ── Test-mode short-circuit (fixture suites; never set in production) ─────
_test_ok() {
  case "${CMD}" in
    check-auth)    printf '{"ok":true,"creds_present":true,"tokens_present":true,"mode":"test"}\n' ;;
    refresh)       printf '{"ok":true,"oauth_expires_at_ms":0,"token_state":"refreshed","mode":"test"}\n' ;;
    update-entity) printf '{"ok":true,"updated":1,"mode":"test"}\n' ;;
    create-note)   printf '{"ok":true,"note_id":"test-note-1","mode":"test"}\n' ;;
  esac
  exit 0
}
case "${BH_BRIDGE_TEST_MODE:-}" in
  ok) _test_ok ;;
  fail)
    printf '{"ok":false,"error":"test_forced_failure","mode":"test"}\n'
    exit 1 ;;
  unavailable)
    printf '{"ok":false,"error":"bridge_unavailable","mode":"test"}\n'
    exit 3 ;;
  note-fail)
    if [[ "${CMD}" == "create-note" ]]; then
      printf '{"ok":false,"error":"test_forced_note_failure","mode":"test"}\n'
      exit 1
    fi
    _test_ok ;;
  note-unsupported)
    if [[ "${CMD}" == "create-note" && "${_HAS_PERSON_ID}" -eq 0 ]]; then
      printf '{"ok":false,"reason":"unsupported_entity","mode":"test"}\n'
      exit 5
    fi
    _test_ok ;;
  "") : ;;
  *) printf 'bh-bridge.sh: unknown BH_BRIDGE_TEST_MODE %s\n' "${BH_BRIDGE_TEST_MODE}" >&2; exit 2 ;;
esac

# ── Resolve the bridge CLI (IFOS_BULLHORN_CLI override → repo dist path) ──
_BH_CLI="${IFOS_BULLHORN_CLI:-${IFOS_REPO_ROOT:-}/packages/mcp-connectors/bullhorn/dist/cli.js}"
if [[ ! -f "${_BH_CLI}" ]] || ! command -v node >/dev/null 2>&1; then
  printf '{"ok":false,"error":"bridge_unavailable","cli":"%s"}\n' "${_BH_CLI}"
  exit 3
fi

# ── refresh: network-free check-auth probe FIRST (review F3/F7) ───────────
# Not-provisioned (no creds / no token bundle) is an expected pre-onboarding
# state → exit 3 'unavailable' (caller records result:unavailable, NO ESC).
# Only a refresh that fails WITH provisioned creds is a genuine failure
# (exit 1 → caller retries then fires ESC_BULLHORN_AUTH).
if [[ "${CMD}" == "refresh" ]]; then
  _probe="$(node "${_BH_CLI}" check-auth 2>/dev/null)" || _probe=""
  if [[ -z "${_probe}" ]] \
       || [[ "$(printf '%s' "${_probe}" | jq -r '.ok // false' 2>/dev/null)" != "true" ]]; then
    _probe_json="$(printf '%s' "${_probe}" | jq -c '.' 2>/dev/null || echo null)"
    printf '{"ok":false,"error":"not_provisioned","probe":%s}\n' "${_probe_json}"
    exit 3
  fi
fi

# ── Invoke (CC pattern: node dist/cli.js <cmd> …; jq-verify .ok) ──────────
_rc=0
_out="$(node "${_BH_CLI}" "${CMD}" "$@" 2>/dev/null)" || _rc=$?
if [[ "${_rc}" -eq 0 ]] \
     && [[ "$(printf '%s' "${_out}" | jq -r '.ok // false' 2>/dev/null)" == "true" ]]; then
  if [[ "${CMD}" == "refresh" ]]; then
    # token_state default for a pre-contract CLI that omits it.
    printf '%s\n' "$(printf '%s' "${_out}" | jq -c '. + {token_state: (.token_state // "refreshed")}')"
  else
    printf '%s\n' "${_out}"
  fi
  exit 0
fi
_out="${_out:-{\"ok\":false,\"error\":\"bridge_call_failed\"}}"
printf '%s\n' "${_out}"
if [[ "${CMD}" == "create-note" ]] \
     && [[ "$(printf '%s' "${_out}" | jq -r '.reason // ""' 2>/dev/null)" == "unsupported_entity" ]]; then
  exit 5
fi
exit 1
