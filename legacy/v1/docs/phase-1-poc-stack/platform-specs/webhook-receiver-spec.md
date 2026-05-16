# Fathom Webhook Receiver — Specification
**The internet-facing service that catches Fathom webhooks and dispatches them to the right tenant container.**

> **Audience:** the engineer implementing CC2 (Webhook Receiver).
>
> **Status:** v1.0 for Fathom only. Same architecture extends to HubSpot, DocuSign, Stripe, Calendly in v1.1+.
>
> **Language:** Node.js 20 + Fastify. Chosen for startup speed, first-class TypeScript, clean middleware model, and minimal memory footprint (<60MB baseline).

---

## 1. What this service does

1. Exposes one public HTTPS endpoint per tenant: `https://hooks.intelforce.ai/{tenant_id}/fathom`.
2. Verifies the inbound request is actually from Fathom (HMAC signature check).
3. Deduplicates (Fathom retries on 5xx — we must be idempotent).
4. Enriches the payload with tenant context.
5. Persists the payload to the tenant's intake directory.
6. Fires a trigger on the tenant's supervisor socket.
7. Responds 200 within 2 seconds so Fathom doesn't retry.

**It does NOT run any Claude Code logic.** That's the supervisor's job inside the tenant container. This receiver is a thin dispatch layer — zero LLM, zero business logic beyond routing.

---

## 2. Architecture

```
     Fathom servers
          │
          │ HTTPS POST
          ▼
┌─────────────────────────────────────┐
│  hooks.intelforce.ai (DNS)          │
│  Cloudflare (DDoS + cert + WAF)     │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  Fastify receiver (this service)    │
│  - Signature verify                 │
│  - Dedup                            │
│  - Enrich                           │
│  - Persist → /tenant/intake/fathom  │
│  - Fire supervisor socket           │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  Tenant container                   │
│  /tenant/.claude/tenant.sock        │
│  (Unix domain socket, same host)    │
└─────────────────────────────────────┘
```

Receiver and tenant containers run on the same host family (orchestrator keeps them co-located), so socket communication is local IPC — no network hop, no auth overhead, no latency.

---

## 3. Endpoints

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/{tenant_id}/fathom` | Fathom webhook target |
| `GET` | `/{tenant_id}/fathom/health` | Per-tenant health probe (returns 200 if tenant registered + supervisor reachable) |
| `GET` | `/health` | Global service health (for load balancer) |
| `GET` | `/metrics` | Prometheus metrics (internal only, IP-allowlisted) |

### 3.1 `POST /{tenant_id}/fathom` — the main path

#### Request headers (from Fathom)

| Header | Purpose |
|---|---|
| `X-Fathom-Signature` | HMAC-SHA256 of the raw body, signed with the tenant's webhook secret |
| `X-Fathom-Event` | Event type, e.g. `meeting.processed` |
| `X-Fathom-Delivery-Id` | Unique ID for this delivery attempt (used for dedup) |
| `User-Agent` | `Fathom-Webhook/1.x` |
| `Content-Type` | `application/json` |

#### Request body

Fathom's standard `meeting.processed` payload shape. We don't parse deeply here — just stash it. The tenant's context.sh extracts what it needs later.

Key fields we touch at receiver time:
- `recording_id` — dedup key
- `url` — the Fathom share URL (for logging)
- `recording_start_time` — for telemetry
- `meeting_type` — we may filter here (see §7.3)

#### Response

```json
{
  "received": true,
  "tenant_id": "tnt_01JKDY8X5RQ4P2N6",
  "delivery_id": "fth_dlv_xyz789",
  "intake_path": "/tenant/intake/fathom/fth_dlv_xyz789.json",
  "dispatched_to_supervisor": true
}
```

Status codes:
- `200 OK` — accepted and dispatched (or already-processed duplicate)
- `400 Bad Request` — body malformed or missing required fields
- `401 Unauthorized` — signature verification failed
- `404 Not Found` — tenant_id doesn't exist or is deactivated
- `422 Unprocessable Entity` — payload shape unrecognised
- `429 Too Many Requests` — rate limit hit (see §7.4)
- `503 Service Unavailable` — tenant supervisor unreachable; Fathom should retry

---

## 4. Signature verification

Every request must carry a valid HMAC-SHA256 signature computed with the tenant's per-integration webhook secret.

### 4.1 Secret storage

- Per tenant, per integration, one secret. Stored in the secrets vault at `secrets://{tenant_id}/fathom/webhook_secret`.
- Provisioning System generates a 32-byte random string on first tenant setup, registers it with Fathom via their API, and stores it.
- Rotation: on demand (dashboard button) or scheduled every 90 days. During rotation, both old and new secrets valid for 60 minutes.

### 4.2 Verification procedure

```javascript
function verify(rawBody, signatureHeader, secret) {
  const expected = crypto
    .createHmac('sha256', secret)
    .update(rawBody)       // CRITICAL: raw bytes, not re-serialised JSON
    .digest('hex');
  return crypto.timingSafeEqual(
    Buffer.from(signatureHeader, 'hex'),
    Buffer.from(expected, 'hex')
  );
}
```

**Important:** the receiver must read the raw request body BEFORE Fastify's JSON parser runs. Use Fastify's `rawBody` plugin or a pre-parsing hook that captures the byte buffer. Re-serialising JSON breaks the signature because JSON key order and whitespace aren't stable.

### 4.3 Failure handling

- Signature mismatch → log the attempt at WARN level with IP, headers (minus the signature itself), and the rejection reason. Return 401.
- If the same IP fails 10 times in 60 seconds → auto-blocklist the IP for 1 hour (Cloudflare rule).
- If a tenant gets >50 failures in an hour → alert on-call (possible secret desync or compromise).

---

## 5. Deduplication

Fathom retries on any non-2xx response, and will occasionally double-deliver even on 200 (we can't control that). The receiver must be idempotent.

### 5.1 Dedup key

`{tenant_id}:{delivery_id}` — Fathom guarantees delivery_id is unique per delivery attempt.

### 5.2 Dedup store

Redis (ioredis client). Single shared Redis cluster for the receiver service.

```
SET dedup:tnt_01JKDY8X5RQ4P2N6:fth_dlv_xyz789 "processed" NX EX 604800
```

- `NX`: only set if not exists. If already exists, this was a duplicate — we skip dispatch and return 200 anyway.
- `EX 604800`: 7-day TTL. Fathom won't retry beyond that window.
- Key value encodes processing status: `processed`, `dispatched`, or an error code.

### 5.3 Behaviour on duplicate

Return 200 with `{received: true, duplicate: true}`. Do NOT write a new intake file. Do NOT fire the supervisor socket. Log at DEBUG.

---

## 6. Dispatch flow

```
1. Parse path → extract tenant_id
2. Look up tenant record (in-memory cache, TTL 60s)
   └─ Not found? → 404
   └─ Deactivated? → 404 (don't leak info about deactivated tenants)
3. Read raw body
4. Verify signature
   └─ Fail? → 401
5. Parse body as JSON
   └─ Malformed? → 400
6. Check dedup
   └─ Duplicate? → 200 (skip rest)
7. Apply filter rules from tenant.fathom_config
   └─ Filtered out? → 200 with {received: true, filtered: true}
8. Enrich payload:
   - Add metadata: { received_at, receiver_version, delivery_id, tenant_id }
   - Keep Fathom payload verbatim under payload.fathom
9. Write to tenant intake atomically:
   /tenant/intake/fathom/{delivery_id}.json.tmp → rename → {delivery_id}.json
10. Fire supervisor socket:
    connect /tenant/.claude/tenant.sock
    send { type: "trigger", agent: "proposal-builder", payload_path: "/tenant/intake/fathom/{delivery_id}.json" }
    close
11. If socket write failed:
    - Mark dedup key "socket_fail"
    - Return 503 so Fathom retries
    - Alert on-call
12. On success:
    - Update dedup key to "dispatched"
    - Return 200
```

---

## 7. Per-tenant filter rules (§7)

Not every Fathom call should trigger Proposal Builder. The `fathom.filter_meeting_types` config on the tenant governs which events dispatch.

### 7.1 Default filters

From the tenant config (populated by Configuration Wizard):
- `meeting_type` ∈ `fathom.filter_meeting_types` (default: `["discovery", "demo", "follow-up"]`)
- `recording_duration_seconds` ≥ `fathom.minimum_duration_minutes * 60`
- If `fathom.exclude_internal_meetings = true`: at least one attendee must be external

### 7.2 Evaluation order

Filters are evaluated in the receiver (not the tenant container) to avoid waking the supervisor for ignorable events:

1. Meeting type — cheapest check
2. Duration — cheap check
3. External attendee — needs to parse attendee list, slightly more expensive

If any filter fails → return 200 with `{received: true, filtered: true, reason: "meeting_type_excluded"}`. Log at INFO.

### 7.3 Rate limiting (per tenant)

Fathom can occasionally burst (e.g., a team processing many recordings at once). We protect the supervisor with a token bucket:

- Default: 10 requests per minute per tenant, burst of 20.
- Configurable per tenant in `fathom_config.rate_limit`.
- On limit hit: 429 with `Retry-After: 60`. Fathom respects this.

---

## 8. Tenant registry

How the receiver knows which tenants exist and where to reach their supervisor.

### 8.1 Source of truth

The Provisioning System writes tenant records to a shared Postgres DB:

```sql
CREATE TABLE tenants (
  id              text PRIMARY KEY,              -- tnt_01JKDY...
  status          text NOT NULL,                 -- active | suspended | archived
  supervisor_sock text NOT NULL,                 -- path to Unix socket
  webhook_secrets jsonb NOT NULL,                -- { fathom: "...", hubspot: "..." }
  fathom_config   jsonb NOT NULL,                -- filter rules
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_tenants_status ON tenants(status) WHERE status = 'active';
```

### 8.2 In-memory cache

Receiver caches tenant records in memory for 60s. On cache miss → Postgres lookup. On Postgres 5xx → fail closed (return 503, don't dispatch).

### 8.3 Hot reload

Provisioning System publishes a Postgres NOTIFY on tenant updates. Receiver listens and invalidates the relevant cache entry.

---

## 9. Logging & observability

### 9.1 Structured logs

Every request emits one structured log line:

```json
{
  "ts": "2026-04-22T15:30:42.123Z",
  "level": "info",
  "service": "webhook-receiver",
  "event": "inbound_request",
  "tenant_id": "tnt_01JKDY8X5RQ4P2N6",
  "delivery_id": "fth_dlv_xyz789",
  "recording_id": "mtg_abc123",
  "meeting_type": "discovery",
  "duration_seconds": 1820,
  "signature_valid": true,
  "duplicate": false,
  "filtered": false,
  "dispatched": true,
  "dispatch_latency_ms": 47,
  "total_latency_ms": 112
}
```

Shipped via Vector to the observability stack.

### 9.2 Metrics (Prometheus)

```
webhook_receiver_requests_total{tenant, integration, status}
webhook_receiver_duplicates_total{tenant}
webhook_receiver_signature_failures_total{tenant}
webhook_receiver_dispatch_latency_seconds{tenant}
webhook_receiver_supervisor_reachable{tenant}
```

### 9.3 Alerts

| Condition | Severity | Action |
|---|---|---|
| Signature failures >50/hr for one tenant | WARN | Slack to #intelforce-ops |
| Dispatch latency p95 > 1s for 5min | WARN | Slack to #intelforce-ops |
| Supervisor unreachable for one tenant >5min | CRIT | PagerDuty + Slack |
| Receiver service down | CRIT | PagerDuty |
| 5xx rate > 1% for 2min | CRIT | PagerDuty |

---

## 10. Deployment topology

- **Dev:** single instance, no replicas, no Cloudflare in front
- **Prod:** 2 replicas minimum (for rolling restarts), behind Cloudflare
- **Scale trigger:** >200 RPS sustained → add replica. For MVP with 10 clients, 2 replicas suffice indefinitely.

Runs on the same Kubernetes cluster as the tenant containers, in its own namespace (`intelforce-hooks`).

---

## 11. Configuration

The receiver reads its own config from environment variables:

```
RECEIVER_PORT=3001
POSTGRES_URL=postgres://...
REDIS_URL=redis://...
SECRETS_PROVIDER=aws-kms        # or local-encrypted for dev
LOG_LEVEL=info
METRICS_PORT=9090
SUPERVISOR_SOCKET_TEMPLATE=/mnt/tenants/{tenant_id}/.claude/tenant.sock
CACHE_TTL_SECONDS=60
DEFAULT_RATE_LIMIT_RPM=10
DEFAULT_RATE_LIMIT_BURST=20
```

---

## 12. Testing

### 12.1 Unit tests

- Signature verification (valid, invalid, missing header, empty body)
- Dedup logic (first call, duplicate within TTL, duplicate after TTL)
- Filter rules (meeting type, duration, external attendee)
- Rate limiter (burst, sustained, reset)

### 12.2 Integration tests

A test harness that:
1. Spins up the receiver + mock supervisor + test Redis + test Postgres
2. Sends canned Fathom payloads with valid and invalid signatures
3. Asserts: correct file dropped in intake, correct socket message sent, correct HTTP response

### 12.3 Load test

- Target: 500 req/s sustained, 100ms p95 latency
- Tool: k6
- Baseline: single receiver replica on a 2-vCPU / 2GB host

---

## 13. Implementation checklist (for CC2)

- [ ] Scaffold Fastify app with TypeScript
- [ ] Raw-body capture middleware
- [ ] HMAC verification helper with constant-time compare
- [ ] Postgres client (pg or prisma) with connection pool
- [ ] Redis client (ioredis) with dedup helper
- [ ] Unix socket client with 2s timeout and retry
- [ ] Filter rule evaluator
- [ ] Structured logger (pino)
- [ ] Prometheus metrics middleware
- [ ] Dockerfile (multi-stage, <100MB final image)
- [ ] Helm chart or Kubernetes manifest
- [ ] Cloudflare DNS + cert + WAF rules
- [ ] CI: lint, typecheck, unit tests, integration tests, build
- [ ] Runbook: how to rotate webhook secrets, how to debug a stuck tenant
- [ ] Smoke test: send a real test payload to the production receiver, verify end-to-end

---

## 14. Extensibility — other integrations

Same pattern reused for HubSpot, DocuSign, Stripe, Calendly:
- New route `/{tenant_id}/{integration}`
- New signature verifier per integration (HubSpot uses v3 signature, Stripe uses their own scheme, etc.)
- New filter rules per integration
- Same dedup, same dispatch, same observability

A PR to add a new integration should touch one file under `/src/integrations/{name}.ts` and register routes in the app bootstrap.

---

## 15. Known limitations (for v2)

- Single-region deployment only. A US-East tenant will have higher latency from Fathom's EU-West webhook origin. Solvable with regional receiver clusters later.
- Secret rotation is synchronous (requires Provisioning System to coordinate). Could be async with generation-tagged keys later.
- No webhook replay UI yet. If a tenant's supervisor was down and we returned 503, Fathom retries up to 24 hours — but for anything beyond that, we'd need to implement manual replay from intake JSON. Low priority (Fathom's retry window is generous).
