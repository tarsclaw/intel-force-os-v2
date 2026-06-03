#!/usr/bin/env bash
# Scribe agent — context.sh (pre-cycle hydration; W5 Day-32 SKELETON)
#
# Status: Proposed (W5 Day-32 SKELETON; W6 build slice replaces stubs with
#         live package calls per agent.md §4 Step 0). v0.4 schema supplement
#         LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS) — bullhorn_corporation_id
#         + granola_workspace_id + operator_telegram_chat_id now allowlisted;
#         Step 2 + Step 3 + Step 6 below flip from "v0.4-supplement-pending"
#         to "canonical SELECT path available; SKELETON still uses env-var
#         fallback at v0.4 landing — W6 build wires the postgres read".
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
# Side effects (W6 build slice):
#   - Refresh Bullhorn OAuth tokens (two-step Step A + Step B per @ifos/bullhorn
#     src/auth.ts; per-corporation_id Promise dedup + 401-force-refresh per
#     cluster F R4 lesson)
#   - Refresh Granola OAuth tokens (OAuth 2.1 + PKCE per @ifos/granola src/auth.ts;
#     per-workspace_id Promise dedup)
#   - Pre-cache Granola accountInfo (plan_tier='paid' assumed per founder
#     2026-06-03 confirmation; short-circuits per-call Paid-plan guard on the
#     Granola client; 1h TTL per @ifos/granola README)
#   - Resolve bullhorn_corporation_id from tenant_adapters.config (v0.4-allowlisted)
#   - Resolve granola_workspace_id from tenant_adapters.config (v0.4-allowlisted)
#   - Load voice corpus + tone-rules YAML for tenant (for Step 6 tacit-note
#     voice classification per agent.md §7)
#   - Load firm-domain whitelist (for Step 7 validate.sh G6 PII regex pass)
#
# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
#   CTX_AGENT_NAME                       — "scribe"
#   CTX_BULLHORN_CORPORATION_ID          — per-tenant Bullhorn corp identifier
#   CTX_GRANOLA_WORKSPACE_ID             — per-tenant Granola workspace identifier
#   CTX_GRANOLA_PLAN_TIER                — "paid" assumed (founder 2026-06-03)
#   CTX_BULLHORN_TOKEN_STATE             — fresh | refreshed | failed
#   CTX_GRANOLA_TOKEN_STATE              — fresh | refreshed | failed
#   CTX_VOICE_CORPUS_ID                  — pgvector index ref (Step 6 narrative voice)
#   CTX_TONE_RULES_COUNT                 — number of tone_rule rows loaded
#   CTX_FIRM_DOMAIN_WHITELIST            — comma-separated tenant firm domains (G6 PII)
#   CTX_GRANOLA_LAST_POLL                — ISO timestamp of last poll-sweep
#                                          (for cycle.sh Step 1 listMeetings window)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'scribe/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'scribe/context.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
export CTX_AGENT_NAME="scribe"

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

# TODO(W6): swap to canonical tenant_adapters SELECT path now that v0.4
# supplement has LANDED. Implementation:
#   SELECT config->>'bullhorn_corporation_id' FROM tenant_adapters
#   WHERE tenant_slug = $1 AND adapter_name = 'bullhorn';
# Today's SKELETON uses env-var fallback; IFOS_FORCE_BULLHORN_CORPORATION_ID
# retained for fixture + local-dev use per established pattern.
export CTX_BULLHORN_CORPORATION_ID="${IFOS_FORCE_BULLHORN_CORPORATION_ID:-STUB}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Granola workspace_id resolution
# Reference: v0.4 supplement LANDED — granola_workspace_id top-level
# allowlisted (opaque string per @ifos/granola GranolaConfig shape).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6): swap to canonical tenant_adapters SELECT path:
#   SELECT config->>'granola_workspace_id' FROM tenant_adapters
#   WHERE tenant_slug = $1 AND adapter_name = 'granola';
# Today's SKELETON uses env-var fallback; IFOS_FORCE_GRANOLA_WORKSPACE_ID
# retained for fixture + local-dev use per established pattern.
export CTX_GRANOLA_WORKSPACE_ID="${IFOS_FORCE_GRANOLA_WORKSPACE_ID:-STUB}"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Granola plan_tier pre-cache (founder 2026-06-03 confirmed Business+)
# Reference: @ifos/granola README §"Scribe consumption pattern" — Scribe
# pre-caches plan_tier='paid' via getAccountInfo() (1h TTL) so per-call
# PAID_PLAN_TOOLS guard short-circuits before any wire round-trip on
# getTranscript + listFolders calls.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6): node -e "import('@ifos/granola').then(g => {
#   const client = new g.GranolaClient({config, transport});
#   const info = await g.getAccountInfo(client);
#   console.log(info.plan_tier);  // expected: 'paid' per founder 2026-06-03
#   client._setAccountInfoForTest(info);  // pre-cache for the cycle.sh session
# })"
# Per agent.md note + founder confirmation: Business+/Paid plan assumed at
# v1.0 default. If getAccountInfo returns 'free' at first commercial signup,
# we surface ESC_GRANOLA_PLAN_TIER + degrade to notes-only ingest (no transcripts).
export CTX_GRANOLA_PLAN_TIER="${IFOS_FORCE_GRANOLA_PLAN_TIER:-paid}"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Bullhorn OAuth refresh (two-step Step A + Step B)
# Reference: agent.md §4 Step 2; @ifos/bullhorn refreshTokens per src/auth.ts.
# Per-corporation_id Promise dedup; atomic file write. ESC_BULLHORN_AUTH on
# refresh failure after 2 retries (blocking; operator + ifos_oncall per
# catalogue routing).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6): @ifos/bullhorn refreshTokens(config, currentTokens) — config built
# from CTX_BULLHORN_CORPORATION_ID + token_file_path; on success: refreshed;
# on 6+ consecutive failures: emit ESC_BULLHORN_AUTH (blocking) + exit 1.
export CTX_BULLHORN_TOKEN_STATE="STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Granola OAuth refresh (OAuth 2.1 + PKCE)
# Reference: @ifos/granola src/auth.ts; per-workspace_id Promise dedup +
# atomic file write. ESC_GRANOLA_AUTH on refresh failure (blocking-equivalent;
# Scribe poll-sweep cannot proceed without Granola access).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6): @ifos/granola refreshTokens(config, currentTokens) — config built
# from CTX_GRANOLA_WORKSPACE_ID + token_file_path; on failure: emit
# ESC_GRANOLA_AUTH (blocking-equivalent; aligns with ESC_BULLHORN_AUTH severity).
# ESC_GRANOLA_AUTH is QUEUED for catalogue registration at W6 build start.
export CTX_GRANOLA_TOKEN_STATE="STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Voice corpus + tone rules (for Step 6 tacit-note narrative)
# Reference: agent.md §7. hh_load_tone_rules filtered by applies_to_agents
# containing 'scribe'; hh_load_voice_samples top-5 ANN matches for
# "internal call summary note" task context.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6): CTX_TONE_RULES=$(hh_load_tone_rules "scribe" 2>/dev/null || echo "[]")
# TODO(W6): CTX_TONE_RULES_COUNT=$(echo "${CTX_TONE_RULES}" | jq 'length')
export CTX_VOICE_CORPUS_ID="${IFOS_FORCE_VOICE_CORPUS_ID:-default}"
export CTX_TONE_RULES_COUNT="${CTX_TONE_RULES_COUNT:-0}"

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Firm-domain whitelist (for validate.sh G6 PII regex pass)
# Reference: agent.md §6 ESC_PII_LEAKAGE_RISK; validate.sh G6 grep pattern
# matches email addresses NOT in CTX_FIRM_DOMAIN_WHITELIST → block write.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6): SELECT config->>'firm_domains' FROM tenant_adapters
# WHERE tenant_slug = $1; default to tenant_slug suffix as the firm domain
# heuristic if not configured.
export CTX_FIRM_DOMAIN_WHITELIST="${IFOS_FORCE_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Granola last_poll resolution (for cycle.sh Step 1 listMeetings window)
# Reference: poll-sweep mode listMeetings since this timestamp; updated at
# session close. NOT a v0.4 allowlisted key (specific to Scribe runtime state
# rather than tenant config) — stored as a Scribe-internal cache file OR
# v1.1+ v0.5 supplement key if needed for cross-process state.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6): read from ~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt
# (Scribe-internal cache; not in tenant_adapters allowlist). Default to
# 5-min-ago if missing (matches the cron cadence; safe to slightly overlap
# on first run since list_meetings is idempotent + Scribe dedups by meeting_id
# in Step 4).
export CTX_GRANOLA_LAST_POLL="${IFOS_FORCE_GRANOLA_LAST_POLL:-$(date -u -v-5M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u --date='5 minutes ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '1970-01-01T00:00:00Z')}"

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Session-start trigger row (mandatory; anchors session in decision_log)
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" \
  "agent:scribe; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; workspace:${CTX_GRANOLA_WORKSPACE_ID}; plan_tier:${CTX_GRANOLA_PLAN_TIER}; voice_corpus:${CTX_VOICE_CORPUS_ID}; last_poll:${CTX_GRANOLA_LAST_POLL}"

# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
printf '[scribe context.sh] tenant=%s corp=%s workspace=%s plan_tier=%s bullhorn_token=%s granola_token=%s voice_corpus=%s tone_rules=%s firm_domains=%s last_poll=%s\n' \
  "${CTX_TENANT_SLUG}" "${CTX_BULLHORN_CORPORATION_ID}" "${CTX_GRANOLA_WORKSPACE_ID}" \
  "${CTX_GRANOLA_PLAN_TIER}" "${CTX_BULLHORN_TOKEN_STATE}" "${CTX_GRANOLA_TOKEN_STATE}" \
  "${CTX_VOICE_CORPUS_ID}" "${CTX_TONE_RULES_COUNT}" "${CTX_FIRM_DOMAIN_WHITELIST}" \
  "${CTX_GRANOLA_LAST_POLL}"

exit 0
