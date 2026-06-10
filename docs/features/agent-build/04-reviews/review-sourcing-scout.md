# Review — Sourcing Scout (spec-003) — Round 1

**Verdict: PASS** (review sub-agent, 2026-06-10) · branch `worktree-agent-a45354564e8f66257` (9 commits over `9573ced`)
**Codex ratification round 1: REJECTED (4 issues — all in `agent.md` contract doc, none in new code)** → fix pass dispatched; round 2 pending.

All spec-003 §6 acceptance criteria met; no BLOCKER or MAJOR findings. All verification run first-hand in the worktree by the reviewer.

## Review findings

1. **MINOR — `agents/recruitment/sourcing-scout/tools.yaml:116`** — stale NOTE says Step 4 emits `linkedin_search_skipped`; live cycle.sh emits `linkedin_query` per spec-003 §3. Fix the comment.
2. **MINOR — `tools.yaml:3-4`** — header still "Status: Proposed (W5 Day-33 SKELETON…)" while README declares LIVE. Fix the Status line.
3. **ADVISORY — `scripts/build-gate.sh:46`** — connector loop hard-coded to xero/quickbooks/open-banking/companies-house; `cv-library` cli.ts not gated (reviewer ran manually: typecheck clean, 20/20 vitest). Follow-up: add cv-library + reed to the loop as a single orchestrator-proposed change (NOT per-branch, to avoid parallel-worker conflicts).
4. **ADVISORY — `validate.sh:300-318` (G6)** — PII detection email-domain-only; broaden (phone/postcode) when the LLM-rationale enhancement lands.
5. **ADVISORY — `cycle.sh:209-223`** — Step-1 `ESC_BRIEF_AMBIGUITY` emits a `validate_gate_a_fail` action row while deviation 4 reserves that for Gate A. Pick one idiom at re-ratification.
6. **ADVISORY — `agent.md:5`** — reading-discipline note still skeleton-era. Refresh (overlaps Codex issue 4). Status flip itself stays founder-gated per agent.md §10.
7. **ADVISORY (positive)** — reviewer independently confirmed `CVLIBRARY_*` values EMPTY (inline comments fool naive awk SET check). Spec-003 §8 "creds SET" premise false; live smoke founder-gated. Implement agent flagging instead of faking = rule 5.

## Codex round-1 findings (agent.md)

1. LinkedIn/Proxycurl internal contradiction — §1/§3 say 3 active sources; line 26 + lines 169-175 still spec a live 4-source Proxycurl workflow. Rewrite around the 3-source v1.0 contract with LinkedIn an explicit NO-OP/deferred row.
2. False `blocked_recipients` migration citation (cites v0.2-to-v0.3.sql 396-409; real allowlist 432-434, validation 510-520).
3. False `recent_edit`/`voice` schema citation ranges (cites supplement 584-593 + 715-724; real `recent_edit` W at 597-606 + 728-737).
4. Stale build-state notes — claims `@ifos/reed`/`@ifos/cv-library` "don't exist yet" and `validate.sh` missing; both exist. (This is the F-tris scaffold↔runtime drift earmarked for reconciliation in the next build slice that touches both — i.e. this one.)

## Deviations table — all 7 ACCEPTED

| # | Deviation | Verdict |
|---|---|---|
| 1 | Matcher comparable-weight normalisation + strong-identifier guard (literal weight-sum caps name+email at 0.7 < 0.85) | ACCEPT — reconcile with Janitor at its review |
| 2 | spec-003 §3 marker names supersede skeleton names | ACCEPT |
| 3 | Fixture-01 arithmetic corrected to its own data (18→15→13) | ACCEPT |
| 4 | Per-source ESCs via `autosend_escalate`, `validate_gate_a_fail` reserved for Gate A | ACCEPT (Step-1 wrinkle → finding 5) |
| 5 | brief_id via Postgres `entities` mirror (no `getBrief` in @ifos/bullhorn v0.1.0) | ACCEPT |
| 6 | MX check opt-in for offline determinism | ACCEPT |
| 7 | Deterministic heuristics for confidence/rationale (CC templated-draft precedent); LLM upgrade documented | ACCEPT |

## Test evidence (reviewer-run)

- `build-gate.sh` → **PASS** (shellcheck CLEAN ×42; 4 connector suites; all 9 DB fixture suites green).
- `run-scout-dedupe-test.sh` 15/15 · `run-scout-gate-a-test.sh` PASS + 9 fail classes w/ ESC routing · `run-scout-degraded-test.sh` 18/18.
- `@ifos/cv-library` typecheck clean + 20/20 vitest (outside gate — finding 3).
- Contract greps: all 11 §3 markers emitted; zero Bullhorn write surfaces; zero Composio/AgentMail refs; zero `packages/harness/cortextos` changes; RLS idiom on every psql block; 9 atomic conventional commits, Co-Authored-By footer on all.

## Queued follow-ups
Codex round 2 (post fix-pass) · founder Q1/Q3/Q5/Q6 approvals + agent.md status flip · Janitor-matcher reconciliation · `sourcing_scout_cleanup` + `*_oauth` policy registration · source-abstraction ADR · live CV-Library smoke (founder: fill creds via `scripts/fill-dev-sandbox-secrets.sh`) · build-gate connector-loop extension (cv-library + reed).
