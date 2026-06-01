#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2015
#
# IFOS Codex ratification driver
#
# Wraps the `codex exec` invocation per artefact: assembles the prompt
# (top-level SKILL.md + type-specific skill + artefact content + output
# contract), runs Codex non-interactively, captures the output, parses the
# RATIFIED/REJECTED verdict, and writes a decision_log audit row per
# `docs/operations/codex-ratification-execution-plan.md` §6.3.
#
# Usage:
#   bash scripts/run-codex-ratification.sh <skill-type> <artefact-path>
#
# Example:
#   bash scripts/run-codex-ratification.sh architecture-decision \
#     docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
#
# Or batch (one cluster at a time):
#   bash scripts/run-codex-ratification.sh --cluster A
#
# Pre-conditions (verified by Step 0):
#   - codex CLI installed + working (`codex --version` succeeds)
#   - .codex/ratification/SKILL.md present
#   - .codex/ratification/review-<type>.md present for requested type
#   - Optional: IFOS_DB_URL set for decision_log audit row writes; otherwise
#     audit row written to fallback JSONL at logs/codex-ratification.jsonl
#
# Output:
#   - logs/codex-ratification/<session-id>/<artefact-slug>.output.md
#       Full Codex response captured verbatim
#   - logs/codex-ratification/<session-id>/<artefact-slug>.verdict.txt
#       Single line: "RATIFIED" or "REJECTED:<count>"
#   - decision_log row (live) OR logs/codex-ratification.jsonl (fallback)
#   - On REJECTED: prompts founder whether to proceed to next artefact
#     (yes), open disagreement-doc template (disagreement), or stop (no).

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly SKILLS_DIR="${REPO_ROOT}/.codex/ratification"
readonly TOP_LEVEL_SKILL="${SKILLS_DIR}/SKILL.md"
readonly LOG_BASE="${REPO_ROOT}/logs/codex-ratification"
readonly FALLBACK_LOG="${REPO_ROOT}/logs/codex-ratification.jsonl"

SESSION_ID="$(date -u +"%Y%m%dT%H%M%SZ")-$$"
readonly SESSION_ID

SESSION_LOG_DIR="${LOG_BASE}/${SESSION_ID}"
mkdir -p "${SESSION_LOG_DIR}"

# Per-cluster artefact lists (mirrors execution-plan §4)
declare -A CLUSTERS
CLUSTERS[A]="docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md|architecture-decision
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md|architecture-decision
docs/decisions/ADR-003-agent-bundle-renderer.md|architecture-decision
docs/decisions/ADR-004-renderer-implementation-deviations.md|architecture-decision
docs/decisions/bullhorn-integration-path.md|architecture-decision
docs/decisions/sequencing-target.md|architecture-decision
docs/decisions/brain-ui-scope.md|architecture-decision
docs/decisions/autosend-safety-policy.md|architecture-decision"

CLUSTERS[B]="docs/architecture/cortexos-primitive-status.md|architecture-decision
docs/architecture/second-brain-design.md|architecture-decision
docs/architecture/agent-bundle-renderer-design.md|architecture-decision
docs/architecture/vault-concurrency.md|architecture-decision
docs/decisions/v1.0-kill-criterion.md|architecture-decision
docs/runbooks/operational-hygiene-protocol.md|architecture-decision"

CLUSTERS[C]="docs/verticals/recruitment/vertical-schema.yaml|schema-change
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml|schema-change"

CLUSTERS[D]="docs/runbooks/day-4-provisioning.md|postgres-migration
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql|postgres-migration
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql|postgres-migration"

# Cluster E — Week-3 v1.0 agent contracts + v0.3 artefacts (re-ratification
# after the 2026-05-27 Day-21 remediation; 29 findings closed). The 6 agent.md
# use the agent-bundle skill; ADR-007 the architecture-decision skill; the v0.3
# supplement the schema-change skill; the v0.3 migration the postgres-migration
# skill (migration was touched in R20 — blocked_recipients element validation).
CLUSTERS[E]="agents/recruitment/diagnostic/agent.md|agent-bundle
agents/recruitment/janitor/agent.md|agent-bundle
agents/recruitment/scribe/agent.md|agent-bundle
agents/recruitment/cash-conductor/agent.md|agent-bundle
agents/recruitment/sourcing-scout/agent.md|agent-bundle
agents/recruitment/concierge/agent.md|agent-bundle
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md|architecture-decision
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml|schema-change
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql|postgres-migration"

# Cluster F — W4 Track-1 MCP connectors (2026-06-01 W4 Day-26 build).
# Three fixture-first connectors scaffolded across Day-25 (xero) + Day-26
# (quickbooks + open-banking) per docs/operations/goal-w4-day-26-2026-06-01.md
# Phase 2. All three use the mcp-connector skill landed at .codex/ratification/
# review-mcp-connector.md (W4 Day-25 overnight commit 267913b).
CLUSTERS[F]="packages/mcp-connectors/xero|mcp-connector
packages/mcp-connectors/quickbooks|mcp-connector
packages/mcp-connectors/open-banking|mcp-connector"

# Cluster Fbis — Agent-bundle full ratifications (2026-06-01 W4 Day-26).
# Both bundles fully present at the scaffold layer:
#   - Cash Conductor: morning skeleton (6ab59d8) + afternoon completion (5ab2f0f)
#   - Concierge: evening scaffold (669a4f4 + 9ec2bd6 + 524bac6 + 8ba3723 + eb1f884)
# Both agent.md files were ratified at the contract layer in W3 cluster E
# (8/9 + 1 fix-applied); this re-review checks the BUNDLE layer now that
# sibling files exist. review-agent-bundle skill (.codex/ratification/
# review-agent-bundle.md) inspects agent.md AND the surrounding bundle files
# + fixtures from the single path given, so each bundle is one entry.
# Run order: AFTER cluster F lands (Fbis depends on @ifos/{xero,quickbooks,open-banking}
# capability declarations in tools.yaml being valid against their ratified packages).
CLUSTERS[Fbis]="agents/recruitment/cash-conductor/agent.md|agent-bundle
agents/recruitment/concierge/agent.md|agent-bundle"

# Cluster G — Architecture-decision docs accumulated since cluster A. D1-B
# (the Telegram approval-bridge founder decision) landed 2026-05-31 and the
# bridge scaffold landed 2026-06-01 (commit 9b282d8). Ratifies via the
# .codex/ratification/review-architecture-decision.md skill — same one cluster
# A used. Other decision-docs may join this cluster as they accumulate
# (e.g. migration rollback re-ratification noted in priorities backlog).
CLUSTERS[G]="docs/decisions/2026-05-31-d1-founder-decision.md|architecture-decision"

PASS_COUNT=0
FAIL_COUNT=0
declare -a FAILED_ARTEFACTS=()

# ────────────────────────────────────────────────────────────────────────
# Early branches that don't need codex (--list-clusters / no-args)
# ────────────────────────────────────────────────────────────────────────

if [[ $# -eq 0 ]]; then
  cat <<EOF
Usage:
  $0 <skill-type> <artefact-path>      # Single artefact
  $0 --cluster <A|B|C|D>               # Batch by cluster
  $0 --list-clusters                   # List available clusters + items

Skill types:
  architecture-decision
  schema-change
  postgres-migration
  agent-bundle

Examples:
  $0 architecture-decision docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
  $0 agent-bundle agents/recruitment/diagnostic/agent.md
  $0 --cluster A
  $0 --cluster E      # Week-3 v1.0 agent contracts + v0.3 artefacts
  $0 --cluster F      # W4 Track-1 MCP connectors (xero + quickbooks + open-banking)
  $0 --cluster Fbis   # Cash Conductor full bundle ratification (run AFTER F)
  $0 --cluster G      # Architecture decisions accumulated since cluster A (D1-B et al.)
EOF
  exit 2
fi

if [[ "$1" == "--list-clusters" ]]; then
  for cluster in A B C D E F Fbis G; do
    printf '\n\033[1mCluster %s:\033[0m\n' "${cluster}"
    printf '%s\n' "${CLUSTERS[${cluster}]}" | awk -F'|' '{ printf "  %s  [%s]\n", $1, $2 }'
  done
  exit 0
fi

# ────────────────────────────────────────────────────────────────────────
# UX helpers
# ────────────────────────────────────────────────────────────────────────

_step() {
  printf '\n\033[1;34m── %s ──\033[0m\n' "$1"
}

_ok() {
  printf '  \033[1;32m✓\033[0m %s\n' "$1"
}

_warn() {
  printf '  \033[1;33m!\033[0m %s\n' "$1"
}

_fail() {
  printf '  \033[1;31m✗\033[0m %s\n' "$1"
  [[ -n "${2:-}" ]] && printf '    %s\n' "$2"
}

_slugify() {
  local input="$1"
  printf '%s' "${input}" | tr '/' '_' | tr '.' '-' | tr -c '[:alnum:]_-' '_'
}

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

_step "Pre-flight"

if ! command -v codex >/dev/null 2>&1; then
  _fail "codex CLI not on PATH" "Install: npm install -g @openai/codex"
  exit 1
fi
_ok "codex CLI present"

if ! codex --version >/dev/null 2>&1; then
  _fail "codex CLI invocation fails (likely broken install)" "See execution-plan §2 Precondition 0"
  exit 1
fi
_ok "codex CLI executes"

if [[ ! -f "${TOP_LEVEL_SKILL}" ]]; then
  _fail "Top-level SKILL.md missing" "${TOP_LEVEL_SKILL}"
  exit 1
fi
_ok "Top-level SKILL.md present"

_ok "Session ID: ${SESSION_ID}"
_ok "Log dir: ${SESSION_LOG_DIR}"

# ────────────────────────────────────────────────────────────────────────
# Audit-row writer (live mode or fallback)
# ────────────────────────────────────────────────────────────────────────

_write_audit_row() {
  local artefact="$1"
  local skill="$2"
  local outcome="$3"          # RATIFIED | REJECTED
  local issue_count="$4"      # integer
  local round_trip="$5"       # 1 or 2
  local response_path="$6"

  local response_text
  response_text=$(cat "${response_path}" 2>/dev/null | head -c 8000 || echo "")

  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" >/dev/null 2>&1 <<EOF
BEGIN;
SET LOCAL app.current_tenant = 'ifos-meta';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
VALUES (
  'ifos-meta',
  '_codex_ratifier',
  'output',
  '${outcome}',
  jsonb_build_object(
    'artefact_path', \$\$${artefact}\$\$,
    'skill_used', \$\$${skill}\$\$,
    'issue_count', ${issue_count}::integer,
    'round_trip', ${round_trip}::integer,
    'session_id', \$\$${SESSION_ID}\$\$,
    'codex_response_text', \$\$${response_text}\$\$
  ),
  now()
);
COMMIT;
EOF
    local psql_rc=$?
    if (( psql_rc == 0 )); then
      _ok "decision_log row written (live)"
      return 0
    fi
    _warn "psql audit-row write failed; using fallback"
  fi

  mkdir -p "$(dirname "${FALLBACK_LOG}")"
  local escaped_resp
  escaped_resp=$(printf '%s' "${response_text}" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo '""')
  printf '{"tenant_slug":"ifos-meta","agent_name":"_codex_ratifier","phase":"output","outcome":"%s","payload":{"artefact_path":"%s","skill_used":"%s","issue_count":%d,"round_trip":%d,"session_id":"%s","codex_response_text":%s},"created_at":"%s"}\n' \
    "${outcome}" "${artefact}" "${skill}" "${issue_count}" "${round_trip}" "${SESSION_ID}" "${escaped_resp}" \
    "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    >> "${FALLBACK_LOG}"
  _ok "decision_log row appended to fallback (${FALLBACK_LOG})"
}

# ────────────────────────────────────────────────────────────────────────
# Single-artefact review
# ────────────────────────────────────────────────────────────────────────

_review_artefact() {
  local skill_type="$1"
  local artefact_path="$2"
  local round_trip="${3:-1}"

  local skill_file="${SKILLS_DIR}/review-${skill_type}.md"
  if [[ ! -f "${skill_file}" ]]; then
    _fail "Skill file missing for type=${skill_type}" "${skill_file}"
    return 2
  fi

  if [[ ! -e "${REPO_ROOT}/${artefact_path}" ]]; then
    _fail "Artefact not found" "${REPO_ROOT}/${artefact_path}"
    return 2
  fi

  local slug
  slug=$(_slugify "${artefact_path}")
  local output_file="${SESSION_LOG_DIR}/${slug}.output.md"
  local verdict_file="${SESSION_LOG_DIR}/${slug}.verdict.txt"
  local prompt_file="${SESSION_LOG_DIR}/${slug}.prompt.md"

  _step "Reviewing ${artefact_path} (round ${round_trip}, skill=${skill_type})"

  # Build the per-artefact body — either the single file's contents, or
  # (for package-directory artefacts like cluster F MCP connectors) a
  # structured digest of package.json + README.md + src/**/*.ts + tests/**/*.ts.
  # Skips node_modules + dist + lockfiles (noise) to keep the prompt under
  # the context budget; the skill's required-reading set lives in those files.
  local artefact_body
  if [[ -d "${REPO_ROOT}/${artefact_path}" ]]; then
    artefact_body=$(
      while IFS= read -r -d '' f; do
        rel="${f#"${REPO_ROOT}"/}"
        printf '\n--- FILE: %s ---\n\n' "${rel}"
        cat "${f}"
      done < <(find "${REPO_ROOT}/${artefact_path}" \
                 \( -name node_modules -o -name dist -o -name 'pnpm-lock.yaml' -o -name '.turbo' \) -prune -o \
                 \( -name 'package.json' -o -name '*.md' -o -name '*.ts' -o -name '*.json' -o -name '*.yaml' -o -name '*.config.*' \) \
                 -type f -print0 2>/dev/null | sort -z)
    )
  else
    artefact_body=$(cat "${REPO_ROOT}/${artefact_path}")
  fi

  # Build the prompt — top-level skill + type skill + artefact + output contract
  cat > "${prompt_file}" <<EOF
=== TOP-LEVEL CODEX RATIFICATION SKILL ===

$(cat "${TOP_LEVEL_SKILL}")

=== TYPE-SPECIFIC SKILL: ${skill_type} ===

$(cat "${skill_file}")

=== ARTEFACT UNDER REVIEW ===

Path: ${artefact_path}

--- BEGIN ARTEFACT ---

${artefact_body}

--- END ARTEFACT ---

=== YOUR TASK ===

Apply the top-level SKILL.md plus the type-specific skill above to the artefact.

Return EXACTLY ONE of:

  RATIFIED
  [optional 0-5 lines of advisory notes]

OR

  REJECTED

  1. <one-line problem statement>. <2-4 line explanation citing specific lines/sections>. <one-line proposed fix>.

  2. <next issue, same shape>

  ...

Do not include preamble, throat-clearing, or summary. Begin your response with the literal word RATIFIED or REJECTED.
EOF

  _ok "Prompt assembled at ${prompt_file}"

  # Run codex non-interactively.
  # NOTE: --output-format flag was removed in codex-cli 0.132.0+ (text is the
  # default for non-TTY stdout). Day-19 patch: omit the flag.
  if ! codex exec < "${prompt_file}" > "${output_file}" 2>&1; then
    _fail "codex exec failed" "See ${output_file} for stderr"
    return 1
  fi
  _ok "Codex returned response (${output_file})"

  # Parse verdict. codex-cli 0.132.0+ structure:
  #   metadata header (Reading prompt..., session id, ...)
  #   user (echoed prompt — contains SKILL.md template that mentions
  #         both RATIFIED and REJECTED literals)
  #   codex (the actual response — starts with the verdict)
  #   tokens used (summary footer)
  # We extract the LAST RATIFIED/REJECTED line that precedes "tokens used",
  # which lands inside the codex response section.
  local first_token
  first_token=$(awk '
    /^tokens used/ { stop=1 }
    !stop && /^(RATIFIED|REJECTED)([[:space:]]|$|:)/ { v=$1 }
    END { print v }
  ' "${output_file}" 2>/dev/null | tr -d ':')
  if [[ "${first_token}" == "RATIFIED" ]]; then
    printf 'RATIFIED\n' > "${verdict_file}"
    _ok "Verdict: RATIFIED"
    _write_audit_row "${artefact_path}" "${skill_type}" "RATIFIED" 0 "${round_trip}" "${output_file}"
    PASS_COUNT=$((PASS_COUNT + 1))
    return 0
  elif [[ "${first_token}" == "REJECTED" ]]; then
    local issue_count
    # Count numbered issues ONLY inside the final verdict block — the same block
    # the detection awk above isolates (last standalone RATIFIED/REJECTED marker
    # preceding "tokens used"). Grepping the whole file inflates the count: it
    # picks up the echoed prompt's numbered rules, the agentic exec traces, and
    # the verdict the CLI prints twice. Forensics 2026-05-27: this reported 41
    # for diagnostic when the real verdict listed 4 issues.
    issue_count=$(awk '
      /^tokens used/ { stop=1 }
      !stop && /^(RATIFIED|REJECTED)([[:space:]]|$|:)/ { inblock=1; count=0; next }
      !stop && inblock && /^[[:space:]]*[0-9]+\./ { count++ }
      END { print count+0 }
    ' "${output_file}")
    [[ -z "${issue_count}" ]] && issue_count=0
    printf 'REJECTED:%d\n' "${issue_count}" > "${verdict_file}"
    _fail "Verdict: REJECTED (${issue_count} numbered issues)" "Read ${output_file}"
    _write_audit_row "${artefact_path}" "${skill_type}" "REJECTED" "${issue_count}" "${round_trip}" "${output_file}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    FAILED_ARTEFACTS+=("${artefact_path}|${output_file}")
    return 1
  else
    _fail "Verdict unparseable; first word: '${first_token}'" "Treating as REJECTED"
    printf 'REJECTED:unparseable\n' > "${verdict_file}"
    _write_audit_row "${artefact_path}" "${skill_type}" "REJECTED" 0 "${round_trip}" "${output_file}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    FAILED_ARTEFACTS+=("${artefact_path}|${output_file}")
    return 1
  fi
}

# ────────────────────────────────────────────────────────────────────────
# Cluster runner
# ────────────────────────────────────────────────────────────────────────

_run_cluster() {
  local cluster="$1"
  if [[ -z "${CLUSTERS[${cluster}]:-}" ]]; then
    _fail "Unknown cluster: ${cluster}" "Valid: A B C D E F Fbis G"
    exit 2
  fi

  local artefact_count
  artefact_count=$(printf '%s\n' "${CLUSTERS[${cluster}]}" | wc -l | tr -d ' ')
  _step "Cluster ${cluster}: ${artefact_count} artefacts"

  while IFS='|' read -r artefact_path skill_type; do
    [[ -z "${artefact_path}" ]] && continue
    _review_artefact "${skill_type}" "${artefact_path}" 1 || true
  done <<< "${CLUSTERS[${cluster}]}"
}

# ────────────────────────────────────────────────────────────────────────
# Entry
# ────────────────────────────────────────────────────────────────────────

case "$1" in
  --cluster)
    [[ -z "${2:-}" ]] && { _fail "Missing cluster name"; exit 2; }
    _run_cluster "$2"
    ;;
  *)
    [[ $# -ne 2 ]] && { _fail "Expected 2 args"; exit 2; }
    _review_artefact "$1" "$2" 1 || true
    ;;
esac

# ────────────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────────────

printf '\n\033[1;34m══════════════════════════════════════════════════════\033[0m\n'
printf '\033[1mSession:\033[0m %s\n' "${SESSION_ID}"
printf 'RATIFIED: %d   REJECTED: %d\n' "${PASS_COUNT}" "${FAIL_COUNT}"

if (( FAIL_COUNT > 0 )); then
  printf '\n\033[1;33mRejected artefacts:\033[0m\n'
  for f in "${FAILED_ARTEFACTS[@]}"; do
    IFS='|' read -r artefact output <<< "${f}"
    printf '  - %s\n    → %s\n' "${artefact}" "${output}"
  done
  printf '\nNext actions:\n'
  printf '  1. Read each rejected artefact response\n'
  printf '  2. Decide per issue: incorporate (fix + re-run) OR counter-argue\n'
  printf '  3. For counter-argument: create docs/decisions/codex-disagreement-%s-<slug>.md\n' "$(date +%Y-%m-%d)"
  printf '  4. Re-run rejected artefacts in round 2 (≤ 2 rounds; escalate to founder if still failing)\n'
  exit 1
fi

printf '\n\033[1;32mAll artefacts ratified in this session.\033[0m\n'
exit 0
