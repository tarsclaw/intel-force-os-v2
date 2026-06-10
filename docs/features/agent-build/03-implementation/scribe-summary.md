# Scribe build summary — W6 build slice (spec-002)

**Date:** 2026-06-10 · **Branch:** `worktree-agent-a59f16e915e384257` (rebased onto `a78a1e2`)
**Verdict:** `bash scripts/build-gate.sh` **PASS** (shellcheck CLEAN 43 files; 4 connector
suites green; 9/9 DB-backed fixture suites green incl. the 3 new Scribe suites).
Live Bullhorn/Granola smoke **founder-gated** (see Honest scope).
**Round-2 fix pass applied 2026-06-10** (review-scribe.md FAIL verdict + Codex
round-1 REJECTED:4) — see the Round-2 section at the end.

## Per-step status (spec-002 §4)

| Step | Marker | Status |
|---|---|---|
| 0 | `session_start` trigger | LIVE (context.sh + cycle.sh) |
| 1 | `webhook_verified` (+ `granola_meetings_polled` discovery row) | LIVE — mode=webhook does real HMAC-SHA256 (`openssl`, secret `$SCRIBE_WEBHOOK_SECRET`) or bearer compare; mismatch → `ESC_INPUT_VALIDATION_FAIL` + exit 1 (the 401 path). poll-sweep/replay emit `signature:not_applicable` honestly (Granola publishes no webhooks — Deviation 1) |
| 2 | `bullhorn_auth_refreshed` | LIVE via `bin/bh-bridge.sh refresh` (2 retries → `ESC_BULLHORN_AUTH`); the shim probes the network-free `check-auth` first — not-provisioned → `unavailable` honestly, NO ESC (round-2 F3/F7) → Gate A G7 then blocks writes |
| 3 | `transcript_fetched` | LIVE — Granola vendor; sources: seeded fixture file/dir → `@ifos/granola` CLI (expected surface documented; not built) → notes-only degraded ingest; /tmp file mode 0600; retry-once 30s → `ESC_PROVIDER_FETCH_FAIL` (upstream=granola) |
| 4 | `entity_resolved` | LIVE — RLS-scoped `entities` cache email match, priority placement>brief>opportunity>contact>candidate; no match → `ESC_AGENT_OUTPUT_SHAPE` + `validate_gate_a_fail` + skip |
| 5 | `fields_extracted` | LIVE — `bin/extract-fields.sh`: deterministic regex extraction (default; fixture-reproducible) + opt-in LLM path (`IFOS_SCRIBE_USE_LLM=1` + key; `claude-opus-4-8`, json_schema output, deterministic fallback on any failure); <3 fields ≥0.6 → `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` + gate row + skip |
| 6 | `tacit_note_rendered` | LIVE — `bin/render-tacit-note.sh`: §3 Output 2 shape, 8-category taxonomy, ≤12-word quote clipping, no compensation in narrative, participant emails masked to local parts, ≤800-word cap; vault file 0600; decision_log payload = `{vault_path, body_sha256, voice_score}` ONLY (ADR-002) |
| 7 | `fields_validated` + Gate A subprocess | LIVE — `bin/validate-fields.sh` (schema-file-derived allowlist) then `validate.sh`; <3 valid → `ESC_SCHEMA_VIOLATION` + gate row + skip |
| 8 | `bullhorn_scribe_field_write` (yellow) | LIVE — RLS `entities` cache UPDATE (DB trigger re-validates shapes) + `bh-bridge update-entity --entity-type --id --patch` PATCH (agreed contract flags); prior-data snapshot for rollback; the Gate B `recent_edit` row (`resolution='deferred'`) is inserted only AFTER Step 9 settles (round-2 F6 — table is append-only for ifos_app); opportunity = cache-only by design |
| 9 | `bullhorn_note_append_summary` (yellow) | LIVE — `bh-bridge create-note --entity-type/--entity-id/--body-file/--title`; `unsupported_entity` (exit 5) → person-scoped fallback when the entity IS a person (`fallback:person_scoped` on the yellow row) else honest defer (round-2 contract); hard fail → best-effort Step 8 rollback (cache restore + reverse PATCH; no recent_edit row exists yet) + `ESC_BULLHORN_WRITE_FAIL`; bridge-unavailable → `note_attach_deferred` output row (no fake yellow row — no Bullhorn state changed) |
| 10 | `scribe_run_complete` | LIVE — per-call elapsed since call end via `bin/sla-class.sh`; `ESC_SCRIBE_SLA_MISS` sla_type=summary_render (>30min) / note_attach (>1h); 10-min Gate B miss recorded, no ESC; session row records the WORST SLA class across the sweep, severity-ranked (round-2 F5) |

All 7 spec-002 §5 Gate A checks LIVE in `validate.sh` (G1 webhook-sig, G2 field-count,
G3 voice **warn-when-unscored**, G4 field-names, G5 field-types, G6 PII boundary —
**FULL physical note body** resolved from `tacit_note.vault_path`, fail-closed when
unreadable (round-2 F1 fix; the 500-char preview is audit-row-only), G7 auth re-query)
plus G8 word-cap (agent.md §3, retained from skeleton).

## Fixture results (deterministic, DB-backed, throwaway tenants, FK-cascade cleanup)

| Suite | Result |
|---|---|
| `scripts/run-scribe-extraction-test.sh` | PASS — 34 assertions: extractor ≥3 fields ≥0.6, drop-invalid (4 invalid classes), end-to-end replay with all 11 spec markers in decision_log, entities-cache write, recent_edit deferred row, vault note 0600, <3-fields fail path (ESC + gate row + exit 1 + no write), **+8 round-2 bridge-contract assertions** (shim `unsupported_entity` → exit 5 + reason; person-scoped fallback leg; numeric-id guard exit 2; cycle.sh fallback yellow row `fallback:person_scoped`; Step-9-fail replay exit 1; recent_edit deferred count UNCHANGED across the failed run — F6; `ESC_BULLHORN_WRITE_FAIL` routed) |
| `scripts/run-scribe-gate-a-test.sh` | PASS — 23 assertions: 2 PASS paths (verified-sig and poll-trigger + warn-when-unscored) + 10 fail cases each with ESC routing asserted (`ESC_BULLHORN_AUTH`, `ESC_INPUT_VALIDATION_FAIL`, `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`, `ESC_VOICE_DRIFT`, `ESC_SCHEMA_VIOLATION`×2, `ESC_PII_LEAKAGE_RISK`×3 — preview-range PII + **tail-PII beyond the 500-char preview (round-2 F1 case)** + fail-closed unreadable body, `ESC_AGENT_OUTPUT_SHAPE`) + 10 `validate_gate_a_fail` rows; every proposal writes the physical vault note G6 scans |
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
   *Superseded in the round-2 fix pass:* agent.md prose was reconciled to the
   Granola-poll built reality per Codex round-1 findings (the pivot itself was
   founder-decided W5 Day-29); the §10 status flip remains founder-gated and
   was NOT exercised.
10. **Transcript-side `ESC_PII_LEAKAGE_RISK` (spec-002 §4 row 3) not
    implemented** (review F2 — declared here as required). Transcripts
    inherently contain third-party contact data (every external attendee email
    is "PII outside the firm boundary" by the gate's own definition), so a
    transcript-wide scan would fire on every call and carry no signal. The
    transcript never leaves the firm boundary: /tmp mode 0600, purged ≤24h by
    cleanup.sh. The correct control point for what DOES leave (the full note
    body Step 9 exports to Bullhorn) is Gate A G6's full-body scan — which the
    F1 fix made real. Declared at the cycle.sh Step 3 call site + agent.md §4
    Step 3 + §6.

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
Round-2 fix pass additionally touched `agent.md` (Granola/built-state
reconciliation — Codex round-1 findings; §10 status flip NOT exercised).
No edits to `agents/_shared/*`, `packages/mcp-connectors/*`, `scripts/build-gate.sh`,
other agents' directories, or `packages/harness/cortextos/*`.

## Round-2 fix pass (2026-06-10 — review-scribe.md FAIL + Codex round-1 REJECTED:4)

Rebased onto `a78a1e2` (clean — docs-only delta on main). Every finding mapped
to its fix; `build-gate.sh` PASS after the pass.

### Review findings (code)

| Finding | Severity | Fix |
|---|---|---|
| F1 — G6 scanned only the 500-char preview while Step 9 exports the FULL note body | **BLOCKER** | `validate.sh` G6 resolves the physical note from `tacit_note.vault_path` (`IFOS_VAULT_ROOT` mapping) and scans the FULL body (frontmatter excluded); fail-closed (`ESC_PII_LEAKAGE_RISK`) when unreadable; preview demoted to audit-row-only. New gate-a cases: tail-PII (>500-char note, clean head, external email in the tail → G6 FAIL + ESC + gate row) + fail-closed unreadable body. `bin/render-tacit-note.sh` coverage claim now true. |
| F2 — transcript-side `ESC_PII_LEAKAGE_RISK` (spec §4 row 3) unimplemented and undeclared | MAJOR | DECLARED as deviation 10 (above) — not implemented by design; note-side full-body G6 is the control point. No transcript-wide scan added. |
| F3 — `bin/bh-bridge.sh` not reconciled with the Janitor CLI | MAJOR | Shim conforms to the agreed CLI contract (orchestrator ruling): `check-auth` probe, `refresh` `{ok, oauth_expires_at_ms, token_state}`, `update-entity --entity-type --id --patch`, extended `create-note` with `unsupported_entity` → exit 5 → person-resolution fallback or honest defer; `IFOS_TOKEN_DIR` documented; numeric-id guard. Fixtures prove all logic without the live CLI (new `note-fail`/`note-unsupported` test modes; +8 assertions). |
| F4 — `${tmp_tx}.cli` written outside the umask-177 subshell | MINOR | CLI-normalised transcript now created inside a `umask 177` subshell — 0600 from birth. |
| F5 — `WORST_SLA_CLASS` recorded the LAST call's class | MINOR | Severity-ranked `_sla_rank` comparison — Step 10 records the worst class across the sweep. |
| F6 — Step-9-fail rollback left the Step-8 `recent_edit` 'deferred' row | MINOR | Mechanism discovered via the new rollback fixture: `recent_edit` is **append-only for ifos_app** (SELECT+INSERT grants only) so delete-on-rollback is impossible — the row is now inserted only AFTER Step 9 settles; a rolled-back write never enters Gate B's denominator (fixture asserts the count is unchanged across a failed run). |
| F7 — refresh-failure mapping → post-merge ESC spam without creds | MINOR | Subsumed by F3: shim's `check-auth` probe maps not-provisioned → exit 3 `unavailable` (NO ESC); only genuine refresh failure reaches `ESC_BULLHORN_AUTH`. |
| F8 — tools.yaml word-cap labelled G7 | MINOR | Relabelled G8 (auth is G7); bridge-note updated to the agreed command surface; stale `--type` flag comments fixed. |
| F9 — SLA anchored to call end (stricter than webhook/poll receipt) | ADVISORY | **Declared note:** kept as built — catalogue-consistent ("after call end") and strictly harder on Scribe (poll latency counts against us, honestly). Recorded in agent.md §4 Step 10. |
| F10 — webhook-401 path exits before `scribe_run_complete` | ADVISORY | **Declared note:** kept as built — a rejected (unauthenticated) webhook is not a Scribe run; the rejection is fully audited (`ESC_INPUT_VALIDATION_FAIL` + `webhook_verified` `result:invalid; rejected:401`), and emitting a run-complete row for unauthenticated input would fabricate a session that never started. |

### Codex round-1 findings (agent.md)

| Finding | Fix |
|---|---|
| 1 — pre-pivot Fathom/Fireflies webhook prose throughout | §1/§2/§4/§6/§8/§9/§10 rewritten around the Granola poll-sweep as the v1.0 PRIMARY trigger; the HMAC/bearer-verified webhook surface retained as the supported SECONDARY mode (`signature:not_applicable` in poll/replay); Fathom/Fireflies reduced to historical pre-pivot notes. §10 status flip NOT exercised (founder-gated). |
| 2 — stale build-state claims (validate.sh "does not exist" etc.) | Banner + §5 + §8 rewritten to post-build truth with per-component states: bundle + fixtures BUILT and gate-green; NO live smoke (creds EMPTY, Granola token absent, CLIs unbuilt); voice classifier NOT built; LLM path opt-in only. Nothing overstated. |
| 3 — §3 promised Bullhorn note attach for every entity incl. Opportunity | Explicit cache-only/vault-only Opportunity contract path: `bullhorn_push:cache_only_by_design`, Step 9 `note_attach_deferred` `reason:opportunity_cache_only_no_note_endpoint`, EXCLUDED from the "note mirrored to Bullhorn" promise. |
| 4 — contractor named in §3 contract but absent from resolver/field table | Implementation truth checked: cycle.sh resolution priority is exactly `placement>brief>opportunity>contact>candidate` — contractor is not resolvable or writable this slice. Removed from the v1.0 §3 contract with a v1.1+ note. |

### Round-2 evidence

`bash scripts/build-gate.sh` **PASS** post-fix (shellcheck CLEAN; 4 connector
suites; 9/9 DB suites). Scribe suites: extraction 34 asserts PASS (incl. the
8 bridge-contract/rollback cases) · gate-a 23 asserts PASS (incl. tail-PII +
fail-closed) · sla 19 asserts PASS. Still NOT live-smoked — creds/token state
unchanged; nothing claimed beyond fixtures.
