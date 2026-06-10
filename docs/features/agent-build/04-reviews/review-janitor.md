# Review — Janitor (spec-001) — Round 1

**Verdict: PASS** (review sub-agent, 2026-06-10) · branch `worktree-agent-abb2ffb971bb471ba` (5 commits over `f456a27`) · merge-eligible as-is, with findings 1-5 folded into a follow-up commit
**Codex round 1 (session `20260610T131628Z-33230`): REJECTED:4 — all agent.md contract-doc findings, 0 code findings** → combined fix pass queued.

All spec-001 §6 criteria met; no BLOCKER/MAJOR. Reviewer ran everything first-hand. Honest-deferral verified: no live Bullhorn write path can fire with empty creds (`write_state:deferred_no_bullhorn_creds` rows proven in-suite).

## Review findings (fold 1-5 into fix pass; 6-10 advisory/post-creds)
1. **MINOR** `cycle.sh:439,:804` — `$(grep -c . file || echo 0)` emits `"0\n0"` on empty file → newline-corrupted marker reason. Use `awk 'END{print NR}'`.
2. **MINOR** `cycle.sh:665` — fixture-5xx coercion also runs on LIVE path; a real 4xx-on-retry is mislabelled `class=5xx` (disposition unchanged). Scope to fixture env.
3. **MINOR** fixtures 02/99 say `operator_notification.tier: yellow`, contradicting accepted deviation 8 (policy-owned GREEN). Align.
4. **MINOR** `cycle.sh:830-839` — `janitor_last_run` stamped on `--report-only` runs too → silently narrows next live scan window. Stamp only when Step 2 ran; post-creds checklist.
5. **MINOR** Step 2 live pull covers 3 of agent.md's 6 entity types (placements/opportunities/contractors not in this slice's CLI) — register as a numbered deviation.
6. **ADVISORY** `bullhorn_write_batch` summary fields count deferred rows as "written" — rename `*_recorded` or split.
7. **ADVISORY** `validate.sh:178` G1 10-min freshness window vs 15-45min documented runtimes → widen (~60min) or pass token state via env.
8. **ADVISORY** Step 8 notes attach to `min(target_entity_id)` per group, not each entity — add to deviations.
9. **ADVISORY** G7 cap is per-run (≤100), stricter than ≤100/min — label imprecise; revisit at live timing.
10. **ADVISORY** provenance stamp uses `customText1` — confirm field free at pilot onboarding.

## Codex round-1 findings (agent.md)
1. Gate-A-vs-review-band contradiction (hard-fail <0.85 vs the 0.70-0.85 held band) — amend agent.md to the spec-001 band model explicitly.
2. `ESC_DUPLICATE_DETECTED` catalogue mismatch — **substrate side landed on main `fc13390`** (catalogue amended to spec-001 band semantics + contractor + generic payload ids); agent.md + emitted payload fields to align.
3. `hh_decision_*` coverage: Step 1 auth refresh + Steps 3-4 dedup outcomes lack their own audit rows (consolidated at Step 9) — document the consolidated model or add rows.
4. §4 steps must cite a tools.yaml capability/_shared helper: Steps 3-4 inline matcher; Step 6 CH capability unnamed — name them.

## Deviations — all 10 ACCEPTED
(1) comparable-weight matcher w/ strong-identifier guard (spec sum can't reach 0.85) · (2) unknown-activity conservative hold · (3) ESC_DUPLICATE_DETECTED holds, not unregistered `operator_approval_request` · (4) G1 warn on creds-absent, hard-fail on `failed` · (5) honest `deferred_no_bullhorn_creds` yellow rows · (6) decision_log-derived Gate B pending day-0 baseline · (7) merge = provenance stamp (no Bullhorn merge API) · (8) notify tier policy-owned green · (9) fixed latent `*2*` step-glob bug, flagged CC's copy (verified real: CC cycle.sh:175) · (10) spec-001 §3 marker names supersede skeleton.

## Matcher reconciliation (vs Scout's copy) — RECONCILED, extraction clean
Same normalisers, same score core (0.3/0.4/0.2/0.1, comparable-weight, required strong identifier, 0.85). Divergences: rounding (Janitor 2dp pre-band vs Scout raw — inert today, must unify at extraction; recommend raw), application layers intentionally differ (bands vs clustering — fine above the shared score), and Scout's `confidence` output field is a different metric (name shared return `match_confidence`).

## Test evidence (reviewer-run)
build-gate **PASS** (shellcheck ×40; 4 connector suites; 9 DB suites) · dedup 25/25 · gate-a 21/21 · report 13/13 · `@ifos/bullhorn` typecheck + vitest 31/31 · 5 atomic commits, footer on all · boundary greps clean · all 6 emitted action_types registered; `bullhorn_oauth`/`janitor_cleanup` correctly on `hh_decision_output`.

## Post-creds live-smoke checklist (carry forward)
Findings 4/5/7/10 + Bullhorn OAuth consent bootstrap + Steps 1/2/9 live smoke.
