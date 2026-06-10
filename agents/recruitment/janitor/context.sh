#!/usr/bin/env bash
# Janitor agent — context.sh (pre-cycle hydration; W6-7 LIVE)
#
# Status: LIVE per spec-001 §4 Step 0 (W6-7 build slice).
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
# Side effects:
#   - Canonical tenant_adapters.config reads (RLS SET LOCAL app.current_tenant)
#     for janitor_dedup_threshold (v0.3-allowlisted), bullhorn_corporation_id +
#     operator_telegram_chat_id (v0.4-allowlisted; LIVE on VPS per commit a1bbcf6)
#   - Bullhorn auth state probe via @ifos/bullhorn dist/cli.js (check-auth is
#     network-free; refresh only attempted when creds + token bundle present —
#     Bullhorn creds are founder-gated today per spec-001 §8, so the honest
#     state is 'absent' and cycle.sh runs in degraded mode against the
#     Postgres entities cache)
#   - Voice corpus presence + tone-rule count (for Step 8 tacit-note narrative
#     per agent.md §7); empty corpus → Step 8 records unscored/no_corpus
#   - recent_edit 30d lookback count (Step 8 harvest input; v0.3 supplement
#     §2a grants Janitor R access)
#
# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
#   CTX_AGENT_NAME                       — "janitor"
#   CTX_BULLHORN_CORPORATION_ID          — per-tenant Bullhorn corp identifier
#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID (Step 11)
#   CTX_BULLHORN_TOKEN_STATE             — ok | failed | configured_no_tokens | absent | fixture
#   CTX_VOICE_CORPUS_ID                  — voice_corpus row id (Step 8) or "none"
#   CTX_VOICE_CORPUS_STATE               — active | absent
#   CTX_TONE_RULES_COUNT                 — number of tone_rule rows loaded
#   CTX_JANITOR_DEDUP_THRESHOLD          — default 0.85; per-tenant override [0.75, 0.95]
#   CTX_RECENT_EDITS_WINDOW_DAYS         — 30 (Step 8 lookback window per agent.md §4)
#   CTX_RECENT_EDITS_COUNT               — approved_after_edit rows in the window
#   CTX_FIRM_DOMAIN_WHITELIST            — firm-boundary domain for validate.sh G6

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
# shellcheck source=/dev/null
source "${_SHARED_DIR}/voice-loader.sh" 2>/dev/null || true

# Connector base + secrets (Path A: values sourced into env, never printed —
# mirrors cash-conductor/context.sh).
_JN_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
if [[ -z "${_JN_CONN_BASE}" || ! -d "${_JN_CONN_BASE}" ]]; then
  _JN_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
fi
_JN_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
if [[ -f "${_JN_SECRETS}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${_JN_SECRETS}"
  set +a
fi

# Canonical tenant_adapters config read (RLS-scoped; first row carrying the key).
# Empty string when DB unreachable OR no row carries the key.
_jn_tenant_config() {
  local key="$1"
  if [[ -z "${IFOS_DB_URL:-}" ]] || ! command -v psql >/dev/null 2>&1; then
    return 0
  fi
  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" --set=key="${key}" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT config->>:'key' FROM tenant_adapters
WHERE tenant_slug = :'tenant' AND config ? :'key'
ORDER BY id LIMIT 1;
COMMIT;
SQL
}

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Dedup confidence threshold (per-tenant override; default 0.85)
# Reference: ULTRAPLAN A2 line 510 verbatim. v0.3 supplement §4
# tenant_adapters_config_additions.janitor_dedup_threshold; validator allowed
# range [0.75, 0.95] per migrations/v0.2-to-v0.3.sql §5 (trigger LIVE).
# IFOS_FORCE_JANITOR_DEDUP_THRESHOLD retained for fixture + local-dev use.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_FORCE_JANITOR_DEDUP_THRESHOLD:-}" ]]; then
  CTX_JANITOR_DEDUP_THRESHOLD="${IFOS_FORCE_JANITOR_DEDUP_THRESHOLD}"
else
  CTX_JANITOR_DEDUP_THRESHOLD="$(_jn_tenant_config janitor_dedup_threshold)"
fi
export CTX_JANITOR_DEDUP_THRESHOLD="${CTX_JANITOR_DEDUP_THRESHOLD:-0.85}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn corporation_id resolution (v0.4-allowlisted canonical path;
# LIVE on VPS per commit a1bbcf6). IFOS_FORCE_BULLHORN_CORPORATION_ID retained
# for fixture + local-dev use per established pattern.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_FORCE_BULLHORN_CORPORATION_ID:-}" ]]; then
  CTX_BULLHORN_CORPORATION_ID="${IFOS_FORCE_BULLHORN_CORPORATION_ID}"
else
  CTX_BULLHORN_CORPORATION_ID="$(_jn_tenant_config bullhorn_corporation_id)"
fi
export CTX_BULLHORN_CORPORATION_ID="${CTX_BULLHORN_CORPORATION_ID:-unset}"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Bullhorn auth state (two-step Step A + Step B per @ifos/bullhorn
# src/auth.ts; surfaced via dist/cli.js). Honest state model (spec-001 §8):
# creds EMPTY today (founder-gated) → 'absent' → cycle.sh degraded mode
# (scan from the Postgres entities cache; writes deferred). When creds land:
# creds + token bundle → live refresh here; refresh failure → cycle.sh Step 1
# retries then ESC_BULLHORN_AUTH (blocking).
# IFOS_JANITOR_FIXTURE_BULLHORN_AUTH=ok|failed forces the state for fixtures.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_JANITOR_FIXTURE_BULLHORN_AUTH:-}" ]]; then
  case "${IFOS_JANITOR_FIXTURE_BULLHORN_AUTH}" in
    ok)     CTX_BULLHORN_TOKEN_STATE="fixture" ;;
    failed) CTX_BULLHORN_TOKEN_STATE="failed" ;;
    *)      CTX_BULLHORN_TOKEN_STATE="absent" ;;
  esac
elif [[ -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" ]]; then
  _jn_bh_cli="${_JN_CONN_BASE}/bullhorn/dist/cli.js"
  if [[ -f "${_jn_bh_cli}" ]]; then
    if node "${_jn_bh_cli}" check-auth 2>/dev/null | jq -e '.tokens_present == true' >/dev/null 2>&1; then
      if node "${_jn_bh_cli}" refresh 2>/dev/null | jq -e '.ok == true' >/dev/null 2>&1; then
        CTX_BULLHORN_TOKEN_STATE="ok"
      else
        CTX_BULLHORN_TOKEN_STATE="failed"
      fi
    else
      CTX_BULLHORN_TOKEN_STATE="configured_no_tokens"   # consent flow not yet run
    fi
  else
    CTX_BULLHORN_TOKEN_STATE="configured_no_tokens"     # CLI not built
  fi
else
  CTX_BULLHORN_TOKEN_STATE="absent"
fi
export CTX_BULLHORN_TOKEN_STATE

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Voice corpus + tone rules (for Step 8 tacit-note narrative)
# Reference: agent.md §7. hh_load_tone_rules filtered by applies_to_agents
# containing 'janitor'. Empty voice_corpus → CTX_VOICE_CORPUS_STATE=absent →
# Step 8 records unscored/no_corpus (never a faked score; CC precedent).
# ────────────────────────────────────────────────────────────────────────

CTX_VOICE_CORPUS_ID="none"
CTX_VOICE_CORPUS_STATE="absent"
if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _jn_vc="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT id FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
COMMIT;
SQL
)"
  if [[ -n "${_jn_vc}" ]]; then
    CTX_VOICE_CORPUS_ID="${_jn_vc}"
    CTX_VOICE_CORPUS_STATE="active"
  fi
fi
export CTX_VOICE_CORPUS_ID CTX_VOICE_CORPUS_STATE

CTX_TONE_RULES_COUNT=0
if command -v jq >/dev/null 2>&1 && declare -F hh_load_tone_rules >/dev/null 2>&1; then
  CTX_TONE_RULES_COUNT="$(hh_load_tone_rules "janitor" 2>/dev/null \
    | jq -r '.rules | length' 2>/dev/null || echo 0)"
  [[ "${CTX_TONE_RULES_COUNT}" =~ ^[0-9]+$ ]] || CTX_TONE_RULES_COUNT=0
fi
export CTX_TONE_RULES_COUNT

# Recent edits lookback window (Step 8 tacit-note harvest) — fixed at 30 days
# per agent.md §4 Step 8 (30-day rolling window). Count loaded here as the
# drift/coverage signal; the full rows are read by cycle.sh Step 8 under RLS.
export CTX_RECENT_EDITS_WINDOW_DAYS="30"
CTX_RECENT_EDITS_COUNT=0
if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _jn_re="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT count(*) FROM recent_edit
WHERE tenant_slug = :'tenant' AND resolution = 'approved_after_edit'
  AND resolved_at > now() - interval '30 days';
COMMIT;
SQL
)"
  [[ "${_jn_re}" =~ ^[0-9]+$ ]] && CTX_RECENT_EDITS_COUNT="${_jn_re}"
fi
export CTX_RECENT_EDITS_COUNT

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Operator routing (Telegram chat ID for Step 11 + the
# ESC_DUPLICATE_DETECTED approval gate). v0.4-allowlisted canonical path;
# IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID retained per Concierge precedent.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-}" ]]; then
  CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID}"
else
  CTX_OPERATOR_TELEGRAM_CHAT_ID="$(_jn_tenant_config operator_telegram_chat_id)"
fi
export CTX_OPERATOR_TELEGRAM_CHAT_ID="${CTX_OPERATOR_TELEGRAM_CHAT_ID:-unset}"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Firm-domain whitelist (validate.sh G6 PII firm-boundary regex).
# Not a tenant_adapters allowlisted key at v0.4 — env-driven with a
# conservative default (Scout precedent): unset → <tenant>.test, meaning any
# real-world email in a narrative fails G6 until the tenant's firm domain is
# configured. Conservative-by-default per agent.md §9 gotcha 2.
# ────────────────────────────────────────────────────────────────────────

export CTX_FIRM_DOMAIN_WHITELIST="${IFOS_FORCE_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Session-start trigger row (mandatory; anchors session in decision_log)
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" \
  "agent:janitor; tenant:${CTX_TENANT_SLUG}; corporation_id:${CTX_BULLHORN_CORPORATION_ID}; dedup_threshold:${CTX_JANITOR_DEDUP_THRESHOLD}; bullhorn_token:${CTX_BULLHORN_TOKEN_STATE}; voice_corpus:${CTX_VOICE_CORPUS_STATE}; recent_edits_30d:${CTX_RECENT_EDITS_COUNT}"

# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
printf '[janitor context.sh] tenant=%s corp=%s dedup_threshold=%s bullhorn_token=%s voice_corpus=%s tone_rules=%s recent_edits_30d=%s\n' \
  "${CTX_TENANT_SLUG}" "${CTX_BULLHORN_CORPORATION_ID}" "${CTX_JANITOR_DEDUP_THRESHOLD}" \
  "${CTX_BULLHORN_TOKEN_STATE}" "${CTX_VOICE_CORPUS_STATE}" "${CTX_TONE_RULES_COUNT}" \
  "${CTX_RECENT_EDITS_COUNT}"

exit 0
