#!/usr/bin/env bash
#
# bootstrap-ob-oauth.sh — one-time TrueLayer (Open Banking) OAuth bootstrap (Path A).
#
# Performs the human-in-the-loop PSD2 consent + authorization-code dance against
# the TrueLayer SANDBOX Mock Bank and writes an OpenBankingTokens bundle (shape
# per packages/mcp-connectors/open-banking/src/types.ts) to the vault so
# @ifos/open-banking's MCP_LIVE_TESTS suite + Cash Conductor cycle.sh Step-1
# auth refresh path can load it.
#
#   Step 1 (authorize): browser consent (pick Mock Bank, log in with mock creds)
#                       -> auth code   (localhost callback)
#   Step 2 (token):     auth code      -> {access_token, refresh_token, expires_in}
#   Step 3 (accounts):  access_token   -> account_id (TrueLayer connection_id)
#
# PSD2: the consent is valid ~90 days; this helper records consent_expires_at_ms
# at now + 90d (auth.ts getTokenAgeStage drives the re-consent alerting ladder).
#
# PATH A / SECRETS DISCIPLINE (per memory feedback-never-cat-secrets-files +
# review-mcp-connector §5):
#   - Credentials are READ from the secrets env file at runtime and NEVER echoed.
#   - This helper prints only HTTP statuses, the output path, token_type, and
#     expiry timestamps — never a token, code, secret, client_id, or account_id.
#   - The token file is written mode 0600 via atomic tmp+rename (in Python).
#
# VERIFICATION STATUS: authored against TrueLayer's documented sandbox OAuth
# model (README + src/auth.ts TRUELAYER_TOKEN_ENDPOINT_SANDBOX). The browser-
# consent leg cannot be exercised headlessly; first run by the founder IS the
# verification. If Step 1 never returns a code, the helper times out after 300s
# — surface per the goal STOP condition; verify the registered redirect URI.
#
# PREREQUISITE (founder, one-time, in the TrueLayer console at https://console.truelayer.com):
#   Add the redirect URI EXACTLY as:  http://localhost:3100/callback
#   (override the port with IFOS_OAUTH_CALLBACK_PORT; the registered URI must match.)
#   Mock Bank login creds are shown on the TrueLayer mock-bank consent screen.
#
# USAGE:
#   bash packages/mcp-connectors/open-banking/scripts/bootstrap-ob-oauth.sh
#
# ENV (read from $IFOS_SECRETS_FILE, default ~/.ifos-local-vault/dev-sandbox/_secrets.env):
#   TRUELAYER_CLIENT_ID      (required)
#   TRUELAYER_CLIENT_SECRET  (required)
#
# ENV (optional overrides):
#   IFOS_OAUTH_CALLBACK_PORT  (default 3100; must match the registered redirect URI)
#   IFOS_TRUELAYER_PROVIDERS  (default uk-cs-mock — the sandbox Mock Bank provider id)
#   IFOS_TOKEN_DIR            (default ~/.ifos-local-vault/dev-sandbox)
#
# OUTPUT:
#   ${IFOS_TOKEN_DIR}/ob-tokens.json    (mode 0600; OpenBankingTokens shape)
#   ${IFOS_TOKEN_DIR}/ob-account.json   (mode 0600; {connection_id} — non-secret helper for the live suite)

set -euo pipefail

SECRETS_FILE="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
TOKEN_DIR="${IFOS_TOKEN_DIR:-${HOME}/.ifos-local-vault/dev-sandbox}"
CALLBACK_PORT="${IFOS_OAUTH_CALLBACK_PORT:-3100}"
PROVIDERS="${IFOS_TRUELAYER_PROVIDERS:-uk-cs-mock}"

die() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

command -v python3 >/dev/null 2>&1 || die "required tool not found on PATH: python3"

[ -f "${SECRETS_FILE}" ] || die "secrets file not found: ${SECRETS_FILE} (run scripts/fill-dev-sandbox-secrets.sh first)"

# Path A: source secrets into the environment; never echo their values.
set -a
# shellcheck disable=SC1090
. "${SECRETS_FILE}"
set +a

missing=""
for var in TRUELAYER_CLIENT_ID TRUELAYER_CLIENT_SECRET; do
  if [ -z "${!var:-}" ]; then
    missing="${missing} ${var}"
  fi
done
[ -z "${missing}" ] || die "the following required vars are EMPTY in ${SECRETS_FILE}:${missing}
  -> run: bash scripts/fill-dev-sandbox-secrets.sh   (then re-run this bootstrap)"

mkdir -p "${TOKEN_DIR}"

printf 'TrueLayer (Open Banking) OAuth bootstrap — callback http://localhost:%s/callback\n' "${CALLBACK_PORT}"
printf '  A browser window will open. Pick "Mock Bank" + log in with the mock creds shown.\n'
printf '  (If no browser opens, copy the URL this prints into your browser.)\n\n'

export IFOS_TOKEN_DIR="${TOKEN_DIR}"
export IFOS_OAUTH_CALLBACK_PORT="${CALLBACK_PORT}"
export IFOS_TRUELAYER_PROVIDERS="${PROVIDERS}"

# -u: unbuffered stdout so the authorize URL + step progress print in real time.
python3 -u - <<'PYEOF'
import base64, http.server, json, os, secrets, sys, threading, time, urllib.parse, urllib.request, webbrowser

AUTH_DIALOG = "https://auth.truelayer-sandbox.com/"
TOKEN       = "https://auth.truelayer-sandbox.com/connect/token"
ACCOUNTS    = "https://api.truelayer-sandbox.com/data/v1/accounts"
SCOPE       = "info accounts balance transactions offline_access"
DAY_MS      = 24 * 60 * 60 * 1000

client_id     = os.environ["TRUELAYER_CLIENT_ID"]
client_secret = os.environ["TRUELAYER_CLIENT_SECRET"]
port          = int(os.environ.get("IFOS_OAUTH_CALLBACK_PORT", "3100"))
providers     = os.environ.get("IFOS_TRUELAYER_PROVIDERS", "uk-cs-mock")
token_dir     = os.environ["IFOS_TOKEN_DIR"]
redirect_uri  = f"http://localhost:{port}/callback"

def b64url(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode("ascii")
state = b64url(secrets.token_bytes(16))

authorize_url = AUTH_DIALOG + "?" + urllib.parse.urlencode({
    "response_type": "code",
    "client_id": client_id,
    "scope": SCOPE,
    "redirect_uri": redirect_uri,
    "providers": providers,
    "state": state,
})

captured = {}
class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        q = urllib.parse.urlparse(self.path)
        if not q.path.startswith("/callback"):
            self.send_response(404); self.end_headers(); return
        params = urllib.parse.parse_qs(q.query)
        captured["code"]  = (params.get("code")  or [""])[0]
        captured["state"] = (params.get("state") or [""])[0]
        captured["error"] = (params.get("error") or [""])[0]
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(b"<html><body><h2>IFOS TrueLayer bootstrap: received.</h2>"
                         b"<p>You can close this tab and return to the terminal.</p></body></html>")

srv = http.server.HTTPServer(("127.0.0.1", port), Handler)
threading.Thread(target=srv.serve_forever, daemon=True).start()

print("  [1/3] authorize ... opening browser (timeout 300s)")
print(f"        {authorize_url}\n")
try:
    webbrowser.open(authorize_url)
except Exception:
    pass

deadline = time.time() + 300
while "code" not in captured and time.time() < deadline:
    time.sleep(0.4)
srv.shutdown()

if captured.get("error"):
    sys.exit(f"ERROR: TrueLayer returned error='{captured['error']}' at the consent screen. STOP + surface.")
if not captured.get("code"):
    sys.exit("ERROR: no auth code captured within 300s. Likely a redirect_uri mismatch — "
             f"register EXACTLY {redirect_uri} in the TrueLayer console, or set IFOS_OAUTH_CALLBACK_PORT. STOP + surface.")
if captured.get("state") != state:
    sys.exit("ERROR: state mismatch (possible CSRF/stale tab). STOP + surface; re-run.")

print("  [2/3] token exchange ... ", end="", flush=True)
body = urllib.parse.urlencode({
    "grant_type": "authorization_code",
    "client_id": client_id,
    "client_secret": client_secret,
    "redirect_uri": redirect_uri,
    "code": captured["code"],
}).encode()
req = urllib.request.Request(TOKEN, data=body, method="POST", headers={
    "Content-Type": "application/x-www-form-urlencoded",
    "Accept": "application/json",
})
try:
    with urllib.request.urlopen(req, timeout=30) as r:
        tok = json.load(r)
except Exception as e:
    # Do NOT print the response body — TrueLayer may echo the refresh_token on error.
    sys.exit(f"\nERROR: token exchange failed ({type(e).__name__}). The auth code is single-use "
             "and now spent; re-run the bootstrap. STOP + surface.")
if not (tok.get("access_token") and tok.get("refresh_token") and tok.get("expires_in")):
    sys.exit("\nERROR: token response missing expected fields (need offline_access scope for refresh_token). STOP + surface.")
print("ok")

print("  [3/3] accounts ... ", end="", flush=True)
areq = urllib.request.Request(ACCOUNTS, headers={
    "Authorization": f"Bearer {tok['access_token']}",
    "Accept": "application/json",
})
try:
    with urllib.request.urlopen(areq, timeout=30) as r:
        acc = json.load(r)
except Exception as e:
    sys.exit(f"\nERROR: /data/v1/accounts call failed ({type(e).__name__}). STOP + surface.")
results = acc.get("results") or []
if not results:
    sys.exit("\nERROR: /accounts returned no accounts — the Mock Bank consent did not link an account. STOP + surface.")
connection_id = results[0]["account_id"]
print("ok")

now_ms = int(time.time() * 1000)
tokens = {
    "access_token":          tok["access_token"],
    "refresh_token":         tok["refresh_token"],
    "expires_at_ms":         now_ms + int(tok["expires_in"]) * 1000,
    "consent_expires_at_ms": now_ms + 90 * DAY_MS,
    "scope":                 tok.get("scope", SCOPE),
    "token_type":            tok.get("token_type", "Bearer"),
}

def atomic_write(path, obj):
    tmp = f"{path}.tmp.{os.getpid()}"
    fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        json.dump(obj, f, indent=2)
    os.replace(tmp, path)
    os.chmod(path, 0o600)

token_file   = os.path.join(token_dir, "ob-tokens.json")
account_file = os.path.join(token_dir, "ob-account.json")
atomic_write(token_file, tokens)
atomic_write(account_file, {"connection_id": connection_id})

print(f"\nDONE. Token bundle written: {token_file} (mode 0600)")
print(f"  token_type={tokens['token_type']}  expires_at_ms={tokens['expires_at_ms']}")
print(f"  consent_expires_at_ms={tokens['consent_expires_at_ms']}  (~90 days; PSD2)")
print(f"  account linked (id stored in {account_file}, mode 0600)")
print("  Verify shape (names only, NEVER cat the file for values):")
print(f"    python3 -c \"import json;print(list(json.load(open('{token_file}')).keys()))\"")
print("  Then run the live suite:")
print("    pnpm --filter @ifos/open-banking test:live")
PYEOF
