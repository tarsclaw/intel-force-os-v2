#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

[[ ! "$FILE_PATH" =~ /vault/clients/[^/]+/follow-up/.*\.md$ ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && { hh_fail "File does not exist: $FILE_PATH"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH")

# Frontmatter check
for key in type prospect status drafted_at drafted_by; do
  echo "$CONTENT" | grep -qE "^${key}:" || hh_fail "Frontmatter missing: '$key' in $BASENAME"
done

# Per-file-type checks
case "$BASENAME" in
  *sequence-plan*)
    echo "$CONTENT" | grep -qE "^sequence_emails:" || hh_fail "Sequence plan missing sequence_emails list"
    ;;
  *email-01*|*email-02*|*email-03*|*email-04*|*email-05*)
    # Frontmatter needs: sequence_position, suggested_send_date, subject, stall_reason, references_from_prior, word_count
    for key in sequence_position suggested_send_date subject stall_reason references_from_prior word_count; do
      echo "$CONTENT" | grep -qE "^${key}:" || hh_fail "Email frontmatter missing: '$key'"
    done

    # Extract body (after second ---)
    BODY=$(awk '/^---$/{c++; next} c>=2' "$FILE_PATH")
    WORDS=$(echo "$BODY" | wc -w | tr -d ' ')

    # Email 1: max 180, Email 2: max 120, Email 3: max 90
    if [[ "$BASENAME" =~ email-01 ]]; then
      if (( WORDS > 180 )); then hh_fail "Email 1 is $WORDS words; max 180"; fi
      if (( WORDS < 30 )); then hh_fail "Email 1 is $WORDS words; too short"; fi
    elif [[ "$BASENAME" =~ email-02 ]]; then
      if (( WORDS > 120 )); then hh_fail "Email 2 is $WORDS words; max 120"; fi
    elif [[ "$BASENAME" =~ email-03 ]]; then
      if (( WORDS > 90 )); then hh_fail "Email 3 is $WORDS words; max 90"; fi
      # Email 3 must contain permission-to-say-no language
      if ! echo "$BODY" | grep -qiE '(not right now|park it|park this|no works|if this isn.t|not interested)'; then
        hh_fail "Email 3 must include explicit permission for prospect to say no"
      fi
    fi

    # Banned follow-up phrases (on top of universal bans)
    for phrase in "just checking in" "circling back" "bumping this" "touching base" "gentle reminder" "following up to see"; do
      if echo "$BODY" | tr '[:upper:]' '[:lower:]' | grep -qF "$phrase"; then
        hh_fail "Generic follow-up phrase found: '$phrase'. Rewrite specifically."
      fi
    done
    ;;
esac

hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"
hh_check_client_banned_phrases "$CONTENT"

hh_report_and_exit
