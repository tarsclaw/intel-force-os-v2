#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/caption-writer"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md 2>/dev/null || echo "*(Voice profile not populated)*")

TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
if [[ -z "$TRIGGER_FILE" || ! -f "$TRIGGER_FILE" ]]; then
  echo "FATAL: No trigger payload found" >&2
  exit 2
fi

PAYLOAD=$(cat "$TRIGGER_FILE")
ASSET_PATH=$(echo "$PAYLOAD" | jq -r '.asset_path // empty')
ASSET_TYPE=$(echo "$PAYLOAD" | jq -r '.asset_type // "image"')
UPLOAD_CONTEXT=$(echo "$PAYLOAD" | jq -r '.context_note // "No context note provided."')
TARGET_PLATFORM=$(echo "$PAYLOAD" | jq -r '.target_platform // empty')
VARIANTS=$(echo "$PAYLOAD" | jq -r '.variants_count // 4')
TRIGGER_SRC=$(echo "$PAYLOAD" | jq -r '.trigger_source // "dashboard-upload"')

# Asset description — if vision already analysed, use that; else leave for agent to do
ASSET_DESC=$(echo "$PAYLOAD" | jq -r '.asset_description // "*(Agent to analyse at runtime via native vision.)*"')

TAG=$(hh_agent_config '.vault.past_captions_retrieval_tag // "caption-high-performing"')
RETRIEVED_JSON=$(hh_retrieve "$UPLOAD_CONTEXT" "$TAG" 3 2>/dev/null || echo '{"results":[]}')
RETRIEVED=$(echo "$RETRIEVED_JSON" | hh_format_retrieved)

CONTEXT_BLOCK=$(cat <<EOF2
<!-- CONTEXT-START -->

## Client voice profile

$VOICE_PROFILE

## Asset analysis
Asset type: $ASSET_TYPE  (image | short_video | screenshot)
Asset path: $ASSET_PATH
Asset description (from vision analysis or manual notes): $ASSET_DESC
Upload context note: $UPLOAD_CONTEXT

## Target platform (if specified)
$TARGET_PLATFORM

## Recent high-performing captions (voice anchors)

$RETRIEVED

## This run
Trigger: $TRIGGER_SRC  (dashboard-upload | watch-folder)
Variants requested: $VARIANTS

<!-- CONTEXT-END -->
EOF2
)

awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"asset_type\":\"$ASSET_TYPE\",\"variants\":$VARIANTS}"
echo "Caption Writer context hydrated. Asset: $ASSET_PATH"
exit 0
