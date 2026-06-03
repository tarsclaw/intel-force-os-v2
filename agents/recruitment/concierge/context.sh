#!/usr/bin/env bash
# Concierge agent — context.sh (pre-cycle hydration; W4 Day-26 SKELETON)
#
# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs
#         with real provider config + tenant_adapters reads. v0.4 schema
#         supplement LANDED 2026-06-03 (commit a1bbcf6) — email_channel +
#         operator_telegram_chat_id now allowlisted; W10-13 implementation
#         flips Step 1 + Step 5 from IFOS_FORCE_* env-var fallback to the
#         canonical SELECT config->>'<key>' FROM tenant_adapters path.
#         Today's SKELETON still reads via env-var fallback (no consumer
#         wiring change at v0.4 landing — that's W10-13 scope per D1-B
#         decision-doc §Implementation surface item 5). No schema violation
#         at runtime today; reads remain env-var-sourced).
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
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): swap to canonical tenant_adapters SELECT path now that v0.4
# supplement has LANDED 2026-06-03 (commit a1bbcf6) — `email_channel` is
# allowlisted in validate_tenant_adapters_config_v0_4 (enum: microsoft-graph
# | gmail). THEN: SELECT config->>'email_channel' FROM tenant_adapters
# WHERE tenant_slug=$1. Today's SKELETON still uses the IFOS_FORCE_*
# env-var fallback; the W10-13 implementation wires the postgres read
# alongside connection-pool setup + IFOS_FORCE_* retained for fixture +
# local-dev use (per pattern established for blocked_recipients reads).
# Default: microsoft-graph (most common in UK recruitment per CSM survey).
export CTX_EMAIL_CHANNEL="${IFOS_FORCE_EMAIL_CHANNEL:-microsoft-graph}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn OAuth refresh
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): @ifos/bullhorn refreshTokens(); on success export CTX_BULLHORN_TOKEN_STATE=refreshed
# On 6+ consecutive failures: emit ESC_BULLHORN_AUTH (blocking) + exit 1
export CTX_BULLHORN_TOKEN_STATE="STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Email provider OAuth refresh (per channel)
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13):
#   if [[ "${CTX_EMAIL_CHANNEL}" == "microsoft-graph" ]]; then
#     @ifos/microsoft-graph refreshTokens() → on fail ESC_MS_GRAPH_AUTH blocking
#   else
#     @ifos/gmail refreshTokens() → on fail ESC_GMAIL_AUTH blocking
#   fi
export CTX_EMAIL_PROVIDER_TOKEN_STATE="STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Voice corpus + tone rules + comms-template library
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): resolve via tenant_adapters.config; default fallback chain.
export CTX_VOICE_CORPUS_ID="${IFOS_FORCE_VOICE_CORPUS_ID:-default}"
export CTX_TONE_RULES_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/tone-rules.yaml"
export CTX_COMMS_TEMPLATE_LIBRARY_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-templates/"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Operator routing (Telegram chat ID for autosend-bridge per D1-B)
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): swap to canonical tenant_adapters SELECT path now that v0.4
# supplement has LANDED 2026-06-03 (commit a1bbcf6) — `operator_telegram_chat_id`
# is allowlisted in validate_tenant_adapters_config_v0_4 (pattern: '^-?[0-9]+$'
# matching Telegram chat ID format). D1-B both paths are now schema-clean:
# Path A reuses approval_routing.default_recipient (no schema change ever
# needed; recommended for new tenants); Path B uses this top-level key
# (v0.4 added; cleaner single-key override for the wizard). THEN:
# SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
# WHERE tenant_slug=$1 (Path B) OR
# SELECT config->'approval_routing'->>'default_recipient' (Path A).
# Today's SKELETON still uses the IFOS_FORCE_* env-var fallback; the
# W10-13 implementation wires the postgres read. The autosend-bridge
# package consumes this CTX_* var as a function argument (per package
# README §Dependency injection), NOT via tenant_adapters read.
export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"

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
