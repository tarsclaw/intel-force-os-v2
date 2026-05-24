# /goal — Week 3: Diagnostic polish + 5 agent.md scaffolds + Codex ratification

**Type:** Goal prompt (paste into Claude Code at session start; executor runs to completion across Days 14-20)
**Authored:** 2026-05-24 (Day 13 evening; for execution Days 14-20)
**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
**Quality bar:** Production-quality. Each agent.md is presentable to Codex for ratification on first submission. Every spec citation verified against the source files. No speculative content; everything cited line-anchored.
**Maps to:** Day-13 (today) → Day-20 (end of Week 3). 7-day execution window.
**Builds on:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 Diagnostic v0 — completed at commit `97a57a2`).

---

## §0 — Mandatory reading order

Before writing any code, the executor reads these in order and confirms each in chat:

1. **`CLAUDE.md`** at repo root — instance scoping + five rules + four boundaries
2. **`.agents/current-priorities.md`** Open + Shipped (Day-13) sections
3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §6 Day 4-7 (foundation state) + §8 (build sequence) + §10.5 (always-ratify artefacts)
4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
5. **`docs/specs/PRODUCT-SPEC.md`** §0-§4 (what we are building) + §5.3 (`_shared/` common schemas)
6. **`docs/decisions/sequencing-target.md`** §3.1 (build waves) + §6.6 (failure conditions)
7. **`docs/decisions/v1.0-kill-criterion.md`** §2 Triggers 1-10 (deadline awareness) + §3 (authority structure)
8. **`docs/decisions/bullhorn-integration-path.md`** §1.3 (commercial-blocker table) + §1.4 (fallback architecture) + §4.1 (per-agent Bullhorn surface)
9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
10. **`docs/decisions/ADR-003-agent-bundle-renderer.md`** + **`docs/architecture/agent-bundle-renderer-design.md`** (bundle pattern: 6 files + 3 fixtures)
11. **`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`** (today's sequencing change)
12. **`agents/recruitment/diagnostic/agent.md`** in full (the gold-standard agent.md to model from)
13. **`agents/_shared/escalation-codes.md`** (24 active ESC codes)
14. **`agents/_shared/autosend-policy.yaml`** (29 action types; tier classifications)
15. **`docs/verticals/recruitment/vertical-schema.yaml`** (8 v1.0 entities + agent R/W matrix)
16. **`docs/operations/goal-option-c-diagnostic-end-to-end.md`** (Day-13 Diagnostic build; reference for Week-3 polish steps)

After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**

---

## §1 — Success state (what "done" looks like at end of Day 20)

When this goal is complete, the following are ALL TRUE:

### Diagnostic polish (Days 14-15)

1. **Companies House data flows end-to-end.** Founder has registered the API key (Step 2). Re-running cycle.sh against Hays plc produces §1 + §10 + §11 with REAL CH data (not "no registration found"). Updated artefact at `docs/artefacts/diagnostic-hays-plc-2026-05-2X.md`.
2. **LinkedIn slug suffix-stripping landed.** The web-scraper's online-footprint section now correctly tries `linkedin.com/company/hays` BEFORE `linkedin.com/company/hays-plc`. Hays's LinkedIn page is found.
3. **§12 conversation opener is LLM-driven, not deterministic.** Calls Claude API (or OpenAI fallback) with §1-§11 context + tenant voice corpus + tone rules. Voice classifier microservice STUB in place (real classifier W4-5; for now: skip-with-warning preserved).
4. **Diagnostic bundle ratified by Codex.** Round 4 ratification run against agent.md + 5 siblings + 3 fixtures via `review-architecture-decision.md` skill. Verdict: RATIFIED (or remediation-pass if needed).

### 5 agent.md output contracts (Days 16-19)

5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).

Each agent.md has the same 10-section structure as Diagnostic:
- §1 Output contract (one-paragraph screenshot per master brief §1 Rule 1)
- §2 Invocation surface (CLI + v1.1+ deferred surfaces)
- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
- §4 Workflow (n-step process; each step cites the tools.yaml capability or `_shared/` helper it depends on)
- §5 Gates (A: validate.sh hard-fail conditions; B: outcome success threshold)
- §6 Escalation codes (subset of `agents/_shared/escalation-codes.md` relevant to this agent)
- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
- §8 Build dependencies (prerequisites that must clear before W-X build begins)
- §9 Status + open questions for founder review
- §10 When this document ratifies + Codex skill reference

### Codex ratification (Day 20)

10. **Round 4 ratification run executed** via `bash scripts/run-codex-ratification.sh` with the manifest extended to include 6 new artefacts (Diagnostic agent.md re-ratify + 5 new agent.md scaffolds).
11. **All 6 verdicts captured** in `logs/codex-ratification/round-4/`. Per-artefact RATIFIED / NEEDS-REMEDIATION / REJECTED.
12. **Remediation pass** runs if any artefacts return REJECTED — mechanical fixes only; founder-decision-bound items annotated and skipped.

### State + audit (Day 20)

13. **`.agents/current-priorities.md`** updated with Day-14 through Day-20 Shipped section.
14. **`docs/RISK-REGISTER.md`** updated: Risk #2 (Bullhorn) blast radius confirmed reduced; Risk #5 (Renderer) state per Diagnostic ratification.
15. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue extended with Round-4 items (queue: 43 → 49).
16. **All commits pushed.** No local-only work. Each commit cites the master plan line numbers that justify it.

---

## §2 — Scope: what's IN, what's OUT

### IN scope (must complete)

| Item | Why |
|---|---|
| Diagnostic CH integration with real key | Goal §1 criterion 1; brings §1/§10/§11 from degraded → full |
| LinkedIn slug suffix-strip (already partially applied to web; extend to LinkedIn URL guess) | Goal §1 criterion 2 |
| §12 LLM-driven opener via Claude API | Goal §1 criterion 3; replaces deterministic v0 |
| Diagnostic Codex ratification | Master brief §10.5 always-ratify |
| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
| Codex Round 4 execution | Master brief §10.6 ratification cadence |
| State + risk + manifest updates | Operational hygiene §6 section-gate discipline |

### OUT of scope (don't touch in Week 3)

| Item | Reason |
|---|---|
| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
| Bullhorn MCP connector wiring | Gated on Bullhorn Sub-decisions A+B response (sent 2026-05-24; expect 2-5 business days; if arrives mid-week, fold update into the relevant agent.md but do NOT start connector code) |
| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
| Fathom/Fireflies MCP connector | Reserved for W6 |
| Proxycurl signup | Founder commercial action; gated on founder decision (cost ~$39/mo); if founder approves mid-week, wire LinkedIn deep data into Diagnostic |
| Voice classifier microservice | Reserved for W4-5 polish; for Week 3, §12 LLM call skips voice-classifier gate (V3 stays as a skipped-with-warning) |
| Tenant onboarding outside migration-test | Single-tenant scope; production tenant onboarding happens post-Q1-LOI |
| Legal / SeedLegals / ICO | Founder action; reserve for founder's own time per the legal self-execute method |
| Modifying ratified ADRs 001-005 | Audit trail; ADR-006+ if new architectural decisions surface during Week 3 |
| Modifying `_shared/hook-helpers.sh` or `_shared/voice-loader.sh` beyond bug fixes | These are foundational substrate; 29/29 tests pass; treat as stable |
| Building any new Codex ratification skill (e.g., `review-agent-bundle.md`) | Defer per execution-plan §3 lazy; agent.md ratification uses existing `review-architecture-decision.md` skill |
| URLs cited without verification | Day-12 lesson: every external URL or vendor contact path is curl-verified before landing in any doc |

---

## §3 — Path A discipline reminder

Credentials needed from founder during Week 3:

| Step | Credential | Path A protocol |
|---|---|---|
| Step 2 | Companies House API key | Founder registers self-service at `https://developer.company-information.service.gov.uk/`; saves to `/vault/migration-test/_secrets.env` (VPS) OR `~/.ifos-local-vault/migration-test/_secrets.env` (local). NEVER pasted in chat. |
| Step 6 | Claude API key (Anthropic) for §12 LLM-driven opener | Founder uses existing key OR registers new at `https://console.anthropic.com/`. Saves to same `_secrets.env`. NEVER in chat. |
| Step 11 | Codex CLI auth | Founder runs `codex auth login` once. Token persists in `~/.codex/auth.json`. |

When the executor reaches a credential gate:

1. STOP executing.
2. State: "Founder action needed: <specific credential>. Register at: <verified URL>. Save command: `<exact bash command with placeholder>`. Confirm 'key saved' when done; DO NOT paste the key in chat."
3. Wait for founder confirmation ("done" / "key saved").
4. Resume.

**NEVER** ask the founder to paste the key. **NEVER** echo the key after they confirm. **NEVER** commit `_secrets.env`. **NEVER** include keys in commit messages, error logs, or comments.

---

## §4 — Execution plan (14 steps, ~7-day window; commit per step)

### DAY 14 — Diagnostic polish substrate (Steps 1-5)

#### Step 1 — Pull master + verify substrate state (~15 min)

```bash
cd ~/code/CortexOS
git pull origin main
pnpm install
# Build all 3 packages so workspace deps resolve
(cd packages/utilities/web-scraper && pnpm build)
(cd packages/mcp-connectors/companies-house && pnpm build)
(cd packages/diagnostic-generator && pnpm build)
# Verify Day-13 test counts still green
(cd packages/utilities/web-scraper && pnpm test) | tail -3
(cd packages/mcp-connectors/companies-house && pnpm test) | tail -3
(cd packages/diagnostic-generator && pnpm test) | tail -3
bash agents/_shared/tests/test-hook-helpers.sh | tail -3
bash agents/_shared/tests/test-voice-loader.sh | tail -3
```

Acceptance: 12 + 13 + 3 + 20 + 9 = 57 tests pass.

Commit (only if any incidental fixes): `chore(week-3): substrate verification before polish slice`

#### Step 2 — Founder gate: Companies House API key registration

STOP. Output to founder:

> Founder action needed: register for Companies House API key at `https://developer.company-information.service.gov.uk/` (verified 2026-05-24). 15 minutes self-service. Save the key via SSH to the VPS:
>
> ```bash
> ssh -i ~/.ssh/ifos_hetzner_ed25519 maddox@178.105.87.24
> echo 'COMPANIES_HOUSE_API_KEY=<your-key>' | sudo tee -a /vault/migration-test/_secrets.env > /dev/null
> sudo chmod 600 /vault/migration-test/_secrets.env
> exit
> ```
>
> OR for local-only testing:
>
> ```bash
> echo 'COMPANIES_HOUSE_API_KEY=<your-key>' > ~/.ifos-local-vault/migration-test/_secrets.env
> chmod 600 ~/.ifos-local-vault/migration-test/_secrets.env
> ```
>
> Confirm "key saved" when done. DO NOT paste the key in chat.

Wait for founder confirmation. Then resume.

#### Step 3 — LinkedIn slug suffix-strip extension (~30 min)

Edit `packages/diagnostic-generator/src/sections/online-footprint.ts`:

1. Apply suffix-stripping to the LinkedIn URL candidate generation (currently only applied to website domain check). After: "Hays plc" tries `https://www.linkedin.com/company/hays/` BEFORE `https://www.linkedin.com/company/hays-plc/`.
2. Return the FIRST reachable URL as `linkedInUrl`; mark `linkedInReachable=true` for HTTP 200 OR 999 (LinkedIn bot-detect response).
3. Add a unit test in `tests/online-footprint.test.ts` confirming suffix-strip works for "Hays plc" → tries hays first.

```bash
pnpm test --filter @ifos/diagnostic-generator
pnpm typecheck --filter @ifos/diagnostic-generator
```

Commit: `fix(diagnostic): LinkedIn slug suffix-strip — Hays plc → linkedin.com/company/hays`

#### Step 4 — §12 LLM-driven conversation opener (~2 hours)

Edit `packages/diagnostic-generator/src/sections/conversation-opener.ts`:

1. Add `@anthropic-ai/sdk` as a dependency in `package.json`. Run `pnpm install`.
2. Replace `renderConversationOpener` deterministic logic with an LLM call:
   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
   - **Model:** `claude-opus-4-7` (per latest model knowledge cutoff; verify by curl-checking `https://docs.claude.com/en/docs/about-claude/models`).
   - **Cache:** include `cache_control: { type: "ephemeral" }` on the system prompt + context blocks per claude-api skill conventions.
   - **Output:** 2-3 sentence opener; evidence-anchored.
   - **Retry:** if response shape malformed, retry once; if still bad, fall back to deterministic logic + emit `ESC_VOICE_DRIFT` warning row.
3. Voice classifier integration: STUB — `IFOS_VOICE_CLASSIFIER_URL` unset means skip-with-warning (preserves V3 behaviour). Real classifier wires up at W4-5.
4. Add 3 unit tests in `tests/conversation-opener.test.ts`:
   - LLM call returns valid 2-sentence opener
   - LLM failure → deterministic fallback
   - Tone-rule violation in LLM output → retry then ESC_VOICE_DRIFT
5. Update `cycle.sh` to require `ANTHROPIC_API_KEY` from `_secrets.env` (same pattern as `COMPANIES_HOUSE_API_KEY`).

```bash
pnpm test --filter @ifos/diagnostic-generator
pnpm typecheck --filter @ifos/diagnostic-generator
pnpm build --filter @ifos/diagnostic-generator
```

Commit: `feat(diagnostic): §12 LLM-driven conversation opener with voice-corpus context`

#### Step 5 — Re-smoke Hays with real CH key + LLM (~10 min)

```bash
rm -rf ~/.ifos-cache
rm -f ~/.ifos-local-vault/migration-test/diagnostic-reports/*.md
export IFOS_REPO_ROOT=$(pwd)
export CTX_AGENT_DIR=$(pwd)/agents/recruitment/diagnostic
export CTX_TENANT_SLUG=migration-test
export IFOS_VAULT_ROOT=${HOME}/.ifos-local-vault
bash agents/recruitment/diagnostic/cycle.sh --firm "Hays plc" --sector recruitment
```

Verify the report:
- §1 Firm signal NOW has real CH data (CRN, incorporation date, address, directors)
- §2 LinkedIn URL is `linkedin.com/company/hays/` (not `/hays-plc/`)
- §10 Recent activity NOW has real CH filings
- §11 Decision-maker map NOW has real directors
- §12 Conversation opener is LLM-generated, evidence-anchored

Copy to `docs/artefacts/diagnostic-hays-plc-2026-05-2X.md` (where X is the run date).

Commit: `milestone(diagnostic): Hays plc full-data re-run — real CH + LLM §12`

### DAY 15 — Diagnostic Codex ratification (Steps 6-7)

#### Step 6 — Codex Round 4 manifest preparation (~30 min)

Edit `docs/decisions/2026-05-18-codex-ratification-manifest.md`:

Add §1.10 (Round-4 queue) listing 6 items:
1. `agents/recruitment/diagnostic/agent.md` — re-ratify (was Round-3 RATIFIED at scaffold; now production-shape)
2. `agents/recruitment/diagnostic/tools.yaml`
3. `agents/recruitment/diagnostic/cycle.sh` (post-Day-13 generator wiring)
4. `agents/recruitment/diagnostic/validate.sh` (post-Day-13 V2 fix)
5. `packages/diagnostic-generator/` (the package as a whole; ratifies via `review-architecture-decision.md` skill)
6. `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` (Day-13 sequencing decision)

Each entry: title + status + Codex skill + ratification date placeholder.

Commit: `ops(codex-round-4): Diagnostic bundle + ADR-005 queue addition`

#### Step 7 — Codex Round 4 Diagnostic-only run (~45 min)

Founder runs:

```bash
bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
```

Captures verdicts in `logs/codex-ratification/round-4/diagnostic/`. Each artefact: RATIFIED | NEEDS-REMEDIATION | REJECTED.

If all RATIFIED → mark Diagnostic ratified in manifest §1.10; proceed to Step 8.
If any REJECTED → triage:
- **Mechanical fix** (e.g., citation drift, line-number error) → fix + commit + re-submit
- **Founder decision** (e.g., scope question, architectural concern) → STOP, write founder-decision doc per Day-11 pattern, escalate

Commit: `decision(codex-round-4): diagnostic verdicts — <N> RATIFIED / <M> REJECTED`

### DAY 16 — Janitor agent.md scaffold (Step 8)

#### Step 8 — `agents/recruitment/janitor/agent.md` (~2-3 hours)

Read FIRST:
- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
- `bullhorn-integration-path.md` §4.1 (Janitor's Bullhorn entity surface)
- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
- `vertical-schema.yaml` §3 agent_access_matrix Janitor row
- Diagnostic's `agent.md` as the gold-standard structure

Author the agent.md following Diagnostic's 10-section template. Specifics:

- **Status:** Proposed (pre-W5-build; awaits Bullhorn A+B + first pilot LOI)
- **Build wave:** W5 per master brief §8.2 line 596
- **Tier:** Tier 1 (batch nightly cron; not request-driven) per `sequencing-target.md` §2.1
- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
- **§3 Output shape:** day-30 report has 8 sections per ULTRAPLAN line 511 (record counts, dedup pairs, field-completeness deltas, tacit-note coverage, agent vs. consultant attribution, gate-B metric, exception list, executive summary).
- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
- **§5 Gate A:** validate.sh hard-fails on missing CTX env, dedup-rate >20% (suggests bad heuristic), field-write-error-rate >5%, schema-violation rows.
- **§5 Gate B:** ≥15% dedup improvement + ≥10% field-completeness improvement per ULTRAPLAN line 512.
- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_BULLHORN_WRITE_FAIL, ESC_SCHEMA_VIOLATION, ESC_RATE_LIMIT_HIT, ESC_AUTOSEND_YELLOW_SPOT_CHECK.
- **§7 Voice + tone:** N/A (Janitor doesn't produce customer-facing output; all writes are internal data).
- **§8 Build prerequisites:** Bullhorn MCP connector wired (W3 conditional; W4-5 if A+B answered) + first pilot tenant with Bullhorn corpToken in `_secrets.env`.
- **§9 Open questions:** 4-6 questions covering dedup-heuristic confidence threshold, field-completeness priority order, Bullhorn write batch size, day-30 report distribution path.
- **§10 Ratification:** via `review-architecture-decision.md` Codex skill; ratifies as part of Round 4 if scaffolded by Day 20.

Target: ~400 lines. Follows Diagnostic's structure verbatim. Every claim cites a specific master plan section + line number.

Acceptance:
- markdown lint clean
- All citations verified against source files (grep for the cited content)
- Every workflow step references a tools.yaml capability OR a `_shared/` helper
- §1 reads as a complete one-paragraph screenshot per master brief §1 Rule 1

Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`

### DAY 17 — Scribe agent.md scaffold (Step 9)

#### Step 9 — `agents/recruitment/scribe/agent.md` (~2-3 hours)

Read FIRST:
- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
- `vertical-schema.yaml` §3 agent_access_matrix Scribe row

Author following Diagnostic's template. Specifics:

- **Build wave:** W6 per master brief §8.2 line 597
- **Tier:** Tier 2 (request-driven, per-call invocation) per `sequencing-target.md` §2.1
- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
- **§3 Output shape:** Bullhorn write payload (entity-type-specific JSON) + 1 tacit-note attachment + 1 audit row in decision_log.
- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
- **§5 Gate B:** ≥80% field-extraction accuracy (per consultant spot-check) + ≥90% within-10-min SLA.
- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
- **§9 Open questions:** 4-6 covering Fathom vs Fireflies first-mover choice, webhook auth, field-extraction model selection, tacit-note length cap.

Target: ~400 lines.

Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`

### DAY 18 — Cash Conductor agent.md scaffold (Step 10)

#### Step 10 — `agents/recruitment/cash-conductor/agent.md` (~3-4 hours; most complex due to 4 external systems)

Read FIRST:
- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
- `vertical-schema.yaml` §3 agent_access_matrix Cash Conductor row
- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)

Author following Diagnostic's template. Specifics:

- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
- **Tier:** Tier 1 (batch daily; cron-driven)
- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
- **§4 Workflow:** ~14 steps. Cron daily 06:00 UTC. Fetch open invoices (Xero/QB/Sage rotation per tenant config) → fetch bank transactions (Open Banking) → match invoices ↔ deposits → identify unmatched + overdue → generate chase drafts → write reconciliation rows → weekly report assembly (Mondays).
- **§5 Gate A:** validate.sh hard-fails on accounting API auth failure, bank API auth failure, reconciliation false-positive rate >2%, chase-draft content failing voice classifier.
- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
- **§6 Escalation codes:** ESC_ACCOUNTING_AUTH, ESC_BANK_AUTH, ESC_RECONCILIATION_AMBIGUOUS, ESC_AUTOSEND_BLOCKED.
- **§7 Voice + tone:** chase drafts are voice-classified; ESC_VOICE_DRIFT if <0.75.
- **§8 Build prerequisites:** Xero MCP connector (W4 build) + QuickBooks MCP + Sage MCP + Open Banking via TrueLayer (or similar; founder commercial signup) + tenant accounting credentials in `_secrets.env`.
- **§9 Open questions:** 6-8 covering accounting system per-tenant choice, Open Banking provider, reconciliation heuristic (exact-amount vs fuzzy), chase escalation ladder, weekly report stakeholder list.

Target: ~450 lines (more than others due to 4 external systems).

Commit: `decision(pre-build): agents/recruitment/cash-conductor/agent.md — output contract per ULTRAPLAN §8.1 A4`

### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)

#### Step 11 — `agents/recruitment/sourcing-scout/agent.md` (~2-3 hours)

Read FIRST:
- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
- `vertical-schema.yaml` §3 agent_access_matrix Sourcing Scout row

Specifics:

- **Build wave:** W9 per master brief §8.2 line 598
- **Tier:** Tier 2 (request-driven per brief)
- **§1 Output contract:** ingests brief description; ranks passive candidates from Bullhorn database + LinkedIn search; outputs ranked match list with explanation per candidate.
- **§3 Output shape:** Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-id>-<ISO-date>.md` with ranked candidate list (typically 5-20 matches); per-candidate confidence score + match rationale + Bullhorn CRN + LinkedIn URL.
- **§4 Workflow:** ~10 steps. Brief fetch → keyword extraction → Bullhorn candidate search (filtered) → LinkedIn search (via Proxycurl or equiv) → semantic ranking → confidence scoring → match rationale generation → report assembly.
- **§5 Gate A:** validate.sh hard-fails on empty match list, low average confidence (<0.5), schema violation.
- **§5 Gate B:** ≥3 high-confidence (>0.7) matches per brief.
- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
- **§7 Voice + tone:** N/A (internal output; no customer-facing voice).
- **§8 Build prerequisites:** Bullhorn MCP read + LinkedIn integration (Proxycurl signup OR LinkedIn API partner-tier) + ranking model (LLM-based or embedding-based).
- **§9 Open questions:** 4-6 covering ranking model choice, max match list size, LinkedIn coverage at v1.0.

Target: ~400 lines.

Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`

#### Step 12 — `agents/recruitment/concierge/agent.md` (~3-4 hours; most complex due to autosend orange-tier)

Read FIRST:
- ULTRAPLAN §8.1 A6 lines 561-570 (Concierge spec)
- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
- `bullhorn-integration-path.md` §4.1 (Concierge's Bullhorn write surface)

Specifics:

- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
- **Tier:** Tier 1 (continuous; lifecycle-event-driven via Bullhorn poll cycle)
- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
- **§5 Gate B:** <5% incorrect-send rate (per consultant feedback loop) + ≥90% lifecycle-event coverage (no missed transitions).
- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
- **§7 Voice + tone:** highest stakes of any agent — customer-facing sends. Voice classifier required (no skip). Tone rules strict (block-severity hit = ESC_TONE_RULE_VIOLATION).
- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
- **§9 Open questions:** 8-10 covering message template library, lifecycle-event coverage (which events get auto-draft), per-tenant tone-rule customisation, spot-check sample rate, consultant feedback loop.

Target: ~500 lines (most lines of any agent; highest stakes).

Commit: `decision(pre-build): agents/recruitment/concierge/agent.md — output contract per ULTRAPLAN §8.1 A6`

### DAY 20 — Codex Round 4 full ratification + state sync (Steps 13-14)

#### Step 13 — Codex Round 4 full execution (~2 hours founder time + ~1 hour Claude triage)

Manifest now includes 6 new items (5 agent.md scaffolds + Diagnostic re-ratify). Founder runs:

```bash
bash scripts/run-codex-ratification.sh --round 4 --full
```

Output captured in `logs/codex-ratification/round-4/`. Per-artefact verdict.

Triage protocol (master brief §10.3 step 5 hard ceiling: ≤2 round-trips):
- **All RATIFIED:** mark in manifest §1.10; proceed to Step 14.
- **Mechanical REJECTIONS:** fix via "Round 4 remediation" autonomous Codex prompt (model on `docs/operations/codex-round-2-remediation-prompt.md`); re-submit; expect Round 5 final.
- **Founder-decision REJECTIONS:** write founder-decision doc; defer to next Sunday review.

Commit (per remediation cycle if needed): `fix(codex-round-4): <N> mechanical fixes + <M> founder-escalated`

#### Step 14 — State + manifest sync + Week-3 close (~45 min)

Update:

1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
2. **`docs/RISK-REGISTER.md`** — Risk #2 (Bullhorn) status per A+B response state; Risk #5 (Renderer) updated per Diagnostic ratification.
3. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue — Round-4 verdicts captured; queue grown to 49+ items.

Commit: `ops(week-3-close): state sync + Codex Round 4 verdicts + Week-4 backlog`

Push:

```bash
git push origin main
```

Final §10 end-of-goal report (per template below).

---

## §5 — Hard quality gates (must pass at each commit)

| Gate | Threshold | Verification |
|---|---|---|
| **Shellcheck** | All `.sh` files clean (errors only; warnings allowed with explicit `# shellcheck disable=`) | `shellcheck **/*.sh` |
| **Typecheck** | All TS packages clean | `pnpm typecheck` |
| **Unit tests** | Each modified package: all tests pass; ≥3 new tests per non-trivial change | `pnpm test` |
| **No secrets in commits** | grep for API keys, passwords, tokens, OAuth refresh tokens | manual scan of diff |
| **URLs verified** | Every external URL in docs/code curl-checked before citing | `curl -sI -L <url>` returns 200/301 |
| **Path A discipline** | No credentials in chat, ever | self-audit before each step |
| **Master plan citations** | Every architectural claim cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
| **Spec line-anchor accuracy** | Cited lines exist + contain claimed content | spot-grep each citation |
| **Commit messages** | Conventional commits format + Co-Authored-By footer + cite master plan section that justifies the change | grep commit log |
| **Codex skill output captured** | Each ratification round writes per-artefact `.output.md` files | `ls logs/codex-ratification/round-4/` |

---

## §6 — Failure modes + recovery

| Failure | Recovery |
|---|---|
| Founder slow to register CH API key (Step 2) | Continue with Step 3 (LinkedIn slug fix; no key needed); resume Step 4 when key arrives; if no key by Day 16, escalate to founder review (Step 2 is a HARD gate for Step 5 smoke test) |
| Founder slow to provide ANTHROPIC_API_KEY (Step 4) | Same — Step 4 LLM call stubs out; fall back to deterministic opener; resume when key arrives |
| LLM call rate-limited or 5xx (Step 4 runtime) | Built-in retry once; fall back to deterministic; emit ESC_VOICE_DRIFT warning |
| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
| Codex Round 4 returns >2 REJECTED on any single artefact | Founder review; do NOT remediate-and-resubmit beyond hard ceiling (per master brief §10.3 step 5); write founder-decision doc; defer |
| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
| Companies House API key returns 401 (invalid key) | Founder re-registers (free; key may be revoked if not used in N days per CH policy); retry after new key saved |
| Founder approves Proxycurl signup mid-week | Wire LinkedIn deep data into Diagnostic via a new `@ifos/linkedin-proxycurl` package (similar to companies-house pattern); commit as separate slice; out of scope for goal §1 but high-value |
| Test suite regression in any package | STOP; root-cause; fix; verify all tests pass before proceeding |
| Disk full / VPS unreachable mid-execution | Pause; founder investigates; resume from last green commit |

---

## §7 — When to ask the founder (vs proceed)

### Proceed without asking

- All Step 1, 3, 6, 8-12 mechanical work
- Bug fixes in existing code
- Adjustments to test fixtures
- Adding more tests
- Doc updates that don't change scope
- Choosing between equivalent implementations (commit captures rationale)
- Citing additional master plan sections beyond those explicitly listed

### MUST ask the founder

- Step 2: Companies House API key registration
- Step 4: Anthropic API key registration
- Step 7: Codex Round 4 Diagnostic-only run (founder runs the script)
- Step 13: Codex Round 4 full run
- Any deviation from agent.md output contract patterns
- Any decision that changes the master-plan citation chain
- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
- Any modification to live VPS Postgres state
- Any reduction in Gate A strictness
- Codex disagreement requiring founder arbitration

---

## §8 — Codex ratification protocol (load-bearing)

Per master brief §10 + §10.3 step 5 hard ceiling + Day-11 Round-2/3 pattern.

### Round 4 manifest preparation (Step 6)

Add 6 items to `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.10:
- Diagnostic agent.md (re-ratify; was Round-3 RATIFIED at scaffold form)
- Diagnostic tools.yaml
- Diagnostic cycle.sh (post-Day-13 generator wiring)
- Diagnostic validate.sh (post-Day-13 V2 fix)
- packages/diagnostic-generator/ (as a whole package)
- ADR-005 (Day-13 sequencing decision)

Each entry: artefact + status + Codex skill + ratification date placeholder.

### Round 4 Diagnostic-only run (Step 7)

```bash
bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
```

Mid-week early ratification of Diagnostic ensures: (a) the substrate is verified before 5 new scaffolds reference it; (b) any architectural concerns surface before the 5 new agent.md contracts are committed.

### Round 4 full run (Step 13)

```bash
bash scripts/run-codex-ratification.sh --round 4 --full
```

Includes the 5 new agent.md scaffolds + any open items from prior rounds.

### Triage rules

- **All RATIFIED:** mark in manifest; close round; proceed.
- **Mechanical REJECTIONS (citation drift, line-anchor error, formatting):** Round 4 remediation prompt; expect Round 5 final. Hard ceiling per master brief §10.3 step 5: 2 round-trips MAX. Round 5 RATIFIED → close. Round 5 STILL REJECTED → founder review.
- **Founder-decision REJECTIONS:** STOP. Write founder-decision doc per Day-11 pattern. Skip the artefact in this round. Resume after founder decision.
- **Codex disagreement (Codex challenges a master-plan-cited decision):** STOP. Write `docs/decisions/codex-disagreement-YYYY-MM-DD-<topic>.md` per Day-8 pattern. Founder arbitrates.

### Existing skills available

- `review-architecture-decision.md` — for agent.md scaffolds (each is an architectural decision; status=Proposed)
- `review-schema-change.md` — N/A this round
- `review-postgres-migration.md` — N/A this round
- `review-agent-bundle.md` — NOT YET BUILT (per execution-plan §3 lazy); defer; use review-architecture-decision.md for each agent.md individually

---

## §9 — Quality multiplier: "presentable to Codex on first submission"

The agent.md scaffolds should be ratifiable on FIRST submission. That means:

1. **Every claim cites a master plan section.** No bare assertions. Every paragraph either cites the master brief / ULTRAPLAN / sequencing-target / kill-criterion / specific ADR, OR is explicitly stated as "scaffold inference; founder review required."
2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
3. **No speculative content.** If a workflow step would require capability X but X doesn't exist yet, mark it as "deferred (pre-W<X>)" — don't bake assumptions about how X will work.
4. **Every escalation code listed exists in `agents/_shared/escalation-codes.md`.** No invented codes. If we need a new code, propose it in the agent.md §6 "new codes required" subsection.
5. **Every Gate A condition is operationally testable.** A future validate.sh implementer can read §5 and write the bash logic without inventing rules.
6. **Every Gate B target is measurable.** Cite the master plan section or ULTRAPLAN line that establishes the metric. No invented numbers.
7. **Voice + tone (§7) integrates with `_shared/voice-loader.sh`.** No alternative voice system invented.

If the agent.md doesn't meet these 7 criteria, Codex Round 4 will reject it as "speculative." Re-write before commit, not after.

---

## §10 — End-of-goal report template

After Step 14, the executor produces this exact report:

```
═══════════════════════════════════════════════════════
WEEK 3 COMPLETE — DIAGNOSTIC POLISH + 5 AGENT.MD SCAFFOLDS

Diagnostic state:
  Production data:    Hays plc 12-section report at <path>
  Word count:         <N>
  Voice classifier:   <skipped per scaffold | live at score X>
  Gate A:             PASS (V1-V6 green; V3 warning per scaffold)
  Codex Round 4:      <N> RATIFIED / <M> REJECTED of <N+M>

5 agent.md scaffolds:
  Janitor (W5):           <N> lines | Codex verdict: <RATIFIED/REJECTED>
  Scribe (W6):            <N> lines | Codex verdict: <RATIFIED/REJECTED>
  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
  Sourcing Scout (W9):    <N> lines | Codex verdict: <RATIFIED/REJECTED>
  Concierge (W10-13):     <N> lines | Codex verdict: <RATIFIED/REJECTED>

Commits (14):
  <SHA>  chore(week-3): substrate verification before polish slice
  <SHA>  fix(diagnostic): LinkedIn slug suffix-strip
  <SHA>  feat(diagnostic): §12 LLM-driven conversation opener
  <SHA>  milestone(diagnostic): Hays plc full-data re-run
  <SHA>  ops(codex-round-4): Diagnostic bundle queue addition
  <SHA>  decision(codex-round-4-diagnostic): N RATIFIED / M REJECTED
  <SHA>  decision(pre-build): agents/recruitment/janitor/agent.md
  <SHA>  decision(pre-build): agents/recruitment/scribe/agent.md
  <SHA>  decision(pre-build): agents/recruitment/cash-conductor/agent.md
  <SHA>  decision(pre-build): agents/recruitment/sourcing-scout/agent.md
  <SHA>  decision(pre-build): agents/recruitment/concierge/agent.md
  <SHA>  decision(codex-round-4-full): N RATIFIED / M REJECTED
  <SHA>  fix(codex-round-4): mechanical remediations (if needed)
  <SHA>  ops(week-3-close): state sync + Codex Round 4 + Week-4 backlog

Master plan alignment:
  ✓ ULTRAPLAN §8.1 — all 6 agents have output contracts authored
  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
  ✓ sequencing-target.md §3.1 — Build Wave 1 (Diagnostic) ratified;
    Waves 2-6 contracts ready for build
  ✓ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratified ahead of
    2026-06-14 deadline by N days

Week-4 backlog (pulled from Week-3 deferred items + ADR-005 conditional):
  Track 1 (Bullhorn-INDEPENDENT — proceed regardless of A+B response):
    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
    - Cash Conductor build (full bundle)
    - Diagnostic voice classifier microservice
    - Diagnostic LinkedIn deep data (if Proxycurl signed up)

  Track 2 (Bullhorn-GATED — conditional on A+B Accepted):
    - Bullhorn MCP connector (auth + read + write endpoints)
    - Janitor build (depends on Bullhorn R+W)
    - Scribe build (depends on Bullhorn W + Fathom MCP)

Pending founder actions:
  - <list any open D1/D2/D3 decisions surfaced during Week 3>
  - <Proxycurl signup if approved>
  - <Fathom/Fireflies signup for W6>
  - <Xero dev account for W4>

Open Codex disagreements:
  - <none | list>

Next decision for founder:
  - Approve Week-4 backlog?
  - Approve Track 1 vs Track 2 priority (depends on Bullhorn A+B status)?
  - Approve Proxycurl signup ($39/mo)?
═══════════════════════════════════════════════════════
```

---

## §11 — Risks specific to this goal

| # | Risk | Likelihood | Mitigation |
|---|---|---|---|
| 1 | Anthropic API rate-limit / outage during Step 4 dev | Low | Built-in retry + deterministic fallback; flag as W4 polish if rate-limited persistently |
| 2 | Founder unavailable for Steps 2/4/7/13 longer than 24h | Medium | Continue with parallel work that doesn't depend on founder gates; resume when available; Day-20 deadline soft (Week 3 extends to Day 22-23 if needed) |
| 3 | Codex Round 4 hard ceiling hit (REJECTED after Round 5) | Low | Founder review; defer artefact; rest of Week-3 ships clean |
| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
| 5 | Master plan line numbers drift during commits (someone else edits during execution) | Low | Each step re-greps citations before commit; if drift detected, fix in same commit |
| 6 | LLM-driven §12 produces opener that fails voice classifier consistently | Medium | Deterministic fallback already in place; flag as W4 polish (real voice classifier wires up later) |
| 7 | The 5 agent.md scaffolds drift in style across days (different writing voice on different days) | Medium | Each scaffold re-reads Diagnostic's agent.md FIRST as the structural template; commit message references the structural anchor |

---

## §12 — Definition of "Week 3 complete"

Week 3 is complete when:

- All 16 items in §1 success state are TRUE
- 14 commits pushed to origin/main
- Codex Round 4 logs in `logs/codex-ratification/round-4/`
- §10 end-of-goal report posted by executor
- Founder has reviewed the §10 report and approved Week-4 backlog

**Day 20 is the soft target. Day 22 is the hard cutoff** (Trigger 2 fires Day 21 if Diagnostic not ratified). If Day 22 hits without completion, escalate to founder review + scope-cut decision.

---

*End of /goal prompt for Week 3 polish + scaffold.*
