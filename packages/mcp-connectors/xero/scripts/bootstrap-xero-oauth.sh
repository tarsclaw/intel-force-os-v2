#!/usr/bin/env bash
#
# bootstrap-xero-oauth.sh — one-time Xero OAuth 2.0 + PKCE bootstrap (Path A).
#
# Performs the human-in-the-loop authorization-code dance for a Xero org
# (the Demo Company sandbox by default) and writes a XeroTokens bundle
# (shape per packages/mcp-connectors/xero/src/types.ts) to the vault so
# @ifos/xero's MCP_LIVE_TESTS suite + Cash Conductor cycle.sh Step-1 auth
# refresh path can load it.
#
#   Step 1 (authorize): browser consent  -> auth code   (localhost callback)
#   Step 2 (token):     auth code + PKCE  -> {access_token, refresh_token, expires_in}
#   Step 3 (connections): access_token    -> tenant_id (Xero "connection" UUID)
#
# PATH A / SECRETS DISCIPLINE (per memory feedback-never-cat-secrets-files +
# review-mcp-connector §5):
#   - Credentials are READ from the secrets env file at runtime and NEVER echoed.
#   - This helper prints only HTTP statuses, the output path, token_type,
#     expiry timestamps, and the tenant *name* — never a token, code, secret,
#     client_id, or the raw tenant UUID.
#   - The token file is written mode 0600 via atomic tmp+rename (in Python).
#
# VERIFICATION STATUS: authored against Xero's documented OAuth 2.0 + PKCE
# model (README §"OAuth bootstrap" + src/auth.ts XERO_TOKEN_ENDPOINT). The
# browser-consent leg cannot be exercised headlessly; first run by the founder
# IS the verification. If Step 1 never returns a code (redirect_uri mismatch is
# the usual cause), the helper times out after 300s — surface to the founder
# per the goal STOP condition and verify the registered redirect_uri matches
# IFOS_OAUTH_REDIRECT_URI below.
#
# PREREQUISITE (founder, one-time, in the Xero app at https://developer.xero.com):
#   Register the redirect URI EXACTLY as:  http://localhost:3100/callback
#   (override the port with IFOS_OAUTH_CALLBACK_PORT; the registered URI must match.)
#
# USAGE:
#   bash packages/mcp-connectors/xero/scripts/bootstrap-xero-oauth.sh
#
# ENV (read from $IFOS_SECRETS_FILE, default ~/.ifos-local-vault/dev-sandbox/_secrets.env):
#   XERO_CLIENT_ID            (required)
#   XERO_CLIENT_SECRET        (required; Xero web/standard app is a confidential client)
#   XERO_DEMO_COMPANY_ORG_ID  (optional; selects the matching tenant from /connections)
#
# ENV (optional overrides):
#   IFOS_OAUTH_CALLBACK_PORT  (default 3100 per .envrc IFOS_DASHBOARD_PORT; stop the
#                              dashboard first if it is running, or pick a free port
#                              that you also registered as the redirect URI)
#   IFOS_TOKEN_DIR            (default ~/.ifos-local-vault/dev-sandbox)
#   IFOS_OAUTH_TIMEOUT_SECONDS (default 600; how long to wait for the browser callback)
#   IFOS_XERO_SCOPE          (default "offline_access accounting.transactions
#                              accounting.contacts.read"; override to narrow scope)
#
# OUTPUT:
#   ${IFOS_TOKEN_DIR}/xero-tokens.json   (mode 0600; XeroTokens shape)
#   ${IFOS_TOKEN_DIR}/xero-tenant.json   (mode 0600; {tenant_id, tenant_name} — non-secret helper for the live suite)

set -euo pipefail

SECRETS_FILE="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
TOKEN_DIR="${IFOS_TOKEN_DIR:-${HOME}/.ifos-local-vault/dev-sandbox}"
CALLBACK_PORT="${IFOS_OAUTH_CALLBACK_PORT:-3100}"

die() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

command -v python3 >/dev/null 2>&1 || die "required tool not found on PATH: python3"

[ -f "${SECRETS_FILE}" ] || die "secrets file not found: ${SECRETS_FILE} (run scripts/fill-dev-sandbox-secrets.sh first)"

# Path A: source secrets into the environment; never echo their values.
set -a
# shellcheck disable=SC1090
. "${SECRETS_FILE}"
set +a

# Validate required vars are present + non-empty WITHOUT printing their values.
missing=""
for var in XERO_CLIENT_ID XERO_CLIENT_SECRET; do
  if [ -z "${!var:-}" ]; then
    missing="${missing} ${var}"
  fi
done
[ -z "${missing}" ] || die "the following required vars are EMPTY in ${SECRETS_FILE}:${missing}
  -> run: bash scripts/fill-dev-sandbox-secrets.sh   (then re-run this bootstrap)"

mkdir -p "${TOKEN_DIR}"

printf 'Xero OAuth bootstrap — callback http://localhost:%s/callback\n' "${CALLBACK_PORT}"
printf '  A browser window will open. Sign in + click "Allow access".\n'
printf '  (If no browser opens, copy the URL this prints into your browser.)\n\n'

export IFOS_TOKEN_DIR="${TOKEN_DIR}"
export IFOS_OAUTH_CALLBACK_PORT="${CALLBACK_PORT}"

# Hand the OAuth mechanics to Python (stdlib only). It reads XERO_* from the
# environment (exported above) and never prints credential material.
# -u: unbuffered stdout so the authorize URL + step progress print in real time.
python3 -u - <<'PYEOF'
import base64, hashlib, http.server, json, os, secrets, sys, threading, time, urllib.parse, urllib.request, webbrowser

AUTHORIZE = "https://login.xero.com/identity/connect/authorize"
TOKEN     = "https://identity.xero.com/connect/token"
CONNS     = "https://api.xero.com/connections"
# Xero granular scopes (apps created after 2026-03-02 only have these; the old
# broad accounting.transactions scope is retired for new apps). invoices.read =
# listOpenInvoices/getInvoice; payments = listPayments + writePaymentReceived;
# contacts.read = invoice contact sub-objects. Override with IFOS_XERO_SCOPE.
SCOPE     = os.environ.get("IFOS_XERO_SCOPE", "offline_access accounting.invoices.read accounting.payments accounting.contacts.read")

client_id     = os.environ["XERO_CLIENT_ID"]
client_secret = os.environ["XERO_CLIENT_SECRET"]
org_id        = os.environ.get("XERO_DEMO_COMPANY_ORG_ID", "").strip()
port          = int(os.environ.get("IFOS_OAUTH_CALLBACK_PORT", "3100"))
token_dir     = os.environ["IFOS_TOKEN_DIR"]
timeout_s     = int(os.environ.get("IFOS_OAUTH_TIMEOUT_SECONDS", "600"))
redirect_uri  = f"http://localhost:{port}/callback"

def b64url(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode("ascii")
verifier  = b64url(secrets.token_bytes(32))
challenge = b64url(hashlib.sha256(verifier.encode("ascii")).digest())
state     = b64url(secrets.token_bytes(16))

# Xero reads the scope param strictly: spaces MUST be %20, not + (it treats a
# literal + as part of the scope token -> invalid_scope). Force percent-encoding
# of spaces via quote_via=quote (urlencode defaults to quote_plus -> '+').
authorize_url = AUTHORIZE + "?" + urllib.parse.urlencode({
    "response_type": "code",
    "client_id": client_id,
    "redirect_uri": redirect_uri,
    "scope": SCOPE,
    "state": state,
    "code_challenge": challenge,
    "code_challenge_method": "S256",
}, quote_via=urllib.parse.quote)

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
        self.wfile.write(b"<html><body><h2>IFOS Xero bootstrap: received.</h2>"
                         b"<p>You can close this tab and return to the terminal.</p></body></html>")

srv = http.server.HTTPServer(("127.0.0.1", port), Handler)
threading.Thread(target=srv.serve_forever, daemon=True).start()

print(f"  [1/3] authorize ... opening browser (timeout {timeout_s}s)")
print(f"        {authorize_url}\n")
try:
    webbrowser.open(authorize_url)
except Exception:
    pass

deadline = time.time() + timeout_s
while "code" not in captured and time.time() < deadline:
    time.sleep(0.4)
srv.shutdown()

if captured.get("error"):
    sys.exit(f"ERROR: Xero returned error='{captured['error']}' at the consent screen. STOP + surface.")
if not captured.get("code"):
    sys.exit(f"ERROR: no auth code captured within {timeout_s}s. No callback reached "
             f"{redirect_uri}. Most likely one of:\n"
             f"  (a) redirect_uri not registered EXACTLY as {redirect_uri} in the Xero app;\n"
             "  (b) the browser showed 'invalid_scope' — the Xero app is a Custom Connection,\n"
             "      not a Web app (Auth Code). Accounting scopes only work on a Web app;\n"
             "  (c) consent not completed in time (raise IFOS_OAUTH_TIMEOUT_SECONDS).\n"
             "  See docs/operations/oauth-sandbox-app-setup-runbook.md. STOP + surface.")
if captured.get("state") != state:
    sys.exit("ERROR: state mismatch (possible CSRF/stale tab). STOP + surface; re-run.")

print("  [2/3] token exchange ... ", end="", flush=True)
basic = base64.b64encode(f"{client_id}:{client_secret}".encode()).decode()
body = urllib.parse.urlencode({
    "grant_type": "authorization_code",
    "code": captured["code"],
    "redirect_uri": redirect_uri,
    "code_verifier": verifier,
}).encode()
req = urllib.request.Request(TOKEN, data=body, method="POST", headers={
    "Authorization": f"Basic {basic}",
    "Content-Type": "application/x-www-form-urlencoded",
})
try:
    with urllib.request.urlopen(req, timeout=30) as r:
        tok = json.load(r)
except Exception as e:
    # Do NOT print the response body — Xero may echo the refresh_token on error.
    sys.exit(f"\nERROR: token exchange failed ({type(e).__name__}). The auth code is single-use "
             "and now spent; re-run the bootstrap. STOP + surface.")
if not (tok.get("access_token") and tok.get("refresh_token") and tok.get("expires_in")):
    sys.exit("\nERROR: token response missing expected fields. STOP + surface.")
print("ok")

print("  [3/3] connections ... ", end="", flush=True)
creq = urllib.request.Request(CONNS, headers={
    "Authorization": f"Bearer {tok['access_token']}",
    "Accept": "application/json",
})
try:
    with urllib.request.urlopen(creq, timeout=30) as r:
        conns = json.load(r)
except Exception as e:
    sys.exit(f"\nERROR: /connections call failed ({type(e).__name__}). STOP + surface.")
if not conns:
    sys.exit("\nERROR: /connections returned no orgs — the consent did not grant an org. STOP + surface.")
chosen = None
if org_id:
    for c in conns:
        if c.get("tenantId") == org_id:
            chosen = c; break
chosen = chosen or conns[0]
tenant_id   = chosen["tenantId"]
tenant_name = chosen.get("tenantName", "<unknown>")
print("ok")

now_ms = int(time.time() * 1000)
tokens = {
    "access_token":  tok["access_token"],
    "refresh_token": tok["refresh_token"],
    "expires_at_ms": now_ms + int(tok["expires_in"]) * 1000,
    "scope":         tok.get("scope", SCOPE),
    "token_type":    tok.get("token_type", "Bearer"),
}

def atomic_write(path, obj):
    tmp = f"{path}.tmp.{os.getpid()}"
    fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        json.dump(obj, f, indent=2)
    os.replace(tmp, path)
    os.chmod(path, 0o600)

token_file  = os.path.join(token_dir, "xero-tokens.json")
tenant_file = os.path.join(token_dir, "xero-tenant.json")
atomic_write(token_file, tokens)
atomic_write(tenant_file, {"tenant_id": tenant_id, "tenant_name": tenant_name})

print(f"\nDONE. Token bundle written: {token_file} (mode 0600)")
print(f"  token_type={tokens['token_type']}  expires_at_ms={tokens['expires_at_ms']}")
print(f"  tenant_name={tenant_name}  (tenant UUID stored in {tenant_file}, mode 0600)")
print("  Verify shape (names only, NEVER cat the file for values):")
print(f"    python3 -c \"import json;print(list(json.load(open('{token_file}')).keys()))\"")
print("  Then run the live suite:")
print("    pnpm --filter @ifos/xero test:live")
PYEOF
