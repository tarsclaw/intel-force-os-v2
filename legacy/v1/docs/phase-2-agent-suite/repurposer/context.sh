#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/repurposer"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md 2>/dev/null || echo "*(Voice profile not populated)*")
PLATFORM_OVERRIDES_PATH=$(hh_agent_config '.behaviour.platform_voice_overrides_path // "/vault/brand/platform-voice-overrides.md"')
PLATFORM_OVERRIDES=$(cat "/tenant/vault${PLATFORM_OVERRIDES_PATH}" 2>/dev/null || echo "*(No platform-specific voice overrides configured. Using base voice with standard platform register adjustments.)*")

# Trigger payload
TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
TRIGGER_SOURCE="manual"
SOURCE_PATH=""
INCLUDE_THREAD="false"
TARGET_PLATFORMS="linkedin,instagram,email"

if [[ -n "$TRIGGER_FILE" && -f "$TRIGGER_FILE" ]]; then
  TRIGGER_SOURCE=$(jq -r '.triggered_by // .source // "manual"' "$TRIGGER_FILE")
  SOURCE_PATH=$(jq -r '.source_piece_path // empty' "$TRIGGER_FILE")
  INCLUDE_THREAD=$(jq -r '.include_thread // false' "$TRIGGER_FILE")
  TP_JSON=$(jq -r '.target_platforms // []' "$TRIGGER_FILE")
  if [[ "$TP_JSON" != "[]" && "$TP_JSON" != "null" ]]; then
    TARGET_PLATFORMS=$(echo "$TP_JSON" | jq -r 'join(",")' 2>/dev/null || echo "$TARGET_PLATFORMS")
  fi
fi

# Resolve source piece
SOURCE_CONTENT="*(Source piece not accessible — agent will escalate SOURCE_PIECE_NOT_FOUND)*"
if [[ -n "$SOURCE_PATH" && -f "$SOURCE_PATH" ]]; then
  SOURCE_CONTENT=$(cat "$SOURCE_PATH")
elif [[ -n "$SOURCE_PATH" && -f "/tenant/vault${SOURCE_PATH}" ]]; then
  SOURCE_CONTENT=$(cat "/tenant/vault${SOURCE_PATH}")
  SOURCE_PATH="/tenant/vault${SOURCE_PATH}"
fi

# Retrieve past high-performing short-form
TAG=$(hh_agent_config '.vault.short_form_retrieval_tag // "short-form-high-performing"')
RETRIEVED_JSON=$(hh_retrieve "$(echo "$SOURCE_CONTENT" | head -c 800)" "$TAG" 5 2>/dev/null || echo '{"results":[]}')
RETRIEVED=$(echo "$RETRIEVED_JSON" | hh_format_retrieved)

CONTEXT_BLOCK=$(cat <<EOF
<!-- CONTEXT-START -->

## Client voice profile (base)

$VOICE_PROFILE

## Platform voice overrides (if defined)

$PLATFORM_OVERRIDES

## Source long-form piece

Source path: $SOURCE_PATH

$SOURCE_CONTENT

## Three recent high-performing short-form pieces per platform (voice anchors)

$RETRIEVED

## This run

Trigger source: $TRIGGER_SOURCE  (chained-from-content-creator | manual)
Target platforms: $TARGET_PLATFORMS
Include thread: $INCLUDE_THREAD

<!-- CONTEXT-END -->
EOF
)

awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"source_path\":\"$SOURCE_PATH\",\"target_platforms\":\"$TARGET_PLATFORMS\"}"

echo "Repurposer context hydrated. Source: $SOURCE_PATH"
exit 0
