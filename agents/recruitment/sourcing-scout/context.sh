#!/usr/bin/env bash
# Sourcing Scout agent — context.sh (pre-cycle hydration; W9 build slice LIVE)
#
# Status: LIVE per spec-003 (W9 build slice). v0.4 schema supplement LANDED
#         2026-06-03 (commit a1bbcf6 + LIVE on VPS) — bullhorn_corporation_id
#         is top-level allowlisted. v0.3 supplement (LIVE on VPS) allowlists
#         blocked_recipients; operator_telegram_chat_id is the v0.4 addition.
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
#   - Per-source auth-state resolution (Bullhorn READ-ONLY + Reed + CV-Library;
#     LinkedIn excluded per the v1.0 Proxycurl-shutdown caveat). Reed +
#     CV-Library use long-lived keys (no refresh op); "refresh" = key presence
#     + CLI check-auth where the connector CLI is built. Bullhorn OAuth refresh
#     needs the @ifos/bullhorn CLI surface which does not exist yet — with
#     creds EMPTY today the honest state is 'absent' → cycle.sh Step 2 degraded
#     skip (spec-003 §8; never faked).
#   - Resolve bullhorn_corporation_id via canonical tenant_adapters SELECT
#     (v0.4-allowlisted) with IFOS_FORCE_* fixture fallback.
#   - Load tenant DNC list from tenant_adapters.config.blocked_recipients
#     (v0.3-allowlisted; array<string>) → CTX_DNC_BLOCKED_RECIPIENTS.
#   - Load voice corpus state + tone-rule count for Step 9 rationale honesty
#     (empty corpus → unscored/no_corpus per spec-003 §8).
#   - Load firm-domain whitelist (validate.sh G6 PII regex pass).
#
# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
#   CTX_AGENT_NAME                — "sourcing-scout"
#   CTX_BULLHORN_CORPORATION_ID   — per-tenant Bullhorn corp identifier
#   CTX_BULLHORN_TOKEN_STATE      — ok | configured_no_refresh_surface | absent
#   CTX_REED_TOKEN_STATE          — ok | configured_no_cli | absent
#   CTX_CVLIBRARY_TOKEN_STATE     — ok | configured_no_cli | failed | absent
#   CTX_VOICE_CORPUS_ID           — active voice_corpus row id (or "none")
#   CTX_VOICE_CORPUS_STATE        — active | absent
#   CTX_TONE_RULES_COUNT          — number of tone_rule rows loaded
#   CTX_FIRM_DOMAIN_WHITELIST     — comma-separated tenant firm domains (G6 PII)
#   CTX_DNC_BLOCKED_RECIPIENTS    — JSON array string of DNC identifiers
#   CTX_OPERATOR_TELEGRAM_CHAT_ID — Step 11 notification recipient
#   CTX_SOURCES_ACTIVE_COUNT      — declared v1.0 source count (=3; Bullhorn +
#                                   Reed + CV-Library; LinkedIn excluded)

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
# shellcheck source=/dev/null
source "${_SHARED_DIR}/voice-loader.sh" 2>/dev/null || true

# Connector base + secrets (Path A: values sourced into env, never printed).
_SS_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
if [[ -z "${_SS_CONN_BASE}" || ! -d "${_SS_CONN_BASE}" ]]; then
  _SS_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
fi
_SS_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
if [[ -f "${_SS_SECRETS}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${_SS_SECRETS}"
  set +a
fi

# Canonical tenant_adapters config read (RLS-scoped; first row carrying the key).
# Empty string when DB unreachable OR no row carries the key.
_ss_tenant_config() {
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
# Step 1 — Bullhorn corporation_id resolution (v0.4-allowlisted canonical path)
# IFOS_FORCE_BULLHORN_CORPORATION_ID retained for fixture + local-dev use.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_FORCE_BULLHORN_CORPORATION_ID:-}" ]]; then
  CTX_BULLHORN_CORPORATION_ID="${IFOS_FORCE_BULLHORN_CORPORATION_ID}"
else
  CTX_BULLHORN_CORPORATION_ID="$(_ss_tenant_config bullhorn_corporation_id)"
fi
export CTX_BULLHORN_CORPORATION_ID="${CTX_BULLHORN_CORPORATION_ID:-unset}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn auth state (read-only; per agent.md §1 + §6)
# Honest state model (spec-003 §8): creds EMPTY today → 'absent' → cycle.sh
# degraded-skip + ESC_BULLHORN_AUTH. When creds land, the @ifos/bullhorn CLI
# refresh surface is the follow-up — until it exists, creds-present reports
# 'configured_no_refresh_surface' (still live-queryable once the CLI lands).
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" ]]; then
  if [[ -f "${_SS_CONN_BASE}/bullhorn/dist/cli.js" ]]; then
    if node "${_SS_CONN_BASE}/bullhorn/dist/cli.js" refresh 2>/dev/null \
         | jq -e '.ok == true' >/dev/null 2>&1; then
      CTX_BULLHORN_TOKEN_STATE="ok"
    else
      CTX_BULLHORN_TOKEN_STATE="failed"
    fi
  else
    CTX_BULLHORN_TOKEN_STATE="configured_no_refresh_surface"
  fi
else
  CTX_BULLHORN_TOKEN_STATE="absent"
fi
export CTX_BULLHORN_TOKEN_STATE

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Reed auth state (long-lived API key; no refresh op)
# Creds EMPTY today (spec-003 §8) → 'absent' → degraded-skip + ESC_REED_AUTH.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${REED_API_KEY:-}" ]]; then
  if [[ -f "${_SS_CONN_BASE}/reed/dist/cli.js" ]]; then
    CTX_REED_TOKEN_STATE="ok"
  else
    CTX_REED_TOKEN_STATE="configured_no_cli"
  fi
else
  CTX_REED_TOKEN_STATE="absent"
fi
export CTX_REED_TOKEN_STATE

# ────────────────────────────────────────────────────────────────────────
# Step 4 — CV-Library auth state (long-lived key; check-auth is network-free)
# Creds SET today (spec-003 §8 — the live source). check-auth via the
# @ifos/cv-library CLI when built; live API calls are the orchestrator's
# post-build smoke, never made here.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${CVLIBRARY_API_KEY:-}" || -n "${CVLIBRARY_ACCESS_TOKEN:-}" ]]; then
  if [[ -f "${_SS_CONN_BASE}/cv-library/dist/cli.js" ]]; then
    if node "${_SS_CONN_BASE}/cv-library/dist/cli.js" check-auth 2>/dev/null \
         | jq -e '.ok == true' >/dev/null 2>&1; then
      CTX_CVLIBRARY_TOKEN_STATE="ok"
    else
      CTX_CVLIBRARY_TOKEN_STATE="failed"
    fi
  else
    CTX_CVLIBRARY_TOKEN_STATE="configured_no_cli"
  fi
else
  CTX_CVLIBRARY_TOKEN_STATE="absent"
fi
export CTX_CVLIBRARY_TOKEN_STATE

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Voice corpus + tone rules (for Step 9 per-candidate rationale)
# Empty voice_corpus → CTX_VOICE_CORPUS_STATE=absent → Step 9 records
# unscored/no_corpus (never a faked score; spec-003 §8).
# ────────────────────────────────────────────────────────────────────────

CTX_VOICE_CORPUS_ID="none"
CTX_VOICE_CORPUS_STATE="absent"
if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _ss_vc="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT id FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
COMMIT;
SQL
)"
  if [[ -n "${_ss_vc}" ]]; then
    CTX_VOICE_CORPUS_ID="${_ss_vc}"
    CTX_VOICE_CORPUS_STATE="active"
  fi
fi
export CTX_VOICE_CORPUS_ID CTX_VOICE_CORPUS_STATE

CTX_TONE_RULES_COUNT=0
if command -v jq >/dev/null 2>&1 && declare -F hh_load_tone_rules >/dev/null 2>&1; then
  CTX_TONE_RULES_COUNT="$(hh_load_tone_rules "sourcing_scout" 2>/dev/null \
    | jq -r '.rules | length' 2>/dev/null || echo 0)"
  [[ "${CTX_TONE_RULES_COUNT}" =~ ^[0-9]+$ ]] || CTX_TONE_RULES_COUNT=0
fi
export CTX_TONE_RULES_COUNT

# ────────────────────────────────────────────────────────────────────────
# Step 6 — DNC list load (tenant_adapters.config.blocked_recipients;
# v0.3-allowlisted; array<string>). Loaded once; reused at Step 8 (cycle.sh
# filter) + G5 (validate.sh defence-in-depth).
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_FORCE_DNC_BLOCKED_RECIPIENTS:-}" ]]; then
  CTX_DNC_BLOCKED_RECIPIENTS="${IFOS_FORCE_DNC_BLOCKED_RECIPIENTS}"
else
  CTX_DNC_BLOCKED_RECIPIENTS="$(_ss_tenant_config blocked_recipients)"
fi
# Guarantee valid JSON array downstream.
if ! printf '%s' "${CTX_DNC_BLOCKED_RECIPIENTS:-}" | jq -e 'type == "array"' >/dev/null 2>&1; then
  CTX_DNC_BLOCKED_RECIPIENTS="[]"
fi
export CTX_DNC_BLOCKED_RECIPIENTS

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Firm-domain whitelist (validate.sh G6 PII regex pass)
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_FORCE_FIRM_DOMAIN_WHITELIST:-}" ]]; then
  CTX_FIRM_DOMAIN_WHITELIST="${IFOS_FORCE_FIRM_DOMAIN_WHITELIST}"
else
  CTX_FIRM_DOMAIN_WHITELIST="$(_ss_tenant_config firm_domains)"
fi
export CTX_FIRM_DOMAIN_WHITELIST="${CTX_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Operator routing (Telegram chat ID for Step 11 notification;
# v0.4-allowlisted operator_telegram_chat_id).
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-}" ]]; then
  CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID}"
else
  CTX_OPERATOR_TELEGRAM_CHAT_ID="$(_ss_tenant_config operator_telegram_chat_id)"
fi
export CTX_OPERATOR_TELEGRAM_CHAT_ID="${CTX_OPERATOR_TELEGRAM_CHAT_ID:-unset}"

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Active source count (v1.0 = 3 per Proxycurl shutdown caveat)
# ────────────────────────────────────────────────────────────────────────

export CTX_SOURCES_ACTIVE_COUNT="3"   # Bullhorn passive + Reed + CV-Library
                                       # (LinkedIn excluded per agent.md v1.0 caveat)

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Session-start trigger row (mandatory; anchors session in decision_log)
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" \
  "agent:sourcing-scout; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; sources_active:${CTX_SOURCES_ACTIVE_COUNT}; voice_corpus:${CTX_VOICE_CORPUS_STATE}"

# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
printf '[sourcing-scout context.sh] tenant=%s corp=%s sources_active=%s bullhorn_token=%s reed=%s cvlibrary=%s voice_corpus=%s tone_rules=%s firm_domains=%s dnc_entries=%s\n' \
  "${CTX_TENANT_SLUG}" "${CTX_BULLHORN_CORPORATION_ID}" "${CTX_SOURCES_ACTIVE_COUNT}" \
  "${CTX_BULLHORN_TOKEN_STATE}" "${CTX_REED_TOKEN_STATE}" "${CTX_CVLIBRARY_TOKEN_STATE}" \
  "${CTX_VOICE_CORPUS_STATE}" "${CTX_TONE_RULES_COUNT}" "${CTX_FIRM_DOMAIN_WHITELIST}" \
  "$(printf '%s' "${CTX_DNC_BLOCKED_RECIPIENTS}" | jq 'length' 2>/dev/null || echo 0)"

exit 0
