#!/usr/bin/env bash
# Scribe — Bullhorn CLI-bridge shim (single reconciliation point).
#
# WHY THIS FILE EXISTS (parallel-conflict rule, W6 build slice):
#   The Janitor sub-agent owns packages/mcp-connectors/bullhorn this cycle, so
#   Scribe must NOT touch that package. ALL of Scribe's Bullhorn calls route
#   through this thin shim instead. When Janitor's @ifos/bullhorn CLI bridge
#   lands at review, THIS file is the only place that needs reconciling.
#
# EXPECTED CLI COMMAND SURFACE from the @ifos/bullhorn bridge (mirrors the
# cash-conductor connector-CLI invocation pattern: `node dist/cli.js <cmd>`
# reading process.env creds + on-disk token bundles, printing JSON {ok,...}
# to stdout — NEVER a raw token value):
#
#   node packages/mcp-connectors/bullhorn/dist/cli.js refresh
#     → {"ok":true,"token_state":"refreshed"|"fresh"}        (auth refresh;
#       two-step Step A OAuth + Step B REST login per src/auth.ts; per-corp
#       dedup; reads BULLHORN_CLIENT_ID/_SECRET + token file from
#       ~/.ifos-local-vault/<tenant>/bullhorn-tokens-<corp>.json)
#
#   node .../cli.js update-entity --type <Candidate|ClientContact|JobOrder|Placement> \
#     --id <bullhorn_id> --fields '<json field map>'
#     → {"ok":true,"updated":<n>}                            (PATCH /<EntityType>/<id>)
#
#   node .../cli.js create-note --entity-type <T> --entity-id <id> \
#     --body-file <path> [--title <s>]
#     → {"ok":true,"note_id":"<id>"}                         (POST /Note linked to entity)
#
# Exit codes (cycle.sh contract):
#   0  command succeeded ({"ok":true} from the CLI)
#   1  bridge CLI ran but the call FAILED ({"ok":false} / non-JSON / non-zero)
#   2  usage error (bad args)
#   3  bridge UNAVAILABLE (dist/cli.js not built yet OR node missing) — the
#      caller degrades (IFOS-cached Postgres write only; push deferred)
#
# Test hook (fixture suites ONLY; mirrors agents/_shared HH_AWAIT_TEST_MODE
# precedent): BH_BRIDGE_TEST_MODE=ok|fail|unavailable short-circuits before
# any CLI resolution so fixtures prove cycle.sh logic without the live bridge.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  printf 'bh-bridge.sh: usage: bh-bridge.sh <refresh|update-entity|create-note> [args]\n' >&2
  exit 2
fi
CMD="$1"
shift

case "${CMD}" in
  refresh|update-entity|create-note) ;;
  *) printf 'bh-bridge.sh: unknown command %s\n' "${CMD}" >&2; exit 2 ;;
esac

# ── Test-mode short-circuit (fixture suites; never set in production) ─────
case "${BH_BRIDGE_TEST_MODE:-}" in
  ok)
    case "${CMD}" in
      refresh)       printf '{"ok":true,"token_state":"refreshed","mode":"test"}\n' ;;
      update-entity) printf '{"ok":true,"updated":1,"mode":"test"}\n' ;;
      create-note)   printf '{"ok":true,"note_id":"test-note-1","mode":"test"}\n' ;;
    esac
    exit 0 ;;
  fail)
    printf '{"ok":false,"error":"test_forced_failure","mode":"test"}\n'
    exit 1 ;;
  unavailable)
    printf '{"ok":false,"error":"bridge_unavailable","mode":"test"}\n'
    exit 3 ;;
  "") : ;;
  *) printf 'bh-bridge.sh: unknown BH_BRIDGE_TEST_MODE %s\n' "${BH_BRIDGE_TEST_MODE}" >&2; exit 2 ;;
esac

# ── Resolve the bridge CLI (IFOS_BULLHORN_CLI override → repo dist path) ──
_BH_CLI="${IFOS_BULLHORN_CLI:-${IFOS_REPO_ROOT:-}/packages/mcp-connectors/bullhorn/dist/cli.js}"
if [[ ! -f "${_BH_CLI}" ]] || ! command -v node >/dev/null 2>&1; then
  printf '{"ok":false,"error":"bridge_unavailable","cli":"%s"}\n' "${_BH_CLI}"
  exit 3
fi

# ── Invoke (CC pattern: node dist/cli.js <cmd> …; jq-verify .ok) ──────────
if _out=$(node "${_BH_CLI}" "${CMD}" "$@" 2>/dev/null) \
     && [[ "$(printf '%s' "${_out}" | jq -r '.ok // false' 2>/dev/null)" == "true" ]]; then
  printf '%s\n' "${_out}"
  exit 0
fi
printf '%s\n' "${_out:-{\"ok\":false,\"error\":\"bridge_call_failed\"}}"
exit 1
