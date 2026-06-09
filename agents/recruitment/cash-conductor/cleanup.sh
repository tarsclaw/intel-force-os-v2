#!/usr/bin/env bash
# Cash Conductor agent — cleanup.sh (post-run state purge; W4 Day-26 SKELETON)
#
# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
#         live cache-purge calls).
# Reading order: agent.md §4 Step 14 (session close) + §6 ESC code mappings first.
#
# Per agent.md §3 actions list: Cash Conductor's cleanup action_type is
# `cash_conductor_cleanup` (green tier — internal-only audit row recording
# cache-purge status + workspace cleanup; no external comms).
#
# Per agents/_shared/autosend-policy.yaml: `cash_conductor_cleanup` is QUEUED
# for registration at W7-8 build start (per tools.yaml status table). Once
# registered + the W7-8 build wires the real purge logic, this script emits
# the action row + green-tier classification.
#
# Invocation contract:
#   bash cleanup.sh
#
# Inputs (env):
#   CTX_AGENT_DIR, CTX_TENANT_SLUG, CTX_AGENT_NAME (already set by cycle.sh)
#
# Side effects (W7-8 build slice):
#   - Purge ~/.ifos-cache/xero/* older than 24h (transient HTTP cache; keeps token files)
#   - Purge ~/.ifos-cache/quickbooks/* older than 24h
#   - Purge ~/.ifos-cache/open-banking/* older than 24h (transactions cache only;
#     balance cache TTL is already 0 so no-op there)
#   - Reset in-process rate-limit buckets via @ifos/{xero,quickbooks,open-banking} resetRateLimit()
#     — but rate-limit is per-process so process-exit handles it; cleanup.sh
#     is mostly disk-cache-side
#
# What cleanup.sh does NOT touch:
#   - Token files at ~/.ifos-local-vault/<tenant>/{xero,qb,ob}-tokens-*.json (load-bearing)
#   - Vault chase drafts at /vault/<tenant>/cash-conductor-drafts/ (kept for audit)
#   - cash_conductor_{transactions,invoices} Postgres rows (kept indefinitely)
#   - decision_log rows (append-only per T5 tenancy invariant)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'cash-conductor/cleanup.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'cash-conductor/cleanup.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=cash-conductor}"

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

# Exported so the W7-8 build-slice can extend the find -delete logic via
# child processes without re-resolving the env var fallback chain.
export XERO_CACHE_DIR="${IFOS_XERO_CACHE_DIR:-${HOME}/.ifos-cache/xero}"
export QB_CACHE_DIR="${IFOS_QB_CACHE_DIR:-${HOME}/.ifos-cache/quickbooks}"
export OB_CACHE_DIR="${IFOS_OPEN_BANKING_CACHE_DIR:-${HOME}/.ifos-cache/open-banking}"

# W7 LIVE: prune transient HTTP cache entries older than 24h per provider. Token
# files live elsewhere (vault) and are never touched here (see header).
_cc_purge_dir() {
  local dir="$1"
  [[ -d "${dir}" ]] || { echo 0; return 0; }
  find "${dir}" -type f -mtime +1 -delete -print 2>/dev/null | wc -l | tr -d ' '
}
XERO_PURGED="$(_cc_purge_dir "${XERO_CACHE_DIR}")"
QB_PURGED="$(_cc_purge_dir "${QB_CACHE_DIR}")"
OB_PURGED="$(_cc_purge_dir "${OB_CACHE_DIR}")"

# Purge this run's scoped temp files (chase candidates + validated list written by
# cycle.sh Steps 7/9). Best-effort; they are /tmp scratch, not audit artefacts.
for _tmp in "${CC_CHASE_CANDIDATES:-}" "${CC_VALIDATED:-}"; do
  [[ -n "${_tmp}" && -f "${_tmp}" ]] && rm -f "${_tmp}" 2>/dev/null || true
done

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Optional: emit ESC_RATE_LIMIT_HIT if any cache shows
# evidence of saturation (e.g. many entries from same minute window).
# Deferred to W7-8 build (analytical signal; not blocking).
# ────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Emit green-tier audit row (per agent.md §3 actions list)
# ────────────────────────────────────────────────────────────────────────

TOTAL_PURGED=$((XERO_PURGED + QB_PURGED + OB_PURGED))

# TODO(W7-8): once cash_conductor_cleanup action_type is registered in
# autosend-policy.yaml (currently QUEUED per tools.yaml status table), switch
# from hh_decision_output to hh_decision_action for proper tier classification.
hh_decision_output "cash_conductor_cleanup" "tenant:${CTX_TENANT_SLUG}" \
  "xero_cache_purged:${XERO_PURGED}; qb_cache_purged:${QB_PURGED}; ob_cache_purged:${OB_PURGED}; total:${TOTAL_PURGED}"

# Operator-readable trace
printf '[cash-conductor cleanup.sh] tenant=%s purged total=%d (xero=%d qb=%d ob=%d)\n' \
  "${CTX_TENANT_SLUG}" "${TOTAL_PURGED}" "${XERO_PURGED}" "${QB_PURGED}" "${OB_PURGED}"

exit 0
