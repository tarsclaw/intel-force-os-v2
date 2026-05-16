# tRPC Router Specification

**The API contract between the Next.js dashboard frontend and its backend. Every procedure the frontend calls, grouped by domain, with inputs, outputs, permissions, and errors.**

> **Audience:** engineers writing procedures or frontend components; anyone reviewing the API surface.
>
> **Status:** v1.0. Lives in `packages/trpc/src/routers/` in the monorepo.
>
> **Philosophy:** a procedure per user action. Not one giant `update` that takes every field. Small procedures are easier to secure, audit, and evolve.

---

## 1. Router structure

```
packages/trpc/src/
├── index.ts                      ← exports appRouter, types
├── context.ts                    ← per-request context (user, roles, db, secrets client)
├── trpc.ts                       ← t.router, t.procedure, middleware
├── procedures/
│   ├── public.ts                 ← unauthenticated procedures
│   ├── authenticated.ts          ← any signed-in user
│   ├── tenant.ts                 ← scoped to a tenant in input
│   ├── agency.ts                 ← scoped to an agency in input
│   └── platform.ts               ← staff-only
├── middleware/
│   ├── rateLimit.ts
│   ├── tenantScope.ts            ← sets Postgres session var
│   ├── auditLog.ts               ← logs mutations
│   └── requireRole.ts
└── routers/
    ├── tenants.ts
    ├── invocations.ts
    ├── escalations.ts
    ├── costs.ts
    ├── vault.ts
    ├── integrations.ts
    ├── secrets.ts
    ├── provisioning.ts
    ├── wizard.ts
    ├── agencies.ts
    ├── audit.ts
    └── system.ts
```

`appRouter` merges all sub-routers:

```typescript
export const appRouter = t.router({
  tenants: tenantsRouter,
  invocations: invocationsRouter,
  escalations: escalationsRouter,
  costs: costsRouter,
  vault: vaultRouter,
  integrations: integrationsRouter,
  secrets: secretsRouter,
  provisioning: provisioningRouter,
  wizard: wizardRouter,
  agencies: agenciesRouter,
  audit: auditRouter,
  system: systemRouter
});
export type AppRouter = typeof appRouter;
```

---

## 2. Context

Per-request context (`packages/trpc/src/context.ts`):

```typescript
export async function createContext({ req }: FetchCreateContextFnOptions) {
  const session = await getClerkSession(req);
  const db = getPrismaClient();

  return {
    req,
    session,               // Clerk session (null if unauthenticated)
    user: session?.user,   // User from our mirror table
    roles: session?.roles, // Array of Role enum values
    db,                    // Prisma client
    secrets: getSecretsClient(),
    logger: getLogger({ reqId: req.headers.get('x-request-id') ?? generateId() }),
    setTenantContext: (tenantId: string) => {
      // Sets app.current_tenant_id Postgres session variable
      // for RLS enforcement on subsequent queries
    }
  };
}
```

---

## 3. Procedure types

```typescript
// No auth required
export const publicProcedure = t.procedure;

// Any signed-in user
export const authenticatedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return next({ ctx: { ...ctx, user: ctx.user } });
});

// Signed-in + tenant-scoped (tenantId in input)
export const tenantProcedure = authenticatedProcedure
  .use(rateLimitMiddleware)
  .use(requireTenantAccess('tenantId'));

// Signed-in + agency-scoped (agencyId in input)
export const agencyProcedure = authenticatedProcedure
  .use(rateLimitMiddleware)
  .use(requireAgencyAccess('agencyId'));

// Platform staff only
export const platformProcedure = authenticatedProcedure
  .use(rateLimitMiddleware)
  .use(requireRole(['platform_admin', 'platform_operator', 'platform_readonly']));
```

Every mutation also runs through `auditLogMiddleware` that records the action to `ops.audit_log`.

---

## 4. Naming conventions

| Verb | Used for |
|---|---|
| `list` | Return a paginated list |
| `get` | Return a single entity by ID |
| `create` | Create a new entity |
| `update` | Update an entity |
| `delete` | Delete (or soft-delete) |
| `archive` | Soft-delete variant |
| `resolve` | Close out an open item (escalation resolved) |
| `approve` | Approve a pending item |
| `reject` | Reject a pending item |

Procedure names read as `namespace.verb` — e.g., `tenants.list`, `escalations.resolve`.

---

## 5. Routers

### 5.1 `tenants`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `tenants.list` | platform query | `{ limit, cursor, status?, plan?, search? }` | `{ tenants: Tenant[], nextCursor? }` | List all tenants; admin table |
| `tenants.get` | tenant query | `{ tenantId }` | `Tenant` | Single tenant detail |
| `tenants.getBySlug` | public query (but Clerk-scoped) | `{ slug }` | `Tenant` or 404 | Resolve tenant by URL slug |
| `tenants.create` | platform mutation | `{ clientName, clientSlug, plan, ownerEmail, ... }` | `{ tenantId }` | Seed a tenant in status=provisioning (then Provisioning System takes over) |
| `tenants.update` | tenant mutation | `{ tenantId, patch }` | `Tenant` | Update mutable fields (name, budget, etc.) |
| `tenants.suspend` | platform mutation | `{ tenantId, reason }` | `Tenant` | Suspend a tenant (webhook routing off, supervisor down) |
| `tenants.resume` | platform mutation | `{ tenantId }` | `Tenant` | Resume a suspended tenant |
| `tenants.decommission` | platform mutation + step-up | `{ tenantId, reason, confirmSlug }` | `{ workflowId }` | Trigger TenantDecommission workflow |
| `tenants.metrics` | tenant query | `{ tenantId, period }` | `{ invocationsCount, costGbp, escalationsOpen, escalationsClosedThisMonth }` | Landing page tiles |

### 5.2 `invocations`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `invocations.list` | tenant query | `{ tenantId, agent?, status?, from?, to?, limit, cursor }` | `{ invocations, nextCursor }` | Paginated list |
| `invocations.get` | tenant query | `{ tenantId, invocationId }` | `Invocation` | Full detail with outputs, costs, escalation if any |
| `invocations.getLogs` | tenant query | `{ tenantId, invocationId, limit }` | `{ logs: LogLine[] }` | Fetch Loki logs for this invocation |
| `invocations.listGlobal` | platform query | `{ limit, cursor, agent?, status?, tenantId? }` | `{ invocations, nextCursor }` | Cross-tenant for debugging |

### 5.3 `escalations`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `escalations.list` | tenant query | `{ tenantId, status?, severity?, agent?, limit, cursor }` | `{ escalations, nextCursor }` | Escalation feed |
| `escalations.get` | tenant query | `{ tenantId, escalationId }` | `Escalation` (includes the escalation note file contents) | Detail view |
| `escalations.resolve` | tenant mutation | `{ tenantId, escalationId, resolutionNote }` | `Escalation` | Mark resolved; moves file to `/outbox/escalations/resolved/` |
| `escalations.wontFix` | tenant mutation | `{ tenantId, escalationId, reason }` | `Escalation` | Mark won't-fix (no file move; status only) |
| `escalations.acknowledge` | tenant mutation | `{ tenantId, escalationId }` | `Escalation` | Mark acknowledged (stops reminders) |
| `escalations.stream` | tenant subscription (SSE) | `{ tenantId }` | yields `EscalationEvent` | Real-time feed |
| `escalations.listGlobal` | platform query | `{ status?, severity?, limit, cursor }` | `{ escalations, nextCursor }` | Ops-wide queue |

### 5.4 `costs`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `costs.currentMonth` | tenant query | `{ tenantId }` | `{ spentGbp, budgetGbp, pctUsed, estProjected }` | Budget tile |
| `costs.byDay` | tenant query | `{ tenantId, from, to }` | `{ days: [{ date, gbp }] }` | Time-series chart |
| `costs.byAgent` | tenant query | `{ tenantId, from, to }` | `{ agents: [{ agent, gbp, invocations }] }` | Agent breakdown |
| `costs.byProvider` | tenant query | `{ tenantId, from, to }` | `{ providers: [{ provider, gbp }] }` | Provider breakdown (Anthropic / Cohere / etc.) |
| `costs.setBudget` | tenant mutation + step-up if `hard_stop` | `{ tenantId, gbp, mode: 'soft_alert' \| 'hard_stop' }` | `Tenant` | Update budget |
| `costs.globalCurrent` | platform query | `{}` | `{ totalGbp, tenantCount, topSpenders }` | Platform overview |

### 5.5 `vault`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `vault.listDir` | tenant query | `{ tenantId, path }` | `{ entries: [{ name, type, size, modified }] }` | Browse folders |
| `vault.getFile` | tenant query | `{ tenantId, path }` | `{ content, frontmatter, sizeBytes, modified }` | Preview a file (read-only) |
| `vault.search` | tenant query | `{ tenantId, query, tagFilter?, topK }` | `{ results: SearchResult[] }` | Semantic search (calls `vault-search` CLI) |
| `vault.recentChanges` | tenant query | `{ tenantId, limit }` | `{ changes: VaultChange[] }` | Recent git commits |
| `vault.getDownloadUrl` | tenant mutation | `{ tenantId, path }` | `{ signedUrl, expiresAt }` | Generate a short-lived download URL |

### 5.6 `integrations`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `integrations.list` | tenant query | `{ tenantId }` | `{ integrations: Integration[] }` | Show enabled integrations |
| `integrations.get` | tenant query | `{ tenantId, integration }` | `Integration` | Single integration detail (including masked secret ref, last verified) |
| `integrations.beginOauth` | tenant mutation | `{ tenantId, integration }` | `{ oauthUrl, state }` | Initiate OAuth flow |
| `integrations.completeOauth` | tenant mutation | `{ tenantId, integration, code, state }` | `Integration` | OAuth callback handler (called from /oauth/callback) |
| `integrations.disable` | tenant mutation | `{ tenantId, integration, reason }` | `Integration` | Disable (keeps secret for audit; can be re-enabled) |
| `integrations.reauthorize` | tenant mutation | `{ tenantId, integration }` | `{ oauthUrl, state }` | Re-trigger OAuth when tokens expire and refresh fails |
| `integrations.testConnection` | tenant mutation | `{ tenantId, integration }` | `{ ok, latencyMs, lastError? }` | Ping the integration to verify |

### 5.7 `secrets`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `secrets.listRefs` | tenant query | `{ tenantId }` | `{ secrets: SecretMetadata[] }` | List refs + metadata (never values) |
| `secrets.rotate` | tenant mutation + step-up | `{ tenantId, secretRef }` | `{ rotatedAt }` | Trigger rotation of a single secret |
| `secrets.rotateAllEmergency` | platform mutation + step-up + two-person | `{ tenantId, reason }` | `{ workflowId }` | Emergency mass rotation |
| `secrets.revoke` | tenant mutation + step-up | `{ tenantId, secretRef, reason }` | `SecretMetadata` | Revoke (does not delete ciphertext immediately) |

Secret VALUES are never returned through this API. Viewing a secret's value is not a supported operation from the dashboard.

### 5.8 `provisioning`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `provisioning.getWorkflowStatus` | platform query | `{ workflowId }` | `{ step, progress, status, error? }` | Poll status of an in-flight provisioning workflow |
| `provisioning.retryActivity` | platform mutation | `{ workflowId, activityId }` | `{ ok }` | Retry a failed activity |
| `provisioning.abortWorkflow` | platform mutation + step-up | `{ workflowId, reason }` | `{ ok }` | Abort (triggers compensations) |
| `provisioning.reprovision` | platform mutation | `{ tenantId, reason }` | `{ workflowId }` | Trigger TenantReprovision |

### 5.9 `wizard`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `wizard.begin` | platform mutation | `{ wizardInput }` | `{ wizardRunId, draftId }` | Start a new wizard run; creates a draft record |
| `wizard.saveStep` | platform mutation | `{ draftId, step, data }` | `{ ok, nextStep }` | Save progress on a step; validate the step's schema |
| `wizard.validate` | platform mutation | `{ draftId }` | `{ errors: FieldError[] }` | Full-config validation |
| `wizard.submit` | platform mutation | `{ draftId }` | `{ tenantId, workflowId }` | Submit final config; kicks off TenantOnboard |
| `wizard.getDraft` | platform query | `{ draftId }` | `{ draft, step }` | Resume a saved draft |
| `wizard.listDrafts` | platform query | `{ limit }` | `{ drafts }` | All in-progress wizards |

### 5.10 `agencies`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `agencies.list` | platform query | `{}` | `{ agencies: Agency[] }` | Admin |
| `agencies.get` | agency query | `{ agencyId }` | `Agency` | Detail |
| `agencies.listSubTenants` | agency query | `{ agencyId }` | `{ tenants: Tenant[] }` | Sub-tenants |
| `agencies.aggregateMetrics` | agency query | `{ agencyId, period }` | `{ invocationsCount, costGbp, activeTenants, openEscalations }` | Portfolio tiles |
| `agencies.create` | platform mutation | `{ agencySlug, agencyName, ownerEmail }` | `Agency` | Create a new agency |
| `agencies.addSubTenant` | agency mutation | `{ agencyId, tenantConfig }` | `{ wizardRunId }` | Begin onboarding a sub-tenant |

### 5.11 `audit`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `audit.list` | tenant query | `{ tenantId, from?, to?, actor?, action?, limit, cursor }` | `{ entries, nextCursor }` | Activity + audit feed |
| `audit.listGlobal` | platform query | (same) | (same) | Platform-wide audit |
| `audit.export` | tenant mutation | `{ tenantId, from, to }` | `{ downloadUrl, expiresAt }` | Generate signed URL to JSON/CSV export |

### 5.12 `system`

| Procedure | Type | Input | Output | Purpose |
|---|---|---|---|---|
| `system.health` | public query | `{}` | `{ ok, version, uptimeSec }` | Dashboard's own health |
| `system.deployments` | platform query | `{}` | `{ deployments }` | Recent deploys across components |
| `system.mcpServers` | platform query | `{}` | `{ servers }` | Which MCPs are up/down |
| `system.alerts` | platform query | `{ status? }` | `{ alerts }` | Active Prometheus alerts |

---

## 6. Types

Types live in `packages/trpc/src/types.ts` and are derived from Prisma + Zod schemas. Examples:

```typescript
export type Tenant = {
  id: string;
  clientName: string;
  clientSlug: string;
  plan: 'starter' | 'growth' | 'scale' | 'enterprise' | 'agency_partner';
  status: 'provisioning' | 'active' | 'suspended' | 'archived';
  costBudgetGbp: Decimal;
  costBudgetMode: 'soft_alert' | 'hard_stop';
  createdAt: Date;
  activatedAt: Date | null;
  // ... etc.
};

export type Escalation = {
  id: number;
  tenantId: string;
  agent: string;
  code: EscalationCode;
  severity: 'info' | 'low' | 'medium' | 'high' | 'critical';
  status: 'open' | 'acknowledged' | 'resolved' | 'won_t_fix';
  raisedAt: Date;
  acknowledgedAt: Date | null;
  acknowledgedBy: string | null;
  resolvedAt: Date | null;
  resolutionNote: string | null;
  fileContent: string | null;     // only in .get(), not .list()
};

export type Invocation = { /* ... matches schema */ };
export type VaultEntry = { name: string; type: 'file' | 'dir'; size?: number; modified: Date };
// ... etc.
```

Frontend imports types: `import type { Tenant } from '@intelforce/trpc'` — tree-shaken at build.

---

## 7. Input validation via Zod

Every procedure's input is validated with Zod. Centralised schemas in `packages/schemas/`:

```typescript
// packages/schemas/src/tenants.ts
export const tenantCreateSchema = z.object({
  clientName: z.string().min(1).max(200),
  clientSlug: z.string().regex(/^[a-z0-9-]+$/).min(2).max(50),
  plan: z.enum(['starter', 'growth', 'scale', 'enterprise']),
  ownerEmail: z.string().email(),
  currency: z.enum(['GBP', 'EUR', 'USD']).default('GBP'),
  timezone: z.string().default('Europe/London'),
  vatTreatment: z.enum(['ex-vat', 'inc-vat', 'no-vat']).default('ex-vat'),
});

// Used in both frontend form AND backend procedure:
import { tenantCreateSchema } from '@intelforce/schemas';
```

One source of truth for validation. Frontend gets the same errors the backend would produce.

---

## 8. Error handling

tRPC's `TRPCError` codes mapped to HTTP:

| Code | HTTP | Meaning |
|---|---|---|
| `UNAUTHORIZED` | 401 | Not signed in |
| `FORBIDDEN` | 403 | Signed in but lacks permission |
| `NOT_FOUND` | 404 | Resource doesn't exist or not accessible |
| `BAD_REQUEST` | 400 | Invalid input |
| `CONFLICT` | 409 | State conflict (e.g., double-submit) |
| `PRECONDITION_FAILED` | 412 | Requires step-up auth |
| `TOO_MANY_REQUESTS` | 429 | Rate limit |
| `INTERNAL_SERVER_ERROR` | 500 | Unhandled; caught by error boundary |

Every error includes:
- `code` — machine-readable
- `message` — user-friendly (shown in UI)
- `cause` — internal error if debuggable (stripped in production)
- `correlationId` — ties to Loki logs

Frontend's error boundary shows `message` + `correlationId`; operator can search Loki by correlation ID.

---

## 9. Pagination

Cursor-based. Every list procedure:

```typescript
input: z.object({
  tenantId: z.string(),
  limit: z.number().int().min(1).max(100).default(25),
  cursor: z.string().optional(),  // base64-encoded id + sort key
  // ...filters
})

output: z.object({
  items: z.array(itemSchema),
  nextCursor: z.string().optional(), // undefined means end of list
  totalEstimate: z.number().optional(), // rough count for UI
})
```

Cursor format: base64(`{id}:{timestamp}`). Simple; sortable; stable across pagination.

---

## 10. Real-time (SSE)

Three subscription procedures:
- `escalations.stream` — new escalations for a tenant
- `invocations.streamRunning` — invocations going from running → completed (live ops)
- `provisioning.streamWorkflow` — progress updates on a provisioning workflow

Implementation: tRPC's `@trpc/server/adapters/fetch` with SSE response. Each subscription:
1. Creates a long-lived HTTP response
2. Writes events as SSE lines
3. Frontend uses tRPC's `useSubscription` hook

If the client disconnects, server notices via `AbortSignal` and cleans up.

Alternatives considered: WebSockets (overkill for broadcast-only), polling (wasteful). SSE wins for our shape.

---

## 11. Rate limiting

Covered in auth spec §12. Applied in tRPC middleware. Per-procedure overrides for expensive routes:

```typescript
export const vaultGetFileProcedure = tenantProcedure
  .use(rateLimit({ perUser: 30, windowMs: 60_000 }));
```

---

## 12. Audit middleware

Every mutation runs through `auditLogMiddleware`:

```typescript
export const auditLogMiddleware = t.middleware(async ({ ctx, next, path, input, type }) => {
  const start = performance.now();
  const result = await next();
  const durationMs = Math.round(performance.now() - start);

  if (type === 'mutation') {
    await ctx.db.auditLog.create({
      data: {
        actor: ctx.user?.email ?? 'anonymous',
        action: path,
        target: JSON.stringify(redactSensitive(input)),
        metadata: { durationMs, ok: result.ok },
        ipAddress: ctx.req.headers.get('x-forwarded-for'),
        userAgent: ctx.req.headers.get('user-agent'),
      }
    });
  }

  return result;
});
```

Every tRPC mutation is auditable. No opt-out — even if a procedure explicitly says "no audit needed," the middleware logs it anyway.

---

## 13. Versioning

No version in the tRPC URL — tRPC isn't REST; the types are the contract.

Breaking changes:
- Add new procedures freely
- Add new optional input fields freely
- Remove input fields requires a deprecation cycle (one release with `.deprecated()`, next release removes)
- Remove output fields requires same cycle
- Change semantic meaning requires a new procedure (e.g., `tenants.list_v2`)

In practice, since the dashboard ships with a pinned tRPC version, we can move faster than a public API. External API keys use REST (separate spec; Phase 5).

---

## 14. Testing

### 14.1 Procedure unit tests

```typescript
// test/tenants.test.ts
describe('tenants.list', () => {
  it('filters to accessible tenants only', async () => {
    const caller = appRouter.createCaller(mockContext({ user: tenantOwner('meadowlane') }));
    const result = await caller.tenants.list({ limit: 10 });
    expect(result.tenants).toHaveLength(1);
    expect(result.tenants[0].clientSlug).toBe('meadowlane-dental');
  });
});
```

### 14.2 E2E via Playwright

Tests hit real tRPC endpoints through the browser, not a mock. Target: every critical user flow has an E2E test (onboarding, resolving an escalation, rotating a secret).

---

## 15. Frontend usage pattern

```typescript
// In a React server component:
import { serverClient } from '@/lib/trpc/server';

export default async function Page({ params }) {
  const tenant = await serverClient.tenants.getBySlug.fetch({ slug: params.slug });
  const metrics = await serverClient.tenants.metrics.fetch({ tenantId: tenant.id, period: 'current_month' });
  return <TenantDashboard tenant={tenant} metrics={metrics} />;
}

// In a client component:
'use client';
import { api } from '@/lib/trpc/react';

export function EscalationFeed({ tenantId }) {
  const { data: escalations } = api.escalations.list.useQuery({ tenantId, limit: 20 });
  const resolve = api.escalations.resolve.useMutation({
    onSuccess: () => {
      // invalidate the list query to refetch
      api.escalations.list.invalidate({ tenantId });
    }
  });
  // ...
}
```

---

## 16. Implementation checklist (for CC13)

- [ ] `packages/trpc/` scaffolded with context, middleware, procedure types
- [ ] Zod schemas in `packages/schemas/` for all inputs
- [ ] All 12 sub-routers implemented per §5
- [ ] Audit log middleware
- [ ] Rate limit middleware
- [ ] SSE subscriptions for escalations, invocations, provisioning
- [ ] React Query client in dashboard app
- [ ] Server caller for RSC usage
- [ ] Unit tests for every procedure (permissions + happy path)
- [ ] Integration tests for multi-step flows (wizard, escalation resolution)
- [ ] Documentation at `packages/trpc/README.md` — how to add a new procedure

---

## 17. What's explicitly NOT in this router

- **External API for customers** — that's REST (documented separately in Phase 5, including OpenAPI spec)
- **Agent-to-platform calls** — agents write to filesystem + Postgres directly via their tenant DB role; they don't use tRPC
- **Webhook receiver** — its own Fastify service
- **Billing/Stripe webhooks** — received by a dedicated endpoint outside tRPC
- **File uploads** — separate multipart endpoint; tRPC is JSON-only
