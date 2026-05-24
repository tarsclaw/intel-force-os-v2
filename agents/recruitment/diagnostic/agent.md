# Diagnostic — the sales tool

**Status:** Proposed (Day-19; full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present. Status flips Proposed → Accepted when ALL of these complete: (a) Codex RATIFIED verdict on this agent.md via review-agent-bundle.md skill, AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row), AND (d) Gate B baseline measurement begins (30% target; 4-week window). See §10 for the same checklist.)
**Date:** 2026-05-22.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
**Build complexity:** M (1 week) per Ultraplan §8.1 A1 line 489.
**Tier:** 2 (request-driven; no persistent PTY) per sequencing-target.md §2.1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (target voice-classifier ≥ 0.75 per `common-voice.json`; v0 implementation warns + exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unreachable per §5 honesty note — W4 polish closes this to unconditional hard-fail) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).

---

## §2 — Invocation surface

### CLI (v1.0)

```bash
# Manual consultant invocation, run from anywhere
ifosctl diagnostic \
  --firm "Charterhouse Partners" \
  --sector "fintech" \                  # optional; helps tighten ICP fit scoring
  --tenant <slug>                       # which tenant's target_patch + voice corpus to use
  --notify-via telegram                 # optional; pings consultant when done
```

Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY). Typical wall-clock: 10-15 minutes (empirical Day-13 measurement against Hays plc + Charterhouse fixtures); not specified in upstream master brief or Ultraplan.

### v1.1+ surfaces (deferred)

- Brain UI "Diagnose Firm" button → triggers via internal API
- Telegram bot command (`@ifos_bot diagnose Charterhouse Partners`)
- Bulk-mode (`ifosctl diagnostic --firm-list firms.csv`) — out of v1.0 scope

---

## §3 — The 12 required sections

Every report MUST contain these 12 sections. The generator (`@ifos/diagnostic-generator`) emits them in the order listed below. Gate A at v0 enforces (a) ≥12 `##` headings present in the rendered draft AND (b) per-section citation coverage; exact-heading-title-and-order matching is W4 polish (validate.sh §1.3 currently counts `##` headings without exact-title matching, per `validate.sh` lines 89-97 "exact-heading matching not implemented at v0; W4 polish adds title + order check").

**v0 source-coverage state:** Companies House data (§1, §10) is live via `@ifos/companies-house` MCP connector. Web-scraped pages (§2 footprint URLs, §8 careers-page pain signals) are live via `@ifos/web-scraper`. **LinkedIn deep-data sections (§3 job posts, §5 placement timeline, §7 employee skills, §9 competitor employee scan, §11 decision-maker profiles) currently use `@ifos/diagnostic-generator` stub-with-Companies-House-fallback citations** — Proxycurl integration deferred to W4 polish per ADR-005. Each LinkedIn-dependent section still emits ≥1 evidence link (per-section Gate A satisfied) by falling back to Companies House URLs, but the data depth is degraded vs the full-coverage W4 target.

| # | Section | What it contains | v0 source(s) | W4-polish source |
|---|---|---|---|---|
| 1 | **Firm signal** | Companies House data: registered name, company number, incorporation date, latest filed accounts (revenue band + headcount band), registered office, recent director changes, share-class moves | Companies House API ✅ | (no change) |
| 2 | **Online footprint** | Primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404) | Web-scraper (HEAD + first 200 lines) ✅ | + LinkedIn company-page Proxycurl fetch |
| 3 | **Sector + role-type mix** | Sectors actively recruiting for; ratio of permanent vs contract roles in last 90 days; technical-vs-commercial-vs-operational split | **v0: stub with Companies House fallback citation** | LinkedIn job posts + careers-page scrape |
| 4 | **Geography** | Office locations + current hiring locations + remote-vs-onsite-vs-hybrid mix | Companies House registered office ✅ | + LinkedIn job posts location field |
| 5 | **Deal-size band proxy** | Salary bands or day-rate ranges in job posts; level distribution; recent placements via LinkedIn timeline | **v0: stub with Companies House fallback** | LinkedIn job posts + Proxycurl employee timeline |
| 6 | **ICP fit vs target_patch** | Score 0-100 against tenant `target_patch.json` (sectors / geographies / size_bands / deal_size_band_gbp); per-dimension match/mismatch list | Tenant config + §1-§5 ✅ | (no change) |
| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | **v0: stub with Companies House fallback** | LinkedIn JDs + Proxycurl employee profiles |
| 8 | **Pain signals** | Phrases on careers page suggesting urgency / hiring pressure / workload concerns | Careers-page scrape ✅ | + LinkedIn director-post search + Glassdoor (opt-in) |
| 9 | **Competitor positioning** | Other recruitment firms visible in the candidate flow (previous-employer agencies; @firm tags; "Who's hiring this firm" inference) | **v0: stub with Companies House fallback** | LinkedIn profile + agency-tag search |
| 10 | **Recent activity** | LinkedIn company posts in last 90 days; press releases or news mentions; funding events visible on Companies House | Companies House filing history + web search ✅ | + LinkedIn company-page posts |
| 11 | **Decision-maker map** | Named people likely to be buyers: head of talent / CPO / hiring manager equivalents; LinkedIn profile URL per person; tenure | **v0: stub with Companies House director list** | LinkedIn employee search filtered by title |
| 12 | **Conversation opener** | 2-3 sentence cold outreach pitch tailored to §8 pain signals; written in consultant's voice (voice-classified); includes specific evidence anchor | LLM-generated; voice-classified ✅ (when classifier URL reachable; warn+exit 0 otherwise per §5) | (no change) |

**Gate A hard-fails** (per ADR-006 + §5 spec):

- Fewer than 12 sections present
- Any section with zero citation links (per-section citation subcheck; ADR-006-canonical)
- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + exit 0 when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail with explicit `validate_check_skipped` audit row)*
- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)
- PII (email-domain mismatch) detected outside firm boundary *(v0 hard-fail when firm-domain whitelist available; warn + exit 0 when whitelist absent per §5 honesty note; W4 polish closes to unconditional hard-fail. v0 PII regex covers emails only; phone-number PII detection deferred to W4 polish.)*

**Per-step audit-row signatures** (per `decision_log`):
- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier

---

## §4 — Workflow

Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.

```
0. Session start — invocation arrives via CLI ifosctl diagnostic
   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
   → hh_decision_trigger("session_start", firm_name + sector_hint)

1. Validate input (cycle.sh Step 1)
   → cycle.sh checks: firm name length ≥ 2 chars
   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
     payload {escalation_code: ESC_INPUT_VALIDATION_FAIL, ...}
   → exit 1 on validation failure

2-11. Generator run (cycle.sh Steps 2-11 — single generator call)
   → bash invokes @ifos/diagnostic-generator with firm + sector + target_patch flags
   → generator fetches all 12 sections internally:
     - §1 Companies House lookup (cached 7d per gotcha §6.2)
     - §2 Online footprint via web-scraper + LinkedIn URL discovery
     - §3-§5-§7 Job posts harvest + tech stack extraction
     - §6 ICP fit scoring against tenant target_patch
     - §7-§11 Director + employee scan
     - §8 Pain signal extraction
     - §10 Recent activity scan
     - §12 Conversation opener (LLM-generated, voice-classified)
   → generator writes complete draft Markdown to /tmp/diagnostic-<firm-slug>-<ISO-date>.draft.md
   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
   → ESC_RATE_LIMIT_HIT raised internally by web-scraper / companies-house on 429
   → ESC_VOICE_DRIFT raised internally by §12 LLM step if classifier <0.75 after 3 retries
   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")

12. Validate (Gate A) (cycle.sh Step 12)
   → bash invokes validate.sh against the draft path
   → per-section citation hard-fail (ADR-006 Tier 1; no warn-only path)
   → voice classifier + PII subchecks per §5 honesty note (warn-only on
     upstream-unavailable in v0; W4 closes to hard-fail)
   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE or
     ESC_PII_LEAKAGE_RISK) and exit 1
   → cycle.sh deletes draft on Gate A fail

13. Atomic vault write + report-render audit row (cycle.sh Step 13)
   → atomic mv -f /tmp/<draft> → /vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md
   → chmod 600 on the report
   → hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")
   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
     — tier: green per autosend-policy.yaml (no external send; vault write only)

14. Operator notification (optional, per --notify-via telegram flag) (cycle.sh Step 14)
   → if telegram: send via curl to api.telegram.org with report path + 200-char summary
     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
     → tier: green (operator-only Telegram; no customer-facing comms)
   → if no flag: silent completion (consultant checks vault); no decision-log row
   → cleanup.sh runs (drops transient LinkedIn cache per ToS gotcha §6.1)
   → exit 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.

**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.

**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.

- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
- Report length 400-2000 words — **v0: hard-fails as specified**
- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.

### Gate B — Outcome threshold (success metric, not block)

Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.

Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.

---

## §6 — Escalation codes

Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |

Diagnostic does NOT use:

- `ESC_RENDERER_FAILED` — that code is owned by the `_renderer` sentinel (agent_name='_renderer') per catalogue §2.4; Diagnostic never fires it
- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention

---

## §7 — Voice + tone constraints

Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
  - No "I hope this finds you well" or other generic openers
  - No salary or commission anchors in cold outreach
  - Specific evidence anchor required (not generic "great company")
- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Production-readiness dependencies

Full bundle (all 6 files + 3 fixtures) is built as of Day 19. Production readiness — i.e. running against a real pilot tenant — additionally requires the items below resolved to ✅.

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ✅ Applied Day 12 |
| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ✅ 24/24 invariants verified Day 12 |
| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
| Companies House MCP connector | `packages/mcp-connectors/companies-house/` | ✅ Shipped Day 13; 13/13 tests passing |
| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
| Web scraper utility (HEAD + first-N-lines) | `packages/utilities/web-scraper/` | ✅ Shipped Day 13 |
| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
| `context.sh` hydration | `agents/recruitment/diagnostic/context.sh` | ✅ Built |
| 3 fixtures with golden outputs | `agents/recruitment/diagnostic/fixtures/` | ✅ Built (01-primary + 02-edge-case + 99-voice-drift-canary) |
| Other bundle files (cycle.sh, tools.yaml, cleanup.sh) | `agents/recruitment/diagnostic/` | ✅ All built |
| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |

**Production-readiness gates:** all ⏸ items above must resolve to ✅ before first production render against a pilot tenant. Bundle code itself is complete.

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + Codex RATIFIED verdict + first production render.

**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (10+ rounds; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on smaller mechanical findings).

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
| Q5 | What's the "firm-slug" canonical form for the output filename? Companies House registration number? URL-slugified firm name? | Recommend Companies House number for stability; canonical-slug fallback for non-UK firms (v1.1+). |
| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |

### Gotchas (carried forward from Ultraplan §8.1 A1)

1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.
2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.

Status flips to Accepted when:
- Codex Round-3+ ratifies the full bundle
- Founder approves §3's 12-section list as canonical
- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
- Gate B baseline measurement begins (30% target; 4-week window)

Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.

*End of Diagnostic agent.md draft.*
