# External REST API Specification

**The programmatic interface customers can use to read and act on their Clawd data. API keys, endpoints, rate limits, errors, OpenAPI.**

> **Audience:** engineer implementing CC21 (REST API service); customers integrating programmatically; solicitor reviewing data-access terms.
>
> **Status:** v1.0. Scope: read-mostly, a few writes. Not a replacement for the dashboard — it's a complement for customers who want to script against their data.
>
> **Non-goals:**
> - Replace the dashboard (the dashboard is the primary interface)
> - Replace tRPC (tRPC is internal to our stack)
> - Support every action in the dashboard via API (we expose what's needed, add as customers ask)

---

## 1. Why a REST API exists at all

### 1.1 The use cases we're solving

1. **Reporting integration.** Customer wants to pull their monthly invocations + costs into their own reporting tool.
2. **Alerting pipelines.** Customer wants to route Clawd escalations into PagerDuty, Opsgenie, or internal Slack (beyond our own notifier).
3. **Data sync.** Customer wants to mirror invocation metadata into their data warehouse for BI.
4. **Agency-level aggregation.** Agency partners with internal tooling want to pull across sub-tenants into their own views.
5. **Custom automations.** Customers with engineering teams want to trigger actions or react to events beyond what our dashboard offers.

### 1.2 Why REST, not GraphQL or gRPC

- **REST is universally understood** — every customer-side developer handles REST without investment
- **GraphQL adds complexity** (schema evolution, N+1 concerns) for a benefit customers don't need
- **gRPC** is wrong for external APIs — adds friction for customers who'd rather use `curl`
- Our internal API is tRPC (for typesafety with our own frontend); external is REST (for customer compatibility). Different goals, different tools.

### 1.3 Why not the same tRPC server exposed publicly

- tRPC encodes assumptions about Zod, React Query, etc. — exposing it externally binds us to internal decisions
- REST lets us version independently
- External consumers benefit from OpenAPI tooling we'd have to reimplement

---

## 2. Authentication

### 2.1 API keys

Customers generate API keys via dashboard Settings → API Keys (per `phase-4-dashboard/views/settings-spec.md §8`).

- Format: `intel_live_<prefix>_<random-hash>` — `intel_live_4tgx_aB9xk...`
- Length: ~40 chars total
- Scoped to a specific tenant (or agency, for agency partners)
- Scope-limited: `read:all`, `read:costs`, `read:invocations`, `read:escalations`, `write:escalations`, `write:settings`
- Max 5 keys per tenant (contact support to raise)
- Revocable at any time (immediate effect)
- Never shown after creation (only prefix visible in UI after one-time reveal)

### 2.2 Authentication in requests

```http
GET /v1/tenants/tnt_xxx/invocations
Host: api.clawd.ai
Authorization: Bearer intel_live_4tgx_aB9xk...
```

### 2.3 Key storage (backend)

API keys are stored in `control.api_keys`:

```sql
CREATE TABLE control.api_keys (
  id              text PRIMARY KEY,              -- key_01JKD...
  tenant_id       text NOT NULL REFERENCES control.tenants(id),
  prefix          text NOT NULL,                  -- first 12 chars (visible in UI)
  key_hash        text NOT NULL,                  -- SHA-256 of full key (for lookup)
  scopes          text[] NOT NULL,                -- ['read:costs', 'write:escalations']
  created_by      text NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now(),
  last_used_at    timestamptz,
  revoked_at      timestamptz,
  revoked_by      text,
  CONSTRAINT api_keys_scopes_not_empty CHECK (cardinality(scopes) > 0)
);

CREATE INDEX idx_api_keys_hash ON control.api_keys(key_hash) WHERE revoked_at IS NULL;
CREATE INDEX idx_api_keys_tenant ON control.api_keys(tenant_id);
```

On request:
1. Extract key from `Authorization` header
2. Hash it (SHA-256)
3. Lookup in `control.api_keys` by hash + `revoked_at IS NULL`
4. Verify the requested tenant scope matches the key's tenant
5. Verify the requested scope is in the key's scopes
6. Update `last_used_at` (debounced — once per minute max per key)

### 2.4 Rate limiting

Per-key: 100 requests per minute (sliding window, Redis-backed).

Exceeded → `429 Too Many Requests` with `Retry-After` header.

Per-endpoint overrides:
- `GET /v1/tenants/{id}/vault/files/{path}` → 30/min (expensive reads)
- Everything else → 100/min

### 2.5 Permissions

API keys are tenant-scoped, not user-scoped. Actions taken via API are attributed to:
- Actor kind: `api_key`
- Actor identifier: `api_key:{id}` + resolved `created_by` user

Audit log captures the key ID and the originating user who created it.

---

## 3. Base URL and versioning

- Production base: `https://api.clawd.ai/v1`
- Staging base: `https://staging-api.clawd.ai/v1`

### 3.1 Versioning strategy

- Major version in the URL (`/v1`, `/v2`) — predictable, easy to route
- Breaking changes mean new major version; old one deprecated with 12-month sunset
- Non-breaking changes (new endpoints, new optional fields) ship in current version

### 3.2 Deprecation policy

- Deprecated endpoints return `Deprecation` header with sunset date
- Docs clearly mark deprecated endpoints
- 12-month minimum deprecation window
- Sunset date announced via email to affected tenants 90 days prior

---

## 4. Request/response format

### 4.1 Content type

- Request: `application/json` (for POST, PATCH, DELETE with body)
- Response: `application/json`

### 4.2 Success response

```json
{
  "data": { ... },
  "meta": {
    "request_id": "req_xxx",
    "timestamp": "2026-04-22T14:53:12Z"
  }
}
```

For list endpoints:

```json
{
  "data": [...],
  "meta": {
    "request_id": "req_xxx",
    "timestamp": "2026-04-22T14:53:12Z",
    "pagination": {
      "next_cursor": "eyJpZCI6...",
      "has_more": true,
      "estimated_total": 847
    }
  }
}
```

### 4.3 Error response

```json
{
  "error": {
    "code": "INVALID_SCOPE",
    "message": "This API key does not have the required scope: write:escalations",
    "details": {
      "required_scope": "write:escalations",
      "key_scopes": ["read:all"]
    }
  },
  "meta": {
    "request_id": "req_xxx",
    "timestamp": "2026-04-22T14:53:12Z"
  }
}
```

HTTP status codes:
- `200 OK` — success with body
- `201 Created` — resource created
- `204 No Content` — success, no body (e.g., DELETE)
- `400 Bad Request` — malformed request, validation error
- `401 Unauthorized` — missing or invalid API key
- `403 Forbidden` — valid key but insufficient scope
- `404 Not Found` — resource doesn't exist or not accessible
- `409 Conflict` — state conflict (e.g., already resolved)
- `429 Too Many Requests` — rate limited
- `500 Internal Server Error` — unexpected failure
- `503 Service Unavailable` — upstream dependency down

### 4.4 Error codes (enum)

| Code | HTTP | Meaning |
|---|---|---|
| `UNAUTHENTICATED` | 401 | Missing or invalid API key |
| `INVALID_SCOPE` | 403 | Key lacks required scope |
| `TENANT_NOT_ACCESSIBLE` | 403 | Key cannot access this tenant |
| `NOT_FOUND` | 404 | Resource doesn't exist |
| `VALIDATION_FAILED` | 400 | Invalid input (details in `details.errors[]`) |
| `RATE_LIMITED` | 429 | Too many requests |
| `CONFLICT` | 409 | State conflict |
| `INTERNAL_ERROR` | 500 | Unexpected server error |
| `UPSTREAM_ERROR` | 503 | Dependent service failed |
| `DEPRECATED_ENDPOINT` | 410 | Endpoint removed |

---

## 5. Endpoints (v1)

Scoped to the happy path. Full OpenAPI spec in §8.

### 5.1 Tenants

```
GET /v1/tenants
    Scope: read:all
    Returns: [Tenant] — for API keys scoped to an agency,
             this lists sub-tenants; for a single-tenant key,
             returns just that tenant.

GET /v1/tenants/{tenant_id}
    Scope: read:all
    Returns: Tenant
```

Tenant object:
```json
{
  "id": "tnt_01JKDY...",
  "client_name": "Meadow Lane Dental",
  "client_slug": "meadowlane-dental",
  "plan": "growth",
  "status": "active",
  "created_at": "2026-02-10T14:23:00Z",
  "timezone": "Europe/London",
  "currency": "GBP"
}
```

### 5.2 Invocations

```
GET /v1/tenants/{tenant_id}/invocations
    Scope: read:invocations  (or read:all)
    Query params:
      agent?:     filter by agent name
      status?:    completed | failed | escalated | running | timed_out
      from?:      ISO 8601 timestamp
      to?:        ISO 8601 timestamp
      limit?:     default 25, max 100
      cursor?:    pagination cursor
    Returns: [Invocation]

GET /v1/tenants/{tenant_id}/invocations/{invocation_id}
    Scope: read:invocations
    Returns: Invocation (with full detail including logs summary)
```

Invocation object:
```json
{
  "id": 12345,
  "tenant_id": "tnt_xxx",
  "agent": "proposal-builder",
  "agent_version": "1.0.0",
  "status": "completed",
  "trigger_kind": "webhook",
  "trigger_id": "fathom_abc123",
  "started_at": "2026-04-22T14:47:12Z",
  "completed_at": "2026-04-22T14:51:04Z",
  "duration_ms": 232000,
  "cost_gbp": 0.68,
  "outputs": [
    {
      "type": "file",
      "path": "/vault/clients/meadowlane-dental/proposals/2026-04-22-proposal.md",
      "created": true
    }
  ],
  "escalation_id": null
}
```

### 5.3 Escalations

```
GET /v1/tenants/{tenant_id}/escalations
    Scope: read:escalations  (or read:all)
    Query params:
      status?:    open | acknowledged | resolved | won_t_fix
      severity?:  info | low | medium | high | critical
      agent?:     filter by agent
      from?:      ISO 8601
      to?:        ISO 8601
      limit?:     default 25, max 100
      cursor?:    pagination cursor
    Returns: [Escalation]

GET /v1/tenants/{tenant_id}/escalations/{escalation_id}
    Scope: read:escalations
    Returns: Escalation (with full file content)

POST /v1/tenants/{tenant_id}/escalations/{escalation_id}/resolve
    Scope: write:escalations
    Body: {
      "resolution_note": "Fixed by updating ICP criteria in vault"
    }
    Returns: Escalation (status = resolved)

POST /v1/tenants/{tenant_id}/escalations/{escalation_id}/acknowledge
    Scope: write:escalations
    Body: {}
    Returns: Escalation (status = acknowledged)

POST /v1/tenants/{tenant_id}/escalations/{escalation_id}/wont-fix
    Scope: write:escalations
    Body: {
      "reason": "Acceptable for this prospect"
    }
    Returns: Escalation (status = won_t_fix)
```

Escalation object:
```json
{
  "id": 4567,
  "tenant_id": "tnt_xxx",
  "agent": "lead-hunter",
  "code": "ICP_CRITERIA_MISSING",
  "severity": "medium",
  "status": "open",
  "raised_at": "2026-04-22T14:23:12Z",
  "summary": "ICP file exists but only 2 of 5 required fields populated...",
  "details_path": "/outbox/escalations/2026-04-22-icp-criteria-missing.md",
  "invocation_id": 12300,
  "correlation_id": "corr_xxx"
}
```

### 5.4 Costs

```
GET /v1/tenants/{tenant_id}/costs/current
    Scope: read:costs  (or read:all)
    Returns: {
      period_start: "2026-04-01",
      period_end:   "2026-04-30",
      spent_gbp:    243.12,
      budget_gbp:   550.00,
      pct_used:     44,
      projected_gbp: 510.00
    }

GET /v1/tenants/{tenant_id}/costs/by-day
    Scope: read:costs
    Query params:
      from: ISO date (required)
      to:   ISO date (required)
    Returns: [{ date: "2026-04-22", gbp: 8.47 }, ...]

GET /v1/tenants/{tenant_id}/costs/by-agent
    Scope: read:costs
    Query params:
      from: ISO date
      to:   ISO date
    Returns: [
      { agent: "proposal-builder", gbp: 45.20, invocations: 12 },
      ...
    ]
```

### 5.5 Vault (limited)

```
GET /v1/tenants/{tenant_id}/vault/files
    Scope: read:all
    Query params:
      path?:  directory path (default: /)
    Returns: [{ name, type, size, modified }]

GET /v1/tenants/{tenant_id}/vault/files/{path+}
    Scope: read:all
    Rate limit: 30/min
    Returns: {
      content:     base64-encoded for binary, utf-8 for text
      content_type: "text/markdown" | "application/json" | ...
      size:        bytes
      modified:    ISO 8601
      frontmatter: object (if markdown with YAML frontmatter)
    }
```

Vault writes are NOT in v1. If a customer wants to push files into the vault, they contact support. This prevents accidental write loops that could clobber agent output.

### 5.6 Settings (limited)

```
PATCH /v1/tenants/{tenant_id}/settings
    Scope: write:settings
    Body: {
      cost_budget_gbp?:      number
      cost_budget_mode?:     "soft_alert" | "hard_stop"
      // limited fields; most settings require dashboard
    }
    Returns: Tenant (updated)

POST /v1/tenants/{tenant_id}/integrations/{integration}/disable
    Scope: write:settings
    Body: {
      reason: string
    }
    Returns: Integration (status = disabled)

POST /v1/tenants/{tenant_id}/integrations/{integration}/test
    Scope: read:all
    Returns: { ok: bool, latency_ms: number, last_error?: string }
```

Settings via API is intentionally narrow. Not all changes are exposed — destructive ones require dashboard with step-up MFA.

### 5.7 Webhooks (our outbound to the customer)

This is the inverse — where WE send events to the customer's endpoint.

```
# Customers register a webhook via dashboard:
POST /v1/tenants/{tenant_id}/outbound-webhooks
    Scope: write:settings
    Body: {
      url:          "https://customer.example.com/clawd-events"
      events:       ["escalation.raised", "invocation.completed"]
      secret:       "customer-provided-string-for-hmac"
    }
    Returns: OutboundWebhook

GET /v1/tenants/{tenant_id}/outbound-webhooks
    Scope: read:all
    Returns: [OutboundWebhook]

DELETE /v1/tenants/{tenant_id}/outbound-webhooks/{webhook_id}
    Scope: write:settings
    Returns: 204
```

When an event fires, we POST to the customer's URL:

```http
POST https://customer.example.com/clawd-events
Content-Type: application/json
X-Clawd-Event: escalation.raised
X-Clawd-Signature: sha256=<hmac>
X-Clawd-Delivery: evt_xxx

{
  "event": "escalation.raised",
  "tenant_id": "tnt_xxx",
  "timestamp": "2026-04-22T14:23:12Z",
  "data": {
    "escalation_id": 4567,
    "severity": "medium",
    ...
  }
}
```

Customer's endpoint verifies HMAC signature using the shared secret.

Retry policy: 3 attempts with exponential backoff (30s, 5m, 30m). After that, webhook delivery is marked failed; visible in their dashboard; customer can manually retry.

---

## 6. Pagination

Cursor-based. Every list endpoint:

- Request: `?limit=25&cursor=eyJpZCI6...`
- Response: `meta.pagination.next_cursor` — if present, more data available
- Response: `meta.pagination.has_more` — boolean for clarity
- Response: `meta.pagination.estimated_total` — rough count (may be absent)

Cursor format: base64-encoded JSON `{id, ts}`. Customers treat it as opaque.

No offset pagination. Offset gets wrong with concurrent mutations; cursor is stable.

---

## 7. Webhooks (inbound — we received from Stripe, integrations)

Not the subject of this spec. Covered in other specs:
- Stripe webhooks → `billing/stripe-integration-spec.md`
- Integration webhooks → `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md`

---

## 8. OpenAPI

Machine-readable spec at `https://api.clawd.ai/v1/openapi.json`.

Generated from the same source as the API implementation (single source of truth). Used for:
- Customers generating client SDKs (via openapi-generator, fern, etc.)
- Our own docs site (human-readable reference)
- Request validation in our handler (runtime enforcement)

### 8.1 Generated SDKs

We don't ship official SDKs in v1. Customers can generate their own from the OpenAPI spec. If a specific language becomes popular (e.g., most customers on Python), we ship an official SDK in that language — v1.1.

---

## 9. Implementation

### 9.1 Where the API lives

Separate Fastify service in the monorepo: `apps/rest-api/`.

Why not in the dashboard Next.js app:
- Different scaling characteristics (background scripts will hammer it)
- Different auth (API keys, not Clerk sessions)
- Different error handling (machine clients vs humans)
- Easier to version independently

### 9.2 Shared code

- Database access via Prisma (shared `packages/db/`)
- Secrets via shared `packages/secrets-client/`
- Schemas via shared `packages/schemas/` (same Zod schemas as tRPC where applicable)

Most endpoints are thin wrappers over the same business logic tRPC uses. The goal is: tRPC and REST expose the same data with different auth and serialisation.

### 9.3 Deployment

- Deployed alongside dashboard on Hetzner UK
- Behind Cloudflare (separate subdomain `api.clawd.ai`)
- Scaled to 2 instances for HA
- Health check at `/health` (consumed by LB)

### 9.4 Observability

- Access logs per request
- Prometheus metrics: `rest_api_requests_total{endpoint, status}`, `rest_api_duration_seconds{endpoint}`
- Per-key request counts (for customer-visible rate limit monitoring)
- Alerts: error rate > 1%, p95 > 500ms

---

## 10. Examples (in docs)

Every endpoint in the docs has `curl`, Python, and Node examples:

```bash
curl https://api.clawd.ai/v1/tenants/tnt_xxx/escalations \
  -H "Authorization: Bearer intel_live_4tgx_aB9xk..."
```

```python
import requests

response = requests.get(
    "https://api.clawd.ai/v1/tenants/tnt_xxx/escalations",
    headers={"Authorization": f"Bearer {API_KEY}"}
)
response.raise_for_status()
for escalation in response.json()["data"]:
    print(escalation["summary"])
```

```javascript
const response = await fetch(
  'https://api.clawd.ai/v1/tenants/tnt_xxx/escalations',
  { headers: { 'Authorization': `Bearer ${API_KEY}` } }
);
const { data } = await response.json();
```

---

## 11. Security

### 11.1 Standard hardening

- HTTPS only; HSTS preload
- CORS disabled (API is not browser-accessible; customers call from servers)
- Request size limit: 1 MB
- Explicit allow-list of endpoints (no wildcard routing)
- Input validation on every endpoint via Zod

### 11.2 Log redaction

- API key never logged (only the key prefix)
- Request bodies sanitised for potential PII before logging
- Errors show `correlation_id`; full details only in server logs

### 11.3 Abuse handling

- Rate limiting (§2.4) is first line
- Suspected abuse patterns (large sweeps, attempted enumeration) trigger alert
- Manual key revocation available; automated on confirmed abuse

---

## 12. Customer-facing docs

Docs live at `docs.clawd.ai/api`. Built from OpenAPI spec using a tool like Mintlify, Redocly, or Stoplight.

Sections:
- Getting started (API key, first request)
- Authentication
- Errors
- Rate limits
- Pagination
- Endpoint reference (auto-generated from OpenAPI)
- Webhooks
- SDK usage (when we have SDKs)
- Changelog

### 12.1 Launch docs minimum

For v1 launch, we need the "Getting started" + endpoint reference as a minimum. Changelog starts empty. SDK docs come later.

---

## 13. Testing

### 13.1 Integration tests

Every endpoint has at least:
- Happy path test (valid request, valid response)
- Auth failure test (missing key, wrong scope, revoked key)
- Rate limit test
- Validation failure test

### 13.2 Customer-run verification

Provide a `/v1/health` endpoint that returns `{ok: true}` — customers integrating can start by hitting this to verify their API key plumbing works.

---

## 14. Roll-out

### 14.1 Phased availability

- **Closed beta (launch month):** API enabled for Founding Customers only. Get feedback from real use.
- **General availability (month 2):** enabled for all paying customers.
- **Enterprise-specific endpoints (month 3+):** custom per-tenant endpoints for Enterprise if needed.

### 14.2 What we listen for

- Which endpoints are used most (focus optimisation there)
- Which rate limits are hit (adjust if consistently hit by legitimate use)
- Which endpoints are requested but don't exist (identifies v1.1 scope)

---

## 15. Implementation checklist (for CC21)

- [ ] Fastify service scaffolded at `apps/rest-api/`
- [ ] API key auth middleware + rate limiting
- [ ] All endpoints in §5 implemented
- [ ] OpenAPI spec generated + exposed at `/v1/openapi.json`
- [ ] Outbound webhook service (HMAC-signed deliveries)
- [ ] Observability (metrics, structured logs)
- [ ] Deployment (Hetzner, behind Cloudflare, subdomain `api.clawd.ai`)
- [ ] Docs site with endpoint reference
- [ ] Integration tests
- [ ] Customer-facing quickstart guide
- [ ] Founding customer rollout

---

## 16. What's explicitly NOT in v1

- **SDKs** — customers generate from OpenAPI or use `curl`
- **Write access to Vault** — reads only
- **Agent invocation trigger** via API — too dangerous; dashboard or webhook only
- **Custom agent builder via API** — dashboard only
- **Webhook replay UI** — CLI tools only for operators
- **Bulk operations** (resolve many escalations at once) — common request for v1.1
- **Streaming** (SSE for live invocations) — add in v1.1 when customers ask
- **Search endpoints** for Vault semantic search — add in v1.1

---

## 17. Open decisions

**OD-P5-26:** API keys never expire, or have optional expiry?
- **Recommendation:** No expiry by default; optional `expires_at` at creation time for customers who want it. Rotate via revoke + create new.

**OD-P5-27:** OpenAPI 3.0 or 3.1?
- **Recommendation:** 3.1 (newer, better JSON Schema support). All modern tools support it.

**OD-P5-28:** Rate limit — 100/min fair or too restrictive?
- **Recommendation:** Start at 100/min. Adjust up for enterprise customers on request. Monitor actual hit rates after launch.

**OD-P5-29:** API subdomain or path (api.clawd.ai vs clawd.ai/api)?
- **Recommendation:** Subdomain. Cleaner separation, different deployment, different caching rules.

---

## 18. Related

- `phase-4-dashboard/views/settings-spec.md §8` — API key generation UI
- `phase-4-dashboard/api/trpc-router-spec.md` — internal API (different from this)
- `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md` — inbound webhook handling (different subsystem)
- `phase-3-platform/postgres/schema-spec.md` — tables referenced
- `msa-template.md` — contractual terms for API usage

---

*Build for the first few customers who actually need this. Ship narrow; expand based on demand, not speculation.*
