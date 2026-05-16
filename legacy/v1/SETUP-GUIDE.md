# Intel Force OS — Setup guide

End-to-end setup from zero to "I'm using the dashboard". Estimated total: **~30 minutes** if you go straight through.

Each step says **You** when it needs your account / credentials, and **Me** when it's something I can run for you once a prerequisite is in place. Tell me which step you're on and I'll execute the corresponding action.

---

## Prerequisites — install once

Three tools you'll need on your machine. Estimated 5 min:

```bash
# Postgres CLI (for connection testing — optional but nice)
brew install libpq && brew link --force libpq

# Cloudflare CLI (for the queue worker)
brew install cloudflare-wrangler2

# Fly CLI (for the three Python/Node services)
brew install flyctl
```

All three are free. None require accounts at install time.

---

## Step 1 — Postgres (Neon recommended)

Free tier supports pgvector + multi-schema. **5 minutes.**

- [ ] **You**: Go to https://neon.tech → sign up
- [ ] **You**: Create project — name "intelforce-dev", region "London (eu-west-2)" (UK residency)
- [ ] **You**: Copy the connection string — it looks like:
  ```
  postgresql://user:pass@ep-xxx.eu-west-2.aws.neon.tech/intelforce?sslmode=require
  ```
- [ ] **You**: Paste it into `apps/dashboard/.env.local` as `DATABASE_URL` (replace the `localhost` placeholder)
- [ ] **You**: Tell me "Postgres ready"
- [ ] **Me**: Run migrations:
  ```bash
  pnpm --filter @intelforce/db db:push
  ```
- [ ] **Me**: Verify the schema:
  ```bash
  pnpm --filter @intelforce/db prisma studio
  ```
  This opens a browser tab where you can see all the tables we created.

---

## Step 2 — Sign in via Clerk

Already configured (you pasted the keys). **2 minutes.**

- [ ] **You**: Refresh `http://localhost:3000` in your browser
- [ ] **You**: Sign up with your email — Clerk sends a verification code
- [ ] **You**: After verification, you land on `/`
- [ ] **You**: Open https://dashboard.clerk.com/users → click your user → copy the **User ID** (starts `user_…`)
- [ ] **You**: Tell me "Signed up, my Clerk ID is user_xxx, my email is you@example.com"
- [ ] **Me**: Seed the database:
  ```bash
  CLERK_USER_ID=user_xxx EMAIL=you@example.com \
    pnpm --filter @intelforce/db seed
  ```
- [ ] **You**: Refresh — you're now owner of "Demo Co" → navigate to `/t/demo-co`

At this point you have a working dashboard with empty data. The next steps add real intelligence (Anthropic, Cohere) and operational durability (Fly + Cloudflare).

---

## Step 3 — Anthropic API key (drives the agent + Ask the brain)

**3 minutes.**

- [ ] **You**: https://console.anthropic.com → Settings → API Keys → Create Key
- [ ] **You**: Name it "intelforce-dev"
- [ ] **You**: Copy the `sk-ant-…` key (shown once)
- [ ] **You**: Paste into `apps/dashboard/.env.local` as `ANTHROPIC_API_KEY=…` (uncomment the line)
- [ ] **You**: Add billing — Anthropic doesn't auto-credit; minimum $5 deposit
- [ ] **You**: Restart dev server (Ctrl+C → `pnpm dev` again)

Once set, ⌘K → "Ask the brain" streams real Claude completions instead of the canned demo answers.

---

## Step 4 — Cohere API key (semantic search)

**3 minutes.** Needed only if you want semantic search; otherwise the brain falls back to substring matching.

- [ ] **You**: https://dashboard.cohere.com → sign up (UK/EU region)
- [ ] **You**: Settings → API Keys → Create Trial Key (free tier: 1,000 calls/min — plenty)
- [ ] **You**: Paste as `COHERE_API_KEY=…` in `apps/dashboard/.env.local`
- [ ] **You**: Same in `services/brain-builder-server/.env` (when you deploy that — see Step 6)

---

## Step 5 — Cloudflare account + wrangler login

For the brain-build queue. **5 minutes.**

- [ ] **You**: https://dash.cloudflare.com/sign-up (free tier)
- [ ] **You**: Verify email
- [ ] **You**: Run:
  ```bash
  wrangler login
  ```
  Browser tab opens, click Allow. Wrangler stores the token at `~/.wrangler/config/`.
- [ ] **You**: Tell me "Cloudflare ready"
- [ ] **Me**: Create the queues:
  ```bash
  wrangler queues create brain-build
  wrangler queues create brain-build-dlq
  ```
- [ ] **Me**: Set the secret on the queue consumer:
  ```bash
  cd services/cf-brain-queue-consumer
  echo $(openssl rand -hex 32) > /tmp/brain-token   # generate a token
  cat /tmp/brain-token | wrangler secret put BRAIN_BUILDER_TOKEN
  ```
- [ ] **Me**: Deploy the consumer:
  ```bash
  wrangler deploy
  ```
- [ ] **Me**: Output the queue URL — paste into `apps/dashboard/.env.local` as `CF_BRAIN_QUEUE_URL`

---

## Step 6 — Deploy the three Fly services

**~10 minutes total.** Requires a Fly account + payment method (the free allowance covers this stack).

- [ ] **You**: https://fly.io/app/sign-up
- [ ] **You**: Add a payment method (no charge unless you exceed free tier)
- [ ] **You**: Run:
  ```bash
  fly auth login
  ```
- [ ] **You**: Tell me "Fly ready"
- [ ] **Me**: Deploy markitdown:
  ```bash
  cd services/markitdown
  fly launch --no-deploy --name intelforce-markitdown --region lhr --copy-config
  fly deploy
  ```
- [ ] **Me**: Deploy graphify-service (with Anthropic key):
  ```bash
  cd ../graphify-service
  fly launch --no-deploy --name intelforce-graphify --region lhr --copy-config
  fly secrets set ANTHROPIC_API_KEY=sk-ant-...
  fly deploy
  ```
- [ ] **Me**: Deploy brain-builder-server (with everything):
  ```bash
  cd ../brain-builder-server
  fly launch --no-deploy --name intelforce-brain-builder --region lhr --copy-config
  fly secrets set \
    DATABASE_URL=$(grep DATABASE_URL ../../apps/dashboard/.env.local | cut -d= -f2-) \
    GRAPHIFY_SERVICE_URL=https://intelforce-graphify.fly.dev \
    COHERE_API_KEY=$(grep COHERE_API_KEY ../../apps/dashboard/.env.local | cut -d= -f2-) \
    BRAIN_BUILDER_TOKEN=$(cat /tmp/brain-token)
  fly deploy
  ```
- [ ] **Me**: Update `apps/dashboard/.env.local` with the public URLs:
  ```
  BRAIN_BUILDER_URL=https://intelforce-brain-builder.fly.dev
  BRAIN_BUILDER_TOKEN=<paste from /tmp/brain-token>
  ```
  (`BRAIN_BUILDER_URL` is the fallback — `CF_BRAIN_QUEUE_URL` from step 5 is preferred when both are set.)

---

## Step 7 — End-to-end smoke test

- [ ] Sign in as a different test user
- [ ] Complete the wizard with a test handbook PDF
- [ ] Submit
- [ ] Watch the brain build:
  ```bash
  watch -n 2 'pnpm --filter @intelforce/db prisma studio --browser=none' &
  # In Studio, open ops.brain_graphs — should flip PENDING → BUILDING → READY in ~2 min
  ```
- [ ] Open the Brain Map for that tenant — see their actual graph
- [ ] ⌘K → ask "what does our handbook say about X" → get a streamed grounded answer

---

## Where you are now (after all 7 steps)

| Component | Status |
|---|---|
| Code | ✅ Phase 1-6 + production track complete |
| Database | ✅ Provisioned + migrations applied + seeded |
| Auth | ✅ Clerk wired + user signed in |
| Anthropic | ✅ Brain Ask streams real completions |
| Cohere | ✅ Semantic search working |
| Markitdown service | ✅ PDFs → markdown |
| Graphify service | ✅ Markdown → knowledge graph |
| Brain builder | ✅ Tenant brains built async |
| Cloudflare Queue | ✅ Durable retry on brain builds |
| Dashboard local | ✅ `pnpm dev` works |
| Dashboard hosted | ❌ Step 8 (deploy to Vercel or Cloudflare Pages) |

Step 8 (production dashboard hosting) and DNS are in `PRODUCTION-CHECKLIST.md` — they're trivial after the rest of this works.

---

## Cost expectation (monthly, light use)

- Neon: £0 (free tier — 512MB, plenty for early customers)
- Clerk: £0 (free tier — 10k MAU)
- Anthropic: £0–£20 (depends on Ask volume; ~£0.005/answer)
- Cohere: £0 (free trial tier covers our embedding load)
- Cloudflare: £0 (Workers + Queues free tier)
- Fly.io: £0–£5 (3 small machines, mostly suspended)
- **Total: roughly £0–£25/month** while you have ≤5 customers

This will scale roughly linearly with customer count, dominated by Anthropic spend on Ask + brain build extraction.
