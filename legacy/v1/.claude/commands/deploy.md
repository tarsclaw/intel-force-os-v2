---
description: Safely deploy the Intel Force OS Worker. Runs pre-flight checks, deploys, verifies. Never deploys without confirmation.
---

# /deploy

Deploy the Worker to an environment with safety checks. I will never deploy without your explicit go-ahead.

## Usage

```
/deploy                      # deploy to preview (default)
/deploy preview              # explicit preview
/deploy production           # production (requires extra confirmation)
```

## Pre-flight checks (always run)

1. **Git state clean?**
   - Uncommitted changes → abort; ask if we should commit first
   - On expected branch? (`main` for production; any for preview)

2. **TypeScript clean?**
   - Run `npm run typecheck`
   - Errors → abort

3. **Tests pass?**
   - Run `npm test`
   - Failures → abort

4. **Build succeeds?**
   - Run `npm run build`
   - Errors → abort

5. **Secrets present?**
   - `wrangler secret list --env={env}` must show: `MICROSOFT_APP_ID`, `MICROSOFT_APP_PASSWORD`, `RELEVANCE_API_KEY`
   - Missing → abort; list what's missing

6. **D1 migrations up to date?**
   - Compare `migrations/*.sql` against `wrangler d1 migrations list`
   - Pending migrations → abort; recommend apply first

## Production-specific extra checks

If `/deploy production`:

7. **Branch check** — must be `main`
8. **Clean working tree** — no uncommitted files
9. **Recent test run** — tests must have passed in last 10 minutes
10. **Customer impact warning** — if customers are live, show:

```
⚠ PRODUCTION DEPLOY

Active customers: {count from KV listing}
Current Worker version: {from wrangler deployments list}

Proceeding will deploy new code to all customers simultaneously.
Rollback is available via `wrangler rollback`.

Confirm deploy? (yes / no)
```

I'll wait for explicit `yes` before deploying to production. `/deploy production` without confirmation does NOT deploy.

## The deploy itself

Once pre-flight passes and you confirm:

```bash
wrangler deploy --env={env}
```

Record the deployment:
- Capture `deployment_id` from output
- Note in a local deploy log (for easy reference if rollback needed)
- Output: `Deployed {environment} — {deployment_id}`

## Post-deploy verification

After deploy:

1. **Health check** — `curl https://{env}.intelforce.ai/health` expects `200 OK`
2. **Smoke tests** — if in Teams HR Agent: trigger a test message, verify audit row appears in D1
3. **Error rate** — `wrangler tail --env={env}` for 30 seconds; if error rate >1%, auto-suggest rollback

Output:
```
Deploy verified ✓
Environment: production  
Deployment ID: abc-123-...
Health check: 200 OK
Smoke test: passed (test message traced end-to-end)
Error rate last 30s: 0%

Next steps:
  - Watch logs: /tail production
  - Monitor Sentry for next hour
```

## Rollback

If something goes wrong post-deploy:

```
/deploy rollback               # rolls back to previous deployment
/deploy rollback {id}          # rolls back to specific deployment
```

What I do:
1. Run `wrangler rollback {id}`
2. Verify rollback with health check
3. Report outcome

Note: rollback reverts Worker code but NOT KV/D1 changes. If the deploy included schema changes, those need separate rollback (usually reverse migration).

## What I won't do

- Deploy with pre-flight failures — never. Fix them first.
- Auto-deploy to production — always require explicit confirmation.
- Silently retry on failure — I'll report the failure and ask.
- Modify secrets in the deploy flow — that's a separate operation, intentionally.

## When to use

- After a change is ready
- After `/review-against-spec` passes
- After `npm test` passes locally
- Scheduled deploys (e.g. Tuesday and Thursday windows during v1)

## When NOT to use

- During an ongoing incident (stabilise first, deploy later)
- Friday afternoon (deploys late Friday means you debug over weekend if something breaks)
- Without the business reason being clear — "because I can" is not a reason

## The deploy rhythm

For v1 during active development:
- Preview deploys: as often as useful during the day
- Production deploys: 1-2x per week, Tuesday / Thursday ideally
- Emergency production: only for SEV1 fixes

When customer 1+ is live, the rhythm slows — every production deploy has customer impact.

## Cross-references

- Phase 6 `deploy-and-rollback.md` — full operational procedure
- `cloudflare-intel-force` skill — wrangler specifics
- `/tail` — watch logs post-deploy
