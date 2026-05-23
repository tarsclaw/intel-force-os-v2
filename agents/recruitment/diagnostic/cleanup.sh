#!/usr/bin/env bash
#
# Diagnostic agent — cleanup.sh
#
# Status: Proposed (pre-W3-build scaffold; Day-12 author).
# Reading order: agent.md §4 (workflow + gotchas) first — specifically
# gotcha §6.1 (LinkedIn ToS: no profile data persistence beyond audit).
#
# Per ADR-003 v2 bundle pattern: cleanup.sh runs after cycle.sh succeeds
# OR fails. Drops any transient state that wouldn't survive a real-world
# multi-tenant render. Most critical: LinkedIn profile data MUST NOT be
# cached to disk per their ToS.
#
# Invocation: bash cleanup.sh
#
# Exit codes:
#   0  Cleanup successful (or nothing to clean)
#   1  Cleanup failure on a critical path (LinkedIn cache still present)

set -uo pipefail

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'cleanup.sh: CTX_AGENT_DIR unset; nothing to clean\n' >&2
  exit 0
fi

# shellcheck source=/dev/null
source "${CTX_AGENT_DIR}/.claude/hooks/_shared/hook-helpers.sh"

# ────────────────────────────────────────────────────────────────────────
# 1 — LinkedIn transient cache purge (CRITICAL per ToS gotcha §6.1)
# ────────────────────────────────────────────────────────────────────────
#
# At W3 build: tools/linkedin_readonly_connector caches profile responses
# in /tmp/ifos-linkedin-cache-<pid>/. Even though tools.yaml sets ttl=0,
# defense-in-depth: explicit purge here.

LINKEDIN_CACHE_PATTERN="/tmp/ifos-linkedin-cache-*"
PURGED=0

# shellcheck disable=SC2086
for cache_dir in ${LINKEDIN_CACHE_PATTERN}; do
  if [[ -d "${cache_dir}" ]]; then
    rm -rf "${cache_dir}"
    PURGED=$((PURGED + 1))
  fi
done

# Verify nothing left
# shellcheck disable=SC2086,SC2012
LEFTOVER=$(ls -d ${LINKEDIN_CACHE_PATTERN} 2>/dev/null | wc -l | tr -d ' ')
if (( LEFTOVER != 0 )); then
  printf 'cleanup.sh: CRITICAL — LinkedIn cache not fully purged (%d dirs remain)\n' "${LEFTOVER}" >&2

  hh_decision_action "linkedin_cache_purge_fail" "cleanup:${CTX_TENANT_SLUG}" \
    "$(date +%s)" \
    '{"escalation_code":"ESC_PII_LEAKAGE_RISK","reason":"LinkedIn cache purge incomplete"}' \
    2>/dev/null || true

  exit 1
fi

if (( PURGED > 0 )); then
  printf 'cleanup.sh: purged %d LinkedIn cache dir(s)\n' "${PURGED}"
fi

# ────────────────────────────────────────────────────────────────────────
# 2 — Web scraper response cache (lower-criticality; can persist 1h)
# ────────────────────────────────────────────────────────────────────────
#
# Companies House cache stays per tools.yaml (7-day TTL).
# Web scraper cache stays per tools.yaml (1-hour TTL).
# Both are public data; no ToS purge mandate.

# ────────────────────────────────────────────────────────────────────────
# 3 — Audit row to confirm cleanup ran
# ────────────────────────────────────────────────────────────────────────

hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
  "$(date +%s)" \
  "$(printf '{"purged_linkedin_cache_dirs":%d}' "${PURGED}")" \
  2>/dev/null || true

exit 0
