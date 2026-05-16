# @intelforce/brain-builder-server

HTTP wrapper around `@intelforce/brain-builder`. Triggered by the wizard.

## Endpoints

- `POST /build` — `{ tenantSlug, sourceDir, force? }` — returns 202; build runs async.
- `GET /status/:tenantSlug` — read the current `BrainGraph` row for a tenant.
- `GET /health` — liveness, reports inFlight counter and external service config.

## Required env

- `DATABASE_URL` — Postgres connection string (used by the brain-builder)
- `GRAPHIFY_SERVICE_URL` — URL of the graphify HTTP service
- `COHERE_API_KEY` — for embeddings (optional but recommended)
- `BRAIN_BUILDER_TOKEN` — bearer token; if set, all endpoints require `Authorization: Bearer <token>`
- `PORT` — default 8090
- `GRAPHIFY_USE_STUB=true` — for dev without graphify-service

## Deploy

Same hosting options as graphify-service. fly.toml is provided.

```bash
cd services/brain-builder-server
fly launch --no-deploy   # first time
fly secrets set DATABASE_URL=... GRAPHIFY_SERVICE_URL=... COHERE_API_KEY=... BRAIN_BUILDER_TOKEN=...
fly deploy
```

## Architecture

This service is intentionally simple and stateless (apart from the in-process
`inFlight` set that prevents duplicate concurrent builds per tenant). State
lives in `ops.brain_graphs` — the dashboard reads progress directly from there.

For multi-host scaling, route requests through Cloudflare Queues:
- Producer: dashboard's wizard router pushes a message
- Consumer Worker pulls from the queue and POSTs here

That layer lives in `services/cf-brain-queue-consumer/` and is optional —
when not configured, the wizard calls this service directly.
