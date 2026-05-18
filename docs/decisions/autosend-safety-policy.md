# Auto-send safety policy

**Status:** Proposed — pending Codex Day-7 ratification
**Date:** 2026-05-18 (Week 0, Day 5)
**Author:** Claude Code, with founder review pending
**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.

---

## §1 — Scope

This policy governs **every agent action that produces a side effect outside the IFOS-internal data layer**. The internal data layer is:

- The vault (`/vault/<tenant>/`) — markdown + YAML, IFOS-controlled
- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
- The pgvector indexes over the above
- The cortextOS file bus and PM2 process tree

**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).

**Actions that ARE governed:**

1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
2. Sends to humans via any communication channel (email, SMS, Telegram, Slack, LinkedIn InMail, calendar invite, etc.) — both customer-facing and consultant-internal where the consultant is not the agent's directly-supervising user
3. Reads from external systems that touch PII or have rate-limit/cost implications (LinkedIn profile lookups, Companies House director searches)
4. Any action declared as side-effecting in `tools.yaml` for an agent, regardless of category

**Out of scope:**

- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
- Render-time renderer operations (writing rendered agent dirs to `${frameworkRoot}/orgs/<org>/agents/<name>/`)
- Vault local writes by the agent's own validate.sh / context.sh / fixture runs
- Codex ratification artefacts (read-only review)

If an action's scope is ambiguous, default to **governed** and require classification.

---

## §2 — Tier model

Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.

### Green — auto-send allowed without review

Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.

**Default characteristics:** idempotent OR internal-to-tenant OR read-only against external systems with rate-limit budget remaining OR low-cost-to-reverse (e.g., add a Bullhorn tag that can be removed in <30s).

### Yellow — auto-send allowed with sampled spot-check

Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).

**Default characteristics:** high-volume actions where systematic per-action review is too slow but where systematic blind trust is too risky; sampled review provides quality signal without operational drag.

### Orange — requires human approval before send

Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.

**Default characteristics:** moderate-to-high cost-to-reverse OR customer-facing comms OR irreversible state changes.

### Red — blocked entirely

Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.

**Default characteristics:** financial/legal/cross-tenant/PII boundaries; structural integrity of the IFOS multi-tenant model.

---

## §3 — Examples per tier across the v1.0 agent surface

Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).

### Green examples (auto-send without review)

| Agent | action_type | Why green |
|---|---|---|
| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
| Concierge | `bullhorn_brief_read` | Read of inbound brief; idempotent; no comms |

### Yellow examples (auto-send with spot-check sampling)

| Agent | action_type | Sample rate | Why yellow |
|---|---|---|---|
| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |

### Orange examples (per-action human approval)

| Agent | action_type | Why orange |
|---|---|---|
| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |

### Red examples (blocked entirely; `ESC_AUTOSEND_BLOCKED`)

| action_type | block_reason | Why red |
|---|---|---|
| `xero_payment_initiate` | `payment_action` | Payment transfer; financial-bearing; never auto-send in v1.0 |
| `stripe_charge_initiate` | `payment_action` | Charges a card; financial-bearing |
| `subscription_modify` | `billing_modification` | Changes tenant's IFOS subscription; structurally distinct from agent work |
| `legal_document_generate` | `legal_artefact` | Offer letters, employment contracts; legal-binding |
| `pii_export_outside_tenant_geography` | `pii_geographic_breach` | PII transmitted outside tenant's declared data residency (e.g., GDPR boundary breach) |
| `cross_tenant_data_send` | `cross_tenant_violation` | Sending tenant-A data to tenant-B recipient; structurally enforced by RLS but red-listed for defence-in-depth |
| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |

---

## §4 — Integration with the `hh_decision_action` contract

Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:

- `hh_decision_trigger` — at session start; logs the trigger
- `hh_decision_output` — when the agent produces its output artefact
- `hh_decision_action` — when an action is taken (or blocked)

The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.

### Reference implementation (bash pseudocode for `_shared/hook-helpers.sh`)

```bash
# hh_decision_action — gate every side-effecting action through the policy
# Args:
#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
#   $2 target        (entity reference, e.g., "candidate:john-smith")
#   $3 payload_hash  (SHA-256 hex of the action payload)
#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
hh_decision_action() {
  local action_type="$1"
  local target="$2"
  local payload_hash="$3"
  local payload_preview="$4"

  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
  local tenant_slug="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
  local agent_name="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"

  # 1. Policy lookup — read tier from the canonical policy table
  local tier
  tier=$(autosend_policy_lookup "$action_type") || {
    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
    return 1
  }

  # 2. Apply tenant override (elevation only; red is floor)
  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
    return 1
  }

  # 3. Tier dispatch
  case "$tier" in
    green)
      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
      return 0
      ;;
    yellow)
      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
      if autosend_should_sample "$action_type" "$tenant_slug"; then
        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
      fi
      return 0
      ;;
    orange)
      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
      autosend_await_approval "$action_type" "$target" "$payload_hash"
      return $?
      ;;
    red)
      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
      return 1
      ;;
    *)
      # Fail-safe: unknown tier → red
      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
      return 1
      ;;
  esac
}
```

### Where the policy check fires in the renderer pipeline

The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).

**Policy hot-reload:** if the policy file changes mid-session (rare), the agent does NOT pick it up until the next session boundary (cortextOS PTY restart). Material policy changes must wait for the next 71-hour boundary or trigger a deliberate restart. Documented as an operational footgun in §11 open questions.

### `tools.yaml` declaration

Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:

```yaml
# agents/recruitment/concierge/tools.yaml (excerpt)
action_types:
  - bullhorn_brief_read              # green
  - bullhorn_candidate_query         # green
  - bullhorn_note_draft_internal     # yellow (sample 1-in-10)
  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
  - gmail_outlook_send_to_candidate  # orange
  - calendar_invite_send             # orange
  - twilio_sms_send                  # orange
```

Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).

---

## §5 — Escalation codes

Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.

### `ESC_AUTOSEND_NEEDS_REVIEW`

**Tier:** orange
**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
**Payload (JSONB into `decision_log.payload`):**

```json
{
  "action_type": "<enum from autosend-policy.yaml>",
  "target": "<entity ref, e.g., 'candidate:john-smith'>",
  "payload_hash": "<SHA-256 hex>",
  "payload_preview": "<human summary, <=500 chars, NO raw PII>",
  "tenant_slug": "<slug>",
  "agent_name": "<agent identifier>",
  "approval_deadline_at": "<ISO 8601 UTC, default trigger_time + 4h>",
  "approval_gate_id": "<cortextOS approval gate primary key>"
}
```

**Escalation path:**

1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
4. Operator responds via Telegram inline button: `approve` / `reject` / `escalate-up`
5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`

**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).

**Telegram message template:**

```
🟠 IFOS approval needed
Tenant: acme-fintech
Agent: concierge
Action: bullhorn_note_customer_visible
Target: candidate:sarah-bowen
Preview: "Following our call, I wanted to confirm the £85k 
base + 15% bonus structure for the Senior PM role at Aragon Labs..."
Approve | Reject | Escalate
Deadline: 2026-05-18 18:42 UTC
```

### `ESC_AUTOSEND_BLOCKED`

**Tier:** red
**Fires when:** a red-tier action is invoked; blocked unconditionally
**Payload:**

```json
{
  "action_type": "<enum>",
  "target": "<entity ref>",
  "payload_hash": "<SHA-256 hex>",
  "payload_preview": "<human summary, <=500 chars>",
  "block_reason": "<enum: red_tier_classification | blocked_recipient | unauthorized_adapter | cross_tenant_violation | payment_action | billing_modification | legal_artefact | pii_geographic_breach>",
  "tenant_slug": "<slug>",
  "agent_name": "<agent identifier>"
}
```

**Escalation path:**

1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
2. `autosend_escalate ESC_AUTOSEND_BLOCKED` notifies tenant operator informationally (no action required)
3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review

**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).

**Telegram message template (informational):**

```
🔴 IFOS auto-send blocked (no action required)
Tenant: acme-fintech
Agent: cash-conductor
Action: xero_payment_initiate
Target: invoice:INV-2026-0042
Block reason: payment_action (red-tier; never auto-sent in v1.0)
Block report: file via Brain UI if you believe this should be allowed
```

### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`

**Tier:** fail-safe-red (treated as red)
**Fires when:** policy lookup raises an error; action defaults to blocked
**Payload:**

```json
{
  "action_type": "<enum, may be unknown>",
  "target": "<entity ref>",
  "payload_hash": "<SHA-256 hex>",
  "payload_preview": "<human summary>",
  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
  "tenant_slug": "<slug>",
  "agent_name": "<agent identifier>"
}
```

**Escalation path:**

1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
2. `autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED` notifies tenant operator AND IFOS oncall
3. Treated as a production incident — IFOS oncall investigates within 1h
4. Root cause + fix applied (e.g., add missing `action_type` to policy, repair table corruption, fix override format)
5. Agent resumed with corrected policy

**Expected resolution:** IFOS oncall investigates within 1h during business hours; within 4h outside business hours. The affected tenant pilot may be PAUSED for that agent until policy is fixed (per `v1.0-kill-criterion.md` §2 trigger 5).

---

## §6 — Failure modes

| Failure | Detection | Response | Recovery |
|---|---|---|---|
| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
| `decision_log` table unreachable (Postgres down, RLS context unset, network partition) | INSERT raises error | **Hard blocking error**; agent halts entirely with non-zero exit; no actions taken at all | Postgres restored OR session restarted with valid context; agent resumes from last checkpoint |
| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |

---

## §7 — Audit

**Every governed action emits exactly one `decision_log` row** at execution time. The append-only enforcement (Postgres grants on `decision_log` are SELECT + INSERT only for `ifos_app` per Day 4 §6.3) means rows cannot be modified or deleted post-write.

### Row schema (within existing `decision_log` table from Day 4)

```sql
-- decision_log columns (Day 4 §6.3):
--   id BIGSERIAL
--   tenant_slug TEXT (RLS-isolated)
--   agent_name TEXT
--   phase TEXT CHECK IN ('trigger','output','action','gating_failed','agent_handoff')
--   outcome TEXT (nullable)
--   reason TEXT (nullable)
--   payload JSONB
--   created_at TIMESTAMPTZ

-- For autosend audit:
--   phase = 'action'         when allowed (green/yellow/orange-approved)
--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
--   payload structure:
--   {
--     "tier": "green|yellow|orange|red|fail-safe-red",
--     "action_type": "<enum>",
--     "target": "<entity ref>",
--     "payload_hash": "<SHA-256 hex>",
--     "payload_preview": "<<=500 chars, NO raw PII>",
--     "override_applied": "<none|tenant_elevated|tenant_blocked_recipient|...>",
--     "approval_id": "<cortextOS approval gate id if orange>",
--     "approval_status": "<pending|approved|rejected|timeout_rejected|escalated>",
--     "approval_resolution_at": "<ISO 8601 if resolved>",
--     "block_reason": "<enum if red/fail-safe-red>",
--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
--   }
```

### What audit answers

Audit queries answer two recurring questions:

1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.

2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.

### Privacy of payload

`payload_preview` is **explicitly required to exclude raw PII**. It is a human-readable summary that:

- May reference entity types ("candidate", "client") and slugs
- May reference action category ("payment reminder", "interview invite")
- Must NOT contain: full message body, email addresses, phone numbers, names beyond first-name-only-first-character (e.g., "S. Bowen" rather than "Sarah Bowen"), salary figures, candidate notes content

Full message content lives in the originating system (Bullhorn, Gmail, Twilio). Audit references the system's own audit log (e.g., Bullhorn note ID) via `payload.target`.

### Retention

`decision_log` rows are retained **indefinitely** for v1.0. v1.1+ may introduce retention policies (e.g., delete rows older than 7 years per UK statutory retention norms).

---

## §8 — Per-tenant override

Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:

```sql
INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
VALUES (
  'acme-fintech',
  'autosend_policy',
  '{
    "tier_overrides": {
      "bullhorn_note_internal": "yellow",
      "linkedin_connection_request": "orange",
      "bullhorn_candidate_dedupe": "orange"
    },
    "blocked_recipients": [
      "competitor-employees@*",
      "specific.email@example.com"
    ],
    "approval_routing": {
      "default_recipient": "<telegram-chat-id-from-secrets-env>",
      "escalation_chain": ["operator", "owner"]
    },
    "approval_timeouts": {
      "default": "PT4H",
      "twilio_sms_send": "PT30M",
      "xero_reminder_send_customer": "PT24H"
    },
    "sampling_rates": {
      "bullhorn_candidate_dedupe": 1,
      "linkedin_connection_request": 3
    }
  }'::jsonb,
  TRUE
);
```

### Override rules

1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.

### Override propagation

Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.

---

## §9 — v1.0 vs v1.1+ phasing

### v1.0 ships with green + red only

**Rationale:**

- **Green and red** give the binary "allowed" vs "blocked" classification needed for a low-risk v1.0 launch. Every action is either fully auto-sent or fully blocked. No "needs approval" or "sampled" intermediate states.
- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
- v1.0 handles "needs approval" cases via **ad-hoc Telegram approval** outside the policy pipeline: agent emits a manual approval request via existing primitive 5, founder/operator resolves manually, agent proceeds. These cases are tracked as "would-be-orange" candidates for v1.1 prioritisation.

### v1.1 phases in

- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
- Existing green and red actions remain unchanged. v1.0 → v1.1 transition is purely additive.

### v1.2+ phases in

- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.
- **Pre-action policy simulation:** Brain UI feature — operator types proposed action; system shows tier, override impact, approval routing, expected resolution time. Reduces accidental tier-aware design.
- **Multi-channel approval:** routing to Slack, Discord, MS Teams in addition to Telegram.

---

## §10 — Pilot-agreement liability language (PLACEHOLDER — legal review required)

**This section is PROPOSED PLACEHOLDER TEXT. Final wording must be reviewed by qualified counsel before the first pilot LOI is signed. Do not use this section as-is in any binding agreement.**

```
PILOT AGREEMENT — AUTO-SEND LIABILITY (PROPOSED LANGUAGE)

1. TIER CLASSIFICATION AT TIME OF SEND

The auto-send safety policy (this document, version-controlled at
docs/decisions/autosend-safety-policy.md in the IFOS code repository)
classifies each agent action into one of four tiers: green, yellow,
orange, or red. The classification in effect at the moment of send, as
recorded in the decision_log table by reference to the policy git SHA
(decision_log.payload.policy_version_sha), is the authoritative record
for purposes of this agreement.

2. TENANT LIABILITY

Tenant assumes liability for any harm, damage, or unauthorised
disclosure resulting from:
  (a) any action classified as green by the policy at time of send;
  (b) any action classified as yellow that passed spot-check review or
      was within the spot-check sampling window;
  (c) any action classified as orange that was approved by Tenant's
      designated approver via the approval gate;
  (d) any tier override defined in Tenant's tenant_adapters configuration
      that elevates or otherwise alters the policy default tier
      classification, for actions affected by that override.

3. IFOS LIABILITY

IFOS Limited (the "Provider") assumes liability for any harm, damage, or
unauthorised disclosure resulting from:
  (a) proven miscategorisation of an action by the policy that resulted
      in send when the action should have been classified at a higher
      tier;
  (b) failure of the policy lookup mechanism (decision_log fail-safe-red
      path) resulting in send when send should have been blocked;
  (c) breaches of Tenant's configured blocked_recipients list by the
      Provider's policy enforcement layer.

4. AUDIT TRAIL

The decision_log table within IFOS's Postgres instance, isolated to
Tenant's data by Postgres Row Level Security, is the authoritative record
of every send and every block. Records cannot be modified or deleted
after write (append-only, enforced by Postgres role grants). Disputes
arising under this agreement are to be resolved by reference to
decision_log timestamps, payload_hash, and policy_version_sha.

5. POLICY VERSIONING

The policy version in effect at time of send is recorded as the git SHA
of docs/decisions/autosend-safety-policy.md in the decision_log row's
payload.policy_version_sha field. Material changes to tier classification
require thirty (30) days' written notice to Tenant; Tenant may terminate
this agreement during the notice period without penalty if Tenant
disagrees with the change.

6. LIMITATIONS

This Section governs auto-send actions only. Human-initiated actions via
the Brain UI, manual Postgres queries by Tenant personnel, or any action
taken outside the IFOS agent runtime are outside the scope of this
liability allocation.

7. LIABILITY CAP

[OPEN: per-incident cap, aggregate cap per pilot, or unlimited; awaiting
legal advice]

8. JURISDICTION AND DISPUTE RESOLUTION

[OPEN: England & Wales given IFOS UK registration; arbitration vs court
forum to be specified]

[END PROPOSED LANGUAGE — LEGAL REVIEW REQUIRED BEFORE FIRST PILOT LOI]
```

### Open legal questions to resolve before first pilot LOI

1. **Jurisdiction.** IFOS Limited is UK Companies House registered → English law as default. Confirm with counsel; cross-border tenants may require alternate forum clauses.
2. **Liability cap.** Per-incident (e.g., £10k cap per send), aggregate per pilot (e.g., £100k cap), or unlimited? Trade-off: lower cap = tenant accepts more risk = easier to land first pilot; higher cap = competitive differentiator vs incumbents.
3. **Dispute resolution forum.** Arbitration (cheaper, faster, private) vs court (precedent-setting, public)? Recommendation: binding arbitration under LCIA rules.
4. **Cyber insurance.** IFOS Limited needs cyber insurance covering policy miscategorisation events. Quote requests pending; budget impact on v1.0 founder-set cost budget (Day-4 runbook §1.4 — £20/mo for infrastructure at single-tenant pilot scale; master brief does not specify a numeric cost target).
5. **PII liability for `payload_preview` formatting.** If `payload_preview` accidentally leaks PII into `decision_log`, that's a Provider liability event. Tooling: linter on `payload_preview` strings at hook-helpers.sh layer.

---

## §11 — Open questions surfaced for future ADR work

| # | Question | Surface | Recommended resolution |
|---|---|---|---|
| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
| 3 | Policy lookup latency — must be <10ms per `hh_decision_action` call. Caching strategy needed (in-memory per session vs hot-reload). | §4 | Recommend in-memory cache per session (71h cache lifetime aligns with cortextOS context rotation). Hot-reload via PTY restart only. |
| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
| 7 | Policy version pinning per-pilot — should a tenant's pilot LOI pin a specific policy git SHA, or always track main? | §10 | Recommend tracking main with 30-day notice for material changes (per §10 placeholder). Pilots that need SHA-pinning are an edge case for v1.2+. |
| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
| 10 | Telegram bot reliability — primitive 5 is shipped but not battle-tested at v1.0 pilot scale. What's the SLA on approval gate notification? | §5 + §6 | Recommend instrumentation in Week 1-2 as part of `_shared/` helpers build. Target: 95th percentile notification latency <30s. Below-target events trigger v1.1 evaluation of alternate channels. |

### Items NOT deferred (resolved inline above)

The following questions surfaced during drafting and are resolved by the policy as written:

- **Whether decision_log captures both allowed and blocked sends:** Yes, §7.
- **Whether tenants can disable spot-check sampling entirely:** No, §8 sampling_rates minimum is 1-in-100.
- **Whether red can be relaxed:** No, §8 rule 2 — red is absolute.
- **Whether the policy hot-reloads mid-session:** No, §4 documents the 71-hour session boundary.

### Day-5 founder decisions on §11 questions

Three open questions resolved by founder review on 2026-05-18 (Day 5):

- **Q3 (lookup latency / 71-hour cache lifetime):** ACCEPTED for v1.0. Policy hot-reload deliberately deferred to v1.1+; v1.0 accepts up-to-71-hour delay on policy changes taking effect at agent layer. Material policy changes must wait for next 71-hour boundary (cortextOS context rotation per master brief §2.4 primitive 2) or trigger deliberate cortextOS PTY restart. Operational footgun documented in §4.
- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.

Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.

---

## Consequences

**For Week 0 remaining.** Day 6 (vertical schema v0.1) and Day 7 (single-sentence test + Codex run) do not depend on this policy directly. Day 7's question 1 (design partner LOI) is the structural Week-0 gate; this policy supports a future LOI by providing the auto-send liability framework needed in the pilot agreement (§10).

**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.

**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).

**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).

**For Risk #3 (design partner gap).** §10 pilot-agreement liability text is a prerequisite for a signed LOI. Final legal review must happen before LOI signing per §10. This is a non-trivial path-dependency: design-partner acquisition cannot complete without legal review of this section.

**For Codex Day-7 ratification queue.** This policy joins the queue. Ratification reviews:

1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
2. `hh_decision_action` pseudocode per §4
3. ESC code payload structures per §5
4. §10 placeholder language (substantive review deferred to legal counsel, but Codex reviews structural completeness)
5. §11 open questions (does the deferral set match what we'd expect to defer?)

**For atomic-correction manifest.** Edit 10 adds the path drift correction (master brief §6 Day 5 line 484-485 → docs/decisions/). Manifest grows from 9 to 10.

---

## Status

**Proposed.** Founder review pending. Codex Day-7 ratification queued. Expected status progression:

- **Proposed** (this commit) → **Accepted** (post-Codex Day-7) → **In force** (when Week-1 `_shared/hook-helpers.sh` implementation completes)
- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.
- v1.0 implementation prerequisite: this policy + the Week-1 `_shared/` helpers + ADR-003 renderer + Day-4 Postgres schema (all four are present after this commit lands).

**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 484-485 paths to live at `docs/decisions/`.

*End of policy.*
