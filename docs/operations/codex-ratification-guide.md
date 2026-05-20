# Codex ratification — practical guide

**Status:** Reference (operations guide).
**Audience:** Founder (Maddox). This guide tells you how to run Codex ratification on the IFOS codebase end-to-end.
**Companions:**
- `docs/operations/codex-ratification-execution-plan.md` — the WHAT/WHEN (queue, schedule, cost)
- This file — the HOW (step-by-step, mental model, troubleshooting)
- `.codex/ratification/SKILL.md` + `review-*.md` — what Codex actually reads
- `scripts/run-codex-ratification.sh` — the driver

---

## §1 — Mental model: what Codex ratification actually is

You have built IFOS with one model (Claude Opus 4.7). Single-model build of this size carries real risk: the model agrees with itself, papers over its own gaps, and ships artefacts that look internally consistent but have structural blind spots.

**Codex ratification is the second-pair-of-eyes loop.** A different model (`gpt-5-codex` from OpenAI) reads each artefact you've built. It applies a known checklist (the SKILL.md files you'll see below) and returns one of two verdicts:

- `RATIFIED` — Codex agrees the artefact passes the checks. Merge with confidence.
- `REJECTED` — Codex flags concrete numbered issues. You either incorporate the feedback or write a disagreement doc explaining why Codex is wrong.

**The disagreements are the most valuable signal.** Where Claude and Codex disagree, the spec is ambiguous or load-bearing assumptions diverge. That's exactly where you, the founder, get the best decision-input.

This loop does NOT replace Claude Code's work. It validates it. Both models writing the same code is wasteful; both models reviewing the same artefact catches different mistakes.

### What Claude tends to miss (and Codex catches)

- Type/build issues — TypeScript inference quirks, runtime type mismatches
- Defensive code that nobody calls
- Citation drift — `master brief §10.4` quoted 15 times in one batch, all wrong (real past incident)
- Over-elaborated worked examples masking thin decisions underneath
- Status drift — file says "Accepted" but content says "TODO"

### What Codex tends to miss (and Claude catches)

- Semantic/specification consistency across docs
- Long-context architectural coherence
- IFOS-specific idiom (boundaries, the five rules, ESC catalogue conventions)

The SKILL.md files give Codex the IFOS-specific idiom. That's the load-bearing part of the loop — without good skills, Codex is just a generic reviewer.

---

## §2 — How Codex actually sees what you've built

Concretely:

1. **Codex CLI** is OpenAI's terminal-based agent (analogous to Claude Code). You launch it with `codex` in your repo directory.
2. **Codex has file-system tools** — it can read any file under the directory it was launched from. It does NOT have automatic context of your conversation with Claude.
3. **Codex starts blank** — no memory of prior sessions, no awareness of IFOS unless the prompt tells it.
4. **The SKILL.md files prime Codex** — when you run a ratification, the wrapper builds a prompt that says: "Here is the IFOS top-level skill. Here is the type-specific skill. Here is the artefact. Apply both skills."
5. **Codex reads + reasons + returns** RATIFIED or REJECTED in a structured format dictated by the SKILL.md output contract.

The wrapper at `scripts/run-codex-ratification.sh` automates this: assembles the prompt, invokes `codex exec` non-interactively, captures output, parses the verdict, writes an audit row to `decision_log`.

You don't need to write the prompts yourself. Run the wrapper and it does the assembly.

---

## §3 — Setup (one-time)

### Step 3.1 — Fix the broken Codex CLI install

Verified 2026-05-20: `which codex` returns `/opt/homebrew/bin/codex` but invocation fails with `ENOENT` — the native binary at `vendor/aarch64-apple-darwin/codex/codex` is missing. The `postinstall` script that downloads the native binary did not complete.

Fix:

```bash
# Reinstall — forces postinstall to run again
npm install -g @openai/codex --force

# Verify the native binary exists
ls /opt/homebrew/lib/node_modules/@openai/codex/node_modules/@openai/codex-darwin-arm64/vendor/aarch64-apple-darwin/codex/codex

# Verify codex executes
codex --version

# Confirm auth (Codex requires either OpenAI API key or ChatGPT login)
codex --help | head -20
```

If the reinstall doesn't fix it, try a full clean:

```bash
npm uninstall -g @openai/codex
npm cache clean --force
npm install -g @openai/codex
```

If it STILL fails (postinstall blocked by network/proxy), download the binary tarball from `https://github.com/openai/codex/releases` and extract to the vendor path manually. Document any workaround in `.agents/learnings/00-cortextos-quirks.md`.

### Step 3.2 — Authenticate Codex

`codex` requires authentication on first run. Two options:

- **OpenAI API key** — set `OPENAI_API_KEY` in your shell environment OR pass via `--api-key`
- **ChatGPT login** — `codex auth login` opens a browser

For IFOS ratification work, the API key path is simpler — paste your key into `~/.zshrc` (or wherever you keep secrets locally):

```bash
export OPENAI_API_KEY="sk-..."
```

Path A discipline: this key stays local. Never commit it. The IFOS repo doesn't need it.

### Step 3.3 — Verify the skills are in place

```bash
ls .codex/ratification/
```

Expected output:

```
SKILL.md
review-architecture-decision.md
review-schema-change.md
review-postgres-migration.md
```

Three more skills (`review-agent-bundle.md`, `review-mcp-connector.md`, `review-harness-bump.md`) are deferred per the execution plan §3 — they're lazy, built at first need.

### Step 3.4 — Verify the wrapper runs

```bash
bash scripts/run-codex-ratification.sh --list-clusters
```

Expected: prints clusters A/B/C/D with their artefact lists. No codex invocation needed for `--list-clusters`.

---

## §4 — Worked example: ratifying ADR-001 end-to-end

Concrete walkthrough so you know exactly what the loop looks like.

### Step 4.1 — Pick the artefact + skill

ADR-001 is at `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md`. It's an architecture decision, so the skill type is `architecture-decision`.

### Step 4.2 — Invoke the wrapper

```bash
bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
```

The wrapper does the following in sequence:

1. **Pre-flight** — verifies `codex` is on PATH + executes, `.codex/ratification/SKILL.md` exists, session log dir created.
2. **Prompt assembly** — concatenates the top-level skill, the type-specific skill, the artefact content, and the output-contract instructions into a single prompt at `logs/codex-ratification/<session-id>/<artefact-slug>.prompt.md`.
3. **Codex invocation** — `codex exec < prompt > output.md`. Codex reads the prompt, applies the skill, returns its verdict.
4. **Verdict parse** — wrapper checks the first word of the output. If `RATIFIED`, marks pass. If `REJECTED`, counts the numbered issues.
5. **Audit row write** — inserts a row into `decision_log` with `tenant_slug='ifos-meta'`, `agent_name='_codex_ratifier'`, `phase='output'`, `outcome=<RATIFIED|REJECTED>`, `payload` includes the artefact path, skill used, issue count, session ID, and the full Codex response text. Falls back to `logs/codex-ratification.jsonl` if no live DB.

### Step 4.3 — Example output (success case)

```
── Reviewing docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md (round 1, skill=architecture-decision) ──
  ✓ Prompt assembled at logs/codex-ratification/20260520T143000Z-12345/...prompt.md
  ✓ Codex returned response (logs/codex-ratification/.../...output.md)
  ✓ Verdict: RATIFIED
  ✓ decision_log row appended to fallback (logs/codex-ratification.jsonl)
```

The output file contains Codex's verbatim response:

```
RATIFIED

ADR-001 cleanly weighs three alternatives (chokidar / FastChecker / hybrid). Status
field is Accepted with founder decision date. Citation accuracy verified: master
brief §2.4 row 3 line reference holds; ADR-002 Edit 1 reference holds. Five-rule
pass: output before architecture (renderer goal stated first); reuse before build
(uses existing master-brief vocabulary, doesn't invent terms). Four-boundary pass:
no submodule modifications proposed; no Composio/AgentMail in tools.yaml; vault/
Postgres split honoured.
```

This artefact merges as-is.

### Step 4.4 — Example output (rejection case)

```
── Reviewing docs/decisions/some-artefact.md (round 1, skill=architecture-decision) ──
  ✓ Prompt assembled at ...
  ✓ Codex returned response (...)
  ✗ Verdict: REJECTED (3 numbered issues)
    Read logs/codex-ratification/.../...output.md
  ✓ decision_log row appended to fallback
```

Codex's response:

```
REJECTED

1. Status field says "Accepted" but §4 (Consequences) says "pending commercial conversations with Bullhorn partnerships team." Status drift. Either flip Status to "Proposed" with Sub-decision C as Accepted-only, or remove the "pending" caveat. Citation: ADR-001 line 7 vs §4.2.

2. Citation §10.4 incorrect — master brief §10.4 is the Codex exclusion list, not the cost target the ADR cites. Past pattern of 15 fabricated §10.4 references; verify line numbers before citing. Citation: ADR-001 line 47.

3. Alternative B ("hybrid chokidar + poll") is named but not weighed — no reason given for rejection. ADR template requires every named alternative to have a stated rejection reason. Add 2-3 sentences explaining why hybrid was rejected. Citation: ADR-001 §3 second bullet.
```

### Step 4.5 — Round trip 2 (if REJECTED)

You read the response. For each issue you have three choices:

- **Incorporate** — fix the artefact + commit + re-run the wrapper. If round 2 RATIFIES, merge.
- **Counter-argue** — write `docs/decisions/codex-disagreement-<date>-<slug>.md` explaining why Codex is wrong. Re-run the wrapper pointing at the disagreement doc.
- **Compromise** — partially incorporate, partially counter-argue. Same disagreement doc pattern.

The hard ceiling is 2 round-trips per artefact. If round 2 still REJECTED, escalate to founder (which is you — make the call, commit the decision, move on).

---

## §5 — Running the full ratification queue

Per the execution plan §9 Option γ recommendation: run clusters A + B + C this week; defer D-I until after the live VPS migration completes.

### Step 5.1 — Cluster A (8 ADRs/decisions)

```bash
bash scripts/run-codex-ratification.sh --cluster A
```

This loops through all 8 cluster-A artefacts, runs each through `review-architecture-decision`, and prints a summary.

Expected time: ~3h20m mean per execution plan §5. Includes round-trips on ~10% of artefacts (estimate 1-2 will REJECT).

### Step 5.2 — Cluster B (6 reference designs)

```bash
bash scripts/run-codex-ratification.sh --cluster B
```

Reference designs (audits, design docs, runbooks). Same skill as cluster A.

Expected time: ~2h30m.

### Step 5.3 — Cluster C (2 schema artefacts)

```bash
bash scripts/run-codex-ratification.sh --cluster C
```

Schema YAMLs. Uses `review-schema-change` skill — checks layering, agent matrix consistency, Bullhorn mapping alignment, open-question discipline.

Expected time: ~1h.

### Step 5.4 — Pause for live VPS migration

Per execution plan §9: after cluster C, PAUSE until `bash scripts/run-live-migration.sh` succeeds. The live migration verifies Phase 4 SQL applies cleanly against the migration-test tenant; cluster D (migration ratification) makes more sense AFTER that.

### Step 5.5 — Clusters D-I

Run after live migration + Q1 LOI close.

```bash
bash scripts/run-codex-ratification.sh --cluster D  # migration SQL
# Then single-artefact invocations for clusters E-I
```

E-I are smaller and individually invokable per the execution plan §4 queue table.

---

## §6 — Reading Codex output — patterns to recognize

### 6.1 — Clean RATIFIED

```
RATIFIED

<0-5 lines of advisory notes>
```

Just merge. The advisory notes are optional improvements; not blocking.

### 6.2 — REJECTED with clear, actionable issues

```
REJECTED

1. <line citation>. <problem>. <fix>.
2. <line citation>. <problem>. <fix>.
3. ...
```

Best-case rejection. Each issue is concrete. Decide per-issue: incorporate or counter-argue.

### 6.3 — REJECTED with vague issues

```
REJECTED

1. The artefact feels under-specified.
2. Consider strengthening the alternatives section.
```

This is a red flag — Codex didn't grip the artefact. Re-run with a slightly more targeted prompt (you can edit the prompt file under `logs/codex-ratification/<session-id>/*.prompt.md` and re-invoke). If the second run is similarly vague, treat as advisory (RATIFIED-with-notes) rather than blocking.

### 6.4 — Unparseable verdict

Wrapper marks as REJECTED with `issue_count=unparseable`. Read the output manually. Common causes:

- Codex hit a token limit mid-response
- Codex started with preamble ("Looking at this artefact, ...") instead of `RATIFIED|REJECTED`
- Codex returned an empty response (timeout)

Re-run. If reproducible, capture the full stderr (look at `logs/codex-ratification/<session-id>/*.output.md`) and escalate to founder.

### 6.5 — Contradictory output (RATIFIED but with issues listed)

```
RATIFIED

However, there are some concerns:
1. ...
2. ...
```

Treat as REJECTED. The model is hedging. Read the concerns; address them. Re-run.

---

## §7 — Writing a disagreement doc (counter-argument)

When you decide Codex is wrong, write:

`docs/decisions/codex-disagreement-<YYYY-MM-DD>-<slug>.md`

Template:

```markdown
# Codex disagreement — <artefact name>

**Date:** YYYY-MM-DD
**Artefact:** <path>
**Skill:** <skill file>
**Codex outcome:** REJECTED
**Codex's numbered issues:**

[Paste verbatim from Codex output]

## Claude's response

1. <Codex's issue #1 verbatim>

   **Counter:** <Claude's reasoning for why Codex is wrong. 2-4 sentences.>

2. <Codex's issue #2 verbatim>

   **Counter:** ...

## Resolution

- [ ] Incorporated (Codex correct; artefact updated)
- [ ] Counter-argued (Claude's reading prevails; founder decision)
- [ ] Compromise (partial accept; both perspectives integrated)

## Founder decision (if escalated)

<Founder writes this when picking between Claude and Codex>

---

After this disagreement doc is written:
- Re-run the wrapper pointing at the artefact (Codex may RATIFY on round 2 if the doc has been added to context)
- OR mark the artefact as RATIFIED-with-disagreement-recorded if you're confident Claude's reading is right
```

The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.

---

## §8 — Audit trail — how everything gets logged

Every Codex review writes a row to `decision_log`:

```sql
SELECT
  created_at,
  payload->>'artefact_path' AS artefact,
  payload->>'skill_used' AS skill,
  outcome,
  payload->>'issue_count' AS issues,
  payload->>'round_trip' AS round
FROM decision_log
WHERE agent_name = '_codex_ratifier'
ORDER BY created_at DESC
LIMIT 50;
```

Run this query at any point to see your ratification history.

If `IFOS_DB_URL` isn't set when the wrapper runs (or psql isn't on PATH or the live DB rejects the write), the row appends to `logs/codex-ratification.jsonl` instead. Same shape, JSON Lines. Replays into Postgres later via the autosend-syncer worker (Week 5+).

### Audit row payload structure

```json
{
  "artefact_path": "docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md",
  "skill_used": "architecture-decision",
  "issue_count": 0,
  "round_trip": 1,
  "session_id": "20260520T143000Z-12345",
  "codex_response_text": "RATIFIED\n\n<full text up to 8000 chars>"
}
```

The `session_id` ties all artefacts reviewed in one wrapper invocation together. Useful for retro queries:

```sql
SELECT
  payload->>'artefact_path' AS artefact,
  outcome,
  payload->>'round_trip' AS round
FROM decision_log
WHERE payload->>'session_id' = '20260520T143000Z-12345'
ORDER BY created_at;
```

---

## §9 — Troubleshooting

### 9.1 — `codex CLI invocation fails (likely broken install)`

Pre-flight catches this. See §3.1 above.

### 9.2 — `Codex returned empty response`

Possible causes:
- Network timeout to OpenAI API → retry
- API key invalid/expired → `codex auth status`
- Rate limit → wait + retry
- Artefact too large for context window → split into chunks; ratify each chunk separately

### 9.3 — `Verdict unparseable`

Codex didn't start with RATIFIED/REJECTED. Read the output file manually. Sometimes Codex prepends thinking ("Looking at this artefact...") despite the prompt instructing not to. Re-run; second invocation usually adheres.

### 9.4 — Codex consistently RATIFIES artefacts that have known issues

You've found a skill-file weakness. The SKILL.md isn't asking Codex to check the right thing. Update the relevant `review-*.md` file to add the missing check, then re-run.

Example: if you noticed Codex RATIFIED an ADR with a status-drift problem, add a check in `review-architecture-decision.md §1` for status-content consistency. Re-ratify the affected artefacts.

### 9.5 — Codex disagrees with itself across re-runs

Same artefact, same skill, different invocations → different verdicts. This is real model nondeterminism. Two strategies:

- Run the same artefact 3 times; take the majority verdict
- Read both responses; if they disagree on substantive issues, those are the most valuable disagreements — escalate to founder

### 9.6 — `IFOS_DB_URL` not set

Audit rows write to fallback JSONL. That's fine for offline runs. When you do the live VPS smoke test (`bash scripts/run-live-migration.sh`), the connection establishment may automatically populate IFOS_DB_URL in your shell session — or you can set it manually:

```bash
# After bringing up an SSH tunnel manually:
ssh -i ~/.ssh/ifos_hetzner_ed25519 -N -L 55432:localhost:5432 maddox@178.105.87.24 &
export IFOS_DB_URL="postgresql://ifos_app:<password>@localhost:55432/ifos?sslmode=disable"

# Then run the ratification wrapper
bash scripts/run-codex-ratification.sh --cluster A

# When done:
unset IFOS_DB_URL
# kill the tunnel
```

---

## §10 — First-run recommendation (Option γ)

The execution plan §9 names three options for when to start ratification (α = now, β = after Q1, γ = hybrid). Founder bias is γ.

### Day-by-day for clusters A+B+C:

**Today:**
1. Fix Codex CLI install (§3.1) — 10 min
2. Verify wrapper runs (`bash scripts/run-codex-ratification.sh --list-clusters`) — 1 min
3. Pick ONE artefact for a smoke test — recommend ADR-001 (smallest, most-tested):
   ```bash
   bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
   ```
4. Read the response. Adjust skill if needed.

**Day 9-10:**
- Cluster A (8 artefacts, ~3h20m)
- Address rejections inline; build a punch-list of any disagreement docs

**Day 11:**
- Cluster B (6 artefacts, ~2h30m)
- Cluster C (2 artefacts, ~1h)

**Day 12+:**
- Pause; do the live VPS migration (`bash scripts/run-live-migration.sh`)
- Then resume with cluster D

**Founder time budget:** ~8-10 hours over 3-4 days for clusters A+B+C. The disagreement docs are where you'll spend most of the founder-decision time — budget ~30 min per disagreement; expect 2-4 disagreements total across the 16 artefacts.

---

## §11 — What success looks like

When you complete cluster A+B+C:

- **16 artefacts** with a recorded Codex verdict (RATIFIED or REJECTED→resolved)
- **0-4 disagreement docs** at `docs/decisions/codex-disagreement-*.md`
- **16+ audit rows** in `decision_log` under `agent_name='_codex_ratifier'`
- **Updated manifest** — `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue table marked with completion dates
- **Possibly updated RISK-REGISTER** — Codex may flag risks Claude missed
- **Possibly updated master brief** — Codex may flag spec drifts requiring atomic correction

When you complete clusters D-I post-live-migration:

- **All 34 artefacts** ratified
- **Codex ratifies this execution plan recursively** (item #32 in cluster G)
- **Codex ratifies this guide recursively** (newly-added queue item)
- **Codex Day-7 manifest closes** — first ratification run complete; production-grade audit trail

At that point, every architectural decision + every line of runtime code + every schema + every migration has been reviewed by two independent models. You have the best possible signal that the foundation is sound.

---

## §12 — One-page cheat sheet

```
# Setup (one-time)
npm install -g @openai/codex --force          # fix broken install
codex --version                                 # verify
export OPENAI_API_KEY="sk-..."                  # or codex auth login

# Daily use
bash scripts/run-codex-ratification.sh --list-clusters
bash scripts/run-codex-ratification.sh architecture-decision <path>
bash scripts/run-codex-ratification.sh --cluster A

# Read output
ls logs/codex-ratification/<session-id>/
less logs/codex-ratification/<session-id>/<artefact-slug>.output.md

# On REJECTED: incorporate fix + re-run
git diff <artefact>
bash scripts/run-codex-ratification.sh <skill-type> <path>

# On REJECTED + you disagree: write disagreement doc
${EDITOR:-vim} docs/decisions/codex-disagreement-$(date +%Y-%m-%d)-<slug>.md

# Audit trail
psql -c "SELECT created_at, payload->>'artefact_path', outcome FROM decision_log WHERE agent_name='_codex_ratifier' ORDER BY created_at DESC LIMIT 20;"
```

---

*End of practical guide.*
