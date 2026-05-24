# /goal — Option C: Diagnostic agent end-to-end against a real UK recruitment firm

**Type:** Goal prompt (paste into Claude Code at session start; executor runs to completion)
**Authored:** 2026-05-24 (Day 13 / end of Week 2)
**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
**Maps to:** Week-3 + Week-4 work pulled forward; Week-3 Bullhorn-MCP work deferred pending Sub-decisions A+B response.
**Quality bar:** Production-ready. Every line of code shellcheck/typecheck/test clean. Every URL verified via curl before citation. Every external credential follows Path A discipline (founder enters once locally, never to chat). Every artefact ratifiable via Codex.

---

## §0 — Read this first (mandatory reading order)

Before writing any code, the executor reads these in order:

1. **`CLAUDE.md`** at repo root — confirms instance scoping (`CTX_INSTANCE_ID=ifos-v2`), Path A discipline, five rules, four boundaries.
2. **`.agents/current-priorities.md`** — current state + what shipped most recently.
3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
5. **`agents/recruitment/diagnostic/agent.md`** — the existing output contract. Read in full.
6. **`agents/recruitment/diagnostic/tools.yaml`** — MCP tool declarations the executor must implement.
7. **`docs/architecture/tenancy-invariants.md`** §3 verification matrix — what must hold true after every code change.
8. **`docs/runbooks/operational-hygiene-protocol.md`** §2 (Path A) + §3 (no defensive additions) + §5 (citation accuracy).

After reading: state in chat "Read order complete. Five rules: [list]. Four boundaries: [list]. Option C scope confirmed."

---

## §1 — Success state (what "done" looks like)

When this goal is complete, the following are TRUE:

1. **One Markdown file exists at `/vault/migration-test/diagnostic-reports/<firm-slug>-2026-05-24.md`** containing a 12-section Diagnostic report for a real UK recruitment firm chosen by the founder.

2. **The report passes Gate A (validate.sh)** clean: 12 sections present, ≥1 citation per section, word count 400-2000, no banned phrases (V3 voice classifier passes OR skipped with explicit warning if `IFOS_VOICE_CLASSIFIER_URL` unset for v0).

3. **Two new packages exist in `packages/`:**
   - `packages/utilities/web-scraper/` — TypeScript Node utility (HTTP HEAD + first-N-lines fetch + robots.txt respect + cache + rate limit)
   - `packages/mcp-connectors/companies-house/` — TypeScript Node connector (search + profile + officers + filing history; 7-day cache; rate limit budget)

4. **Both packages have:**
   - `pnpm test` returns green (≥10 vitest unit tests per package; integration test against live Companies House API marked `.skipIf(!process.env.COMPANIES_HOUSE_API_KEY)`)
   - `pnpm typecheck` clean
   - `pnpm build` succeeds
   - README.md explaining usage + env vars + rate-limit posture
   - `package.json` with workspace metadata matching `packages/agent-renderer/` shape

5. **`cycle.sh` is wired to call the new connectors** at the right workflow steps (§4 Steps 2 + 3 + 6 + 8 + 10 per `agent.md`). LinkedIn paths remain stubbed (gracefully degraded per fixture 02-edge-case).

6. **A decision-log audit trail** for the smoke run: 3+ rows in `decision_log` (trigger + output + action), all under `agent_name='diagnostic'`, with `tenant_slug='migration-test'`.

7. **All work committed** as atomic commits with clear messages. Final commit confirms Trigger 2 beat (2026-06-14 deadline cleared 21 days early).

8. **ADR-005 written and committed** documenting the Week-3-deferred-to-Week-4-accelerated sequencing decision.

9. **State files updated:** `current-priorities.md` Shipped section + `RISK-REGISTER.md` Risk #2 status (Diagnostic ratification path proven).

---

## §2 — Scope: what's IN, what's OUT

### IN scope (must complete)

| Item | Why |
|---|---|
| Web scraper utility | Diagnostic §4 Step 3 + 6 + 8 |
| Companies House connector | Diagnostic §4 Step 2 + 10 |
| `cycle.sh` wiring of the two new connectors | Makes the §1-§11 sections produce real content |
| §12 conversation opener — LLM-generated, minimal voice gate | Sufficient for v0 demo; full voice classifier in W4 polish |
| Smoke run against ONE real UK recruitment firm | The milestone |
| ADR-005 sequencing-deferral decision | Audit trail |
| Updates to `current-priorities.md` + `RISK-REGISTER.md` | State hygiene |

### OUT of scope (don't touch)

| Item | Reason |
|---|---|
| LinkedIn integration (Proxycurl, etc.) | Requires founder commercial action (Proxycurl signup ~£50/mo); LinkedIn paths remain stubbed; fixture 02 verifies graceful degradation already |
| Voice classifier microservice | Defer to Week 4 polish; v0 skips V3 with explicit warning |
| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
| Renderer or `_shared/` modifications | They're done; if a bug surfaces, surface it as an issue, don't patch in this goal |
| Tenant onboarding outside `migration-test` | Single-tenant scope for this milestone |
| Legal / SeedLegals / ICO | Founder action; deferred per founder decision |
| Verification of external URLs without curl | Day-12 lesson: every URL cited must be verified via `curl -sI -L` before landing in any doc |

### OUT of scope (explicit non-goals)

- **Do NOT** add features beyond what `agent.md` and `tools.yaml` specify
- **Do NOT** modify the v0.2 schema or migration SQL — schema is live
- **Do NOT** modify `_shared/hook-helpers.sh` or `_shared/voice-loader.sh` beyond fixing genuine bugs (29/29 tests pass; treat as stable substrate)
- **Do NOT** sign up for any paid service (Proxycurl, etc.) — founder gates external spend
- **Do NOT** put API keys in chat OR commit them; they go to `/vault/migration-test/_secrets.env` mode 0600 only

---

## §3 — Path A discipline reminder

The executor will need ONE credential from the founder during this goal:

**Companies House Developer API Key** (free; founder registers at https://developer.company-information.service.gov.uk/ — URL verified 2026-05-24 by curl).

When the executor reaches the point of needing it:

1. STOP executing.
2. State: "Founder action needed: register for Companies House API key at https://developer.company-information.service.gov.uk/ (free, 5 min). Save the key as: `echo 'COMPANIES_HOUSE_API_KEY=<your-key>' >> /vault/migration-test/_secrets.env && chmod 600 /vault/migration-test/_secrets.env`. Confirm when done; do NOT paste the key into chat."
3. Wait for founder confirmation ("done" or "key saved").
4. Resume.

**NEVER** ask the founder to paste the key. **NEVER** echo the key after they confirm. **NEVER** commit `_secrets.env`.

---

## §4 — Execution plan (10 steps, commit per step)

### Step 1 — Package scaffolding (~20 min)

Create `packages/utilities/web-scraper/` and `packages/mcp-connectors/companies-house/` mirroring the structure of `packages/agent-renderer/`. Each package:
- `package.json` with workspace metadata (Node ≥20, ESM, tsup/vitest/commander deps)
- `tsconfig.json` + `tsup.config.ts` + `vitest.config.ts`
- `src/index.ts` placeholder export
- `tests/` directory
- `README.md` (skeleton)

Commit: `feat(packages): scaffold web-scraper + companies-house packages`

### Step 2 — Web scraper utility (~60 min)

Implement `packages/utilities/web-scraper/src/`:
- `client.ts` — HTTP client with timeout, redirect-follow, user-agent string
- `cache.ts` — disk cache with TTL (per tools.yaml: 1h for careers pages)
- `robots.ts` — robots.txt fetcher + permission check
- `fetcher.ts` — main API: `headCheck(url)`, `fetchFirstNLines(url, n)`, `googleSearch(query)` (stub for v0)
- `errors.ts` — error types mapping to escalation codes

Tests (vitest):
- HEAD check returns status + last-modified
- First-N-lines fetch handles 200, 404, 5xx, timeout
- Cache stores + retrieves with TTL respect
- robots.txt blocks expected paths
- Rate limit gracefully degrades (returns null + logs warning)

Acceptance: `pnpm test --filter web-scraper` returns ≥8 tests passing. `pnpm typecheck --filter web-scraper` clean.

Commit: `feat(web-scraper): HTTP HEAD + first-N-lines + cache + robots.txt`

### Step 3 — Companies House connector (~90 min)

Implement `packages/mcp-connectors/companies-house/src/`:
- `client.ts` — Companies House REST client with Basic auth (API key as username, empty password per CH docs)
- `cache.ts` — 7-day cache per `(company_number, capability)` (matches tools.yaml)
- `rate-limit.ts` — 600 req / 5-min window per IP; pre-emptive backoff
- `capabilities/search.ts` — name → CRN
- `capabilities/profile.ts` — CRN → full profile (incorporation date, accounts, address)
- `capabilities/officers.ts` — CRN → directors with appointment dates
- `capabilities/filing-history.ts` — CRN → filings last 90 days
- `errors.ts` — 429 → ESC_RATE_LIMIT_HIT, 5xx → ESC_SCHEMA_VIOLATION
- `index.ts` — top-level export

Tests (vitest):
- Unit tests with mocked fetch (no live calls)
- Schema validation against Companies House response shapes
- Cache TTL respect
- Rate-limit backoff fires before hitting 429
- Error mapping correct

**Integration test** (separate file, runs ONLY when `COMPANIES_HOUSE_API_KEY` env present):
- Search for a real UK firm ("Bullhorn UK" or similar — known to exist)
- Fetch its profile
- Fetch officers
- Verify response shape matches CH OpenAPI spec

Acceptance: `pnpm test --filter companies-house` returns ≥12 tests passing (unit); integration test skipped without key + passes with key.

Commit: `feat(companies-house): MCP connector — search + profile + officers + filings`

### Step 4 — Founder API key registration (BLOCKING founder action)

STOP. Output to founder: "Step 4 — please register for Companies House API key at https://developer.company-information.service.gov.uk/. Save to /vault/migration-test/_secrets.env via SSH. Do NOT paste the key in chat. Confirm when saved."

Wait for confirmation.

### Step 5 — Companies House integration smoke test (~20 min)

With the API key in `/vault/migration-test/_secrets.env`:
- Run the integration test suite against live CH API
- Verify ≥3 endpoints work (search, profile, officers)
- Cache works (second call same input returns from cache)
- Rate limit doesn't trip in normal use

Acceptance: integration tests green; one log line per endpoint showing response time + cache state.

Commit: `test(companies-house): integration smoke verified against live API`

### Step 6 — Wire connectors into cycle.sh (~60 min)

Replace the stub `_section_1()` through `_section_11()` functions in `agents/recruitment/diagnostic/cycle.sh` with real connector calls:

- `_section_1` calls `companies-house search → profile → officers → filing-history`
- `_section_2` calls `web-scraper.headCheck` for {firm}.com + {firm}.co.uk + LinkedIn-stubbed
- `_section_3-5` LinkedIn paths remain stubbed with explicit "no LinkedIn data" content (matches fixture 02)
- `_section_6` reads `target_patch.json`, computes composite ICP fit score from §1-§5 outputs
- `_section_7-11` mostly LinkedIn-dependent — use stubs producing "LinkedIn integration v1.1" content with Companies House anchor as fallback citation
- `_section_12` calls a minimal LLM (Claude or local) with §1-§11 context to produce 2-3 sentence opener; voice classifier SKIPPED (warn, don't fail)

Sections producing real content: §1 (Companies House) + §2 (Companies House URL + web scraper for {firm} domain) + §6 (ICP fit derived from §1).
Sections producing stub content with Companies House anchor: §3-§5, §7-§11.
Section §12: LLM-generated, voice-classification skipped.

Each section has ≥1 citation link → V2 passes. 12 sections → V1 passes. Length 400-2000 words → V4 passes. No banned phrases (clean text) → V5 passes. No emails embedded → V6 passes trivially. V3 skipped with warning per scaffold spec.

Acceptance: `bash agents/recruitment/diagnostic/cycle.sh --firm "Test Firm Name" --tenant migration-test` produces a draft at /tmp/... and Gate A passes (V3 warning only).

Commit: `feat(diagnostic): wire web-scraper + companies-house into cycle.sh §1+§2+§6`

### Step 7 — End-to-end smoke run against a real firm (~30 min)

Founder picks the firm name. Use one of:
- A real UK recruitment firm Jack is targeting
- A well-known firm ("Charterhouse Partners", "Hays plc", "Robert Walters") — Companies House will return real data
- The firm name doesn't need to know us; we're producing intel ABOUT them

Founder sets `IFOS_DIAGNOSTIC_FIRM_NAME` env var (or passes via --firm).

Run:
```bash
cd ~/code/CortexOS
source /vault/migration-test/_secrets.env
ifosctl diagnostic --firm "<firm name>" --tenant migration-test
```

OR if `ifosctl` not wired:
```bash
export CTX_AGENT_DIR=$(pwd)/agents/recruitment/diagnostic
export CTX_TENANT_SLUG=migration-test
export IFOS_DB_URL=...
bash agents/recruitment/diagnostic/cycle.sh --firm "<firm name>"
```

Verify the report at `/vault/migration-test/diagnostic-reports/<slug>-2026-05-24.md`:
- Read it end-to-end
- Identify weak sections (note for Week-4 polish)
- Confirm Gate A passed
- Confirm 3+ decision_log rows present

Commit: `milestone(diagnostic): first end-to-end run — <firm name> report at <path>`

### Step 8 — ADR-005 (~30 min)

Write `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` documenting:

- **Status:** Accepted
- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
- **Decision:** Week 3 (Days 13-20) repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) repurposed from Diagnostic-build to Diagnostic-polish + Codex ratification + (conditional) Bullhorn-MCP-build if A+B answered.
- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
- **Ratifies via:** review-architecture-decision.md Codex skill (next round).

Commit: `decision(ADR-005): Week 3 repurposed Bullhorn-MCP → Diagnostic acceleration`

### Step 9 — State file updates (~15 min)

Update `.agents/current-priorities.md`:
- Move Diagnostic agent.md scaffold from "Shipped" Day-11 to "shipped + extended" pointing at today's commits
- Add Day-13 Shipped section: web-scraper + companies-house + cycle.sh wired + first E2E report

Update `docs/RISK-REGISTER.md`:
- Risk #2 (Bullhorn MCP build): note Diagnostic-doesn't-need-Bullhorn path explored Day-13; reduces blast radius if Bullhorn response delayed
- Risk #3 (Q1 LOI): note that Diagnostic-as-sales-tool now has empirical artefact for the Q1 pitch

Commit: `ops(day-13): state-file updates — Option C complete + ADR-005 + risk register sync`

### Step 10 — Push + final report (~10 min)

```bash
git push origin main
```

Final output to founder:
- Commit SHAs (1-9)
- Report path
- Word count + section coverage
- Gate A verdict
- Trigger 2 deadline cleared (X days early)
- Recommendations for Week-4 polish (weak sections, voice classifier wiring, LinkedIn integration if Proxycurl signed up)

---

## §5 — Hard quality gates (must pass at each commit)

| Gate | Threshold | Verification |
|---|---|---|
| **Shellcheck** | All `.sh` files clean (no errors; warnings allowed only with explicit `# shellcheck disable=`) | `shellcheck **/*.sh` |
| **Typecheck** | All TS packages clean | `pnpm typecheck` per package |
| **Unit tests** | Each new package ≥8 tests; all pass | `pnpm test` |
| **No secrets in commits** | grep for API keys, passwords, tokens in diff | manual scan of diff before commit |
| **URLs verified** | Every external URL in docs/code curl-checked before citing | `curl -sI -L <url>` returns 200/301 |
| **Path A discipline** | No credentials in chat, ever | self-audit before each step |
| **Master plan citations** | Every architectural decision cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
| **Commit messages** | Conventional commits format; include "Co-Authored-By: Claude" footer; reference the master-plan citation that justifies the change | grep commit log |

---

## §6 — Failure modes + recovery

| Failure | Recovery |
|---|---|
| Companies House API key blocks (founder slow to register) | Pause at Step 4; founder runs other work; resume when key saved. Steps 1-3 + 6 (partially) still committable. |
| Companies House API returns unexpected schema | Schema-validation error in connector; surface as Risk #14 in register; downgrade §1 to stub with Companies House URL as citation; continue. |
| Web scraper hits a JS-heavy site that returns no text | Expected (gotcha §6.1); §2 reports "site requires JS, signal unavailable"; counts as graceful degradation (fixture 02 already verifies this); no Gate A impact. |
| LLM generates §12 with banned phrase | V5 fails; retry up to 3x; if still failing, ESC_VOICE_DRIFT row + report blocked (matches fixture 99); record as known limitation, defer voice tuning to Week-4 polish. |
| Diagnostic report word count <400 | V4 fails; cycle.sh detects + retries with longer prompt; if still failing, surface as Diagnostic-spec issue (revisit agent.md §3 section count vs word budget). |
| Founder picks a firm name not found in Companies House | Search returns 0 results; cycle.sh degrades to "Companies House: no UK registration found"; continues with web-scraper + stubs; still produces a valid 12-section report. |
| Real run reveals Gate A V3 voice classifier was actually needed (skipped warning was too lenient) | Surface as W4 polish item; do not block the milestone. |

---

## §7 — When to ask the founder (vs proceed)

**Proceed without asking:**
- All Step 1-3 + 5-9 mechanical work
- Bug fixes in scaffold code (e.g., shellcheck issues)
- Adjustments to test fixtures
- Adding more tests
- Doc updates that don't change scope

**MUST ask the founder:**
- Step 4 — Companies House API key registration
- Step 7 — firm name choice for the smoke run
- Any deviation from `agent.md` output contract
- Any decision that changes the master-plan citation chain
- Any external service requiring paid signup (Proxycurl, OpenAI tier, etc.)
- Any modification to live VPS Postgres state
- Any reduction in Gate A strictness

---

## §8 — Closing checklist (executor confirms before final commit)

- [ ] Read order complete (§0)
- [ ] All 10 steps executed
- [ ] 1 real Markdown report exists in vault
- [ ] Gate A passes (V3 warning only, all others pass)
- [ ] 2 new packages committed (web-scraper + companies-house)
- [ ] 8 commits pushed
- [ ] ADR-005 written + committed
- [ ] State files updated (current-priorities + RISK-REGISTER)
- [ ] Master plan citations verified at every decision point
- [ ] No secrets in any commit
- [ ] All URLs cited in docs verified via curl
- [ ] Path A discipline maintained throughout
- [ ] Trigger 2 deadline cleared (≥7 days remaining)
- [ ] Final summary delivered to founder with commit SHAs + report path + polish recommendations

---

## §9 — Quality multiplier: "12-page audit" standard

ULTRAPLAN line 755 sets the bar: "Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."

For the report to count as a real sales artefact (not just a technical proof-of-concept), it should:

1. **Be presentable to a prospective pilot tenant as-is** — not "imagine when this works"
2. **Cite real Companies House data** for §1 (no stubs)
3. **Include real web data** for §2 (careers page URL + state, last-update signal)
4. **Have a §12 conversation opener that's not generic** — even if voice classifier skipped, the opener should anchor to a specific evidence point from §1-§11 (filings, headcount, hiring posts)
5. **Read as written by a thoughtful operator**, not as templated boilerplate
6. **Be the kind of artefact you'd be happy to forward to Jack to use in his Q1 pitch**

If the first run doesn't meet this bar, the goal is NOT complete. Iterate within Step 7 until it does (within reason; ≤3 iterations before flagging to founder as Week-4 polish item).

---

## §10 — End-of-goal report template

After Step 10, the executor produces this exact summary in chat (filling in the bracketed parts):

```
═══════════════════════════════════════════════════════
OPTION C COMPLETE — DIAGNOSTIC END-TO-END

Firm:              [firm name]
Report path:       [/vault/migration-test/diagnostic-reports/<slug>-<date>.md]
Word count:        [N]
Sections:          12/12
Gate A:            PASS (V3 warning — voice classifier skipped per scaffold)
Audit rows:        [N] decision_log rows

Commits:
  1. [SHA] feat(packages): scaffold web-scraper + companies-house packages
  2. [SHA] feat(web-scraper): HTTP HEAD + first-N-lines + cache + robots.txt
  3. [SHA] feat(companies-house): MCP connector
  4. [SHA] test(companies-house): integration smoke verified
  5. [SHA] feat(diagnostic): wire web-scraper + companies-house into cycle.sh
  6. [SHA] milestone(diagnostic): first end-to-end run
  7. [SHA] decision(ADR-005): Week 3 repurposed
  8. [SHA] ops(day-13): state-file updates

Trigger 2 deadline (2026-06-14): cleared by [N] days
Master plan alignment: ULTRAPLAN §8.1 Week-4 milestone hit on Day-13

Week-4 polish recommendations (NOT in scope for this goal):
  - [Section X needs Y improvement based on first run]
  - [LinkedIn integration via Proxycurl signup]
  - [Voice classifier microservice wiring]
  - [Additional fixtures based on real-firm-run findings]

Next decision for founder:
  - [Approve report? Forward to Jack for Q1 pitch?]
  - [Run against [N] more real firms to build iterating dataset?]
  - [Proceed to Week-4 polish OR wait on Bullhorn response before Janitor W5?]
═══════════════════════════════════════════════════════
```

---

*End of /goal prompt for Option C.*
