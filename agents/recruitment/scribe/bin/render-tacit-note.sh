#!/usr/bin/env bash
# Scribe — Step 6 tacit-note renderer (agent.md §3 Output 2 + 8-category taxonomy).
#
# Prints ONE tacit-note markdown document (YAML frontmatter + body) to stdout.
# Deterministic + zero-LLM-dependency (CC render-chase-draft.sh precedent):
# the same transcript always renders the same note, so it is fixture-testable.
# cycle.sh Step 6 captures stdout → writes the physical vault file (0600) and
# emits METADATA only ({vault_path, body_sha256, voice_score}) to decision_log
# per ADR-002 — the narrative body NEVER enters Postgres.
#
# Taxonomy v0.1 (agent.md §3, 8 categories) — observations are derived per
# transcript line by keyword cue, capped, and timestamped where the transcript
# carries [MM:SS] prefixes. Privacy tone rules applied (agent.md §7):
#   - no verbatim quote longer than 12 words (lines are clipped)
#   - no compensation specifics in the narrative (salary lines are skipped —
#     those belong in structured fields only)
# Word cap ≤800 enforced (agent.md §3; G-word-cap in validate.sh).
#
# Voice: this renderer does NOT fake a voice score. cycle.sh resolves the
# score (forced test score | unscored/no_corpus | unscored/no_classifier) and
# passes it through --voice-score/--voice-reason for the frontmatter.
#
# Usage:
#   render-tacit-note.sh --call-id ID --date YYYY-MM-DD --transcript <path> \
#     [--participants "a@x,b@y"] [--duration-min N] [--context "summary"] \
#     [--voice-score S] [--voice-reason R] [--needs-review]

set -euo pipefail

CALL_ID="" DATE="" TRANSCRIPT="" PARTICIPANTS="" DURATION="" CONTEXT=""
VOICE_SCORE="unscored" VOICE_REASON="no_corpus" NEEDS_REVIEW="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --call-id)      CALL_ID="${2:-}"; shift 2 ;;
    --date)         DATE="${2:-}"; shift 2 ;;
    --transcript)   TRANSCRIPT="${2:-}"; shift 2 ;;
    --participants) PARTICIPANTS="${2:-}"; shift 2 ;;
    --duration-min) DURATION="${2:-}"; shift 2 ;;
    --context)      CONTEXT="${2:-}"; shift 2 ;;
    --voice-score)  VOICE_SCORE="${2:-}"; shift 2 ;;
    --voice-reason) VOICE_REASON="${2:-}"; shift 2 ;;
    --needs-review) NEEDS_REVIEW="true"; shift ;;
    *) printf 'render-tacit-note.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done
if [[ -z "${CALL_ID}" || -z "${DATE}" || -z "${TRANSCRIPT}" || ! -f "${TRANSCRIPT}" ]]; then
  printf 'render-tacit-note.sh: --call-id, --date and --transcript <existing file> required\n' >&2
  exit 2
fi

# Clip a line to ≤12 words (privacy tone rule: paraphrase-length only).
_clip12() {
  awk '{ n = (NF > 12 ? 12 : NF); out = ""; for (i = 1; i <= n; i++) out = out (i>1 ? " " : "") $i; if (NF > 12) out = out " …"; print out }' <<<"$1"
}
# Timestamp prefix ("[MM:SS]") if present on the source line, else empty.
_ts() { sed -nE 's/^(\[[0-9]+:[0-9]{2}\]).*/\1/p' <<<"$1" | head -1; }
# Strip "[MM:SS] speaker:" prefix → bare utterance text.
_utt() { sed -E 's/^\[[0-9]+:[0-9]{2}\][[:space:]]*//; s/^[^:]{1,60}:[[:space:]]*//' <<<"$1"; }

# Per-category keyword cues (taxonomy v0.1; agent.md §3 categories 1-8).
declare -a CAT_LABELS=(
  "Relationship signal" "Process friction" "Competitive intel" "Pricing/budget signal"
  "Decision-process insight" "Calendar/availability nuance" "Cultural fit observation" "Risk flag"
)
declare -a CAT_PATTERNS=(
  "warm|enthusias|friendly|friction|supportive|rapport|happy to be"
  "overwhelm|complaint|tool gap|slow process|time wast|paperwork|admin burden"
  "competitor|another agency|other recruiters|also talking to"
  "budget|fee|rate card|room on price|tight on cost"
  "decide|decision|sign[- ]off|approval|stakeholder|politics"
  "vacation|holiday|available|interview week|away next|life event"
  "culture|working style|team feel|communication style|remote-first"
  "ir35|compliance|legal|reference|right to work|risk"
)

OBS=""      # observations (categorised)
TONE=""     # tone signals
QUESTIONS=""  # open questions
_obs_count=0

while IFS= read -r line; do
  [[ -z "${line//[[:space:]]/}" ]] && continue
  # Privacy: skip compensation specifics entirely (structured fields own those).
  if printf '%s' "${line}" | grep -qiE '£[0-9]|salary|day rate'; then continue; fi
  ts="$(_ts "${line}")"
  utt="$(_utt "${line}")"
  clipped="$(_clip12 "${utt}")"
  for i in "${!CAT_PATTERNS[@]}"; do
    if printf '%s' "${line}" | grep -qiE "${CAT_PATTERNS[$i]}"; then
      if (( _obs_count < 8 )); then
        OBS+="- ${CAT_LABELS[$i]}: ${clipped}${ts:+ ${ts}}"$'\n'
        _obs_count=$((_obs_count + 1))
      fi
      break
    fi
  done
  if printf '%s' "${line}" | grep -qiE '(sounded|seemed|felt) (frustrated|excited|hesitant|relieved|positive|negative)|tone'; then
    TONE+="- $(_clip12 "${utt}")"$'\n'
  fi
  if [[ "${utt}" == *\?* ]] && [[ "$(printf '%s' "${QUESTIONS}" | grep -c '^-' || true)" -lt 3 ]]; then
    QUESTIONS+="- Follow up: $(_clip12 "${utt}")"$'\n'
  fi
done < "${TRANSCRIPT}"

# Privacy (agent.md §7 tone rules): participant emails never enter the
# narrative — render local parts only ("jane.doe" not "jane.doe@x.test").
# Any third-party email inside an utterance still surfaces and is caught by
# the Gate A G6 check, which scans the FULL rendered note body resolved from
# tacit_note.vault_path — not just a preview (that is outside-boundary PII;
# participants are not).
PARTICIPANTS_DISPLAY="$(printf '%s' "${PARTICIPANTS}" | tr ',' '\n' | sed -E 's/@.*$//' | paste -sd ', ' -)"

[[ -z "${OBS}" ]] && OBS="- (no taxonomy-cued observations in this transcript)"$'\n'
[[ -z "${TONE}" ]] && TONE="- (no explicit tone signals detected)"$'\n'
[[ -z "${QUESTIONS}" ]] && QUESTIONS="- (none captured)"$'\n'

BODY="# Tacit notes — ${CONTEXT:-call ${CALL_ID}}
**Date:** ${DATE}  **Duration:** ${DURATION:-?} min  **Participants:** ${PARTICIPANTS_DISPLAY:-unknown}

## Things observed that don't fit a structured field

${OBS}
## Tone signals

${TONE}
## Open questions for consultant follow-up

${QUESTIONS}"

# Word cap ≤800 (agent.md §3). The deterministic template is short by
# construction; the guard hard-truncates if a pathological transcript blows it.
_words="$(printf '%s' "${BODY}" | wc -w | tr -d ' ')"
if (( _words > 800 )); then
  BODY="$(printf '%s' "${BODY}" | awk '{ for (i=1;i<=NF;i++) { n++; if (n>790) exit; printf "%s ", $i } }')
…(truncated at 800-word cap per agent.md §3)"
fi

cat <<NOTE
---
call_id: ${CALL_ID}
date: ${DATE}
voice_score: ${VOICE_SCORE}
voice_reason: ${VOICE_REASON}
needs_consultant_review: ${NEEDS_REVIEW}
taxonomy_version: "0.1"
---

${BODY}
NOTE
