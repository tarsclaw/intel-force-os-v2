# Spec 004 — Concierge build (LAST — most downstream)

**A sub-agent given ONLY this file + `agents/recruitment/concierge/agent.md` + the Cash Conductor
template + CLAUDE.md has everything it needs to build Concierge autonomously.**

- **Agent dir:** `agents/recruitment/concierge/` (cycle.sh 15-step + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures — SKELETON, ~16 TODO(W10-13) markers)
- **Master-plan source (READ IN FULL):** `agents/recruitment/concierge/agent.md`
- **Mirror template:** Cash Conductor — CC Step 8 render→vault (the chase draft) maps to Concierge Step 7; CC Step 10 autosend-bridge-telegram consumer (drafts-only/bridge branch) maps to Concierge Step 11; CC Gate A position-aware voice → Concierge Step 8.
- **Wave/tier:** v1.0 W10-13; the highest-stakes customer-facing comms agent. Largest ESC surface.

## 1. Scope
Replace the 16 TODO markers with live impl matching agent.md §3-§6: the 15-step lifecycle workflow
(webhook/poll/nurture), per-event comms drafts, the orange-tier approval+send path (D1-B), Gate A
(position-aware), and fixtures. **Concierge OWNS `gmail_outlook_send_to_candidate` — the
TRANSPORT row that Cash Conductor's orange `xero_reminder_send_customer` initiation hands off to.**

## 2. Upstream contract (CONSUMES — freeze on main first)
- `agents/_shared/` substrate — frozen.
- **autosend-policy action_types:** `concierge_email_draft` (yellow), `concierge_approval_routed`, `gmail_outlook_send_to_candidate` (orange), `bullhorn_note_customer_visible` (orange), `bullhorn_activity_log_write` (green), `concierge_send_complete`, `concierge_run_complete` (green). Verify each via grep.
- **Postgres:** `entities` (Bullhorn cache), `decision_log` (anti-duplicate query + audit), `tenant_adapters.config.concierge_last_poll`, `voice_corpus`. No new migration.
- **Connectors:** `@ifos/bullhorn` (read context + activity-log/state writes), Microsoft Graph / Gmail (email send), **`@ifos/autosend-bridge-telegram`** (D1-B approval shim — scaffold landed; PRODUCTION wiring is THIS build, see §8).
- **Vault:** tenant comms-template library `/vault/<slug>/concierge-templates/` + `shared/common-comms-templates.yaml` fallback.
- **Voice:** `hh_load_tone_rules` (∋ concierge) + `hh_load_voice_samples` (ANN on event_type).

## 3. Downstream contract (MUST EXPOSE)
- decision_log markers: `lifecycle_event_detected`, `anti_duplicate_check`, `bullhorn_context_fetched`, `addressee_resolved`, `template_selected`, `escalation_position_set`, `concierge_draft_rendered`, `concierge_sla_miss`, `pii_check_passed`, + action rows `concierge_email_draft`/`concierge_approval_routed`/`gmail_outlook_send_to_candidate`/`bullhorn_activity_log_write`/`concierge_send_complete`/`concierge_run_complete`.
- The orange `gmail_outlook_send_to_candidate` TRANSPORT row — the second half of the autosend chain Cash Conductor opens. Wiring this completes CC's send path too.

## 4. Workflow steps to wire (agent.md §4 — EVERY step)
| Step | What to implement | marker | ESC on fail | CC pattern |
|---|---|---|---|---|
| 0 | Session start (webhook/poll/cron-nurture); context.sh hydrate | `hh_decision_trigger session_start` | — | CC Step 0 |
| 1 | Source detection (parse webhook / poll / nurture-sweep) → 12-event taxonomy | `lifecycle_event_detected` | `ESC_LIFECYCLE_STATE_UNKNOWN` | CC Step 2 router |
| 2 | Anti-duplicate guard (decision_log query, 24h window) | `anti_duplicate_check` | skip if true dup | CC Step 6 idempotency (decision_log ledger) |
| 3 | Bullhorn context fetch (candidate/placement/client/contact) | `bullhorn_context_fetched` | `ESC_RATE_LIMIT_HIT`, `ESC_BULLHORN_AUTH`, `ESC_AGENT_OUTPUT_SHAPE` | CC Step 1/4 |
| 4 | **Addressee resolution (Gate A critical)** — recipient matches the changing candidate | `addressee_resolved` | `ESC_ADDRESSEE_MISMATCH` (blocking) | CC Gate A G1 contact |
| 5 | Comms-template selection (event×recipient_role; tenant→shared fallback) | `template_selected` | — | — |
| 6 | Sensitive-event escalation routing (rejection/withdrawal/high-value → position 3) | `escalation_position_set` | — | — |
| 7 | LLM draft → `/vault/<tenant>/concierge-drafts/<id>.md` | `concierge_draft_rendered` | `ESC_VOICE_DRIFT` (position threshold) | CC Step 8 render→vault |
| 8 | Voice+tone validation (position thresholds 0.75/0.78/0.82) → yellow draft row | (action) `concierge_email_draft` | `ESC_VOICE_DRIFT`, `ESC_TONE_RULE_VIOLATION` | CC Gate A G3 (position-aware) |
| 9 | SLA timing check (Gate B leading; >30min) | `concierge_sla_miss` | `ESC_CONCIERGE_SLA_MISS` (warn, aggregate) | CC Step 13 SLA |
| 10 | PII boundary check | `pii_check_passed` | `ESC_PII_LEAKAGE_RISK` (blocking) | CC Gate A G4 |
| 11 | Autosend-bridge routing (D1-B Telegram; orange approval) | `concierge_approval_routed` | `ESC_APPROVAL_BRIDGE_TIMEOUT` | CC Step 10 bridge consumer |
| 12 | Send execution (MS Graph/Gmail; BCC archive) — orange transport | `gmail_outlook_send_to_candidate` (orange) | `ESC_SEND_FAIL` (retry once) | — |
| 13 | Bullhorn activity-log write (green, audit) | `bullhorn_activity_log_write` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 |
| 14 | Lifecycle state advance (conditional Bullhorn write, per-tenant opt-in) | `concierge_send_complete` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 |
| 15 | Session close + Gate B (ghosted-rate, send-as-is, SLA) | `concierge_run_complete` (green) | `ESC_GATE_B_MISS` | CC Step 14 |

## 5. Gate A (validate.sh) — every check (agent.md §5)
| Check | Rule | ESC | Enforcement |
|---|---|---|---|
| voice | classifier ≥ position threshold (0.75/0.78/0.82) | `ESC_VOICE_DRIFT` | hard (warn-when-unscored) |
| addressee | recipient matches the changing candidate (no cross-addressing) | `ESC_ADDRESSEE_MISMATCH` (blocking) | hard |
| tone | no block-severity tone-rule violations | `ESC_TONE_RULE_VIOLATION` | hard |
| PII | none outside firm boundary | `ESC_PII_LEAKAGE_RISK` (blocking) | hard |
| anti-dup | Step 2 guard passed | (skip true dup) | hard |
| context | Bullhorn context complete (name + email present) | `ESC_AGENT_OUTPUT_SHAPE` | hard |
(30-min SLA is Gate B leading, NOT a Gate A hard-fail — per ADR-007.)

## 6. Acceptance criteria
- All §4 steps emit markers; all Gate A checks live; position-aware voice thresholds enforced.
- `bash scripts/build-gate.sh` green; new fixtures green; shellcheck CLEAN; RLS; boundaries; atomic commits; tree clean.

## 7. Test plan (deterministic fixtures)
- `scripts/run-concierge-gate-a-test.sh` — PASS + each fail class (addressee mismatch, tone, PII, missing-context) + position-threshold voice + ESC routes (register tenant; decision_log FK).
- `scripts/run-concierge-antidup-test.sh` — seed prior draft/send rows → assert the 24h anti-duplicate guard (true-dup skip vs fresh-allow).
- `scripts/run-concierge-routing-test.sh` — event_type → escalation_position (rejection/withdrawal/high-value → 3; else 1) + template selection.

## 8. Honest-scope flags (DOCUMENT, NEVER FAKE)
- **🔴 BULLHORN CREDS BLOCKED** (Steps 3/13/14) → build+fixtures only; live post-creds.
- **🔴 AUTOSEND-BRIDGE PRODUCTION WIRING IS THIS BUILD'S DELIVERABLE (W10-13).** The `@ifos/autosend-bridge-telegram` scaffold + CC consumer wiring exist, but the real Telegram Bot API + postgres approvals reader are NOT built — that's Steps 11-12's production wiring here. **Completing it unblocks BOTH Concierge sends AND Cash Conductor's drafts-only→orange-send path** (CC's `xero_reminder_send_customer` initiation currently halts at drafts-only because this bridge isn't live). Until done, Concierge runs drafts-only like CC.
- **🟡 EMAIL SEND (Step 12)** needs MS Graph / Gmail OAuth per tenant (founder/tenant onboarding) — live send is post-OAuth.
- Voice (Steps 7-8): empty `voice_corpus` → `unscored/no_corpus`, never faked.

## 9. Dependencies + sequencing
- **LAST agent.** Build independent parts (source detection, anti-dup, addressee resolution, templates, draft gen, Gate A, fixtures) in parallel; gate the orange send + bridge production wiring on the W10-13 autosend-bridge contract + Bullhorn creds + email OAuth.
- Blocked-for-live by: Bullhorn creds + autosend-bridge production wiring (this build) + email OAuth (all founder/build-gated). NOT blocked for the build of its independent parts + fixtures.
- Sequence after Janitor/Scribe/Sourcing-Scout prove the bundle pattern; the autosend-bridge wiring is the cross-cutting deliverable that also closes Cash Conductor's send loop.
