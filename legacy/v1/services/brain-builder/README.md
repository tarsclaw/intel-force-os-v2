# @intelforce/brain-builder

Builds the per-tenant knowledge graph (the "brain") from uploaded source documents.

## What it does

Given a tenant ID and a directory of source files (handbook PDFs, markdown notes, etc.),
this service:

1. Marks the tenant's `BrainGraph` row as `BUILDING`.
2. Converts non-text files to markdown via the existing `markitdown` service.
3. Runs `graphify` over the resulting corpus (entities → edges → communities).
4. Persists the resulting graph JSON to `ops.brain_graphs.graph_json`.
5. Marks status as `READY` (or `FAILED` with error detail).

## Triggering

In production, this is triggered by:

- **Wizard step 7 submission** — `apps/dashboard/components/wizard/steps/step7-review.tsx` 
  enqueues a build job after the tenant config is finalised.
- **Manual rebuild** — admin action from `/t/[slug]/brain` (Phase 5).
- **Document upload** — when a customer adds a new doc to Knowledge (Phase 5+).

The recommended queue is **Cloudflare Queues** (already in the stack) because builds
are durable, retryable, and shouldn't block the wizard submit handler.

## CLI usage (development / one-off rebuilds)

```bash
pnpm --filter @intelforce/brain-builder build:tenant -- \
  --tenant-slug acme-dental \
  --source-dir /tmp/acme-handbook
```

## Implementation status

- [x] Service scaffold (this README, package.json, src/cli.ts, src/build.ts)
- [x] BrainGraph DB write
- [ ] graphify CLI invocation (currently stubbed — needs `graphifyy` python pkg in the runtime)
- [ ] markitdown integration (HTTP call to services/markitdown)
- [ ] Cloudflare Queue trigger
- [ ] Wizard step 7 enqueue
- [ ] Cost tracking → ops.costs

The schema and the API consumers (apps/dashboard) are already wired to read from
`ops.brain_graphs`, so when this service starts producing real data the dashboard
just lights up — no UI changes needed.
