#!/usr/bin/env bash
# Client Onboarder — PostToolUse hook
# Validates each onboarding artefact's structure.

set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

# Only validate onboarding files
if [[ ! "$FILE_PATH" =~ /vault/clients/[^/]+/onboarding/.*\.md$ ]] \
   && [[ ! "$FILE_PATH" =~ /vault/clients/[^/]+/00-context\.md$ ]] \
   && [[ ! "$FILE_PATH" =~ /vault/clients/[^/]+/content/briefs/.*\.md$ ]]; then
  exit 0
fi

[[ ! -f "$FILE_PATH" ]] && { hh_fail "File does not exist: $FILE_PATH"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH")

# All onboarding artefacts need frontmatter with type + status
if ! echo "$CONTENT" | grep -qE "^---"; then
  hh_fail "Missing YAML frontmatter in $BASENAME"
fi

if ! echo "$CONTENT" | grep -qE "^type:"; then
  hh_fail "Frontmatter missing 'type' field in $BASENAME"
fi

if ! echo "$CONTENT" | grep -qE "^status:\s*draft\s*$"; then
  hh_fail "Frontmatter 'status' must be 'draft' on initial write (enforcing human-review-first principle)"
fi

# Per-artefact rules
case "$BASENAME" in
  01-welcome-email.md)
    # Email: 150-250 words, no placeholders
    hh_check_word_count "$CONTENT" 120 280
    ;;
  02-kickoff-agenda.md)
    # Must have a time-marked agenda
    if ! echo "$CONTENT" | grep -qE '[0-9]{2}:[0-9]{2}'; then
      hh_fail "Kickoff agenda must contain time markers (e.g. 00:00–00:05)"
    fi
    ;;
  03-loom-script.md)
    # Loom script word count — 1050 max (~7 min at 150 wpm)
    LOOM_MAX=$(hh_agent_config '.behaviour.loom_script_max_words // 1050')
    hh_check_word_count "$CONTENT" 400 "$LOOM_MAX"
    # Must have stage directions (bracketed text like [00:00–00:30])
    STAGE_COUNT=$(echo "$CONTENT" | grep -cE '\[[0-9]{2}:[0-9]{2}' || true)
    if (( STAGE_COUNT < 3 )); then
      hh_fail "Loom script needs at least 3 stage-direction markers (e.g. [00:00–00:30])"
    fi
    ;;
  04-access-checklist.md)
    # Every item should have some indication of how to provide
    if ! echo "$CONTENT" | grep -qiE '(how to|add|grant|invite|provide|send)'; then
      hh_fail "Access checklist items must include specific 'how to provide' instructions"
    fi
    ;;
  01-*-first-brief.md)
    # First content brief — must have audience, objective, deliverable title
    for needed in "Audience" "Objective" "Deliverable" "Deadline"; do
      if ! echo "$CONTENT" | grep -qi "$needed"; then
        hh_fail "First content brief missing required field: $needed"
      fi
    done
    ;;
  00-context.md)
    # Internal kickoff note — just needs to exist with content
    if (( $(echo "$CONTENT" | wc -w) < 100 )); then
      hh_fail "Internal context note is under 100 words — too thin for the delivery team"
    fi
    ;;
esac

# Universal checks
hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"
hh_check_client_banned_phrases "$CONTENT"

hh_report_and_exit
