#!/usr/bin/env bash
# Janitor agent — cleanup.sh (post-run state purge; W6-7 LIVE)
#
# Status: LIVE per spec-001 §4 (W6-7 build slice).
# Reading order: agent.md §4 Step 12 (session close) + §6 ESC code mappings first.
#
# Per agent.md §3 actions list: Janitor's cleanup action_type is
# `janitor_cleanup` (green tier — internal-only audit row recording
# cache-purge status + workspace cleanup; no external comms).
#
# Per agents/_shared/autosend-policy.yaml: `janitor_cleanup` is NOT yet
# registered (QUEUED per tools.yaml status table — registration is a
# substrate-owner change; agents/_shared/ is frozen for this build slice per
# the parallel-conflict rule). The audit row therefore stays
# hh_decision_output; switch to hh_decision_action once registered
# (CC + Scout cleanup precedent).
#
# Invocation contract:
#   bash cleanup.sh
#
# Inputs (env):
#   CTX_AGENT_DIR, CTX_TENANT_SLUG, CTX_AGENT_NAME (already set by context.sh + cycle.sh)
#
# Side effects:
#   - Purge ~/.ifos-cache/bullhorn/* older than 24h (transient HTTP cache;
#     token files live in the vault and are NEVER touched here)
#   - Purge ~/.ifos-cache/companies-house/* older than 7d (CRN lookup cache;
#     longer TTL per agent.md §4 Step 6 — the connector relies on warm 7d hits)
#   - Remove stale janitor run workspaces under /tmp older than 24h (cycle.sh
#     traps its own; this catches crashed-run leftovers)
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

export BULLHORN_CACHE_DIR="${IFOS_BULLHORN_CACHE_DIR:-${HOME}/.ifos-cache/bullhorn}"
export COMPANIES_HOUSE_CACHE_DIR="${IFOS_COMPANIES_HOUSE_CACHE_DIR:-${HOME}/.ifos-cache/companies-house}"

_jn_purge_dir() {  # <dir> <mtime_days>
  local dir="$1" days="$2"
  [[ -d "${dir}" ]] || { echo 0; return 0; }
  find "${dir}" -type f -mtime "+${days}" -delete -print 2>/dev/null | wc -l | tr -d ' '
}
BULLHORN_PURGED="$(_jn_purge_dir "${BULLHORN_CACHE_DIR}" 1)"          # 24h TTL
CH_PURGED="$(_jn_purge_dir "${COMPANIES_HOUSE_CACHE_DIR}" 7)"         # 7d TTL per agent.md §4 Step 6

# Stale run workspaces from crashed runs (cycle.sh traps its own on exit).
TMP_PURGED=0
while IFS= read -r _stale; do
  [[ -z "${_stale}" ]] && continue
  rm -rf "${_stale}" 2>/dev/null || continue
  TMP_PURGED=$((TMP_PURGED + 1))
done < <(find "${TMPDIR:-/tmp}" -maxdepth 1 -type d -name 'janitor-run-*' -mtime +1 2>/dev/null || true)

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Rate-limit saturation signal: deferred (analytical, not blocking).
# The @ifos/bullhorn + @ifos/companies-house connectors already gate at their
# own budgets in-process; a disk-cache-derived saturation heuristic adds no
# enforcement and is left to the canary cron (v1.1 analytics).
# ────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Emit green-tier audit row (per agent.md §3 actions list)
# ────────────────────────────────────────────────────────────────────────

TOTAL_PURGED=$((BULLHORN_PURGED + CH_PURGED + TMP_PURGED))

# Stays hh_decision_output until janitor_cleanup is registered in
# autosend-policy.yaml (substrate-owner change; see header).
hh_decision_output "janitor_cleanup" "tenant:${CTX_TENANT_SLUG}" \
  "bullhorn_cache_purged:${BULLHORN_PURGED}; companies_house_cache_purged:${CH_PURGED}; stale_run_dirs_purged:${TMP_PURGED}; total:${TOTAL_PURGED}"

# Operator-readable trace
printf '[janitor cleanup.sh] tenant=%s purged total=%d (bullhorn=%d companies_house=%d stale_tmp=%d)\n' \
  "${CTX_TENANT_SLUG}" "${TOTAL_PURGED}" "${BULLHORN_PURGED}" "${CH_PURGED}" "${TMP_PURGED}"

exit 0
