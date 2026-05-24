# IFOS escalation codes catalogue

**Status:** Reference — single source of truth for `ESC_*` codes used by any agent. Wired into `_shared/hook-helpers.sh` (Phase 3).
**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
**Update protocol:** new codes added here BEFORE wiring into helpers + before referencing from any agent bundle. Code names are case-sensitive; pattern `ESC_[A-Z][A-Z0-9_]*`.

---

## §1 — How escalation codes work

Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).

The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:

```
agent_name        — the agent firing the escalation (or '_renderer')
tenant_slug       — RLS-isolated per tenant
phase             — one of {trigger, output, action, gating_failed, agent_handoff}; per decision_log CHECK constraint at Day-4 §6.3
human_action      — the ESC_* code itself + optional `:reason` suffix
payload           — JSON object: {tier?, action_type?, target?, payload_hash?, reason, ...code-specific fields}
created_at        — `now()` at insertion
```

The Telegram message is templated via `common-notifications.json` `escalation_routes.<ESC_CODE>` if present; otherwise routed to `operator_chat_id`. `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` additionally CCs `ifos_oncall_chat_id`.

---

## §2 — Catalogue (24 codes)

### 2.1 — Auto-send safety (3 codes)
Source: `docs/decisions/autosend-safety-policy.md` §5

#### `ESC_AUTOSEND_NEEDS_REVIEW`
- **Severity:** info → blocking-pending-approval
- **Trigger:** Orange-tier action queued for tenant operator review
- **Phase:** `action`
- **Routing:** `operator_chat_id` via Telegram approval gate (primitive 4)
- **Timeout:** 4h default per `common-notifications.json.default_approval_timeout_seconds`; on timeout, converts to manual reconciliation
- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`

#### `ESC_AUTOSEND_BLOCKED`
- **Severity:** warn (informational; no human action needed)
- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`; informational only
- **Payload fields:** `tier='red'`, `action_type`, `target`, `payload_hash`, `reason='red_tier_classification'`

#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
- **Severity:** **critical** — operational failure, not a policy decision
- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — IFOS oncall must investigate
- **Payload fields:** `tier='fail-safe-red'`, `action_type`, `target`, `reason` (one of `unknown_action_type`, `override_resolution_failed`, `unknown_tier:<value>`)
- **Fail-safe behaviour:** Action refused regardless of declared tier

### 2.2 — Vault concurrency (5 codes)
Source: `docs/architecture/vault-concurrency.md` §6

#### `ESC_VAULT_LOCK_TIMEOUT`
- **Severity:** warn
- **Trigger:** `flock` acquisition failed within `OP_LOCK_TIMEOUT_S = 5` seconds (per `common-vault.json.lock_timeout_seconds`)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `vault_path`, `lock_holder_pid` (if knowable), `wait_duration_ms`

#### `ESC_VAULT_VERSION_MISMATCH`
- **Severity:** warn
- **Trigger:** Postgres optimistic-concurrency UPDATE found 0 rows after `OP_RETRY_BACKOFF_MS = 100` retry (per `common-vault.json.retry_backoff_ms`); per vault-concurrency §3 retry policy
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `entity_id`, `expected_version`, `actual_version`

#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
- **Severity:** warn — likely founder is editing in Obsidian
- **Trigger:** Obsidian debounce hit `MAX_RETRIES = 5` (file mtime still recent after 30s of waiting) per vault-concurrency §4 + `common-vault.json.obsidian_debounce_max_retries`
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `vault_path`, `file_mtime`, `last_observed_age_ms`

#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
- **Severity:** warn — requires founder manual reconciliation
- **Trigger:** Rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite per vault-concurrency §5.4 v1.0 mitigation
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `failures` (list of entity_id strings), `successful_count`, `total_count`

#### `ESC_VAULT_CASCADE_TIMEOUT`
- **Severity:** warn
- **Trigger:** Cascade exceeded `CASCADE_TIMEOUT_MS = 30_000` ms per vault-concurrency §5 + `common-vault.json.cascade_timeout_ms`
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `partial_progress_count`, `total_refs_count`

### 2.3 — Bullhorn integration (1 code)
Source: `docs/decisions/bullhorn-integration-path.md` §4.5 + §6

#### `ESC_BULLHORN_AUTH`
- **Severity:** **blocking** — agent enters degraded mode (drafts-only, no auto-send)
- **Trigger:** Bullhorn OAuth token refresh failed twice on the per-agent 8-minute cycle (per `common-ats.json.auth_refresh_interval_seconds`); or REST call returned 401 indefinitely (revoked token in Bullhorn admin UI)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `failure_type` (one of `refresh_failed`, `revoked_401`), `last_attempt_at`, `consecutive_failures`
- **Recovery:** agent stays in degraded mode until founder rotates token via Bullhorn admin → next `_secrets.env` reload picks up new token

### 2.4 — Renderer (1 code)
Source: `docs/architecture/agent-bundle-renderer-design.md` §4

#### `ESC_RENDERER_FAILED`
- **Severity:** blocking — render did not produce a runnable agent dir
- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`; CC `ifos_oncall_chat_id` only on `atomic-rename-failed` (infrastructure failure, not author error)
- **Agent name:** `_renderer` (sentinel; not a real agent)
- **Payload fields:** `reason` (one of `schema-validation-failure`, `bundle-malformed`, `shared-helpers-missing`, `tenant-not-provisioned`, `atomic-rename-failed`, `non-rendered-target`), `agent_name_attempted`, `tenant_slug_attempted`
- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7

### 2.5 — Recruitment-domain vocabulary (8 codes)
Source: master brief §8.1 Change 3 lines 585-592

#### `ESC_VOICE_DRIFT`
- **Severity:** warn
- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `final_classifier_score`, `retry_count`, `agent_name`, `task_summary`

#### `ESC_DUPLICATE_DETECTED`
- **Severity:** warn — Janitor dedup needs human approval
- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
- **Phase:** `action`
- **Routing:** `operator_chat_id` via Telegram approval gate
- **Payload fields:** `candidate_a_id`, `candidate_b_id`, `confidence_score`, `match_basis` (e.g. `email+phone`, `name+email`, `phone+linkedin`)

#### `ESC_JSL_RED_FLAG`
- **Severity:** warn — Supply Chain Auditor (placeholder for v1.1+ JSL extension)
- **Trigger:** Supply Chain Auditor detected red flag (v1.0 placeholder; SCA agent in v1.1 backlog)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Status:** v1.0 placeholder; no agent fires this yet. Reserved name.

#### `ESC_BRIEF_AMBIGUITY`
- **Severity:** warn — Brief Decoder cannot confidently shortlist
- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
- **Phase:** `agent_handoff`
- **Routing:** `operator_chat_id`
- **Payload fields:** `brief_id`, `ambiguity_dimensions` (list of {`field`, `confidence`}), `proposed_clarifying_questions`

#### `ESC_PII_LEAKAGE_RISK`
- **Severity:** **blocking** — agent halts immediately, no retry
- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — potential GDPR incident
- **Payload fields:** `detected_pii_type` (one of `email`, `phone`, `name`, `address`, `nin`, `passport`), `boundary_violated` (the tenant_slug whose data leaked), `output_snippet_redacted_hash`
- **Recovery:** Agent restart required after operator review; founder must determine whether DPO notification is needed per UK GDPR Art. 33

#### `ESC_RATE_LIMIT_HIT`
- **Severity:** warn
- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `upstream` (e.g. `bullhorn`, `linkedin`, `reed`, `cv-library`), `retry_after_seconds`, `consecutive_429s`

#### `ESC_SCHEMA_VIOLATION`
- **Severity:** warn
- **Trigger:** Agent produced output violating vertical-schema.yaml field constraints (e.g. wrote an unknown enum value, missing required field). Detected at write-time by adapter validation
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `entity_type` (from vertical-schema.yaml entities), `field_violated`, `value_attempted`, `constraint_failed`

#### `ESC_VOICE_DRIFT_TENANT`
- **Severity:** warn (info-level — single-tenant pattern, not just one drift event)
- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (CSM may need to retrain voice corpus)
- **Payload fields:** `tenant_slug`, `drift_event_count`, `window_days`, `affected_agents` (list of agent_name)

#### `ESC_INPUT_VALIDATION_FAIL`
- **Severity:** warn
- **Trigger:** Agent rejected its input at the validation gate (e.g. malformed firm name, missing required CLI argument, brief description too short). Detected at Step 1 of the agent's workflow BEFORE any tool calls or LLM invocations
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `input_field`, `input_value_preview` (truncated to 80 chars), `validation_rule_violated`

#### `ESC_AGENT_OUTPUT_SHAPE`
- **Severity:** warn
- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `agent_name`, `output_path`, `shape_rule_violated`, `expected_value`, `actual_value`

### 2.6 — Cross-cutting infrastructure (6 codes)
Source: derived from operational discipline + sequencing-target §5

#### `ESC_HUMAN_EDITING_LOCK`
- **Severity:** info
- **Trigger:** Manual editing lock held by founder; agent backs off and reschedules
- **Phase:** `gating_failed`
- **Routing:** log-only (no Telegram noise)
- **Payload fields:** `vault_path`, `lock_age_seconds`

#### `ESC_VAULT_CONCURRENCY`
- **Severity:** warn
- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `vault_path`, `anomaly_class`, `freeform_reason`
- **Note:** Catch-all; specific codes preferred. New patterns may justify a new code.

#### `ESC_VAULT_RENAME_RACE`
- **Severity:** warn
- **Trigger:** Rename operation raced with another writer; per vault-concurrency §5
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `from_path`, `to_path`, `racing_writer_pid`

#### `ESC_CORTEXTOS_RESTART_REQUESTED`
- **Severity:** info
- **Trigger:** Agent self-requested restart per primitive 6 (`cortextos-ifos bus self-restart`) — typically post-degraded-mode recovery, post-context-overflow handoff
- **Phase:** `agent_handoff`
- **Routing:** log-only
- **Payload fields:** `reason`, `next_session_token`

#### `ESC_CORTEXTOS_HANDOFF`
- **Severity:** info
- **Trigger:** Context approaching `ctx_handoff_threshold` (default 80%); agent saves state and triggers fresh-session takeover per primitive 1+2 context-rotation
- **Phase:** `agent_handoff`
- **Routing:** log-only
- **Payload fields:** `from_session_id`, `context_pct`, `handoff_summary_path`

#### `ESC_CORTEXTOS_DEGRADED`
- **Severity:** warn
- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `reason` (e.g. `bullhorn_auth_failed`, `mcp_connector_unreachable`), `degraded_since`, `recovery_condition`

---

## §3 — Reserved codes (not-yet-wired)

These names are reserved by design documents but no agent fires them in v1.0. Listed here to prevent collision; do not invent codes overlapping these names.

| Code | Reserved by | Earliest agent |
|---|---|---|
| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |

---

## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)

`_shared/hook-helpers.sh` must:

1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)
3. Resolve `phase` from this catalogue's `Phase:` line (table-driven, not freeform)
4. Default `agent_name` to `${CTX_AGENT_NAME}` or `_renderer` (renderer-only sentinel)

The catalogue is read at process start via `_shared/escalation-codes-table.sh` (machine-readable companion; deferred to Phase 3 or first use, whichever lands first). If absent, helpers fall back to permissive write (log row only; no Telegram) + emit a one-shot operational warning.

---

## §5 — Change protocol

New codes added here BEFORE wiring into helpers + before any agent references them. Code names case-sensitive (`ESC_[A-Z][A-Z0-9_]*`).

The Codex Day-7 ratification queue includes this catalogue (item #20 placeholder per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1). Updates after ratification = new commit + Codex re-review of the diff.

*End of catalogue (24 active codes + 2 reserved).*
