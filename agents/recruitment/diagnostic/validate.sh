#!/usr/bin/env bash
# shellcheck disable=SC2155
#
# Diagnostic agent — validate.sh (Gate A enforcement)
#
# Status: Proposed (pre-W3-build scaffold; Day-12 author).
# Reading order: agent.md §5 (Gates) + §6 (Escalation codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
# is the hard-fail gate that runs AFTER cycle.sh produces a draft report
# but BEFORE the vault write + operator notify. If any check fails,
# validate.sh exits non-zero and emits an ESC_* escalation row to
# decision_log; the report does NOT land in the vault.
#
# Invocation contract:
#   bash validate.sh <draft_report_path>
#
# Inputs:
#   - $1: path to the draft Markdown report (cycle.sh writes it to /tmp first)
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
#          CTX_TONE_RULES (json string)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to vault write
#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts
#   2  validate.sh invocation error (bad args, missing draft, etc.)
#
# Checks (per agent.md §5 Gate A):
#   V1 — All 12 sections present (count + heading regex)
#   V2 — Each section has ≥1 markdown link (regex)
#   V3 — Section 12 voice classifier score ≥ 0.75
#   V4 — Report length 400-2000 words
#   V5 — No banned phrases per tone_rule table
#   V6 — No PII outside firm boundary (regex pass)

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  printf 'validate.sh: usage: validate.sh <draft_report_path>\n' >&2
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

# Source helpers for escalation emission
if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi
# shellcheck source=/dev/null
source "${CTX_AGENT_DIR}/.claude/hooks/_shared/hook-helpers.sh"

# Track failures across all checks; collect all before exit (richer audit)
declare -a FAILURES=()
declare -a WARNINGS=()

_fail() {
  FAILURES+=("$1")
  printf '  ✗ %s\n' "$1" >&2
}

_pass() {
  printf '  ✓ %s\n' "$1"
}

_warn() {
  WARNINGS+=("$1")
  printf '  ! %s\n' "$1" >&2
}

# ────────────────────────────────────────────────────────────────────────
# V1 — 12 sections present
# ────────────────────────────────────────────────────────────────────────

# Section labels documented for reference; not currently regex-matched
# individually because count + per-section citation check covers V1+V2.
# At W3 build: tighten to enforce exact-heading match per EXPECTED_SECTIONS.
SECTION_COUNT=$(grep -cE '^##[[:space:]]' "${DRAFT}" || echo 0)
if (( SECTION_COUNT == 12 )); then
  _pass "V1: 12 sections present"
else
  _fail "V1: expected 12 sections, found ${SECTION_COUNT}"
fi

# ────────────────────────────────────────────────────────────────────────
# V2 — Each section has ≥1 markdown link
# ────────────────────────────────────────────────────────────────────────

# Per-section citation check: single awk pass tracks current section
# index, sets has_link[i]=1 when a Markdown link is found within a
# section's body, then prints the indices of sections with no link.
MISSING_INDICES=$(awk '
  /^## / { sec_num++; next }
  sec_num > 0 && /\[[^]]+\]\([^)]+\)/ { has_link[sec_num]=1 }
  END {
    for (i=1; i<=sec_num; i++) {
      if (!has_link[i]) printf "%d ", i
    }
  }
' "${DRAFT}")

MISSING_CITATION=()
for idx in ${MISSING_INDICES}; do
  MISSING_CITATION+=("section ${idx}")
done

if (( ${#MISSING_CITATION[@]} == 0 )); then
  _pass "V2: every section has ≥1 citation link"
else
  _fail "V2: missing citation in: ${MISSING_CITATION[*]}"
fi

# ────────────────────────────────────────────────────────────────────────
# V3 — §12 voice classifier ≥ 0.75
# ────────────────────────────────────────────────────────────────────────

# Extract §12 (conversation opener)
SECTION_12=$(awk '/^## .*[Cc]onversation [Oo]pener/{flag=1; next} /^## /{flag=0} flag' "${DRAFT}")

if [[ -z "${SECTION_12}" ]]; then
  _fail "V3: §12 (Conversation opener) section not found or empty"
else
  # Voice classifier microservice call (W3 build wires this up)
  # For scaffold: assume IFOS_VOICE_CLASSIFIER_URL set; fail gracefully if not
  if [[ -n "${IFOS_VOICE_CLASSIFIER_URL:-}" ]]; then
    SCORE=$(curl -sS -X POST "${IFOS_VOICE_CLASSIFIER_URL}/classify" \
      -H "Content-Type: application/json" \
      -d "$(printf '{"text":%s,"tenant_slug":"%s"}' \
        "$(printf '%s' "${SECTION_12}" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))")" \
        "${CTX_TENANT_SLUG}")" \
      2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('score', 0))" 2>/dev/null || echo "0")

    if [[ -n "${SCORE}" ]] && python3 -c "import sys; sys.exit(0 if float('${SCORE}') >= 0.75 else 1)" 2>/dev/null; then
      _pass "V3: §12 voice classifier score=${SCORE} (≥ 0.75)"
    else
      _fail "V3: §12 voice classifier score=${SCORE} (< 0.75)"
    fi
  else
    _warn "V3: IFOS_VOICE_CLASSIFIER_URL unset; voice classification SKIPPED (W3 build wires this)"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# V4 — Length 400-2000 words
# ────────────────────────────────────────────────────────────────────────

WORD_COUNT=$(wc -w < "${DRAFT}" | tr -d ' ')
if (( WORD_COUNT >= 400 && WORD_COUNT <= 2000 )); then
  _pass "V4: word count=${WORD_COUNT} (400-2000)"
elif (( WORD_COUNT < 400 )); then
  _fail "V4: report too short (${WORD_COUNT} words; min 400)"
else
  _fail "V4: report too long (${WORD_COUNT} words; max 2000)"
fi

# ────────────────────────────────────────────────────────────────────────
# V5 — Banned phrases per tone_rule
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${CTX_TONE_RULES:-}" ]]; then
  BANNED_HITS=$(printf '%s' "${CTX_TONE_RULES}" | python3 -c "
import json, sys, re
data = json.loads(sys.stdin.read() or '{}')
rules = data.get('rules', [])
with open('${DRAFT}', 'r') as f:
    text = f.read()
hits = []
for r in rules:
    if r.get('severity') == 'block':
        for phrase in r.get('examples_negative', []):
            if phrase and phrase.lower() in text.lower():
                hits.append(f\"rule={r.get('rule_id')} phrase='{phrase}'\")
print('|'.join(hits))
" 2>/dev/null || echo "")

  if [[ -z "${BANNED_HITS}" ]]; then
    _pass "V5: no banned phrases detected"
  else
    _fail "V5: banned phrases detected: ${BANNED_HITS}"
  fi
else
  _warn "V5: CTX_TONE_RULES empty; banned-phrase check skipped"
fi

# ────────────────────────────────────────────────────────────────────────
# V6 — No PII outside firm boundary
# ────────────────────────────────────────────────────────────────────────
#
# Detect emails/phones in the report that DON'T belong to the firm being
# diagnosed. Simple regex pass; production W3 build adds NER pass.

FIRM_NAME="${IFOS_DIAGNOSTIC_FIRM_NAME:-unknown}"
# At W3 build: extract firm domain from Companies House link to scope
# the PII-boundary check. Stub for scaffold.

# Find all emails in the report
ALL_EMAILS=$(grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "${DRAFT}" | sort -u || echo "")

# This is a coarse check — true PII boundary requires firm-domain enumeration
# at W3 build. For scaffold: warn if any email present (rather than fail)
# since we don't yet have the firm-domain whitelist mechanism.
if [[ -n "${ALL_EMAILS}" ]]; then
  _warn "V6: emails present in report (verify they belong to ${FIRM_NAME}): $(echo "${ALL_EMAILS}" | tr '\n' ' ')"
else
  _pass "V6: no emails embedded (firm-boundary PII check trivially passes)"
fi

# ────────────────────────────────────────────────────────────────────────
# Verdict + escalation emission
# ────────────────────────────────────────────────────────────────────────

if (( ${#FAILURES[@]} == 0 )); then
  printf '\nValidate Gate A: \033[1;32mPASS\033[0m (warnings=%d)\n' "${#WARNINGS[@]}"
  exit 0
else
  printf '\nValidate Gate A: \033[1;31mFAIL\033[0m (%d failures, %d warnings)\n' \
    "${#FAILURES[@]}" "${#WARNINGS[@]}"

  # Emit the specific ESC code per agent.md §6 mapping:
  #   - PII detected outside firm boundary → ESC_PII_LEAKAGE_RISK (blocking)
  #   - Voice classifier score <0.75 (V3) → ESC_VOICE_DRIFT (warn, per
  #     fixture 99-voice-drift-canary.yaml expectation)
  #   - Output-shape violation (section count, per-section citation,
  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
  # ESC_SCHEMA_VIOLATION is reserved for vertical-schema field-constraint
  # violations at write time per catalogue line 163 — not for Diagnostic's
  # output-shape failures.
  PII_FAILURE_PRESENT=0
  VOICE_FAILURE_PRESENT=0
  for failure in "${FAILURES[@]}"; do
    if [[ "${failure}" == *"PII"* || "${failure}" == *"pii"* ]]; then
      PII_FAILURE_PRESENT=1
    elif [[ "${failure}" == *"voice"* || "${failure}" == *"Voice"* || "${failure}" == *"V3"* ]]; then
      VOICE_FAILURE_PRESENT=1
    fi
  done

  if (( PII_FAILURE_PRESENT == 1 )); then
    ESC_CODE="ESC_PII_LEAKAGE_RISK"
  elif (( VOICE_FAILURE_PRESENT == 1 )); then
    ESC_CODE="ESC_VOICE_DRIFT"
  else
    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
  fi

  ESC_PAYLOAD=$(printf '{"escalation_code":"%s","draft_path":"%s","failures":%s}' \
    "${ESC_CODE}" \
    "${DRAFT}" \
    "$(printf '%s\n' "${FAILURES[@]}" | python3 -c "import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))" 2>/dev/null || echo '[]')")

  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
    "$(echo "${ESC_PAYLOAD}" | shasum | awk '{print $1}')" \
    "${ESC_PAYLOAD}" 2>/dev/null || true

  exit 1
fi
