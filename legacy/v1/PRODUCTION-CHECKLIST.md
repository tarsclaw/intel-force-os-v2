# Production Deploy Checklist

Everything between "code is written" and "first paying customer can sign up". Each item that says **You** requires a credential, hosting decision, or DNS change that I (Claude) cannot do for you. Every other item is already done in the codebase — this list points to the file or command.

**Last updated:** 2026-04-26 — corresponds to the state at the end of Phase 5 + production close-out.

---

## 1. Postgres database

You need a Postgres instance with the `pgvector` and `pgcrypto` extensions.

**Recommended:** Neon (UK region) or Supabase (EU region) for residency alignment with the DPA. Both auto-enable pgvector.

- [ ] **You**: provision a Postgres instance (≥ 14, with pgvector)
- [ ] **You**: copy the connection string into `.env.local` as `DATABASE_URL` for `apps/dashboard` and `services/brain-builder-server`
- [ ] Run migrations:
  ```bash
  pnpm --filter @intelforce/db prisma db push
  ```
  This applies both:
  - `20260426120000_brain_graph` — BrainGraph + BrainEdgeReview tables
  - `20260426130000_brain_embeddings` — BrainNodeEmbedding (pgvector) table

**Verify:**
```bash
psql $DATABASE_URL -c "\dt ops.brain_*"
# Should list: brain_graphs, brain_edge_reviews, brain_node_embeddings
```

---

## 2. External API keys

- [ ] **You**: Anthropic console → create API key → set as `ANTHROPIC_API_KEY` everywhere it's referenced (dashboard, graphify-service, optionally brain-builder-server if you want it to embed-via-Anthropic later)
- [ ] **You**: Cohere dashboard → create API key → set as `COHERE_API_KEY` in dashboard + brain-builder-server. Required for semantic search; without it, search falls back to substring (still works, just dumber).
- [ ] **You**: Clerk dashboard → create application → set `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` + `CLERK_SECRET_KEY` in dashboard

---

## 3. Hosted services (Fly.io recommended)

Three Python/Node services need hosting. All have `fly.toml` provided. Each is independent — deploy in any order.

### 3a. `services/markitdown` (PDF/DOCX → markdown)

- [ ] **You**: `cd services/markitdown && fly launch --no-deploy`
- [ ] **You**: `fly deploy`
- Verify: `curl https://intelforce-markitdown.fly.dev/health`

### 3b. `services/graphify-service` (graphify CLI HTTP wrapper)

- [ ] **You**: `cd services/graphify-service && fly launch --no-deploy`
- [ ] **You**: `fly secrets set ANTHROPIC_API_KEY=sk-ant-...`
- [ ] **You**: `fly deploy`
- Verify: `curl https://intelforce-graphify.fly.dev/health`

### 3c. `services/brain-builder-server` (the orchestrator)

- [ ] **You**: `cd services/brain-builder-server && fly launch --no-deploy`
- [ ] **You**: Set secrets:
  ```bash
  fly secrets set \
    DATABASE_URL=postgres://... \
    GRAPHIFY_SERVICE_URL=https://intelforce-graphify.fly.dev \
    COHERE_API_KEY=cohere-... \
    BRAIN_BUILDER_TOKEN=$(openssl rand -hex 32)
  ```
- [ ] **You**: `fly deploy`
- Verify: `curl https://intelforce-brain-builder.fly.dev/health`
- **Save the `BRAIN_BUILDER_TOKEN` — you'll need it for the dashboard + queue consumer envs.**

---

## 4. Cloudflare Queue (optional but recommended)

Adds durable retry + DLQ to the brain-build trigger. Without it, the wizard's HTTP call to brain-builder-server is fire-and-forget — works but no retry on transient failures.

- [ ] **You**: `cd services/cf-brain-queue-consumer`
- [ ] **You**: Create the queues:
  ```bash
  wrangler queues create brain-build
  wrangler queues create brain-build-dlq
  ```
- [ ] **You**: Set secrets:
  ```bash
  wrangler secret put BRAIN_BUILDER_TOKEN
  # paste the same token as brain-builder-server's
  ```
- [ ] **You**: Update `wrangler.toml` `BRAIN_BUILDER_URL` to your brain-builder-server's fly URL
- [ ] **You**: `wrangler deploy`
- Verify: `curl -X POST https://intelforce-brain-queue-consumer.<your-subdomain>.workers.dev/ -d '{"type":"brain.build","payload":{"tenantSlug":"test","sourceDir":"/tmp"}}' -H "Authorization: Bearer $BRAIN_BUILDER_TOKEN"`

---

## 5. Dashboard environment

- [ ] **You**: Copy `apps/dashboard/.env.example` → `.env.local`
- [ ] **You**: Fill in:
  - `DATABASE_URL` — same as step 1
  - `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` + `CLERK_SECRET_KEY` — from step 2
  - `ANTHROPIC_API_KEY` — from step 2
  - `COHERE_API_KEY` — from step 2
  - **One** of: `CF_BRAIN_QUEUE_URL` (preferred) or `BRAIN_BUILDER_URL` (fallback)
  - `BRAIN_BUILDER_TOKEN` — same value as steps 3c + 4
  - `WORKER_URL` + `PORTAL_API_KEY` — from your existing HR Worker
- [ ] Run locally: `cd apps/dashboard && pnpm dev`
- [ ] Verify: navigate to `http://localhost:3000/sign-in` → sign in → see Overview

### Dashboard hosting (when ready)

Recommended: **Vercel** (zero-config Next.js) or **Cloudflare Pages** (stays in CF).

- [ ] **You**: connect the repo, set `apps/dashboard` as the root, add all env vars
- [ ] **You**: configure custom domain `dashboard.intelforce.ai`

---

## 6. Smoke test the full loop

Once the above is done, this should work end-to-end:

1. Sign up as a new user (Clerk)
2. Complete the wizard with a test handbook PDF (use `apps/dashboard/components/wizard`)
3. Submit
4. Watch the brain build:
   ```bash
   # Watch the BrainGraph row flip PENDING → BUILDING → READY
   psql $DATABASE_URL -c "SELECT status, node_count, edge_count, generated_at FROM ops.brain_graphs;"
   ```
5. Open `/t/<slug>/brain` → Brain Map renders the tenant's actual data
6. Press ⌘K → ask "what does our handbook say about leave?" → get a streamed answer with citations
7. Open Surprises tab → reject one inferred edge → reload → it stays rejected and is filtered from future answers

---

## 7. Production-ready monitoring (recommended, not blocking)

- [ ] Cloudflare Workers tail: `wrangler tail intel-force-os-bot` (HR Worker), `wrangler tail intelforce-brain-queue-consumer`
- [ ] Fly logs: `fly logs -a intelforce-brain-builder`, `fly logs -a intelforce-graphify`, `fly logs -a intelforce-markitdown`
- [ ] DLQ check: `wrangler queues consumer messages brain-build-dlq` — these are jobs that exhausted retries
- [ ] Postgres: pgAnalyze or Neon's built-in metrics for slow queries
- [ ] **Optional**: Sentry for the dashboard (error reporting on `apps/dashboard`)
- [ ] **Optional**: Datadog or Grafana Cloud for service-level metrics

---

## 8. Things still TODO in code

### 8a. Two remaining TypeScript errors (need package installs)

The original 9 pre-existing errors are now down to **2**, both of which require
adding dependencies. Run these and the typecheck is fully clean:

```bash
# (1) @clerk/themes — used in apps/dashboard/app/layout.tsx for the dark Clerk theme
pnpm --filter @intelforce/dashboard add @clerk/themes

# (2) superjson — needed in @intelforce/trpc to match the client-side transformer
pnpm --filter @intelforce/trpc add superjson
```

After `(2)` is installed, uncomment the `transformer: superjson` block in
`packages/trpc/src/init.ts` (the change is documented inline next to the `t`
initializer).

### 8b. Phase 6 polish that doesn't block first customer

- [ ] Mobile responsive audit at 375px on every page (most are responsive via Tailwind, needs verification)
- [ ] Accessibility — extend ARIA pass beyond TenantNav to all icon buttons (in `components/brain/BrainMap.tsx`, `components/approvals/approval-card.tsx`, etc.)
- [ ] Centralised tenant access guard — apply `requireTenantAccess()` to `/api/escalations/stream` route (currently only on `/api/brain/*`)

These don't block first customer; they'd block scaling to dozens of customers.

---

## What I (Claude) cannot do — full list

To make the boundary explicit:

| Item | Why |
|---|---|
| Provision the Postgres database | Needs your Neon/Supabase account |
| Run `prisma db push` | Needs DB credentials I don't have |
| Get Anthropic / Cohere / Clerk API keys | Needs your dashboard logins |
| Run `fly launch` / `fly deploy` | Needs your fly.io account, billing, and the auth token I don't have |
| Create Cloudflare Queue | Needs your Cloudflare account API token |
| Configure the custom domain `dashboard.intelforce.ai` | Needs DNS + your domain registrar |
| Buy any of the above accounts | Costs money, decisions are yours |

Everything else — code, configs, migration SQL, deploy scripts, env templates — is in the repo and ready to go.
