#!/usr/bin/env bash
# proposal-builder/validate.sh
#
# PostToolUse hook for the Proposal Builder agent.
# Runs after any Write or Edit on a file under /vault/clients/**/proposals/.
#
# Implements the seven Quality Gates from agent.md:
#   Gate 1 — Price justification (checked semantically via LLM-as-judge, NOT here)
#   Gate 2 — Timeline realism (semantic; not checked here)
#   Gate 3 — Verbatim transcript quotes (partial — checks for quote markers)
#   Gate 4 — No placeholders (HARD check here)
#   Gate 5 — Length bounds 800–2500 words (HARD check here)
#   Gate 6 — Voice match (semantic; not checked here)
#   Gate 7 — Case study relevance (semantic; not checked here)
#
# Additional structural checks enforced here that aren't explicit "gates":
#   - File path is correct (under /vault/clients/{slug}/proposals/)
#   - YAML frontmatter present and valid
#   - All 9 required sections present in exact order
#   - Prices format correctly (£ followed by digits, no decimals, comma-separated)
#   - Markdown parses without errors
#
# Exit codes:
#   0 — all structural gates pass; semantic gates to be evaluated by LLM-judge
#   1 — one or more structural gates failed; failure details printed to stdout
#       for injection into Claude's context, so it self-corrects.
#   2 — script internal error (bug in validation logic)
#
# Claude Code behaviour on exit 1: the printed failure details are appended to
# the agent's context. The agent sees the errors and revises in the same session.

set -euo pipefail

# ----------------------------------------------------------------------------
# Environment — passed in by Claude Code hook runner via JSON on stdin
# ----------------------------------------------------------------------------
# Hook receives JSON on stdin with: {tool_name, tool_input, cwd, session_id}
# tool_input.file_path gives us the file that was just written.

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // "unknown"')

# Only validate files that look like proposals. Silently pass through anything else.
if [[ ! "$FILE_PATH" =~ /vault/clients/[^/]+/proposals/.*\.md$ ]]; then
  exit 0
fi

# ----------------------------------------------------------------------------
# Logging helpers
# ----------------------------------------------------------------------------
FAILURES=()

fail() {
  FAILURES+=("$1")
}

log_telemetry() {
  # Emit a structured log event for observability
  local event="$1"
  local status="$2"
  local details="$3"
  cat <<EOF >> "/tenant/logs/validate-$(date +%Y%m%d).jsonl"
{"ts":"$(date -Iseconds)","session_id":"$SESSION_ID","agent":"proposal-builder","event":"$event","status":"$status","file":"$FILE_PATH","details":$details}
EOF
}

# ----------------------------------------------------------------------------
# Load file content
# ----------------------------------------------------------------------------
if [[ ! -f "$FILE_PATH" ]]; then
  fail "File $FILE_PATH does not exist."
  log_telemetry "validate" "error" "\"file_missing\""
  printf "%s\n" "${FAILURES[@]}"
  exit 1
fi

CONTENT=$(cat "$FILE_PATH")

# ----------------------------------------------------------------------------
# CHECK 1 — File path matches convention
# ----------------------------------------------------------------------------
# Expected: /vault/clients/{slug}/proposals/{YYYY-MM-DD}-{slug}-v{n}.md
if [[ ! "$FILE_PATH" =~ /vault/clients/[a-z0-9-]+/proposals/[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+-v[0-9]+\.md$ ]]; then
  fail "File path does not match the canonical pattern: /vault/clients/{slug}/proposals/{YYYY-MM-DD}-{slug}-v{n}.md. Got: $FILE_PATH"
fi

# ----------------------------------------------------------------------------
# CHECK 2 — YAML frontmatter present and complete
# ----------------------------------------------------------------------------
# Must begin with '---', close with '---', contain required keys.
if [[ ! "$CONTENT" =~ ^---[[:space:]]*\n ]]; then
  fail "Missing YAML frontmatter — the file must begin with '---' on line 1."
else
  # Extract frontmatter (between first pair of --- delimiters)
  FRONTMATTER=$(awk '/^---$/{c++; if(c==2) exit} c>=1' "$FILE_PATH" | sed '1d;$d')

  REQUIRED_KEYS=(
    "prospect" "deal_value" "tier" "call_id" "call_url"
    "drafted_at" "drafted_by" "status" "sales_lead" "tags"
  )

  for key in "${REQUIRED_KEYS[@]}"; do
    if ! echo "$FRONTMATTER" | grep -qE "^${key}:"; then
      fail "Frontmatter missing required key: '$key'"
    fi
  done

  # Specific value validations
  if ! echo "$FRONTMATTER" | grep -qE '^status:\s*draft-awaiting-review\s*$'; then
    fail "Frontmatter 'status' must be exactly 'draft-awaiting-review' on initial draft (this is a safety invariant — do not change)."
  fi
fi

# ----------------------------------------------------------------------------
# CHECK 3 — All 9 required sections present in exact order
# ----------------------------------------------------------------------------
# Output Specification §1–§9. Each is a ### level heading.
# We check both presence and order.
REQUIRED_HEADINGS=(
  "### 1."
  "### 2."
  "### 3."
  "### 4."
  "### 5."
  "### 6."
  "### 7."
  "### 8."
  "### 9."
)

# Extract the list of ### headings from the content, in order.
# Using grep with -o and then checking that they appear in the right sequence.
HEADINGS_FOUND=$(echo "$CONTENT" | grep -oE '^### [0-9]+\.' | head -20)
EXPECTED_SEQUENCE="### 1.
### 2.
### 3.
### 4.
### 5.
### 6.
### 7.
### 8.
### 9."

if [[ "$HEADINGS_FOUND" != "$EXPECTED_SEQUENCE" ]]; then
  fail "The 9 required sections (### 1. through ### 9.) are not present in the correct order. Found: $(echo "$HEADINGS_FOUND" | tr '\n' ' '). Expected: 1 through 9 in order. Refer to agent.md Output Specification."
fi

# ----------------------------------------------------------------------------
# CHECK 4 — No placeholders (GATE 4, hard enforcement)
# ----------------------------------------------------------------------------
PLACEHOLDER_PATTERNS=(
  "\\bTBD\\b"
  "\\bTBC\\b"
  "\\[INSERT"
  "\\[PLACEHOLDER"
  "\\{\\{"
  "\\bXXX\\b"
  "\\?\\?\\?"
  "\\bFIXME\\b"
  "\\bTODO\\b"
  "\\[DRAFT-NOTE"
)

for pattern in "${PLACEHOLDER_PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -qE "$pattern"; then
    MATCHES=$(echo "$CONTENT" | grep -nE "$pattern" | head -3)
    fail "Quality Gate 4 FAIL — placeholder pattern '$pattern' found in output. A proposal going to a sales lead cannot contain placeholders. Matches: $MATCHES"
  fi
done

# ----------------------------------------------------------------------------
# CHECK 5 — Length bounds 800–2500 words (GATE 5, hard enforcement)
# ----------------------------------------------------------------------------
WORD_COUNT=$(echo "$CONTENT" | wc -w | tr -d ' ')

if (( WORD_COUNT < 800 )); then
  fail "Quality Gate 5 FAIL — proposal is $WORD_COUNT words. Minimum is 800. Either the scope is too sparse or sections were omitted. Check that all 9 sections have substantive content."
fi

if (( WORD_COUNT > 2500 )); then
  fail "Quality Gate 5 FAIL — proposal is $WORD_COUNT words. Maximum is 2500. You've padded. Cut back to the essentials. The prospect will read 2500 words; they won't read 3500."
fi

# ----------------------------------------------------------------------------
# CHECK 6 — Price format
# ----------------------------------------------------------------------------
# Prices must match £ followed by digits (optionally with comma-thousands).
# No decimals unless VAT-inclusive and explicitly marked.
# At least one £-price must appear (Section 6 Investment requires prices).

PRICE_COUNT=$(echo "$CONTENT" | grep -oE '£[0-9,]+' | wc -l | tr -d ' ')

if (( PRICE_COUNT == 0 )); then
  fail "No prices (£...) found in the proposal. Section 6 (Investment) requires at least one price per tier."
fi

# Check for malformed prices
if echo "$CONTENT" | grep -qE '£[0-9]+\.[0-9]{3,}'; then
  fail "Malformed price found — too many decimal places. Round to realistic whole numbers (e.g. £4,800, not £4,800.00 or £4,791.34)."
fi

if echo "$CONTENT" | grep -qE '£0\b|£[0-9]{1,2}\b'; then
  fail "Implausibly small price found. Proposals for this client start at the minimum_engagement_value threshold."
fi

# ----------------------------------------------------------------------------
# CHECK 7 — Quote markers present (GATE 3, partial)
# ----------------------------------------------------------------------------
# We can't verify quotes are actually from the transcript without access to
# the transcript here. But we can check that at least two blockquotes or
# quoted-phrases appear in the content — a proxy for Gate 3.
#
# Semantic quote-match is done by the LLM-as-judge pass after this.

# Count blockquotes (lines starting with '>') AND double-quoted phrases in prose.
BLOCKQUOTE_COUNT=$(echo "$CONTENT" | grep -cE '^>' || true)
QUOTED_PHRASE_COUNT=$(echo "$CONTENT" | grep -oE '"[^"]{3,100}"' | wc -l | tr -d ' ')

TOTAL_QUOTE_INDICATORS=$((BLOCKQUOTE_COUNT + QUOTED_PHRASE_COUNT))

if (( TOTAL_QUOTE_INDICATORS < 2 )); then
  fail "Quality Gate 3 FAIL (partial) — fewer than 2 quote indicators found (blockquotes + quoted phrases = $TOTAL_QUOTE_INDICATORS). The agent.md requires at least 2 verbatim quotes from the prospect's own words. Add them in Section 1 (Opening) and/or Section 2 (Their situation)."
fi

# ----------------------------------------------------------------------------
# CHECK 8 — Banned phrases (voice-profile-independent, always-banned AI tells)
# ----------------------------------------------------------------------------
# These are universal AI tells that never belong in a client-facing proposal.
# Client-specific banned phrases come from voice_profile.md and are checked
# by the LLM-as-judge pass.

UNIVERSAL_BANNED_PHRASES=(
  "In today's fast-paced world"
  "In the ever-evolving landscape"
  "cutting-edge solution"
  "revolutionise your"
  "game-changing"
  "synergis"           # catches synergise, synergies, synergistic
  "leverage our"
  "best-in-class"
  "state-of-the-art"
  "Let's dive in"
  "It's worth noting that"
  "We are excited to"
  "Thank you for the opportunity"
)

# Case-insensitive matching
CONTENT_LOWER=$(echo "$CONTENT" | tr '[:upper:]' '[:lower:]')
for phrase in "${UNIVERSAL_BANNED_PHRASES[@]}"; do
  phrase_lower=$(echo "$phrase" | tr '[:upper:]' '[:lower:]')
  if echo "$CONTENT_LOWER" | grep -qF "$phrase_lower"; then
    fail "Banned AI-tell phrase found: '$phrase'. This phrase is a universal red flag for AI-generated text. Rewrite the sentence with client-voice-appropriate language."
  fi
done

# ----------------------------------------------------------------------------
# CHECK 9 — Signature block presence
# ----------------------------------------------------------------------------
# Section 9 is the signature block. It must have at least a name and contact info.
# We check by looking for an email-pattern or phone-pattern in the last 500 chars.

LAST_SECTION=$(echo "$CONTENT" | tail -c 500)

if ! echo "$LAST_SECTION" | grep -qE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'; then
  fail "Section 9 (Signature block) does not appear to contain a contact email. Verify sales_lead.signature_block is populated in tenant config."
fi

# ----------------------------------------------------------------------------
# Result
# ----------------------------------------------------------------------------
if (( ${#FAILURES[@]} > 0 )); then
  echo "=== PROPOSAL BUILDER VALIDATION FAILED ==="
  echo "File: $FILE_PATH"
  echo "Word count: $WORD_COUNT"
  echo ""
  echo "The following issues must be corrected before this proposal can be considered complete:"
  echo ""
  for i in "${!FAILURES[@]}"; do
    printf "%d. %s\n\n" "$((i+1))" "${FAILURES[$i]}"
  done
  echo ""
  echo "Revise the proposal addressing every issue above, then the hook will re-run automatically after the next Write."

  log_telemetry "validate" "fail" "{\"failure_count\":${#FAILURES[@]},\"word_count\":$WORD_COUNT}"
  exit 1
fi

# Success path — brief log, quiet exit
log_telemetry "validate" "pass" "{\"word_count\":$WORD_COUNT,\"price_count\":$PRICE_COUNT}"
exit 0
