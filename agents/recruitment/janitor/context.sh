#!/usr/bin/env bash
# Janitor agent — context.sh (pre-cycle hydration; W5 Day-31 SKELETON)
#
# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice replaces stubs with
#         live package calls per agent.md §4 Step 0). v0.4 schema supplement
#         LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS) — bullhorn_corporation_id
#         + operator_telegram_chat_id now allowlisted; Step 2 + Step 5 below
#         flip from "v0.4-supplement-pending" to "canonical SELECT path
#         available; SKELETON still uses env-var fallback at v0.4 landing —
#         W6-7 build wires the postgres read".
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
# Side effects (W6-7 build slice):
#   - Refresh Bullhorn OAuth tokens (two-step Step A + Step B per @ifos/bullhorn
#     src/auth.ts; per-corporation_id Promise dedup)
#   - Resolve bullhorn_corporation_id from tenant_adapters.config (v0.4-allowlisted)
#   - Resolve operator_telegram_chat_id from tenant_adapters.config (v0.4-allowlisted)
#   - Load voice corpus + tone-rules YAML for tenant (for Step 8 tacit-note
#     voice classification per agent.md §7)
#   - Load recent_edit rows from last 30 days (for Step 8 tacit-note harvest;
#     v0.3 supplement §2a grants Janitor R access)
#   - Resolve dedup confidence threshold from tenant_adapters.config (default
#     0.85 per ULTRAPLAN A2 line 510; per-tenant override range [0.75, 0.95]
#     enforced by v0.3 validator trigger)
#
# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
#   CTX_AGENT_NAME                       — "janitor"
#   CTX_BULLHORN_CORPORATION_ID          — per-tenant Bullhorn corp identifier
#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID (Step 11)
#   CTX_BULLHORN_TOKEN_STATE             — fresh | refreshed | failed
#   CTX_VOICE_CORPUS_ID                  — pgvector index ref (Step 8 narrative voice)
#   CTX_TONE_RULES_COUNT                 — number of tone_rule rows loaded
#   CTX_JANITOR_DEDUP_THRESHOLD          — default 0.85; per-tenant override [0.75, 0.95]
#   CTX_RECENT_EDITS_WINDOW_DAYS         — 30 (Step 8 lookback window per agent.md §4)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'janitor/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'janitor/context.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
export CTX_AGENT_NAME="janitor"

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
# Step 1 — Dedup confidence threshold (per-tenant override; default 0.85)
# Reference: ULTRAPLAN A2 line 510 verbatim. v0.3 supplement §4
# tenant_adapters_config_additions.janitor_dedup_threshold; validator allowed
# range [0.75, 0.95] per migrations/v0.2-to-v0.3.sql §5.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): canonical SELECT path available — v0.3 supplement LANDED;
# v0.3 trigger active on VPS. Implementation:
#   SELECT config->>'janitor_dedup_threshold' FROM tenant_adapters
#   WHERE tenant_slug = $1 AND adapter_name = 'janitor';
# Today's SKELETON uses env-var fallback (IFOS_FORCE_JANITOR_DEDUP_THRESHOLD).
export CTX_JANITOR_DEDUP_THRESHOLD="${IFOS_FORCE_JANITOR_DEDUP_THRESHOLD:-0.85}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn corporation_id resolution
# Reference: v0.4 supplement LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS).
# bullhorn_corporation_id is now top-level allowlisted in
# validate_tenant_adapters_config_v0_4 (pattern '^[0-9]+$').
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): swap to canonical tenant_adapters SELECT path now that v0.4
# supplement has LANDED — bullhorn_corporation_id allowlisted. Implementation:
#   SELECT config->>'bullhorn_corporation_id' FROM tenant_adapters
#   WHERE tenant_slug = $1 AND adapter_name = 'bullhorn';
# Today's SKELETON uses env-var fallback; IFOS_FORCE_BULLHORN_CORPORATION_ID
# retained for fixture + local-dev use per established pattern.
export CTX_BULLHORN_CORPORATION_ID="${IFOS_FORCE_BULLHORN_CORPORATION_ID:-STUB}"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Bullhorn OAuth refresh (two-step Step A + Step B)
# Reference: agent.md §4 Step 1; @ifos/bullhorn refreshTokens per src/auth.ts
# (Step A OAuth refresh at auth-{region}.bullhornstaffing.com; Step B REST
# login at rest.bullhornstaffing.com/rest-services/login → BhRestToken +
# per-corp restUrl). Per-corporation_id Promise dedup; atomic file write.
# ESC_BULLHORN_AUTH on refresh failure after 2 retries (blocking; operator +
# ifos_oncall_chat_id per catalogue routing).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): node -e "import('@ifos/bullhorn').then(b => {
#   const tokens = await b.loadTokens(config);
#   const refreshed = await b.refreshTokens(config, tokens);
#   console.log('refreshed');
# })"
# On 6+ consecutive failures: emit ESC_BULLHORN_AUTH (blocking) + exit 1.
export CTX_BULLHORN_TOKEN_STATE="STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Voice corpus + tone rules (for Step 8 tacit-note narrative)
# Reference: agent.md §7. hh_load_tone_rules filtered by applies_to_agents
# containing 'janitor'; hh_load_voice_samples top-5 ANN matches for
# "internal note summary" task context.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): CTX_TONE_RULES=$(hh_load_tone_rules "janitor" 2>/dev/null || echo "[]")
# TODO(W6-7): CTX_TONE_RULES_COUNT=$(echo "${CTX_TONE_RULES}" | jq 'length')
export CTX_VOICE_CORPUS_ID="${IFOS_FORCE_VOICE_CORPUS_ID:-default}"
export CTX_TONE_RULES_COUNT="${CTX_TONE_RULES_COUNT:-0}"

# Recent edits lookback window (Step 8 tacit-note harvest) — fixed at 30 days
# per agent.md §4 Step 8 (30-day rolling window).
export CTX_RECENT_EDITS_WINDOW_DAYS="30"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Operator routing (Telegram chat ID for Step 11 + ESC_DUPLICATE_DETECTED)
# Reference: v0.4 supplement LANDED — operator_telegram_chat_id allowlisted
# (pattern '^-?[0-9]+$'). Used by Step 11 nightly summary notification AND
# (when validate.sh G3 fails on recent-activity-but-high-confidence) by the
# ESC_DUPLICATE_DETECTED Telegram approval gate.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): swap to canonical tenant_adapters SELECT path:
#   SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
#   WHERE tenant_slug = $1;
# Today's SKELETON uses env-var fallback; IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID
# retained for fixture + local-dev use per Concierge precedent.
export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Session-start trigger row (mandatory; anchors session in decision_log)
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" \
  "agent:janitor; tenant:${CTX_TENANT_SLUG}; corporation_id:${CTX_BULLHORN_CORPORATION_ID}; dedup_threshold:${CTX_JANITOR_DEDUP_THRESHOLD}; voice_corpus:${CTX_VOICE_CORPUS_ID}"

# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
printf '[janitor context.sh] tenant=%s corp=%s dedup_threshold=%s bullhorn_token=%s voice_corpus=%s tone_rules=%s\n' \
  "${CTX_TENANT_SLUG}" "${CTX_BULLHORN_CORPORATION_ID}" "${CTX_JANITOR_DEDUP_THRESHOLD}" \
  "${CTX_BULLHORN_TOKEN_STATE}" "${CTX_VOICE_CORPUS_ID}" "${CTX_TONE_RULES_COUNT}"

exit 0
