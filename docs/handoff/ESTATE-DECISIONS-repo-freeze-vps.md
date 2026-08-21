# Estate decisions — repo location, CortexOS freeze, the VPS

**Written:** 2026-08-21. **Status:** assistant-decided at founder instruction ("answer the question yourself").
**Standing:** these are recommendations with reasoning, made to unblock planning. They are overridable by founder
ruling and should be entered into `RULING-REGISTER.md` when the new repo stands up. They are written down rather
than left in a transcript because the STEP 0 slate was lost exactly that way.

Companion to `SESSION-HANDOFF-cortexos-to-ifos.md` and `~/.claude/plans/lucky-prancing-cookie.md`.
These close open items O11 (repo path), O12 (CortexOS freeze) and O13 (the VPS).

---

## D1 — The new monorepo lives at `~/code/core/`, created fresh

**Decision.** A new, empty repository at `~/code/core/`. Not a rename of `~/code/CortexOS`, not a branch of it.

**Evidence.** MONOREPO build plan §2 line 29: *"Repo name: pending rebrand; use `ifos` until the name lands."*
The document names the working name and declines to name a path. `~/code/` already holds the other three
(`CortexOS`, `cortex-os-ifos`, `intel-force-os`), so it stays the single workspace root.

**Why fresh and not in-place.** MONOREPO §3 turns the pillar boundaries into dependency-cruiser rules enforced in
CI — a forbidden import fails the build like a failing test. That is the load-bearing mechanism that lets five IP
layers share one repo. Restructuring CortexOS in place means those rules fail from day one against a large body of
pre-existing code, and the first weeks go to fighting import violations instead of building. Starting fresh means
the rules pass at commit 1 and every import after that is checked. Two further benefits fall out for free:
`gate.yaml` is one denylist for the whole repo and is far easier to author against a clean tree; and the CortexOS
`docs/decisions/` ADR series never travels, which structurally prevents the ADR-004/ADR-006 collision documented
in the session handoff from corrupting Tier 1.

**Seed.** `~/Desktop/Hand-Off/claude-global-setup/repo-scaffold/` — 12 files already written (`LOOP.md`, `STATE.md`,
`gate.yaml`, `RULING-REGISTER.md`, `escalation-codes.md`, `build-decision-log.md`, `CLAUDE.md`, loop docs). Most of
STEP 3 is pre-built. Known gaps: `RULING-REGISTER.md` holds one row (`R-0001`, PENDING); `gate.yaml` has 10 deny
entries and is 3 short — `packages/contracts/**`, `vertical-pack/**`, `attribution/**`.

**Submodule.** `vendor/cortextos/` at pinned SHA `c21fbfe`, read-only forever. Confirmed Bucket 1: zero source
edits, so the submodule is a clean pin with no patches to carry.

---

## D2 — Package scope is `@core/*`, not `@ifos/*`

**Decision.** Internal pnpm workspace scope `@core/*`. CortexOS keeps `@ifos/*`; nothing is renamed there.

**Why this is decided now and not later.** The directory name is free to change — a filesystem move plus a GitHub
setting. The package scope is not: it appears in every `package.json`, every import statement, and every
dependency-cruiser rule in the repo, so renaming it later is a repo-wide sed across hundreds of files. This is the
cheapest moment the decision will ever have.

**Why not `@ifos`.** The rebrand off "Intel Force OS" is forced, not optional. Seeding a new repo with the mark
being retired guarantees that sed.

**Why not the frontrunner name.** No formal trademark search has cleared it. Betting the scope on an unconfirmed
name risks doing the rename twice.

**Why `@core`.** Brand-independent, so it survives this rebrand and the next one. A generic internal scope is
ordinary practice in monorepos and carries no cost. Does not collide with `packages/spine`, `packages/shared` or
any other §2 package name.

**Consequence.** The directory name `ifos` carries the working name and is disposable; the scope carries none and
is permanent. If the founder prefers the product name in the scope, that overrides — but it should be taken after
the trademark search, not before.

---

## D3 — CortexOS feature-freezes immediately. W3–W8 does not continue

**Decision.** Feature freeze as of now. Not an archive, not a delete. It stays running, readable and harvestable.
Retire only after thickening pass 2 (WP-12).

**Why W3–W8 stops.** Three independent reasons, each sufficient on its own:

1. **It builds what has already been superseded.** The harvest map marks the six agent bundles,
   `diagnostic-generator` and `agent-renderer` as superseded; the new agent model is the three-tool `mcp-seam`.
   More bundles is not parallel work, it is divergent work.
2. **It cannot reach live verification.** Credentials were declared unobtainable by the founder on 2026-06-11.
   Anything W3–W8 produces is fixture-proven and permanently unprovable against a live system — on an
   architecture being retired.
3. **`[LOCK-MR-5]`.** Implementing a function in a stub-phase package before its phase opens is the spec-gravity
   trap. Continuing agent work during Phase A is that trap with a different label.

**Explicitly do NOT fix the renderer.** It is tempting because it is cheap — six `config.schema.json` files, one
per bundle, and preflight passes. It is confirmed from source that this is the only blocker
(`packages/agent-renderer/src/fileMap.ts:20-22` requires the file; `preflight.ts:checkBundle` throws
`bundle-malformed`; zero of six bundles ship one; `orgs/` holds zero files). Spend it and you have rendered agents
into a runtime whose agent model is being replaced. The fix is cheap and the payoff is zero.

**What "freeze" permits.** Data-integrity and security fixes only, and only to something that will be harvested.
Everything else waits.

**What gets harvested later, and when.** CortexOS is the source for three genuinely valuable bodies of work:

| Asset | Destination | Phase |
|---|---|---|
| 9 MCP connectors (`@ifos/bullhorn`, `cv-library`, `reed`, `granola`, `xero`, `quickbooks`, `open-banking`, `companies-house`, `workos`) | `packages/ingest-connectors/` | Phase B `[PULL]` |
| Postgres migrations v0.1→v0.5 + the RLS discipline | `migrations/` (see D4) | WP-0 baseline |
| Local dev DB harness (`scripts/setup-local-dev-db.sh`) | `scripts/` | WP-0, useful immediately |

---

## D4 — The Hetzner VPS is kept and becomes the new monorepo's Postgres

**Decision.** No new database is provisioned. The existing VPS Postgres is the one Postgres the estate mandates.

**Evidence.** MONOREPO §2: *"one Postgres with RLS"*, and §3: *"one migrations lineage, one RLS discipline."*
That instance already exists, live, with RLS proven and migrations through v0.3 applied in production. Standing up
a second would violate the one-lineage lock and manufacture a reconciliation problem.

**The estate never mentions it.** A grep across the Hand-Off and Pillar trees for `hetzner|vps|178.105.87.24`
returns zero hits. No canonical document owns the deployment target. **This is a gap, not a decision** — it should
be logged as an open item in the ratification pass and given an owning document.

**Schema compatibility.** What is on the VPS is the recruitment-vertical schema. The new estate's tables —
`decision`, `outcome_event`, `holdout_assignment`, the P1 entity contract — do not exist there yet and arrive as
new migrations. Additive, not conflicting.

**Lineage — AMENDED 2026-08-21, see correction note below.** Baseline at **v0.4**, which is the actual live
production state. Squash CortexOS v0.1→v0.4 into `migrations/0000_baseline.sql`; `v0.4-to-v0.5.sql` then becomes
the **first forward migration in the new repo's lineage**, applied when the new estate actually needs the
reconciliation write-back columns. One lineage, no history rewrite, dev DB reproducible from the baseline.

> **Correction.** This section originally said: baseline at v0.5, therefore apply `v0.4-to-v0.5.sql` to production
> first, therefore a founder-only blocker on the WP-0 baseline. That was wrong — it manufactured a prerequisite
> that the design does not need. Baselining at the schema production actually has makes the baseline true by
> construction rather than true because someone remembered to run something first, and under D3's freeze Cash
> Conductor performs no live reconciliation writes, so the two columns are not needed in production yet.
> **Net effect: open item N2 is withdrawn. Nothing is required on the VPS before WP-0.**

**Divergence note.** The local dev DB is at v0.5; production is at v0.4. That divergence predates this decision and
is not worsened by it — the baseline-plus-replay reconciles the two. `v0.5-to-v0.4.sql` (rollback) exists.
No `run-v0.5-migration-as-postgres.sh` runner exists yet; the v0.4 runner is the template if one is ever needed.

**Access note.** The assistant cannot reach the VPS — `ssh maddox@178.105.87.24` returns
`Permission denied (publickey)`. Any future production migration is genuinely founder-executed, not merely
founder-authorised.

---

## Open items these decisions create

| # | Item | Blocking? |
|---|---|---|
| N1 | No canonical document owns the deployment target (the VPS). Needs an owner. | No — log in ratification |
| N2 | ~~`v0.5` must reach prod before the baseline squash~~ — **WITHDRAWN**, see D4 correction. Baseline at v0.4 instead. | No |
| N3 | `@core` scope should be revisited once the trademark search clears — override or confirm. | No |
| N4 | `gate.yaml` in the scaffold is 3 deny entries short. | Blocks STEP 3 |
