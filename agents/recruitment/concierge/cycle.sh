#!/usr/bin/env bash
# Concierge agent — cycle.sh (15-step orchestration)
#
# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs with
#         full package wiring per agent.md §4).
# Reading order: agent.md §1 (output contract) + §3 (12 lifecycle events) +
#         §4 (this workflow's 15 steps) + §5 (Gate A) + §6 (16 ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# Invocation modes (per agent.md §2):
#   mode=webhook         — Bullhorn lifecycle webhook event-driven (v1.0 primary)
#   mode=poll            — Bullhorn state-changed-at polling fallback when
#                          tenant lacks webhook capability
#   mode=nurture-sweep   — cron: 7d/30d/90d post-start nurture cadence
#   mode=manual          — ifosctl concierge process-event|nurture-sweep
#
# Package dependencies (W10-13 build slice; v0.1.0 fixture-first SKELETON):
#   @ifos/bullhorn               — Bullhorn ATS (auth + entity fetches + activity-log write)
#   @ifos/microsoft-graph        — MS Graph send_email (alt to gmail)
#   @ifos/gmail                  — Gmail send_email (alt to microsoft-graph)
#   @ifos/autosend-bridge-telegram — D1-B Telegram approval shim (Concierge OWNS Step 11)
#   @ifos/voice-classifier       — voice scoring per position threshold
#   @ifos/tone-rules             — block-severity tone-rule enforcement
#   @ifos/telegram               — operator notifications (NOT customer-facing)
#
# Output contract per agent.md §1 (READ THAT FIRST):
#   Customer-facing email drafts per lifecycle event (12-event taxonomy) →
#   vault at /vault/<tenant>/concierge-drafts/<draft_id>.md + decision_log
#   yellow-tier concierge_email_draft row; SEND is orange tier
#   (gmail_outlook_send_to_candidate / bullhorn_note_customer_visible)
#   gated by autosend-bridge approval per D1-B founder decision.

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

# ────────────────────────────────────────────────────────────────────────
# Mode + invocation surface
# ────────────────────────────────────────────────────────────────────────

MODE="${CTX_CONCIERGE_MODE:-webhook}"
STEPS_TO_RUN="${CTX_STEPS_OVERRIDE:-0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}"

# TODO(W10-13): mode-dependent argument parsing
#   webhook  → CTX_WEBHOOK_PAYLOAD (JSON; Bullhorn lifecycle event)
#   poll     → CTX_POLL_SINCE_ISO
#   nurture  → CTX_NURTURE_LOOKBACK_DAYS (7|30|90)
#   manual   → CTX_MANUAL_ENTITY_TYPE + CTX_MANUAL_ENTITY_ID + CTX_MANUAL_EVENT_TYPE
# Until parsed, mark unused intentionally:
export STEPS_TO_RUN MODE

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start
# Reference: agent.md §4 Step 0. context.sh runs first (bus invokes
# context.sh BEFORE cycle.sh per ADR-003 v2 bundle pattern); this script
# emits the trigger row that anchors the session in decision_log.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *0* ]]; then
  hh_decision_trigger "session_start" "mode:${MODE}; agent:concierge"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Source detection (mode-dependent)
# Reference: agent.md §4 Step 1. Three branches: webhook (parse payload),
# poll (query Bullhorn since last poll), nurture-sweep (time-elapsed events).
# Anti-duplicate window handled in Step 2.
# ESC_LIFECYCLE_STATE_UNKNOWN per agent.md §6 row 5 if state transition not
# in the 12-event taxonomy (escalation-codes.md catalogue addition flagged).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *1* ]]; then
  # TODO(W10-13): per-mode source detection
  #   if [[ "${MODE}" == "webhook" ]]; then parse_bullhorn_webhook_payload; fi
  #   if [[ "${MODE}" == "poll" ]]; then query_bullhorn_state_changes_since; fi
  #   if [[ "${MODE}" == "nurture-sweep" ]]; then query_placements_for_time_elapsed; fi
  # On state ∉ 12-event taxonomy: emit ESC_LIFECYCLE_STATE_UNKNOWN warn + skip
  hh_decision_output "lifecycle_event_detected" "mode:${MODE}" \
    "entity_type:STUB; bullhorn_id:STUB; state_from:STUB; state_to:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Anti-duplicate guard
# Reference: agent.md §4 Step 2 + Q7 disposition. Query decision_log for
# prior concierge_email_draft row for (candidate_id, payload.event_type)
# in last 24h with phase ∈ ('output','action'). If prior draft was sent OR
# is still pending consultant action AND send-completed → skip; if prior
# draft never sent → allow new attempt.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *2* ]]; then
  # TODO(W10-13): SELECT decision_log WHERE agent_name='concierge'
  #   AND action_type='concierge_email_draft'
  #   AND payload->>'event_type'=<event_type>
  #   AND created_at > now() - interval '24h'
  hh_decision_output "anti_duplicate_check" "candidate:STUB:STUB" \
    "duplicate_status:STUB; prior_send_completed:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Bullhorn context fetch
# Reference: agent.md §4 Step 3. Pulls candidate + placement + client +
# contact entities. ESC_RATE_LIMIT_HIT on 429; ESC_BULLHORN_AUTH on auth
# fail; ESC_AGENT_OUTPUT_SHAPE if critical fields missing (no email/name).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *3* ]]; then
  # TODO(W10-13): @ifos/bullhorn entity fetches
  #   bullhorn.get_candidate(candidate_id) → name, state, comms_history
  #   bullhorn.get_placement(placement_id) → role, client, dates
  #   bullhorn.get_client(client_id) → company, primary_contact
  #   bullhorn.get_contact(contact_id) → name, email
  # On critical-field-missing: hh_decision_action "validate_gate_a_fail" \
  #   "candidate:<id>" "<hash>" "ESC_AGENT_OUTPUT_SHAPE; missing:email|name"
  hh_decision_output "bullhorn_context_fetched" "candidate:STUB" \
    "fields_present:STUB; rate_limit_remaining:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Addressee resolution (Gate A CRITICAL)
# Reference: agent.md §4 Step 4 + §5 Gate A + ULTRAPLAN A6 line 566 verbatim
# "correct addressee resolution; no candidates emailed under another's name".
# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on mismatch.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *4* ]]; then
  # TODO(W10-13): assert recipient_email matches the candidate_id whose
  # lifecycle is changing; cross-check against bullhorn.get_candidate.email.
  # On mismatch: emit ESC_ADDRESSEE_MISMATCH + abort the draft pipeline.
  hh_decision_output "addressee_resolved" "candidate:STUB" \
    "recipient_role:STUB; addressee_resolution:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Comms-template selection
# Reference: agent.md §4 Step 5. Per-tenant /vault/<slug>/concierge-templates/
# library; fallback to shared/common-comms-templates.yaml.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *5* ]]; then
  # TODO(W10-13): resolve template by (event_type, recipient_role); read from
  # tenant vault first, fall back to shared common.
  hh_decision_output "template_selected" "event:STUB:STUB" \
    "template_id:STUB; source:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Sensitive-event escalation routing
# Reference: agent.md §4 Step 6. Set escalation_position=3 for rejection,
# withdrawal, or on-hold (placement value >£10k). Else position=1.
# Position drives the per-draft voice classifier threshold at Step 8.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *6* ]]; then
  # TODO(W10-13): if event_type IN ('rejection','withdrawal','on-hold' AND placement>£10k):
  #   ESCALATION_POSITION=3
  # else
  #   ESCALATION_POSITION=1
  hh_decision_output "escalation_position_set" "candidate:STUB" \
    "position:STUB; rationale:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 7 — LLM draft generation
# Reference: agent.md §4 Step 7. Prompt = event context + candidate state
# history + voice corpus ANN-matched on event_type + tone rules + template.
# Output → /vault/<tenant>/concierge-drafts/<draft_id>.md.
# ESC_VOICE_DRIFT if classifier score < threshold after 3 retries (the actual
# Gate A hard-fail expression is at Step 8 below via validate_gate_a_fail).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *7* ]]; then
  # TODO(W10-13): LLM call → write draft body to vault → emit:
  #   DRAFT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-drafts/<draft_id>.md"
  #   hh_decision_output "concierge_draft_rendered" "candidate:STUB:STUB" \
  #     "vault_path:${DRAFT_PATH}; voice_score:STUB; words:STUB"
  hh_decision_output "concierge_draft_rendered" "candidate:STUB:STUB" \
    "vault_path:STUB; voice_score:STUB; words:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Voice + tone validation
# Reference: agent.md §4 Step 8 + §5 Gate A. Position-specific thresholds:
#   position 1: ≥0.75 ; position 2: ≥0.78 ; position 3: ≥0.82
# On pass: emit concierge_email_draft (yellow tier; REGISTERED in policy).
# On block-severity tone hit: ESC_TONE_RULE_VIOLATION (blocking).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *8* ]]; then
  # TODO(W10-13): bash validate.sh "${DRAFT_PATH}"; if exit 0:
  #   hh_decision_action "concierge_email_draft" \
  #     "candidate:<bullhorn_id>:<event_type>" "<payload_hash>" \
  #     "voice_score:<N>; position:<P>; words:<W>; recipient:<email>"
  # else: validate.sh already emitted validate_gate_a_fail; cycle.sh aborts the draft
  hh_decision_action "concierge_email_draft" "candidate:STUB:STUB" "stub-hash" \
    "voice_score:STUB; position:STUB; words:STUB; recipient:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 9 — SLA timing check (Gate B leading metric; NOT Gate A hard-fail)
# Reference: agent.md §4 Step 9 + ADR-007 RATIFIED 2026-05-31.
# elapsed = now() - event_timestamp; if >30min → ESC_CONCIERGE_SLA_MISS
# (warn; aggregated to Gate B at 90% threshold). Per-draft hard-fail would
# block legitimate polling-fallback delays.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *9* ]]; then
  # TODO(W10-13): ELAPSED=$(( $(date +%s) - EVENT_TIMESTAMP_EPOCH ))
  # if (( ELAPSED > 1800 )); then
  #   hh_decision_output "concierge_sla_miss" "candidate:<id>:<event>" \
  #     "elapsed_seconds:${ELAPSED}; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct"
  # fi
  :
fi

# ────────────────────────────────────────────────────────────────────────
# Step 10 — PII boundary check
# Reference: agent.md §4 Step 10. No PII from other candidates / competitor
# clients / compensation specifics outside candidate's record. On hit:
# ESC_PII_LEAKAGE_RISK (blocking; operator + ifos_oncall).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *10* ]]; then
  # TODO(W10-13): regex sweep against firm-domain whitelist + competitor list
  # + candidate-record allowlist; on hit:
  # hh_decision_action "validate_gate_a_fail" "candidate:<id>" "<hash>" \
  #   "ESC_PII_LEAKAGE_RISK; class:<other_candidate|competitor|comp_specifics>"
  hh_decision_output "pii_check_passed" "candidate:STUB" "result:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 11 — Autosend-bridge routing (D1-B Telegram path)
# Reference: agent.md §4 Step 11 + D1-B founder decision (2026-05-31) +
# docs/decisions/2026-05-31-d1-founder-decision.md §"Implementation surface"
# item 2 verbatim: "Concierge cycle.sh Step 11 — calls proposeApproval for
# orange-tier drafts; on approved, proceeds to Step 12 transport; on rejected
# or timeout, fires ESC_APPROVAL_BRIDGE_TIMEOUT (timeout) or records rejection
# in decision_log (rejected)."
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *11* ]]; then
  if [[ -d "${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist" ]]; then
    # Bridge package PRESENT — production-shape per-draft flow.
    # SKELETON (W10-13 build slice wires the per-draft iteration + tsx CLI
    # entrypoints; entrypoints land at packages/utilities/autosend-bridge-telegram/
    # bin/{propose,await}.ts in the same build slice — they are intentionally
    # NOT in v0.1 scaffold per the package README §"Out of scope (v1.0)").
    #
    # Per draft produced at Step 7:
    #
    # 1. proposeApproval — @ifos/autosend-bridge-telegram proposeApproval API:
    #
    #    PROPOSE_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/propose.ts" \
    #      --action gmail_outlook_send_to_candidate \
    #      --tenant "${CTX_TENANT_SLUG}" \
    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
    #      --target "${RECIPIENT_EMAIL}" \
    #      --preview "${DRAFT_PREVIEW_500_CHARS}" \
    #      --vault-path "${DRAFT_PATH}" \
    #      --timeout-seconds 14400)
    #    APPROVAL_ID=$(printf '%s' "${PROPOSE_JSON}" | jq -r .approval_id)
    #    EXPIRES_AT_ISO=$(printf '%s' "${PROPOSE_JSON}" | jq -r .expires_at_iso)
    #
    # 2. Emit concierge_approval_routed audit row (R19 registration):
    #
    #    hh_decision_action "concierge_approval_routed" \
    #      "candidate:${BULLHORN_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
    #      "d1_path:B; bridge_target:${APPROVAL_ID}; expires:${EXPIRES_AT_ISO}"
    #
    # 3. awaitApprovalDecision — block until decision or PT4H deadline:
    #
    #    AWAIT_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/await.ts" \
    #      --approval-id "${APPROVAL_ID}" \
    #      --expires-at "${EXPIRES_AT_ISO}")
    #    OUTCOME=$(printf '%s' "${AWAIT_JSON}" | jq -r .outcome)
    #    DECIDED_BY=$(printf '%s' "${AWAIT_JSON}" | jq -r '.decided_by // ""')
    #
    # 4. Branch on outcome:
    #    case "${OUTCOME}" in
    #      approved) : ;;  # Step 12 transport proceeds
    #      rejected)
    #        hh_decision_output "approval_rejected" \
    #          "candidate:${BULLHORN_ID}:${EVENT_TYPE}" \
    #          "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}" ;;
    #      timeout)
    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
    #        # lines 348-353: warn-tier; operator + tenant-admin per agent.md §6 row 11
    #        hh_decision_action "validate_gate_a_fail" \
    #          "candidate:${BULLHORN_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
    #    esac
    : # TODO(W10-13): wire the per-draft loop above; tsx CLI entrypoints land alongside
  else
    # Bridge package ABSENT — D1-C graceful degradation (drafts-only).
    # DO NOT emit concierge_approval_routed; draft stays in vault for manual
    # consultant pickup. Concierge §1 readiness caveat captures this state.
    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
      "autosend-bridge-telegram package dist/ not present — D1-C mode active; drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable D1-B send path"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# Step 12 — Send execution (orange tier; ONLY fires post-Step-11 approval)
# Reference: agent.md §4 Step 12. microsoft_graph_send OR gmail_send per
# tenant config; BCC tenant archive address. ESC_SEND_FAIL on 4xx/5xx
# (retry once 30s backoff per agent.md §4 Step 12).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *12* ]]; then
  # TODO(W10-13): per-tenant channel resolution:
  #   if tenant_adapters.config.email_channel == 'microsoft-graph':
  #     ms_graph.send_email(to=RECIPIENT, subject=SUBJECT, body=BODY_MD, bcc=TENANT_ARCHIVE)
  #   else: gmail.send_email(...)
  # On success:
  #   hh_decision_action "gmail_outlook_send_to_candidate" "candidate:<id>" "<hash>" "<preview>"
  # On 4xx/5xx after 1 retry: ESC_SEND_FAIL warn-tier
  :
fi

# ────────────────────────────────────────────────────────────────────────
# Step 13 — Bullhorn activity-log write (post-send audit trail in ATS)
# Reference: agent.md §4 Step 13. Green-tier; NOT customer-visible; maintains
# audit trail in Bullhorn so downstream consultant ops see Concierge actions
# in the candidate's Bullhorn record.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *13* ]]; then
  # TODO(W10-13): bullhorn.create_activity_log(candidate_id, "concierge: <event_type> sent at <ISO>")
  hh_decision_output "bullhorn_activity_logged" "candidate:STUB" \
    "event_type:STUB; bullhorn_activity_id:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 14 — Lifecycle state advance (conditional; per-tenant opt-in)
# Reference: agent.md §4 Step 14. Some events trigger Bullhorn state changes
# (e.g. interview-completed sent → advances to "post-interview" if tenant
# policy says so). Not all tenants want this — opt-in via tenant config.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *14* ]]; then
  # TODO(W10-13): if tenant_adapters.config.concierge_state_advance_enabled:
  #   bullhorn.update_candidate_state(candidate_id, NEXT_STATE)
  # Always emit the audit row (records the policy decision):
  hh_decision_action "concierge_send_complete" "candidate:STUB" "stub-hash" \
    "event_type:STUB; elapsed:STUB; state_advanced:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 15 — Session close + Gate B metric
# Reference: agent.md §4 Step 15. Computes elapsed (event → send) for Gate B
# SLA tracking. Checks ghosted-rate (any candidate with no Concierge action
# in 14d post-state-change). 30-day rolling >5% ghosted → ESC_GATE_B_MISS.
# ────────────────────────────────────────────────────────────────────────

# TODO(W10-13): UPDATE tenant_adapters SET config = jsonb_set(config, '{concierge_last_run}', '"<ISO>"')

hh_decision_action "concierge_run_complete" "session:${CTX_TENANT_SLUG}" "stub-hash" \
  "mode:${MODE}; drafts:STUB; sends:STUB; ghosted_rate:STUB"

exit 0
