# Sourcing Scout — request-response passive sourcing

**Status:** Proposed.
**Build state:** W9 build slice COMPLETE (spec-003; branch `worktree-agent-a45354564e8f66257`, 2026-06-10) — all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN; three deterministic DB-backed fixture suites green. Prior contract history: Day-20 W4 bilateral pass + R19 substantive fix; R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`; R19 (2026-05-24) added the `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups (creds EMPTY; live smoke founder-gated) + Codex re-ratification of the built bundle + founder approvals per §10.
**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the cleanup action name `sourcing_scout_cleanup` is NOT a registered autosend-policy action_type — registration is a founder-gated policy decision (a `future_registration` entry in tools.yaml, not an action_type claim); `cleanup.sh` emits `hh_decision_output` until it lands. `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.

**v1.0 readiness caveat — LinkedIn deep-data vendor (added 2026-06-02):** the original v1.0 design listed **Proxycurl** as the LinkedIn deep-data source (one of FOUR sources in the §1 output contract). **Proxycurl was shut down in 2025** following LinkedIn's January 2025 lawsuit against Nubela (Proxycurl's parent; ~50% of their revenue came from LinkedIn scraping; see https://nubela.co/blog/goodbye-proxycurl/). The successor product **NinjaPear** (same team) explicitly does NOT carry LinkedIn data — it is a B2B competitive-intelligence platform sourced from non-LinkedIn channels. Net: the LinkedIn-via-Proxycurl path in the original four-source design **does not have a legally-clear vendor as of 2026-06-02**; §1 + §3 + §4 Step 4 + §6 below are written to the three-source v1.0 contract with LinkedIn as an explicit NO-OP row.

**v1.0 disposition (per founder decision 2026-06-02):** LinkedIn deep-data is **DEFERRED to v1.1+**. v1.0 Sourcing Scout operates against **THREE active sources** (Bullhorn-candidate passive-match + Reed + CV-Library), not four. The §1 output contract's "5-15 candidates" Gate A target is preserved; Reed + CV-Library + Bullhorn passive-match combined are sufficient at v1.0 pilot scale (≤3 tenants). LinkedIn-vendor selection for v1.1+ takes place at W8-9 when the Sourcing Scout build slice forces the choice and we have more clarity on the post-lawsuit legal landscape (candidate vendors: Lix, Phantombuster, Apify with LinkedIn-aware contracts, or LinkedIn's own Sales Navigator enterprise API at much higher cost). Until that decision: §4 Step 4 (LinkedIn search) is an explicit structurally-present NO-OP in v1.0; the ranked-list assembly at Step 6 weights the 3 active sources accordingly; the §3 output template still shows the LinkedIn row but populates it as "deferred to v1.1+; vendor pending" rather than a scraped result. Gate B target (≥6 of 10 advance per ULTRAPLAN A5 line 553) unchanged at v1.0 — the marginal contribution of LinkedIn deep-data is unknown until pilot data lands; v1.1+ vendor selection partly informed by whether Gate B underperforms without it.

**Schema-key references:**
- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 434; `allowed_keys` array lines 432-445; element-type validation block lines 510-523); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 823-840 (R19 added this declaration; no longer deferred).
- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from THREE active v1.0 sources** (Bullhorn ATS passive-match read; Reed.co.uk API; CV-Library API) — LinkedIn is structurally present as an explicit NO-OP row only (deferred to v1.1+ per the vendor caveat above; §4 Step 4 emits `linkedin_query` with `results:0; no_op`). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).

---

## §2 — Invocation surface

### Brain UI (v1.0 primary)

Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.

### Telegram command (v1.0)

```
@ifos_bot scout <brief-id-or-slug>
@ifos_bot scout --description "Senior React engineer, London, £120k, hybrid"
```

### Webhook (DEFERRED to v1.1+)

Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables `auto_source_on_brief_create`. v0.4-supplement-pending (config key not yet registered); webhook-trigger code path is BLOCKED until v0.4 supplement lands. v1.0 invocation is Brain UI button + Telegram only.

### CLI (v1.0 — debugging)

```bash
ifosctl sourcing-scout source --tenant <slug> --brief-id <id>
ifosctl sourcing-scout source --tenant <slug> --description "<free-text>"
```

### v1.1+ surfaces (deferred)

- Night Sourcer Tier-1 always-on (Brain UI dashboard; cortextOS primitive #6)
- Bulk-source mode (`--brief-list briefs.csv`)
- Refresh-source mode (re-source against the same brief 30 days later)

---

## §3 — Output shape

One output per invocation. Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md`. Structure:

```markdown
# Sourcing Scout — <Brief title>
**Generated:** <ISO-date>  **Brief ID:** <Bullhorn-brief-id>  **Tenant:** <slug>
**Sources searched:** Bullhorn ATS + LinkedIn (deferred to v1.1+; vendor pending) + Reed + CV-Library
**Aggregate candidates:** <N> (top 5-15 ranked)

## Brief context
<2-3 sentences summarising the role from the brief input>

## Ranked candidates

### 1. <Candidate name> — confidence 0.92
**Source:** Bullhorn (passive match) | **Contact:** <method + verified>
**Match rationale:**
<≥50 words explaining why this candidate is a match — references brief
requirements + candidate background; cites Bullhorn placement history,
LinkedIn current role, or other source-specific evidence.>
**Risk flags:** <e.g., "active with placement at competitor agency 2024";
"prefers contract not perm per Bullhorn note">
**Profile links:** [Bullhorn](url) | [LinkedIn](url)

### 2. <Candidate name> — confidence 0.88
...

(5-15 candidates total)

## Source breakdown
| Source | Candidates contributed | Avg confidence | Rate-limit budget remaining |
|---|---|---|---|
| Bullhorn ATS | <N> | <score> | n/a (no quota) |
| LinkedIn | 0 (NO-OP; deferred to v1.1+; vendor pending) | — | — |
| Reed | <N> | <score> | <remaining> |
| CV-Library | <N> | <score> | <remaining> |

## Diagnostic + exception list
- <Any source failures (e.g., "Reed API 429; retried once; 3 candidates lost")>
- <Any "do not contact" filter hits>
- <Any low-confidence candidates discarded (below 0.5)>
```

Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.

Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style is the TARGET contract — **NOT enforced in v1.0, because no voice classifier exists**: `@ifos/voice-classifier` is a W4-5 polish microservice (per tools.yaml + §8 build deps), not built. ALL v1.0 rationales are recorded as `unscored` — reason `no_corpus` (empty tenant `voice_corpus`) or `classifier_unavailable` (corpus active but no classifier; `cycle.sh` Step 9 records this even when `CTX_VOICE_CORPUS_STATE=active`) — never a faked score, and `validate.sh` G4 warns-and-passes on any unscored rationale. **Warn-when-unscored is the accepted v1.0 gate behaviour** (spec-003 §5 "hard (warn-when-unscored)" + the Cash Conductor honesty precedent). The ≥0.75 hard enforcement — including the corpus-exists distinction — ACTIVATES when `@ifos/voice-classifier` ships. The threshold logic itself is live: a real computed score <0.75 after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list; ESC_VOICE_DRIFT never fires on `unscored`.

---

## §4 — Workflow

11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.

```
0. Session start
   → context.sh hydrates: tenant config + multi-source auth + voice-corpus
     STATE (active|absent; tone rules via hh_load_tone_rules — voice
     SAMPLES are not loaded in v1.0, see §7)
     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
     backed per ADR-002 vault/Postgres split; canonical v0.1 + v0.2 + v0.3
     registered config key)
   → hh_decision_trigger("session_start", "scout <brief-id-or-slug>")

1. Brief ingestion
   → if brief_id: bullhorn.get_brief(brief_id) → fetch fields
   → if free-text description: LLM parse → extract role / location / sector
     / seniority / day-rate-band / must-haves / nice-to-haves
   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
     escalation-codes.md §2.5 — canonical code for under-resolvable briefs)
   → hh_decision_output("brief_ingested", "<brief_id_or_slug>",
     "key_dims:<N>")

2. Multi-source auth refresh
   → bullhorn (read-only); Reed; CV-Library. LinkedIn: NO auth at v1.0
     (Step 4 is a NO-OP; vendor deferred to v1.1+)
   → per-source auth failure fires the catalogue-specified ESC code with
     its catalogue-specified degraded-mode behavior:
     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
       enters degraded mode per catalogue ("drafts-only, no auto-send" —
       Sourcing-Scout-specific interpretation: skip Bullhorn source +
       continue with the other 2 active sources, since Sourcing Scout has
       no auto-send path of its own; the "drafts-only" framing maps to
       "report-only with Bullhorn data omitted from the sourcing set")
     - ESC_REED_AUTH (catalogue §2.7): blocking → degraded mode (cached
       Reed search results only)
     - ESC_CVLIBRARY_AUTH (catalogue §2.7): blocking → degraded mode
       (cached CV-Library search only)
     - ESC_LINKEDIN_AUTH (catalogue §2.7): NOT fired at v1.0 — reserved
       for the v1.1+ LinkedIn vendor integration
   → if MULTIPLE sources are in degraded mode AND the remaining live
     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
     return partial report with exception note (Gate A floor violated)
   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
     "sources_ok:<N>/4; degraded:<list>; linkedin:v1.0_no_op")

3. Bullhorn passive-match query
   → bullhorn.search_candidates(filter=brief_key_dimensions,
     status='active', date_last_modified_at < now() - interval '90 days')
     — "passive" is a derived state (active candidate not recently
     modified); NOT a vertical-schema enum value. The schema defines
     candidate.status as [active, archived, do_not_contact, placed,
     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
     as the recency field (line 100). Passive-match queries filter on
     modification recency within the active set.
   → up to 30 candidates fetched (will rank+filter later)
   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")

4. LinkedIn search — explicit NO-OP at v1.0 (deferred to v1.1+)
   → structurally present per the Janitor Step 7 NO-OP pattern: emits an
     empty result set into the Step 7 aggregate; the §3 report shows the
     LinkedIn row as "deferred to v1.1+; vendor pending"
   → no vendor call, no cache, no auth, no ESC at v1.0 (Proxycurl shut
     down 2025 per the v1.0 readiness caveat; v1.1+ vendor selection
     pending — Lix / Phantombuster / Apify / Sales Navigator)
   → hh_decision_output("linkedin_query", "brief:<id>",
     "results:0; no_op; reason:v1.0_caveat_proxycurl_shutdown;
      vendor_selection:v1.1_deferred")

5. Reed query
   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   → up to 30 candidates
   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
     (payload.upstream='reed')
   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")

6. CV-Library query
   → cvlibrary.search_candidates(query, location, salary_band)
   → up to 30 candidates
   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
     (payload.upstream='cv-library')
   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")

7. Aggregate + dedupe
   → merge all sources into single candidate set
   → dedupe across sources by (name + email) OR (name + phone) OR
     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   → annotate each row with source provenance (e.g., "from Bullhorn + Reed
     match" if found in both)
   → hh_decision_output("aggregate_dedupe", "brief:<id>",
     "pre_dedupe:<N>; post_dedupe:<N>")

8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
     (concept referenced by autosend-policy.yaml red-tier
     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
     §2.10; the config key IS registered in the canonical authority
     `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 434;
     `allowed_keys` array lines 432-445; element-type validation block
     lines 510-523).
     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
     Postgres-backed per ADR-002 vault/Postgres split — NOT vault markdown.
     `blocked_recipients` is now declared in `vertical-schema.v0.3-supplement.yaml`
     lines 823-840.)
   → remove any candidate matching any DNC identifier from the sourcing list
   → log dropped candidates to exception list in §3 output
   → NOTE: ESC_DNC_FILTER_HIT is catalogue §2.10 reserved for OUTBOUND SEND
     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
     TIME (pre-outbound); no outbound send attempt occurs. v0.3 disposition:
     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
     add ESC_SOURCING_DNC_FILTER for the pre-outbound case.
   → hh_decision_output("dnc_filter", "brief:<id>",
     "dropped:<N>; kept:<N>")

9. LLM ranking + rationale generation (per candidate)
   → for top 15 by source-aggregated confidence: generate per-candidate
     rationale ≥50 words
   → prompt = (brief context + candidate profile + tone rules) — v1.0 uses
     deterministic rationale templates (accepted deviation 7); voice-corpus
     samples (hh_load_voice_samples) join the prompt with the documented
     LLM-rationale enhancement, NOT in v1.0 (see §7)
   → voice scoring (v1.0 honesty): NO voice classifier exists in v1.0
     (@ifos/voice-classifier is W4-5 polish, not built) — ALL v1.0
     rationales record voice_score "unscored" (reason no_corpus when
     voice_corpus is empty; classifier_unavailable when a corpus is
     active), never a faked number; warn-when-unscored is the accepted
     v1.0 gate behaviour per spec-003 §5. The ≥0.75 hard enforcement
     activates when @ifos/voice-classifier ships.
   → ESC_VOICE_DRIFT only on a REAL computed classifier score <0.75
     after 3 retries; drop candidate from final list (the threshold
     branch is live in cycle.sh Step 9 + validate.sh G4 whenever a
     numeric score is present; never fired on "unscored")
   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)

10. Output assembly + Gate A validation
    → ensure 5-15 candidates remaining after Step 9
    → ensure each has working contact method (email validated via simple
      regex + domain MX check; phone validated via E.164 format)
    → ensure each rationale ≥50 words
    → if any condition fails: write partial draft to /tmp, then emit the
      mandatory audit row hh_decision_action("validate_gate_a_fail",
      "brief:<id>", payload_hash, "ESC_AGENT_OUTPUT_SHAPE; <failed_condition>")
      — output-shape violation per catalogue line 184 (distinct from
      ESC_SCHEMA_VIOLATION, reserved for vertical-schema field-constraint
      violations at write time; audit row mandatory per master brief §8.1
      Change 2 + autosend-policy.yaml lines 119-123) — then abort (exit 1)
      BEFORE the scout_report row below
    → write Markdown report to vault path per §3
    → hh_decision_output("scout_report", report_path, "N candidates from M sources")

11. Session close + notification
    → operator notification per invocation source (Brain UI: in-app
      notification; Telegram: reply with report path; webhook: bus event back)
    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
      "N=<N> sources_used=<M>")
    → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):

- **"5–15 candidates returned per brief"** (count within range)
- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
- **"each has rationale ≥ 50 words"**
- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
- All rationales pass voice classifier ≥0.75 — the TARGET contract; **NOT hard-enforced in v1.0, because no voice classifier exists** (`@ifos/voice-classifier` is W4-5 polish, not built). ALL v1.0 rationales carry `unscored` (`no_corpus` or `classifier_unavailable` — a score is never faked, even when `CTX_VOICE_CORPUS_STATE=active`) and G4 warns-and-passes on any non-numeric score: **warn-when-unscored is the accepted v1.0 gate behaviour** (spec-003 §5 "hard (warn-when-unscored)" + the Cash Conductor honesty precedent). G4's hard-fail branch is live for any real numeric score <0.75 (→ ESC_VOICE_DRIFT); the ≥0.75 hard enforcement activates when `@ifos/voice-classifier` ships
- No PII outside firm boundary in rationale text → fires `ESC_PII_LEAKAGE_RISK` (BLOCKING per catalogue §2.5 lines 148-154; halts immediately, not warn-only output-shape)
- No enabled live source returns 0 candidates WITHOUT a recorded degradation exception note (sources in degraded mode per §4 Step 2 are expected to return 0 and don't trip Gate A)

Gate A failure routing by class:
- PII leakage → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall)
- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.

**Build note (updated 2026-06-10; the original Cat-5 honesty note said `validate.sh` did not exist yet):** `agents/recruitment/sourcing-scout/validate.sh` is now LIVE — delivered by the W9 build slice (spec-003 §5) implementing G1-G7 against the contract above, exercised by `scripts/run-scout-gate-a-test.sh` (PASS + 9 fail classes; deterministic DB-backed fixtures). Not yet production-proven: no live run has occurred (creds EMPTY; live smoke founder-gated).

### Gate B — Outcome threshold (success metric, not block)

Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.

Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply (v1.0). Aggregate over rolling 30-day window per tenant. NOTE: Bullhorn-note feedback is NOT a v1.0 path (Sourcing Scout is read-only on Bullhorn per §1 + §6 contracts; would require write capability not in v1.0 scope).

Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).

Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.

---

## §6 — Escalation codes

Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
| `ESC_LINKEDIN_AUTH` | v1.1+ LinkedIn vendor session/OAuth fail — NOT fired at v1.0 (§4 Step 4 is an explicit NO-OP; no vendor) | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / reed / cv-library; linkedin reserved for v1.1+) | warn | operator_chat_id |
| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries — REAL computed score only; never fired on `unscored` (no classifier in v1.0, so this code does not fire until `@ifos/voice-classifier` ships) | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |

Sourcing Scout does NOT use:

- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.

---

## §7 — Voice + tone constraints

Step 9 (per-candidate rationale generation) is voice-constrained — tone rules are LIVE; classifier scoring + voice-sample retrieval are PENDING (no classifier in v1.0; see below). The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
  - No salary-band reference unless explicitly supplied by candidate
  - No claims about candidate intent ("looking to leave their role") without evidence in source data
  - No mention of competing agency placements except in risk-flag context
- **`hh_load_voice_samples` ANN query against tenant voice_corpus** (top-5 chunks matching "candidate sourcing rationale" task context) — **PENDING, NOT wired in v1.0**: `context.sh` calls `hh_load_tone_rules` only, and the deterministic v1.0 rationale templates (accepted deviation 7) do not consume voice samples. The `hh_load_voice_samples` integration lands together with the documented LLM-rationale enhancement + `@ifos/voice-classifier`.
- **Voice-drift detection (classifier-only):** per `vertical-schema.v0.3-supplement.yaml` lines 597-606 (§2a access-list amendment) + 728-737 (access matrix), Sourcing Scout has `recent_edit` access of **W** (writes its rationale drafts) but **not R**, so it does NOT read consultant edit history via `hh_load_recent_edits`. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries — REAL computed scores only; NO scores are computed in v1.0 (no classifier built — `@ifos/voice-classifier` is W4-5 polish): every v1.0 rationale records `unscored` (`no_corpus` when the corpus is empty; `classifier_unavailable` when a corpus is active) and `validate.sh` G4 warns-and-passes (the accepted v1.0 warn-when-unscored gate behaviour per spec-003 §5; hard-scoring activates when the classifier ships). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. The cron — not Sourcing Scout — reads edit history for analytics + canary threshold tuning.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W9 prerequisites — table updated 2026-06-10 post-W9-build)

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
| **Bullhorn Sub-decisions A+B Accepted** | Sub-decision A RESOLVED 2026-06-02; B pending | ⏸ |
| Bullhorn MCP read capability | `packages/mcp-connectors/bullhorn` package exists; Sourcing-Scout OAuth CLI bridge + creds pending → Step 2 degraded-skip | ⏸ (partial) |
| **LinkedIn vendor selection + commercial signup** (Proxycurl shut down 2025) | Founder commercial, v1.1+ | DEFERRED v1.1+ |
| **Reed.co.uk commercial signup** + API access | Founder commercial (creds EMPTY) | ⏸ |
| **CV-Library commercial signup** + API access | Founder commercial (creds EMPTY at last names-only verification) | ⏸ |
| LinkedIn vendor MCP connector | v1.1+ after vendor selection | DEFERRED v1.1+ |
| Reed MCP connector | `packages/mcp-connectors/reed` v0.1.0, tests green | ✅ (creds EMPTY) |
| CV-Library MCP connector | `packages/mcp-connectors/cv-library` v0.1.0 + `dist/cli.js` bridge | ✅ (creds EMPTY; live smoke founder-gated) |
| Source-abstraction layer (Night Sourcer reuse) | `_scout_query_source()` in cycle.sh (W9 build slice) | ✅ (ADR per §9 Q6 still to be authored) |
| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| `@ifos/voice-classifier` microservice (Step 9 scoring + G4 ≥0.75 hard enforcement) | W4-5 polish backlog (per tools.yaml) | ⏸ NOT BUILT — all v1.0 rationales record `unscored` |
| `validate.sh` Gate A logic | W9 build slice (spec-003 §5; G1-G7) | ✅ |
| `context.sh` hydration | W9 build slice (canonical `tenant_adapters` SELECTs) | ✅ |
| `cycle.sh` orchestration (11-step) | W9 build slice (spec-003 §4) | ✅ |
| 3 fixtures with golden outputs | W9 build slice + 3 DB-backed test suites | ✅ |

**Post-W9-build note:** the four sibling-bundle deliverables (validate.sh, context.sh, cycle.sh, fixtures) WERE the W9 build slice and are delivered on this branch; the W9 build proceeded against deterministic fixtures per spec-003 §8 honest scope. The remaining ⏸ rows are FOUNDER/TENANT-ADMIN actions (commercial signups, creds, DNC population, voice corpus, ratifications) — they gate the first LIVE run and the §10 lifecycle transitions (Proposed → Accepted → In Force per the rewritten §10), not the fixture-backed build.

---

## §9 — Status + open questions

**Status:** Proposed (W9 build slice COMPLETE on this branch — bundle LIVE per the build-state header; §10 status flip is founder-gated). Awaits Bullhorn Sub-decision B + 2 commercial signups (Reed + CV-Library; LinkedIn vendor deferred to v1.1+) + Q1 LOI + Codex re-ratification + founder approvals per §10.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | All three v1.0 sources required? Reed + CV-Library are UK-recruitment-specific; LinkedIn deep-data is deferred to v1.1+ post-Proxycurl-shutdown. Could v1.0 ship with Bullhorn + one job board only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
| Q2 | LinkedIn vendor pricing (v1.1+) — the original Proxycurl model (~$39/mo for 5,000 credits, ~$20-50/day at peak per consultant) is void post-shutdown. Per-tenant budget cap for the v1.1+ vendor? | Deferred to v1.1+ vendor selection (Lix / Phantombuster / Apify / Sales Navigator); cost ceiling per brief remains the design constraint whichever vendor is chosen. |
| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. A new ADR (number assigned at authoring time; not ADR-006 — that's Diagnostic Gate A) at W9 build start documenting the source-abstraction interface. |
| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |

### Gotchas (carried forward from ULTRAPLAN A5 line 555)

1. **LinkedIn vendor rate limits (v1.1+).** The original Proxycurl per-credit quota model is void post-shutdown; the underlying constraint stands — deep profile fetches cost more than searches, so plan a cost ceiling per brief for whichever v1.1+ vendor is selected.
2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`). **Single post-W9 criteria set (rewritten 2026-06-10).** The pre-build "Ratified-as-Scaffold" intermediate state (introduced at R9) applied to the scaffold-only document; the W9 build slice is COMPLETE on this branch, so the unit that ratifies now is the BUILT bundle (this agent.md + 6 sibling files + 3 fixtures), not the scaffold. Lifecycle:

1. **Proposed** — CURRENT state. W9 build slice complete; build-gate GREEN; three deterministic DB-backed fixture suites green. No live API call has been made by this bundle; creds EMPTY.

2. **Proposed → Accepted** when ALL of:
   - Codex review-agent-bundle returns RATIFIED on the built bundle (this agent.md + `tools.yaml` + `context.sh` + `validate.sh` + `cycle.sh` + `cleanup.sh` + `README.md` + 3 fixtures)
   - Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B feedback UX)
   - Q6: source-abstraction-layer ADR drafted + ratified (new ADR — not the same as ADR-006 which is Diagnostic Gate A; number assigned at authoring time)

   **No production-run requirement at this state** — Accepted certifies the built, Codex-ratified, founder-approved bundle. (Q2 — LinkedIn vendor cost model — is deferred to v1.1+ vendor selection per §9 and does not gate Accepted.)

3. **Accepted → In Force** when ALL of:
   - First production brief processed end-to-end against the migration-test tenant, with live-smoke evidence (live smoke is founder-gated: Reed + CV-Library commercial signups + Bullhorn Sub-decision B + creds provisioned)
   - Gate B feedback loop operational (Telegram /scout-feedback path; Brain UI in v1.1)
   - First production render against a pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)

The **Status** field at the top of this document remains **Proposed** — every lifecycle flip is founder-gated.

*End of Sourcing Scout agent.md draft.*
