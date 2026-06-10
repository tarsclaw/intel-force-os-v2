# Spec 003 — Sourcing Scout build

**A sub-agent given ONLY this file + `agents/recruitment/sourcing-scout/agent.md` + the Cash
Conductor template + CLAUDE.md has everything it needs to build Sourcing Scout autonomously.**

- **Agent dir:** `agents/recruitment/sourcing-scout/` (cycle.sh 11-step + validate.sh + multi-source context.sh + cleanup.sh + tools.yaml + 3 fixtures — SKELETON, ~15 TODO markers)
- **Master-plan source (READ IN FULL):** `agents/recruitment/sourcing-scout/agent.md`
- **Mirror template:** Cash Conductor (LLM render→vault + report assembler + RLS idiom) + reuse the **Janitor fuzzy matcher** (spec-001 §4 Step 3) for cross-source dedupe.
- **Wave/tier:** v1.0 W9; request-response passive sourcing. **READ-ONLY on Bullhorn — no writes, no auto-send.**

## 1. Scope
Replace the 15 TODO markers (cycle.sh + validate.sh + multi-source context.sh) with live impl
matching agent.md §3-§6: the 11-step brief→ranked-candidates workflow across 4 sources with
per-source degraded-mode, cross-source dedupe, DNC filter, LLM ranking+rationale, Gate A, and a
5-15 candidate Markdown report. Out of scope: LinkedIn (Proxycurl shut down → NO-OP); webhook
trigger (v1.1); Bullhorn writes (read-only agent).

## 2. Upstream contract (CONSUMES — freeze on main first)
- `agents/_shared/` substrate — frozen.
- **autosend-policy action_types:** `scout_run_complete` + green `validate_gate_a_fail`. **No write action_types** (read-only agent). Verify via grep.
- **Postgres:** `entities` (Bullhorn candidate read — source #1), `tenant_adapters.config.blocked_recipients` (DNC list, registered key), `decision_log`, `voice_corpus`. No new migration.
- **Connectors (the 4 sources):** `@ifos/bullhorn` (read-only candidate search), Proxycurl/LinkedIn (NO-OP), `@ifos/reed`, `@ifos/cvlibrary`. The source-abstraction layer must let rank+rationale logic be shared, not duplicated (gotcha ULTRAPLAN A5 line 555).
- **Voice:** `hh_load_tone_rules` (∋ sourcing_scout) + `hh_load_voice_samples`.

## 3. Downstream contract (MUST EXPOSE)
- decision_log markers: `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query`, `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (ONE row PER candidate, incl. dropped with `included=false`+drop_reason), `scout_report`, `scout_run_complete`.
- The vault Markdown report (ranked candidates + source breakdown + exception list) per §3.

## 4. Workflow steps to wire (agent.md §4 — EVERY step)
| Step | What to implement | marker | ESC on fail | CC/Janitor pattern |
|---|---|---|---|---|
| 0 | Session start; context.sh hydrate (multi-source auth + DNC list) | `hh_decision_trigger session_start` | — | CC Step 0 |
| 1 | Brief ingestion (brief_id→Bullhorn OR free-text→LLM parse) | `brief_ingested` | `ESC_BRIEF_AMBIGUITY` (<3 dims) | CC Step 8 LLM (deterministic fallback) |
| 2 | Multi-source auth refresh; per-source degraded mode on fail | `auth_refresh_complete` ("sources_ok:N/4; degraded:list") | per-source `ESC_*_AUTH` (blocking→degraded-skip); `ESC_AGENT_OUTPUT_SHAPE` if <5 obtainable | CC Step 1 |
| 3 | Bullhorn passive-match (active + not-modified-90d; ≤30) | `bullhorn_query` | `ESC_RATE_LIMIT_HIT` | CC Step 3 |
| 4 | LinkedIn search — **NO-OP** (Proxycurl shutdown); structurally present | `linkedin_query` ("results:0; no_op") | — | (skip) |
| 5 | Reed query (≤30) | `reed_query` | `ESC_REED_AUTH`, `ESC_RATE_LIMIT_HIT` | CC Step 3 |
| 6 | CV-Library query (≤30) | `cvlibrary_query` | `ESC_CVLIBRARY_AUTH`, `ESC_RATE_LIMIT_HIT` | CC Step 3 |
| 7 | Aggregate + dedupe across sources (name+email / name+phone / linkedin; ≥0.85) + provenance | `aggregate_dedupe` ("pre:N; post:M") | — | Janitor matcher (spec-001 §4) |
| 8 | DNC filter vs `blocked_recipients`; drop matches → exception list (no ESC fire) | `dnc_filter` ("dropped:N; kept:M") | — (W4-backlog ESC_SOURCING_DNC_FILTER) | — |
| 9 | LLM rank + per-candidate rationale (top 15; ≥50w; voice ≥0.75) | `candidate_proposed` (per candidate) | `ESC_VOICE_DRIFT` (drop candidate) | CC Step 8 render (voice honesty + fallback) |
| 10 | Output assembly + Gate A (5-15; contact method; rationale ≥50w) → vault report | `scout_report` | `ESC_AGENT_OUTPUT_SHAPE` + `validate_gate_a_fail`, exit 1 | CC Step 13 report assembler |
| 11 | Session close + notify (Brain UI / Telegram / bus per source) | `scout_run_complete` | — | CC Step 14 |

## 5. Gate A (validate.sh) — every check (agent.md §5)
| Check | Rule | ESC | Enforcement |
|---|---|---|---|
| count | 5–15 candidates returned | `ESC_AGENT_OUTPUT_SHAPE` | hard |
| contact | each has working contact (email+MX / E.164 phone / LinkedIn / Bullhorn id) | `ESC_AGENT_OUTPUT_SHAPE` | hard |
| rationale | each rationale ≥50 words | `ESC_AGENT_OUTPUT_SHAPE` | hard |
| DNC | none flagged in `blocked_recipients` | (filtered at Step 8) | hard |
| voice | all rationales classifier ≥0.75 | `ESC_VOICE_DRIFT` | hard (warn-when-unscored) |
| PII | none outside firm boundary in rationale | `ESC_PII_LEAKAGE_RISK` | hard (blocking) |
| source-floor | no enabled live source returns 0 WITHOUT a degradation note | `ESC_AGENT_OUTPUT_SHAPE` | hard |

## 6. Acceptance criteria
- All §4 steps emit markers (verify decision_log); all Gate A checks live.
- `bash scripts/build-gate.sh` green; new fixtures green; shellcheck CLEAN; RLS; read-only-on-Bullhorn honoured; boundaries; atomic commits; tree clean.

## 7. Test plan (deterministic fixtures)
- `scripts/run-scout-dedupe-test.sh` — seeded multi-source candidate sets → assert cross-source dedupe + provenance + the ≥0.85 matcher (reuse Janitor matcher fixtures).
- `scripts/run-scout-gate-a-test.sh` — PASS + each fail class (count<5 / >15, no contact method, rationale <50w, source-floor) + ESC routes + DNC drop (register tenant; decision_log FK).
- `scripts/run-scout-degraded-test.sh` — simulate per-source auth fail → assert degraded-mode skip + the <5-obtainable `ESC_AGENT_OUTPUT_SHAPE` floor.

## 8. Honest-scope flags (DOCUMENT, NEVER FAKE)
- **🟢 MOST LIVE-CAPABLE of the 4 agents.** CV-Library creds are SET → Step 6 + the full rank→report path can be **live-smoked end-to-end in degraded mode (CV-Library only)** producing a real ranked report. Strongly consider Sourcing Scout (not Janitor) as the live prove-one demo — it needs no Bullhorn write + has a live source.
- **🔴 Bullhorn (Step 3) BLOCKED** (read creds unobtainable) → degraded-skip; **Reed (Step 5) creds EMPTY** → degraded-skip until founder fills; **LinkedIn (Step 4) NO-OP** (Proxycurl). So v1.0 live sourcing = CV-Library (+ Reed when filled, + Bullhorn when creds land). The degraded-mode design (agent.md §4 Step 2) makes this graceful, not a failure.
- Voice (Step 9): empty `voice_corpus` → `unscored/no_corpus`, never faked.
- DNC at sourcing-time logs drops only (no ESC fire per v0.3 disposition).

## 9. Dependencies + sequencing
- NOT blocked for build/fixtures. Live-capable NOW via CV-Library (no founder action needed for a CV-Library-only live smoke). Reed/Bullhorn live = founder-gated.
- Can run in parallel with: Janitor, Scribe (disjoint files). Reuses the Janitor matcher → spawn after Janitor lands that helper, or carry a copy + reconcile at review.
