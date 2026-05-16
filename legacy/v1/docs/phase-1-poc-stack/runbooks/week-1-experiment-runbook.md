# Week-1 Experiment Runbook
**How to execute the Proposal Builder POC end-to-end on real Fathom data, in one laptop, one week, before any container infrastructure exists.**

> **Audience:** you (Maddox) or whoever runs the POC. Intended to be executable by a mid-level dev in 3–5 days.
>
> **Purpose:** prove that the Proposal Builder bundle works on a real discovery call before we build the platform around it. If this week fails, we redesign. If it succeeds, CC2-CC11 are the natural next move.
>
> **Scope:** Proposal Builder only. Not the dashboard. Not the webhook receiver. Not Docker. Just: can a Fathom transcript land in a folder and produce a good proposal via Claude Code locally? If yes → the whole thesis survives.

---

## 1. Success criteria (define before you start)

Hard pass/fail on day 5. No partial credit.

- [ ] **PASS 1** — Run the agent on fixture 01 (clean dental case). Output is a proposal ≥ 800 words, passes all 9 structural checks in validate.sh, matches the golden output directionally (same tier recommended, same price band ±10%, same case study referenced).
- [ ] **PASS 2** — Run the agent on fixture 02 (ambiguous SaaS case). Output proposes three shapes matching the golden output, addresses the "wary of agencies" framing, references voice-profile extraction in Week 1.
- [ ] **PASS 3** — Run the agent on fixture 03 (budget mismatch). Output is an escalation note (NOT a proposal), cites code `BUDGET_BELOW_MINIMUM`, references Sam's verbatim budget quote, recommends self-serve alternatives.
- [ ] **PASS 4** — Run the agent on ONE real Fathom call (your own, yours and Jack's, or any recent external you can get consent for). Output is "reasonable" by your judgement — not perfect, but on-brand, priced within framework, no hallucinated facts.

If 4/4 pass → proceed to CC2 (Webhook Receiver) build.
If 3/4 pass → analyse the failure, patch agent.md, rerun.
If ≤2/4 pass → stop. Call me. We redesign the prompt structure before going further.

---

## 2. Prerequisites

Before starting, have these ready:

- [ ] MacBook or Linux machine with at least 16GB RAM
- [ ] Node.js 20+ installed (`node --version` shows v20.x)
- [ ] Python 3.11+ installed
- [ ] Claude Code installed globally (`npm install -g @anthropic-ai/claude-code`)
- [ ] `jq` installed (`brew install jq` on mac, `apt install jq` on linux)
- [ ] An Anthropic API key with Sonnet access, minimum £20 credit loaded
- [ ] A Fathom account (free tier works)
- [ ] Your existing Gmail account (we'll wire up Gmail MCP)
- [ ] The `phase-1-poc-stack/` folder unzipped to your local machine
- [ ] One real discovery-call-style Fathom recording you have consent to use

**Estimated setup time:** 60–90 minutes.

---

## 3. Day-by-day plan

### Day 1 (Monday) — Setup

**Morning (2–3 hours)**

Step 1.1 — Create the local working directory:
```bash
mkdir -p ~/intelforce-poc
cd ~/intelforce-poc
```

Step 1.2 — Copy the phase-1-poc-stack into place:
```bash
cp -R /path/to/phase-1-poc-stack ./
```

Step 1.3 — Set up your local vault (we're mimicking the tenant filesystem, but without Docker):
```bash
mkdir -p ~/intelforce-poc/tenant/{.claude/agents,vault,intake/fathom,outbox/{proposals,emails-pending,escalations},logs}
```

Step 1.4 — Wire the agent bundle into Claude Code's subagent structure:
```bash
cp -R ~/intelforce-poc/phase-1-poc-stack/proposal-builder ~/intelforce-poc/tenant/.claude/agents/
```

Step 1.5 — Seed a minimal vault using `minimal-vault-structure.md`. For the POC, you can fill this manually. The MUST-haves:
- `~/intelforce-poc/tenant/vault/CLAUDE.md` — copy the template, substitute placeholders with made-up Acme Agency details (the fixtures all use Acme as the client)
- `~/intelforce-poc/tenant/vault/brand/voice-profile.md` — minimal version, just one-line description and a few banned phrases
- `~/intelforce-poc/tenant/vault/brand/pricing.md` — three tiers for Acme Agency matching what the golden outputs reference:
  - Starter: £1,200/mo + £3,500 setup
  - Growth: £1,800/mo + £7,500 setup
  - Scale: £3,000/mo + £15,000 setup
  - Minimum engagement value: £1,500/mo
  - Human-drafting threshold: £50,000
- `~/intelforce-poc/tenant/vault/brand/service-catalogue.md` — list the services the fixtures reference: Voice Receptionist, Follow-Up Pilot, Content Creator, Outbound Pilot, Customer Success Watchdog, Missed-Call Recovery, Ad management, SEO programme
- Drop the three fixture `expected.md` files into `~/intelforce-poc/tenant/vault/clients/_past-proposals/` and tag them `winning-proposal` in the frontmatter — so retrieval has something to return

Step 1.6 — Create `~/intelforce-poc/tenant/.claude/tenant-config.json` manually using the template in `tenant-container-spec.md` §4. Fill in:
```json
{
  "tenant": { "id": "tnt_poc_001", "plan": "growth", "status": "active" },
  "client": {
    "name": "Acme Agency",
    "company_slug": "acme-agency",
    "industry": "B2B agency",
    "currency": "GBP",
    "timezone": "Europe/London",
    "vat_treatment": "ex-vat"
  },
  "sales_lead": {
    "name": "Jordan Taylor",
    "first_name": "Jordan",
    "email": "YOUR_GMAIL@gmail.com",
    "slack_handle": "@jordan",
    "signature_block": "Jordan Taylor\nHead of Growth, Acme Agency\njordan@acme-agency.co.uk · 0161 xxx xxxx\nacme-agency.co.uk"
  },
  "pricing": {
    "minimum_engagement_value": 1500,
    "human_drafting_threshold": 50000,
    "tier_naming": { "tier_1": "Starter", "tier_2": "Growth", "tier_3": "Scale" }
  }
}
```

Step 1.7 — Set the Anthropic API key:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
# Also add to ~/.zshrc or ~/.bashrc for persistence
```

**Afternoon (2 hours) — Verify Claude Code sees the subagent**

Step 1.8 — From `~/intelforce-poc/tenant/`:
```bash
claude
```

Then in the Claude Code TUI:
```
/agents
```

You should see `proposal-builder` listed. If not:
- Check the folder structure is exactly `.claude/agents/proposal-builder/agent.md`
- Check the YAML frontmatter in `agent.md` parses (name, description, tools)
- Run `claude --help` to confirm the version is 2.x

**End of Day 1 gate:** `/agents` shows proposal-builder. If not, stop and fix before Day 2.

---

### Day 2 (Tuesday) — Fixture 01 (the easy case)

**Morning (2–3 hours)**

Step 2.1 — Manually hydrate the context block. (We're skipping the context.sh hook for POC simplicity — we'll paste context directly.)

Edit `~/intelforce-poc/tenant/.claude/agents/proposal-builder/agent.md`. Between `<!-- CONTEXT-START -->` and `<!-- CONTEXT-END -->`, paste:
- The full voice-profile.md content
- The full pricing.md content
- The three fixture `expected.md` files (under "Three closest past winning proposals")
- The deal context — Meadow Lane Dental, domain, meeting type
- The Fathom summary from `tests/fixtures/01-dental-clear-fit/transcript.json` (the `default_summary.markdown_formatted` field)
- The Fathom action items
- The full transcript, formatted as `[timestamp] Speaker: text` one per line

Step 2.2 — Start Claude Code from the tenant directory:
```bash
cd ~/intelforce-poc/tenant
claude
```

Step 2.3 — Invoke the agent:
```
Use the proposal-builder agent to draft a proposal for Meadow Lane Dental based on the context block in the agent definition.
```

Step 2.4 — Watch what happens:
- Does it follow the 9-step workflow?
- Does it produce a file under `vault/clients/meadowlane-dental/proposals/`?
- Does validate.sh run after the Write and pass?

Step 2.5 — Compare output to `tests/fixtures/01-dental-clear-fit/expected.md`:
- Same tier recommended (Growth)?
- Price band match (£1,800/mo + £7,500 setup, ±10%)?
- Verbatim quotes from Priya appear in the proposal?
- Timeline references pre-August (her stated constraint)?
- Case study references Crescent Dental Edinburgh (in your retrieved context)?
- Length between 800–2500 words?

Step 2.6 — If the output is close but off, iterate:
- Maybe the voice-profile wasn't specific enough → add detail → rerun
- Maybe banned phrases slipped through → add to voice profile bans → rerun
- Maybe the case study wasn't retrieved properly → check retrieval fixture placement

**Afternoon (1–2 hours) — Lock in PASS 1**

Once fixture 01 passes your judgement test, commit the configuration. Don't touch the voice profile or pricing now — the next fixture should run against the SAME config.

Mark PASS 1 ✓ in success criteria.

---

### Day 3 (Wednesday) — Fixtures 02 and 03

**Morning — Fixture 02 (ambiguous SaaS)**

Step 3.1 — Reset the context block in agent.md to fixture 02's content (new transcript, new deal metadata, keep voice profile + pricing + past proposals the same).

Step 3.2 — Run the agent. Compare to `tests/fixtures/02-multi-service-ambiguous/expected.md`:
- Three distinct tier shapes (content-led, content+outbound, full stack)?
- Candidate screening explicitly EXCLUDED (it's outside service catalogue)?
- References Marcus's "wary of agencies" framing?
- Voice-profile extraction prominent in Week 1?

Step 3.3 — Iterate until acceptable. Mark PASS 2 ✓.

**Afternoon — Fixture 03 (budget mismatch)**

Step 3.4 — Reset context to fixture 03.

Step 3.5 — Run the agent. The CORRECT output is an escalation note, NOT a proposal. Verify:
- File landed in `outbox/escalations/` not `vault/clients/*/proposals/`
- Escalation code is `BUDGET_BELOW_MINIMUM`
- Sam's £200–300/month quote is referenced verbatim
- Recommendation includes self-serve tools, not a watered-down Starter

If the agent produces a proposal anyway → FAILED this gate. Likely means the escalation rules aren't weighted strongly enough in agent.md. Fix: strengthen the "STOP. Do NOT save a proposal" language in Step 2 and Escalation Conditions §2.

Step 3.6 — Mark PASS 3 ✓.

---

### Day 4 (Thursday) — Real Fathom call

This is the real test. All three fixtures are synthetic. Fixture 4 uses your actual data.

Step 4.1 — Pick a Fathom recording you have consent to process. Ideal: a recent sales-style or discovery-style call. If you don't have one, record a 20-minute roleplay with Jack where he plays a skeptical prospect.

Step 4.2 — Export the transcript from Fathom (Fathom has a transcript download option, or use their API). Format it as speaker-labelled, timestamped prose.

Step 4.3 — Substitute this real transcript into the context block of agent.md.

Step 4.4 — Update the deal context with the real company name, domain, etc.

Step 4.5 — Keep the voice profile / pricing / past proposals the same as previous runs (you're testing the agent, not the retrieval context).

Step 4.6 — Run the agent.

Step 4.7 — Judgement-test the output:
- Is this on-brand?
- Would you send this to the sales lead for review, or would you be embarrassed?
- Are any facts invented? (Numbers not in the transcript. Claims not in the service catalogue. Case studies you don't have.)
- Does it ask for the right next step?

If output is acceptable → PASS 4 ✓. Proceed to Day 5.
If output is unacceptable → document what went wrong. Classify:
- Voice miss (fix: improve voice profile)
- Fact invention (fix: strengthen "do not invent" guardrails in agent.md)
- Wrong scope (fix: service catalogue clarity)
- Wrong tier (fix: pricing framework clarity)
- Structural fail (fix: validate.sh)

Iterate. Rerun. Only mark PASS 4 when output is genuinely sendable.

---

### Day 5 (Friday) — Wire up Gmail + HubSpot (lightweight)

If all four PASS gates hit, spend Day 5 wiring the MCP integrations. If any fail, spend Day 5 on the failing case.

**Gmail MCP**

Step 5.1 — Install the Gmail MCP server:
```bash
npm install -g @gongrzhe/server-gmail-autoauth-mcp
```

Step 5.2 — First run triggers OAuth consent:
```bash
npx @gongrzhe/server-gmail-autoauth-mcp auth
```
Sign in with the Gmail account you set in `sales_lead.email`. Grant compose scope.

Step 5.3 — Register it in Claude Code's MCP config. In `~/intelforce-poc/tenant/.claude/settings.json`:
```json
{
  "mcpServers": {
    "gmail": {
      "command": "npx",
      "args": ["@gongrzhe/server-gmail-autoauth-mcp"]
    }
  }
}
```

Step 5.4 — Rerun fixture 01 end-to-end. The agent should produce a draft in your Gmail drafts folder. Open Gmail, verify the draft is there with the correct subject and body.

**HubSpot MCP (optional for POC, required for PASS 5 in later phases)**

Step 5.5 — If you have a HubSpot account, add the HubSpot MCP similarly and verify that stage updates work.

**End-of-week deliverable**

Step 5.6 — Write a 1-page POC report. Template:
```
# Proposal Builder POC — Results

## Gate results
- PASS 1 (fixture 01): ✓ / ✗
- PASS 2 (fixture 02): ✓ / ✗
- PASS 3 (fixture 03): ✓ / ✗
- PASS 4 (real call): ✓ / ✗
- PASS 5 (Gmail draft): ✓ / ✗

## Cost per run
[from Anthropic console — tokens in/out × Sonnet price]
Average: £X per proposal. Growth tier margin check: [X vs retainer].

## Time per run
[from logs: trigger → vault write]
Average: X seconds. Target is under 120s.

## Quality observations
- What the agent got right consistently:
- What it got wrong or needed nudging on:
- What's the single biggest improvement needed for v1.1:

## Recommendation
[PROCEED to CC2-CC11] / [PAUSE and redesign agent.md] / [KILL, this approach isn't viable]
```

Step 5.7 — Send the report to me. We decide CC2+ build kicks off Monday.

---

## 4. Common problems & fixes

### The agent doesn't find the proposal-builder subagent

- Check path: must be exactly `.claude/agents/proposal-builder/agent.md` relative to where you launched `claude`.
- Check frontmatter: `name: proposal-builder` (exact match), `tools:` line present.
- Try `claude /agents` to list what's discovered.

### The agent runs but produces generic output

- Voice profile is probably too sparse. Flesh out §2–§7 with real detail.
- Check the CONTEXT block actually got populated — open agent.md and look for `{{placeholder}}` still present.

### The validate.sh hook doesn't fire

- Check `settings.json` has the hook registered with correct `matcher` and `command` fields.
- Make sure validate.sh is executable: `chmod +x ~/intelforce-poc/tenant/.claude/agents/proposal-builder/validate.sh`.
- Check the hook is on `PostToolUse` for `Write` and `Edit`.

### Hallucinated facts

- Strengthen the guardrails. Add "do not invent" lines to §3 and §4 of agent.md.
- Add the banned "If you're inventing..." lines to the internal quality notes.
- Consider an LLM-as-judge pass post-validation that specifically checks facts against the transcript (v1.1 work, not POC).

### Costs higher than expected

- The transcript might be too long. Cap to 40k tokens in context.
- Reduce retrieval top_k to 2 if proposals are too padded with past-proposal context.
- Check you're on Sonnet, not Opus (Opus ~5x cost).

---

## 5. Costs you'll incur this week

Rough estimate on real Sonnet pricing:

| Item | Cost |
|---|---|
| Anthropic API usage (20 runs across 5 days) | £10–20 |
| Fathom free tier | £0 |
| Gmail OAuth | £0 |
| Cohere embeddings (skipped for POC — add later) | £0 |
| Your time (~30 hours) | your opportunity cost |

Budget £50 of API credit to be safe. You won't use it all.

---

## 6. What this POC proves (and what it doesn't)

### Proves
- The agent.md prompt structure produces usable proposals from real transcripts
- Quality gates catch structural failures
- Escalation conditions trigger correctly on unfit deals
- Cost per run is sustainable at tier retainer pricing
- Gmail draft delivery is reliable

### Does NOT prove
- Multi-tenant isolation (no containers)
- Webhook dispatch (manual context paste, not auto-triggered)
- Git-sync vault (local filesystem)
- pgvector retrieval (we're using files directly)
- Provisioning System (manual setup)
- Dashboard / configuration wizard (none of that exists yet)

Those are the CC2–CC11 work. This POC is proving the MOST IMPORTANT THING — that the prompt+config+validate pattern produces sendable output — before we build scaffolding around it. If this week succeeds, everything else is engineering work against a proven unit.

---

## 7. Escape hatch

If by end of Day 3 none of the fixtures pass, stop and call me. We'll do a pair-debugging session and likely restructure agent.md. Don't push through a week that's obviously broken.

## 8. What "done" looks like

- `phase-1-poc-stack/` ships with agent.md updates from lessons learned
- Voice profile is fleshed out enough to produce on-brand output
- Pricing framework is a real document, not placeholders
- A 1-page POC report exists
- A Go/No-Go decision on CC2 is made

If you hit all 5 PASS gates with a cost under £20 and a time under 120s per run → the product works. Next week we build the platform around it.
