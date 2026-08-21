# harvest/ — the landing kit

Everything CortexOS hands the new estate repo. **Start at `LANDING-ORDER.md`** — it is the executable checklist,
67 rows across 11 stages, each with a verification command.

Governed by `docs/handoff/TRANSFER-MAP.md` (what moves), `CONFORMANCE-AUDIT.md` (what must change first) and
`MIGRATION-PLAN.md` (how). Results in `VERIFICATION.md`.

| Directory | Contents | Destination | Mechanic |
|---|---|---|---|
| `LANDING-ORDER.md` | **the checklist — read this first** | — | — |
| `patches/` | 3 landing patches (A1, A2, A3) — apply at landing, never here | — | PATCH |
| `actions/` | policy YAML ×2, join contract, `hook-helpers.sh` reference | `actions/` + `packages/authoriser` | re-home, zero edits |
| `contracts/` | 8 JSON Schemas (487) | `packages/contracts/` | verbatim |
| `migrations/` | `0000_baseline.sql` (from live prod), `0001` + rollback | `migrations/` | derived, verified |
| `vertical-pack/` | `vertical-schema.yaml` + 3 supplements (2,794) | `vertical-pack/recruitment/` | verbatim |
| `sql/` | 5 RLS-scoped query artefacts (400) | `packages/*/sql/` | verbatim |
| `registers/` | escalation catalogue (82 codes) + reconciliation appendix | `docs/registers/` | verbatim + appendix |
| `specs/` | 6 × `agent.md` + 6 × `tools.yaml` (3,978) | `docs/reference/agents/` | verbatim, reference only |
| `docs/adr-cortexos/` | 26 ADRs, 7 **renamed `ADR-CX-*`** | `docs/adr/cortexos/` | namespaced — prevents the IFOS ADR collision |
| `docs/architecture/` | 7 design docs | `docs/` | verbatim. **`tenancy-invariants.md` must land with the migrations** |
| `docs/runbooks/` | 4 operational runbooks | `docs/runbooks/` | verbatim |
| `docs/specs/` | `approval-routing-architecture.md` + PRODUCT-SPEC + ULTRAPLAN | `docs/canonical/` | verbatim. **The architecture doc must land with `actions/`** |
| `docs/learnings/` | 4 learnings incl. `00-cortextos-quirks.md` | `docs/` | verbatim |
| `scripts/` | `setup-local-dev-db.sh`, `verify-test-baseline.sh`, 2 runbooks | `scripts/` | verbatim |

## What is deliberately NOT staged here

**Whole package trees.** The 9 connectors (14,653 lines) and the 3 utilities packages (5,676) are clean copyable
units — `cp -r`, rewrite the scope, run the suite. Duplicating 20,000 lines of source into `harvest/` would double
the repo and create a second copy to keep in sync. `LANDING-ORDER.md` names their in-place source paths instead.

**The 18 shell test harnesses.** Same reason — they are one directory (`scripts/run-*-test.sh`) and move together.

The rule: `harvest/` stages what must be **assembled, derived, or namespaced**. Anything that is already a clean
copyable unit is referenced in place.

## The acceptance gate

`scripts/verify-test-baseline.sh` holds the per-package test counts captured at `ac0e361` — **380 passed, 9
skipped, zero failures**. Run it in the new repo after each package lands:

```
bash verify-test-baseline.sh @core
```

It exits non-zero when a package lands below its baseline. Silently skipped tests are the failure mode it exists
to catch: a suite running 40 of 52 cases looks identical to a healthy one on the console.
