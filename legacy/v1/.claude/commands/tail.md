---
description: Tail live Worker logs with helpful filters. Good for watching deploys, debugging live issues, or monitoring a specific tenant.
---

# /tail

Tail live Worker logs with helpful filters to avoid drowning in noise.

## Usage

```
/tail                                    # production, all tenants, readable format
/tail preview                            # preview environment
/tail production --tenant=abc-123        # one tenant only
/tail production --errors                # only errors and exceptions
/tail production --slow                  # only requests >3 seconds
/tail production --stage=F               # only activity related to current build stage
/tail --json                             # machine-readable
```

## What I do

Run `wrangler tail --env={env} --format=json` and process the stream with filters.

## Filters

### `--tenant={id}`
Only show logs where `tenantId` matches. Useful for debugging one customer's issue without noise from others.

### `--errors`
Only show log entries with `outcome: 'exception'` or `level: 'error'`. Good for incident triage.

### `--slow`
Only show requests where duration > 3000ms. Catches Relevance AI timeouts or Worker CPU issues.

### `--card-actions`
Only show card action invocations (Approve, Edit, Reject, Escalate). Useful for watching approval flow.

### `--escalations`
Only show messages routed as escalations. Useful for monitoring sensitivity classification accuracy.

### `--pretty` (default) vs `--json`
Pretty format shows one-line summary per request:
```
14:23:51 [abc-123] POST /api/messages msg=8ms relevance=1.2s render=4ms reply=45ms total=1.26s OK
```

JSON format shows full log data, useful for piping to other tools.

## Example outputs

### Normal traffic
```
14:23:51 [abc-123] POST /api/messages 1.2s OK sensitivity=0.2 action=approval_card
14:23:52 [abc-123] POST /api/card-action 0.3s OK action=approve audit=12345
14:24:10 [def-456] POST /api/messages 1.8s OK sensitivity=0.8 action=escalation_card
14:24:15 [def-456] POST /api/card-action 0.2s OK action=handled audit=12346
```

### Error investigation
```
/tail production --errors

14:23:51 [abc-123] POST /api/messages 25s TIMEOUT relevance_timeout
  → Relevance AI took >25s; request fell back to escalation
  → audit_id=12345 logged

14:24:15 [def-456] POST /api/messages 120ms ERROR jwt_verification_failed
  → Bot Framework JWT audience mismatch
  → Check MICROSOFT_APP_ID env var
```

### Single tenant investigation
```
/tail production --tenant=abc-123

14:23:51 [abc-123] POST /api/messages msg=8ms total=1.26s OK
14:24:02 [abc-123] POST /api/card-action 0.3s OK audit=12345
14:24:18 [abc-123] POST /api/messages msg=12ms total=0.98s OK
```

## Interpreting logs

### Normal latency
- Typical request: 1-2s (dominated by Relevance AI call)
- Card action: 200-500ms
- Health check: <50ms

### Red flags
- Relevance AI >5s → Relevance AI backend slow; check their status page
- Worker >10s CPU time → bug; check compute-heavy code
- Multiple JWT failures → deployed wrong app ID
- Multiple "no tenant config" errors → customer config missing; re-run onboarding
- Sudden spike in escalations → prompt drift; review recent Relevance AI changes

## When to tail

### During deploys
After `/deploy`, tail for 30s-5min to catch deploy-related errors early.

### During incidents
`/tail production --errors` is the first thing to run during SEV1/2.

### During customer onboarding
`/tail production --tenant={new-tenant-id}` while installing — watch for smoke test success.

### For learning
Sometimes useful to tail normal traffic for a minute to internalise what healthy traffic looks like. Makes abnormal traffic easier to spot later.

## Stopping a tail

Ctrl+C to exit. Tails don't cost money on Cloudflare but do consume your terminal. Don't leave a tail running and forgotten.

## Cross-references

- Logs visible here are the same as Cloudflare dashboard
- Observability MCP can also query logs via `cloudflare-observability.mcp.cloudflare.com`
- For structured analytics over time: Datadog (Phase 3) or Workers Analytics Engine (v1)

## What this command is NOT

- **Not a database query tool.** For D1 queries, use `wrangler d1 execute`.
- **Not a KV inspector.** For KV reads, use `wrangler kv:key get`.
- **Not a metrics dashboard.** For aggregates, use Workers Analytics.

## One-sentence summary

Live Worker logs with smart filters, for deploys, debugging, and incident response.
