#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/content-creator"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

# --- Load brand files ---
VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md 2>/dev/null || echo "*(Voice profile not populated — outputs will be generic)*")
POSITIONING=$(cat /tenant/vault/brand/positioning.md 2>/dev/null || echo "*(Positioning not populated)*")

# --- Read trigger payload ---
TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
TRIGGER_SOURCE="scheduled"
REQUESTED_LENGTH=$(hh_agent_config '.output.default_length_target // 1500')
DEADLINE="not specified"
BRIEF_CONTENT="*(No explicit brief — find the most recent unused brief in /vault/content/briefs/)*"

if [[ -n "$TRIGGER_FILE" && -f "$TRIGGER_FILE" ]]; then
  TRIGGER_SOURCE=$(jq -r '.source // "manual-brief"' "$TRIGGER_FILE")
  REQUESTED_LENGTH=$(jq -r ".requested_length // $REQUESTED_LENGTH" "$TRIGGER_FILE")
  DEADLINE=$(jq -r '.deadline // "not specified"' "$TRIGGER_FILE")

  BRIEF_PATH=$(jq -r '.brief_path // empty' "$TRIGGER_FILE")
  INLINE_BRIEF=$(jq -r '.brief_inline // empty' "$TRIGGER_FILE")

  if [[ -n "$BRIEF_PATH" && -f "/tenant/vault${BRIEF_PATH}" ]]; then
    BRIEF_CONTENT=$(cat "/tenant/vault${BRIEF_PATH}")
  elif [[ -n "$INLINE_BRIEF" && "$INLINE_BRIEF" != "null" ]]; then
    BRIEF_CONTENT="$INLINE_BRIEF"
  fi
fi

# Fallback: most recent brief in /vault/content/briefs/ that hasn't got a matching published piece
if [[ "$BRIEF_CONTENT" =~ "No explicit brief" ]]; then
  BRIEFS_DIR="/tenant/vault/content/briefs"
  if [[ -d "$BRIEFS_DIR" ]]; then
    LATEST_BRIEF=$(find "$BRIEFS_DIR" -name "*.md" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    if [[ -n "$LATEST_BRIEF" ]]; then
      BRIEF_CONTENT=$(cat "$LATEST_BRIEF")
    fi
  fi
fi

# --- Retrieve past high-performing pieces ---
TAG=$(hh_agent_config '.vault.past_pieces_retrieval_tag // "long-form"')
TOP_K=$(hh_agent_config '.vault.retrieval_top_k // 3')

# Query seed: first 1000 chars of the brief
QUERY=$(echo "$BRIEF_CONTENT" | head -c 1000)

RETRIEVED_JSON=$(hh_retrieve "$QUERY" "$TAG" "$TOP_K" 2>/dev/null || echo '{"results":[]}')
RETRIEVED=$(echo "$RETRIEVED_JSON" | hh_format_retrieved)

# --- Assemble ---
CONTEXT_BLOCK=$(cat <<EOF
<!-- CONTEXT-START -->

## Client voice profile

$VOICE_PROFILE

## Positioning

$POSITIONING

## Three recent high-performing pieces (for voice anchoring)

$RETRIEVED

## The brief

$BRIEF_CONTENT

## This run

Trigger source: $TRIGGER_SOURCE  (scheduled | manual-brief)
Requested length: $REQUESTED_LENGTH
Deadline: $DEADLINE

<!-- CONTEXT-END -->
EOF
)

awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"trigger_source\":\"$TRIGGER_SOURCE\",\"requested_length\":$REQUESTED_LENGTH,\"brief_loaded\":$(if [[ ! "$BRIEF_CONTENT" =~ "No explicit brief" ]]; then echo true; else echo false; fi)}"

echo "Content Creator context hydrated:"
echo "  Trigger: $TRIGGER_SOURCE"
echo "  Length target: $REQUESTED_LENGTH words"
echo "  Brief: $(if [[ "$BRIEF_CONTENT" =~ "No explicit brief" ]]; then echo "MISSING"; else echo "loaded"; fi)"
echo "  Past pieces retrieved for voice anchor: $(echo "$RETRIEVED_JSON" | jq -r '.results | length' 2>/dev/null || echo 0)"

exit 0
