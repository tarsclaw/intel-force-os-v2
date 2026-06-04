#!/usr/bin/env bash
#
# bootstrap-bullhorn-oauth.sh — one-time Bullhorn OAuth bootstrap (Path A).
#
# Performs the full two-step Bullhorn auth dance for a sandbox/dev tenant and
# writes a BullhornTokens bundle (matching packages/mcp-connectors/bullhorn/
# src/types.ts) to the vault so @ifos/bullhorn's MCP_LIVE_TESTS suite + the
# Janitor/Scribe/Concierge cycle.sh Step-1 auth path can load it.
#
#   Step 1 (authorize): username/password -> auth code   (headless sandbox flow)
#   Step 2 (token):     auth code -> {access_token, refresh_token, expires_in}
#   Step 3 (REST login): access_token -> {BhRestToken, restUrl}
#
# PATH A / SECRETS DISCIPLINE (per memory feedback-never-cat-secrets-files +
# review-mcp-connector §5):
#   - Credentials are READ from the secrets env file at runtime and NEVER echoed.
#   - This script prints only HTTP status codes, the output path, token_type,
#     and expiry timestamps — never a token, code, secret, username, or password.
#   - The output token file is written mode 0600 via atomic tmp+rename.
#
# VERIFICATION STATUS: the HTTP flow is authored against Bullhorn's documented
# two-step model (see packages/mcp-connectors/bullhorn/README.md §"OAuth
# bootstrap") + src/auth.ts. It has NOT been run end-to-end against a live
# sandbox yet (creds not provisioned at authoring time). First run is the
# verification; if Step 1 does not return an auth code (some tenants require a
# registered redirect_uri or disable the headless username/password authorize),
# set BULLHORN_REDIRECT_URI and/or surface to the founder per the goal STOP
# condition ("OAuth bootstrap dance fails -> STOP, surface; verify cred format").
#
# USAGE:
#   bash packages/mcp-connectors/bullhorn/scripts/bootstrap-bullhorn-oauth.sh
#
# ENV (read from $IFOS_SECRETS_FILE, default ~/.ifos-local-vault/dev-sandbox/_secrets.env):
#   BULLHORN_CLIENT_ID              (required)
#   BULLHORN_CLIENT_SECRET          (required)
#   BULLHORN_SANDBOX_USERNAME       (required)
#   BULLHORN_SANDBOX_PASSWORD       (required)
#   BULLHORN_SANDBOX_CORPORATION_ID (required; recorded into the token filename)
#   BULLHORN_SANDBOX_REGION         (required; one of west|east|uk)
#   BULLHORN_REDIRECT_URI           (optional; include only if your app registered one)
#
# OUTPUT (override dir via IFOS_TOKEN_DIR):
#   ~/.ifos-local-vault/dev-sandbox/bullhorn-tokens.json   (mode 0600)

set -euo pipefail

SECRETS_FILE="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
TOKEN_DIR="${IFOS_TOKEN_DIR:-${HOME}/.ifos-local-vault/dev-sandbox}"
TOKEN_FILE="${TOKEN_DIR}/bullhorn-tokens.json"
REST_LOGIN_URL="https://rest.bullhornstaffing.com/rest-services/login"

die() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

for bin in curl jq python3; do
  command -v "$bin" >/dev/null 2>&1 || die "required tool not found on PATH: ${bin}"
done

[ -f "${SECRETS_FILE}" ] || die "secrets file not found: ${SECRETS_FILE} (run scripts/fill-dev-sandbox-secrets.sh first)"

# Path A: source secrets into the environment; never echo their values.
set -a
# shellcheck disable=SC1090
. "${SECRETS_FILE}"
set +a

# Validate required vars are present + non-empty WITHOUT printing their values.
missing=""
for var in BULLHORN_CLIENT_ID BULLHORN_CLIENT_SECRET BULLHORN_SANDBOX_USERNAME \
           BULLHORN_SANDBOX_PASSWORD BULLHORN_SANDBOX_CORPORATION_ID BULLHORN_SANDBOX_REGION; do
  if [ -z "${!var:-}" ]; then
    missing="${missing} ${var}"
  fi
done
[ -z "${missing}" ] || die "the following required vars are EMPTY in ${SECRETS_FILE}:${missing}
  -> run: bash scripts/fill-dev-sandbox-secrets.sh   (then re-run this bootstrap)"

case "${BULLHORN_SANDBOX_REGION}" in
  west) OAUTH_HOST="https://auth-west.bullhornstaffing.com" ;;
  east) OAUTH_HOST="https://auth-east.bullhornstaffing.com" ;;
  uk)   OAUTH_HOST="https://auth-uk.bullhornstaffing.com" ;;
  *)    die "BULLHORN_SANDBOX_REGION must be one of west|east|uk" ;;
esac

REDIRECT_URI="${BULLHORN_REDIRECT_URI:-}"
# Conditionally pass redirect_uri only if the app registered one. Array form is
# bash-3.2 + `set -u` safe via the ${arr[@]+...} guard (empty array otherwise).
redirect_args=()
if [ -n "${REDIRECT_URI}" ]; then
  redirect_args=(--data-urlencode "redirect_uri=${REDIRECT_URI}")
fi

printf 'Bullhorn OAuth bootstrap — region class=%s, corp recorded into filename only.\n' \
  "$(printf '%s' "${BULLHORN_SANDBOX_REGION}" | tr -dc '[:lower:]')"

# ── Step 1: authorize → auth code (capture from the 302 Location header) ──────
printf '  [1/3] authorize ... '
authorize_headers="$(
  curl -sS -i -o /dev/null -D - --max-time 30 \
    --data-urlencode "client_id=${BULLHORN_CLIENT_ID}" \
    --data-urlencode "response_type=code" \
    --data-urlencode "action=Login" \
    --data-urlencode "username=${BULLHORN_SANDBOX_USERNAME}" \
    --data-urlencode "password=${BULLHORN_SANDBOX_PASSWORD}" \
    ${redirect_args[@]+"${redirect_args[@]}"} \
    "${OAUTH_HOST}/oauth/authorize" 2>/dev/null
)" || die "authorize request failed (network)"

authorize_status="$(printf '%s' "${authorize_headers}" | awk 'toupper($1) ~ /HTTP/ {print $2; exit}')"
location="$(printf '%s' "${authorize_headers}" | awk -F': ' 'tolower($1)=="location"{print $2; exit}' | tr -d '\r')"
printf 'HTTP %s\n' "${authorize_status:-<none>}"

AUTH_CODE="$(printf '%s' "${location}" | sed -n 's/.*[?&]code=\([^&]*\).*/\1/p')"
if [ -z "${AUTH_CODE}" ]; then
  die "Step 1 did not return an auth code (HTTP ${authorize_status:-?}).
  Likely causes: headless username/password authorize disabled for this app, OR a
  registered redirect_uri is required. Set BULLHORN_REDIRECT_URI to the value
  registered for this client_id and retry. STOP + surface to founder per goal."
fi

# ── Step 2: token exchange → {access_token, refresh_token, expires_in} ────────
printf '  [2/3] token exchange ... '
token_json="$(
  curl -sS --max-time 30 -X POST \
    --data-urlencode "grant_type=authorization_code" \
    --data-urlencode "code=${AUTH_CODE}" \
    --data-urlencode "client_id=${BULLHORN_CLIENT_ID}" \
    --data-urlencode "client_secret=${BULLHORN_CLIENT_SECRET}" \
    ${redirect_args[@]+"${redirect_args[@]}"} \
    "${OAUTH_HOST}/oauth/token" 2>/dev/null
)" || die "token request failed (network)"

if ! printf '%s' "${token_json}" | jq -e '.access_token and .refresh_token and .expires_in' >/dev/null 2>&1; then
  # Do NOT print the body verbatim — Bullhorn may echo the refresh_token on error.
  die "Step 2 token exchange did not return the expected fields. STOP + surface
  to founder (do not retry blindly — the auth code is single-use and now spent)."
fi
printf 'ok\n'

OAUTH_ACCESS="$(printf '%s' "${token_json}" | jq -r '.access_token')"

# ── Step 3: REST login → {BhRestToken, restUrl} ──────────────────────────────
printf '  [3/3] REST login ... '
login_json="$(
  curl -sS --max-time 30 -G \
    --data-urlencode "version=2.0" \
    --data-urlencode "access_token=${OAUTH_ACCESS}" \
    "${REST_LOGIN_URL}" 2>/dev/null
)" || die "REST login request failed (network)"

if ! printf '%s' "${login_json}" | jq -e '.BhRestToken and .restUrl' >/dev/null 2>&1; then
  die "Step 3 REST login did not return BhRestToken/restUrl. The OAuth token was
  issued but /login refused it. STOP + surface to founder."
fi
printf 'ok\n'

# ── Compose BullhornTokens bundle (shape per src/types.ts) ────────────────────
NOW_MS="$(python3 -c 'import time; print(int(time.time()*1000))')"

tokens_json="$(
  jq -n \
    --argjson now "${NOW_MS}" \
    --argjson token "${token_json}" \
    --argjson login "${login_json}" \
    '{
      oauth_access_token:          $token.access_token,
      oauth_refresh_token:         $token.refresh_token,
      oauth_expires_at_ms:         ($now + (($token.expires_in // 600) * 1000)),
      scope:                       ($token.scope // ""),
      token_type:                  ($token.token_type // "Bearer"),
      bh_rest_token:               $login.BhRestToken,
      rest_url:                    $login.restUrl,
      bh_rest_token_expires_at_ms: ($now + (($token.expires_in // 600) * 1000))
    }'
)"

# ── Atomic write, mode 0600 ───────────────────────────────────────────────────
mkdir -p "${TOKEN_DIR}"
TMP_FILE="${TOKEN_FILE}.tmp.$$"
umask 077
printf '%s\n' "${tokens_json}" > "${TMP_FILE}"
chmod 0600 "${TMP_FILE}"
mv -f "${TMP_FILE}" "${TOKEN_FILE}"
chmod 0600 "${TOKEN_FILE}"

# Safe summary only — no token material.
token_type="$(printf '%s' "${tokens_json}" | jq -r '.token_type')"
expires_at="$(printf '%s' "${tokens_json}" | jq -r '.oauth_expires_at_ms')"
printf '\nDONE. Token bundle written: %s (mode 0600)\n' "${TOKEN_FILE}"
printf '  token_type=%s  expires_at_ms=%s\n' "${token_type}" "${expires_at}"
printf '  Verify shape (names only, NEVER cat the file for values):\n'
printf '    jq -r "keys[]" %s\n' "${TOKEN_FILE}"
printf '  Then run the live suite:\n'
printf '    MCP_LIVE_TESTS=1 pnpm --filter @ifos/bullhorn test:live\n'
