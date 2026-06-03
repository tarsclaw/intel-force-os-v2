#!/usr/bin/env bash
# Janitor agent — cycle.sh (12-step nightly cron orchestration; W5 Day-31 SKELETON)
#
# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice replaces stubs with
#         full package wiring per agent.md §4).
# Reading order: agent.md §1 (output contract) + §3 (2 outputs: day-30 report
#         + Bullhorn yellow-tier writes) + §4 (this workflow's 12 steps) +
#         §5 (Gate A + Gate B) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# Invocation modes (per agent.md §2):
#   mode=full-cleanup   — nightly cron 02:00 UTC: all 12 steps (default)
#   mode=incremental    — cron catch-up: Steps 1-4 + 8-9 + 12 (skip enrichment +
#                         day-30 report assembly; the next full-cleanup picks them up)
#   mode=report-only    — Steps 1 + 10 + 12 only (regenerate day-30 report without
#                         writes; used post-incident per agent.md §2 manual trigger)
#   mode=dry-run        — Steps 1-8 + 10 + 12 only (no Bullhorn writes; report
#                         shows what WOULD have been written)
#
# Package dependencies (W5 Day-28 + W4 carry-over; v0.1.0 fixture-first):
#   @ifos/bullhorn        — Bullhorn ATS (R+W on Candidate / Contact / Client /
#                           ClientCorporation; W only on Note)
#   @ifos/companies-house — client enrichment (CRN lookup → industry + size)
#
# Output contract per agent.md §1 (READ THAT FIRST). Two outputs:
#   1. Day-30 Markdown report → /vault/<tenant>/janitor-reports/day-30-<ISO>.md
#   2. Yellow-tier Bullhorn writes (3 action_types REGISTERED in autosend-policy.yaml):
#      bullhorn_candidate_dedupe + bullhorn_field_backfill + bullhorn_note_attach
#
# Per agent.md §5 Gate A: hard-fail any merge proposal with confidence <0.85;
# review-band pairs (0.70–0.85 OR ≥0.85 with recent activity) held for synchronous
# Telegram approval via ESC_DUPLICATE_DETECTED. v0.4 supplement (landed 2026-06-03;
# commit a1bbcf6 + LIVE on VPS) made bullhorn_corporation_id schema-clean — Step 0
# can resolve it from tenant_adapters.config without env-var fallback at v0.4+.

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: hydrate context + resolve _shared/ helpers
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'janitor/cycle.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'janitor/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=janitor}"

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

# Mode dispatch (default = full-cleanup; cron passes --mode full-cleanup at 02:00 UTC)
MODE="full-cleanup"
TENANT_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)    MODE="${2:-}"; shift 2 ;;
    --tenant)  TENANT_ARG="${2:-}"; shift 2 ;;
    --dry-run) MODE="dry-run"; shift ;;
    --report-only) MODE="report-only"; shift ;;
    *)         shift ;;
  esac
done
# TENANT_ARG: parsed for manual-trigger consistency; cycle.sh already requires
# CTX_TENANT_SLUG to be set by the bus (per ADR-003 invocation contract).
# When provided via --tenant, validates against CTX_TENANT_SLUG to surface
# mismatched-invocation early. Wired at W6-7 build slice.
export TENANT_ARG

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start
# ────────────────────────────────────────────────────────────────────────

hh_decision_trigger "session_start" "janitor mode=${MODE}"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Bullhorn auth refresh
# Reference: agent.md §4 Step 1; emits ESC_BULLHORN_AUTH on failure after 2 retries
# (per agent.md §6 blocking severity; operator + ifos_oncall routing).
# W6-7 wires: @ifos/bullhorn refreshTokens (two-step Step A OAuth + Step B
#             REST login per @ifos/bullhorn src/auth.ts; per-corporation_id
#             Promise dedup + 401-force-refresh per cluster F R4 lesson).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): replace this STUB with actual @ifos/bullhorn refreshTokens call.
# Skeleton emits the audit row shape that the full implementation will preserve.
hh_decision_output "bullhorn_auth_refresh" "tenant:${CTX_TENANT_SLUG}" \
  "corporation_id:${CTX_BULLHORN_CORPORATION_ID:-STUB}; bullhorn_token_state:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Bullhorn entity scan (read-only)
# Reference: agent.md §4 Step 2; enumerate candidates + contractors + clients +
# contacts + placements + opportunities modified since janitor_last_run
# (tenant_adapters.config.janitor_last_run; v0.3-allowlisted; LIVE on VPS).
# ESC_RATE_LIMIT_HIT on 429 (60s backoff per catalogue §2.5).
# ────────────────────────────────────────────────────────────────────────

# Mode dispatch — full-cleanup runs all steps; incremental + dry-run skip enrichment;
# report-only skips scan entirely (uses prior run's data from decision_log).
case "${MODE}" in
  full-cleanup) STEPS_TO_RUN="2 3 4 5 6 7 8 9 10 11 12" ;;
  incremental)  STEPS_TO_RUN="2 3 4 8 9 12" ;;
  dry-run)      STEPS_TO_RUN="2 3 4 5 6 7 8 10 12" ;;  # No Step 9 (writes); No Step 11
  report-only)  STEPS_TO_RUN="10 12" ;;
  *)            printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
esac
hh_decision_output "mode_routed" "tenant:${CTX_TENANT_SLUG}" \
  "mode:${MODE}; steps_planned:${STEPS_TO_RUN}"

if [[ "${STEPS_TO_RUN}" == *2* ]]; then
  # TODO(W6-7): @ifos/bullhorn listCandidates/listContacts/listClients (per
  # @ifos/bullhorn capability exports) since janitor_last_run; collect modified-IDs.
  hh_decision_output "bullhorn_entity_scan" "tenant:${CTX_TENANT_SLUG}" \
    "scanned:STUB; since:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Dedup pass: candidate entity
# Reference: agent.md §4 Step 3; fuzzy-match on (name, email, phone, linkedin_url);
# confidence = name×0.3 + email×0.4 + phone×0.2 + linkedin×0.1.
# Discard <0.85 confidence; discard pairs with Bullhorn activity in last 90d.
# Sub-0.85 silently dropped (no ESC). Per agent.md §5 + ULTRAPLAN A2 line 510.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *3* ]]; then
  # TODO(W6-7): fuzzy-matcher; output proposed-merge list (in-memory intermediate);
  # hh_decision_action emitted at Step 9 when each merge actually writes.
  # Review-band pairs (0.70-0.85 OR ≥0.85 with recent activity) → ESC_DUPLICATE_DETECTED
  # SUCCESS-path Telegram approval gate (per agent.md §5 + catalogue §2.5).
  hh_decision_output "dedup_candidate_pass" "tenant:${CTX_TENANT_SLUG}" \
    "auto_merges:STUB; review_band:STUB; dropped:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 4 — Dedup pass: contractor entity (same algorithm; separate entity_type
# per vertical-schema.yaml §1 + Q1 Day-6 resolution).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *4* ]]; then
  # TODO(W6-7): same fuzzy-matcher applied to contractor entity type.
  hh_decision_output "dedup_contractor_pass" "tenant:${CTX_TENANT_SLUG}" \
    "auto_merges:STUB; review_band:STUB; dropped:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Field completeness audit (canonical field names per vertical-schema.yaml)
# Reference: agent.md §4 Step 5; identify missing critical fields:
# candidate.location, client.industry, client.size_employees,
# contractor.day_rate_min/max, brief.salary_min/max.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *5* ]]; then
  # TODO(W6-7): SELECT entities WHERE data missing canonical fields;
  # batch enrichment calls for Step 6.
  hh_decision_output "field_completeness_audit" "tenant:${CTX_TENANT_SLUG}" \
    "missing_fields_total:STUB; enrichable_via_companies_house:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Companies House enrichment (clients only)
# Reference: agent.md §4 Step 6; @ifos/companies-house search → CRN → profile →
# fill client.industry + client.companies_house_number.
# 7-day cache per tools.yaml; ESC_RATE_LIMIT_HIT on 429.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *6* ]]; then
  # TODO(W6-7): for each client with missing CRN/industry:
  # @ifos/companies-house search(client.name) → CRN → profile → field deltas.
  hh_decision_output "companies_house_enrichment" "tenant:${CTX_TENANT_SLUG}" \
    "lookups:STUB; backfilled:STUB; cache_hits:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 7 — LinkedIn enrichment (v1.0 NO-OP per agent.md §4 Step 7)
# v1.0 caveat: Proxycurl shut down 2025 (LinkedIn lawsuit; nubela.co/blog/
# goodbye-proxycurl/); NinjaPear successor doesn't carry LinkedIn data.
# v1.1+ vendor selection deferred to W8-9 (Lix / Phantombuster / Apify /
# Sales Navigator per .agents/current-priorities.md action board item 8).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *7* ]]; then
  # NO-OP at v1.0; emit explicit no-op audit row so the day-30 report can
  # reference "LinkedIn enrichment: v1.1+ scope" rather than silent skip.
  hh_decision_output "linkedin_enrichment_skipped" "tenant:${CTX_TENANT_SLUG}" \
    "reason:v1.0_caveat_proxycurl_shutdown; vendor_selection:W8-9_deferred"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 8 — Tacit-note harvest (from recent_edit; v0.3 supplement §2a grants Janitor R)
# Reference: agent.md §4 Step 8; SELECT FROM recent_edit WHERE
# resolution='approved_after_edit' AND resolved_at > now() - interval '30 days'
# AND tenant_slug=$tenant. Group by target_entity_type; generate voice-classified
# narrative per group; ESC_VOICE_DRIFT if classifier <0.75 after retries.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *8* ]]; then
  # TODO(W6-7): SELECT + group + LLM narrative generation per group +
  # hh_load_tone_rules('janitor') voice classification gate.
  hh_decision_output "tacit_note_harvest" "tenant:${CTX_TENANT_SLUG}" \
    "harvested:STUB; groups:STUB; narrative_drafts:STUB; voice_score_avg:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 9 — Bullhorn write batch (yellow tier — 3 action_types per agent.md §3 Output 2)
# Reference: agent.md §4 Step 9; emit hh_decision_action with tier='yellow'
# for each merge/backfill/note; atomic per-write transaction. ESC_BULLHORN_WRITE_FAIL
# on 4xx (skip + continue) OR 5xx (retry once with 30s backoff). NEVER fires in
# dry-run mode (STEPS_TO_RUN excludes 9 for dry-run).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *9* ]]; then
  # TODO(W6-7): per merge → @ifos/bullhorn updateCandidate (or per-contractor
  # equivalent); per backfill → @ifos/bullhorn updateCandidate/updateClient;
  # per note → @ifos/bullhorn createNote. Each emits hh_decision_action with
  # action_type per autosend-policy.yaml (bullhorn_candidate_dedupe yellow rate=10;
  # bullhorn_field_backfill yellow rate=10; bullhorn_note_attach yellow rate=20).
  # Pre-write validate.sh runs as Gate A per agent.md §5.
  hh_decision_output "bullhorn_write_batch" "tenant:${CTX_TENANT_SLUG}" \
    "merges_written:STUB; backfills_written:STUB; notes_attached:STUB; failures:STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Day-30 report assembly
# Reference: agent.md §4 Step 10 + §3 Output 1 (8-section Markdown report).
# SELECT FROM decision_log WHERE agent_name='janitor' AND created_at > now() -
# interval '30 days'. Compute Gate B metric (dedup ≥15% AND completeness ≥10%).
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *10* ]]; then
  # TODO(W6-7): SELECT + group + tally + compute Gate B + assemble 8-section
  # Markdown report; write to /vault/<tenant>/janitor-reports/day-30-<ISO>.md
  REPORT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/janitor-reports/day-30-$(date -u +%Y-%m-%d).md"
  mkdir -p "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
  printf '# Janitor day-30 report — STUB\n\nTODO(W6-7): full §3 Output 1 8-section report.\n' > "${REPORT_PATH}" 2>/dev/null || true
  hh_decision_output "day_30_report" "${REPORT_PATH}" \
    "gate_b_dedup_pct:STUB; gate_b_completeness_pct:STUB; sections:1_of_8_STUB"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 11 — Operator notification (Telegram)
# Reference: agent.md §4 Step 11; green-tier if Gate B met; yellow-tier
# (+200-char executive summary) if Gate B missed. Single-threshold misses do
# NOT fire ESC_GATE_B_MISS — only BOTH thresholds missed for 3 consecutive
# runs per agent.md §5 ESC_GATE_B_MISS row.
# ────────────────────────────────────────────────────────────────────────

if [[ "${STEPS_TO_RUN}" == *11* ]]; then
  # TODO(W6-7): @ifos/telegram operator_notify_telegram (green tier; REGISTERED
  # in autosend-policy.yaml). Read CTX_OPERATOR_TELEGRAM_CHAT_ID from context.sh
  # (now v0.4-allowlisted via operator_telegram_chat_id; LIVE on VPS).
  hh_decision_action "operator_notify_telegram" "tenant:${CTX_TENANT_SLUG}" "stub-hash" \
    "gate_b_state:STUB; chars:STUB; channel:telegram"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 12 — Session close
# tenant_adapters.config.janitor_last_run = now() (v0.3-allowlisted).
# Exit 0 (or 1 if BOTH Gate B thresholds missed for 3 consecutive runs per §5).
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): UPDATE tenant_adapters SET config = jsonb_set(config, '{janitor_last_run}', '"<ISO>"')
#             WHERE tenant_slug=$CTX_TENANT_SLUG;
# TODO(W6-7): query 3-consecutive-run Gate B miss state from decision_log
#             history; on triple-miss → ESC_GATE_B_MISS warn + exit 1.

if [[ "${STEPS_TO_RUN}" == *11* ]]; then NOTIFIED="true"; else NOTIFIED="false"; fi
hh_decision_action "janitor_run_complete" "session:${CTX_TENANT_SLUG}" "stub-hash" \
  "mode:${MODE}; corporation_id:${CTX_BULLHORN_CORPORATION_ID:-STUB}; notified:${NOTIFIED}"

exit 0
