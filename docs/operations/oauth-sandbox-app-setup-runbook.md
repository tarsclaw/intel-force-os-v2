# OAuth sandbox app setup runbook — Xero · QuickBooks · TrueLayer

**Purpose:** the exact, one-shot setup for the three Cash Conductor sandbox OAuth apps so the live-test bootstrap dances succeed first try. Written 2026-06-09 (W6 Day 36) after a long live-dance loop; every failure mode we hit is captured in §4.

**Who runs this:** the founder (the OAuth consent + provider-console steps are human-in-the-loop). Claude cannot click "Allow" in your browser or see your provider consoles.

**The bootstrap helpers this unblocks:**
- `packages/mcp-connectors/xero/scripts/bootstrap-xero-oauth.sh`
- `packages/mcp-connectors/quickbooks/scripts/bootstrap-qb-oauth.sh`
- `packages/mcp-connectors/open-banking/scripts/bootstrap-ob-oauth.sh`

Each opens a browser to the provider consent screen, captures the redirect on a local callback, and writes a mode-0600 token bundle to `~/.ifos-local-vault/dev-sandbox/`. Then `pnpm --filter @ifos/<pkg> test:live` runs the live capability tests.

---

## The smooth flow (do this) — pre-flight, then one command

After the long 2026-06-08 loop, the fix was to stop clicking into misconfigured apps. Two helpers now gate that:

```bash
# 1. Doctor — checks everything verifiable WITHOUT a browser, per provider:
#    port free, creds SET + plausible, redirect_uri registered, scope accepted.
bash scripts/oauth-preflight.sh            # or: ... xero | quickbooks | truelayer

# 2. Runner — pre-flights each provider, then opens a FRESH consent window only
#    for the GREEN ones; you click Allow; it runs that package's test:live.
bash scripts/run-oauth-dances.sh           # or one provider: ... xero
```

**The rule: don't click until the doctor is GREEN for that provider.** The doctor reliably catches redirect_uri/client problems AND Xero's `invalid_scope` (it follows the redirect chain, so it sees Xero's post-login scope rejection without a browser). The one thing it cannot see is purely cosmetic — it tells you when an app is good to go.

As of 2026-06-09 the doctor reports: **QuickBooks ✓, TrueLayer ✓, Xero ✗** (the Xero app rejects accounting scopes — see §1).

---

## §0 — Universal prerequisites (all three)

1. **Redirect URI** — every app must register **exactly**:
   ```
   http://localhost:3100/callback
   ```
   Character-for-character: `http://` (not https), `localhost` (not 127.0.0.1), port `3100`, path `/callback`, no trailing slash. A mismatch → the provider never redirects back → the dance times out with "no auth code captured".

2. **Port 3100 must be free** during the dance (it is also `IFOS_DASHBOARD_PORT`). Stop the dashboard first, or set `IFOS_OAUTH_CALLBACK_PORT=<free-port>` **and** register `http://localhost:<free-port>/callback` to match.

3. **Credentials go in `~/.ifos-local-vault/dev-sandbox/_secrets.env`** — never pasted into chat (Path A). Easiest reliable way to write them: `bash scripts/fill-dev-sandbox-secrets.sh` (clipboard-based). If you hand-edit in VS Code, **press Cmd+S** — an unsaved buffer is the #1 silent failure (see §4).

4. **Timeout** — the dance now waits **600s** for your "Allow" click (raise with `IFOS_OAUTH_TIMEOUT_SECONDS`). You are not racing a 5-minute clock.

5. **Close stale provider error tabs** before re-running. A logged-in browser will happily show you an *old* error tab; open the fresh consent in a new window.

---

## §1 — Xero

**App type is the thing that bites.** The connector uses the **OAuth 2.0 Authorization Code** flow (browser consent → refresh token). That requires a **Web app**. A **Custom Connection** is a different, machine-to-machine (`client_credentials`) flow with **no browser step** — requesting accounting scopes against one via the browser flow returns **`invalid_scope` / Error 500** every time.

> **The tell (visual):** in the app's config page, a **Custom Connection shows a list of scope checkboxes**; a **Web app does not**. If you see scope checkboxes, it is the wrong type.
>
> **The tell (provable, browserless):** `bash scripts/oauth-preflight.sh xero`. It probes the authorize endpoint per scope. A correct Web app accepts `accounting.transactions`; the broken app accepts `openid`/`offline_access` but returns **`invalid_scope`** for every `accounting.*` scope. That asymmetry = not a Web app (confirmed 2026-06-09 on the current `XERO_CLIENT_ID`).

### Steps
1. https://developer.xero.com → **My Apps** → **New app**.
2. Integration type: **Web app** (a.k.a. Auth Code). **Not** "Custom connection", **not** "Mobile or desktop app".
3. Company or application URL: anything, e.g. `http://localhost:3100`.
4. **Redirect URI:** `http://localhost:3100/callback` → add → Save.
5. Copy the **Client id**; **Generate a secret** and copy it.
6. Put them in `_secrets.env`: `XERO_CLIENT_ID`, `XERO_CLIENT_SECRET` → **save**.
   - `XERO_DEMO_COMPANY_ORG_ID` (optional) selects the matching org from `/connections`.
7. Run: `bash packages/mcp-connectors/xero/scripts/bootstrap-xero-oauth.sh`
8. In the browser: sign in → choose **Demo Company (Global)** → **Allow access**.
9. Verify: `pnpm --filter @ifos/xero test:live` (expect ≥3 green).

Scopes requested: `offline_access accounting.transactions accounting.contacts.read` — all standard; a Web app accepts them automatically (no per-app enablement).

---

## §2 — QuickBooks (Intuit)

**Use the Development / Sandbox keys, not Production.** Our `_secrets.env` carries `QB_SANDBOX_REALM_ID` (a sandbox company), which only pairs with the **Development** keys. If `QB_CLIENT_ID`/`QB_CLIENT_SECRET` are the Production keys, the sandbox realm won't authorize.

### Steps
1. https://developer.intuit.com → **My Apps** → your app → **Keys & credentials**.
2. Switch to the **Development** tab (not Production).
3. Under **Redirect URIs**, add `http://localhost:3100/callback` → Save.
4. Copy the **Development** Client ID + Client Secret.
5. Put them in `_secrets.env`: `QB_CLIENT_ID`, `QB_CLIENT_SECRET` (Development keys) → **save**. Ensure `QB_SANDBOX_REALM_ID` is your sandbox company's realmId.
6. Run: `bash packages/mcp-connectors/quickbooks/scripts/bootstrap-qb-oauth.sh`
7. In the browser: sign in → **Connect** / authorize the sandbox company. (Intuit returns `realmId` on the callback; the helper warns if it differs from `QB_SANDBOX_REALM_ID`.)
8. Verify: `pnpm --filter @ifos/quickbooks test:live` (expect ≥3 green).

Scope: `com.intuit.quickbooks.accounting`.

---

## §3 — TrueLayer (Open Banking)

Standard sandbox auth-code flow against the **Mock Bank** — no Custom-Connection trap. The usual failure is the redirect URI not being saved in the console, or not finishing the Mock Bank consent.

### Steps
1. https://console.truelayer.com → your app → **Settings** (or App settings).
2. Under **Redirect URIs / Allowed redirect URIs**, add `http://localhost:3100/callback` → **Save**. (Confirm it persisted — re-open the page.)
3. Confirm `_secrets.env` has `TRUELAYER_CLIENT_ID`, `TRUELAYER_CLIENT_SECRET` (sandbox app) → saved.
4. Run: `bash packages/mcp-connectors/open-banking/scripts/bootstrap-ob-oauth.sh`
5. In the browser: pick **Mock Bank** (`uk-cs-mock`) → log in with the **mock credentials shown on TrueLayer's screen** → **Allow / Continue**.
6. Verify: `pnpm --filter @ifos/open-banking test:live` (expect ≥3 green).

Scopes: `info accounts balance transactions offline_access`. The helper records a 90-day PSD2 consent window and writes `ob-account.json` with the linked `account_id`.

---

## §4 — Troubleshooting table (everything we hit on 2026-06-08/09)

| Symptom | Real cause | Fix |
|---|---|---|
| Xero browser: **`invalid_scope` / Error 500** after sign-in | App is a **Custom Connection**, not a Web app (accounting scopes aren't grantable via the browser flow) | Create a **Web app** (§1); a Web app has no scope-checkbox list |
| Dance: **"no auth code captured within Ns"** (timeout) | redirect URI not registered exactly, OR consent not completed | Register `http://localhost:3100/callback` exactly (§0.1); finish the consent; raise `IFOS_OAUTH_TIMEOUT_SECONDS` if you need more time |
| Edited `_secrets.env` but the dance uses the **old value** | **VS Code unsaved buffer** — the file on disk still has the old value | **Cmd+S**. Verify with the SET/EMPTY awk check (names only, never `cat`) |
| Browser shows the same error after a fix | **Stale tab** — a logged-in browser re-displays an old error tab | Close old provider tabs; open the fresh consent in a new window |
| QuickBooks dance times out / won't authorize sandbox | Using **Production** keys or redirect added under Production | Use the **Development** tab keys + redirect (§2) |
| Scope rejected even though strings look valid | `scope` param spaces encoded as `+` instead of `%20`; strict providers read `+` literally | Already fixed in the helpers (`quote_via=quote`, commit cf76632) |
| `curl` of the authorize URL 302→login looked "valid" but browser still errored | Providers validate scope **after** login; a 302→login (unauthenticated) does **not** prove the scope is accepted | Test in the browser logged in, or trust the app-type check above |

---

## §5 — Path A reminder

- Never `cat`/`Read`/`head` `_secrets.env` or any `*token*`/`*credential*` path. Use `awk -F= '{print $1}'` for variable names only, or the SET/EMPTY check (names + status, never values).
- The bootstrap helpers read creds via the environment and print only HTTP statuses, output paths, token types, and expiry — never a token, secret, code, or raw id. The OAuth **client_id** appears in the authorize URL by design (it is a public identifier, not the secret).

---

*Companion to the W6 plan (`docs/operations/goal-week-6-execution-plan.md` §2) and the three `packages/mcp-connectors/*/README.md` §Live tests sections. Bootstrap helpers hardened in commit 464d4e8.*
