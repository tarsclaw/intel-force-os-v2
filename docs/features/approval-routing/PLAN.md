# Approval Routing + The Desk — build plan (FINAL)

## Context
Founder spec: `/Users/madsadmin/Downloads/ifos-approval-routing-architecture (1).md` (369 lines, authoritative — copy into `docs/specs/approval-routing-architecture.md` as commit #1). Core idea: approvals are **resolved from data the firm already maintains** (Bullhorn record ownership + M365 identity), never configured. One resolver ladder (record owner → function role → firm default), 3 trust buckets with a graduation gate (<2% override / 30 days → standing approval), TTL/escalation/quiet-hours/digest, a Teams Adaptive-Card approval surface, and **The Desk** — a foreground RAG chat agent over the tenant's second brain that is also the approval surface. Goal: clients feel they hold a product, and approve *less* over time.

Repo state: all six v1.0 agents merged 2026-06-11, gate PASS. The injectable autosend-bridge (Telegram transport + pg decision source + propose/await/record-decision CLIs) landed with Concierge. External creds unobtainable → everything below must be fixture-provable; live Teams/Graph proof is pilot-onboarding-gated.

**Founder decisions locked (2026-06-11):** all 7 spec-§10 recommendations adopted as defaults · HTTPS endpoint = Hetzner VPS + Let's Encrypt · The Desk = first slice of `packages/brain` · full W1→W8 sequence via the proven parallel worktree-worker method, Telegram digest interim.

## Architectural decisions (designed against verified machinery)
1. **`resolve_approver()` = new TS package `packages/utilities/approval-routing/`** mirroring the proven `autosend-bridge-telegram` shape (zero npm deps, injectable db/clock/files, `dist/bin/*.js` CLIs shelled from cycle.sh, `IFOS_ROUTING_FAKE` mode). Shell stays orchestrator.
2. **Backwards-compat invariant (hard):** missing resolver dist OR missing `/vault/{t}/routing/function-roles.yaml` OR any resolution failure → orange path behaves byte-for-byte as today (single operator via `CTX_OPERATOR_TELEGRAM_CHAT_ID`), logging `routing_fallback: single_operator`. The 6 merged agents' suites pass unmodified.
3. **Standing approvals = separate audited vault artefact** `/vault/{t}/_config/standing-approvals.yaml` (grants with evidence snapshot + revocation), consulted inside the orange branch of `hh_decision_action` BEFORE propose. Tier overrides stay elevation-only (`autosend_apply_tenant_override` untouched); red never short-circuits. Every grant/revoke writes a decision_log audit row.
4. **Action-class registry = `agents/_shared/action-class-registry.yaml`**, keyed by the SAME 47 action_type keys as `autosend-policy.yaml` (the join key). Per type: routing_rule (record_owner | function_role:<finance|ops_data|business_development|candidate_comms_default|client_comms_default|admin>), trust_bucket, escalation_after_minutes, ttl_minutes, on_expiry (hold|auto_execute|safe_default), breaks_quiet_hours, digest_eligible. Seeded from spec §4.1; v1.1 agents seeded `dormant: true`. Shipped, not configured.
5. **TTL/escalation/on-expiry extend the EXISTING blocking await** (`autosend_await_approval` + bridge `await.js` gains `--escalation-plan` json; hop re-proposes to next approver, same approval_id, first-valid-reply-wins). On-expiry branches live where Concierge Step 11 branches on `timeout` today. **Quiet-hours/digest = no daemon**: propose-time check (reuse `concierge_send_window` tenant_adapters key — already v0.4-allowlisted) → `held_for_digest` non-blocking row (+ immediate safe-default holding reply where classed); cron-invoked `build-digest.js` posts ONE owner-scoped digest per person at 08:30.
6. **Teams = two stages.** C1 (now, fixture-provable): `packages/utilities/approval-surface-teams/` — pure Adaptive-Card renderer (summary + opaque token + deep link ONLY; PII-absence asserted in tests; dual OpenUrl/Submit mode = bot-framework-ready), `TeamsTransport` implementing the bridge's injectable transport interface (`IFOS_TEAMS_FAKE`), **approve-by-link**: signed single-use HMAC tokens → ~50-line HTTPS handler → `record-decision.js`. Full round-trip provable with zero Microsoft creds. C2 (pilot-gated): Azure Bot registration + Bot Framework endpoint on the VPS + native Submit buttons + Teams-mobile push (runbook `docs/runbooks/teams-bot-provisioning.md`).
7. **The Desk = `packages/brain/` first slice** (retires ADR-002 backlog): `src/retrieval/` (entities + entity_links + decision_log + vault markdown; pgvector when present, lexical fallback; mandatory citation objects) + `src/desk/` (question → owner-scoped retrieval → Anthropic cite-or-decline answer; `IFOS_DESK_NO_LLM=1` deterministic templated mode for fixtures — CC precedent). Owner read-filter = the SAME resolver join exported from `@ifos/approval-routing` (spec §7). Approve-in-thread shells `record-decision.js`. Desk writes go through `hh_decision_action` — one trust model. v1 scoping: own records + firm-admin sees all (manager-sees-reports waits for Graph reporting line). CLI + Telegram thread first; Teams thread rides C2.
8. **Identity:** `/vault/{t}/routing/identity-map.yaml` ({bullhorn_user_id, m365_object_id, email, telegram_user_id, display_name, source}) + CSV/manual seed CLI now; `IdentitySource` interface lets a Graph email-match populator drop in later. Approval rows record `decided_by` envelope `{person_ref, transport, transport_user_id}` in payload jsonb (no migration; column semantics unchanged).
9. **§10 defaults land at:** safe-default for candidate acks → registry seed (W2) + bundled `holding_reply` template extending `agents/recruitment/concierge/templates/common-comms-templates.yaml` (tenant→shared→bundled chain). Firm-admin-only graduation → grant/revoke CLIs (W4). Deep-link edit → card renderer (W6). Record-ownership-wins + candidate-owner-approves-w/-AM-CC → ladder + card CC field. Confirm-in-Diagnostic → the function-roles populator emits a Diagnostic-style cited confirmation output as a standalone CLI until the onboarding wizard exists. Opinionated defaults, no config UI.

## Build sequence — 8 worktree-worker slices (proven parallel method, each: build-gate + review-subagent + Codex ≤2 rounds)
| Slice | Content | Depends | Parallel |
|---|---|---|---|
| W1 | `approval-routing` pkg: types, function-roles + identity-map loaders/validators, owner-lookup (RLS psql, reuse bridge `defaultRunPsql` pattern), §4 ladder pure fn, `resolve-approver.js` + `seed-identity-map.js` CLIs, vitest | — | W2 |
| W2 | `action-class-registry.yaml` seed + new ESC codes (ESC_APPROVAL_ESCALATED_HOP, ESC_STANDING_APPROVAL_EXECUTED, ESC_SAFE_DEFAULT_SENT) + vault schema fixtures + bundled holding-reply template | — | W1 |
| W3 | hook-helpers orange-path integration (resolve → recipient/plan/TTL into propose; audit payload {resolved_person_ref, ladder_step, reason}; fallback invariant) + bridge propose per-recipient param + fixture suites `run-routing-resolver-test.sh` + `run-routing-backcompat-test.sh` | W1,W2 | — |
| W4 | Graduation (`graduation-report.js` — override rate from decision_log) + `grant/revoke-standing-approval.js` (evidence-gated) + orange short-circuit + `run-trust-graduation-test.sh` | W3 | W5 |
| W5 | Chain-aware `await.js` + on-expiry branches in Concierge Step 11 / CC Step 10 + quiet-hours + `build-digest.js` + `run-escalation-expiry-test.sh` + `run-quiet-hours-digest-test.sh` | W3 | W4 |
| W6 | Teams C1: card renderer + TeamsTransport + approval tokens + link handler + endpoint binary + `run-teams-approval-test.sh` | W3 | W4/W5 |
| W7 | `packages/brain` retrieval + citations + owner scoping + `run-desk-scoping-test.sh` | W1 | W6 |
| W8 | Desk chat loop + approve-in-thread + `run-desk-citation-test.sh` + live-LLM smoke (non-gating) | W5,W7 | — |
| Gated | C2 bot endpoint + live Graph posting + VPS TLS ops session + Teams-mobile push | pilot/founder | — |

Critical path W1→W3→W5→W8; three parallel pairs. New `run-*-test.sh` suites are auto-discovered by the hardened `scripts/build-gate.sh`.

## Critical files
- Modify: `agents/_shared/hook-helpers.sh` (orange branch of `hh_decision_action`, ~line 219-290), `packages/utilities/autosend-bridge-telegram/src/types.ts` + `bin/await.ts` + `bin/record-decision.ts` (--reject-reason + person_ref envelope), `agents/recruitment/concierge/cycle.sh` Step 11 + `agents/recruitment/cash-conductor/cycle.sh` Step 10 (on-expiry branches), `agents/_shared/escalation-codes.md`, `agents/recruitment/concierge/templates/common-comms-templates.yaml`.
- New: `packages/utilities/approval-routing/`, `packages/utilities/approval-surface-teams/`, `packages/brain/`, `agents/_shared/action-class-registry.yaml`, vault schemas `routing/function-roles.yaml` + `routing/identity-map.yaml` + `_config/standing-approvals.yaml`, `docs/specs/approval-routing-architecture.md` (the spec, committed), `docs/runbooks/teams-bot-provisioning.md`.
- Reused as-is: `record-decision.js` (single decision writer all transports converge on), `_hh_emit_row` audit, `createPostgresDecisionSource`, template-resolution chain, `concierge_send_window` config key, registered-throwaway-tenant fixture pattern.

## Verification
Per slice: vitest green + shellcheck + the slice's DB-backed fixture suite(s) + full `bash scripts/build-gate.sh` PASS (now hard-requires the dev DB) + review-subagent PASS + Codex ratification (≤2 rounds, trail recorded). System-level proofs: (1) backcompat suite proves the 6 merged agents are byte-identical without routing files; (2) Teams round-trip (card → signed link → decision row → await resolves) proven with zero live creds; (3) Desk scoping adversarial fixtures prove owner A never reads owner B + cross-tenant isolation; (4) graduation provably evidence-gated, demotion-via-override still impossible, red never short-circuits. Live-gated remainder documented per runbook: VPS TLS, Azure bot, real Graph posting, Teams mobile push.

## Open items for founder DURING build (none block start)
- VPS TLS ops session (blocks live link-mode buttons only).
- Confirm Telegram digest is acceptable for pilot demos until Teams C2.
- First split-desk prospect re-confirms §10.4/§10.5 (record-ownership-wins; candidate-owner + AM CC).
- `decided_by` envelope: grep showed only bridge consumers parse it today — flagged at review if anything new appears.

---

## Remaining-build backlog AFTER this plan (transparency)
**A. Blocking first pilot deployment:**
1. **Runtime/activation** — no agent has ever been rendered/activated as a daemon; no scheduler/trigger wiring (Janitor nightly cron, Scribe poll, Concierge poll); `packages/agent-renderer` unproven CLI; PM2 ecosystem generation unbuilt. (The cron entries this plan adds for digest are a start.)
2. **Onboarding wizard** — `packages/onboarding-wizard/` zero implementation (5-day flow specced, PRODUCT-SPEC §5.2). This plan's identity-map seeding + function-roles confirmation become Day-2/Day-4 wizard steps when it's built.
3. **Email send transport** (Concierge Step 12 / MS Graph or Gmail connector) — greenfield; degraded-no-transport today. Natural follow-on to the Teams/Graph work in this plan.
4. **Brain v1.0 remainder** — W7 builds retrieval; the 9 `wiki-*.sh` wrappers + ingest/compile/reflect/lint modules remain.
5. **Granola live transport verify** (token + ≥1 meeting, pilot-gated).
**B. Quality/uplift:** voice classifier microservice (+ drift cron); `_shared` fuzzy-matcher extraction; Concierge's 4 named bullhorn-CLI extensions (incl. Placement read, list-state-changes/nurture-due — partly needed for real lifecycle polling).
**C. Founder-gated:** pilot-supplied creds at onboarding (Bullhorn/Reed/CV-Library/Granola/Telegram/M365); v0.5 migration → prod VPS; 4 autosend-policy registrations; agent.md §10 status flips + Codex sign-offs; DKIM/DMARC records; pilot LOI.
**D. v1.1+ (explicit deferrals):** 7 v1.1 agents (Inbound Triage, Brief Decoder, Night Sourcer, Competitor Interception, Client Hunter, Supply Chain Auditor, Compliance Watchtower), 5 v1.2 agents, LoRA pipeline (v2.0), WhatsApp/Slack adapters, territory tags, Brain web UI.
