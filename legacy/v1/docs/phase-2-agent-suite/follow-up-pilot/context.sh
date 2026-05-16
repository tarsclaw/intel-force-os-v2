#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/follow-up-pilot"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md 2>/dev/null || echo "*(Voice profile not populated)*")
SERVICE_CATALOGUE=$(cat /tenant/vault/brand/service-catalogue.md 2>/dev/null || echo "*(Service catalogue not populated)*")
SUPPRESSION=$(cat /tenant/vault/brand/suppression-list.md 2>/dev/null || echo "*(No suppression list found)*")

TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
if [[ -z "$TRIGGER_FILE" || ! -f "$TRIGGER_FILE" ]]; then
  # Scheduled run: no single-prospect payload; agent works from HubSpot query
  PAYLOAD='{}'
else
  PAYLOAD=$(cat "$TRIGGER_FILE")
fi

PROSPECT_COMPANY=$(echo "$PAYLOAD" | jq -r '.prospect.company // "[agent will query HubSpot for eligible deals]"')
PROSPECT_EMAIL=$(echo "$PAYLOAD" | jq -r '.prospect.contact_email // "[multiple]"')
DISCOVERY_DATE=$(echo "$PAYLOAD" | jq -r '.discovery_call_date // "unknown"')
DAYS_SINCE=$(echo "$PAYLOAD" | jq -r '.days_since_last_contact // "unknown"')
UNCONVERTED_REASON=$(echo "$PAYLOAD" | jq -r '.unconverted_reason // "not classified"')
PRIOR_EMAILS=$(echo "$PAYLOAD" | jq -r '.prior_email_threads // "[agent will fetch via mcp__gmail__get_thread]"')
DISCOVERY_EXCERPT=$(echo "$PAYLOAD" | jq -r '.discovery_call_excerpt // "[agent will fetch if vault contains the call record]"')
EXISTING_SEQS=$(echo "$PAYLOAD" | jq -r '.existing_sequences // "none"')
INDUSTRY_SIGNALS=$(echo "$PAYLOAD" | jq -r '.industry_recent_signals // "[agent will web search for Email 2 if relevant]"')

CONTEXT_BLOCK=$(cat <<EOF2
<!-- CONTEXT-START -->

## Client voice profile

$VOICE_PROFILE

## Service catalogue (for relevance)

$SERVICE_CATALOGUE

## Suppression list

$SUPPRESSION

## Prospect — full context
Company: $PROSPECT_COMPANY
Contact: $PROSPECT_EMAIL
Original source: $(echo "$PAYLOAD" | jq -r '.prospect.original_source // "unknown"')
Discovery call date: $DISCOVERY_DATE
Days since last contact: $DAYS_SINCE
Why they're unconverted (notes from HubSpot): $UNCONVERTED_REASON

## Prior email thread history
$PRIOR_EMAILS

## Discovery call transcript excerpt (if available)
$DISCOVERY_EXCERPT

## Existing follow-up sequences for this prospect (if any)
$EXISTING_SEQS

## Recent relevant happenings in their industry (for Email 2 content hook)
$INDUSTRY_SIGNALS

<!-- CONTEXT-END -->
EOF2
)

awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"prospect\":\"$PROSPECT_COMPANY\",\"days_since\":\"$DAYS_SINCE\"}"
echo "Follow-Up Pilot context hydrated. Prospect: $PROSPECT_COMPANY"
exit 0
