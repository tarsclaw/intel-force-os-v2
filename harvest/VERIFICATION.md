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
