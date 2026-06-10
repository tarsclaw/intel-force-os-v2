# Concierge — W10-13 implementation summary

**Branch:** `worktree-agent-a4d7fb0c8ae47cca6` (based on main @ `05f6668`)
**Date:** 2026-06-10. **Spec:** `docs/features/agent-build/02-specs/spec-004-concierge.md`.
**Build gate:** `bash scripts/build-gate.sh` → **PASS** (shellcheck CLEAN 40 files; 4 connector suites green; 9 fixture suites green incl. the 3 new concierge suites).

## Headline deliverable — autosend-bridge production wiring

`@ifos/autosend-bridge-telegram` production wiring LANDED (also unblocks Cash
Conductor's drafts-only→orange-send path; no CC files touched):

| Piece | State |
|---|---|
| `src/transport-telegram.ts` | REAL Telegram Bot API `sendMessage` over fetch; token never logged/echoed; ok:false + non-2xx + network failures all throw (never a silent approve) |
| `src/decisions-postgres.ts` | Postgres approvals reader — RLS-scoped over `decision_log` rows (`agent_name='autosend-bridge'`). **No new `approvals` table** (spec-004 §2 "no new migration"); decisions live in the same append-only audit substrate. Zero npm deps (psql via execFile; injectable `runPsql`) |
| `dist/bin/{propose,await,record-decision}.js` | CLI entrypoints — the cycle.sh shell contract (Concierge Step 11 + CC Step 10). `IFOS_BRIDGE_FAKE=approve\|reject\|timeout` deterministic fixture mode |
| `record-decision` | Single writer; first-valid-reply-wins (NOT EXISTS guard); the future `@ifos/telegram-surface` `/approve`–`/reject` handler calls this same CLI (its reconciliation point) |
| Tests | 34 vitest green (11 new, all offline: fetch-mocked transport incl. token-non-leak; psql-mocked reader); typecheck now covers `bin/` |

**Still gated (honest):** (1) the Telegram `/approve`–`/reject` command handler
is `@ifos/telegram-surface` scope — NOT built; until it lands, operator
decisions are recorded via `record-decision.js`. (2) `TELEGRAM_BOT_TOKEN` is
EMPTY in the dev sandbox (names-only check, 2026-06-10) → **no live Bot API
call was made** (no getMe; the transport is fetch-mock-tested only).

## Per-step status (cycle.sh; spec-004 §4)

| Step | State | Notes |
|---|---|---|
| 0 session start | LIVE | trigger row |
| 1 source detection | LIVE | webhook (CTX_WEBHOOK_PAYLOAD) / poll (bh-bridge `list-state-changes` since `concierge_last_poll`) / nurture (`list-nurture-due`); 12-event taxonomy gate → `ESC_LIFECYCLE_STATE_UNKNOWN` warn+skip. **v1.0 scope: one event per run** (poll cadence drains the queue; queue_depth reported) |
| 2 anti-dup guard | LIVE | 24h decision_log ledger; Q7: found+sent=skip, found+unsent=allow; suite-proven incl. window edge |
| 3 context fetch | LIVE (fixture-mode) | via `bin/bh-bridge.sh` (entities cache); missing name/email → `ESC_AGENT_OUTPUT_SHAPE` + abort. Live Bullhorn gated (creds EMPTY; connector on Janitor branch) |
| 4 addressee resolution | LIVE | `ESC_ADDRESSEE_MISMATCH` blocking; adversarial path via `IFOS_FORCE_RECIPIENT_EMAIL` |
| 5 template selection | LIVE | tenant `.md` → vault `shared/common-comms-templates.yaml` → bundled canonical (shipped, 12 events + 4 client_contact variants); 3-stage fallback suite-proven |
| 6 escalation routing | LIVE | rejection/withdrawal→3; on-hold>£10k→3 (placement_value); placement-positive/status→2; else 1; 10 routes suite-proven |
| 7 LLM draft → vault | LIVE | deterministic templated render (0600, metadata-only decision row per ADR-002); LLM polish active when ANTHROPIC_API_KEY set (+verified live once: `draft_generator: llm`); fixtures force `IFOS_CONCIERGE_NO_LLM=1` |
| 8 voice+tone validation | LIVE | validate.sh gate → yellow `concierge_email_draft` row |
| 9 SLA check | LIVE | >30 min → `concierge_sla_miss` marker + `ESC_CONCIERGE_SLA_MISS` warn; **Gate B leading, never blocks (ADR-007)** |
| 10 PII check | LIVE | `pii_check_passed` marker; blocking on hit |
| 11 bridge routing | LIVE | propose → `concierge_approval_routed` row → await; approved→12; rejected→`approval_rejected`+graceful close; timeout→`ESC_APPROVAL_BRIDGE_TIMEOUT`+exit 1; drafts-only (D1-C) when dist/operator-chat/bot-token missing. All four branches smoke-verified |
| 12 orange send | LIVE chain, gated transport | bridge approval pre-resolves the hook-helpers orange gate (no double-approval); orange `gmail_outlook_send_to_candidate` row emitted; transport = `IFOS_FORCE_SEND_RESULT` (fixtures) or future MS Graph/Gmail connector CLI (OAuth ABSENT → honest `send_degraded_no_transport`); `ESC_SEND_FAIL` after 1 retry |
| 13 activity-log write | LIVE (fixture-mode) | `bullhorn_activity_log_write` green row via bh-bridge |
| 14 state advance | LIVE, opt-in OFF | conditional patch-state via bh-bridge; `concierge_send_complete` always emitted. Opt-in via `IFOS_FORCE_STATE_ADVANCE` only — see deviation 3 |
| 15 close + Gate B | LIVE | ghosted-rate SQL (>5% → `ESC_GATE_B_MISS`); `concierge_last_poll` cursor stamp; `concierge_run_complete` green |

Gate A (validate.sh): all 6 spec-004 §5 checks live (G1 voice position
thresholds 0.75/0.78/0.82 hard on numeric scores, unscored warn-and-pass;
G2 addressee vs entities incl. client_contact collision check; G3 tone —
tenant `tone_rule` block-severity `examples_negative` + agent.md §7 built-ins;
G4 PII boundary; G5 anti-dup race re-check; G6 context completeness), with
dominant-ESC routing + `validate_gate_a_fail` row + `/tmp` quarantine.

## Fixture/suite results (deterministic, DB-backed; build-gate auto-discovered)

| Suite | Result |
|---|---|
| `run-concierge-gate-a-test.sh` | GREEN — 15 assertions (3 pass paths, 4 position-threshold voice cases, addressee/tone×2/PII/missing-context + ESC routes) |
| `run-concierge-antidup-test.sh` | GREEN — 9 assertions (true-dup skip / Q7 fresh-allow / 24h window) |
| `run-concierge-routing-test.sh` | GREEN — 15 assertions (10 position routes, 3-stage template fallback, taxonomy gate, addressee ESC) |
| bridge package vitest | GREEN — 34 tests (+ typecheck) |
| Full-chain smokes | happy path (16 audit rows incl. orange transport), timeout (exit 1 + ESC), rejected, drafts-only — all verified on dev DB |

## Numbered deviations

1. **One event per run** (Step 1). agent.md poll/nurture imply batch
   processing; v1.0 processes the first pending event and reports
   `queue_depth` — the 5-min poll cadence drains the rest. Multi-event loop is
   a straightforward W14+ enhancement; documented in cycle.sh header.
2. **client_contact drafts not generated** (events 5/9/11/12 name "Candidate +
   Client separate drafts"). v1.0 generates the candidate draft;
   client_contact templates ARE shipped and template selection + G2 collision
   logic handle the role, but cycle.sh does not yet emit a second draft per
   event. Spec-004 §4's addressee contract ("recipient matches the changing
   candidate") is fully met.
3. **Step 14 opt-in key not in tenant_adapters** — `concierge_state_advance_enabled`
   is not in the v0.4 allowlist; writing it would hard-fail the validator.
   Schema-before-code: opt-in defaults OFF, fixture override via
   `IFOS_FORCE_STATE_ADVANCE=1`; a v0.5 supplement adds the key.
4. **Approvals stored in decision_log, not a new `approvals` table** — spec §2
   says "No new migration"; the D1-B doc says the audit chain is decision_log.
   Reader/writer documented in `src/decisions-postgres.ts`.
5. **Fixture YAML test surface aligned to implementation** — fixture 99's
   skeleton-era `test_mode_overrides` (forced approval_id) replaced by the
   implemented `IFOS_BRIDGE_FAKE=timeout`; `bullhorn_activity_logged` output
   marker renamed to the spec-004 §3 `bullhorn_activity_log_write` action row.
6. **Step 11 propose-transport failure path** routes to drafts-only with an
   explicit marker rather than a dedicated ESC (no concierge-scoped transport
   ESC exists in the catalogue; adding one is a catalogue amendment).

## Honest-scope (never faked)

- Bullhorn creds EMPTY + connector CLI unmerged → fixture mode throughout;
  `bin/bh-bridge.sh` header documents the exact CLI surface (get-candidate /
  -placement / -client / -contact, create-activity-log, patch-state,
  list-state-changes, list-nurture-due) — the single reconciliation point.
- MS Graph / Gmail OAuth absent → no live email send anywhere.
- TELEGRAM_BOT_TOKEN EMPTY → no live Telegram call (no getMe run).
- No voice classifier in v1.0 → `unscored/no_classifier`, warn-and-pass;
  thresholds hard-enforce on real numeric scores only.
- `concierge_cleanup` unregistered → cleanup.sh emits `hh_decision_output`
  (future_registration noted in tools.yaml).
- agent.md untouched (status flip founder-gated).

## Queued for Codex ratification

Concierge bundle (cycle/validate/context/cleanup/tools + bins + templates +
fixtures + 3 suites) + autosend-bridge-telegram production wiring, via
`review-agent-bundle.md`.

## Round-2 combined fix pass (2026-06-10)

Combined fix pass after review round 1 (`04-reviews/review-concierge.md`) +
Codex session `20260610T142308Z-65963` (REJECTED:4, all agent.md). Three
atomic commits on this branch:

1. **`10dfc07` agent.md honesty pass** (Codex 1-4 + reviewer finding 2 +
   deviation-2 recording): all "awaits D1" language + §9 Q1 removed (D1
   ACCEPTED 2026-05-31; Q2-Q10 numbering retained for stable §10
   cross-references); header + reading-discipline note + §5 honesty note +
   §8 rows + §10 updated to the W10-13 LIVE/BUILT bundle state
   (fixture-proven only; zero live Bullhorn/Telegram/email; /approve handler
   = @ifos/telegram-surface scope); §4 Step 2 doc query corrected to
   `payload->>'action_type'` / `payload->>'target'` equality (implementation
   was already correct); v0.4 supplement moved to satisfied dependency
   (landed 2026-06-03, `a1bbcf6`); reviewer deviation 2 (client_contact
   second drafts not generated, events 5/9/11/12, W14+ path) recorded in §3.
   §10 status field NOT flipped (founder-gated).
2. **`997226d` bh-bridge.sh reconciliation** (reviewer finding 1) to the
   agreed CLI contract + Janitor's actual `cli.ts`: network-free `check-auth`
   mode resolution (not-provisioned → refresh reason `unavailable`, NO ESC;
   provisioned-but-failed refresh → `failed` → context.sh fires
   ESC_BULLHORN_AUTH); agreed refresh shape `{ok, oauth_expires_at_ms,
   token_state}` carried verbatim into CTX_BULLHORN_TOKEN_STATE; live
   context fetches via existing `list-*` with shim-side id filter;
   `create-activity-log` → `create-note --entity-type/--entity-id/
   --body-file --action` (note_id parsed); `patch-state` → `update-entity
   --patch {"status":...}` ({ok,updated} parsed); IFOS_TOKEN_DIR + numeric-id
   live requirement documented; 4 REQUIRED CONNECTOR EXTENSIONS named in the
   shim header (get-by-id convenience, Placement read, list-state-changes,
   list-nurture-due — served honestly from the entities cache, none
   invented). Fixture mode unchanged (the proven path).
3. **`b5bf167` catalogue-honest ESC + vault default + gap note** (reviewer
   findings 3/4/5/6): ESC_RENDERER_FAILED → ESC_AGENT_OUTPUT_SHAPE at the
   Step-7 render-failure path; IFOS_VAULT_ROOT default unified to `/vault`
   (hook-helpers contract); Step 12 KNOWN-GAP comment — orange row emitted
   pre-transport, emit-on-confirmed-send (or correction row) required when
   the live email connector lands; phantom ESC_AGENT_TOOL_FAILURE removed
   from tools.yaml + cycle.sh comment + transport-telegram.ts header;
   ESC_TONE_RULE_VIOLATION aligned to catalogue (warn / operator_chat_id);
   tenant-admin routing notes dropped per agent.md §6.

Verification: shellcheck clean across the bundle; bridge typecheck clean +
34/34 vitest offline; all 3 concierge DB suites green; full build-gate PASS
re-run after the pass. Honest scope unchanged: fixture-proven only — live
Bullhorn/Telegram/email remain unexercised (creds/tokens EMPTY,
founder-gated). Post-merge follow-ups (tracked in STATUS): the 4 named
connector extensions + email-connector emit-on-confirmed-send.
