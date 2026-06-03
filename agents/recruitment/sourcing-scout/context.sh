#!/usr/bin/env bash
# Sourcing Scout agent — context.sh (pre-cycle hydration; W5 Day-33 SKELETON)
#
# Status: Proposed (W5 Day-33 SKELETON; W9 build slice replaces stubs with
#         live package calls per agent.md §4 Step 0). v0.4 schema supplement
#         LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS) —
#         bullhorn_corporation_id is now top-level allowlisted. v0.3 supplement
#         (LIVE on VPS post v0.4 migration) allowlists blocked_recipients +
#         operator_telegram_chat_id (v0.4 addition).
# Reading order: agent.md §2 (invocation surface) + §4 Step 0 (session start) +
#         §7 (voice + tone constraints) first.
#
# Per ADR-003 v2 agent-bundle pattern: bus invokes context.sh BEFORE cycle.sh
# at session start. context.sh hydrates session-scoped CTX_* env vars that
# cycle.sh + validate.sh read, then emits the mandatory session_start trigger
# row to anchor the session in decision_log.
#
# Invocation contract:
#   bash context.sh
#
# Inputs (env from bus):
#   CTX_AGENT_DIR    — agent's directory (this file's dirname)
#   CTX_TENANT_SLUG  — tenant the run targets
#
# Side effects (W9 build slice):
#   - Refresh Bullhorn OAuth tokens (READ-ONLY; per agent.md §1 + §6 contracts;
#     ESC_BULLHORN_AUTH on 2-retry fail — Sourcing-Scout-specific degraded
#     mode = skip Bullhorn source + continue with Reed + CV-Library)
#   - Refresh Reed API token (TODO Phase 8 — @ifos/reed scaffold pending)
#   - Refresh CV-Library API token (TODO Phase 8 — @ifos/cv-library scaffold pending)
#   - Resolve bullhorn_corporation_id from tenant_adapters.config (v0.4-allowlisted)
#   - Load tenant DNC list from tenant_adapters.config.blocked_recipients
#     (v0.3-allowlisted; LIVE on VPS; array<string>) → CTX_DNC_BLOCKED_RECIPIENTS
#   - Load voice corpus + tone-rules for tenant (for Step 9 rationale voice
#     classification per agent.md §7)
#   - Load firm-domain whitelist (for validate.sh G6 PII regex pass)
#
# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
#   CTX_AGENT_NAME                       — "sourcing-scout"
#   CTX_BULLHORN_CORPORATION_ID          — per-tenant Bullhorn corp identifier
#   CTX_BULLHORN_TOKEN_STATE             — fresh | refreshed | failed
#   CTX_REED_TOKEN_STATE                 — TODO Phase 8 (package scaffold pending)
#   CTX_CVLIBRARY_TOKEN_STATE            — TODO Phase 8 (package scaffold pending)
#   CTX_VOICE_CORPUS_ID                  — pgvector index ref (Step 9 narrative voice)
#   CTX_TONE_RULES_COUNT                 — number of tone_rule rows loaded
#   CTX_FIRM_DOMAIN_WHITELIST            — comma-separated tenant firm domains (G6 PII)
#   CTX_DNC_BLOCKED_RECIPIENTS           — JSON array string of DNC identifiers
#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — Step 11 notification recipient
#                                          (v0.4-allowlisted; LIVE on VPS)
#   CTX_SOURCES_ACTIVE_COUNT             — count of sources Sourcing Scout will
#                                          query at v1.0 (=3; Bullhorn + Reed +
#                                          CV-Library; LinkedIn excluded per
#                                          Proxycurl shutdown)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'sourcing-scout/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'sourcing-scout/context.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
export CTX_AGENT_NAME="sourcing-scout"

# 4-candidate _shared/ helper fallback (matches sibling agents post commit d7d52c5).
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
  printf 'context.sh: cannot locate _shared/ helpers\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Bullhorn corporation_id resolution
# Reference: v0.4 supplement LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS).
# bullhorn_corporation_id is now top-level allowlisted in
# validate_tenant_adapters_config_v0_4 (pattern '^[0-9]+$').
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): swap to canonical tenant_adapters SELECT path now that v0.4
# supplement has LANDED. Implementation:
#   SELECT config->>'bullhorn_corporation_id' FROM tenant_adapters
#   WHERE tenant_slug = $1 AND adapter_name = 'bullhorn';
# Today's SKELETON uses env-var fallback; IFOS_FORCE_BULLHORN_CORPORATION_ID
# retained for fixture + local-dev use per established pattern.
export CTX_BULLHORN_CORPORATION_ID="${IFOS_FORCE_BULLHORN_CORPORATION_ID:-STUB}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn OAuth refresh (read-only; per agent.md §1 + §6)
# Reference: agent.md §4 Step 2; @ifos/bullhorn refreshTokens per src/auth.ts.
# Per-corporation_id Promise dedup; atomic file write.
# ESC_BULLHORN_AUTH on refresh failure after 2 retries (blocking; degraded
# mode = skip Bullhorn source + continue with Reed + CV-Library; per
# agent.md §4 Step 2 catalogue interpretation for Sourcing Scout).
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): @ifos/bullhorn refreshTokens(config, currentTokens) — config built
# from CTX_BULLHORN_CORPORATION_ID + token_file_path; on failure: emit
# ESC_BULLHORN_AUTH but DO NOT exit 1 (Sourcing-Scout degraded mode continues
# with non-Bullhorn sources). Set CTX_BULLHORN_TOKEN_STATE="failed".
export CTX_BULLHORN_TOKEN_STATE="STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Reed token refresh (TODO Phase 8 — @ifos/reed package pending)
# Reference: agent.md §4 Step 2; @ifos/reed will provide refreshTokens or
# API-key bearer auth (verify via WebFetch reed.co.uk dev docs at Phase 8).
# ESC_REED_AUTH on failure → degraded mode = cached Reed search only
# (when cache exists; v1.0 ships without warm cache so degraded = effectively
# skip Reed source).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6+ commercial signup + Phase 8 package scaffold + W9 wiring):
# @ifos/reed refreshTokens OR loadApiKey per the auth model verified at
# Phase 8 WebFetch. Set CTX_REED_TOKEN_STATE per outcome.
export CTX_REED_TOKEN_STATE="STUB_PHASE_8_PENDING"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — CV-Library token refresh (TODO Phase 8 — @ifos/cv-library pending)
# Reference: agent.md §4 Step 2; @ifos/cv-library will provide refreshTokens
# or API-key bearer auth (verify via WebFetch at Phase 8). ESC_CVLIBRARY_AUTH
# on failure → same degraded-mode pattern as Reed.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6+ commercial signup + Phase 8 package scaffold + W9 wiring):
# @ifos/cv-library auth refresh; set CTX_CVLIBRARY_TOKEN_STATE per outcome.
export CTX_CVLIBRARY_TOKEN_STATE="STUB_PHASE_8_PENDING"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Voice corpus + tone rules (for Step 9 per-candidate rationale)
# Reference: agent.md §7. hh_load_tone_rules filtered by applies_to_agents
# containing 'sourcing_scout'; hh_load_voice_samples top-5 ANN matches for
# "candidate sourcing rationale" task context.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): CTX_TONE_RULES=$(hh_load_tone_rules "sourcing_scout" 2>/dev/null || echo "[]")
# TODO(W9): CTX_TONE_RULES_COUNT=$(echo "${CTX_TONE_RULES}" | jq 'length')
export CTX_VOICE_CORPUS_ID="${IFOS_FORCE_VOICE_CORPUS_ID:-default}"
export CTX_TONE_RULES_COUNT="${CTX_TONE_RULES_COUNT:-0}"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — DNC list load (tenant_adapters.config.blocked_recipients)
# Reference: agent.md §4 Step 8 + §5 G5; v0.3-allowlisted (LIVE on VPS post
# v0.4 migration commit a1bbcf6). Array<string> validator per v0.3
# supplement §4. Loaded once at session start; reused at Step 8 (cycle.sh
# filter) + G5 (validate.sh defence-in-depth).
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): SELECT config->'blocked_recipients' FROM tenant_adapters
# WHERE tenant_slug = $1 AND adapter_name = 'sourcing-scout';
# Default to empty JSON array if no row OR no key.
export CTX_DNC_BLOCKED_RECIPIENTS="${IFOS_FORCE_DNC_BLOCKED_RECIPIENTS:-[]}"

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Firm-domain whitelist (for validate.sh G6 PII regex pass)
# Reference: agent.md §5 + §6 ESC_PII_LEAKAGE_RISK; validate.sh G6 grep
# pattern matches email addresses NOT in CTX_FIRM_DOMAIN_WHITELIST → block.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): SELECT config->>'firm_domains' FROM tenant_adapters
# WHERE tenant_slug = $1; default to tenant_slug suffix as the firm domain
# heuristic if not configured.
export CTX_FIRM_DOMAIN_WHITELIST="${IFOS_FORCE_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Operator routing (Telegram chat ID for Step 11 notification)
# Reference: v0.4 supplement LANDED — operator_telegram_chat_id allowlisted
# (pattern '^-?[0-9]+$'). Used by Step 11 cycle.sh for completion
# notification (Telegram OR Brain UI in-app).
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): swap to canonical tenant_adapters SELECT path now v0.4 LANDED.
#   SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
#   WHERE tenant_slug = $1;
# Today's SKELETON uses env-var fallback; IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID
# retained for fixture + local-dev use per established pattern.
export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Active source count (v1.0 = 3 per Proxycurl shutdown caveat)
# ────────────────────────────────────────────────────────────────────────

export CTX_SOURCES_ACTIVE_COUNT="3"   # Bullhorn passive + Reed + CV-Library
                                       # (LinkedIn excluded per agent.md v1.0 caveat)

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Session-start trigger row (mandatory; anchors session in decision_log)
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" \
  "agent:sourcing-scout; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; sources_active:${CTX_SOURCES_ACTIVE_COUNT}; voice_corpus:${CTX_VOICE_CORPUS_ID}"

# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
printf '[sourcing-scout context.sh] tenant=%s corp=%s sources_active=%s bullhorn_token=%s reed=%s cvlibrary=%s voice_corpus=%s tone_rules=%s firm_domains=%s\n' \
  "${CTX_TENANT_SLUG}" "${CTX_BULLHORN_CORPORATION_ID}" "${CTX_SOURCES_ACTIVE_COUNT}" \
  "${CTX_BULLHORN_TOKEN_STATE}" "${CTX_REED_TOKEN_STATE}" "${CTX_CVLIBRARY_TOKEN_STATE}" \
  "${CTX_VOICE_CORPUS_ID}" "${CTX_TONE_RULES_COUNT}" "${CTX_FIRM_DOMAIN_WHITELIST}"

exit 0
