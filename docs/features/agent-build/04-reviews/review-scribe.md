# Review — Scribe (spec-002) — Round 1

**Verdict: FAIL** (review sub-agent, 2026-06-10) · branch `worktree-agent-a59f16e915e384257` (5 commits over `f456a27`) · "strong, honest build — fails on exactly one thing"; fix is small and locally contained.
**Codex round 1 (session `20260610T131636Z-33646`): REJECTED:4 — all agent.md contract-doc findings** → combined fix pass dispatched.

## Findings
- **F1 BLOCKER** `validate.sh:230-254` + `cycle.sh:486` — Gate A **G6 (PII) scans only the first 500 bytes** (`head -c 500` preview) of the tacit note, while Step 9 exports the FULL body to Bullhorn (`create-note --body-file`); fixtures' notes are ~1,300-1,600 chars so >60% is never scanned, and `render-tacit-note.sh:107-109` falsely claims full coverage. Fix: G6 scans the full body (read the physical file from `tacit_note.vault_path`); preview stays for the audit row; add a >500-char tail-PII test case.
- **F2 MAJOR** cycle.sh Step 3 — spec lists `ESC_PII_LEAKAGE_RISK` at Step 3 (transcript-side); built Step 3 fires only `ESC_PROVIDER_FETCH_FAIL`. A declared deviation (transcripts inherently contain third-party contact data; note-side gate is the right control point) would be acceptable — but it wasn't declared. Declare or implement.
- **F3 MAJOR** `bin/bh-bridge.sh` vs Janitor's actual CLI — **NOT RECONCILED**; all three expected commands mismatch (full list in the review transcript §3): `refresh` output shape; failure semantics (should use the network-free `check-auth` probe to distinguish `unavailable` from `failed`); `update-entity` doesn't exist (only `update-candidate`/`update-client`, `--patch` not `--fields`, no Contact/JobOrder/Placement updates); `create-note` is person-scoped `--comments` inline (no `--entity-type/--entity-id/--body-file/--title`); token-path default; numeric-id typing. Mandatory pre-merge reconciliation — agreed contract defined by orchestrator (below).
- **F4 MINOR** `cycle.sh:307-315` — `${tmp_tx}.cli` written outside the `umask 177` subshell (brief default-perm transcript exposure).
- **F5 MINOR** `cycle.sh:660` — `WORST_SLA_CLASS` records the LAST call's class, not the worst, in multi-meeting sweeps.
- **F6 MINOR** `cycle.sh:621-643` — Step-9-fail rollback reverses cache+PATCH but leaves the Step-8 `recent_edit` 'deferred' row → inflates Gate B denominator. Resolve the row in rollback.
- **F7 MINOR** shim refresh-failure mapping → ESC spam post-merge without creds; use `check-auth`.
- **F8 MINOR** `tools.yaml:247-249` — word-cap labelled G7 (twice); built validate.sh has word-cap G8, auth G7.
- **F9/F10 ADVISORY** — SLA anchored to call end (catalogue-consistent, stricter); webhook-401 path exits before `scribe_run_complete` (defensible).

## Codex round-1 findings (agent.md)
1. Pre-pivot Fathom/Fireflies webhook prose throughout §1/§2/§4/§6/§8/§9/§10 vs the Granola-poll bundle — rewrite around Granola (the pivot is already founder-decided, W5 Day-29; only the §10 status flip stays founder-gated).
2. Stale build-state claims (validate.sh "does not exist" etc.) — post-build honesty update (Scout R1-4 precedent).
3. §3 promises Bullhorn note attach for every entity, but Opportunity is cache-only (no note endpoint; cycle.sh defers) — define the cache-only/vault-only Opportunity output path.
4. Contractor named in §3 contract but absent from field table/resolution shape — align with the implementation (exclude from v1.0 contract or add the full row).

## Deviations — all 9 ACCEPTED (F1/F2 should have been items 10-11; their absence is part of the FAIL)

## Agreed `@ifos/bullhorn` CLI contract (orchestrator ruling — binds both fix passes)
- `refresh` → `{ok, oauth_expires_at_ms, token_state: "refreshed"|"fresh"}` (Janitor adds `token_state`).
- `check-auth` (exists, network-free) — Scribe shim MUST use it to map not-provisioned → `unavailable` (no ESC) vs real refresh failure → `failed` (ESC_BULLHORN_AUTH).
- NEW `update-entity --entity-type Candidate|ClientContact|JobOrder|Placement --id <N> --patch <json>` → `{ok, updated, entity_type, id}` (Janitor adds; existing update-candidate/update-client stay).
- `create-note` extended: `--person-id <N> | (--entity-type <T> --entity-id <N>)` + `--body-file <path>` + optional `--title` → `{ok, note_id}`; if Bullhorn cannot attach notes to a given entity type, the CLI returns an explicit `{ok:false, reason:"unsupported_entity"}` and Scribe falls back to person-resolution (documented, honest).
- Token path: `IFOS_TOKEN_DIR` override is the per-tenant mechanism; shim header documents it.
- IDs numeric; callers pass numeric strings.

## Test evidence (reviewer-run)
build-gate **PASS** (shellcheck ×43; 4 connector suites; 9/9 DB suites) · extraction 26 asserts PASS · gate-a 19 asserts PASS (8 fail classes + ESC routing) · sla 19 asserts PASS · 5 atomic commits w/ footer · zero boundary violations · ADR-002 honoured · all emitted action_types registered.

## Disposition
Fix pass on the Scribe branch (F1/F2/F4-F8 + Codex 1-4 + shim reconciliation to the agreed contract) + Janitor fix pass extends the CLI per the contract. Then targeted re-review of F1/F2 + Codex round 2 on both.
