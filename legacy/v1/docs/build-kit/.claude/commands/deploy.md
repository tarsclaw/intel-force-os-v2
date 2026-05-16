---
description: Deploy the Intel Force OS Worker to production. Runs pre-checks (typecheck, tests), deploys via wrangler, verifies health endpoint, tails logs briefly. Use when you're ready to push a change to production.
---

# Deploy

Deploy the Intel Force OS Worker to production safely.

## Execute this sequence

### 1. Pre-flight checks

Run these in order. If ANY fails, STOP and report to the user. Do not proceed to deploy.

```bash
# Must be on main branch (or ask user for confirmation if on a feature branch)
git status
git branch --show-current

# No uncommitted changes
git diff --exit-code

# Tests pass
npm run typecheck
npm test

# Correct wrangler project loaded
wrangler deployments list | head -5
```

Report to the user:
- Current branch
- Last deployment (version ID and time)
- Pre-flight: PASS/FAIL for each check

If the user has uncommitted changes, ask: "You have uncommitted changes. Commit first, or deploy anyway?" — don't auto-commit.

### 2. Show the diff being deployed

```bash
# Show what changed since last deploy
git log --oneline $(wrangler deployments list --json | jq -r '.[0].tag')..HEAD
```

Summarise the changes being deployed in 2-4 bullets. Get the user's go-ahead before deploying.

### 3. Deploy

```bash
wrangler deploy
```

Capture the new deployment ID and URL from output.

### 4. Post-deploy verification

```bash
# Health check
curl -f https://bot.intelforce.ai/health
# Should return 200 OK

# Brief log tail (30 seconds)
timeout 30 wrangler tail --format pretty
```

Report:
- New deployment version ID
- Health check: PASS/FAIL
- Any errors seen in tail

### 5. If anything looks wrong

Offer immediate rollback:

```bash
# List recent deployments
wrangler deployments list

# Rollback if needed
wrangler rollback --version-id=<previous-version-id>
```

Don't rollback automatically — ask the user first. But make it a one-command operation.

### 6. Notify

If the deploy was successful, remind the user:
- The deployment affects all customer tenants
- If this was a breaking change, customers may need manifest updates (check `validDomains`, bot ID, permissions)
- Weekly report cron will use the new code from Monday

## Common failures

### "wrangler not authenticated"
Run `wrangler login` and retry.

### "Typecheck fails"
Don't skip. Fix the types. If the failure is genuinely a type-system gap (not a real bug), ask the user before using `// @ts-expect-error`.

### "Tests fail"
Don't skip. Run the failing test in isolation (`npm test -- --grep "..."`), diagnose, fix. Deploying broken code is the leading cause of Friday 6pm disasters.

### "Deploy succeeds but health check fails"
The Worker deployed but isn't responding. Check:
- `wrangler tail` for startup errors
- Cloudflare dashboard → Worker → Logs
- Custom domain routing (bot.intelforce.ai/* should point to the Worker)
- Did secrets get lost? `wrangler secret list`

### "Deploy succeeds but production behaviour is wrong"
Don't hesitate — rollback first, investigate second. Ask the user to approve the rollback.
