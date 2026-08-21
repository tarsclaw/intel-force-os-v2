# Conformance audit — transferable assets vs the new repo's dependency rules

**Run:** 2026-08-21 against `1c62f29`. **Scope:** every asset in `TRANSFER-MAP.md` §1–3.
**Method:** read-only greps over source on disk. Every verdict cites `file:line`. No verdict inherited from a
document, including the four suspicions this audit was asked to confirm or refute — one of which is **refuted**.
**Nothing was modified.** No repo created, no harness code written.

---

## P1 — The rule set

Extracted verbatim from `IFOS-MONOREPO-MASTER-BUILD-PLAN.md` §3 (eight dependency rules), §2 `[LOCK-MR-2]`,
§4 `[LOCK-MR-4]`, §5 `[LOCK-MR-5]`, and §8 (five CI guards).

| # | Rule | Source |
|---|---|---|
| R1 | `gauntlet`, `identity`, `trust`, `ingest-connectors` may never import `harness`, `spine`, `queue`, `authoriser` | §3 |
| R2 | Only `trust` may expose a read API; no other package may query Postgres/pgvector for brain content directly | §3 |
| R3 | Only `spine` writes `decision`, `outcome_event`, `holdout_assignment`; only `harness` executes | §3 |
| R4 | `learning` imports only `contracts` + reads Value Spine via a declared interface; nothing imports `learning` | §3 |
| R5 | Nothing imports `vendor/cortextos` except `harness/runtime-adapter` | §3 |
| R6 | `config-centre` composes data; no agent or pillar package imports sector strings | §3 |
| R7 | `shared/wilson` is the only Wilson implementation | §3 |
| R8 | No package imports `actions/` or `attribution/` YAML at build time; loaded and validated at runtime | §3 |
| R9 | `packages/contracts` contains **no runtime logic** — schemas, types, JSON Schema only. A function there is a review rejection | §2 `[LOCK-MR-2]` |
| R10 | A pillar is replaced behind its seam or not at all | §4 `[LOCK-MR-4]` |
| R11 | No implemented function in a stub-phase package before its phase opens | §5 `[LOCK-MR-5]` |
| R12 | Vendor guard: any diff under `vendor/` outside a pinned-SHA bump PR fails | §8.2 |
| R13 | Discipline greps: swallowed errors (`catch {}`, `\|\| true`, `2>/dev/null` on read/verify paths), second Wilson, `staging_*` schema, `Math.random` in holdout assignment | §8.3 |
| R14 | Contract suite: seam tests run against stub AND real implementations | §8.4 |
| R15 | Tenancy guard: every new table's migration enables RLS **or names a ratified exemption**; F14 permission fuzz at 100% | §8.5 |

---

## P2/P3 — Verdicts

### GREEN — lands as-is (7)

| Asset | Destination | Evidence |
|---|---|---|
| `agents-runtime/_shared/*.json` (8 files, 487 lines) | `packages/contracts` | All parse as valid JSON Schema draft 2020-12; zero executable content. **R9 clean** |
| 9 connectors (14,653 lines) | `packages/ingest-connectors` | **R1 clean** — no connector imports `approval-routing` or `autosend-bridge`. **R5 clean** — no `vendor/cortextos` import anywhere. **R6 clean** — no sector strings. No cross-package `@ifos/*` dependency declared |
| `autosend-policy.yaml` + `action-class-registry.yaml` (1,062) | `actions/` | **R8 clean** — no build-time import found; loaded at runtime by `hook-helpers.sh`. Join verified set-equal at 53 keys |
| 5 SQL artefacts (400) | called by rebuilt agents | Standalone, parameterised, RLS-scoped by design |
| `0000_baseline.sql` + `0001` (1,680) | `migrations/` | **R15 conditionally clean** — see the conditional below |
| `vertical-schema.yaml` + 3 supplements (2,794) | `vertical-pack/recruitment` | Data only, zero code |
| 18 bundle fixtures (2,419) | `evals/` | Test data |

**Two notes on GREEN rows.**

*Connectors and R13.* `bullhorn/src/client.ts:39`, `reed/src/client.ts:43`, `xero/src/client.ts:37`,
`cv-library/src/client.ts:37` all call `Math.floor(Math.random() * base)`. The CI discipline grep targets
`Math.random`. **These are retry backoff jitter, not holdout assignment** — legitimate under R13 as written, but
they *will* trip a naive grep. The new repo's guard needs a scoped pattern or a named allowlist, or four connectors
fail CI on arrival for no reason.

*The migration's R15 conditional.* `0000_baseline.sql` defines 12 tables; 11 enable RLS. The exception is
`tenants`. This is **not** a violation — it is documented as an explicit design exemption at
`docs/architecture/tenancy-invariants.md:25` and `:215`: *"the tenant registry itself. NO RLS by design (the
registry needs to be visible to admin operations). All writes admin-only."*

> **Therefore: `migrations/` cannot travel without `docs/architecture/tenancy-invariants.md`.** Move them in the
> same commit. Separated, the new repo's tenancy guard flags `tenants` with no ratified exemption on record, and
> someone either adds RLS that breaks admin operations or waves the guard through.

### AMBER — lands after a named refactor (5)

| # | Asset | Rule | Evidence | Refactor | Est. |
|---|---|---|---|---|---|
| A1 | `approval-routing` → `packages/authoriser` | R2 | `src/owner-lookup.ts:45` `execFile("psql", ...)` reads entity owner data | Replace the **default** reader with a `trust`-provided one | **~30 lines** |
| A2 | `autosend-bridge-telegram` → `packages/queue` | R2, R3 | `src/decisions-postgres.ts:46` `execFile("psql")` reads; `:132` `INSERT INTO decision_log` writes | Route reads and writes through `spine` | **~60 lines** |
| A3 | `approval-routing/src/types.ts` → `packages/contracts` | R9 | `:228` `export class RoutingConfigError extends Error` — runtime logic in a contracts-mapped file | Move the error class to `authoriser` or `shared`; keep `types.ts` pure | **~15 lines** |
| A4 | `_shared/hook-helpers.sh` → `packages/shared` | R3 | `:148` `INSERT INTO decision_log` directly | Does not travel as-is; the rebuilt agents call `spine`. Port the non-DB helpers only | folded into rebuild |
| A5 | 18 shell test harnesses → `tests/` | R3, R13 | `run-janitor-report-test.sh:66,121,193` and `run-scribe-gate-a-test.sh:134` INSERT `decision_log` for fixture setup; `run-janitor-gate-a-test.sh:44`, `run-scout-gate-a-test.sh:42`, `run-janitor-report-test.sh:43,46` use `>/dev/null 2>&1 \|\| true` on verify paths | Seed via `spine`; audit each `\|\| true` — some are legitimate cleanup (`run-v0.3-migration.sh:94-97` killing a tunnel), some are swallowed verification | moderate |

**A1 and A2 are much cheaper than they look, and this is the audit's most useful finding.**

Both packages already inject their database access. `approval-routing/src/owner-lookup.ts:84-85` declares
`runPsql?: RunPsql` — *"Injectable psql runner (tests). Defaults to `execFile("psql", ...)"* — and `:95` resolves
`config.runPsql ?? defaultRunPsql`. `autosend-bridge-telegram/src/decisions-postgres.ts:37-38` and `:79` are the
identical pattern.

**The seam the new architecture requires already exists.** Conformance is not a rewrite; it is changing what the
default resolves to. The logic, the tests and the public API are untouched. `resolve.ts` is already
*"a PURE function over injected dependencies"* — it was built for this.

### RED — needs a founder ruling (3)

| # | Question | Why it cannot be decided here |
|---|---|---|
| **RED-1** | **Does `packages/utilities/web-scraper` (412 src + 163 test) travel, or die with the diagnostic generator?** Its only consumer is `packages/diagnostic-generator` (`package.json:20` declares `"@ifos/web-scraper": "workspace:*"`), which `TRANSFER-MAP` §6 discards. Note `companies-house/src/cache.ts:2` copied its cache pattern deliberately rather than depending on it | Whether the Diagnostic capability survives into the new estate is a product decision, not an architectural one |
| ~~**RED-2**~~ | **RESOLVED 2026-08-21 — not a ruling.** See §RED-2 resolution below | — |
| **RED-3** | **Does the new estate ratify the `tenants` RLS exemption, and in which register?** Documented at `tenancy-invariants.md:215` as a CortexOS decision. R15 requires a *ratified* exemption | The new repo's ruling register is the authority; a CortexOS doc cannot ratify into it |

---

## P4 — Summary

| Verdict | Count | Volume |
|---|---|---|
| GREEN — lands as-is | **7** | ~21,500 lines |
| AMBER — named refactor first | **5** | ~105 lines of TS refactor + test-harness work |
| RED — founder ruling | **3** | — |

**Total refactor estimate: ~105 lines of TypeScript** (A1 30 + A2 60 + A3 15), plus a pass over the 18 shell test
harnesses. Against ~22,400 lines transferring as working code.

### Rules with zero violations

R1, R4, R5, R6, R7, R8, R10, R11, R12, R14 — clean across every audited asset.

**Precision correction (2026-08-21).** This section originally read "no package declares a dependency on any other
package in this repo". A full edge scan finds **exactly one**: `diagnostic-generator -> [web-scraper,
companies-house]`. It originates from a **discarded** package, so the operative claim holds — *no transferable
package depends on another, and there is no internal coupling to unwind* — but the original wording was too broad.
The edge independently confirms the RED-1 analysis: `web-scraper` has one consumer and it is on the discard list.

### One suspicion refuted

`granola/src/transport-http.ts:73` `new Client(CLIENT_INFO)` is the **MCP SDK client**
(`@modelcontextprotocol/sdk`, per the file header at `:3`), not a Postgres client. Not an R2 violation.

### Founder rulings required, most blocking first

1. **RED-2** — telegram-surface. Blocks scoping `packages/queue`; everything else is unaffected.
2. **RED-3** — the `tenants` RLS exemption. Blocks the migrations landing cleanly under the tenancy guard.
3. **RED-1** — web-scraper. Blocks nothing; decide before the Phase B connector move.

### Go / no-go

**GO, with conditions.** The transfer is safe to start. No asset is architecturally incompatible; the two apparent
blockers dissolve into ~90 lines because both packages were built with injected database access. Conditions:

1. Do A1–A3 **before** those packages land, not after. Landing first and refactoring later means the boundary rule
   is written to fit the code.
2. `migrations/` and `docs/architecture/tenancy-invariants.md` move in the same commit.
3. Scope the `Math.random` CI grep before the connectors arrive, or four of them fail on landing.
4. RED-2 answered before `packages/queue` is scoped.


---

## RED-2 — resolved by investigation, not by ruling

**Question was:** does `@ifos/telegram-surface` exist, or was the `/approve` `/reject` handler never built?

**Answer: it was never built, anywhere, and the omission was deliberate and documented.** Searched `~/code`,
`~/Desktop`, `~/Downloads`, `~/Documents`; no package by that name, no `package.json` declaring it, and
`git log --all --diff-filter=A` shows it was never committed to this repo.

`bin/record-decision.ts:1-10` states the scope decision in its own header:

> *This is the SINGLE WRITER of approval-decision rows. Callers: the **future** `@ifos/telegram-surface`
> `/approve`//`reject` command handler (its reconciliation point — it shells this CLI per reply), and
> operators/tests doing manual decision recording **while the Telegram command handler is not yet built**
> (honest-scope: getUpdates-driven command handling is telegram-surface scope, NOT this package's).*

### What this means for `packages/queue`

The approval loop is complete except for one inbound leg:

| Leg | Status |
|---|---|
| Propose an approval to a human | **Built** — `proposeApproval`, `createTelegramTransport` (`transport-telegram.ts:44`) |
| Format the message so a reply can be matched | **Built** — `message-format.ts` |
| Record an approve/reject decision | **Built** — `bin/record-decision.ts`, `RECORD_DECISION_SQL`, first-reply-wins, RLS-scoped |
| Read pending/decided state | **Built** — `createPostgresDecisionSource` |
| **Turn a human's Telegram tap into a `record-decision` call** | **MISSING** — no `getUpdates`, webhook, or poller anywhere in `src/` |

So `packages/queue` arrives able to ask and able to record, but **not able to hear.** Today a human decision is
recorded by an operator invoking the CLI by hand.

**Disposition: a scoped Phase A work item, not a founder ruling.** The gap is a `getUpdates`-driven command
handler that parses `/approve <id>` using the existing `message-format` contract and shells the existing
`record-decision` CLI. Both ends already exist and the wire format is already specified — this is the smallest
piece of net-new work identified anywhere in the transfer.

Note also that cortextOS's own Telegram module (`~/code/cortex-os-ifos/src/telegram/` — `api`, `poller`,
`media`, `transcribe`) is transport and polling only; it has no slash-command routing, so it does not fill this
gap for free.

**Revised ruling count: 2 RED, not 3.** Remaining: RED-3 (where the `tenants` RLS exemption is ratified) and
RED-1 (whether `web-scraper` travels).

---

## Test baseline — the acceptance gate, made executable

`TRANSFER-MAP.md` §8 condition 2 makes test count the acceptance criterion. That criterion was previously an
uncounted assertion. It is now measured and checkable.

All 12 transferable packages were run on 2026-08-21 at `90df272`. **380 passed, 9 skipped, zero failures.**

| Package | Passing | Skipped |
|---|---|---|
| approval-routing | 86 | — |
| bullhorn | 52 | — |
| autosend-bridge-telegram | 34 | — |
| granola | 33 | — |
| open-banking | 32 | 3 |
| xero | 29 | 3 |
| quickbooks | 27 | 3 |
| workos | 24 | — |
| cv-library | 20 | — |
| reed | 18 | — |
| companies-house | 13 | — |
| web-scraper | 12 | — |

The 9 skips are live-API tests gated behind `MCP_LIVE_TESTS` — expected, not a gap.

`harvest/scripts/verify-test-baseline.sh` bakes these numbers in and re-runs them. It takes a scope prefix, so it
works unchanged in the new repo (`bash verify-test-baseline.sh @core`). It exits non-zero on any package landing
below its baseline. **Silently skipped tests are the failure mode it exists to catch** — a green suite that
quietly runs 40 of 52 tests looks identical to a healthy one on the console.

Self-verified against CortexOS on the day of capture: **BASELINE HELD**.


---

## Rulings — all three REDs closed, 2026-08-21

| Was | Now |
|---|---|
| RED-1 web-scraper | **R-CX-5** — deferred, not deleted. Diagnostic deprioritised; the code stays green in CortexOS |
| RED-2 telegram-surface | **Resolved by investigation** — never built; scoped as a Phase A item (see above) |
| RED-3 `tenants` RLS exemption | **R-CX-2** — ratified as a permanent single-table exemption |

Two further items raised by the patches are also ruled: **R-CX-3** (`FUNCTION_NAMES` ships with contracts) and
**R-CX-4** (`spine` owns `decision_log` reads as well as writes, closing the rule gap flagged in patch A2).

Full reasoning and reversal costs: `harvest/RULINGS.md`. **Zero open rulings remain.**
