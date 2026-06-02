# Current priorities

**Week:** Week 4 — **Day 26 / closed FOUR TIMES (2026-06-01) — morning + afternoon + evening + evening-2 (Codex F-R1 fix bundle) autonomous /goal runs**

**Latest:** Evening-4 autonomous fix bundle after founder R3 trigger (session 20260602T105413Z-29512) — xero RATIFIED ✓; QB + OB remained rejected; founder authorized R4 via /goal continuation. Closed all 6 R3 issues across 2 fix commits + 1 disagreement decision-doc: (a) f9e85d8 QB — fixed package.json description step list (1,4,5,6,9 not 4-6+10-11); COUNTER-ARGUED concurrent-throttle issue via codex-disagreement-2026-06-02-qb-concurrent-throttle.md (10/s concurrent cap structurally impossible with serial caller); (b) d17d6a8 OB — single structural fix per Codex's offered path: removed Plaid UK from v1.0 public surface (tools.yaml + README + src/index.ts header comment) — closes all 4 OB issues at once (single-upstream-provider + set-equality + missing Plaid fixtures + Plaid endpoint-specific rate-limit). Plaid internal stub retained in src/ for v1.1+ work. Per-package gates: xero 28/28 vitest RATIFIED; qb 26/26 vitest typecheck CLEAN; ob 31/31 vitest typecheck CLEAN. Tree clean. Founder action: re-run `bash scripts/run-codex-ratification.sh --cluster F` for R4; if QB + OB still reject with NEW issues, HARD STOP and accept partial ratification per pre-agreed escalation.


**Today's task:** Morning (9 commits): priorities refactor + 2 MCP connectors + Cash Conductor bundle skeletons. Afternoon (3 commits): Cash Conductor bundle completion + `@ifos/autosend-bridge-telegram` scaffold + T12 grep refinement. **Evening (11 commits) per `goal-w4-day-26-afternoon-2026-06-01.md`** (the second /goal carried into evening): **Phase 1** wire bridge into Cash Conductor (tools.yaml split into propose/await + failure_modes; cycle.sh Step 10 production-shape call site as commentary; 076e231); **Phase 2** Codex manifest entries cluster Fbis + cluster G (0f1a0d1); **Phase 3** full Concierge bundle scaffold (5 commits 669a4f4→eb1f884: 14-cap tools.yaml + 15-step cycle.sh + Gate A G1-G5 validate.sh + context.sh hydration + cleanup.sh + 3 fixtures incl. rejection-voice-drift adversarial + 99-bridge-timeout-canary); **Phase 3+** Fbis extension to include Concierge (b3f4206). **Total Day-26 output: 23 commits / 0 founder gates touched / all quality gates green throughout.**
**Active plan:** Day-26 closed (thrice). Day-27 picks up with founder-triggered Codex runs: (a) `bash scripts/run-codex-ratification.sh --cluster F` (3 MCP connectors); (b) if F RATIFIED, `--cluster Fbis` (Cash Conductor AND Concierge full agent-bundle ratifications — both 100% present at scaffold layer; review-agent-bundle skill inspects each); (c) `--cluster G` D1-B decision-doc ratification via review-architecture-decision skill. Production wiring (real Telegram Bot API + postgres approvals table; W7-8 Cash Conductor + W10-13 Concierge build slices) stays gated per respective doc §"Implementation surface" notes.
**Most recent close:** Day 26 evening (2026-06-01 ~15:00→16:00 BST — ~1h actual vs 5h budgeted; sibling-pattern mirror + injectable-deps design + clean shellcheck/YAML gates throughout = no integration friction; Concierge bundle 5 files in ~25min; manifest extension in 1 commit). Tree clean. **Both Cash Conductor AND Concierge bundles now 100% present at scaffold layer** — W7-8 + W10-13 build slices respectively replace SKELETON TODOs with live impl.

## Active founder action board (2026-06-01)

| # | Action | Status |
|---|---|---|
| 1 | Confirm 4 design decisions | ✅ Confirmed |
| 2 | Accept ADR-007 | ✅ Accepted (commit `c862c77`) |
| 3a | Companies House key | ✅ Saved |
| 3b | Anthropic key | ✅ Saved + **credits topped up** |
| 3c | Diagnostic smoke (LLM §12 live) | ✅ **Trigger 2 CLOSED** — 634-word 12-section Hays plc report archived at `docs/artefacts/diagnostic-hays-plc-2026-06-01.md` |
| 4 | v0.3 migration to live VPS | ✅ APPLIED via `run-v0.3-migration-as-postgres.sh`; tenancy audit 12/12 |
| 5 | Founder Decision D1 | ✅ D1-B Telegram shim (commit `8d9acc2`) |
| 6 | Bullhorn chase (post email-fix) | 🔴 **FIRE refreshed form** — email outage discovered 2026-06-01; original 2026-05-24 submission's replies bounced; chase template (incident-aware framing) in chat 2026-06-01 + `docs/operations/founder-manual-playbook-2026-05-31.md` §4 |
| 7 | Q1 LOI (Jack) | ⏸ Jack lane (on track per founder 2026-06-01); Trigger 1 fires 2026-06-03 |
| 8 | Proxycurl signup | Deferrable — W9 Sourcing Scout gate |
| 9 | Fathom OR Fireflies signup | Deferrable — W6 Scribe gate |
| 10 | Xero developer account | Deferrable — gates live Cash Conductor test (fixture-first proceeds) |
| 11 | Email infra: send test from external + verify M365 receipt | ⏸ per `docs/incidents/2026-06-01-intelforce-ai-email-outage.md` TODO §3 |
| 12 | Secondary email channel (gmail backup) | ⏸ `docs/operations/contact-channels.md` to author post-DNS lesson |

## Active triggers (kill-criterion clocks)

| Trigger | Fires | Status |
|---|---|---|
| Trigger 1 (Q1 LOI) | 2026-06-03 (2 days) | Jack lane (on track) |
| Trigger 2 (DIAGNOSTIC-NO-RENDER-W3) | 2026-06-14 (13 days) | ✅ **CLOSED** — production-shape live render confirmed |
| Trigger 3 (JANITOR-BULLHORN-AUTH-W5) | ~2026-06-08 (7 days) | Blocked on Bullhorn A+B chase (item 6) |

## W4 backlog (actionable, not historical)

- [ ] **W4 Track-1 buildout** — week via `goal-week-4-track-1.md`. Status: `@ifos/xero` + `@ifos/quickbooks` + `@ifos/open-banking` MCPs all shipped (74/74 vitest across the three; cluster F manifest entry exists). Cash Conductor bundle 100% present at scaffold layer (W7-8 build slice replaces TODOs). Concierge bundle 100% present at scaffold layer (W10-13 build slice replaces TODOs). `@ifos/autosend-bridge-telegram` scaffold + consumer wiring landed today per D1-B (on both Cash Conductor and Concierge). **Remaining for the week**: cluster F + Fbis + G Codex ratification runs (founder-triggered); production wiring deferred to W7-8 + W10-13 build slices per their respective specs.
- [ ] **Migration rollback re-ratification** — R3 `to_regclass` fix applied at `0f4ce8d`; Codex re-run deferred per §10.3 ceiling to next natural rollback touch.
- [ ] **D1 decision doc Codex ratification** — `docs/decisions/2026-05-31-d1-founder-decision.md` queued for next Codex cluster (architecture-decision skill).
- [ ] **Diagnostic voice classifier microservice** — W4-5 polish; gated on Anthropic credits (now have ✓).
- [ ] **Diagnostic LinkedIn deep data via Proxycurl** — W4 polish; gated on signup #8.
- [x] **Tenancy audit T12 heuristic refinement** — closed 2026-06-01 Phase C (added `phase='trigger|action|output'` literal exclusions, `"description"` + `reason:` exclusions, and a `^[[:space:]]*#` pure-comment exclusion). Dry-run produces 0 hits where it previously produced 4 false positives.
- [x] **Tenancy audit `decision_log` row write** — already wrapped in `SET LOCAL app.current_tenant='ifos-meta'` at `scripts/run-tenancy-audit.sh:549` (verified 2026-06-01 Phase C). Earlier JSONL fallback was not an SET-LOCAL issue.
- [ ] **DKIM + DMARC TXT records** — outbound deliverability per email-outage incident TODO §5.
- [ ] **Cluster F Codex ratification** — pending cluster F manifest entry today (Phase 2 step 8); founder triggers the run.

## Historical context

Full chronological history (Day 1 → Day 25, all shipped items + closed backlog + Week-0 era foundation work) lives in **`docs/operations/decision-log.md`** (append-only). Established 2026-06-01 as part of the priorities-file refactor (today's goal §1.2). Pre-refactor this file was 1161 lines; refactor preserves every historical entry verbatim and cuts session-startup context cost ~80%.

## Other load-bearing references

| Document | Purpose |
|---|---|
| `CLAUDE.md` | 5 rules + 4 boundaries + Karpathy per-edit discipline + session rituals |
| `docs/build-brief/00-MASTER-BRIEF.md` | Operative one-stop brief |
| `docs/specs/PRODUCT-SPEC.md` | What we're building (§0-§4 + §10) |
| `docs/specs/ULTRAPLAN.md` | How + sequencing (§1 + §3 + §4 + §9 + §11) |
| `docs/decisions/v1.0-kill-criterion.md` | Triggers 1-10 + scope-cut authority |
| `docs/decisions/` (ADR-001 → 007) | Architectural decisions, all Accepted |
| `docs/operations/goal-w4-day-26-2026-06-01.md` | Today's morning autonomous /goal |
| `docs/operations/goal-w4-day-26-afternoon-2026-06-01.md` | Today's afternoon autonomous /goal |
| `docs/operations/goal-week-4-track-1.md` | Week's canonical W4 Track-1 /goal |
| `docs/operations/founder-manual-playbook-2026-05-31.md` | Manual founder-task playbook |
| `docs/incidents/2026-06-01-intelforce-ai-email-outage.md` | DNS post-mortem |
| `agents/_shared/{escalation-codes,autosend-policy,hook-helpers,voice-loader}.{md,yaml,sh}` | Runtime substrate (catalogue + hooks) |
| `docs/architecture/tenancy-invariants.md` | T1-T12 + verification matrix |
| `docs/operations/decision-log.md` | All historical context (this file's predecessor content) |
