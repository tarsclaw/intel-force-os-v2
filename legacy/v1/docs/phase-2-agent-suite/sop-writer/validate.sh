#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

[[ ! "$FILE_PATH" =~ /vault/sops/[^/]+\.md$ ]] && exit 0
# Skip the _index.md and _template.md files
[[ "$FILE_PATH" =~ /_(index|template)\.md$ ]] && exit 0

[[ ! -f "$FILE_PATH" ]] && { hh_fail "File does not exist: $FILE_PATH"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH")

# Filename convention: NN-kebab-case.md
if [[ ! "$BASENAME" =~ ^[0-9]{2}-[a-z0-9-]+\.md$ ]]; then
  hh_fail "SOP filename must match NN-kebab-case-name.md. Got: $BASENAME"
fi

# Frontmatter required fields
for key in type title category owner frequency trigger version last_verified verify_every_days drafted_at drafted_by status; do
  echo "$CONTENT" | grep -qE "^${key}:" || hh_fail "Frontmatter missing: '$key'"
done

# Required sections in body
for heading in "When to run this" "Preconditions" "Inputs" "Steps" "Outputs" "Success criteria" "Escalation" "Change log"; do
  if ! echo "$CONTENT" | grep -qE "^##.*${heading}"; then
    hh_fail "Missing required section containing heading: '$heading'"
  fi
done

# Steps section: must have at least 2 numbered steps with checkbox + action verb pattern
STEP_COUNT=$(echo "$CONTENT" | grep -cE '^[0-9]+\. \[ \] \*\*[A-Z]' || true)
if (( STEP_COUNT < 2 )); then
  hh_fail "Steps section has $STEP_COUNT properly-formatted steps. Minimum 2. Format: '1. [ ] **Verb object** — specifics'"
fi

# Length cap
hh_check_word_count "$CONTENT" 150 1200

# Universal checks
hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"

hh_report_and_exit
