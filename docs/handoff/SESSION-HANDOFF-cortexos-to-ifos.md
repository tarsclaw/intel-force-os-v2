# SESSION HANDOFF — CortexOS → IFOS transition

**Document type:** Session handoff. Written at the end of the session that merged approval-routing Wave 1 and discovered that the CortexOS repo is superseded by the five-pillar IFOS estate. Its job is to stop the next session re-deriving what was verified here, and re-making the mistakes made here.
**Session dates:** 2026-08-07 → 2026-08-21
**Repo at write time:** `~/code/CortexOS`, `main` = `16a2019`, tree clean, build gate PASS.
**Status:** CortexOS is a **superseded authority**. Do not start new feature work here. See §5.

---

## 1. The one thing to know

The founder has a complete five-pillar architecture estate on the Desktop (`~/Desktop/Pillar 1..4`, `~/Desktop/Hand-Off`) that specifies **a new monorepo named IFOS**. This repo — `~/code/CortexOS` — is not it, and cannot be reshaped into it.

Decided by the founder this session: **new repo, called IFOS.**

The next session's job is NOT to build. It is to complete **STEP 0** of the estate's own boot sequence (`IFOS-PILLAR-2-START-HERE-MASTER-HANDOFF-v1-1.md` §5): read the authority chain in full, produce the ratification slate, get it ratified. Nothing legitimately starts before that.

---

## 2. What went RIGHT — keep doing these

1. **Verification before trust.** Every claim on the status boards was independently re-run rather than believed. This found a real defect (§3.1) that the boards asserted was fine.
2. **Cheap boundary checks first.** `git diff --name-only main...<branch> -- packages/harness/` and a Composio/AgentMail grep cost seconds and cleared two of the four boundaries before any expensive test ran.
3. **Integration-branch merge pattern.** Built `main + W1 + W2` on a scratch branch, ran the full gate on the *merged* result, then fast-forwarded. Catches interaction defects that per-branch gates miss. **Use this for every future merge.**
4. **Filesystem truth over document truth.** `orgs/` empty + 0 `crons.json` + `git log --all -- packages/brain` proved things the documents only claimed. When a doc and the filesystem disagree, the filesystem wins.
5. **Set-equality verified by script, not by reading the header.** The registry↔autosend-policy join was checked programmatically (53 = 53, zero drift both directions), which is exactly what PLAN decision 4 demanded and what the stale `47` in the header would have misled a reader into doubting.

---

## 3. What went WRONG — do not repeat

### 3.1 Structural findings (real defects in the repo, not process errors)

| Finding | Evidence | Consequence |
|---|---|---|
| **`build-gate.sh` loops a hardcoded package list** | `scripts/build-gate.sh` tier 2+3 | `approval-routing` (86 tests) was outside the gate — a regression would have shipped silently. Fixed at `0020fdc`. **Still outside:** `diagnostic-generator`, `agent-renderer`, `granola`, `workos`. The tier-4 fixture loop auto-discovers; the package loop does not. |
| **The renderer is blocked and always has been** | `packages/agent-renderer/src/fileMap.ts:21` requires `config.schema.json`; **zero of the six agent bundles ship one**; `preflight.ts:22` throws `bundle-malformed` | This is *why* no agent has ever been rendered or activated. Not a missing feature — a hard blocker nobody had traced. |
| **`packages/brain/` has never existed** | `git log --all -- packages/brain` returns nothing | ADR-002 + `second-brain-design.md` + master brief §5 specify it in full (9 wrappers, 9 lib modules, ~11–13 person-days). Zero lines written. |
| **Base schema is not in a migration** | Migrations run `v0.1→v0.5`; the v0.1 DDL for all 7 base tables lives in prose in `docs/runbooks/day-4-provisioning.md` | The database cannot be rebuilt from the migration chain. |
| **`.agents/current-priorities.md` was ~8 weeks stale** | Headers on the parallel agent build; silent on approval-routing, which was the last 5 commits | The file meant to carry state did not carry it. Real state was in `docs/features/approval-routing/STATUS.md` + git log. |
| **The "IFOS harness" is not a fork** | `~/code/cortex-os-ifos` origin = `grandamenium/cortextos`; only diff is a 2-line `package.json` rename; **uncommitted** | One `git checkout .` deletes the `cortextos-ifos` binary name that `.envrc`, every red line and every doc depends on. Isolation (separate `CTX_ROOT`, ports, instance ID) is real and correct; code divergence is zero. |

### 3.2 Process errors made by the assistant this session

1. **Reasoned ahead of the authority chain.** Produced a four-pillar sequencing recommendation, a six-item "prep the codebase" plan and a keystone-first argument — all from 4 of ~8 authority documents, and all before learning the estate specified a different repo entirely. That work was discarded. **Rule: read the chain, then reason. Not the reverse.**
2. **Asked the founder to decide things the documents had already decided.** Put up a four-option question on the cortextOS fork model when `IFOS-AGENTIC-HARNESS-PILLAR-HANDOFF.md` §2 already says *"rented plumbing at `vendor/cortextos`, pinned SHA, read-only forever."* Stop-and-ask is never a failure; asking about a settled ruling is noise.
3. **Overclaimed verification scope.** Wrote *"nothing IFOS is running. Anywhere"* having checked only the local Mac. The Hetzner VPS was never checked. **Say where you looked.**
4. **Let the session drift without re-anchoring.** Began as "verify and merge two branches", became a strategy review, then an estate audit. Each step was reasonable; the sequence was never re-scoped out loud.
5. **Sloppy attribution of evidence.** Labelled the five `ct-*` PM2 processes "your personal cortextos install" on the strength of one path (`~/.cortextos/default/scripts/ct-quant-risk-watcher.sh`). They are more likely a separate copytrading project (cf. `COPYTRADING-CORTEXTOS-BUILD-INSTRUCTIONS.md` in Downloads). Not IFOS either way — but the label outran the evidence.

---

## 4. Verified facts — do NOT re-derive these

### Repo
- `main` = `16a2019`. Tree clean. Build gate **PASS**: shellcheck 60 files · 9 packages typecheck+vitest · 18 DB-backed fixture suites.
- Approval-routing **W1 + W2 merged** (fast-forward `35d837e` → `0020fdc`, 17 commits, zero conflicts, zero file overlap between slices). Worktrees pruned; one branch (`main`).
- W1: typecheck clean, 86/86 vitest, 0 harness edits, 0 adapter-boundary violations.
- W2: 5/5 YAML parse; registry↔autosend-policy **set equality 53 = 53**; all 53 types carry all 7 required fields; 3/3 new ESC codes present.
- The `47` in `autosend-policy.yaml`'s header is **stale text**, not a join defect.
- W3–W8 never started. Critical path is W1→W3→W5→W8; only W1 exists.

### Runtime
- **Nothing IFOS runs on this Mac.** `~/.cortextos/ifos-v2/orgs/` = 0 files; 0 `crons.json`; no IFOS daemon. `state/` holds only `oauth/` and `usage/`.
- The five PM2 `ct-*` processes are not IFOS.
- **The Hetzner VPS (`178.105.87.24`) was never checked.** Open gap.
- Postgres: VPS at v0.4; local dev DB at v0.5 (`postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev`, confirmed up).

### Harness
- `~/code/cortex-os-ifos` = upstream clone at `c21fbfe`, npm-linked globally (`/opt/homebrew/lib/node_modules/cortextos-ifos` → the working tree, so edits go live after `pnpm build`). 255 commits behind upstream `main`; histories have diverged (upstream rewrote).
- The submodule `packages/harness/cortextos` pins the **same SHA `c21fbfe`** — which is what the new repo's `vendor/cortextos` needs. Carries directly.

### Missing packages (specified but never built)
`context-assembly`, `decision-log`, `vault-syncer`, `voice`, `vertical-adapters`, `onboarding-wizard`, `dashboard-ext`, `brain`.

### Agents reach Postgres directly
67 raw `psql` calls across `agents/_shared/hook-helpers.sh` (11) and the six `cycle.sh` files. Master brief §9 says `context-assembly` should be the only reader. It doesn't exist.

---

## 5. The IFOS estate — what the next session must read

**Numbering trap — read this twice.** Desktop folders and document-internal numbering disagree (`IFOS-NEW-PROJECT-KICKOFF-PROMPT.md`, "NUMBERING TRANSLATION"):

| Desktop folder | Inside the documents | Phase |
|---|---|---|
| Pillar 1 Data Layer + Pillar 2 Second Brain | **"Pillar 1"** | B `[PULL]` |
| **Pillar 3 The Agentic Harness** | **"Pillar 2"** | **A — BUILD NOW** |
| Pillar 4 Delivery Layer | "Pillar 3" | C `[PULL]` |
| (Learning) | "Pillar 4" | `[DEFER]`, gated OL-8 |

**Always cite by title, never by pillar number.**

### Read in this order
1. `~/Desktop/Hand-Off/IFOS-MONOREPO-MASTER-BUILD-PLAN.md` — repo shape, boundaries, phases ✅ *read this session*
2. `~/Desktop/Pillar 3 .../IFOS-PILLAR-2-START-HERE-MASTER-HANDOFF-v1-1.md` — the door ✅ *read*
3. `~/Desktop/Pillar 3 .../IFOS-PILLAR-2-THE-AGENTIC-HARNESS-MASTER-SPEC.md` (138KB) ❌ **UNREAD**
4. `~/Desktop/Pillar 3 .../IFOS-THE-OUTCOME-LEDGER-CANONICAL.md` ❌ **UNREAD**
5. `~/Desktop/Pillar 3 .../IFOS-cortextOS-Integration-and-Upgrade-CONTRACT.md` ❌ **UNREAD**
6. `~/Desktop/Pillar 3 .../IFOS-PILLAR-2-BUILD-EXECUTION-PACK.md` — WP-0→WP-24 ❌ **UNREAD**
7. `~/Desktop/Hand-Off/loop-engineering.md` + `dynamic-workflows.md` ✅ *available*
8. `~/Desktop/Hand-Off/IFOS-Build-Loop-Engine-CANONICAL.md` ❌ **UNREAD**

Also read: `~/Desktop/Hand-Off/IFOS-NEW-PROJECT-KICKOFF-PROMPT.md` (the paste-ready first message) and `IFOS-AGENTIC-HARNESS-PILLAR-HANDOFF.md`.

### Estate hygiene problems to fix before booting
- `ADR-004` exists in **3** places; `FIRST-CLIENT-RUNBOOK` in 2; `IFOS-Directive-Loop-CANONICAL-SPEC` in 2; `AUTHORITY-MANIFEST` in 2.
- `~/Desktop/Pillar 2 The Second Brain/ifos-second-brain-estate/` is a ~90-file dump mixing canonical with clearly-superseded material (`intelforce-os-v2-prd.md`, `intelforce-os-cortexos-build-handoff.md`).
- `[LOCK-MR-6]` requires superseded docs archived with a `SUPERSEDED` header naming their absorber. This is a WP-0 chore, not a copy-paste.
- **`IFOS-THE-AGENT-APPROACH.md` is missing** — named in MONOREPO §7 (Tier 2) and §9 but not found anywhere on disk.

---

## 6. Decisions taken, and decisions still open

**Taken by the founder:**
- New repo, named IFOS.
- (Earlier, superseded by the above) keystone-first sequencing; four pillars in focus.

**Open — the next session must NOT decide these alone:**
1. Repo path for IFOS (`~/code/core/` proposed, unconfirmed).
2. Whether CortexOS is frozen immediately, or the approval-routing sprint (W3–W8) continues in parallel.
3. Everything in STEP 0: R20–R24, R27–R32, OL-1→OL-8, `[LOCK-BX-*]`, `[LOCK-FM-*]` — all unread, therefore unratified.
4. The VPS: leave, migrate, or rebuild under the single `migrations/` lineage.

---

## 7. Harvest map — what CortexOS gives IFOS, and when

Nothing here should be **ported during Phase A.** `[LOCK-MR-5]`: *"An implemented function in a stub-phase package before its phase opens is the spec-gravity trap wearing a new coat."* `ingest-connectors` is Pillar 1 = Phase B. Index it now; port it when its phase opens.

| Asset | Target | Phase |
|---|---|---|
| cortextOS submodule **@ `c21fbfe`** | `vendor/cortextos` (same SHA) | **A, day one** |
| 9 MCP connectors — Bullhorn (29 tests, two-step OAuth + per-`corporation_id` rate limit + 401-force-refresh), Xero, QuickBooks, Open Banking (**all 3 live-verified, 9/9**), Companies House, Reed, CV-Library, Granola, WorkOS | `packages/ingest-connectors/` | **B** — Bullhorn OAuth is the named "long pole"; already solved here |
| `docs/operations/oauth-sandbox-app-setup-runbook.md` — Xero granular-scopes-only, `+` vs `%20` encoding, redirect-port mismatches, QB Development-vs-Production keys | carry the runbook itself | **B** — brutal to rediscover |
| Tenancy invariants T1–T12 + `scripts/run-tenancy-audit.sh` | CI guard 5 (F14 permission fuzz) | **A** (discipline), **B** (tables) |
| `packages/utilities/approval-routing` (86 tests: ladder, trust buckets, TTL, escalation) | design input to `packages/authoriser` + `packages/queue` | **A — reference only, not code** |
| `agents/_shared/action-class-registry.yaml` (53 rows) | evidence for choosing the **six** `actions/*.yaml` | **A — input, not import** |
| `hh_decision_trigger/output/action` + `decision_log` | `packages/spine` | **A** — concept proven, schema rebuilt |
| `scripts/build-gate.sh` | the five CI guards (MONOREPO §8) | **A** — pattern carries, implementation new (dependency-cruiser) |
| Codex ratification loop | the review protocol | **A** — proven practice |
| 6 agent bundles, `diagnostic-generator`, `agent-renderer` | superseded (new agent model = three-tool `mcp-seam`) | workflow *analysis* is B/C knowledge; code is not |

---

## 8. What the next session should do, in order

1. **Read §4 of this document.** Do not re-verify it; it was checked, not inherited.
2. **Read the four unread authority documents in full** (§5 items 3, 4, 5, 6, plus 8). Rule 1 of the standing protocol: never infer from training data what a document in the estate answers.
3. **Assemble the clean estate** — de-duplicate, apply `[LOCK-MR-6]` archive headers, flag `IFOS-THE-AGENT-APPROACH.md` as missing.
4. **Produce the STEP 0 ratification slate** in one message for founder ratification. Do not scaffold before it is ratified.
5. **Flag on day one:** the boot sequence puts *"message Steve — WP-9 gold set"* on day one, described as *"the item most likely to be deferred and most expensive to defer."* Founder action, human dependency, no code blocker.

**Do not:** create the repo, write code, port connectors, or continue W3–W8, before STEP 0 is ratified.

---

## 9. Cold-start test for this handoff

A fresh session given only this file should be able to state:
- [ ] Which repo is authoritative going forward, and which is superseded
- [ ] Why "Pillar 3" on the Desktop is "Pillar 2" in the documents
- [ ] Four verified facts it must not re-derive
- [ ] The four authority documents it has not yet read
- [ ] Why porting the MCP connectors during Phase A is a review rejection
- [ ] What STEP 0 is, and that nothing starts before it

If it cannot, fix this file before building anything.

**The sentence to carry:** *the code in this repo is inventory, not foundation; the estate on the Desktop is the constitution; and nothing starts before STEP 0 is ratified.*
