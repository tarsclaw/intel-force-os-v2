#!/usr/bin/env bash
# Client Onboarder — SessionStart hook
# Loads signed proposal, discovery transcript, voice profile, onboarding templates.

set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/client-onboarder"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

# --- Read trigger payload ---
TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
if [[ -z "$TRIGGER_FILE" || ! -f "$TRIGGER_FILE" ]]; then
  echo "FATAL: No trigger payload found" >&2
  hh_log "hydrate" "fatal" "\"no_trigger_file\""
  exit 2
fi

PAYLOAD=$(cat "$TRIGGER_FILE")
DEAL_ID=$(echo "$PAYLOAD" | jq -r '.deal_id // .hubspot_deal_id // empty')
PROSPECT_COMPANY=$(echo "$PAYLOAD" | jq -r '.prospect.company // .properties.dealname // "Unknown"')
PROSPECT_SLUG=$(echo "$PAYLOAD" | jq -r '.prospect.slug // empty')
SIGNED_DATE=$(echo "$PAYLOAD" | jq -r '.signed_date // .properties.closedate // "today"')
TIER_NAME=$(echo "$PAYLOAD" | jq -r '.tier_name // "unknown"')
DEAL_VALUE=$(echo "$PAYLOAD" | jq -r '.deal_value_display // "unknown"')
PRIMARY_CONTACT_NAME=$(echo "$PAYLOAD" | jq -r '.primary_contact.name // empty')
PRIMARY_CONTACT_EMAIL=$(echo "$PAYLOAD" | jq -r '.primary_contact.email // empty')

# Derive slug from company name if not provided
if [[ -z "$PROSPECT_SLUG" || "$PROSPECT_SLUG" == "null" ]]; then
  PROSPECT_SLUG=$(echo "$PROSPECT_COMPANY" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed 's/-\+/-/g;s/^-\|-$//g')
fi

# Kickoff target = signed_date + lead_time_days
LEAD_DAYS=$(hh_agent_config '.onboarding.kickoff_lead_time_days // 7')
KICKOFF_TARGET=$(date -d "+${LEAD_DAYS} days" +%Y-%m-%d 2>/dev/null || date -v "+${LEAD_DAYS}d" +%Y-%m-%d)

# --- Load signed proposal ---
SIGNED_PROPOSAL_PATH=""
for f in /tenant/vault/clients/"$PROSPECT_SLUG"/proposals/*.md; do
  [[ -f "$f" ]] || continue
  if grep -qE '^status:\s*signed\s*$' "$f"; then
    SIGNED_PROPOSAL_PATH="$f"
    break
  fi
done

if [[ -n "$SIGNED_PROPOSAL_PATH" ]]; then
  SIGNED_PROPOSAL=$(cat "$SIGNED_PROPOSAL_PATH")
else
  SIGNED_PROPOSAL="*(No signed proposal found in /vault/clients/${PROSPECT_SLUG}/proposals/. Agent will escalate SIGNED_PROPOSAL_MISSING.)*"
fi

# --- Load discovery transcript excerpt (first 3000 chars) ---
DISCOVERY_EXCERPT="*(Discovery transcript not available in vault.)*"
DISCOVERY_DIR="/tenant/vault/clients/$PROSPECT_SLUG/calls"
if [[ -d "$DISCOVERY_DIR" ]]; then
  LATEST_CALL=$(find "$DISCOVERY_DIR" -name "*.md" -type f | sort -r | head -1 || echo "")
  if [[ -n "$LATEST_CALL" ]]; then
    DISCOVERY_EXCERPT=$(head -c 3000 "$LATEST_CALL")
  fi
fi

# --- Load brand files ---
VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md 2>/dev/null || echo "*(Voice profile not populated)*")
SERVICE_CATALOGUE=$(cat /tenant/vault/brand/service-catalogue.md 2>/dev/null || echo "*(Service catalogue not populated)*")
TEMPLATES=$(cat /tenant/vault/brand/onboarding-templates.md 2>/dev/null || echo "*(No client-specific templates — using generic onboarding shape.)*")

# --- Secondary contacts ---
SECONDARY_CONTACTS=$(echo "$PAYLOAD" | jq -r '.secondary_contacts[]? | .name + " <" + .email + ">"' | paste -sd, - || echo "none")

# --- Assemble context ---
CONTEXT_BLOCK=$(cat <<EOF
<!-- CONTEXT-START -->

## Client voice profile

$VOICE_PROFILE

## Service catalogue

$SERVICE_CATALOGUE

## Signed proposal

$SIGNED_PROPOSAL

## Original discovery call transcript (for tone signals)

$DISCOVERY_EXCERPT

## This engagement

Prospect: $PROSPECT_COMPANY
Prospect slug: $PROSPECT_SLUG
Signed date: $SIGNED_DATE
Kickoff target: $KICKOFF_TARGET
Tier: $TIER_NAME
Deal value: $DEAL_VALUE
Key contact: $PRIMARY_CONTACT_NAME ($PRIMARY_CONTACT_EMAIL)
Secondary contacts: $SECONDARY_CONTACTS

## Onboarding templates (if client has their own)

$TEMPLATES

<!-- CONTEXT-END -->
EOF
)

awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"prospect\":\"$PROSPECT_COMPANY\",\"signed_proposal_found\":$(if [[ -n "$SIGNED_PROPOSAL_PATH" ]]; then echo true; else echo false; fi),\"kickoff_target\":\"$KICKOFF_TARGET\"}"

echo "Client Onboarder context hydrated:"
echo "  Prospect: $PROSPECT_COMPANY"
echo "  Signed proposal: $(if [[ -n "$SIGNED_PROPOSAL_PATH" ]]; then echo "found"; else echo "MISSING — will escalate"; fi)"
echo "  Kickoff target: $KICKOFF_TARGET"

exit 0
