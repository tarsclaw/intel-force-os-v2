#!/usr/bin/env bash
# Scribe agent — context.sh (pre-cycle hydration; W6 build slice LIVE)
#
# Status: built (W6 build slice; replaces the W5 Day-32 skeleton stubs with
#         live tenant_adapters reads + bridge-backed token state). v0.4
#         schema supplement LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS):
#         bullhorn_corporation_id + granola_workspace_id are top-level
#         allowlisted keys — Steps 1+2 below read the canonical SELECT path,
#         with IFOS_FORCE_* env fallbacks retained for fixtures + local dev.
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
# Honest-scope (spec-002 §8): Bullhorn dev creds are EMPTY and the Granola
# IFOS-side OAuth token is NOT on disk (the Claude-Code MCP keychain token is
# NOT what @ifos/granola reads — it expects
# ~/.ifos-local-vault/<tenant>/granola-tokens-<workspace_id>.json). Token
# states below therefore resolve honestly to "unavailable"/"no_token" until
# the founder provisions creds; they are NEVER faked. Fixture suites use
# BH_BRIDGE_TEST_MODE (see bin/bh-bridge.sh) to prove the green path.
#
# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
#   CTX_AGENT_NAME                — "scribe"
#   CTX_BULLHORN_CORPORATION_ID  — per-tenant Bullhorn corp identifier
#   CTX_GRANOLA_WORKSPACE_ID     — per-tenant Granola workspace identifier
#   CTX_GRANOLA_PLAN_TIER        — "paid" assumed (founder 2026-06-03)
#   CTX_BULLHORN_TOKEN_STATE     — fresh|refreshed|failed|unavailable
#   CTX_GRANOLA_TOKEN_STATE      — fresh|no_token|unavailable
#   CTX_VOICE_CORPUS_ID          — active voice_corpus id OR "none"
#   CTX_TONE_RULES_COUNT         — number of scribe-applicable tone_rule rows
#   CTX_FIRM_DOMAIN_WHITELIST    — comma-separated firm domains (G-PII check)
#   CTX_GRANOLA_LAST_POLL        — ISO timestamp of last poll-sweep

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

# RLS-scoped single-value tenant_adapters read; empty string on any failure.
_ctx_adapter_key() {  # <adapter_name> <config_key>
  if [[ -z "${IFOS_DB_URL:-}" ]] || ! command -v psql >/dev/null 2>&1; then
    echo ""; return 0
  fi
  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" --set=an="$1" --set=k="$2" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(config->>:'k','') FROM tenant_adapters
WHERE tenant_slug = :'tenant' AND adapter_name = :'an' LIMIT 1;
COMMIT;
SQL
}

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Bullhorn corporation_id resolution (v0.4 allowlisted key; LIVE)
# Canonical: SELECT config->>'bullhorn_corporation_id' FROM tenant_adapters
# WHERE adapter_name='bullhorn'. IFOS_FORCE_* fallback kept for fixtures.
# ────────────────────────────────────────────────────────────────────────

_corp="${IFOS_FORCE_BULLHORN_CORPORATION_ID:-}"
[[ -z "${_corp}" ]] && _corp="$(_ctx_adapter_key bullhorn bullhorn_corporation_id)"
export CTX_BULLHORN_CORPORATION_ID="${_corp:-unset}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Granola workspace_id resolution (v0.4 allowlisted key; LIVE)
# ────────────────────────────────────────────────────────────────────────

_ws="${IFOS_FORCE_GRANOLA_WORKSPACE_ID:-}"
[[ -z "${_ws}" ]] && _ws="$(_ctx_adapter_key granola granola_workspace_id)"
export CTX_GRANOLA_WORKSPACE_ID="${_ws:-unset}"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Granola plan_tier pre-cache
# Per @ifos/granola README §"Scribe consumption pattern": getAccountInfo()
# pre-cache (1h TTL) short-circuits the PAID_PLAN_TOOLS guard. Live call is
# blocked until the IFOS-side OAuth token exists on disk (honest-scope above),
# so v1.0 resolves: forced override → 'paid' default (founder 2026-06-03
# confirmed Business+). If first live getAccountInfo returns 'free', cycle.sh
# degrades to notes-only ingest (ESC_GRANOLA_PLAN_TIER is QUEUED for catalogue
# registration; until then the degradation is recorded on the audit row).
# ────────────────────────────────────────────────────────────────────────

export CTX_GRANOLA_PLAN_TIER="${IFOS_FORCE_GRANOLA_PLAN_TIER:-paid}"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Bullhorn OAuth refresh (via bin/bh-bridge.sh — the single
# reconciliation point for Janitor's @ifos/bullhorn CLI bridge)
# ESC_BULLHORN_AUTH firing is owned by cycle.sh Step 2 (which retries);
# context.sh only records the starting token state.
# ────────────────────────────────────────────────────────────────────────

_bh_state="unavailable"
_bh_rc=0
_bh_out="$(bash "${CTX_AGENT_DIR}/bin/bh-bridge.sh" refresh 2>/dev/null)" || _bh_rc=$?
case "${_bh_rc}" in
  0) _bh_state="$(printf '%s' "${_bh_out}" | jq -r '.token_state // "refreshed"' 2>/dev/null || echo refreshed)" ;;
  3) _bh_state="unavailable" ;;   # bridge not built yet / creds not provisioned
  *) _bh_state="failed" ;;
esac
export CTX_BULLHORN_TOKEN_STATE="${_bh_state}"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Granola token state (OAuth 2.1 + PKCE per @ifos/granola src/auth.ts)
# The connector reads ~/.ifos-local-vault/<tenant>/granola-tokens-<workspace>.json.
# No token file on disk → state 'no_token' (honest; live fetch paths then rely
# on fixture/seeded transcript sources only).
# ────────────────────────────────────────────────────────────────────────

_gr_token_file="${IFOS_LOCAL_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/granola-tokens-${CTX_GRANOLA_WORKSPACE_ID}.json"
if [[ -f "${_gr_token_file}" ]]; then
  export CTX_GRANOLA_TOKEN_STATE="fresh"
else
  export CTX_GRANOLA_TOKEN_STATE="no_token"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Voice corpus + tone rules (agent.md §7)
# voice_corpus: active row for tenant (empty → 'none' → Step 6 voice scoring
# records unscored/no_corpus, never a faked score).
# tone rules: hh_load_tone_rules('scribe') count via _shared/voice-loader.sh.
# ────────────────────────────────────────────────────────────────────────

_vc_id="${IFOS_FORCE_VOICE_CORPUS_ID:-}"
if [[ -z "${_vc_id}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _vc_id="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT id::text FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
COMMIT;
SQL
)"
fi
export CTX_VOICE_CORPUS_ID="${_vc_id:-none}"

_tr_count="0"
if [[ -f "${_SHARED_DIR}/voice-loader.sh" ]]; then
  # shellcheck source=/dev/null
  source "${_SHARED_DIR}/voice-loader.sh"
  if declare -f hh_load_tone_rules >/dev/null 2>&1; then
    _tr_json="$(hh_load_tone_rules "scribe" 2>/dev/null || echo '{"rules":[]}')"
    _tr_count="$(printf '%s' "${_tr_json}" | jq -r '.rules | length' 2>/dev/null || echo 0)"
  fi
fi
export CTX_TONE_RULES_COUNT="${_tr_count:-0}"

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Firm-domain whitelist (for validate.sh G-PII regex pass)
# 'firm_domains' is NOT a v0.4 tenant_adapters allowlist key (16-key trigger,
# verified 2026-06-10), so a canonical SELECT would be rejected at write time
# anyway. v1.0 keeps the env override + tenant-slug heuristic; promoting the
# key is a v0.5-supplement item (noted in build summary).
# ────────────────────────────────────────────────────────────────────────

export CTX_FIRM_DOMAIN_WHITELIST="${IFOS_FORCE_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Granola last_poll resolution (Scribe-internal cache file; NOT a
# tenant_adapters key). cleanup.sh writes it at session close.
# ────────────────────────────────────────────────────────────────────────

_lp_file="${HOME}/.ifos-cache/scribe/${CTX_TENANT_SLUG}/last-poll-${CTX_GRANOLA_WORKSPACE_ID}.txt"
_lp="${IFOS_FORCE_GRANOLA_LAST_POLL:-}"
if [[ -z "${_lp}" && -f "${_lp_file}" ]]; then
  _lp="$(head -1 "${_lp_file}" 2>/dev/null | tr -d '[:space:]')"
fi
if [[ -z "${_lp}" ]]; then
  # Default to 5-min-ago (cron cadence; safe overlap — listMeetings is
  # idempotent and Step 4 dedups by meeting_id).
  _lp="$(date -u -v-5M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u --date='5 minutes ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '1970-01-01T00:00:00Z')"
fi
export CTX_GRANOLA_LAST_POLL="${_lp}"

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
