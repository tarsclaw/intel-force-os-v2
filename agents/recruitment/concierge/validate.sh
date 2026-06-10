#!/usr/bin/env bash
# Concierge agent — validate.sh (Gate A enforcement; W10-13 LIVE)
#
# Status: BUILT (W10-13 build slice; spec-004 §5 — all 6 checks live).
# Reading order: agent.md §5 (Gate A) + §6 (ESC codes) + §1 thresholds first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is
# the hard-fail gate that runs BETWEEN draft generation (cycle.sh Step 7) and
# the autosend-bridge propose call (Step 11). If any check fails, validate.sh
# exits non-zero + emits the dominant ESC_* escalation row + a
# validate_gate_a_fail action row; the draft is moved OUT of the
# customer-facing path (/tmp) per agent.md §5; cycle.sh aborts the draft.
#
# Invocation contract:
#   bash validate.sh <draft_path>
#
# Inputs:
#   - $1: path to the vault concierge-draft file (cycle.sh Step 7 wrote it)
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR, IFOS_DB_URL
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to Step 8 action row + Step 11
#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts the draft
#   2  validate.sh invocation error (bad args, missing draft, env unset)
#
# Checks (per agent.md §5 Gate A + spec-004 §5 — 6 checks):
#   G1 — voice classifier score ≥ position-specific threshold
#        (position 1: ≥0.75 ; position 2: ≥0.78 ; position 3: ≥0.82).
#        HONESTY: no voice classifier exists in v1.0 (@ifos/voice-classifier
#        unbuilt; voice_corpus empty) → unscored drafts WARN-AND-PASS (the
#        accepted v1.0 Gate A behaviour); the threshold HARD-ENFORCES on any
#        real numeric score (fixtures supply one to prove the gate).
#   G2 — addressee resolution: draft recipient matches the changing
#        candidate's email (entities cache cross-check; ULTRAPLAN A6 line 566
#        verbatim "no candidates emailed under another's name") —
#        ESC_ADDRESSEE_MISMATCH (blocking)
#   G3 — no block-severity tone-rule violation (tenant tone_rule rows via
#        hh_load_tone_rules ∋ concierge: examples_negative phrase match;
#        plus the agent.md §7 built-in block phrases) —
#        ESC_TONE_RULE_VIOLATION
#   G4 — no PII outside firm boundary (email addresses in body whose domain
#        is neither the recipient's nor an allowlisted firm domain) —
#        ESC_PII_LEAKAGE_RISK (blocking)
#   G5 — anti-duplicate re-check at validate time (race guard vs Step 2) —
#        ESC_AUTOSEND_RACE (warn class; still blocks the draft)
#   G6 — Bullhorn context complete: candidate name + email present —
#        ESC_AGENT_OUTPUT_SHAPE
# (30-min SLA is Gate B leading, NOT a Gate A hard-fail — ADR-007.)

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  printf 'concierge/validate.sh: usage: validate.sh <draft_path>\n' >&2
  exit 2
fi

readonly DRAFT="$1"

if [[ ! -f "${DRAFT}" ]]; then
  printf 'validate.sh: draft not found at %s\n' "${DRAFT}" >&2
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

# Resolve _shared/ helpers (4-candidate fallback; matches sibling pattern
# post d7d52c5 smoke-hotfix).
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
# voice-loader supplies hh_load_tone_rules (G3).
if [[ -f "${_SHARED_DIR}/voice-loader.sh" ]]; then
  # shellcheck source=/dev/null
  source "${_SHARED_DIR}/voice-loader.sh"
fi

# Track failures + warnings across all checks (collect all before exit for
# richer audit; same pattern as cash-conductor/validate.sh).
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

# Frontmatter reader: pull "key: value" from the leading YAML block.
_fm() {
  sed -n '1,/^---$/{/^---$/d;p;}' "${DRAFT}" 2>/dev/null \
    | grep -m1 "^$1:" | sed "s/^$1:[[:space:]]*//; s/^\"//; s/\"$//"
}
# Body = everything after the second '---'.
_body() { awk 'c==2{print} /^---$/{c++}' "${DRAFT}" 2>/dev/null; }

D_CANDIDATE_ID="$(_fm candidate_id)"
D_CANDIDATE_NAME="$(_fm candidate_name)"
D_EVENT_TYPE="$(_fm event_type)"
D_RECIPIENT="$(_fm recipient)"
D_RECIPIENT_ROLE="$(_fm recipient_role)"
D_VOICE="$(_fm voice_score)"
D_POSITION="$(_fm escalation_position)"

# One RLS-scoped read of the candidate's entities cache row (G2 + G6).
DB_CAND_EMAIL="" DB_CAND_NAME="" DB_ROW_PRESENT=0
if [[ -n "${D_CANDIDATE_ID}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _db_row="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" --set=cid="${D_CANDIDATE_ID}" <<'SQL' 2>/dev/null
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(data->>'email','') || '|' || coalesce(data->>'name','')
FROM entities WHERE entity_type='candidate' AND entity_id = :'cid' LIMIT 1;
COMMIT;
SQL
)"
  _db_row="$(printf '%s\n' "${_db_row}" | grep -vE '^$' | head -1 || true)"
  if [[ -n "${_db_row}" ]]; then
    DB_ROW_PRESENT=1
    IFS='|' read -r DB_CAND_EMAIL DB_CAND_NAME <<<"${_db_row}"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# G1 — voice classifier score ≥ position-specific threshold
# Position 1 ≥0.75 ; Position 2 ≥0.78 ; Position 3 ≥0.82
# Reference: agent.md §5 Gate A + §4 Step 8 + ULTRAPLAN A6 line 566 (amended)
# ────────────────────────────────────────────────────────────────────────

if [[ "${D_VOICE}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  case "${D_POSITION}" in
    3) _thr="0.82" ;;
    2) _thr="0.78" ;;
    *) _thr="0.75" ;;
  esac
  if awk -v s="${D_VOICE}" -v t="${_thr}" 'BEGIN{exit !(s>=t)}'; then
    _ok "G1: voice_score ${D_VOICE} ≥ ${_thr} (position ${D_POSITION:-1})"
  else
    _fail "G1: voice_score ${D_VOICE} < ${_thr} (position ${D_POSITION:-1})"
    ESC_CLASS="${ESC_CLASS:-ESC_VOICE_DRIFT}"
  fi
else
  # unscored/no_corpus is the HONEST v1.0 state — warn-and-pass (accepted
  # Gate A behaviour; @ifos/voice-classifier unbuilt, voice_corpus empty).
  _warn "G1: voice unscored (${D_VOICE:-none}) — no classifier/corpus in v1.0; threshold enforced only on real numeric scores"
fi

# ────────────────────────────────────────────────────────────────────────
# G2 — addressee resolution: recipient matches the changing candidate.
# ULTRAPLAN A6 line 566 verbatim: "no candidates emailed under another's
# name". client_contact recipients are checked the inverse way: the
# recipient must NOT be a different candidate's address.
# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on fail.
# ────────────────────────────────────────────────────────────────────────

if [[ "${D_RECIPIENT_ROLE}" == "candidate" ]]; then
  if [[ -z "${DB_CAND_EMAIL}" ]]; then
    _warn "G2: no candidate email in entities cache — cross-check deferred (G6 governs completeness)"
  elif [[ "${D_RECIPIENT}" == "${DB_CAND_EMAIL}" ]]; then
    _ok "G2: recipient matches candidate ${D_CANDIDATE_ID} (${D_RECIPIENT})"
  else
    _fail "G2: ADDRESSEE MISMATCH — draft recipient '${D_RECIPIENT}' != candidate email '${DB_CAND_EMAIL}'"
    ESC_CLASS="ESC_ADDRESSEE_MISMATCH"
  fi
else
  # client_contact path: recipient must not collide with ANOTHER candidate.
  _collision=""
  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    _collision="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
      --set=tenant="${CTX_TENANT_SLUG}" --set=cid="${D_CANDIDATE_ID}" --set=rcpt="${D_RECIPIENT}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT entity_id FROM entities
WHERE entity_type='candidate' AND data->>'email' = :'rcpt' AND entity_id <> :'cid' LIMIT 1;
COMMIT;
SQL
)"
  fi
  if [[ -n "${_collision}" ]]; then
    _fail "G2: ADDRESSEE MISMATCH — client_contact recipient '${D_RECIPIENT}' is candidate ${_collision}'s email"
    ESC_CLASS="ESC_ADDRESSEE_MISMATCH"
  else
    _ok "G2: client_contact recipient does not collide with any candidate address"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# G3 — no block-severity tone-rule violation
# Tenant rules via hh_load_tone_rules (tone_rule table, ∋ concierge):
# block-severity rules match when any examples_negative phrase appears in
# the body. Built-in block phrases per agent.md §7 always apply.
# ESC_TONE_RULE_VIOLATION (Gate A blocks; ESC severity warn per catalogue).
# ────────────────────────────────────────────────────────────────────────

BODY_TEXT="$(_body)"
BODY_LC="$(printf '%s' "${BODY_TEXT}" | tr '[:upper:]' '[:lower:]')"
_g3_hit=""

# Built-in block phrases (agent.md §7 tone defaults).
for _phrase in "we regret to inform you" "per our previous conversation" "act now" "urgent:"; do
  if [[ "${BODY_LC}" == *"${_phrase}"* ]]; then
    _g3_hit="builtin:${_phrase}"
    break
  fi
done

# Tenant block-severity rules (examples_negative phrase match).
if [[ -z "${_g3_hit}" ]] && declare -f hh_load_tone_rules >/dev/null 2>&1; then
  _rules_json="$(hh_load_tone_rules concierge 2>/dev/null || echo '{"rules":[]}')"
  while IFS=$'\t' read -r _rid _neg; do
    [[ -z "${_rid}" || -z "${_neg}" ]] && continue
    # examples_negative arrives as a Postgres array literal: {"a","b"} — split.
    _neg="${_neg#\{}"; _neg="${_neg%\}}"
    IFS=',' read -ra _phrases <<<"${_neg}"
    for _p in "${_phrases[@]}"; do
      _p="${_p%\"}"; _p="${_p#\"}"
      _p="$(printf '%s' "${_p}" | tr '[:upper:]' '[:lower:]')"
      [[ -z "${_p}" ]] && continue
      if [[ "${BODY_LC}" == *"${_p}"* ]]; then
        _g3_hit="rule:${_rid}:${_p}"
        break 2
      fi
    done
  done < <(printf '%s' "${_rules_json}" | jq -r '.rules[]? | select(.severity=="block") | [.rule_id, .examples_negative] | @tsv' 2>/dev/null)
fi

if [[ -n "${_g3_hit}" ]]; then
  _fail "G3: block-severity tone-rule violation (${_g3_hit})"
  ESC_CLASS="${ESC_CLASS:-ESC_TONE_RULE_VIOLATION}"
else
  _ok "G3: no block-severity tone-rule violations"
fi

# ────────────────────────────────────────────────────────────────────────
# G4 — no PII outside firm boundary: scan body for email addresses whose
# domain is neither the recipient's nor an allowlisted firm domain
# (CTX_FIRM_DOMAINS, space-separated; from context hydration).
# ESC_PII_LEAKAGE_RISK (blocking; operator + ifos_oncall).
# ────────────────────────────────────────────────────────────────────────

_BODY_EMAILS="$(printf '%s' "${BODY_TEXT}" \
  | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
if [[ -n "${_BODY_EMAILS}" ]]; then
  _allow="${D_RECIPIENT##*@} ${CTX_FIRM_DOMAINS:-}"
  _ext=""
  while IFS= read -r _em; do
    [[ -z "${_em}" ]] && continue
    _dom="${_em##*@}"
    _dom_ok=0
    for _a in ${_allow}; do
      [[ "${_dom}" == "${_a}" ]] && _dom_ok=1
    done
    [[ "${_dom_ok}" -eq 0 ]] && _ext="${_em}"
  done <<<"${_BODY_EMAILS}"
  if [[ -n "${_ext}" ]]; then
    _fail "G4: body contains email address outside the firm boundary (${_ext})"
    ESC_CLASS="${ESC_CLASS:-ESC_PII_LEAKAGE_RISK}"
  else
    _ok "G4: no PII outside firm boundary"
  fi
else
  _ok "G4: no email addresses in body"
fi

# ────────────────────────────────────────────────────────────────────────
# G5 — anti-duplicate re-check at validate time. Defence-in-depth vs the
# Step 2 guard: a webhook re-fire between Step 2 and validate.sh could
# insert a completed send in the window — re-check prevents the race.
# True dup = prior draft row AND completed send for same candidate+event in 24h.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _dup="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" --set=tgt="candidate:${D_CANDIDATE_ID}:${D_EVENT_TYPE}" \
    --set=ctgt="candidate:${D_CANDIDATE_ID}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT 1 FROM decision_log d
WHERE d.agent_name='concierge'
  AND d.payload->>'action_type'='concierge_email_draft'
  AND d.payload->>'target' = :'tgt'
  AND d.phase IN ('action','gating_failed')
  AND d.created_at > now() - interval '24 hours'
  AND EXISTS (
    SELECT 1 FROM decision_log s
    WHERE s.agent_name='concierge'
      AND s.payload->>'action_type'='gmail_outlook_send_to_candidate'
      AND s.payload->>'target' = :'ctgt'
      AND s.phase='action'
      AND s.created_at > now() - interval '24 hours'
  )
LIMIT 1;
COMMIT;
SQL
)"
  if [[ "${_dup}" == "1" ]]; then
    _fail "G5: true duplicate at validate time — prior draft + completed send within 24h"
    ESC_CLASS="${ESC_CLASS:-ESC_AUTOSEND_RACE}"
  else
    _ok "G5: anti-duplicate re-check clean"
  fi
else
  _warn "G5: DB unavailable — anti-duplicate re-check skipped (Step 2 guard was the primary)"
fi

# ────────────────────────────────────────────────────────────────────────
# G6 — Bullhorn context complete: candidate name + email present (draft
# frontmatter AND entities cache row). ESC_AGENT_OUTPUT_SHAPE.
# (ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10.)
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${D_CANDIDATE_NAME}" || -z "${D_RECIPIENT}" ]]; then
  _fail "G6: draft missing candidate_name or recipient"
  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
elif [[ "${DB_ROW_PRESENT}" -eq 1 && ( -z "${DB_CAND_EMAIL}" || -z "${DB_CAND_NAME}" ) ]]; then
  _fail "G6: candidate ${D_CANDIDATE_ID} cache row incomplete (name/email missing)"
  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
elif [[ "${DB_ROW_PRESENT}" -eq 0 ]]; then
  _fail "G6: no entities cache row for candidate ${D_CANDIDATE_ID} — context fetch incomplete"
  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
else
  _ok "G6: Bullhorn context complete (name + email present)"
fi

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nValidate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # Per-failure ESC routing (agent.md §5): G1→ESC_VOICE_DRIFT (warn),
  # G2→ESC_ADDRESSEE_MISMATCH (blocking), G3→ESC_TONE_RULE_VIOLATION (warn),
  # G4→ESC_PII_LEAKAGE_RISK (blocking), G5→ESC_AUTOSEND_RACE (warn),
  # G6→ESC_AGENT_OUTPUT_SHAPE (warn). Gate A blocks the draft regardless of
  # the ESC code's paging severity (the two dimensions are separate).
  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
  autosend_escalate "${ESC_CLASS}" "agent=concierge" \
    "tenant=${CTX_TENANT_SLUG}" "candidate=${D_CANDIDATE_ID:-unknown}" \
    "event=${D_EVENT_TYPE:-unknown}" "failures=${#FAILURES[@]}" "draft=${DRAFT}"
  _gfail_hash="$(printf '%s' "${DRAFT}|${ESC_CLASS}" | shasum -a 256 2>/dev/null | cut -c1-16)"
  [[ -z "${_gfail_hash}" ]] && _gfail_hash="gate-a-fail"
  hh_decision_action "validate_gate_a_fail" \
    "candidate:${D_CANDIDATE_ID:-unknown}:${D_EVENT_TYPE:-unknown}" "${_gfail_hash}" \
    "${ESC_CLASS}; position:${D_POSITION:-1}; score:${D_VOICE:-unscored}; failures:${#FAILURES[@]}" || true
  # Move the draft OUT of the customer-facing path (agent.md §5).
  _quarantine="/tmp/concierge-gate-a-failed-$(basename "${DRAFT}")"
  mv -f "${DRAFT}" "${_quarantine}" 2>/dev/null \
    && printf 'validate.sh: draft quarantined to %s\n' "${_quarantine}" >&2
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
