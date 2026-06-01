# Current priorities

**Week:** Week 4 — **Day 26 / closed (2026-06-01)**
**Today's task:** **W4 Day-26 autonomous build per `docs/operations/goal-w4-day-26-2026-06-01.md` — ALL 3 PHASES SHIPPED. Phase 1 (5 compounding commits): incident doc + priorities refactor (1161→67 lines + decision-log.md) + CLAUDE.md session ritual + codex round-trip discipline learning + ECC pattern extraction (NO ecc install). Phase 2 (3 build commits): `@ifos/quickbooks` MCP (23/23 vitest) + `@ifos/open-banking` MCP (28/28 vitest incl. PSD2 token-aging property-tested) + cluster F manifest. Phase 3 stretch (1 commit, amended for shellcheck): Cash Conductor bundle skeletons (cycle.sh 14-step + validate.sh Gate A G1-G7 + tools.yaml). 10 logical changes / 9 commits. Tree clean. Tomorrow: Cash Conductor bundle fixtures + context.sh + cleanup.sh + cluster F Codex run.**
**Active plan:** Day-26 closed; Day-27 picks up with Cash Conductor bundle completion (3 remaining files: context.sh + cleanup.sh + 3 fixtures) → cluster F Codex run (founder triggers `bash scripts/run-codex-ratification.sh --cluster F`) → if RATIFIED, Cash Conductor agent.md flips Proposed→Accepted at the bundle layer (production-readiness still gates on Hire #1 + accounting/Open Banking commercial signups per agent.md §8).
**Most recent close:** Day 26 (2026-06-01) — autonomous 3-phase buildout: 9 commits, 0 founder gates touched during execution, all quality gates green throughout (typecheck + vitest + shellcheck + boundary scans). Process compounds: session-startup context cost dropped ~80% via priorities refactor; codex round-trip discipline codified as hard ≤2 ceiling; ECC patterns adapted IFOS-native without package install (Karpathy precedent).

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

- [ ] **W4 Track-1 buildout** — today via `goal-w4-day-26-2026-06-01.md`; week via `goal-week-4-track-1.md`. Status: `@ifos/xero` shipped; `@ifos/quickbooks` + `@ifos/open-banking` queued for today; Cash Conductor bundle next.
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
| `docs/operations/goal-w4-day-26-2026-06-01.md` | TODAY'S autonomous /goal |
| `docs/operations/goal-week-4-track-1.md` | Week's canonical W4 Track-1 /goal |
| `docs/operations/founder-manual-playbook-2026-05-31.md` | Manual founder-task playbook |
| `docs/incidents/2026-06-01-intelforce-ai-email-outage.md` | DNS post-mortem |
| `agents/_shared/{escalation-codes,autosend-policy,hook-helpers,voice-loader}.{md,yaml,sh}` | Runtime substrate (catalogue + hooks) |
| `docs/architecture/tenancy-invariants.md` | T1-T12 + verification matrix |
| `docs/operations/decision-log.md` | All historical context (this file's predecessor content) |
