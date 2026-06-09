#!/usr/bin/env bash
# Cash Conductor agent — context.sh (hydration; W4 Day-26 SKELETON)
#
# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
#         live package calls per agent.md §4 Step 0).
# Reading order: agent.md §4 Step 0 (hydration contract) first.
#
# Per master brief §8.1 Change 2: context.sh runs at cycle.sh Step 0 and exports
# the env vars cycle.sh needs to do its work. It MUST emit one
# hh_decision_trigger("session_start", ...) audit row before exit.
#
# Outputs (env vars exported for cycle.sh consumption):
#   CTX_ACCOUNTING_PROVIDER   xero | quickbooks | sage (per tenant config)
#   CTX_OPEN_BANKING_PROVIDER truelayer | plaid-uk (per tenant config)
#   CTX_VOICE_CORPUS_ID       tenant's voice corpus id (for chase-draft voice)
#   CTX_TONE_RULES_COUNT      number of tone_rule rows loaded
#   CTX_RECENT_EDITS_COUNT    recent_edit rows seen (drift signal)
#   CTX_OPEN_BANKING_TOKEN_STAGE  fresh|info|warn|blocking (per getTokenAgeStage)
#   CTX_LAST_CHASE_POSITION_MAP   JSON: { "<invoice_id>": <position> } from
#                                  cash_conductor_invoices.last_chase_position
#                                  (v0.3 schema-backed field per migrations §3)
#
# Failure modes (per agent.md §6):
#   - Missing tenant_slug                  → exit 1 with ESC_SCHEMA_VIOLATION
#   - Accounting auth unreachable          → exit 1 with ESC_ACCOUNTING_AUTH
#   - Open Banking auth unreachable        → exit 1 with ESC_OPEN_BANKING_AUTH
#   - Open Banking token in blocking stage → exit 1 with ESC_OPEN_BANKING_TOKEN_AGING
#   - Voice corpus empty for tenant        → warn-only; chase drafts fall back to
#                                            generic tone (logged as warning row)

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env vars + _shared/ helper resolution
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'cash-conductor/context.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'cash-conductor/context.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=cash-conductor}"

# Resolve _shared/ helpers (rendered location OR repo source-tree fallback —
# 4-candidate chain; matches diagnostic/context.sh + cash-conductor/cycle.sh
# pattern per smoke-hotfix commit d7d52c5).
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
  printf 'context.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT or render the agent first\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"
# shellcheck source=/dev/null
source "${_SHARED_DIR}/voice-loader.sh"

# Connector CLI base + provider creds (Path A: source secrets into env, never
# cat them). Used by the Open Banking token-age probe below + cycle.sh Step 1.
_CC_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
if [[ -z "${_CC_CONN_BASE}" || ! -d "${_CC_CONN_BASE}" ]]; then
  _CC_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
fi
_CC_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
if [[ -f "${_CC_SECRETS}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${_CC_SECRETS}"
  set +a
fi

# ────────────────────────────────────────────────────────────────────────
# Hydrate tenant config (accounting provider + Open Banking provider)
# Reference: agent.md §2 invocation surface — per-tenant via
# tenant_adapters.config; defaults to xero + truelayer per Cash Conductor §9 Q1+Q2.
# ────────────────────────────────────────────────────────────────────────

# TODO(W7-8): SELECT config->>'accounting_provider', config->>'open_banking_provider'
# FROM tenant_adapters WHERE tenant_slug = $CTX_TENANT_SLUG; honour defaults.
# v0.3 supplement §4 tenant_adapters_config_additions includes neither key yet;
# v0.4 supplement-pending will add them. Until then, defaults below stand.
: "${CTX_ACCOUNTING_PROVIDER:=xero}"
: "${CTX_OPEN_BANKING_PROVIDER:=truelayer}"
export CTX_ACCOUNTING_PROVIDER CTX_OPEN_BANKING_PROVIDER

# ────────────────────────────────────────────────────────────────────────
# Voice corpus + tone rules + recent edits (for §4 Step 8 chase-draft generation)
# Reference: agent.md §7 + voice-loader.sh signatures.
# ────────────────────────────────────────────────────────────────────────

# TODO(W7-8): replace skeleton stubs with real voice-loader calls. Skeleton
# preserves the env-var shape cycle.sh + validate.sh expect.

# Tone rules — voice-loader.sh hh_load_tone_rules signature: filter applies_to_agents
# containing 'cash_conductor'. Stub returns empty.
CTX_TONE_RULES_COUNT="${CTX_TONE_RULES_COUNT:-0}"
export CTX_TONE_RULES_COUNT
# TODO(W7-8): CTX_TONE_RULES=$(hh_load_tone_rules "cash_conductor" 2>/dev/null || echo "[]")
# TODO(W7-8): CTX_TONE_RULES_COUNT=$(echo "${CTX_TONE_RULES}" | jq 'length')

# Voice corpus — hh_load_voice_samples returns top-5 ANN matches for the task
# context "professional polite chase email" per agent.md §7.
CTX_VOICE_CORPUS_ID="${CTX_VOICE_CORPUS_ID:-}"
export CTX_VOICE_CORPUS_ID
# TODO(W7-8): CTX_VOICE_CORPUS_ID=$(hh_load_voice_samples "${CTX_TENANT_SLUG}" "chase-email" 2>/dev/null)

# Recent edits — Cash Conductor has recent_edit W-only per v0.3 supplement
# §2a line 729 (per cash-conductor agent.md §7 NOTE); does NOT call
# hh_load_recent_edits (canary cron reads instead).
CTX_RECENT_EDITS_COUNT="0"
export CTX_RECENT_EDITS_COUNT

# ────────────────────────────────────────────────────────────────────────
# Open Banking token-age probe (Step 1 readiness check)
# Reference: agent.md §6 ESC_OPEN_BANKING_TOKEN_AGING staged severity.
# ────────────────────────────────────────────────────────────────────────

# W7 LIVE: probe PSD2 token-age stage via the @ifos/open-banking CLI bin
# (node dist/cli.js token-stage → {stage, days_until_consent_expiry}).
CTX_OPEN_BANKING_TOKEN_STAGE="${CTX_OPEN_BANKING_TOKEN_STAGE:-unknown}"
_OB_CLI="${_CC_CONN_BASE}/open-banking/dist/cli.js"
if [[ -f "${_OB_CLI}" ]]; then
  CTX_OPEN_BANKING_TOKEN_STAGE="$(node "${_OB_CLI}" token-stage 2>/dev/null \
    | jq -r '.stage // "unknown"' 2>/dev/null || echo unknown)"
fi
export CTX_OPEN_BANKING_TOKEN_STAGE
# Blocking stage (≤7d to PSD2 consent expiry): operator must re-authorise
# before any bank read; emit ESC + exit 1 per agent.md §6 staged severity.
if [[ "${CTX_OPEN_BANKING_TOKEN_STAGE}" == "blocking" ]]; then
  autosend_escalate "ESC_OPEN_BANKING_TOKEN_AGING" "agent=cash-conductor" \
    "tenant=${CTX_TENANT_SLUG}" "stage=blocking"
  printf '[cash-conductor context.sh] OB token in blocking stage — re-consent required\n' >&2
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# Last chase position state (per-invoice; from cash_conductor_invoices)
# Reference: agent.md §4 Step 7 — read last_chase_position for chase routing.
# ────────────────────────────────────────────────────────────────────────

CTX_LAST_CHASE_POSITION_MAP="${CTX_LAST_CHASE_POSITION_MAP:-{}}"
export CTX_LAST_CHASE_POSITION_MAP
# TODO(W7-8): query Postgres via the daemon
#   SELECT jsonb_object_agg(invoice_id, last_chase_position)
#   FROM cash_conductor_invoices WHERE tenant_slug = $CTX_TENANT_SLUG AND last_chase_position > 0;
# Wrap in SET LOCAL app.current_tenant = $CTX_TENANT_SLUG (RLS isolation).

# ────────────────────────────────────────────────────────────────────────
# Emit session_start audit row (per master brief §8.1 Change 2 — mandatory first row)
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" \
  "cash-conductor tenant=${CTX_TENANT_SLUG} accounting=${CTX_ACCOUNTING_PROVIDER} open_banking=${CTX_OPEN_BANKING_PROVIDER} token_stage=${CTX_OPEN_BANKING_TOKEN_STAGE} voice_corpus=${CTX_VOICE_CORPUS_ID:-<empty>} tone_rules=${CTX_TONE_RULES_COUNT}"

# Operator-readable trace line (parallel to diagnostic/context.sh logging)
printf '[cash-conductor context.sh] tenant=%s accounting=%s open_banking=%s token_stage=%s voice_corpus=%s tone_rules=%s\n' \
  "${CTX_TENANT_SLUG}" "${CTX_ACCOUNTING_PROVIDER}" "${CTX_OPEN_BANKING_PROVIDER}" \
  "${CTX_OPEN_BANKING_TOKEN_STAGE}" "${CTX_VOICE_CORPUS_ID:-<empty>}" "${CTX_TONE_RULES_COUNT}"

exit 0
