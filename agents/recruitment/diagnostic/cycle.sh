#!/usr/bin/env bash
#
# Diagnostic agent — cycle.sh (workflow orchestration)
#
# Status: Proposed (pre-W3-build scaffold; Day-12 author).
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
# Build state: SCAFFOLD. MCP connectors not yet wired (Companies House,
# LinkedIn, web scraper) — those land at W3 start. This script:
#   - Structures the 10-step flow with proper hook-helpers integration
#   - Stubs each external call with a clear "W3 BUILD: <what's missing>"
#     comment + a fail-clean fallback message
#   - Generates a valid-shape Markdown report that passes V1+V2 even
#     without real upstream data, useful for fixture-driven testing

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
    --notify-via) NOTIFY_VIA="$2"; shift 2 ;;
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
    '{"escalation_code":"ESC_SCHEMA_VIOLATION","reason":"firm name too short"}' >/dev/null
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# Step 2-11 — Generate the 12 sections (scaffold; W3 wires real connectors)
# ────────────────────────────────────────────────────────────────────────
#
# Each section function emits 2-3 paragraphs of content + ≥1 evidence link.
# In the scaffold: content is structured-but-stubbed. At W3 build:
# - companies_house calls populate §1
# - LinkedIn calls populate §2-§11
# - voice_classifier scores §12

_section_1() {
  cat <<EOF

## Firm signal

**${FIRM_NAME}** — diagnostic data pending Companies House lookup at W3 build.

This section will contain: registered name + company number + incorporation date + latest filed accounts (revenue band + headcount band) + registered office + recent director changes + share-class moves.

Source: [Companies House](https://find-and-update.company-information.service.gov.uk/search?q=$(printf '%s' "${FIRM_NAME}" | tr ' ' '+'))

*W3 build: wire companies_house.profile + officers + filing_history capabilities per tools.yaml.*
EOF
}

_section_2() {
  cat <<EOF

## Online footprint

This section will contain: primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404).

Source: [LinkedIn](https://www.linkedin.com/company/${FIRM_SLUG}/) (pending; verify the slug at W3) + web scraper for {firm}.com / {firm}.co.uk.

*W3 build: wire linkedin.company_page + web_scraper.http_fetch_first_n_lines.*
EOF
}

_section_3() {
  cat <<EOF

## Sector + role-type mix

This section will contain: sectors actively recruiting for (extracted from current LinkedIn job posts); ratio of permanent vs contract roles in last 90 days; technical-vs-commercial-vs-operational split.

Sector hint provided at invocation: ${SECTOR_HINT:-<none>}.

Source: [LinkedIn jobs for ${FIRM_NAME}](https://www.linkedin.com/jobs/search/?company=${FIRM_SLUG})

*W3 build: wire linkedin.job_posts capability; parse first 50 results.*
EOF
}

_section_4() {
  cat <<EOF

## Geography

This section will contain: office locations + current hiring locations + remote-vs-onsite-vs-hybrid mix.

Source: [LinkedIn jobs location filter](https://www.linkedin.com/jobs/search/?company=${FIRM_SLUG}&location=United%20Kingdom) + Companies House registered office.

*W3 build: extract location field from job_posts results; join with companies_house.profile.address.*
EOF
}

_section_5() {
  cat <<EOF

## Deal-size band proxy

This section will contain: salary bands or day-rate ranges visible in job posts; level distribution (junior / mid / senior / executive); recent placements visible via LinkedIn employees-of-firm timeline scan.

Source: [LinkedIn jobs](https://www.linkedin.com/jobs/search/?company=${FIRM_SLUG}) + LinkedIn employee profile scan.

*W3 build: extract salary_band + experience_level from job_posts; parse employee.timeline for "Started new position at ${FIRM_NAME}" events.*
EOF
}

_section_6() {
  # ICP fit scoring — happens here at W3 build via composite of §1-§5
  cat <<EOF

## ICP fit vs target_patch

This section will contain: score 0-100 against tenant's target_patch.json (sectors / geographies / size_bands / deal_size_band).

Tenant target_patch: [loaded from /vault/${CTX_TENANT_SLUG}/common-target-patch.json](vault://target-patch).

*W3 build: composite score = avg(sector_match × 0.3, geo_match × 0.2, size_match × 0.2, deal_size_match × 0.3). Break down per dimension.*
EOF
}

_section_7() {
  cat <<EOF

## Tech stack signals

This section will contain: technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts.

Source: [LinkedIn](https://www.linkedin.com/company/${FIRM_SLUG}/) job posts + employee skill aggregation.

*W3 build: wire linkedin.job_posts.description regex for skills + linkedin.employee_search for top-N current employees' skill sections.*
EOF
}

_section_8() {
  cat <<EOF

## Pain signals

This section will contain: urgency phrases on careers page ("rapid growth", "scaling fast"); frustration phrases in director LinkedIn posts; hiring-pressure phrases.

Source: [Careers page](https://${FIRM_SLUG}.com/careers) (if exists; web scraper) + [LinkedIn director posts](https://www.linkedin.com/company/${FIRM_SLUG}/posts/).

*W3 build: wire web_scraper + regex pass for urgency keywords; linkedin.company_posts for last 90 days.*
EOF
}

_section_9() {
  cat <<EOF

## Competitor positioning

This section will contain: other recruitment firms visible in candidate flow (LinkedIn employee profiles showing previous-employer agency names); @firm tags in recruitment-agency posts; "Who's hiring this firm" inference.

Source: [LinkedIn employee profile scan](https://www.linkedin.com/search/results/people/?currentCompany=%5B%22${FIRM_SLUG}%22%5D).

*W3 build: linkedin.employee_search → for each, fetch employment_history; aggregate previous-employer recruitment-agency names.*
EOF
}

_section_10() {
  cat <<EOF

## Recent activity

This section will contain: LinkedIn company posts in last 90 days (count + summary); press releases / news mentions (Google search); Companies House filings (share allotments, director appointments) in last 90 days.

Source: [LinkedIn posts](https://www.linkedin.com/company/${FIRM_SLUG}/posts/) + Google search + Companies House filing history.

*W3 build: linkedin.company_posts + web_scraper.google_web_search + companies_house.filing_history filtered to last 90 days.*
EOF
}

_section_11() {
  cat <<EOF

## Decision-maker map

This section will contain: named people likely to be buyers (head of talent / chief people officer / hiring manager equivalents). LinkedIn profile URL per person. Tenure at firm. Recent activity.

Source: [LinkedIn employee search by title](https://www.linkedin.com/search/results/people/?currentCompany=%5B%22${FIRM_SLUG}%22%5D&keywords=head%20of%20talent).

*W3 build: linkedin.employee_search with title filter; deduplicate; max 10 named people.*
EOF
}

_section_12() {
  # The voice-classified conversation opener. At W3, this is the highest-
  # risk section — voice_classifier must score ≥ 0.75 or validate.sh fails.
  cat <<EOF

## Conversation opener

[Voice-classified cold outreach opener — generated at W3 build with LLM + voice corpus context.]

Sample shape (NOT actual; W3 wires real generation):

> "Hi [Decision-maker name from §11] — I noticed ${FIRM_NAME} has been actively hiring across [sectors from §3] over the last 90 days. With [pain signal from §8] showing up across your recent posts, curious how you're handling sourcing pressure at that pace. Happy to share what we've learned from working with similar [size band from §5] firms in [sector from §3]."

Evidence anchor: [LinkedIn director post](https://www.linkedin.com/company/${FIRM_SLUG}/posts/)

*W3 build: LLM prompt = (sections 1-11 context, especially §8 pain signals) → 2-3 sentence cold outreach pitch; voice classifier scores against tenant corpus; ≥ 3 retries if score < 0.75; ESC_VOICE_DRIFT if all retries fail.*
EOF
}

# ────────────────────────────────────────────────────────────────────────
# Assemble draft Markdown
# ────────────────────────────────────────────────────────────────────────

{
  cat <<EOF
# Diagnostic report — ${FIRM_NAME}

**Generated:** ${ISO_DATE} by Intel Force OS Diagnostic agent (Tier 2, request-driven).
**Tenant:** ${CTX_TENANT_SLUG}
**Sector hint:** ${SECTOR_HINT:-<none>}
**Report status:** SCAFFOLD (pre-W3 build; real connector calls pending). This is a structural draft demonstrating the 12-section shape.

EOF
  _section_1
  _section_2
  _section_3
  _section_4
  _section_5
  _section_6
  _section_7
  _section_8
  _section_9
  _section_10
  _section_11
  _section_12
} > "${DRAFT_PATH}"

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
