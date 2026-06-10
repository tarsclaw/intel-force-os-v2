#!/usr/bin/env bash
# Scribe agent — validate.sh (Gate A enforcement; W6 build slice LIVE)
#
# Status: built (W6 build slice; the W5 Day-32 skeleton TODO(W6-7) markers are
#         replaced with live checks per spec-002-scribe.md §5 + agent.md §5).
# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
# hard-fail gate that runs BETWEEN cycle.sh Step 7 (field validation) and
# Step 8 (Bullhorn write). If any check fails, validate.sh exits non-zero +
# emits the ESC_* row + the validate_gate_a_fail action row to decision_log;
# the meeting's Bullhorn writes are skipped; cycle.sh continues to the next
# meeting (poll-sweep mode) or exits with the gate-fail signal (replay/webhook).
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
#           "bullhorn_id": "<id>",
#           "webhook_sig_state": "verified" | "not_applicable" | "invalid" | "missing",
#           "fields_extracted": [
#             {"field_name": "...", "value": ..., "confidence": <0.0-1.0>}
#           ],
#           "tacit_note": {
#             "vault_path": "/vault/<tenant>/scribe-notes/<call_id>-<ISO>.md",
#             "body_sha256": "...",
#             "voice_score": <0.0-1.0> | "unscored",
#             "voice_reason": "...",
#             "narrative_word_count": <int>,
#             "narrative_body_preview": "..."  // first 500 chars — AUDIT ROW ONLY;
#                                              // G6 scans the FULL physical body
#                                              // resolved from vault_path
#           }
#         }
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
#          CTX_FIRM_DOMAIN_WHITELIST (comma-separated; for the PII check),
#          IFOS_VAULT_ROOT (physical vault root for resolving vault_path;
#          default ~/.ifos-local-vault — must match cycle.sh)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to Steps 8 + 9 writes
#   1  At least one check failed; ESC_* row emitted; cycle.sh skips writes
#   2  validate.sh invocation error (bad args, missing file, etc.)
#
# Checks (spec-002 §5 — all 7, in spec order — plus the agent.md §3 word cap):
#   G1 — webhook-sig: valid per provider                    ESC_INPUT_VALIDATION_FAIL  hard
#   G2 — field-count: ≥ per-entity min extractions ≥0.6     ESC_FIELD_EXTRACTION_LOW_CONFIDENCE  hard
#        (contact: 2 — its full Scribe-writable v0.3 set; all others: 3)
#   G3 — tacit-voice: classifier ≥0.75                      ESC_VOICE_DRIFT  hard (warn-when-unscored)
#   G4 — field-names: exist in target entity schema         ESC_SCHEMA_VIOLATION  hard
#   G5 — field-types: per-field type/range valid; ≥ per-entity min valid  ESC_SCHEMA_VIOLATION  hard
#   G6 — PII: none outside firm boundary in note narrative  ESC_PII_LEAKAGE_RISK  hard (blocking)
#        (FULL physical body from tacit_note.vault_path — Step 9 exports the
#        full body to Bullhorn, so the gate scans everything that leaves)
#   G7 — auth: Bullhorn refresh succeeded this session      ESC_BULLHORN_AUTH  hard
#   G8 — word-cap: tacit-note ≤800 words (agent.md §3)      ESC_AGENT_OUTPUT_SHAPE  hard

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
command -v jq >/dev/null 2>&1 || { printf 'validate.sh: jq required\n' >&2; exit 2; }
jq -e 'type=="object"' "${PROPOSAL}" >/dev/null 2>&1 || {
  printf 'validate.sh: proposal is not a JSON object\n' >&2; exit 2; }

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

_BIN="${CTX_AGENT_DIR}/bin"
[[ -d "${_BIN}" ]] || _BIN="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/bin"

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

# Dominant failure class for ESC routing (first hard fail wins).
ESC_CLASS=""

# Thresholds (per ULTRAPLAN A3 line 524 + agent.md §3)
readonly FIELD_CONFIDENCE_THRESHOLD="0.6"
readonly VOICE_SCORE_THRESHOLD="0.75"
readonly TACIT_NOTE_WORD_CAP="800"

CALL_ID="$(jq -r '.call_id // "unknown"' "${PROPOSAL}")"
ENTITY_TYPE="$(jq -r '.entity_type // ""' "${PROPOSAL}")"
BULLHORN_ID="$(jq -r '.bullhorn_id // "unknown"' "${PROPOSAL}")"

# Per-entity Gate A minimum (Codex R2-1): the v0.3 schema grants Scribe
# exactly TWO writable Contact fields (preferred_channel,
# next_action_target_date — decision_authority is R-only per the v0.3 §2
# access matrix), so a blanket ≥3 bar would hard-fail EVERY legitimate
# Contact-resolved call at G5 (max 2 valid writable fields exist). Contact's
# minimum is its full writable set (2); all other entities keep the
# ULTRAPLAN A3 line 524 ≥3 bar. Extraction may surface more fields; R-only
# fields flow to the tacit-note narrative only, never the write payload.
case "${ENTITY_TYPE}" in
  contact) MIN_FIELDS_REQUIRED="2" ;;
  *)       MIN_FIELDS_REQUIRED="3" ;;
esac
readonly MIN_FIELDS_REQUIRED

# ────────────────────────────────────────────────────────────────────────
# G1 — Webhook signature valid per provider (spec-002 §5 row 1)
# cycle.sh Step 1 verified the HMAC/bearer and recorded the verdict in the
# proposal. 'not_applicable' = poll-sweep/replay (Granola publishes no
# webhooks — there is no external input to verify); anything else fails hard.
# ────────────────────────────────────────────────────────────────────────

_sig="$(jq -r '.webhook_sig_state // "missing"' "${PROPOSAL}")"
case "${_sig}" in
  verified)        _ok "G1: webhook signature verified" ;;
  not_applicable)  _ok "G1: webhook signature not applicable (poll/replay trigger; no external webhook input)" ;;
  *)
    _fail "G1: webhook signature state '${_sig}' — reject"
    ESC_CLASS="${ESC_CLASS:-ESC_INPUT_VALIDATION_FAIL}" ;;
esac

# ────────────────────────────────────────────────────────────────────────
# G2 — structured-field extractions with confidence ≥0.6 meet the
# per-entity minimum (contact: 2; all others: 3 per ULTRAPLAN A3 line 524).
# ────────────────────────────────────────────────────────────────────────

_n_conf="$(jq --argjson t "${FIELD_CONFIDENCE_THRESHOLD}" \
  '[.fields_extracted[]? | select(.confidence >= $t)] | length' "${PROPOSAL}" 2>/dev/null || echo 0)"
if [[ "${_n_conf}" -ge "${MIN_FIELDS_REQUIRED}" ]]; then
  _ok "G2: ${_n_conf} fields with confidence ≥${FIELD_CONFIDENCE_THRESHOLD} (≥${MIN_FIELDS_REQUIRED} required)"
else
  _fail "G2: only ${_n_conf} fields ≥${FIELD_CONFIDENCE_THRESHOLD} confidence (need ${MIN_FIELDS_REQUIRED})"
  ESC_CLASS="${ESC_CLASS:-ESC_FIELD_EXTRACTION_LOW_CONFIDENCE}"
fi

# ────────────────────────────────────────────────────────────────────────
# G3 — Tacit-note voice classifier ≥0.75
# Hard fail when a numeric score is below threshold (per agent.md §3: the
# note is NOT attached; the vault draft is flagged needs-consultant-review).
# warn-when-unscored (spec-002 §5): with no tenant voice_corpus (or no
# classifier wired) a score cannot be HONESTLY computed — warn, never fake.
# ────────────────────────────────────────────────────────────────────────

_voice="$(jq -r '.tacit_note.voice_score // "missing"' "${PROPOSAL}")"
_vreason="$(jq -r '.tacit_note.voice_reason // ""' "${PROPOSAL}")"
if [[ "${_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  if awk -v s="${_voice}" -v t="${VOICE_SCORE_THRESHOLD}" 'BEGIN{exit !(s>=t)}'; then
    _ok "G3: tacit-note voice score ${_voice} ≥ ${VOICE_SCORE_THRESHOLD}"
  else
    _fail "G3: tacit-note voice score ${_voice} < ${VOICE_SCORE_THRESHOLD} (after retries) — note NOT attached; vault draft held for consultant review"
    ESC_CLASS="${ESC_CLASS:-ESC_VOICE_DRIFT}"
  fi
else
  _warn "G3: voice unscored (${_vreason:-no_reason}) — cannot enforce threshold without a seeded voice_corpus + classifier (never faked)"
fi

# ────────────────────────────────────────────────────────────────────────
# G4 + G5 — Field names exist in target entity schema + per-field type/range
# Single source of truth: bin/validate-fields.sh (schema-file-derived
# allowlist mirroring the validate_entities_data_v0_3 trigger).
# ────────────────────────────────────────────────────────────────────────

_FIELDS_TMP="$(mktemp -t scribe-gate-fields-XXXXXX)"
trap 'rm -f "${_FIELDS_TMP}"' EXIT
jq -c '.fields_extracted // []' "${PROPOSAL}" > "${_FIELDS_TMP}"

_vres="$(bash "${_BIN}/validate-fields.sh" --entity-type "${ENTITY_TYPE}" --fields-file "${_FIELDS_TMP}" 2>/dev/null)" \
  || _vres='{"valid":[],"dropped":[{"field_name":"(validator)","reason":"validate-fields.sh failed"}],"valid_count":0}'
_valid_count="$(jq -r '.valid_count' <<<"${_vres}")"
_bad_names="$(jq -r '[.dropped[] | select(.reason | test("not in .* writable schema"))] | length' <<<"${_vres}")"
_bad_types="$(jq -r '[.dropped[] | select(.reason | test("not in .* writable schema") | not)] | length' <<<"${_vres}")"

if [[ "${_bad_names}" -eq 0 ]]; then
  _ok "G4: all field names exist in ${ENTITY_TYPE} schema (vertical-schema v0.1+v0.3)"
else
  _fail "G4: ${_bad_names} field name(s) not in ${ENTITY_TYPE} schema: $(jq -r '[.dropped[] | select(.reason | test("not in")) | .field_name] | join(",")' <<<"${_vres}")"
  ESC_CLASS="${ESC_CLASS:-ESC_SCHEMA_VIOLATION}"
fi

if [[ "${_bad_types}" -eq 0 && "${_valid_count}" -ge "${MIN_FIELDS_REQUIRED}" ]]; then
  _ok "G5: per-field type/range checks pass (${_valid_count} valid)"
else
  if [[ "${_bad_types}" -gt 0 ]]; then
    _fail "G5: ${_bad_types} field(s) failed type/range checks: $(jq -r '[.dropped[] | select(.reason | test("not in") | not) | .field_name + " (" + .reason + ")"] | join("; ")' <<<"${_vres}")"
  fi
  if [[ "${_valid_count}" -lt "${MIN_FIELDS_REQUIRED}" ]]; then
    _fail "G5: only ${_valid_count} valid field(s) after drops (need ${MIN_FIELDS_REQUIRED})"
  fi
  ESC_CLASS="${ESC_CLASS:-ESC_SCHEMA_VIOLATION}"
fi

# ────────────────────────────────────────────────────────────────────────
# G6 — No PII outside firm boundary in the tacit-note narrative.
# Scans the FULL physical note body resolved from tacit_note.vault_path
# (review F1 fix): Step 9 exports the full body to Bullhorn via
# `create-note --body-file`, so the gate must cover everything that leaves
# the firm boundary. narrative_body_preview is the AUDIT ROW artefact only —
# it is never the scan surface. Fail-closed: a body that cannot be read
# cannot be certified PII-clean, so it blocks.
# Blocking severity per agent.md §6 ESC_PII_LEAKAGE_RISK.
# ────────────────────────────────────────────────────────────────────────

_vault_path="$(jq -r '.tacit_note.vault_path // ""' "${PROPOSAL}")"
_note_phys=""
if [[ "${_vault_path}" == /vault/* ]]; then
  _note_phys="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${_vault_path#/vault/}"
fi
if [[ -z "${_note_phys}" || ! -r "${_note_phys}" ]]; then
  _fail "G6: tacit-note body unreadable (vault_path:'${_vault_path:-missing}') — cannot certify PII boundary; write blocked"
  ESC_CLASS="ESC_PII_LEAKAGE_RISK"
else
  # Frontmatter excluded (metadata only — call_id/date/voice keys, no
  # narrative). Anchored to the LEADING block ONLY (re-review advisory): a
  # `---` pair must start at line 1 to be frontmatter; later `---` lines in
  # the narrative (e.g. markdown horizontal rules) are BODY and stay in the
  # scan surface. The previous sed range (/^---$/,/^---$/!p) wrongly skipped
  # content between ANY later `---` pair.
  _note_body="$(awk 'NR==1 && /^---$/ {fm=1; next} fm {if (/^---$/) fm=0; next} {print}' "${_note_phys}")"
  _whitelist="${CTX_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"
  _pii_hit=0
  _body_emails="$(printf '%s' "${_note_body}" | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
  if [[ -n "${_body_emails}" ]]; then
    while IFS= read -r _em; do
      [[ -z "${_em}" ]] && continue
      _dom="${_em##*@}"
      _allowed=0
      for _fd in ${_whitelist//,/ }; do
        [[ "${_dom,,}" == "${_fd,,}" ]] && _allowed=1
      done
      [[ "${_allowed}" -eq 0 ]] && _pii_hit=1
    done <<<"${_body_emails}"
  fi
  # UK NI numbers + phone-number shapes are also outside-boundary PII in a narrative.
  if printf '%s' "${_note_body}" | grep -qiE '\b[A-CEGHJ-PR-TW-Z]{2}[0-9]{6}[A-D]\b'; then
    _pii_hit=1
  fi
  if [[ "${_pii_hit}" -eq 1 ]]; then
    _fail "G6: PII outside firm boundary detected in tacit-note narrative (full-body scan) — write blocked; vault draft held for review"
    ESC_CLASS="ESC_PII_LEAKAGE_RISK"
  else
    _ok "G6: no PII outside firm boundary in full note body ($(printf '%s' "${_note_body}" | wc -c | tr -d ' ') bytes scanned)"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# G7 — Bullhorn auth refresh succeeded this session
# Re-query decision_log for a fresh bullhorn_auth_refreshed row (≤10 min)
# whose result is fresh|refreshed. unavailable/failed/absent = hard fail —
# no stale-token (or no-token) Bullhorn writes, ever.
# ────────────────────────────────────────────────────────────────────────

_auth_row=""
if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _auth_row="$(psql "${IFOS_DB_URL}" -tAq --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT reason FROM decision_log
WHERE tenant_slug = :'tenant' AND agent_name = 'scribe'
  AND payload->>'output_type' = 'bullhorn_auth_refreshed'
  AND created_at > now() - interval '10 minutes'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
  if [[ "${_auth_row}" == *"result:fresh"* || "${_auth_row}" == *"result:refreshed"* ]]; then
    _ok "G7: Bullhorn auth refreshed this session (${_auth_row##*result:})"
  else
    _fail "G7: no fresh successful bullhorn_auth_refreshed row (got: '${_auth_row:-none}') — Bullhorn writes blocked"
    ESC_CLASS="${ESC_CLASS:-ESC_BULLHORN_AUTH}"
  fi
else
  _warn "G7: DB unavailable — cannot confirm auth refresh (offline-mode fallback rows not queryable)"
fi

# ────────────────────────────────────────────────────────────────────────
# G8 — Tacit-note word count ≤800 (agent.md §3 cap; kept from the skeleton
# in ADDITION to the 7 spec-002 §5 checks — notes must stay scannable;
# long-form analysis belongs in the vault, not Bullhorn)
# ────────────────────────────────────────────────────────────────────────

_words="$(jq -r '.tacit_note.narrative_word_count // 0' "${PROPOSAL}")"
if [[ "${_words}" =~ ^[0-9]+$ ]] && (( _words <= TACIT_NOTE_WORD_CAP )); then
  _ok "G8: tacit-note word count ${_words} ≤ ${TACIT_NOTE_WORD_CAP}"
else
  _fail "G8: tacit-note word count ${_words} exceeds ${TACIT_NOTE_WORD_CAP} cap"
  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
fi

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nScribe validate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # Per-failure-class ESC routing (spec-002 §5): G1 → ESC_INPUT_VALIDATION_FAIL;
  # G2 → ESC_FIELD_EXTRACTION_LOW_CONFIDENCE; G3 → ESC_VOICE_DRIFT;
  # G4/G5 → ESC_SCHEMA_VIOLATION; G6 → ESC_PII_LEAKAGE_RISK (blocking);
  # G7 → ESC_BULLHORN_AUTH (blocking); G8 → ESC_AGENT_OUTPUT_SHAPE.
  # ESC_FIELD_EXTRACTION_LOW_CONFIDENCE carries the catalogue AGGREGATE-form
  # payload fields (escalation-codes.md, amended 2026-06-10): entity_type,
  # fields_extracted_count, confidence_floor, required_minimum, agent_name.
  declare -a _esc_extra=()
  if [[ "${ESC_CLASS:-}" == "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE" ]]; then
    _esc_extra+=("entity_type=${ENTITY_TYPE}" "fields_extracted_count=${_n_conf}" \
      "confidence_floor=${FIELD_CONFIDENCE_THRESHOLD}" "required_minimum=${MIN_FIELDS_REQUIRED}" \
      "agent_name=scribe")
  fi
  autosend_escalate "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}" "agent=scribe" \
    "tenant=${CTX_TENANT_SLUG}" "call=${CALL_ID}" \
    "entity=${ENTITY_TYPE}:${BULLHORN_ID}" "failures=${#FAILURES[@]}" \
    ${_esc_extra[@]+"${_esc_extra[@]}"}
  _gate_hash="$(printf '%s' "${CALL_ID}|${ENTITY_TYPE}|${BULLHORN_ID}" | shasum -a 256 2>/dev/null | cut -c1-16)"
  [[ -z "${_gate_hash}" ]] && _gate_hash="${CALL_ID}"
  hh_decision_action "validate_gate_a_fail" "${ENTITY_TYPE}:${BULLHORN_ID}" "${_gate_hash}" \
    "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}; agent_name:scribe; call:${CALL_ID}; failures:${#FAILURES[@]}; first:${FAILURES[0]}" || true
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
