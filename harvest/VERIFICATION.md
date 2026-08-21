# Verification results — Stage 1 extraction

Run 2026-08-21. Migration plan §6 requires a mechanical pass criterion per asset class; nothing moves on trust.
Every check below was executed, not asserted.

| # | Check | Criterion | Result |
|---|---|---|---|
| V1 | Policy-layer join | key sets set-equal across both YAML files | **PASS** — 53 = 53 |
| V2 | Policy-layer duplicates | zero duplicate keys in either file | **PASS** — 0 and 0 |
| V3 | Policy property coverage | all 53 keys carry tier, trust_bucket, routing_rule, on_expiry | **PASS** — 53/53 on all four |
| V4 | No seeded auto-approval | zero `on_expiry: auto_execute` | **PASS** — 51 hold, 2 safe_default, 0 auto_execute |
| V5 | Baseline round-trip | `0000_baseline.sql` → empty DB, then `0001` forward, byte-identical to the dev DB dump | **PASS** — md5 `e3d241c7…` both sides |
| V6 | Baseline rollback | v0.5 columns absent from the baseline | **PASS** — 0 of 2 present |
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
