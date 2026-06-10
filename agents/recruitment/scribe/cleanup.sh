#!/usr/bin/env bash
# Scribe agent — cleanup.sh (post-run state purge; W6 build slice LIVE)
#
# Status: built (W6 build slice; the W5 Day-32 skeleton stubs are replaced
#         with live cache-purge + last-poll-stamp logic).
# Reading order: agent.md §4 Step 10 (session close) + §6 ESC code mappings first.
#
# Per agent.md §3 actions list: Scribe's cleanup action_type is
# `scribe_cleanup` (green tier — internal-only audit row recording
# cache-purge status + workspace cleanup; no external comms).
#
# Per agents/_shared/autosend-policy.yaml: `scribe_cleanup` is still QUEUED
# for registration (verified 2026-06-10 — registering it requires an
# agents/_shared edit, which is out of this build slice's boundary). Until it
# is registered, the audit row is emitted via hh_decision_output (matches the
# CC cleanup precedent); flip to hh_decision_action when the policy entry lands.
#
# Invocation contract:
#   bash cleanup.sh
#
# Inputs (env):
#   CTX_AGENT_DIR, CTX_TENANT_SLUG, CTX_AGENT_NAME (already set by context.sh + cycle.sh)
#   CTX_GRANOLA_WORKSPACE_ID (for the last-poll cache filename)
#
# Side effects:
#   - Purge ~/.ifos-cache/bullhorn/* older than 24h (transient HTTP cache; keeps
#     token files at ~/.ifos-local-vault/<tenant>/bullhorn-tokens-<corp>.json)
#   - Purge ~/.ifos-cache/granola/* older than 10min (10-min default TTL per
#     @ifos/granola cache module; transcripts are immutable so a longer TTL
#     would also be safe — we match the module default)
#   - Purge /tmp/scribe-<tenant>-* run artefacts older than 24h (Step 3 wrote
#     transcripts mode 0600; auto-purge prevents stale transcript exposure)
#   - Stamp ~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt with the
#     session end timestamp so the next cycle.sh poll-sweep window starts here
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

export BULLHORN_CACHE_DIR="${IFOS_BULLHORN_CACHE_DIR:-${HOME}/.ifos-cache/bullhorn}"
export GRANOLA_CACHE_DIR="${IFOS_GRANOLA_CACHE_DIR:-${HOME}/.ifos-cache/granola}"

_purge_older_than() {  # <dir> <find-age-predicate> <value>
  local dir="$1" pred="$2" val="$3"
  [[ -d "${dir}" ]] || { echo 0; return 0; }
  find "${dir}" -type f "${pred}" "${val}" -delete -print 2>/dev/null | wc -l | tr -d ' '
}

BULLHORN_PURGED="$(_purge_older_than "${BULLHORN_CACHE_DIR}" -mtime +1)"
GRANOLA_PURGED="$(_purge_older_than "${GRANOLA_CACHE_DIR}" -mmin +10)"

# /tmp run artefacts (transcripts + fields/proposal scratch): purge >24h old.
TMP_TRANSCRIPTS_PURGED=0
while IFS= read -r _tmpf; do
  [[ -z "${_tmpf}" ]] && continue
  TMP_TRANSCRIPTS_PURGED=$((TMP_TRANSCRIPTS_PURGED + 1))
done < <(find /tmp -maxdepth 1 -type f -name "scribe-${CTX_TENANT_SLUG}-*" -mtime +1 -delete -print 2>/dev/null || true)

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Stamp the Scribe-internal last-poll cache file
# (~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt) — the next
# cycle.sh poll-sweep listMeetings window starts from this point.
# ────────────────────────────────────────────────────────────────────────

LAST_POLL_CACHE_DIR="${HOME}/.ifos-cache/scribe/${CTX_TENANT_SLUG}"
LAST_POLL_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
LAST_POLL_STATE="written"
if mkdir -p "${LAST_POLL_CACHE_DIR}" 2>/dev/null; then
  printf '%s\n' "${LAST_POLL_TS}" > "${LAST_POLL_CACHE_DIR}/last-poll-${CTX_GRANOLA_WORKSPACE_ID:-unset}.txt" 2>/dev/null \
    || LAST_POLL_STATE="write_failed"
else
  LAST_POLL_STATE="mkdir_failed"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Emit green-tier audit row (per agent.md §3 actions list)
# scribe_cleanup is QUEUED in autosend-policy.yaml → hh_decision_output until
# the registration lands (see header note; CC cleanup precedent).
# ────────────────────────────────────────────────────────────────────────

TOTAL_PURGED=$((BULLHORN_PURGED + GRANOLA_PURGED + TMP_TRANSCRIPTS_PURGED))

hh_decision_output "scribe_cleanup" "tenant:${CTX_TENANT_SLUG}" \
  "bullhorn_cache_purged:${BULLHORN_PURGED}; granola_cache_purged:${GRANOLA_PURGED}; tmp_transcripts_purged:${TMP_TRANSCRIPTS_PURGED}; total:${TOTAL_PURGED}; last_poll_updated:${LAST_POLL_TS}; last_poll_state:${LAST_POLL_STATE}"

# Operator-readable trace
printf '[scribe cleanup.sh] tenant=%s purged total=%d (bullhorn=%d granola=%d tmp=%d) last_poll=%s (%s)\n' \
  "${CTX_TENANT_SLUG}" "${TOTAL_PURGED}" "${BULLHORN_PURGED}" "${GRANOLA_PURGED}" \
  "${TMP_TRANSCRIPTS_PURGED}" "${LAST_POLL_TS}" "${LAST_POLL_STATE}"

exit 0
