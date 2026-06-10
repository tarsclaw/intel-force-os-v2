# Spec 002 — Scribe build

**A sub-agent given ONLY this file + `agents/recruitment/scribe/agent.md` + the Cash Conductor
template + CLAUDE.md has everything it needs to build Scribe autonomously.**

- **Agent dir:** `agents/recruitment/scribe/` (cycle.sh 10-step + validate.sh + dual context.sh + cleanup.sh + tools.yaml + 3 fixtures — SKELETON, ~13 TODO markers)
- **Master-plan source (READ IN FULL):** `agents/recruitment/scribe/agent.md`
- **Mirror template:** Cash Conductor. Reuse: RLS psql idiom; `bin/` LLM-render helper (CC `render-chase-draft.sh`) for the tacit-note; the `scripts/run-*-test.sh` fixture pattern; CC Step 6 idempotent write-back + ESC routing for the Bullhorn writes.
- **Wave/tier:** v1.0 W6; Tier 1 webhook-driven. **Scribe is the data spine (agent.md §1).**
- **⚠ TRANSCRIPT VENDOR = GRANOLA (`@ifos/granola`).** The agent.md §4 Step 3 text still names Fathom/Fireflies — that is PRE-PIVOT and WRONG. The W5 Day-29 vendor pivot moved Scribe's transcript source to **Granola**. Build every transcript-fetch path against `@ifos/granola`. Do NOT implement Fathom or Fireflies. (See §2, §4 Step 3, §8.)

## 1. Scope
Replace the 13 TODO markers (cycle.sh + validate.sh + context.sh) with live impl matching
agent.md §3-§6: the 10-step per-call workflow, ≥3 structured Bullhorn field writes + 1 tacit-note
(8-category taxonomy), Gate A, deterministic fixtures. Out of scope: Ringover provider (v1.1).

## 2. Upstream contract (CONSUMES — freeze on main first)
- `agents/_shared/` substrate — frozen.
- **autosend-policy action_types (registered, yellow):** `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`; + green `validate_gate_a_fail`, `scribe_run_complete`. Verify via grep.
- **Postgres (v0.3/v0.4 schema):** `entities` (Bullhorn cache: Candidate/Contact/Brief/Placement + IFOS-cached Opportunity v0.3 fields), `recent_edit` (Gate B edit-rate measurement), `decision_log`, `voice_corpus`. **Confirm the v0.3-supplement field names exist** (must_haves/nice_to_haves/deal_breakers on Brief; placement_status/satisfaction_signal/week_1_status_vault_path on Placement; headcount_growth_signal_text/hiring_velocity_band/decision_window_text on Opportunity) — agent.md §3 flags re-verifying these against the supplement; if a field is missing that is an Upstream-contract item to land on main first.
- **Connectors:** `@ifos/bullhorn` (auth + PATCH/POST writes — needs CLI bridge), `@ifos/granola` (transcript fetch — the vendor; see §8).
- **Voice:** `hh_load_tone_rules` (∋ scribe) + `hh_load_voice_samples`.

## 3. Downstream contract (MUST EXPOSE)
- decision_log markers: `webhook_verified`, `bullhorn_auth_refreshed`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered` (output, `{vault_path,body_sha256,voice_score}` — body NOT in payload per ADR-002), `fields_validated`, + action rows `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`.
- `recent_edit` rows other agents (Janitor) + Gate B read.

## 4. Workflow steps to wire (agent.md §4 — EVERY step)
| Step | What to implement | marker | ESC on fail | CC pattern |
|---|---|---|---|---|
| 0 | Session start (webhook handler); context.sh hydrate | `hh_decision_trigger session_start` | — | CC Step 0 |
| 1 | Webhook signature verify (HMAC/bearer) | `webhook_verified` | `ESC_INPUT_VALIDATION_FAIL` (401) | — |
| 2 | Bullhorn auth refresh | `bullhorn_auth_refreshed` | `ESC_BULLHORN_AUTH` | CC Step 1 |
| 3 | Transcript fetch (**Granola** — see §8) → /tmp 0600 | `transcript_fetched` | `ESC_PROVIDER_FETCH_FAIL`, `ESC_PII_LEAKAGE_RISK` | — |
| 4 | Participant→entity inference; resolve bullhorn_id+type | `entity_resolved` | `ESC_AGENT_OUTPUT_SHAPE` (no target) | — |
| 5 | LLM field extraction (per-field confidence; drop <0.6; need ≥3) | `fields_extracted` | `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | CC Step 8 LLM pattern (deterministic fallback for fixtures) |
| 6 | LLM tacit-note (8-cat taxonomy, ≤800w, voice ≥0.75) → vault 0600 | `tacit_note_rendered` | `ESC_VOICE_DRIFT` (3 retries) | CC Step 8 render→vault (voice honesty) |
| 7 | Field validation vs vertical-schema (name + type/range; need ≥3 valid) | `fields_validated` | `ESC_SCHEMA_VIOLATION` + `validate_gate_a_fail`, exit 1 | CC Gate A G1 |
| 8 | Bullhorn field write (PATCH, yellow, atomic) | `bullhorn_scribe_field_write` | `ESC_BULLHORN_WRITE_FAIL` (no Step 9) | CC Step 6 write-back |
| 9 | Bullhorn note attach (POST /Note, yellow); rollback Step 8 on fail | `bullhorn_note_append_summary` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 |
| 10 | Session close + SLA metric (elapsed since webhook) | `scribe_run_complete` | `ESC_SCRIBE_SLA_MISS` (>30min render / >1h attach) | CC Step 14 |

## 5. Gate A (validate.sh) — every check (agent.md §5)
| Check | Rule | ESC | Enforcement |
|---|---|---|---|
| webhook-sig | valid per provider | `ESC_INPUT_VALIDATION_FAIL` | hard |
| field-count | ≥3 extractions ≥0.6 confidence | `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_AGENT_OUTPUT_SHAPE` | hard |
| tacit-voice | note classifier ≥0.75 | `ESC_VOICE_DRIFT` | hard (warn-when-unscored) |
| field-names | exist in target entity schema | `ESC_SCHEMA_VIOLATION` | hard |
| field-types | per-field type/range valid; ≥3 valid | `ESC_SCHEMA_VIOLATION` | hard |
| PII | none outside firm boundary in transcript/note | `ESC_PII_LEAKAGE_RISK` | hard |
| auth | Bullhorn refresh succeeded | `ESC_BULLHORN_AUTH` | hard |

## 6. Acceptance criteria
- All §4 steps emit markers (verify decision_log after fixture-mode run); all Gate A checks live.
- `bash scripts/build-gate.sh` green; new fixtures green; shellcheck CLEAN; RLS; boundaries; atomic commits; tree clean.

## 7. Test plan (deterministic fixtures)
- `scripts/run-scribe-extraction-test.sh` — seeded transcript + entity → assert field extraction (≥3 ≥0.6), schema validation (name+type/range), drop-invalid, and the <3-valid Gate A fail.
- `scripts/run-scribe-gate-a-test.sh` — PASS + each fail class (webhook-sig, field-count, voice, schema, PII) + ESC routes (register tenant first; decision_log FK).
- `scripts/run-scribe-sla-test.sh` — elapsed-time → SLA bucket logic (5/10/30min/1h thresholds + Gate B 10-min miss).

## 8. Honest-scope flags (DOCUMENT, NEVER FAKE)
- **🔴 BULLHORN CREDS BLOCKED (founder action):** Steps 2/8/9 hit Bullhorn (no dev creds). Build + fixtures + gate-green achievable; live-Bullhorn-smoke is post-creds. Build the `@ifos/bullhorn` CLI bridge; fixtures prove logic against seeded `entities`.
- **🟡 VENDOR = GRANOLA, not Fathom/Fireflies.** agent.md §4 Step 3 text still names Fathom/Fireflies, but the W5 Day-29 pivot moved the transcript vendor to **Granola** (`@ifos/granola`). Wire Step 3 to Granola. Granola live path is itself blocked: IFOS-side OAuth token not on disk (the Claude-Code MCP token is in keychain, not the `~/.ifos-local-vault/<tenant>/granola-tokens-*.json` path the connector reads) + the test workspace has 0 recorded meetings. So Step 3 live-smoke is blocked; fixture-prove with a seeded transcript file.
- Voice (Step 6): empty `voice_corpus` → record `unscored/no_corpus`, never faked (CC precedent).
- Field extraction (Step 5): use a deterministic fallback (like CC's templated draft) so fixtures are reproducible without the LLM; LLM path active when ANTHROPIC_API_KEY set.

## 9. Dependencies + sequencing
- Blocked-for-live by: Bullhorn creds + Granola IFOS-side OAuth token + ≥1 recorded meeting (all founder actions). NOT blocked for build/fixtures.
- Can run in parallel with: Janitor, Sourcing Scout (disjoint files). Spawn after Janitor proves the build machine + the `@ifos/bullhorn` CLI-bridge pattern (which Scribe reuses).
