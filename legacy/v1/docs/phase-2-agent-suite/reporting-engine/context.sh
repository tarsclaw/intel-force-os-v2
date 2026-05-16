#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/reporting-engine"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
if [[ -z "$TRIGGER_FILE" || ! -f "$TRIGGER_FILE" ]]; then
  echo "FATAL: No trigger payload for reporting-engine" >&2
  exit 2
fi

PAYLOAD=$(cat "$TRIGGER_FILE")
CLIENT_SLUG=$(echo "$PAYLOAD" | jq -r '.client_slug // empty')
REPORT_TYPE=$(echo "$PAYLOAD" | jq -r '.report_type // "monthly"')
PERIOD_START=$(echo "$PAYLOAD" | jq -r '.period_start // ""')
PERIOD_END=$(echo "$PAYLOAD" | jq -r '.period_end // ""')

# Compute default period if not provided (last full month)
if [[ -z "$PERIOD_START" || "$PERIOD_START" == "null" ]]; then
  PERIOD_START=$(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m-01 2>/dev/null || date -v1d -v-1m +%Y-%m-01)
  PERIOD_END=$(date -d "$(date +%Y-%m-01) -1 day" +%Y-%m-%d 2>/dev/null || date -v1d -v-1d +%Y-%m-%d)
fi

VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md 2>/dev/null || echo "*(Voice profile not populated)*")
CLIENT_CONTEXT=$(cat "/tenant/vault/clients/$CLIENT_SLUG/00-context.md" 2>/dev/null || echo "*(Client context file missing)*")

# Signed proposal extraction — find the most recent signed proposal
SIGNED_PROPOSAL_EXTRACTS="*(No signed proposal found)*"
for p in /tenant/vault/clients/"$CLIENT_SLUG"/proposals/*.md; do
  [[ -f "$p" ]] || continue
  if grep -qE '^status:\s*signed\s*$' "$p"; then
    SIGNED_PROPOSAL_EXTRACTS=$(cat "$p")
    break
  fi
done

# Last month's report
LAST_MONTH=$(date -d "$PERIOD_START -1 month" +%Y-%m 2>/dev/null || echo "")
LAST_MONTH_REPORT_PATH="/tenant/vault/reports/monthly/${LAST_MONTH}-${CLIENT_SLUG}.md"
LAST_MONTH_REPORT="*(No prior report for comparison)*"
[[ -f "$LAST_MONTH_REPORT_PATH" ]] && LAST_MONTH_REPORT=$(cat "$LAST_MONTH_REPORT_PATH")

# Vault activity counts (for the period)
VAULT_PROPOSALS_COUNT=$(find /tenant/vault/clients/"$CLIENT_SLUG"/proposals -name "*.md" -newermt "$PERIOD_START" -not -newermt "$PERIOD_END" 2>/dev/null | wc -l | tr -d ' ')
VAULT_CONTENT_COUNT=$(find /tenant/vault/content/long-form -name "*.md" -newermt "$PERIOD_START" -not -newermt "$PERIOD_END" 2>/dev/null | wc -l | tr -d ' ')
VAULT_CAPTIONS_COUNT=$(find /tenant/vault/content/social/captions -name "*.md" -newermt "$PERIOD_START" -not -newermt "$PERIOD_END" 2>/dev/null | wc -l | tr -d ' ')
VAULT_FOLLOWUPS_COUNT=$(find /tenant/vault/clients/"$CLIENT_SLUG"/follow-up -name "*-sequence-plan.md" -newermt "$PERIOD_START" -not -newermt "$PERIOD_END" 2>/dev/null | wc -l | tr -d ' ')
VAULT_ESCALATIONS_COUNT=$(find /tenant/outbox/escalations -name "*${CLIENT_SLUG}*.md" -newermt "$PERIOD_START" -not -newermt "$PERIOD_END" 2>/dev/null | wc -l | tr -d ' ')

# Integration data — passed in via trigger payload from the reconciliation job
HS_METRICS=$(echo "$PAYLOAD" | jq -r '.hubspot_metrics // "*(HubSpot data not included in trigger payload)*"')
GA4_METRICS=$(echo "$PAYLOAD" | jq -r '.ga4_metrics // "*(GA4 not configured or not included)*"')
STRIPE_METRICS=$(echo "$PAYLOAD" | jq -r '.stripe_metrics // "*(Stripe not configured or not included)*"')
DATA_STATUS=$(echo "$PAYLOAD" | jq -r '.data_source_status // "{}"')

# Client tenure
SIGNED_DATE=$(echo "$SIGNED_PROPOSAL_EXTRACTS" | grep -oE 'signed_at: *[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 | awk '{print $2}' || echo "")
if [[ -n "$SIGNED_DATE" ]]; then
  TENURE_DAYS=$(( ($(date +%s) - $(date -d "$SIGNED_DATE" +%s 2>/dev/null || echo 0)) / 86400 ))
  TENURE_MONTHS=$(( TENURE_DAYS / 30 ))
else
  TENURE_MONTHS="unknown"
fi

CONTEXT_BLOCK=$(cat <<EOF2
<!-- CONTEXT-START -->

## Client voice profile

$VOICE_PROFILE

## Client context

$CLIENT_CONTEXT

## Signed proposal commitments

$SIGNED_PROPOSAL_EXTRACTS

## Last month's report (for comparison + narrative continuity)

$LAST_MONTH_REPORT

## Vault activity this month
Proposals drafted: $VAULT_PROPOSALS_COUNT
Content pieces published: $VAULT_CONTENT_COUNT
Captions produced: $VAULT_CAPTIONS_COUNT
Follow-up sequences run: $VAULT_FOLLOWUPS_COUNT
Escalations raised: $VAULT_ESCALATIONS_COUNT

## Integration data — HubSpot
$HS_METRICS

## Integration data — GA4 (if configured)
$GA4_METRICS

## Integration data — Stripe (if configured)
$STRIPE_METRICS

## Data availability status
$DATA_STATUS

## This run
Report period: $PERIOD_START to $PERIOD_END
Report type: $REPORT_TYPE
Client tenure: $TENURE_MONTHS months

<!-- CONTEXT-END -->
EOF2
)

awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"client\":\"$CLIENT_SLUG\",\"period\":\"$PERIOD_START to $PERIOD_END\",\"tenure_months\":\"$TENURE_MONTHS\"}"
echo "Reporting Engine context hydrated. Client: $CLIENT_SLUG, Period: $PERIOD_START to $PERIOD_END"
exit 0
