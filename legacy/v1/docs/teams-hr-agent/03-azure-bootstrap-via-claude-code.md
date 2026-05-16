# 03 — Azure Bootstrap via Claude Code

**The one-time, 30-minute Intel Force OS setup. Done once, ever. Claude Code drives 90% of it.**

This is the "AI agent configures Azure for me" answer, made specific. You sit at your terminal with Claude Code open. Claude Code types commands. You read them, confirm, and watch them execute. At the end, you have a registered bot, an Entra ID app, a deployed Worker, and a working Teams app manifest.

**What this file gives you:** the exact sequence of steps, what Claude Code does at each step, what you do, and what success looks like.

---

## Prerequisites

Before starting, ensure:

- [ ] Microsoft 365 account with Developer Program sandbox (sign up at `developer.microsoft.com/microsoft-365/dev-program`, free, 90-day renewable)
- [ ] Cloudflare account with a custom domain (intelforce.ai) added
- [ ] Node.js 18+ installed
- [ ] Claude Code running in VS Code
- [ ] 30 minutes of uninterrupted time

**Do NOT proceed if you're missing any prerequisite. Backing out halfway through is painful.**

---

## The five stages

| Stage | What happens | Time | Who drives |
|---|---|---|---|
| A | CLI tools installed and authenticated | 5 min | Claude Code + you approve |
| B | Azure Entra ID app + bot registered | 10 min | Claude Code runs `az` commands |
| C | Cloudflare Worker deployed with secrets | 5 min | Claude Code runs `wrangler` |
| D | Teams app manifest built and packaged | 5 min | Claude Code generates files |
| E | Sideloaded into dev tenant + smoke tested | 5 min | You, manually |

---

## Stage A — Install and authenticate CLIs (5 min)

### A.1 The Claude Code prompt

```
I'm setting up a new Teams bot project for Intel Force OS. Please:
1. Check which CLI tools are already installed: node, npm, wrangler, az, teamsfx
2. Install whatever's missing using the appropriate method for macOS (brew/npm)
3. Run `wrangler login` and `az login` so I can authenticate
4. Verify all are working by running version commands

Do NOT try to install anything that requires sudo without asking me first.
```

### A.2 What Claude Code will do

- Run `which node wrangler az teamsfx` to check availability
- Install missing tools:
  - `wrangler`: `npm install -g wrangler`
  - `az`: `brew install azure-cli`
  - `teamsfx` (optional): `npm install -g @microsoft/teamsfx-cli`
- Open browser windows for `wrangler login` and `az login`
- Run `node -v`, `wrangler --version`, `az --version` to verify

### A.3 What you do

- Watch the browser windows Claude Code opens
- Log in to Cloudflare (wrangler) and Microsoft (az) using your Intel Force account
- Confirm to Claude Code when auth is complete

### A.4 Success criteria

```
node -v             → v18.x or higher
wrangler --version  → 3.x or higher
az --version        → 2.x or higher (shows Azure CLI version table)
```

---

## Stage B — Azure Entra ID + bot registration (10 min)

### B.1 The Claude Code prompt

```
I need to register a new Teams bot for Intel Force OS. The bot will run
on Cloudflare Workers at https://bot.intelforce.ai.

Please:
1. Create an Entra ID multi-tenant app registration named "Intel Force OS"
   using `az ad app create`. It needs to be multi-tenant (AzureADMultipleOrgs).
2. Create a client secret for the app that expires in 12 months.
3. Save the app ID, tenant ID, and secret to a file .env.local.
   Do NOT commit this file.
4. Use the Teams Developer Portal (dev.teams.microsoft.com) to register
   a bot — but since we want to automate, use the `az bot create` command
   if possible, OR guide me through the manual UI steps if CLI doesn't work.
5. Configure the bot's messaging endpoint to https://bot.intelforce.ai/api/messages
6. Enable Microsoft Teams as a bot channel.
7. Output everything I need to paste into the Teams app manifest:
   app ID, bot ID, messaging endpoint.

Ask me to confirm at each Azure command before executing.
```

### B.2 What Claude Code will actually do

This is a mix of `az` CLI commands and, potentially, Teams Developer Portal clicks. Concretely:

```bash
# Create Entra ID app (multi-tenant)
az ad app create \
  --display-name "Intel Force OS" \
  --sign-in-audience AzureADMultipleOrgs \
  --web-redirect-uris "https://token.botframework.com/.auth/web/redirect"

# Capture the appId from output → APP_ID
# Create client secret
az ad app credential reset \
  --id $APP_ID \
  --years 1 \
  --display-name "Primary secret"

# Capture password from output → APP_PASSWORD

# Create Azure Bot Service registration (F0 = free tier)
az bot create \
  --resource-group intelforce-rg \
  --name intel-force-os-bot \
  --app-type MultiTenant \
  --appid $APP_ID \
  --endpoint "https://bot.intelforce.ai/api/messages" \
  --sku F0
  
# Note: az bot create DOES require a resource group. Create one first:
# az group create --name intelforce-rg --location uksouth

# Enable Teams channel on the bot
az bot msteams create \
  --resource-group intelforce-rg \
  --name intel-force-os-bot
```

### B.3 The one Azure resource group you'll have

Despite the "minimise Azure" goal, `az bot create` requires a resource group. You'll have one called `intelforce-rg` containing one resource (the bot). This is free (F0 SKU) and doesn't incur charges at your scale. It's the minimum Azure footprint possible for a real Teams bot.

**Alternative if you genuinely want zero Azure resources:** skip `az bot create` and use the Teams Developer Portal UI (`dev.teams.microsoft.com` → Tools → Bots) to register the bot. This creates the bot without an explicit resource group in your subscription. Claude Code can guide you through the UI clicks but can't automate them. Recommendation: accept the one resource group, let Claude Code automate.

### B.4 Output you need to capture

At end of Stage B, you should have in `.env.local`:

```bash
MICROSOFT_APP_ID=12345678-abcd-1234-efgh-1234567890ab
MICROSOFT_APP_PASSWORD=xYzABC123...
MICROSOFT_TENANT_ID=your-intel-force-tenant-id
BOT_MESSAGING_ENDPOINT=https://bot.intelforce.ai/api/messages
BOT_NAME=intel-force-os-bot
```

### B.5 What you do manually

- **Approve each `az` command before execution** — Claude Code should ask, but double-check. Azure commands create real resources and you want to see what's happening.
- **If any command fails**, screenshot and paste into Claude Code. Common issues:
  - Tenant doesn't have a subscription → need to upgrade dev tenant (free)
  - Resource group creation requires confirmation
  - `az bot create` fails because Bot Service provider isn't registered → run `az provider register --namespace Microsoft.BotService`

### B.6 Success criteria

```bash
# This should return a JSON showing the bot with Teams channel enabled
az bot show --resource-group intelforce-rg --name intel-force-os-bot
```

Output should include `"endpoint": "https://bot.intelforce.ai/api/messages"` and `"msaAppId"` matching your `.env.local`.

---

## Stage C — Cloudflare Worker scaffold and deploy (5 min)

### C.1 The Claude Code prompt

```
Scaffold a Cloudflare Worker project at /Users/maddox/dev/intel-force-os
for a Teams bot, using TypeScript. Include:

1. wrangler.toml with:
   - Worker name: intel-force-os-bot
   - Custom domain: bot.intelforce.ai
   - KV namespace: TENANT_CONFIG
   - D1 database: intel-force-audit
   - Node.js compat flag
   - Cron trigger for weekly reports (Monday 09:00 UTC)

2. package.json with these dependencies:
   - botbuilder (Bot Framework SDK)
   - adaptivecards-templating
   - itty-router
   - jose (for JWT verification)

3. src/ directory structure from 02-component-design.md §2.1

4. Stub files for each module — just the exports and function signatures,
   not the implementation yet. We'll fill those in next.

5. Minimal src/index.ts that exports a fetch handler responding to
   /health with 200 OK. Just enough to verify deployment works.

6. A .gitignore excluding node_modules, .env*, .wrangler/, dist/

Then:
7. Run `npm install` to install dependencies
8. Create the KV namespace: `wrangler kv:namespace create TENANT_CONFIG`
9. Create the D1 database: `wrangler d1 create intel-force-audit`
10. Update wrangler.toml with the IDs output by those commands
11. Set secrets from .env.local:
    wrangler secret put MICROSOFT_APP_ID
    wrangler secret put MICROSOFT_APP_PASSWORD
    (prompt me to paste each value)

12. Deploy: `wrangler deploy`

13. Configure custom domain: walk me through the Cloudflare dashboard
    to add the Worker route for bot.intelforce.ai

Make sure all generated TypeScript is in strict mode with noImplicitAny.
```

### C.2 What Claude Code will do

- Create directory structure
- Write config files (wrangler.toml, package.json, tsconfig.json)
- Generate stub TypeScript files
- Run `npm install`
- Run Cloudflare resource creation commands, capture IDs, inject into wrangler.toml
- Guide you through secret entry interactively
- Deploy the minimal Worker
- Guide you through custom domain setup (Cloudflare dashboard click-through)

### C.3 Success criteria

```bash
# Verify health endpoint
curl https://bot.intelforce.ai/health
→ 200 OK

# Verify Worker is deployed
wrangler tail
→ streams logs; you should see any request to the Worker
```

---

## Stage D — Teams app manifest + package (5 min)

### D.1 The Claude Code prompt

```
In the intel-force-os project, create the teams-app/ directory with:

1. manifest.json using the template from 02-component-design.md §1.2
   Replace {GENERATED_APP_UUID} with a new UUID (Claude Code generates it).
   Replace {GENERATED_BOT_UUID} with the MICROSOFT_APP_ID from .env.local.

2. color.png and outline.png — placeholder icons. For now, just generate
   simple emerald-green squares with "IF" text. Use a Node.js script
   that runs `sharp` or ImageMagick to create them. These will be replaced
   with Jack's final designs later.

3. A build script at package.json scripts.package:
   "package": "cd teams-app && zip -r ../dist/intel-force-os-v1.0.0.zip ."

4. Run the package script and produce dist/intel-force-os-v1.0.0.zip

5. Tell me exactly where the zip is and what to do with it next.
```

### D.2 What Claude Code will do

- Generate a UUID for the app ID
- Write manifest.json with correct replacements
- Create placeholder PNG icons programmatically (NOT via AI image generation — just literal coloured squares with text, deterministic)
- Run the package script
- Verify the zip contains exactly `manifest.json`, `color.png`, `outline.png` at the root

### D.3 Success criteria

```bash
ls -la dist/intel-force-os-v1.0.0.zip
→ ~10KB file

unzip -l dist/intel-force-os-v1.0.0.zip
→ shows: manifest.json, color.png, outline.png (at root, not in a subfolder)
```

---

## Stage E — Sideload and smoke test (5 min)

### E.1 What you do manually

Claude Code can't click through Teams UI for you. Steps:

1. **Open Microsoft Teams** (desktop client or `teams.microsoft.com`)
2. **Ensure you're in your M365 Developer tenant**, not a personal/work tenant
3. Click **Apps** in the left sidebar
4. Click **Manage your apps** at the bottom
5. Click **Upload a custom app**
6. Select `dist/intel-force-os-v1.0.0.zip`
7. Teams processes for ~10 seconds, then shows "Intel Force OS" install page
8. Click **Add** → installs into personal scope (1:1 chat with bot)

### E.2 The smoke test

In the 1:1 chat that opens with Intel Force OS bot:

1. Type: `hello`
2. Within 3 seconds, bot should respond with something — even if just "I'm alive, but not configured for this tenant" (if tenant provisioning hasn't been done)

If you see that response: **everything is connected**. Worker is receiving messages from Teams via the bot registration via your Entra ID app. This is the core validation.

If nothing happens: debug. Common issues:
- Worker endpoint not receiving (check `wrangler tail` — any requests arriving?)
- JWT verification failing (check Worker logs)
- Bot Framework authentication mismatch (app ID mismatch between Entra ID and Worker)

### E.3 Next step

You have a connected bot. Now you can write the real handler logic, Adaptive Cards, Relevance AI integration, etc. That's the multi-day build from the architecture overview.

---

## Appendix — Common issues and fixes

### "Insufficient privileges to complete the operation" when running `az ad app create`

Your Azure dev tenant account may not have app registration permissions. Fix: assign yourself the "Application Administrator" role in Entra ID.

```bash
# Get your user object ID
az ad signed-in-user show --query id -o tsv

# Assign role (replace USER_ID)
# This actually requires higher privileges — may need to do in Entra ID portal UI
```

### "Bot service provider not registered"

```bash
az provider register --namespace Microsoft.BotService
# Wait ~2 minutes, then retry az bot create
```

### Worker deploys but `bot.intelforce.ai` returns 404

You need to add a Worker route in Cloudflare dashboard:
1. Cloudflare Dashboard → Workers & Pages → intel-force-os-bot
2. Settings → Triggers → Routes
3. Add route: `bot.intelforce.ai/*` → intel-force-os-bot

### Teams says "App couldn't be installed" during sideload

Usually manifest validation error. Check:
- Every URL in manifest is HTTPS
- `botId` is a valid UUID (not a placeholder)
- `validDomains` includes every domain referenced
- Icon PNGs are the correct sizes (192×192 colour, 32×32 outline)

### Bot receives messages but can't reply

Authentication mismatch. Double-check:
- Worker env has correct `MICROSOFT_APP_ID` (from `.env.local`)
- Worker env has correct `MICROSOFT_APP_PASSWORD`
- These match what's registered in Entra ID and the bot service

### Wrangler complains about "nodejs_compat" flag

Add to wrangler.toml:
```toml
compatibility_flags = ["nodejs_compat"]
```

Some Bot Framework internals need Node-compatible APIs.

---

## Cost so far

At end of this 30-minute setup:

| Resource | Cost |
|---|---|
| Azure Entra ID app | £0 |
| Azure Bot Service registration (F0) | £0 (free tier, 10k msgs/month) |
| Azure resource group | £0 |
| Cloudflare Worker (free tier) | £0 — will move to $5/mo paid when first customer ships |
| Cloudflare KV + D1 | £0 |
| intelforce.ai domain (via Cloudflare) | £9/year |

**Running cost to maintain Intel Force OS infrastructure before first customer: £0.75/month.**

---

## What you have now

After 30 minutes:
- A registered, callable, secure Teams bot
- A Cloudflare Worker receiving messages at a custom domain
- A Teams app that can be sideloaded into any M365 tenant
- An Entra ID app registration that supports multi-tenant OAuth

**You do not yet have:** the actual agent logic, Adaptive Cards, Relevance AI integration, tenant provisioning, or weekly reports. Those are the 3-4 day build that comes next, detailed in `02-component-design.md` and `07-claude-code-prompts.md`.

The setup from this document is the scaffold. Everything else is code generation via Claude Code.

---

Continue to `04-deployment-guide.md` for the per-customer onboarding process once the product build is complete.
