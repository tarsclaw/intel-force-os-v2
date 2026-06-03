#!/usr/bin/env bash
# Scribe agent — cleanup.sh (post-run state purge; W5 Day-32 SKELETON)
#
# Status: Proposed (W5 Day-32 SKELETON; W6 build slice replaces stubs with
#         live cache-purge calls).
# Reading order: agent.md §4 Step 10 (session close) + §6 ESC code mappings first.
#
# Per agent.md §3 actions list: Scribe's cleanup action_type is
# `scribe_cleanup` (green tier — internal-only audit row recording
# cache-purge status + workspace cleanup; no external comms).
#
# Per agents/_shared/autosend-policy.yaml: `scribe_cleanup` is QUEUED for
# registration at W6 build start (per tools.yaml status table). Once
# registered + the W6 build wires the real purge logic, this script emits
# the action row + green-tier classification.
#
# Invocation contract:
#   bash cleanup.sh
#
# Inputs (env):
#   CTX_AGENT_DIR, CTX_TENANT_SLUG, CTX_AGENT_NAME (already set by context.sh + cycle.sh)
#
# Side effects (W6 build slice):
#   - Purge ~/.ifos-cache/bullhorn/* older than 24h (transient HTTP cache; keeps
#     token files at ~/.ifos-local-vault/<tenant>/bullhorn-tokens-<corp>.json)
#   - Purge ~/.ifos-cache/granola/* older than 10min for non-transcript entries
#     (10min default TTL per @ifos/granola cache; transcripts immutable so a
#     longer TTL would also be safe but we match the cache module default)
#   - Purge /tmp/scribe-<tenant>-*.txt transcripts older than 24h (Step 3
#     wrote these mode 0600; auto-purge prevents stale transcript exposure)
#   - Update Scribe-internal last-poll cache file with session end timestamp
#     (~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt) so the next
#     cycle.sh poll-sweep starts from this point
#
# What cleanup.sh does NOT touch:
#   - Token files (~/.ifos-local-vault/<tenant>/{bullhorn,granola}-tokens-*.json)
#   - Vault tacit-note artefacts (/vault/<tenant>/scribe-notes/) — kept for audit
#   - decision_log rows (append-only per T5 tenancy invariant)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'scribe/cleanup.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'scribe/cleanup.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=scribe}"

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

# Exported so the W6 build-slice can extend the find -delete logic via
# child processes without re-resolving the env var fallback chain.
export BULLHORN_CACHE_DIR="${IFOS_BULLHORN_CACHE_DIR:-${HOME}/.ifos-cache/bullhorn}"
export GRANOLA_CACHE_DIR="${IFOS_GRANOLA_CACHE_DIR:-${HOME}/.ifos-cache/granola}"
export SCRIBE_TMP_PATTERN="/tmp/scribe-${CTX_TENANT_SLUG}-*.txt"

# TODO(W6): replace these STUB counts with actual find -delete invocations
# that prune entries older than the per-provider TTL. Skeleton emits zero so
# the audit row shape is preserved for the build-slice author.
BULLHORN_PURGED=0
GRANOLA_PURGED=0
TMP_TRANSCRIPTS_PURGED=0
# When ready, replace with the real purge logic:
#   if [[ -d "${BULLHORN_CACHE_DIR}" ]]; then
#     BULLHORN_PURGED=$(find "${BULLHORN_CACHE_DIR}" -type f -mtime +1 -delete -print 2>/dev/null | wc -l | tr -d ' ')
#   fi
#   if [[ -d "${GRANOLA_CACHE_DIR}" ]]; then
#     GRANOLA_PURGED=$(find "${GRANOLA_CACHE_DIR}" -type f -mmin +10 -delete -print 2>/dev/null | wc -l | tr -d ' ')
#   fi
#   # /tmp transcripts: purge older than 24h
#   for tmp_file in ${SCRIBE_TMP_PATTERN}; do
#     [[ -f "$tmp_file" ]] || continue
#     find "$tmp_file" -mtime +1 -delete -print 2>/dev/null | head -1 && TMP_TRANSCRIPTS_PURGED=$((TMP_TRANSCRIPTS_PURGED + 1))
#   done

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Update Scribe-internal last-poll cache file (for next cycle.sh poll-sweep)
# ────────────────────────────────────────────────────────────────────────

# TODO(W6): write ISO timestamp of THIS session's end to
# ~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt so the next
# cycle.sh Step 1 (mode=poll-sweep) starts listMeetings from this point.
# Skeleton: emit the audit row shape; W6 wires the file write.
LAST_POLL_CACHE_DIR="${HOME}/.ifos-cache/scribe/${CTX_TENANT_SLUG}"
mkdir -p "${LAST_POLL_CACHE_DIR}" 2>/dev/null || true
LAST_POLL_TS_STUB="STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Emit green-tier audit row (per agent.md §3 actions list)
# ────────────────────────────────────────────────────────────────────────

TOTAL_PURGED=$((BULLHORN_PURGED + GRANOLA_PURGED + TMP_TRANSCRIPTS_PURGED))

# TODO(W6): once scribe_cleanup action_type is registered in
# autosend-policy.yaml (currently QUEUED per tools.yaml status table), switch
# from hh_decision_output to hh_decision_action for proper tier classification.
hh_decision_output "scribe_cleanup" "tenant:${CTX_TENANT_SLUG}" \
  "bullhorn_cache_purged:${BULLHORN_PURGED}; granola_cache_purged:${GRANOLA_PURGED}; tmp_transcripts_purged:${TMP_TRANSCRIPTS_PURGED}; total:${TOTAL_PURGED}; last_poll_updated:${LAST_POLL_TS_STUB}; mode:SKELETON"

# Operator-readable trace
printf '[scribe cleanup.sh] tenant=%s purged total=%d (bullhorn=%d granola=%d tmp=%d) last_poll=%s mode=SKELETON\n' \
  "${CTX_TENANT_SLUG}" "${TOTAL_PURGED}" "${BULLHORN_PURGED}" "${GRANOLA_PURGED}" \
  "${TMP_TRANSCRIPTS_PURGED}" "${LAST_POLL_TS_STUB}"

exit 0
