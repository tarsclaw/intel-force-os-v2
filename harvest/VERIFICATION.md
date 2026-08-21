# Verification results — Stage 1 extraction

Run 2026-08-21. Migration plan §6 requires a mechanical pass criterion per asset class; nothing moves on trust.
Every check below was executed, not asserted.

| # | Check | Criterion | Result |
|---|---|---|---|
| V1 | Policy-layer join | key sets set-equal across both YAML files | **PASS** — 53 = 53 |
| V2 | Policy-layer duplicates | zero duplicate keys in either file | **PASS** — 0 and 0 |
| V3 | Policy property coverage | all 53 keys carry tier, trust_bucket, routing_rule, on_expiry | **PASS** — 53/53 on all four |
| V4 | No seeded auto-approval | zero `on_expiry: auto_execute` | **PASS** — 51 hold, 2 safe_default, 0 auto_execute |
| V5 | Baseline vs **live production** | `0000_baseline.sql` matches a fresh `pg_dump` of `ifos_v2` on `ifos-v2-prod-01` | **PASS by construction** — the file now *is* that dump (regenerated 2026-08-21). See revision note |
| V6 | Baseline version | v0.5 columns absent (prod is at v0.4) | **PASS** — confirmed against live: 0 of 2 present |
| V6b | Baseline applies to an empty DB | clean apply | **NOT VERIFIED LOCALLY** — requires pgvector, absent on this Mac. See dev-environment gap |
| V7 | Escalation reconciliation | every `ESC_*` in code is catalogued | **FAIL — 6 genuine defects.** See below |
| V8 | SQL artefacts | all bundle `.sql` staged | **PASS** — 5 files, 400 lines |
| V9 | Agent specs | 6 × agent.md + 6 × tools.yaml staged | **PASS** — 12 files, 3,978 lines |

## V7 — the one failure

Six escalation codes are wired into `tools.yaml` and connector source but were never added to the catalogue,
against the catalogue's own protocol ("new codes added here BEFORE wiring into helpers"):
`ESC_GRANOLA_PLAN_TIER`, `ESC_GRANOLA_AUTH`, `ESC_WORKOS_AUTH`, `ESC_WORKOS_VALIDATION_FAIL`,
`ESC_CVLIBRARY_VALIDATION_FAIL`, `ESC_REED_VALIDATION_FAIL`.

Each is self-documented in place as deferred ("QUEUED for catalogue registration at W6", "pending W5 Phase 4
addition"), so this is known debt, not a surprise. All six are connector-scoped and therefore Phase B.
**Disposition: register them when the connectors land, not now.** Recorded in
`registers/escalation-codes.md` Appendix A.1.

A further 5 tokens were grep artefacts (shell variables, a negative-path test fixture, one "phantom" code
explicitly removed in June) and 14 catalogued codes have never fired. Both sets are classified in Appendix A.2/A.3.

## Risk raised by this extraction — schema origin is not in source control

CortexOS holds no base schema. The migration chain is incremental from `v0.1-to-v0.2` onward, and
`setup-local-dev-db.sh` builds the dev database from `pg_dump` of the Hetzner VPS rather than from source. **The
origin state exists only on that server.** If it were lost, the schema could not be rebuilt from git.

`0000_baseline.sql` closes this — it is the first complete, self-contained schema definition the project has ever
had in version control, and it is round-trip verified. **The new repo should never regress to incremental-only.**

## Outstanding founder verification

`0000_baseline.sql` descends from the local dev database, which descends from a VPS dump of unrecorded date loaded
with `ON_ERROR_STOP=0` (`setup-local-dev-db.sh:81`) — so load errors were tolerated at that step. The baseline is
internally consistent and round-trip verified, but its agreement with **live production** is unconfirmed.

Before trusting it in the new repo, diff against a fresh dump:

```
ssh maddox@178.105.87.24 'sudo -u postgres pg_dump --schema-only ifos_v2' > /tmp/prod_schema.sql
# then diff against harvest/migrations/0000_baseline.sql (expect: v0.5 columns absent from both)
```

The assistant cannot run this — `ssh maddox@178.105.87.24` returns `Permission denied (publickey)`.

One observation to check while there: the v0.5 migration header names `voice_corpus_chunks` as an existing table,
but it is absent from the local dev DB's 11 tables. Either it was never created locally, or the dump predates it.


---

# REVISION 2026-08-21 (same day) — VPS reached, baseline regenerated

## What changed

`ssh maddox@178.105.87.24` failed for both assistant and founder with `Permission denied (publickey)`. Cause was
not lost access: the key `~/.ssh/ifos_hetzner_ed25519` exists but there is **no `~/.ssh/config` entry** and nothing
loaded in `ssh-agent`, so ssh never offered it and fell back to default key names that do not exist. Naming the key
explicitly connects:

```
ssh -i ~/.ssh/ifos_hetzner_ed25519 maddox@178.105.87.24     # -> ifos-v2-prod-01, PostgreSQL 16.14
```

**Recommended fix** — add to `~/.ssh/config` so the bare hostname works:

```
Host ifos-prod 178.105.87.24
    HostName 178.105.87.24
    User maddox
    IdentityFile ~/.ssh/ifos_hetzner_ed25519
```

## The defect this exposed

The original `0000_baseline.sql` was derived from the local dev DB and **was incomplete**. Diff against live:

| Missing from the derived baseline | |
|---|---|
| `CREATE EXTENSION vector` (pgvector) | |
| `public.voice_corpus_chunks` | `vector(1536)` embeddings, HNSW index (`vector_cosine_ops`, m=16, ef_construction=64), FK to `voice_corpus` ON DELETE CASCADE, RLS-isolated by `tenant_slug` |

Nothing was present in the baseline and absent from prod — it was a strict subset missing exactly one table and its
extension. **Production has 12 tables; the local dev DB has 11.**

`0000_baseline.sql` has been regenerated directly from the live `pg_dump` and is now authoritative rather than
derived. The earlier derivation is discarded; nothing depended on it.

## Root cause — a dev-environment gap, not a stale dump

`setup-local-dev-db.sh:81` loads the VPS dump with `ON_ERROR_STOP=0`. Local Postgres is **15.17 with no pgvector**;
production is **16.14 with pgvector**. So on every local setup run, `CREATE EXTENSION vector` fails silently, then
`voice_corpus_chunks` fails silently for want of the `vector` type, and the script's own guard passes anyway
because it only checks for a named subset of expected tables.

**Consequence:** every local dev database ever built by that script has been missing the embeddings table. Any
local work touching voice-corpus embeddings, semantic retrieval or pgvector would have failed in a way that looked
like a code bug.

## Actions for the new repo

| # | Action | Priority |
|---|---|---|
| 1 | `brew install pgvector` (0.8.6 available) and align local Postgres to **16** to match production | Before any local embeddings work |
| 2 | Change the dev-DB loader to `ON_ERROR_STOP=1` — silent tolerance is what hid this for months | WP-0 |
| 3 | Replace the named-table guard with a **count + set comparison against the baseline**, so a missing table fails loudly | WP-0 |
| 4 | Add the `~/.ssh/config` entry above so VPS commands are copy-pasteable | Any time |

## Closed

The two founder items raised in the original verification are both **resolved**: production agreement is confirmed
(the baseline is now the prod dump itself), and the `voice_corpus_chunks` question is answered — it exists in
production and was missing locally for the reason above.

---

# STAGE-1 LANDING KIT — verification, 2026-08-21

Second pass. Goal `migration-landing-kit`. All four gates run; results below.

| Gate | Criterion | Result |
|---|---|---|
| G1 | No landing patch applied to source | **PASS** — `git status packages/ agents/` clean throughout |
| G2 | Every staged file byte-identical to source, or declared derived | **PASS** — 0 mismatches across all staged copies |
| G3 | Every `TRANSFER-MAP` asset appears in `LANDING-ORDER.md` | **PASS after fix** — see below |
| G4 | Test baseline still holds | **PASS** — 380 passed / 9 skipped, BASELINE HELD |

## G3 caught three real omissions

The coverage check was not a formality. It found three assets staged or mapped with **no landing row**:

1. **`vertical-schema.yaml` + 3 supplements — 2,794 lines, staged to `harvest/vertical-pack/`, no row anywhere.**
   The single largest omission. Added as STAGE 9b.
2. **`scripts/provision-tenant.sh`** — Phase C config-centre input, no row. Added as STAGE 9b.
3. **The 8 JSON Schemas** — had a row, but cited only the `harvest/` path, so a reader could not trace them back
   to `packages/agents-runtime/_shared/`. Source path added.

Both new rows are Phase C. `LANDING-ORDER.md` grew 63 → 67 rows.

## Landing patches — actual vs estimate

All three came in **at or under** estimate, for one reason: both packages already inject their database access,
so the seam the new architecture requires was already present.

| Patch | Rule | Estimate | Actual | Shape |
|---|---|---|---|---|
| A1 | R2 single read path | ~30 lines | **8 changed lines** + 2 file relocations | `owner-lookup.ts` (131) + its test (100) move to `trust` |
| A2 | R3 single write path | ~60 lines | **~10 changed lines** + 1 file relocation | `decisions-postgres.ts` (152) moves to `spine` |
| A3 | R9 contracts purity | ~15 lines | **~10 lines** + a declaration block extracted | `types.ts` splits; **zero consumer imports change** |

No patch exceeded its estimate, so the STOP condition ("2× estimate means it is a port, not a refactor") was never
approached. **A1 is additionally a behavioural no-op**: `owner-lookup.ts:18-28` documents that the Bullhorn CLI
normalisers drop the owner field before it reaches `data` jsonb, so the lookup already returns null in production
and the ladder already falls through to function-role/firm-default.

## Two items raised for founder ruling

- **A2 rule gap.** R3 forbids non-`spine` **writes** to `decision_log`. Neither R2 nor R3 explicitly forbids
  **reading** it from outside `spine` — R2 is scoped to "brain content", and `decision_log` is spine content. A2
  moves the reader as well as the writer, on the §4 reading that the Value Spine tables are "P2 writes, ledger
  measures, P4 reads". **That is an interpretation, not a quoted rule.** If the ruling goes the other way, the
  reader stays in `queue` and A2 shrinks.
- **A3 second item.** `types.ts:146` `export const FUNCTION_NAMES = [...]` is a runtime *value* whose only purpose
  is to derive `FunctionName`. R9's hard line is "a function in contracts is a review rejection" — a const array is
  not a function. Recommended it ships with contracts, because the alternative (a hand-maintained union literal)
  reintroduces exactly the drift R9 exists to prevent. Flagged, not decided.

## Staging count

30 files → **95 files**. Added: 3 landing patches, 8 JSON Schemas, 4 vertical-schema files, 7 architecture docs,
4 runbooks, 3 specs, 4 learnings, 26 ADRs (7 renamed `ADR-CX-*`), `LANDING-ORDER.md`, `verify-test-baseline.sh`.
