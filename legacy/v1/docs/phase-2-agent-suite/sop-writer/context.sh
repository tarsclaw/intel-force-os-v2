#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/sop-writer"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md 2>/dev/null || echo "*(Voice profile not populated)*")
SOPS_INDEX=$(cat /tenant/vault/sops/_index.md 2>/dev/null || echo "*(No existing SOPs index. This will be the first SOP for this tenant.)*")
SOP_TEMPLATE=$(cat /tenant/vault/sops/_template.md 2>/dev/null || cat <<'TMPL'
*(Use the embedded template from agent.md.)*
TMPL
)

TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
if [[ -z "$TRIGGER_FILE" || ! -f "$TRIGGER_FILE" ]]; then
  echo "FATAL: SOP Writer requires a trigger payload with the process description" >&2
  exit 2
fi

PAYLOAD=$(cat "$TRIGGER_FILE")
REQUESTER=$(echo "$PAYLOAD" | jq -r '.requester // "unknown"')
SUGGESTED_NAME=$(echo "$PAYLOAD" | jq -r '.suggested_name // "(agent to derive)"')
RELATED_EXISTING=$(echo "$PAYLOAD" | jq -r '.related_existing_sop // "none — agent checks index"')
IS_REVISION=$(echo "$PAYLOAD" | jq -r '.is_revision // false')

INPUT_DESC=$(echo "$PAYLOAD" | jq -r '.input_description // .description // ""')
# If input_description is a path, load it
if [[ "$INPUT_DESC" == /* && -f "$INPUT_DESC" ]]; then
  INPUT_DESC=$(cat "$INPUT_DESC")
fi

if [[ -z "$INPUT_DESC" || "$INPUT_DESC" == "null" ]]; then
  INPUT_DESC="*(No input description in trigger payload. Agent will escalate PROCESS_TOO_AMBIGUOUS.)*"
fi

REVISION_TEXT="new"
[[ "$IS_REVISION" == "true" ]] && REVISION_TEXT="revision_of_existing"

CONTEXT_BLOCK=$(cat <<EOF2
<!-- CONTEXT-START -->

## Client voice profile

$VOICE_PROFILE

## Existing SOPs index

$SOPS_INDEX

## SOP template (the shape every SOP follows)

$SOP_TEMPLATE

## The input — the process description to formalise

$INPUT_DESC

## Metadata from trigger
Requested by: $REQUESTER
Suggested SOP name: $SUGGESTED_NAME
Related existing SOP: $RELATED_EXISTING
This is: $REVISION_TEXT

<!-- CONTEXT-END -->
EOF2
)

awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"requester\":\"$REQUESTER\",\"is_revision\":$IS_REVISION}"
echo "SOP Writer context hydrated. Requester: $REQUESTER"
exit 0
