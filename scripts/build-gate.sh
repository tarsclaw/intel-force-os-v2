#!/usr/bin/env bash
# IFOS agent-build merge-readiness gate (parallel-agent-build-method.md §4 tier 1).
#
# The non-negotiable quality bar a worktree branch MUST pass before it is proposed
# for merge. Skip-permissions removes the per-command prompt, NOT this gate — run it
# (or let the review sub-agent run it) before every merge. Exit 0 = green; non-zero = blocked.
#
# Tiers run here:
#   1. shellcheck — all agent-bundle shells + bin helpers + fixture-test scripts
#   2. typecheck  — the MCP connector TS packages
#   3. vitest     — the MCP connector suites (fetch-mocked; no network)
#   4. fixtures   — every scripts/run-*-test.sh (DB-backed; skipped w/ warning if no DB)
#
# Usage:  bash scripts/build-gate.sh [--no-db]
#   IFOS_DB_URL defaults to the local dev DB; --no-db (or an unreachable DB) skips tier 4.

set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}" || exit 1
IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
export IFOS_DB_URL
NO_DB=0
[[ "${1:-}" == "--no-db" ]] && NO_DB=1

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }
_step() { printf '\n\033[1;34m── %s ──\033[0m\n' "$1"; }
fails=0

# ── Tier 1: shellcheck ────────────────────────────────────────────────────
_step "1. shellcheck (agent bundles + bin + fixture tests)"
mapfile -t SH < <(
  find agents -type f -name '*.sh' -not -path '*/node_modules/*' 2>/dev/null
  find scripts -maxdepth 1 -type f -name 'run-*-test.sh' 2>/dev/null
)
if [[ "${#SH[@]}" -gt 0 ]] && command -v shellcheck >/dev/null 2>&1; then
  if shellcheck -s bash "${SH[@]}"; then _ok "shellcheck CLEAN (${#SH[@]} files)"; else _fail "shellcheck findings"; fails=$((fails+1)); fi
else
  _warn "shellcheck unavailable or no shell files found"
fi

# ── Tier 2+3: connector typecheck + vitest ────────────────────────────────
_step "2+3. connector typecheck + vitest"
if command -v pnpm >/dev/null 2>&1; then
  for pkg in xero quickbooks open-banking companies-house; do
    dir="packages/mcp-connectors/${pkg}"
    [[ -d "${dir}" ]] || continue
    if (cd "${dir}" && pnpm -s typecheck && pnpm -s test) >/tmp/gate-${pkg}.log 2>&1; then
      _ok "${pkg}: typecheck + vitest green"
    else
      _fail "${pkg}: typecheck/vitest FAILED (see /tmp/gate-${pkg}.log)"; fails=$((fails+1))
    fi
  done
else
  _warn "pnpm unavailable — skipping connector typecheck/vitest"
fi

# ── Tier 4: DB-backed fixture suites ──────────────────────────────────────
_step "4. fixture suites (DB-backed)"
db_up=0
if [[ "${NO_DB}" -eq 0 ]] && command -v psql >/dev/null 2>&1 && psql "${IFOS_DB_URL}" -tAc 'SELECT 1' >/dev/null 2>&1; then
  db_up=1
fi
if [[ "${db_up}" -eq 1 ]]; then
  shopt -s nullglob
  for t in scripts/run-*-test.sh; do
    if bash "${t}" >"/tmp/gate-$(basename "${t}").log" 2>&1; then
      _ok "$(basename "${t}")"
    else
      _fail "$(basename "${t}") FAILED (see /tmp/gate-$(basename "${t}").log)"; fails=$((fails+1))
    fi
  done
else
  _warn "no reachable IFOS_DB_URL — DB-backed fixture suites SKIPPED (run on a machine with the dev DB)"
fi

# ── Verdict ───────────────────────────────────────────────────────────────
printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  printf '\033[1;32mBUILD GATE: PASS\033[0m\n'; exit 0
fi
printf '\033[1;31mBUILD GATE: FAIL (%d tier(s) red)\033[0m\n' "${fails}"; exit 1
