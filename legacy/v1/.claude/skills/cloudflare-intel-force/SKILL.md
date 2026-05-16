---
name: cloudflare-intel-force
description: Intel Force OS-specific Cloudflare Workers patterns. KV schema for tenant config, D1 schema for audit logs, wrangler.toml configuration, cron triggers, environments (dev/preview/production), secret management per environment, deployment patterns, common Cloudflare gotchas for Intel Force. Use this skill for anything involving wrangler commands, KV / D1 operations in our project, cron schedules, routing configuration, environments, or Cloudflare-specific debugging. Also triggers on: wrangler, KV, D1, cron trigger, Worker, env.FOO, wrangler.toml, CPU time, free tier, paid plan.
---

# Cloudflare for Intel Force OS — Domain Skill

Covers the Intel Force OS-specific patterns for using Cloudflare Workers, KV, D1, and wrangler. For general Cloudflare docs, use the Cloudflare docs MCP instead.

## Our Cloudflare stack

| Service | Usage |
|---|---|
| Cloudflare Workers | Worker at `api.intelforce.ai` handling Bot Framework endpoint |
| Cloudflare KV | Tenant config, conversation references |
| Cloudflare D1 | Audit log, message history |
| Cloudflare Pages | Landing page (intelforce.ai) and future dashboard |
| Cloudflare R2 | Customer handbook storage (Phase 1.5 feature) |

## Plan requirement — paid plan from customer 1

The Workers free tier has a 10ms CPU time limit per request. Relevance AI calls take 1-3 seconds. Response construction takes more CPU. **Free tier requests will time out.**

Paid plan is Workers Paid ($5/month), which gives:
- 30s CPU time limit (we use ~5s average)
- 10M requests/month
- Much higher KV and D1 limits
- Production-grade SLA

Onboard to the paid plan as part of Azure bootstrap, before any customer install.

## wrangler.toml structure

```toml
name = "intel-force-os-worker"
main = "src/index.ts"
compatibility_date = "2026-04-01"
compatibility_flags = ["nodejs_compat"]
workers_dev = false

# Environments
[env.production]
routes = [
  { pattern = "api.intelforce.ai/*", zone_name = "intelforce.ai" }
]

[env.preview]
routes = [
  { pattern = "api-preview.intelforce.ai/*", zone_name = "intelforce.ai" }
]

# KV namespaces
[[kv_namespaces]]
binding = "TENANT_CONFIG"
id = "..."  # production
preview_id = "..."  # dev

# D1 databases
[[d1_databases]]
binding = "AUDIT_DB"
database_name = "intel-force-audit"
database_id = "..."

# Cron triggers
[triggers]
crons = ["0 8 * * 1"]  # Monday 09:00 BST (08:00 UTC during BST, 09:00 UTC in winter — note)
```

### Cron time zones — the trap

Cloudflare crons run in UTC. The spec says "Monday 09:00 BST." During BST (Mar-Oct), that's 08:00 UTC. During GMT (Oct-Mar), that's 09:00 UTC. If you hardcode `"0 8 * * 1"`, reports will arrive at 08:00 local during GMT.

Fix: compute desired UTC at runtime and/or schedule both and filter:
```toml
crons = ["0 8 * * 1", "0 9 * * 1"]
```
Then in the cron handler, check if `new Date().getTimezoneOffset()` indicates BST or GMT and skip accordingly. Or (simpler) tolerate a 1-hour variance between seasons — customers don't actually care if the report arrives at 8am or 9am.

## KV namespace conventions

Always use prefixed keys for readability and listability:

| Key pattern | Purpose | Example |
|---|---|---|
| `tenant_config:{tenantId}` | Per-tenant config | `tenant_config:abc-123` |
| `hr_lead_conversation:{tenantId}:{aadObjectId}` | Conversation ref for HR Lead DM | `hr_lead_conversation:abc:xyz` |
| `channel_conversation:{tenantId}:{channelId}` | Conversation ref for channel posts | `channel_conversation:abc:19:...` |
| `rate_limit:{tenantId}:{windowStart}` | Rate limiting counters | `rate_limit:abc:20260423-14` |

### Reading KV in Workers

```typescript
const config = await env.TENANT_CONFIG.get(`tenant_config:${tenantId}`, 'json');
if (!config) {
  return errorResponse(404, 'tenant_not_configured');
}
```

### Writing KV

```typescript
await env.TENANT_CONFIG.put(
  `tenant_config:${tenantId}`,
  JSON.stringify(config),
  { expirationTtl: null }  // permanent unless explicitly deleted
);
```

### Listing KV (for admin ops)

```typescript
const { keys } = await env.TENANT_CONFIG.list({ prefix: 'tenant_config:' });
// Returns up to 1000 keys; use cursor for more
```

## D1 schema

Primary table: `audit_log`

```sql
CREATE TABLE audit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tenant_id TEXT NOT NULL,
  timestamp INTEGER NOT NULL,      -- unix ms
  activity_type TEXT NOT NULL,
  employee_aad_id TEXT,
  hr_lead_aad_id TEXT,
  channel_id TEXT,
  channel_name TEXT,
  original_message TEXT,           -- redacted of PII where feasible
  original_message_hash TEXT,       -- sha256 of raw message
  draft_reply TEXT,
  final_reply TEXT,                -- NULL unless approved/edited
  sensitivity_score REAL,
  sensitivity_category TEXT,
  confidence REAL,
  escalation_recommended INTEGER,   -- 0 or 1
  hr_action TEXT,                  -- 'approve' | 'edit' | 'reject' | 'handled' | NULL
  hr_action_timestamp INTEGER,
  action_metadata TEXT             -- JSON blob for extras
);

CREATE INDEX idx_audit_tenant_time ON audit_log (tenant_id, timestamp DESC);
CREATE INDEX idx_audit_sensitivity ON audit_log (tenant_id, sensitivity_score DESC);
CREATE INDEX idx_audit_category ON audit_log (tenant_id, sensitivity_category);
```

### Migrations

Store in `migrations/NNNN_description.sql`. Apply:
```bash
wrangler d1 execute intel-force-audit --file=migrations/0001_initial.sql
wrangler d1 execute intel-force-audit --file=migrations/0002_add_column.sql --env=production
```

`wrangler d1 migrations` subcommand is available but the simple file-based approach is clearer for small teams.

### Querying D1 in Workers

```typescript
// Parameterised queries ALWAYS (SQL injection prevention)
const { results } = await env.AUDIT_DB.prepare(
  "SELECT * FROM audit_log WHERE tenant_id = ?1 ORDER BY timestamp DESC LIMIT ?2"
).bind(tenantId, 50).all();
```

### D1 limits to respect

- 5GB per database (plenty for audit logs — rotate after 7 years)
- 50,000 rows per query result
- 1MB per row (our rows are ~2KB average; no risk)

## Secret management

### Per-environment secrets
```bash
# Production
wrangler secret put MICROSOFT_APP_ID --env=production
wrangler secret put MICROSOFT_APP_PASSWORD --env=production
wrangler secret put RELEVANCE_API_KEY --env=production

# Preview/staging
wrangler secret put MICROSOFT_APP_PASSWORD --env=preview
```

### Listing secrets (safely)
```bash
wrangler secret list --env=production  # lists names only, not values
```

### Never in code
- Never hardcode secrets in `wrangler.toml` (except for public bindings like KV namespace IDs)
- Never log `env` objects — they contain secrets
- Never commit `.dev.vars` (local dev env file) — add to `.gitignore`

## Deployment patterns

### Dev loop
```bash
wrangler dev  # local, hot reload, uses preview bindings
```

### Deploy to preview
```bash
wrangler deploy --env=preview
```

### Deploy to production
```bash
# With pre-flight checks (from our /deploy slash command)
npm run typecheck && npm test && wrangler deploy --env=production
```

### Rollback
Cloudflare keeps last 10 deployments:
```bash
wrangler deployments list
wrangler rollback {deployment_id}
```

Note: rollback does NOT revert KV or D1 changes. Schema migrations require separate rollback scripts.

## Observability via wrangler

### Live logs
```bash
wrangler tail --env=production
# or JSON format for filtering:
wrangler tail --env=production --format=json | jq 'select(.outcome == "exception")'
```

### Analytics
```bash
wrangler analytics duration  # Worker CPU time distribution
# Or use the Cloudflare dashboard Analytics tab
```

### Filter by tenant
```bash
wrangler tail --format=json | jq 'select(.scriptVersion and .logs[]?.message[]? | contains("tenantId:abc-123"))'
```

Structured logs make this work. Log every request with `tenantId` as a top-level field:
```typescript
console.log(JSON.stringify({
  event: 'message_received',
  tenantId,
  aadObjectId: activity.from.aadObjectId,
  timestamp: Date.now(),
}));
```

## Common Cloudflare gotchas for Intel Force

### "Workers are stateless"
Yes, but KV and D1 are state. Don't write code that assumes in-memory state persists between requests. Each request hits a fresh Worker instance.

### "Why is my fetch() failing?"
Outbound fetches from Workers need valid SSL. Relevance AI endpoint works; your dev custom endpoints might not (self-signed certs fail).

### "Why does my cron not fire?"
- Cron only runs on deployed Worker, not `wrangler dev`
- Test cron handlers locally: `wrangler dev --test-scheduled`
- Check `wrangler.toml` cron syntax — no trailing whitespace

### "Can I use Node.js APIs?"
Set `compatibility_flags = ["nodejs_compat"]` in wrangler.toml. Most Node APIs work (`crypto`, `stream`, etc.) but not all. Prefer Web APIs where possible (`crypto.subtle`, `fetch`).

### "What about file system access?"
None. Workers don't have a filesystem. Use KV, D1, or R2 for any storage need.

### "Can I use native modules?"
No. Workers runtime is JavaScript/WASM only. Pure TypeScript packages work; packages with native bindings (e.g. `bcrypt`) don't.

## Cross-references

- Bot Framework usage of these services: `bot-framework-teams` skill
- Teams HR Agent component design: `teams-hr-agent` skill  
- Phase 3 migration away from Cloudflare-only: `phase-3-platform` skill
- Cost governance for Cloudflare services: `phase-6-ops-runbooks` skill

## The Cloudflare docs MCP

Configured in `.claude/settings.json`. When in doubt about Cloudflare-specific behaviour, ask the MCP rather than guessing:

```
cloudflare-docs: "How do I bind a D1 database in wrangler.toml?"
cloudflare-observability: "Show me Worker errors from the last hour"
```

The MCP has up-to-date Cloudflare documentation; Claude training data may be stale.

## When NOT to use this skill

- For Intel Force business logic: use `teams-hr-agent`
- For Bot Framework specifics: `bot-framework-teams`
- For generic "how does Cloudflare X work" questions: use the Cloudflare docs MCP directly

## One-sentence summary

This skill covers how Intel Force OS uses Cloudflare specifically — our KV/D1 schema, wrangler configuration, and the paid-plan requirement that must be met before any customer goes live.
