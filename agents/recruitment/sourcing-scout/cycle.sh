#!/usr/bin/env bash
# Sourcing Scout agent — cycle.sh (11-step per-brief orchestration; W5 Day-33 SKELETON)
#
# Status: Proposed (W5 Day-33 SKELETON; W9 build slice replaces stubs with
#         full package wiring per agent.md §4).
# Reading order: agent.md §1 (output contract) + §3 (Markdown report shape) +
#         §4 (this workflow's 11 steps) + §5 (Gate A + Gate B) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
# produces output OR takes action MUST call hh_decision_* from
# agents/_shared/hook-helpers.sh.
#
# IMPORTANT — v1.0 LinkedIn caveat (see sourcing-scout/agent.md §"v1.0 readiness
# caveat — LinkedIn deep-data vendor" lines 6-8): Proxycurl was shut down 2025
# following the LinkedIn lawsuit against Nubela; NinjaPear successor doesn't
# carry LinkedIn data. v1.0 Sourcing Scout operates against THREE active
# sources (Bullhorn passive-match + Reed + CV-Library) NOT four. Step 4
# (LinkedIn search) is a NO-OP at v1.0 — emits an explicit no-op audit row
# per the Janitor Step 7 pattern so the day-30 report can reference
# "LinkedIn deep-data: v1.1+ scope" rather than silent skip. v1.1+ vendor
# selection deferred to W8-9 (candidates: Lix / Phantombuster / Apify /
# Sales Navigator). agent.md §1 output contract still references "FOUR sources"
# verbatim per the pre-pivot RATIFIED state; Reading-discipline note on
# agent.md documents the SKELETON-vs-CONTRACT delta.
#
# IMPORTANT — Reed + CV-Library MCP packages (Phase 8 sibling commits):
# @ifos/reed + @ifos/cv-library don't exist yet. tools.yaml declares the
# capabilities with TODO(W6+) markers; cycle.sh Steps 5+6 emit STUB audit
# rows referencing the queried-sources count without making real wire calls.
# W6 commercial signups + W9 build slice wires the actual calls.
#
# Invocation modes (per agent.md §2):
#   mode=brain-ui      — internal API trigger from Brain UI "Source candidates"
#                        button (v1.0 primary; takes --brief-id)
#   mode=telegram      — @ifos_bot scout <brief-id-or-slug>; takes --brief-id
#                        OR --description for free-text
#   mode=cli           — ifosctl sourcing-scout source --tenant <slug>
#                        --brief-id <id>; debugging path (default if no mode set)
#   mode=webhook       — Bullhorn "new brief created" auto-source DEFERRED to
#                        v1.1+ (blocked on auto_source_on_brief_create config
#                        key landing in a v0.5 supplement; v0.4 did NOT add it)
#
# Package dependencies (W5 Day-28/29 scaffolded; v0.1.0 fixture-first):
#   @ifos/bullhorn        — Bullhorn ATS read-only (passive-match search; v1.0)
#   @ifos/reed            — Reed.co.uk recruiter API (TODO Phase 8 — scaffold pending)
#   @ifos/cv-library      — CV-Library API (TODO Phase 8 — scaffold pending)
#   @ifos/telegram        — operator notification (Step 11)
#
# Output contract per agent.md §1 (READ THAT FIRST). One output per brief:
#   1. Markdown report → /vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO>.md
#      with ranked 5-15 candidates + per-candidate ≥50-word rationale +
#      source breakdown + diagnostic exception list
#
# Per agent.md §5 Gate A: ≥5 AND ≤15 candidates returned; each has working
# contact method; each rationale ≥50 words AND voice classifier ≥0.75; no
# DNC list match; no PII outside firm boundary. Below threshold →
# ESC_AGENT_OUTPUT_SHAPE (warn) OR ESC_PII_LEAKAGE_RISK (blocking).
#
# v0.4 supplement (LANDED + LIVE on VPS 2026-06-03) made bullhorn_corporation_id
# schema-clean — context.sh resolves it at Step 0. blocked_recipients is
# v0.3-allowlisted (LIVE on VPS) — Step 8 DNC filter SELECTs from
# tenant_adapters.config without env-var fallback at v0.3+.

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight: hydrate context + resolve _shared/ helpers
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'sourcing-scout/cycle.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'sourcing-scout/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
  exit 2
fi
: "${CTX_AGENT_NAME:=sourcing-scout}"

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

# Mode dispatch (default = cli; brain-ui/telegram pass --mode + --brief-id)
MODE="cli"
BRIEF_ID_ARG=""
DESCRIPTION_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)        MODE="${2:-}"; shift 2 ;;
    --brief-id)    BRIEF_ID_ARG="${2:-}"; shift 2 ;;
    --description) DESCRIPTION_ARG="${2:-}"; shift 2 ;;
    --tenant)      shift 2 ;;  # tenant set via CTX_TENANT_SLUG by bus
    *)             shift ;;
  esac
done
export BRIEF_ID_ARG DESCRIPTION_ARG

# Validate mode + brief-input args
case "${MODE}" in
  brain-ui|telegram|cli)
    if [[ -z "${BRIEF_ID_ARG}" && -z "${DESCRIPTION_ARG}" ]]; then
      printf 'cycle.sh: either --brief-id or --description required\n' >&2
      exit 2
    fi ;;
  webhook)
    printf 'cycle.sh: webhook mode DEFERRED to v1.1+ (auto_source_on_brief_create config not yet allowlisted)\n' >&2
    exit 2 ;;
  *) printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
esac

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Session start
# ────────────────────────────────────────────────────────────────────────

BRIEF_SLUG="${BRIEF_ID_ARG:-${DESCRIPTION_ARG:0:30}}"
hh_decision_trigger "session_start" "sourcing-scout mode=${MODE} brief=${BRIEF_SLUG}"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Brief ingestion (per agent.md §4 Step 1)
# If brief_id: @ifos/bullhorn getBrief (TODO — Brief entity reads not yet
# in @ifos/bullhorn v0.1.0 exports; W9 build slice adds OR uses getCandidate
# brief-context endpoint). If free-text: LLM parse → key dimensions.
# ESC_BRIEF_AMBIGUITY if <3 key dimensions extracted.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): if BRIEF_ID_ARG: bullhorn.getBrief → fields; if DESCRIPTION_ARG:
# LLM parse → role / location / sector / seniority / day-rate / must-haves /
# nice-to-haves. <3 key dimensions → ESC_BRIEF_AMBIGUITY (per agent.md §6;
# warn-tier; operator_chat_id) + validate_gate_a_fail + skip.
hh_decision_output "brief_ingested" "brief:${BRIEF_SLUG}" \
  "input_type:${BRIEF_ID_ARG:+brief_id}${DESCRIPTION_ARG:+free_text}; key_dims_extracted:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Multi-source auth refresh
# Reference: agent.md §4 Step 2; per-source failure fires catalogue-specified
# ESC code with degraded-mode behavior. v1.0 sources: Bullhorn (read-only) +
# Reed + CV-Library. LinkedIn = NO-OP (Step 4); no auth refresh needed.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): @ifos/bullhorn refreshTokens(config) — ESC_BULLHORN_AUTH on fail;
# Sourcing-Scout-specific degraded mode = skip Bullhorn source + continue
# with Reed + CV-Library (per agent.md §4 Step 2 catalogue interpretation).
# TODO(W9): @ifos/reed refreshTokens (TODO Phase 8 — package scaffold pending);
# ESC_REED_AUTH on fail; degraded mode = cached Reed search only.
# TODO(W9): @ifos/cv-library refreshTokens (TODO Phase 8); ESC_CVLIBRARY_AUTH
# on fail; degraded mode = cached CV-Library search only.
# TODO(W9): if multiple sources in degraded mode AND combined live can't
# produce ≥5 candidates → ESC_AGENT_OUTPUT_SHAPE + partial report + Gate A
# floor violated (operator review).
hh_decision_output "auth_refresh_complete" "tenant:${CTX_TENANT_SLUG}" \
  "sources_active:3; degraded:none; linkedin_status:v1.0_no_op"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — Bullhorn passive-match query
# Reference: agent.md §4 Step 3; @ifos/bullhorn listCandidates with filter
# status='active' AND date_last_modified_at < now() - interval '90 days'
# ("passive" is derived; not a vertical-schema enum value). Up to 30 fetched.
# ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn').
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): @ifos/bullhorn listCandidates({query: 'status:active AND
# dateLastModified:<now-90d>' + brief_key_dimensions}); store up to 30 hits.
hh_decision_output "bullhorn_passive_query" "brief:${BRIEF_SLUG}" \
  "candidates_returned:STUB; query_filter:'status:active+modified<90d'"

# ────────────────────────────────────────────────────────────────────────
# Step 4 — LinkedIn search — NO-OP at v1.0 per Proxycurl shutdown caveat
# Reference: agent.md §"v1.0 readiness caveat" lines 6-8; v1.1+ vendor
# selection deferred to W8-9 (Lix / Phantombuster / Apify / Sales Navigator).
# Explicit no-op audit row per Janitor Step 7 pattern so day-30/report
# diagnostics reference "v1.1+ scope" rather than silent skip.
# ────────────────────────────────────────────────────────────────────────

# NO-OP at v1.0; emit explicit no-op audit row.
hh_decision_output "linkedin_search_skipped" "brief:${BRIEF_SLUG}" \
  "reason:v1.0_caveat_proxycurl_shutdown; vendor_selection:W8-9_deferred; alternatives:lix|phantombuster|apify|sales_navigator"

# ────────────────────────────────────────────────────────────────────────
# Step 5 — Reed query
# Reference: agent.md §4 Step 5; @ifos/reed search (TODO Phase 8 — package
# scaffold pending). Up to 30 candidates. ESC_REED_AUTH on auth fail;
# ESC_RATE_LIMIT_HIT on quota (payload.upstream='reed').
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): @ifos/reed search({query: brief_dimensions, location, salary_band});
# requires Phase 8 @ifos/reed scaffold + W6+ Reed commercial signup creds.
hh_decision_output "reed_query" "brief:${BRIEF_SLUG}" \
  "candidates_returned:STUB; package_status:scaffold_pending_phase_8"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — CV-Library query
# Reference: agent.md §4 Step 6; @ifos/cv-library search (TODO Phase 8 —
# package scaffold pending). ESC_CVLIBRARY_AUTH on auth fail;
# ESC_RATE_LIMIT_HIT on quota (payload.upstream='cv-library').
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): @ifos/cv-library search({query, location, salary_band});
# requires Phase 8 @ifos/cv-library scaffold + W6+ CV-Library commercial signup.
hh_decision_output "cvlibrary_query" "brief:${BRIEF_SLUG}" \
  "candidates_returned:STUB; package_status:scaffold_pending_phase_8"

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Aggregate + dedupe across sources
# Reference: agent.md §4 Step 7; merge all sources; dedupe by (name+email) OR
# (name+phone) OR (LinkedIn URL) using same fuzzy matcher as Janitor
# (confidence ≥0.85); annotate provenance.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): merge candidate sets from Steps 3 + 5 + 6 (Step 4 NO-OP);
# dedupe per Janitor's fuzzy-matcher pattern (name×0.3 + email×0.4 + phone×0.2
# + linkedin×0.1; threshold 0.85); annotate each row with source provenance
# (e.g., "from Bullhorn + Reed" if found in both).
hh_decision_output "aggregate_dedupe" "brief:${BRIEF_SLUG}" \
  "pre_dedupe:STUB; post_dedupe:STUB; cross_source_matches:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 8 — DNC filter (pre-outbound sourcing filter; NOT outbound refusal)
# Reference: agent.md §4 Step 8; load tenant DNC list from
# tenant_adapters.config.blocked_recipients (v0.3-allowlisted; LIVE on VPS
# post v0.4 migration commit a1bbcf6). Remove matching candidates.
# Per catalogue §2.10: ESC_DNC_FILTER_HIT is reserved for OUTBOUND send
# refusal — Sourcing Scout drops at sourcing time (no ESC fire); log to
# exception list in §3 output. W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): SELECT config->'blocked_recipients' FROM tenant_adapters
# WHERE tenant_slug=$CTX_TENANT_SLUG (v0.3-allowlisted; LIVE on VPS;
# array<string> per v0.3 supplement §4 validator). For each candidate,
# check email/phone against blocked list; remove matches; log dropped to
# exception list (per §3 output Diagnostic section).
hh_decision_output "dnc_filter" "brief:${BRIEF_SLUG}" \
  "dropped:STUB; kept:STUB; source:tenant_adapters.config.blocked_recipients"

# ────────────────────────────────────────────────────────────────────────
# Step 9 — LLM ranking + per-candidate rationale generation
# Reference: agent.md §4 Step 9; for top 15 by source-aggregated confidence,
# generate rationale ≥50 words. Voice classifier ≥0.75 per agent.md §7;
# ESC_VOICE_DRIFT if <0.75 after 3 retries → drop candidate from final list
# + flag in exception list.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): per candidate: LLM prompt = (brief context + candidate profile +
# voice corpus + tone rules); generate ≥50-word rationale; score voice
# classifier; if <0.75 after 3 retries → drop + ESC_VOICE_DRIFT (warn;
# operator_chat_id) + log to exception list. Per-candidate audit row:
# hh_decision_output("candidate_proposed", "candidate:<id>", "source:<src>;
# confidence:<N>; voice_score:<N>; included:<bool>; drop_reason:<reason_if_excluded>")
hh_decision_output "rationale_generation" "brief:${BRIEF_SLUG}" \
  "candidates_ranked:STUB; voice_pass:STUB; voice_drift_drops:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 10 — Output assembly + Gate A validation
# Reference: agent.md §4 Step 10 + §5 Gate A; ensure 5-15 candidates;
# each has working contact method; each rationale ≥50 words. Failure →
# validate_gate_a_fail + ESC_AGENT_OUTPUT_SHAPE + partial draft to /tmp +
# exit 1 BEFORE the scout_report audit row.
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): run validate.sh against the assembled proposal; on PASS:
# write Markdown report per §3 to vault path; on FAIL: partial draft to
# /tmp + hh_decision_action validate_gate_a_fail + exit 1.
REPORT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/sourcing-scout-reports/${BRIEF_SLUG}-$(date -u +%Y-%m-%d).md"
mkdir -p "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
printf '# Sourcing Scout — STUB\n\nTODO(W9): full §3 output shape with 5-15 ranked candidates.\n' > "${REPORT_PATH}" 2>/dev/null || true
hh_decision_output "scout_report" "${REPORT_PATH}" \
  "candidates_final:STUB; sources_contributing:STUB; gate_a_state:STUB"

# ────────────────────────────────────────────────────────────────────────
# Step 11 — Session close + operator notification
# Reference: agent.md §4 Step 11; per-invocation-source notification
# (Brain UI in-app; Telegram reply with report path; webhook bus event).
# ────────────────────────────────────────────────────────────────────────

# TODO(W9): @ifos/telegram operator_notify_telegram (green tier; REGISTERED)
# OR Brain UI internal API; reads CTX_OPERATOR_TELEGRAM_CHAT_ID from
# context.sh (v0.4-allowlisted; LIVE on VPS).
hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" "stub-hash" \
  "mode:${MODE}; tenant:${CTX_TENANT_SLUG}; candidates_final:STUB; sources_used:STUB; report_path:${REPORT_PATH}"

exit 0
