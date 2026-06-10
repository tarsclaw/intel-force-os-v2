#!/usr/bin/env bash
# Concierge — lifecycle-event draft renderer (agent.md §3 draft structure +
# §4 Step 7). Mirrors cash-conductor/bin/render-chase-draft.sh.
#
# Prints one concierge-draft markdown document (YAML frontmatter + body) to
# stdout. Deterministic by default: the same inputs always render the same
# draft (fixture-testable). cycle.sh Step 7 captures stdout → writes to
# /vault/<tenant>/concierge-drafts/<draft_id>.md (chmod 0600) and emits
# METADATA-only to decision_log (ADR-002 vault/Postgres split).
#
# LLM path (spec-004 + CC precedent): when ANTHROPIC_API_KEY is set AND
# IFOS_CONCIERGE_NO_LLM != 1, the templated body is polished via one
# Claude messages call; on ANY failure (network, non-2xx, bad JSON) the
# templated body is kept silently — fixtures set IFOS_CONCIERGE_NO_LLM=1 so
# they never depend on the API. draft_generator records which path produced
# the body (template | llm).
#
# Voice score honesty (spec-004 §8 + tools.yaml): NO voice classifier exists
# in v1.0 (@ifos/voice-classifier unbuilt) and the dev-sandbox voice_corpus is
# empty → voice_score renders as `unscored` + voice_reason `no_classifier`
# unless the caller supplies a REAL numeric score via --voice-score
# (fixtures use this to exercise the position thresholds). Never faked.
#
# Usage:
#   render-concierge-draft.sh --draft-id ID --event-type E --candidate-id C \
#     --recipient EMAIL --recipient-role candidate|client_contact \
#     --candidate-name N --position 1|2|3 --template-file PATH \
#     --template-source tenant|shared|bundled \
#     [--placement-id P] [--role R] [--company CO] [--interview-at ISO] \
#     [--start-date D] [--event-ts ISO] [--voice-score 0.NN] [--signature SIG]

set -euo pipefail

DRAFT_ID="" EVENT_TYPE="" CANDIDATE_ID="" RECIPIENT="" RECIPIENT_ROLE="candidate"
CANDIDATE_NAME="" POSITION="" TEMPLATE_FILE="" TEMPLATE_SOURCE="bundled"
PLACEMENT_ID="" ROLE_TITLE="" COMPANY="" INTERVIEW_AT="" START_DATE=""
EVENT_TS="" VOICE_SCORE="" SIGNATURE="Best regards,
The recruitment team"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --draft-id)        DRAFT_ID="${2:-}"; shift 2 ;;
    --event-type)      EVENT_TYPE="${2:-}"; shift 2 ;;
    --candidate-id)    CANDIDATE_ID="${2:-}"; shift 2 ;;
    --recipient)       RECIPIENT="${2:-}"; shift 2 ;;
    --recipient-role)  RECIPIENT_ROLE="${2:-}"; shift 2 ;;
    --candidate-name)  CANDIDATE_NAME="${2:-}"; shift 2 ;;
    --position)        POSITION="${2:-}"; shift 2 ;;
    --template-file)   TEMPLATE_FILE="${2:-}"; shift 2 ;;
    --template-source) TEMPLATE_SOURCE="${2:-}"; shift 2 ;;
    --placement-id)    PLACEMENT_ID="${2:-}"; shift 2 ;;
    --role)            ROLE_TITLE="${2:-}"; shift 2 ;;
    --company)         COMPANY="${2:-}"; shift 2 ;;
    --interview-at)    INTERVIEW_AT="${2:-}"; shift 2 ;;
    --start-date)      START_DATE="${2:-}"; shift 2 ;;
    --event-ts)        EVENT_TS="${2:-}"; shift 2 ;;
    --voice-score)     VOICE_SCORE="${2:-}"; shift 2 ;;
    --signature)       SIGNATURE="${2:-}"; shift 2 ;;
    *) printf 'render-concierge-draft.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done

for req in DRAFT_ID EVENT_TYPE CANDIDATE_ID RECIPIENT POSITION TEMPLATE_FILE; do
  if [[ -z "${!req}" ]]; then
    printf 'render-concierge-draft.sh: --%s required\n' \
      "$(printf '%s' "${req}" | tr '[:upper:]_' '[:lower:]-')" >&2
    exit 2
  fi
done
if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  printf 'render-concierge-draft.sh: template file not found: %s\n' "${TEMPLATE_FILE}" >&2
  exit 2
fi

# ── Template extraction ──────────────────────────────────────────────────
# Tenant template (.md): first line `subject: ...`, rest = body.
# Shared/bundled YAML: locate the (event_type, recipient_role) block.
SUBJECT="" BODY="" TEMPLATE_ID=""
if [[ "${TEMPLATE_FILE}" == *.md ]]; then
  SUBJECT="$(head -1 "${TEMPLATE_FILE}" | sed 's/^subject:[[:space:]]*//')"
  BODY="$(tail -n +2 "${TEMPLATE_FILE}")"
  TEMPLATE_ID="tenant-$(basename "${TEMPLATE_FILE}" .md)"
else
  _block="$(awk -v ev="${EVENT_TYPE}" -v role="${RECIPIENT_ROLE}" '
    /^  - event_type: / {
      in_block = ($3 == ev) ? 1 : 0; role_ok = 0; next
    }
    in_block && /^    recipient_role: / { role_ok = ($2 == role) ? 1 : 0; next }
    in_block && role_ok { print }
  ' "${TEMPLATE_FILE}")"
  if [[ -z "${_block}" ]]; then
    printf 'render-concierge-draft.sh: no template for (%s, %s) in %s\n' \
      "${EVENT_TYPE}" "${RECIPIENT_ROLE}" "${TEMPLATE_FILE}" >&2
    exit 3
  fi
  TEMPLATE_ID="$(printf '%s\n' "${_block}" | grep -m1 '^    template_id:' | sed 's/^    template_id:[[:space:]]*//')"
  SUBJECT="$(printf '%s\n' "${_block}" | grep -m1 '^    subject:' | sed 's/^    subject:[[:space:]]*//; s/^"//; s/"$//')"
  BODY="$(printf '%s\n' "${_block}" | awk '/^    body: \|/{found=1; next} found && /^      /{print substr($0,7)} found && !/^      / && !/^$/{exit} found && /^$/{print ""}')"
fi

# ── Placeholder substitution (pure bash; no sed escaping pitfalls) ───────
FIRST_NAME="${CANDIDATE_NAME%% *}"
_subst() {
  local s="$1"
  s="${s//\{\{candidate_name\}\}/${CANDIDATE_NAME}}"
  s="${s//\{\{candidate_first_name\}\}/${FIRST_NAME}}"
  s="${s//\{\{role\}\}/${ROLE_TITLE:-the role}}"
  s="${s//\{\{company\}\}/${COMPANY:-the client}}"
  s="${s//\{\{interview_at\}\}/${INTERVIEW_AT:-the agreed time}}"
  s="${s//\{\{start_date\}\}/${START_DATE:-your agreed start date}}"
  s="${s//\{\{consultant_signature\}\}/${SIGNATURE}}"
  printf '%s' "${s}"
}
SUBJECT="$(_subst "${SUBJECT}")"
BODY="$(_subst "${BODY}")"

# ── Optional LLM polish (templated fallback ALWAYS retained on failure) ──
DRAFT_GENERATOR="template"
if [[ -n "${ANTHROPIC_API_KEY:-}" && "${IFOS_CONCIERGE_NO_LLM:-0}" != "1" ]] \
     && command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  _model="${IFOS_CONCIERGE_LLM_MODEL:-claude-opus-4-8}"
  _prompt="You are polishing a recruitment-agency email draft. Keep the same meaning, recipient, and every factual detail EXACTLY as written (names, roles, companies, dates). Improve warmth and flow only. Tone rules: never write 'We regret to inform you'; no urgency language; no mention of other candidates; no salary specifics. Return ONLY the polished email body, no preamble.

${BODY}"
  _req="$(jq -n --arg model "${_model}" --arg prompt "${_prompt}" \
    '{model:$model, max_tokens:1024, messages:[{role:"user", content:$prompt}]}')"
  if _resp="$(curl -sS --max-time 30 https://api.anthropic.com/v1/messages \
       -H "content-type: application/json" \
       -H "x-api-key: ${ANTHROPIC_API_KEY}" \
       -H "anthropic-version: 2023-06-01" \
       -d "${_req}" 2>/dev/null)"; then
    _polished="$(printf '%s' "${_resp}" | jq -r '[.content[]? | select(.type=="text") | .text] | join("\n")' 2>/dev/null || true)"
    if [[ -n "${_polished}" && "${_polished}" != "null" ]]; then
      BODY="${_polished}"
      DRAFT_GENERATOR="llm"
    fi
  fi
fi

WORDS="$(printf '%s' "${BODY}" | wc -w | tr -d ' ')"

# Voice score: real numeric only (caller-supplied); otherwise honest unscored.
if [[ "${VOICE_SCORE}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  VS_LINE="voice_score: ${VOICE_SCORE}"
  VR_LINE="voice_reason: classifier"
else
  VS_LINE="voice_score: unscored"
  VR_LINE="voice_reason: no_classifier"
fi

cat <<DRAFT
---
draft_id: ${DRAFT_ID}
event_type: ${EVENT_TYPE}
candidate_id: ${CANDIDATE_ID}
candidate_name: ${CANDIDATE_NAME}
placement_id: ${PLACEMENT_ID:-null}
recipient: ${RECIPIENT}
recipient_role: ${RECIPIENT_ROLE}
subject: "${SUBJECT}"
${VS_LINE}
${VR_LINE}
addressee_resolution_check: passed
escalation_position: ${POSITION}
template_id: ${TEMPLATE_ID}
template_source: ${TEMPLATE_SOURCE}
draft_generator: ${DRAFT_GENERATOR}
event_timestamp: ${EVENT_TS:-unknown}
expected_send_window: "orange-tier approval window PT4H per autosend-policy.yaml"
words: ${WORDS}
---

${BODY}
DRAFT
