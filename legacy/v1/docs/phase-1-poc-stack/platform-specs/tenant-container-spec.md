# Tenant Container Structure Specification
**The base primitive every tenant runs in. Built once, deployed per tenant via config-volume mount.**

> **Audience:** the engineer implementing CC8 (Tenant Docker Image). Also the Provisioning System (CC4) which launches containers from this spec.
>
> **Status:** v1.0. Targets the shared-image-with-mounted-config model (see decision C2b).
>
> **Changes if C2b flips to per-tenant images:** the image-build step happens per-tenant instead of once. Everything else stays the same.

---

## 1. Overview

Every IntelForce AI OS tenant runs inside its own Docker container. One image per environment (dev/staging/prod), shared across all tenants. Tenant-specific data lives in a mounted volume. This gives:

- Fast tenant provisioning (no per-tenant image build; 30-second container start)
- Clean tenant isolation (container namespaces + per-tenant filesystem)
- Simple upgrades (rebuild once, all tenants inherit)
- Simple rollback (pin tenant to previous image tag)

---

## 2. Image spec

### 2.1 Base image

```dockerfile
FROM node:20-bookworm-slim
```

Debian Bookworm slim gives a stable foundation with a manageable attack surface. Node 20 LTS because Claude Code's npm package is the primary runtime, plus we'll run Node-based MCP servers. Python 3.11+ installed on top for the Python-based MCP servers (Fathom MCP, some integration wrappers).

### 2.2 Installed software

| Software | Version | Purpose |
|---|---|---|
| `@anthropic-ai/claude-code` | pinned to latest stable (e.g. `2.1.0`) | The agent runtime |
| Python 3.11 | 3.11+ | For Python MCP servers and helper scripts |
| `uv` | latest | Python package manager (faster than pip) |
| Git | 2.x | Vault sync (see §5) |
| `jq` | 1.6+ | JSON parsing in hooks |
| `curl`, `wget` | latest | Debug + retrieval helpers |
| `pnpm` | 8.x | Node package manager for MCP servers |
| IntelForce CLI tools | local bundle | `vault-search`, `cost-report`, others (see §6) |

### 2.3 Image size budget

Target under 1.2GB compressed. Anything larger slows container starts and bloats our image registry costs. If size creeps above that, move rarely-used tools into optional add-on containers.

### 2.4 Dockerfile structure (reference)

```dockerfile
FROM node:20-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3.11 python3-pip python3-venv \
      git curl wget jq ca-certificates \
      build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv (fast Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.cargo/bin/uv /usr/local/bin/uv

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@2.1.0

# Create tenant directory structure at /tenant (mount point)
# Actual contents come from the volume mount; these are just placeholders
# to ensure permissions are correct.
RUN mkdir -p /tenant/.claude/agents \
             /tenant/.claude/bin \
             /tenant/vault \
             /tenant/intake/fathom \
             /tenant/intake/hubspot \
             /tenant/intake/docusign \
             /tenant/intake/manual \
             /tenant/outbox/proposals \
             /tenant/outbox/emails-pending \
             /tenant/outbox/escalations \
             /tenant/logs \
             /tenant/secrets

# Copy the IntelForce CLI helpers into the image (shared across tenants)
COPY ./platform-helpers /usr/local/lib/intelforce-helpers
RUN ln -s /usr/local/lib/intelforce-helpers/bin/* /usr/local/bin/

# Non-root user for the tenant workload
RUN useradd -r -u 1001 -m -d /home/tenant tenant \
    && chown -R tenant:tenant /tenant /home/tenant

USER tenant
WORKDIR /tenant

# Health check — cheap tick
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD [ -f /tenant/.claude/tenant-config.json ] && \
      [ -w /tenant/logs ] && \
      claude --version > /dev/null 2>&1 || exit 1

# Container entrypoint — the supervisor process (see §7)
ENTRYPOINT ["/usr/local/bin/tenant-supervisor"]
```

---

## 3. Filesystem layout

The root of every tenant is `/tenant/`. Everything below is mounted from the tenant's persistent volume (the container itself is stateless and ephemeral; all state lives in the volume).

```
/tenant/
├── .claude/                        # Claude Code configuration (tenant-specific)
│   ├── tenant-config.json          # The full tenant config (see §4)
│   ├── settings.json               # Claude Code settings (hooks, permissions, model defaults)
│   ├── mcp.json                    # MCP server definitions with credential refs
│   ├── agents/                     # Sub-agent definitions (see agent bundles)
│   │   ├── proposal-builder/
│   │   │   ├── agent.md            # Source of truth (read-only after provisioning)
│   │   │   ├── agent.working.md    # Hydrated copy used by session (overwritten each invocation)
│   │   │   ├── config.schema.json
│   │   │   ├── tools.yaml
│   │   │   ├── validate.sh
│   │   │   └── context.sh
│   │   ├── lead-hunter/
│   │   ├── follow-up-pilot/
│   │   ├── ...
│   │   └── librarian/
│   └── bin/                        # Tenant-scoped helpers written by provisioning
│       ├── vault-search            # pgvector retrieval CLI
│       ├── cost-report             # per-invocation cost attribution
│       └── hook-runner             # orchestrates hooks
│
├── CLAUDE.md                       # The brain stem (auto-loaded, always present)
│
├── vault/                          # The Obsidian vault — GIT-SYNCED (see §5)
│   ├── .git/                       # Git repo for this tenant's vault
│   ├── .obsidian/                  # Obsidian config (shipped by provisioning)
│   ├── clients/                    # Per-prospect folders
│   ├── brand/                      # Voice profile, pricing framework, brand docs
│   ├── sops/
│   ├── content/
│   ├── daily/                      # Librarian-generated daily rollups
│   └── archive/                    # Superseded material, still searchable
│
├── intake/                         # Landing zone for webhook + trigger payloads
│   ├── fathom/
│   ├── hubspot/
│   ├── docusign/
│   ├── stripe/
│   └── manual/                     # Dashboard "Run Now" button drops here
│
├── outbox/                         # Agent outputs awaiting delivery
│   ├── proposals/                  # Draft proposals (pre-Gmail-draft)
│   ├── emails-pending/             # Emails that failed to deliver to Gmail
│   ├── escalations/                # Escalation notes awaiting human review
│   └── reports/
│
├── logs/                           # Structured JSONL logs (shipped by observability)
│   ├── validate-{date}.jsonl
│   ├── context-{date}.jsonl
│   ├── agent-invocations-{date}.jsonl
│   └── cost-{date}.jsonl
│
└── secrets/                        # Encrypted credentials (KMS-wrapped)
    └── vault.enc                   # Opens via KMS at runtime; never decrypted on disk
```

### 3.1 Permissions matrix

| Path | Owner | Mode | Notes |
|---|---|---|---|
| `/tenant/` | `tenant:tenant` | `755` | Root mount |
| `/tenant/.claude/agents/*/agent.md` | `tenant:tenant` | `444` | Read-only after provisioning — agent definitions don't mutate |
| `/tenant/.claude/agents/*/agent.working.md` | `tenant:tenant` | `644` | Rewritten per session by context.sh |
| `/tenant/.claude/tenant-config.json` | `tenant:tenant` | `400` | Tenant-only readable — contains secret refs |
| `/tenant/vault/**` | `tenant:tenant` | `664` | Read/write |
| `/tenant/intake/**` | `tenant:tenant` | `664` | Webhook receiver writes here |
| `/tenant/outbox/**` | `tenant:tenant` | `664` | Agents write here |
| `/tenant/logs/**` | `tenant:tenant` | `600` | Tenant-only readable; shipped out by Vector |
| `/tenant/secrets/**` | `tenant:tenant` | `400` | Decrypted in-memory only, never written plain |

---

## 4. Tenant configuration (`tenant-config.json`)

The single source of truth for this tenant's provisioning state. Written by the Provisioning System at deployment time. Read by context.sh, validate.sh, and every hook.

```json
{
  "tenant": {
    "id": "tnt_01JKDY8X5RQ4P2N6",
    "created_at": "2026-04-22T14:00:00Z",
    "plan": "growth",
    "status": "active",
    "deployed_version": "1.2.0"
  },
  "client": {
    "name": "Meadow Lane Dental",
    "company_slug": "meadowlane-dental",
    "industry": "Dental practice",
    "sic_code": "86230",
    "website": "https://meadowlane-dental.co.uk",
    "currency": "GBP",
    "timezone": "Europe/London",
    "vat_treatment": "ex-vat"
  },
  "sales_lead": {
    "name": "Dr Priya Shah",
    "first_name": "Priya",
    "email": "priya@meadowlane-dental.co.uk",
    "slack_handle": "@priya",
    "signature_block": "Dr Priya Shah\nPrincipal Dentist, Meadow Lane Dental\n..."
  },
  "anthropic": {
    "api_key_ref": "secrets://tnt_01JKDY8X5RQ4P2N6/anthropic/api_key",
    "metadata_tags": {
      "tenant_id": "tnt_01JKDY8X5RQ4P2N6",
      "plan": "growth"
    }
  },
  "embedding_provider": {
    "name": "cohere",
    "api_key_ref": "secrets://tnt_01JKDY8X5RQ4P2N6/cohere/api_key",
    "model": "embed-v3",
    "region": "eu-west-1"
  },
  "vault_sync": {
    "method": "git",
    "remote": "git@github.com:intelforce-vaults/meadowlane-dental.git",
    "branch": "main",
    "auth_ref": "secrets://tnt_01JKDY8X5RQ4P2N6/github/deploy_key"
  },
  "agents": {
    "enabled": [
      "proposal-builder",
      "lead-hunter",
      "follow-up-pilot",
      "content-creator",
      "repurposer",
      "caption-writer",
      "client-onboarder",
      "reporting-engine",
      "sop-writer",
      "librarian"
    ],
    "addons_enabled": [],
    "per_agent_config_path": "/tenant/.claude/agents/{name}/tenant-config.merged.json"
  },
  "observability": {
    "log_shipper": "vector",
    "control_plane_endpoint": "https://control.intelforce.ai/ingest",
    "alert_webhook": "https://hooks.slack.com/services/..."
  },
  "webhooks": {
    "receiver_base": "https://hooks.intelforce.ai/tnt_01JKDY8X5RQ4P2N6",
    "registered": [
      { "integration": "fathom", "url": "https://hooks.intelforce.ai/tnt_01JKDY8X5RQ4P2N6/fathom", "secret_ref": "secrets://tnt_01JKDY8X5RQ4P2N6/fathom/webhook_secret" },
      { "integration": "hubspot", "url": "https://hooks.intelforce.ai/tnt_01JKDY8X5RQ4P2N6/hubspot", "secret_ref": "secrets://tnt_01JKDY8X5RQ4P2N6/hubspot/webhook_secret" }
    ]
  },
  "cost_budget": {
    "monthly_gbp": 150,
    "alert_threshold_pct": 80,
    "hard_stop_pct": 100
  }
}
```

### 4.1 Hot-reloading

Changes to `tenant-config.json` are picked up on the next agent invocation — no container restart required. Provisioning System writes an atomic update (write-to-temp + rename) so concurrent reads see either the old or new state, never a partial update.

---

## 5. Vault sync (Git-backed)

### 5.1 Remote

Each tenant has a private GitHub repo under your `intelforce-vaults` org:
- Repo name: `intelforce-vaults/{tenant-company-slug}`
- Visibility: private
- Access: deploy key specific to this tenant (readable only inside this container)

### 5.2 Sync mechanism

The container runs a small sidecar process (`vault-syncer`, part of platform-helpers) that:
1. On boot: `git clone` the vault into `/tenant/vault/` if it doesn't exist.
2. Continuously: watches `/tenant/vault/` for writes via `inotify`.
3. On write: debounces 30s, then `git add . && git commit -m "agent: {agent} — {summary}" && git push`.
4. Every 15min: `git pull` to pick up any client-side edits (Obsidian app writes).

Commit messages encode attribution: `agent: proposal-builder — drafted proposal for Meadow Lane`. This gives a natural audit log.

### 5.3 Conflict handling

Rare but handled. Vault writes are append-heavy (new notes, rarely edited-in-place), so true conflicts are uncommon. When they do occur:
- Agent writes always win on `/vault/clients/**/proposals/**` (machine-generated, timestamped)
- Client edits always win on `/vault/brand/**` (they own their brand)
- Everything else: last-write-wins, conflicts get tagged with `[[CONFLICT-{timestamp}]]` for human review

---

## 6. Platform helpers (`/usr/local/bin/`)

Thin CLI tools shipped into every image. Each is a few dozen lines of Node/Python.

| Tool | Purpose |
|---|---|
| `vault-search` | Semantic retrieval against the tenant's pgvector index. Called by context.sh. Takes `--query`, `--tag`, `--top-k`, returns JSON results. |
| `cost-report` | Summarises API spend for this tenant since invocation X. Called by dashboard. |
| `hook-runner` | Wrapper around all pre/post-tool hooks; handles JSON stdin, timeouts, retries. |
| `tenant-supervisor` | The container's entrypoint. Starts vault-syncer, log-shipper, and waits for trigger signals. |
| `cc-invoke` | Convenience wrapper: `cc-invoke proposal-builder --trigger /path/to/payload.json` — handles trigger file plumbing, logging, error capture. |

---

## 7. Supervisor (container entrypoint)

The container doesn't run Claude Code continuously — that would burn API tokens 24/7. Instead, the supervisor is a long-running thin Node process that:

1. Starts `vault-syncer` as a subprocess (persistent).
2. Starts the Vector log-shipper as a subprocess (persistent).
3. Opens a Unix socket at `/tmp/tenant.sock` (`/tenant/.claude/tenant.sock`) and listens for trigger messages.
4. When a trigger arrives: spawns `cc-invoke` with the trigger payload path. Claude Code runs → exits. Supervisor collects exit code and logs.
5. Rotates logs nightly.
6. Exposes a health endpoint on `127.0.0.1:9091/health` for the container orchestrator.

### 7.1 Trigger sources (all route through the socket)

- Webhook receiver: POST → socket
- Cron scheduler: socket write → supervisor → cc-invoke
- Dashboard "Run Now": control plane → socket via secure tunnel
- Manual (dev / debug): CLI directly to socket

### 7.2 Concurrent invocations

One tenant can run multiple agents concurrently. Supervisor uses a worker pool (default size 3) to run agents in parallel. Each invocation is isolated (own Claude Code process). No shared state beyond the vault, which is concurrent-safe by design (file writes go through git which linearises).

---

## 8. Network

### 8.1 Egress (outbound) whitelist

Container can only reach:
- `api.anthropic.com` (Claude API)
- `api.cohere.com` or `api.eu.cohere.com` (embeddings)
- `api.fathom.ai` + other integration API hosts (per-tenant MCP config)
- `github.com` (vault sync, narrowed to tenant's deploy key)
- `hooks.intelforce.ai` (only outbound pings, for self-registration)
- `control.intelforce.ai` (log + telemetry shipment)

All other egress blocked at the container network policy. This is the UK-sovereignty story in concrete terms: data flows only to named, declared processors.

### 8.2 Ingress (inbound)

The container does not accept inbound connections directly. All triggers arrive via:
- The Unix socket (from the webhook receiver on the same host)
- The supervisor's health endpoint on localhost only

No public IP on the container. The webhook receiver (a separate service) is the only internet-facing component.

---

## 9. Resource limits

Per-tenant container defaults (configurable per plan):

| Resource | Starter | Growth | Scale |
|---|---|---|---|
| CPU limit | 1 vCPU | 2 vCPU | 4 vCPU |
| Memory limit | 1 GiB | 2 GiB | 4 GiB |
| Disk (vault) | 5 GiB | 20 GiB | 100 GiB |
| Disk (logs, rotated) | 2 GiB | 5 GiB | 10 GiB |
| Concurrent agent invocations | 1 | 3 | 10 |

These match the pricing tiers and are enforced by the orchestrator (Kubernetes limits on Hetzner K3s, or Docker resource constraints on plain Docker hosts).

---

## 10. Startup sequence

When a container starts:

```
T+0s   Container boots, supervisor starts
T+1s   Supervisor decrypts /tenant/secrets/vault.enc via KMS (fails fast if KMS unreachable)
T+2s   vault-syncer clones/pulls the vault from GitHub
T+4s   Vector log-shipper starts, connects to control plane
T+5s   Supervisor opens Unix socket, writes health "ready"
T+6s   Health check starts passing
T+7s+  Supervisor idles; waiting for triggers
```

Target boot time: under 10 seconds. The actual agent invocation latency (from trigger arriving to Claude Code starting) should be under 1s on a warm container.

---

## 11. Shutdown

Graceful shutdown on `SIGTERM`:

1. Supervisor stops accepting new triggers
2. In-flight invocations allowed to complete (max wait: 60s)
3. Final log flush
4. `git push` any pending vault commits
5. Exit

`SIGKILL` after 60s if any stage hangs.

---

## 12. Upgrades & rollbacks

### 12.1 Upgrade flow

1. New image built, tagged `intelforce/tenant:1.3.0`.
2. Tested on staging tenant.
3. Promoted to production manifest (updates image tag).
4. Orchestrator performs rolling restart, one tenant at a time (respecting concurrent limits).
5. Health check gate: new tenant container must pass health before old is terminated.

### 12.2 Rollback

Single command rollback: `intelforce rollback --tenant tnt_XXX --to 1.2.0`. Pins tenant to previous image tag. Used when a specific tenant breaks on a new image.

### 12.3 Per-tenant version pinning (Enterprise tier only)

Enterprise clients can pin to a specific image version in their MSA. Provisioning System respects the pin and excludes that tenant from the rolling upgrade.

---

## 13. Build pipeline (how the image gets built)

- CI: GitHub Actions on `intelforce/tenant-image` repo
- Trigger: push to `main` OR tag matching `v*.*.*`
- Build: multi-arch (amd64 + arm64) via docker buildx
- Scan: Trivy for CVEs, fail on HIGH or CRITICAL
- Test: spin up a test tenant, run all 10 agents' smoke tests
- Publish: ghcr.io/intelforce/tenant-image:{version}
- Promote: manual approval step before tagging as `:latest`

---

## 14. Open questions for CC8 implementation

- Whether to use `distroless` in v2 for reduced attack surface (requires moving away from Debian-based; trade-off with debuggability).
- Whether to run `claude` as a separate systemd user inside the container for further privilege separation (likely v2).
- Whether the platform-helpers should be a separate versioned package or baked into the image (v1: baked; v2: probably separate for independent upgrade).

These do not block the v1 build. Flag them in the runbook for v2 planning.
