# Migration plan — how CortexOS work physically becomes the new repo

**Written:** 2026-08-21. **Answers:** "will we have to rewrite the code, and how does this actually work?"
Companion to `HARVEST-MANIFEST.md` (what moves) and `ESTATE-DECISIONS-repo-freeze-vps.md` (D1–D4).

---

## 1. The short answer

**Most of it is not rewritten. It is re-homed.** Three different mechanics apply, and confusing them is what makes
this feel like a rewrite:

| Mechanic | What physically happens | Volume |
|---|---|---|
| **Verbatim move** | `cp` the directory, change one line in `package.json`, run `sed` on the import scope, run the tests | **~16,000 lines** |
| **Re-home** | The file's *content* is correct; a different piece of code loads it. Zero edits to the file itself | **~1,500 lines** |
| **Rebuild** | Rewritten in TypeScript inside the harness. The old file is the specification | **~5,700 lines** |

The rebuild column is **less than half** what the raw bundle line-count suggested, for two reasons measured below:
about 44% of the bundle shell is comments, blank lines and logging, and the most architecturally valuable part of
the bundles is not shell at all — it is declarative YAML, which does not get rewritten.

---

## 2. What was found on inspection — the policy layer is already built

This is the headline correction to the earlier estimate.

`agents/_shared/` contains two files the earlier accounting treated as bundle plumbing:

**`autosend-policy.yaml` (416 lines)** — 53 action types classified into four risk tiers (25 green / 10 yellow /
10 orange / 8 red). Each row carries tier, owning agent, rationale, spot-check sample rate, block reason,
orange-path timeout, and an irreversibility flag.

**`action-class-registry.yaml` (646 lines)** — the same 53 keys, each carrying five approval-routing properties:
`routing_rule` (record owner, or a named function role), `trust_bucket`, `escalation_after_minutes`, `ttl_minutes`,
`on_expiry` (hold / auto_execute / safe_default), `breaks_quiet_hours`, and `digest_eligible`.

**Why this matters more than any other row in the harvest.** The new estate's harness is specified as: an action
ontology, an authoriser that decides allowed / needs-approval / refused, an approval queue with escalation, and an
autonomy ladder that promotes an action from always-ask to auto once it has a track record.

Every one of those four already exists here as data:

| New harness concept | Already exists as |
|---|---|
| Action ontology | 53 keys in `autosend-policy.yaml` |
| Authoriser risk tiers | `tier: green\|yellow\|orange\|red` |
| Approval queue + escalation chain | `routing_rule`, `escalation_after_minutes`, `ttl_minutes`, `on_expiry` |
| **Autonomy ladder** | **`trust_bucket: 1 never-asks \| 2 asks-once-then-graduates \| 3 always-asks`**, with graduation gated on <2% override across 30 days |
| Morning brief batching | `digest_eligible`, `breaks_quiet_hours` |

The estate documents treat authoring the action definitions as a founder task from a blank page. It is not a blank
page: it is 1,062 lines of policy that has already been through a Codex ratification round and has survived contact
with Xero, Bullhorn and a live bank feed. **These two files move verbatim.** The new authoriser is code that reads
them; the policy itself is not rewritten.

---

## 3. Measured composition of the bundle shell

`find agents/recruitment -name '*.sh'`, classifying comments, blank lines and logging calls as boilerplate:

| Bundle | Total | Boilerplate | Logic |
|---|---|---|---|
| Scribe | 2,185 | 930 | 1,255 |
| Concierge | 2,033 | 848 | 1,185 |
| Janitor | 1,863 | 779 | 1,084 |
| Sourcing Scout | 1,848 | 775 | 1,073 |
| Cash Conductor | 1,413 | 661 | 752 |
| Diagnostic | 789 | 439 | 350 |
| **Total** | **10,131** | **4,432 (44%)** | **5,699** |

And of the 5,699 logic lines, a further slice is orchestration the new harness provides centrally — step
sequencing, audit-row emission, escalation dispatch, retry. **The genuine rewrite kernel is smaller than 5,699.**
That figure is a mechanical classification, not a hand audit; treat it as an upper bound with a wide error bar.

---

## 4. The mechanics, per asset class

### 4a. Connectors — verbatim move (~14,450 lines, Phase B)

Per connector, roughly an hour:

```
cp -r packages/mcp-connectors/bullhorn  <new>/packages/ingest-connectors/bullhorn
# package.json:  "@ifos/bullhorn"  ->  "@core/bullhorn"
# sed the import scope across src/ and tests/
pnpm --filter @core/bullhorn test        # must match the CortexOS count exactly
```

The pass criterion is the pre-existing test count, unchanged. Bullhorn is 1,125 lines of tests; if 1,125 lines of
assertions still pass, the connector moved correctly. **No judgement required — it is mechanically verifiable.**

Git history: use `git subtree split` per connector if provenance matters, otherwise copy and record the source SHA
in the new package README. Recommend the latter — nine subtree splits is a day of work for history nobody reads.

### 4b. Policy layer — re-home, zero edits (~1,062 lines, Phase A)

`autosend-policy.yaml` and `action-class-registry.yaml` are copied unchanged into the new repo. What changes is the
*reader*: today `hook-helpers.sh::autosend_policy_lookup()` reads them from shell; in the new repo
`packages/authoriser` reads them from TypeScript. The files themselves are untouched. Their 53-key join invariant
(already grep-verified, already Codex-reviewed) becomes a contract test in the new repo.

### 4c. SQL — verbatim move (~400 lines, Phase A)

`sql/reconciliation-match.sql` (159 lines, the five-stage matcher), `sql/chase-scan.sql` (65),
`sql/weekly-report-metrics.sql` (38), plus Janitor's 138. These are already written as standalone, RLS-scoped,
parameterised files precisely so the shell and the fixture tests could share them. That design decision now pays
off: they move as-is and the new code calls them the same way.

### 4d. Schema — squash and verify (~1,848 lines, Phase A)

Concatenate `v0.1→v0.4` into `migrations/0000_baseline.sql`. Verify by applying it to an empty local database and
diffing the resulting schema against a dump of the live VPS; they must be identical. `v0.4-to-v0.5.sql` becomes the
first forward migration in the new lineage (per D4 as amended). **The live database does not move at all.**

### 4e. Agent specs — become inputs, not code (~2,822 lines, Phase A/C)

The six `agent.md` files are behavioural specifications: what the agent is for, what it may touch, its gates, its
§10 status. In the new architecture an agent is a thin client of the three-tool seam, so these stop being bundle
manifests and become the source material for the action definitions and the agent prompts. Copy verbatim into the
new repo as reference; edit down rather than author cold.

### 4f. Bundle shell — the actual rebuild (~5,699 lines, deferred)

This is the only genuine rewrite, and **none of it is needed for Phase A.** Phase A builds the harness against a
fixture brain; the bundles are rebuilt as harness clients later. When that happens the shell does not translate
line-for-line — it **decomposes**, and most of its parts have already been extracted above:

| What a bundle's `cycle.sh` does today | Where it goes |
|---|---|
| Auth refresh, API calls | Already in the connectors (4a) |
| SQL queries | Already extracted (4c) |
| Tier/approval decisions | Already declarative policy (4b) |
| Escalation emission | Provided centrally by the harness |
| Audit rows | Provided centrally by the decision log |
| Step sequencing, logging, retry | Provided centrally by the harness |
| **The business rules between the steps** | **The genuine rewrite** |

---

## 5. Order of operations

Stages 1 and 2 do not depend on Stage 3, so extraction and ratification run in parallel.

| Stage | Work | Gate | Effort |
|---|---|---|---|
| **1. Extract** | Consolidate the 82 escalation codes into the register format · generate and verify `0000_baseline.sql` · lift the dev-DB harness · stage the policy YAML, SQL and `agent.md` files for copy | none — nothing touches the new repo | 1–2 sessions |
| **2. Freeze** | Tag CortexOS · write the freeze notice into `CLAUDE.md` so no session resumes W3–W8 · final commit | none | ~30 min |
| **3. Ratify** | Regenerate the STEP 0 slate; founder signs or amends | **founder — this is the only gate on harness code** | 15–45 min |
| **4. Scaffold** | Seed from `~/Desktop/Hand-Off/claude-global-setup/repo-scaffold/` (12 files pre-built) · add the 3 missing `gate.yaml` deny entries · submodule at `c21fbfe` · dependency-cruiser · CI · empty package tree | Stage 3 | half a day |
| **5. Land Phase A inputs** | Copy in the policy YAML, SQL, baseline, escalation register, agent specs. Write the 53-key join contract test | Stage 4 | half a day |
| **6. Build the harness** | Phase A proper: contracts, spine, authoriser, queue, mcp-seam | Stage 5 | weeks 1–8 |
| **7. Phase B** | The nine connectors move (4a). Pulled by revenue signal, not calendar | Phase A exit gate | ~2 days of moving |
| **8. Retire CortexOS** | Only after thickening pass 2 (WP-12) and every manifest row resolved | — | — |

---

## 6. Verification at each step — nothing moves on trust

- **Connectors:** the pre-existing test count passes unchanged. Mechanical.
- **Policy YAML:** the 53-key join between the two files holds. Already a grep-verified invariant; becomes a test.
- **Schema baseline:** applying it to an empty DB produces a schema byte-identical to a live VPS dump.
- **SQL:** the existing fixture tests that already share these files still pass.
- **Escalation register:** all 82 codes present, no duplicates, every code referenced by something.

---

## 7. What this means in one paragraph

Of roughly 38,000 lines, about 16,000 move by copy-and-run-the-tests, about 1,500 move without being edited at all
because they are policy data rather than code, about 1,765 are discarded, and about 5,700 are eventually rebuilt —
none of which is needed to start. The most valuable single thing in the repo turned out to be 1,062 lines of YAML
that already implements the action ontology, the risk tiers, the approval routing and the autonomy ladder the new
harness was going to have to invent. **The new repo does not start from scratch. It starts from the policy layer
you already proved.**
