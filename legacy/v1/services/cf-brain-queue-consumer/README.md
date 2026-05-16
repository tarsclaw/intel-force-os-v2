# @intelforce/cf-brain-queue-consumer

Cloudflare Worker that drains the `brain-build` queue and forwards each job to
`brain-builder-server`. Optional but recommended for production.

## Why this layer

- The wizard shouldn't block on a brain build (3+ minutes for graphify).
- Brain-builder may be unavailable (deploy, restart). Queue gives retry + DLQ for free.
- Multi-region fanout becomes a config change, not a code change.

When this consumer isn't deployed, the wizard falls back to calling
brain-builder-server directly — slower and less durable, but works.

## Endpoints

- `POST /` — produces a message onto the queue (used by the wizard via `CF_BRAIN_QUEUE_URL`)

## Deploy

```bash
cd services/cf-brain-queue-consumer

# 1. Create the queue
wrangler queues create brain-build
wrangler queues create brain-build-dlq

# 2. Set secrets
wrangler secret put BRAIN_BUILDER_TOKEN

# 3. Deploy
wrangler deploy
```

After deploy:
- Set `CF_BRAIN_QUEUE_URL` in dashboard env to `https://intelforce-brain-queue-consumer.<workers-subdomain>.workers.dev`
- Set `BRAIN_BUILDER_TOKEN` to the same value used by brain-builder-server

## Monitoring

```bash
wrangler tail intelforce-brain-queue-consumer
```

Failed messages land in the `brain-build-dlq` queue. Inspect with:

```bash
wrangler queues consumer messages brain-build-dlq
```
