#!/usr/bin/env bash
#
# run-oauth-dances.sh — one command to run the Cash Conductor OAuth dances
# smoothly: pre-flight each provider, then (only for the GREEN ones) open a
# fresh consent window, capture the token, and run that package's live tests.
#
# THE "JUST APPROVE" FLOW:
#   bash scripts/run-oauth-dances.sh
#   → for each provider it pre-flights (port, creds, redirect_uri, scope); a
#     RED provider is skipped with a one-line fix pointer (no wasted clicks);
#     a GREEN provider opens its consent in a NEW browser window — you click
#     "Allow" — then its `test:live` runs and the result is summarised.
#
# Run a single provider:  bash scripts/run-oauth-dances.sh xero
#
# Pre-flight gate means you never click into a misconfigured app. Path A: this
# script never reads or prints credential values — the bootstrap helpers it
# calls source _secrets.env themselves.
#
# ENV: IFOS_OAUTH_CALLBACK_PORT (default 3100); IFOS_OAUTH_TIMEOUT_SECONDS
#      (default 600, passed through to the dance).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${REPO_ROOT}"
PORT="${IFOS_OAUTH_CALLBACK_PORT:-3100}"
WANT="${1:-all}"

# provider key : preflight-arg : package dir : pnpm filter : bootstrap script
PROVIDERS=(
  "xero:xero:xero:@ifos/xero:bootstrap-xero-oauth.sh"
  "quickbooks:quickbooks:quickbooks:@ifos/quickbooks:bootstrap-qb-oauth.sh"
  "truelayer:truelayer:open-banking:@ifos/open-banking:bootstrap-ob-oauth.sh"
)

free_port() {
  if lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
    lsof -nP -tiTCP:"${PORT}" -sTCP:LISTEN 2>/dev/null | xargs -r kill 2>/dev/null || true
    sleep 1
  fi
}

open_fresh() {  # $1 = url — prefer a brand-new Chrome window to dodge stale tabs
  open -na "Google Chrome" --args --new-window "$1" 2>/dev/null \
    || open "$1" 2>/dev/null || true
}

summary=()

run_one() {
  local key="$1" pf="$2" dir="$3" filter="$4" script="$5"
  echo ""
  echo "════════════════════════════════════════════════════════════════"
  echo "  ${key}"
  echo "════════════════════════════════════════════════════════════════"

  # ── Pre-flight gate ────────────────────────────────────────────────────
  if ! bash scripts/oauth-preflight.sh "${pf}" >/tmp/ifos-pf-"${key}".log 2>&1; then
    sed 's/^/    /' /tmp/ifos-pf-"${key}".log
    rm -f /tmp/ifos-pf-"${key}".log
    echo "  → SKIPPED (${key} pre-flight RED). Fix per docs/operations/oauth-sandbox-app-setup-runbook.md, then re-run."
    summary+=("${key}: SKIPPED (pre-flight red)")
    return 0
  fi
  rm -f /tmp/ifos-pf-"${key}".log
  echo "  pre-flight GREEN."

  # ── Dance ──────────────────────────────────────────────────────────────
  free_port
  echo "  Opening consent — click Allow in the new browser window…"
  local bootstrap="packages/mcp-connectors/${dir}/scripts/${script}"
  # Run the dance in the background so we can open a guaranteed-fresh window,
  # then wait for it to finish (it exits on callback or timeout).
  bash "${bootstrap}" >/tmp/ifos-dance-"${key}".log 2>&1 &
  local dance_pid=$!
  # Give it a moment to print the authorize URL, then force a fresh window.
  sleep 3
  local url
  url=$(grep -oE 'https://[^ ]*(authorize|truelayer-sandbox.com/)[^ ]*' /tmp/ifos-dance-"${key}".log | head -1)
  [ -n "${url}" ] && open_fresh "${url}"
  wait "${dance_pid}"; local rc=$?
  if [ "${rc}" -ne 0 ]; then
    tail -4 /tmp/ifos-dance-"${key}".log | sed 's/^/    /'
    rm -f /tmp/ifos-dance-"${key}".log
    echo "  → dance FAILED (rc=${rc})."
    summary+=("${key}: DANCE FAILED")
    return 0
  fi
  rm -f /tmp/ifos-dance-"${key}".log
  echo "  token captured ✓"

  # ── Verify ─────────────────────────────────────────────────────────────
  echo "  running ${filter} test:live …"
  if pnpm --filter "${filter}" test:live >/tmp/ifos-live-"${key}".log 2>&1; then
    local n
    n=$(grep -oE '[0-9]+ passed' /tmp/ifos-live-"${key}".log | head -1)
    echo "  → test:live GREEN (${n:-passed})"
    summary+=("${key}: LIVE GREEN (${n:-passed})")
  else
    grep -iE 'fail|error|expect' /tmp/ifos-live-"${key}".log | head -4 | sed 's/^/    /'
    echo "  → test:live RED"
    summary+=("${key}: LIVE RED")
  fi
  rm -f /tmp/ifos-live-"${key}".log
}

for entry in "${PROVIDERS[@]}"; do
  IFS=':' read -r key pf dir filter script <<<"${entry}"
  if [ "${WANT}" = "all" ] || [ "${WANT}" = "${key}" ]; then
    run_one "${key}" "${pf}" "${dir}" "${filter}" "${script}"
  fi
done

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  SUMMARY"
echo "════════════════════════════════════════════════════════════════"
for line in "${summary[@]}"; do echo "  - ${line}"; done
echo ""
echo "  Green packages: amend the wip( commit to feat( (per the goal)."
echo "  Skipped/red: fix per docs/operations/oauth-sandbox-app-setup-runbook.md, then re-run."
