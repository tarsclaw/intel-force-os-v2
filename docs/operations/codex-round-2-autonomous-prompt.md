# Codex Round 2 — autonomous one-shot prompt

**Status:** Reference (operations artefact).
**Date:** 2026-05-22 (Day 11 PM).
**Purpose:** Single prompt the founder pastes into `codex` interactive mode that runs Round 2 ratification + manifest closure + commit + push **end-to-end without founder input**.

**Pre-flight** (founder, 2 min):

```bash
cd ~/code/CortexOS
codex --version          # must succeed; if not, see codex-ratification-guide.md §3.1
codex auth status        # must be signed in or OPENAI_API_KEY set
codex                    # enter interactive mode
```

Then paste the prompt below.

**Expected runtime:** ~6-9 hours of Codex time. Founder can walk away.

---

## The prompt (paste verbatim into `codex` interactive mode)

```
You are running Codex Round 2 ratification for the Intel Force OS (IFOS) codebase. 
Your working directory is the IFOS repo root. This is a fully autonomous run — 
the founder does NOT want to be interrupted. Make sensible defaults for 
ambiguity; surface concerns in your final report, not mid-run.

═══════════════════════════════════════════════════════════════════
BINDING SPECIFICATION
═══════════════════════════════════════════════════════════════════

The full Round-2 protocol lives at:
  docs/operations/codex-round-2-handoff.md

READ THAT DOCUMENT FIRST IN FULL. It defines:
  - The 26 artefacts in 3 tiers (§3)
  - The ratification skills to apply per artefact (§3 tables)
  - How to handle the 6 outcome classes (§6)
  - Post-run manifest closure (§7)
  - Stopping rules (§9)

This prompt provides autonomous-execution guidance on top of that protocol.

═══════════════════════════════════════════════════════════════════
EXECUTION SEQUENCE (autonomous; no founder input)
═══════════════════════════════════════════════════════════════════

STEP 1 — Load context (15 min)

Read in order:
  1. docs/operations/codex-round-2-handoff.md  (binding protocol)
  2. .codex/ratification/SKILL.md  (top-level ratification skill)
  3. .codex/ratification/review-architecture-decision.md  (with D5 softening
     in §1-Exemption; affects 4 artefacts' verdicts)
  4. .codex/ratification/review-schema-change.md
  5. .codex/ratification/review-postgres-migration.md
  6. docs/build-brief/00-MASTER-BRIEF.md §1 (five rules) + §3 (four boundaries)
     + §10 (ratification loop)

Confirm internalisation by listing the 12 tenancy invariants from 
docs/architecture/tenancy-invariants.md §2 (T1-T12) at the start of your 
run log — proves you've grounded yourself.

STEP 2 — Create run directory

mkdir -p logs/codex-ratification/round-2-autonomous/

All per-artefact output files land here. Naming convention:
  <slug>.output.md  where <slug> = filename with / and . replaced by _ and -

STEP 3 — Ratify 26 artefacts in 3 tiers (~6h)

Use the table in docs/operations/codex-round-2-handoff.md §3. For each artefact:

  a) Read the file in full
  b) Apply top-level SKILL.md + the type-specific skill named in §3
  c) Decide RATIFIED or REJECTED
  d) Write your verdict to logs/codex-ratification/round-2-autonomous/<slug>.output.md
     Format per SKILL.md §4: first line starts with literal RATIFIED or REJECTED
  e) Continue to next artefact regardless of verdict; do NOT stop on REJECTED

For Tier 1 (14 re-ratifications): the Round-1 verdict + remediation commit 
SHA is in docs/decisions/2026-05-18-codex-ratification-manifest.md §1.5. 
Verify the remediation actually addressed the Round-1 issue before voting 
RATIFIED. If the Round-1 issue is still present despite a commit claiming 
to fix it, REJECT with the specific evidence.

For Tier 3 disagreement docs (items 19 + 20 in §3): you are evaluating 
recursive ratification per master brief §10.5. Decide whether Claude's 
counter-argument holds OR whether the original Round-1 Codex rejection was 
correct. For doc #19 (D5 skill softening), evaluate the proposed skill 
change itself. For doc #20 (bullhorn Week-1 gate), evaluate whether the 
gate hierarchy reframing is correct.

For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
#14): these have founder-decision-bound issues (D1, D3). If the content 
itself is clean but the founder decisions remain unresolved, RATIFIED-with-
advisory is acceptable — note the open founder decisions explicitly.

For ANY artefact where you find a NEW issue not surfaced in Round 1:
  REJECT with the new issue numbered. Don't try to fix it; document it.

STEP 4 — Write the summary report (~30 min)

After all 26 artefacts are reviewed, write a comprehensive report to:
  logs/codex-ratification/round-2-autonomous/SUMMARY.md

Required sections:

  ## §1 — Headline counts
  - Tier 1 (re-ratify): X RATIFIED / Y REJECTED of 14
  - Tier 2 (new Day-9): X RATIFIED / Y REJECTED of 4
  - Tier 3 (new Day-11): X RATIFIED / Y REJECTED of 8
  - Total: X RATIFIED / Y REJECTED of 26

  ## §2 — Per-tier per-artefact table
  Columns: Tier | Path | Skill | Round-1 verdict | Round-2 verdict | 
           Issue count | Notes

  ## §3 — Disagreement-doc recursive verdicts
  For items 19 + 20: did Codex agree with Claude's counter-argument? 
  If REJECTED: explain whether you reject the framing OR the proposed 
  skill change.

  ## §4 — Founder-attention items
  Top 3-5 items that need founder action post-Round-2. For each:
  - What the issue is
  - Why it's founder-domain (not Claude-fixable)
  - Recommended path

  ## §5 — New gaps surfaced
  Any architectural concerns Codex spotted that aren't in the existing 
  remediation queue (architecture-cohesion-review.md §8 has 14 items + 
  tenant-lifecycle.md §8 has 8 items). New gaps = numbered list with 
  severity + recommended owner.

  ## §6 — Risk register additions
  If your review surfaces a risk-register-worthy item not already captured 
  (Risks #1-#10), list it with proposed severity + tripwire.

STEP 5 — Update the Codex manifest queue (~15 min)

Edit docs/decisions/2026-05-18-codex-ratification-manifest.md.

Add a new §1.7 section "Codex Round 2 verdicts (2026-05-22)" mirroring the 
existing §1.5 (Round 1) shape:

  - Header paragraph summarising counts + remediation commit refs
  - Per-artefact table with columns: # | Artefact | Round-2 verdict | 
    Round-2 disposition

For items that flipped REJECTED → RATIFIED: disposition column says 
"Incorporated remediation verified clean."

For items that stayed REJECTED: disposition says "Open: see SUMMARY.md §4 
for founder action."

For new artefacts (Tier 2 + Tier 3): disposition says "First ratification 
on Round 2; <verdict>."

Update the manifest total ("21 items at Day-7 close") to reflect final 
state ("43+ items; X ratified / Y remaining"). Don't rewrite §1.5 — append.

STEP 6 — Update state files (~10 min)

Edit .agents/current-priorities.md:
  - Update "Today's task" to reflect Round 2 closure
  - Add a "Shipped" section for the Round-2 work
  - Update the architecture+tenancy backlog if any items resolved

Edit docs/RISK-REGISTER.md:
  - Add a log entry under "Update log" for the Round-2 close
  - If §5 of SUMMARY.md surfaced a new risk, append it as Risk #11+

STEP 7 — Commit + push

Stage:
  git add logs/codex-ratification/round-2-autonomous/ \
    docs/decisions/2026-05-18-codex-ratification-manifest.md \
    .agents/current-priorities.md \
    docs/RISK-REGISTER.md

Commit message (use a HEREDOC to preserve formatting):

  ops(codex-round-2): autonomous ratification of 26 artefacts + manifest closure

  Round 2 ratification complete. <X> of 26 RATIFIED. <Y> remaining 
  REJECTED items detailed in SUMMARY.md §4 require founder attention.

  Tier 1 (re-ratify Round-1 REJECTED): <X> of 14 flipped to RATIFIED.
  Tier 2 (Day-9 new artefacts): <X> of 4 RATIFIED.
  Tier 3 (Day-11 new artefacts): <X> of 8 RATIFIED.

  Disagreement docs (recursive ratification per master brief §10.5):
    - D5 skill softening (item 19): <RATIFIED|REJECTED>
    - Bullhorn Week-1 gate (item 20): <RATIFIED|REJECTED>

  Full per-artefact verdicts at logs/codex-ratification/round-2-autonomous/
  + manifest update at docs/decisions/2026-05-18-codex-ratification-
  manifest.md §1.7.

  Founder action items surfaced: <N> (see SUMMARY.md §4).

  Co-Authored-By: Codex (gpt-5-codex)

Then: git push origin main

STEP 8 — Final status to stdout

Print a one-screen summary to stdout:

  ═══════════════════════════════════════════════════════════════════
  CODEX ROUND 2 COMPLETE — <timestamp>
  ═══════════════════════════════════════════════════════════════════

  Total: X RATIFIED / Y REJECTED of 26
  Tier 1: X/14 — most should have flipped from REJECTED → RATIFIED
  Tier 2: X/4
  Tier 3: X/8 (incl 2 disagreement-recursive verdicts)

  Manifest closed at: <commit-SHA>
  Logs at: logs/codex-ratification/round-2-autonomous/

  FOUNDER ACTION REQUIRED:
  - <Item 1 brief>
  - <Item 2 brief>
  - <Item 3 brief>

  Next: bash scripts/run-live-migration.sh --dry-run
        (then live + tenancy audit; see codex-round-2-handoff.md §11)

  ═══════════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════════
AUTONOMOUS-EXECUTION RULES
═══════════════════════════════════════════════════════════════════

1. **DO NOT stop and ask for clarification.** Make sensible defaults. 
   Surface concerns in SUMMARY.md §4, not mid-run.

2. **DO NOT modify ANY artefact file** during ratification. If Codex 
   thinks an artefact needs editing, REJECT it + note the fix in the 
   output file. The founder OR Claude decides whether to incorporate.
   Exception: Steps 5 + 6 modify manifest + state files + commit; that's 
   intentional + scoped.

3. **DO NOT push partial work.** Only push when Step 7 commits everything 
   together. If a step fails mid-run, log it + continue with what's 
   possible.

4. **DO NOT make founder decisions.** Items like D1 (autosend orange tier), 
   D2 (external advisor), D3 (PII retention), D4 (Path B), D5 (skill 
   softening — wait, D5 is already resolved as of commit 783c496) — these 
   are founder-domain. Codex evaluates them in artefacts but does NOT 
   decide them.

5. **DO NOT run scripts that require credentials.** Specifically:
   - scripts/run-live-migration.sh (needs Postgres password)
   - scripts/run-tenancy-audit.sh (needs Postgres password)
   - scripts/ifos-pii-purge.sh (production cron; needs deployment context)
   - Any cortextos-ifos command requiring CTX_FRAMEWORK_ROOT
   These are founder Path-A actions.

6. **DO commit + push the ratification work** in Step 7. The wrapper 
   script (scripts/run-codex-ratification.sh) handles per-artefact audit 
   rows; you handle the closure commit.

7. **If you hit a stopping-rule condition** (codex-round-2-handoff.md §9):
   document it in SUMMARY.md §4 + still try to commit the partial work.

8. **Honest signal over optimistic projection.** If your honest assessment 
   is "this artefact still REJECTS even after remediation", say so. The 
   founder NEEDS that signal.

═══════════════════════════════════════════════════════════════════
BEGIN NOW
═══════════════════════════════════════════════════════════════════

Start with Step 1 (read context). Confirm internalisation by listing the 
12 tenancy invariants. Then proceed through Steps 2-8 without pausing for 
founder input.

Total expected runtime: 6-9 hours. The founder will check on you when you 
finish — they're walking away during the run.

Begin.
```

---

## What this prompt is + isn't

### IS:
- **Self-contained** — references the binding spec (`codex-round-2-handoff.md`) but doesn't require external instruction
- **Autonomous** — explicit "no founder input" rules + sensible-defaults guidance
- **Comprehensive** — covers all 26 artefacts + manifest closure + state files + commit + push
- **Verifiable** — Step 1 internalisation check + Step 4 SUMMARY.md + Step 8 stdout summary

### IS NOT:
- A replacement for the live VPS work (Postgres password is Path-A founder-only)
- A replacement for SeedLegals engagement (commercial action)
- A replacement for any founder decision (D1-D5 are surfaced, not decided)
- A blocker on Diagnostic build — that runs separately after Round 2 + founder actions

---

## After Codex finishes

When you return:

1. Read `logs/codex-ratification/round-2-autonomous/SUMMARY.md`
2. Check the commit on `origin/main` — single commit + push expected
3. Review SUMMARY.md §4 (founder action items) — usually 0-3 items
4. Read SUMMARY.md §5 (new gaps) — surface any architectural surprises

**If SUMMARY.md shows clean (0 REJECTED OR all REJECTED are founder-decision-bound):** Round 2 done. Move to founder action sequence items 5-8 (live migration + tenancy audit + SeedLegals + Diagnostic build).

**If SUMMARY.md shows unexpected REJECTED items:** Codex caught something. Read the per-artefact output file. Decide whether to incorporate or counter-argue. Then Round 3 (~limited; ≤2 round-trips per master brief §10.3).

---

## Cost

- ~6-9h of Codex runtime
- ~$80-150 OpenAI billing
- 0h founder time during the run (walk away)
- ~30 min founder review post-run

*End of autonomous prompt doc.*
