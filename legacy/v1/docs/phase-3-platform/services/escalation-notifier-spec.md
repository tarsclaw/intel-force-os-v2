# Escalation Notifier Service Specification

**The sidecar that watches `/outbox/escalations/` across every tenant container, posts to Slack, writes to Postgres, and surfaces alerts in the dashboard.**

> **Audience:** the engineer implementing CC7 (Escalation Notifier).
>
> **Status:** v1.0. Small Go or Node service. Runs as a platform-level sidecar (one instance per region), not per tenant.
>
> **Why this exists:** agents write escalation notes to the filesystem using `hh_escalate` (see `phase-2-agent-suite/_shared/hook-helpers.sh`). That file write is durable and auditable, but it's not visible to anyone until something picks it up. This service picks it up.

---

## 1. What it does

1. Watches `/mnt/tenants/*/outbox/escalations/*.md` across every tenant volume
2. When a new file appears, parses its YAML frontmatter
3. Inserts a row into `control.escalations`
4. Posts a Slack message to the tenant's escalations channel
5. Triggers a dashboard push notification
6. On resolution (file moved to `.../escalations/resolved/`), updates the row and the dashboard

Kept deliberately simple. Agents own the "what to escalate" logic. This service owns the "make sure a human sees it" logic.

---

## 2. Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  Tenant container A                                              │
│  /outbox/escalations/2026-04-22-acme-proposal-builder.md   ─┐    │
└──────────────────────────────────────────────────────────────┼───┘
                                                               │
┌──────────────────────────────────────────────────────────────┼───┐
│  Tenant container B                                          │   │
│  /outbox/escalations/2026-04-22-foo-lead-hunter.md         ─┼┐  │
└──────────────────────────────────────────────────────────────┼┼──┘
                                                               ││
                                                               ▼▼
                           ┌─────────────────────────────────────┐
                           │    Escalation Notifier              │
                           │    (single service, one per region) │
                           │                                     │
                           │  - inotify / fsnotify watches       │
                           │  - parse YAML frontmatter           │
                           │  - dedup via file hash              │
                           └──────┬──────────┬───────────┬───────┘
                                  │          │           │
                ┌─────────────────┘          │           └──────────────┐
                ▼                            ▼                          ▼
     ┌────────────────────┐      ┌─────────────────────┐      ┌──────────────────┐
     │  Postgres          │      │  Slack              │      │  Dashboard push  │
     │  control.escalations│      │  Webhook POST       │      │  SSE endpoint    │
     └────────────────────┘      └─────────────────────┘      └──────────────────┘
```

---

## 3. File watching

### 3.1 Target paths

```
/mnt/tenants/*/outbox/escalations/*.md          # new escalations
/mnt/tenants/*/outbox/escalations/resolved/*.md # resolutions (move event)
```

### 3.2 Watch mechanism

- **Linux:** inotify via fsnotify (Go) or chokidar (Node)
- **Polling fallback:** 30-second scan in case inotify misses events (NFS mounts don't fire inotify events reliably)

### 3.3 Event types

| Event | Source | Action |
|---|---|---|
| CREATE in `/escalations/` | Agent writes new note | Insert + notify |
| MOVE from `/escalations/` to `/escalations/resolved/` | Operator resolves via dashboard | Update status |
| DELETE | Should never happen; file moves to archive only | Log at WARN |

---

## 4. Processing pipeline

For every new escalation file:

```
1. READ the file
2. PARSE YAML frontmatter — extract: agent, reason, raised_at, tenant, slug, file path
3. COMPUTE content hash (dedup key)
4. CHECK hash against recent events (last 1h) — if dup, skip
5. DETERMINE severity from reason code (lookup table)
6. INSERT INTO control.escalations
7. POST to Slack with formatted card
8. EMIT SSE event for dashboard
9. LOG structured event
```

All steps idempotent. If the service crashes mid-pipeline, restart recovers from step 1 — file is still on disk, DB dedup catches anything already inserted, Slack dedup catches any already posted.

---

## 5. Severity mapping

Each escalation code has a default severity (configurable per tenant):

| Code | Default severity |
|---|---|
| `BUDGET_BELOW_MINIMUM` | medium |
| `HIGH_VALUE_HUMAN_DRAFT` | medium |
| `OUT_OF_STANDARD_SCOPE` | medium |
| `BUYER_SKEPTICISM` | medium |
| `PROSPECT_OPTED_OUT` | low |
| `SIGNED_PROPOSAL_MISSING` | high |
| `SCOPE_CONTRACT_MISMATCH` | high |
| `KPI_UNDERPERFORMANCE` | high |
| `DATA_SOURCE_UNAVAILABLE` | high |
| `CONTROVERSIAL_TOPIC` | medium |
| `NSFW_CONTENT` | critical |
| `ASSET_OFF_BRAND` | high |
| `VOICE_MATCH_FAILED` | low |
| `BRIEF_TOO_AMBIGUOUS` | low |
| `SOURCES_INSUFFICIENT` | low |
| `INDEX_CORRUPTION` | critical |
| `DISK_SPACE_LOW` | critical |
| `EMBEDDING_PROVIDER_DOWN` | high |
| `TAG_CONSISTENCY_BROKEN` | medium |
| `COST_BUDGET_EXCEEDED` | high |
| `FATAL_CONFIG_MISSING` | critical |
| `VAULT_READ_FAILED` | critical |
| `INTEGRATION_AUTH_FAILED` | high |
| `CONFIDENTIAL_DEPENDENCIES` | high |
| ...all others | medium |

Full mapping lives in `/escalation-severity.yaml` shipped with the service.

---

## 6. Slack message shape

```
🚩 [MEDIUM] Lead Hunter escalation — Meadow Lane Dental
Code: ICP_CRITERIA_MISSING
Agent needs a human — can't proceed with this run.

> ICP file at /vault/brand/icp.md exists but only 2 of the 5 required
> fields are populated (geography and SIC codes; missing size, tech
> signals, and target roles).

Raised:  2 minutes ago
Tenant:  meadowlane-dental
Assignee: @priya

[View in dashboard](https://dashboard.intelforce.ai/tenants/meadowlane-dental/escalations/12345)
[View full note](https://dashboard.intelforce.ai/vault/outbox/escalations/2026-04-22-meadowlane-dental-lead-hunter.md)

Resolve by:
  • Filling missing ICP fields
  • Or marking this escalation "won't fix" if Lead Hunter is paused intentionally
```

**Notes:**
- Colour matches severity (green/yellow/orange/red)
- Assignee derived from tenant config's `sales_lead.slack_handle`
- Quote is pulled from the escalation note's "Why I stopped" section, truncated to 3 lines
- Both dashboard links are actual, working URLs

### 6.1 Slack threading

Multiple escalations for the same tenant within the same hour thread together under a parent message ("🚩 3 escalations for {tenant} in the last hour"). Keeps #escalations from becoming unreadable.

---

## 7. Dashboard push

The service exposes an SSE (server-sent events) endpoint that the dashboard's frontend subscribes to:

```
GET /v1/escalations/stream?tenant_id=tnt_xxx
Accept: text/event-stream
```

Emits:
```
event: escalation_raised
data: {"id": 12345, "tenant_id": "tnt_xxx", "agent": "lead-hunter", "code": "ICP_CRITERIA_MISSING", "severity": "medium", ...}

event: escalation_resolved
data: {"id": 12345, "resolved_at": "2026-04-22T16:15:00Z", "resolved_by": "priya@meadowlane-dental.co.uk"}
```

Frontend reacts by:
- Updating the Escalations count badge in the nav
- Adding a toast notification (if the user hasn't muted)
- Refreshing the escalations list view if currently open

---

## 8. Resolution flow

Operator clicks "Resolve" on the dashboard's escalations view:

1. Dashboard backend:
   - `UPDATE control.escalations SET status='resolved', resolved_at=now(), resolved_by=$user WHERE id=$id`
   - Calls the tenant's supervisor via API: "move this escalation file to resolved/"
2. Tenant supervisor:
   - `mv /outbox/escalations/file.md /outbox/escalations/resolved/file.md`
3. Escalation Notifier observes the move event:
   - Updates Slack thread with a "✅ resolved by @priya" reply
   - Emits SSE `escalation_resolved` event

Optionally: "Won't fix" — same flow, different status, no Slack reply (keeps Slack clean for genuinely open items).

---

## 9. Deployment

- **Service name:** `escalation-notifier`
- **Replicas:** 1 per region (deliberately single-instance to avoid duplicate notifications; restart is fast enough)
- **Volumes mounted:** read-only access to all `/mnt/tenants/*/outbox/` paths
- **Database access:** `escalation_notifier` role, write to `control.escalations`, read to `control.tenants`
- **Slack access:** webhook URLs per tenant stored in `secrets://{tenant_id}/slack/webhook_url`; platform-level fallback webhook for tenants without Slack

### 9.1 Running state

Keep in memory:
- Known file hashes (last 24h, for dedup) — ~10k entries tops, negligible memory
- Slack thread IDs per (tenant_id, hour) — for threading

Restart behaviour: scan all existing `/outbox/escalations/*.md` files, compare against `control.escalations` rows, insert any missing. This gives us recovery if the service was down when escalations fired.

---

## 10. Failure modes

| Mode | Impact | Mitigation |
|---|---|---|
| Slack webhook fails | No Slack ping, but DB row + dashboard still work | Retry 3x with backoff; log at WARN |
| Postgres write fails | No dashboard visibility | Retry infinitely with exponential backoff; log at ERROR |
| Service crashes | Nothing processed until restart | Kubernetes restarts; recovery pass on startup catches up |
| NFS mount drops | Can't see tenant outboxes | Alert; manually remount; catch up on restart |
| Malformed escalation note | That note skipped | Log at WARN with file path; alert after 3 consecutive malformed |

---

## 11. Throughput expectations

- MVP (5 tenants, 10 agents each): ~10 escalations/day total
- Year 1 (50 tenants): ~100 escalations/day
- High scale (500 tenants): ~1000 escalations/day

All well within a single-instance service's capacity. Horizontal scaling is not on the roadmap.

---

## 12. Implementation checklist (for CC7)

- [ ] Scaffold service (Go or Node, single-binary deployment)
- [ ] fsnotify watcher for target paths
- [ ] YAML frontmatter parser
- [ ] Deduplication logic (in-memory + DB-backed)
- [ ] Severity mapping lookup
- [ ] Postgres writer
- [ ] Slack webhook poster with threading
- [ ] SSE endpoint for dashboard
- [ ] Recovery pass on startup
- [ ] Dockerfile
- [ ] Kubernetes manifest
- [ ] Grafana dashboard — "Escalations per tenant per day" chart
- [ ] Runbook: how to replay escalations after downtime, how to mute a noisy code per tenant

---

## 13. What this service does NOT do

- **Doesn't write escalation notes** — agents do that, via `hh_escalate`
- **Doesn't make resolution decisions** — operators do via dashboard, service just reflects state
- **Doesn't route beyond Slack + dashboard** — no email notifications (yet), no SMS, no PagerDuty integration (that's for infrastructure alerts, not business escalations)
- **Doesn't own the escalation schema** — that's defined in `phase-2-agent-suite/_shared/escalation-codes.md`; this service is a consumer
