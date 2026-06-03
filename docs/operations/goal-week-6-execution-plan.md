# /goal — Week 6 execution plan: SKELETON → LIVE wiring sweep

**Status:** Drafted (W5 Day-34 marathon Phase 9; ratifies when first W6 /goal fires).
**Type:** Multi-day execution plan (referenced throughout Week 6; per-phase atomic commits; per-day /goal pacing matches W5).
**Authored:** 2026-06-03 (W5 close evening; marathon Phase 9).
**Master plan citations:** Master brief §8.2 (build sequence; W6 = Scribe primary build week per line 597; W5+ Janitor + Scribe + Sourcing Scout transitions from SKELETON to LIVE) + ULTRAPLAN §8.1 A3 (Scribe build complexity M = 1 week per line 526) + W5 close state in `docs/operations/decision-log.md` Day 34.
**Strategic premise:** W5 left ALL 5 v1.0 agent bundles at SKELETON tier (TODO(W6+) markers throughout). W6 transitions from scaffold-vs-live mismatch to live wiring as external dependencies land. Order of operations is dependency-driven: each agent's live wiring waits on its dependent MCP package having LIVE creds.
**Quality bar:** Same as W5 — each artefact production-quality; tests-clean before commit; honest-signal pattern preserved (don't claim "live integration verified" until it is).
**Maps to:** Day-35 (2026-06-04) → Day-41 (2026-06-10). 7-day window. May extend to Day-42+ if external dependencies land late.
**Builds on:** `docs/operations/goal-week-5-execution-plan.md` (W5 plan); W5 deliverables enumerated in `.agents/current-priorities.md` W5 CLOSED section + `decision-log.md` Day 34.

---

## §0 — Mandatory reading order

Before writing any code, the executor reads these in order and confirms each in chat:

1. **`CLAUDE.md`** at repo root — instance scoping + five rules + four boundaries + Karpathy per-edit discipline
2. **`.agents/current-priorities.md`** header + action board + W5 CLOSED + W6+ deferred founder gates
3. **`docs/operations/decision-log.md`** Day 34 (W5 close summary; key decisions)
4. **`docs/operations/founder-api-signups-2026-06-03.md`** — current state of which signups have landed (founder updates this; pending signups gate corresponding phases)
5. **`docs/operations/goal-week-5-execution-plan.md`** — for the SKELETON shape each W6 phase wires live against
6. **Per-agent: `agents/recruitment/<agent>/agent.md`** Reading-discipline notes — these document the SKELETON-vs-CONTRACT deltas each W6 phase resolves
7. **Per-MCP-package: `packages/mcp-connectors/<package>/README.md`** §"Live tests deferred" notes — these document what TODO(W5-live) or TODO(W6-live) markers W6 fills in

---

## §1 — Success state (what "done" looks like at end of Day 41 / Week-6 close)

When this plan completes, the following are ALL TRUE:

### A — Scribe primary build (Days 35-37)

1. **`@ifos/granola` LIVE TESTS pass** — founder completes browser OAuth dance (per founder-api-signups-2026-06-03.md P7); IFOS captures token bundle at vault path; `MCP_LIVE_TESTS=1 pnpm test` against real `mcp.granola.ai/mcp` passes ≥4 capability tests (list_meetings + get_meetings + get_transcript + get_account_info).
2. **`@ifos/bullhorn` LIVE TESTS pass** — founder completes Bullhorn developer-account signup (per founder-api-signups-2026-06-03.md P1); IFOS bootstraps per-corporation OAuth tokens; `MCP_LIVE_TESTS=1 pnpm test` passes ≥6 capability tests (refreshTokens + getCandidate + listCandidates + updateCandidate + createNote + getNote against sandbox tenant).
3. **Scribe `cycle.sh` Steps 1-9 wired live** — TODO(W6) markers replaced with real `@ifos/granola listMeetings` + `getTranscript` calls in Step 1 + Step 3; real `@ifos/bullhorn refreshTokens` in Step 2; real `@ifos/bullhorn updateCandidate` + `createNote` in Steps 8+9. Step 10 SLA metric computed against real elapsed seconds.
4. **Scribe `validate.sh` Gate A G1-G7 wired live** — JSON proposal parsing + per-check validation + per-failure ESC routing.
5. **Scribe `context.sh` SELECT path active** — env-var fallbacks replaced with `SELECT config->>'<key>' FROM tenant_adapters` for `bullhorn_corporation_id` + `granola_workspace_id` (v0.4-allowlisted) + Granola plan-tier pre-cache via `getAccountInfo`.
6. **First real transcript ingested end-to-end** against migration-test tenant — Granola meeting → transcript fetch → LLM field extraction → Bullhorn updateCandidate + createNote → vault tacit-note artefact. Founder verifies in Bullhorn sandbox the candidate's record now shows the extracted fields + the new Note attachment.
7. **agent.md Reading-discipline note updated** — vendor delta documented (webhook → polling per Granola) reconciled; status flips Proposed → Accepted per agent.md §10 lifecycle.

### B — Janitor secondary build (Days 38-39)

8. **Janitor `cycle.sh` Steps 1-9 wired live** — TODO(W6-7) markers replaced with real `@ifos/bullhorn` calls (refreshTokens, listCandidates with passive-match filter, updateCandidate for dedupe + field-backfill, createNote for tacit-note attach) + `@ifos/companies-house` enrichment lookups.
9. **Janitor `validate.sh` Gate A G1-G7 wired live** — per-write proposal JSON parsing + per-check validation + per-failure ESC routing.
10. **First real nightly cron run** against migration-test tenant — Janitor scans Bullhorn, identifies dedup candidates, writes merge actions (with operator approval gate for review-band per ESC_DUPLICATE_DETECTED), assembles day-30 report.

### C — Sourcing Scout MCP package wiring (Days 40-41; PARTIAL build slice)

W6 partial because Sourcing Scout's W9 build slice per master brief §8.2 line 599 — Day 40+ is preparation, not the full Sourcing Scout production wiring. Specifically:

11. **`@ifos/reed` LIVE TESTS pass** — founder completes Reed Recruiter API signup (per founder-api-signups-2026-06-03.md P2); IFOS gets API key; `MCP_LIVE_TESTS=1 pnpm test` passes ≥3 capability tests (searchCandidates + getCandidate + listJobs against sandbox).
12. **`@ifos/cv-library` LIVE TESTS pass** — founder completes CV-Library API signup (per P3); IFOS gets API key OR access token (depending on actual auth_mode); `MCP_LIVE_TESTS=1 pnpm test` passes ≥2 capability tests (searchCandidates + getCandidate).
13. **CV-Library auth_mode VERIFIED** — package `auth_mode` placeholder resolves to either 'basic' OR 'bearer'; README + types updated.
14. **Sourcing Scout `cycle.sh` Step 4 LinkedIn NO-OP confirmed as W1.1+ scope** — no change; W6 acknowledges deferred status; W8-9 vendor selection precedes any wiring.

### D — Quality gates + state hygiene (Day 41)

15. All 5 v1.0 agent bundles in some live-wired state (full LIVE = Scribe + Janitor; PARTIAL = Sourcing Scout MCP packages ready, agent wait for W9).
16. `scripts/run-tenancy-audit.sh` re-run by founder; passes 12/12.
17. `.agents/current-priorities.md` W6 CLOSED state with deliverables enumerated.
18. `docs/operations/decision-log.md` Day 41 entry appended.
19. `docs/RISK-REGISTER.md` updated if anything new surfaced.
20. **Cluster F-tris re-trigger entry** — agent.md ↔ code drift naturally reconciled by W6 wiring; partial-ratification disagreement docs from F + Fbis + G can be re-evaluated.

### E — Founder-side gates carried to W7+ (not blocking W6 work)

- Q1 LOI with Jack — if not signed by 2026-06-10, kill-criterion Trigger 1 has now fired for a full week; reassessment required
- Xero + QuickBooks + TrueLayer developer signups → W7-8 Cash Conductor live wiring
- WorkOS staging key → v1.1+ admin agent live work
- Concierge live wiring → W10-13 build slice per agent.md
- Bullhorn dev-support reply (if delayed past 2026-06-09) → may push Scribe/Janitor live tests into W7

---

## §2 — Day-by-day phases

Each phase is per-artefact atomic commits + commits referenceable from this doc.

### Phase 1 — Day 35 (2026-06-04): @ifos/granola + @ifos/bullhorn live tests

**Founder gate:** Bullhorn developer-account signup DONE + Granola browser OAuth dance DONE (founder confirms; per founder-api-signups-2026-06-03.md P1 + P7 reply patterns).

**Build:**
- `@ifos/bullhorn`: add `MCP_LIVE_TESTS=1` test block per cluster F R3 honest-signal pattern; OAuth bootstrap CLI helper (one-time founder dance); per-corp token bundle saved to vault path
- `@ifos/granola`: add `MCP_LIVE_TESTS=1` block; live token loaded from Claude-Code-MCP-captured path OR IFOS-side OAuth dance (verify which works)
- Live test suites: ≥6 Bullhorn capability tests + ≥4 Granola capability tests against actual upstream

**Commits (2 atomic):** `feat(mcp/bullhorn): MCP_LIVE_TESTS block + OAuth bootstrap helper` + `feat(mcp/granola): MCP_LIVE_TESTS block + token loader`

### Phase 2 — Day 36 (2026-06-05): Scribe live wiring (half-day)

**Build:**
- `agents/recruitment/scribe/context.sh`: TODO(W6) → real implementation; SELECT path active for bullhorn_corporation_id + granola_workspace_id; getAccountInfo pre-cache
- `agents/recruitment/scribe/cycle.sh` Steps 1-3: real @ifos/granola listMeetings + getTranscript; real @ifos/bullhorn refreshTokens
- 1 atomic commit per file

### Phase 3 — Day 36 evening (2026-06-05 PM): Scribe live wiring (continued)

**Build:**
- `cycle.sh` Steps 4-7: real Bullhorn entity inference + LLM field extraction + tacit-note generation + vertical-schema validation
- `validate.sh`: real per-check implementation + ESC routing
- 2 atomic commits

### Phase 4 — Day 37 (2026-06-06): Scribe end-to-end + first real transcript ingested

**Build:**
- `cycle.sh` Steps 8-10: real updateCandidate + createNote + SLA computation
- First real Granola transcript → Bullhorn writes against migration-test sandbox
- agent.md Reading-discipline note updated to reflect LIVE state (vendor delta reconciled)
- Status flips Proposed → Accepted (per agent.md §10 lifecycle)
- 3 atomic commits

### Phase 5 — Day 38 (2026-06-07): Janitor live wiring (half-day each)

**Build:**
- `agents/recruitment/janitor/{cycle,validate,context}.sh`: TODO(W6-7) → real implementation
- Real Bullhorn passive-match + dedup + Companies House enrichment
- 3 atomic commits

### Phase 6 — Day 39 (2026-06-08): Janitor end-to-end + first nightly cron

**Build:**
- First real nightly cron run against migration-test sandbox
- Day-30 report assembled with real data
- agent.md Reading-discipline note updated
- Status flips Proposed → Accepted
- 2 atomic commits

### Phase 7 — Days 40-41 (2026-06-09 / 2026-06-10): @ifos/reed + @ifos/cv-library live + CV-Library auth verified

**Build:**
- `@ifos/reed`: MCP_LIVE_TESTS block; ≥3 capability live tests
- `@ifos/cv-library`: MCP_LIVE_TESTS block; auth_mode VERIFIED (collapse dual-mode to single mode in v0.2.0); ≥2 capability live tests
- Sourcing Scout tools.yaml: flip `package_status:scaffold_pending_phase_8` → `package_status:live` for reed_* + cvlibrary_*
- 3 atomic commits

### Phase 8 — Day 41 evening: W6 close

**Build:**
- Run full smoke
- Update `.agents/current-priorities.md` W6 CLOSED
- Append `docs/operations/decision-log.md` Day 41 entry
- Update `docs/RISK-REGISTER.md`
- Re-evaluate cluster F-tris partial-ratification docs (some may close as agent.md ↔ code drift is naturally reconciled by W6 live wiring)
- 2-3 atomic commits

---

## §3 — Phase budgets + stop conditions

| Phase | Day | Budget | Soft-stop trigger | Hard-stop trigger |
|---|---|---|---|---|
| 1 (live tests) | 35 | 4h | OAuth bootstrap dance fails | founder unavailable for OAuth → defer to Day 36 |
| 2-3 (Scribe wire) | 36 | 8h | Bullhorn write API rejects payload shape | shape mismatch unresolvable in 1 round → STOP + ask founder |
| 4 (Scribe E2E) | 37 | 6h | first real transcript end-to-end fails | upstream change between scaffold + W6 → STOP + reconcile |
| 5 (Janitor wire) | 38 | 6h | dedup heuristic disagrees with operator expectation | tune threshold per founder feedback |
| 6 (Janitor E2E) | 39 | 4h | day-30 report metrics off | bullhorn data quality issue → STOP + surface |
| 7 (Reed + CV-Library live) | 40-41 | 4h | commercial signups not landed yet | defer to W7; mark deferred in close report |
| 8 (W6 close) | 41 PM | 2h | smoke fails on previously-green test | STOP — surface + joint diagnosis with founder |

**Universal stop conditions (apply to every phase):**
- Boundary violation (Composio/AgentMail in agent.md / tools.yaml / fixtures) → STOP, surface, do not auto-fix
- Schema-before-code violation (consumer attempts unallowlisted tenant_adapters.config key) → STOP, surface
- Founder-gated work (live API call, commercial signup) → flag-and-continue or pause per dependency
- Codex ratification round attempted in this plan → NOT ALLOWED. Codex re-trigger happens after W6 close (cluster F-tris re-evaluation) per master brief §10.5 ceiling discipline.

---

## §4 — Founder gates explicit

| Gate | Blocks | Path A discipline |
|---|---|---|
| Bullhorn dev-account creds in 1Password | Phase 1 (Bullhorn live tests) | Founder runs P1 of `founder-api-signups-2026-06-03.md`; save to 1Password as "IFOS Bullhorn — developer sandbox" |
| Granola browser OAuth done (requires Claude Code restart) | Phase 1 (Granola live tests) | Founder runs P7 of founder playbook; restart Claude Code; `/mcp` → granola → Authenticate |
| Reed Recruiter API key | Phase 7 (Reed live) | Founder runs P2; save to 1Password as "IFOS Reed.co.uk — recruiter API" |
| CV-Library API access | Phase 7 (CV-Library live) | Founder runs P3; save to 1Password as "IFOS CV-Library — recruiter API" |
| Q1 LOI status (Jack) | Strategic — does v1.0 still ship? | Founder closes LOI directly; reports outcome by 2026-06-10 |
| Tenancy audit re-run | Day 41 close | Founder runs `bash scripts/run-tenancy-audit.sh` with ifos_app password |

None of these block the SKELETON layer — but ALL block the corresponding live wiring. If founder gates slip, the wiring phase slips with them; SKELETON state at W5 close is good enough to pause indefinitely without losing momentum.

---

## §5 — Cluster F-tris re-evaluation expectation

W5 close added the cluster F-tris manifest entry (per scripts/run-codex-ratification.sh). W6's natural agent.md ↔ code reconciliation (when both files are touched in same workflow per the disagreement-doc framework) will resolve some of the disagreement-on-file artefacts.

Expected outcomes at W6 close:
- Scribe agent.md updated + bundle live-wired → Reading-discipline-note vendor-delta disagreement naturally closed
- Janitor agent.md updated + bundle live-wired → contract-vs-runtime disagreement naturally closed
- Sourcing Scout: still partial (W9 build slice owns full close); package-delta disagreement persists at W6 close

W7+ window for founder-triggered cluster F-tris run remains; expect partial-ratification at the Sourcing Scout layer only.

---

## §6 — Companion: deferred to W7+

Things explicitly OUT OF SCOPE for W6 but named for traceability:

- **Cash Conductor production wiring** — W7-8 build slice per CC agent.md §10
- **Concierge production wiring** — W10-13 build slice per Concierge agent.md §10
- **LinkedIn vendor selection for Sourcing Scout v1.1+** — W8-9 decision per agent.md §"v1.1+ disposition"
- **Sourcing Scout full agent live wiring** — W9 build slice per master brief §8.2 line 599
- **WorkOS live admin/onboarding work** — v1.1+ (no v1.0 consumer)
- **SCIM provisioning (workos_directory_id)** — v1.1+ supplement when SCIM write-back needed
- **Brain UI (rich-panel approval surface)** — v1.1+ per ADR-007

---

## §7 — Reading-discipline carryover from W5

Every agent.md Reading-discipline note added in W5 (CC + Concierge + Janitor + Scribe + Sourcing Scout) documents the SKELETON-vs-CONTRACT gap. W6 live wiring naturally REDUCES this gap as TODO(W6+) markers get replaced with real implementation. By W6 close, the Reading-discipline notes for Scribe + Janitor should flip from "SKELETON state today; W6+ build slice wires" to "LIVE state per Phase X commit Y; agent.md Status flipped Proposed → Accepted".

Sourcing Scout's Reading-discipline note may remain in SKELETON state at W6 close since its full agent wiring is W9 — but the package-delta portion of the note (reed/cvlibrary `package_status:scaffold_pending_phase_8`) DOES close at Phase 7 of W6.

---

*End of W6 execution plan. Refresh `.agents/current-priorities.md` header at each phase close. This document is the source of truth; deviations require an entry in `docs/operations/decision-log.md`.*
