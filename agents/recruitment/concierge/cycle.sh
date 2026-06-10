#!/usr/bin/env bash
# Concierge agent — cycle.sh (15-step orchestration; W10-13 LIVE)
#
# Status: BUILT (W10-13 build slice; spec-004 §4 — every step, marker, ESC route).
# Reading order: agent.md §1 (output contract) + §3 (12 lifecycle events) +
#         §4 (this workflow's 15 steps) + §5 (Gate A) + §6 (ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# Invocation modes (per agent.md §2):
#   mode=webhook         — Bullhorn lifecycle webhook event-driven (v1.0 primary)
#   mode=poll            — Bullhorn state-changed-at polling fallback
#   mode=nurture-sweep   — cron: 7d/30d/90d post-start nurture cadence
#   mode=manual          — ifosctl concierge process-event|nurture-sweep
#
# v1.0 throughput note: ONE lifecycle event per run. webhook mode is per-event
# by nature; poll/nurture take the FIRST pending event and report queue depth —
# the 5-min poll cadence drains the rest (documented v1.0 scope).
#
# Bullhorn boundary: ALL Bullhorn calls route through bin/bh-bridge.sh — the
# Janitor branch owns packages/mcp-connectors/bullhorn this cycle; the shim
# documents the exact connector CLI surface and is the single reconciliation
# point at review. Fixture mode serves the seeded `entities` cache rows.
#
# Autosend bridge (HEADLINE — D1-B): @ifos/autosend-bridge-telegram production
# wiring (real Telegram Bot API transport + postgres approvals reader +
# dist/bin/{propose,await,record-decision}.js) landed in THIS build slice.
# Step 11 routes orange approvals through it when the dist + operator chat +
# bot token (or IFOS_BRIDGE_FAKE fixture mode) are available; otherwise
# drafts-only graceful degradation (D1-C).
#
# Honest-scope (spec-004 §8, verified 2026-06-10): Bullhorn creds EMPTY →
# Steps 3/13/14 run fixture-mode against entities; MS Graph / Gmail OAuth
# ABSENT → Step 12 live transport gated (IFOS_FORCE_SEND_RESULT proves the
# chain in fixtures); TELEGRAM_BOT_TOKEN EMPTY → live Telegram unexercised.

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: CTX env + _shared/ helper resolution
# (Mirrors the 4-candidate fallback chain established in d7d52c5 smoke-hotfix.)
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'concierge/cycle.sh: CTX_AGENT_DIR unset (context.sh must run first)\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'concierge/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=concierge}"
export CTX_AGENT_NAME CTX_AGENT_DIR CTX_TENANT_SLUG   # inherited by validate.sh subprocess (Step 8)

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
  printf 'concierge/cycle.sh: cannot locate _shared/ helpers\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# Secrets into env for the bridge CLIs + LLM renderer (CC Step 1 idiom; the
# file is sourced, never cat'd; values never echoed).
_CG_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
if [[ -f "${_CG_SECRETS}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${_CG_SECRETS}"
  set +a
fi

# Helper bins (agent-dir first, repo fallback — CC pattern).
_BH_BRIDGE="${CTX_AGENT_DIR}/bin/bh-bridge.sh"
[[ -f "${_BH_BRIDGE}" ]] || _BH_BRIDGE="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/bin/bh-bridge.sh"
_RENDER="${CTX_AGENT_DIR}/bin/render-concierge-draft.sh"
[[ -f "${_RENDER}" ]] || _RENDER="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/bin/render-concierge-draft.sh"
_VALIDATE="${CTX_AGENT_DIR}/validate.sh"
[[ -f "${_VALIDATE}" ]] || _VALIDATE="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/validate.sh"
_BRIDGE_DIST="${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist"

# ────────────────────────────────────────────────────────────────────────
# Mode + step gating
# ────────────────────────────────────────────────────────────────────────

MODE="${CTX_CONCIERGE_MODE:-webhook}"
STEPS_TO_RUN="${CTX_STEPS_OVERRIDE:-0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}"
export STEPS_TO_RUN MODE

# Comma-list membership (the skeleton's *N* glob matched 1 inside 10-15 — fixed).
_step_on() {
  case ",${STEPS_TO_RUN}," in
    *,"$1",*) return 0 ;;
    *) return 1 ;;
  esac
}

# Run counters for Step 15.
DRAFTS_MADE=0
SENDS_MADE=0
SEND_APPROVED=0

# Step 15 body (defined up-front so _close_run can invoke it from any step).
# Reference: agent.md §4 Step 15. Ghosted-rate: candidates with a lifecycle
# state change in 30d and no concierge action within 14d of it. >5% →
# ESC_GATE_B_MISS (warn; founder + operator). Stamps the poll cursor
# (tenant_adapters.config.concierge_last_poll — v0.3-allowlisted key).
_cg_step15() {
  local note="${1:-}"
  local ghosted="n/a"
  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    ghosted="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || echo n/a
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
WITH changed AS (
  SELECT entity_id, updated_at FROM entities
  WHERE entity_type='candidate' AND updated_at > now() - interval '30 days'
),
ghosted AS (
  SELECT c.entity_id FROM changed c
  WHERE c.updated_at < now() - interval '14 days'
    AND NOT EXISTS (
      SELECT 1 FROM decision_log d
      WHERE d.agent_name='concierge' AND d.phase='action'
        AND d.payload->>'target' LIKE 'candidate:' || c.entity_id || '%'
        AND d.created_at >= c.updated_at
    )
)
SELECT CASE WHEN (SELECT count(*) FROM changed) = 0 THEN '0.0'
       ELSE round((SELECT count(*) FROM ghosted)::numeric / (SELECT count(*) FROM changed), 3)::text END;
COMMIT;
SQL
)"
    if [[ "${ghosted}" =~ ^[0-9.]+$ ]] && awk -v g="${ghosted}" 'BEGIN{exit !(g>0.05)}'; then
      autosend_escalate "ESC_GATE_B_MISS" "agent=concierge" \
        "tenant=${CTX_TENANT_SLUG}" "metric=ghosted_rate" "value=${ghosted}"
    fi
    # Stamp the poll cursor (allowlisted v0.3 key; best-effort).
    psql "${IFOS_DB_URL}" -q -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
UPDATE tenant_adapters
SET config = jsonb_set(coalesce(config,'{}'::jsonb), '{concierge_last_poll}',
                       to_jsonb(to_char(now() AT TIME ZONE 'utc','YYYY-MM-DD"T"HH24:MI:SS"Z"')))
WHERE tenant_slug = :'tenant';
COMMIT;
SQL
  fi
  local run_hash
  run_hash="$(printf '%s' "${CTX_TENANT_SLUG}|${MODE}|$(date -u +%s)" | shasum -a 256 2>/dev/null | cut -c1-16)"
  [[ -z "${run_hash}" ]] && run_hash="run-${MODE}"
  hh_decision_action "concierge_run_complete" "session:${CTX_TENANT_SLUG}" "${run_hash}" \
    "mode:${MODE}; drafts:${DRAFTS_MADE}; sends:${SENDS_MADE}; ghosted_rate:${ghosted}${note:+; note:${note}}" || true
}

# Graceful close: emits Step-15 close rows then exits 0 (skip paths: no event,
# true duplicate, operator rejection, drafts-only). Hard Gate A failures exit 1
# WITHOUT run_complete (the run did not complete — fixture 02 contract).
_close_run() {
  local note="${1:-}"
  if _step_on 15; then
    _cg_step15 "${note}"
  fi
  exit 0
}

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start
# Reference: agent.md §4 Step 0. context.sh runs first (bus invokes
# context.sh BEFORE cycle.sh per ADR-003 v2 bundle pattern); this script
# emits the trigger row that anchors the session in decision_log.
# ────────────────────────────────────────────────────────────────────────

if _step_on 0; then
  hh_decision_trigger "session_start" "mode:${MODE}; agent:concierge"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Source detection (mode-dependent) → 12-event taxonomy
# Reference: agent.md §4 Step 1. webhook parses CTX_WEBHOOK_PAYLOAD (JSON);
# poll asks bh-bridge list-state-changes since tenant_adapters.config.
# concierge_last_poll; nurture-sweep asks bh-bridge list-nurture-due.
# ESC_LIFECYCLE_STATE_UNKNOWN (warn) + skip if event ∉ 12-event taxonomy.
# ────────────────────────────────────────────────────────────────────────

# The 12-event taxonomy (agent.md §3).
_CG_TAXONOMY=" application-received interview-booked interview-completed offer-extended offer-accepted rejection withdrawal on-hold start-date-confirmed 7-day-check-in 30-day-check-in 90-day-check-in "

EVENT_JSON="{}"
QUEUE_DEPTH=0
if _step_on 1; then
  case "${MODE}" in
    webhook|manual)
      EVENT_JSON="${CTX_WEBHOOK_PAYLOAD:-{\}}"
      ;;
    poll)
      _since="$(psql "${IFOS_DB_URL:-}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(config->>'concierge_last_poll','') FROM tenant_adapters WHERE tenant_slug = :'tenant' LIMIT 1;
COMMIT;
SQL
)"
      [[ -z "${_since}" ]] && _since="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)"
      _events="$(bash "${_BH_BRIDGE}" list-state-changes --since "${_since}" 2>/dev/null || echo '[]')"
      QUEUE_DEPTH="$(printf '%s' "${_events}" | jq 'length' 2>/dev/null || echo 0)"
      EVENT_JSON="$(printf '%s' "${_events}" | jq -c '.[0] // {}' 2>/dev/null || echo '{}')"
      ;;
    nurture-sweep)
      _events="$(bash "${_BH_BRIDGE}" list-nurture-due 2>/dev/null || echo '[]')"
      QUEUE_DEPTH="$(printf '%s' "${_events}" | jq 'length' 2>/dev/null || echo 0)"
      EVENT_JSON="$(printf '%s' "${_events}" | jq -c '.[0] // {}' 2>/dev/null || echo '{}')"
      ;;
    *)
      printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
  esac

  EVENT_TYPE="$(printf '%s' "${EVENT_JSON}" | jq -r '.event_type // ""' 2>/dev/null || true)"
  CANDIDATE_ID="$(printf '%s' "${EVENT_JSON}" | jq -r '.candidate_id // ""' 2>/dev/null || true)"
  PLACEMENT_ID="$(printf '%s' "${EVENT_JSON}" | jq -r '.placement_id // ""' 2>/dev/null || true)"
  CONTACT_ID="$(printf '%s' "${EVENT_JSON}" | jq -r '.contact_id // ""' 2>/dev/null || true)"
  CLIENT_ID="$(printf '%s' "${EVENT_JSON}" | jq -r '.client_id // ""' 2>/dev/null || true)"
  STATE_FROM="$(printf '%s' "${EVENT_JSON}" | jq -r '.state_from // ""' 2>/dev/null || true)"
  STATE_TO="$(printf '%s' "${EVENT_JSON}" | jq -r '.state_to // ""' 2>/dev/null || true)"
  EVENT_TS="$(printf '%s' "${EVENT_JSON}" | jq -r '.event_timestamp_iso // ""' 2>/dev/null || true)"

  if [[ -z "${EVENT_TYPE}" || -z "${CANDIDATE_ID}" ]]; then
    hh_decision_output "lifecycle_event_detected" "mode:${MODE}" \
      "no_pending_event; queue_depth:${QUEUE_DEPTH}"
    _close_run "no_event"
  fi

  if [[ "${_CG_TAXONOMY}" != *" ${EVENT_TYPE} "* ]]; then
    autosend_escalate "ESC_LIFECYCLE_STATE_UNKNOWN" "agent=concierge" \
      "tenant=${CTX_TENANT_SLUG}" "event_type=${EVENT_TYPE}" \
      "state_from=${STATE_FROM}" "state_to=${STATE_TO}"
    hh_decision_output "lifecycle_event_detected" "candidate:${CANDIDATE_ID}" \
      "event_type:${EVENT_TYPE}; UNKNOWN — not in 12-event taxonomy; skipped"
    _close_run "lifecycle_state_unknown"
  fi

  hh_decision_output "lifecycle_event_detected" "candidate:${CANDIDATE_ID}" \
    "event_type:${EVENT_TYPE}; ${STATE_FROM}→${STATE_TO}; mode:${MODE}; queue_depth:${QUEUE_DEPTH}"
fi
: "${EVENT_TYPE:=}" "${CANDIDATE_ID:=}" "${PLACEMENT_ID:=}" "${CONTACT_ID:=}"
: "${CLIENT_ID:=}" "${STATE_FROM:=}" "${STATE_TO:=}" "${EVENT_TS:=}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Anti-duplicate guard (decision_log ledger; 24h window)
# Reference: agent.md §4 Step 2 + Q7 disposition; CC Step 6 idempotency
# ledger idiom. action_type/target live in payload jsonb (hook-helpers
# autosend_emit_decision_log shape), not top-level columns.
#   found + completed send → SKIP (true duplicate)
#   found + no send       → ALLOW the new attempt (per Q7)
# ────────────────────────────────────────────────────────────────────────

if _step_on 2; then
  _dup_status="fresh"
  _dup_sent="false"
  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    _dup_row="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
      --set=tenant="${CTX_TENANT_SLUG}" \
      --set=tgt="candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
      --set=ctgt="candidate:${CANDIDATE_ID}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT
  (SELECT count(*) FROM decision_log
   WHERE agent_name='concierge'
     AND payload->>'action_type'='concierge_email_draft'
     AND payload->>'target' = :'tgt'
     AND phase IN ('action','gating_failed')
     AND created_at > now() - interval '24 hours') || '|' ||
  (SELECT count(*) FROM decision_log
   WHERE agent_name='concierge'
     AND payload->>'action_type'='gmail_outlook_send_to_candidate'
     AND payload->>'target' = :'ctgt'
     AND phase='action'
     AND created_at > now() - interval '24 hours');
COMMIT;
SQL
)"
    IFS='|' read -r _dup_drafts _dup_sends <<<"${_dup_row:-0|0}"
    if [[ "${_dup_drafts:-0}" -gt 0 ]]; then
      _dup_status="found"
      [[ "${_dup_sends:-0}" -gt 0 ]] && _dup_sent="true"
    fi
  fi
  hh_decision_output "anti_duplicate_check" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
    "duplicate_status:${_dup_status}; prior_send_completed:${_dup_sent}"
  if [[ "${_dup_status}" == "found" && "${_dup_sent}" == "true" ]]; then
    _close_run "true_duplicate_skip"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Bullhorn context fetch (candidate/placement/client/contact)
# Reference: agent.md §4 Step 3, via bin/bh-bridge.sh. ESC_AGENT_OUTPUT_SHAPE
# if critical fields missing (no email/name). ESC_RATE_LIMIT_HIT /
# ESC_BULLHORN_AUTH fire on live-connector failures (live branch only).
# ────────────────────────────────────────────────────────────────────────

CAND_JSON="{}" PLAC_JSON="{}" CLIENT_JSON="{}" CONTACT_JSON="{}"
CAND_NAME="" CAND_EMAIL=""
if _step_on 3; then
  CAND_JSON="$(bash "${_BH_BRIDGE}" get-candidate --id "${CANDIDATE_ID}" 2>/dev/null || echo '{}')"
  [[ -n "${PLACEMENT_ID}" ]] && PLAC_JSON="$(bash "${_BH_BRIDGE}" get-placement --id "${PLACEMENT_ID}" 2>/dev/null || echo '{}')"
  [[ -n "${CLIENT_ID}" ]] && CLIENT_JSON="$(bash "${_BH_BRIDGE}" get-client --id "${CLIENT_ID}" 2>/dev/null || echo '{}')"
  [[ -n "${CONTACT_ID}" ]] && CONTACT_JSON="$(bash "${_BH_BRIDGE}" get-contact --id "${CONTACT_ID}" 2>/dev/null || echo '{}')"

  CAND_NAME="$(printf '%s' "${CAND_JSON}" | jq -r '.name // ""' 2>/dev/null || true)"
  CAND_EMAIL="$(printf '%s' "${CAND_JSON}" | jq -r '.email // ""' 2>/dev/null || true)"
  _fields_present=0
  for _f in "${CAND_NAME}" "${CAND_EMAIL}" \
            "$(printf '%s' "${PLAC_JSON}" | jq -r '.role // ""' 2>/dev/null)" \
            "$(printf '%s' "${CLIENT_JSON}" | jq -r '.company // ""' 2>/dev/null)" \
            "$(printf '%s' "${CONTACT_JSON}" | jq -r '.email // ""' 2>/dev/null)"; do
    [[ -n "${_f}" ]] && _fields_present=$((_fields_present + 1))
  done
  hh_decision_output "bullhorn_context_fetched" "candidate:${CANDIDATE_ID}" \
    "fields_present:${_fields_present}"

  if [[ -z "${CAND_NAME}" || -z "${CAND_EMAIL}" ]]; then
    # Cannot produce the declared output shape without a resolvable candidate.
    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=concierge" \
      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \
      "missing=$([[ -z "${CAND_NAME}" ]] && printf name)$([[ -z "${CAND_EMAIL}" ]] && printf ' email')"
    hh_decision_action "validate_gate_a_fail" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
      "ctx-missing-${CANDIDATE_ID}" "ESC_AGENT_OUTPUT_SHAPE; missing_critical_context" || true
    exit 1
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Addressee resolution (Gate A CRITICAL)
# Reference: agent.md §4 Step 4 + ULTRAPLAN A6 line 566 verbatim "correct
# addressee resolution; no candidates emailed under another's name".
# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on mismatch.
# IFOS_FORCE_RECIPIENT_EMAIL lets adversarial fixtures inject a wrong
# recipient to prove the gate.
# ────────────────────────────────────────────────────────────────────────

RECIPIENT="" RECIPIENT_ROLE="candidate"
if _step_on 4; then
  RECIPIENT="${IFOS_FORCE_RECIPIENT_EMAIL:-${CAND_EMAIL}}"
  if [[ "${RECIPIENT}" != "${CAND_EMAIL}" ]]; then
    autosend_escalate "ESC_ADDRESSEE_MISMATCH" "agent=concierge" \
      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \
      "recipient=${RECIPIENT}" "expected=${CAND_EMAIL}"
    hh_decision_action "validate_gate_a_fail" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
      "addressee-${CANDIDATE_ID}" "ESC_ADDRESSEE_MISMATCH; recipient:${RECIPIENT}; expected:${CAND_EMAIL}" || true
    exit 1
  fi
  hh_decision_output "addressee_resolved" "candidate:${CANDIDATE_ID}" \
    "recipient_role:${RECIPIENT_ROLE}; addressee_resolution:passed"
fi
: "${RECIPIENT:=${CAND_EMAIL}}"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Comms-template selection (tenant → shared → bundled fallback)
# Reference: agent.md §4 Step 5 + spec-004 §2. Tenant overrides live at
# /vault/<slug>/concierge-templates/<event>-<role>.md; shared fallback is
# shared/common-comms-templates.yaml (deployed under the vault root); the
# in-repo bundled copy is the last resort.
# ────────────────────────────────────────────────────────────────────────

TEMPLATE_FILE="" TEMPLATE_SOURCE="" TEMPLATE_ID=""
if _step_on 5; then
  _vault_root="${IFOS_VAULT_ROOT:-/vault}"   # /vault default per hook-helpers contract
  _tenant_tpl="${_vault_root}/${CTX_TENANT_SLUG}/concierge-templates/${EVENT_TYPE}-${RECIPIENT_ROLE}.md"
  _shared_tpl="${_vault_root}/shared/common-comms-templates.yaml"
  _bundled_tpl="${CTX_AGENT_DIR}/templates/common-comms-templates.yaml"
  [[ -f "${_bundled_tpl}" ]] || _bundled_tpl="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/templates/common-comms-templates.yaml"

  if [[ -f "${_tenant_tpl}" ]]; then
    TEMPLATE_FILE="${_tenant_tpl}"; TEMPLATE_SOURCE="tenant"
    TEMPLATE_ID="tenant-${EVENT_TYPE}-${RECIPIENT_ROLE}"
  elif [[ -f "${_shared_tpl}" ]]; then
    TEMPLATE_FILE="${_shared_tpl}"; TEMPLATE_SOURCE="shared"
  else
    TEMPLATE_FILE="${_bundled_tpl}"; TEMPLATE_SOURCE="bundled"
  fi
  if [[ -z "${TEMPLATE_ID}" ]]; then
    TEMPLATE_ID="$(awk -v ev="${EVENT_TYPE}" -v role="${RECIPIENT_ROLE}" '
      /^  - event_type: / { in_block = ($3 == ev) ? 1 : 0; role_ok = 0; next }
      in_block && /^    recipient_role: / { role_ok = ($2 == role) ? 1 : 0; next }
      in_block && role_ok && /^    template_id: / { print $2; exit }
    ' "${TEMPLATE_FILE}" 2>/dev/null || true)"
    TEMPLATE_ID="${TEMPLATE_ID:-unknown}"
  fi
  hh_decision_output "template_selected" "${EVENT_TYPE}:${RECIPIENT_ROLE}" \
    "template_id:${TEMPLATE_ID}; source:${TEMPLATE_SOURCE}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Sensitive-event escalation routing
# Reference: agent.md §4 Step 6 + §7 position bands.
#   position 3: rejection, withdrawal, on-hold with placement value >£10k
#   position 2: offer-extended, offer-accepted, start-date-confirmed,
#               on-hold ≤£10k (placement-positive / status-update)
#   position 1: everything else (acknowledgement, prep, debrief, nurture)
# ────────────────────────────────────────────────────────────────────────

ESCALATION_POSITION=1
if _step_on 6; then
  _plac_value="$(printf '%s' "${PLAC_JSON}" | jq -r '.placement_value // 0' 2>/dev/null || echo 0)"
  _pos_rationale="standard"
  case "${EVENT_TYPE}" in
    rejection|withdrawal)
      ESCALATION_POSITION=3; _pos_rationale="sensitive_event" ;;
    on-hold)
      if awk -v v="${_plac_value}" 'BEGIN{exit !(v>10000)}'; then
        ESCALATION_POSITION=3; _pos_rationale="on_hold_high_value(>10000)"
      else
        ESCALATION_POSITION=2; _pos_rationale="status_update"
      fi ;;
    offer-extended|offer-accepted|start-date-confirmed)
      ESCALATION_POSITION=2; _pos_rationale="placement_positive" ;;
    *)
      ESCALATION_POSITION=1; _pos_rationale="standard" ;;
  esac
  hh_decision_output "escalation_position_set" "candidate:${CANDIDATE_ID}" \
    "position:${ESCALATION_POSITION}; rationale:${_pos_rationale}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 7 — LLM draft generation → vault (ADR-002: body in vault, metadata
# in decision_log). Deterministic templated render; LLM polish active when
# ANTHROPIC_API_KEY set + IFOS_CONCIERGE_NO_LLM!=1 (renderer handles the
# fallback). voice_score: REAL numeric only via IFOS_FORCE_VOICE_SCORE
# (fixtures / future classifier); else honest unscored/no_classifier.
# ────────────────────────────────────────────────────────────────────────

DRAFT_PATH=""
if _step_on 7; then
  _drafts_dir="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/concierge-drafts"   # /vault default per hook-helpers contract
  mkdir -p "${_drafts_dir}" 2>/dev/null || true
  chmod 0700 "${_drafts_dir}" 2>/dev/null || true
  DRAFT_ID="cg-${CANDIDATE_ID}-${EVENT_TYPE}-$(date -u +%Y%m%dT%H%M%SZ)"
  DRAFT_PATH="${_drafts_dir}/${DRAFT_ID}.md"
  _render_args=(
    --draft-id "${DRAFT_ID}" --event-type "${EVENT_TYPE}"
    --candidate-id "${CANDIDATE_ID}" --recipient "${RECIPIENT}"
    --recipient-role "${RECIPIENT_ROLE}" --candidate-name "${CAND_NAME}"
    --position "${ESCALATION_POSITION}" --template-file "${TEMPLATE_FILE}"
    --template-source "${TEMPLATE_SOURCE}"
    --role "$(printf '%s' "${PLAC_JSON}" | jq -r '.role // ""' 2>/dev/null)"
    --company "$(printf '%s' "${CLIENT_JSON}" | jq -r '.company // ""' 2>/dev/null)"
    --interview-at "$(printf '%s' "${PLAC_JSON}" | jq -r '.interview_at // ""' 2>/dev/null)"
    --start-date "$(printf '%s' "${PLAC_JSON}" | jq -r '.start_date // ""' 2>/dev/null)"
    --event-ts "${EVENT_TS}"
  )
  [[ -n "${PLACEMENT_ID}" ]] && _render_args+=(--placement-id "${PLACEMENT_ID}")
  [[ -n "${IFOS_FORCE_VOICE_SCORE:-}" ]] && _render_args+=(--voice-score "${IFOS_FORCE_VOICE_SCORE}")
  if ! bash "${_RENDER}" "${_render_args[@]}" > "${DRAFT_PATH}.tmp" 2>/dev/null; then
    rm -f "${DRAFT_PATH}.tmp" 2>/dev/null || true
    # ESC_AGENT_OUTPUT_SHAPE: the agent cannot produce its declared output
    # shape. (ESC_RENDERER_FAILED is catalogue-reserved for the _renderer
    # sentinel, NOT agent-local draft-render failures — review finding 3.)
    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=concierge" \
      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" "event=${EVENT_TYPE}" \
      "class=draft_render_failed"
    exit 1
  fi
  mv "${DRAFT_PATH}.tmp" "${DRAFT_PATH}"
  chmod 0600 "${DRAFT_PATH}" 2>/dev/null || true
  DRAFTS_MADE=$((DRAFTS_MADE + 1))
  _d_voice="$(grep -m1 '^voice_score:' "${DRAFT_PATH}" | sed 's/^voice_score:[[:space:]]*//')"
  _d_words="$(grep -m1 '^words:' "${DRAFT_PATH}" | sed 's/^words:[[:space:]]*//')"
  # Vault path is the canonical artefact_ref (agent.md §3 line 107); the
  # candidate+event composite + voice metadata ride the reason string.
  hh_decision_output "concierge_draft_rendered" "${DRAFT_PATH}" \
    "candidate:${CANDIDATE_ID}:${EVENT_TYPE}; voice_score:${_d_voice}; words:${_d_words}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Voice + tone validation (Gate A; validate.sh) → yellow draft row
# Reference: agent.md §4 Step 8 + §5. Position thresholds 0.75/0.78/0.82
# hard-enforce on real numeric scores (unscored warn-and-pass is the
# accepted v1.0 behaviour — no classifier exists; documented in tools.yaml).
# On fail: validate.sh already emitted the ESC + validate_gate_a_fail rows
# and quarantined the draft; cycle.sh aborts (exit 1).
# ────────────────────────────────────────────────────────────────────────

PAYLOAD_HASH=""
if _step_on 8; then
  if ! bash "${_VALIDATE}" "${DRAFT_PATH}"; then
    exit 1
  fi
  PAYLOAD_HASH="$(shasum -a 256 "${DRAFT_PATH}" 2>/dev/null | cut -c1-16)"
  [[ -z "${PAYLOAD_HASH}" ]] && PAYLOAD_HASH="${CANDIDATE_ID}-${EVENT_TYPE}"
  _d_voice="$(grep -m1 '^voice_score:' "${DRAFT_PATH}" | sed 's/^voice_score:[[:space:]]*//')"
  _d_words="$(grep -m1 '^words:' "${DRAFT_PATH}" | sed 's/^words:[[:space:]]*//')"
  hh_decision_action "concierge_email_draft" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
    "${PAYLOAD_HASH}" \
    "voice_score:${_d_voice}; position:${ESCALATION_POSITION}; words:${_d_words}; recipient:${RECIPIENT}" || true
fi
: "${PAYLOAD_HASH:=${CANDIDATE_ID}-${EVENT_TYPE}}"

# ────────────────────────────────────────────────────────────────────────
# Step 9 — SLA timing check (Gate B leading metric; NOT Gate A hard-fail)
# Reference: agent.md §4 Step 9 + ADR-007 (Accepted + RATIFIED 2026-05-31).
# elapsed = now() - event_timestamp; >30min → ESC_CONCIERGE_SLA_MISS (warn;
# aggregated to the Gate B 90% threshold). Never blocks the draft.
# ────────────────────────────────────────────────────────────────────────

SLA_ELAPSED=""
if _step_on 9; then
  if [[ -n "${EVENT_TS}" ]]; then
    _ev_epoch="$(date -u -j -f '%Y-%m-%dT%H:%M:%S' "${EVENT_TS%%.*}" +%s 2>/dev/null \
      || date -u -d "${EVENT_TS}" +%s 2>/dev/null || true)"
    if [[ -n "${_ev_epoch}" ]]; then
      SLA_ELAPSED=$(( $(date -u +%s) - _ev_epoch ))
      if (( SLA_ELAPSED > 1800 )); then
        hh_decision_output "concierge_sla_miss" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
          "elapsed_seconds:${SLA_ELAPSED}; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct"
        autosend_escalate "ESC_CONCIERGE_SLA_MISS" "agent=concierge" \
          "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \
          "elapsed_seconds=${SLA_ELAPSED}"
      fi
    fi
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 10 — PII boundary check (cycle-side marker; validate.sh G4 is the
# Gate A enforcement — this re-check guards drafts produced when Step 8 ran
# with a partial STEPS override and emits the contract marker).
# ESC_PII_LEAKAGE_RISK (blocking) on hit.
# ────────────────────────────────────────────────────────────────────────

if _step_on 10; then
  _pii_hit=""
  _body_emails="$(awk 'c==2{print} /^---$/{c++}' "${DRAFT_PATH}" 2>/dev/null \
    | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
  if [[ -n "${_body_emails}" ]]; then
    _allow="${RECIPIENT##*@} ${CTX_FIRM_DOMAINS:-}"
    while IFS= read -r _em; do
      [[ -z "${_em}" ]] && continue
      _dom_ok=0
      for _a in ${_allow}; do [[ "${_em##*@}" == "${_a}" ]] && _dom_ok=1; done
      [[ "${_dom_ok}" -eq 0 ]] && _pii_hit="${_em}"
    done <<<"${_body_emails}"
  fi
  if [[ -n "${_pii_hit}" ]]; then
    autosend_escalate "ESC_PII_LEAKAGE_RISK" "agent=concierge" \
      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" "class=other_party_email"
    hh_decision_action "validate_gate_a_fail" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
      "${PAYLOAD_HASH}" "ESC_PII_LEAKAGE_RISK; class:other_party_email" || true
    mv -f "${DRAFT_PATH}" "/tmp/concierge-pii-failed-$(basename "${DRAFT_PATH}")" 2>/dev/null || true
    exit 1
  fi
  hh_decision_output "pii_check_passed" "candidate:${CANDIDATE_ID}" "result:passed"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 11 — Autosend-bridge routing (D1-B Telegram; orange approval)
# Reference: agent.md §4 Step 11 + D1-B decision doc §Implementation surface
# item 2. PRODUCTION wiring landed THIS slice: dist/bin/{propose,await}.js
# (real Bot API transport + postgres approvals reader). Requirements for the
# bridge path: dist built + operator chat id + (TELEGRAM_BOT_TOKEN set OR
# IFOS_BRIDGE_FAKE fixture mode). Anything missing → drafts-only (D1-C).
# ────────────────────────────────────────────────────────────────────────

BRIDGE_OUTCOME="" APPROVAL_ID="" DECIDED_BY=""
if _step_on 11; then
  _bridge_ready=0
  if [[ -d "${_BRIDGE_DIST}" && -f "${_BRIDGE_DIST}/bin/propose.js" \
        && -n "${CTX_OPERATOR_TELEGRAM_CHAT_ID:-}" ]] \
     && { [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]] || [[ -n "${IFOS_BRIDGE_FAKE:-}" ]]; }; then
    _bridge_ready=1
  fi

  if [[ "${_bridge_ready}" -eq 1 ]]; then
    _preview="$(awk 'c==2{print} /^---$/{c++}' "${DRAFT_PATH}" 2>/dev/null | head -c 400)"
    _timeout_s=14400   # PT4H per autosend-policy.yaml gmail_outlook_send_to_candidate.timeout
    if _propose_json="$(node "${_BRIDGE_DIST}/bin/propose.js" \
        --action gmail_outlook_send_to_candidate \
        --tenant "${CTX_TENANT_SLUG}" \
        --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
        --target "${RECIPIENT}" \
        --preview "${_preview}" \
        --vault-path "${DRAFT_PATH}" \
        --timeout-seconds "${_timeout_s}" 2>/dev/null)"; then
      APPROVAL_ID="$(printf '%s' "${_propose_json}" | jq -r '.approval_id // ""')"
      _expires_iso="$(printf '%s' "${_propose_json}" | jq -r '.expires_at_iso // ""')"
      hh_decision_action "concierge_approval_routed" \
        "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
        "d1_path:B; bridge_target:${APPROVAL_ID}; expires:${_expires_iso}" || true
      _await_json="$(node "${_BRIDGE_DIST}/bin/await.js" \
        --approval-id "${APPROVAL_ID}" --tenant "${CTX_TENANT_SLUG}" \
        --expires-at "${_expires_iso}" 2>/dev/null || echo '{"outcome":"timeout"}')"
      BRIDGE_OUTCOME="$(printf '%s' "${_await_json}" | jq -r '.outcome // "timeout"')"
      DECIDED_BY="$(printf '%s' "${_await_json}" | jq -r '.decided_by // ""')"
      case "${BRIDGE_OUTCOME}" in
        approved)
          SEND_APPROVED=1 ;;
        rejected)
          hh_decision_output "approval_rejected" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
            "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}"
          _close_run "operator_rejected" ;;
        timeout|*)
          # ESC_APPROVAL_BRIDGE_TIMEOUT per escalation-codes.md lines 348-353
          # (warn; operator + ifos_oncall); send NOT executed; draft stays in
          # vault for manual reconciliation; run exits non-zero (fixture 99).
          autosend_escalate "ESC_APPROVAL_BRIDGE_TIMEOUT" "agent=concierge" \
            "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \
            "approval_id=${APPROVAL_ID}" "timeout_seconds=${_timeout_s}"
          hh_decision_action "validate_gate_a_fail" \
            "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
            "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:${_timeout_s}; approval_id:${APPROVAL_ID}" || true
          exit 1 ;;
      esac
    else
      # Telegram postMessage transport failure — NO catalogue ESC exists for
      # transport-class failure (the phantom ESC_AGENT_TOOL_FAILURE is not in
      # the catalogue); surface as drafts-only with an explicit reason (the
      # draft is safe in vault; operator picks up). NOT
      # ESC_APPROVAL_BRIDGE_TIMEOUT — no approval message went out.
      hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
        "bridge propose failed (transport) — draft retained in vault for manual consultant pickup"
      _close_run "bridge_transport_failed"
    fi
  else
    # Bridge prerequisites absent — D1-C graceful degradation (drafts-only).
    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
      "autosend-bridge prerequisites missing (dist:$([[ -d "${_BRIDGE_DIST}" ]] && echo yes || echo no); operator_chat:$([[ -n "${CTX_OPERATOR_TELEGRAM_CHAT_ID:-}" ]] && echo set || echo unset); bot_token:$([[ -n "${TELEGRAM_BOT_TOKEN:-}" ]] && echo set || echo EMPTY)) — drafts retained in vault for manual consultant pickup"
    _close_run "drafts_only"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 12 — Send execution (orange tier; ONLY fires post-Step-11 approval)
# Reference: agent.md §4 Step 12. The bridge approval IS the human approval:
# the .approved marker is pre-written so hh_decision_action's orange gate
# resolves instantly against it (same vault substrate; no double-approval).
# Transport: MS Graph / Gmail per tenant config — OAuth ABSENT today, so the
# live send path is gated; IFOS_FORCE_SEND_RESULT=sent proves the chain in
# fixtures. ESC_SEND_FAIL (warn) on 4xx/5xx after 1 retry.
#
# Orange-row ordering (Codex 20260610T154203Z-26445 finding 3, incorporated
# post-run): the orange gmail_outlook_send_to_candidate row is emitted by
# hh_decision_action, whose orange path FUSES row emission with the gating
# (policy lookup → tenant red-elevation block → orange row (approval_pending)
# → ESC_AUTOSEND_NEEDS_REVIEW → approval await) inside the SHARED helper
# (agents/_shared/hook-helpers.sh — Cash Conductor + every agent). Emitting
# the orange row only after transport would mean either editing the shared
# helper or running the tenant red-elevation policy gate AFTER the email
# left — both dishonest/worse. Closest honest variant implemented instead:
# the orange row stays pre-transport as the POLICY-AUTHORIZATION record, and
# transport truth is carried by three output rows:
#   send_attempt   — pre-transport (transport_not_yet_executed)
#   send_confirmed — post-transport provider success; the ONLY marker that
#                    means an email actually left
#   send_failed    — post-transport failure CORRECTION row: explicitly states
#                    the orange row did NOT result in a delivered email
# Invariants: success = exactly 1 orange row + send_confirmed;
# degraded/timeout/drafts-only = 0 orange rows (unchanged); transport-failure
# = 1 orange row + send_failed correction + ESC_SEND_FAIL (documented
# deviation from "failed = 0 orange rows" — the gate fusion makes 0
# impossible without bypassing the helper). Anti-dup consequence (deliberate):
# Step 2 / validate.sh G5 read the orange action row as "completed send", so
# a post-failure webhook re-fire within 24h is suppressed as true-duplicate —
# recovery is manual per ESC_SEND_FAIL (draft retained in vault), never
# automated re-send spam.
# ────────────────────────────────────────────────────────────────────────

SEND_DONE=0
if _step_on 12 && [[ "${SEND_APPROVED}" -eq 1 ]]; then
  _transport=""
  _email_cli="${IFOS_REPO_ROOT:-}/packages/mcp-connectors/${CTX_EMAIL_CHANNEL:-microsoft-graph}/dist/cli.js"
  if [[ "${IFOS_FORCE_SEND_RESULT:-}" == "sent" ]]; then
    _transport="forced"
  elif [[ -f "${_email_cli}" && "${CTX_EMAIL_PROVIDER_TOKEN_STATE:-absent}" != "absent" ]]; then
    _transport="connector"
  fi

  if [[ -z "${_transport}" ]]; then
    hh_decision_output "send_degraded_no_transport" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
      "approved by ${DECIDED_BY:-operator} (approval:${APPROVAL_ID}) but email transport unavailable (channel:${CTX_EMAIL_CHANNEL:-microsoft-graph}; oauth:${CTX_EMAIL_PROVIDER_TOKEN_STATE:-absent}) — manual send required"
    _close_run "approved_no_transport"
  fi

  # Record the bridge approval on the vault approval substrate BEFORE the
  # orange action row, so autosend_await_approval resolves instantly.
  _pending_dir="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/pending-approvals"
  mkdir -p "${_pending_dir}" 2>/dev/null || true
  {
    printf 'approved via autosend-bridge-telegram\n'
    printf 'approval_id=%s\n' "${APPROVAL_ID}"
    printf 'decided_by=%s\n' "${DECIDED_BY}"
  } > "${_pending_dir}/${PAYLOAD_HASH}.approved"

  if hh_decision_action "gmail_outlook_send_to_candidate" "candidate:${CANDIDATE_ID}" \
       "${PAYLOAD_HASH}" \
       "event:${EVENT_TYPE}; recipient:${RECIPIENT}; channel:${CTX_EMAIL_CHANNEL:-microsoft-graph}; approval_id:${APPROVAL_ID}; policy_authorization_pre_transport"; then
    # Pre-transport attempt row: the orange row above is authorization, not
    # delivery — this marker records that transport is about to be attempted.
    hh_decision_output "send_attempt" "${DRAFT_PATH}" \
      "candidate:${CANDIDATE_ID}:${EVENT_TYPE}; recipient:${RECIPIENT}; channel:${CTX_EMAIL_CHANNEL:-microsoft-graph}; transport:${_transport}; approval_id:${APPROVAL_ID}; transport_not_yet_executed"
    _send_ok=0
    case "${_transport}" in
      forced) _send_ok=1 ;;   # fixture-proved chain; no live transport exists
      connector)
        # Documented connector CLI surface (reconciled when the MS Graph /
        # Gmail connectors land): node dist/cli.js send-email --to --subject
        # --body-file --bcc → {"ok":true,"message_id":...}
        _subject="$(grep -m1 '^subject:' "${DRAFT_PATH}" | sed 's/^subject:[[:space:]]*//; s/^"//; s/"$//')"
        for _attempt in 1 2; do
          if _send_out="$(node "${_email_cli}" send-email --to "${RECIPIENT}" \
               --subject "${_subject}" --body-file "${DRAFT_PATH}" \
               --bcc "${CTX_TENANT_ARCHIVE_BCC:-}" 2>/dev/null)" \
             && [[ "$(printf '%s' "${_send_out}" | jq -r '.ok // false')" == "true" ]]; then
            _send_ok=1; break
          fi
          [[ "${_attempt}" -eq 1 ]] && sleep 30
        done ;;
    esac
    if [[ "${_send_ok}" -eq 1 ]]; then
      # Provider-confirmed transport success — the ONLY marker that means an
      # email actually left (the orange row alone is policy authorization).
      hh_decision_output "send_confirmed" "${DRAFT_PATH}" \
        "candidate:${CANDIDATE_ID}:${EVENT_TYPE}; recipient:${RECIPIENT}; channel:${CTX_EMAIL_CHANNEL:-microsoft-graph}; transport:${_transport}; provider_confirmed"
      SEND_DONE=1
      SENDS_MADE=$((SENDS_MADE + 1))
    else
      autosend_escalate "ESC_SEND_FAIL" "agent=concierge" \
        "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \
        "channel=${CTX_EMAIL_CHANNEL:-microsoft-graph}" "retries=1"
      # CORRECTION row: the pre-transport orange gmail_outlook_send_to_candidate
      # row did NOT result in a delivered email.
      hh_decision_output "send_failed" "${DRAFT_PATH}" \
        "candidate:${CANDIDATE_ID}:${EVENT_TYPE}; CORRECTION: orange row ${PAYLOAD_HASH} did NOT result in a delivered email; transport failed after 1 retry; ESC_SEND_FAIL emitted; manual send required"
      _close_run "send_failed"
    fi
  else
    # Orange gate did not resolve approved (defensive; bridge said approved).
    _close_run "orange_gate_unresolved"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 13 — Bullhorn activity-log write (green; audit trail in the ATS;
# NOT customer-visible — separate from bullhorn_note_customer_visible).
# Reference: agent.md §4 Step 13, via bh-bridge create-activity-log.
# ESC_BULLHORN_WRITE_FAIL (warn) on write failure.
# ────────────────────────────────────────────────────────────────────────

if _step_on 13 && [[ "${SEND_DONE}" -eq 1 ]]; then
  _al_out="$(bash "${_BH_BRIDGE}" create-activity-log --candidate "${CANDIDATE_ID}" \
    --note "concierge: ${EVENT_TYPE} sent at $(date -u +%Y-%m-%dT%H:%M:%SZ)" 2>/dev/null || echo '{}')"
  if [[ "$(printf '%s' "${_al_out}" | jq -r '.ok // false')" == "true" ]]; then
    _al_id="$(printf '%s' "${_al_out}" | jq -r '.activity_id // ""')"
    hh_decision_action "bullhorn_activity_log_write" "candidate:${CANDIDATE_ID}" \
      "${PAYLOAD_HASH}" "event_type:${EVENT_TYPE}; bullhorn_activity_id:${_al_id}" || true
  else
    autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=concierge" \
      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" "write=activity_log"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 14 — Lifecycle state advance (conditional Bullhorn write; per-tenant
# opt-in). Reference: agent.md §4 Step 14. Opt-in via
# IFOS_FORCE_STATE_ADVANCE=1 (the tenant_adapters key for this policy is NOT
# in the v0.4 allowlist yet — schema-before-code: defaults OFF until a v0.5
# supplement adds it; documented deviation). Always emits the audit row.
# ────────────────────────────────────────────────────────────────────────

if _step_on 14 && [[ "${SEND_APPROVED}" -eq 1 ]]; then
  _advanced="false"
  if [[ "${IFOS_FORCE_STATE_ADVANCE:-0}" == "1" && -n "${STATE_TO}" ]]; then
    if [[ "$(bash "${_BH_BRIDGE}" patch-state --type candidate --id "${CANDIDATE_ID}" \
           --state "${STATE_TO}" 2>/dev/null | jq -r '.ok // false')" == "true" ]]; then
      _advanced="true"
    else
      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=concierge" \
        "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" "write=state_advance"
    fi
  fi
  hh_decision_action "concierge_send_complete" "candidate:${CANDIDATE_ID}" \
    "${PAYLOAD_HASH}" \
    "event_type:${EVENT_TYPE}; elapsed:${SLA_ELAPSED:-unknown}; state_advanced:${_advanced}" || true
fi

# ────────────────────────────────────────────────────────────────────────
# Step 15 — Session close + Gate B metric (body defined up-front as
# _cg_step15 so the skip paths can close cleanly via _close_run).
# ────────────────────────────────────────────────────────────────────────

if _step_on 15; then
  _cg_step15 ""
fi

exit 0
