#!/usr/bin/env bash
# Janitor — tacit-note narrative renderer (agent.md §4 Step 8 + §7).
#
# Renders the per-entity-type narrative summary of consultant-approved edits
# harvested from recent_edit (resolution='approved_after_edit', 30d window).
#
# v1.0 voice posture (CC + Scout precedent): the DETERMINISTIC template below
# is the always-available base. When ANTHROPIC_API_KEY is set (and the
# IFOS_JANITOR_NO_LLM=1 fixture guard is NOT set), the template is polished
# via one Anthropic Messages API call; ANY failure falls back to the template
# silently. The narrative is built ONLY from aggregate facts (counts +
# action_types + entity type) — raw recent_edit original_text/edited_text is
# NEVER passed to the LLM or embedded in the note, so no candidate/client PII
# can leak into the narrative (validate.sh G6 defence-in-depth still scans).
#
# Voice scoring: no embedding classifier exists at v1.0 and dev tenants carry
# an empty voice_corpus, so the score is recorded honestly by the CALLER as
# unscored/no_corpus (never a faked number). IFOS_JANITOR_FORCE_VOICE_SCORE
# exercises the scored ESC_VOICE_DRIFT route in fixtures.
#
# Usage:
#   render-tacit-note.sh --entity-type candidate --edit-count 4 \
#     --action-types "note_rewrite,status_change" --window-days 30
#
# Output (stdout): narrative text (plain prose; no markdown headers — it goes
# into a Bullhorn Note comments body).

set -euo pipefail

ENTITY_TYPE=""
EDIT_COUNT="0"
ACTION_TYPES=""
WINDOW_DAYS="30"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --entity-type)  ENTITY_TYPE="${2:-}"; shift 2 ;;
    --edit-count)   EDIT_COUNT="${2:-0}"; shift 2 ;;
    --action-types) ACTION_TYPES="${2:-}"; shift 2 ;;
    --window-days)  WINDOW_DAYS="${2:-30}"; shift 2 ;;
    *)              printf 'render-tacit-note.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done

if [[ -z "${ENTITY_TYPE}" ]]; then
  printf 'render-tacit-note.sh: --entity-type required\n' >&2
  exit 2
fi

# ── Deterministic base template (always produced) ───────────────────────
_plural="edits"
[[ "${EDIT_COUNT}" == "1" ]] && _plural="edit"
_types_clause=""
if [[ -n "${ACTION_TYPES}" ]]; then
  _types_clause=" The edits covered: ${ACTION_TYPES//,/, }."
fi
TEMPLATE="Internal data-hygiene note (Janitor, automated). Over the last ${WINDOW_DAYS} days, consultants reviewed and approved-after-edit ${EDIT_COUNT} agent ${_plural} touching ${ENTITY_TYPE} records.${_types_clause} The approved corrections have been folded back into the record as tacit knowledge: where consultants consistently rephrased or re-prioritised agent output, future agent drafts for this ${ENTITY_TYPE} should follow the consultant-approved phrasing. No candidate or client personal data is reproduced in this note; see the decision log for the underlying edit references."

# ── Optional LLM polish (active when ANTHROPIC_API_KEY set; fixture guard
#    IFOS_JANITOR_NO_LLM=1 keeps test runs deterministic + offline) ───────
if [[ -n "${ANTHROPIC_API_KEY:-}" && -z "${IFOS_JANITOR_NO_LLM:-}" ]] && command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  _prompt="Rewrite the following internal recruitment-ops data-hygiene note so it reads naturally for a consultant audience. Keep it under 120 words, plain prose, no markdown, no greetings. CRITICAL: do not invent any names, emails, companies or numbers not present in the input.\n\n${TEMPLATE}"
  _body="$(jq -n --arg p "${_prompt}" \
    '{model: "claude-3-5-haiku-latest", max_tokens: 300, messages: [{role: "user", content: $p}]}')"
  _resp="$(curl -sS --max-time 30 https://api.anthropic.com/v1/messages \
    -H "x-api-key: ${ANTHROPIC_API_KEY}" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "${_body}" 2>/dev/null || true)"
  _polished="$(printf '%s' "${_resp}" | jq -r '.content[0].text // empty' 2>/dev/null || true)"
  if [[ -n "${_polished}" ]]; then
    printf '%s\n' "${_polished}"
    exit 0
  fi
  # Fall through to the deterministic template on any API failure.
fi

printf '%s\n' "${TEMPLATE}"
