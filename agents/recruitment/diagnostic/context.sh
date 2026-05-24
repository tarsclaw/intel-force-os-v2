#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# Diagnostic agent — context.sh
#
# Status: Proposed (pre-W3-build scaffold; Day-12 author).
# Reading order: agent.md §4 Step 0 (session start) + §7 (voice + tone) first.
#
# Purpose: hydrate the agent's session with tenant-scoped context BEFORE
# the first workflow step runs. Per master brief §8.1 Change 1: load voice
# corpus + tone rules + recent edits + target_patch from the tenant's
# Postgres + vault. Per ADR-003: context.sh is the second of six bundle
# files (after agent.md, before validate.sh).
#
# Invocation contract:
#   - Sourced by cycle.sh at session start (not exec'd as subprocess)
#   - Populates these env vars for downstream steps:
#       CTX_TENANT_SLUG       (already set by ifosctl invocation)
#       CTX_AGENT_NAME=diagnostic
#       CTX_TARGET_PATCH      JSON path or inline (per common-target-patch.json)
#       CTX_VOICE_CORPUS_ID   active corpus id from voice_corpus table
#       CTX_TONE_RULES        JSON array of applicable rules
#       CTX_RECENT_EDITS_REF  count of recent_edit rows (drift signal)
#   - Sources _shared/hook-helpers.sh + _shared/voice-loader.sh
#   - Emits hh_decision_trigger("session_start", ...) as first audit row
#
# Failure modes:
#   - Missing tenant_slug → exit 1 with ESC_SCHEMA_VIOLATION
#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
#     production tenants; only migration-test allows empty corpus)
#   - target_patch unreachable → exit 1 with ESC_SCHEMA_VIOLATION

set -uo pipefail

CTX_AGENT_NAME="diagnostic"
export CTX_AGENT_NAME

# ────────────────────────────────────────────────────────────────────────
# 0 — Source shared helpers
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  echo "context.sh: CTX_AGENT_DIR unset; agent not rendered correctly" >&2
  exit 1
fi

# Resolve _shared/ helpers: rendered agent has them at
# ${CTX_AGENT_DIR}/.claude/hooks/_shared/ (symlink per ADR-003). For
# direct source-tree execution (Day-13 smoke tests), fall back to repo
# root via IFOS_REPO_ROOT or computed relative path.
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
  echo "context.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT or render the agent first" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"
# shellcheck source=/dev/null
source "${_SHARED_DIR}/voice-loader.sh"

# ────────────────────────────────────────────────────────────────────────
# 1 — Validate tenant context
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'context.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 1
fi

# Emit session-start audit row
hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
  || {
    printf 'context.sh: hh_decision_trigger failed; vault may be unwritable\n' >&2
    exit 1
  }

# ────────────────────────────────────────────────────────────────────────
# 2 — Load target_patch (tenant's commercial sweet spot)
# ────────────────────────────────────────────────────────────────────────
#
# target_patch defines sectors / geographies / size_bands / deal_size_band
# per common-target-patch.json schema. Loaded from tenant's _config.yaml or
# inline via env. Used in §4 Step 7 (ICP fit scoring).

# target_patch resolution order:
#   1. CTX_AGENT_DIR/target_patch.json (rendered agent path)
#   2. ${VAULT_ROOT}/${CTX_TENANT_SLUG}/target_patch.json (per-tenant vault)
#   3. Permissive default (empty patch — ICP fit degrades to "not computable")
TARGET_PATCH_FILE=""
for _candidate in \
  "${CTX_AGENT_DIR}/target_patch.json" \
  "${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/target_patch.json" ; do
  if [[ -f "${_candidate}" ]]; then
    TARGET_PATCH_FILE="${_candidate}"
    break
  fi
done

if [[ -n "${TARGET_PATCH_FILE}" ]]; then
  CTX_TARGET_PATCH=$(<"${TARGET_PATCH_FILE}")
else
  # shellcheck disable=SC2089,SC2090
  CTX_TARGET_PATCH='{"sectors":[],"size_bands":[],"geographies":[]}'
  printf 'context.sh: no target_patch.json found; ICP fit will degrade to "not computable"\n' >&2
fi
# shellcheck disable=SC2090
export CTX_TARGET_PATCH

# ────────────────────────────────────────────────────────────────────────
# 3 — Load voice corpus active row
# ────────────────────────────────────────────────────────────────────────
#
# Used in §4 Step 9 (conversation opener voice classification). The voice
# corpus is per-tenant; ANN query happens later in cycle.sh Step 9 against
# the active corpus.

VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
CTX_VOICE_CORPUS_ID=$(printf '%s' "${VOICE_CORPUS_JSON}" | python3 -c "
import sys, json
d = json.load(sys.stdin) if sys.stdin.read().strip() else {}
print(d.get('corpus_id', ''))
" 2>/dev/null || echo "")
export CTX_VOICE_CORPUS_ID

if [[ -z "${CTX_VOICE_CORPUS_ID}" && "${CTX_TENANT_SLUG}" != "migration-test" ]]; then
  printf 'context.sh: No active voice corpus for tenant %s\n' "${CTX_TENANT_SLUG}" >&2
  printf '  Production tenants require seeded corpus before agent run.\n' >&2
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# 4 — Load tone rules (filtered to diagnostic agent)
# ────────────────────────────────────────────────────────────────────────

CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
export CTX_TONE_RULES

TONE_RULE_COUNT=$(printf '%s' "${CTX_TONE_RULES}" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(len(d.get('rules', [])))
" 2>/dev/null || echo "0")

# ────────────────────────────────────────────────────────────────────────
# 5 — Load recent_edits (voice drift signal)
# ────────────────────────────────────────────────────────────────────────

CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
export CTX_RECENT_EDITS_REF

EDIT_COUNT=$(printf '%s' "${CTX_RECENT_EDITS_REF}" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(len(d.get('edits', [])))
" 2>/dev/null || echo "0")

# ────────────────────────────────────────────────────────────────────────
# 6 — Summary (printed at context-load completion)
# ────────────────────────────────────────────────────────────────────────

printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
  "${CTX_TENANT_SLUG}" "${CTX_VOICE_CORPUS_ID:-<empty>}" "${TONE_RULE_COUNT}" "${EDIT_COUNT}"

# End of context.sh
