#!/usr/bin/env bash
# proposal-builder/context.sh
#
# SessionStart hook for the Proposal Builder agent.
#
# Purpose: when Claude Code spawns a session to run Proposal Builder, this
# script populates the <!-- CONTEXT-START --> / <!-- CONTEXT-END --> block in
# agent.md with fresh, task-specific context retrieved from the vault.
#
# How it works:
#   1. Claude Code reads the trigger payload from /tenant/intake/fathom/{id}.json.
#      This file was dropped there by the webhook receiver when the call ended.
#   2. We extract the prospect identity (domain, company name) from the payload.
#   3. We retrieve the client's voice profile, pricing framework, and the top-k
#      most-similar past winning proposals using a pgvector semantic search.
#   4. We assemble the full context block and write it into the working copy
#      of agent.md that this session will read.
#
# This script runs inside the tenant container at session start. It has access
# to the full tenant vault filesystem. It has read-only network access to the
# embedding provider (Cohere) and the pgvector database.
#
# Exit codes:
#   0 — context assembled successfully
#   1 — recoverable error (e.g., retrieval failed but we can proceed with
#       voice profile only; we warn but don't block)
#   2 — fatal error (e.g., trigger payload missing or malformed); abort session

set -euo pipefail

# ----------------------------------------------------------------------------
# Configuration — read from the tenant config
# ----------------------------------------------------------------------------
CONFIG_FILE="/tenant/.claude/tenant-config.json"
AGENT_DIR="/tenant/.claude/agents/proposal-builder"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "FATAL: Tenant config not found at $CONFIG_FILE" >&2
  exit 2
fi

VAULT_ROOT="/tenant/vault"
INTAKE_DIR="/tenant/intake/fathom"
LOG_FILE="/tenant/logs/context-$(date +%Y%m%d).jsonl"

# Extract config values
CLIENT_NAME=$(jq -r '.client.name' "$CONFIG_FILE")
CLIENT_SLUG=$(jq -r '.client.company_slug' "$CONFIG_FILE")
VOICE_PROFILE_PATH=$(jq -r '.vault.voice_profile_path' "$CONFIG_FILE")
PRICING_FRAMEWORK_PATH=$(jq -r '.pricing.framework_path' "$CONFIG_FILE")
RETRIEVAL_TOP_K=$(jq -r '.vault.retrieval_top_k // 3' "$CONFIG_FILE")
RETRIEVAL_TAG=$(jq -r '.vault.past_proposals_query_tag // "winning-proposal"' "$CONFIG_FILE")

log_telemetry() {
  local event="$1"
  local status="$2"
  local details="$3"
  mkdir -p "$(dirname "$LOG_FILE")"
  cat <<EOF >> "$LOG_FILE"
{"ts":"$(date -Iseconds)","agent":"proposal-builder","hook":"context","event":"$event","status":"$status","details":$details}
EOF
}

# ----------------------------------------------------------------------------
# Step 1 — Identify the trigger payload
# ----------------------------------------------------------------------------
# The session is triggered with a CLI arg specifying which intake file to process.
# If none is specified (e.g. manual invocation), we pick the most recent unprocessed one.

TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"

if [[ -z "$TRIGGER_FILE" ]]; then
  # Fall back to most recent .json in intake that doesn't have a matching .processed marker
  TRIGGER_FILE=$(find "$INTAKE_DIR" -maxdepth 1 -name "*.json" ! -name "*.processed" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || echo "")
fi

if [[ -z "$TRIGGER_FILE" || ! -f "$TRIGGER_FILE" ]]; then
  echo "FATAL: No trigger payload found. Expected CLAUDE_TRIGGER_FILE env var or a file in $INTAKE_DIR." >&2
  log_telemetry "hydrate" "fatal" "\"no_trigger_file\""
  exit 2
fi

PAYLOAD=$(cat "$TRIGGER_FILE")

# ----------------------------------------------------------------------------
# Step 2 — Extract prospect identity and call metadata from payload
# ----------------------------------------------------------------------------
CALL_ID=$(echo "$PAYLOAD" | jq -r '.recording_id // .call_id // empty')
FATHOM_URL=$(echo "$PAYLOAD" | jq -r '.url // .share_url // empty')
MEETING_TYPE=$(echo "$PAYLOAD" | jq -r '.meeting_type // "discovery"')
MEETING_DATE=$(echo "$PAYLOAD" | jq -r '.recording_start_time // .created_at')

# Prospect identification — derive from first external attendee's domain
PROSPECT_DOMAIN=$(echo "$PAYLOAD" | jq -r '.calendar_invitees[] | select(.is_external == true) | .email' | head -1 | awk -F'@' '{print $2}')

if [[ -z "$PROSPECT_DOMAIN" ]]; then
  # Fallback: try to infer from the transcript if no clear external attendee
  PROSPECT_DOMAIN=$(echo "$PAYLOAD" | jq -r '.transcript | .[0:5] | .[].speaker.matched_calendar_invitee_email' 2>/dev/null | awk -F'@' '{print $2}' | grep -v "^$CLIENT_SLUG" | head -1 || echo "unknown-prospect")
fi

PROSPECT_COMPANY=$(echo "$PAYLOAD" | jq -r '.calendar_invitees[] | select(.is_external == true) | .name' | head -1 | awk '{print $NF}' || echo "Unknown")
PROSPECT_SLUG=$(echo "$PROSPECT_DOMAIN" | sed 's/\..*//' | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed 's/-\+/-/g;s/^-\|-$//g')

# ----------------------------------------------------------------------------
# Step 3 — Load voice profile and pricing framework
# ----------------------------------------------------------------------------
VOICE_PROFILE_FULL="$VAULT_ROOT$VOICE_PROFILE_PATH"
PRICING_FRAMEWORK_FULL="$VAULT_ROOT$PRICING_FRAMEWORK_PATH"

if [[ ! -f "$VOICE_PROFILE_FULL" ]]; then
  echo "WARNING: Voice profile not found at $VOICE_PROFILE_FULL. Proposal will use generic tone." >&2
  VOICE_PROFILE_CONTENT="*(Voice profile not yet ingested. Produce a professional, tight, specific proposal in plain business English. Do not attempt to mimic a voice.)*"
else
  VOICE_PROFILE_CONTENT=$(cat "$VOICE_PROFILE_FULL")
fi

if [[ ! -f "$PRICING_FRAMEWORK_FULL" ]]; then
  echo "FATAL: Pricing framework missing at $PRICING_FRAMEWORK_FULL. Cannot proceed without pricing." >&2
  log_telemetry "hydrate" "fatal" "\"pricing_framework_missing\""
  exit 2
else
  PRICING_CONTENT=$(cat "$PRICING_FRAMEWORK_FULL")
fi

# ----------------------------------------------------------------------------
# Step 4 — Retrieve similar past winning proposals via pgvector
# ----------------------------------------------------------------------------
# Build a retrieval query from the call summary and first ~2000 chars of transcript.
# Call a small Node helper that:
#   (1) generates a Cohere embedding for the query
#   (2) queries pgvector for the top-k similar notes tagged {{retrieval_tag}}
#   (3) returns the matching notes' content

RETRIEVAL_QUERY=$(echo "$PAYLOAD" | jq -r '.default_summary.markdown_formatted // ""' | head -c 2000)

# Fallback: if no summary yet, use first 2000 chars of transcript text
if [[ -z "$RETRIEVAL_QUERY" || "$RETRIEVAL_QUERY" == "null" ]]; then
  RETRIEVAL_QUERY=$(echo "$PAYLOAD" | jq -r '.transcript | map(.text) | join(" ")' | head -c 2000)
fi

# Call the vault-search helper. This is a thin Node wrapper around the pgvector query.
# See: /tenant/.claude/bin/vault-search
RETRIEVED_JSON=$(
  /tenant/.claude/bin/vault-search \
    --query "$RETRIEVAL_QUERY" \
    --tag "$RETRIEVAL_TAG" \
    --top-k "$RETRIEVAL_TOP_K" \
    --format json \
    2>/dev/null || echo '{"error":"retrieval_failed","results":[]}'
)

RETRIEVAL_ERROR=$(echo "$RETRIEVED_JSON" | jq -r '.error // empty')

if [[ -n "$RETRIEVAL_ERROR" ]]; then
  echo "WARNING: Past-proposal retrieval failed ($RETRIEVAL_ERROR). Proceeding without retrieval context." >&2
  PAST_PROPOSALS_CONTENT="*(Retrieval unavailable — no past proposals pulled in. Agent will produce from voice profile and pricing framework only.)*"
  log_telemetry "retrieval" "warn" "{\"error\":\"$RETRIEVAL_ERROR\"}"
else
  # Format the retrieved notes as a readable section
  PAST_PROPOSALS_CONTENT=$(echo "$RETRIEVED_JSON" | jq -r '
    .results
    | if length == 0 then
        "*(No matching past proposals found for this industry/deal shape. Agent will produce from voice profile and pricing framework only.)*"
      else
        map(
          "### Past proposal — " + (.metadata.prospect // "unknown") +
          " (deal: " + (.metadata.deal_value_display // "unknown") + ", closed: " + (.metadata.closed_at // "unknown") + ")\n\n" +
          .content +
          "\n\n---\n"
        ) | join("\n")
      end
  ')
  RESULT_COUNT=$(echo "$RETRIEVED_JSON" | jq -r '.results | length')
  log_telemetry "retrieval" "ok" "{\"results\":$RESULT_COUNT}"
fi

# ----------------------------------------------------------------------------
# Step 5 — Extract call details from Fathom payload
# ----------------------------------------------------------------------------
FATHOM_SUMMARY=$(echo "$PAYLOAD" | jq -r '.default_summary.markdown_formatted // "No summary available from Fathom."')

FATHOM_ACTION_ITEMS=$(echo "$PAYLOAD" | jq -r '
  if .action_items and (.action_items | length > 0) then
    .action_items | map("- " + .description) | join("\n")
  else
    "No action items extracted by Fathom."
  end
')

# Transcript: format as speaker-labelled, timestamped prose. Cap at 40k tokens
# (~160k chars) to stay inside Sonnet's effective context budget after other
# content. The agent.md notes the truncation behaviour.
TRANSCRIPT=$(echo "$PAYLOAD" | jq -r '
  .transcript
  | map("[" + .timestamp + "] " + .speaker.display_name + ": " + .text)
  | join("\n")
' | head -c 160000)

TRANSCRIPT_LEN=$(echo -n "$TRANSCRIPT" | wc -c)
if (( TRANSCRIPT_LEN >= 160000 )); then
  TRANSCRIPT="$TRANSCRIPT

---
*[Transcript truncated at 160k chars for context budget. Full transcript available at $FATHOM_URL.]*"
fi

# Attendees summary
ATTENDEES=$(echo "$PAYLOAD" | jq -r '
  .calendar_invitees
  | map(.name + " (" + .email + ")" + (if .is_external then " [external]" else " [internal]" end))
  | join(", ")
')

# Sales lead (from config)
SALES_LEAD_NAME=$(jq -r '.sales_lead.name' "$CONFIG_FILE")
SALES_LEAD_EMAIL=$(jq -r '.sales_lead.email' "$CONFIG_FILE")

# ----------------------------------------------------------------------------
# Step 6 — Assemble the deal context block
# ----------------------------------------------------------------------------
DEAL_CONTEXT=$(cat <<EOF
prospect_company: $PROSPECT_COMPANY
prospect_domain: $PROSPECT_DOMAIN
prospect_slug: $PROSPECT_SLUG
meeting_type: $MEETING_TYPE
meeting_date: $MEETING_DATE
attendees: $ATTENDEES
sales_lead: $SALES_LEAD_NAME <$SALES_LEAD_EMAIL>
fathom_url: $FATHOM_URL
fathom_call_id: $CALL_ID
EOF
)

# ----------------------------------------------------------------------------
# Step 7 — Inject context into the working copy of agent.md
# ----------------------------------------------------------------------------
# We read agent.md (read-only source of truth), substitute the CONTEXT block,
# and write to agent.working.md which the session actually reads.

# Generate the context block
CONTEXT_BLOCK=$(cat <<EOF
<!-- CONTEXT-START -->

## Client voice profile

$VOICE_PROFILE_CONTENT

## Pricing framework

$PRICING_CONTENT

## Three closest past winning proposals

$PAST_PROPOSALS_CONTENT

## This deal

\`\`\`
$DEAL_CONTEXT
\`\`\`

## Discovery call

### Fathom AI summary

$FATHOM_SUMMARY

### Fathom AI action items

$FATHOM_ACTION_ITEMS

### Full transcript (speaker-labelled, timestamped)

$TRANSCRIPT

<!-- CONTEXT-END -->
EOF
)

# Replace everything between CONTEXT-START and CONTEXT-END in agent.md
# Using awk for reliable multi-line replacement
awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { in_ctx = 1; print ctx; next }
  /<!-- CONTEXT-END -->/ { in_ctx = 0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

# ----------------------------------------------------------------------------
# Step 8 — Done
# ----------------------------------------------------------------------------
log_telemetry "hydrate" "ok" "{\"prospect\":\"$PROSPECT_COMPANY\",\"call_id\":\"$CALL_ID\",\"voice_profile\":$(if [[ -f "$VOICE_PROFILE_FULL" ]]; then echo true; else echo false; fi),\"retrievals\":${RESULT_COUNT:-0},\"transcript_chars\":$TRANSCRIPT_LEN}"

# Claude Code reads the working copy. We can optionally emit a summary to stdout
# which will be injected as a system reminder into the session.
echo "Context hydrated for Proposal Builder:"
echo "  Prospect: $PROSPECT_COMPANY ($PROSPECT_DOMAIN)"
echo "  Call ID: $CALL_ID"
echo "  Meeting type: $MEETING_TYPE"
echo "  Past proposals retrieved: ${RESULT_COUNT:-0}"
echo "  Voice profile: $(if [[ -f "$VOICE_PROFILE_FULL" ]]; then echo "loaded"; else echo "MISSING — generic tone will be used"; fi)"

exit 0
