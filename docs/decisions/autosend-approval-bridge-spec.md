# Autosend approval bridge — implementation spec

**Status:** Proposed
**Date:** 2026-05-22 (Day 11, pre-Concierge W10 prerequisite)
**Author:** Claude Code
**Surfaced by:** Founder Decision D1 (`docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`) + Codex Round 1 autosend rejection issue 2
**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
**Estimated effort:** 2-3 days (NOT 1 week as the founder briefing originally implied)

---

## §1 — Why this exists

Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.

The infrastructure for IFOS-side approval pending is **already shipped** in Phase 3 (commit `e6e9df1`):

- `agents/_shared/hook-helpers.sh::autosend_await_approval` writes pending marker `/vault/<tenant>/pending-approvals/<hash>.pending`
- Polls for `.approved` or `.rejected` marker files (5s→60s backoff)
- 4h timeout converts to `ESC_AUTOSEND_NEEDS_REVIEW`

What's **missing**: the bridge that converts a `.pending` marker into a Telegram approval request, and a Telegram button-press back into a `.approved`/`.rejected` marker.

This spec defines that bridge.

---

## §2 — Existing cortextOS surface (primitive 4)

`packages/harness/cortextos/src/bus/approval.ts` already implements the Telegram approval flow:

```typescript
// EXISTS in upstream — read-only submodule per master brief §3.1 boundary 1
export async function createApproval(
  paths: BusPaths,
  agentName: string,
  org: string,
  title: string,
  category: ApprovalCategory,
  context?: string,
  frameworkRoot?: string,
  agentDir?: string,
): Promise<string>
// → writes ${approvalDir}/pending/approval_<epoch>_<rand5>.json
// → fans out to Telegram with [Approve][Deny] inline buttons
// → returns approvalId
```

```typescript
export function updateApproval(
  paths: BusPaths,
  approvalId: string,
  status: 'approved' | 'denied',
  note?: string,
): void
// → moves file from pending/ to resolved/
// → notifies requesting agent via inbox message
```

This is shipped + tested + production-hardened (per `cortexos-primitive-status.md` §"Primitive 4"). **We do not need to build a Telegram bot from scratch.**

The Telegram bot itself is `packages/harness/cortextos/src/telegram/*` — also shipped + tested. Inline-button presses → `updateApproval(approvalId, 'approved'|'denied')` is wired end-to-end per `src/bus/approval.ts:178-229` + `src/daemon/agent-manager.ts` activity-channel poller.

---

## §3 — What we build: the IFOS bridge

A new IFOS package: `packages/autosend-approval-bridge/`. ~200-250 lines of TypeScript. Runs as a long-lived process (PM2-managed alongside the daemon).

### §3.1 — The bridge's two loops

**Loop 1: IFOS pending → cortextOS approval**

```
Watch /vault/<tenant>/pending-approvals/*.pending (across all tenants)
  ↓
For each new .pending file:
  - Read action_type, target, payload_hash, payload_preview from the marker
  - Map IFOS action_type → cortextOS ApprovalCategory (autosend taxonomy)
  - Call cortextOS createApproval(paths, agentName, org=tenant_slug, title, category, context)
  - Record mapping {ifos_payload_hash → cortextos_approval_id} in bridge state
```

**Loop 2: cortextOS resolved → IFOS marker write**

```
Watch ${CTX_FRAMEWORK_ROOT}/orgs/<org>/approvals/resolved/*.json
  ↓
For each new resolved file:
  - Look up the IFOS payload_hash from bridge state via cortextos_approval_id
  - Parse JSON for status ('approved' or 'denied')
  - If approved: write /vault/<tenant>/pending-approvals/<payload_hash>.approved
  - If denied:   write /vault/<tenant>/pending-approvals/<payload_hash>.rejected
  - Remove the .pending marker
  - Update bridge state mapping → resolved
```

The bridge's `autosend_await_approval` polling loop (already in `hook-helpers.sh`) sees the new marker → returns 0 (approved) or 1 (rejected) → agent proceeds or escalates.

### §3.2 — Bridge state persistence

Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:

```sql
CREATE TABLE IF NOT EXISTS autosend_approval_mappings (
  ifos_payload_hash    TEXT PRIMARY KEY,
  cortextos_approval_id TEXT NOT NULL UNIQUE,
  tenant_slug          TEXT NOT NULL,
  agent_name           TEXT NOT NULL,
  action_type          TEXT NOT NULL,
  target               TEXT NOT NULL,
  status               TEXT NOT NULL CHECK (status IN ('pending','approved','denied','timeout_expired')),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at          TIMESTAMPTZ,
  resolved_by          TEXT
);

ALTER TABLE autosend_approval_mappings ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON autosend_approval_mappings
  USING (tenant_slug = current_setting('ifos.tenant_slug', TRUE));
GRANT SELECT, INSERT, UPDATE ON autosend_approval_mappings TO ifos_app;
```

This adds the 10th tenant-data table (T1-T12 invariants apply). Tenancy-invariants.md needs update on landing.

### §3.2.1 — Tenancy invariants update

`autosend_approval_mappings` becomes the 10th tenant-data table when the bridge implementation lands. The Week-9 bridge implementation slice MUST update `docs/architecture/tenancy-invariants.md` §1 and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` to include this table in T1-T3, T11, and audit coverage. This remediation corrects the spec only; the table does not exist yet, so the live invariant inventory remains the v0.2 nine-table set until the bridge migration ships.

### §3.3 — IFOS action_type → cortextOS ApprovalCategory mapping

cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:

| IFOS action_type | cortextOS category |
|---|---|
| `bullhorn_note_customer_visible` | `external-comms` |
| `gmail_outlook_send_to_candidate` | `external-comms` |
| `twilio_sms_send` | `external-comms` |
| `calendar_invite_send` | `external-comms` |
| `email_summary_to_customer` | `external-comms` |
| `xero_reminder_send_customer` | `financial` |
| `diagnostic_email_send` | `external-comms` |
| `diagnostic_calendar_invite` | `external-comms` |
| `linkedin_inmail_send` | `external-comms` |
| `bullhorn_placement_terminate` | `data-deletion` |

`bullhorn_placement_terminate` maps to `data-deletion` because placement termination destroys/closes a placement record; `other` remains only an explicit fallback for future action_types without a clean cortextOS category. The category is metadata for cortextOS's audit; IFOS-side semantics are preserved via the action_type field in our state table.

### §3.4 — Telegram operator UX

When the bridge calls `createApproval`, the operator's Telegram chat receives a message like:

```
🔔 Approval request: Concierge bullhorn_note_customer_visible

Tenant: acme-recruitment
Agent: concierge
Action: write customer-visible Bullhorn Note
Target: candidate:s.bowen
Payload preview: <500-char operator-friendly summary, no raw PII>

[✅ Approve] [❌ Deny]
```

(Format inherited from `postApprovalToActivityChannel` — no IFOS customisation needed for v1.0; might want a more recruiter-specific template at v1.1.)

Operator taps button → cortextOS Telegram bot fires → `updateApproval(approvalId, 'approved'|'denied')` → resolved file → bridge writes marker → IFOS agent proceeds.

### §3.5 — Timeout behaviour

`autosend_await_approval` already enforces 4h default timeout per action_type's `timeout` field in autosend-policy.yaml. If the timeout fires before operator responds:

1. IFOS-side: poll loop exits → `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` → agent gives up
2. cortextOS-side: approval file stays in `pending/` indefinitely (no auto-timeout) — **THIS IS A LEAK**

**Bridge fix:** on IFOS-side timeout, the bridge MUST call `updateApproval(approvalId, 'denied', note='ifos_timeout')` to clean up the pending file. Otherwise stale pending approvals accumulate in cortextOS.

### §3.6 — Failure modes

| Failure | Bridge behaviour |
|---|---|
| cortextOS approval system down (createApproval throws) | Write `<hash>.bridge-error` marker; IFOS poll-loop times out at 4h; ESC_AUTOSEND_NEEDS_REVIEW fires with `reason='bridge_unavailable'` |
| Operator never responds (4h timeout) | Bridge cleans up cortextOS pending file via `updateApproval(..., 'denied', 'ifos_timeout')` |
| Bridge process crashes | PM2 restart; on restart, scan all `*.pending` markers + cortextOS pending/ to rebuild bridge state |
| Postgres unreachable | Write bridge state to fallback JSONL at `/vault/_meta/autosend-bridge.jsonl`; same replay pattern as decision_log fallback |
| Telegram bot down (cortextOS Primitive 5) | `createApproval` still writes pending file; operator can approve via Brain UI (v1.1+) OR direct file write (founder Path A) |

### §3.7 — Concurrency

- Per-tenant pending dir is watched; per-tenant resolved dir is watched. Multi-tenant write contention is rare (each tenant has independent dirs).
- File watches use `fs.watch` with debounce 100ms (race condition: file write completion).
- Bridge state inserts use `INSERT ... ON CONFLICT DO NOTHING` to handle restart-replay.

---

## §4 — Implementation surface

```
packages/autosend-approval-bridge/
├── package.json              ← @ifos/autosend-approval-bridge; Node 20+
├── tsconfig.json
├── README.md
├── src/
│   ├── cli.ts                ← entry; PM2-managed long-lived process
│   ├── bridge.ts             ← orchestration (2 loops + state)
│   ├── ifosWatcher.ts        ← Loop 1: watch /vault/<tenant>/pending-approvals/
│   ├── cortextosWatcher.ts   ← Loop 2: watch ${CTX_FRAMEWORK_ROOT}/orgs/<org>/approvals/resolved/
│   ├── categoryMapper.ts     ← IFOS action_type → cortextOS ApprovalCategory
│   ├── stateStore.ts         ← Postgres persistence + JSONL fallback
│   └── types.ts
└── tests/
    ├── unit/
    │   ├── categoryMapper.test.ts
    │   ├── stateStore.test.ts
    │   └── bridge.test.ts        ← integration with mock cortextOS approval surface
    └── fixtures/
        └── approval-flow/        ← golden inputs/outputs for the 2 loops
```

Estimated: ~600 lines TypeScript (incl. tests), ~150 lines bash/PM2 config. Similar shape to `packages/agent-renderer/` but smaller.

---

## §5 — Database migration (v0.3 schema increment)

Adding `autosend_approval_mappings` table requires:
- `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` — adds the table + GRANTs + RLS policy
- `docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql` — rollback (DROP TABLE)
- `docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml` (or similar) — schema doc

Total schema impact: 1 new table; tenancy-invariants.md grows from 12 to 13 invariants (T13: autosend_approval_mappings tenant_slug + RLS), or we count this as covered by T1-T3 already (cleaner).

---

## §6 — Acceptance criteria

| # | Acceptance | Test |
|---|---|---|
| A1 | Bridge process starts via PM2 + connects to Postgres + reads bridge state | `pm2 status ifos-autosend-bridge` shows online; bridge starts fresh on empty DB |
| A2 | `.pending` marker triggers `createApproval` call within 200ms | Integration test: write marker → assert cortextOS pending file appears with correct payload |
| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
| A4 | 4h timeout: bridge calls `updateApproval(..., 'denied', 'ifos_timeout')` cleanly | Integration test: write `.pending` marker, advance simulated clock 4h, assert cortextOS `pending/` is empty + `resolved/` has `denied` record |
| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
| A6 | RLS: bridge writing tenant-A's approval cannot leak tenant-B's pending markers | Tenancy audit T11 extension: cross-tenant marker read returns 0 |
| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
| A8 | Bridge state row in `autosend_approval_mappings` exists for every pending approval | Audit query: count(pending markers) == count(pending bridge state rows) |
| A9 | shellcheck + tsc clean | `pnpm typecheck` + `pnpm test` + shellcheck for any bash entry |
| A10 | Live VPS smoke: real Telegram chat receives approval message + button press routes back to marker | Founder Path A manual test on migration-test tenant |

---

## §7 — When to build

**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
- Day 1-2: build bridge code + unit tests
- Day 3: live integration test on migration-test tenant
- Day 4 (Concierge W10 start): Concierge uses bridge from day 1

**Alternative:** as the next IFOS Claude slice (now). Pre-builds the prerequisite before Diagnostic W3-4 starts, so it's not blocking Concierge. ~2-3 days inserted before Diagnostic.

**Founder decision:** schedule for Week 9 (sequential with master brief) OR insert now (parallel with Diagnostic prep).

---

## §8 — What this spec does NOT cover

- **Building the cortextOS Telegram bot** — already exists upstream
- **Building the IFOS-side `autosend_await_approval` polling loop** — already exists in `hook-helpers.sh` (Phase 3)
- **Modifying cortextOS source** — boundary violation; bridge uses cortextOS's existing public API (`createApproval` + `updateApproval`)
- **iOS approval surface** — aspirational per `cortexos-primitive-status.md` §"Primitive 5"; v1.1+ concern
- **Standing authorisations** ("auto-approve category X for next 24h") — explicitly NOT a cortextOS primitive per primitive-status doc; IFOS-layer concept for v1.1+
- **Re-authorisation flow** — if an operator approves but then changes their mind, action is in-flight; v1.0 ships forward-only

---

## §9 — Risks + mitigations

| # | Risk | Mitigation |
|---|---|---|
| 1 | cortextOS approval API signature changes upstream | Pinned SHA `c21fbfe` for v1.0; bridge tests catch any drift at submodule bump time |
| 2 | Bridge process becomes a single point of failure | PM2 restart on crash; fallback JSONL for state; multiple bridge processes per-tenant possible at v1.1+ scale |
| 3 | Mapping table grows large at scale | Cleanup cron: rows older than 30 days with status≠pending get purged. Doesn't affect operational correctness. |
| 4 | Operator approves but bridge crashes before marker write | Recovery on restart: scan resolved/ + replay missed conversions. Idempotent via `ON CONFLICT DO NOTHING`. |
| 5 | Race: operator approves the SAME approval twice (double-tap) | cortextOS updateApproval is idempotent on `approvalId`; second call no-ops |
| 6 | RLS on autosend_approval_mappings forgotten | Migration includes ENABLE ROW LEVEL SECURITY; tenancy audit T2 catches if missing |

---

## §10 — Out of scope for v1.0 → v1.1 reservations

- Approval batching ("approve all 5 pending bullhorn_note_customer_visible at once") → v1.1+
- Approval delegation ("approve as ifos-csm on behalf of operator") → v1.1+
- Webhook approval surface (alternative to Telegram polling) → v1.1+
- Approval analytics dashboard (Brain UI) → v1.1 Brain UI build
- iOS native approval app → v1.2+ when iOS surface enabled

---

## §11 — Status

**Proposed.** Founder decision pending: build timing (Week 9 OR now).

Codex Day-7 manifest queue position: TBD (will be ~#39 when filed). Ratifies via `review-architecture-decision.md` skill (with D5 softening applies if Status flipped to Reference after build complete).

When built:
- Adds 1 tenant-data table (`autosend_approval_mappings`) → tenancy-invariants.md update OR considered covered by T1-T3 patterns
- Adds 1 PM2-managed process (`ifos-autosend-bridge`) → ecosystem.config.js update
- Unblocks Concierge build (W10-13) — without this, Concierge can only ship as drafts-only (D1-A) which loses the demo value prop

*End of spec.*
