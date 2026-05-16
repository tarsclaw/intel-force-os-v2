# 07 — Claude Code Prompts

**The literal prompts you paste into Claude Code at each build step. Copy, paste, let Claude Code execute, approve what it proposes, verify the output, move to the next prompt.**

This file is the "AI agent configures Azure and builds the product for me" answer, made fully concrete.

---

## How to use this file

1. Open Claude Code in your VS Code workspace (`/Users/maddox/dev/intel-force-os` — create this folder first)
2. For each prompt below: copy the **prompt block** (everything inside the triple-backtick), paste into Claude Code chat
3. Claude Code will propose commands/files — **read what it proposes**, approve or correct, execute
4. Verify the **success check** after each stage before moving on
5. If a stage fails, copy the error into Claude Code and ask it to fix — don't skip ahead

**Order matters.** Don't jump ahead. Each stage depends on the previous one.

---

## Stage A — Environment setup (5 min)

### A.1 Prompt

```
I'm starting a new project called Intel Force OS — a Microsoft Teams bot
for UK SME HR teams, hosted on Cloudflare Workers, calling a Relevance AI
agent as the intelligence backend.

Please:

1. Create the project directory at /Users/maddox/dev/intel-force-os (or
   use the current working directory if I'm already in it) with these
   subfolders: src/, teams-app/, migrations/, tests/, dist/, docs/,
   onboarding/

2. Initialise git, create .gitignore excluding node_modules, .env*,
   .wrangler/, dist/, *.log, .DS_Store

3. Check which of these CLI tools are installed: node, npm, wrangler, az.
   Report versions. If any are missing, tell me the install command for
   macOS Homebrew or npm and wait for me to confirm before installing.
   Do NOT run commands requiring sudo without my explicit approval.

4. Once all tools are present, run `wrangler login` and `az login` in
   sequence and wait for me to complete the browser auth for each.

5. At the end, output a checklist showing:
   - directory structure created
   - git initialised
   - tool versions
   - both clouds authenticated
```

### A.2 Success check

```bash
cd /Users/maddox/dev/intel-force-os
ls -la          # should show: src/ teams-app/ migrations/ etc.
node -v         # 18+
wrangler --version  # 3+
az --version    # 2+
az account show # shows your Azure account JSON
wrangler whoami # shows your Cloudflare email
```

---

## Stage B — Azure bootstrap (15 min)

### B.1 Prompt

```
Please register a new multi-tenant Teams bot for Intel Force OS. The bot
will run at https://bot.intelforce.ai.

Walk through these steps, asking me to confirm before running each
Azure command (they create real resources):

1. Check if resource group "intelforce-rg" exists in region uksouth.
   If not, create it: `az group create --name intelforce-rg --location uksouth`

2. Ensure Microsoft.BotService provider is registered:
   `az provider register --namespace Microsoft.BotService`
   Wait ~2 minutes for it to complete (poll `az provider show`).

3. Create Entra ID app (multi-tenant) named "Intel Force OS":
   `az ad app create --display-name "Intel Force OS" \
      --sign-in-audience AzureADMultipleOrgs \
      --web-redirect-uris "https://token.botframework.com/.auth/web/redirect"`
   Capture the appId from the output.

4. Create a client secret valid for 1 year:
   `az ad app credential reset --id <appId> --years 1 --display-name "Primary secret"`
   Capture the password from output.

5. Create Azure Bot Service registration (F0 free tier):
   `az bot create --resource-group intelforce-rg \
      --name intel-force-os-bot \
      --app-type MultiTenant --appid <appId> \
      --endpoint "https://bot.intelforce.ai/api/messages" --sku F0`

6. Enable Teams channel on the bot:
   `az bot msteams create --resource-group intelforce-rg --name intel-force-os-bot`

7. Write captured values to .env.local in the project root (create file):
      MICROSOFT_APP_ID=<appId>
      MICROSOFT_APP_PASSWORD=<password>
      MICROSOFT_TENANT_ID=<your tenant id from `az account show`>
      BOT_MESSAGING_ENDPOINT=https://bot.intelforce.ai/api/messages
      BOT_NAME=intel-force-os-bot

8. Verify everything by running:
   `az bot show --resource-group intelforce-rg --name intel-force-os-bot`
   Confirm the endpoint matches what we set.

If any command fails, show me the full error output and propose a fix
before retrying. Do not invent appId/password values — only use what the
Azure CLI actually returns.
```

### B.2 Success check

```bash
cat .env.local | wc -l        # should be 5 lines
az bot show --resource-group intelforce-rg --name intel-force-os-bot \
  --query "properties.endpoint" -o tsv
# → https://bot.intelforce.ai/api/messages
```

---

## Stage C — Cloudflare Worker scaffold (5 min)

### C.1 Prompt

```
Scaffold the Cloudflare Worker project in the current directory with:

1. package.json with scripts:
     dev: "wrangler dev"
     deploy: "wrangler deploy"
     package: "cd teams-app && zip -r ../dist/intel-force-os-v$npm_package_version.zip ."
     test: "vitest"
     typecheck: "tsc --noEmit"
   And dependencies:
     runtime: botbuilder, adaptivecards-templating, itty-router, jose
     dev: wrangler, typescript, @cloudflare/workers-types, vitest,
          @types/node

2. tsconfig.json with strict mode, target ES2022, module ES2022,
   moduleResolution bundler, types includes cloudflare workers and node

3. wrangler.toml with:
   - name: intel-force-os-bot
   - main: src/index.ts
   - compatibility_date: 2026-04-01
   - compatibility_flags: ["nodejs_compat"]
   - KV namespace binding TENANT_CONFIG (create namespace, capture id)
   - D1 database binding AUDIT_DB (create db 'intel-force-audit', capture id)
   - Cron trigger: "0 8 * * 1" (Monday 08:00 UTC = 09:00 BST)
   - Placeholder for custom domain bot.intelforce.ai

4. Create stub files matching the structure in
   02-component-design.md §2.1:
     src/index.ts (entry point with /health route only for now)
     src/bot/handler.ts (empty exports: handleBotMessage, handleCardAction)
     src/bot/auth.ts (empty: verifyJWT)
     src/bot/proactive.ts (empty: sendProactiveCard, sendWeeklyReport)
     src/cards/approval.ts, escalation.ts, report.ts, config.ts,
       welcome.ts, error.ts (empty build* functions)
     src/agents/relevance.ts (empty: callRelevanceAgent)
     src/storage/config.ts (empty: getTenantConfig, setTenantConfig)
     src/storage/audit.ts (empty: logMessage, logApproval,
       getAuditRecord, getWeeklyStats)
     src/utils/redact.ts, errors.ts (empty utility stubs)

5. Run `npm install`, then:
   `wrangler kv:namespace create TENANT_CONFIG` and capture the id
   `wrangler d1 create intel-force-audit` and capture the id
   Update wrangler.toml with these ids.

6. Set secrets by prompting me for each value (don't print the values):
     wrangler secret put MICROSOFT_APP_ID
     wrangler secret put MICROSOFT_APP_PASSWORD
   (Use values from .env.local — tell me what to paste.)

7. Deploy: `wrangler deploy`. Expect a URL like
   intel-force-os-bot.<subdomain>.workers.dev.

8. Verify: curl that URL + /health should return 200 OK.

9. Custom domain setup: output the exact steps I need to click in
   Cloudflare dashboard to route bot.intelforce.ai/* to this Worker.
   Don't try to do this via CLI unless you're certain the correct
   zone exists.

All TypeScript files should compile cleanly (run `npm run typecheck`
after scaffolding).
```

### C.2 Success check

```bash
curl https://intel-force-os-bot.<your-subdomain>.workers.dev/health
# → 200 OK
npm run typecheck  # no errors
wrangler deployments list  # shows one deployment
```

---

## Stage D — Bot auth and message handler (3-4 hours)

### D.1 Prompt

```
Now implement the core bot message handling in src/bot/. Reference
02-component-design.md §2 for the design and the code sketches.

1. src/bot/auth.ts:
   - Export verifyJWT(request, env) that:
     - Extracts Authorization: Bearer <token> from request
     - Fetches Microsoft's public signing keys from
       https://login.botframework.com/v1/.well-known/keys
       Cache for 24 hours in Worker memory (use Map)
     - Verifies JWT signature using jose library
     - Verifies: issuer is https://api.botframework.com,
       audience is env.MICROSOFT_APP_ID, token not expired
     - Returns { valid: boolean, tenantId?, error? }
   - Include a second verifyCardActionJWT that's the same but accepts
     invoke activity tokens (slightly different audience).

2. src/index.ts — wire up the router:
   - POST /api/messages → handleBotMessage
   - POST /api/card-action → handleCardAction
   - GET /health → 200 OK
   - Scheduled handler → sendWeeklyReport
   - Catch-all → 404

3. src/bot/handler.ts — handleBotMessage:
   Follow the pseudocode in 02-component-design.md §2.4 exactly:
   - Verify JWT
   - Parse activity
   - Extract tenantId from channelData.tenant.id
   - Load tenant config (use stub for now — returns hardcoded config
     if tenantId matches env.DEV_TENANT_ID, else null)
   - Handle conversationUpdate events: capture conversation reference,
     store in KV at hr_lead_conversation:{tenantId}:{userAadId},
     send the welcome_card from 06-adaptive-card-examples.json
   - Handle message events: for now, just echo back the text with a
     "I got your message" reply (we'll add Relevance AI in stage E)
   - Handle /help command: return static help text
   - Handle /status command: return "nothing pending" for now (stub)
   - All replies use the Bot Framework CloudAdapter pattern

4. src/bot/handler.ts — handleCardAction:
   - Verify JWT (use the card-action variant)
   - Parse activity.value to get action, auditId, conversationId
   - For now, just log what action was clicked and reply "Got it"
   - We'll wire up the full approval logic in stage F

5. Write integration tests in tests/integration/handler.test.ts that:
   - Mock a valid bot framework request
   - Verify handleBotMessage returns 200
   - Verify invalid JWT returns 401
   - Verify conversationUpdate stores conversation reference

Before writing any code, show me the file list you'll create/modify and
the rough line count for each. Wait for my approval before writing.

Use strict TypeScript throughout. No `any` types. If you need to loosen
a type, tell me why and propose the narrowest widening.
```

### D.2 Success check

```bash
npm run typecheck      # clean
npm test               # handler tests pass
wrangler deploy        # deploys successfully
wrangler tail          # in another terminal — watch logs

# In Teams (after stage I sideload), DM the bot "hello"
# → you should see the echo reply and "handled message" in wrangler tail
```

---

## Stage E — Relevance AI integration (2 hours)

### E.1 Prompt

```
Wire up the Relevance AI agent call in src/agents/relevance.ts.

My existing Relevance AI HR agent is at:
  Base URL: https://api-d7b62b.stack.tryrelevance.com/latest
  Agent ID: <ask me — I'll paste from the Relevance AI dashboard>
  Auth: Authorization: Bearer <env.RELEVANCE_API_KEY>

1. Implement callRelevanceAgent(env, config, input) per the HTTP contract
   in 02-component-design.md §4.1 and §4.2. Request body matches exactly;
   response should be validated against the expected shape.

2. Add retry logic:
   - 1 retry on 5xx or timeout
   - Exponential backoff: 500ms then 1500ms
   - On final failure, return the fallback escalation response from
     §4.4 (sensitivity 1.0, escalation_recommended true, category
     "system_unavailable")

3. Add a 25-second timeout on the fetch call. If it times out, treat
   as failure. (Cloudflare Workers paid plan caps at 30s CPU time.)

4. Add schema validation: if Relevance AI returns unexpected shape,
   log the raw response and return the escalation fallback.

5. Update src/bot/handler.ts — instead of echoing, now:
   - Call callRelevanceAgent with query + context
   - If escalation_recommended: send the draft_reply to employee as
     a holding reply, and we'll wire the escalation card in stage F
   - If not escalation: for now, just reply with the draft_reply
     directly (we'll add the approval card flow in stage F)

6. Set the Relevance AI key:
   `wrangler secret put RELEVANCE_API_KEY`
   (tell me what value to paste — I'll get it from Relevance AI)

7. Write a unit test for callRelevanceAgent that mocks fetch and:
   - Verifies retry on 503
   - Verifies timeout behaviour
   - Verifies fallback escalation response shape
   - Verifies success path returns parsed response

Show me the code before running. I want to review the request/response
mapping and the retry logic specifically.
```

### E.2 Success check

Deploy and DM the bot "what's the holiday carry-over policy?" in your dev tenant. You should get a real draft reply from Relevance AI. Check `wrangler tail` for the Relevance AI call timing — should be 1-3 seconds.

---

## Stage F — Adaptive Cards + approval flow (3-4 hours)

### F.1 Prompt

```
Implement all 6 Adaptive Cards from 06-adaptive-card-examples.json as
TypeScript modules that take typed data and return the card JSON.

1. For each card (approval, escalation, weekly_report, config, error,
   welcome):
   - Create src/cards/{name}.ts
   - Define a typed Data interface matching the _template_data_shape
   - Load the JSON template (inline the JSON as a const — don't fetch
     at runtime)
   - Use adaptivecards-templating's Template.expand(data) to fill
   - Export build{Name}Card(data: {Name}Data) returning the expanded
     card JSON

2. Update src/bot/handler.ts handleBotMessage:
   - Replace the "reply with draft directly" logic with the full flow:
     a. Log the message to audit log (call logMessage — stub for now,
        we'll implement in stage G)
     b. If escalation_recommended:
        - Reply to employee with the holding draft
        - Build escalation_card, send via proactive messaging to HR Lead
     c. Else:
        - Build approval_card, send via proactive messaging to HR Lead
        - DON'T reply to employee yet — wait for approval

3. Implement src/bot/proactive.ts sendProactiveCard(env, conversationRef, card):
   - Use CloudAdapter.continueConversationAsync
   - Send a single message activity with the card as an attachment
   - Handle errors: if conversationRef is stale (user uninstalled the
     bot), log and return silently — don't crash

4. Implement handleCardAction fully:
   - Parse action from activity.value.action: approve | edit | reject | acknowledge | request_backup | save_config | cancel_config
   - approve: look up audit record (stub), post the draft as a reply
     in the original conversation, mark audit as approved, send ack card
   - edit: get editedReply from activity.value.editedReply, post THAT
     as the reply, mark audit as edited_and_approved
   - reject: post a gentle holding message to employee, mark audit
     as rejected
   - acknowledge: mark audit as acknowledged, send ack card to HR Lead
   - request_backup: send escalation_card to config.backupHrLeadAadId
   - save_config: parse settings from activity.value, write to tenant config
   - cancel_config: just ack and dismiss the card

5. Implement postReplyInOriginalThread(env, config, auditRecord):
   - Use CloudAdapter.continueConversationAsync with original conversation
     reference stored in audit record
   - Post the reply as a thread reply to the original message

6. Test locally with wrangler dev + the Bot Framework Emulator
   (or defer to stage J for Teams-based testing).

For the approval card specifically: the Action.ShowCard with edit
Input.Text needs to include the current draft as the value, AND the
data payload must include auditId so the edit action can find the
audit record. Make sure the template substitution works for both.

Test every card by opening it in the Adaptive Card Designer at
https://adaptivecards.io/designer/ — paste the expanded JSON, verify
it renders.

Show me the expanded JSON for the approval card with sample data
before wiring up the handler.
```

### F.2 Success check

In your dev tenant: DM the bot a question → approval card appears in your HR Lead account's DM → tap Approve → reply appears in the original channel.

---

## Stage G — Storage: KV tenant config + D1 audit log (2 hours)

### G.1 Prompt

```
Implement persistent storage for tenant config and audit log.

1. Create migrations/0001_initial.sql exactly as written in
   02-component-design.md §6.1. Apply it:
     `wrangler d1 execute intel-force-audit --file=migrations/0001_initial.sql`

2. Implement src/storage/config.ts:
   - getTenantConfig(kv, tenantId): read 'tenant_config:{tenantId}'
   - setTenantConfig(kv, tenantId, config): write JSON, update updatedAt
   - getAllTenants(kv): list keys with 'tenant_config:' prefix, return
     array of tenant IDs (used by weekly report cron)
   - getHrLeadConversationRef(kv, tenantId, aadId): read
     'hr_lead_conversation:{tenantId}:{aadId}', parse as ConversationReference
   - setHrLeadConversationRef(kv, tenantId, aadId, ref): write JSON

   TenantConfig interface must match 02-component-design.md §5.2 exactly.

3. Implement src/storage/audit.ts:
   - logMessage(db, entry) per §6.2 — returns last_row_id
   - logApproval(db, auditId, newStatus, actorAadId, extras?) per §6.2
   - getAuditRecord(db, auditId) — SELECT by id, return typed row
   - getPendingApprovals(db, tenantId) — SELECT WHERE status =
     'pending_approval' for /status command
   - getWeeklyStats(db, tenantId, weekStart) per §6.3
   - deleteEmployeeData(db, tenantId, employeeAadId) per §6.4 — GDPR
   - exportEmployeeData(db, tenantId, employeeAadId) per §6.4 — DSAR

4. Update src/bot/handler.ts to call these real implementations
   instead of stubs:
   - handleBotMessage: logMessage before sending cards, store returned
     auditId in the card data for action handlers to reference
   - handleCardAction: getAuditRecord by auditId, then logApproval

5. Implement src/utils/redact.ts:
   - redactName(aadId) — return initials like "S.C." — but we actually
     don't know the name from aadId without a Graph call. For v1, just
     return the aadId truncated. Add a TODO for v1.5 to Graph-lookup names.
   - redactPII(text) — regex match UK phone, NHS number, email, redact
     with [REDACTED_PHONE] etc. Unit test this with examples.

6. Add D1 migration verification: a startup check in src/index.ts that
   runs once per Worker start — try a SELECT COUNT(*) FROM audit_log;
   if it errors, log a warning (migration not applied).

7. Write tests for all storage functions using D1 local testing
   (wrangler supports this via --local flag).

Show me the migration SQL and the TypeScript interfaces before writing
the implementations. I want to check the schema matches the design doc.
```

### G.2 Success check

```bash
wrangler d1 execute intel-force-audit --command "SELECT COUNT(*) FROM audit_log"
# → 0 (initially)

# After a DM in dev tenant:
wrangler d1 execute intel-force-audit --command "SELECT id, status, sensitivity_score FROM audit_log ORDER BY id DESC LIMIT 5"
# → shows recent entries with correct status
```

---

## Stage H — Weekly report cron (1 hour)

### H.1 Prompt

```
Implement the weekly report Monday 09:00 BST delivery.

1. src/bot/proactive.ts sendWeeklyReport(env, ctx):
   - List all tenants via getAllTenants
   - For each tenant:
     - Load config; skip if !weeklyReportEnabled or
       subscriptionStatus !== 'active'
     - Get last week's stats via getWeeklyStats (weekStart = last Monday)
     - Get top patterns via a new query in storage/audit.ts:
       - SELECT sensitivity_category, COUNT(*) FROM audit_log
         WHERE tenant_id=? AND created_at >= ? GROUP BY sensitivity_category
     - Build weekly_report_card with stats + patterns
     - Get HR Lead conversation reference
     - Send card via sendProactiveCard
     - Wrap each tenant in try/catch — one tenant failing shouldn't
       block others
     - Use ctx.waitUntil so cron doesn't time out on slow tenants

2. For the "thisWeekPriority" field in the card data:
   - If edited count > approved count, priority = "Review prompts —
     edits are outpacing approvals."
   - If escalation count > 20% of total, priority = "Lots of
     escalations this week — consider if scope has shifted."
   - Else, priority = "All steady. Quality holding at {avgConfidence}/5."
   (Simple rule-based — no AI needed for v1 priority logic.)

3. Update wrangler.toml cron:
   crons = ["0 8 * * 1"]   # 08:00 UTC = 09:00 BST Monday

4. Test the cron locally:
   `wrangler dev --test-scheduled`
   Then hit http://localhost:8787/__scheduled?cron=0+8+*+*+1
   to trigger. Verify logs show the report being built.

5. Deploy and verify cron is registered:
   `wrangler deploy`
   `wrangler cron list` (or check dashboard)
```

### H.2 Success check

In your dev tenant, set up at least one fake audit log entry from "last week" (manually INSERT via `wrangler d1 execute`), then trigger the scheduled handler. A weekly report card should arrive in your HR Lead DM.

---

## Stage I — Teams app manifest + sideload (1 hour)

### I.1 Prompt

```
Build the Teams app manifest and package it for sideloading.

1. Write teams-app/manifest.json using the template in
   02-component-design.md §1.2. Specifically:
   - Replace {GENERATED_APP_UUID} with a new UUID (generate via
     crypto.randomUUID or uuidgen)
   - Replace {GENERATED_BOT_UUID} with env.MICROSOFT_APP_ID from .env.local
   - manifestVersion "1.19", schemas URL matches
   - Scopes: personal, team, groupchat
   - commandLists include: help, status, report, config

2. Generate teams-app/color.png (192x192) and outline.png (32x32)
   as placeholder emerald squares with "IF" text. Use sharp or
   pure canvas in a Node script. These are placeholder — Jack will
   design real ones.

3. Update package.json version to 1.0.0 if not already.

4. Run `npm run package` — produces dist/intel-force-os-v1.0.0.zip.
   Verify with `unzip -l` that the zip contains:
     manifest.json (at root, not in subfolder)
     color.png
     outline.png

5. Validate manifest:
   `npx teams-manifest-validator dist/intel-force-os-v1.0.0.zip`
   (install teams-manifest-validator if needed)

6. Give me exact steps to sideload:
   - Open Teams in M365 dev tenant
   - Apps → Manage your apps → Upload a custom app
   - Select the zip
   - Click Add
   - Wait for 1:1 chat with Intel Force OS to open

7. After I sideload, I'll tell you whether it worked. If it failed,
   I'll paste the error.
```

### I.2 Success check

Sideload succeeds. 1:1 chat with Intel Force OS opens. Welcome card is shown. You can DM the bot and get a reply.

---

## Stage J — End-to-end smoke tests (1 hour)

### J.1 Prompt

```
Run the 8-scenario test matrix from 04-deployment-guide.md §6 against
our dev tenant, using Claude Code to help interpret results.

For each scenario, I'll DM the bot with the test input. Please monitor
`wrangler tail` in parallel and tell me what's happening server-side.

Scenarios:

1. Simple policy question: "What's the holiday policy?"
   Expected: approval card within 5s, correct draft, low sensitivity

2. Question not in handbook: "What's our policy on pet insurance?"
   Expected: low confidence flag OR escalation OR "I'll check and get
   back to you"-style draft

3. Sensitive question: "I've been having issues with my manager."
   Expected: holding reply sent to employee, escalation card to HR Lead

4. Approve a draft
   Expected: reply in original channel within 3s

5. Edit a draft
   Expected: edited version sent, audit log shows edited_reply field

6. Reject a draft
   Expected: holding message sent

7. Unconfigured channel: DM in a channel the bot isn't configured for
   Expected: polite "I'm only listening to X" reply

8. Invalid tenant (impersonate wrong tenantId in a test harness)
   Expected: 401 or tenant-not-found graceful error

For each scenario:
- Before I send the test, tell me what I should see in:
  (a) the employee experience
  (b) the HR Lead experience (your test DM with the bot)
  (c) the wrangler tail logs
  (d) the D1 audit log after

- After I send, check wrangler tail and confirm what happened
- If mismatched: debug together
- Record pass/fail for the scenario

At the end, give me a table of 8 scenarios with pass/fail and any
notes on issues.
```

---

## Stage K — Per-customer onboarding script (2 hours)

### K.1 Prompt

```
Build the onboarding script used during customer install calls.

1. Create onboarding/new-tenant.ts — a CLI tool using
   @inquirer/prompts that walks through the config values from
   04-deployment-guide.md §3.4:
   - Customer tenant ID (M365 tenant ID — paste from customer)
   - Customer name, domain
   - HR Lead email, Entra ID object ID (we'll look this up via Graph
     if we have the permission; else paste manually)
   - Backup HR Lead email (optional)
   - Teams channel IDs to listen to (paste from customer)
   - Company tone (free text)
   - Approval mode (all | sensitive_only | none) — default all
   - Sensitivity threshold (0-1) — default 0.5
   - Weekly report enabled (y/n) — default y
   - Relevance AI agent ID (either clone from template or paste existing)

2. On confirmation, the script:
   a. Writes tenant_config:{tenantId} to KV via wrangler kv:key put
   b. (v1.5) Clones Relevance AI HR agent via Relevance AI API — for
      v1 just accept an existing agent ID from the user
   c. Prints a summary of what was configured

3. Add a companion script onboarding/offboard-tenant.ts that:
   a. Prompts for tenantId
   b. Confirms we want to delete (scary warning)
   c. Deletes KV keys: tenant_config:*, hr_lead_conversation:*
   d. Runs DELETE FROM audit_log WHERE tenant_id = ?
   e. Prints summary of what was deleted

4. Both scripts should use the same wrangler authentication.
   Accept a --env flag: dev (use preview Worker KV/D1) vs
   prod (use production Worker KV/D1).

5. Add an onboarding/list-tenants.ts that queries KV and prints a
   table of all configured tenants with status, created date, etc.

6. Write package.json scripts:
     onboard: "tsx onboarding/new-tenant.ts --env=prod"
     offboard: "tsx onboarding/offboard-tenant.ts --env=prod"
     tenants: "tsx onboarding/list-tenants.ts --env=prod"

7. Test the onboard script against dev tenant:
   `npm run onboard`
   Verify the KV key is written, then test the bot works for that
   tenant (DM it, see an approval card).

Show me the prompts flow as a mock before writing the script. I want
to make sure the questions match my onboarding call script.
```

---

## Stage L — CI/CD + monitoring (1 hour)

### L.1 Prompt

```
Set up production-ready deployment automation.

1. Create .github/workflows/deploy.yml:
   - Trigger on push to main
   - Run npm ci, npm test, npm run typecheck
   - Deploy via `wrangler deploy` using CF_API_TOKEN secret
   - Apply D1 migrations via `wrangler d1 migrations apply`
   - Post Slack notification on success/failure

2. Create .github/workflows/preview.yml:
   - Trigger on pull request
   - Deploy to intel-force-os-bot-preview
   - Run smoke tests against the preview URL
   - Post preview URL as PR comment

3. Set up Sentry for error tracking:
   - Install @sentry/cloudflare
   - Wrap the Worker export in Sentry.withSentry
   - Add SENTRY_DSN as wrangler secret
   - Verify errors surface in Sentry dashboard

4. Set up Better Uptime or Uptime Robot to ping /health every
   60 seconds. Alert to your email + Slack if down for 2+ checks.

5. Create docs/runbook.md — a one-page operations runbook:
   - How to deploy
   - How to roll back
   - How to view logs
   - How to check individual tenant health
   - How to rotate secrets
   - Phone number for Cloudflare support
   - Link to Microsoft support form

6. Update README.md in the project root with:
   - What this is
   - Architecture diagram (reference the pack)
   - How to dev locally
   - How to deploy
   - Link to docs/runbook.md

Commit everything. Push. Verify CI passes. Verify uptime monitor
shows green.
```

---

## Appendix — Debugging prompts

When things break, use these:

### Debug a specific tenant

```
For tenant {tenantId}, please:
1. Show me the current KV config
2. Show the last 10 audit log entries
3. Tail the Worker for 30 seconds and tell me if there's any
   traffic from this tenant
4. Check Relevance AI agent {relevanceAgentId} is responding
   via curl
5. Summarise: is this tenant healthy?
```

### Fix a failed deploy

```
The last `wrangler deploy` failed with this error:
{paste error}

Please:
1. Explain what's wrong
2. Propose a fix
3. Wait for my approval before running any destructive commands
```

### Add a new agent command

```
I want to add a new slash command '/summarise' that takes the
conversation history of the last 10 messages in a channel and
produces a summary.

1. Update manifest.json commandLists
2. Add handler in src/bot/handler.ts
3. Build a new card: src/cards/summary.ts
4. Add the template to 06-adaptive-card-examples.json
5. Bump manifest version to 1.0.1
6. Repackage and guide me through pushing the update to customers
```

---

## The honest meta-point

Claude Code is excellent at executing these prompts. It will NOT:

- Make commercial decisions for you (pricing, which customer to pursue)
- Design the Adaptive Cards visually — the JSON works but beautiful, brand-consistent design needs Jack
- Debug real customer issues without your context on which customer
- Replace talking to customers about what they actually need

What Claude Code does replace:
- Manually writing Azure CLI invocations
- Looking up Bot Framework SDK methods
- Writing boilerplate TypeScript for Workers
- Generating test cases
- Producing Adaptive Card JSON
- Setting up CI/CD workflows

**The constraint is your time and attention, not Claude Code's ability.** You can realistically build this from Stage A through Stage L in 5 focused working days, assuming no major debugging detours. Plan for 10 working days including debugging, documentation, and Jack's icon work.

---

**End of Teams HR Agent Architecture Pack.**

Return to `README.md` for the top-level index, or `01-architecture-overview.md` if you want to re-examine the architecture decision before committing.
