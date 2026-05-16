#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

[[ ! "$FILE_PATH" =~ /vault/content/(social|email)/.*\.md$ ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && { hh_fail "File does not exist: $FILE_PATH"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH")

# Frontmatter: every derivative must have type, source_piece, platform, status
for key in type source_piece platform drafted_at drafted_by status; do
  if ! echo "$CONTENT" | grep -qE "^${key}:"; then
    hh_fail "Frontmatter missing: '$key' in $BASENAME"
  fi
done

if ! echo "$CONTENT" | grep -qE "^status:\s*draft-awaiting-review\s*$"; then
  hh_fail "Status must be 'draft-awaiting-review' on initial write"
fi

# Platform-specific length checks
case "$BASENAME" in
  *-linkedin.md)
    # Strip frontmatter for word count
    BODY=$(awk '/^---$/{c++; next} c>=2' "$FILE_PATH")
    WORDS=$(echo "$BODY" | wc -w | tr -d ' ')
    if (( WORDS < 80 )); then hh_fail "LinkedIn post is $WORDS words — below platform-appropriate minimum 80"; fi
    if (( WORDS > 350 )); then hh_fail "LinkedIn post is $WORDS words — above recommended max 350"; fi
    ;;
  *-instagram.md)
    BODY=$(awk '/^---$/{c++; next} c>=2' "$FILE_PATH")
    WORDS=$(echo "$BODY" | wc -w | tr -d ' ')
    if (( WORDS < 40 )); then hh_fail "Instagram caption is $WORDS words — too short for context"; fi
    if (( WORDS > 200 )); then hh_fail "Instagram caption is $WORDS words — above 200 breaks 'more' truncation"; fi
    ;;
  *-twitter.md)
    BODY=$(awk '/^---$/{c++; next} c>=2' "$FILE_PATH")
    # For single post, check 280 char limit on the longest line
    # For thread, separators are ---
    if echo "$BODY" | grep -q '^---$'; then
      # Thread mode — each segment must be under 280
      MAX_SEG=$(awk 'BEGIN{RS="\n---\n"} {gsub(/\n/," "); if (length > m) m=length} END{print m}' <<< "$BODY")
      if (( MAX_SEG > 280 )); then hh_fail "Twitter thread has a segment of $MAX_SEG chars (>280)"; fi
    else
      CHARS=$(echo -n "$BODY" | wc -c | tr -d ' ')
      if (( CHARS > 280 )); then hh_fail "Twitter post is $CHARS chars (>280)"; fi
    fi
    ;;
  *-email.md)
    BODY=$(awk '/^---$/{c++; next} c>=2' "$FILE_PATH")
    WORDS=$(echo "$BODY" | wc -w | tr -d ' ')
    if (( WORDS < 250 )); then hh_fail "Email segment is $WORDS words — below useful minimum 250"; fi
    if (( WORDS > 600 )); then hh_fail "Email segment is $WORDS words — above max 600"; fi
    # Must have a subject line in frontmatter
    if ! echo "$CONTENT" | grep -qE "^subject:"; then
      hh_fail "Email derivative missing 'subject:' in frontmatter"
    fi
    ;;
  *-atomisation.md)
    # Index file — must list derivatives_produced
    if ! echo "$CONTENT" | grep -qE "^derivatives_produced:"; then
      hh_fail "Atomisation index missing 'derivatives_produced:' list"
    fi
    ;;
esac

# Universal checks
hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"
hh_check_client_banned_phrases "$CONTENT"

hh_report_and_exit
