#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

# Librarian writes to /vault/daily/, /outbox/librarian/, and /tenant/.claude/state/
case "$FILE_PATH" in
  */vault/daily/*.md)
    ;;
  */outbox/librarian/*)
    # Findings file — very loose structure
    [[ -f "$FILE_PATH" ]] || { hh_fail "File does not exist"; hh_report_and_exit; }
    exit 0
    ;;
  */state/librarian-last-run.json)
    # State file — validate JSON
    if ! jq -e . "$FILE_PATH" >/dev/null 2>&1; then
      hh_fail "librarian-last-run.json is not valid JSON"
    fi
    hh_report_and_exit
    ;;
  *)
    exit 0
    ;;
esac

[[ ! -f "$FILE_PATH" ]] && { hh_fail "File does not exist: $FILE_PATH"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH")

# Daily rollup checks
if [[ "$FILE_PATH" =~ /vault/daily/ ]]; then
  # Filename must be YYYY-MM-DD.md
  if [[ ! "$BASENAME" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$ ]]; then
    hh_fail "Daily rollup filename must be YYYY-MM-DD.md. Got: $BASENAME"
  fi

  # Frontmatter
  for key in type date generated_by; do
    echo "$CONTENT" | grep -qE "^${key}:" || hh_fail "Rollup frontmatter missing: '$key'"
  done

  # Required sections
  for heading in "Needs attention" "Yesterday's agent activity" "Vault stats"; do
    if ! echo "$CONTENT" | grep -qE "^##.*${heading}"; then
      hh_fail "Daily rollup missing required section: '$heading'"
    fi
  done

  # Length bound — keep short
  WORDS=$(echo "$CONTENT" | wc -w | tr -d ' ')
  if (( WORDS > 500 )); then
    hh_fail "Daily rollup is $WORDS words — exceeds 500-word cap. Humans don't read long rollups. Cut."
  fi
fi

hh_check_no_placeholders "$CONTENT"

hh_report_and_exit
