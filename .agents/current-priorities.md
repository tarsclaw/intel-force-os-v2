# Current priorities

**Week:** Week 4 — **CLOSED 2026-06-02 (Day 27).** W5 starts when Bullhorn dev-support reply lands (~2-5 business days from 2026-06-02 = by 2026-06-09) OR Q1 LOI with Jack lands (whichever first).

**W4 deliverables shipped:**
1. 3 MCP connectors scaffolded (xero/quickbooks/open-banking; 74+ vitest across the three; xero RATIFIED; QB + OB Proposed-with-disagreement-on-file per `codex-disagreement-2026-06-02-*` docs)
2. Cash Conductor full agent-bundle at SKELETON layer (agent.md + cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures; W7-8 build slice replaces TODOs with live impl)
3. Concierge full agent-bundle at SKELETON layer (same shape; W10-13 build slice)
4. `@ifos/autosend-bridge-telegram` package scaffold + consumer wiring on both CC + Concierge (23/23 vitest; injectable transport+decisions+clock; per D1-B founder decision)
5. Codex ratification framework battle-tested across 13 rounds: 1 ratified + 5 proposed-with-disagreement-on-file; pattern codified as repeatable
6. Bullhorn Sub-decision A RESOLVED (marketplace deferred to v1.1+; direct API per-tenant OAuth = v1.0 path; founder pivoted to dev-support route)
7. Sourcing Scout v1.0 caveat for Proxycurl→NinjaPear shutdown (LinkedIn deep-data deferred to v1.1+; v1.0 = 3 active sources)
8. Bridge product hygiene: `bullhorn_activity_log_write` action_type registered; 7 real bugs caught + fixed across the Codex arc

**W5 readiness (verified 2026-06-02 W4 polish smoke):**
- ✅ Tree clean; 134/134 vitest across 6 MCP packages; 6/6 typecheck CLEAN; shellcheck CLEAN; 9/9 YAML parse; 0 boundary violations
- ✅ Disagreement docs in tree; build progress unblocked
- ✅ Decision-log + risk register + Sourcing Scout caveat + Bullhorn-path RESOLVED row all caught up
- ⏸ Tenancy audit deferred to founder (needs ifos_app Postgres password; non-blocking — W4 polish edits were additive-only on schema-touching surfaces; bash scripts/run-tenancy-audit.sh when you have the password)
- ⏸ Bullhorn dev-support reply pending (2-5 days; gates Janitor W5 build)
- ⏸ Q1 LOI with Jack pending (gates Trigger 1 fire 2026-06-03)
- ⏸ Email infra hardening (DKIM/DMARC/external test/secondary gmail; founder-paced; not blocking)
- 🟢 W5 /goal shape: Janitor agent-bundle scaffold (mirror CC + Concierge pattern) + `@ifos/bullhorn` MCP connector scaffold against the verified developer-API path

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
| 6 | Bullhorn chase (post email-fix) | 🟢 **PIVOTED 2026-06-02** — marketplace form route abandoned (requires ≥2 live customers; not justified at ≤3-pilot scale; ~$5-25k/yr); Sub-decision A RESOLVED (marketplace deferred to v1.1+; direct API per-tenant OAuth = v1.0). Founder submitted dev-support enquiry at `developer.bullhorn.com` 2026-06-02 for Sub-decision B (OAuth technical details). Awaiting 2-5 business-day reply (by ~2026-06-09). |
| 7 | Q1 LOI (Jack) | ⏸ Jack lane (on track per founder 2026-06-01); Trigger 1 fires 2026-06-03 |
| 8 | ~~Proxycurl signup~~ | ❌ **DEFERRED to v1.1+ (2026-06-02)** — Proxycurl shut down 2025 (LinkedIn lawsuit; nubela.co/blog/goodbye-proxycurl/); NinjaPear successor doesn't carry LinkedIn data. v1.0 Sourcing Scout operates against 3 sources (Bullhorn passive-match + Reed + CV-Library), not 4. LinkedIn-vendor selection deferred to W8-9 build slice (candidates: Lix / Phantombuster / Apify / Sales Navigator). Risk 14 in RISK-REGISTER. |
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
