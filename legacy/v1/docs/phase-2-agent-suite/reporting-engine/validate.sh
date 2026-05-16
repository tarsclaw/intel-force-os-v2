#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

[[ ! "$FILE_PATH" =~ /vault/reports/monthly/[0-9]{4}-[0-9]{2}-.+\.md$ ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && { hh_fail "File does not exist: $FILE_PATH"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")

# Frontmatter
for key in type client client_slug period_start period_end drafted_at drafted_by status data_sources_used; do
  echo "$CONTENT" | grep -qE "^${key}:" || hh_fail "Frontmatter missing: '$key'"
done

# Required sections — must have Executive line, What we delivered, The numbers, What moved, What's flagged, Next month focus
for heading in "Executive line" "What we delivered" "The numbers" "What moved" "What's flagged" "Next month focus"; do
  if ! echo "$CONTENT" | grep -qE "^#{2,3}.*${heading}"; then
    hh_fail "Missing required section containing heading: '$heading'"
  fi
done

# Length
hh_check_word_count "$CONTENT" 600 1800

# Must contain a numbers table (look for markdown table syntax in The numbers section)
if ! echo "$CONTENT" | grep -qE '^\|.*\|.*\|'; then
  hh_fail "Report missing a numbers table (expected markdown table in §The numbers)"
fi

# Hedging-phrase check — these specifically undermine a numbers-based report
HEDGES=("significantly" "materially" "substantially" "markedly" "considerably")
BODY_LOWER=$(echo "$CONTENT" | tr '[:upper:]' '[:lower:]')
for hedge in "${HEDGES[@]}"; do
  if echo "$BODY_LOWER" | grep -qE "\\b${hedge}\\b"; then
    # Allow it if followed by a number in same line (e.g. "grew significantly — from 50 to 120" is fine if the number follows)
    COUNT_BAD=$(grep -iE "\\b${hedge}\\b" "$FILE_PATH" | grep -cvE '[0-9]+' || true)
    if (( COUNT_BAD > 0 )); then
      hh_fail "Hedging word '$hedge' used without a concrete number on the same line. Use the number or remove the claim."
    fi
  fi
done

hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"
hh_check_client_banned_phrases "$CONTENT"

hh_report_and_exit
