#!/usr/bin/env bash
# Janitor agent — cleanup.sh (post-run state purge; W5 Day-31 SKELETON)
#
# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice replaces stubs with
#         live cache-purge calls).
# Reading order: agent.md §4 Step 12 (session close) + §6 ESC code mappings first.
#
# Per agent.md §3 actions list: Janitor's cleanup action_type is
# `janitor_cleanup` (green tier — internal-only audit row recording
# cache-purge status + workspace cleanup; no external comms).
#
# Per agents/_shared/autosend-policy.yaml: `janitor_cleanup` is QUEUED for
# registration at W6-7 build start (per tools.yaml status table below). Once
# registered + the W6-7 build wires the real purge logic, this script emits
# the action row + green-tier classification.
#
# Invocation contract:
#   bash cleanup.sh
#
# Inputs (env):
#   CTX_AGENT_DIR, CTX_TENANT_SLUG, CTX_AGENT_NAME (already set by context.sh + cycle.sh)
#
# Side effects (W6-7 build slice):
#   - Purge ~/.ifos-cache/bullhorn/* older than 24h (transient HTTP cache; keeps
#     token files at ~/.ifos-local-vault/<tenant>/bullhorn-tokens-<corp>.json)
#   - Purge ~/.ifos-cache/companies-house/* older than 7d (CRN lookup cache TTL
#     longer per agent.md §4 Step 6)
#   - Reset in-process rate-limit buckets via @ifos/bullhorn resetRateLimit()
#     + @ifos/companies-house resetRateLimit() — but rate-limit is per-process
#     so process-exit handles it; cleanup.sh is mostly disk-cache-side
#
# What cleanup.sh does NOT touch:
#   - Token files at ~/.ifos-local-vault/<tenant>/bullhorn-tokens-*.json (load-bearing)
#   - Vault day-30 reports at /vault/<tenant>/janitor-reports/ (kept for audit)
#   - recent_edit Postgres rows (read-only access; canary cron owns purge)
#   - decision_log rows (append-only per T5 tenancy invariant)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'janitor/cleanup.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'janitor/cleanup.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=janitor}"

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
# Step 1 — Transient HTTP cache purge (per-provider; older-than-TTL entries only)
# ────────────────────────────────────────────────────────────────────────

# Exported so the W6-7 build-slice can extend the find -delete logic via
# child processes without re-resolving the env var fallback chain.
export BULLHORN_CACHE_DIR="${IFOS_BULLHORN_CACHE_DIR:-${HOME}/.ifos-cache/bullhorn}"
export COMPANIES_HOUSE_CACHE_DIR="${IFOS_COMPANIES_HOUSE_CACHE_DIR:-${HOME}/.ifos-cache/companies-house}"

# TODO(W6-7): replace these STUB counts with actual find -delete invocations
# that prune entries older than the per-provider TTL. Skeleton emits zero so
# the audit row shape is preserved for the build-slice author.
BULLHORN_PURGED=0
CH_PURGED=0
# When ready, replace with the real purge logic:
#   if [[ -d "${BULLHORN_CACHE_DIR}" ]]; then
#     BULLHORN_PURGED=$(find "${BULLHORN_CACHE_DIR}" -type f -mtime +1 -delete -print 2>/dev/null | wc -l | tr -d ' ')
#   fi
#   if [[ -d "${COMPANIES_HOUSE_CACHE_DIR}" ]]; then
#     CH_PURGED=$(find "${COMPANIES_HOUSE_CACHE_DIR}" -type f -mtime +7 -delete -print 2>/dev/null | wc -l | tr -d ' ')
#   fi

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Optional: emit ESC_RATE_LIMIT_HIT analytical signal if cache shows
# evidence of saturation (many entries from same minute window).
# Deferred to W6-7 build (analytical signal; not blocking).
# ────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Emit green-tier audit row (per agent.md §3 actions list)
# ────────────────────────────────────────────────────────────────────────

TOTAL_PURGED=$((BULLHORN_PURGED + CH_PURGED))

# TODO(W6-7): once janitor_cleanup action_type is registered in
# autosend-policy.yaml (currently QUEUED per tools.yaml status table), switch
# from hh_decision_output to hh_decision_action for proper tier classification.
hh_decision_output "janitor_cleanup" "tenant:${CTX_TENANT_SLUG}" \
  "bullhorn_cache_purged:${BULLHORN_PURGED}; companies_house_cache_purged:${CH_PURGED}; total:${TOTAL_PURGED}; mode:SKELETON"

# Operator-readable trace
printf '[janitor cleanup.sh] tenant=%s purged total=%d (bullhorn=%d companies_house=%d) mode=SKELETON\n' \
  "${CTX_TENANT_SLUG}" "${TOTAL_PURGED}" "${BULLHORN_PURGED}" "${CH_PURGED}"

exit 0
