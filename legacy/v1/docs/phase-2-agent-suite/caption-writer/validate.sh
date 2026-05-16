#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

[[ ! "$FILE_PATH" =~ /vault/content/social/captions/.*\.md$ ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && { hh_fail "File does not exist: $FILE_PATH"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")

# Frontmatter
for key in type asset asset_type variants_count drafted_at drafted_by status; do
  echo "$CONTENT" | grep -qE "^${key}:" || hh_fail "Frontmatter missing: '$key'"
done

# Count variants — headings like "## Variant N — angle"
VARIANT_COUNT=$(echo "$CONTENT" | grep -cE '^## Variant [0-9]+ — ' || true)
if (( VARIANT_COUNT < 3 )); then
  hh_fail "Only $VARIANT_COUNT variants found; minimum is 3"
fi
if (( VARIANT_COUNT > 5 )); then
  hh_fail "$VARIANT_COUNT variants found; maximum is 5 (avoid overwhelming the client with too many options)"
fi

# Frontmatter's variants_count must match actual count
DECLARED=$(echo "$CONTENT" | grep -E "^variants_count:" | awk '{print $2}')
if [[ "$DECLARED" != "$VARIANT_COUNT" ]]; then
  hh_fail "Frontmatter variants_count=$DECLARED but actual count=$VARIANT_COUNT"
fi

# Each variant must have a Platform fit and Tone line
VARIANTS_MISSING_META=$(awk '
  /^## Variant [0-9]+/ { in_var=1; has_platform=0; has_tone=0; name=$0; next }
  /^\*Platform fit:\*/ { has_platform=1 }
  /^\*Tone:\*/ { has_tone=1 }
  /^## / && in_var {
    if (!has_platform || !has_tone) print name
    in_var=/^## Variant/
    has_platform=0; has_tone=0
  }
  END { if (in_var && (!has_platform || !has_tone)) print name }
' "$FILE_PATH" | wc -l | tr -d ' ')

if (( VARIANTS_MISSING_META > 0 )); then
  hh_fail "$VARIANTS_MISSING_META variant(s) missing Platform fit or Tone metadata line"
fi

# Universal
hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"
hh_check_client_banned_phrases "$CONTENT"

hh_report_and_exit
