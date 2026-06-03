#!/usr/bin/env bash
# shellcheck disable=SC2329
# (_fail + _warn are not invoked in the W5 Day-32 skeleton — TODO(W6-7)
#  blocks invoke them when the per-check impl lands. Keeping them defined
#  so the skeleton matches the final shape + the build-slice author can fill
#  the TODOs without re-declaring helpers.)
#
# Scribe agent — validate.sh (Gate A enforcement; W5 Day-32 SKELETON)
#
# Status: Proposed (W5 Day-32 SKELETON; W6 build slice completes the impl).
# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
# hard-fail gate that runs BETWEEN cycle.sh Step 7 (field validation) and
# Step 8 (Bullhorn write). If any check fails, validate.sh exits non-zero +
# emits an ESC_* row to decision_log; the meeting's Bullhorn writes are
# skipped; cycle.sh continues to the next meeting (poll-sweep mode) or exits
# with the gate-fail signal (replay mode).
#
# Invocation contract:
#   bash validate.sh <extraction_proposal_json>
#
# Inputs:
#   - $1: path to JSON describing the proposed Bullhorn writes for ONE call.
#         Shape:
#         {
#           "call_id": "<granola_meeting_id>",
#           "entity_type": "candidate" | "contact" | "brief" | "placement" | "opportunity",
#           "bullhorn_id": <int>,
#           "fields_extracted": [
#             {"field_name": "...", "value": "...", "confidence": <0.0-1.0>}
#           ],
#           "tacit_note": {
#             "vault_path": "/vault/<tenant>/scribe-notes/<call_id>-<ISO>.md",
#             "body_sha256": "...",
#             "voice_score": <0.0-1.0>,
#             "narrative_word_count": <int>,
#             "narrative_body_preview": "..."  // first 500 chars for PII regex pass
#           }
#         }
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
#          CTX_BULLHORN_CORPORATION_ID, CTX_GRANOLA_WORKSPACE_ID,
#          CTX_FIRM_DOMAIN_WHITELIST (comma-separated; for G6 PII check)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to Steps 8 + 9 writes
#   1  At least one check failed; ESC_* row emitted; cycle.sh skips writes
#   2  validate.sh invocation error (bad args, missing file, etc.)
#
# Checks (per agent.md §5 Gate A):
#   G1 — Bullhorn auth refresh succeeded in Step 2 (no stale-token writes)
#   G2 — ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN
#         A3 line 524 verbatim)
#   G3 — Tacit-note voice classifier ≥0.75 (per agent.md §3 line 111;
#         persistent failure after 3 retries = hard Gate A failure)
#   G4 — Field names exist in target entity per vertical-schema.yaml
#   G5 — Per-field type + range validation passes
#   G6 — No PII outside firm boundary in tacit-note narrative (regex pass)
#   G7 — Tacit-note word count ≤800 (agent.md §3 line 110 cap)

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  printf 'scribe/validate.sh: usage: validate.sh <extraction_proposal_json>\n' >&2
  exit 2
fi

readonly PROPOSAL="$1"

if [[ ! -f "${PROPOSAL}" ]]; then
  printf 'validate.sh: proposal not found at %s\n' "${PROPOSAL}" >&2
  exit 2
fi

if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi

# Resolve _shared/ helpers (4-candidate fallback; matches sibling agents
# per smoke-hotfix commit d7d52c5).
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
  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
  exit 2
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# Track failures + warnings across all checks (collect all before exit for richer audit)
declare -a FAILURES=()
declare -a WARNINGS=()

_fail() {
  FAILURES+=("$1")
  printf '  ✗ %s\n' "$1" >&2
}
_warn() {
  WARNINGS+=("$1")
  printf '  ! %s\n' "$1" >&2
}
_ok() {
  printf '  ✓ %s\n' "$1"
}

# Thresholds (per ULTRAPLAN A3 line 524 + agent.md §3 line 111)
readonly FIELD_CONFIDENCE_THRESHOLD="0.6"
readonly MIN_FIELDS_REQUIRED="3"
readonly VOICE_SCORE_THRESHOLD="0.75"
readonly TACIT_NOTE_WORD_CAP="800"

# ────────────────────────────────────────────────────────────────────────
# G1 — Bullhorn auth refresh succeeded in cycle.sh Step 2 (sanity check)
# Sanity check that cycle.sh Step 2 emitted a fresh bullhorn_auth_refresh row.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): SELECT FROM decision_log WHERE output_type='bullhorn_auth_refresh'
# AND tenant_slug=$CTX_TENANT_SLUG AND created_at > now() - interval '10 minutes';
# if no row OR payload.bullhorn_token_state='failed' → _fail + ESC_BULLHORN_AUTH
# (blocking; operator + ifos_oncall per catalogue routing).
_ok "G1: Bullhorn auth refresh fresh — SKELETON (W6 wires the decision_log re-query)"

# ────────────────────────────────────────────────────────────────────────
# G2 — ≥3 structured-field extractions with confidence ≥0.6
# Per ULTRAPLAN A3 line 524 verbatim. Below threshold → ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
# warn + transcript stays in /tmp; no Bullhorn write.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): jq -r '.fields_extracted | map(select(.confidence >= 0.6)) | length' "$PROPOSAL"
# if count < 3: _fail + ESC_FIELD_EXTRACTION_LOW_CONFIDENCE warn-tier (per
# catalogue routing operator_chat_id) via hh_decision_action validate_gate_a_fail.
_ok "G2: ≥${MIN_FIELDS_REQUIRED} fields with confidence ≥${FIELD_CONFIDENCE_THRESHOLD} — SKELETON (W6 wires jq parse + filter)"

# ────────────────────────────────────────────────────────────────────────
# G3 — Tacit-note voice classifier ≥0.75
# Per agent.md §3 line 111: persistent classifier failure (after 3 retries) is
# a hard Gate A failure. Note NOT attached to Bullhorn (Step 9 skipped); vault
# draft flagged "needs consultant review" for manual handling.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): jq -r '.tacit_note.voice_score' "$PROPOSAL" → compare to 0.75;
# if < threshold: _fail + ESC_VOICE_DRIFT warn-tier (catalogue lines 120-125;
# operator_chat_id) via hh_decision_action validate_gate_a_fail; flag vault
# draft with "needs consultant review" marker (cycle.sh Step 6 already wrote
# the vault file; we add a frontmatter flag here).
_ok "G3: tacit-note voice classifier ≥${VOICE_SCORE_THRESHOLD} — SKELETON (W6 wires)"

# ────────────────────────────────────────────────────────────────────────
# G4 — Field names exist in target entity per vertical-schema.yaml
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): jq -r '.fields_extracted[].field_name' "$PROPOSAL" → for each field
# name, verify against vertical-schema.yaml entity_field_additions[entity_type]
# OR the v0.3 supplement allowlist. Drop invalid; if remaining count <3:
# _fail + ESC_SCHEMA_VIOLATION (catalogue line 163; warn; operator_chat_id) via
# hh_decision_action validate_gate_a_fail.
_ok "G4: field names exist in vertical-schema — SKELETON (W6 wires schema lookup)"

# ────────────────────────────────────────────────────────────────────────
# G5 — Per-field type + range validation passes
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): for each field, parse the schema-declared type (string/integer/
# number/boolean/enum/timestamp/date); check the extracted value matches;
# check range constraints (enum membership; min/max for numerics; ISO-8601
# for dates/timestamps); on any fail: _fail + ESC_SCHEMA_VIOLATION (same as G4).
_ok "G5: per-field type + range validation — SKELETON (W6 wires per-type checkers)"

# ────────────────────────────────────────────────────────────────────────
# G6 — No PII outside firm boundary in tacit-note narrative (regex pass)
# Per agent.md §7 tone rules + §6 ESC_PII_LEAKAGE_RISK blocking severity.
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): jq -r '.tacit_note.narrative_body_preview' "$PROPOSAL" → grep
# for email patterns NOT matching CTX_FIRM_DOMAIN_WHITELIST; also pattern-match
# for full names not in known-participants set; if any hit: _fail +
# ESC_PII_LEAKAGE_RISK blocking-tier (operator + ifos_oncall_chat_id routing);
# meeting's Bullhorn writes blocked; vault draft held for consultant review.
_ok "G6: no PII outside firm boundary — SKELETON (W6 wires firm-domain whitelist + regex pass)"

# ────────────────────────────────────────────────────────────────────────
# G7 — Tacit-note word count ≤800 (agent.md §3 line 110 cap)
# ────────────────────────────────────────────────────────────────────────

# TODO(W6-7): jq -r '.tacit_note.narrative_word_count' "$PROPOSAL" → compare to
# 800; if >: _fail + ESC_AGENT_OUTPUT_SHAPE (output-shape constraint per
# catalogue line 184; warn; operator_chat_id). Cap exists to keep notes
# scannable for consultants; long-form analysis belongs in vault not Bullhorn.
_ok "G7: tacit-note word count ≤${TACIT_NOTE_WORD_CAP} — SKELETON (W6 wires word count check)"

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nScribe validate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # TODO(W6-7): per-failure routing — different ESC code per failure class
  # (G1 → ESC_BULLHORN_AUTH blocking; G2 → ESC_FIELD_EXTRACTION_LOW_CONFIDENCE warn;
  #  G3 → ESC_VOICE_DRIFT warn; G4 + G5 → ESC_SCHEMA_VIOLATION warn;
  #  G6 → ESC_PII_LEAKAGE_RISK blocking; G7 → ESC_AGENT_OUTPUT_SHAPE warn)
  # hh_decision_action "validate_gate_a_fail" "call:$(jq -r .call_id "$PROPOSAL")" payload_hash \
  #   "ESC_<class>; agent_name:scribe; failures:${#FAILURES[@]}"
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
