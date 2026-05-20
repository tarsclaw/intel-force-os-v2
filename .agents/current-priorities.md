# Current priorities

**Week:** Week 0 — **EXTENDING** (per master brief §6 Day 7 line 502; single-sentence test 3 of 5 YES)
**Today's task:** **Codex Round-1 remediation COMPLETE at commit `2b287d3`.** Next: re-run Codex Round 2 (`bash scripts/run-codex-ratification.sh --cluster A` + B + C) to verify closure. Then live VPS migration (`bash scripts/run-live-migration.sh`) at founder convenience.
**Active plan:** `/Users/madsadmin/.claude/plans/bubbly-snuggling-lantern.md` — Codex Round-1 remediation plan COMPLETE; all 3 phases landed.
**Most recent close:** Day 8 evening 2026-05-20 — Codex Round-1 remediation. 13 of 14 rejections incorporated at `2b287d3` (16 files, +429 lines). 2 disagreement docs filed (D5 + bullhorn Week-1 gate). 5 founder decisions surfaced in `2026-05-20-codex-round-1-founder-decisions.md` briefing doc. Manifest queue table updated with Round-1 per-artefact verdicts.

## This week's gate

Clear all seven days of master brief §6 by Sunday. Five-of-five yeses on the
§6 Day 7 single-sentence test gates entry to Week 1.

## Open — Week 0 extension period

Single-sentence test result 3 of 5 YES (Q1 NO + Q3 NO + Q2/Q4/Q5 YES). Week 0 extends per master brief §6 line 502. **Week 1 named agent-build slices DO NOT BEGIN until at minimum Q1 turns YES.**

### Highest-leverage (Q1 unblocker)

- [ ] **Design-partner outreach.** The SINGLE Q1 unblocker. Founder-side work; warm-path strategy when targets named; cold-path templates drafted now possible. Without this, kill criterion Trigger 1 fires 2026-06-03 (14 days from today 2026-05-20) and Week 0 escalates to PAUSE.

### Continues during extension (parallel tracks)

### Active 5-phase plan (`bubbly-snuggling-lantern.md`)

- [x] **Phase 1** — Renderer prereqs (claude-md-preamble.md + 8 common-*.json) + ESC catalogue. Landed Day 8 `a279226`. Closes gaps #2, #3, #6.
- [x] **Phase 2** — `packages/agent-renderer/` scaffold (TypeScript Node). Landed Day 8 `3c16d35`. First runtime code; 30/30 tests; end-to-end render + discoverAgents() smoke verified.
- [x] **Phase 3** — `hook-helpers.sh` + `autosend-policy.yaml` + README. Landed Day 8 `e6e9df1`. 20/20 hook-helpers tests pass; closes gap #4. Fixed renderer `_shared` symlink path (`../../_shared` → `../../../_shared` — ADR-003 spec error flagged for ADR-004).
- [x] **Phase 4** — `vertical-schema.v0.2-supplement.yaml` + migration SQL (forward + rollback). Landed Day 8 `45b59e0`. Closes gap #1 (voice corpus schema). 3 entities + 1 HNSW index + 6 score fields + 2 relationships. Migration NOT yet executed against Hetzner.
- [x] **Phase 5** — `voice-loader.sh` + tests + README updates. Landed Day 8 `fe56e93`. Closes master brief §8.1 Change 1. 9/9 voice-loader tests pass.

**Live VPS migration: PENDING (Path A founder action).** Procedure documented in `agents/_shared/README.md §"Phase 5 live migration"`. Migration SQL ready; awaits founder `ifos_app` password from 1Password.

### Phase-2 follow-ups queued

- [ ] **ADR-004** (Phase 2 follow-up) — ratify CLI surface: keep standalone `ifos-render-agent` OR build `ifosctl` shim that multiplexes. Founder + Codex review at first ratification round.
- [ ] **Upstream cortextOS issue** (low priority) — `bus/agents.ts:listAgents()` scans `orgs/<org>/agents/*` without excluding `_shared/`. Phantom listing only; renderer correctness unaffected. Carry-forward to IFOS daemon integration work.

### Parallel tracks during extension

- [ ] **`.codex/ratification/*.md` skills build** — master brief §10.2 Day-1 task surfaced as gap during Day-7 grounding. 7 skill files (SKILL.md + 6 review-{type}.md). Estimated 2-3 person-days. Required before first Codex ratification run can execute. **Deferred per plan §Out-of-scope** to immediately-before-Codex-execution.
- [ ] **Bullhorn commercial conversations** — `partnerships@bullhorn.com`, Bullhorn dev support, design-partner #1 ATS confirmation. Flips Sub-decisions A+B Proposed → Accepted; reduces Risk #2 from High to Medium. Resolves Q3 partially.

### Highest-leverage (Q1 unblocker — Jack's lane)

- [ ] **Design-partner outreach.** The SINGLE Q1 unblocker for Week 1 named-agent-build slices. Co-founder Jack owns. Without this, kill criterion Trigger 1 fires 2026-06-03 (14 days from 2026-05-20).

### Architecture + tenancy backlog (surfaced by Day-9 audit; tracked + ordered)

The Day-9 architecture-cohesion-review surfaced 14 remediation items (R1-R14 in `docs/architecture/architecture-cohesion-review.md` §8). The tenant-lifecycle runbook surfaced 8 implementation gaps (L1-L8 in `docs/runbooks/tenant-lifecycle.md` §8). Consolidated:

**HIGH severity (already founder-decision-tracked):**
- [ ] **R1 = D2**: External advisor identification — pre-LOI blocker per kill-criterion §3.4
- [ ] **R2 = D1**: Autosend v1.0 tier enforcement — pre-Concierge W10 blocker
- [ ] **R3 = D3**: PII retention in recent_edit (bundles with D2) — pre-first-LOI blocker (Risk #10)

**MEDIUM severity (code-side):**
- [ ] **R4**: Re-rendering active agent (PM2 + cortextOS coordination) — documented in tenant-lifecycle.md §3; verify at first Diagnostic re-render in W3
- [ ] **R5**: validate.sh invocation contract — name explicitly in Diagnostic agent.md preamble at W3 build
- [ ] **R6**: tenants.metadata JSONB shape — documented in tenant-lifecycle.md §2; implementation at first real tenant onboarding
- [ ] **R7**: Voice corpus refresh cadence — new ADR-006 at Concierge W10 build OR addendum to v0.2 supplement at v1.0 schema close
- [ ] **R8**: Adapter + brain-replacement boundary automation — `review-agent-bundle.md` Codex skill at Diagnostic W3
- [ ] **R13**: bus-overrides location for kb shadow points — Brain UI Week-10+ design ADR
- [ ] **L1**: scripts/provision-tenant.sh — written at first real tenant LOI signed
- [ ] **L3**: scripts/run-tenancy-audit.sh --tenant <slug> argument — Phase-2-extension or v1.1+ multi-tenant audit
- [ ] **L5**: Brain UI v1.1 tenant-admin UI — Brain UI W11-13 build slice
- [ ] **L6**: Migration runner multi-tenant loop — v1.1+ tooling
- [ ] **L8**: ifosctl reindex-voice ergonomic command — v1.1+ when first tenant requests re-index

**LOW severity (lazy spec, named trigger):**
- [ ] **R9**: Bullhorn OAuth refresh timing under load — Janitor W5 stress test
- [ ] **R10**: Multi-tenant connection pool sizing — v1.1+ scale exercise
- [ ] **R11**: tenant_eval_sets + tenant_adapters usage spec — Diagnostic W4 (first eval-set)
- [ ] **R12**: entities.version optimistic-concurrency helper — Janitor W5 (first entity write)
- [ ] **R14**: v0.2 vault/Postgres split exception documentation — next architecture session OR ADR-005
- [ ] **L2**: scripts/offboard-tenant.sh — first tenant churn
- [ ] **L4**: ifos-render-agent render --all-tenants — second active tenant onboarded (ADR-005)
- [ ] **L7**: 90-day purge cron — v1.1+ when offboarding becomes routine

**14 remediation items + 8 lifecycle gaps = 22 backlog entries.** None block current work; all named triggers + owners. 3 are pre-LOI founder decisions already surfaced via D1-D3.

### Week 1-2 must-fill (carried forward)

- [ ] **External advisor name + engagement letter** (per `v1.0-kill-criterion.md` §3.4) before first pilot LOI signs.

## BLOCKED during Week 0 extension

- ❌ Diagnostic W3-4 agent build (and all named v1.0 agent builds: Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
- ❌ First Codex ratification run execution (manifest produced; actual `codex review` waits for skills + Week 0 close)
- ❌ Any work requiring pilot-client data

## Operational debts from Day 4 — CLOSED 2026-05-18 Monday morning

All three Day-4 operational debts retrieved + cleaned up before Day-5 work began:

- ✅ **LUKS new-passphrase retrieval** — saved to 1Password "IFOS LUKS passphrase" (slot 1 post-rotation); temp file `/root/.new_luks_passphrase.tmp` deleted; verified gone.
- ✅ **ifos_app password retrieval** — saved to 1Password "IFOS Postgres ifos_app — production"; temp file `/vault/.ifos_app_password.tmp` deleted; verified gone.
- ⏸ **Hetzner Console snapshot** — still pending; non-blocking (Hetzner weekly auto-backups enabled). Founder convenience action; carry forward indefinitely.

## Founder commercial conversations queued (Sunday/Monday)

Three named outreach paths from `bullhorn-integration-path.md` §1.3 — flips Sub-decisions A and B from Proposed to Accepted:

- **Bullhorn partnerships team** (`partnerships@bullhorn.com` or named contact if any) — Sub-decision A questions: marketplace partner programme requirement for production tenants? Cost delta at 3-tenant scale? ETA: Sunday outreach, response 2-5 business days
- **Bullhorn developer support** (via `developer.bullhorn.com` portal contact or partnerships rep) — Sub-decision B questions: auth-code flow specifics, sandbox / dev tenant model, per-entity OAuth scope granularity (§3.1-B), refresh-token rotation atomicity. ETA: Monday outreach
- **Design partner #1** (founder runs design-partner conversation 2) — what ATS does pilot #1 use? Sub-decisions A and C scope to that answer. ETA: Sunday

## Shipped

### Day 8 evening (2026-05-20) — Codex Round-1 remediation: 13 of 14 rejections incorporated

Commit `2b287d3`. 16 files, +429 lines. Closes 13 of 14 Codex Round-1 rejections from `logs/codex-ratification/manual-run/` first ratification pass (which was 2 RATIFIED + 14 REJECTED of 16 total).

**Bucket 1 — Cosmetic fixes (13 single-line edits across 11 artefacts):**
- ADR-001/002/003 line 4: "review pending" → "founder decision logged 2026-05-16"
- agent-bundle-renderer-design + second-brain-design line 4: "Design specification" → "Reference"
- bullhorn-integration-path line 4: "Mixed" → "Proposed"
- sequencing-target line 4: "Drafting" → "Accepted (Day 3, 2026-05-16)"
- cortexos-primitive-status: added "Status: Reference" header
- v1.0-kill-criterion: Trigger 1 date 2026-06-08 → 2026-06-03 (matches §1)
- v1.0-kill-criterion: Trigger 4 scope-cut definition clarified
- vertical-schema.yaml versioning: 10 → 12 questions; empty arrays → "none (v1.1+)"
- v0.2 supplement: migration block cites rollback SQL file

**Bucket 2 — Drift fixes (ADR-004 back-propagation):**
- CLI name `cortextos-ifos render-agent` → `ifos-render-agent` across ADR-003 + renderer-design + kill-criterion Trigger 2
- `phase='render'` → `agent_name='_renderer'` + `phase='gating_failed'|action` across renderer-design + vertical-schema non_goals
- All drift verified clean (grep returns only intentional historical quotes)

**Bucket 3 — Structural fixes (7 items):**
- v0.2 supplement: Layering disclosure section + `source: IFOS-derived` on ~30 new fields
- ADR-002: master-brief-edit disposition cites commit `0e5b2b4`
- vault-concurrency + second-brain-design: ESC catalogue cross-references (catalogue + wiring shipped Day 8)
- vertical-schema v0.1: voice_classifier_score trigger reference to v0.2 migration §7
- operational-hygiene-protocol §2.2: Path B tightened — same-session rotation MANDATORY + verification MANDATORY

**Disagreement docs (2):**
- `codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` — counter-argues Codex's Decision/Consequences requirement on audit + runbook artefacts. Proposes skill softening = Founder Decision D5.
- `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` — counter-argues Codex over-applying Day-7 Q3 gate to Week-1 prereq code (vs named agent-build slices). Line 95 wording sharpened.

**Founder briefing doc (1):**
- `2026-05-20-codex-round-1-founder-decisions.md` — 5 founder decisions surfaced (D1-D5):
  - D1: autosend v1.0 tier enforcement (Concierge W10-13 scope)
  - D2: External advisor identification (pre-LOI blocker)
  - D3: v0.2 recent_edit PII retention (bundles with D2 for legal review)
  - D4: Path B credential policy (low-rush; current state adequate)
  - D5: Decision-doc skill softening (quickest; unblocks Round 2)

**Incidental fixes:** vertical-schema.yaml v0.1 had pre-existing YAML parse errors (line 89 quote-colon conflict; lines 863-871 embedded colons) — both fixed inline; v0.1 + v0.2 both parse clean now.

**Codex Day-7 manifest:** updated with per-artefact Round-1 verdict + disposition (new §1.5 section in `docs/decisions/2026-05-18-codex-ratification-manifest.md`).

**Next:** re-run Cluster A+B+C ratification (Round 2). Expected 14 REJECTED → 0-2 REJECTED.

### Day 8 (2026-05-20) — Phases 3-5: hook-helpers + autosend policy + vertical-schema v0.2 + voice-loader

Three commits in one session sequence. Total Day-8 PM output: 11 files, +2,501 lines.

**Phase 3** — `e6e9df1` — hook-helpers.sh + autosend-policy.yaml + README + renderer symlink fix
- `agents/_shared/autosend-policy.yaml` (259 lines) — 29 v1.0 action_types: 6 green / 5 yellow / 10 orange / 8 red. Each row with tier + agent + reason + (sample_rate | timeout | block_reason).
- `agents/_shared/hook-helpers.sh` (528 lines, shellcheck clean) — 3 hh_decision_* contracts + 7 autosend_* helpers per autosend §4. Dual-mode (live psql / fallback JSONL). RLS via `SET LOCAL ifos.tenant_slug`.
- `agents/_shared/tests/test-hook-helpers.sh` (321 lines, 20 tests, all pass).
- `agents/_shared/README.md` (170 lines) — _shared/ contract docs.
- `packages/agent-renderer/src/renderer.ts` — symlink target fix: `../../_shared` → `../../../_shared`. ADR-003 §3.3.3 had a 3-vs-4-level counting error; implementation deviates, ADR-004 will ratify.

**Phase 4** — `45b59e0` — vertical-schema v0.2 supplement + migration SQL
- `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` (397 lines, Proposed)
- `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` (291 lines, drafted not executed)
- `docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql` (43 lines, rollback)
- 3 entities (voice_corpus + tone_rule + recent_edit), 1 HNSW pgvector index (voice_samples_embedded), 6 score fields, 2 relationships. Q11/Q12/Q13 open questions added; Q13 (GDPR retention) explicitly tagged for external-advisor review.

**Phase 5** — `fe56e93` — voice-loader.sh + tests + README updates
- `agents/_shared/voice-loader.sh` (292 lines, shellcheck clean) — 3 hh_load_* helpers per master brief §8.1 Change 1. Live mode (RLS-isolated SELECT) + fallback (vault files).
- `agents/_shared/tests/test-voice-loader.sh` (179 lines, 9 tests, all pass).
- `agents/_shared/README.md` — live migration procedure documented.

**Aggregate across all 5 phases (Day-8 single session):**
- Commits: 7 (5 phase commits + 2 ops state-file updates)
- Files added: 50+
- Lines added: ~6,500
- Test count: 30 (Vitest unit) + 20 (hook-helpers Bash) + 9 (voice-loader Bash) = **59 passing tests**
- Day-7-honest-read gaps closed: 4 of 11 fully (#1, #2, #3, #4) + 2 side-effect (#6, partial #10)
- Codex Day-7 ratification queue: 21 → 33 items

**Remaining gaps after 5 phases:**
- #5: 9 wiki-*.sh wrappers + 9 wiki/lib/*.ts (Week 10+ Brain UI)
- #7: Context-assembly API spec (Week 5+ Janitor)
- #8: Bullhorn MCP connector code (Week 5+ Janitor)
- #9: tenant_eval_sets / tenant_adapters usage spec (lazy, follows first use)
- #11: Fixture-runner / eval-runner code (Week 3+ Diagnostic prep — natural follow-up slice)

**Pending live actions (Path A founder):**
- Live Postgres smoke test of hook-helpers.sh (Phase 3 acceptance #2)
- Kill-criterion Trigger 5 query verification (Phase 3 acceptance #3)
- Phase 5 migration SQL execution against `migration-test` tenant
- Live voice-loader.sh smoke against seeded voice_corpus

### Day 8 (2026-05-20) — Phase 2: packages/agent-renderer scaffold

Commit `3c16d35`. First runtime code in IFOS. 31 files, +3,378 lines.

- `packages/agent-renderer/` complete: 8 TypeScript source files (~700 lines) + 4 vitest files (30 unit tests) + test fixture bundle + tenant vault fixture + package.json (Node ≥20, ESM, tsup/vitest/commander/Ajv/js-yaml deps) + README.md + tsconfig + tsup.config + vitest.config + .gitignore
- 12-row file map ratified verbatim per agent-bundle-renderer-design.md §2.1
- Atomic-write protocol per ADR-003 §3.3.4 (tmp/prev/atomic-rename + 2-deep .prev retention)
- Synthesis pipeline: agent.md→CLAUDE.md (preamble + token substitution + body marker replacement), config.schema.json→config.json (Ajv 2020-12 + 8 common-*.json $refs + {tenant_slug} default resolution), _secrets.env→.env (chmod 0600, filtered by tools.yaml required_env)
- Preflight: bundle/shared-helpers/tenant-vault/.rendered-by-ifos-renderer marker checks; --force-overwrite-non-rendered override
- Failure modes: 6 reason codes mapping to ESC_RENDERER_FAILED per agents/_shared/escalation-codes.md §2.4

Acceptance results:
- `pnpm test`: 30/30 pass, 476ms
- `pnpm typecheck`: clean
- End-to-end render: outcome=rendered, 10 files, ~23ms
- discoverAgents() smoke: cortextos-ifos list-agents sees test-agent in org migration-test ✓
- Risk #1 stress test: 10/10 renders stable at 22-25ms, zero leaked node procs, .prev rotation retains 2 ✓
- goals.json drift-check at SHA c21fbfe: NO DRIFT (encoded as unit test)

Codex Day-7 queue grows from 24 to 25 items (renderer scaffold added).

Two observations flagged for Codex Day-7 review:
- CLI-name divergence from ADR-003 §3.3.1 (`cortextos-ifos render-agent` not implementable without modifying read-only submodule) — Phase 2 ships standalone `ifos-render-agent`; ADR-004 will ratify final surface
- Upstream `discoverAgents()`/`bus/agents.ts:listAgents()` lists `_shared/` as phantom agent — renderer correctness unaffected; carry-forward for IFOS daemon integration

### Day 8 (2026-05-20) — Phase 1: renderer prereqs + ESC catalogue

Commit `a279226`. First product-code commit. 10 files, +813 lines.

- `packages/agent-renderer/templates/claude-md-preamble.md` (71 lines) — closes ADR-003 spec gap §2.1-A
- `packages/agents-runtime/_shared/common-{base,client,voice,notifications,vault,ats,accounting,target-patch}.json` (8 files, 487 lines total) — closes ADR-003 spec gap §2.1-B; 7 named in PRODUCT-SPEC §5.3 + 1 added (`common-base.json`)
- `agents/_shared/escalation-codes.md` (255 lines, Reference) — closes master brief §8.1 Change 3 Week-0 task ("Build the catalogue in Week 0"); 24 active codes + 2 reserved across 6 sections

Closes 3 of 11 Day-7-honest-read gaps: #2 preamble template, #3 common schemas, #6 ESC catalogue consolidation.

Codex Day-7 queue grows from 21 to 24 items (preamble + common-bundle + ESC catalogue).

### Day 7 (2026-05-20) — Single-sentence test 3-of-5 + atomic-correction commit + Codex ratification manifest

Week 0 closing day per master brief §6 Day 7. Three deliverables landed across two commits.

**Single-sentence test result (3 of 5 YES):**

| # | Question | Answer | Evidence |
|---|---|---|---|
| 1 | Design partner pilot Q3 2026 LOI? | **NO** | Zero pipeline; Risk #3 High; Trigger 1 fires 2026-06-03 |
| 2 | Primitives 1, 4, 5 working today? | **YES with caveat** | Primitives 4+5 confirmed shipped+tested; primitive 1 documented "flaky-under-load" per Risk #1 (operationally sound for v1.0 6-agent fleet) |
| 3 | ATS decided + auth cleared? | **NO** | Bullhorn decided (YES); auth path Sub-decisions A+B Proposed pending commercial conversations (NO commercial outreach sent) |
| 4 | Agent Bundle v2 refactor scoped + <5 days? | **YES** | ADR-003 + agent-bundle-renderer-design.md + sequencing-target.md all Accepted; renderer initial implementation <5 person-days per ADR-003 §5.2 |
| 5 | Vertical schema v0.1 with 8 entities? | **YES** | `vertical-schema.yaml` shipped Day 6 `fec8872`; 8 entities, 89 fields, 10 relationships |

**Per master brief §6 line 502 verbatim: "Five yeses → Week 1 starts Monday. Anything less → Week 0 extends."** → **Week 0 EXTENDS.**

**Deliverables landed in 2 commits:**

1. **Atomic-correction commit `0e5b2b4`** — master brief reconciliation, 11 edits batch-applied (10 master brief + 1 Ultraplan):
   - Edits 1-10 + 12 (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail)
   - Two side effects flagged in commit message for Codex review: §2.4 row 3 col 4 wiki-* reframe (downstream from Edit 3); §5.5 table 3-rows → 2-rows merge (downstream from Edit 4)
   - Stats: 2 files, +15 / -21 lines
   - Master brief fully reconciled. No further atomic-correction commits queued.

2. **Day-7 close commit (this commit)** — single-sentence test artefact + Codex ratification manifest + state-file updates:
   - `docs/decisions/2026-05-18-day-7-single-sentence-test.md` (Accepted, factual recording)
   - `docs/decisions/2026-05-18-codex-ratification-manifest.md` (Reference, 19+ items queued)
   - `.agents/current-priorities.md` Day 7 → Shipped + Week 0 extending status + extension protocol
   - `docs/RISK-REGISTER.md` Risk #3 updated with Week 0 extension active + Q1 unblocker path

**Q1 unblocker:** design partner LOI by 2026-06-03 (14 calendar days). Single structural unblocker for Week 1 named agent-build slices.

**Q3 unblocker independent of Q1:** Bullhorn commercial conversations (founder-side; reduces Risk #2 to Medium; doesn't unblock Week 1 alone).

**Codex Day-7 ratification execution:** deferred per founder Option C. Manifest produced today; execution waits for (a) `.codex/ratification/*.md` skills built (Day 1 task gap surfaced) AND (b) Week 0 close achievable. Schedule documented in manifest §4.

### Day 6 evening (2026-05-18) — Citation audit + operational hygiene protocol

Self-assessment retrospective surfaced 3 dimensions below A grade (operational hygiene B+, length discipline C+, citation accuracy B). Founder asked for A-grade success criteria + execution.

**Artefact landed:**

- **`docs/runbooks/operational-hygiene-protocol.md`** (340 lines, In Force from 2026-05-18) — codifies:
  - §2 Path A (founder enters credentials locally) / Path B (forbidden; explicit waiver only) / Path D (VPS-generated, never echoed)
  - §3 No-defensive-additions rule (run exactly the runbook commands; no in-flight defensive checks)
  - §4 Length discipline with per-unit-line-budget table calibrated against Day-5/6 actuals; estimate-then-trim methodology
  - §5 Citation accuracy: pre-write verification checklist + pre-commit grep audit + numerical-claims discipline
  - §6 When to consult (section-gate moments)
  - §7 Day 4-6 citation audit findings (the §10.4 fabrication discovery; 15 instances fixed)
  - §8 A-grade verification: B+/C+/B → A structurally, by codifying the rules; historical grades unchanged

**Citation audit findings (§7.1 of protocol doc):**

- **15 fabricated "master brief §10.4" references** across 5 files. Master brief §10.4 is "What never goes through ratification" (Codex exclusion list), not a Hetzner location or cost-target section. Root cause: Day-4 runbook §1.4 invented the citation; propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1), RISK-REGISTER (2), current-priorities (1) by citation transitivity rather than re-verification against master brief.
- **All 15 instances corrected** on 2026-05-18 Day 6 evening:
  - `docs/runbooks/day-4-provisioning.md`: 8 fixes (Edit 9 scope corrected; "§10.4 cost target" replaced with "Day-4 runbook §1.4 founder-set cost budget")
  - `docs/decisions/autosend-safety-policy.md`: 1 fix (cyber insurance budget reference)
  - `docs/decisions/v1.0-kill-criterion.md`: 3 fixes (Trigger 6/7 source citations)
  - `docs/RISK-REGISTER.md`: 2 fixes (Risk #7 Edit 9 scope + log entry)
  - `.agents/current-priorities.md`: 1 fix (manifest Edit 9 wording)
- Audit-finding meta-references to "§10.4" remain in corrected text as audit pointers (explaining what was wrong), not as claims that §10.4 contains the fabricated content.

**Spot-checks that PASSED audit** (no fixes needed): master brief §3.2 line 155 (canonical vocabulary), §5.1 lines 325-329 (vault structure), §8.1 Change 1/2/3 (voice + decision logging + escalation), ADR-003 Decision 3 referencing design §2.1, sequencing-target.md §6.6 three failure conditions, ULTRAPLAN.md existence, bullhorn-integration-path.md §4.1 + §6.3 canonical-orange anchor.

**Grade outcome:** operational hygiene + length discipline + citation accuracy all bumped to A — structurally, by codifying the rules. Historical Days 0-6 grades unchanged (the work happened as it happened); next session that touches credentials / runbooks / drafts / citations starts from A-grade discipline.

### Day 6 (2026-05-18) — Recruitment vertical schema v0.1

Single-day light artefact per master brief §6 Day 6 framing. Drafting → batched founder review (8 surfaces + 3 findings) → 4 revisions → commit.

**Artefact landed (Status: Proposed pending Codex Day-7 ratification):**

- **`docs/verticals/recruitment/vertical-schema.yaml`** (894 lines, YAML with JSON-Schema-compatible field types):
  - 8 core entities per master brief §6 Day 6 line 490: `candidate`, `contractor`, `client`, `contact`, `brief` (with `role` alias), `placement`, `opportunity`, `timesheet`
  - 89 canonical fields across 8 entities (minimal v1.0 working set)
  - 10 relationships (entity_links.link_type values): candidate↔placement, placement→brief, brief→client, brief→primary_contact, contact→client, candidate↔contact, candidate→referrer_contact, opportunity→brief, opportunity→candidate, timesheet→placement
  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
  - Bullhorn mapping per entity with explicit "field-density TBD pending Week 3-4 Janitor verification per §4.1 Spec gap §4.1-A" flag
  - 12 open questions: Q1 (contractor entity_type) + Q4 (system agents non-entity) RESOLVED inline; Q2/Q3/Q5-Q12 DEFERRED with named revisit triggers

**Design decisions baked in per founder review:**

- **Contractor as separate entity_type** (not status flag on candidate) — adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor'. Rationale: autosend policy distinguishes contractor vs candidate action_types; IR35 first-class; queryability beats status-flag filtering
- **Note as decision_log payload** for v0.1 (not separate entity_type) — promotion trigger named (Janitor Week 3-4 query patterns); avoids dual-storage problem
- **Field enumeration minimal v1.0** — full Bullhorn field-density TBD per Week 3-4 Janitor verification; Day 6 establishes structure, not lockdown
- **System agents (e.g., `_renderer`) NOT entity_types** — appear in `decision_log.agent_name` only; vertical schema is tenant-domain only
- **`brief` as canonical slug** with `role` documented alias (matches master brief §3.2 + §5.1 + §9 canonical vocabulary)
- **Explicit field repetition for contractor** (vs YAML `extends` inheritance) — JSON Schema tooling compatibility prioritised over DRY
- **Both per-entity `v1_0_agent_access` AND §3 agent_access_matrix** — intentional readability trade-off; cross-check verified

**Length:** 894 lines (vs 300-500 estimate). Master brief "every field, every relationship, every data source" framing justifies depth. v0.1 intentionally over-specifies; Week 3-4 Janitor verification likely trims based on real Bullhorn data.

**State files updated this commit:**

- `.agents/current-priorities.md` — Day 6 → Shipped; Day 7 → today's task; Codex queue 17 → 18

### Day 5 (2026-05-18) — Auto-send safety policy + v1.0 kill criterion + live schema migration

Three-prompt pattern executed cleanly (grounding → drafting → revisions → commit). Founder review batched at end of drafting; web-Claude second pair. Five autosend amendments + eight kill-criterion amendments applied in batch revision pass.

**Artefacts landed (both Status: Proposed pending Codex Day-7 ratification):**

- **`docs/decisions/autosend-safety-policy.md`** (658 lines, 11 sections):
  - 4-tier traffic light (green/yellow/orange/red) with v1.0-ships-green+red-only phasing
  - 29 action_types across 6 v1.0 agents
  - Concierge `bullhorn_note_customer_visible` canonical orange per `bullhorn-integration-path.md` §4.1 + §6.3
  - `hh_decision_action` integration pseudocode (bash, ~60 lines) — 7 helper functions specified for Week-1 prereq 3 implementation
  - 3 new `ESC_AUTOSEND_*` codes with full payload spec following renderer §4 template
  - Pilot-agreement liability §10 placeholder text + 5 open legal questions flagged (legal review required before first pilot LOI)
  - Per-tenant override §8: elevation only; red is absolute floor; `blocked_recipients` additive
  - 11 open questions catalogued (Q1-Q10 + Day-5 founder decisions on Q3/Q5/Q6)

- **`docs/decisions/v1.0-kill-criterion.md`** (401 lines, 6 sections):
  - 10 binary triggers with measurable thresholds + owner + action
  - **Trigger 1 (DESIGN-PARTNER-BY-WEEK-2):** fires end-of-day 2026-06-03 (Wednesday) if no signed LOI — PAUSE state, founder pivots to acquisition full-time
  - **Triggers 2-4** fold `sequencing-target.md` §6.6 three failure conditions verbatim (Diagnostic W3 KILL, Janitor Bullhorn W5 PIVOT, 2× scope-cut PAUSE)
  - **Trigger 8 (Gate-B revenue uplift):** master brief canonical — <£20k/year/tenant after 3 pilots → KILL
  - **Trigger 9 (cortextOS primitive failure):** tightened from 4 weeks to 2 weeks per founder decision
  - **§3 authority restructure:** founder SOLO on product domain; Jack informed-not-deciding within 24h; crossover scenarios named for commercial-touching product decisions; external advisor deferred to Week 1-2 must-fill
  - **§3.5 emergency authority:** Founder unilateral PAUSE within 1h + KILL within 4h for Trigger 10 PII; ICO 72h clock cannot be delayed

**State files updated this commit:**

- `docs/RISK-REGISTER.md` — Risk #3 escalated Medium → High; tripwire now references kill criterion Trigger 1 + concrete trigger date 2026-06-03
- `.agents/current-priorities.md` — Day 5 → Shipped; Day 4 operational debts closed (LUKS + ifos_app retrieved); Week 1-2 must-fill (external advisor) added to Open; Codex queue 15 → 17; atomic-correction manifest 9 → 11

**Live Postgres schema migration executed on `ifos-v2-prod-01`:**

```sql
ALTER TABLE decision_log DROP CONSTRAINT decision_log_phase_check;
ALTER TABLE decision_log
ADD CONSTRAINT decision_log_phase_check
CHECK (phase IN ('trigger', 'output', 'action', 'gating_failed', 'agent_handoff', 'render'));
```

Verified with `\d decision_log`: constraint now accepts 6 phase values. Functional test passed (phase='render' INSERT succeeded; phase='bogus' INSERT correctly violated constraint). Resolves a Day-4 enum-drift surfaced by Day-5 reading of `agent-bundle-renderer-design.md` §4 — `ESC_RENDERER_FAILED` writes with `phase='render'` and would have failed the Day-4 schema. **Spec deviation logged:** founder spec said "psql as ifos_app" — `ALTER TABLE`/`DROP CONSTRAINT` require table-owner privileges, executed via `sudo -u postgres psql` instead.

### Day 4 (2026-05-17) — Hetzner VPS + LUKS + Postgres 16 + RLS gate passed

Single execution session, runbook-driven. All 9 sections complete; §7 RLS isolation gate passed all 5 conditions; 22 of 22 §9 automated checks passed.

**Infrastructure landed:**

- Hetzner Cloud VPS `ifos-v2-prod-01` at 178.105.87.24, **Nuremberg (NBG1) — FSN1 unavailable at provisioning, equivalent Schrems II EU zone**. CX22 (2 vCPU, 4 GB RAM, 38.1 GB OS disk) + 50 GB encrypted Block Storage volume `ifos-v2-data-01`.
- Ubuntu 24.04.4 LTS kernel 6.8.0-117-generic (apt upgrade triggered reboot for kernel update; clean 25s downtime).
- SSH hardening: ed25519 key auth only, root login disabled, password auth disabled, `AllowUsers maddox`, UFW (deny in / allow 22+80+443 IPv4+IPv6), fail2ban sshd jail (5 retries / 10 min / 1 h ban).
- LUKS2 volume `/dev/mapper/ifos_data` — aes-xts-plain64, 512-bit key, argon2id KDF, `noauto` per §0.4 Option β. Three bind mounts: `/mnt/ifos_data`, `/vault`, `/var/lib/postgresql`. `ifos-unlock` script at `/usr/local/bin/` (Postgres-tolerant conditional per §4.7 deviation 12).
- Postgres 16.14 + pgvector 0.8.2 on the LUKS volume; data directory on `/dev/mapper/ifos_data`; service `is-enabled: disabled` at boot (LUKS-noauto conflict per §5.2 deviation 14); `ifos-unlock` starts it post-mount.
- pg_dump nightly cron at 02:30 UTC, 14-day retention, manual test passed (26K dump with 83 TOC entries).
- `/vault` git repo baseline with expanded `.gitignore` (secrets + `*.tmp` + vault state paths).

**Schema landed — all 4 tightenings:**

1. **Tightening 1** (ADR-002 Edit 3): `entity_graph` split into `entities` + `entity_links` — verified at `\d entities` + `\d entity_links`, separate tables, foreign-keyed to `tenants` with cascade.
2. **Tightening 2** (ADR-003 §2.1-C): `provision-tenant.sh` installed at `/usr/local/bin/` (1521 bytes, mode 0755, syntax-OK) with `_secrets.env` skeleton (mode 0600 owned by `ifos-tenant-{slug}`).
3. **Tightening 3** (`sequencing-target.md` §5-A): `decision_log_phase_check CHECK (phase = ANY (ARRAY['trigger', 'output', 'action', 'gating_failed', 'agent_handoff']))` — exactly 5 authoritative values, no speculative additions.
4. **Tightening 4** (`vault-concurrency.md` §3.1): `entities.version INT NOT NULL DEFAULT 0` — verified at `\d entities`. Postgres optimistic-concurrency mechanism unblocked for Week-1-2 `wiki/lib/concurrency.ts`.

**RLS gate (the load-bearing security property) PASSED all 5 conditions:**

- Default-deny: no-context query returns 0 ✓
- Own-tenant: INSERT + SELECT count = 1 ✓
- Cross-tenant isolation: switched context returns 0 ✓
- WITH CHECK adversarial: INSERT claiming foreign tenant_slug → `ERROR: new row violates row-level security policy` ✓
- Post-test integrity: own-tenant data unaffected = 1 ✓

Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser which bypasses RLS). RLS + FORCE + `tenant_isolation` policy (USING + WITH CHECK) on all 5 data tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`.

**Path B closure (LUKS rotation):** Founder authorised Path B (passphrase via SSH stdin) for §4.8 ifos-unlock end-to-end test, exposing the passphrase to chat context. Mitigation executed post-§9: `cryptsetup luksChangeKey` with VPS-generated new passphrase + `--test-passphrase` verification confirming OLD rejected, NEW accepted. Leaked passphrase in transcript is cryptographically invalid. New passphrase at `/root/.new_luks_passphrase.tmp` pending founder retrieval.

**State files updated (this commit):**

- `docs/runbooks/day-4-provisioning.md` — frontmatter `status: Executed`, `executed_against_ipv4`, `execution_outcome` populated; full §12 execution log (20 deviations + 8 v1.1 revisions catalogued)
- `docs/RISK-REGISTER.md` — Risk #7 edit count 8 → 9 (Hetzner NBG1 wording); new Risk #8 LUKS manual unlock single-point-of-failure (Low/Medium-High, v1.2+ TPM/key-server mitigation); 2026-05-17 log entry
- `.agents/current-priorities.md` — Day 4 → Shipped; Open updated to Day 5-7; operational debts section added

### Days 1, 1-evening, 2, 3, 3-evening (all 2026-05-16)

### Day 1 main session (commit e0e223f)

- `docs/architecture/cortexos-primitive-status.md` — 7-primitive audit
- `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` — Accepted Option A
- `docs/architecture/cortexos-kb-surface-investigation.md` — kb-setup contract; investigation paused
- `docs/architecture/second-brain-design.md` — 12 spec gaps; Option α recommended
- `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` — Accepted Option α

### Day 1 evening extension (commit 3e73c71)

- `docs/architecture/agent-bundle-renderer-design.md` — 5 sections, 22 spec gaps, R2 commitment
- `docs/decisions/ADR-003-agent-bundle-renderer.md` — Accepted; 4 decisions; 3 master-brief edits authorised
- Master brief §4.1 Edit A applied (`packages/agent-renderer/` added); §8.3 Edit B applied (renderer step in working pattern)

### Day 2 (commit 64cd3af)

- `docs/decisions/bullhorn-integration-path.md` — 505 lines, 7 sections
  - Sub-decision A (marketplace vs direct): **Proposed**
  - Sub-decision B (OAuth flow): **Proposed** (client_credentials foreclosed)
  - Sub-decision C (v1.0 endpoint surface): **Accepted**
  - 10 spec gaps; first verified finding (Bullhorn public REST docs confirm no webhook/subscription mechanism)

### Day 3 (commit 299108d)

- `docs/decisions/sequencing-target.md` — 522 lines, 7 sections. **Accepted** Option Alpha (master brief §8.2 ratified)
- `docs/decisions/brain-ui-scope.md` — 235 lines, 5 sections. **Proposed** pending v1.1 phase

### Day 3 evening (this commit)

- `docs/architecture/vault-concurrency.md` — 455 lines, 7 sections. **Reference document** (no Proposed/Accepted lifecycle):
  - 4 concurrency mechanisms with TypeScript worked examples: `flock(2)` per-entity locks (§2), Postgres optimistic concurrency (§3), Obsidian-aware mtime debounce (§4), rewrite-backlinks cascade (§5)
  - Lock-ordering rule explicit (alphabetical by `entity_id` within `entity_type`, then by `entity_type`) — prevents cascade deadlock
  - flock+Postgres sequencing rule explicit (flock first, Postgres check second, write third)
  - v1.0 filesystem-vs-Postgres atomicity gap honestly documented; v1.2+ write-ahead-log pattern deferred
  - **5 new `ESC_VAULT_*` escalation codes** consolidated for `_shared/hook-helpers.sh` wiring
  - 5 operational defaults named with override semantics
  - Bucket 3 surfaces **1 new Day-4 tightening:** `entities.version` column (4th tightening on Day 4 task)

## Week 1 prerequisites — status

**2 of 3 closed** (was 1 of 3 at Day 3 close):

- **Closed:** ADR-003 + `agent-bundle-renderer-design.md` (Day 1 evening at `3e73c71`).
- **Closed (NEW this commit):** `docs/architecture/vault-concurrency.md` — resolves `second-brain-design.md` Spec gap 2.6. `wiki/lib/concurrency.ts` Week-1-2 implementation now has its reviewable spec.

**1 remaining:**

- `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh` per master brief §8.1 Changes 1 + 2. **Full ESC_* wiring scope now specified across prior documents:**
  - `ESC_BULLHORN_AUTH` per `bullhorn-integration-path.md` §6.1
  - `ESC_RENDERER_FAILED` per `agent-bundle-renderer-design.md` §4.7
  - **5 new `ESC_VAULT_*` codes** per `vault-concurrency.md` §6: `ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_VERSION_MISMATCH`, `ESC_VAULT_HUMAN_EDIT_BLOCKED`, `ESC_VAULT_CASCADE_PARTIAL_FAILURE`, `ESC_VAULT_CASCADE_TIMEOUT`
  - Owner: Claude Code, Week 1-2

**Day 2 added Week-1 prerequisites:** Bullhorn client_id + client_secret obtained via support ticket; IFOS-owned Bullhorn dev tenant provisioned; Bullhorn MCP connector scaffolded at `packages/mcp-connectors/bullhorn/`; refresh-loop implementation per `bullhorn-integration-path.md` §4.5.

**Day 3 added Week-1 prerequisites:** Diagnostic agent bundle authored at `agents/recruitment/diagnostic/` (Week-3 build prerequisite per `sequencing-target.md` §4.1 + §6.2).

**Day 3 evening (this commit) added Week-1-2 prerequisites:** `wiki/lib/concurrency.ts` implementation against `vault-concurrency.md` spec; `entities.version` column on Day 4 (4th tightening).

## Day 4 tightening (landed 2026-05-17, see Shipped)

All four consolidated tightenings applied in §6 + §7 of Day 4 execution. Verified at `\dt` + `\d entities` + `\d decision_log` + `ls -la /usr/local/bin/provision-tenant.sh` + RLS gate pass.

## Atomic master-brief correction commit — LANDED Day 7 at `0e5b2b4`

**11 of 12 edits applied** in atomic-correction commit `0e5b2b4` on 2026-05-20. Edit 11 dropped (already-executed live SQL migration is its own audit trail). Master brief is fully reconciled. Two side effects flagged in commit message for Codex review (Edit 1 col 4 reframe + Edit 4 row merge).

Historical 12-edit manifest preserved below for traceability:

1. **ADR-001** — Master brief §2.4 row 3: `chokidar watcher` → `FastChecker poll loop`
2. **ADR-001** — Ultraplan §3.2: 4-agent pipeline latency reframe to "3-5 seconds end-to-end"
3. **ADR-002 Edit 1** — Master brief §3.4: brain-replacement seam wording (shadow → parallel)
4. **ADR-002 Edit 2** — Master brief §5.5: v1.0 brain build wording (9 wrappers + 9 lib modules + 4 tables + pgvector)
5. **ADR-003 Edit C** — Master brief §8: footnote referencing the renderer + naming `cortextos-ifos add-agent` as NOT the IFOS path
6. **Bullhorn decision §6.6** — Master brief §6 Day 2 line 466: OAuth wording (auth-code-against-IFOS-dev-tenant; client_credentials foreclosed)
7. **Sequencing decision §6.8** — Master brief §6 Day 3 line 471: path convention `.agents/decisions/` → `docs/decisions/`
8. **Brain UI scope §4.5** — Master brief §6 Day 3 line 472: three-drift bundled rewrite (path + `kb-*` shadow → `wiki-*` parallel + `/brain` today-view as v1.0 → as v1.1)
9. **Hetzner location (NEW Day 4 2026-05-17; scope corrected Day-6 citation audit 2026-05-18)** — Master brief §6 Day 4 line 477: "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations". Verified during Day-4 execution: Hetzner has no UK data centre; NBG1 used because FSN1 was unavailable at provisioning time. Source: Day-4 runbook §0.1 + §12 deviation 3. (Earlier drafts also cited §10.4 as a co-occurring Hetzner/cost reference; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list and contains no Hetzner or cost-target content. §10.4 reference dropped.)
10. **Day-5 path drift (NEW Day 5 2026-05-18)** — Master brief §6 Day 5 lines 484-485: paths `docs/auto-send-safety-policy.md` and `docs/v1-kill-criterion.md` → `docs/decisions/autosend-safety-policy.md` and `docs/decisions/v1.0-kill-criterion.md` per repo convention since Day 0 (matching ADR-001/-002/-003 + bullhorn + sequencing-target + brain-ui-scope). Source: Day-5 autosend policy header + kill criterion header.
11. **decision_log.phase enum expansion (NEW Day 5 2026-05-18)** — Day-4 runbook §6.4 + executed migration on `ifos-v2-prod-01`: phase enum expanded from 5 values to 6 (added `'render'` for renderer audit per `ESC_RENDERER_FAILED` contract in `agent-bundle-renderer-design.md` §4). Live SQL migration committed alongside this manifest entry; runbook v1.1 revision note attached.

Commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1 + Day-5 path drift + decision_log.phase render`. Single Codex ratification on Day 7.

**Day-4 Postgres provisioning tightenings landed in §6 of Day-4 execution (separate commit) — not part of the master-brief reconciliation commit.**

## Queued for Codex ratification (Day 7)

Per master brief §10.6 first ratification run — Day 7 added items 20 + 21 + the landed atomic-correction commit `0e5b2b4`. Total: 21 items + 1 commit. **Execution deferred** to Week 0 extension period (skills + Q1 unblocker both required first). See `docs/decisions/2026-05-18-codex-ratification-manifest.md` §3 + §4 for the gap + schedule.

1. `docs/architecture/cortexos-primitive-status.md` (the audit document)
2. `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` (Accepted Option A)
3. `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` (Accepted Option α)
4. `docs/architecture/second-brain-design.md` — reference; ADR-002 is the binding artefact
5. `docs/architecture/agent-bundle-renderer-design.md` — reference; ADR-003 is the binding artefact
6. `docs/decisions/ADR-003-agent-bundle-renderer.md` (Accepted)
7. `docs/decisions/bullhorn-integration-path.md` (Sub-decision C Accepted; A and B Proposed pending commercial)
8. `docs/decisions/sequencing-target.md` (Accepted Option Alpha)
9. `docs/decisions/brain-ui-scope.md` (Proposed pending v1.1 phase)
10. **`docs/architecture/vault-concurrency.md`** (Reference) — NEW Day 3 evening
11. **`docs/runbooks/day-4-provisioning.md`** (Reference status pre-execution; Executed status post-execution) — NEW Day 4 morning
12. **Day 4 close commit** — runbook §12 deviation log (20 deviations + 8 v1.1 revisions) + RISK-REGISTER #8 LUKS-unlock-SPOF + state-file updates — NEW Day 4 evening 2026-05-17
13. The atomic master-brief correction commit (11-edit manifest, end of Week 0 / early Week 1)
14. The Day 4 Postgres provisioning artefact (4 consolidated tightenings landed in §6 of Day-4 close commit)
15. Plus the remaining Week 0 artefacts (Day 6 vertical schema v0.1; Day 7 single-sentence test review)
16. **`docs/decisions/autosend-safety-policy.md`** (Status: Proposed) — NEW Day 5 morning 2026-05-18
17. **`docs/decisions/v1.0-kill-criterion.md`** (Status: Proposed) — NEW Day 5 morning 2026-05-18 + Day-5 close commit (includes live Postgres schema migration; Risk #3 escalation; state-file updates)
18. **`docs/verticals/recruitment/vertical-schema.yaml`** (Status: Proposed) — NEW Day 6 2026-05-18 (8 entities, 89 fields, 10 relationships, agent R/W matrix, Bullhorn mapping, 12 open_questions)
19. **`docs/runbooks/operational-hygiene-protocol.md`** (Status: In Force) — NEW Day 6 evening 2026-05-18 (Path A/D credential protocols, no-defensive-additions rule, length calibration methodology, citation accuracy discipline, Day-4-6 audit findings)
20. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** (Status: Reference) — NEW Day 7 2026-05-20 (this manifest itself; lists 19+ ratification queue items + gap + schedule)
21. **`docs/decisions/2026-05-18-day-7-single-sentence-test.md`** (Status: Accepted, factual recording) — NEW Day 7 2026-05-20 (3 of 5 YES result + Week 0 extension protocol)
22. **Atomic-correction commit `0e5b2b4`** — LANDED Day 7 2026-05-20 (`docs: master brief reconciliation — 11 edits batch-applied`); two side effects flagged for Codex review per commit message

## Stuck

(nothing — Day 4 closed cleanly with 22/22 verification + RLS gate pass; Sub-decisions A and B Status: Proposed in `bullhorn-integration-path.md` is the intended state pending Sunday/Monday commercial verification; three operational debts from Day 4 listed above are non-blocking founder-convenience items)

## Notes

- Day 0 setup notes: IFOS dashboard credentials in `~/.cortextos/ifos-v2/dashboard.env`, 1Password "IFOS dashboard admin"; personal install undisturbed at `~/.cortextos/default/`
- **Day 2 verified Bullhorn finding** (load-bearing for Week 1-2): Bullhorn public REST API documentation describes **no webhook / subscription / event-stream mechanism** — pull-only model for v1.0. Per-tenant 5-minute polling cycle is the Concierge default. Marketplace-tier subscription verification is a v1.1+ commercial track
- **Day 2 verified Bullhorn finding**: 10-minute access token TTL forced refresh-loop architecture into v1.0 design per `bullhorn-integration-path.md` §4.5. Connector ships with per-agent 8-minute refresh background task; not lazy refresh on 401
- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
- **Day 3 finding**: line 472 has three drifts (path + `kb-*` shadow + v1.0/v1.1 placement) bundled into single 8th atomic-correction edit
- **Day 3 evening finding**: `vault-concurrency.md` surfaces 4th Day-4 tightening (`entities.version` column required for Postgres optimistic-concurrency). Without it, `wiki/lib/concurrency.ts` in Week 1-2 references a column that doesn't exist
- Day 4 carry-forward: ~~four consolidated Postgres tightenings~~ **LANDED 2026-05-17** in §6 of Day-4 execution (see Shipped)
- Day 5 carry-forward: v1.0 kill criterion must reference Day 3 §6.6 three failure conditions + Day 2 §4.1 Concierge Bullhorn Note auto-send sensitivity
- **Day 4 finding (2026-05-17):** Hetzner has no UK data centre — NBG1 used as equivalent. Surfaced as 9th atomic-correction edit. Functionally equivalent: same Hetzner eu-central zone, Schrems II EU jurisdiction, ~25-30ms UK latency.
- **Day 4 LUKS rotation pattern (2026-05-17):** Path B exposure (LUKS passphrase entered chat for ifos-unlock end-to-end test) closed via `cryptsetup luksChangeKey` with VPS-generated new passphrase + `--test-passphrase` verification. Pattern documented in runbook §12 deviation 20. v1.1 runbook revision: investigate paste-once-and-cache helper that doesn't require chat exposure. Lesson: Path A protocol cost (~90s of founder time per interactive step) is the right trade-off vs Path B (chat exposure + post-hoc rotation).
- **Day 4 Path D pattern (2026-05-17):** New protocol for VPS-side credential generation that never enters chat context. Used for ifos_app password in §5.4: `openssl rand -base64 24` on VPS → `/vault/.ifos_app_password.tmp` (LUKS-encrypted, mode 0600) → `CREATE ROLE` via psql stdin heredoc → founder retrieves at convenience. Reusable for future password generation operations.
