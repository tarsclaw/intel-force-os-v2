#!/usr/bin/env bash
# Concierge agent — context.sh (pre-cycle hydration; W10-13 LIVE)
#
# Status: BUILT (W10-13 build slice). v0.4 schema supplement landed 2026-06-03
#         (commit a1bbcf6) — email_channel + operator_telegram_chat_id are
#         allowlisted, so Steps 1 + 5 now read the canonical
#         SELECT config->>'<key>' FROM tenant_adapters path, with the
#         IFOS_FORCE_* env-var fallback retained for fixtures + local dev
#         (the blocked_recipients precedent). Bullhorn OAuth refresh routes
#         through bin/bh-bridge.sh (the Janitor-branch connector shim) and
#         records token state HONESTLY (creds are EMPTY in the dev sandbox
#         as of 2026-06-10 → state=degraded, never a faked "refreshed").
#         Email-provider OAuth (MS Graph / Gmail) is absent → state=absent;
#         live send remains founder/tenant-onboarding-gated.
# Reading order: agent.md §2 (invocation surface) + §4 Step 0 (session start)
# + §7 (voice + tone constraints) first.
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
#   CTX_AGENT_DIR        — agent's directory (this file's dirname)
#   CTX_TENANT_SLUG      — tenant the run targets
#   CTX_CONCIERGE_MODE   — webhook | poll | nurture-sweep | manual
#
# Side effects (W10-13 build slice):
#   - Refresh Bullhorn OAuth (per agent.md §4 Step 0 + Q-12 disposition)
#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
#   - Load voice corpus pgvector index for CTX_VOICE_CORPUS_ID
#   - Load tone-rules YAML for tenant
#   - Resolve operator_telegram_chat_id from tenant_adapters.config
#   - Load tenant comms-template library path
#   - Hydrate addressee-resolution allowlists (firm-domain whitelist +
#     competitor list for Gate A G2/G4 enforcement)
#
# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
#   CTX_AGENT_NAME                       — "concierge"
#   CTX_EMAIL_CHANNEL                    — "microsoft-graph" | "gmail"
#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID
#   CTX_VOICE_CORPUS_ID                  — pgvector index ref
#   CTX_TONE_RULES_PATH                  — vault path to tone-rules YAML
#   CTX_COMMS_TEMPLATE_LIBRARY_PATH      — /vault/<slug>/concierge-templates/
#   CTX_BULLHORN_TOKEN_STATE             — fresh | refreshed | failed
#   CTX_EMAIL_PROVIDER_TOKEN_STATE       — fresh | refreshed | failed

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'concierge/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'concierge/context.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
export CTX_AGENT_NAME="concierge"

# 4-candidate _shared/ helper fallback (matches sibling agents post d7d52c5).
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
# Step 1 — Email channel resolution (MS Graph OR Gmail per tenant)
# Canonical: tenant_adapters.config.email_channel (v0.4-allowlisted key).
# IFOS_FORCE_EMAIL_CHANNEL overrides for fixtures + local dev.
# Default: microsoft-graph (most common in UK recruitment per CSM survey).
# ────────────────────────────────────────────────────────────────────────

# RLS-scoped single-key read of tenant_adapters.config (empty on any failure).
_ctx_ta_read() {
  local key="$1" out=""
  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    out="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
      --set=tenant="${CTX_TENANT_SLUG}" --set=k="${key}" <<'SQL' 2>/dev/null || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(config->>:'k', '') FROM tenant_adapters WHERE tenant_slug = :'tenant' LIMIT 1;
COMMIT;
SQL
)"
    out="$(printf '%s\n' "${out}" | grep -vE '^$' | head -1 || true)"
  fi
  printf '%s' "${out}"
}

_ctx_channel="${IFOS_FORCE_EMAIL_CHANNEL:-}"
[[ -z "${_ctx_channel}" ]] && _ctx_channel="$(_ctx_ta_read email_channel)"
export CTX_EMAIL_CHANNEL="${_ctx_channel:-microsoft-graph}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn OAuth refresh (via bin/bh-bridge.sh — Janitor-branch
# connector shim; see that file's header for the reconciliation contract)
# ────────────────────────────────────────────────────────────────────────

_bh_bridge="${CTX_AGENT_DIR}/bin/bh-bridge.sh"
[[ -f "${_bh_bridge}" ]] || _bh_bridge="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/bin/bh-bridge.sh"
CTX_BULLHORN_TOKEN_STATE="degraded"
if [[ -f "${_bh_bridge}" ]]; then
  _bh_refresh="$(bash "${_bh_bridge}" refresh 2>/dev/null || echo '{}')"
  if [[ "$(printf '%s' "${_bh_refresh}" | jq -r '.ok // false' 2>/dev/null)" == "true" ]]; then
    CTX_BULLHORN_TOKEN_STATE="refreshed"
  else
    # Honest degraded state: creds EMPTY in dev sandbox / connector CLI
    # unmerged. ESC_BULLHORN_AUTH fires only on a REAL refresh failure with
    # creds present (reason=refresh_failed), not on the known-absent case.
    _bh_reason="$(printf '%s' "${_bh_refresh}" | jq -r '.reason // "unknown"' 2>/dev/null || echo unknown)"
    if [[ "${_bh_reason}" == "refresh_failed" || "${_bh_reason}" == "revoked_401" ]]; then
      CTX_BULLHORN_TOKEN_STATE="failed"
    fi
  fi
fi
export CTX_BULLHORN_TOKEN_STATE

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Email provider OAuth refresh (per channel)
# HONEST: MS Graph / Gmail OAuth is ABSENT (per-tenant onboarding not done;
# connector packages not built). State=absent → cycle.sh Step 12 degrades to
# no-live-send. When the connectors land, this mirrors Step 2's shim call
# and fires ESC_MS_GRAPH_AUTH / ESC_GMAIL_AUTH (blocking) on refresh failure.
# ────────────────────────────────────────────────────────────────────────

export CTX_EMAIL_PROVIDER_TOKEN_STATE="${IFOS_FORCE_EMAIL_TOKEN_STATE:-absent}"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Voice corpus + tone rules + comms-template library
# ────────────────────────────────────────────────────────────────────────

export CTX_VOICE_CORPUS_ID="${IFOS_FORCE_VOICE_CORPUS_ID:-default}"
export CTX_TONE_RULES_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/tone-rules.yaml"
export CTX_COMMS_TEMPLATE_LIBRARY_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-templates/"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Operator routing (Telegram chat ID for autosend-bridge per D1-B)
# ────────────────────────────────────────────────────────────────────────

# Canonical read order (v0.4 supplement landed 2026-06-03, commit a1bbcf6):
#   1. IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID (fixtures + local dev)
#   2. Path B: tenant_adapters.config.operator_telegram_chat_id (v0.4 key)
#   3. Path A: tenant_adapters.config.approval_routing.default_recipient
# The autosend-bridge CLIs consume this CTX_* var as an argument (per package
# README §Dependency injection), NOT via their own tenant_adapters read.
_ctx_op_chat="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-}"
[[ -z "${_ctx_op_chat}" ]] && _ctx_op_chat="$(_ctx_ta_read operator_telegram_chat_id)"
if [[ -z "${_ctx_op_chat}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _ctx_op_chat="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(config->'approval_routing'->>'default_recipient', '')
FROM tenant_adapters WHERE tenant_slug = :'tenant' LIMIT 1;
COMMIT;
SQL
)"
fi
# Empty = unconfigured; cycle.sh Step 11 degrades to drafts-only when unset.
export CTX_OPERATOR_TELEGRAM_CHAT_ID="${_ctx_op_chat}"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Session-start trigger row (mandatory; anchors session in decision_log)
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" \
  "agent:concierge; tenant:${CTX_TENANT_SLUG}; mode:${CTX_CONCIERGE_MODE:-webhook}; email_channel:${CTX_EMAIL_CHANNEL}"

# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
printf '[concierge context.sh] tenant=%s channel=%s bullhorn_token=%s email_token=%s voice_corpus=%s\n' \
  "${CTX_TENANT_SLUG}" "${CTX_EMAIL_CHANNEL}" "${CTX_BULLHORN_TOKEN_STATE}" \
  "${CTX_EMAIL_PROVIDER_TOKEN_STATE}" "${CTX_VOICE_CORPUS_ID}"

exit 0
