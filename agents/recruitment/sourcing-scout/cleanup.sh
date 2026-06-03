#!/usr/bin/env bash
# Sourcing Scout agent — cleanup.sh (post-run state purge; W5 Day-33 SKELETON)
#
# Status: Proposed (W5 Day-33 SKELETON; W9 build slice replaces stubs with
#         live cache-purge calls).
# Reading order: agent.md §4 Step 11 (session close) + §6 ESC code mappings first.
#
# Per agent.md §3 actions list: Sourcing Scout's cleanup action_type is
# `sourcing_scout_cleanup` (green tier — internal-only audit row recording
# cache-purge status + workspace cleanup; no external comms).
#
# Per agents/_shared/autosend-policy.yaml: `sourcing_scout_cleanup` is QUEUED
# for registration at W9 build start (per tools.yaml status table). Once
# registered + the W9 build wires the real purge logic, this script emits
# the action row + green-tier classification.
#
# Invocation contract:
#   bash cleanup.sh
#
# Inputs (env):
#   CTX_AGENT_DIR, CTX_TENANT_SLUG, CTX_AGENT_NAME (already set by context.sh + cycle.sh)
#
# Side effects (W9 build slice):
#   - Purge ~/.ifos-cache/bullhorn/* older than 24h (transient HTTP cache;
#     keeps token files at ~/.ifos-local-vault/<tenant>/bullhorn-tokens-<corp>.json)
#   - Purge ~/.ifos-cache/reed/* older than 1h (Reed search results; short TTL
#     since job market data churns hourly; TODO Phase 8 — @ifos/reed package
#     defines actual cache TTL)
#   - Purge ~/.ifos-cache/cv-library/* older than 1h (same rationale; TODO Phase 8)
#   - Purge /tmp/sourcing-scout-<tenant>-* draft reports older than 24h
#     (cycle.sh Step 10 writes partial drafts to /tmp on Gate A failure;
#     auto-purge prevents stale draft exposure)
#
# What cleanup.sh does NOT touch:
#   - Token files (~/.ifos-local-vault/<tenant>/{bullhorn,reed,cv-library}-tokens-*.json)
#   - Vault sourcing-scout reports (/vault/<tenant>/sourcing-scout-reports/) — kept for audit
#   - decision_log rows (append-only per T5 tenancy invariant)
#   - tenant_adapters.config.blocked_recipients (loaded read-only by context.sh)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'sourcing-scout/cleanup.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'sourcing-scout/cleanup.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=sourcing-scout}"

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

# Exported so the W9 build-slice can extend the find -delete logic via
# child processes without re-resolving the env var fallback chain.
export BULLHORN_CACHE_DIR="${IFOS_BULLHORN_CACHE_DIR:-${HOME}/.ifos-cache/bullhorn}"
export REED_CACHE_DIR="${IFOS_REED_CACHE_DIR:-${HOME}/.ifos-cache/reed}"
export CVLIBRARY_CACHE_DIR="${IFOS_CVLIBRARY_CACHE_DIR:-${HOME}/.ifos-cache/cv-library}"
export SCOUT_TMP_PATTERN="/tmp/sourcing-scout-${CTX_TENANT_SLUG}-*.md"

# TODO(W9): replace these STUB counts with actual find -delete invocations
# that prune entries older than the per-provider TTL. Skeleton emits zero so
# the audit row shape is preserved for the build-slice author.
BULLHORN_PURGED=0
REED_PURGED=0
CVLIBRARY_PURGED=0
TMP_DRAFTS_PURGED=0
# When ready, replace with the real purge logic:
#   if [[ -d "${BULLHORN_CACHE_DIR}" ]]; then
#     BULLHORN_PURGED=$(find "${BULLHORN_CACHE_DIR}" -type f -mtime +1 -delete -print 2>/dev/null | wc -l | tr -d ' ')
#   fi
#   # Reed + CV-Library: 1h TTL since job market churns hourly
#   if [[ -d "${REED_CACHE_DIR}" ]]; then
#     REED_PURGED=$(find "${REED_CACHE_DIR}" -type f -mmin +60 -delete -print 2>/dev/null | wc -l | tr -d ' ')
#   fi
#   if [[ -d "${CVLIBRARY_CACHE_DIR}" ]]; then
#     CVLIBRARY_PURGED=$(find "${CVLIBRARY_CACHE_DIR}" -type f -mmin +60 -delete -print 2>/dev/null | wc -l | tr -d ' ')
#   fi
#   # /tmp drafts: purge older than 24h
#   for tmp_file in ${SCOUT_TMP_PATTERN}; do
#     [[ -f "$tmp_file" ]] || continue
#     find "$tmp_file" -mtime +1 -delete -print 2>/dev/null | head -1 && TMP_DRAFTS_PURGED=$((TMP_DRAFTS_PURGED + 1))
#   done

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Emit green-tier audit row (per agent.md §3 actions list)
# ────────────────────────────────────────────────────────────────────────

TOTAL_PURGED=$((BULLHORN_PURGED + REED_PURGED + CVLIBRARY_PURGED + TMP_DRAFTS_PURGED))

# TODO(W9): once sourcing_scout_cleanup action_type is registered in
# autosend-policy.yaml (currently QUEUED per tools.yaml status table), switch
# from hh_decision_output to hh_decision_action for proper tier classification.
hh_decision_output "sourcing_scout_cleanup" "tenant:${CTX_TENANT_SLUG}" \
  "bullhorn_cache_purged:${BULLHORN_PURGED}; reed_cache_purged:${REED_PURGED}; cvlibrary_cache_purged:${CVLIBRARY_PURGED}; tmp_drafts_purged:${TMP_DRAFTS_PURGED}; total:${TOTAL_PURGED}; mode:SKELETON"

# Operator-readable trace
printf '[sourcing-scout cleanup.sh] tenant=%s purged total=%d (bullhorn=%d reed=%d cvlibrary=%d tmp=%d) mode=SKELETON\n' \
  "${CTX_TENANT_SLUG}" "${TOTAL_PURGED}" "${BULLHORN_PURGED}" "${REED_PURGED}" \
  "${CVLIBRARY_PURGED}" "${TMP_DRAFTS_PURGED}"

exit 0
