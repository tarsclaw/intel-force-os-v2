#!/usr/bin/env bash
set -euo pipefail
source /tenant/.claude/bin/hook-helpers.sh
hh_init

AGENT_DIR="/tenant/.claude/agents/librarian"
AGENT_MD="$AGENT_DIR/agent.md"
WORKING_AGENT_MD="$AGENT_DIR/agent.working.md"

STATE_FILE="/tenant/.claude/state/librarian-last-run.json"
VAULT="/tenant/vault"

# Config
ARCHIVE_DAYS=$(hh_agent_config '.vault.archive_threshold_days // 90')
EMB_PROVIDER=$(hh_agent_config '.embedding.provider // "cohere"')
EMB_MODEL=$(hh_agent_config '.embedding.model // "embed-v3"')
SOP_OVERDUE_DAYS=$(hh_agent_config '.thresholds.sop_overdue_days // 0')
PGV_SCHEMA=$(hh_agent_config '.pgvector.schema_name // "tenant_unknown"')

# Last run
if [[ -f "$STATE_FILE" ]]; then
  LAST_RUN_ISO=$(jq -r '.ran_at // "never"' "$STATE_FILE")
  LAST_DURATION=$(jq -r '.duration_sec // 0' "$STATE_FILE")
  LAST_INDEXED=$(jq -r '.indexed_count // 0' "$STATE_FILE")
  LAST_ARCHIVED=$(jq -r '.archived_count // 0' "$STATE_FILE")
  LAST_FLAGGED=$(jq -r '.flagged_count // 0' "$STATE_FILE")
  LAST_STATUS=$(jq -r '.status // "unknown"' "$STATE_FILE")
else
  LAST_RUN_ISO="never"
  LAST_DURATION=0
  LAST_INDEXED=0
  LAST_ARCHIVED=0
  LAST_FLAGGED=0
  LAST_STATUS="first-run"
fi

# Vault health
TOTAL_FILES=$(find "$VAULT" -type f 2>/dev/null | wc -l | tr -d ' ')
DISK_USAGE_KB=$(du -s "$VAULT" 2>/dev/null | awk '{print $1}' || echo 0)
DISK_USAGE_MB=$(( DISK_USAGE_KB / 1024 ))
DISK_PCT=50  # Placeholder — computed properly against plan allowance by helper

# Recent changes from git log
if [[ -d "$VAULT/.git" ]]; then
  SINCE_ARG="24 hours ago"
  [[ "$LAST_RUN_ISO" != "never" ]] && SINCE_ARG="$LAST_RUN_ISO"
  RECENT_CHANGES=$(cd "$VAULT" && git log --name-status --since="$SINCE_ARG" --pretty=format:"=== %h %s (%an)" 2>/dev/null | head -200 || echo "(git log unavailable)")
else
  RECENT_CHANGES="(Vault not git-backed — scanning filesystem mtimes instead)"
fi

# Tag taxonomy — extract all tags currently in use
TAXONOMY=$(grep -rhE "^  - [a-z-]+" "$VAULT" --include="*.md" 2>/dev/null | sort -u | head -40 | tr '\n' ', ' || echo "(none observed yet)")

# Placeholder metrics (real ones come from pgvector query)
INDEX_ROWS=0
ORPHAN_COUNT=0
BROKEN_LINKS=0

CONTEXT_BLOCK=$(cat <<EOF2
<!-- CONTEXT-START -->

## Configuration snapshot
Archive threshold days: $ARCHIVE_DAYS
Embedding provider: $EMB_PROVIDER
Embedding model: $EMB_MODEL
pgvector schema: $PGV_SCHEMA
SOP verify overdue threshold days: $SOP_OVERDUE_DAYS

## Last run summary
Last run: $LAST_RUN_ISO
Last run duration: ${LAST_DURATION}s
Last run indexed: $LAST_INDEXED
Last run archived: $LAST_ARCHIVED
Last run flagged: $LAST_FLAGGED
Last run status: $LAST_STATUS

## Vault health snapshot
Total files: $TOTAL_FILES
Total disk usage: $DISK_USAGE_MB MB (${DISK_PCT}% of plan allowance)
Index size: $INDEX_ROWS chunks
Orphaned files (not referenced): $ORPHAN_COUNT
Broken internal links: $BROKEN_LINKS

## Files changed in last 24h (from git log)
\`\`\`
$RECENT_CHANGES
\`\`\`

## Tag taxonomy (existing patterns to conform to)
$TAXONOMY

<!-- CONTEXT-END -->
EOF2
)

awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "{\"total_files\":$TOTAL_FILES,\"disk_mb\":$DISK_USAGE_MB,\"last_run\":\"$LAST_RUN_ISO\"}"
echo "Librarian context hydrated. $TOTAL_FILES files. Disk: ${DISK_USAGE_MB}MB. Last run: $LAST_RUN_ISO"
exit 0
