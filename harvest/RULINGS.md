# Rulings — ready to land in the new repo's RULING-REGISTER.md

Founder-authorised 2026-08-21. Each carries the question, the decision, the reasoning, and what it costs if
reversed. Copy these rows into `RULING-REGISTER.md` at STAGE 1; they are the first entries after `R-0001`.

---

## R-CX-1 — Package scope is `@core/*`

**Question.** Every package declares `@ifos/*`. The Intel Force name is being retired. What replaces it, and when?

**Decision.** `@core/*`, decided **before** any code moves.

**Reasoning.** The scope appears in every `package.json`, every import, and every dependency-cruiser rule.
Renaming before the move is one rewrite; after, it is hundreds of files. `@core` is brand-independent, so it
survives this rebrand and the next — the alternatives were `@ifos` (perpetuates the mark being retired) and the
frontrunner product name (no trademark search has cleared; risks doing the rename twice).

**Verified safe.** All 12 packages carry `private: true` and declare internal deps as `workspace:*`. Nothing is
published to npm, so `@core` — a common name that is certainly taken publicly — carries **zero collision risk**.

**Cost if reversed.** One scripted rename before STAGE 5. After STAGE 9, hundreds of files.

---

## R-CX-2 — The `tenants` table's RLS exemption is ratified

**Question.** R15 (MONOREPO §8.5) requires every table to enable row-level security **or name a ratified
exemption**. `0000_baseline.sql` defines 12 tables and 11 policies. `tenants` has none.

**Decision.** **Ratified as a permanent, intentional exemption.** `tenants` is the only table that may omit RLS.

**Reasoning.** `tenants` is the tenant registry itself — the list *of* customers. RLS scopes a row to the tenant
reading it; the registry must be visible to admin operations that span all tenants, so scoping it to itself is
incoherent. This is not an oversight: `docs/architecture/tenancy-invariants.md:25` classifies it as the estate's
single "Meta table", and `:215` records *"NO RLS by design... All `tenants` writes are admin-only; `ifos_app` has
SELECT-only on it. This is documented as an explicit exception, not a violation."*

**Scope.** Exactly one table. Any *other* table arriving without RLS is a violation, not a precedent.

**Binding condition.** `migrations/0000_baseline.sql` and `docs/architecture/tenancy-invariants.md` land in the
**same commit** (LANDING-ORDER STAGE 3). Separated, the tenancy guard flags `tenants` with no exemption on record
and someone either adds a policy that breaks admin access or disables the guard.

**Cost if reversed.** Adding RLS to `tenants` breaks admin operations across every tenant.

---

## R-CX-3 — `FUNCTION_NAMES` ships with `packages/contracts`

**Question.** R9 ([LOCK-MR-2]) says contracts holds "no runtime logic: schemas, types, JSON Schema files, nothing
else. A function appearing in `contracts/` is a review rejection." `approval-routing/src/types.ts:146` declares
`export const FUNCTION_NAMES = [...] as const`, from which `:155` derives `type FunctionName`. A const array is a
runtime value, but it is not a function.

**Decision.** **It ships with contracts.** The derived type ships with it.

**Reasoning.** R9's stated hard line is functions, and this is data — a frozen literal whose sole purpose is to
generate a type. The alternative is to leave the array behind and hand-declare `FunctionName` as a duplicate
union literal in contracts. That duplicate can drift from the array, and **drift between a declaration and its
source is precisely the failure R9 exists to prevent.** Excluding it would satisfy the letter of the rule while
defeating its purpose.

**Boundary.** This licenses `as const` literals that exist solely to derive types. It does **not** license
functions, classes, or any value with behaviour. `RoutingConfigError` still leaves contracts (patch A3).

**Cost if reversed.** ~10 lines, plus accepting a hand-maintained duplicate.

---

## R-CX-4 — `spine` owns `decision_log` reads as well as writes

**Question.** R3 says *"Only `spine` writes `decision`, `outcome_event`, `holdout_assignment`."* It says nothing
about reads, and R2's single-read-path rule is scoped to *brain content* — which `decision_log` is not. Patch A2
moves `autosend-bridge`'s reader to spine alongside its writer. Is that required, or over-reach?

**Decision.** **`spine` owns both directions.** The reader moves with the writer.

**Reasoning.** Four points, in order of weight.

1. MONOREPO §4 describes the Value Spine tables as *"P2 writes, ledger measures, P4 reads"* — access to these
   tables is characterised as flowing through spine in both directions, not just outbound.
2. If `queue` keeps the reader, **two packages know the `decision_log` schema.** When `outcome_event` and
   `holdout_assignment` arrive in Phase A they will each need readers, and the same split question recurs per
   table. One owner answers it once.
3. The Outcome Ledger measures off exactly these tables. A single owner gives the measurement queries one home.
4. Practically, the reader and writer already share a `runPsql`, an RLS wrapper and a connection config
   (`decisions-postgres.ts` :46, :55, :83). Splitting them triplicates all three.

**Considered and rejected.** Queue polls for decisions, so an extra hop adds latency. Rejected as theoretical —
it is a poll loop against a local database, and schema duplication is a concrete cost against a speculative one.

**Preserved.** First-valid-reply-wins travels intact: the `NOT EXISTS` guard at `decisions-postgres.ts:93-100`
moves inside the SQL constant, and `production-wiring.test.ts:160-163` asserts on it, so the property stays
regression-tested wherever it lands.

**Cost if reversed.** ~20 lines to move the reader back to queue.

---

## R-CX-5 — Diagnostic and `web-scraper` are DEFERRED, not discarded

**Question.** `packages/utilities/web-scraper` (412 src + 163 test) has exactly one consumer:
`diagnostic-generator`, which `TRANSFER-MAP` §6 discards. Does it travel?

**Decision.** **Neither lands nor is deleted.** Both stay in CortexOS, unlanded, until the Diagnostic capability
is revisited. Founder: *"ignore the diagnostic report for now, it's not a priority."*

**Reasoning.** "Not a priority" is not "never". Landing it now adds an unused package to a repo whose whole
premise is that nothing exists before its phase opens ([LOCK-MR-5]) — and an unused package invites someone to
build against it. Deleting it destroys 575 lines of tested code to save nothing, since CortexOS is not being
retired for months.

**Verified.** The dependency graph confirms the analysis: `diagnostic-generator -> [web-scraper,
companies-house]` is the **only** internal package edge in the repository, and it originates from a discarded
package. No transferable package depends on `web-scraper`. Dropping it strands nothing.

**Note.** `companies-house` is the other half of that edge and **does** travel — it is one of the nine connectors,
consumed independently. Do not let the Diagnostic deferral pull it out of Phase B by association.
`companies-house/src/cache.ts:2` records that it deliberately copied web-scraper's cache pattern rather than
depending on it, so it stands alone.

**Revisit trigger.** Whenever the Diagnostic capability is reconsidered. The code stays in CortexOS and remains
green (12 tests passing) until then.

**Cost if reversed.** One `cp -r` plus a scope rewrite. Roughly an hour.
