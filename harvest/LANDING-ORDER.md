# Landing order — the executable checklist

**Written:** 2026-08-21 at `ac0e361`. **Purpose:** make creating the new repo mechanical rather than a series of
judgement calls. Work top to bottom. Every row has a verification command; a row is not done until its command
passes.

Sources: `TRANSFER-MAP.md` (what), `CONFORMANCE-AUDIT.md` (what must change first), `MIGRATION-PLAN.md` (how),
`ESTATE-DECISIONS-repo-freeze-vps.md` (where).

**Mechanic legend.** `COPY` — copy the directory, rewrite the scope, run its suite. `STAGED` — take it from
`harvest/`, already assembled or derived. `PATCH` — apply the named landing patch as part of the same commit.
`DERIVE` — generate in the new repo; nothing to copy.

---

## STAGE 0 — Blocking preconditions

Nothing below STAGE 0 may start until every row here is done. Each is a GO condition from `CONFORMANCE-AUDIT.md` §P4.

| ☐ | Precondition | Why it blocks | Verify |
|---|---|---|---|
| ☑ | ~~Founder ratifies the STEP 0 slate~~ — **NOT a gate. Downgraded to a briefing** | Audited 2026-08-21: of ~40 rulings, only the boundary rules, the holdout commitment and the repo shape cannot wait — all three now ruled (R-CX-6/7/8). The rest are additive migrations or commercial policy better decided against real code; R30 says so itself (*"Bars are initial; recalibrate after tenant one"*). Discipline is preserved by the ruling register, not by a pre-sign-off. **R31 cannot be ratified either way** — it cites ADR-006, which does not exist | Read once before STAGE 1. No signature |
| ☐ | **PREREQUISITE: Postgres 16 + pgvector, IN THAT ORDER** | `0000_baseline.sql:87` runs `CREATE EXTENSION vector`; `:924` declares `embedding public.vector(1536)`. Without it the migration halts. **Blocks STAGE 3.** Order matters: brew's default `postgresql` is now **@18**, so `brew install pgvector` alone builds the extension against 18 and 15.17 cannot load it. 16 also matches production (16.14) | `brew install postgresql@16` → `brew install pgvector` → `psql -tAc "select name from pg_available_extensions where name='vector'"` returns a row |
| ☑ | ~~Package scope decided~~ — **`@core/*`, R-CX-1** | Verified safe: all 12 packages are `private: true` with `workspace:*` deps, so no npm collision | RULINGS.md R-CX-1 |
| ☑ | ~~`tenants` RLS exemption~~ — **ratified, R-CX-2** | Exactly one table; any other table landing without RLS is still a violation | RULINGS.md R-CX-2 — copy into `RULING-REGISTER.md` at STAGE 1 |
| ☑ | ~~`FUNCTION_NAMES` in contracts?~~ — **yes, R-CX-3** | Avoids a hand-maintained duplicate that would drift | RULINGS.md R-CX-3 |
| ☑ | ~~`web-scraper`~~ — **deferred, not deleted, R-CX-5** | Diagnostic is not a priority; code stays green in CortexOS | RULINGS.md R-CX-5 |
| ☑ | ~~`decision_log` read ownership~~ — **spine owns both directions, R-CX-4** | Was an unquoted interpretation in patch A2; now ruled | RULINGS.md R-CX-4 |

**All decision preconditions are closed — nine rulings, R-CX-1 to R-CX-9.** One prerequisite ACTION remains (pgvector).
Copy `harvest/RULINGS.md` into the new `RULING-REGISTER.md` as the first entries after `R-0001`.

---

## STAGE 1 — Skeleton and rules, before any code

`[LOCK-MR-3]`: a lock expressible as an import rule is expressed that way *in the same PR that establishes it*.
Landing code first means the rule gets written to fit the code.

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | Repo + workspace | — | `~/code/ifos` | DERIVE | `pnpm -w install` succeeds |
| ☐ | Package tree (empty dirs) | MONOREPO §2 | repo root | DERIVE | every §2 path exists. **NO top-level `agents/` or `orgs/` — R-CX-8** |
| ☐ | Loop + governance files (12) | `~/Desktop/Hand-Off/claude-global-setup/repo-scaffold/` | repo root | COPY | files present |
| ☐ | `gate.yaml` **+ the 3 missing deny entries** | scaffold | repo root | COPY+edit | 13 deny entries incl. `packages/contracts/**`, `vertical-pack/**`, `attribution/**` |
| ☐ | **dependency-cruiser rules R1–R8** | `CONFORMANCE-AUDIT.md` §P1 | `.dependency-cruiser.js` | DERIVE | rules run and pass on an empty tree |
| ☐ | **Discipline greps — `Math.random` SCOPED (R-CX-6)** | §8.3 | CI config | DERIVE | pattern targets holdout assignment only; the 4 connectors' retry jitter must pass |
| ☐ | cortextOS submodule @ `c21fbfe` | `packages/harness/cortextos` | `vendor/cortextos` | COPY | `git submodule status` shows `c21fbfe` |

---

## STAGE 2 — Contracts first (everything depends on it)

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | 8 JSON Schemas (487 lines) — orig. `packages/agents-runtime/_shared/*.json` | `harvest/contracts/` | `packages/contracts/` | STAGED | all 8 parse as draft 2020-12 |
| ☐ | Routing type declarations | `approval-routing/src/types.ts` :1–226 | `packages/contracts/routing/` | **PATCH A3** | `grep -cE '^export (function\|class)' → 0` |

---

## STAGE 3 — Database (two files, ONE commit)

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | `0000_baseline.sql` (1,570) | `harvest/migrations/` | `migrations/` | STAGED | applies to an empty DB; 12 tables |
| ☐ | `0001_reconciliation_writeback.sql` + rollback | `harvest/migrations/` | `migrations/` | STAGED | applies forward on the baseline |
| ☐ | **`tenancy-invariants.md`** | `harvest/docs/architecture/` | `docs/` | STAGED | **SAME COMMIT as the baseline** |

> **Blocking condition.** The baseline defines 12 tables and 11 RLS policies. `tenants` is exempt *by design*,
> documented at `tenancy-invariants.md:25,215`. Land them separately and the tenancy guard flags `tenants` with no
> ratified exemption on record. **One commit, both files.**
>
> Local prerequisite: `brew install pgvector` and Postgres **16** — the baseline needs the `vector` extension, and
> local is currently 15.17 without it (`VERIFICATION.md` revision note).

---

## STAGE 4 — Policy (two files, ONE commit)

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | `autosend-policy.yaml` (416) | `harvest/actions/` | `actions/` | STAGED | 53 keys |
| ☐ | `action-class-registry.yaml` (646) | `harvest/actions/` | `actions/` | STAGED | 53 keys, set-equal to the above |
| ☐ | **`approval-routing-architecture.md`** | `harvest/docs/specs/` | `docs/canonical/` | STAGED | **SAME COMMIT** — `TRANSFER-MAP` §8.3 |
| ☐ | Join contract test | `harvest/actions/JOIN-CONTRACT.md` | `tests/` | DERIVE | all 6 assertions pass, incl. **zero seeded `auto_execute`** |
| ☐ | Fix the stale header comment | `autosend-policy.yaml` | — | edit | says 53, not 47 |

---

## STAGE 5 — Authoriser

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | `approval-routing` (1,555 + 1,342) | `packages/utilities/approval-routing` | `packages/authoriser` | COPY | see below |
| ☐ | **A1** — relocate `owner-lookup.ts` + its test to `trust` | `harvest/patches/A1-*.patch` | — | **PATCH, same commit** | — |
| ☐ | **A3** — split `types.ts` | `harvest/patches/A3-*.patch` | — | **PATCH, same commit** | — |
| ☐ | Landing check | — | — | — | `pnpm --filter @core/authoriser test` → **77 passed** (86 baseline − 9 relocated) |
| ☐ | `owner-lookup` in its new home | via A1 | `packages/trust` (Phase A stub) | PATCH | `pnpm --filter @core/trust test` → **9 passed**; 77 + 9 = 86 |

---

## STAGE 6 — Spine and Queue

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | `decisions-postgres.ts` (152) | via A2 | `packages/spine` | **PATCH A2** | decision-source cases pass in spine |
| ☐ | `autosend-bridge-telegram` (679 + 703) | `packages/utilities/autosend-bridge-telegram` | `packages/queue` | COPY + **PATCH A2, same commit** | split counts sum to **34** |
| ☐ | Repoint the surviving type export | `src/index.ts` | — | edit | no dangling `./decisions-postgres.js` import |
| ☐ | Log the inbound gap as a Phase A item | `CONFORMANCE-AUDIT` RED-2 | backlog | — | `getUpdates` handler scoped |

---

## STAGE 7 — Shared, SQL, evals

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | `yaml-lite.ts` | `approval-routing/src/` | `packages/shared` | COPY | its cases pass |
| ☐ | 5 SQL artefacts (400) | `harvest/sql/` | `packages/*/sql/` | STAGED | parse against the baseline |
| ☐ | 18 bundle fixtures (2,419) | `agents/recruitment/*/fixtures/` | `evals/` | COPY | 18 files |
| ☐ | 18 shell test harnesses (3,045) | `scripts/run-*-test.sh` | `tests/` | COPY | **A5:** re-seed via spine; audit each `\|\| true` |
| ☐ | `setup-local-dev-db.sh` | `harvest/scripts/` | `scripts/` | STAGED | **`ON_ERROR_STOP=1`** + set-comparison guard vs the baseline |
| ☐ | `verify-test-baseline.sh` | `harvest/scripts/` | `scripts/` | STAGED | `bash verify-test-baseline.sh @core` |

---

## STAGE 8 — Documentation estate

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | Escalation register (82 codes + appendix) | `harvest/registers/` | `docs/registers/` | STAGED | 82 codes; the 6 Phase-B codes stay unregistered until STAGE 9 |
| ☐ | 26 ADRs, **namespaced `ADR-CX-*`** | `harvest/docs/adr-cortexos/` | `docs/adr/cortexos/` | STAGED | **zero collision** with the IFOS ADR series |
| ☐ | 7 architecture docs | `harvest/docs/architecture/` | `docs/` | STAGED | `tenancy-invariants.md` already landed at STAGE 3 |
| ☐ | 4 runbooks | `harvest/docs/runbooks/` | `docs/runbooks/` | STAGED | present |
| ☐ | 4 learnings | `harvest/docs/learnings/` | `docs/` | STAGED | incl. `00-cortextos-quirks.md` |
| ☐ | 6 agent specs + 6 tools.yaml (3,978) | `harvest/specs/` | `docs/reference/agents/` | STAGED | reference only — not bundles |

---

## STAGE 8b — Phase A build inputs (net-new, not transferred)

Everything above is transfer. These four are the genuinely new work Phase A needs, identified during prep so they
are not discovered mid-build.

| ☐ | Item | Why | Ruling | Verify |
|---|---|---|---|---|
| ☐ | **Harbour & Finch fixture tenant** | Phase A's stub brain serves it. **It does not exist** — the name appears only in prose. No fixture, no Slice 0 | **R-CX-9** — build from the 18 existing bundle fixtures (2,419 lines), extend for citations. ~1 day | stub brain answers `brain.query` with real citations |
| ☐ | **Holdout skeleton** | The only irrecoverable item in the estate | **R-CX-7** — `holdout_assignment` table + **deterministic** assignment + `holdout_arm` on every decision row | no real-tenant action can fire without an arm recorded |
| ☐ | **`mcp-seam`** — the three tools agents see | Nothing exists; wholly new | — | `brain.query` / `brain.assert` / `spine.propose` |
| ☐ | **Telegram inbound handler** | The queue can propose, format, record and read — but cannot HEAR | RED-2 resolved | `getUpdates` parses `/approve <id>` via the existing `message-format` contract and calls the existing `record-decision` CLI |

> **Slice 0 is the week-two proof.** It may fake the agent and the brain. It may **not** fake the lease, the
> idempotency key, the authoriser, the action definition, the three clocks, the budget decrement, the contention
> constraint or the decision-log schema. Execution pack: *"Slice 0 runs end to end by week two or the architecture
> is questioned, not the schedule."* That "must not fake" list is the real deadline for the deferred schema
> rulings (R27, R28, §24) — week two, decided against working code, not today in the abstract.

---

## STAGE 9 — Phase B, pulled by revenue signal, not calendar

Do not start until Phase A's exit gate passes.

| ☐ | Asset | Source | Destination | Verify |
|---|---|---|---|---|
| ☐ | **Scope the `Math.random` grep FIRST** | — | CI | 4 connectors use it for retry jitter (`bullhorn/src/client.ts:39`, `reed:43`, `xero:37`, `cv-library:37`). A naive grep fails all four on arrival |
| ☐ | 9 connectors (14,653) | `packages/mcp-connectors/*` | `packages/ingest-connectors/*` | `verify-test-baseline.sh @core` → **380 total** |
| ☐ | Register the 6 deferred ESC codes | `registers/` appendix A.1 | `docs/registers/` | 88 codes |
| ☐ | OAuth tooling + runbook | `harvest/scripts/`, `scripts/oauth-*.sh` | `scripts/` | present |
| ⊘ | ~~`web-scraper` (412 + 163)~~ | **DEFERRED — R-CX-5.** Does not land. Stays in CortexOS, green (12 tests), until Diagnostic is revisited. NOT deleted | — |

---

## STAGE 9b — Phase C, pulled on tenant two

`TRANSFER-MAP` §2 assigns both rows to Phase C. Neither was covered by an earlier stage — **added 2026-08-21 after
the coverage gate flagged them missing.** MONOREPO §5 is explicit that tenant one is provisioned BY HAND against
the same schemas Phase C later automates, and that the hand-run *is* the requirements capture: never build
provisioning before doing it manually once.

| ☐ | Asset | Source | Destination | Mechanic | Verify |
|---|---|---|---|---|---|
| ☐ | `vertical-schema.yaml` + v0.2/v0.3/v0.4 supplements (2,794 lines) | `harvest/vertical-pack/` | `vertical-pack/recruitment/` | STAGED | 4 files; data only, zero code (R6 — no package imports sector strings) |
| ☐ | `provision-tenant.sh` | `scripts/provision-tenant.sh` | `packages/config-centre/` | COPY | vault root + tenant dir checks pass |
| ☐ | `tenant-lifecycle.md`, `day-4-provisioning.md` | already landed STAGE 8 | `docs/runbooks/` | — | cross-reference only |

> Note: `provision-tenant.sh:62` assumes `IFOS_VAULT_ROOT` defaulting to `/vault` on a LUKS volume. That
> filesystem dependency is a config-centre design input, and it is the same `/vault` path A1's sibling
> `function-roles.ts:38` reads. Confirm the new estate keeps a vault-on-disk model before automating against it.

---

## STAGE 10 — Retire CortexOS

| ☐ | Condition |
|---|---|
| ☐ | Every row above is checked |
| ☐ | Thickening pass 2 (WP-12) has run |
| ☐ | `verify-test-baseline.sh @core` reports 380 passed / 9 skipped |
| ☐ | Nothing in the new repo still reads from `~/code/CortexOS` |

**Until then CortexOS keeps running.** Every move above is a copy. Nothing is deleted.
