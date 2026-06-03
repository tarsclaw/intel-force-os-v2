#!/usr/bin/env bash
# Scribe agent — cycle.sh (10-step per-call orchestration; W5 Day-32 SKELETON)
#
# Status: Proposed (W5 Day-32 SKELETON; W6 build slice replaces stubs with
#         full package wiring per agent.md §4).
# Reading order: agent.md §1 (output contract) + §3 (2 outputs: Bullhorn
#         structured-field writes + tacit-note vault + Bullhorn note attach) +
#         §4 (this workflow's 10 steps) + §5 (Gate A + Gate B) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# IMPORTANT — vendor delta from CONTRACT (see scribe/agent.md Reading-discipline
# note added in the same bundle pass): agent.md describes a WEBHOOK-DRIVEN flow
# from Fathom/Fireflies (Step 1 = webhook signature verification). The deployed
# SKELETON uses POLLING from Granola per Day-29 vendor pivot (founder
# confirmed 2026-06-03; Fathom/Fireflies → Granola — see goal-week-5-execution-plan.md
# §2 Phase 3 fix-forward). Granola does NOT publish webhooks per @ifos/granola
# README §Scribe consumption pattern — so cycle.sh handles BOTH the outer
# poll-sweep loop (mode=poll-sweep; analogous to Janitor's nightly orchestration)
# AND the per-meeting Steps 0-10 (matches agent.md per-call shape internally).
# W6 ratification updates agent.md to match the deployed Granola polling reality.
#
# Invocation modes:
#   mode=poll-sweep   — 5-min cron: list_meetings since last_poll → for each
#                       new meeting → process Steps 0-10 per meeting (default)
#   mode=replay       — manual: process one specific meeting_id (debugging /
#                       reprocessing after taxonomy update; per agent.md §2
#                       "ifosctl scribe replay --call-id <id>")
#   mode=dry-run      — poll-sweep + Steps 0-7 only (no Step 8/9 Bullhorn writes;
#                       fields-extracted + tacit-note rendered to vault for
#                       inspection; no live ATS state change)
#
# Package dependencies (W5 Day-28/29 scaffolded; v0.1.0 fixture-first):
#   @ifos/bullhorn        — Bullhorn ATS (R+W on Candidate via updateCandidate;
#                           W on Note via createNote; v1.0 LIMITATION: Contact /
#                           Brief / Placement updates require @ifos/bullhorn v0.2+
#                           — declared in tools.yaml with TODO(W6-7) markers)
#   @ifos/granola         — Granola MCP wrapper (5 capabilities: listMeetings +
#                           getMeeting + queryMeetings + getTranscript + getAccountInfo;
#                           Paid-plan tools gated via plan_tier_hint)
#
# Output contract per agent.md §1 (READ THAT FIRST). Two outputs per meeting:
#   1. ≥3 Bullhorn structured-field writes (yellow tier bullhorn_scribe_field_write)
#   2. Tacit-note Markdown to /vault/<tenant>/scribe-notes/<call_id>-<ISO>.md
#      + Bullhorn Note attachment (yellow tier bullhorn_note_append_summary)
#
# Per agent.md §5 Gate A: ≥3 fields with confidence ≥0.6 AND tacit-note voice
# classifier ≥0.75. Below threshold → ESC_FIELD_EXTRACTION_LOW_CONFIDENCE or
# ESC_VOICE_DRIFT respectively; transcript stays in /tmp; no Bullhorn write.
# v0.4 supplement (LANDED + LIVE on VPS 2026-06-03) made bullhorn_corporation_id +
# granola_workspace_id schema-clean — context.sh resolves both at Step 0.

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: hydrate context + resolve _shared/ helpers
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'scribe/cycle.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'scribe/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=scribe}"

# Resolve _shared/ helpers (4-candidate chain per smoke-hotfix commit d7d52c5
# mirrored from sibling agent bundles).
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
  printf 'cycle.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# Mode dispatch (default = poll-sweep; cron passes --mode poll-sweep every 5 min)
MODE="poll-sweep"
CALL_ID_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)    MODE="${2:-}"; shift 2 ;;
    --call-id) CALL_ID_ARG="${2:-}"; shift 2 ;;
    --tenant)  shift 2 ;;  # tenant set via CTX_TENANT_SLUG by bus
    --dry-run) MODE="dry-run"; shift ;;
    *)         shift ;;
  esac
done
export CALL_ID_ARG

# Validate mode + replay-mode args
case "${MODE}" in
  poll-sweep|dry-run)
    if [[ -n "${CALL_ID_ARG}" ]]; then
      printf 'cycle.sh: --call-id only valid in mode=replay; ignoring\n' >&2
    fi ;;
  replay)
    if [[ -z "${CALL_ID_ARG}" ]]; then
      printf 'cycle.sh: --call-id required for mode=replay\n' >&2
      exit 2
    fi ;;
  *) printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
esac

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start (outer; per cycle.sh invocation)
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" "scribe mode=${MODE} call_id=${CALL_ID_ARG:-NA}"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Granola transcript fetch (replaces agent.md "webhook signature
# verification"; vendor pivot Fathom/Fireflies → Granola per Day-29)
# Reference: agent.md §4 Step 3 (fetch transcript) + Day-29 pivot.
# Modes:
#   poll-sweep: @ifos/granola listMeetings since granola_last_poll
#               (tenant_adapters.config; W6-7 wires) → for each new meeting →
#               getTranscript (if has_transcript AND plan_tier='paid')
#   replay:     getTranscript directly for CALL_ID_ARG
# ESC_PROVIDER_FETCH_FAIL on Granola 4xx/5xx (per agent.md §6); 30s backoff;
# retry once. ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
# (defer pattern-match to Step 7 validate.sh G6).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): poll-sweep loop:
#   import {listMeetings, getTranscript} from '@ifos/granola';
#   const meetings = await listMeetings(client, {start_date: last_poll, end_date: now()});
#   for meeting of meetings where has_transcript and accountInfo.plan_tier === 'paid':
#     const transcript = await getTranscript(client, meeting.id, {plan_tier_hint: 'paid'});
#     // process Steps 2-10 per-meeting; emit per-meeting audit rows
hh_decision_output "granola_meetings_polled" "tenant:${CTX_TENANT_SLUG}" \
  "mode:${MODE}; meetings_with_transcripts:STUB; since:STUB; workspace_id:${CTX_GRANOLA_WORKSPACE_ID:-STUB}"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn auth refresh
# Reference: agent.md §4 Step 2; @ifos/bullhorn refreshTokens (two-step Step A
# OAuth + Step B REST login per src/auth.ts). ESC_BULLHORN_AUTH on 2-retry fail.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): import {refreshTokens, loadTokens} from '@ifos/bullhorn'; refresh
# per CTX_BULLHORN_CORPORATION_ID; per-corp Promise dedup + 401-force-refresh
# per cluster F R4 lesson; ESC_BULLHORN_AUTH (blocking; operator + ifos_oncall)
# on failure.
hh_decision_output "bullhorn_auth_refresh" "tenant:${CTX_TENANT_SLUG}" \
  "corporation_id:${CTX_BULLHORN_CORPORATION_ID:-STUB}; bullhorn_token_state:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Granola transcript fetch (per-meeting; only when mode=replay OR
# poll-sweep iterates over a specific meeting with has_transcript=true)
# Reference: agent.md §4 Step 3; transcript stored at /tmp/scribe-<tenant>-<call_id>.txt
# mode 0600. ESC_PROVIDER_FETCH_FAIL on Granola 4xx/5xx.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): per-meeting iteration body. Skeleton emits the audit row shape
# that the per-meeting full implementation will preserve. In poll-sweep mode
# this fires N times (once per new meeting with transcript); in replay mode
# fires once for CALL_ID_ARG.
hh_decision_output "transcript_fetched" "call:${CALL_ID_ARG:-STUB}" \
  "provider:granola; bytes:STUB; tmp_path:/tmp/scribe-${CTX_TENANT_SLUG}-STUB.txt"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Participant + entity inference (Bullhorn lookup)
# Reference: agent.md §4 Step 4; match transcript participants against
# Bullhorn contacts + candidates + consultant accounts. Resolve target
# entity (bullhorn_id + entity_type per vertical-schema canonical id).
# ESC_AGENT_OUTPUT_SHAPE if no resolvable target (Scribe run cannot produce
# its declared output shape without a target).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): @ifos/bullhorn listCandidates / listContacts with name/email
# match against transcript.participants[]; resolve highest-confidence entity;
# if no match ≥0.6: ESC_AGENT_OUTPUT_SHAPE + hh_decision_action
# validate_gate_a_fail; skip this meeting (continue poll-sweep to next).
hh_decision_output "entity_resolved" "call:${CALL_ID_ARG:-STUB}" \
  "entity_type:STUB; bullhorn_id:STUB; confidence:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — LLM field extraction (≥3 fields with confidence ≥0.6 per Gate A)
# Reference: agent.md §4 Step 5; prompt = (transcript + entity context +
# vertical-schema entity field list + 3 voice-corpus examples) → JSON with
# per-field confidence. Discard <0.6. Require ≥3 ≥0.6 OR
# ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): LLM call; parse JSON; filter confidence ≥0.6; if <3 fields pass:
# ESC_FIELD_EXTRACTION_LOW_CONFIDENCE warn-tier + hh_decision_action
# validate_gate_a_fail + skip Steps 8-9; continue to next meeting.
hh_decision_output "fields_extracted" "call:${CALL_ID_ARG:-STUB}" \
  "fields_above_threshold:STUB; entity_type:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — LLM tacit-note generation (voice-classified; ≥0.75 score)
# Reference: agent.md §4 Step 6 + §3 Output 2 shape (8-category taxonomy);
# voice classifier ≥0.75 OR ESC_VOICE_DRIFT after 3 retries. Write to
# /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md (vault is canonical
# narrative source per ADR-002).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): LLM call with hh_load_tone_rules('scribe') + hh_load_voice_samples;
# write to VAULT path (NOT decision_log; per ADR-002 vault/Postgres split —
# decision_log row carries vault_path + body_sha256 + voice_score METADATA only).
TACIT_NOTE_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/scribe-notes/${CALL_ID_ARG:-STUB}-$(date -u +%Y-%m-%d).md"
mkdir -p "$(dirname "${TACIT_NOTE_PATH}")" 2>/dev/null || true
printf '# Tacit notes — STUB\n\nTODO(W6-7): full §3 Output 2 narrative + 8-category taxonomy.\n' > "${TACIT_NOTE_PATH}" 2>/dev/null || true
hh_decision_output "tacit_note_rendered" "${TACIT_NOTE_PATH}" \
  "voice_score:STUB; words:STUB; body_sha256:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Field-extraction validation against vertical-schema
# Reference: agent.md §4 Step 7; per-field name + type/range checks against
# vertical-schema.yaml. Failure → ESC_SCHEMA_VIOLATION + validate_gate_a_fail
# + exit 1. validate.sh sibling enforces this (Gate A G2 per validate.sh).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): per-field schema lookup; drop invalid; require ≥3 valid;
# if <3: ESC_SCHEMA_VIOLATION + validate_gate_a_fail (catalogue line 163;
# warn-tier; operator_chat_id).
hh_decision_output "fields_validated" "call:${CALL_ID_ARG:-STUB}" \
  "valid:STUB; dropped:STUB"

# Skip Bullhorn writes in dry-run mode
if [[ "${MODE}" == "dry-run" ]]; then
  hh_decision_output "dry_run_writes_skipped" "call:${CALL_ID_ARG:-STUB}" \
    "would_write_field_count:STUB; would_attach_note:true"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Bullhorn write: structured fields (yellow tier per agent.md §3 Output 1)
# action_type: bullhorn_scribe_field_write per agent.md §3 line 84.
# v1.0 LIMITATION: @ifos/bullhorn only exports updateCandidate; Contact /
# Brief / Placement updates require @ifos/bullhorn v0.2+ (declared in
# tools.yaml with TODO(W6-7) markers). For v0.1.0 scaffold, only Candidate
# field writes are wireable today.
# ────────────────────────────────────────────────────────────────────────

if [[ "${MODE}" != "dry-run" ]]; then
  # TODO(W6-7): switch on entity_type from Step 4:
  #   case entity_type:
  #     candidate → @ifos/bullhorn updateCandidate(field_map)  // v0.1 supported
  #     contact   → @ifos/bullhorn updateContact(field_map)    // requires v0.2
  #     brief     → @ifos/bullhorn updateBrief(field_map)      // requires v0.2
  #     placement → @ifos/bullhorn updatePlacement(field_map)  // requires v0.2
  #     opportunity → IFOS-cached Postgres write (NOT direct Bullhorn endpoint
  #                   per bullhorn-integration-path §4.1 A3; v0.3 fields only)
  # atomic per-write; rollback on 4xx/5xx; ESC_BULLHORN_WRITE_FAIL.
  # action_type: bullhorn_scribe_field_write (yellow tier; verify registered
  # in autosend-policy.yaml — currently expected REGISTERED; QUEUED otherwise).
  hh_decision_action "bullhorn_scribe_field_write" "call:${CALL_ID_ARG:-STUB}" "stub-hash" \
    "entity_type:STUB; bullhorn_id:STUB; fields_written:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Bullhorn write: tacit-note attachment (yellow tier)
# Reference: agent.md §4 Step 9; POST /Note linked to entity from Step 4
# (mirror of vault artefact from Step 6). action_type:
# bullhorn_note_append_summary per agent.md §3 line 113 + autosend-policy.yaml
# line 212. On failure: rollback Step 8 (best-effort PATCH reversing changes)
# per agent.md §9 Q5 documented risk.
# ────────────────────────────────────────────────────────────────────────

if [[ "${MODE}" != "dry-run" ]]; then
  # TODO(W6-7): @ifos/bullhorn createNote with body=vault_artefact_contents +
  # entityType+entityId from Step 4; on success emit action row; on failure:
  # ESC_BULLHORN_WRITE_FAIL + best-effort rollback Step 8 changes.
  hh_decision_action "bullhorn_note_append_summary" "call:${CALL_ID_ARG:-STUB}" "stub-hash" \
    "entity_type:STUB; bullhorn_id:STUB; vault_path:${TACIT_NOTE_PATH}"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Session close + SLA metric
# Reference: agent.md §4 Step 10 + master brief §8.2 line 597 (10-min product
# promise) + catalogue ESC_SCRIBE_SLA_MISS thresholds (30-min summary-render OR
# 1h note-attach alerting). Sub-5-min = info; 5-10 min = 10-min miss tracked in
# Gate B aggregation (no ESC fire); 10-30 min = same (still no ESC fire — the
# catalogue alerting is 30-min+).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): compute elapsed_seconds from session_start trigger row → now();
# fire ESC_SCRIBE_SLA_MISS per catalogue thresholds (>30min summary_render OR
# >1h note_attach; both warn-tier; operator_chat_id; aggregated to Gate B).
hh_decision_action "scribe_run_complete" "call:${CALL_ID_ARG:-NA}" "stub-hash" \
  "mode:${MODE}; elapsed_seconds:STUB; sla_class:STUB"

exit 0
