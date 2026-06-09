#!/usr/bin/env bash
#
# oauth-preflight.sh — pre-flight doctor for the Cash Conductor OAuth dances.
#
# WHY THIS EXISTS: the bootstrap helpers open a browser and wait. Before this
# doctor, every misconfiguration (unregistered redirect URI, wrong client,
# wrong app type) only surfaced AFTER you clicked — a reactive loop. This checks
# everything verifiable WITHOUT a browser, up front, and prints a clear GO/NO-GO
# per provider so you fix config first and then just click "Allow".
#
# WHAT IT CAN AND CANNOT CATCH:
#   ✓ port 3100 free
#   ✓ required creds SET (+ plausible length) — names only, never values (Path A)
#   ✓ redirect_uri registered + client_id recognised (probes the real authorize
#     endpoint, FOLLOWS redirects, flags only definitive OAuth error markers —
#     no false positives from redirect_uri echoed in a login page's returnUrl)
#   ✗ Xero app TYPE (Web app vs Custom Connection). Xero validates scope only
#     AFTER login, so a browserless probe cannot see it. The doctor prints the
#     reminder; the fix is in docs/operations/oauth-sandbox-app-setup-runbook.md.
#
# PATH A: creds are sourced into the env and never printed. Only the public
# client_id is sent to the provider (it appears in every authorize URL).
#
# USAGE:
#   bash scripts/oauth-preflight.sh            # all three
#   bash scripts/oauth-preflight.sh xero       # one provider (xero|quickbooks|truelayer)
#
# ENV: IFOS_SECRETS_FILE (default ~/.ifos-local-vault/dev-sandbox/_secrets.env),
#      IFOS_OAUTH_CALLBACK_PORT (default 3100).

set -euo pipefail

SECRETS_FILE="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
PORT="${IFOS_OAUTH_CALLBACK_PORT:-3100}"
REDIRECT="http://localhost:${PORT}/callback"
WANT="${1:-all}"

command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 not found" >&2; exit 1; }
command -v curl    >/dev/null 2>&1 || { echo "ERROR: curl not found" >&2; exit 1; }
[ -f "${SECRETS_FILE}" ] || { echo "ERROR: secrets file not found: ${SECRETS_FILE}" >&2; exit 1; }

set -a
# shellcheck disable=SC1090
. "${SECRETS_FILE}"
set +a

fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=$((fail+1)); }
note() { printf '  \033[33m•\033[0m %s\n' "$1"; }

echo "OAuth pre-flight — redirect ${REDIRECT}, secrets $(basename "${SECRETS_FILE}")"
echo ""

# ── Port 3100 ────────────────────────────────────────────────────────────────
if lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
  printf '\033[31m✗\033[0m port %s BUSY — stop whatever holds it (the dashboard?) before a dance\n' "${PORT}"
  fail=$((fail+1))
else
  printf '\033[32m✓\033[0m port %s free\n' "${PORT}"
fi
echo ""

# Required vars are SET + plausibly long (names only; never prints a value).
creds_set() {
  local allgood=1 v val
  for v in "$@"; do
    val="${!v:-}"
    if [ -z "${val}" ]; then bad "${v} EMPTY in _secrets.env"; allgood=0
    elif [ "${#val}" -lt 8 ]; then bad "${v} looks too short (len ${#val}) — wrong value?"; allgood=0
    else ok "${v} set (len ${#val})"; fi
  done
  return $((1-allgood))
}

# Probe the authorize endpoint: follow redirects, flag ONLY definitive OAuth
# error markers (invalid_scope/unauthorized_client/invalid_client/error=...).
# A bare redirect_uri in the page (login returnUrl) is NOT an error.
probe_authorize() {
  local base="$1" qextra="$2" cidvar="$3"
  local url body code
  url=$(python3 -c "
import urllib.parse,os
p={'response_type':'code','client_id':os.environ['${cidvar}'],'redirect_uri':'${REDIRECT}','state':'preflight'}
${qextra}
print('${base}?'+urllib.parse.urlencode(p, quote_via=urllib.parse.quote))
")
  body=$(curl -sSL --max-time 25 -w '\n__HTTP__%{http_code}' "${url}" 2>/dev/null) || { bad "authorize probe network error"; return 1; }
  code=$(printf '%s' "${body}" | sed -n 's/.*__HTTP__\([0-9]*\)$/\1/p')
  if printf '%s' "${body}" | grep -qi 'invalid_scope'; then
    bad "authorize → invalid_scope (Xero: app is a Custom Connection, not a Web app — see runbook)"
  elif printf '%s' "${body}" | grep -qiE 'error=invalid_client|"?error"?[:=][[:space:]]*"?(unauthorized_client|invalid_client|invalid_request)|invalid redirect_uri|redirect_uri.{0,20}(mismatch|not.{0,5}registered|invalid)'; then
    bad "authorize → redirect_uri/client error — register EXACTLY ${REDIRECT}, verify the client_id"
  else
    ok "authorize → ${code:-?}; client_id recognised, scope accepted, login/consent shown"
    note "  ⚠ this does NOT prove the redirect URI is registered for the CALLBACK. Some"
    note "    providers (Intuit) accept the authorize request but reject the redirect at the"
    note "    final step ('redirect_uri ... is invalid') — that is only catchable in-browser."
    note "    So: still register http://localhost:3100/callback EXACTLY under the SAME key set"
    note "    (e.g. Intuit Development tab) as the client_id you put in _secrets.env."
  fi
}

run_xero() {
  echo "Xero:"
  creds_set XERO_CLIENT_ID XERO_CLIENT_SECRET || true
  probe_authorize "https://login.xero.com/identity/connect/authorize" \
    "p['scope']='offline_access accounting.invoices.read accounting.payments accounting.contacts.read'" XERO_CLIENT_ID
  note "Xero apps created after 2026-03-02 use granular scopes (accounting.invoices.read etc.); the old broad accounting.transactions scope is retired for them."
  echo ""
}
run_qb() {
  echo "QuickBooks:"
  creds_set QB_CLIENT_ID QB_CLIENT_SECRET QB_SANDBOX_REALM_ID || true
  probe_authorize "https://appcenter.intuit.com/connect/oauth2" \
    "p['scope']='com.intuit.quickbooks.accounting'" QB_CLIENT_ID
  note "Manual: client/secret must be the DEVELOPMENT (sandbox) keys, not Production."
  echo ""
}
run_tl() {
  echo "TrueLayer:"
  creds_set TRUELAYER_CLIENT_ID TRUELAYER_CLIENT_SECRET || true
  probe_authorize "https://auth.truelayer-sandbox.com/" \
    "p['scope']='info accounts balance transactions offline_access'; p['providers']='uk-cs-mock'" TRUELAYER_CLIENT_ID
  note "At consent: pick Mock Bank (uk-cs-mock) + the mock login shown on screen."
  echo ""
}

case "${WANT}" in
  xero)       run_xero ;;
  quickbooks|qb) run_qb ;;
  truelayer|ob|open-banking) run_tl ;;
  all)        run_xero; run_qb; run_tl ;;
  *) echo "unknown provider '${WANT}' (use: xero | quickbooks | truelayer | all)"; exit 2 ;;
esac

if [ "${fail}" -eq 0 ]; then
  printf '\033[32mPRE-FLIGHT GREEN\033[0m — redirect_uri + client OK. Run the dance(s); just click Allow.\n'
  printf '(Xero only: still confirm the app is a Web app — that is not browserless-detectable.)\n'
else
  printf '\033[31mPRE-FLIGHT found %s blocker(s)\033[0m — fix above, then re-run. See the runbook.\n' "${fail}"
  exit 1
fi
