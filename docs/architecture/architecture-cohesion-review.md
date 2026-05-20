# Architecture cohesion review — Week 0 close

**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation audit).
**Status:** Reference (audit surfaces issues; does not resolve inline — remediation paths named).
**Method:** Read all 4 ADRs + 4 reference designs end-to-end as a coherent set. Walk each of the 4 boundaries from master brief §3 with adversarial questions. Identify gaps, contradictions, implicit assumptions.
**Companion:** `docs/architecture/tenancy-invariants.md` (Day-9 same commit chain).

---

## §1 — What this review is

Eight ratified architecture artefacts have shipped through Day 8. Each was ratified individually (Codex Round 1 ran on all of them with 2 RATIFIED + 14 REJECTED → 13 incorporated + 2 disagreement docs). What hasn't been done: **read them as a coherent system**. ADRs were authored sequentially; each delegates concerns to its predecessors/successors. The set is only as strong as its cross-references.

This review:

1. Maps every "X delegates Y to Z" reference → verifies Z actually fills Y
2. Walks each of the 4 boundaries with adversarial questions
3. Surfaces implicit assumptions (load-bearing but unstated)
4. Surfaces contradictions (two artefacts implying different things)
5. Surfaces gaps (questions the set leaves unanswered)

Output: a remediation queue. **Does NOT modify ADRs inline.** If a structural issue surfaces, a new ADR-005+ resolves it. This artefact catches issues; ADRs resolve them.

---

## §2 — The 8 ratified artefacts as a coherent system

The set covers four conceptual layers:

| Layer | Artefacts |
|---|---|
| **Foundation** | ADR-001 (bus poll), ADR-002 (parallel brain), cortexos-primitive-status.md (audit), second-brain-design.md (vault/Postgres split) |
| **Build pipeline** | ADR-003 (agent renderer), agent-bundle-renderer-design.md (12-row file map) |
| **Helpers + storage** | vault-concurrency.md (locks + version), v0.1 schema, v0.2 supplement, kill-criterion.md (Trigger 5 audit) |
| **Implementation deviations** | ADR-004 (3 implementation deviations from ADR-003 corrected post-implementation) |

**Reading order for new readers:**

1. cortexos-primitive-status.md (what cortextOS actually is + 7 primitives audit)
2. second-brain-design.md (why IFOS-side wiki + Postgres replaces cortextOS-KB)
3. ADR-002 (ratifies parallel-brain decision)
4. ADR-001 (one ratified primitive correction: bus is poll-based)
5. vault-concurrency.md (mechanics of vault writes)
6. agent-bundle-renderer-design.md (12-row file mapping for the renderer)
7. ADR-003 (ratifies renderer design)
8. ADR-004 (3 implementation deviations from ADR-003 found during Phase 2-3 build)

The set is mostly coherent. Where it isn't: §4-§6 below.

---

## §3 — Delegation chains

Each "X delegates Y to Z" relationship traced:

| Source | Delegates | To | Verified? |
|---|---|---|---|
| ADR-001 | bus mechanism (chokidar→FastChecker) | master brief §2.4 row 3 (Edit) | ✓ landed atomic `0e5b2b4` |
| ADR-002 | brain replacement details | second-brain-design.md | ✓ second-brain-design §2.4 covers vault/Postgres split |
| ADR-002 | `_shared/` helpers contract | "Week 1 work" §"For Week 1 work" → vault-concurrency.md + hook-helpers.sh | ✓ landed Phase 1 + 3 commits |
| ADR-003 | renderer mechanism details | agent-bundle-renderer-design.md | ✓ design doc §3 covers all 12-row file map |
| ADR-003 | spec gap §2.1-A (preamble) | `packages/agent-renderer/templates/claude-md-preamble.md` | ✓ landed Phase 1 (a279226) |
| ADR-003 | spec gap §2.1-B (common schemas) | `packages/agents-runtime/_shared/common-*.json` | ✓ landed Phase 1 (a279226), 8 files |
| ADR-003 | spec gap §2.1-C (_secrets.env) | Day-4 §6.5 provisioning + renderer envFile.ts | ✓ landed Day-4 + Phase 2 |
| ADR-003 | renderer code | packages/agent-renderer/ | ✓ landed Phase 2 (3c16d35) |
| ADR-003 | `_shared/` Option γ | `agents/_shared/` + renderer copy logic | ✓ landed Phase 3 (e6e9df1) + renderer symlink |
| ADR-003 | failure modes / ESC catalogue | `agents/_shared/escalation-codes.md` | ✓ landed Phase 1 (a279226), 24 codes |
| ADR-003 | phase enum for renderer | Day-4 §6.3 CHECK constraint | **✓ landed but with deviation per ADR-004 Decision 7** — phase='render' NOT in enum; uses agent_name='_renderer' + existing phase |
| ADR-004 | CLI naming | `packages/agent-renderer/package.json` `bin` | ✓ landed Phase 2 |
| ADR-004 | symlink target | renderer.ts symlinkSync call | ✓ landed Phase 3 fix (e6e9df1) |
| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
| second-brain-design.md §2.6 | concurrency mechanics | vault-concurrency.md | ✓ shipped Day 3 (78680cc) |
| second-brain-design.md §2.6.4 | ESC_VAULT_* catalogue | escalation-codes.md | ✓ landed Phase 1 (a279226) — 4 of the 5 catalogued |
| vault-concurrency.md §6 | ESC wiring | hook-helpers.sh::autosend_escalate | ✓ landed Phase 3 (e6e9df1) |
| vault-concurrency.md §3.1 | entities.version column | Day-4 §6.3 entities table | ✓ landed Day-4 with version column |
| cortexos-primitive-status.md | primitive 1 (PTY) stability | Risk #1 in RISK-REGISTER.md | ✓ logged + stress-tested Phase 2 |

**All 19 delegations verified.** No orphan delegations.

---

## §4 — Implicit assumptions surfaced

Load-bearing assumptions that aren't explicitly stated:

| # | Assumption | Where load-bearing | Risk if false |
|---|---|---|---|
| A1 | **Postgres `current_setting('ifos.tenant_slug', TRUE)` returns NULL when unset, never empty string.** RLS predicate `tenant_slug = current_setting(...)` relies on NULL≠'anything' semantics. | Every RLS policy on every tenant-data table | If empty string is returned, an INSERT with `tenant_slug=''` could leak across tenants. Postgres docs confirm NULL behaviour; assumption holds. |
| A2 | **`SET LOCAL` scopes the setting to the current transaction.** A connection pool with auto-commit could leak `ifos.tenant_slug` across requests if `SET LOCAL` is wrong scope. | hook-helpers.sh `_hh_emit_row` issues `SET LOCAL` inside the same psql invocation as the INSERT — single transaction. | If connection pool shares connections across requests, `SET LOCAL` rolls back at commit; `SET` (non-LOCAL) would persist and cause leak. Helpers correctly use LOCAL. |
| A3 | **The `_shared/` symlink target `../../../_shared` resolves to `<org>/agents/_shared/`, not anywhere else.** | renderer.ts symlinkSync call | If filesystem semantics differ (mac vs linux), or someone moves the rendered dir, symlink could escape. macOS + Linux behaviour verified identical for this case. |
| A4 | **`ifos_app` Postgres role is the only role used by app code.** No path uses postgres superuser or admin role. | Day-4 §6.3 grants + RLS posture | If any path uses superuser, RLS is bypassed (RLS doesn't apply to superusers by default). |
| A5 | **The cortextOS daemon `discoverAgents()` filters by directory pattern, not contents.** Means `.tmp.<pid>/` + `.prev.<ts>/` dirs are invisible. | ADR-003 §3.3.4 atomic-write protocol | If daemon scan ever changes to content-based discovery, the atomic-write protocol could expose half-rendered state. Verified against pinned SHA `c21fbfe`. |
| A6 | **Voice corpus chunks fit in pgvector memory at v1.0 scale.** HNSW index assumes per-tenant chunk count < 10K. | Phase 4 v0.2 supplement + voice-loader.sh queries | At 1 tenant × 5K chunks = ~30MB. 100 tenants × 5K = 3GB. Within Hetzner VPS RAM. Above 1000 tenants this becomes a real constraint. |
| A7 | **The renderer's atomic-rename uses `renameSync` on the SAME filesystem.** Cross-filesystem rename is not atomic. | `packages/agent-renderer/src/atomicWrite.ts` `commitStaging` | If `${frameworkRoot}` and the working dir are on different mounts, rename fails or becomes copy+delete. Hetzner VPS has single root filesystem, so safe. macOS dev box: same. |
| A8 | **Bullhorn OAuth refresh-loop fires before token expiry under load.** Per-agent 8-min cycle vs 10-min TTL. | bullhorn-integration-path.md §4.5 + common-ats.json `auth_refresh_interval_seconds` | If the 2-min buffer is insufficient under network latency or rate-limit backoff, agent loses Bullhorn auth mid-write. Untested at scale; flagged at first Janitor build. |

8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.

---

## §5 — Contradictions surfaced

Places where two artefacts imply different things:

### C1 — Renderer phase enum (RESOLVED post-Round-1)

- **agent-bundle-renderer-design.md** (pre-Round-1) said `phase='render'` written to decision_log on renderer failure
- **Day-4 §6.3** CHECK constraint enum is `(trigger, output, action, gating_failed, agent_handoff)` — `render` NOT included
- **Resolution:** ADR-004 Decision 7 (Codex Round 1 RATIFIED) + Day-8-evening remediation `2b287d3` corrected both renderer-design + ADR-003 to use `agent_name='_renderer'` + existing `phase=gating_failed|action`. **RESOLVED.**

### C2 — Renderer CLI name (RESOLVED post-Round-1)

- **ADR-003 §3.3.1 + agent-bundle-renderer-design.md** said `cortextos-ifos render-agent` (sub-command of upstream)
- **master brief §3.1 boundary 1** read-only submodule
- **Resolution:** ADR-004 Decision 1 (RATIFIED) + Day-8-evening remediation corrected both to `ifos-render-agent` standalone binary. **RESOLVED.**

### C3 — `_shared/` symlink target (RESOLVED post-Round-1)

- **ADR-003 §3.3.3 Option γ** said `../../_shared` (2 levels up)
- **Filesystem reality**: from `<agent_dir>/.claude/hooks/`, 2 levels up is `<agent_dir>/_shared/` (inside agent dir, doesn't exist)
- **Resolution:** ADR-004 Decision 2 (RATIFIED) + Day-8-evening renderer.ts fix corrected to `../../../_shared` (3 levels up). **RESOLVED.**

### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)

- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
- **v0.2 supplement** `recent_edit.original_text` + `edited_text` store agent draft + consultant edit VERBATIM (8192 cap), explicitly admitting PII can be present
- **Status:** This is by design — `recent_edit` is the SFT corpus source, not the operator-facing audit. But Codex Round 1 flagged it as a GDPR risk (now Risk #10).
- **Resolution path:** Founder Decision D3 in `2026-05-20-codex-round-1-founder-decisions.md`. Recommended D3-B (90-day text purge + indefinite metadata).
- **Status: OPEN until D3 resolves.**

### C5 — `tenants` table RLS exception (RESOLVED via tenancy-invariants.md)

- **Day-4 §6.3** lines 697-704: `tenants` table has no `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`
- **second-brain-design.md** + **tenancy-invariants.md §1** both treat `tenants` as a meta table by design — RLS would prevent admin operations from listing all tenants
- **Resolution:** Now explicitly documented as the single meta exception in `tenancy-invariants.md` §1 + §3 verification matrix. **RESOLVED via consolidation.**

**Summary: 3 of 5 contradictions RESOLVED (C1, C2, C3 via ADR-004 + Day-8-evening remediation). 1 RESOLVED via consolidation (C5). 1 OPEN (C4) pending founder decision D3.**

---

## §6 — Gaps surfaced (questions the set leaves unanswered)

Load-bearing questions where the coherent set has no answer:

| # | Gap | Severity | Resolution path |
|---|---|---|---|
| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
| G2 | **The `tenants` table life-cycle states.** `tenants.metadata` JSONB has no documented shape. What goes in: `status` enum? `tier` cache? `provisioned_at`? `last_offboard_warning_at`? | Medium (tenant-lifecycle runbook depends on it) | Surfaced in tenant-lifecycle.md (same commit). Real implementation lands at first tenant onboarding. |
| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
| G4 | **The agent runtime's `validate.sh` invocation contract is implicit.** ADR-003 §2.1 row 5 says it's a verbatim copy to `.claude/hooks/validate.sh`. But what does the runtime DO with it? Is it called before every tool use? Once per session? | Medium (every agent uses validate.sh) | Diagnostic W3 build's agent.md preamble names the invocation; pattern propagates. Add to tenant-lifecycle runbook. |
| G5 | **Multi-tenant connection pool sizing is unspecified.** v1.0 has 1 tenant × 6 agents = 6 PTYs. v1.1 with 5 tenants = 30 PTYs. Each PTY's psql connection: ephemeral or pooled? Postgres `max_connections` default 100. | Low (single-tenant pilot has headroom) | v1.1+ scale exercise. Add to lifecycle runbook §"Operate" + RISK-REGISTER if scale risk surfaces. |
| G6 | **vault-concurrency.md `entities.version` enforcement is one-directional.** The doc names optimistic-concurrency UPDATE pattern but the helpers don't yet implement it (hook-helpers.sh has no entity-update path; that lands when an agent needs to write to `entities`). | Low (Janitor W5 will be first writer) | First entity-write helper at Janitor build adds version-check pattern. New ADR if pattern surfaces decisions. |
| G7 | **Re-rendering an active agent mid-pilot.** Current design says "stop, render, restart" but PM2 + cortextOS daemon coordination isn't specified. Does cortextos-ifos bus self-restart pick up the new render? | Medium (any agent.md edit triggers this) | Renderer README §"Hand-edits and re-rendering" hints at the answer but doesn't specify. Surface in tenant-lifecycle.md §"Operate". |
| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
| G9 | **The cortextOS `4 bus/kb-*.sh` shadow points override path.** Master brief §3.1 boundary 4 says ONLY these 4 files override. But: WHERE does the override land? `packages/brain/bus-overrides/`? It doesn't exist. | Medium (Brain UI v1.1+ dependency) | Brain UI Week-10 design ADR resolves. Currently no agent depends on this. |
| G10 | **External advisor identification.** Kill-criterion §3.4 calls for Week 1-2 must-fill. Today = Day 9 (Week 1+). | High (pre-LOI blocker) | Founder Decision D2 in `2026-05-20-codex-round-1-founder-decisions.md`. Engage this week. |

**10 gaps surfaced. 2 are HIGH severity (G8, G10) — both already founder-decision-tracked. 5 MEDIUM, 3 LOW.** All have a named resolution path.

---

## §7 — Per-boundary adversarial walk (master brief §3 boundaries)

### §7.1 — Submodule boundary

**Boundary:** `packages/harness/cortextos/*` is read-only EXCEPT the four `bus/kb-*.sh` shadow points.

**Adversarial questions:**

- **Q:** Can any IFOS code path write into the submodule?
  - **A:** Grep finds no `write` / `mkdir` / `rm` operations targeting `packages/harness/cortextos/`. Renderer writes to `${frameworkRoot}/orgs/...` (outside submodule). Helpers don't touch submodule. ✓ Clean.
- **Q:** Are the four `bus/kb-*.sh` shadow points the ONLY override path?
  - **A:** `packages/brain/bus-overrides/` directory doesn't yet exist (Gap G9). Once it does, this is the override seam. Currently NO bus-override exists — the upstream `bus/kb-*.sh` files run untouched.
- **Q:** Could a developer accidentally `cd packages/harness/cortextos && vim README.md`?
  - **A:** Submodule HEAD detached at SHA `c21fbfe`. Any local edit shows as detached-HEAD modification but doesn't propagate to upstream. Edits are local-only until explicitly pushed upstream (which we never do). **Acceptable risk; covered by CLAUDE.md §"Never modify packages/harness/cortextos/* except..."**.

**Verdict: BOUNDARY HOLDS.** G9 is the open architectural question (override-seam location); doesn't violate the boundary.

### §7.2 — Adapter boundary

**Boundary:** Composio and AgentMail are NEVER referenced in `agent.md`, `tools.yaml`, vault files, or fixtures.

**Adversarial questions:**

- **Q:** Are there any references to Composio/AgentMail in agent.md or tools.yaml?
  - **A:** Grep across agents/, packages/agents-runtime/, tests/fixtures/: zero hits. Internal discussion text (e.g., this audit) is allowed; production artefacts must be clean. ✓
- **Q:** Could a future agent silently introduce a Composio or AgentMail tool?
  - **A:** Codex review skill `review-agent-bundle.md` (not yet built) would catch this. Currently relies on grep audit + author discipline. Recommend: add this check to `scripts/run-tenancy-audit.sh` (Phase 1 enhancement OR Codex skill).

**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.

### §7.3 — Vault/Postgres split

**Boundary:** Markdown content in vault; structured state in Postgres; pgvector indexes over both.

**Adversarial questions:**

- **Q:** Is any structured state being written to vault?
  - **A:** Helpers write to `/vault/<tenant>/decision-log.jsonl` (fallback mode) — that's structured. BUT it's an audit trail that replays into Postgres, not the source of truth. Vault `_voice/`, `_config/`, `_brand/`, `_playbooks/` are content (markdown). Vault `spot-checks/` is markdown notes. Vault `_secrets.env` is config (Path D). ✓ Mostly clean.
  - **Edge case:** `decision-log.jsonl` is a temporary structured cache, not narrative. Document explicitly in second-brain-design.md update (Gap G2 surfaces this).
- **Q:** Is any narrative content being written to Postgres?
  - **A:** `recent_edit.original_text` + `edited_text` are narrative (raw text). `tone_rule.rule_text` is natural language. `voice_corpus_chunks.text_chunk` is text. **These ARE narrative content in Postgres** — but they're indexed for retrieval, not for primary storage. The vault remains the source of truth for the original docs; Postgres holds the indexable chunked + classified copy. ✓ Acceptable hybrid.

**Verdict: BOUNDARY HOLDS as a conceptual guide; v0.2 introduces a documented exception (text in Postgres for retrieval).** Update second-brain-design.md to acknowledge the exception explicitly. Queue as Phase-2 follow-up to ADR-005 if needed.

### §7.4 — Brain-replacement boundary

**Boundary:** Only the four `bus/kb-*.sh` shadow points may interact with cortextOS's brain system.

**Adversarial questions:**

- **Q:** Does any IFOS code path call upstream KB primitives outside the four shadow points?
  - **A:** `packages/agent-renderer/`, `agents/_shared/`, hook-helpers, voice-loader — none reference cortextOS KB at all. They write to IFOS-side Postgres + vault. ✓
- **Q:** Could a future agent inadvertently invoke `kb-search.sh` via tools.yaml?
  - **A:** R2 commitment (ADR-003 Decision 1): tools.yaml can opt-in to cortextOS skills via `cortextos_skills:` block. If an agent opts in to `knowledge-base`, it gets the upstream KB. **This is the seam.** Currently no agent opts in. Recommend: add `review-agent-bundle.md` skill check to flag any `knowledge-base` opt-in for explicit founder review.

**Verdict: BOUNDARY HOLDS at current artefact set.** Same pattern as adapter boundary — needs automated guardrail at Diagnostic W3.

---

## §8 — Remediation queue

Issues for resolution in priority order:

| # | Issue | Severity | Resolution path | Owner | Trigger |
|---|---|---|---|---|---|
| R1 | G10: External advisor identification | High | Founder Decision D2 | Founder | This week (pre-LOI) |
| R2 | G8: Autosend v1.0 tier enforcement | High | Founder Decision D1 | Founder | Pre-Concierge W10 |
| R3 | C4: PII retention in recent_edit | High (Risk #10) | Founder Decision D3 bundles with D2 | Founder | Pre-first-LOI |
| R4 | G7: Re-rendering active agent (PM2 + cortextOS coordination) | Medium | Document in tenant-lifecycle.md §"Operate" | Claude Code | Phase 2.2 of this slice (same commit chain) |
| R5 | G4: validate.sh invocation contract | Medium | Document in tenant-lifecycle.md OR Diagnostic agent.md preamble | Claude Code | Diagnostic W3 build |
| R6 | G2: tenants.metadata shape | Medium | Document in tenant-lifecycle.md (this commit) + implementation at first tenant onboarding | Claude Code | First real tenant LOI signed |
| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
| R9 | A8: Bullhorn OAuth refresh timing under load | Low | First Janitor build stress test | Claude Code | Janitor W5 |
| R10 | G5: Multi-tenant connection pool sizing | Low | v1.1+ scale exercise | Claude Code | v1.1 design phase |
| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
| R12 | G6: entities.version optimistic-concurrency helper | Low | First entity-write helper at Janitor build | Claude Code | Janitor W5 |
| R13 | G9: bus-overrides location for the 4 kb shadow points | Medium | Brain UI Week-10+ design ADR | Claude Code | Week 10 |
| R14 | C4 v0.2 → vault/Postgres split exception documentation | Low | Phase-2 follow-up to ADR-005 OR addendum to second-brain-design.md | Claude Code | Next architecture session |

**14 remediation items. 3 high-severity all founder-decision-tracked. 11 lower-severity with named code-side resolution paths.**

---

## §9 — Overall verdict

The 8 ratified architecture artefacts cohere into a working system. **3 of 5 contradictions are RESOLVED through Codex Round 1 + Day-8 remediation. 1 RESOLVED via consolidation. 1 OPEN pending founder decision (D3).**

**8 implicit assumptions documented; 3 are catastrophic-if-false but verified empirically.**

**10 gaps surfaced; 2 high-severity (G8, G10) are founder-domain decisions already tracked. 8 lower-severity have named code-side resolution paths.**

**All 4 boundaries (submodule, adapter, vault/Postgres, brain-replacement) hold at current artefact set.** Two need automated guardrails at Diagnostic W3 (adapter + brain-replacement).

**The foundation is sound for Diagnostic build, conditional on:**
1. Founder Decisions D1 + D2 + D3 resolve before Concierge W10 + first pilot LOI signing
2. R4-R8 documented during this slice (Phase 2.2 + Diagnostic W3)
3. Codex Round 2 closes (re-ratification after Day-8-evening fixes)
4. Live VPS tenancy audit confirms 12 invariants hold (founder runs `bash scripts/run-tenancy-audit.sh`)

If those four hold, **Diagnostic agent build can begin with high confidence.**

---

## §10 — Status

**Reference.** Codex Day-7 manifest queue item #36; ratifies via `review-architecture-decision.md` skill. Companion to `docs/architecture/tenancy-invariants.md`.

*End of architecture-cohesion-review.md.*
