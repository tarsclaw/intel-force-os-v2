---
description: Stream Worker logs live with helpful filtering and parsing. Use when debugging an issue in production, watching a specific tenant, or verifying a deploy worked.
---

# Tail Logs

Stream live logs from the production Worker with helpful filtering.

## Ask the user

Before starting, ask:

1. **What are you watching for?** Options:
   - General health check (all logs, parsed)
   - A specific tenant's traffic (need tenant ID)
   - A specific error (need error type or keyword)
   - Deployment verification (first 2 min after deploy)

2. **How long?** Default: 2 minutes. Offer: until interrupted.

## Execute based on answer

### General health check
```bash
wrangler tail --format pretty
```

Narrate as logs come in:
- Count incoming requests per minute
- Flag any 4xx or 5xx
- Flag any exceptions
- At the end, summarise: total requests, errors, tenants touched

### Specific tenant
```bash
wrangler tail --format json | jq 'select(.tenantId == "TENANT_ID_HERE")'
```

(If your log structure uses different field names, adjust.)

Narrate only events for that tenant. Track: messages received, cards sent, approvals clicked, errors.

### Specific error
```bash
wrangler tail --format json | jq 'select(.level == "error" or (.exceptions | length > 0))'
```

For each error, capture:
- Tenant ID (if present)
- Request path
- Error message
- Stack trace (first 3 frames)

Group similar errors. At the end: "Saw N errors across M tenants. Top patterns: ..."

### Deployment verification
```bash
timeout 120 wrangler tail --format pretty
```

Watch for:
- Startup errors (first 30s)
- 5xx responses
- Latency outliers (>5s for normal flows, >10s for card actions)

At the end: "Deployment looks healthy. Saw N requests, 0 errors." OR "Deployment has issues — saw X in the first 2 min. Recommend rollback / investigation."

## Useful patterns once logs are streaming

### Count requests per tenant
```bash
wrangler tail --format json | jq -r '.tenantId // "unknown"' | sort | uniq -c | sort -rn
```

### Show only slow requests
```bash
wrangler tail --format json | jq 'select(.duration > 3000)'
```

### Watch a specific endpoint
```bash
wrangler tail --format json | jq 'select(.url | contains("/api/card-action"))'
```

## When to stop tailing

- Issue identified: stop and propose a fix
- User says stop: stop
- 5 minutes of no relevant events: stop and report "no issues observed"
- Log volume is too high: suggest filtering more narrowly

## What to do with what you see

Don't just dump raw logs to the user. Interpret:

- **Every 5xx is important.** Investigate stack trace, propose fix.
- **Every 4xx might be important.** Check if Teams client is doing something unexpected (retry storms = auth issue).
- **High latency (>5s) matters.** Probably Relevance AI is slow; check if pattern.
- **No traffic at all is informative.** Either nobody's using it or the Worker isn't receiving (check DNS / custom domain).

Be proactive: if you see a pattern, say so. Don't wait to be asked.
