# Fly.io setup — Three Intel Force OS services

Step-by-step deploy of `markitdown`, `graphify-service`, and `brain-builder-server` to Fly.io. Long-form companion to `SETUP-GUIDE.md` step 6.

---

## What you're deploying

| App | Purpose | Public? |
|---|---|---|
| `intelforce-markitdown` | Converts uploaded PDFs / DOCX / PPTX to markdown | No (internal only) |
| `intelforce-graphify` | Wraps the graphify CLI (Python) — builds knowledge graphs | No (internal only) |
| `intelforce-brain-builder` | Orchestrates per-tenant brain builds — calls graphify, writes to DB | Yes (called by Cloudflare Queue + dashboard) |

All three live in `services/<name>/` with a `Dockerfile` and `fly.toml` already configured. London region (`lhr`) for UK/EU residency.

---

## Account setup

### 1. Sign up

https://fly.io/app/sign-up — free tier covers 3 small machines (we use exactly 3). Add a payment method; nothing is charged unless you exceed free allowances.

### 2. Install flyctl

```bash
brew install flyctl
flyctl version
```

### 3. Authenticate

```bash
fly auth login
```

Opens a browser tab. After that, the CLI has a long-lived token.

---

## Deploy 1 — markitdown

Markitdown converts PDFs to markdown. graphify-service will eventually call this, but for v1 we point graphify at uploaded markdown directly.

```bash
cd services/markitdown
fly launch --no-deploy --name intelforce-markitdown --region lhr --copy-config
fly deploy
```

`--copy-config` keeps our existing `fly.toml`. `--no-deploy` lets us inspect before pushing.

When `fly deploy` finishes:

```bash
curl https://intelforce-markitdown.fly.dev/health
# → { "status": "ok" }
```

---

## Deploy 2 — graphify-service

The Python wrapper around `graphifyy`. Needs an Anthropic API key (graphify's extraction step calls Claude).

```bash
cd ../graphify-service
fly launch --no-deploy --name intelforce-graphify --region lhr --copy-config

# Set the Anthropic key as a Fly secret — never commit this
fly secrets set ANTHROPIC_API_KEY=sk-ant-...

fly deploy
```

Verify:

```bash
curl https://intelforce-graphify.fly.dev/health
# → { "status": "ok", "graphify_available": true, "version": "1.x.x" }
```

If `graphify_available: false`, the Docker build didn't install the `graphifyy` package — re-run `fly deploy --force`.

---

## Deploy 3 — brain-builder-server

The orchestrator. Needs:
- `DATABASE_URL` — your Neon connection string from step 1 of `SETUP-GUIDE.md`
- `GRAPHIFY_SERVICE_URL` — the URL from the deploy above
- `COHERE_API_KEY` — for embeddings (optional but recommended)
- `BRAIN_BUILDER_TOKEN` — the random token you generated for Cloudflare

```bash
cd ../brain-builder-server
fly launch --no-deploy --name intelforce-brain-builder --region lhr --copy-config

# Set all secrets in one call
fly secrets set \
  DATABASE_URL='postgresql://user:pass@ep-xxx.eu-west-2.aws.neon.tech/intelforce?sslmode=require' \
  GRAPHIFY_SERVICE_URL=https://intelforce-graphify.fly.dev \
  COHERE_API_KEY=<your-cohere-key> \
  BRAIN_BUILDER_TOKEN=<paste from /tmp/brain-token>

fly deploy
```

Verify:

```bash
curl https://intelforce-brain-builder.fly.dev/health
# → { "status": "ok", "graphifyServiceUrl": "...", "cohereConfigured": true }
```

---

## Wire the dashboard

Update `apps/dashboard/.env.local` with the new URLs:

```env
BRAIN_BUILDER_URL=https://intelforce-brain-builder.fly.dev
BRAIN_BUILDER_TOKEN=<paste from /tmp/brain-token>

# If you also did the Cloudflare Queue setup:
CF_BRAIN_QUEUE_URL=https://intelforce-brain-queue-consumer.<subdomain>.workers.dev
```

Restart the dashboard dev server. The next wizard submit will trigger a real brain build.

---

## Smoke-test the full chain

After all three are deployed and the dashboard is wired:

1. In the dashboard, complete the wizard with a tenant slug like `test-co`
2. Submit
3. Tail logs across the chain:
   ```bash
   # In separate terminals:
   fly logs -a intelforce-brain-builder
   fly logs -a intelforce-graphify
   wrangler tail intelforce-brain-queue-consumer  # if CF queue is deployed
   ```

Expected sequence:
1. Wizard submits → POST to queue/builder
2. brain-builder logs `tenant=test-co received build job`
3. brain-builder POSTs to graphify-service → `tenant=test-co files=N staged`
4. graphify processes → returns graph JSON
5. brain-builder embeds nodes (Cohere) and writes to `ops.brain_graphs`
6. Dashboard polls /api/brain/test-co/graph → shows real data instead of demo

---

## Costs and tuning

Each `fly.toml` is configured with `auto_stop_machines = "suspend"` and `min_machines_running = 0`. This means:
- Machines suspend after a period of inactivity (free)
- First request after suspend wakes them in ~2-5 seconds
- For a low-volume early-customer setup this is exactly right

If you want zero cold-start latency on brain queries, set:
```bash
fly scale count 1 --app intelforce-brain-builder
fly scale count 1 --app intelforce-graphify
```

Cost goes from ~£0/month to ~£3/machine/month. Negligible.

---

## Rollback

```bash
fly apps destroy intelforce-markitdown
fly apps destroy intelforce-graphify
fly apps destroy intelforce-brain-builder
```

The dashboard transparently degrades — `/api/brain/[slug]/graph` returns demo data, `/api/brain/[slug]/ask` returns canned answers. Nothing breaks.

---

## Common issues

**"`fly launch` says the app name is taken"** — App names are globally unique on Fly. Suffix yours: `intelforce-graphify-yourname`. Update `fly.toml`'s `app =` accordingly.

**"Deploy fails with `EISDIR` on copy"** — You're running `fly launch` from the wrong directory. Always `cd services/<service>` first.

**"`/health` returns 200 but `/build` returns 502"** — The container is running but graphify CLI isn't on PATH. SSH in to debug:
```bash
fly ssh console -a intelforce-graphify
which graphify   # should print /usr/local/bin/graphify or similar
```

**"`fly logs` shows OOM kills"** — Bump memory in `fly.toml` `[[vm]] memory = "2gb"` and re-deploy. graphify is memory-heavy on long handbooks.
