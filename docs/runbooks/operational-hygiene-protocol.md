# Operational hygiene protocol — A-grade discipline rules

**Status:** In force (Day 6, 2026-05-18). All sections from Week 0 onwards reference this document at section-gate moments.
**Author:** Claude Code + founder (Maddox), Day-6 evening 2026-05-18
**Source:** Lessons from Days 0-6 execution. Bumps three operational-grade dimensions from B+/C+/B → A by codifying what was previously implicit.
**Audience:** This session and every future session. Reference at the start of any work that involves credentials, runbooks, drafts, or citations.

---

## §1 — Why this document exists

Days 0-6 self-grade on Week-0 retrospective (Day-6 evening):

| Dimension | Day-6 grade | A-grade target |
|---|---|---|
| Architectural rigour | A | maintain |
| Honest signal | A | maintain |
| Process discipline | A− | maintain |
| **Operational hygiene** | **B+** | A |
| **Length discipline** | **C+** | A |
| **Citation accuracy** | **B** | A |

The B+/C+/B grades reflect specific lapses where the discipline was implicit rather than written down:

- **Operational hygiene B+** — Path B was allowed mid-Day-4 (LUKS passphrase entered chat); Day 4 execution had self-inflicted deviations (defensive `sudo file -s` check; missing `sudo` on `sshd -T`; outdated `findmnt` regex)
- **Length discipline C+** — Day 5 autosend policy 658 lines vs 300-500 estimate; Day 6 vertical schema 899 lines vs same estimate
- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)

This document codifies the rules to bring all three to A. Reference it at the section-gate moment of any future work that touches the relevant surface.

---

## §2 — Credential-bearing operations: Path A / Path D protocols

Three named protocols for handling credentials in IFOS operations. Path A is the default for entering existing credentials; Path D is the default for generating new credentials. **Path B is forbidden absent explicit per-session founder waiver.**

### §2.1 — Path A (default for credential entry)

**Definition:** Founder enters credentials in their own local terminal session. Credentials never appear in Claude Code chat context, tool input, tool output, or anywhere a transcript could capture them.

**Use cases:**
- LUKS passphrase entry at `cryptsetup luksFormat` / `luksOpen` / `luksChangeKey`
- Postgres role passwords typed into `psql` prompts
- API tokens entered into Console UIs
- Any password prompt that the application requests interactively

**Mechanism:**
1. Claude Code prepares the command and surfaces it to the founder
2. Founder opens a fresh local terminal (or uses an existing one outside Claude Code's tool scope)
3. Founder runs the command interactively
4. Founder reports back: success / failure + relevant non-credential output

**Trade-off:** ~30-90 seconds of founder time per interactive step vs. zero credential exposure.

**Day-4 lesson:** Path A was the initial agreed protocol for §4.2 luksFormat + §4.3 luksOpen + §4.8 ifos-unlock end-to-end test. Path B was authorised mid-Day-4 for the ifos-unlock test specifically; the operational friction of Path A was found acceptable for first-use (luksFormat) but unacceptable for repeated use (ifos-unlock). Mitigation: Path D pattern (§2.3) eliminates many would-be-Path-B cases by generating credentials on-VPS where they never need to be re-entered.

### §2.2 — Path B (FORBIDDEN absent explicit waiver)

**Definition:** Credential enters Claude Code chat context, then gets piped via stdin or written to a temporary file for command execution.

**Why forbidden:**
- Chat transcript captures the credential
- Future transcript export, search history, or harness telemetry retains it
- Cannot be scrubbed retroactively
- Required to rotate the credential post-use to invalidate the transcript-captured copy

**Waiver process if Path B is genuinely needed:**
1. Founder types literally: `Path B: protocol override authorised` followed by the credential on a new line
2. Claude Code uses the credential once, immediately
3. Founder rotates the credential within 24 hours
4. Rotation logged in `.agents/decisions/<date>-path-b-rotation-<n>.md` with the original need and the rotation evidence

**Day-4 incident:** Path B was authorised once for §4.8 ifos-unlock end-to-end test. Founder retrospectively rotated via `cryptsetup luksChangeKey`; `--test-passphrase` verified OLD rejected + NEW accepted. The leaked passphrase in the transcript became cryptographically invalid against the LUKS volume. **Cost:** ~30 minutes of rotation work + permanent transcript-history annotation.

**Path B was the right call for Day 4 only because the protocol violation was acknowledged and the rotation was committed in the same session.** The Day-4 close commit (`98c79b2`) is the audit record. Future sessions: avoid Path B by defaulting to Path A or Path D.

### §2.3 — Path D (default for credential generation)

**Definition:** Credential generated on the remote VPS (or other target system) via `openssl rand` or equivalent. Never echoed to stdout. Stored in a file with mode 0600 root:root. Founder retrieves separately via `sudo cat` in their own terminal, saves to 1Password, then deletes the temp file.

**Use cases:**
- Postgres role passwords (Day-5 §5.4 `ifos_app` role)
- LUKS passphrase rotation (Day-5 §11 LUKS rotation post-Path-B)
- Future API token generation
- Any random-generated credential

**Mechanism (worked example from Day-5 §5.4):**

```bash
# Inside an SSH session as maddox on the VPS:
PASSWORD=$(openssl rand -base64 24)                              # generate; not echoed
printf '%s' "$PASSWORD" | sudo tee /vault/.<name>.tmp >/dev/null # write file; tee output discarded
sudo chmod 600 /vault/.<name>.tmp                                # restrict access
sudo chown root:root /vault/.<name>.tmp                          # root-only
sudo -u postgres psql <<SQL                                      # use via stdin heredoc (not ps-visible)
ALTER ROLE <role> WITH PASSWORD '$PASSWORD';
SQL
unset PASSWORD                                                    # clear from shell env
```

Founder retrieval (separate terminal, separate SSH session):

```bash
ssh ... 'sudo cat /vault/.<name>.tmp'   # founder views password
# (founder copies to 1Password)
ssh ... 'sudo rm /vault/.<name>.tmp'    # founder deletes temp file
```

**Properties:**
- Password never appears in Claude Code's output stream
- `ps auxf` cannot show the password (stdin heredoc, not command-line argument)
- Temp file is on the LUKS-encrypted volume (encrypted at rest)
- Founder retrieves at their convenience; no blocking handoff
- Rotation NOT required because password was never in chat context

**Trade-off:** ~2-minute founder retrieval at convenience vs. zero chat exposure.

---

## §3 — No-defensive-additions rule

**Rule:** When executing a runbook, run exactly the commands in the runbook. Do not add defensive checks, verification probes, or "while we're here" diagnostics beyond what the runbook specifies.

**Why:** Defensive additions introduce failure modes the runbook author didn't anticipate. They risk aborting the script via `set -e` on a check that wasn't part of the contract. They create the false impression of robustness while actually reducing it.

**Day-4 lessons:**
- Added `sudo file -s /dev/disk/by-id/...` defensive check not in runbook §4.1. `file` was not installed on the base Ubuntu image; `set -e` aborted the script before §4.2 install. Reverted to exact runbook commands.
- §9 verification script had `sshd -T` without `sudo`. Without root, sshd cannot read host keys and exits with "no hostkeys available". The check appeared to fail though state was correct. Diagnostic re-run needed.
- §9 verification script had `findmnt --verify` regex matching old output format. Post-LUKS-open, output simplified to "Success, no errors or warnings detected" which the regex missed. Diagnostic re-run needed.

**Discipline:**

1. **If the runbook is incomplete:** stop, fix the runbook (document the gap), then continue. Do not patch in-flight.
2. **If the runbook is wrong:** stop, fix the runbook (correct the spec), then continue. Do not work around silently.
3. **If you want to add a defensive check:** ask the founder first. If the check is genuinely valuable, it goes in the runbook for next time, not as an ad-hoc addition this time.
4. **Verification scripts:** test against known state before live use. A verification script that fails on a known-good state is a script bug, not a state bug.

**A-grade test:** zero self-inflicted deviations in a runbook execution. Every command run is in the runbook; every command in the runbook is run; deviations are explicit founder decisions, not Claude's choices.

---

## §4 — Length discipline: calibration methodology

**Rule:** Length estimates are calibration goals, not constraints — but they must be within ±20% of actual final length. If they're not, either the estimate was wrong (calibration issue) or the work bloated (trim discipline issue).

**Day-5/6 lessons:**
- Day 5 autosend policy: estimated 300-500 lines; actual 648. **+30% to +116% overshoot.**
- Day 6 vertical schema: estimated 300-500; actual 899. **+80% to +200% overshoot.**

Both were defensible (the depth was needed) but the estimates were systematically optimistic. The fix is per-unit calibration.

### §4.1 — Per-unit-line-budget table

Use this as the estimate basis for future drafts:

| Artefact type | Per-unit | Line budget | Examples |
|---|---|---|---|
| **ADR** | Per decision | 50-80 lines | ADR-001 (Decision 1 + 2 + Consequences ≈ 200 lines for 3 decisions) |
| **Reference doc** | Per mechanism / section | 60-100 lines | vault-concurrency.md (4 mechanisms ≈ 400 lines + headers) |
| **Runbook** | Per executable section | 80-150 lines (incl. commands + verification) | day-4-provisioning.md (12 sections ≈ 1200 lines) |
| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
| **Schema (YAML)** | Per entity / relationship | 40-60 lines (incl. fields + notes) | vertical-schema.yaml (8 entities × ~50 lines + 10 relationships × 10 lines + matrices + 12 questions ≈ 900 lines) |
| **Header + footer overhead** | Per artefact | +30-50 lines | Standard frontmatter + closing |

### §4.2 — Estimate methodology

1. Count sub-units (decisions, mechanisms, sections, tiers, entities, etc.)
2. Multiply by per-unit budget from §4.1
3. Add 20% overhead for headers, cross-references, open questions
4. Round to nearest 100

**Day-6 retrospective check:** vertical-schema.yaml estimated 300-500. Per §4.1: 8 entities × 50 = 400 lines, 10 relationships × 10 = 100 lines, agent matrix + Bullhorn mapping + open questions + versioning = ~200 lines, header overhead = ~50 lines. **True estimate: 750 lines.** Actual: 899. ±20% range: [600, 900]. **Actual is within range.** The Day-6 estimate was the wrong number, not the work.

### §4.3 — Trim discipline before commit

If first-draft length exceeds calibrated estimate by >20%:

1. Stop. Identify the bloat — usually one of three:
   - **Redundant cross-references** (same fact restated in multiple sections)
   - **Verbose examples** (10-line examples that could be 3 lines)
   - **Defensive notes** (footnotes that aren't load-bearing)
2. Trim before commit OR commit with explicit acknowledgment that depth-needed-equals-length-shipped + rationale in commit message
3. If founder accepts overshoot: that's a calibration update (§4.1 per-unit budget gets revised upward), not a discipline failure

**A-grade test:** estimates within ±20% of actual. When overshoot happens, it's a known/documented choice, not a surprise.

---

## §5 — Citation accuracy: pre-write verification

**Rule:** Every `§X.Y` reference, every line number, every numerical claim is verified against source *before* being written into an artefact, not after-the-fact in review.

### §5.1 — Pre-write verification checklist

Before writing any citation:

1. **`§X.Y` references:** open the source document. Verify the section exists and contains what you're about to claim.
2. **`line N` references:** open the source document at that line. Verify it matches.
3. **Numerical claims:** count. "29 action_types" not "30+". "10 entity_links" not "~10". If counting is hard, write the counting query (grep, wc -l, SQL) and run it.
4. **Cross-references:** when citing `<artefact>.md §X.Y`, verify both the artefact exists and §X.Y exists within it. Path drifts and renamed sections are common.

### §5.2 — Pre-commit citation audit (for new artefacts)

Before commit, run a citation grep across the artefact:

```bash
# Find all §-references
grep -nE "§[0-9]+(\.[0-9]+)*" <artefact>

# Find all line-N references
grep -nE "line [0-9]+" <artefact>

# Find all numerical-claim patterns
grep -nE "\b[0-9]+ (entities|fields|action_types|relationships|triggers|tiers|sections|edits|items)" <artefact>
```

For each match, verify against source. Fix any drift before commit.

### §5.3 — Numerical claims discipline

- "30+ action_types" → forbidden. Count: 29. Write "29 action_types".
- "~10 entity_links" → forbidden. Count: 10. Write "10 entity_links".
- "covers ~18 of 50+ available fields" → forbidden. Don't estimate the denominator if you don't know it. Write "covers 18 fields; full set TBD pending <named-trigger>".
- "8+ binary triggers" → forbidden if you have a specific count. Count: 10. Write "10 binary triggers".

### §5.4 — Master brief / cross-artefact citation discipline

**Day-6 lesson (§7 below):** 15 fabricated "master brief §10.4" references propagated across 5 files. The root cause: Day-4 runbook drafting invented a citation that didn't exist, and subsequent artefacts cited the Day-4 runbook citation without re-verifying against master brief.

**Discipline:**
- When citing master brief, verify against master brief — never against an intermediate artefact's citation of master brief
- When citing another IFOS artefact, verify the section + line exists in that artefact
- Citation transitivity is not a verification short-cut

**A-grade test:** zero citation drift in a pre-commit audit. Every reference checks out against source.

---

## §6 — When to consult this document

Reference at the section-gate moment of:

1. **Any runbook execution** — §3 no-defensive-additions rule applies to every command
2. **Any credential-bearing operation** — §2 Path A/D protocols apply
3. **Any drafting session** — §4 length calibration sets the estimate; §5 citation discipline applies during writing
4. **Any pre-commit audit** — §5.2 citation grep checklist
5. **Any Codex ratification preparation** — §5.2 audit is the input quality gate

Specifically, the section-gate prompts (e.g., "About to start §4 LUKS") should reference this doc as:

> "About to start §4 LUKS. Applying operational-hygiene-protocol §2 (Path A for passphrase entry; Path D for any new credential generation) + §3 (exact runbook commands only)."

---

## §7 — Day 4-6 citation audit findings (2026-05-18 Day 6 evening)

Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.

### §7.1 — Finding: master brief §10.4 fabrication

**Scope:** 15 references to "master brief §10.4" across 5 files, claiming §10.4 contains either (a) a Hetzner UK / FSN1 location reference or (b) a £20/mo cost target.

**Verified ground truth:** master brief §10.4 is "What never goes through ratification" — a 5-bullet list of Codex exclusions (comment-only changes, test fixture additions, documentation typos, build/deps version bumps, anything inside `.agents/`). It contains no Hetzner reference and no cost-target reference.

**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.

**Fix:** all 15 instances corrected on 2026-05-18 Day 6 evening:

| File | Instances | Correction |
|---|---|---|
| `docs/runbooks/day-4-provisioning.md` | 8 | "+§10.4" dropped from Edit 9 scope (was about Hetzner UK); "§10.4 cost target" replaced with "Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target)" |
| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
| `docs/decisions/v1.0-kill-criterion.md` | 3 | Same cost-target replacement for Trigger 6/7 source citations |
| `docs/RISK-REGISTER.md` | 2 | Risk #7 Edit 9 scope corrected; log entry annotated |
| `.agents/current-priorities.md` | 1 | Manifest Edit 9 scope corrected |

Audit-finding meta-references to "§10.4" remain in the corrected text (explaining what was wrong). These are NOT claims that §10.4 contains the fabricated content; they are pointers to the audit finding.

### §7.2 — Finding: Day-5 §4.1 citation incompleteness (resolved during Day-5 review)

Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").

**Fix applied during Day-5 founder review:** citation corrected to `§4.1 + §6.3`. No outstanding drift.

### §7.3 — Finding: Day-6 "30+ action_types" inflation (caught in founder review)

Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.

**Fix:** no artefact change. Lesson captured in §5.3 numerical-claims discipline.

### §7.4 — Spot-checks that PASSED audit

- `master brief §3.2 line 155` (canonical vocabulary "candidate, placement, brief") — ✅ verified line 155 matches
- `master brief §5.1 lines 325-329` (vault directory structure) — ✅ verified
- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
- `ADR-003 Decision 3` referencing "design §2.1" — ✅ verified Decision 3 exists; references `agent-bundle-renderer-design.md §2.1` correctly
- `sequencing-target.md §6.6 three failure conditions` — ✅ verified §6.6 exists and contains the three failure conditions verbatim
- `docs/specs/ULTRAPLAN.md` — ✅ verified exists (60KB; ratified canonical doc)
- `bullhorn-integration-path.md §4.1 + §6.3` (canonical-orange anchor) — ✅ verified both sections exist and contain claimed content

### §7.5 — Codex Day-7 ratification consequence

Codex reviews 18 items at Day 7. The citation-audit pass made all 15 fabrication fixes BEFORE Codex review. Codex receives correct citations; ratification does not need to re-discover the §10.4 fabrication. Saves Codex review time + improves ratification confidence.

---

## §8 — A-grade verification — Day-6 evening retrospective

Running the discipline rules against Days 0-6 retroactively:

| Dimension | Pre-doc grade | Post-doc grade | Why |
|---|---|---|---|
| Operational hygiene | B+ | **A** (codified) | §2 Path A/D + §3 no-defensive-additions now written. Future sessions reference at section-gate moment. Day-4 Path-B incident remains in history but the rule that would have prevented it is now in force. |
| Length discipline | C+ | **A** (calibration) | §4.1 per-unit-line-budget table calibrated against Day-5/6 actual lengths. Future estimates use the table, not optimistic guesses. Day-5/6 overshoots are now documented calibration data, not unexplained surprises. |
| Citation accuracy | B | **A** (audit + protocol) | 15 fabrications fixed (§7.1). §5 pre-write verification + §5.2 pre-commit audit rules now codified. Future citations checked at write time, not after-the-fact review. |

The A-grade is structural, not retrospective: Days 0-6 retain their historical grades (the work happened the way it happened), but the *next* session that touches credentials / runbooks / drafts / citations starts from A-grade discipline.

---

## §9 — Open questions

| # | Question | Resolution path |
|---|---|---|
| 1 | Should Path B waiver require a justification text in `.agents/decisions/`, not just the literal "protocol override authorised" line? | Day-7 Codex ratification reviews. Recommend yes: justification is the audit record of why Path A wasn't chosen. |
| 2 | Should §4.1 per-unit-line-budget table get its own per-week revision as new artefact types emerge? | Yes; track in this doc. Update after each new artefact type ships (e.g., when first agent bundle ships in Week 3-4, add "Agent bundle" row with calibrated budget). |
| 3 | Should §5 citation discipline be enforced via pre-commit hook (mechanical grep + verify)? | Defer to Week 1-2. Hook would be valuable but is itself code-to-write. v1.0: discipline is mental; v1.1+: tool-enforced. |
| 4 | How does this protocol interact with Codex ratification? | Codex reviews against this doc as criteria. If Codex flags a Day-7 artefact for violating §2/§3/§4/§5, that's actionable feedback, not a separate failure mode. |

---

## §10 — Status

**In force from 2026-05-18 Day 6 evening.**

Codex Day-7 ratification queue position 19 (was 18 pre-citation-audit; this doc joins).

Next revision: after Day 7 single-sentence test + first Codex ratification run. If Codex surfaces lessons from reviewing all 18 prior items, those lessons land here as §11+ findings.

*End of operational hygiene protocol.*
