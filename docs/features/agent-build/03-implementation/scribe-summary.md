# Scribe build summary — W6 build slice (spec-002)

**Date:** 2026-06-10 · **Branch:** `worktree-agent-a59f16e915e384257` (based on `f456a27`)
**Verdict:** `bash scripts/build-gate.sh` **PASS** (shellcheck CLEAN 43 files; 4 connector
suites green; 9/9 DB-backed fixture suites green incl. the 3 new Scribe suites).
Live Bullhorn/Granola smoke **founder-gated** (see Honest scope).

## Per-step status (spec-002 §4)

| Step | Marker | Status |
|---|---|---|
| 0 | `session_start` trigger | LIVE (context.sh + cycle.sh) |
| 1 | `webhook_verified` (+ `granola_meetings_polled` discovery row) | LIVE — mode=webhook does real HMAC-SHA256 (`openssl`, secret `$SCRIBE_WEBHOOK_SECRET`) or bearer compare; mismatch → `ESC_INPUT_VALIDATION_FAIL` + exit 1 (the 401 path). poll-sweep/replay emit `signature:not_applicable` honestly (Granola publishes no webhooks — Deviation 1) |
| 2 | `bullhorn_auth_refreshed` | LIVE via `bin/bh-bridge.sh refresh` (2 retries → `ESC_BULLHORN_AUTH`); bridge-unavailable recorded honestly → Gate A G7 then blocks writes |
| 3 | `transcript_fetched` | LIVE — Granola vendor; sources: seeded fixture file/dir → `@ifos/granola` CLI (expected surface documented; not built) → notes-only degraded ingest; /tmp file mode 0600; retry-once 30s → `ESC_PROVIDER_FETCH_FAIL` (upstream=granola) |
| 4 | `entity_resolved` | LIVE — RLS-scoped `entities` cache email match, priority placement>brief>opportunity>contact>candidate; no match → `ESC_AGENT_OUTPUT_SHAPE` + `validate_gate_a_fail` + skip |
| 5 | `fields_extracted` | LIVE — `bin/extract-fields.sh`: deterministic regex extraction (default; fixture-reproducible) + opt-in LLM path (`IFOS_SCRIBE_USE_LLM=1` + key; `claude-opus-4-8`, json_schema output, deterministic fallback on any failure); <3 fields ≥0.6 → `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` + gate row + skip |
| 6 | `tacit_note_rendered` | LIVE — `bin/render-tacit-note.sh`: §3 Output 2 shape, 8-category taxonomy, ≤12-word quote clipping, no compensation in narrative, participant emails masked to local parts, ≤800-word cap; vault file 0600; decision_log payload = `{vault_path, body_sha256, voice_score}` ONLY (ADR-002) |
| 7 | `fields_validated` + Gate A subprocess | LIVE — `bin/validate-fields.sh` (schema-file-derived allowlist) then `validate.sh`; <3 valid → `ESC_SCHEMA_VIOLATION` + gate row + skip |
| 8 | `bullhorn_scribe_field_write` (yellow) | LIVE — RLS `entities` cache UPDATE (DB trigger re-validates shapes) + `bh-bridge update-entity` PATCH; prior-data snapshot for rollback; per-write `recent_edit` row (`resolution='deferred'`) for Gate B edit-rate; opportunity = cache-only by design |
| 9 | `bullhorn_note_append_summary` (yellow) | LIVE — `bh-bridge create-note`; hard fail → best-effort Step 8 rollback (cache restore + reverse PATCH) + `ESC_BULLHORN_WRITE_FAIL`; bridge-unavailable → `note_attach_deferred` output row (no fake yellow row — no Bullhorn state changed) |
| 10 | `scribe_run_complete` | LIVE — per-call elapsed since call end via `bin/sla-class.sh`; `ESC_SCRIBE_SLA_MISS` sla_type=summary_render (>30min) / note_attach (>1h); 10-min Gate B miss recorded, no ESC |

All 7 spec-002 §5 Gate A checks LIVE in `validate.sh` (G1 webhook-sig, G2 field-count,
G3 voice **warn-when-unscored**, G4 field-names, G5 field-types, G6 PII boundary,
G7 auth re-query) plus G8 word-cap (agent.md §3, retained from skeleton).

## Fixture results (deterministic, DB-backed, throwaway tenants, FK-cascade cleanup)

| Suite | Result |
|---|---|
| `scripts/run-scribe-extraction-test.sh` | PASS — 26 assertions: extractor ≥3 fields ≥0.6, drop-invalid (4 invalid classes), end-to-end replay with all 11 spec markers in decision_log, entities-cache write, recent_edit deferred row, vault note 0600, <3-fields fail path (ESC + gate row + exit 1 + no write) |
| `scripts/run-scribe-gate-a-test.sh` | PASS — 19 assertions: 2 PASS paths (verified-sig and poll-trigger + warn-when-unscored) + 8 fail classes each with ESC routing asserted (`ESC_BULLHORN_AUTH`, `ESC_INPUT_VALIDATION_FAIL`, `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`, `ESC_VOICE_DRIFT`, `ESC_SCHEMA_VIOLATION`×2, `ESC_PII_LEAKAGE_RISK`, `ESC_AGENT_OUTPUT_SHAPE`) + 8 `validate_gate_a_fail` rows |
| `scripts/run-scribe-sla-test.sh` | PASS — 19 assertions: 11 boundary buckets (0/240/300/301/600/601/1800/1801/3600/3601/7200s) + 4 cycle.sh integration cases (under-5-min, Gate-B 10-min miss with NO ESC, 30-min summary_render, 2h note_attach) |

## Deviations (numbered, with rationale)

1. **Webhook + poll dual trigger.** spec-002 §4 Step 1 mandates webhook signature
   verification; the Day-29 vendor (Granola) publishes no webhooks. Built BOTH:
   mode=webhook with real HMAC/bearer verification (agent.md §2 surface), and the
   poll-sweep operational path emitting `webhook_verified` with
   `signature:not_applicable` (Gate A G1 accepts {verified, not_applicable};
   hard-fails {invalid, missing}). Every-step-emits-its-marker holds without faking
   a verification that has no input.
2. **`granola_meetings_polled` retained** as an additional discovery output row
   (not in the §3 marker set, which is a MUST-EXPOSE minimum, not a cap) — it is
   the Granola-pivot operational record (count, window, workspace).
3. **ESC_GRANOLA_PLAN_TIER / ESC_GRANOLA_AUTH not fired.** Both are QUEUED for
   catalogue registration; `autosend_escalate` on an unregistered code produces a
   fail-safe-red meta row. Free-tier degradation is recorded as
   `ingest_mode:notes_only_degraded` on the audit rows; granola fetch failures
   route through catalogue `ESC_PROVIDER_FETCH_FAIL` with `upstream=granola`
   (agent.md §6 sanctioned). Fixture 02 documents the post-registration contract.
4. **Step 8 writes the IFOS `entities` cache as the primary surface** with the
   Bullhorn PATCH push via `bh-bridge.sh` recorded as
   `bullhorn_push:pushed|deferred_bridge_unavailable`. While the bridge CLI is
   unbuilt the action row records the real state change (cache write) honestly;
   Step 9 with no bridge emits `note_attach_deferred` (no yellow row — nothing
   changed in Bullhorn). Reconciliation point when Janitor's bridge lands:
   `agents/recruitment/scribe/bin/bh-bridge.sh` ONLY.
5. **Voice retries.** agent.md's 3-retry voice loop presumes a non-deterministic
   generator. The v1.0 deterministic renderer emits one canonical rendering —
   `retries:0` recorded; the retry loop becomes meaningful when the LLM
   note-generator + classifier land. Unscored states are honest:
   `unscored/no_corpus` (empty voice_corpus) or `unscored/no_classifier` (corpus
   present, classifier microservice is W4-5 polish). `IFOS_FORCE_VOICE_SCORE` is
   the clearly-labelled test hook (HH_AWAIT_TEST_MODE precedent) used by fixture 99.
6. **`recent_edit` rows written at Step 8 with `resolution='deferred'`** — the
   table requires NOT NULL resolution; 'deferred' = pending consultant review,
   giving Gate B its edit-rate denominator. Consultant tooling later flips rows to
   approved_verbatim/approved_after_edit/rejected.
7. **`firm_domains` is NOT a v0.4 tenant_adapters allowlist key** (16-key trigger
   verified) — context.sh keeps the env override + tenant-slug heuristic; promoting
   the key is a v0.5-supplement item.
8. **`scribe_cleanup`/`bullhorn_oauth`/`granola_oauth` remain hh_decision_output**
   — registering them needs an `agents/_shared/autosend-policy.yaml` edit, outside
   this slice's boundary (CC cleanup precedent). Queued for the policy owner.
9. **agent.md untouched** (founder-gated status + W6-ratification rewrite). Its
   §4 Step 3 Fathom/Fireflies text remains PRE-PIVOT prose; the divergence is
   tracked at contract level (spec-002 §8 + this summary), implemented as Granola.

## Honest scope (spec-002 §8 — verified again 2026-06-10, names-only check)

- **Bullhorn dev creds EMPTY** (BULLHORN_CLIENT_ID/SECRET/SANDBOX_* all EMPTY in
  dev-sandbox `_secrets.env`) and the `@ifos/bullhorn` CLI bridge is unbuilt → no
  live Bullhorn call was made or simulated outside the labelled
  `BH_BRIDGE_TEST_MODE` fixture hook.
- **Granola IFOS-side OAuth token NOT on disk** (`~/.ifos-local-vault/*/granola-tokens-*.json`
  absent — the Claude-Code MCP keychain token is not what `@ifos/granola` reads)
  and the test workspace has 0 recorded meetings → Step 3 live path is dormant;
  fixture-proven with seeded transcripts. `@ifos/granola` has no dist/cli.js yet;
  the expected CLI surface (`list-meetings --since` / `get-transcript --meeting`)
  is documented at the call sites in cycle.sh.
- **ANTHROPIC_API_KEY is SET** — the LLM extraction path exists but fixtures never
  enable it (`IFOS_SCRIBE_USE_LLM` unset ⇒ deterministic).
- **Live smoke checklist for the founder:** provision Bullhorn sandbox creds; land
  the Janitor `@ifos/bullhorn` CLI bridge (then reconcile `bin/bh-bridge.sh`);
  complete the Granola OAuth dance to put the IFOS-side token on disk; record ≥1
  meeting in the test workspace; run
  `cycle.sh --mode replay --call-id <meeting_id>` without `BH_BRIDGE_TEST_MODE`.

## Files touched

`agents/recruitment/scribe/{cycle,validate,context,cleanup}.sh`, `tools.yaml`,
`README.md`, `fixtures/{01,02,99}-*.yaml`, new `bin/{bh-bridge,extract-fields,
render-tacit-note,validate-fields,sla-class}.sh`, new
`scripts/run-scribe-{extraction,gate-a,sla}-test.sh`, this summary.
No edits to `agents/_shared/*`, `packages/mcp-connectors/*`, `scripts/build-gate.sh`,
other agents' directories, or `packages/harness/cortextos/*`.
