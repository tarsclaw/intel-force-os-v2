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

## §2 — Catalogue (52 codes)

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

### 2.5 — Recruitment-domain vocabulary (10 codes)
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

### 2.7 — Upstream provider auth (8 codes)
Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)

#### `ESC_REED_AUTH`
- **Severity:** **blocking** — agent enters degraded mode (cached search results only)
- **Trigger:** Reed jobs-board API OAuth token refresh failed twice OR REST call returned 401 indefinitely
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `failure_type` (`refresh_failed` | `revoked_401`), `last_attempt_at`, `consecutive_failures`
- **Recovery:** founder rotates Reed API key via Reed admin → `_secrets.env` reload

#### `ESC_CVLIBRARY_AUTH`
- **Severity:** **blocking** — agent degraded (cached search only)
- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `failure_type`, `last_attempt_at`, `consecutive_failures`
- **Recovery:** founder rotates CV-Library credentials

#### `ESC_LINKEDIN_AUTH`
- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
- **Trigger:** LinkedIn session cookie / OAuth token revoked or expired (LinkedIn has aggressive anti-bot session invalidation)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `failure_type` (`session_expired` | `bot_detected_999` | `revoked_401`), `last_attempt_at`
- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow

#### `ESC_GMAIL_AUTH`
- **Severity:** **blocking** — Concierge cannot send candidate emails; falls back to draft-only
- **Trigger:** Google Workspace OAuth token refresh failed; Gmail send returns 401
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
- **Recovery:** founder reauthenticates Google Workspace OAuth

#### `ESC_MS_GRAPH_AUTH`
- **Severity:** **blocking** — Concierge Outlook send disabled; drafts-only
- **Trigger:** Microsoft Graph OAuth refresh failed; Outlook sendMail returns 401
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
- **Recovery:** founder reauthenticates MS Graph OAuth

#### `ESC_ACCOUNTING_AUTH`
- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `provider` (`xero` | `quickbooks` | `freeagent`), `failure_type`, `last_attempt_at`
- **Recovery:** founder reauthenticates accounting OAuth

#### `ESC_OPEN_BANKING_AUTH`
- **Severity:** **blocking** — Cash Conductor cannot fetch latest bank-feed; falls back to last-known balance
- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `failure_type` (`consent_expired_90d` | `refresh_failed`), `consent_expires_at`, `bank_provider`
- **Recovery:** founder completes Open Banking SCA reauthentication flow

#### `ESC_OPEN_BANKING_TOKEN_AGING`
- **Severity:** staged — info → warn → blocking as expiry approaches (per Cash Conductor agent.md §6)
- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
  - **≤30 days remaining:** info — non-urgent operator awareness; nightly health check emits this
  - **≤14 days remaining:** warn — operator nudge to schedule reauth this week
  - **≤7 days remaining:** blocking — Cash Conductor enters degraded mode (cached balance only; no fresh bank-feed reads); operator must complete SCA reauth before token expires
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` (info + warn stages); ADD `ifos_oncall_chat_id` at blocking stage
- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`, `stage` (`info` | `warn` | `blocking`)
- **Recovery:** founder schedules + completes Open Banking SCA reauth via tenant's bank login

### 2.8 — Provider read/write failures (4 codes)
Source: derived from v1.0 agent.md adapter call sites

#### `ESC_BULLHORN_WRITE_FAIL`
- **Severity:** warn
- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `endpoint`, `entity_type`, `entity_id`, `status_code`, `error_body_preview` (truncated 120 chars)

#### `ESC_ACCOUNTING_WRITE_FAIL`
- **Severity:** warn
- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`

#### `ESC_PROVIDER_FETCH_FAIL`
- **Severity:** warn
- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`

#### `ESC_SEND_FAIL`
- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer
- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `channel` (`gmail` | `outlook` | `twilio` | `telegram`), `recipient_id_hash`, `error_class`, `attempts_made`

### 2.9 — Auto-send orchestration (4 codes)
Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics

#### `ESC_AUTOSEND_ORANGE_PENDING`
- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
- **Phase:** `action`
- **Routing:** `operator_chat_id` (gentle reminder; no oncall)
- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`

#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
- **Severity:** warn — orange action's approval window expired without response
- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
- **Recovery:** action converts to manual reconciliation; operator handles offline

#### `ESC_AUTOSEND_RACE`
- **Severity:** warn — concurrency / state-change race
- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
  - **Duplicate-payload race:** two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict; second wins-suppressed (first sends; idempotency by payload_hash)
  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
- **Recovery:** duplicate → second suppressed; state-change → cancelled draft logged; no operator action required beyond informational review

#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
- **Severity:** info — quality sampling, not a failure
- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
- **Phase:** `action`
- **Routing:** `operator_chat_id`; sampled action is queued in `spot_check_queue_path` (`/vault/{tenant_slug}/spot-checks/`)
- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
- **Note:** Operator review of sampled rows is asynchronous (typically end-of-day batch); no SLA timer.

### 2.10 — Agent workflow (10 codes)
Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge

#### `ESC_GATE_B_MISS`
- **Severity:** warn — post-send quality signal; not a hard failure
- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `agent_name`, `metric_name`, `actual_value`, `threshold`, `window`, `sample_size`
- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).

#### `ESC_TONE_RULE_VIOLATION`
- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review

#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
- **Severity:** warn
- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`

#### `ESC_CANDIDATE_DATA_INCOMPLETE`
- **Severity:** warn
- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `candidate_id`, `missing_fields` (list), `shortlist_id`, `brief_id`

#### `ESC_ADDRESSEE_MISMATCH`
- **Severity:** **blocking** — outbound send refused (whichever agent firing)
- **Trigger:** Outbound recipient resolution failed — addressee does not match the entity whose lifecycle/event triggered the send. Two canonical use cases:
  - **Cash Conductor:** chase/reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure between accounting + ATS)
  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
- **Recovery:** operator reviews; either reconciles manually OR updates one system to match

#### `ESC_RECONCILIATION_AMBIGUOUS`
- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `payment_id`, `amount`, `payee_name_raw`, `candidate_invoice_ids` (list), `match_basis` (e.g. `amount_only`, `payee_partial`)

#### `ESC_DNC_FILTER_HIT`
- **Severity:** **blocking** — outbound (email / SMS / call) refused
- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`

#### `ESC_CONCIERGE_SLA_MISS`
- **Severity:** warn — aggregated to Gate B (not a per-event block)
- **Trigger:** Concierge SLA breached. Three canonical sla_types:
  - `brief_ack`: inbound brief not acknowledged within 4h (default)
  - `customer_reply`: customer reply not actioned within 24h (default)
  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `brief_id` or `candidate_bullhorn_id` or `lifecycle_event_id` (per sla_type), `sla_type` (one of the three above), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`

#### `ESC_SCRIBE_SLA_MISS`
- **Severity:** warn
- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `call_id`, `sla_type` (`summary_render` | `note_attach`), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`

#### `ESC_LIFECYCLE_STATE_UNKNOWN`
- **Severity:** warn — agent cannot determine entity state for downstream action
- **Trigger:** Lifecycle state is ambiguous or outside the agent's known taxonomy. Two canonical use cases:
  - **Janitor:** placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields

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

*End of catalogue (52 active codes + 2 reserved).*
