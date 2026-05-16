#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

[[ ! "$FILE_PATH" =~ /vault/content/long-form/.*\.md$ ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && { hh_fail "File does not exist: $FILE_PATH"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")

# Frontmatter required fields
for key in title slug type target_audience objective word_count sources_count drafted_at drafted_by status; do
  if ! echo "$CONTENT" | grep -qE "^${key}:"; then
    hh_fail "Frontmatter missing: '$key'"
  fi
done

# Status must be draft-awaiting-review
if ! echo "$CONTENT" | grep -qE "^status:\s*draft-awaiting-review\s*$"; then
  hh_fail "Status must be 'draft-awaiting-review'"
fi

# Length target — use config default, allow ±20%
TARGET_LENGTH=$(hh_agent_config '.output.default_length_target // 1500')
MIN_LEN=$(( TARGET_LENGTH * 80 / 100 ))
MAX_LEN=$(( TARGET_LENGTH * 120 / 100 ))
# But also clamp to hard bounds 800-2500
(( MIN_LEN < 800 )) && MIN_LEN=800
(( MAX_LEN > 2500 )) && MAX_LEN=2500
hh_check_word_count "$CONTENT" "$MIN_LEN" "$MAX_LEN"

# Count cited sources (markdown links in body + Sources section)
SOURCES_MIN=$(hh_agent_config '.output.required_sources_min // 3')
LINK_COUNT=$(echo "$CONTENT" | grep -oE '\[[^]]+\]\(https?://[^)]+\)' | wc -l | tr -d ' ')
if (( LINK_COUNT < SOURCES_MIN )); then
  hh_fail "Found $LINK_COUNT cited sources; minimum is $SOURCES_MIN. Add markdown-linked citations for core claims."
fi

# Sources section at bottom
if ! echo "$CONTENT" | grep -qE '^## Sources?'; then
  hh_fail "Missing a '## Sources' section at the bottom listing references"
fi

# Opening paragraph generic-check — flag obvious openers
FIRST_PARAGRAPH=$(awk 'BEGIN{RS="\n\n"} /^[A-Z]/ && !/^---/ && !/^#/ && !/^\[/ {print; exit}' "$FILE_PATH")
if echo "$FIRST_PARAGRAPH" | grep -qiE '^(in today|in the (digital|modern) age|many (people|businesses|companies)|have you ever|if you.re (a|an))'; then
  hh_fail "Opening paragraph starts with a generic opener. Rewrite with something specific to the topic."
fi

# Universal checks
hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"
hh_check_client_banned_phrases "$CONTENT"

hh_report_and_exit
