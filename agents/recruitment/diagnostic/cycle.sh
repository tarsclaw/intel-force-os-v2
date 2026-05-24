#!/usr/bin/env bash
#
# Diagnostic agent — cycle.sh (workflow orchestration)
#
# Status: Proposed (Day-19; v0 implementation using @ifos/diagnostic-generator + web-scraper + companies-house MCP connectors all wired).
# Reading order: agent.md §1 (output contract) + §4 (10-step workflow) first.
#
# This is the main orchestration loop. Sources context.sh, runs the 10
# workflow steps from agent.md §4, calls validate.sh for Gate A, writes
# the report to vault, optionally notifies operator.
#
# Per ADR-003 + sequencing-target.md §2.1: Diagnostic is Tier 2 (request-
# driven, no persistent PTY). Each invocation is one report, one firm.
#
# Invocation contract:
#   bash cycle.sh --firm "<firm name>" [--sector <hint>] [--notify-via telegram]
#
# Outputs:
#   - One Markdown file in /vault/<tenant_slug>/diagnostic-reports/<firm-slug>-<ISO-date>.md
#   - Audit rows to decision_log (trigger + output + action)
#   - Optional Telegram notification with executive summary
#
# Exit codes:
#   0  Report generated + validated + vault-written
#   1  Workflow failure (specific step failed; ESC_* row emitted)
#   2  Invocation error (bad args)
#   3  Gate A validation failed
#
# Build state: v0 PRODUCTION. MCP connectors wired Day 13: @ifos/companies-house
# (HTTP Basic auth, 7-day cache); @ifos/web-scraper (HEAD + first-N-lines fetch,
# robots.txt aware, rate-limit aware) for online footprint + LinkedIn page-fetch.
# Proxycurl deep-data integration deferred to W4 polish per ADR-005.
# This script:
#   - Implements the 14-step cycle (per agent.md §4) via a single
#     @ifos/diagnostic-generator package call that composes all 12 sections
#   - Emits audit rows at draft + report + render boundaries (not per-section;
#     per-section telemetry is W4 polish optional per §4)
#   - Uses validate.sh for Gate A enforcement (per-section citation hard-fail
#     per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per
#     §5 honesty note; W4 polish closes those to hard-fail)

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Arguments
# ────────────────────────────────────────────────────────────────────────

FIRM_NAME=""
SECTOR_HINT=""
NOTIFY_VIA=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --firm) FIRM_NAME="$2"; shift 2 ;;
    --sector) SECTOR_HINT="$2"; shift 2 ;;
    --notify-via) NOTIFY_VIA="$2"; shift 2 ;;  # used below in Step 14
    *) printf 'cycle.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done

if [[ -z "${FIRM_NAME}" ]]; then
  printf 'cycle.sh: --firm <name> required\n' >&2
  exit 2
fi

export IFOS_DIAGNOSTIC_FIRM_NAME="${FIRM_NAME}"

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Context hydration
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'cycle.sh: CTX_AGENT_DIR unset (agent not rendered)\n' >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${CTX_AGENT_DIR}/context.sh"

# Sanity
if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  printf 'cycle.sh: CTX_TENANT_SLUG unset after context.sh\n' >&2
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# Compute firm-slug for filename + draft path
# ────────────────────────────────────────────────────────────────────────

FIRM_SLUG=$(printf '%s' "${FIRM_NAME}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9- ' | tr ' ' '-' | sed 's/--*/-/g; s/^-//; s/-$//')
ISO_DATE=$(date -u +"%Y-%m-%d")
VAULT_ROOT="${IFOS_VAULT_ROOT:-/vault}"
REPORT_DIR="${VAULT_ROOT}/${CTX_TENANT_SLUG}/diagnostic-reports"
REPORT_PATH="${REPORT_DIR}/${FIRM_SLUG}-${ISO_DATE}.md"
DRAFT_PATH="/tmp/diagnostic-draft-${FIRM_SLUG}-$$.md"

mkdir -p "${REPORT_DIR}" 2>/dev/null || {
  printf 'cycle.sh: cannot create %s\n' "${REPORT_DIR}" >&2
  exit 1
}

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Validate input + sector
# ────────────────────────────────────────────────────────────────────────

if [[ ${#FIRM_SLUG} -lt 2 ]]; then
  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
    "$(printf '%s' "${FIRM_NAME}" | shasum | awk '{print $1}')" \
    '{"escalation_code":"ESC_INPUT_VALIDATION_FAIL","input_field":"firm","input_value_preview":"<malformed>","validation_rule_violated":"min_length_2"}' >/dev/null
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# Step 2-11 — Generate the 12 sections via @ifos/diagnostic-generator
# ────────────────────────────────────────────────────────────────────────
#
# v0 build (Day 13): web-scraper + companies-house wired; LinkedIn deep
# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
# CLI: packages/diagnostic-generator/dist/cli.js

GENERATOR_CLI="${IFOS_REPO_ROOT:-${REPO_ROOT}}/packages/diagnostic-generator/dist/cli.js"
if [[ ! -f "${GENERATOR_CLI}" ]]; then
  printf 'cycle.sh: generator CLI not built at %s\n' "${GENERATOR_CLI}" >&2
  printf '  Run: cd packages/diagnostic-generator && pnpm build\n' >&2
  exit 1
fi

# target_patch.json — optional; if missing, §6 ICP fit degrades to "no patch"
TARGET_PATCH_PATH="${VAULT_ROOT}/${CTX_TENANT_SLUG}/target_patch.json"
TARGET_PATCH_FLAG=""
if [[ -f "${TARGET_PATCH_PATH}" ]]; then
  TARGET_PATCH_FLAG="--target-patch ${TARGET_PATCH_PATH}"
fi

# Load Companies House API key from tenant secrets if present
if [[ -f "${VAULT_ROOT}/${CTX_TENANT_SLUG}/_secrets.env" && -z "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${VAULT_ROOT}/${CTX_TENANT_SLUG}/_secrets.env"
  set +a
fi

if [[ -z "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
  printf 'cycle.sh: COMPANIES_HOUSE_API_KEY not set\n' >&2
  printf '  Founder action: register at https://developer.company-information.service.gov.uk/ and save key to %s/_secrets.env\n' \
    "${VAULT_ROOT}/${CTX_TENANT_SLUG}" >&2
  exit 1
fi

# shellcheck disable=SC2086
node "${GENERATOR_CLI}" \
  --firm "${FIRM_NAME}" \
  --tenant "${CTX_TENANT_SLUG}" \
  --sector "${SECTOR_HINT}" \
  ${TARGET_PATCH_FLAG} \
  --iso-date "${ISO_DATE}" \
  > "${DRAFT_PATH}"

if [[ ! -s "${DRAFT_PATH}" ]]; then
  printf 'cycle.sh: generator produced empty output\n' >&2
  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
    "$(date +%s)" \
    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# Step 12 — Validate (Gate A)
# ────────────────────────────────────────────────────────────────────────

hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
  "${FIRM_NAME} 12-section draft (pre-validate)" >/dev/null

if ! bash "${CTX_AGENT_DIR}/validate.sh" "${DRAFT_PATH}"; then
  printf 'cycle.sh: Gate A failed; draft NOT moved to vault\n' >&2
  rm -f "${DRAFT_PATH}"
  exit 3
fi

# ────────────────────────────────────────────────────────────────────────
# Step 13 — Atomic vault write (per ADR-003 §3.3.4 atomic-write protocol)
# ────────────────────────────────────────────────────────────────────────

mv -f "${DRAFT_PATH}" "${REPORT_PATH}"
chmod 600 "${REPORT_PATH}"

# Final report output row per agent.md §3 audit-row signature
hh_decision_output "diagnostic_report" "${REPORT_PATH}" \
  "12-section report on ${FIRM_NAME}" >/dev/null

hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
  "$(shasum "${REPORT_PATH}" | awk '{print $1}')" \
  "$(printf '{"vault_path":"%s","firm_name":"%s","tenant":"%s"}' \
      "${REPORT_PATH}" "${FIRM_NAME}" "${CTX_TENANT_SLUG}")" >/dev/null

printf '\n\033[1;32mDiagnostic report written:\033[0m %s\n' "${REPORT_PATH}"

# ────────────────────────────────────────────────────────────────────────
# Step 14 — Optional notify
# ────────────────────────────────────────────────────────────────────────

if [[ "${NOTIFY_VIA}" == "telegram" ]]; then
  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_OPERATOR_CHAT_ID:-}" ]]; then
    SUMMARY=$(head -200 "${REPORT_PATH}" | sed 's/[^[:print:][:space:]]//g' | head -c 200)

    # Emit decision_log row BEFORE the send per agent.md §4 Step 11 spec —
    # operator_notify_telegram is green-tier per autosend-policy.yaml so the
    # send executes regardless; this row records the action for audit.
    NOTIFY_PAYLOAD=$(printf '{"recipient":"operator","chat_id":"%s","report_path":"%s","firm":"%s","summary_len":%d}' \
      "${TELEGRAM_OPERATOR_CHAT_ID}" \
      "${REPORT_PATH}" \
      "${FIRM_NAME}" \
      "${#SUMMARY}")
    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
      "$(echo "${NOTIFY_PAYLOAD}" | shasum | awk '{print $1}')" \
      "${NOTIFY_PAYLOAD}" 2>/dev/null || true

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      -d "chat_id=${TELEGRAM_OPERATOR_CHAT_ID}" \
      -d "text=Diagnostic report ready: ${FIRM_NAME} → ${REPORT_PATH}%0A%0A${SUMMARY}..." \
      >/dev/null 2>&1 || \
      printf 'cycle.sh: telegram notify failed (non-fatal)\n' >&2
  else
    printf 'cycle.sh: --notify-via telegram set but credentials missing; skipped\n' >&2
  fi
fi

# Call cleanup (drop transient LinkedIn cache per ToS gotcha §6.1)
bash "${CTX_AGENT_DIR}/cleanup.sh" 2>/dev/null || true

exit 0
