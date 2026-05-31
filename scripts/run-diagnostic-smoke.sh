#!/usr/bin/env bash
# shellcheck disable=SC1091
#
# IFOS Diagnostic live-smoke wrapper — one command from "keys saved" to vault report.
#
# Closes the Trigger-2 founder gate: requires only COMPANIES_HOUSE_API_KEY and
# ANTHROPIC_API_KEY in the local secrets vault, then runs the full Diagnostic
# pipeline against a real UK firm and archives the resulting 12-section report.
#
# Usage:
#   bash scripts/run-diagnostic-smoke.sh --firm "Hays plc"
#   bash scripts/run-diagnostic-smoke.sh --firm "Charterhouse Partners" --sector fintech
#   bash scripts/run-diagnostic-smoke.sh --dry-run                       # validate env; no API calls
#   bash scripts/run-diagnostic-smoke.sh --help
#
# Pre-conditions (verified at start):
#   - Two API keys saved to ~/.ifos-local-vault/migration-test/_secrets.env:
#       COMPANIES_HOUSE_API_KEY=<key>      (https://developer.company-information.service.gov.uk/)
#       ANTHROPIC_API_KEY=<key>            (https://console.anthropic.com/)
#     File must be mode 0600.
#   - pnpm install + per-package build complete (the Diagnostic packages must be built).
#
# Path A discipline:
#   - Keys are SOURCED from the secrets file; never echoed or written elsewhere.
#   - Failure messages never include key VALUES; they reference key NAMES only.
#   - The script never asks for keys interactively.

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly VAULT_ROOT="${HOME}/.ifos-local-vault"
readonly TENANT_SLUG="migration-test"
readonly SECRETS_FILE="${VAULT_ROOT}/${TENANT_SLUG}/_secrets.env"
readonly REPORTS_DIR="${VAULT_ROOT}/${TENANT_SLUG}/diagnostic-reports"
readonly ARTEFACTS_DIR="${REPO_ROOT}/docs/artefacts"

FIRM=""
SECTOR=""
DRY_RUN=0

# ────────────────────────────────────────────────────────────────────────
# UX helpers
# ────────────────────────────────────────────────────────────────────────

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; [[ -n "${2:-}" ]] && printf '    %s\n' "$2"; }
_step() { printf '\n\033[1;34m── %s ──\033[0m\n' "$1"; }

_usage() {
  cat <<EOF
IFOS Diagnostic live-smoke wrapper

Usage:
  $0 --firm "<UK firm name>" [--sector <sector>]
  $0 --dry-run         # validate env + key presence; no API calls
  $0 --help

Required:
  --firm NAME          Real UK firm to diagnose. Example: --firm "Hays plc"

Optional:
  --sector NAME        Sector hint (helps ICP fit). Example: --sector recruitment
  --dry-run            Validate setup without invoking cycle.sh
  --help               Show this message

Pre-conditions:
  Save both keys to ${SECRETS_FILE} (mode 0600):
    echo 'COMPANIES_HOUSE_API_KEY=<key>' >> ${SECRETS_FILE}
    echo 'ANTHROPIC_API_KEY=<key>'       >> ${SECRETS_FILE}
    chmod 600 ${SECRETS_FILE}

Output:
  Vault report: ${REPORTS_DIR}/<firm-slug>-<ISO-date>.md
  Archive:      ${ARTEFACTS_DIR}/diagnostic-<firm-slug>-<ISO-date>.md
EOF
}

# ────────────────────────────────────────────────────────────────────────
# Arg parsing
# ────────────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --firm)    FIRM="${2:-}"; shift 2 ;;
    --sector)  SECTOR="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help|-h) _usage; exit 0 ;;
    *)         _fail "Unknown arg: $1"; _usage; exit 2 ;;
  esac
done

if [[ $DRY_RUN -eq 0 && -z "${FIRM}" ]]; then
  _fail "--firm is required (or use --dry-run)"; _usage; exit 2
fi

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

_step "Pre-flight"

if [[ ! -d "${VAULT_ROOT}/${TENANT_SLUG}" ]]; then
  _fail "Local vault tenant dir missing" "Create it: mkdir -p ${VAULT_ROOT}/${TENANT_SLUG} && chmod 700 ${VAULT_ROOT}/${TENANT_SLUG}"
  exit 1
fi
_ok "Vault tenant dir present: ${VAULT_ROOT}/${TENANT_SLUG}"

if [[ ! -f "${SECRETS_FILE}" ]]; then
  _fail "Secrets file missing: ${SECRETS_FILE}" "Save COMPANIES_HOUSE_API_KEY and ANTHROPIC_API_KEY there (see --help)."
  exit 1
fi
_ok "Secrets file present: ${SECRETS_FILE}"

# Check mode is 0600 (security: no group/world read)
SECRETS_MODE=$(stat -f '%Lp' "${SECRETS_FILE}" 2>/dev/null || stat -c '%a' "${SECRETS_FILE}" 2>/dev/null || echo "????")
if [[ "${SECRETS_MODE}" != "600" ]]; then
  _warn "Secrets file mode is ${SECRETS_MODE}; should be 600. Run: chmod 600 ${SECRETS_FILE}"
fi

# Source keys (Path A: file → env; never echoed)
set +u
# shellcheck source=/dev/null
. "${SECRETS_FILE}"
set -u

if [[ -z "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
  _fail "COMPANIES_HOUSE_API_KEY not set in ${SECRETS_FILE}" "Add: echo 'COMPANIES_HOUSE_API_KEY=<your-key>' >> ${SECRETS_FILE}"
  exit 1
fi
_ok "COMPANIES_HOUSE_API_KEY present (length=${#COMPANIES_HOUSE_API_KEY})"

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  _fail "ANTHROPIC_API_KEY not set in ${SECRETS_FILE}" "Add: echo 'ANTHROPIC_API_KEY=<your-key>' >> ${SECRETS_FILE}"
  exit 1
fi
_ok "ANTHROPIC_API_KEY present (length=${#ANTHROPIC_API_KEY})"

# Verify Diagnostic packages are built (Day-13 deliverables)
for p in packages/utilities/web-scraper packages/mcp-connectors/companies-house packages/diagnostic-generator; do
  if [[ ! -d "${REPO_ROOT}/${p}/dist" ]] && [[ ! -d "${REPO_ROOT}/${p}/build" ]]; then
    _warn "${p}: no dist/ or build/ — running pnpm build"
    (cd "${REPO_ROOT}/${p}" && pnpm -s build) >/dev/null || { _fail "Build failed: ${p}"; exit 1; }
  fi
done
_ok "Diagnostic packages built"

# Reports dir + archive dir
mkdir -p "${REPORTS_DIR}" "${ARTEFACTS_DIR}"
chmod 700 "${REPORTS_DIR}" 2>/dev/null || true
_ok "Reports dir: ${REPORTS_DIR}"
_ok "Archive dir: ${ARTEFACTS_DIR}"

if [[ $DRY_RUN -eq 1 ]]; then
  _step "DRY RUN — environment validated"
  _ok "All pre-flight checks passed; no API calls made"
  _ok "Run live with: bash $0 --firm \"<UK firm name>\""
  exit 0
fi

# ────────────────────────────────────────────────────────────────────────
# Run cycle.sh
# ────────────────────────────────────────────────────────────────────────

_step "Running Diagnostic cycle.sh against \"${FIRM}\""

export IFOS_REPO_ROOT="${REPO_ROOT}"
export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/diagnostic"
export CTX_AGENT_NAME="diagnostic"
export CTX_TENANT_SLUG="${TENANT_SLUG}"
export IFOS_VAULT_ROOT="${VAULT_ROOT}"
export COMPANIES_HOUSE_API_KEY
export ANTHROPIC_API_KEY

CYCLE_ARGS=(--firm "${FIRM}")
[[ -n "${SECTOR}" ]] && CYCLE_ARGS+=(--sector "${SECTOR}")

if ! bash "${REPO_ROOT}/agents/recruitment/diagnostic/cycle.sh" "${CYCLE_ARGS[@]}"; then
  _fail "cycle.sh exited non-zero" "Inspect Diagnostic output above; check vault for any partial draft at /tmp/diagnostic-*"
  exit 1
fi
_ok "cycle.sh completed"

# ────────────────────────────────────────────────────────────────────────
# Locate produced report + archive
# ────────────────────────────────────────────────────────────────────────

_step "Locating + archiving report"

# Find the most recent report file in the vault reports dir
REPORT=$(find "${REPORTS_DIR}" -maxdepth 1 -name "*.md" -type f -print0 2>/dev/null \
  | xargs -0 ls -t 2>/dev/null \
  | head -1)

if [[ -z "${REPORT}" ]]; then
  _fail "No report produced under ${REPORTS_DIR}" "Check cycle.sh output for Gate A failure"
  exit 1
fi
_ok "Report produced: ${REPORT}"

REPORT_BASENAME=$(basename "${REPORT}")
ARCHIVE_PATH="${ARTEFACTS_DIR}/diagnostic-${REPORT_BASENAME}"
cp "${REPORT}" "${ARCHIVE_PATH}"
_ok "Archived to: ${ARCHIVE_PATH}"

# ────────────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────────────

WORD_COUNT=$(wc -w < "${REPORT}" | tr -d ' ')
SECTION_COUNT=$(grep -cE '^## ' "${REPORT}")

printf '\n\033[1;34m══════════════════════════════════════════════════════\033[0m\n'
printf '\033[1mDiagnostic live-smoke complete\033[0m\n'
printf 'Firm:           %s\n' "${FIRM}"
[[ -n "${SECTOR}" ]] && printf 'Sector:         %s\n' "${SECTOR}"
printf 'Vault report:   %s\n' "${REPORT}"
printf 'Archive:        %s\n' "${ARCHIVE_PATH}"
printf 'Word count:     %s\n' "${WORD_COUNT}"
printf 'Section count:  %s\n' "${SECTION_COUNT}"
printf '\nNext step: review the report; if Gate A green + 12 sections + cited evidence, Trigger 2 is CLOSED.\n'

exit 0
