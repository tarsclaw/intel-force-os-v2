# Cloudflare setup — Brain build queue

Step-by-step from zero. This is the longer-form companion to `SETUP-GUIDE.md` step 5.

---

## What you're setting up

Two Cloudflare resources:

1. **A pair of Queues** (`brain-build` + `brain-build-dlq`) — durable message bus for brain build jobs.
2. **A Worker** (`intelforce-brain-queue-consumer`) — drains the queue and POSTs to brain-builder-server.

Why this layer instead of calling brain-builder directly: when brain-builder is restarting, deploying, or temporarily down, the queue holds messages and retries automatically. Without it, the wizard's brain-build trigger is fire-and-forget — works, but loses any builds that hit a transient brain-builder failure.

**Skip this whole guide if** you're fine with that fire-and-forget behaviour for v1. Set `BRAIN_BUILDER_URL` instead of `CF_BRAIN_QUEUE_URL` in the dashboard env.

---

## Account setup

### 1. Sign up (free tier is enough)

- Go to https://dash.cloudflare.com/sign-up
- Verify your email
- The free Workers Paid plan is **not** required for Queues — the Free tier includes 1M Queue messages/month, plenty for our load.

### 2. Install wrangler

Wrangler is Cloudflare's CLI. We use it to create queues and deploy the worker.

```bash
brew install cloudflare-wrangler2
# verify
wrangler --version
```

### 3. Authenticate

```bash
wrangler login
```

Opens a browser tab. Click **Allow**. Wrangler stores a long-lived token at `~/.wrangler/config/`. You only do this once per machine.

---

## Create the queues

```bash
wrangler queues create brain-build
wrangler queues create brain-build-dlq
```

Each creation is instant. You can verify in the dashboard at https://dash.cloudflare.com/?to=/:account/workers/queues.

**Why two queues?** The DLQ (dead-letter queue) catches messages that exceed `max_retries` (we set 3 in `wrangler.toml`). Inspect failed jobs there:

```bash
wrangler queues consumer messages brain-build-dlq
```

---

## Generate the shared auth token

The queue consumer needs to authenticate with brain-builder-server. Generate a strong random token once, use it in three places.

```bash
openssl rand -hex 32 > /tmp/brain-token
cat /tmp/brain-token
# example output: 7e6f5...3c2b
```

This token will be used by:
- The queue consumer (Worker secret)
- brain-builder-server (env var)
- The dashboard (env var that signs requests to the queue)

Keep `/tmp/brain-token` until you've pasted the value into all three places.

---

## Deploy the queue consumer

```bash
cd services/cf-brain-queue-consumer
```

### Set the secret

```bash
cat /tmp/brain-token | wrangler secret put BRAIN_BUILDER_TOKEN
```

### Update `wrangler.toml`

Open `services/cf-brain-queue-consumer/wrangler.toml` — change `BRAIN_BUILDER_URL` to your brain-builder-server's Fly URL (you'll have it after step 6 of `SETUP-GUIDE.md`). For now, leave the placeholder and update later.

### Deploy

```bash
wrangler deploy
```

Output looks like:

```
Total Upload: ~6 KiB / gzip: ~2 KiB
Uploaded intelforce-brain-queue-consumer (1.2 sec)
Published intelforce-brain-queue-consumer (0.3 sec)
  https://intelforce-brain-queue-consumer.<your-subdomain>.workers.dev
```

**Save that URL.** Paste into `apps/dashboard/.env.local` as `CF_BRAIN_QUEUE_URL`.

---

## Verify

```bash
# health probe (requires auth)
curl -X POST https://intelforce-brain-queue-consumer.<your-subdomain>.workers.dev \
  -H "Authorization: Bearer $(cat /tmp/brain-token)" \
  -H "Content-Type: application/json" \
  -d '{"type":"brain.build","payload":{"tenantSlug":"test","sourceDir":"/tmp"}}'

# expected: HTTP 202 with body { "status": "queued", "tenantSlug": "test" }
```

If you get a 401, the secret didn't take — re-run `wrangler secret put BRAIN_BUILDER_TOKEN`.

If you get a 502, the Worker hasn't deployed — check `wrangler tail intelforce-brain-queue-consumer`.

---

## Monitor

```bash
# Live tail of the consumer's logs
wrangler tail intelforce-brain-queue-consumer

# Inspect failed messages
wrangler queues consumer messages brain-build-dlq
```

When you submit the wizard for a tenant, the consumer's tail should show:

```
[cf-brain-queue] tenant=acme-dental forwarded to brain-builder
```

If you see retries followed by DLQ landings, brain-builder-server is not reachable at `BRAIN_BUILDER_URL` — check that Fly deploy is healthy.

---

## Cost

For our use case (1 brain build per new customer + occasional rebuild on doc upload), Cloudflare Queues free tier (1M messages/month) is permanent free. You'd need to onboard ~20,000 customers/month before billing kicks in.

---

## Rollback

If something goes wrong, drop the consumer + queues:

```bash
wrangler delete intelforce-brain-queue-consumer
wrangler queues delete brain-build
wrangler queues delete brain-build-dlq
```

The dashboard transparently falls back to direct `BRAIN_BUILDER_URL` when `CF_BRAIN_QUEUE_URL` isn't set.
