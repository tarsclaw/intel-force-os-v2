#!/usr/bin/env bash
# Lead Hunter — SessionStart hook
# Hydrates the CONTEXT block with ICP, positioning, suppression list, CRM state, previous run.

set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/lead-hunter"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

# --- Load context files ---
VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md 2>/dev/null || echo "*(Voice profile not yet populated)*")
ICP=$(cat /tenant/vault/brand/icp.md 2>/dev/null || echo "*(ICP not defined — agent will escalate ICP_CRITERIA_MISSING)*")
POSITIONING=$(cat /tenant/vault/brand/positioning.md 2>/dev/null || echo "*(Positioning not yet populated)*")
SUPPRESSION=$(cat /tenant/vault/brand/suppression-list.md 2>/dev/null || echo "*(No suppression list — treat all prospects as eligible)*")

# --- Read CRM state snapshot (if cached) ---
# The reconciliation job refreshes this every 6 hours. If stale, agent falls back to live queries.
CRM_SNAPSHOT="/tenant/.claude/state/crm-snapshot.json"
if [[ -f "$CRM_SNAPSHOT" ]]; then
  EXISTING_DOMAINS_COUNT=$(jq -r '.domains | length' "$CRM_SNAPSHOT" 2>/dev/null || echo "0")
  RECENT_TOUCHES=$(jq -r '.recent_touches_summary // "Not available"' "$CRM_SNAPSHOT" 2>/dev/null)
else
  EXISTING_DOMAINS_COUNT=0
  RECENT_TOUCHES="(CRM snapshot unavailable; agent will fetch live)"
fi

# --- Find previous run for dedup ---
PROSPECTS_DIR="/tenant/vault/clients/_prospects"
PREV_RUN=$(find "$PROSPECTS_DIR" -maxdepth 1 -name "*-prospect-list.md" -type f 2>/dev/null | sort -r | head -1)
if [[ -n "$PREV_RUN" ]]; then
  PREV_RUN_DATE=$(basename "$PREV_RUN" | cut -d- -f1-3)
  PREV_UNREVIEWED=$(grep -cE '^### [0-9]+\.' "$PREV_RUN" || echo "0")
else
  PREV_RUN_DATE="none"
  PREV_UNREVIEWED=0
fi

# --- Trigger metadata ---
TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
if [[ -n "$TRIGGER_FILE" && -f "$TRIGGER_FILE" ]]; then
  RUN_MODE=$(jq -r '.mode // "manual"' "$TRIGGER_FILE")
  ICP_OVERRIDE=$(jq -r '.icp_override // "none"' "$TRIGGER_FILE")
  TARGET_COUNT=$(jq -r '.target_count // 30' "$TRIGGER_FILE")
  BUDGET_OVERRIDE=$(jq -r '.budget_override // "default"' "$TRIGGER_FILE")
else
  RUN_MODE="scheduled"
  ICP_OVERRIDE="none"
  TARGET_COUNT=$(hh_agent_config '.icp.target_count // 30')
  BUDGET_OVERRIDE="default"
fi

# --- Assemble CONTEXT block ---
CONTEXT_BLOCK=$(cat <<EOF
<!-- CONTEXT-START -->

## Client voice profile

$VOICE_PROFILE

## ICP definition

$ICP

## Positioning

$POSITIONING

## Suppression list (do not contact)

$SUPPRESSION

## Existing CRM state (for dedup)

Companies already in CRM: $EXISTING_DOMAINS_COUNT domains.
Recent touches (last 90d): $RECENT_TOUCHES

## Previous run (for dedup)

Last run date: $PREV_RUN_DATE
Prospects from last run still in "New—Unreviewed": $PREV_UNREVIEWED

## This run

Run mode: $RUN_MODE  (scheduled | manual)
Requested ICP override: $ICP_OVERRIDE
Target count: $TARGET_COUNT
Budget override for this run: $BUDGET_OVERRIDE

<!-- CONTEXT-END -->
EOF
)

# Inject into agent.working.md
awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"run_mode\":\"$RUN_MODE\",\"target_count\":$TARGET_COUNT,\"prev_unreviewed\":$PREV_UNREVIEWED}"

echo "Lead Hunter context hydrated:"
echo "  ICP: $(if [[ -f /tenant/vault/brand/icp.md ]]; then echo "loaded"; else echo "MISSING"; fi)"
echo "  Previous run: $PREV_RUN_DATE"
echo "  Target: $TARGET_COUNT prospects"

exit 0
