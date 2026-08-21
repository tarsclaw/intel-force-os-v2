# Transfer map — every new-repo destination and what fills it

**Written:** 2026-08-21, after a systematic sweep of the whole repository rather than a guess at what mattered.
**Supersedes** the asset lists in `HARVEST-MANIFEST.md` and `MIGRATION-PLAN.md` where they disagree. Those
documents' *reasoning* stands; their inventories were incomplete.

Organised by **destination**, not by source, because the question that matters is "when I open package X in the
new repo to start building, what is already in it?"

---

## Correction to the earlier assessment

`MIGRATION-PLAN.md` and the conversation preceding it stated that the new repo's packages "share almost nothing
with CortexOS except the connectors," and put the rebuild column at ~13,300 lines.

**That was wrong.** A systematic sweep found three TypeScript packages under `packages/utilities/` that were never
opened, plus eight JSON Schema files under `packages/agents-runtime/_shared/`. Between them they already implement
the authoriser, the approval queue and the shared contract types — three of the seven packages Phase A was
scheduled to build from nothing.

The corrected position is in §1. Nothing below is inferred from a document; every row was checked on disk.

---

## 1. Phase A packages — what already exists

| New repo destination | Filled by | Volume | State |
|---|---|---|---|
| **`packages/authoriser`** | `packages/utilities/approval-routing` | **1,555 src + 1,342 test** | Working, tested |
| **`packages/queue`** | `packages/utilities/autosend-bridge-telegram` | **679 src + 703 test** | Working, tested |
| **`packages/contracts`** | `packages/agents-runtime/_shared/*.json` (8 JSON Schemas) + `approval-routing/src/types.ts` | **487 + types** | Working |
| **`actions/`** | `_shared/autosend-policy.yaml` + `_shared/action-class-registry.yaml` | **1,062** | Verified, 53 keys, set-equal |
| **`migrations/`** | `0000_baseline.sql` (from live prod) + `0001_reconciliation_writeback.sql` | **1,570 + 110** | Verified against production |
| **`packages/spine`** (decision log) | `decision_log` table (in baseline) + `autosend-bridge/src/decisions-postgres.ts` | schema + writer | Partial — outcome/holdout are new |
| `packages/shared` | `_shared/hook-helpers.sh`, `approval-routing/src/yaml-lite.ts`, `_shared/voice-loader.sh` | ~600 | Reference / port |
| `packages/mcp-seam` | — | — | **New. Nothing exists** |
| `packages/harness` | `packages/harness/cortextos` submodule @ `c21fbfe` | pinned | Already correct |

### What `approval-routing` actually is

`src/resolve.ts` header, verbatim:

> `resolve_approver(action) → ResolveResult` — the §4 record-owner-first ladder as a PURE function over injected
> dependencies. 1. RECORD OWNER · 2. FUNCTION ROLE · 3. FIRM DEFAULT. Every result carries `ladder_step` +
> `reason` — routing itself is auditable.

Pure function, dependency-injected, auditable by construction, with explicit gap rules ("nothing falls through")
and a documented precedence rule between per-class and per-function properties. Modules: `resolve`, `registry`,
`function-roles`, `identity-map`, `owner-lookup`, `yaml-lite`, `types`. Three CLI entrypoints.

**This is the authoriser.** It is not a rough approximation of one.

### What `autosend-bridge-telegram` actually is

Exports `proposeApproval`, `awaitApprovalDecision`, `awaitApprovalDecisionOrThrow`, a real Telegram Bot API
transport, and `createPostgresDecisionSource` with `RECORD_DECISION_SQL`. Propose an action, block for a human
decision, record the outcome to Postgres.

**This is the approval queue and the human-in-the-loop bridge**, minus the web UI.

---

## 2. Phase B and C destinations

| Destination | Filled by | Volume | Phase |
|---|---|---|---|
| `packages/ingest-connectors` | 9 connectors under `packages/mcp-connectors/` | **14,653 lines** | B |
| `vertical-pack/recruitment` | `docs/verticals/recruitment/vertical-schema.yaml` + v0.2/v0.3/v0.4 supplements | **2,794** | C |
| `packages/config-centre` | `scripts/provision-tenant.sh`, `docs/runbooks/tenant-lifecycle.md`, `day-4-provisioning.md` | ~400 + runbooks | C |
| `packages/identity` | `approval-routing/src/identity-map.ts` (person-ref mapping only — entity resolution is new) | partial | B |
| `packages/gauntlet`, `packages/trust` | — | — | **New** |
| `packages/learning` | — | — | Deferred |
| `apps/console`, `apps/queue`, `apps/operator` | — | — | **New** (Telegram bridge is the current UI) |
| `attribution/` | — | — | **New** |

---

## 3. Testing and evaluation assets

Substantial and previously uncounted.

| Destination | Filled by | Volume |
|---|---|---|
| `tests/` (cross-package) | 18 shell test harnesses in `scripts/run-*-test.sh` | **3,045 lines** |
| `evals/` | 18 bundle fixture files + the `tenant_eval_sets` table (in baseline) | **2,419 lines** |
| per-package tests | 162 vitest files | **2,076 test cases** |
| approval-routing config fixtures | `_shared/tests/fixtures/approval-routing/` — `function-roles.example.yaml`, `identity-map.example.yaml`, `standing-approvals.example.yaml` | 3 files |

**2,076 passing test cases** is the transfer's safety net: a connector or utility that lands in the new repo and
still passes its own suite has moved correctly, with no judgement required.

The three approval-routing example fixtures matter more than their size — they define the *runtime config shapes*
the authoriser expects per tenant, which is exactly what has to be documented before anyone provisions a firm.

---

## 4. Operational and governance assets

| Destination | Filled by | Notes |
|---|---|---|
| `docs/registers/escalation-codes.md` | `_shared/escalation-codes.md` + harvest appendix | 82 codes, reconciled |
| `docs/canonical/` | `docs/specs/approval-routing-architecture.md` | **The source of truth for the policy layer.** Must travel with `actions/` |
| `docs/canonical/` | `docs/specs/PRODUCT-SPEC.md`, `ULTRAPLAN.md` | Reference; superseded by the estate specs on architecture |
| `docs/adr/` | `docs/decisions/` — 26 files | **Renumber or namespace.** ADR-004/006 collide with the IFOS series |
| `docs/` | `docs/architecture/` — 7 design docs incl. `tenancy-invariants.md`, `vault-concurrency.md` | Tenancy invariants are load-bearing |
| `docs/` | `docs/runbooks/` — 4 files | `tenant-lifecycle`, `pii-purge`, `day-4-provisioning`, `operational-hygiene` |
| `docs/` | `docs/features/approval-routing/PLAN.md` + `STATUS.md` | Build history for the authoriser — read before extending it |
| `scripts/` | `build-gate.sh`, `setup-local-dev-db.sh`, `run-tenancy-audit.sh`, `ifos-pii-purge.sh`, `oauth-preflight.sh`, `run-oauth-dances.sh` | |
| root | `.agents/learnings/` — 4 files incl. `00-cortextos-quirks.md` | Hard-won integration quirks |

---

## 5. Rebuilt, not moved

| Asset | Volume | Note |
|---|---|---|
| 6 bundle shell scripts (`cycle`/`validate`/`context`/`cleanup` + `bin/`) | 10,131 raw · **5,699 non-boilerplate** | Rebuilt as harness clients. Decomposes — see `MIGRATION-PLAN.md` §4f |
| 6 × `agent.md` + 6 × `tools.yaml` | 3,978 | Become action definitions and agent prompts, not code |

---

## 6. Discarded

| Asset | Volume | Why |
|---|---|---|
| `packages/agent-renderer` | 756 | Bundle→runtime render model replaced by the three-tool seam. Never ran — all six bundles fail preflight on a missing `config.schema.json` |
| `packages/diagnostic-generator` | 1,009 | Same seam change |
| `knowledge-base/` (top level) | 884 files | A Python virtualenv. Build artefact, not source |
| `legacy/v1/` | 922 files | v1 codebase, separately preserved at `~/code/intel-force-os` |
| `logs/` | 530 files | Session and ratification logs |
| `docs/_archive-build-pack/`, `_supplementary/` | ~15 | Explicitly historical |

---

## 7. Corrected totals

| Category | Lines |
|---|---|
| Moves as working, tested code | **~22,400** (connectors 14,653 · utilities 5,676 · schemas 487 · SQL 400 · migrations 1,180) |
| Moves as data or policy, zero edits | **~6,300** (policy 1,062 · vertical schema 2,794 · fixtures 2,419) |
| Moves as specification | **~4,000** (agent.md + tools.yaml) |
| Rebuilt | **~5,700** |
| Discarded | **~1,765** of source |

Plus **2,076 test cases** and 3,045 lines of shell test harness that transfer with the code they exercise.

**The rebuild column is roughly a fifth of what moves intact.**

---

## 8. What "seamless" requires

Six conditions. Each is checkable, and none is a matter of opinion.

1. **Package scope decided once, before anything moves.** Every one of these packages declares `@ifos/*` today.
   Decide the new scope (recommended `@core/*`, see `ESTATE-DECISIONS` D2), then move — renaming after the fact
   means re-running every import rewrite.
2. **Test count is the acceptance gate.** A package has moved correctly when its own suite passes at the same
   count. 2,076 cases; no package lands without its number.
3. **Policy travels with its specification.** `actions/*.yaml` is meaningless without
   `docs/specs/approval-routing-architecture.md`. Move them in the same commit.
4. **Dependency rules go in before the code, not after.** The new repo's boundary rules must pass at the first
   commit. Landing `approval-routing` before the rule that says only `authoriser` may read the registry means the
   rule is written to fit the code rather than the other way round.
5. **The ADR series must not merge.** `docs/decisions/ADR-004` and `ADR-006` here mean different things from the
   IFOS documents' ADR-004 and ADR-006. Namespace on arrival (`ADR-CX-004`) or renumber deliberately.
6. **Nothing is deleted from CortexOS.** Every move is a copy. CortexOS keeps running as the reference and the
   Phase B source until every row above is resolved.

---

## 9. What this means for building the harness

Opening the new repo to start Phase A, the following are **already populated**: the authoriser, the approval
queue, the shared contract schemas, the action ontology with its risk tiers and autonomy ladder, the database
baseline, and 2,076 passing tests.

**Genuinely new work in Phase A:** `packages/mcp-seam` (the three-tool interface agents see), the outcome and
holdout halves of `packages/spine`, and the queue web app — the current queue is Telegram-only.

That is a materially smaller Phase A than the plan assumes, and the difference is not optimism: it is three
packages and eight schema files that a systematic sweep found and an assumption had missed.
