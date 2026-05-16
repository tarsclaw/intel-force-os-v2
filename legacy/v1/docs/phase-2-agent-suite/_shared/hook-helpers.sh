#!/usr/bin/env bash
# phase-2-agent-suite/_shared/hook-helpers.sh
#
# Common bash functions for every agent's hook scripts to source.
# Reduces per-agent boilerplate. Sourced from the tenant's path:
#   source /tenant/.claude/bin/hook-helpers.sh
#
# Every agent's validate.sh and context.sh can rely on these helpers being
# available. The Provisioning System copies this file into every tenant's
# /tenant/.claude/bin/ at provisioning time and on upgrade.

# ----------------------------------------------------------------------------
# Logging / telemetry
# ----------------------------------------------------------------------------

# Emit a structured JSONL log event. Writes to /tenant/logs/{hook-name}-{date}.jsonl.
# Usage: hh_log EVENT_NAME STATUS DETAILS_JSON [EXTRA_FIELDS_JSON]
hh_log() {
  local event="$1"
  local status="$2"
  local details="${3:-null}"
  local extra="${4:-}"
  local hook_name="${HOOK_NAME:-unknown}"
  local agent="${AGENT_NAME:-unknown}"
  local session="${SESSION_ID:-unknown}"
  local log_file="/tenant/logs/${hook_name}-$(date +%Y%m%d).jsonl"
  mkdir -p "$(dirname "$log_file")"

  local ts
  ts=$(date -Iseconds)

  if [[ -n "$extra" ]]; then
    cat <<EOF >> "$log_file"
{"ts":"$ts","hook":"$hook_name","agent":"$agent","session_id":"$session","event":"$event","status":"$status","details":$details,"extra":$extra}
EOF
  else
    cat <<EOF >> "$log_file"
{"ts":"$ts","hook":"$hook_name","agent":"$agent","session_id":"$session","event":"$event","status":"$status","details":$details}
EOF
  fi
}

# ----------------------------------------------------------------------------
# Tenant config accessors
# ----------------------------------------------------------------------------

# Path to the tenant config file.
HH_TENANT_CONFIG="${HH_TENANT_CONFIG:-/tenant/.claude/tenant-config.json}"

# Read a value from tenant config using a jq path.
# Usage: hh_config '.client.name'
hh_config() {
  local path="$1"
  jq -r "$path" "$HH_TENANT_CONFIG" 2>/dev/null || echo ""
}

# Read a value from this agent's merged config (tenant + agent-specific).
# Usage: hh_agent_config '.behaviour.revision_limit'
hh_agent_config() {
  local path="$1"
  local agent_config="/tenant/.claude/agents/${AGENT_NAME}/tenant-config.merged.json"
  if [[ -f "$agent_config" ]]; then
    jq -r "$path" "$agent_config" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# ----------------------------------------------------------------------------
# Failure tracking
# ----------------------------------------------------------------------------

# Global failure array. Accumulated across checks, printed at the end.
HH_FAILURES=()

hh_fail() {
  HH_FAILURES+=("$1")
}

hh_report_and_exit() {
  if (( ${#HH_FAILURES[@]} > 0 )); then
    echo "=== ${AGENT_NAME} VALIDATION FAILED ==="
    echo "Failures:"
    for i in "${!HH_FAILURES[@]}"; do
      printf "%d. %s\n\n" "$((i+1))" "${HH_FAILURES[$i]}"
    done
    hh_log "validate" "fail" "{\"failure_count\":${#HH_FAILURES[@]}}"
    exit 1
  fi
  hh_log "validate" "pass" "null"
  exit 0
}

# ----------------------------------------------------------------------------
# Universal content checks (used by most agents' validate.sh)
# ----------------------------------------------------------------------------

# Load the universal banned-phrases list.
HH_BANNED_PHRASES_FILE="/tenant/.claude/bin/universal-banned-phrases.txt"

# Check content for universal AI-tell phrases. Case-insensitive.
# Usage: hh_check_banned_phrases "$CONTENT"
hh_check_banned_phrases() {
  local content="$1"
  local content_lower
  content_lower=$(echo "$content" | tr '[:upper:]' '[:lower:]')

  if [[ ! -f "$HH_BANNED_PHRASES_FILE" ]]; then
    return 0  # Silently pass if the file is missing — fallback to agent-specific checks only
  fi

  while IFS= read -r phrase; do
    # Skip empty lines and comments
    [[ -z "$phrase" || "$phrase" =~ ^[[:space:]]*# ]] && continue

    local phrase_lower
    phrase_lower=$(echo "$phrase" | tr '[:upper:]' '[:lower:]')

    if echo "$content_lower" | grep -qF "$phrase_lower"; then
      hh_fail "Banned phrase found: '$phrase'. This is a universal AI-tell. Rewrite with client-voice-appropriate language."
    fi
  done < "$HH_BANNED_PHRASES_FILE"
}

# Check content against client-specific banned phrases from voice profile.
# Looks for a "## 5. Banned phrases" section in voice-profile.md.
# Usage: hh_check_client_banned_phrases "$CONTENT"
hh_check_client_banned_phrases() {
  local content="$1"
  local voice_profile
  voice_profile=$(hh_config '.vault.voice_profile_path')
  local voice_profile_path="/tenant/vault${voice_profile}"

  [[ ! -f "$voice_profile_path" ]] && return 0

  # Extract lines under "## 5. Banned phrases" → "### Client-specific bans"
  local client_bans
  client_bans=$(awk '/^### Client-specific bans/{flag=1; next} /^##/{flag=0} flag && /^- /{sub(/^- /,""); print}' "$voice_profile_path")

  local content_lower
  content_lower=$(echo "$content" | tr '[:upper:]' '[:lower:]')

  while IFS= read -r phrase; do
    [[ -z "$phrase" ]] && continue
    local phrase_lower
    phrase_lower=$(echo "$phrase" | tr '[:upper:]' '[:lower:]')
    if echo "$content_lower" | grep -qF "$phrase_lower"; then
      hh_fail "Client-specific banned phrase found: '$phrase'. See /brand/voice-profile.md §5."
    fi
  done <<< "$client_bans"
}

# Check no placeholders.
# Usage: hh_check_no_placeholders "$CONTENT"
hh_check_no_placeholders() {
  local content="$1"
  local patterns=("\\bTBD\\b" "\\bTBC\\b" "\\[INSERT" "\\[PLACEHOLDER" "\\{\\{" "\\bXXX\\b" "\\?\\?\\?" "\\bFIXME\\b" "\\bTODO\\b" "\\[DRAFT-NOTE")

  for pattern in "${patterns[@]}"; do
    if echo "$content" | grep -qE "$pattern"; then
      local matches
      matches=$(echo "$content" | grep -nE "$pattern" | head -3)
      hh_fail "Placeholder pattern '$pattern' found. Matches: $matches"
    fi
  done
}

# Check word count within bounds.
# Usage: hh_check_word_count "$CONTENT" MIN MAX
hh_check_word_count() {
  local content="$1"
  local min="$2"
  local max="$3"
  local count
  count=$(echo "$content" | wc -w | tr -d ' ')

  if (( count < min )); then
    hh_fail "Word count $count is below minimum $min."
  fi
  if (( count > max )); then
    hh_fail "Word count $count is above maximum $max."
  fi
}

# ----------------------------------------------------------------------------
# Escalation
# ----------------------------------------------------------------------------

# Write an escalation note and post to Slack.
# Usage: hh_escalate REASON_CODE "Why I stopped" "What I saw" "What human should do" [prospect_slug]
hh_escalate() {
  local code="$1"
  local why="$2"
  local saw="$3"
  local recommend="$4"
  local slug="${5:-unknown}"
  local now
  now=$(date -Iseconds)
  local date_part
  date_part=$(date +%Y-%m-%d)
  local escalation_file="/tenant/outbox/escalations/${date_part}-${slug}-${AGENT_NAME}.md"

  mkdir -p "$(dirname "$escalation_file")"

  cat > "$escalation_file" <<EOF
---
agent: $AGENT_NAME
reason: $code
raised_at: $now
raised_by: ${AGENT_NAME}@$(hh_config '.tenant.deployed_version')
status: awaiting-human
slug: $slug
---

# Escalation — $code

**Why I stopped:**

$why

**What I saw:**

$saw

**What I'd recommend the human do:**

$recommend
EOF

  # Slack notification
  local slack_channel
  slack_channel=$(hh_config '.notifications.escalations_channel')
  local slack_webhook
  slack_webhook=$(hh_config '.notifications.slack_workspace_ref')

  # We don't post here — that's the job of the escalation-notifier service
  # that watches /tenant/outbox/escalations/. We just write the file.

  hh_log "escalation" "raised" "{\"code\":\"$code\",\"slug\":\"$slug\",\"file\":\"$escalation_file\"}"
  echo "$escalation_file"
}

# ----------------------------------------------------------------------------
# Retrieval helper wrappers
# ----------------------------------------------------------------------------

# Call the vault-search helper and format results for context injection.
# Usage: hh_retrieve "query text" TAG TOP_K
hh_retrieve() {
  local query="$1"
  local tag="$2"
  local top_k="${3:-3}"

  /tenant/.claude/bin/vault-search \
    --query "$query" \
    --tag "$tag" \
    --top-k "$top_k" \
    --format json \
    2>/dev/null || echo '{"error":"retrieval_failed","results":[]}'
}

# Format retrieved results into readable markdown for context injection.
# Usage: echo "$RETRIEVED_JSON" | hh_format_retrieved
hh_format_retrieved() {
  jq -r '
    if .error then
      "*(Retrieval unavailable: " + .error + ")*"
    elif (.results | length == 0) then
      "*(No matching prior content found.)*"
    else
      .results | map(
        "### " + (.metadata.title // .metadata.prospect // "Untitled") +
        (if .metadata.date then " — " + .metadata.date else "" end) +
        "\n\n" + .content + "\n\n---\n"
      ) | join("\n")
    end
  '
}

# ----------------------------------------------------------------------------
# Atomic file writes (for context.sh agent.working.md writes)
# ----------------------------------------------------------------------------

# Write content to a file atomically (write-to-temp + rename).
# Usage: hh_atomic_write /path/to/file "content"
hh_atomic_write() {
  local target="$1"
  local content="$2"
  local tmp
  tmp=$(mktemp "${target}.XXXXXX")
  printf '%s' "$content" > "$tmp"
  mv "$tmp" "$target"
}

# ----------------------------------------------------------------------------
# Initialisation helper
# ----------------------------------------------------------------------------

# Call this at the start of any hook. Sets AGENT_NAME from the calling path.
# Usage (from /tenant/.claude/agents/lead-hunter/validate.sh):
#   source /tenant/.claude/bin/hook-helpers.sh
#   hh_init
hh_init() {
  # Best-effort derivation of AGENT_NAME from the script's directory.
  if [[ -z "${AGENT_NAME:-}" && -n "${BASH_SOURCE[1]:-}" ]]; then
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)
    AGENT_NAME=$(basename "$script_dir")
  fi
  # Hook name from script filename (validate.sh → validate, context.sh → context).
  if [[ -z "${HOOK_NAME:-}" && -n "${BASH_SOURCE[1]:-}" ]]; then
    HOOK_NAME=$(basename "${BASH_SOURCE[1]}" .sh)
  fi
  # Session ID from env if Claude Code set it, else generate.
  SESSION_ID="${SESSION_ID:-${CLAUDE_SESSION_ID:-sess_$(date +%s)_$$}}"

  export AGENT_NAME HOOK_NAME SESSION_ID
}
