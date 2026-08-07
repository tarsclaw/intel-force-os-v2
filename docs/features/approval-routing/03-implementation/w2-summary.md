# W2 — action-class registry + ESC codes + vault fixtures + holding reply

**Slice:** approval-routing PLAN W2 (architectural decisions 3, 4, 9)
**Built:** 2026-06-11 · branch `worktree-agent-aa7320163e4edb70d` off `b7e8d58`
**Gate:** `bash scripts/build-gate.sh` → **PASS** (shellcheck 60 files clean · 8 connector typecheck+vitest green · all 18 DB-backed fixture suites green, including the three concierge suites after the template addition)

## Deliverables

| # | Path | What |
|---|---|---|
| 1 | `agents/_shared/action-class-registry.yaml` | 53 rows, key-set-equal with `autosend-policy.yaml` (verified by set diff) |
| 2 | `agents/_shared/escalation-codes.md` §2.11 | `ESC_APPROVAL_ESCALATED_HOP`, `ESC_STANDING_APPROVAL_EXECUTED`, `ESC_SAFE_DEFAULT_SENT` (catalogue 52 → 55) |
| 3 | `agents/_shared/tests/fixtures/approval-routing/` | `function-roles.example.yaml` (§6.3 verbatim structure, boutique collapse), `identity-map.example.yaml`, `standing-approvals.example.yaml` |
| 4 | `agents/recruitment/concierge/templates/common-comms-templates.yaml` | `shared-holding-reply-candidate-v1` (§5.2 safe-default), smoke-rendered through `bin/render-concierge-draft.sh` |

## Seeded registry — full table for founder review

Legend: rule `RO` = record_owner, `F:x` = function_role:x · `esc` = escalation_after_minutes · `ttl` = ttl_minutes (∅ = null, hold indefinitely) · `exp` = on_expiry · `QH` = breaks_quiet_hours · `dig` = digest_eligible.

### Green tier → Bucket 1 (25 rows — resolver never consulted; rows for join completeness)

All green rows: bucket 1, esc ∅, ttl ∅, exp hold, QH false, dig false. Only `routing_rule` varies (audit/digest attribution per the owning agent's §4.1 class):

| action_type | rule | | action_type | rule |
|---|---|---|---|---|
| diagnostic_report_render | F:business_development | | consultant_feedback | RO |
| bullhorn_candidate_tag | F:ops_data | | validate_gate_a_fail | F:admin |
| bullhorn_note_internal | RO | | diagnostic_input_invalid | F:business_development |
| linkedin_profile_cache | RO | | diagnostic_generator_empty | F:business_development |
| xero_query_invoices | F:finance | | linkedin_cache_purge_fail | F:admin |
| bullhorn_brief_read | RO | | diagnostic_cleanup | F:business_development |
| operator_notify_telegram | F:admin | | xero_oauth | F:finance |
| janitor_run_complete | F:ops_data | | quickbooks_oauth | F:finance |
| scout_run_complete | RO | | open_banking_truelayer | F:finance |
| scribe_run_complete | RO | | open_banking_plaid_uk | F:finance **(dormant)** |
| concierge_run_complete | RO | | bullhorn_activity_log_write | RO |
| concierge_send_complete | RO | | cash_conductor_run_complete | F:finance |
| concierge_approval_routed | RO | | | |

### Yellow tier → Bucket 2 (10 rows — auto-sends with spot-check today)

All yellow rows: bucket 2, esc ∅, ttl ∅, exp hold, QH false, **dig true** (the pending cases — spot-check queue, Janitor dedup review-band holds — are async/low-urgency by design):

| action_type | rule | | action_type | rule |
|---|---|---|---|---|
| bullhorn_candidate_dedupe | F:ops_data | | xero_reminder_draft_internal | F:finance |
| bullhorn_field_backfill | F:ops_data | | bullhorn_note_draft_internal | RO |
| bullhorn_note_attach | F:ops_data | | bullhorn_scribe_field_write | RO |
| bullhorn_note_append_summary | RO | | accounting_reconciliation_write | F:finance |
| linkedin_connection_request | RO | | concierge_email_draft | RO |

### Orange tier (10 rows — the real routing consumers)

| action_type | rule | bucket | esc | ttl | exp | QH | dig |
|---|---|---|---|---|---|---|---|
| bullhorn_note_customer_visible | RO | 2 | 30 | 120 | hold | no | yes |
| gmail_outlook_send_to_candidate | RO | 2 | 30 | 120 | **safe_default** | **yes** | yes |
| twilio_sms_send | RO | 2 | 15 | 30 | **safe_default** | **yes** | no |
| calendar_invite_send | RO | 2 | 30 | 240 | hold | no | yes |
| email_summary_to_customer | RO | 3 | ∅ | ∅ | hold | no | yes |
| xero_reminder_send_customer | F:finance | 3 | ∅ | ∅ | hold | no | yes |
| diagnostic_email_send | F:business_development | 3 | ∅ | ∅ | hold | no | yes |
| diagnostic_calendar_invite | F:business_development | 3 | ∅ | ∅ | hold | no | yes |
| linkedin_inmail_send | RO | 3 | ∅ | ∅ | hold | no | yes |
| bullhorn_placement_terminate | F:ops_data | 3 | 1440 | ∅ | hold | no | yes |

### Red tier → Bucket 3, never graduates (8 rows — blocked before routing)

All red rows: bucket 3, esc ∅, ttl ∅, exp hold, QH false, dig false; standing-approval grants must refuse them. Rules: `xero_payment_initiate` + `stripe_charge_initiate` → F:finance; the other six (`subscription_modify`, `legal_document_generate`, `pii_export_outside_tenant_geography`, `cross_tenant_data_send`, `unauthorised_adapter_send`, `send_to_blocked_recipient`) → F:admin.

## Spec-derivation anchors (the non-judgement seeds)

- Candidate-ack column (§5.1): bucket 2, RO, desk-lead hop @30m, TTL 120m → `gmail_outlook_send_to_candidate` (+ on_expiry safe_default per §10 decision 1).
- Credit-note column (§5.1): bucket 3, F:finance, no chain, null TTL, hold, no QH break, morning digest → `xero_reminder_send_customer` and the bucket-3 digest_eligible=true pattern generally.
- §4.1 agent classes drive every routing_rule: Concierge/Scribe/Scout desk-bound → RO; Janitor → F:ops_data; Cash Conductor → F:finance.
- §2 buckets vs autosend tiers: green→1, yellow→2, orange split by candidate/client side, red→3.
- Graduation firm-admin-only (§10 decision 2) → documented in registry header + standing-approvals fixture; `auto_execute` seeded nowhere (runtime-only, post-graduation, §5.2 rule 2).

## seed-judgement calls (all marked inline in the registry)

1. **`bullhorn_candidate_tag` → Bucket 1, not 2.** Spec §2 lists "Janitor cleanup tags" as a Bucket-2 example, but the autosend tier is green (auto-sends, no review, reversible <30s) — the class already behaves past-graduation. Tier wins.
2. **Yellow rows `digest_eligible: true`.** §5.3 digest text covers Bucket-2 items; the yellow pending cases (spot-check, dedup review band) are explicitly async end-of-day per `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` — the digest is that batch.
3. **Diagnostic agent → F:business_development.** Diagnostic is absent from §4.1; it is the sales-stage agent, so its 6 classes (4 green + 2 orange) seed to the BD function.
4. **Cross-cutting `agent: all` audit classes → F:admin** (`operator_notify_telegram`, `validate_gate_a_fail`, `linkedin_cache_purge_fail`); `consultant_feedback` → RO (feedback attaches to the consultant's own artefact).
5. **`bullhorn_note_customer_visible` on_expiry hold, not safe_default.** A customer-visible CRM note is not a live email conversation; the holding-reply register doesn't fit a Note artefact. Nothing lost by holding.
6. **`twilio_sms_send` compressed cycle + safe_default + no digest.** SMS is the live-conversation channel §5.2 exists to protect; autosend timeout is PT30M → hop 15m / TTL 30m; a pending SMS is time-sensitive by definition so batching to 08:30 is wrong.
7. **`calendar_invite_send` hold @240m.** No holding-reply analogue for an attendee-notified invite; TTL mirrors the autosend PT4H timeout.
8. **`email_summary_to_customer` → Bucket 3, overriding Scribe's §4.1 default 2.** "Customer" = client; §2 is explicit that outbound-to-client always asks. The §4.1 Scribe bucket-2 default covers internal note-writing.
9. **`linkedin_inmail_send` → Bucket 3, overriding Scout's §4.1 default 1.** The §4.1 default covers the read-only sourcing pass; InMail is first-contact paid outreach with reputation effects — the §2 "first-contact … outreach" register.
10. **`bullhorn_placement_terminate` → Bucket 3 + 1440m hop, overriding Janitor's §4.1 default 2.** Commercial/legal implications (autosend reason) → always-asks; hop-to-founder after 24h mirrors §6.3 ops_data ttl so a stuck termination doesn't sit with one person forever.
11. **`diagnostic_email_send` QH false despite §6.3 seeding the BD function `breaks_quiet_hours: true`.** That flag exists for the v1.1 competitor-interception window; overnight prospect outreach is reputation risk, not opportunity.
12. **`gmail_outlook_send_to_candidate` QH true (static).** §5.1 says "yes if live conversation" — the registry is static per class, and this is the live-candidate-flow class the "Hudson by morning" pitch rides on; non-live instances are still digest_eligible.

## Deviations / flags

- **53 keys, not 47.** The PLAN (decision 4) and the `autosend-policy.yaml` invariant both say 47, but the policy file actually contains 53 action_types (post-freeze additions: 4 MCP OAuth rows, `bullhorn_activity_log_write`, `concierge_approval_routed`, plus the earlier run-complete/audit extensions). The registry keys off the **actual** file — set equality verified by diff — and documents the stale "47" in its header. The autosend-policy invariant comment itself was NOT corrected (outside the four W2 deliverable paths; flag for a later slice or Codex round).
- **Only one `dormant: true` row** (`open_banking_plaid_uk`). The other v1.1 agents (Client Hunter, Spec Pitcher, …) have no action_type keys registered in autosend-policy yet, so they cannot have registry rows under the join-key rule; a trailer comment in the registry says how to seed them when their keys land.
- **Worktree environment note:** first gate run failed tiers 2+3 with `tsc: command not found` — this fresh worktree had no `node_modules`. `pnpm install --frozen-lockfile` fixed it; no code change involved. Final gate: PASS.

## Queued for Codex ratification

- `agents/_shared/action-class-registry.yaml` (new substrate artefact)
- `agents/_shared/escalation-codes.md` diff (catalogue is a ratified artefact; updates require Codex re-review of the diff per its §5)
