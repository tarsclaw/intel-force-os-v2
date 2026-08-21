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

---

## R-CX-6 — The fifteen boundary rules are adopted as written

**Question.** MONOREPO §3 gives eight dependency rules; §2/§4/§5 add three locks; §8 adds five CI guards. Adopt,
amend, or defer?

**Decision.** **Adopt all fifteen as extracted in `CONFORMANCE-AUDIT.md` §P1**, effective at the first commit,
with two amendments already ruled and one scoping fix.

**Reasoning.** These are the only decisions whose cost rises every day they are deferred. Enforced by
dependency-cruiser in CI, a forbidden import fails the build like a failing test — that mechanism is what lets
five IP layers share one repo. Adopted late, code accretes that violates them and the choice becomes mass
refactor or permanent exception; exceptions granted on day one are never removed. **The evidence is this session's
own audit:** the three landing patches cost ~105 lines *only because* both packages happened to inject their
database access. Without that accident the same audit would have found a rewrite. That is the gap between fixing
this at commit 1 and at commit 500.

**Amendments already carried:** R-CX-3 (`FUNCTION_NAMES` ships with contracts) and R-CX-4 (`spine` owns
`decision_log` in both directions).

**Required scoping fix — R13.** The discipline grep targets `Math.random`. Four connectors use it for retry
backoff jitter (`bullhorn/src/client.ts:39`, `reed:43`, `xero:37`, `cv-library:37`). The rule's actual target is
`Math.random` in **holdout assignment**, where non-determinism would corrupt the lift measurement — see R-CX-7.
**Scope the pattern to holdout assignment, or allowlist the four, BEFORE the connectors land** or all four fail
CI on arrival for a legitimate use. Same function, opposite meaning; a naive pattern cannot tell them apart.

**Cost if reversed.** Rises continuously. Cheap at commit 1, a refactor programme by commit 500.

---

## R-CX-7 — The holdout skeleton ships before the first real action

**Question.** OL-1 says the outcome ledger "ships before the first tenant action, not after the first tenant —
the one thing in the estate where late is the same as never." Commit now, or defer with the other ledger rulings?

**Decision.** **Committed now.** No action fires for a real tenant until the holdout mechanism exists. Build the
**skeleton only** in Phase A; the six analysis rules (OL-4) are deferred to the work package that measures.

**Reasoning.** This is the single genuinely irrecoverable decision in the estate, and the claim is literal rather
than rhetorical. Act on 100% of cases for three months and there is no way to construct the control group for
those three months afterwards. The evidence of value for that period is permanently gone. Every other deferred
ruling can be made later at the cost of a migration or a refactor; this one cannot be made later at any price.

**Minimum skeleton — three pieces, small:**
1. A `holdout_assignment` table (new migration on the baseline).
2. **Deterministic** assignment — a stable hash of a stable key, never `Math.random`. This is what R-CX-6's
   scoping fix exists to protect.
3. A `holdout_arm` field recorded on every decision row (a §24 addition already drafted as amendment A3 of the
   master-spec set).

**Explicitly deferred:** attribution rules, lift calculation, the non-negative-lift bars, cost-per-rung-3
economics. None is needed until something is being measured.

**Cost if reversed.** Not reversible. That is the entire point of the ruling.

---

## R-CX-8 — Repo shape follows MONOREPO §2. No top-level `agents/` or `orgs/`

**Question.** A genuine document conflict, open since the first handoff. The integration contract §7 shows
top-level `agents/` and `orgs/`; MONOREPO §2 shows neither; master spec §51/§52 assume both.

**Decision.** **MONOREPO §2 wins. Neither directory is created.**

**Reasoning.** Three independent grounds.
1. MONOREPO is the later document.
2. `IFOS-PILLAR-2-START-HERE-MASTER-HANDOFF` §9 names MONOREPO as the **owner of repo shape**; on its own subject
   it outranks the integration contract.
3. Decisive: those directories exist to hold the **agent-bundle model**, which the three-tool `mcp-seam` replaces.
   `TRANSFER-MAP` §6 already discards the renderer that populated `orgs/` — it never successfully ran, all six
   bundles failing preflight on a missing `config.schema.json`, and `orgs/` has always held zero files. Creating
   them would build a home for the thing we have decided not to build, and an empty directory invites someone to
   fill it ([LOCK-MR-5], the spec-gravity trap).

**Consequence.** Agent behavioural specs land at `docs/reference/agents/` as reference material
(LANDING-ORDER STAGE 8), not as runnable bundles.

**Cost if reversed.** Two `mkdir`s — but reversing means re-adopting the superseded agent model, which is a far
larger decision than the directories.

---

## R-CX-9 — Harbour & Finch is built from the existing fixtures

**Question.** Phase A builds against a stub brain serving the "Harbour & Finch" synthetic tenant with real
citations. **That tenant does not exist.** A search of `~/Desktop`, `~/code` and `~/Downloads` finds the name only
in prose — no dataset anywhere.

**Decision.** **Build it from the 18 existing bundle fixtures**, extended where Slice 0 needs citations. Do not
invent an agency from scratch, and do not use real client data.

**Reasoning.** This is the most likely thing to stall Phase A, because it is assumed rather than specified. Slice
0 — the end-to-end proof — is explicitly permitted to fake the agent and the brain, but **not** the lease, the
idempotency key, the authoriser, the action definition, the three clocks, the budget decrement, the contention
constraint or the decision-log schema. No fixture means no stub brain means no Slice 0. And the execution pack is
unambiguous about the stakes: *"Slice 0 runs end to end by week two or the architecture is questioned, not the
schedule."* A missing dataset would read as an architecture failure.

Building from existing fixtures rather than from scratch: 18 files, 2,419 lines, already shaped like real
recruitment data, already exercised by six agents' test suites, plus a working `dev-sandbox` tenant. Roughly a
day's work instead of a week, and the data is realistic because it was derived from real usage.

**Cost if reversed.** Regenerate the fixture set. Contained.

---

## Prerequisite (an action, not a ruling)

**`brew install pgvector` and move local Postgres to 16.** Local is 15.17 without pgvector;
`0000_baseline.sql` requires the `vector` extension for `voice_corpus_chunks`. **The baseline will not apply
locally without it.** This is the same gap that silently broke every local dev database for months
(`VERIFICATION.md` revision note). Blocks LANDING-ORDER STAGE 3.
