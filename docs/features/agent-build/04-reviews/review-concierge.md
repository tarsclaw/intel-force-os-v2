# Review — Concierge (spec-004) — Round 1

**Verdict: PASS** (review sub-agent, 2026-06-10) · branch `worktree-agent-a4d7fb0c8ae47cca6` (8 commits over `05f6668`) · merge-ready pending the two MAJORs below (both on the established fix-pass track; neither a spec-004 §6 gate hole).
**Codex round 1 (session `20260610T142308Z-65963`): REJECTED:4 — all agent.md stale-contract findings** (D1 still "awaited" though accepted 2026-05-31; scaffold prose vs LIVE bundle; §4 Step 2 documents a top-level-column decision_log query while the implementation already correctly uses `payload->>`; v0.4 supplement misclassified as pending though landed `a1bbcf6`).

## Findings
1. **MAJOR** `bin/bh-bridge.sh` — live-passthrough branch NOT reconciled to the agreed CLI contract + Janitor's actual CLI (expected; the shim is the declared reconciliation point; live mode double-gated today). Mismatches: no `check-auth` probe usage (a real auth failure would map to `degraded` and never fire ESC_BULLHORN_AUTH); stale refresh shape; `get-candidate/get-placement/get-client/get-contact` don't exist (only `list-*`; **no Placement read at all**); `create-activity-log` → must map to `create-note --action`; `patch-state` → must map to `update-entity`; `list-state-changes`/`list-nurture-due` have NO connector equivalent (genuinely new surface — connector extension required); `IFOS_TOKEN_DIR` undocumented; numeric-id live requirement unstated.
2. **MAJOR** `agent.md` materially stale (= Codex's 4 findings) — honesty pass owed; status flip stays founder-gated. Deviation 2's recipient narrowing must be recorded there too.
3. **MINOR** `cycle.sh:469` fires `ESC_RENDERER_FAILED` (catalogue-reserved for the `_renderer` sentinel) for a draft-render failure → use `ESC_AGENT_OUTPUT_SHAPE`.
4. **MINOR** `cycle.sh:448` vs `:666` — two different `IFOS_VAULT_ROOT` defaults in one script (hook-helpers uses `/vault`).
5. **MINOR** orange `gmail_outlook_send_to_candidate` row emitted before transport executes — fix (emit-on-confirmed or correction row) when the email connector lands; honest today (only reachable success path is forced).
6. **ADVISORY** tools.yaml skeleton drift: phantom `ESC_AGENT_TOOL_FAILURE` (not in catalogue; repeated in transport-telegram.ts header), tone-violation routing/severity vs catalogue, "tenant-admin" routing agent.md excludes.
7. **ADVISORY** PII scan email-domain-only (but FULL-body + blocking — the Scribe-F1 class was avoided); deepen W14+.

## Deviations — all 6 ACCEPTED
(1) one-event-per-run · (2) client_contact second drafts not generated (declared; record in agent.md) · (3) Step-14 opt-in env-only (schema-before-code) · (4) approvals as decision_log rows, no new table (spec mandate) · (5) fixture YAML aligned to implementation · (6) propose-transport failure → drafts-only fail-safe.

## Bridge-wiring verdict (verified first-hand)
**REAL:** genuine Bot API sendMessage (token never logged/leaked — throw sites read; 403 + network paths assert non-leakage); fail-closed on every non-2xx/non-JSON/network error; Postgres decision source with RLS `SET LOCAL` in FETCH and RECORD, execFile + `-v` vars (no interpolation), race-safe NOT-EXISTS; 3 CLIs in dist/bin; `IFOS_BRIDGE_FAKE` fixture mode; typecheck clean; **34/34 vitest offline**; TELEGRAM_BOT_TOKEN EMPTY → zero live calls anywhere. **Gated:** live Bot API unexercised; `/approve`-`/reject` handler = `@ifos/telegram-surface` scope (`record-decision.js` is the single writer it will call).

## Test evidence (reviewer-run)
build-gate **PASS** (shellcheck ×40; 4 connector suites; 9/9 DB suites) · gate-a 11 cases + 7 ESC routes · antidup 9 · routing 15 · 4 independent full-chain smokes (approved+send → exactly 1 orange row; degraded/timeout/drafts-only → 0 orange) · 8 atomic commits w/ footer · all 15 §3 markers · all 7 action_types registered; `concierge_cleanup` on `hh_decision_output` · zero out-of-scope edits (27-file diff) · drafts 0600/0700 · blocking addressee + PII gates proven.

## Disposition
Combined fix pass (Codex 1-4 + findings 1/3/4/6 + deviation-2 recording) → final Codex run → merge proposal. The `list-state-changes`/`list-nurture-due` connector extension + email-connector emit-on-confirmed are post-merge follow-ups tracked in STATUS.

## Closure (2026-06-10)
Review **PASS** → combined fix pass (`10dfc07`/`997226d`/`b5bf167`/`78ad4e0`: agent.md honesty + bh-bridge reconciliation to Janitor's actual CLI w/ 4 named connector extensions + catalogue-honest ESC usage) → final Codex run (session `20260610T154203Z-26445`) REJECTED:3 → incorporated post-run (`acc5805`/`aea658b`/`1f501dd`): both missing ESC table rows + the Step-12 transport-truth contract (orange row stays pre-transport as the policy-authorization record — `hh_decision_action`'s orange path FUSES gating with emission in frozen `_shared/`, so emit-after-send was impossible honestly; `send_attempt`/`send_confirmed`/`send_failed`-correction output rows carry delivery truth; smoke-verified: happy = exactly 1 orange + confirmed; drafts-only/timeout = 0 orange). Codex trail **4→3**, loop closed at the ≤2-round ceiling. **PROPOSED FOR FOUNDER MERGE @ `1f501dd`.**
