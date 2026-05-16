#!/usr/bin/env bash
# Lead Hunter — PostToolUse hook
# Validates the prospect list structure after Claude writes it.

set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

# Only validate prospect list files
if [[ ! "$FILE_PATH" =~ /vault/clients/_prospects/.*\.md$ ]]; then
  exit 0
fi

[[ ! -f "$FILE_PATH" ]] && { hh_fail "File $FILE_PATH does not exist"; hh_report_and_exit; }

CONTENT=$(cat "$FILE_PATH")

# --- Structural checks ---

# File naming convention: YYYY-MM-DD-prospect-list.md
if [[ ! "$FILE_PATH" =~ /[0-9]{4}-[0-9]{2}-[0-9]{2}-prospect-list\.md$ ]]; then
  hh_fail "Filename must match YYYY-MM-DD-prospect-list.md. Got: $(basename "$FILE_PATH")"
fi

# Required frontmatter keys
for key in run_date run_mode icp_used search_count qualified_count ranked_count cost_gbp status; do
  if ! echo "$CONTENT" | grep -qE "^${key}:"; then
    hh_fail "Frontmatter missing: '$key'"
  fi
done

# Status must be awaiting-review
if ! echo "$CONTENT" | grep -qE "^status:\s*awaiting-review\s*$"; then
  hh_fail "Status must be 'awaiting-review' on initial write"
fi

# Must contain Ranked prospects section
if ! echo "$CONTENT" | grep -qE "^## Ranked prospects"; then
  hh_fail "Missing required section: '## Ranked prospects'"
fi

# --- Per-prospect structural checks ---
# Each ranked entry starts with ### {N}. {name} — {score}/100
PROSPECT_HEADINGS=$(echo "$CONTENT" | grep -cE '^### [0-9]+\. .+ — [0-9]+/100')
if (( PROSPECT_HEADINGS < 5 )); then
  hh_fail "Only $PROSPECT_HEADINGS ranked prospects found — expected at least 5 for a useful list. Consider escalating NO_RESULTS_FOUND upstream."
fi

# Every prospect section should have Contact: line with email
PROSPECTS_WITHOUT_CONTACT=$(awk '
  /^### [0-9]+\./ { p=1; has_contact=0; name=$0; next }
  /^\*\*Contact:\*\*/ && p { has_contact=1 }
  /^### [0-9]+\./ || /^## / {
    if (p && !has_contact) print name
    p = /^### [0-9]+\./
    has_contact = 0
  }
  END { if (p && !has_contact) print name }
' "$FILE_PATH" | wc -l | tr -d ' ')

if (( PROSPECTS_WITHOUT_CONTACT > 0 )); then
  hh_fail "$PROSPECTS_WITHOUT_CONTACT prospect(s) missing **Contact:** line. Every ranked prospect must have a verified contact."
fi

# Every prospect section should have Why this one: line
PROSPECTS_WITHOUT_WHY=$(awk '
  /^### [0-9]+\./ { p=1; has_why=0; name=$0; next }
  /^\*\*Why this one:\*\*/ && p { has_why=1 }
  /^### [0-9]+\./ || /^## / {
    if (p && !has_why) print name
    p = /^### [0-9]+\./
    has_why = 0
  }
  END { if (p && !has_why) print name }
' "$FILE_PATH" | wc -l | tr -d ' ')

if (( PROSPECTS_WITHOUT_WHY > 0 )); then
  hh_fail "$PROSPECTS_WITHOUT_WHY prospect(s) missing **Why this one:** line."
fi

# --- Suppression list cross-check ---
# Hard fail if any domain in the prospect list appears in the suppression list
SUPPRESSION_PATH="/tenant/vault/brand/suppression-list.md"
if [[ -f "$SUPPRESSION_PATH" ]]; then
  # Extract domains from suppression list (assumes one-per-line format or markdown list)
  SUPPRESSION_DOMAINS=$(grep -oE '[a-zA-Z0-9][-a-zA-Z0-9.]+\.[a-zA-Z]{2,}' "$SUPPRESSION_PATH" | sort -u)
  while IFS= read -r domain; do
    [[ -z "$domain" ]] && continue
    if echo "$CONTENT" | grep -qF "@$domain"; then
      hh_fail "SUPPRESSION VIOLATION — domain '$domain' appears in prospect list but is on suppression list"
    fi
  done <<< "$SUPPRESSION_DOMAINS"
fi

# --- Universal checks ---
hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"

hh_report_and_exit
