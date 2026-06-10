#!/usr/bin/env bash
# Concierge agent — cleanup.sh (post-run state purge; W10-13 LIVE)
#
# Status: BUILT (W10-13 build slice; live cache purge below).
# Reading order: agent.md §4 Step 15 (session close) + §6 ESC mappings first.
#
# Per agent.md §3 actions list: Concierge's cleanup action_type is
# `concierge_cleanup` (green tier — internal-only audit row recording
# cache-purge status + workspace cleanup; no external comms).
#
# Per agents/_shared/autosend-policy.yaml: `concierge_cleanup` is still QUEUED
# for registration (future_registration noted in tools.yaml). It emits via
# hh_decision_output until the registration commit lands — the Scout/Janitor
# precedent; an unregistered type via hh_decision_action would fail-safe-red.
#
# Invocation contract:
#   bash cleanup.sh
#
# Inputs (env):
#   CTX_AGENT_DIR, CTX_TENANT_SLUG, CTX_AGENT_NAME (already set by cycle.sh/context.sh)
#
# Side effects (W10-13 build slice):
#   - Purge ~/.ifos-cache/bullhorn/* older than 24h (transient HTTP cache; keeps tokens)
#   - Purge ~/.ifos-cache/microsoft-graph/* older than 24h
#   - Purge ~/.ifos-cache/gmail/* older than 24h
#   - Reset in-process rate-limit buckets via @ifos/{bullhorn,microsoft-graph,gmail}
#     resetRateLimit() — but rate-limit is per-process so process-exit handles it
#
# What cleanup.sh does NOT touch:
#   - Token files at ~/.ifos-local-vault/<tenant>/{bullhorn,msgraph,gmail}-tokens-*.json (load-bearing)
#   - Vault concierge drafts at /vault/<tenant>/concierge-drafts/ (kept for audit)
#   - decision_log rows (append-only per T5 tenancy invariant)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'concierge/cleanup.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'concierge/cleanup.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=concierge}"

# Resolve _shared/ helpers (4-candidate fallback; matches sibling pattern)
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
  printf 'cleanup.sh: cannot locate _shared/ helpers\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Transient HTTP cache purge (per-provider; >24h entries only)
# ────────────────────────────────────────────────────────────────────────

# Exported so the W10-13 build-slice can extend the find -delete logic via
# child processes without re-resolving the env var fallback chain.
export BULLHORN_CACHE_DIR="${IFOS_BULLHORN_CACHE_DIR:-${HOME}/.ifos-cache/bullhorn}"
export MSGRAPH_CACHE_DIR="${IFOS_MSGRAPH_CACHE_DIR:-${HOME}/.ifos-cache/microsoft-graph}"
export GMAIL_CACHE_DIR="${IFOS_GMAIL_CACHE_DIR:-${HOME}/.ifos-cache/gmail}"

# W10-13 LIVE: prune transient HTTP-cache entries older than 24h. Token files
# live under ~/.ifos-local-vault/<tenant>/ (NOT these dirs) and are never
# touched. A missing cache dir is a clean zero, not an error.
_purge_old() {
  local dir="$1"
  if [[ -d "${dir}" ]]; then
    find "${dir}" -type f -mtime +1 -delete -print 2>/dev/null | wc -l | tr -d ' '
  else
    printf '0'
  fi
}
BULLHORN_PURGED="$(_purge_old "${BULLHORN_CACHE_DIR}")"
MSGRAPH_PURGED="$(_purge_old "${MSGRAPH_CACHE_DIR}")"
GMAIL_PURGED="$(_purge_old "${GMAIL_CACHE_DIR}")"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Emit green-tier audit row (per agent.md §3 actions list)
# ────────────────────────────────────────────────────────────────────────

TOTAL_PURGED=$((BULLHORN_PURGED + MSGRAPH_PURGED + GMAIL_PURGED))

# concierge_cleanup is NOT yet registered in autosend-policy.yaml (QUEUED per
# tools.yaml status table; future_registration noted there). Per the
# Scout/Janitor precedent: unregistered action_types emit via
# hh_decision_output — switching to hh_decision_action happens at the
# registration commit, not before (emitting an unregistered type via
# hh_decision_action would fail-safe-red).
hh_decision_output "concierge_cleanup" "tenant:${CTX_TENANT_SLUG}" \
  "bullhorn_cache_purged:${BULLHORN_PURGED}; msgraph_cache_purged:${MSGRAPH_PURGED}; gmail_cache_purged:${GMAIL_PURGED}; total:${TOTAL_PURGED}"

# Operator-readable trace
printf '[concierge cleanup.sh] tenant=%s purged total=%d (bullhorn=%d msgraph=%d gmail=%d)\n' \
  "${CTX_TENANT_SLUG}" "${TOTAL_PURGED}" "${BULLHORN_PURGED}" "${MSGRAPH_PURGED}" "${GMAIL_PURGED}"

exit 0
