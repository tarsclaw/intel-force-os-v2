Reading prompt from stdin...
OpenAI Codex v0.132.0
--------
workdir: /Users/madsadmin/code/CortexOS
model: gpt-5.5
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: none
reasoning summaries: none
session id: 019e5982-adfd-7f03-9c09-f62166f8c0fe
--------
user
=== TOP-LEVEL CODEX RATIFICATION SKILL ===

# Codex ratification — top-level skill

You are reviewing an Intel Force OS (IFOS) artefact for ratification.

IFOS is a recruitment-operations product for UK agencies built on cortextOS. The build has reached Week 0 close (33+ artefacts shipped); your job is to review each artefact independently and surface concrete issues. Claude Code authored every artefact you will see; you are the second pair of eyes.

**Your output for every artefact MUST start with one of two literal tokens:**

- `RATIFIED` — the artefact is accepted as-is. Optionally followed by minor advisory notes that do not block merge.
- `REJECTED` — the artefact has concrete issues. MUST be followed by a numbered list of issues. Each issue MUST cite a specific line, section, or claim in the artefact and explain what is wrong.

Do not include preamble, throat-clearing, or summary. Do not soften REJECTED to "needs minor improvement". If you find an issue, REJECT and list it. If the artefact passes, RATIFY.

---

## §1 — The five rules (master brief §1)

Every artefact is checked against the five rules in order. **A violation of any one is grounds for REJECTED.**

1. **Output before architecture** — Every agent ships with its output contract written first as a one-paragraph screenshot description. Does this artefact name what it produces before what it is built from? For non-agent artefacts (ADRs, schemas, runbooks): does the artefact name its goal/output before its mechanism?

2. **Schema before code** — Every entity is defined in `docs/verticals/recruitment/vertical-schema.yaml` (or v0.2 supplement) before any agent reads/writes it. Does this artefact assume entities/fields that are not in the schema?

3. **Reuse before build** — `_shared/` helpers (`hook-helpers.sh`, `voice-loader.sh`, `escalation-codes.md`) + `common-*.json` schemas + ESC catalogue exist; new code must reuse, not re-implement. Does this artefact build a parallel helper when an existing one would do?

4. **Quality gates before features** — Gate A (`validate.sh` hard-fails) + Gate B (`decision_log` mandatory writes) + autosend-safety-policy tier dispatch. Does this artefact bypass or weaken any gate?

5. **Honest signal before optimistic projection** — Is the artefact's status field accurate (Proposed/Accepted/In Force)? Are caveats explicit? Are limitations named, not buried?

---

## §2 — The four boundaries (master brief §3)

Boundary violations are immediate REJECT.

1. **Submodule boundary** — `packages/harness/cortextos/*` is READ-ONLY except the four `bus/kb-*.sh` files we shadow via `packages/brain/bus-overrides/`. Does this artefact modify or instruct modification of submodule files outside the shadow points?

2. **Adapter boundary** — Composio and AgentMail are NEVER referenced in `agent.md`, `tools.yaml`, vault files, or fixtures. Does this artefact mention either name in those locations?

3. **Vault/Postgres split** — Markdown content lives in vault (`/vault/<tenant>/`); structured state lives in Postgres (`decision_log`, `entities`, `entity_links`, `voice_corpus`, etc.); pgvector indexes over both. Does this artefact mix the two (e.g., narrative content into Postgres, structured state into markdown)?

4. **Brain-replacement boundary** — Only the four `bus/kb-*.sh` shadow points may interact with cortextOS's brain system. Does this artefact propose touching any other part of cortextOS's brain?

---

## §3 — Honest-signal checks specific to IFOS

These are recurring failure modes Claude Code is prone to. Look for them.

- **Citation accuracy** — section references like "§X.Y" MUST be verifiable. Open the cited file at the cited line/section; does the citation hold? Past violations: a Day-6 audit found 15 fabricated "master brief §10.4 cost target" references; §10.4 is actually the Codex exclusion list.

- **Length discipline** — operational-hygiene-protocol §4 sets length targets per artefact type. Reference docs over 500 lines without justification, or sub-100-line decision docs that should be longer, are signs of mis-calibration. Flag but don't reject on length alone.

- **No defensive additions** — operational-hygiene-protocol §3. Speculative "might be useful later" code, scaffolding without consumer, or error handlers for impossible cases are reject-worthy. Validate at system boundaries only.

- **Dates** — operational-hygiene-protocol §5 + master brief §1 Rule 5. Absolute dates (not relative — "by Friday" is wrong; "by 2026-06-03" is right). Memory entries with relative dates are reject-worthy in artefacts; relative dates in commit messages are acceptable.

---

## §4 — Output contract — exact format

```
RATIFIED
[optional advisory notes; 0-5 lines maximum]
```

OR

```
REJECTED

1. <one-line problem statement>. <2-4 line explanation citing specific lines/sections>. <one-line proposed fix>.

2. <next issue, same shape>

3. <etc.>
```

**Do NOT:**
- Use language like "this artefact is generally well-written but..." — get to the verdict
- Include a "summary" or "conclusion" section after the verdict
- Use Markdown headers (`##`) inside the output — keep it terse
- Repeat the artefact's own content back; reference it by line/section instead

**DO:**
- Quote specific text when citing a problem (`"Line 47: 'every agent...'"`)
- Number issues sequentially
- Propose a concrete fix per issue, not just identify the problem
- Use RATIFIED-with-notes for genuinely minor things that don't block merge (typos, suboptimal wording); use REJECTED for anything load-bearing

---

## §5 — How to invoke the type-specific skill

After this top-level skill loads, the founder will tell you which type-specific skill to apply:

- `review-architecture-decision.md` — for ADRs, decision docs, design docs
- `review-schema-change.md` — for `vertical-schema.yaml` edits
- `review-postgres-migration.md` — for `.sql` files under `migrations/`
- `review-agent-bundle.md` — for new agents under `agents/<vertical>/<name>/`
- `review-mcp-connector.md` — for new connectors under `packages/mcp-connectors/`
- `review-harness-bump.md` — for pinned cortextos SHA changes

The type-specific skill ADDS checks on top of this one. The five rules + four boundaries from this top-level skill always apply.

---

## §6 — When in doubt

If the artefact's purpose is unclear OR you cannot determine whether a rule applies, return REJECTED with a numbered issue asking for clarification. Do not RATIFY by default. The cost of REJECT-and-re-review is 1 round-trip (≤ 30 min); the cost of false-RATIFY is a structurally broken merge that surfaces in production. Bias toward REJECT.

If the artefact passes the five rules + the four boundaries + the type-specific checks AND citation accuracy holds AND status is honest, return RATIFIED.

---

## §7 — Your relationship to Claude Code

Claude Code authored this artefact. Claude tends to:

- Over-elaborate on architecture (long worked examples; multiple alternatives explored when one is enough)
- Soft-pedal limitations (caveats buried at the bottom; optimistic language up top)
- Miss type/build issues (you catch these more reliably)
- Over-defensive code (extra error handlers, scaffolding without consumer)

You tend to:
- Under-weight semantic/specification concerns (Claude catches these more reliably)
- Over-conservative about architecture (Claude pushes for cleaner abstractions sometimes worth taking)

**Disagreements between you and Claude are the most valuable signal.** Write them concretely. The founder will use them as decision-input. Do not hedge.

---

*End of top-level SKILL.md. Apply the relevant type-specific skill next.*

=== TYPE-SPECIFIC SKILL: agent-bundle ===

# Codex ratification skill — review-agent-bundle

Type-specific checks for: agent.md output contracts at `agents/recruitment/<name>/agent.md` and (when present) the surrounding bundle files at `agents/recruitment/<name>/{tools.yaml,context.sh,validate.sh,cycle.sh,cleanup.sh}` + fixtures at `agents/recruitment/<name>/fixtures/*.yaml`.

This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.

**Distinction from review-architecture-decision:** agent.md files are NOT architecture-decision documents. They follow the ADR-003 v2 bundle pattern (6 files + 3 fixtures) and have their own structural requirements documented below. Do NOT REJECT an agent.md for missing Context/Decision/Consequences sections — those belong in ADRs (which live at `docs/decisions/ADR-*.md`).

---

## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)

Every `agents/recruitment/<name>/agent.md` MUST have these 10 sections in order. Reject if any are missing OR materially out of order.

| § | Section title | Purpose | Reject criteria |
|---|---|---|---|
| Header | (file metadata) | Status field; date; author; build wave; tier; build complexity | Missing Status field; status conflicts with content (e.g. "Accepted" but build dependencies still ⏸) |
| §1 | Output contract | One-paragraph screenshot per master brief §1 Rule 1. Names WHAT the agent produces in a single paragraph, readable cold | Missing; >3 paragraphs; doesn't name vault write path; doesn't name Gate A + Gate B thresholds |
| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
| §3 | Output shape | Specific to agent. Diagnostic: 12 sections. Janitor: day-30 report + Bullhorn writes. Cash Conductor: reconciliation rows + chase drafts + weekly report | Missing; doesn't name the artefact paths; doesn't name the decision_log audit-row signature for each output |
| §4 | Workflow | n-step process. Each step must reference (a) the tools.yaml capability it depends on OR (b) a `_shared/` helper. Must integrate `hh_decision_*` calls at every step that produces output OR takes action | Missing; steps reference undocumented capabilities; steps that produce output/action don't call `hh_decision_*` |
| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
| §6 | Escalation codes | Subset of `agents/_shared/escalation-codes.md` relevant to this agent. Each cited code must exist in the catalogue OR be flagged for catalogue addition | Missing; cites invented ESC codes not in catalogue + not flagged for addition; ESC code repurposed beyond catalogue definition |
| §7 | Voice + tone constraints | `_shared/voice-loader.sh` integration; per-tenant scope; voice classifier threshold per agent.md §5 | Missing for agents that produce text output; threshold drift from master brief §8.1 Change 1 |
| §8 | Build dependencies | Prerequisites that must clear before W-X build slice can begin. Table with Status (✅ ⏸ ❌) per dep | Missing; doesn't name Bullhorn / accounting / LinkedIn commercial gates where applicable; doesn't cite Trigger 3 (Bullhorn-touching agents) or D1 (Concierge) where applicable |
| §9 | Status + open questions | Numbered list of founder-review questions; each has a resolution path (founder review at next Sunday OR pilot tenant onboarding OR commercial conversation) | Missing; questions are vague (no resolution path); doesn't acknowledge gotchas from corresponding ULTRAPLAN §8.1 A-N spec |
| §10 | When this document ratifies | Codex skill reference + status-flip criteria (Proposed → Accepted → In Force) | Missing; cites wrong Codex skill; doesn't name the W-X build-slice completion criteria for status-flip |

---

## §2 — Citation accuracy requirements

agent.md files cite extensively. Every cited line/section MUST match the source.

**Required citations:**

1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
3. **agents/_shared/escalation-codes.md** for every cited ESC code. Verify the code exists. Verify the trigger description matches.
4. **autosend-safety-policy.yaml** for tier classifications. Verify the action_type exists in the policy + tier assignment matches.
5. **agents/_shared/voice-loader.sh** for voice-related claims. Verify the helper functions exist.
6. **v1.0-kill-criterion.md Trigger N** references must match the actual trigger definition.
7. **vertical-schema.yaml / v0.2 supplement** for entity-field references.

**Common drift patterns to catch:**

- ESC code reused for a different trigger than its catalogue definition states
- master brief week N cited but row mismatches (e.g. "W5" but the row says W6)
- ULTRAPLAN line-anchor drift (off by ±5 lines after edits)
- Sentinel agent_names invented without registering in the catalogue (e.g. `_consultant_feedback` without an entry in escalation-codes.md or a documented sentinel registry)
- Kill-criterion Trigger references swapped (Trigger 5 cited when content describes Trigger 8 territory)

**Drift between master brief and ULTRAPLAN is the norm, not an error.** Master brief is authoritative per project hierarchy. agent.md should cite BOTH with a "drift flag" note if the build-wave timing differs (e.g. Sourcing Scout: master brief W9 vs ULTRAPLAN A5 W8-9 — note the drift; use master brief).

---

## §3 — Pre-build vs production-ready agent.md

agent.md files come in two flavours per the Diagnostic precedent:

**Pre-build scaffold (Status: Proposed)** — written BEFORE the sibling bundle files exist. The 5 W3-scaffold agents (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) are all pre-build scaffolds. Allowed gaps:

- Sibling bundle files (tools.yaml, context.sh, etc.) may not exist yet — §8 names them in the build-prereq list
- Some prereqs may be ⏸ (e.g. Bullhorn Sub-decisions A+B pending)
- §9 will have many open questions (this is the point — surface them for founder review)
- May cite ESC codes that are documented in catalogue but not yet wired in any agent

REJECT only if:
- §1 output contract is unclear (can't tell what the agent produces)
- §4 workflow has steps citing capabilities that DON'T appear in any tools.yaml — known OR planned
- §6 cites invented ESC codes that don't exist in catalogue AND aren't flagged for addition
- §8 missing prereqs that any reasonable build slice would need
- §10 doesn't name the Codex skill (this skill) for ratification

**Production-ready (Status: Accepted OR In Force)** — written AFTER bundle files exist + pass tests. Diagnostic at Day-13 + Day-19 polish is production-ready. Additional requirements:

- All 5 sibling files exist + pass shellcheck (for .sh files) + typecheck (for .ts files)
- All 3 fixtures exist + pass validate.sh against golden outputs
- §8 prereq list should be mostly ✅ (with explicit notes on any remaining ⏸)
- §10 names the W-X build-slice completion + first-production-run as status-flip criteria

REJECT if:
- §1 contract narrower than any test fixture demonstrates
- §5 Gate A conditions don't match validate.sh implementation
- §6 cites codes not implemented in cycle.sh
- §10 doesn't name the actual first-production-run evidence

---

## §4 — Boundary checks (cross-cutting)

Every agent.md is checked against the four boundaries (master brief §3):

1. **cortextOS submodule** — agent.md must NOT reference files under `packages/harness/cortextos/*`. cortextOS primitives are referenced by index (#1 Persistent PTY, #5 Telegram surface, etc.) NOT by file path.

2. **Composio/AgentMail adapter** — agent.md MUST NOT reference Composio or AgentMail directly. References to v1.1+ AgentMail integration via adapter boundary are allowed when explicitly framed as "deferred".

3. **Vault/Postgres split** — agent.md output contracts: structured per-row state → Postgres (decision_log, recent_edit, voice_corpus); narrative content → vault (Markdown files under `/vault/<tenant>/`). REJECT if §3 output shape mixes these (e.g., proposing to write 12-section Markdown reports to a Postgres column).

4. **Brain-replacement** — agent.md MUST NOT propose direct interaction with cortextOS's stock KB. All knowledge-base interaction goes through the four `bus/kb-*.sh` shadow points OR through the agent's `_shared/voice-loader.sh` helpers.

---

## §5 — Output contract for this skill

Per top-level SKILL.md: your output MUST start with literal `RATIFIED` or `REJECTED`. For agent.md ratification:

**RATIFY** when:
- All 10 sections present (§ Header + §1-§10)
- §1 output contract is single-paragraph + names artefact path
- All citations verified against source files (master brief / ULTRAPLAN / escalation-codes / vertical-schema)
- No invented ESC codes / no invented sentinels
- Four boundary checks pass
- Status field consistent with content
- For pre-build: ESC code references either exist in catalogue OR are flagged for catalogue addition

**REJECT** when:
- Sections missing OR materially out of order
- Citation drift (cited line doesn't contain claimed content)
- Invented codes/sentinels/payload fields without catalogue registration
- Output contract doesn't name vault path OR Gate A/B thresholds
- §4 workflow steps missing `hh_decision_*` calls at output/action points
- Boundary violation (submodule modification, Composio/AgentMail in body, vault/Postgres mix, KB direct access)
- Gate A weaker than §1 output contract claims

**Advisory notes (allowed under RATIFIED):**
- "§9 question 3 is vague — suggest tightening before founder review"
- "ESC code list omits ESC_RATE_LIMIT_HIT which Step N implies — suggest adding"
- "§8 prereq list missing the voice classifier microservice as W4-5 dependency"

Advisory notes do NOT block ratification — they're suggestions for the author. Use sparingly; if 5+ advisory notes accumulate, REJECT instead and require a remediation pass.

---

## §6 — Special case: Diagnostic agent.md

Diagnostic was scaffold-ratified at Day-11 (Round 3 RATIFIED) + production-shape polished at Day-13 (commits `97a57a2` + `2688b6a`) + Day-19 remediation (commit `6e0cb86`). Codex Round 4 Phase 1 hit hard ceiling — see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` for the 5-issue disposition.

When re-ratifying Diagnostic agent.md with THIS skill (not review-architecture-decision):

- Issue 5 from the disagreement doc (missing Context/Decision/Consequences sections) is **REJECTED RECONSIDERED** — this skill explicitly does NOT require those sections for agent.md files. The Round-5 REJECTED on this basis was caused by Codex applying the wrong skill (review-architecture-decision was used instead of this one).
- Issues 1-4 from the disagreement doc may still apply when re-evaluated under this skill — verify each per §1-§4 above.
- If Issues 1-4 resolve via the founder arbitration recommendations in the disagreement doc (which I'd accept as the right framing for v0), then Diagnostic agent.md should RATIFY under this skill.

---

*End of review-agent-bundle skill.*

=== ARTEFACT UNDER REVIEW ===

Path: agents/recruitment/cash-conductor/agent.md

--- BEGIN ARTEFACT ---

# Cash Conductor — the FD's evenings back

**Status:** Proposed (Day-18 pre-W7-8-build scaffold; awaits Q1 LOI + accounting + Open Banking commercial signups + W7 build slice OR earlier-pull-forward per ADR-005 if Bullhorn delays persist).
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 541.
**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 539). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 539 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 540) — the FD-tier closer metric. Chase drafts are orange-tier per `autosend-safety-policy.yaml` (consultant approval required before send via Concierge); reconciliation writes are yellow-tier.

---

## §2 — Invocation surface

### Webhook (v1.0 primary path)

```http
POST https://<tenant>.ifos.app/agents/cash-conductor/webhook
Authorization: Bearer <provider-shared-secret>
Content-Type: application/json

# Event types (per provider):
# - Xero/QuickBooks/Sage: invoice.created, invoice.sent, invoice.viewed,
#   invoice.paid, payment.received
# - Open Banking (TrueLayer/Plaid UK): transaction.posted, balance.updated
```

Per-provider webhook auth handled in `tools.yaml`.

### Cron (daily reconciliation sweep)

```bash
# 07:00 UTC daily — bank feed catch-up + invoice age scan
0 7 * * * sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode daily-sweep
```

### Weekly report cron

```bash
# Monday 06:00 UTC — cash-flow report regeneration
0 6 * * 1 sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode weekly-report
```

### Manual triggers (v1.0)

```bash
ifosctl cash-conductor reconcile --tenant <slug> [--invoice <id>]
ifosctl cash-conductor draft-chase --tenant <slug> --invoice <id>
ifosctl cash-conductor weekly-report --tenant <slug>
```

### v1.1+ surfaces (deferred)

- Brain UI cash-flow dashboard
- Per-tenant Telegram daily summary
- FD-mode end-of-month report (more detailed than weekly)

---

## §3 — Output shape

Three outputs. All load-bearing.

### Output 1 — Reconciliation rows (yellow tier)

Per webhook event, Cash Conductor reconciles incoming bank deposits against the tenant's open invoice register. Match algorithm:

| Stage | Match dimensions | Confidence |
|---|---|---|
| 1 | Exact amount + matching invoice reference in transaction memo | 0.98 |
| 2 | Exact amount + matching payee name | 0.85 |
| 3 | Exact amount + within-90-day-of-invoice-issue window | 0.70 |
| 4 | Fuzzy amount (±0.5% rounding) + matching payee name | 0.65 |
| 5 | Unmatched (queued for review) | <0.50 |

Stages 1-2 auto-write reconciliation to accounting system (yellow tier; spot-check sampled). Stages 3-4 queue for consultant review. Stage 5 flagged in weekly report.

Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.

### Output 2 — Payment-chase drafts (orange tier)

For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. Output is a queued draft, NOT a send. Drafts route to Concierge (which handles the actual send pipeline + consultant approval per autosend §4 orange tier).

Chase draft structure:

```yaml
draft_id: <uuid>
invoice_id: <accounting-system-invoice-id>
contact_email: <client-billing-contact-email>
subject: "Friendly reminder — invoice <number> from <YYYY-MM-DD>"
body_markdown: <voice-classified consultant-tone reminder>
amount_due: <decimal>
days_overdue: <int>
prior_chases_sent: <int>
escalation_ladder_position: 1-4 per §3.2 below
expected_send_window: orange-tier approval expected within 24h
```

Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='chase_draft'`, `tier='orange'`, payload includes the draft.

### §3.2 — Chase escalation ladder

| Position | Trigger | Tone | Voice classifier minimum |
|---|---|---|---|
| 1 | 7 days overdue | "Friendly reminder, hope everything's OK on your end" | ≥0.75 |
| 2 | 14 days overdue, position-1 sent | "Following up — please let us know if there's a query" | ≥0.75 |
| 3 | 21 days overdue, position-2 sent | "Need to flag this; can we schedule a quick call?" | ≥0.80 (higher bar) |
| 4 | 30 days overdue, position-3 sent | "Escalation to operator review" — drafts STOP; operator manual handle | n/a (not sent) |

Position 4 is the kill-switch: Cash Conductor never auto-drafts beyond position 3. Operator decides next step manually.

### Output 3 — Weekly cash-flow Markdown report

Located at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md`. Generated Monday 06:00 UTC. Six sections:

| # | Section | Content |
|---|---|---|
| 1 | **Week summary** | Receipts received + invoices issued + invoices paid + new chases sent |
| 2 | **DSO trend** | Days-Sales-Outstanding metric this week vs prior-week vs month-0 baseline; Gate B tracking |
| 3 | **Aged debtors** | Invoices outstanding bucketed (0-30 / 31-60 / 61-90 / 90+ days); per-client totals |
| 4 | **Chase pipeline** | Active chase drafts by position 1-3; pending consultant approval; sent-but-no-response |
| 5 | **Cash-flow forecast** | 4-week forward cash projection (open invoices + expected payments per historical conversion rate) |
| 6 | **Exception list** | Reconciliation failures; bank-feed gaps; accounting-API failures; operator action items |

---

## §4 — Workflow

14 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.

```
0. Session start (webhook OR cron OR manual)
   → context.sh hydrates: tenant config + accounting-provider auth +
     Open Banking auth + voice corpus + tone rules
   → hh_decision_trigger("session_start", "<webhook|cron|manual>")

1. Provider auth refresh
   → accounting: Xero/QuickBooks/Sage OAuth refresh per provider
   → Open Banking: TrueLayer/Plaid UK 90-day token refresh (CRITICAL —
     gotcha §6.1 of ULTRAPLAN A4 line 542); if <30 days until expiry,
     fire ESC_OPEN_BANKING_TOKEN_AGING (operator must re-authorise)
   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on failure

2. Event router (mode-dependent)
   → if mode=webhook: parse event_type → routes to Step 3-7 path
   → if mode=daily-sweep: skip to Step 8 (catch-up reconciliation)
   → if mode=weekly-report: skip to Step 13

3. Bank transaction ingest (mode=webhook from Open Banking)
   → fetch latest transactions since last_ingested_at
   → normalise schema (TrueLayer vs Plaid have different formats)
   → store in /vault/<tenant>/cash-conductor-cache/transactions.jsonl
     (90-day rolling; chmod 0600; LUKS-encrypted)

4. Invoice register ingest (mode=webhook from accounting OR daily-sweep)
   → accounting.list_open_invoices() per provider
   → store in /vault/<tenant>/cash-conductor-cache/invoices.jsonl

5. Reconciliation pass (5-stage match algorithm per §3 Output 1)
   → for each transaction × open invoice: compute match confidence
   → write Stage 1-2 matches to accounting (yellow tier) atomically
   → queue Stage 3-4 matches for consultant review
   → flag Stage 5 (unmatched) in weekly-report exception list

6. Reconciliation write (yellow tier; per match)
   → accounting.write_payment_received(invoice_id, payment_id, amount, date)
   → atomic transaction; rollback on 4xx/5xx
   → ESC_ACCOUNTING_WRITE_FAIL on failure
   → spot-check sampling per autosend-safety-policy.yaml yellow tier

7. Chase generation pass (for overdue, unmatched invoices)
   → query open invoices with age >7 days AND no Stage-1/2 reconciliation
   → for each, determine chase position 1-4 based on age + prior chases
     sent (counted from decision_log decision_log.payload.position)
   → if position=4: STOP — operator review (no auto-draft)
   → else: proceed to Step 8

8. LLM chase-draft generation (per overdue invoice)
   → prompt = (invoice details + client context + position-N tone +
     voice corpus + tone rules)
   → output = email body + subject
   → voice classifier scores against tenant style (≥0.75 for position 1-2;
     ≥0.80 for position 3 per §3.2)
   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries

9. Chase-draft validation (Gate A specifics)
   → verify: invoice_number cited matches invoice_id
   → verify: amount_due cited matches accounting record
   → verify: client_contact_email matches active billing contact
   → verify: NOT paid in last 24h (re-query accounting)
   → ESC_SCHEMA_VIOLATION on any miss
   → ESC_AUTOSEND_BLOCKED if chase proposed for paid invoice (defence-in-depth)

10. Chase-draft queue to Concierge (orange tier)
    → POST internal API → Concierge agent receives draft
    → Concierge handles autosend-bridge call to operator (D1 path per
      Founder Decision)
    → hh_decision_output("chase_draft", invoice_id, payload_preview);
      tier=orange; awaiting operator approval

11. (Operator approves via Concierge → Concierge sends → Cash Conductor
    records send event)
    → Concierge fires webhook back: chase_sent
    → Cash Conductor updates internal state: prior_chases_sent counter

12. (Mode=webhook only) Re-trigger eligibility check
    → was this webhook also a "payment received" that just hit?
    → re-run Step 5 to check if any chases-in-flight should be cancelled
      (paid-since-draft-but-before-send race condition)
    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)

13. Weekly report assembly (mode=weekly-report; runs Monday 06:00 UTC)
    → query decision_log + accounting + bank feed for the 7-day window
    → compute DSO metric (Gate B tracking)
    → 6-section Markdown report per §3 Output 3
    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
    → hh_decision_output("weekly_report", report_path)

14. Session close
    → update tenant_adapters.config.cash_conductor_last_run = now()
    → hh_decision_action("cash_conductor_run_complete", session_id,
      run_mode, payload_hash, payload_preview)
    → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 539 verbatim):

- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
- Voice classifier score ≥0.75 for position 1-2 chases; ≥0.80 for position 3
- No PII outside firm boundary in chase body
- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
- Open Banking token >30 days from expiry (otherwise warn)
- Accounting auth refresh succeeded in Step 1

Gate A failures fire `ESC_SCHEMA_VIOLATION` or `ESC_AUTOSEND_BLOCKED`; draft stays in `/tmp` (auto-purged 24h); operator notified.

### Gate B — Outcome threshold (FD-tier closer metric)

Per ULTRAPLAN A4 line 540 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.

DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.

Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.

This is THE FD-tier closer metric per master brief §8.2 line 597. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).

---

## §6 — Escalation codes

Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking token <30 days from 90-day expiry | warn (info if <60 days; warn if <30; blocking if <7) | operator_chat_id → ifos_oncall as expiry nears |
| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 3-4 match queued for review | info | (logged; aggregated to weekly report exception list) |
| `ESC_AUTOSEND_BLOCKED` | Chase proposed for paid invoice OR race condition detected | **blocking** | operator + ifos_oncall |
| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
| `ESC_VOICE_DRIFT_TENANT` | Consultant edit-rate on chase drafts >50% in 30-day window | warn | operator + tenant-admin |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
| `ESC_SCHEMA_VIOLATION` | Gate A miss (invoice/amount/contact validation) | **blocking** | operator + ifos_oncall |
| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval >24h | info | (logged; weekly report) |

Cash Conductor does NOT use Bullhorn-specific codes (no Bullhorn dependency).

---

## §7 — Voice + tone constraints

Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
  - No "Final demand" or legal-threatening language (escalation ladder caps at position 3; position 4 is operator-handled)
  - No reference to the client's industry / sector pain points (chase is operational, not strategic)
  - No mentions of late-payment fees unless tenant's terms explicitly state them
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Edit-distance >150 chars on >40% of chase recent_edits fires `ESC_VOICE_DRIFT_TENANT`.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W7-8 prerequisites OR earlier per ADR-005 pull-forward)

Cash Conductor build cannot start until ALL of the following are confirmed:

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
| **Accounting commercial signup** (developer access + sandbox) | Founder commercial | ⏸ |
| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
| Xero MCP connector | W7 build start (~2 days) | ⏸ |
| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
| Per-tenant accounting credentials in `_secrets.env` | Tenant onboarding | ⏸ |
| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
| Concierge agent in production (for chase-send routing) | W10-13 build | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |

**Per ADR-005 §5.1 pull-forward provision:** if Bullhorn Sub-decisions A+B answers delay past 2026-06-10, Cash Conductor may be pulled forward from W7-8 to W4-5 because it has zero Bullhorn dependency. The other prerequisites (accounting + Open Banking commercial signups) remain founder-action gates regardless.

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start (or earlier per ADR-005 pull-forward).

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
| Q4 | Chase escalation ladder — 4 positions proposed in §3.2. Founder confidence each position's timing + tone is right? | Founder review with first pilot tenant; varies by tenant's payment terms (net-30 vs net-14 vs net-60). |
| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |

### Gotchas (carried forward from ULTRAPLAN A4 line 542)

1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

Status flips Proposed → Accepted when:
- Codex Round 4 Phase 2 ratifies
- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
- Q3 UX flow approved (operator re-auth path)

Status flips Accepted → In Force when:
- W7-8 build slice produces all 5 sibling bundle files + 3 fixtures
- First production webhook processed end-to-end against migration-test tenant
- 30-day month-0 baseline measured for first pilot
- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
- Codex re-ratifies post-build via `review-agent-bundle.md` skill

Until then: this document is a forward-looking scaffold.

*End of Cash Conductor agent.md draft.*

--- END ARTEFACT ---

=== YOUR TASK ===

Apply the top-level SKILL.md plus the type-specific skill above to the artefact.

Return EXACTLY ONE of:

  RATIFIED
  [optional 0-5 lines of advisory notes]

OR

  REJECTED

  1. <one-line problem statement>. <2-4 line explanation citing specific lines/sections>. <one-line proposed fix>.

  2. <next issue, same shape>

  ...

Do not include preamble, throat-clearing, or summary. Begin your response with the literal word RATIFIED or REJECTED.

codex
I’ll verify the cited source lines and shared catalogues first, then check the agent-bundle structure and boundary rules against the artefact.
exec
/bin/zsh -lc 'rg -n "ESC_ACCOUNTING_AUTH|ESC_ACCOUNTING_WRITE_FAIL|ESC_OPEN_BANKING_AUTH|ESC_OPEN_BANKING_TOKEN_AGING|ESC_RECONCILIATION_AMBIGUOUS|ESC_AUTOSEND_BLOCKED|ESC_AUTOSEND_RACE|ESC_VOICE_DRIFT|ESC_VOICE_DRIFT_TENANT|ESC_PII_LEAKAGE_RISK|ESC_SCHEMA_VIOLATION|ESC_GATE_B_MISS|ESC_RATE_LIMIT_HIT|ESC_AUTOSEND_ORANGE_PENDING" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
41:#### `ESC_AUTOSEND_BLOCKED`
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time

exec
/bin/zsh -lc "rg -n \"hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|hh_decision_|decision_log|tenant_adapters|recent_edit|voice_corpus|reconciliation_write|chase_draft\" agents docs packages -g '"'!*node_modules*'"'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"Cash Conductor|A4|W7|Hire #1|DSO|paid in last 24|90-day|autosend|Tier\" docs agents packages -g '"'!*node_modules*'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:5:# hh_decision_action() invocation. Per-tenant overrides live in Postgres
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:19:# Schema version stamps decision_log.payload.policy_version_sha at write time.
agents/_shared/autosend-policy.yaml:229:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:240:# Defaults applied when override fields are absent in tenant_adapters
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:18:phase             — one of {trigger, output, action, gating_failed, agent_handoff}; per decision_log CHECK constraint at Day-4 §6.3
agents/_shared/escalation-codes.md:115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
agents/_shared/escalation-codes.md:254:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:255:        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:352:    target: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:33:| 11 | **Tenant-context guard failure due transactionless `SET LOCAL` usage** — scripts and helpers used `SET LOCAL ifos.tenant_slug` in psql heredocs/strings without visible `BEGIN/COMMIT`. If PostgreSQL treats the setting as transaction-local with no active transaction, RLS-protected reads/writes can return zero rows, fail audit inserts, or silently fall back to JSONL. | ~~High~~ → Low post-remediation | High | Any psql call with `SET LOCAL` not bracketed by `BEGIN/COMMIT`, or a successful operation whose decision_log row falls back because RLS rejected the insert. | Round-2 remediation Fix 3-5 wraps every `SET LOCAL` psql call in a transaction. Verified by shellcheck + 29 helper tests + Round 3. | **Mitigated in this commit; Round-3 verified.** |
docs/RISK-REGISTER.md:34:| 12 | **PII purge remediation cannot execute against current schema** — `v0.2-to-v0.3-pii-purge.sql` adds `text_purged_at` and a CHECK requiring text fields to be NULL after purge, but v0.2 declares `recent_edit.original_text TEXT NOT NULL`; the purge script sets `original_text=NULL`. | ~~High~~ → Low post-remediation | ~~High~~ → Low for cron execution; legal posture still depends on D2/D3 | `v0.2-to-v0.3-pii-purge.sql` executed without `ALTER COLUMN original_text DROP NOT NULL`. | Round-2 remediation Fix 2 adds `ALTER COLUMN DROP NOT NULL` before the CHECK constraint. Verified by Round 3. | **Mitigated in this commit; remains pending D2/D3 founder decisions before production deployment.** |
docs/RISK-REGISTER.md:55:- 2026-05-22 (Day 11) — **Codex Round 2 autonomous ratification complete.** 26 artefacts reviewed; 17 RATIFIED / 9 REJECTED. Manifest §1.7 appended and full outputs written to `logs/codex-ratification/round-2-autonomous/`. D5 skill softening ratified. Bullhorn gate disagreement rejected because the promised source-doc sharpening did not land. Autosend policy, v0.2 supplement, approval bridge, PII purge runbook/script/forward migration, and tenancy audit script remain rejected. **New Risk #11** added for transactionless `SET LOCAL` usage across live DB scripts/helpers. **New Risk #12** added for the PII purge migration/script mismatch with `recent_edit.original_text NOT NULL`.
docs/RISK-REGISTER.md:56:- 2026-05-22 (Day 11 evening) — **Codex Round-2 remediation applied + Round 3 verified.** Fixes wrap all identified `SET LOCAL` calls in explicit transactions and make `recent_edit.original_text` nullable before PII purge; Risks #11 and #12 moved to mitigated. Founder-domain D1/D2/D3 remain open and are explicitly annotated in the affected artefacts.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:66:- 2026-05-20 (Day 8 evening) — **Codex ratification Round 1 complete + remediation landed.** 16 artefacts reviewed (Cluster A+B+C); 2 RATIFIED (ADR-004, brain-ui-scope); 14 REJECTED. Remediation commit `2b287d3` incorporates 13 of 14 rejections (Bucket 1 cosmetic + Bucket 2 ADR-004 back-propagation + Bucket 3 structural). 2 disagreement docs filed (`codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` + `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`). 5 founder decisions surfaced (D1-D5 in `2026-05-20-codex-round-1-founder-decisions.md`). **NEW Risk #10 candidate surfaced by Codex** (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation) — see Risk #10 below. Manifest queue updated with per-artefact Round-1 verdicts (`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5). Round 2 expected to take 14 REJECTED → 0-2 REJECTED.
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:171:hh_decision_trigger     # Called at start of agent run; logs the trigger
docs/specs/ULTRAPLAN.md:172:hh_decision_output      # Called when agent produces output; logs the artefact
docs/specs/ULTRAPLAN.md:173:hh_decision_action      # Called when human acts on output; logs the action
docs/specs/ULTRAPLAN.md:227:- Three relevant tables: `tenants`, `entity_graph`, `decision_log`.
docs/specs/ULTRAPLAN.md:228:- Both `entity_graph` and `decision_log` partitioned by `tenant_id` (hash partitioning, 32 partitions to start).
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:66:### §0.3 — `decision_log.phase` enum: 5 values, not more
docs/runbooks/day-4-provisioning.md:749:-- decision_log (per ADR-002 §3 Decision 3; phase enum per §6.4 below = Tightening 3)
docs/runbooks/day-4-provisioning.md:750:CREATE TABLE decision_log (
docs/runbooks/day-4-provisioning.md:761:CREATE INDEX decision_log_tenant_agent_idx
docs/runbooks/day-4-provisioning.md:762:  ON decision_log (tenant_slug, agent_name, created_at DESC);
docs/runbooks/day-4-provisioning.md:764:GRANT SELECT, INSERT ON decision_log TO ifos_app;
docs/runbooks/day-4-provisioning.md:765:GRANT USAGE, SELECT ON SEQUENCE decision_log_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:784:CREATE TABLE tenant_adapters (
docs/runbooks/day-4-provisioning.md:795:GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_adapters TO ifos_app;
docs/runbooks/day-4-provisioning.md:796:GRANT USAGE, SELECT ON SEQUENCE tenant_adapters_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:804:### §6.4 — Tightening 3: `decision_log.phase` enum constraint
docs/runbooks/day-4-provisioning.md:810:ALTER TABLE decision_log
docs/runbooks/day-4-provisioning.md:811:ADD CONSTRAINT decision_log_phase_check
docs/runbooks/day-4-provisioning.md:823:WHERE conrelid = 'decision_log'::regclass AND contype = 'c';
docs/runbooks/day-4-provisioning.md:906:\d decision_log
docs/runbooks/day-4-provisioning.md:908:\d tenant_adapters
docs/runbooks/day-4-provisioning.md:915:# - decision_log has the phase CHECK constraint     (Tightening 3)
docs/runbooks/day-4-provisioning.md:934:ALTER TABLE decision_log ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:936:ALTER TABLE tenant_adapters ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:941:ALTER TABLE decision_log FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:943:ALTER TABLE tenant_adapters FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:961:CREATE POLICY tenant_isolation ON decision_log
docs/runbooks/day-4-provisioning.md:971:CREATE POLICY tenant_isolation ON tenant_adapters
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1130:- [ ] §6.4 (Tightening 3) — `decision_log_phase_check` constraint present with exactly 5 values
docs/runbooks/day-4-provisioning.md:1156:| §6.4 constraint | CHECK constraint fails to add | `ALTER TABLE decision_log DROP CONSTRAINT decision_log_phase_check;` then retry — most common cause is pre-existing rows violating the check, but the table is empty at this point so unusual |
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:28:DROP TABLE IF EXISTS voice_corpus_chunks  CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:29:DROP TABLE IF EXISTS voice_corpus         CASCADE;
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:10:# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
agents/_shared/hook-helpers.sh:19:# Side-effects: appends to decision_log table OR fallback JSONL; never reads
agents/_shared/hook-helpers.sh:102:# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
agents/_shared/hook-helpers.sh:121:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:166:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:168:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:180:hh_decision_output() {
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:193:hh_decision_action() {
agents/_shared/hook-helpers.sh:203:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:211:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:220:      autosend_emit_decision_log "action" "green" "${action_type}" \
agents/_shared/hook-helpers.sh:225:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
agents/_shared/hook-helpers.sh:234:      autosend_emit_decision_log "action" "orange" "${action_type}" \
agents/_shared/hook-helpers.sh:242:      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
agents/_shared/hook-helpers.sh:249:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:330:# Emits the standard autosend decision_log row with payload.tier set.
agents/_shared/hook-helpers.sh:331:autosend_emit_decision_log() {
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:137:# Runs pgvector ANN against voice_corpus_chunks for the active voice_corpus
agents/_shared/voice-loader.sh:149:#     "voice_corpus_version": "v0.2-seed",
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:161:    # Live mode: run HNSW ANN query against active voice_corpus
agents/_shared/voice-loader.sh:164:         FROM voice_corpus_chunks vcc
agents/_shared/voice-loader.sh:165:         JOIN voice_corpus vc ON vc.id = vcc.voice_corpus_id
agents/_shared/voice-loader.sh:172:    version="$(_vl_psql_query "SELECT version FROM voice_corpus WHERE is_active = TRUE LIMIT 1;")"
agents/_shared/voice-loader.sh:180:    printf '{"samples":[],"voice_corpus_version":"fallback","source":"fallback","style_guide_path":"%s","task_context":"%s","reason":"%s"}\n' \
agents/_shared/voice-loader.sh:186:  printf '{"samples":[],"voice_corpus_version":"empty","source":"empty","task_context":"%s","reason":"no_db_no_style_guide"}\n' \
agents/_shared/voice-loader.sh:198:    printf '{"samples":[],"voice_corpus_version":"%s","source":"%s","task_context":"%s","count":0}\n' \
agents/_shared/voice-loader.sh:216:  printf '],"voice_corpus_version":"%s","source":"%s","task_context":"%s"}\n' \
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:225:# Returns recent_edit rows from the last <lookback_days> for <agent_name>
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/voice-loader.sh:246:           FROM recent_edit
agents/_shared/voice-loader.sh:253:           FROM recent_edit
agents/_shared/voice-loader.sh:260:    _vl_render_recent_edits_json "${rows}" "${lookback_days}"
agents/_shared/voice-loader.sh:268:_vl_render_recent_edits_json() {
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:24:`hook-helpers.sh` writes to `decision_log` via two paths:
agents/_shared/README.md:44:| `HH_POLICY_VERSION_SHA` | no | Git SHA stamped into `decision_log.payload.policy_version_sha` per §7 | `unknown` |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:51:hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/README.md:52:hh_decision_output  <output_type> <artefact_ref> [<reason>]
agents/_shared/README.md:53:hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/README.md:56:`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:72:`hh_decision_action` dispatches per tier:
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:120:   bash -c 'source agents/_shared/hook-helpers.sh; hh_decision_trigger "manual_smoke_test"'
agents/_shared/README.md:122:3. Founder verifies via `psql` that one new row landed in `decision_log` with `phase='trigger'` + `tenant_slug='migration-test'`.
agents/_shared/README.md:125:   SELECT count(*) FROM decision_log
agents/_shared/README.md:144:   - 4 new tables (`voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`)
agents/_shared/README.md:145:   - `voice_samples_embedded` HNSW index on `voice_corpus_chunks.embedding`
agents/_shared/README.md:147:   - 1 seed row in `voice_corpus` for `migration-test` with `version='v0.2-seed'`, `is_active=TRUE`
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
docs/operations/codex-ratification-guide.md:54:The wrapper at `scripts/run-codex-ratification.sh` automates this: assembles the prompt, invokes `codex exec` non-interactively, captures output, parses the verdict, writes an audit row to `decision_log`.
docs/operations/codex-ratification-guide.md:154:5. **Audit row write** — inserts a row into `decision_log` with `tenant_slug='ifos-meta'`, `agent_name='_codex_ratifier'`, `phase='output'`, `outcome=<RATIFIED|REJECTED>`, `payload` includes the artefact path, skill used, issue count, session ID, and the full Codex response text. Falls back to `logs/codex-ratification.jsonl` if no live DB.
docs/operations/codex-ratification-guide.md:163:  ✓ decision_log row appended to fallback (logs/codex-ratification.jsonl)
docs/operations/codex-ratification-guide.md:190:  ✓ decision_log row appended to fallback
docs/operations/codex-ratification-guide.md:379:Every Codex review writes a row to `decision_log`:
docs/operations/codex-ratification-guide.md:389:FROM decision_log
docs/operations/codex-ratification-guide.md:419:FROM decision_log
docs/operations/codex-ratification-guide.md:513:- **16+ audit rows** in `decision_log` under `agent_name='_codex_ratifier'`
docs/operations/codex-ratification-guide.md:554:psql -c "SELECT created_at, payload->>'artefact_path', outcome FROM decision_log WHERE agent_name='_codex_ratifier' ORDER BY created_at DESC LIMIT 20;"
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
docs/specs/_archive-build-handoff.md:431:- **Decision logging is required** (Ultraplan §4.2 change 2). Every agent run writes three log entries via `hh_decision_trigger`, `hh_decision_output`, `hh_decision_action`. Missing calls = hard fail in validate.sh. This is what enables the per-tenant LoRA pipeline at v2.0.
agents/_shared/tests/test-hook-helpers.sh:95:printf '\n[1] hh_decision_trigger writes a phase=trigger row\n'
agents/_shared/tests/test-hook-helpers.sh:98:  hh_decision_trigger "session_start" "boot"
agents/_shared/tests/test-hook-helpers.sh:106:printf '\n[2] hh_decision_output writes a phase=output row\n'
agents/_shared/tests/test-hook-helpers.sh:109:  hh_decision_output "diagnostic_report" "/vault/x/y.md"
agents/_shared/tests/test-hook-helpers.sh:129:printf '\n[4] hh_decision_action — green tier emits action row, rc=0\n'
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:142:printf '\n[5] hh_decision_action — red tier emits gating_failed row, rc=1\n'
agents/_shared/tests/test-hook-helpers.sh:145:  hh_decision_action "xero_payment_initiate" "invoice:42" "def456" "test"
agents/_shared/tests/test-hook-helpers.sh:156:printf '\n[6] hh_decision_action — orange tier with test-mode approve → rc=0\n'
agents/_shared/tests/test-hook-helpers.sh:159:  HH_AWAIT_TEST_MODE=approve hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash1" "preview"
agents/_shared/tests/test-hook-helpers.sh:170:printf '\n[7] hh_decision_action — orange tier with test-mode reject → rc=1\n'
agents/_shared/tests/test-hook-helpers.sh:173:  HH_AWAIT_TEST_MODE=reject hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash2" "preview"
agents/_shared/tests/test-hook-helpers.sh:179:printf '\n[8] hh_decision_action — unknown action_type → ESC_AUTOSEND_POLICY_LOOKUP_FAILED\n'
agents/_shared/tests/test-hook-helpers.sh:182:  hh_decision_action "nonexistent_action" "x" "hash3" "preview"
agents/_shared/tests/test-hook-helpers.sh:270:printf '\n[15] hh_decision_action — yellow tier emits row + may enqueue spot-check\n'
agents/_shared/tests/test-hook-helpers.sh:273:  hh_decision_action "bullhorn_candidate_dedupe" "candidate:foo" "hash9" "preview"
agents/_shared/tests/test-hook-helpers.sh:286:  # (a) the autosend_emit_decision_log audit row with payload.tier='red'
agents/_shared/tests/test-hook-helpers.sh:293:    hh_decision_action "xero_payment_initiate" "invoice:${i}" "hashred${i}" "amount: £100"
agents/_shared/tests/test-voice-loader.sh:70:printf '\n[1] hh_load_tone_rules returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:73:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:78:printf '\n[2] hh_load_tone_rules reads tone-rules.yaml fallback path\n'
agents/_shared/tests/test-voice-loader.sh:86:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:91:printf '\n[3] hh_load_voice_samples returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:94:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:99:printf '\n[4] hh_load_voice_samples surfaces style guide when present\n'
agents/_shared/tests/test-voice-loader.sh:103:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:110:printf '\n[5] hh_load_voice_samples top_k validation clamps to 10\n'
agents/_shared/tests/test-voice-loader.sh:113:  out=$(hh_load_voice_samples "task" "abc")  # non-numeric → 10
agents/_shared/tests/test-voice-loader.sh:115:  out=$(hh_load_voice_samples "task" "999")  # over cap → 10
agents/_shared/tests/test-voice-loader.sh:117:  out=$(hh_load_voice_samples "task" "0")    # zero → 10
agents/_shared/tests/test-voice-loader.sh:122:printf '\n[6] hh_load_recent_edits returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:123:test_recent_edits_no_db() {
agents/_shared/tests/test-voice-loader.sh:125:  out=$(hh_load_recent_edits)
agents/_shared/tests/test-voice-loader.sh:130:_test_run "recent_edits fallback: empty array + default 30 days" test_recent_edits_no_db
agents/_shared/tests/test-voice-loader.sh:132:printf '\n[7] hh_load_recent_edits accepts custom lookback_days\n'
agents/_shared/tests/test-voice-loader.sh:133:test_recent_edits_custom_lookback() {
agents/_shared/tests/test-voice-loader.sh:135:  out=$(hh_load_recent_edits 7 "concierge")
agents/_shared/tests/test-voice-loader.sh:139:_test_run "recent_edits accepts 7-day lookback + agent_name" test_recent_edits_custom_lookback
agents/_shared/tests/test-voice-loader.sh:141:printf '\n[8] hh_load_recent_edits lookback_days validation clamps to 30\n'
agents/_shared/tests/test-voice-loader.sh:142:test_recent_edits_invalid_lookback() {
agents/_shared/tests/test-voice-loader.sh:144:  out=$(hh_load_recent_edits "abc")  # non-numeric → 30
agents/_shared/tests/test-voice-loader.sh:146:  out=$(hh_load_recent_edits "999")   # over cap → 30
agents/_shared/tests/test-voice-loader.sh:148:  out=$(hh_load_recent_edits "0")     # zero → 30
agents/_shared/tests/test-voice-loader.sh:151:_test_run "recent_edits lookback validation: non-numeric/over-cap/zero clamp to 30" test_recent_edits_invalid_lookback
agents/_shared/tests/test-voice-loader.sh:156:  out1=$(hh_load_tone_rules | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:157:  out2=$(hh_load_voice_samples "task" | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:158:  out3=$(hh_load_recent_edits | wc -l | tr -d ' ')
docs/operations/codex-round-2-handoff.md:148:**Per-artefact output:** `logs/codex-ratification/<session-id>/<slug>.output.md` + audit row to `decision_log` (live mode) OR `logs/codex-ratification.jsonl` (fallback).
docs/operations/codex-round-2-handoff.md:268:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
docs/operations/codex-round-2-handoff.md:351:- **`decision_log`** has audit rows for every Round-2 review
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:11:--   - 1 auxiliary table: voice_corpus_chunks (holds the pgvector index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:43:-- §2 — Create voice_corpus table (per-tenant voice pack)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:46:CREATE TABLE IF NOT EXISTS voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:59:  CONSTRAINT voice_corpus_tenant_version_unique UNIQUE (tenant_slug, version)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:62:-- Partial unique index: at most one active voice_corpus per tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:63:CREATE UNIQUE INDEX IF NOT EXISTS voice_corpus_one_active_per_tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:64:  ON voice_corpus (tenant_slug)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:67:CREATE INDEX IF NOT EXISTS voice_corpus_tenant_slug_idx ON voice_corpus (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:69:ALTER TABLE voice_corpus ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:70:ALTER TABLE voice_corpus FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:71:DROP POLICY IF EXISTS voice_corpus_tenant_isolation ON voice_corpus;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:72:CREATE POLICY voice_corpus_tenant_isolation ON voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:76:-- §3 — Create voice_corpus_chunks table (pgvector substrate)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:78:-- One row per chunk produced from voice_corpus source docs. Embedding column
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:82:CREATE TABLE IF NOT EXISTS voice_corpus_chunks (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:85:  voice_corpus_id   BIGINT      NOT NULL REFERENCES voice_corpus (id) ON DELETE CASCADE,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:91:  CONSTRAINT voice_corpus_chunks_corpus_chunk_unique UNIQUE (voice_corpus_id, chunk_index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:94:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_tenant_idx ON voice_corpus_chunks (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:95:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_corpus_idx ON voice_corpus_chunks (voice_corpus_id);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:99:  ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:103:ALTER TABLE voice_corpus_chunks ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:104:ALTER TABLE voice_corpus_chunks FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:105:DROP POLICY IF EXISTS voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:106:CREATE POLICY voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:161:CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:162:CREATE INDEX IF NOT EXISTS recent_edit_lookback_idx ON recent_edit (tenant_slug, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:164:ALTER TABLE recent_edit ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:165:ALTER TABLE recent_edit FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:166:DROP POLICY IF EXISTS recent_edit_tenant_isolation ON recent_edit;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:167:CREATE POLICY recent_edit_tenant_isolation ON recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:177:GRANT SELECT, INSERT, UPDATE        ON voice_corpus        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:178:GRANT SELECT, INSERT, UPDATE, DELETE ON voice_corpus_chunks TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:182:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_id_seq        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:183:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_chunks_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:199:--   ALTER TABLE voice_corpus OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:200:--   ALTER TABLE voice_corpus_chunks OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:203:--   ALTER SEQUENCE voice_corpus_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:204:--   ALTER SEQUENCE voice_corpus_chunks_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:280:-- §9 — Reference rows: seed migration-test tenant with a starter voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:282:-- Inserts a single empty active voice_corpus row for migration-test only.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:289:INSERT INTO voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:313:-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:315:-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:316:--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:317:--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
docs/runbooks/tenant-lifecycle.md:106:  INSERT INTO voice_corpus (tenant_slug, version, source_doc_count, source_doc_origin,
docs/runbooks/tenant-lifecycle.md:133:- Initial voice_corpus row with `is_active=TRUE` (T10 invariant)
docs/runbooks/tenant-lifecycle.md:148:| Agent draft + approve via Telegram | `hh_decision_action` writes to decision_log; orange-tier blocks on Telegram approval | T4 (every write sets SET LOCAL) |
docs/runbooks/tenant-lifecycle.md:246:  DELETE FROM recent_edit       WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:247:  DELETE FROM voice_corpus_chunks WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:248:  DELETE FROM voice_corpus      WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:252:  DELETE FROM decision_log      WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:255:# decision_log + recent_edit are append-only — DELETE requires running as superuser (admin operation)
docs/runbooks/tenant-lifecycle.md:274:- Audit row in decision_log: `agent_name='_tenant_admin'`, `phase='gating_failed'`, `payload.action='tenant_purged'`, `payload.tenant_slug=<slug>` (written PRE-DELETE so the audit row survives)
docs/runbooks/tenant-lifecycle.md:343:- **T10**: voice_corpus is_active=TRUE single-per-tenant (Migrate transition needs atomic flip)
docs/runbooks/tenant-lifecycle.md:351:- **Voice corpus re-index** (Active sub-state): new `voice_corpus` row inserted with `is_active=TRUE`; old row updated to `is_active=FALSE` in same transaction. Partial unique index (T10) enforces no two `is_active=TRUE` rows simultaneously.
docs/runbooks/tenant-lifecycle.md:357:Every state transition writes to decision_log:
docs/runbooks/tenant-lifecycle.md:360:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
agents/recruitment/cash-conductor/agent.md:86:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:107:Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='chase_draft'`, `tier='orange'`, payload includes the draft.
agents/recruitment/cash-conductor/agent.md:137:14 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/cash-conductor/agent.md:143:   → hh_decision_trigger("session_start", "<webhook|cron|manual>")
agents/recruitment/cash-conductor/agent.md:182:     sent (counted from decision_log decision_log.payload.position)
agents/recruitment/cash-conductor/agent.md:206:    → hh_decision_output("chase_draft", invoice_id, payload_preview);
agents/recruitment/cash-conductor/agent.md:221:    → query decision_log + accounting + bank feed for the 7-day window
agents/recruitment/cash-conductor/agent.md:225:    → hh_decision_output("weekly_report", report_path)
agents/recruitment/cash-conductor/agent.md:228:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:229:    → hh_decision_action("cash_conductor_run_complete", session_id,
agents/recruitment/cash-conductor/agent.md:293:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:297:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:298:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Edit-distance >150 chars on >40% of chase recent_edits fires `ESC_VOICE_DRIFT_TENANT`.
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:12:-- Risk register: #10 (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e))
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:14:-- This migration is ADDITIVE. Adds one nullable column to recent_edit for
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:25:-- §1 — Add text_purged_at audit column to recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:28:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:31:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:34:COMMENT ON COLUMN recent_edit.text_purged_at IS
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:39:CREATE INDEX IF NOT EXISTS recent_edit_text_purged_idx
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:40:  ON recent_edit (text_purged_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:51:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:52:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:54:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:55:  ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:78:--   WHERE table_name='recent_edit' AND column_name='text_purged_at';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:82:--   WHERE table_name='recent_edit' AND column_name='original_text';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:86:--   WHERE table_name='recent_edit' AND constraint_name='recent_edit_text_purged_consistency';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:90:--   WHERE tablename='recent_edit' AND indexname='recent_edit_text_purged_idx';
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:132:     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
agents/recruitment/scribe/agent.md:133:   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
agents/recruitment/scribe/agent.md:183:   → on success: hh_decision_action("bullhorn_scribe_field_write" +
agents/recruitment/scribe/agent.md:192:   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
agents/recruitment/scribe/agent.md:220:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:256:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:260:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:261:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT` (separate from per-run drift).
agents/recruitment/scribe/agent.md:308:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
docs/runbooks/pii-purge-operational-pattern.md:5:**Authority:** Surfaces UK GDPR Art. 5(1)(e) data-minimisation compliance for `recent_edit` text fields. Companion to `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D3 + Risk #10 in `docs/RISK-REGISTER.md`.
docs/runbooks/pii-purge-operational-pattern.md:15:`recent_edit` rows store the agent's draft (`original_text`) and the consultant's edited version (`edited_text`) verbatim, length-capped at 8192 chars per field. Per v0.2 supplement §1, these can contain PII (candidate names, salaries, contact info).
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:39:`recent_edit` table extended via `v0.2-to-v0.3-pii-purge.sql`:
docs/runbooks/pii-purge-operational-pattern.md:42:ALTER TABLE recent_edit
docs/runbooks/pii-purge-operational-pattern.md:47:ALTER TABLE recent_edit ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (
docs/runbooks/pii-purge-operational-pattern.md:97:3. SELECTs count(*) from `recent_edit` WHERE `resolved_at < now() - interval '<N> days' AND original_text IS NOT NULL`
docs/runbooks/pii-purge-operational-pattern.md:100:6. Audit row to `decision_log`: `agent_name='_pii_purger'`, `phase='gating_failed'`, `outcome='purged'`, payload has `rows_purged` + `tenants_touched` + `retention_days` + invocation_time
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:171:SELECT count(*) FROM recent_edit
docs/runbooks/pii-purge-operational-pattern.md:185:FROM decision_log
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:38:- **Subtle case:** `recent_edit.original_text` was originally `TEXT NOT NULL` in v0.2; v0.3 (post Round-2 remediation) drops that NOT NULL constraint to allow PII purge to set `original_text=NULL`. This does not weaken T1: `recent_edit.tenant_slug` remains `TEXT NOT NULL`.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:86:### T5 — `ifos_app` role has no DELETE on `decision_log` or `recent_edit` (append-only audit tables)
docs/architecture/tenancy-invariants.md:88:- **Definition:** The two audit tables (`decision_log` from Day-4 + `recent_edit` from v0.2) are structurally append-only. Even if app code attempted DELETE, the role lacks permission.
docs/architecture/tenancy-invariants.md:90:- **Documentation source:** Day-4 §6.3 line 764 (`GRANT SELECT, INSERT ON decision_log TO ifos_app`) + v0.2 §6 line 172 (`GRANT SELECT, INSERT ON recent_edit TO ifos_app`).
docs/architecture/tenancy-invariants.md:94:  WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
docs/architecture/tenancy-invariants.md:97:  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/tenancy-invariants.md:156:- **Enforcement:** Partial unique index in v0.2 migration §2: `CREATE UNIQUE INDEX voice_corpus_one_active_per_tenant ON voice_corpus (tenant_slug) WHERE is_active=TRUE`. Postgres enforces — duplicate INSERT fails.
docs/architecture/tenancy-invariants.md:161:  WHERE tablename='voice_corpus' AND indexname='voice_corpus_one_active_per_tenant';
docs/architecture/tenancy-invariants.md:176:  SELECT count(*) FROM voice_corpus;            -- expect 0
docs/architecture/tenancy-invariants.md:177:  SELECT count(*) FROM decision_log WHERE agent_name='test-agent';  -- expect 0
docs/architecture/tenancy-invariants.md:206:| T5 | Partial → Verified | Day-4 §6.3 GRANT inspection + tenancy audit | Day-4 §6.3 documented; pending adversarial in Day-9 | Decision_log + recent_edit confirmed |
docs/operations/codex-round-2-remediation-prompt.md:76:      ALTER TABLE recent_edit ALTER COLUMN original_text DROP NOT NULL;
docs/operations/codex-round-2-remediation-prompt.md:82:      ALTER TABLE recent_edit ALTER COLUMN original_text SET NOT NULL;
docs/operations/codex-round-2-remediation-prompt.md:108:      INSERT INTO decision_log (...) VALUES (...);
docs/operations/codex-round-2-remediation-prompt.md:139:      INSERT INTO decision_log (tenant_slug, agent_name, phase, payload, created_at)
docs/operations/codex-round-2-remediation-prompt.md:141:      SELECT count(*) FROM decision_log
docs/operations/codex-round-2-remediation-prompt.md:161:    - agents/_shared/hook-helpers.sh (every decision_log write)
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/operations/codex-round-2-remediation-prompt.md:340:If FIX 2 added DROP NOT NULL to recent_edit.original_text, the invariant
docs/operations/codex-round-2-remediation-prompt.md:345:  Subtle case: recent_edit.original_text was originally TEXT NOT NULL in
docs/operations/codex-round-2-remediation-prompt.md:520:    - tenancy-invariants.md §2 T1: recent_edit.original_text nullability
agents/recruitment/sourcing-scout/agent.md:96:Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.
agents/recruitment/sourcing-scout/agent.md:104:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:110:   → hh_decision_trigger("session_start", "scout <brief-id-or-slug>")
agents/recruitment/sourcing-scout/agent.md:177:    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
agents/recruitment/sourcing-scout/agent.md:182:    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
agents/recruitment/sourcing-scout/agent.md:250:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:255:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:256:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT`.
docs/operations/seedlegals-engagement-queries.md:144:6. **First cron run** — verify decision_log audit row + zero rows purged (because no recent_edit data exists yet)
docs/build-brief/00-MASTER-BRIEF.md:57:4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
docs/build-brief/00-MASTER-BRIEF.md:396:| Realtime | SSE from `decision_log` writes | No websocket complexity |
docs/build-brief/00-MASTER-BRIEF.md:413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:508:| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:571:hh_decision_trigger   # at start; logs trigger
docs/build-brief/00-MASTER-BRIEF.md:572:hh_decision_output    # on output; logs the artefact
docs/build-brief/00-MASTER-BRIEF.md:573:hh_decision_action    # when human acts; logs the action
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/build-brief/00-MASTER-BRIEF.md:672:                 │  → bus-overrides                    │   entity-graph svc                        │   hh_decision_*
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:41:**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:62:## D3 — v0.2 recent_edit PII retention
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:70:**Real issue:** `recent_edit.original_text` + `edited_text` are CAPPED at 8192 chars but otherwise stored verbatim. The agent's draft AND the consultant's edited version. Both can contain PII (candidate names, salaries, contact info). Indefinite retention for LoRA SFT training. UK GDPR Art. 5(1)(e) "data minimisation" arguably requires bounded retention.
docs/operations/goal-option-c-diagnostic-end-to-end.md:49:6. **A decision-log audit trail** for the smoke run: 3+ rows in `decision_log` (trigger + output + action), all under `agent_name='diagnostic'`, with `tenant_slug='migration-test'`.
docs/operations/goal-option-c-diagnostic-end-to-end.md:242:- Confirm 3+ decision_log rows present
docs/operations/goal-option-c-diagnostic-end-to-end.md:385:Audit rows:        [N] decision_log rows
docs/operations/codex-ratification-execution-plan.md:258:### 6.3 — Capture results to `decision_log` (audit trail)
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:263:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload)
docs/operations/codex-ratification-execution-plan.md:383:3. **Commit `decision_log` rows** (per §6.3) — these become the audit trail for the ratification run.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
docs/architecture/architecture-cohesion-review.md:71:| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
docs/architecture/architecture-cohesion-review.md:107:- **agent-bundle-renderer-design.md** (pre-Round-1) said `phase='render'` written to decision_log on renderer failure
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:126:- **v0.2 supplement** `recent_edit.original_text` + `edited_text` store agent draft + consultant edit VERBATIM (8192 cap), explicitly admitting PII can be present
docs/architecture/architecture-cohesion-review.md:127:- **Status:** This is by design — `recent_edit` is the SFT corpus source, not the operator-facing audit. But Codex Round 1 flagged it as a GDPR risk (now Risk #10).
docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:202:  - **A:** `recent_edit.original_text` + `edited_text` are narrative (raw text). `tone_rule.rule_text` is natural language. `voice_corpus_chunks.text_chunk` is text. **These ARE narrative content in Postgres** — but they're indexed for retrieval, not for primary storage. The vault remains the source of truth for the original docs; Postgres holds the indexable chunked + classified copy. ✓ Acceptable hybrid.
docs/architecture/architecture-cohesion-review.md:229:| R3 | C4: PII retention in recent_edit | High (Risk #10) | Founder Decision D3 bundles with D2 | Founder | Pre-first-LOI |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
docs/decisions/brain-ui-scope.md:6:**Surfaced by:** Master brief §6 Day 3 line 472 — "Brain UI v1.0 scope decision" + ADR-002 §3.4 closing paragraph (Brain UI explicitly forward-deferred to v1.1) + `second-brain-design.md` §3.4 ("Brain UI minimal v1 is built as a thin read-only page over `decision_log` — no new wiki API needed").
docs/decisions/brain-ui-scope.md:17:- **v1.0 minimum (weeks 11-13):** wiki API + Postgres tables (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector voice samples + 9 `wiki-*.sh` parallel wrappers + 9 `wiki/lib/*.ts` modules. **No Brain UI** — operational access via Obsidian + CLI + psql.
docs/decisions/brain-ui-scope.md:26:1. Which wiki operations get hit hardest in v1.0 (decision_log queries vs entity reads vs entity_links traversals) — informs which feature lands first in v1.1.
docs/decisions/brain-ui-scope.md:41:- Shows recent `decision_log` entries with phase + outcome filtering (`trigger | output | action | gating_failed | agent_handoff` per `sequencing-target.md` §5.3 + §6.5 enum extension).
docs/decisions/brain-ui-scope.md:53:**Likely implementation surface:** Next.js route at `/brain/today` (or equivalent), reading Postgres `decision_log` + `entities` + filesystem mtime on `/vault/<tenant>/wiki/raw/`. Auth model deferred to §3.
docs/decisions/brain-ui-scope.md:55:**Dependency on v1.0:** wiki API live + `decision_log` populated per ADR-002 §3 Decision 3 + extended phase enum per `sequencing-target.md` §6.5.
docs/decisions/brain-ui-scope.md:92:**Dependency on v1.0:** `wiki-find.sh` shipped in v1.1 itself (the wrapper isn't a v1.0 deliverable per ADR-003 §"Decision 3" wrapper table); `decision_log` + `entities` populated in v1.0.
docs/decisions/brain-ui-scope.md:142:- **`psql` against Postgres `decision_log`** for escalation review + audit trail — direct SQL queries, no UI layer.
docs/decisions/brain-ui-scope.md:152:- **`decision_log` audit trail** if asked — `psql` query showing per-agent decisions over time.
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type='bullhorn_candidate_merge' | 'bullhorn_field_backfill' | 'bullhorn_note_attach'`, `tier='yellow'`, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:85:   → hh_decision_trigger("session_start", "janitor nightly cron")
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run)
agents/recruitment/janitor/agent.md:96:   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
agents/recruitment/janitor/agent.md:130:   → query decision_log for recent_edit rows in last 30 days for this tenant
agents/recruitment/janitor/agent.md:137:   → for each proposed merge / backfill / note: emit hh_decision_action with
agents/recruitment/janitor/agent.md:144:   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
agents/recruitment/janitor/agent.md:149:   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")
agents/recruitment/janitor/agent.md:157:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:158:   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
agents/recruitment/janitor/agent.md:219:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:223:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:224:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Drift >200 chars on >50% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT`.
agents/recruitment/janitor/agent.md:264:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
docs/decisions/autosend-approval-bridge-spec.md:185:| Postgres unreachable | Write bridge state to fallback JSONL at `/vault/_meta/autosend-bridge.jsonl`; same replay pattern as decision_log fallback |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:109:| `agents/recruitment/<name>/agent.md` | `orgs/<org>/agents/<name>/CLAUDE.md` | **Synthesis** | (1) `agent.md` body verbatim; (2) **cortextOS preamble template** — spec gap §2.1-A; (3) per-tenant footer (resolved tenant_slug, current `_voice/style-guide.md` path, decision_log Postgres role); (4) hook invocation block referencing `.claude/hooks/{validate,context}.sh` paths | Lint pass: no unresolved `{{tenant_slug}}` / `{{...}}` placeholders survive; preamble matches the renderer's canonical preamble version (hash check); CLAUDE.md is non-empty and parses as valid markdown |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:144:| `tasks` | cortextOS task management — `create-task` / `update-task` / `complete-task` against the `orgs/{org}/tasks/` directory | IFOS uses Postgres `decision_log` for the "what did this agent do" trail and the wiki for the "what's the state of this entity" view. The cortextOS task store is unused by IFOS agents (parallel to the KB-untouched decision per ADR-002 Decision 1) |
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:307:# Gate A: hard-fail on missing hh_decision_* calls in this run
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:370:   `hh_decision_trigger` at start of every run
docs/architecture/agent-bundle-renderer-design.md:371:   `hh_decision_output` before producing the artefact
docs/architecture/agent-bundle-renderer-design.md:372:   `hh_decision_action` when the human resolves
docs/architecture/agent-bundle-renderer-design.md:638:**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `agent_name='_renderer'`, `phase='gating_failed'`, `payload->>'reason'='schema-validation-failure'`. (`phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — see ADR-004 Decision 7; the 5-value enum is `trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 schema migration.) If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)
docs/architecture/agent-bundle-renderer-design.md:764:| Postgres `decision_log` table live (per master brief §6 Day 4) | founder | Day 4 of Week 0 (already scheduled) |
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:339:- **§3 Output shape:** Bullhorn write payload (entity-type-specific JSON) + 1 tacit-note attachment + 1 audit row in decision_log.
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/architecture/vault-concurrency.md:3:**Status:** Reference (no Proposed/Accepted lifecycle). Synthesis of `docs/architecture/second-brain-design.md` §2.6 + `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` Decisions 2-3 + `docs/decisions/sequencing-target.md` §5-A `decision_log.phase` extension.
docs/architecture/vault-concurrency.md:192:- If second attempt also fails: raise `ESC_VAULT_VERSION_MISMATCH`, record in `decision_log` with `phase='gating_failed'` per `sequencing-target.md` §5-A enum extension, log human-readable error to operator Telegram per primitive 5 escalation surface.
docs/architecture/vault-concurrency.md:381:**V1.0 mitigation:** surface partial failure as `ESC_VAULT_CASCADE_PARTIAL_FAILURE` carrying the list of `failures` (referencing entities whose markdown bodies were not rewritten). Record in `decision_log` with `phase='gating_failed'`, `metadata` containing the failures list. **Founder reviews and manually reconciles** — for each failure, run the rewrite by hand (most edits are small) or accept temporary inconsistency until next operation through that entity.
docs/architecture/vault-concurrency.md:406:| `ESC_VAULT_CASCADE_PARTIAL_FAILURE` | §5: rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite | `gating_failed` | Telegram operator chat, plus `failures` list in decision_log metadata |
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:424:| Cascade atomicity gap (v1.0 mitigation via `ESC_VAULT_CASCADE_PARTIAL_FAILURE` + decision_log + manual reconciliation; full atomicity via write-ahead-log deferred to v1.2+) | §5.4 |
docs/architecture/vault-concurrency.md:441:The `entities.version` column is a new Day-4 tightening — joins the three already on the list per `sequencing-target.md` §6.5 (entity_graph split + `_secrets.env` + `decision_log.phase` enum extension). Day-4 task now has **4 consolidated tightenings**.
agents/recruitment/diagnostic/cleanup.sh:55:  hh_decision_action "linkedin_cache_purge_fail" "cleanup:${CTX_TENANT_SLUG}" \
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:78:  decision_log_rows_min: 4  # trigger + output + validate_gate_a_fail action + cleanup
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:167:├── _decisions/                                     ← narrative summaries — spec gap 2.1-B re: overlap with Postgres decision_log
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:427:| `update-entity` | Concierge (v1.0): append conversation note to Candidate page | v1.0 | `(id: str, section: str, content: str, tenant_id: str)` | `EntityRef` | few seconds | Targets the `<!-- BEGIN auto:{section} -->` block per §2.2.1; preserves frontmatter; rewrites backlinks if `display_name` changes; `hh_decision_*` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:463:Three tables anchored in Ultraplan §5.1 line 227 ("`tenants`, `entity_graph`, `decision_log`"). The IFOS design here renames `entity_graph` to **`entities`** (one row per entity) and adds **`entity_links`** (the adjacency table) — both flagged below as **Spec gap 2.4-B** because Ultraplan groups them under a single name.
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:543:CREATE TABLE decision_log (
docs/architecture/second-brain-design.md:559:CREATE INDEX decision_log_entity_idx ON decision_log (tenant_slug, entity_id, created_at DESC);
docs/architecture/second-brain-design.md:560:CREATE INDEX decision_log_agent_run_idx ON decision_log (tenant_slug, agent_run_id);
docs/architecture/second-brain-design.md:562:ALTER TABLE decision_log ENABLE ROW LEVEL SECURITY;
docs/architecture/second-brain-design.md:563:CREATE POLICY decision_log_tenant_isolation ON decision_log
docs/architecture/second-brain-design.md:567:Partitioned by hash on `tenant_slug` (Ultraplan §5.1 line 228: "Both `entity_graph` and `decision_log` partitioned by `tenant_id` (hash partitioning, 32 partitions to start)"). This is the **only** source of entity-history queries — the `_decisions/` directory in Ultraplan §5.1 line 220 is for narrative summaries (Spec gap 2.1-B remains; recommended resolution: `_decisions/` is for founder-written end-of-quarter narratives only, not for agent decisions; agent decisions live exclusively in `decision_log`).
docs/architecture/second-brain-design.md:571:**No `agent_runs` table for v1.0.** The `agent_run_id` column on `decision_log` is the join key; "what did this agent do this run" is a `SELECT * FROM decision_log WHERE agent_run_id = ...`. A separate `agent_runs` table can be derived as a materialised view if v1.1 dashboards need it.
docs/architecture/second-brain-design.md:609:- decision_log — never embedded; structured queries only.
docs/architecture/second-brain-design.md:642:        │  decision_log (partitioned)│    │   hnsw cosine_ops           │
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:655:        │  entity-history → decision_log SELECT                        │
docs/architecture/second-brain-design.md:676:| `ingest-entity` | Filesystem write (atomic) + Postgres UPSERT to `entities` + Postgres INSERTs to `entity_links` (all in one transaction per §2.6.1) | None — atomic or fail | Slug collision check via Postgres `SELECT 1 FROM entities WHERE tenant_slug = ? AND id = ?`. `hh_decision_trigger` + `hh_decision_output` calls insert to `decision_log` in the same transaction. |
docs/architecture/second-brain-design.md:682:| `entity-history` | Postgres `decision_log` SELECT by `(tenant_slug, entity_id)` ORDER BY `created_at DESC` | None | v1.1 read; v1.0 writes via `hh_decision_*`. No filesystem fallback — decision_log is unique source. |
docs/architecture/second-brain-design.md:712:- No corruption; both changes land; decision_log captures both `hh_decision_output` rows separately.
docs/architecture/second-brain-design.md:782:**Decision-log volume:** every agent run produces 1-3 `decision_log` rows (`hh_decision_trigger`, `hh_decision_output`, optionally `hh_decision_action` when human responds). At 6 v1.0 agents × ~10 runs/agent/day × 3 tenants × 3 rows = ~540 rows/day per shared Postgres instance. Trivial volume; the table needs hash partitioning (per Ultraplan §5.1) primarily for query performance at v1.2+ scale, not v1.0 write throughput.
docs/architecture/second-brain-design.md:825:        ├── history.ts           ← decision_log SELECT
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:870:Concurrency mechanisms live inside the server process. Audit logging via decision_log + an internal request log. Tenant scoping validated at server entry: the `CTX_TENANT_SLUG` from the agent's environment is the authoritative tenant; any tool call carrying a mismatched `tenant_slug` is rejected before reaching the library.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:921:- **v2.0 LoRA scale (master brief §5.5):** the LoRA pipeline operates on the `decision_log` table, not on the wiki. Wiki ops from LoRA-enhanced agents are unchanged. Both options work.
docs/architecture/second-brain-design.md:938:| Implied: cortextOS KB is the substrate | Explicit: parallel system. cortextOS KB untouched, IFOS owns Postgres entities/links/decision_log + pgvector voice + filesystem markdown |
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:968:| **2.1-B** | `_decisions/` directory (Ultraplan §5.1) overlapping with Postgres `decision_log` table | Two candidates for "where agent history lives" | Resolved in §2.4.2: `_decisions/` is for founder-written end-of-quarter narratives only; agent decisions live exclusively in Postgres `decision_log`. Update Ultraplan §5.1 wording. | No |
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
agents/recruitment/diagnostic/fixtures/01-primary.yaml:97:expected_decision_log_rows:
docs/decisions/2026-05-18-codex-ratification-manifest.md:26:| 11 | `docs/runbooks/day-4-provisioning.md` | Executed | Verify §12 execution log (20 deviations + 8 v1.1 revisions); cross-check schema migration against decision_log.phase enum (live SQL at `c6734d1`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:29:| 14 | Day-4 Postgres provisioning artefact | Embedded in #12 | Same review as #12 + verify 4 consolidated tightenings (entity_graph split, _secrets.env, decision_log.phase, entities.version) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:32:| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:257:| **~~11~~** | **DROPPED** | (was decision_log.phase enum already executed at `c6734d1`) | n/a |
agents/recruitment/diagnostic/validate.sh:13:# decision_log; the report does NOT land in the vault.
agents/recruitment/diagnostic/validate.sh:233:  # Emit ESC_SCHEMA_VIOLATION row to decision_log with the failure list
agents/recruitment/diagnostic/validate.sh:238:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
agents/recruitment/diagnostic/context.sh:21:#       CTX_VOICE_CORPUS_ID   active corpus id from voice_corpus table
agents/recruitment/diagnostic/context.sh:23:#       CTX_RECENT_EDITS_REF  count of recent_edit rows (drift signal)
agents/recruitment/diagnostic/context.sh:25:#   - Emits hh_decision_trigger("session_start", ...) as first audit row
agents/recruitment/diagnostic/context.sh:83:hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
agents/recruitment/diagnostic/context.sh:85:    printf 'context.sh: hh_decision_trigger failed; vault may be unwritable\n' >&2
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:157:# 5 — Load recent_edits (voice drift signal)
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:95:expected_decision_log_rows:
agents/recruitment/concierge/README.md:24:- `cleanup.sh` — token rotation + 14-day decision_log retention check
agents/recruitment/diagnostic/cycle.sh:20:#   - Audit rows to decision_log (trigger + output + action)
agents/recruitment/diagnostic/cycle.sh:102:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:156:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:166:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:182:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/agent.md:73:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/diagnostic/agent.md:78:   → hh_decision_trigger("session_start", firm_name + sector_hint)
agents/recruitment/diagnostic/agent.md:129:                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
agents/recruitment/diagnostic/agent.md:130:                 constraint = tone rules (hh_load_tone_rules)
agents/recruitment/diagnostic/agent.md:138:    → hh_decision_output("diagnostic_report", "<path>", "12-section report on {firm}")
agents/recruitment/diagnostic/agent.md:145:    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:160:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3)
agents/recruitment/diagnostic/agent.md:162:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter)
agents/recruitment/diagnostic/agent.md:167:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='_consultant_feedback'` + `phase='action'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field).
agents/recruitment/diagnostic/agent.md:198:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:202:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
agents/recruitment/diagnostic/agent.md:203:- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.
agents/recruitment/diagnostic/tools.yaml:123:      voice-loader.sh for tenant corpus + tone rules + recent_edits.
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='action'`, `action_type='concierge_draft_<event_type>'`, `tier='orange'`, payload includes voice_score + recipient + escalation_position.
agents/recruitment/concierge/agent.md:110:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:116:     voice corpus + tone rules + recent_edits + tenant comms-template
agents/recruitment/concierge/agent.md:118:   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
agents/recruitment/concierge/agent.md:123:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:130:   → query decision_log for prior concierge_draft for same (candidate_id,
agents/recruitment/concierge/agent.md:211:    → hh_decision_action("concierge_send_complete", candidate_id, payload_hash,
agents/recruitment/concierge/agent.md:219:    → hh_decision_action("concierge_run_complete", session_id, run_mode)
agents/recruitment/concierge/agent.md:247:- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`.
agents/recruitment/concierge/agent.md:286:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:293:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:294:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal at tenant level. Edit-distance >150 chars on >40% of recent_edit rows → ESC_VOICE_DRIFT_TENANT → tenant-admin reviews voice corpus + tone rules.
agents/recruitment/concierge/agent.md:349:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:353:| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:46:| `wiki-history.sh` | entity-history (reads `decision_log`) | v1.1 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:63:- **Postgres tables (v1.0):** `tenants`, `entities`, `entity_links`, `decision_log` — schemas in design §2.4.2. RLS by tenant_slug on every table except `tenants`. The Ultraplan §5.1 line 227 single `entity_graph` table is **split** into `entities` (one row per entity) and `entity_links` (adjacency) — see Spec gap 2.4-B in the design doc.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:93:> "v1.0 minimum (weeks 11-13) — 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; no Brain UI yet. Total v1.0 effort ~11-13 person-days. v1.1 adds `wiki-find.sh` + `wiki-history.sh` + Brain UI today-view and backlinks panel."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:7:**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:21:**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
docs/decisions/autosend-safety-policy.md:32:- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
docs/decisions/autosend-safety-policy.md:49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:128:## §4 — Integration with the `hh_decision_action` contract
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:132:- `hh_decision_trigger` — at session start; logs the trigger
docs/decisions/autosend-safety-policy.md:133:- `hh_decision_output` — when the agent produces its output artefact
docs/decisions/autosend-safety-policy.md:134:- `hh_decision_action` — when an action is taken (or blocked)
docs/decisions/autosend-safety-policy.md:136:The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
docs/decisions/autosend-safety-policy.md:141:# hh_decision_action — gate every side-effecting action through the policy
docs/decisions/autosend-safety-policy.md:147:hh_decision_action() {
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:241:**Payload (JSONB into `decision_log.payload`):**
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:262:5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:355:| `decision_log` table unreachable (Postgres down, RLS context unset, network partition) | INSERT raises error | **Hard blocking error**; agent halts entirely with non-zero exit; no actions taken at all | Postgres restored OR session restarted with valid context; agent resumes from last checkpoint |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:364:**Every governed action emits exactly one `decision_log` row** at execution time. The append-only enforcement (Postgres grants on `decision_log` are SELECT + INSERT only for `ifos_app` per Day 4 §6.3) means rows cannot be modified or deleted post-write.
docs/decisions/autosend-safety-policy.md:366:### Row schema (within existing `decision_log` table from Day 4)
docs/decisions/autosend-safety-policy.md:369:-- decision_log columns (Day 4 §6.3):
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:418:`decision_log` rows are retained **indefinitely** for v1.0. v1.1+ may introduce retention policies (e.g., delete rows older than 7 years per UK statutory retention norms).
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:513:recorded in the decision_log table by reference to the policy git SHA
docs/decisions/autosend-safety-policy.md:514:(decision_log.payload.policy_version_sha), is the authoritative record
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:537:  (b) failure of the policy lookup mechanism (decision_log fail-safe-red
docs/decisions/autosend-safety-policy.md:544:The decision_log table within IFOS's Postgres instance, isolated to
docs/decisions/autosend-safety-policy.md:549:decision_log timestamps, payload_hash, and policy_version_sha.
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:586:5. **PII liability for `payload_preview` formatting.** If `payload_preview` accidentally leaks PII into `decision_log`, that's a Provider liability event. Tooling: linter on `payload_preview` strings at hook-helpers.sh layer.
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:598:| 3 | Policy lookup latency — must be <10ms per `hh_decision_action` call. Caching strategy needed (in-memory per session vs hot-reload). | §4 | Recommend in-memory cache per session (71h cache lifetime aligns with cortextOS context rotation). Hot-reload via PTY restart only. |
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:611:- **Whether decision_log captures both allowed and blocked sends:** Yes, §7.
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:643:2. `hh_decision_action` pseudocode per §4
packages/agents-runtime/_shared/common-voice.json:8:    "voice_corpus_path": {
packages/agents-runtime/_shared/common-voice.json:16:      "description": "Tag matching docs/verticals/recruitment/vertical-schema.yaml voice_corpus.version row."
packages/agents-runtime/_shared/common-voice.json:35:    "recent_edits_lookback_days": {
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/agents-runtime/_shared/common-voice.json:49:  "required": ["voice_corpus_path", "voice_classifier_threshold"],
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:111:**Owner:** IFOS oncall + tenant operator. Daily check via `decision_log` queries: `SELECT COUNT(*) FROM decision_log WHERE phase='gating_failed' AND payload->>'tier'='red' AND payload->>'block_reason'='red_tier_classification' AND tenant_slug=? AND created_at > NOW() - INTERVAL '7 days'`.
docs/decisions/v1.0-kill-criterion.md:121:**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
docs/decisions/v1.0-kill-criterion.md:176:**Owner:** IFOS oncall; weekly check via `decision_log` + cortextOS daemon logs.
packages/agent-renderer/templates/claude-md-preamble.md:22:- `hh_decision_trigger` at start of every run
packages/agent-renderer/templates/claude-md-preamble.md:23:- `hh_decision_output` before producing the artefact
packages/agent-renderer/templates/claude-md-preamble.md:24:- `hh_decision_action` when the human resolves
packages/agent-renderer/templates/claude-md-preamble.md:44:- `memory/` — replaced by Postgres `decision_log` (writes via `hh_decision_*` helpers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:80:- **Layering verified:** YAML specifies entity_type + link_type + data JSONB shape over Day-4 generic primitives (`entities`, `entity_links`, `decision_log` tables) — entity-type slugs land in `entities.entity_type` column; link-type slugs land in `entity_links.link_type` column.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/sequencing-target.md:32:- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
docs/decisions/sequencing-target.md:40:**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
docs/decisions/sequencing-target.md:55:| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:101:| 6. Tenant-onboarding readiness | **High** | Runnable from end of Week 2 with renderer + `_shared/` + Postgres decision_log. No vault `_secrets.env` complexity (no per-tenant Bullhorn OAuth needed), no wiki API needed. Single-tenant deployable immediately |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:348:2. **First production run lands clean** for at least one tenant — no `ESC_*` escalation rows in `decision_log` for agent N's run.
docs/decisions/sequencing-target.md:351:5. **Founder explicit sign-off** recorded in `decision_log` with `phase='agent_handoff'`, `agent_name='_sequencing'`, `entity_id='<N>->_<N+1>'`, `metadata` carrying the §5.2-row evidence summary.
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:371:1. **Surface** in `decision_log` with `phase='gating_failed'`, `agent_name='_sequencing'`, `entity_id='<N>->_<N+1>'`, `metadata` carrying which gate(s) failed.
docs/decisions/sequencing-target.md:376:**New `decision_log` `phase` values introduced by this document:** `gating_failed`, `agent_handoff`. The Postgres decision_log table column `phase` (per `second-brain-design.md` §2.4.2 schema) currently lists only `trigger | output | action` per ADR-002 Decision 3. **Spec gap §5-A** flagged for Day 4 Postgres provisioning: extend the `phase` column's accepted values to include the two new ones. Schema migration is a one-line `CHECK` constraint update.
docs/decisions/sequencing-target.md:399:- Smallest viable Diagnostic exercising renderer + `_shared/` + `decision_log` end-to-end per §2.1 substrate-exercise column.
docs/decisions/sequencing-target.md:424:The `decision_log` schema must support `phase='gating_failed'` and `phase='agent_handoff'` per §5.3 Spec gap §5-A. Day 4 Postgres provisioning script needs the extended `CHECK` constraint:
docs/decisions/sequencing-target.md:427:ALTER TABLE decision_log
docs/decisions/sequencing-target.md:428:  ADD CONSTRAINT decision_log_phase_check
docs/decisions/sequencing-target.md:451:- Spec gap §5-A (decision_log phase enum extension) is queued for Day 4 implementation, not deferred.
docs/decisions/sequencing-target.md:507:| Substrate readiness for W3 Diagnostic build (renderer + `_shared/` + `decision_log`) | Claude Code | End of W2 | Already tracked from ADR-002 + ADR-003 |
docs/decisions/sequencing-target.md:509:| `decision_log.phase` enum extended to include `gating_failed` + `agent_handoff` per §5.3 / §6.5 | Claude Code | Day 4 Postgres provisioning | **NEW from this document** Spec gap §5-A |
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
packages/agent-renderer/tests/fixtures/test-agent/agent.md:5:Test-agent emits one structured `decision_log` row per invocation with phase
packages/agent-renderer/tests/fixtures/test-agent/agent.md:11:1. `hh_decision_trigger` at session start
packages/agent-renderer/tests/fixtures/test-agent/agent.md:13:3. Echo input + emit `hh_decision_output`
packages/agent-renderer/tests/fixtures/test-agent/agent.md:14:4. Wait for human resolve; emit `hh_decision_action`

 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:129:      - Cash Conductor (R — payment reminder tone)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:211:        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:414:      Claude analysis: D3-B (90-day text purge + indefinite metadata) with
agents/recruitment/cash-conductor/README.md:1:# Cash Conductor — directory README
agents/recruitment/cash-conductor/README.md:3:**Status:** Proposed (Day-18 pre-W7-8-build scaffold).
agents/recruitment/cash-conductor/README.md:18:Full bundle at W7-8 build (~2 weeks per ULTRAPLAN A4 line 541):
agents/recruitment/cash-conductor/README.md:21:- `context.sh` — multi-provider auth refresh + voice corpus + 90-day token monitor
agents/recruitment/cash-conductor/README.md:22:- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
agents/recruitment/cash-conductor/README.md:27:- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)
agents/recruitment/cash-conductor/README.md:29:## Hire #1 anchor
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
agents/recruitment/cash-conductor/README.md:39:*End of Cash Conductor README.*
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:4:# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
agents/_shared/autosend-policy.yaml:246:  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:27:2. **Fallback mode (degraded / offline)** — `IFOS_DB_URL` unset OR `psql` unavailable OR `psql` exited non-zero. Helpers append JSON lines to `${IFOS_DECISION_LOG_FALLBACK:-/vault/<tenant>/decision-log.jsonl}`. The trail replays into Postgres when connectivity returns via the autosend-syncer worker (Week 5+).
agents/_shared/README.md:41:| `HH_POLICY_FILE` | no | Override path to `autosend-policy.yaml` | `${CTX_AGENT_DIR}/.claude/hooks/_shared/autosend-policy.yaml` |
agents/_shared/README.md:43:| `HH_AWAIT_TEST_MODE` | no (test only) | `approve` / `reject` / `timeout` — short-circuits `autosend_await_approval` poll loop | — |
agents/_shared/README.md:58:### 7 `autosend_*` helpers (autosend-safety-policy §4)
agents/_shared/README.md:61:autosend_policy_lookup        <action_type>                                          # prints tier
agents/_shared/README.md:62:autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>               # prints possibly-elevated tier
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:64:autosend_escalate             <ESC_CODE> [<key=value>...]
agents/_shared/README.md:65:autosend_should_sample        <action_type> <tenant_slug>                            # returns 0 if sampled
agents/_shared/README.md:66:autosend_spot_check_enqueue   <action_type> <target> <hash> <preview> <tenant_slug>
agents/_shared/README.md:67:autosend_await_approval       <action_type> <target> <hash>                          # blocks until resolved
agents/_shared/README.md:70:## Auto-send tier dispatch (autosend-safety-policy §4)
agents/_shared/README.md:74:| Tier | Behaviour | Return |
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:167:- `agents/_shared/autosend-policy.yaml` (Reference — runtime table)
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:177:- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
agents/_shared/escalation-codes.md:13:The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:43:- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:254:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
packages/agents-runtime/_shared/common-accounting.json:5:  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
packages/agents-runtime/_shared/common-accounting.json:12:      "description": "None = Cash Conductor not deployed for this tenant. Xero = deployed."
packages/agents-runtime/_shared/common-accounting.json:30:      "description": "Default Cash Conductor cadence; tenant-overridable per autosend-safety-policy §6 tenant-override discipline."
packages/agents-runtime/_shared/common-accounting.json:36:      "description": "Outstanding amount above which Cash Conductor escalates to operator via ESC route rather than auto-chasing."
packages/agents-runtime/_shared/common-accounting.json:42:      "description": "v1.0 closes loop via Open Banking reconciliation per Ultraplan §8.1 A4; truelayer placeholder."
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:192:        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
docs/verticals/recruitment/vertical-schema.yaml:335:        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
docs/verticals/recruitment/vertical-schema.yaml:365:        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
agents/recruitment/cash-conductor/agent.md:1:# Cash Conductor — the FD's evenings back
agents/recruitment/cash-conductor/agent.md:3:**Status:** Proposed (Day-18 pre-W7-8-build scaffold; awaits Q1 LOI + accounting + Open Banking commercial signups + W7 build slice OR earlier-pull-forward per ADR-005 if Bullhorn delays persist).
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:7:**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 541.
agents/recruitment/cash-conductor/agent.md:8:**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 539). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 539 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 540) — the FD-tier closer metric. Chase drafts are orange-tier per `autosend-safety-policy.yaml` (consultant approval required before send via Concierge); reconciliation writes are yellow-tier.
agents/recruitment/cash-conductor/agent.md:74:Per webhook event, Cash Conductor reconciles incoming bank deposits against the tenant's open invoice register. Match algorithm:
agents/recruitment/cash-conductor/agent.md:80:| 3 | Exact amount + within-90-day-of-invoice-issue window | 0.70 |
agents/recruitment/cash-conductor/agent.md:90:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. Output is a queued draft, NOT a send. Drafts route to Concierge (which handles the actual send pipeline + consultant approval per autosend §4 orange tier).
agents/recruitment/cash-conductor/agent.md:118:Position 4 is the kill-switch: Cash Conductor never auto-drafts beyond position 3. Operator decides next step manually.
agents/recruitment/cash-conductor/agent.md:127:| 2 | **DSO trend** | Days-Sales-Outstanding metric this week vs prior-week vs month-0 baseline; Gate B tracking |
agents/recruitment/cash-conductor/agent.md:147:   → Open Banking: TrueLayer/Plaid UK 90-day token refresh (CRITICAL —
agents/recruitment/cash-conductor/agent.md:148:     gotcha §6.1 of ULTRAPLAN A4 line 542); if <30 days until expiry,
agents/recruitment/cash-conductor/agent.md:161:     (90-day rolling; chmod 0600; LUKS-encrypted)
agents/recruitment/cash-conductor/agent.md:177:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:198:   → verify: NOT paid in last 24h (re-query accounting)
agents/recruitment/cash-conductor/agent.md:204:    → Concierge handles autosend-bridge call to operator (D1 path per
agents/recruitment/cash-conductor/agent.md:209:11. (Operator approves via Concierge → Concierge sends → Cash Conductor
agents/recruitment/cash-conductor/agent.md:212:    → Cash Conductor updates internal state: prior_chases_sent counter
agents/recruitment/cash-conductor/agent.md:222:    → compute DSO metric (Gate B tracking)
agents/recruitment/cash-conductor/agent.md:240:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 539 verbatim):
agents/recruitment/cash-conductor/agent.md:243:- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
agents/recruitment/cash-conductor/agent.md:254:Per ULTRAPLAN A4 line 540 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
agents/recruitment/cash-conductor/agent.md:256:DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.
agents/recruitment/cash-conductor/agent.md:258:Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
agents/recruitment/cash-conductor/agent.md:266:Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/cash-conductor/agent.md:273:| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking token <30 days from 90-day expiry | warn (info if <60 days; warn if <30; blocking if <7) | operator_chat_id → ifos_oncall as expiry nears |
agents/recruitment/cash-conductor/agent.md:281:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:285:Cash Conductor does NOT use Bullhorn-specific codes (no Bullhorn dependency).
agents/recruitment/cash-conductor/agent.md:304:## §8 — Build dependencies (W7-8 prerequisites OR earlier per ADR-005 pull-forward)
agents/recruitment/cash-conductor/agent.md:306:Cash Conductor build cannot start until ALL of the following are confirmed:
agents/recruitment/cash-conductor/agent.md:316:| Xero MCP connector | W7 build start (~2 days) | ⏸ |
agents/recruitment/cash-conductor/agent.md:317:| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
agents/recruitment/cash-conductor/agent.md:318:| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
agents/recruitment/cash-conductor/agent.md:319:| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
agents/recruitment/cash-conductor/agent.md:324:| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
agents/recruitment/cash-conductor/agent.md:325:| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:326:| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
agents/recruitment/cash-conductor/agent.md:327:| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |
agents/recruitment/cash-conductor/agent.md:329:**Per ADR-005 §5.1 pull-forward provision:** if Bullhorn Sub-decisions A+B answers delay past 2026-06-10, Cash Conductor may be pulled forward from W7-8 to W4-5 because it has zero Bullhorn dependency. The other prerequisites (accounting + Open Banking commercial signups) remain founder-action gates regardless.
agents/recruitment/cash-conductor/agent.md:335:**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start (or earlier per ADR-005 pull-forward).
agents/recruitment/cash-conductor/agent.md:341:| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
agents/recruitment/cash-conductor/agent.md:343:| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
agents/recruitment/cash-conductor/agent.md:346:| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
agents/recruitment/cash-conductor/agent.md:347:| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
agents/recruitment/cash-conductor/agent.md:348:| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
agents/recruitment/cash-conductor/agent.md:350:### Gotchas (carried forward from ULTRAPLAN A4 line 542)
agents/recruitment/cash-conductor/agent.md:352:1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
agents/recruitment/cash-conductor/agent.md:355:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:369:- W7-8 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/cash-conductor/agent.md:372:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
agents/recruitment/cash-conductor/agent.md:377:*End of Cash Conductor agent.md draft.*
agents/_shared/tests/test-hook-helpers.sh:82:export HH_POLICY_FILE="${REPO_ROOT}/agents/_shared/autosend-policy.yaml"
agents/_shared/tests/test-hook-helpers.sh:117:printf '\n[3] autosend_policy_lookup resolves each tier\n'
agents/_shared/tests/test-hook-helpers.sh:118:test_lookup_green() { local t; t=$(autosend_policy_lookup "diagnostic_report_render"); _assert_eq "green" "${t}" "green"; }
agents/_shared/tests/test-hook-helpers.sh:119:test_lookup_yellow() { local t; t=$(autosend_policy_lookup "bullhorn_candidate_dedupe"); _assert_eq "yellow" "${t}" "yellow"; }
agents/_shared/tests/test-hook-helpers.sh:120:test_lookup_orange() { local t; t=$(autosend_policy_lookup "bullhorn_note_customer_visible"); _assert_eq "orange" "${t}" "orange"; }
agents/_shared/tests/test-hook-helpers.sh:121:test_lookup_red() { local t; t=$(autosend_policy_lookup "xero_payment_initiate"); _assert_eq "red" "${t}" "red"; }
agents/_shared/tests/test-hook-helpers.sh:122:test_lookup_unknown() { autosend_policy_lookup "nonexistent_action" >/dev/null 2>&1; _assert_rc "1" "$?" "unknown"; }
agents/_shared/tests/test-hook-helpers.sh:191:printf '\n[9] autosend_apply_tenant_override — elevation allowed\n'
agents/_shared/tests/test-hook-helpers.sh:193:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:200:  result=$(autosend_apply_tenant_override "green" "bullhorn_note_internal" "${CTX_TENANT_SLUG}")
agents/_shared/tests/test-hook-helpers.sh:205:printf '\n[10] autosend_apply_tenant_override — demotion refused\n'
agents/_shared/tests/test-hook-helpers.sh:207:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:213:  autosend_apply_tenant_override "orange" "bullhorn_note_customer_visible" "${CTX_TENANT_SLUG}" >/dev/null 2>&1
agents/_shared/tests/test-hook-helpers.sh:218:printf '\n[11] autosend_apply_tenant_override — red is absolute\n'
agents/_shared/tests/test-hook-helpers.sh:220:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:227:  result=$(autosend_apply_tenant_override "red" "xero_payment_initiate" "${CTX_TENANT_SLUG}")
agents/_shared/tests/test-hook-helpers.sh:233:printf '\n[12] autosend_escalate — unknown ESC code → meta-escalation\n'
agents/_shared/tests/test-hook-helpers.sh:236:  autosend_escalate "ESC_NONEXISTENT_CODE" 2>/dev/null
agents/_shared/tests/test-hook-helpers.sh:245:printf '\n[13] autosend_should_sample — yellow tier with high rate eventually returns 0\n'
agents/_shared/tests/test-hook-helpers.sh:251:    if autosend_should_sample "bullhorn_candidate_dedupe" "${CTX_TENANT_SLUG}"; then
agents/_shared/tests/test-hook-helpers.sh:260:printf '\n[14] autosend_spot_check_enqueue writes idempotent markdown\n'
agents/_shared/tests/test-hook-helpers.sh:263:  autosend_spot_check_enqueue "bullhorn_candidate_dedupe" "candidate:foo" "abc123def456" "merge preview" "${CTX_TENANT_SLUG}"
agents/_shared/tests/test-hook-helpers.sh:286:  # (a) the autosend_emit_decision_log audit row with payload.tier='red'
agents/_shared/tests/test-hook-helpers.sh:287:  # (b) the autosend_escalate ESC_AUTOSEND_BLOCKED escalation row
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:31:_HH_POLICY_FILE="${HH_POLICY_FILE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/autosend-policy.yaml}"
agents/_shared/hook-helpers.sh:202:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
agents/_shared/hook-helpers.sh:203:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:205:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:210:  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
agents/_shared/hook-helpers.sh:211:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:213:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:220:      autosend_emit_decision_log "action" "green" "${action_type}" \
agents/_shared/hook-helpers.sh:225:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
agents/_shared/hook-helpers.sh:227:      if autosend_should_sample "${action_type}" "${tenant}"; then
agents/_shared/hook-helpers.sh:228:        autosend_spot_check_enqueue "${action_type}" "${target}" \
agents/_shared/hook-helpers.sh:234:      autosend_emit_decision_log "action" "orange" "${action_type}" \
agents/_shared/hook-helpers.sh:236:      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:238:      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
agents/_shared/hook-helpers.sh:242:      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
agents/_shared/hook-helpers.sh:244:      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
agents/_shared/hook-helpers.sh:249:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:251:      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:259:# 7 autosend_* helpers (autosend-safety-policy §4)
agents/_shared/hook-helpers.sh:262:# autosend_policy_lookup <action_type>
agents/_shared/hook-helpers.sh:265:autosend_policy_lookup() {
agents/_shared/hook-helpers.sh:268:    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
agents/_shared/hook-helpers.sh:285:# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:287:# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
agents/_shared/hook-helpers.sh:289:autosend_apply_tenant_override() {
agents/_shared/hook-helpers.sh:300:  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
agents/_shared/hook-helpers.sh:322:    printf 'autosend_apply_tenant_override: refusing to demote %s → %s for %s/%s\n' \
agents/_shared/hook-helpers.sh:329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:330:# Emits the standard autosend decision_log row with payload.tier set.
agents/_shared/hook-helpers.sh:331:autosend_emit_decision_log() {
agents/_shared/hook-helpers.sh:353:# autosend_escalate <ESC_CODE> [<key=value>...]
agents/_shared/hook-helpers.sh:357:autosend_escalate() {
agents/_shared/hook-helpers.sh:362:    printf 'autosend_escalate: unknown ESC code: %s\n' "${code}" >&2
agents/_shared/hook-helpers.sh:386:  # signal. Dispatcher (autosend-syncer) reads recent gating_failed rows and
agents/_shared/hook-helpers.sh:390:# autosend_should_sample <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:392:# 1 otherwise. Sample rate read from autosend-policy.yaml (sample_rate field);
agents/_shared/hook-helpers.sh:394:autosend_should_sample() {
agents/_shared/hook-helpers.sh:416:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:419:autosend_spot_check_enqueue() {
agents/_shared/hook-helpers.sh:428:    printf 'autosend_spot_check_enqueue: cannot mkdir %s\n' "${spot_dir}" >&2
agents/_shared/hook-helpers.sh:451:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:457:autosend_await_approval() {
agents/_shared/hook-helpers.sh:511:        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:539:  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
packages/agents-runtime/_shared/common-client.json:47:      "description": "Drives agent Tier 1/2/3 classification per master brief §2.4 primitive 1."
packages/agents-runtime/_shared/common-notifications.json:25:      "description": "Primary surface for orange-tier approval gates per autosend-safety-policy §4."
packages/agents-runtime/_shared/common-notifications.json:49:      "description": "4h default per autosend-safety-policy §5 ESC_AUTOSEND_NEEDS_REVIEW; timeout converts orange-tier to ESC_AUTOSEND_NEEDS_REVIEW row."
agents/recruitment/scribe/agent.md:8:**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:202:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
packages/agents-runtime/_shared/common-vault.json:21:      "description": "Relative to vault_root; holds _config.yaml + autosend-overrides.yaml."
packages/agents-runtime/_shared/common-vault.json:36:      "description": "Queue directory written by autosend_spot_check_enqueue per autosend-safety-policy §4."
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:10:--           + Founder Decision D3 (recommended D3-B: 90-day text purge +
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:37:  'Per Founder Decision D3 (v1.0 default: 90-day window).';
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:16:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:45:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:74:- **D3-B: 90-day text purge + indefinite metadata** — purge `original_text` + `edited_text` after 90 days; keep `edit_distance` + `resolution` + `tone_rules_triggered` (already aggregates) forever. **Loses some SFT corpus signal** but retains the "what rules fired" signal indefinitely.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:164:Implementation work: <commit reference or "in autosend §9 update commit">
agents/recruitment/sourcing-scout/agent.md:8:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:46:- Night Sourcer Tier-1 always-on (Brain UI dashboard; cortextOS primitive #6)
agents/recruitment/sourcing-scout/agent.md:193:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 553 verbatim):
agents/recruitment/janitor/agent.md:8:**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:29:Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
agents/recruitment/janitor/agent.md:67:Per `autosend-safety-policy.yaml` row `janitor_bullhorn_write`. Three write categories:
agents/recruitment/janitor/agent.md:138:     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
agents/recruitment/janitor/agent.md:168:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:186:Gate B doesn't block the agent. It's the v1.0 kill-criterion §2 Trigger 8 supporting metric ("Gate-B revenue uplift" — Janitor's day-30 report is THE artefact that demonstrates "DSO drops" / "consultant time saved" claims to the FD-tier closer).
agents/recruitment/janitor/agent.md:252:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
docs/decisions/autosend-approval-bridge-spec.md:6:**Surfaced by:** Founder Decision D1 (`docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`) + Codex Round 1 autosend rejection issue 2
docs/decisions/autosend-approval-bridge-spec.md:18:- `agents/_shared/hook-helpers.sh::autosend_await_approval` writes pending marker `/vault/<tenant>/pending-approvals/<hash>.pending`
docs/decisions/autosend-approval-bridge-spec.md:68:A new IFOS package: `packages/autosend-approval-bridge/`. ~200-250 lines of TypeScript. Runs as a long-lived process (PM2-managed alongside the daemon).
docs/decisions/autosend-approval-bridge-spec.md:79:  - Map IFOS action_type → cortextOS ApprovalCategory (autosend taxonomy)
docs/decisions/autosend-approval-bridge-spec.md:98:The bridge's `autosend_await_approval` polling loop (already in `hook-helpers.sh`) sees the new marker → returns 0 (approved) or 1 (rejected) → agent proceeds or escalates.
docs/decisions/autosend-approval-bridge-spec.md:102:Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:
docs/decisions/autosend-approval-bridge-spec.md:105:CREATE TABLE IF NOT EXISTS autosend_approval_mappings (
docs/decisions/autosend-approval-bridge-spec.md:118:ALTER TABLE autosend_approval_mappings ENABLE ROW LEVEL SECURITY;
docs/decisions/autosend-approval-bridge-spec.md:119:CREATE POLICY tenant_isolation ON autosend_approval_mappings
docs/decisions/autosend-approval-bridge-spec.md:121:GRANT SELECT, INSERT, UPDATE ON autosend_approval_mappings TO ifos_app;
docs/decisions/autosend-approval-bridge-spec.md:128:`autosend_approval_mappings` becomes the 10th tenant-data table when the bridge implementation lands. The Week-9 bridge implementation slice MUST update `docs/architecture/tenancy-invariants.md` §1 and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` to include this table in T1-T3, T11, and audit coverage. This remediation corrects the spec only; the table does not exist yet, so the live invariant inventory remains the v0.2 nine-table set until the bridge migration ships.
docs/decisions/autosend-approval-bridge-spec.md:132:cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:
docs/decisions/autosend-approval-bridge-spec.md:171:`autosend_await_approval` already enforces 4h default timeout per action_type's `timeout` field in autosend-policy.yaml. If the timeout fires before operator responds:
docs/decisions/autosend-approval-bridge-spec.md:173:1. IFOS-side: poll loop exits → `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` → agent gives up
docs/decisions/autosend-approval-bridge-spec.md:185:| Postgres unreachable | Write bridge state to fallback JSONL at `/vault/_meta/autosend-bridge.jsonl`; same replay pattern as decision_log fallback |
docs/decisions/autosend-approval-bridge-spec.md:199:packages/autosend-approval-bridge/
docs/decisions/autosend-approval-bridge-spec.md:200:├── package.json              ← @ifos/autosend-approval-bridge; Node 20+
docs/decisions/autosend-approval-bridge-spec.md:226:Adding `autosend_approval_mappings` table requires:
docs/decisions/autosend-approval-bridge-spec.md:231:Total schema impact: 1 new table; tenancy-invariants.md grows from 12 to 13 invariants (T13: autosend_approval_mappings tenant_slug + RLS), or we count this as covered by T1-T3 already (cleaner).
docs/decisions/autosend-approval-bridge-spec.md:239:| A1 | Bridge process starts via PM2 + connects to Postgres + reads bridge state | `pm2 status ifos-autosend-bridge` shows online; bridge starts fresh on empty DB |
docs/decisions/autosend-approval-bridge-spec.md:242:| A4 | 4h timeout: bridge calls `updateApproval(..., 'denied', 'ifos_timeout')` cleanly | Integration test: write `.pending` marker, advance simulated clock 4h, assert cortextOS `pending/` is empty + `resolved/` has `denied` record |
docs/decisions/autosend-approval-bridge-spec.md:245:| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
docs/decisions/autosend-approval-bridge-spec.md:246:| A8 | Bridge state row in `autosend_approval_mappings` exists for every pending approval | Audit query: count(pending markers) == count(pending bridge state rows) |
docs/decisions/autosend-approval-bridge-spec.md:268:- **Building the IFOS-side `autosend_await_approval` polling loop** — already exists in `hook-helpers.sh` (Phase 3)
docs/decisions/autosend-approval-bridge-spec.md:285:| 6 | RLS on autosend_approval_mappings forgotten | Migration includes ENABLE ROW LEVEL SECURITY; tenancy audit T2 catches if missing |
docs/decisions/autosend-approval-bridge-spec.md:306:- Adds 1 tenant-data table (`autosend_approval_mappings`) → tenancy-invariants.md update OR considered covered by T1-T3 patterns
docs/decisions/autosend-approval-bridge-spec.md:307:- Adds 1 PM2-managed process (`ifos-autosend-bridge`) → ecosystem.config.js update
packages/harness/cortextos/src/daemon/fast-checker.ts:961:    // Tier 3: deadline exceeded — force restart if agent ignored handoff prompt
packages/harness/cortextos/src/daemon/fast-checker.ts:969:    // Tier 1: warning — PTY injection only, no Telegram ping (context management is internal)
packages/harness/cortextos/src/daemon/fast-checker.ts:978:    // Tier 2: handoff (fires once per session lifecycle)
packages/harness/cortextos/src/daemon/fast-checker.ts:1025:    // hard-restart --handoff-doc (e.g. Tier 3 force-restart cut it short), pick it up
packages/harness/cortextos/src/daemon/fast-checker.ts:1040:          this.log(`Tier 3 restart: found recent handoff doc, writing marker → ${docPath}`);
packages/harness/cortextos/src/daemon/fast-checker.ts:1054:    // Tier 2 immediately by reading the stale high-% value from the previous session.
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:66:| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:82:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:95:| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:99:| 6 | `docs/decisions/autosend-approval-bridge-spec.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:168:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:273:| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
packages/utilities/web-scraper/pnpm-lock.yaml:166:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:220:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/utilities/web-scraper/pnpm-lock.yaml:436:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/utilities/web-scraper/pnpm-lock.yaml:517:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/utilities/web-scraper/pnpm-lock.yaml:703:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/utilities/web-scraper/pnpm-lock.yaml:773:    resolution: {integrity: sha512-34wB/Y7MW7bzjKRjUKTa46I2Z7eV62Rkhva+KkopW7Qvv/OSWBqvkSY7vusOPrNuZcUG3tApvdVgNB8POj3SPw==}
packages/utilities/web-scraper/pnpm-lock.yaml:1004:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
agents/recruitment/concierge/README.md:14:The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.
agents/recruitment/concierge/README.md:20:- `tools.yaml` — Bullhorn R+W + Microsoft Graph + Gmail + voice classifier + autosend bridge (per D1 outcome)
agents/recruitment/concierge/README.md:35:**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
agents/recruitment/concierge/README.md:38:- D1-C: no autosend; manual consultant pickup (0 dev; ships fastest but worst UX)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:66:| 10 | Reporting Engine | Operations | Friday 07:00 | Weekly briefing | Stripe, GA4, Meta Ads, Slack |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:86:| Tier | £/mo | Agents | Seats | Integrations | Runs/mo |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:206:- GA4 (Reporting Engine)
agents/recruitment/diagnostic/cycle.sh:12:# Per ADR-003 + sequencing-target.md §2.1: Diagnostic is Tier 2 (request-
agents/recruitment/diagnostic/agent.md:8:**Tier:** 2 (request-driven; no persistent PTY) per sequencing-target.md §2.1.
agents/recruitment/diagnostic/agent.md:33:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY) → exits within 10-15 min per Ultraplan §8.1 A1 turnaround target.
agents/recruitment/diagnostic/agent.md:146:    → action tier per autosend-policy.yaml: green (no external send; vault write only)
agents/recruitment/diagnostic/agent.md:156:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces:
agents/recruitment/diagnostic/agent.md:169:Gate B doesn't block the agent. It contributes to v1.0 kill-criterion §2 Trigger 8 ("Gate-B revenue uplift" — Diagnostic's discovery-call conversion is one of three signals feeding Trigger 8, alongside Janitor day-30 reports and Cash Conductor DSO improvement). Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review (not an immediate trigger fire).
agents/recruitment/diagnostic/agent.md:189:- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
docs/RISK-REGISTER.md:10:| 1 | CortexOS primitives 3 or 4 are flaky in production | High | High | Daily orchestrator health check flags > 1 incident/week | Every Tier-1 agent has a degraded-mode fallback; manual file-bus handoff documented | **Updated Day 1** — primitive 3 (bus) is **shipped and tested**; primitive 4 (approval gates) is **shipped and tested**; only primitive 1 (PTY/PM2) is **shipped but flaky** per quirks 2-3 + 2026-04-22 restart-storm evidence in `cortextos-primitive-status.md`. Risk severity revised down. |
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:25:- `agents/_shared/hook-helpers.sh` + `autosend-policy.yaml` (Phase 3, commit `e6e9df1`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
agents/recruitment/diagnostic/tools.yaml:171:  - xero           # Cash Conductor's territory (W7-8)
agents/recruitment/diagnostic/tools.yaml:172:  - quickbooks     # Cash Conductor's territory
agents/recruitment/diagnostic/tools.yaml:173:  - sage           # Cash Conductor's territory
agents/recruitment/diagnostic/tools.yaml:174:  - open_banking   # Cash Conductor's territory
agents/recruitment/concierge/agent.md:3:**Status:** Proposed (Day-19 pre-W10-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice).
agents/recruitment/concierge/agent.md:8:**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Drafts are orange-tier per `autosend-safety-policy.yaml` — consultant approval required before send via the autosend-bridge mechanism (Founder Decision D1 path A bridge OR D1-B shim OR D1-C manual; W10 design selects). Sends route via tenant's Microsoft Graph OR Gmail (per-tenant config; AgentMail deferred to v1.1+). Gate A hard-fails any draft generated >30 minutes after lifecycle event, any draft with voice classifier <0.75, or any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). Gate B success threshold: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:82:| 12 | 90-day check-in | Nurture-check-in + relationship | Candidate + Client | Establishes ongoing relationship; offers "is there anyone in your network looking?" |
agents/recruitment/concierge/agent.md:104:The actual SEND happens through the autosend-bridge (D1 path) — consultant approves → send routes through Microsoft Graph / Gmail; Bullhorn activity-log entry written post-send.
agents/recruitment/concierge/agent.md:159:     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
agents/recruitment/concierge/agent.md:193:      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
agents/recruitment/concierge/agent.md:194:    → per autosend-policy.yaml: orange-tier; consultant approves
agents/recruitment/concierge/agent.md:229:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 verbatim:
agents/recruitment/concierge/agent.md:314:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:322:| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
agents/recruitment/concierge/agent.md:347:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
agents/recruitment/concierge/agent.md:356:| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:804:            &mdash; share code <em>W12&nbsp;EX9&nbsp;A4T</em>, valid through Dec 2027.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:253:| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
docs/architecture/architecture-cohesion-review.md:74:| vault-concurrency.md §6 | ESC wiring | hook-helpers.sh::autosend_escalate | ✓ landed Phase 3 (e6e9df1) |
docs/architecture/architecture-cohesion-review.md:91:| A4 | **`ifos_app` Postgres role is the only role used by app code.** No path uses postgres superuser or admin role. | Day-4 §6.3 grants + RLS posture | If any path uses superuser, RLS is bypassed (RLS doesn't apply to superusers by default). |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:125:- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
docs/architecture/architecture-cohesion-review.md:128:- **Resolution path:** Founder Decision D3 in `2026-05-20-codex-round-1-founder-decisions.md`. Recommended D3-B (90-day text purge + indefinite metadata).
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:188:Tier-1 always-on candidate-lifecycle agent. No candidate ghosted, no client
docs/architecture/agent-bundle-renderer-design.md:380:- Operating window: 24/7 (Tier 1)
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:26:| 5 | Telegram + iOS approval surface | **shipped and tested** (Telegram); **aspirational** (iOS) | Every Tier-1 agent's escalation path |
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:66:**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.
docs/architecture/cortexos-primitive-status.md:107:- `src/daemon/fast-checker.ts:899-1003` — `checkContextStatus()` polls `${stateDir}/context_status.json` written by the `hook-context-status` statusLine bridge. Three tiers: Tier 1 warning at `ctx_warning_threshold` default 70% injects `[CONTEXT] Window at X%`, Tier 2 handoff at `ctx_handoff_threshold` default 80% writes the handoff prompt and `.force-fresh` marker (line 996-1000), Tier 3 force-restart 5 minutes after Tier 2 if the agent didn't comply (line 962-967).
docs/architecture/cortexos-primitive-status.md:136:# 2. Context-percentage handoff (Tier 2)
docs/architecture/cortexos-primitive-status.md:146:# 3. Tier 3 force-restart (deadline)
docs/architecture/cortexos-primitive-status.md:147:# After Tier 2 fires, wait 5 minutes without acting; expect "Handoff deadline exceeded — force restarting"
docs/architecture/cortexos-primitive-status.md:150:# Trigger Tier 3 more than the threshold within 15 min; expect "Context circuit breaker reset after 30min pause"
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:292:**Master-brief description:** Bot per agent, `.env` carries `BOT_TOKEN / CHAT_ID / ALLOWED_USER`; the escalation path for every Tier-1 agent (master brief §2.4 row 5).
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:325:- Product Spec §6.1 row 5: "Telegram + iOS approval surface — every Tier 1 agent's escalation path."
docs/architecture/cortexos-primitive-status.md:328:**Risk if flaky:** Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5 ("iOS in v1.2 is the marketing line, not a tech blocker"). Real risk is Telegram outage during a Cash Conductor escalation, which is exactly what the activity-channel + per-agent-bot belt-and-braces pattern (primitive 4 evidence, `approval.ts:222-226`) was built to mitigate after the "50h+ Repo-B-style stall" incident.
docs/architecture/vault-concurrency.md:397:**Status update 2026-05-20 (Day 8 Codex Round 1):** all 5 codes below are now catalogued at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`, Phase 1 of Week-1 slice) AND wired into the `autosend_escalate` helper at `agents/_shared/hook-helpers.sh` (commit `e6e9df1`, Phase 3 of Week-1 slice). The "_shared/hook-helpers.sh Week-1 prereq must wire these 5 codes" language below has been satisfied — current state is shipped + tested.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
packages/harness/cortextos/scripts/self-healing/usage-monitor.sh:7:# Tiers (tunable below):
docs/architecture/second-brain-design.md:203:| `wiki/raw/inbox-emails/` | one file per email | markdown with frontmatter | `{epoch}-{from-domain}-{rand5}.md` | inbound email webhook handler (v1.0: Cash Conductor for AR-relevant; v1.1: Triage for everything) | Brief Decoder (v1.1), Cash Conductor (v1.0); future Pulse semantic-search-over-raw |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:311:xero_contact_id: 9876                                # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:895:| **Failure mode if cortextOS daemon is unhealthy** | Wrappers don't depend on the daemon — they exec directly into Node. As long as Postgres is up and the filesystem is mounted, wiki ops succeed. Decision_log writes still go through (Postgres direct). Tracks per Ultraplan §3.5 "Tier 1 agents have degraded-mode fallbacks" — the wiki is part of the fallback substrate, not part of what fails. | If `ifos-wiki-mcp` crashes, every agent loses wiki access until it restarts. PM2 auto-restart bounds the outage to ~5s, but during the outage every wiki call fails. If `cortextos-daemon` is unhealthy, MCP connections from agents (which are in PTYs supervised by the daemon) may also be affected. Two-process dependency. | Same as α (library invoked directly, no daemon dependency) but adds skill-discovery path: if the agent's Claude Code session can't find the skill (e.g. corrupted scaffold), all wiki ops fail. |
docs/architecture/second-brain-design.md:975:| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` LANDED (Day 3, commit `78680cc`). New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) CATALOGUED at `agents/_shared/escalation-codes.md` §2.2 (Day 8 commit `a279226`) + WIRED into `agents/_shared/hook-helpers.sh::autosend_escalate` (Day 8 commit `e6e9df1`). | **Closed 2026-05-20.** Catalogue + wiring complete; ESC codes callable from any rendered agent. |
docs/operations/codex-ratification-guide.md:397:If `IFOS_DB_URL` isn't set when the wrapper runs (or psql isn't on PATH or the live DB rejects the write), the row appends to `logs/codex-ratification.jsonl` instead. Same shape, JSON Lines. Replays into Postgres later via the autosend-syncer worker (Week 5+).
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:43:## §2 — Tier model
docs/decisions/autosend-safety-policy.md:45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/autosend-safety-policy.md:143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
docs/decisions/autosend-safety-policy.md:159:  tier=$(autosend_policy_lookup "$action_type") || {
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
docs/decisions/autosend-safety-policy.md:166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:172:  # 3. Tier dispatch
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:180:      if autosend_should_sample "$action_type" "$tenant_slug"; then
docs/decisions/autosend-safety-policy.md:181:        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:187:      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
docs/decisions/autosend-safety-policy.md:189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:239:**Tier:** orange
docs/decisions/autosend-safety-policy.md:245:  "action_type": "<enum from autosend-policy.yaml>",
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:259:2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:282:**Tier:** red
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:301:2. `autosend_escalate ESC_AUTOSEND_BLOCKED` notifies tenant operator informationally (no action required)
docs/decisions/autosend-safety-policy.md:320:**Tier:** fail-safe-red (treated as red)
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:339:2. `autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED` notifies tenant operator AND IFOS oncall
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:353:| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:357:| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:379:-- For autosend audit:
docs/decisions/autosend-safety-policy.md:394:--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:430:  'autosend_policy',
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
docs/decisions/autosend-safety-policy.md:510:docs/decisions/autosend-safety-policy.md in the IFOS code repository)
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/operations/codex-round-2-handoff.md:66:### Tier 1 — Re-ratify Round-1 REJECTED (14 artefacts)
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:87:**Likely outcomes:** 11-12 of 14 RATIFY. Items #6 (autosend tier contradiction) and #14 (PII retention) are founder-decision-bound (D1/D3); Codex may RATIFY-with-advisory or REJECT pending decisions.
docs/operations/codex-round-2-handoff.md:89:### Tier 2 — Day-9 architecture+tenancy artefacts (4 new)
docs/operations/codex-round-2-handoff.md:100:### Tier 3 — Day-11 disagreement + decision + spec + D3 prep (8 new)
docs/operations/codex-round-2-handoff.md:107:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | `review-architecture-decision` | RATIFY (Proposed spec; alternatives weighed; ratifies cortextOS primitive-4 reuse) |
docs/operations/codex-round-2-handoff.md:124:# Tier 1 — re-ratify 14 previously REJECTED
docs/operations/codex-round-2-handoff.md:129:# Tier 2 — Day-9 new artefacts (run individually)
docs/operations/codex-round-2-handoff.md:135:# Tier 3 — Day-11 new artefacts
docs/operations/codex-round-2-handoff.md:139:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-handoff.md:168:  review, tenant lifecycle, founder decision briefing, 2 disagreement docs, autosend
docs/operations/codex-round-2-handoff.md:195:For Round-1-redux items (Tier 1): explicitly note whether the Round-1 issue
docs/operations/codex-round-2-handoff.md:199:For disagreement docs (Tier 3 items 19 + 20): you are evaluating recursive
docs/operations/codex-round-2-handoff.md:211:  docs/decisions/autosend-safety-policy.md
docs/operations/codex-round-2-handoff.md:231:  docs/decisions/autosend-approval-bridge-spec.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:240:| Tier | Artefact | Round-1 verdict | Round-2 verdict | Issue count | Output file |
docs/operations/codex-round-2-handoff.md:265:This is the expected case for most Tier 1 items. Mark as ratified in the manifest queue table:
docs/operations/codex-round-2-handoff.md:286:If Codex rejects a Tier 1 item again, two sub-cases:
docs/operations/codex-round-2-handoff.md:288:**Sub-case 2a: Same issue as Round 1** — incorporation didn't actually fix the root cause. Escalate to founder; reopen as a fresh issue. Likely candidates: autosend-safety-policy (D1 + D3 unresolved); v0.2 supplement (D3 unresolved).
docs/operations/codex-round-2-handoff.md:296:Expected for Tier 2 + most of Tier 3. Manifest queue marks as ratified. No further action.
docs/operations/codex-round-2-handoff.md:300:Tier 2/3 artefact rejected on first encounter. Read Codex output carefully:
docs/operations/codex-round-2-handoff.md:375:| Tier | Items | Mean time | Subtotal |
docs/operations/codex-round-2-remediation-prompt.md:238:  FIX 8 — autosend-approval-bridge-spec.md category mapping rewrite
docs/operations/codex-round-2-remediation-prompt.md:240:  File: docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-remediation-prompt.md:243:  Issue 2: new autosend_approval_mappings table not added to
docs/operations/codex-round-2-remediation-prompt.md:266:         new autosend_approval_mappings table as the 10th tenant-data
docs/operations/codex-round-2-remediation-prompt.md:280:  Fix: update §2 "Default retention window" to make the 90-day default
docs/operations/codex-round-2-remediation-prompt.md:297:  FLAG 1 — autosend-safety-policy.md tier contradiction
docs/operations/codex-round-2-remediation-prompt.md:306:  > the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`).
docs/operations/codex-round-2-remediation-prompt.md:311:  FLAG 2 — autosend-safety-policy.md legal placeholder
docs/operations/codex-round-2-remediation-prompt.md:332:    Claude analysis: D3-B (90-day text purge + indefinite metadata) with
docs/operations/codex-round-2-remediation-prompt.md:351:  Q5: When autosend_approval_mappings ships in v0.3 with the bridge
docs/operations/codex-round-2-remediation-prompt.md:352:  implementation (per docs/decisions/autosend-approval-bridge-spec.md),
docs/operations/codex-round-2-remediation-prompt.md:391:    - autosend-approval-bridge-spec.md  (FIX 8)
docs/operations/codex-round-2-remediation-prompt.md:472:        docs/decisions/autosend-approval-bridge-spec.md \
docs/operations/codex-round-2-remediation-prompt.md:473:        docs/decisions/autosend-safety-policy.md \
docs/operations/codex-round-2-remediation-prompt.md:509:    - autosend-approval-bridge-spec.md: category mapping rewritten using
docs/operations/codex-round-2-remediation-prompt.md:515:    - autosend-safety-policy.md §1 + §10: D1 + D2/D3 blocker annotations
docs/operations/codex-round-2-remediation-prompt.md:521:      subtle case + §6 Q5 autosend_approval_mappings table inventory
docs/operations/codex-round-2-remediation-prompt.md:549:  - Resolve D1 autosend orange-tier v1.0 path
docs/operations/codex-round-2-remediation-prompt.md:623:6. bullhorn-integration-path.md line 95 sharpening + Gate hierarchy subsection + disagreement doc closure + autosend-approval-bridge-spec.md category mapping rewrite + pii-purge-operational-pattern.md "Proposed pending D3"
docs/operations/codex-round-2-remediation-prompt.md:626:- FLAG 1: autosend-safety-policy.md §1 D1 annotation
docs/operations/codex-round-2-remediation-prompt.md:627:- FLAG 2: autosend-safety-policy.md §10 D2+D3 annotation
docs/operations/codex-round-2-remediation-prompt.md:631:- tenancy-invariants.md §2 T1 (nullability subtle case) + §6 Q5 (autosend_approval_mappings inventory)
docs/operations/codex-ratification-execution-plan.md:130:| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |
docs/operations/codex-ratification-execution-plan.md:167:| 25 | autosend-policy.yaml | `agents/_shared/autosend-policy.yaml` | A |
docs/operations/codex-round-2-autonomous-prompt.md:84:For Tier 1 (14 re-ratifications): the Round-1 verdict + remediation commit 
docs/operations/codex-round-2-autonomous-prompt.md:90:For Tier 3 disagreement docs (items 19 + 20 in §3): you are evaluating 
docs/operations/codex-round-2-autonomous-prompt.md:97:For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
docs/operations/codex-round-2-autonomous-prompt.md:113:  - Tier 1 (re-ratify): X RATIFIED / Y REJECTED of 14
docs/operations/codex-round-2-autonomous-prompt.md:114:  - Tier 2 (new Day-9): X RATIFIED / Y REJECTED of 4
docs/operations/codex-round-2-autonomous-prompt.md:115:  - Tier 3 (new Day-11): X RATIFIED / Y REJECTED of 8
docs/operations/codex-round-2-autonomous-prompt.md:119:  Columns: Tier | Path | Skill | Round-1 verdict | Round-2 verdict | 
docs/operations/codex-round-2-autonomous-prompt.md:160:For new artefacts (Tier 2 + Tier 3): disposition says "First ratification 
docs/operations/codex-round-2-autonomous-prompt.md:192:  Tier 1 (re-ratify Round-1 REJECTED): <X> of 14 flipped to RATIFIED.
docs/operations/codex-round-2-autonomous-prompt.md:193:  Tier 2 (Day-9 new artefacts): <X> of 4 RATIFIED.
docs/operations/codex-round-2-autonomous-prompt.md:194:  Tier 3 (Day-11 new artefacts): <X> of 8 RATIFIED.
docs/operations/codex-round-2-autonomous-prompt.md:219:  Tier 1: X/14 — most should have flipped from REJECTED → RATIFIED
docs/operations/codex-round-2-autonomous-prompt.md:220:  Tier 2: X/4
docs/operations/codex-round-2-autonomous-prompt.md:221:  Tier 3: X/8 (incl 2 disagreement-recursive verdicts)
docs/operations/codex-round-2-autonomous-prompt.md:253:4. **DO NOT make founder decisions.** Items like D1 (autosend orange tier), 
docs/operations/goal-week-3-polish-and-scaffold.md:24:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:29:14. **`agents/_shared/autosend-policy.yaml`** (29 action types; tier classifications)
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
docs/operations/goal-week-3-polish-and-scaffold.md:302:- **Tier:** Tier 1 (batch nightly cron; not request-driven) per `sequencing-target.md` §2.1
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:337:- **Tier:** Tier 2 (request-driven, per-call invocation) per `sequencing-target.md` §2.1
docs/operations/goal-week-3-polish-and-scaffold.md:352:### DAY 18 — Cash Conductor agent.md scaffold (Step 10)
docs/operations/goal-week-3-polish-and-scaffold.md:357:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:360:- `vertical-schema.yaml` §3 agent_access_matrix Cash Conductor row
docs/operations/goal-week-3-polish-and-scaffold.md:361:- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:366:- **Tier:** Tier 1 (batch daily; cron-driven)
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:371:- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
docs/operations/goal-week-3-polish-and-scaffold.md:379:Commit: `decision(pre-build): agents/recruitment/cash-conductor/agent.md — output contract per ULTRAPLAN §8.1 A4`
docs/operations/goal-week-3-polish-and-scaffold.md:394:- **Tier:** Tier 2 (request-driven per brief)
docs/operations/goal-week-3-polish-and-scaffold.md:409:#### Step 12 — `agents/recruitment/concierge/agent.md` (~3-4 hours; most complex due to autosend orange-tier)
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:414:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
docs/operations/goal-week-3-polish-and-scaffold.md:421:- **Tier:** Tier 1 (continuous; lifecycle-event-driven via Bullhorn poll cycle)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:459:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:618:  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:648:    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/goal-week-3-polish-and-scaffold.md:649:    - Cash Conductor build (full bundle)
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/decisions/v1.0-kill-criterion.md:113:**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
docs/decisions/v1.0-kill-criterion.md:117:**Escalation path:** If three pilots experience this trigger within one quarter, escalate to system-wide PAUSE while structural autosend policy redesign happens (potential v1.1 advancement of orange tier).
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:188:**Threshold:** ANY confirmed incident in which agent action results in PII (personally-identifiable information per UK GDPR Art. 4(1)) transmitted to an unauthorised party (cross-tenant recipient, unauthorised external recipient, or recipient outside tenant's declared data residency) AND not blocked by the RLS + autosend policy combination.
docs/decisions/v1.0-kill-criterion.md:196:**Action:** KILL. Rationale: multi-tenant trust is the structural foundation of v1.0. A single confirmed PII breach beyond the RLS + autosend boundary indicates the foundation is unsound. Continuing operation risks (a) further breaches, (b) regulatory action, (c) catastrophic loss of pilot trust. Wind-down protects existing pilots from further exposure.
docs/decisions/v1.0-kill-criterion.md:235:**Must-fill before first pilot LOI signs.** The pilot agreement may reference an external advisor for dispute resolution per `autosend-safety-policy.md` §10 placeholder language. Founder identifies and engages within Weeks 1-2.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:337:- The autosend safety policy per this Day 5 commit (green + red tiers only)
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/decisions/v1.0-kill-criterion.md:387:**For atomic-correction manifest.** Edit 10 (shared with autosend-safety-policy.md) adds the path drift correction. Manifest grows from 9 to 10.
docs/operations/seedlegals-engagement-queries.md:29:**Recommended Tier 1 (pre-LOI minimum):** LOI template + DPA template + Mutual NDA = ~£500, all delivered within 72h.
docs/operations/seedlegals-engagement-queries.md:31:**Recommended Tier 2 (post-pilot):** Full SaaS subscription agreement + customer-grade DPA — engage when first pilot converts to paid customer. Higher-stakes; consider specialist firm.
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
docs/operations/seedlegals-engagement-queries.md:154:- Lawful basis for AI-training retention beyond 90-day operational window
docs/operations/founder-legal-setup-guide.md:122:3. *"My pilot tenants will store free-text edits from consultants reviewing AI drafts. These edits may contain candidate PII. I'm planning a 90-day raw-text retention then bounded purge. Is 90 days defensible under UK GDPR Art. 5(1)(e) data minimisation for this use case?"*
docs/operations/founder-legal-setup-guide.md:229:> Would you provide a quote? Happy to share more about our autosend-safety-policy on a call.
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
packages/harness/cortextos/package-lock.json:194:      "integrity": "sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==",
packages/harness/cortextos/package-lock.json:245:      "integrity": "sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==",
packages/harness/cortextos/package-lock.json:466:      "integrity": "sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==",
packages/harness/cortextos/package-lock.json:805:      "integrity": "sha512-zYyqWgGQi3NhBcNq4Isc5rB3oEdQEh1Q/EcAnOW0FK4MpnXWkvSBYgA4cYrTM4A9UB573omouZbnL9JJ74Mq3A==",
packages/harness/cortextos/package-lock.json:1275:      "integrity": "sha512-L+34Qqil+v5uC0zEubW7uByo78WOCIrBvci69E7sFASRl0X7b/MB6Cqd1lky/CtcSVTydWa2WZwFuWexjS5o6g==",
packages/harness/cortextos/package-lock.json:1485:      "integrity": "sha512-i1okWYkA4FJICtr7KpYzFpRTHgy5jdDbZiWfvny21iIKky5YExiDXP+zbXzm3dUcFpkEeYNHgQ5fuG236JPq0g==",
packages/harness/cortextos/package-lock.json:1612:      "integrity": "sha512-Ize4iQtEALHDttPRCmN+FKqOl2vxTiNUhzobQFFt/BM1lRUTG7zRCLOykG/6Vo4E4hnUdfVLo5/eqKPukcWW7Q==",
packages/harness/cortextos/package-lock.json:2118:      "integrity": "sha512-34wB/Y7MW7bzjKRjUKTa46I2Z7eV62Rkhva+KkopW7Qvv/OSWBqvkSY7vusOPrNuZcUG3tApvdVgNB8POj3SPw==",
packages/harness/cortextos/package-lock.json:3149:      "integrity": "sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==",
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:135:| 1. Implementation simplicity | **Medium-High** | Ultraplan §8.1 line 541 estimate **L (2 weeks)**. Three accounting integrations (Xero / QuickBooks / Sage — one per tenant per Ultraplan §8.1 line 537). Open Banking auth complexity (90-day token rotation per Ultraplan §8.1 line 542 gotcha). Tier 1 always-on (cortextOS Primitive 1 dependency) |
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:142:**Hire-#1 anchor (per Ultraplan §9 line 766 verbatim):** "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)." Cash Conductor's three-accounting-API + Open-Banking integration is the right scope for Hire #1's first sprint per Ultraplan §9 — this places Cash Conductor at W7-8 in the canonical sequence.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:184:W7-8: Cash Conductor (A4) — Hire-#1-anchored per Ultraplan §9 line 766
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:194:- W7-8: Risk #1 (cortextOS Primitives 1+4+5) — Cash Conductor first Tier-1. Reduction trigger fires.
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:230:W6-9: Concierge (A6) — Risk #1 derisk via Tier-1 + Primitive 2 first exercise
docs/decisions/sequencing-target.md:232:W11:  Cash Conductor (A4)
docs/decisions/sequencing-target.md:236:**Why this ordering:** Front-load risk-de-risking by building Concierge (the most Primitive-heavy agent) early. Cash Conductor's Risk #1 exercise becomes redundant if Concierge already exercises Primitives 1+2+4+5.
docs/decisions/sequencing-target.md:240:1. **Concierge depends on Scribe** for Notes-for-context (per `bullhorn-integration-path.md` §4.1 row 4 — Concierge reads Notes Scribe wrote). Building Concierge at W6-9 before Scribe (W10) means Concierge's first-month operation has empty Note context. Materially degrades the Tier-1 always-on demo.
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:242:3. **Hire-#1 anchor broken.** Cash Conductor at W11 is 4 weeks after Hire #1's assumed W7 start. Hire #1 again has no first-sprint scope.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:307:**Trigger 2 — Risk #4 materialises (Hire #1 doesn't start by end of Week 4).** Per RISK-REGISTER #4 tripwire "No offer accepted by end of week 4":
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:334:- Whether Cash Conductor's 2-week build can compress if Hire #1 onboarding is fast — deferred to Week 7 Cash-Conductor-kickoff check-in.
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:449:- §4.3 revisit conditions name specific tripwires (Risk #2, Risk #4, Hire #1) and concrete activation actions (decider + updates required + cascade).
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:491:| Revisit conditions | §4.3 | Three triggers named (Risk #2, Risk #4, Hire #1) with decider + activation + updates + cascade per trigger |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
packages/agent-renderer/README.md:120:- **Telegram-down hang for orange-tier autosend** (autosend-safety-policy §5) is a Phase-3 concern in `hook-helpers.sh` `autosend_await_approval`, not a renderer concern. Documented for completeness.
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/runbooks/operational-hygiene-protocol.md:26:- **Length discipline C+** — Day 5 autosend policy 658 lines vs 300-500 estimate; Day 6 vertical schema 899 lines vs same estimate
docs/runbooks/operational-hygiene-protocol.md:150:- Day 5 autosend policy: estimated 300-500 lines; actual 648. **+30% to +116% overshoot.**
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:275:| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/operational-hygiene-protocol.md:290:Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.
docs/runbooks/tenant-lifecycle.md:33:                                                │  (90-day legal hold │
docs/runbooks/tenant-lifecycle.md:153:| Spot-check operator review | `autosend_spot_check_enqueue` writes to `/vault/<slug>/spot-checks/<file>.md`; operator reviews + flags as approved/rejected/escalate | (No invariant violation) |
docs/runbooks/tenant-lifecycle.md:218:### 90-day legal hold
docs/runbooks/tenant-lifecycle.md:225:**v1.0 default:** 90-day legal hold + tenant-controlled retention beyond.
docs/runbooks/tenant-lifecycle.md:390:| L7 | 90-day purge cron (currently manual) | Low | Automation at v1.1+ when offboarding becomes routine | First offboarding cycle complete |
docs/runbooks/pii-purge-operational-pattern.md:159:| Disk full during audit row write | UPDATE succeeds; audit row write fails; orphaned purge | Decision_log fallback to JSONL at `/var/log/ifos/decision-log.jsonl`; replay via autosend-syncer when disk recovers |
docs/build-brief/00-MASTER-BRIEF.md:465:- [ ] Hire #1 status one-liner
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:600:| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:843:| 1 | CortexOS primitives 3 or 4 are flaky in production | Daily orchestrator health check flags > 1 incident/week | Every Tier-1 agent has a degraded-mode fallback (drafts-only, scheduled retry) that runs if cortextOS state is unhealthy; manual file-bus handoff documented |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/build-brief/00-MASTER-BRIEF.md:986:6. **The quality gates** — Gate A binary per-run, Gate B 90-day, Gate C weekly voice classifier
docs/specs/ULTRAPLAN.md:4:**Audience:** Maddox first. Future co-founder / Hire #1 second. The senior engineer who reads this in week six and needs to know what to do without asking.
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:107:- Every Tier 1 agent has a "degraded mode" fallback (drafts-only, no auto-send, scheduled retry) that runs if CortexOS state is unhealthy.
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:267:**Tier change** (e.g., Boutique → Growth):
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:473:Always-on? (Tier 1 / Tier 2)
docs/specs/ULTRAPLAN.md:504:- **Always-on?** Tier 2 — scheduled nightly cron
docs/specs/ULTRAPLAN.md:518:- **Always-on?** Tier 2 — webhook-driven
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:532:- **Always-on?** Tier 1 — persistent watcher on accounting + bank webhooks
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:539:- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
docs/specs/ULTRAPLAN.md:541:- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
docs/specs/ULTRAPLAN.md:546:- **Always-on?** Tier 2 — request-response
docs/specs/ULTRAPLAN.md:560:- **Always-on?** Tier 1 — persistent state across the candidate lifecycle
docs/specs/ULTRAPLAN.md:576:- **Always-on?** Tier 1 — the highest 24/7 agent
docs/specs/ULTRAPLAN.md:590:- **Always-on?** Tier 1
docs/specs/ULTRAPLAN.md:601:#### A9. Real-time Cash Conductor reframe (2 weeks)
docs/specs/ULTRAPLAN.md:603:Already specified in §8.1 A4 as v1.0. The v1.1 work is the reframe of pitch and any latency optimisations needed once we have 3+ tenants in production. Not a new build, ~3 days of polish.
docs/specs/ULTRAPLAN.md:608:- **Always-on?** Tier 1
docs/specs/ULTRAPLAN.md:622:- **Always-on?** Tier 1 — overnight autoresearch is the canonical use case
docs/specs/ULTRAPLAN.md:636:- **Always-on?** Tier 1
docs/specs/ULTRAPLAN.md:650:- **Always-on?** Tier 1
docs/specs/ULTRAPLAN.md:688:| Cash Conductor | ✓ | | | ✓ | | | | | | ✓ | Open Banking |
docs/specs/ULTRAPLAN.md:713:7. **Xero / QuickBooks / Sage** — 4 of 18 (one per tenant typically). Cash Conductor's blocker.
docs/specs/ULTRAPLAN.md:722:- Maddox solo for weeks 0–6; Hire #1 starts week 7 (per the most plausible reading of the user's memory, with caveat in §10).
docs/specs/ULTRAPLAN.md:764:### Weeks 7–8 — Cash Conductor + Hire #1 onboards
docs/specs/ULTRAPLAN.md:766:- Week 7: Hire #1 onboards (assumed); Xero MCP + Open Banking integration
docs/specs/ULTRAPLAN.md:767:- Week 8: Cash Conductor agent; chase-cadence config; tenant-level baseline DSO captured
docs/specs/ULTRAPLAN.md:769:Milestone: Cash Conductor running in shadow mode against first pilot's accounting data.
docs/specs/ULTRAPLAN.md:800:5. Cash Conductor's escalation-tier-3 (bad debt write-off draft) — manual until 6 months in
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:821:| 5 | Open Banking integration takes more than 1 week | Medium | Medium | End of week 7 status not "Xero + first bank connected" | Cash Conductor ships with manual reconciliation in v1.0; webhook-driven mode at v1.1 |
docs/specs/ULTRAPLAN.md:855:- [ ] Hire #1 status one-liner. **Owner:** Maddox.
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/specs/_archive-build-handoff.md:382:| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/PRODUCT-SPEC.md:39:Eight Tier 1 agents are genuinely always-on and structurally need CortexOS primitives. The rest are scheduled, batch, or webhook-driven and live inside the same runtime to share infrastructure but are not marketed as 24/7. This is the structural integrity rule that keeps the product credible with FD-level buyers.
docs/specs/PRODUCT-SPEC.md:47:| Product line | What it serves | Number of agents | Tier range |
docs/specs/PRODUCT-SPEC.md:60:- **Always-on?** — Tier 1 (CortexOS-required) vs Tier 2 (scheduled / batch)
docs/specs/PRODUCT-SPEC.md:61:- **Tier availability** — which subscription tier unlocks it
docs/specs/PRODUCT-SPEC.md:69:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:70:- **Tier availability:** Solo (drafts-only, no auto-send) / Boutique+ (full auto-send).
docs/specs/PRODUCT-SPEC.md:73:#### R2. Real-Time Cash Conductor — the FD's evenings back
docs/specs/PRODUCT-SPEC.md:76:- **Revenue story:** "DSO drops by 15+ days. £40k–£120k of working capital unlocked for a mid-sized agency. One bad debt caught per quarter pays for the entire suite."
docs/specs/PRODUCT-SPEC.md:78:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:79:- **Tier availability:** Boutique+.
docs/specs/PRODUCT-SPEC.md:88:- **Always-on?** Digest is Tier 2 (cron). Competitor Interception is Tier 1.
docs/specs/PRODUCT-SPEC.md:89:- **Tier availability:** Boutique (digest) / Growth+ (Competitor Interception).
docs/specs/PRODUCT-SPEC.md:97:- **Always-on?** Tier 1 (overnight autoresearch is the canonical use case).
docs/specs/PRODUCT-SPEC.md:98:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:106:- **Always-on?** Tier 2 (request-response).
docs/specs/PRODUCT-SPEC.md:107:- **Tier availability:** Boutique+.
docs/specs/PRODUCT-SPEC.md:115:- **Always-on?** Tier 2 (webhook-driven).
docs/specs/PRODUCT-SPEC.md:116:- **Tier availability:** All tiers including Solo. This is the data spine.
docs/specs/PRODUCT-SPEC.md:124:- **Always-on?** Tier 1 (downstream handoff target from Triage; needs persistent state across the candidate lifecycle).
docs/specs/PRODUCT-SPEC.md:125:- **Tier availability:** Boutique+.
docs/specs/PRODUCT-SPEC.md:133:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:134:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:142:- **Always-on?** Tier 2 (scheduled nightly batch).
docs/specs/PRODUCT-SPEC.md:143:- **Tier availability:** Solo+ (with one-off £1,500 setup-cleanup fee on Starter/Growth, waived on Scale).
docs/specs/PRODUCT-SPEC.md:151:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:152:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:160:- **Always-on?** Tier 2 (scheduled weekly batch).
docs/specs/PRODUCT-SPEC.md:161:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:169:- **Always-on?** Tier 2 (scheduled monthly cron).
docs/specs/PRODUCT-SPEC.md:170:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:177:- **Always-on?** Tier 2 (request-driven; runs on demand).
docs/specs/PRODUCT-SPEC.md:178:- **Tier availability:** Free pre-sales tool for prospects; not on the customer pricing card.
docs/specs/PRODUCT-SPEC.md:189:- **Always-on?** Tier 2.
docs/specs/PRODUCT-SPEC.md:190:- **Tier availability:** Compliance + Operations and above.
docs/specs/PRODUCT-SPEC.md:197:- **Always-on?** Tier 1 (off-hours work is the entire arbitrage).
docs/specs/PRODUCT-SPEC.md:198:- **Tier availability:** Compliance + Operations and above.
docs/specs/PRODUCT-SPEC.md:205:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:206:- **Tier availability:** Compliance Core (T5 only) doesn't include T3. Compliance + Operations and above includes it.
docs/specs/PRODUCT-SPEC.md:213:- **Always-on?** Tier 2 (scheduled per contract event).
docs/specs/PRODUCT-SPEC.md:214:- **Tier availability:** Full Temp Sub-Platform.
docs/specs/PRODUCT-SPEC.md:221:- **Always-on?** Tier 1 (continuous monitoring).
docs/specs/PRODUCT-SPEC.md:222:- **Tier availability:** Compliance Core (sold standalone) and Full Temp.
docs/specs/PRODUCT-SPEC.md:229:- **Always-on?** Tier 2.
docs/specs/PRODUCT-SPEC.md:230:- **Tier availability:** Full Temp.
docs/specs/PRODUCT-SPEC.md:240:| Tier | Monthly | Agents included | The single ROI promise |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:249:| Tier | Monthly | Agents included | The single ROI promise |
docs/specs/PRODUCT-SPEC.md:345:- Cash Conductor runs against historical invoices — produces the DSO baseline.
docs/specs/PRODUCT-SPEC.md:374:- **Per-customer compute cost: ~£200/month for full Tier 1 deployment** (per the CortexOS directive's unit-economics work). At Boutique £1,495/mo this is 13% COGS; at Growth £3,250/mo this is 6%; healthy at every tier above Solo's three-agent gate.
docs/specs/PRODUCT-SPEC.md:392:### 6.1 The seven CortexOS primitives every Tier 1 agent uses
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:401:| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
docs/specs/PRODUCT-SPEC.md:402:| 5 | Telegram + iOS approval surface | Every Tier 1 agent's escalation path |
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:474:- Cash Conductor (real-time mode)
docs/specs/PRODUCT-SPEC.md:523:2. **Real-Time Cash Conductor** — "DSO drops by 15+ days, working capital unlocked."
docs/_supplementary/build-plan-original.md:200:- **Tier 1 (always present)** — `CLAUDE.md` (4KB max). Client name, industry, voice summary, key people, brand do/don'ts. This is the brain stem.
docs/_supplementary/build-plan-original.md:201:- **Tier 2 (task-specific, retrieved)** — for a Proposal Builder session, pull 3 past winning proposals semantically similar to this prospect's industry and deal size. Retrieved via pgvector query against the vault.
docs/_supplementary/build-plan-original.md:202:- **Tier 3 (explicit, linked)** — if the triggering event references specific documents (e.g., "draft proposal for the deal at HubSpot deal-id 12345"), pull that deal's full history.
docs/_supplementary/build-plan-original.md:223:- Tier 1: ~1,500 tokens
docs/_supplementary/build-plan-original.md:224:- Tier 2: ~3,000 tokens (5 notes × 600 tokens avg)
docs/_supplementary/build-plan-original.md:225:- Tier 3: ~5,000 tokens when triggered
docs/_supplementary/build-plan-original.md:228:Total context per invocation: 10–25k tokens typical. With prompt caching on the Tier 1 + Tier 2 stuff that's shared across invocations, effective cost is ~10% of input rate. This is how the £80–180/mo per tenant cost target holds.
docs/_supplementary/build-plan-original.md:290:- **Kaspr API** — LinkedIn-sourced mobile numbers (Tier 2+ only; not cheap enough for Tier 1)
docs/_supplementary/build-plan-original.md:514:- Have had no activity for >7 days (Tier 1 clients) or >3 days (aggressive pipelines)
docs/_supplementary/build-plan-original.md:590:**Sonnet 4.6** baseline. Opus 4.7 for Tier 2+ clients whose voice is highly distinctive or technical.
docs/_supplementary/build-plan-original.md:814:- Last 7 days of data from: Stripe, GA4, Meta Ads, Google Ads, HubSpot, CRM, LinkedIn Ads, Shopify (if retail client), Klaviyo, etc.
docs/_supplementary/build-plan-original.md:821:- **GA4 MCP** — traffic + conversion
docs/_supplementary/build-plan-original.md:977:- **Ahrefs / SEMrush API** (paid, passed through to client — OR build against free DataForSEO tier for Tier 1)
docs/_supplementary/build-plan-original.md:1261:| GA4 | No official | Build your own wrapper |
docs/_supplementary/strategic-plan.md:34:**Tier 1 — Core SME (priced £3–8k setup + £500–£2,000/mo retainer):**
docs/_supplementary/strategic-plan.md:41:**Tier 2 — Specialist vertical (priced £8–20k setup + £2k–5k/mo):**
docs/_supplementary/strategic-plan.md:48:**Tier 3 — Enterprise (priced £50k–250k setup + £5k–20k/mo):**
docs/_supplementary/strategic-plan.md:92:8. **Reporting Engine** — pulls from Stripe, GA4, Meta Ads, CRM. Delivers weekly briefing in-Slack + PDF
docs/_supplementary/strategic-plan.md:174:│    Notion, GA4, Meta Ads, Stripe, Calendly, Dentally        │
docs/_supplementary/strategic-plan.md:194:For a typical Tier 1 SME client running the nine agents:
docs/_supplementary/strategic-plan.md:203:| **Retainer (Tier 1)** | **£800–£2,000/mo** |
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
docs/_supplementary/strategic-plan.md:404:| Tier | Setup | Monthly | What's included |
docs/_supplementary/planning-phase-brief.md:38:| **CC9** | **Custom MCP Servers (6 of them)** — DocuSign, GA4, Meta Ads, Companies House, Prospeo, Dentally | Python (FastMCP) or TypeScript | §3.8 (six of the 15 integration specs) |
docs/_supplementary/planning-phase-brief.md:178:- Session 25: Integration Specs Batch 2 — Stripe, GA4, Meta Ads, Cal.com (3.8)
docs/_supplementary/technical-strategy-v2.md:259:0 7 * * 5 cd /tenant && claude -p "Run the Reporting Engine. Pull last 7 days from Stripe, GA4, Meta Ads, and HubSpot. Produce the weekly briefing. Save to /outbox/reports/. Post the summary to #leadership in Slack." --output-format json >> /logs/reporting-$(date +\%Y\%m\%d).log 2>&1
docs/_supplementary/technical-strategy-v2.md:463:Tier 0 — Founding customers (first 5)                     £2.5k setup · £800/mo
docs/_supplementary/technical-strategy-v2.md:466:Tier 1 — SME direct                                       £3–7.5k · £800–2k/mo
docs/_supplementary/technical-strategy-v2.md:471:Tier 2 — Operator direct (highest-ROI ICP)                £5–15k · £1.5–3k/mo
docs/_supplementary/technical-strategy-v2.md:476:Tier 3 — Agency Partner (the distribution lever)          £15k · £5k/mo + seats
docs/_supplementary/technical-strategy-v2.md:480:Tier 4 — Enterprise                                       £50k+ · £5k+/mo
docs/_supplementary/technical-strategy-v2.md:489:Sell Tier 1 for volume. Sell Tier 2 for fit. Sell Tier 3 for leverage. Sell Tier 4 for the brand.
docs/_supplementary/technical-strategy-v2.md:590:6. **ICP expansion:** agencies and course sellers are added as Tier 2. Agency Partner white-label becomes the Tier 3 distribution lever.
docs/_supplementary/execution-plan.md:291:  - *Prompt per integration:* "Write the {Integration Name} Integration Specification: the MCP server choice (fork X / build from Y spec / official), auth setup (OAuth flow or API key), the scopes/permissions required and why, the specific operations used by agents (read leads, write deals, fetch transcript, etc.), fallback behaviour on failure, test checklist, rate limit handling. Priority 1 integrations: Fathom, HubSpot, Gmail, Slack, Notion, DocuSign. Priority 2: Companies House, Prospeo, Kaspr, Stripe, GA4, Meta Ads, Cal.com, Loom, Google Drive."
packages/agent-renderer/pnpm-lock.yaml:178:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/agent-renderer/pnpm-lock.yaml:232:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/agent-renderer/pnpm-lock.yaml:448:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/agent-renderer/pnpm-lock.yaml:529:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/agent-renderer/pnpm-lock.yaml:693:    resolution: {integrity: sha512-8iUql50EUR+uUcdRQ3HDqa6EVyo3docL8g5WJ3FNcWmu62IbkGUue/pEyLBW8VGKKucTPgqeks4fIU1DA4yowQ==}
packages/agent-renderer/pnpm-lock.yaml:732:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/agent-renderer/pnpm-lock.yaml:736:    resolution: {integrity: sha512-Vw8qHK3bZM9y/P10u3Vib8o/DdkvA2OtPtZvD871QKjy74Wj1WSKFILMPRPSdUSx5RFK1arlJzEtA4PkFgnbuA==}
packages/agent-renderer/pnpm-lock.yaml:812:    resolution: {integrity: sha512-34wB/Y7MW7bzjKRjUKTa46I2Z7eV62Rkhva+KkopW7Qvv/OSWBqvkSY7vusOPrNuZcUG3tApvdVgNB8POj3SPw==}
packages/agent-renderer/pnpm-lock.yaml:1050:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/agent-renderer/tests/fixtures/test-agent/tools.yaml:11:autosend_categories: []
packages/mcp-connectors/companies-house/pnpm-lock.yaml:162:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:216:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:432:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:513:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:699:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:769:    resolution: {integrity: sha512-34wB/Y7MW7bzjKRjUKTa46I2Z7eV62Rkhva+KkopW7Qvv/OSWBqvkSY7vusOPrNuZcUG3tApvdVgNB8POj3SPw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:996:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:104:## Limits (Free Tier)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:38:## Three-Tier Protocol
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:40:### Tier 1 — Wind-Down (>= 85% utilization)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:49:- Check usage every 5 minutes until dropping below 85% or escalating to Tier 2
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:55:### Tier 2 — Minimal (85-95% utilization)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:70:### Tier 3 — Dark (>= 95% utilization)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:115:- `--warn-7day 75` — early warning at 75% (10 points before Tier 1)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:138:| Utilization | Tier | Behavior |
packages/harness/cortextos/dashboard/package-lock.json:546:      "integrity": "sha512-LwdZHpScM4Qz8Xw2iKSzS+cfglZzJGvofQICy7W7v4caru4EaAmyUuO6BGrbyQ2mYV11W0U8j5mBhd14dd3B0A==",
packages/harness/cortextos/dashboard/package-lock.json:926:      "integrity": "sha512-S48WzZW777zhNIrn7gxOlISNAqi9ZC/uQFnRdbeIHhZhCA6UqpkOT8T1G7BvfdgP4Er8gF4sUbaS0i7QvIfCWw==",
packages/harness/cortextos/dashboard/package-lock.json:3243:      "integrity": "sha512-4og1V+ftEPXGttOO7eCmW7VICmzzJWgMx+QXAJRAhjrSjumCwWqMfkDrNu1LXEQzNAwz28NCUpucgQPrR4S2yw==",
packages/harness/cortextos/dashboard/package-lock.json:3515:      "integrity": "sha512-NcV1JjO5oDzoK26oMzbILE6HW7uVXOHLQvHshBUW4UMdZGfiY6v5BeQwh9a9tCzv+CeefZQHJt5SRgK154RtiA==",
packages/harness/cortextos/dashboard/package-lock.json:3521:      "integrity": "sha512-mgLPETlrpVV1YRJIglr4Ez47g7Yxjl1lj7YKsiMCb27VJH9W8NVM6Bb9d8kkpG/uAQS5AmbA48q2IAolKKo1MA==",
packages/harness/cortextos/dashboard/package-lock.json:4057:      "integrity": "sha512-34gw7PjDGB9JgePJEmhEqBhWvCiiWCuXsL9hYphDF7crW7UgI05gyBAi6MF58uGcMOiOqSJ2ybEeCvHcq0BCmQ==",
packages/harness/cortextos/dashboard/package-lock.json:4085:      "integrity": "sha512-D8Vae74A4/a+mZH0FbOkFJL9DSK2R6TFPC9M+jCWYia/q2einCubX10pecpDiTmkJVUH+y8K3BZClycD8nCShA==",
packages/harness/cortextos/dashboard/package-lock.json:4099:      "integrity": "sha512-frxL4OrzOWVVsOc96+V3aqTIQl1O2TjgExV4EKgRY09AJ9leZpEg8Ak9phadbuX0BA4k8U5qtvMSQQGGmaJqcQ==",
packages/harness/cortextos/dashboard/package-lock.json:4246:      "integrity": "sha512-Ize4iQtEALHDttPRCmN+FKqOl2vxTiNUhzobQFFt/BM1lRUTG7zRCLOykG/6Vo4E4hnUdfVLo5/eqKPukcWW7Q==",
packages/harness/cortextos/dashboard/package-lock.json:4403:      "integrity": "sha512-8iUql50EUR+uUcdRQ3HDqa6EVyo3docL8g5WJ3FNcWmu62IbkGUue/pEyLBW8VGKKucTPgqeks4fIU1DA4yowQ==",
packages/harness/cortextos/dashboard/package-lock.json:5130:      "integrity": "sha512-IV3Ou0jSMzZrd3pZ48nLkT9DA7Ag1pnPzaiQhpW7c3RbcqqzvzzVu+L8gfqMp/8IM2MQtSiqaCxrrcfu8I8rMA==",
packages/harness/cortextos/dashboard/package-lock.json:6575:      "integrity": "sha512-KmfKL3b6G+RXvP8N1vr3Tq1kL/oCFgn2NYXEtqP8/L3pKapUA4G8cFVaoF3SU323CD4XypR/ffioHmkti6/Tag==",
packages/harness/cortextos/dashboard/package-lock.json:6633:      "integrity": "sha512-CRT1WTyuQoD771GW56XEZFQ/ZoSfWid1alKGDYMmkt2yl8UXrVR4pspqWNEcqKvVIzg6PAltWjxcSSPrboA4iA==",
packages/harness/cortextos/dashboard/package-lock.json:7700:      "integrity": "sha512-gNCGbnnnnFAUGKeZ9PdbyeGYJqewpmc2aKHUEMO5nQPWU9lOmv7jcmQIv+qHD8fXW6W7qfuCwX4rY9LNRjXrkQ==",
packages/harness/cortextos/dashboard/package-lock.json:8842:      "integrity": "sha512-0KpjqXRVvrYyCsX1swR/XTK0va6VQkQM6MNo7PqW77ByjAhoARA8EfrP1N4+KlKj8YS0ZUCtRT/YUuhyYDujIQ==",
packages/harness/cortextos/dashboard/package-lock.json:8984:      "integrity": "sha512-abv/qOcuPfk3URPfDzmZU1LKmuw8kT+0nIHvKrKgFrwifol/doWcdA4ZqsWQ8ENrFKkd67Mfpo/LovbIUsbt3w==",
packages/harness/cortextos/dashboard/package-lock.json:9529:      "integrity": "sha512-8u/hfXFRBD1O0hPUjioLhoWFHRmt6tKA4/vZPyckBr18l1KE9uHrFaFaUi8MDRTpi4uak2goyPTSNJLXX2k2Hw==",
packages/harness/cortextos/dashboard/package-lock.json:9645:      "integrity": "sha512-smsWv2LzFjP03xmvFoJ331ss6h+jixfA4UUV/Bsiyuu4YJPfN+FIQGOIiv4w9/+MoHkfkJ22UIaQWRVFRfH6Vw==",
packages/harness/cortextos/dashboard/package-lock.json:10109:      "integrity": "sha512-24e6ynE2H+OKt4kqsOvNd8kBpV65zoxbA4BVsEOB3ARVWQki/DHzaUoC5KuON/BiccDaCCTZBuOcfZs70kR8bQ==",
packages/harness/cortextos/dashboard/package-lock.json:11542:      "integrity": "sha512-9QNk5KwDF+Bvz+PyObkmSYjI5ksVUYtjW7AU22r2NKcfLJcXp96hkDWU3+XndOsUb+AQ9QhfzfCT2O+CNWT5Tw==",
packages/harness/cortextos/dashboard/package-lock.json:11576:      "integrity": "sha512-KWBIxs1Xb6NoLdMVqhbhgwZf2PGBpPEiwOqgI4pFIYbNTfBXiKYyWoTsXgBQ9WFg/OlhnvHaY+AEpW7wSmFo2Q==",
packages/harness/cortextos/dashboard/package-lock.json:11836:      "integrity": "sha512-7bziOlRqH0hJx80h/3mbicLW7o8qLsH5+RaLR2t+OHM3D0JlWGODQKQ4cxbK7WlvmUxpcj6Kgu6EKqjrGFe3QQ==",
packages/harness/cortextos/dashboard/package-lock.json:12450:      "integrity": "sha512-o8qghlI8NZHU1lLPrpi2+Uq7abh4GGPpYANlalzWxyWteJOCsr/P+oPBA49TOLu5FTZO4d3F9MnWJfiMo4BkmA==",
packages/harness/cortextos/dashboard/package-lock.json:12720:      "integrity": "sha512-JZnDKK8B0RCDw84FNdDAIpZK+JuJw+s7Lz8nksI7SIuU3UXJJslUthsi+uWBUYOwPFwW7W7PRLRfUKpxjtjFCw==",
packages/harness/cortextos/dashboard/package-lock.json:12759:      "integrity": "sha512-tVpsJW7DdjecAiFpbIB1e3qxIQsE6NoPc5/eTdrbbIC4h0LVsWhnoa3g+m2HclBIujHzsxZ4VJVA+GUuc2/LBw==",
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:70:  function selectTier(pct: number, exceeds: boolean, warningFiredAt: number, handoffFiredAt: number, now: number) {
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:74:    // Tier 2 check (handoff) — must check before warning for edge cases
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:77:    // Tier 1 check (warning) — 15min cooldown
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:84:    expect(selectTier(69, false, 0, 0, Date.now())).toBe('none');
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:88:    expect(selectTier(70, false, 0, 0, Date.now())).toBe('warning');
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:92:    expect(selectTier(79, false, 0, 0, Date.now())).toBe('warning');
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:96:    expect(selectTier(80, false, 0, 0, Date.now())).toBe('handoff');
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:100:    expect(selectTier(90, false, 0, 0, Date.now())).toBe('handoff');
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:105:    expect(selectTier(80, false, 0, handoffFiredAt, Date.now())).toBe('warning');

codex
The first pass already shows several source-catalogue mismatches worth checking precisely: some ESC codes cited by the artefact do not appear in the shared catalogue search output, and the policy filename may differ from the artefact’s cited name. I’m pulling exact source line ranges now.
exec
/bin/zsh -lc "nl -ba docs/specs/PRODUCT-SPEC.md | sed -n '585,610p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '525,545p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   525	- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
   526	- **Build complexity:** **M** (1 week) — the structured field mapping is per-firm config, not code
   527	- **Gotchas:** Tacit-note extraction is the hard part. Start with a small taxonomy (5–10 tacit-note types) and expand. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   528	
   529	#### A4. Cash Conductor (real-time mode) — the FD's evenings back
   530	
   531	- **Build wave:** v1.0 (week 7–8)
   532	- **Always-on?** Tier 1 — persistent watcher on accounting + bank webhooks
   533	- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
   534	- **CortexOS primitives required:** Persistent PTY (#1), Telegram approval surface (#5), standing authorisations (#4)
   535	- **MCP tools required:** Xero / QuickBooks / Sage (one of, per tenant), bank-feed connector
   536	- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
   537	- **External APIs:** Xero API or QuickBooks API or Sage API; bank feed via Open Banking (TrueLayer / Plaid UK)
   538	- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
   539	- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
   540	- **Build complexity:** **L** (2 weeks) — three accounting integrations × Open Banking is the work
   541	- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
   542	
   543	#### A5. Sourcing Scout (daytime form) — request-response sourcing
   544	
   545	- **Build wave:** v1.0 (week 8–9)

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,230p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS auto-send policy (runtime table)
     2	#
     3	# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
     4	# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
     5	# hh_decision_action() invocation. Per-tenant overrides live in Postgres
     6	# tenant_adapters.config.tier_overrides (§8).
     7	#
     8	# 29 v1.0 action_types: 6 green + 5 yellow + 10 orange + 8 red.
     9	# Each row carries:
    10	#   tier            green|yellow|orange|red
    11	#   agent           v1.0 owning agent (or "all" if cross-cutting red rule)
    12	#   reason          short rationale (mirrors §3 column 3)
    13	#   sample_rate     yellow only: 1-in-N for spot-check sampling
    14	#   block_reason    red only: enum from §3 red table column 2
    15	#   timeout         orange only: ISO-8601 duration; default PT4H if absent
    16	#   irreversible    boolean; informational — drives operator UX framing
    17	#
    18	# Schema validated by common-base.json $refs via render-time pre-flight.
    19	# Schema version stamps decision_log.payload.policy_version_sha at write time.
    20	
    21	version: "v1.0-2026-05-20"
    22	
    23	action_types:
    24	
    25	  # ───────────────────────────────────────────────────────────
    26	  # GREEN — auto-send without review (6 action_types)
    27	  # ───────────────────────────────────────────────────────────
    28	
    29	  diagnostic_report_render:
    30	    tier: green
    31	    agent: diagnostic
    32	    reason: "Internal artefact write; no external comms; idempotent (re-render overwrites)"
    33	    irreversible: false
    34	
    35	  bullhorn_candidate_tag:
    36	    tier: green
    37	    agent: janitor
    38	    reason: "Adds tag with checked_at date; reversible in <30s; high volume"
    39	    irreversible: false
    40	
    41	  bullhorn_note_internal:
    42	    tier: green
    43	    agent: scribe
    44	    reason: "Internal-only Bullhorn note (isExternal: false); consultant-visible; non-customer-facing"
    45	    irreversible: false
    46	
    47	  linkedin_profile_cache:
    48	    tier: green
    49	    agent: sourcing-scout
    50	    reason: "Stores profile snapshot to /vault/<tenant>/wiki/raw/; no external send; no rate-limit cost"
    51	    irreversible: false
    52	
    53	  xero_query_invoices:
    54	    tier: green
    55	    agent: cash-conductor
    56	    reason: "Read-only Xero query; rate-limited via Xero's own quotas; no side effect"
    57	    irreversible: false
    58	
    59	  bullhorn_brief_read:
    60	    tier: green
    61	    agent: concierge
    62	    reason: "Read of inbound brief; idempotent; no comms"
    63	    irreversible: false
    64	
    65	  # ───────────────────────────────────────────────────────────
    66	  # YELLOW — auto-send with 1-in-N spot-check (5 action_types)
    67	  # ───────────────────────────────────────────────────────────
    68	
    69	  bullhorn_candidate_dedupe:
    70	    tier: yellow
    71	    agent: janitor
    72	    sample_rate: 10
    73	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
    74	    irreversible: false
    75	
    76	  bullhorn_note_append_summary:
    77	    tier: yellow
    78	    agent: scribe
    79	    sample_rate: 20
    80	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
    81	    irreversible: false
    82	
    83	  linkedin_connection_request:
    84	    tier: yellow
    85	    agent: sourcing-scout
    86	    sample_rate: 5
    87	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
    88	    irreversible: true
    89	
    90	  xero_reminder_draft_internal:
    91	    tier: yellow
    92	    agent: cash-conductor
    93	    sample_rate: 10
    94	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
    95	    irreversible: false
    96	
    97	  bullhorn_note_draft_internal:
    98	    tier: yellow
    99	    agent: concierge
   100	    sample_rate: 10
   101	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   102	    irreversible: false
   103	
   104	  # ───────────────────────────────────────────────────────────
   105	  # ORANGE — per-action human approval (10 action_types)
   106	  # ───────────────────────────────────────────────────────────
   107	
   108	  bullhorn_note_customer_visible:
   109	    tier: orange
   110	    agent: concierge
   111	    timeout: PT4H
   112	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   113	    irreversible: true
   114	    canonical: true
   115	
   116	  gmail_outlook_send_to_candidate:
   117	    tier: orange
   118	    agent: concierge
   119	    timeout: PT4H
   120	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   121	    irreversible: true
   122	
   123	  twilio_sms_send:
   124	    tier: orange
   125	    agent: concierge
   126	    timeout: PT30M
   127	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   128	    irreversible: true
   129	
   130	  calendar_invite_send:
   131	    tier: orange
   132	    agent: concierge
   133	    timeout: PT4H
   134	    reason: "Creates calendar event with attendee notification; visible to attendee"
   135	    irreversible: true
   136	
   137	  email_summary_to_customer:
   138	    tier: orange
   139	    agent: scribe
   140	    timeout: PT4H
   141	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   142	    irreversible: true
   143	
   144	  xero_reminder_send_customer:
   145	    tier: orange
   146	    agent: cash-conductor
   147	    timeout: PT24H
   148	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   149	    irreversible: true
   150	
   151	  diagnostic_email_send:
   152	    tier: orange
   153	    agent: diagnostic
   154	    timeout: PT4H
   155	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   156	    irreversible: true
   157	
   158	  diagnostic_calendar_invite:
   159	    tier: orange
   160	    agent: diagnostic
   161	    timeout: PT4H
   162	    reason: "Books intro call with prospect; reputation + scheduling friction"
   163	    irreversible: true
   164	
   165	  linkedin_inmail_send:
   166	    tier: orange
   167	    agent: sourcing-scout
   168	    timeout: PT4H
   169	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
   170	    irreversible: true
   171	
   172	  bullhorn_placement_terminate:
   173	    tier: orange
   174	    agent: janitor
   175	    timeout: PT4H
   176	    reason: "Marks placement as terminated; commercial/legal implications; reversible only via support ticket"
   177	    irreversible: false
   178	
   179	  # ───────────────────────────────────────────────────────────
   180	  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
   181	  # ───────────────────────────────────────────────────────────
   182	
   183	  xero_payment_initiate:
   184	    tier: red
   185	    agent: all
   186	    block_reason: payment_action
   187	    reason: "Payment transfer; financial-bearing; never auto-send in v1.0"
   188	    irreversible: true
   189	
   190	  stripe_charge_initiate:
   191	    tier: red
   192	    agent: all
   193	    block_reason: payment_action
   194	    reason: "Charges a card; financial-bearing"
   195	    irreversible: true
   196	
   197	  subscription_modify:
   198	    tier: red
   199	    agent: all
   200	    block_reason: billing_modification
   201	    reason: "Changes tenant's IFOS subscription; structurally distinct from agent work"
   202	    irreversible: false
   203	
   204	  legal_document_generate:
   205	    tier: red
   206	    agent: all
   207	    block_reason: legal_artefact
   208	    reason: "Offer letters, employment contracts; legal-binding"
   209	    irreversible: true
   210	
   211	  pii_export_outside_tenant_geography:
   212	    tier: red
   213	    agent: all
   214	    block_reason: pii_geographic_breach
   215	    reason: "PII transmitted outside tenant's declared data residency (GDPR boundary breach)"
   216	    irreversible: true
   217	
   218	  cross_tenant_data_send:
   219	    tier: red
   220	    agent: all
   221	    block_reason: cross_tenant_violation
   222	    reason: "Sending tenant-A data to tenant-B recipient; RLS-enforced + red-listed for defence-in-depth"
   223	    irreversible: true
   224	
   225	  unauthorised_adapter_send:
   226	    tier: red
   227	    agent: all
   228	    block_reason: unauthorized_adapter
   229	    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
   230	    irreversible: true
   231	
   232	  send_to_blocked_recipient:
   233	    tier: red
   234	    agent: all
   235	    block_reason: blocked_recipient
   236	    reason: "Recipient in tenant's blocked_recipients override list"
   237	    irreversible: true
   238	
   239	# ───────────────────────────────────────────────────────────
   240	# Defaults applied when override fields are absent in tenant_adapters
   241	# ───────────────────────────────────────────────────────────
   242	
   243	defaults:
   244	  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
   245	  min_sample_rate: 100          # Tenants cannot set sample rate above 1-in-100 per §8 rule 6
   246	  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
   247	
   248	# ───────────────────────────────────────────────────────────
   249	# Compile-time consistency assertions (enforced by Phase-3 validator script,
   250	# not by YAML itself — documented here so Codex can verify)
   251	# ───────────────────────────────────────────────────────────
   252	
   253	invariants:
   254	  - "tier ∈ {green, yellow, orange, red}"
   255	  - "yellow action_types MUST declare sample_rate (positive integer)"
   256	  - "orange action_types MUST declare timeout (ISO-8601 duration)"
   257	  - "red action_types MUST declare block_reason"
   258	  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
   259	  - "29 total action_types (6 green + 5 yellow + 10 orange + 8 red); v1.0 frozen"

 succeeded in 0ms:
     1	# IFOS escalation codes catalogue
     2	
     3	**Status:** Reference — single source of truth for `ESC_*` codes used by any agent. Wired into `_shared/hook-helpers.sh` (Phase 3).
     4	**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
     5	**Update protocol:** new codes added here BEFORE wiring into helpers + before referencing from any agent bundle. Code names are case-sensitive; pattern `ESC_[A-Z][A-Z0-9_]*`.
     6	
     7	---
     8	
     9	## §1 — How escalation codes work
    10	
    11	Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
    12	
    13	The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
    14	
    15	```
    16	agent_name        — the agent firing the escalation (or '_renderer')
    17	tenant_slug       — RLS-isolated per tenant
    18	phase             — one of {trigger, output, action, gating_failed, agent_handoff}; per decision_log CHECK constraint at Day-4 §6.3
    19	human_action      — the ESC_* code itself + optional `:reason` suffix
    20	payload           — JSON object: {tier?, action_type?, target?, payload_hash?, reason, ...code-specific fields}
    21	created_at        — `now()` at insertion
    22	```
    23	
    24	The Telegram message is templated via `common-notifications.json` `escalation_routes.<ESC_CODE>` if present; otherwise routed to `operator_chat_id`. `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` additionally CCs `ifos_oncall_chat_id`.
    25	
    26	---
    27	
    28	## §2 — Catalogue (24 codes)
    29	
    30	### 2.1 — Auto-send safety (3 codes)
    31	Source: `docs/decisions/autosend-safety-policy.md` §5
    32	
    33	#### `ESC_AUTOSEND_NEEDS_REVIEW`
    34	- **Severity:** info → blocking-pending-approval
    35	- **Trigger:** Orange-tier action queued for tenant operator review
    36	- **Phase:** `action`
    37	- **Routing:** `operator_chat_id` via Telegram approval gate (primitive 4)
    38	- **Timeout:** 4h default per `common-notifications.json.default_approval_timeout_seconds`; on timeout, converts to manual reconciliation
    39	- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
    40	
    41	#### `ESC_AUTOSEND_BLOCKED`
    42	- **Severity:** warn (informational; no human action needed)
    43	- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
    44	- **Phase:** `gating_failed`
    45	- **Routing:** `operator_chat_id`; informational only
    46	- **Payload fields:** `tier='red'`, `action_type`, `target`, `payload_hash`, `reason='red_tier_classification'`
    47	
    48	#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
    49	- **Severity:** **critical** — operational failure, not a policy decision
    50	- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
    51	- **Phase:** `gating_failed`
    52	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — IFOS oncall must investigate
    53	- **Payload fields:** `tier='fail-safe-red'`, `action_type`, `target`, `reason` (one of `unknown_action_type`, `override_resolution_failed`, `unknown_tier:<value>`)
    54	- **Fail-safe behaviour:** Action refused regardless of declared tier
    55	
    56	### 2.2 — Vault concurrency (5 codes)
    57	Source: `docs/architecture/vault-concurrency.md` §6
    58	
    59	#### `ESC_VAULT_LOCK_TIMEOUT`
    60	- **Severity:** warn
    61	- **Trigger:** `flock` acquisition failed within `OP_LOCK_TIMEOUT_S = 5` seconds (per `common-vault.json.lock_timeout_seconds`)
    62	- **Phase:** `gating_failed`
    63	- **Routing:** `operator_chat_id`
    64	- **Payload fields:** `vault_path`, `lock_holder_pid` (if knowable), `wait_duration_ms`
    65	
    66	#### `ESC_VAULT_VERSION_MISMATCH`
    67	- **Severity:** warn
    68	- **Trigger:** Postgres optimistic-concurrency UPDATE found 0 rows after `OP_RETRY_BACKOFF_MS = 100` retry (per `common-vault.json.retry_backoff_ms`); per vault-concurrency §3 retry policy
    69	- **Phase:** `gating_failed`
    70	- **Routing:** `operator_chat_id`
    71	- **Payload fields:** `entity_id`, `expected_version`, `actual_version`
    72	
    73	#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
    74	- **Severity:** warn — likely founder is editing in Obsidian
    75	- **Trigger:** Obsidian debounce hit `MAX_RETRIES = 5` (file mtime still recent after 30s of waiting) per vault-concurrency §4 + `common-vault.json.obsidian_debounce_max_retries`
    76	- **Phase:** `gating_failed`
    77	- **Routing:** `operator_chat_id`
    78	- **Payload fields:** `vault_path`, `file_mtime`, `last_observed_age_ms`
    79	
    80	#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
    81	- **Severity:** warn — requires founder manual reconciliation
    82	- **Trigger:** Rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite per vault-concurrency §5.4 v1.0 mitigation
    83	- **Phase:** `gating_failed`
    84	- **Routing:** `operator_chat_id`
    85	- **Payload fields:** `failures` (list of entity_id strings), `successful_count`, `total_count`
    86	
    87	#### `ESC_VAULT_CASCADE_TIMEOUT`
    88	- **Severity:** warn
    89	- **Trigger:** Cascade exceeded `CASCADE_TIMEOUT_MS = 30_000` ms per vault-concurrency §5 + `common-vault.json.cascade_timeout_ms`
    90	- **Phase:** `gating_failed`
    91	- **Routing:** `operator_chat_id`
    92	- **Payload fields:** `partial_progress_count`, `total_refs_count`
    93	
    94	### 2.3 — Bullhorn integration (1 code)
    95	Source: `docs/decisions/bullhorn-integration-path.md` §4.5 + §6
    96	
    97	#### `ESC_BULLHORN_AUTH`
    98	- **Severity:** **blocking** — agent enters degraded mode (drafts-only, no auto-send)
    99	- **Trigger:** Bullhorn OAuth token refresh failed twice on the per-agent 8-minute cycle (per `common-ats.json.auth_refresh_interval_seconds`); or REST call returned 401 indefinitely (revoked token in Bullhorn admin UI)
   100	- **Phase:** `gating_failed`
   101	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   102	- **Payload fields:** `failure_type` (one of `refresh_failed`, `revoked_401`), `last_attempt_at`, `consecutive_failures`
   103	- **Recovery:** agent stays in degraded mode until founder rotates token via Bullhorn admin → next `_secrets.env` reload picks up new token
   104	
   105	### 2.4 — Renderer (1 code)
   106	Source: `docs/architecture/agent-bundle-renderer-design.md` §4
   107	
   108	#### `ESC_RENDERER_FAILED`
   109	- **Severity:** blocking — render did not produce a runnable agent dir
   110	- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
   111	- **Phase:** `gating_failed`
   112	- **Routing:** `operator_chat_id`; CC `ifos_oncall_chat_id` only on `atomic-rename-failed` (infrastructure failure, not author error)
   113	- **Agent name:** `_renderer` (sentinel; not a real agent)
   114	- **Payload fields:** `reason` (one of `schema-validation-failure`, `bundle-malformed`, `shared-helpers-missing`, `tenant-not-provisioned`, `atomic-rename-failed`, `non-rendered-target`), `agent_name_attempted`, `tenant_slug_attempted`
   115	- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
   116	
   117	### 2.5 — Recruitment-domain vocabulary (8 codes)
   118	Source: master brief §8.1 Change 3 lines 585-592
   119	
   120	#### `ESC_VOICE_DRIFT`
   121	- **Severity:** warn
   122	- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
   123	- **Phase:** `gating_failed`
   124	- **Routing:** `operator_chat_id`
   125	- **Payload fields:** `final_classifier_score`, `retry_count`, `agent_name`, `task_summary`
   126	
   127	#### `ESC_DUPLICATE_DETECTED`
   128	- **Severity:** warn — Janitor dedup needs human approval
   129	- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
   130	- **Phase:** `action`
   131	- **Routing:** `operator_chat_id` via Telegram approval gate
   132	- **Payload fields:** `candidate_a_id`, `candidate_b_id`, `confidence_score`, `match_basis` (e.g. `email+phone`, `name+email`, `phone+linkedin`)
   133	
   134	#### `ESC_JSL_RED_FLAG`
   135	- **Severity:** warn — Supply Chain Auditor (placeholder for v1.1+ JSL extension)
   136	- **Trigger:** Supply Chain Auditor detected red flag (v1.0 placeholder; SCA agent in v1.1 backlog)
   137	- **Phase:** `gating_failed`
   138	- **Routing:** `operator_chat_id`
   139	- **Status:** v1.0 placeholder; no agent fires this yet. Reserved name.
   140	
   141	#### `ESC_BRIEF_AMBIGUITY`
   142	- **Severity:** warn — Brief Decoder cannot confidently shortlist
   143	- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
   144	- **Phase:** `agent_handoff`
   145	- **Routing:** `operator_chat_id`
   146	- **Payload fields:** `brief_id`, `ambiguity_dimensions` (list of {`field`, `confidence`}), `proposed_clarifying_questions`
   147	
   148	#### `ESC_PII_LEAKAGE_RISK`
   149	- **Severity:** **blocking** — agent halts immediately, no retry
   150	- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
   151	- **Phase:** `gating_failed`
   152	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — potential GDPR incident
   153	- **Payload fields:** `detected_pii_type` (one of `email`, `phone`, `name`, `address`, `nin`, `passport`), `boundary_violated` (the tenant_slug whose data leaked), `output_snippet_redacted_hash`
   154	- **Recovery:** Agent restart required after operator review; founder must determine whether DPO notification is needed per UK GDPR Art. 33
   155	
   156	#### `ESC_RATE_LIMIT_HIT`
   157	- **Severity:** warn
   158	- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
   159	- **Phase:** `gating_failed`
   160	- **Routing:** `operator_chat_id`
   161	- **Payload fields:** `upstream` (e.g. `bullhorn`, `linkedin`, `reed`, `cv-library`), `retry_after_seconds`, `consecutive_429s`
   162	
   163	#### `ESC_SCHEMA_VIOLATION`
   164	- **Severity:** warn
   165	- **Trigger:** Agent produced output violating vertical-schema.yaml field constraints (e.g. wrote an unknown enum value, missing required field). Detected at write-time by adapter validation
   166	- **Phase:** `gating_failed`
   167	- **Routing:** `operator_chat_id`
   168	- **Payload fields:** `entity_type` (from vertical-schema.yaml entities), `field_violated`, `value_attempted`, `constraint_failed`
   169	
   170	#### `ESC_VOICE_DRIFT_TENANT`
   171	- **Severity:** warn (info-level — single-tenant pattern, not just one drift event)
   172	- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
   173	- **Phase:** `gating_failed`
   174	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (CSM may need to retrain voice corpus)
   175	- **Payload fields:** `tenant_slug`, `drift_event_count`, `window_days`, `affected_agents` (list of agent_name)
   176	
   177	#### `ESC_INPUT_VALIDATION_FAIL`
   178	- **Severity:** warn
   179	- **Trigger:** Agent rejected its input at the validation gate (e.g. malformed firm name, missing required CLI argument, brief description too short). Detected at Step 1 of the agent's workflow BEFORE any tool calls or LLM invocations
   180	- **Phase:** `gating_failed`
   181	- **Routing:** `operator_chat_id`
   182	- **Payload fields:** `input_field`, `input_value_preview` (truncated to 80 chars), `validation_rule_violated`
   183	
   184	#### `ESC_AGENT_OUTPUT_SHAPE`
   185	- **Severity:** warn
   186	- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
   187	- **Phase:** `gating_failed`
   188	- **Routing:** `operator_chat_id`
   189	- **Payload fields:** `agent_name`, `output_path`, `shape_rule_violated`, `expected_value`, `actual_value`
   190	
   191	### 2.6 — Cross-cutting infrastructure (6 codes)
   192	Source: derived from operational discipline + sequencing-target §5
   193	
   194	#### `ESC_HUMAN_EDITING_LOCK`
   195	- **Severity:** info
   196	- **Trigger:** Manual editing lock held by founder; agent backs off and reschedules
   197	- **Phase:** `gating_failed`
   198	- **Routing:** log-only (no Telegram noise)
   199	- **Payload fields:** `vault_path`, `lock_age_seconds`
   200	
   201	#### `ESC_VAULT_CONCURRENCY`
   202	- **Severity:** warn
   203	- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
   204	- **Phase:** `gating_failed`
   205	- **Routing:** `operator_chat_id`
   206	- **Payload fields:** `vault_path`, `anomaly_class`, `freeform_reason`
   207	- **Note:** Catch-all; specific codes preferred. New patterns may justify a new code.
   208	
   209	#### `ESC_VAULT_RENAME_RACE`
   210	- **Severity:** warn
   211	- **Trigger:** Rename operation raced with another writer; per vault-concurrency §5
   212	- **Phase:** `gating_failed`
   213	- **Routing:** `operator_chat_id`
   214	- **Payload fields:** `from_path`, `to_path`, `racing_writer_pid`
   215	
   216	#### `ESC_CORTEXTOS_RESTART_REQUESTED`
   217	- **Severity:** info
   218	- **Trigger:** Agent self-requested restart per primitive 6 (`cortextos-ifos bus self-restart`) — typically post-degraded-mode recovery, post-context-overflow handoff
   219	- **Phase:** `agent_handoff`
   220	- **Routing:** log-only
   221	- **Payload fields:** `reason`, `next_session_token`
   222	
   223	#### `ESC_CORTEXTOS_HANDOFF`
   224	- **Severity:** info
   225	- **Trigger:** Context approaching `ctx_handoff_threshold` (default 80%); agent saves state and triggers fresh-session takeover per primitive 1+2 context-rotation
   226	- **Phase:** `agent_handoff`
   227	- **Routing:** log-only
   228	- **Payload fields:** `from_session_id`, `context_pct`, `handoff_summary_path`
   229	
   230	#### `ESC_CORTEXTOS_DEGRADED`

exec
/bin/zsh -lc "ls -la agents/recruitment/cash-conductor agents/_shared docs/decisions | sed -n '1,160p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared:
total 160
drwxr-xr-x@ 8 madsadmin  staff    256 May 24 11:12 .
drwxr-xr-x@ 4 madsadmin  staff    128 May 22 14:54 ..
-rw-r--r--@ 1 madsadmin  staff  11505 May 22 16:17 README.md
-rw-r--r--@ 1 madsadmin  staff  10213 May 20 11:29 autosend-policy.yaml
-rw-r--r--@ 1 madsadmin  staff  15730 May 24 11:12 escalation-codes.md
-rw-r--r--@ 1 madsadmin  staff  22056 May 23 12:48 hook-helpers.sh
drwxr-xr-x@ 4 madsadmin  staff    128 May 20 11:47 tests
-rw-r--r--@ 1 madsadmin  staff  12956 May 22 16:17 voice-loader.sh

agents/recruitment/cash-conductor:
total 56
drwxr-xr-x@ 4 madsadmin  staff    128 May 24 10:54 .
drwxr-xr-x@ 8 madsadmin  staff    256 May 24 10:46 ..
-rw-r--r--@ 1 madsadmin  staff   1697 May 24 10:54 README.md
-rw-r--r--@ 1 madsadmin  staff  22205 May 24 10:54 agent.md

docs/decisions:
total 776
drwxr-xr-x  20 madsadmin  staff    640 May 24 11:22 .
drwxr-xr-x@ 15 madsadmin  staff    480 May 24 09:35 ..
-rw-r--r--@  1 madsadmin  staff  28068 May 24 11:22 2026-05-18-codex-ratification-manifest.md
-rw-r--r--@  1 madsadmin  staff  13634 May 20 09:39 2026-05-18-day-7-single-sentence-test.md
-rw-r--r--@  1 madsadmin  staff  14325 May 22 13:42 2026-05-20-codex-round-1-founder-decisions.md
-rw-r--r--@  1 madsadmin  staff   7427 May 20 13:37 ADR-001-bus-dispatcher-poll-not-chokidar.md
-rw-r--r--@  1 madsadmin  staff  13683 May 20 13:43 ADR-002-brain-system-as-parallel-not-shadow.md
-rw-r--r--@  1 madsadmin  staff  15724 May 20 13:39 ADR-003-agent-bundle-renderer.md
-rw-r--r--@  1 madsadmin  staff  13533 May 20 12:25 ADR-004-renderer-implementation-deviations.md
-rw-r--r--@  1 madsadmin  staff   7818 May 24 09:23 ADR-005-week-3-diagnostic-acceleration.md
-rw-r--r--   1 madsadmin  staff     32 May 16 13:28 README.md
-rw-r--r--@  1 madsadmin  staff  16778 May 22 16:17 autosend-approval-bridge-spec.md
-rw-r--r--@  1 madsadmin  staff  44472 May 22 14:30 autosend-safety-policy.md
-rw-r--r--@  1 madsadmin  staff  16484 May 16 21:53 brain-ui-scope.md
-rw-r--r--@  1 madsadmin  staff  60893 May 23 16:01 bullhorn-integration-path.md
-rw-r--r--@  1 madsadmin  staff   5777 May 22 14:30 codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
-rw-r--r--@  1 madsadmin  staff   5989 May 22 13:24 codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
-rw-r--r--@  1 madsadmin  staff   8660 May 24 11:16 codex-disagreement-2026-05-24-diagnostic-gate-a.md
-rw-r--r--@  1 madsadmin  staff  54723 May 20 13:37 sequencing-target.md
-rw-r--r--@  1 madsadmin  staff  31366 May 20 13:39 v1.0-kill-criterion.md

exec
/bin/zsh -lc "rg -n \"master brief|§8\\.2|W7|Cash Conductor|Hire #1\" docs -g '*.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/runbooks/day-4-provisioning.md:15:This runbook is the **reviewable plan** for Day 4 of Week 0 per master brief §6 Day 4. It is **not executed by writing it.** Execution happens in a separate session against a real VPS after this document is reviewed and ratified.
docs/runbooks/day-4-provisioning.md:30:- **Rule 5 (Honest signal before optimistic projection):** §0 surfaces every drift between the master brief and reality (notably: Hetzner has no UK data centre).
docs/runbooks/day-4-provisioning.md:38:### §0.1 — DRIFT: Hetzner has no UK data centre (master brief §6 Day 4 line 477)
docs/runbooks/day-4-provisioning.md:40:**Master brief asserts (line 477 verbatim):** "Hetzner UK VPS provisioned, LUKS-encrypted volume mounted at `/vault/`". This is the single Hetzner reference in the master brief. §10 (Codex ratification loop) does not mention Hetzner or cost targets — earlier drafts of this runbook cited "master brief §10.4" for cost target and Hetzner location; both fabricated. Corrected in citation-audit pass 2026-05-18.
docs/runbooks/day-4-provisioning.md:51:| £20/mo target (Day-4 runbook §1.4 founder-set budget; not specified in master brief) | ✅ well under | ✅ within budget |
docs/runbooks/day-4-provisioning.md:56:**Master-brief correction:** add to the atomic-correction commit manifest (currently 8 edits at end of Week 0). Proposed Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; flag UK-residency as a commercial-conversation gate. (Earlier drafts also referenced "§10.4" as a separate location-naming surface; verified that §10.4 — "What never goes through ratification" — contains no Hetzner or cost-target content. §10.4 component dropped.)
docs/runbooks/day-4-provisioning.md:58:### §0.2 — DRIFT: master brief §6 Day 4 table list says `entity_graph`, ADR-002 Edit 3 split this to `entities` + `entity_links`
docs/runbooks/day-4-provisioning.md:64:**This runbook follows the corrected list.** The atomic correction commit manifest covers the master brief §6 wording.
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/runbooks/day-4-provisioning.md:171:| Instance type | CX22 (2 vCPU, 4 GB RAM, 40 GB NVMe) | Fits v1.0 pilot scale per founder-set budget in this section §1.4; master brief does not specify a numeric cost target |
docs/runbooks/day-4-provisioning.md:178:Estimated monthly cost: ~€5/mo VPS + ~€2.40/mo (50 GB volume at €0.0476/GB/mo) ≈ €7.40/mo ≈ £6.40/mo. Well under the £20/mo founder-set budget for v1.0 pilot scale (this section §1.4; master brief does not specify a numeric cost target).
docs/runbooks/day-4-provisioning.md:766:-- Note: NO UPDATE/DELETE grant. Decision log is append-only per master brief §5.7.
docs/runbooks/day-4-provisioning.md:768:-- tenant_eval_sets (per master brief §6 Day 4 line 478; v1.0 placeholder)
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1090:The vault per ADR-002 + master brief §3.3 is markdown, git-backed. Initial baseline:
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1187:- Add Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; document UK-residency as commercial-conversation gate. (§10.4 reference dropped per 2026-05-18 citation audit; §10.4 is Codex exclusion list, not a Hetzner or cost-target section.)
docs/runbooks/day-4-provisioning.md:1212:3. **§2 location — NBG1 substituted for FSN1:** FSN1 unavailable at provisioning time. Substituted Nuremberg (NBG1) — same Hetzner eu-central zone, identical Schrems II EU jurisdiction (German court orders only), latency to UK ~25-30ms vs FSN1 ~20-25ms (functionally equivalent). **Triggers §11.4 master-brief Edit 9:** master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations". (Earlier drafts of Edit 9 also referenced master brief §10.4; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list, not a Hetzner or cost-target section. §10.4 component dropped.)
docs/RISK-REGISTER.md:4:the top. Full risk list is in master brief §12 and Ultraplan §10.
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:50:Full risk register per master brief §12 / Ultraplan §10. Port the remaining
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:63:- 2026-05-17 (Day 4) — **Day 4 provisioning executed end-to-end against Hetzner Cloud NBG1 VPS (178.105.87.24).** All 9 runbook sections complete; §7 RLS isolation gate passed all 5 conditions (cross-tenant data access structurally impossible for `ifos_app` regardless of application bugs); 22 of 22 §9 automated checks passed. **Risk #7 edit count revised from 8 to 9** with new Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations"). **One new risk added (#8 LUKS manual unlock single-point-of-failure)** — Low probability, Medium-High impact, v1.2+ TPM/key-server mitigation path named. Two non-blocking operational items deferred to founder convenience: (a) Hetzner Console snapshot of `ifos-v2-prod-01`; (b) ifos_app password retrieval from `/vault/.ifos_app_password.tmp` → 1Password → temp file delete; (c) **high-priority** LUKS new-passphrase retrieval from `/root/.new_luks_passphrase.tmp` → 1Password → temp file delete (must be done before next reboot — old leaked passphrase already invalidated by Day-4 §11 rotation). Path B protocol gap (LUKS passphrase entered chat for `ifos-unlock` end-to-end test) closed via `cryptsetup luksChangeKey` rotation: OLD (leaked) rejected by `--test-passphrase`, NEW accepted; leaked passphrase in chat transcript is cryptographically invalid. v1.1 runbook revisions catalogued (8 items) for collection during Days 5-7. Codex Day-7 queue grows from 13 to 15 (Day 4 runbook + executed version).
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:57:- §1 Output contract (one-paragraph screenshot per master brief §1 Rule 1)
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
docs/operations/goal-week-3-polish-and-scaffold.md:292:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:301:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:320:- §1 reads as a complete one-paragraph screenshot per master brief §1 Rule 1
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:352:### DAY 18 — Cash Conductor agent.md scaffold (Step 10)
docs/operations/goal-week-3-polish-and-scaffold.md:357:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:360:- `vertical-schema.yaml` §3 agent_access_matrix Cash Conductor row
docs/operations/goal-week-3-polish-and-scaffold.md:361:- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:448:Triage protocol (master brief §10.3 step 5 hard ceiling: ≤2 round-trips):
docs/operations/goal-week-3-polish-and-scaffold.md:459:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:485:| **Master plan citations** | Every architectural claim cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
docs/operations/goal-week-3-polish-and-scaffold.md:500:| Codex Round 4 returns >2 REJECTED on any single artefact | Founder review; do NOT remediate-and-resubmit beyond hard ceiling (per master brief §10.3 step 5); write founder-decision doc; defer |
docs/operations/goal-week-3-polish-and-scaffold.md:538:Per master brief §10 + §10.3 step 5 hard ceiling + Day-11 Round-2/3 pattern.
docs/operations/goal-week-3-polish-and-scaffold.md:571:- **Mechanical REJECTIONS (citation drift, line-anchor error, formatting):** Round 4 remediation prompt; expect Round 5 final. Hard ceiling per master brief §10.3 step 5: 2 round-trips MAX. Round 5 RATIFIED → close. Round 5 STILL REJECTED → founder review.
docs/operations/goal-week-3-polish-and-scaffold.md:588:1. **Every claim cites a master plan section.** No bare assertions. Every paragraph either cites the master brief / ULTRAPLAN / sequencing-target / kill-criterion / specific ADR, OR is explicitly stated as "scaffold inference; founder review required."
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:618:  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:640:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:648:    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/goal-week-3-polish-and-scaffold.md:649:    - Cash Conductor build (full bundle)
docs/runbooks/operational-hygiene-protocol.md:27:- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
docs/runbooks/operational-hygiene-protocol.md:231:**Day-6 lesson (§7 below):** 15 fabricated "master brief §10.4" references propagated across 5 files. The root cause: Day-4 runbook drafting invented a citation that didn't exist, and subsequent artefacts cited the Day-4 runbook citation without re-verifying against master brief.
docs/runbooks/operational-hygiene-protocol.md:234:- When citing master brief, verify against master brief — never against an intermediate artefact's citation of master brief
docs/runbooks/operational-hygiene-protocol.md:262:### §7.1 — Finding: master brief §10.4 fabrication
docs/runbooks/operational-hygiene-protocol.md:264:**Scope:** 15 references to "master brief §10.4" across 5 files, claiming §10.4 contains either (a) a Hetzner UK / FSN1 location reference or (b) a £20/mo cost target.
docs/runbooks/operational-hygiene-protocol.md:266:**Verified ground truth:** master brief §10.4 is "What never goes through ratification" — a 5-bullet list of Codex exclusions (comment-only changes, test fixture additions, documentation typos, build/deps version bumps, anything inside `.agents/`). It contains no Hetzner reference and no cost-target reference.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:274:| `docs/runbooks/day-4-provisioning.md` | 8 | "+§10.4" dropped from Edit 9 scope (was about Hetzner UK); "§10.4 cost target" replaced with "Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target)" |
docs/runbooks/operational-hygiene-protocol.md:296:- `master brief §3.2 line 155` (canonical vocabulary "candidate, placement, brief") — ✅ verified line 155 matches
docs/runbooks/operational-hygiene-protocol.md:297:- `master brief §5.1 lines 325-329` (vault directory structure) — ✅ verified
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/operations/codex-round-2-autonomous-prompt.md:91:recursive ratification per master brief §10.5. Decide whether Claude's 
docs/operations/codex-round-2-autonomous-prompt.md:196:  Disagreement docs (recursive ratification per master brief §10.5):
docs/operations/codex-round-2-autonomous-prompt.md:320:**If SUMMARY.md shows unexpected REJECTED items:** Codex caught something. Read the per-artefact output file. Decide whether to incorporate or counter-argue. Then Round 3 (~limited; ≤2 round-trips per master brief §10.3).
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/specs/ULTRAPLAN.md:4:**Audience:** Maddox first. Future co-founder / Hire #1 second. The senior engineer who reads this in week six and needs to know what to do without asking.
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:601:#### A9. Real-time Cash Conductor reframe (2 weeks)
docs/specs/ULTRAPLAN.md:688:| Cash Conductor | ✓ | | | ✓ | | | | | | ✓ | Open Banking |
docs/specs/ULTRAPLAN.md:713:7. **Xero / QuickBooks / Sage** — 4 of 18 (one per tenant typically). Cash Conductor's blocker.
docs/specs/ULTRAPLAN.md:722:- Maddox solo for weeks 0–6; Hire #1 starts week 7 (per the most plausible reading of the user's memory, with caveat in §10).
docs/specs/ULTRAPLAN.md:764:### Weeks 7–8 — Cash Conductor + Hire #1 onboards
docs/specs/ULTRAPLAN.md:766:- Week 7: Hire #1 onboards (assumed); Xero MCP + Open Banking integration
docs/specs/ULTRAPLAN.md:767:- Week 8: Cash Conductor agent; chase-cadence config; tenant-level baseline DSO captured
docs/specs/ULTRAPLAN.md:769:Milestone: Cash Conductor running in shadow mode against first pilot's accounting data.
docs/specs/ULTRAPLAN.md:800:5. Cash Conductor's escalation-tier-3 (bad debt write-off draft) — manual until 6 months in
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:821:| 5 | Open Banking integration takes more than 1 week | Medium | Medium | End of week 7 status not "Xero + first bank connected" | Cash Conductor ships with manual reconciliation in v1.0; webhook-driven mode at v1.1 |
docs/specs/ULTRAPLAN.md:855:- [ ] Hire #1 status one-liner. **Owner:** Maddox.
docs/operations/codex-round-2-remediation-prompt.md:407:Per master brief §10.3 step 5: Round 3 is the LAST automated round.
docs/operations/codex-round-2-remediation-prompt.md:433:     Per master brief §10.3, this is the last automated round. Confirm
docs/operations/codex-round-2-remediation-prompt.md:525:  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
docs/_supplementary/README.md:5:- `docs/build-brief/00-MASTER-BRIEF.md` — the master brief Claude Code reads first
docs/operations/codex-ratification-guide.md:30:- Citation drift — `master brief §10.4` quoted 15 times in one batch, all wrong (real past incident)
docs/operations/codex-ratification-guide.md:200:2. Citation §10.4 incorrect — master brief §10.4 is the Codex exclusion list, not the cost target the ADR cites. Past pattern of 15 fabricated §10.4 references; verify line numbers before citing. Citation: ADR-001 line 47.
docs/operations/codex-ratification-guide.md:373:The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.
docs/operations/codex-ratification-guide.md:516:- **Possibly updated master brief** — Codex may flag spec drifts requiring atomic correction
docs/operations/codex-ratification-execution-plan.md:5:**Source artefacts:** master brief §10 (the loop) + `docs/decisions/2026-05-18-codex-ratification-manifest.md` (the queue) + this plan (the how).
docs/operations/codex-ratification-execution-plan.md:10:## §1 — Why this loop matters (re-statement from master brief §10.1)
docs/operations/codex-ratification-execution-plan.md:78:### Skill shape (per master brief §10.2 last paragraph)
docs/operations/codex-ratification-execution-plan.md:93:## Five-rule pass (master brief §1)
docs/operations/codex-ratification-execution-plan.md:100:## Four-boundary pass (master brief §3)
docs/operations/codex-ratification-execution-plan.md:204:Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:317:Per master brief §10.3 step 5:
docs/operations/codex-ratification-execution-plan.md:338:4. **Spec drift** — Codex reviews an artefact that's based on a now-stale version of the master brief. Disagreement → update the master brief OR the artefact; re-review. Moderately expensive.
docs/operations/codex-ratification-execution-plan.md:340:**Worth tracking for retro:** category mix on first run. If category 1 dominates, the master brief needs sharpening. If category 4 dominates, the atomic-correction discipline is failing.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:427:- **Multi-model ratification (e.g., adding Gemini)** — v1.0 is Claude + Codex per master brief §10. Multi-model is v2.0+ if signal justifies.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
docs/specs/PRODUCT-SPEC.md:73:#### R2. Real-Time Cash Conductor — the FD's evenings back
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:345:- Cash Conductor runs against historical invoices — produces the DSO baseline.
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:401:| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:474:- Cash Conductor (real-time mode)
docs/specs/PRODUCT-SPEC.md:523:2. **Real-Time Cash Conductor** — "DSO drops by 15+ days, working capital unlocked."
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:200:ratification per master brief §10.5. Decide whether Claude's counter-argument
docs/operations/codex-round-2-handoff.md:292:Hard ceiling: 2 round-trips (master brief §10.3 step 5). After Round 2, no Round 3 — escalate to founder for explicit decision.
docs/operations/codex-round-2-handoff.md:332:Any Round-2 REJECTED items get their own row in the manifest queue updated to "REJECTED→ROUND-3-pending OR founder-escalated". Per §10.3 master brief: no Round 3 until founder decides.
docs/operations/codex-round-2-handoff.md:373:Per master brief §10.6 + execution plan §5:
docs/operations/codex-round-2-handoff.md:406:Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).
docs/architecture/architecture-cohesion-review.md:5:**Method:** Read all 4 ADRs + 4 reference designs end-to-end as a coherent set. Walk each of the 4 boundaries from master brief §3 with adversarial questions. Identify gaps, contradictions, implicit assumptions.
docs/architecture/architecture-cohesion-review.md:58:| ADR-001 | bus mechanism (chokidar→FastChecker) | master brief §2.4 row 3 (Edit) | ✓ landed atomic `0e5b2b4` |
docs/architecture/architecture-cohesion-review.md:114:- **master brief §3.1 boundary 1** read-only submodule
docs/architecture/architecture-cohesion-review.md:162:## §7 — Per-boundary adversarial walk (master brief §3 boundaries)
docs/architecture/cortexos-kb-surface-investigation.md:12:Day-1 audit of cortextOS Primitive 3 (`docs/architecture/cortexos-primitive-status.md`) surfaced that master brief §3.4 names four shadow files (`kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`) that **do not exist** at the verified SHA. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`.
docs/architecture/cortexos-kb-surface-investigation.md:14:Drafting ADR-002 began with the plan to read all four real files and pick one of three outcomes (full shadow / mixed shadow + new wrappers / abandon shadow). After reading **only `kb-setup.sh`**, the substrate of cortextOS's KB became clear, and that substrate is incompatible with the IFOS wiki data model in master brief §5. The ADR's scope is too narrow to absorb that finding — it would be designing the second brain inside an architectural decision record, on the side of an audit.
docs/architecture/cortexos-kb-surface-investigation.md:35:- **Per-instance isolation:** the KB root path includes `$CTX_INSTANCE_ID`, so IFOS's `ifos-v2` install and the personal install at `default` have **separate** KB indexes by construction. This is already correct against the master brief §3.1 submodule boundary.
docs/architecture/cortexos-kb-surface-investigation.md:83:**cortextOS's KB is a chunked-vector RAG store; the IFOS wiki in master brief §5 is an entity-document store. These data models do not compose without an adapter layer, and the adapter layer is large enough to be a design decision rather than a shadow-wrapper detail.**
docs/architecture/cortexos-kb-surface-investigation.md:88:- **IFOS wiki unit of storage:** one markdown file per entity (Candidate, Client, Brief, Placement…) with structured YAML frontmatter (`id / entity_type / tenant_id / created_at / updated_at / provenance / importance_score / linked_entities`) and `[[wiki-link]]` references in body — per master brief §5.2 example at lines 357-369. The natural read pattern is "give me the canonical page for this entity, plus its backlinks".
docs/architecture/cortexos-kb-surface-investigation.md:97:  - **Indexing of ingested raw email/transcript chunks** (master brief §5.1 `raw/` directory tree). The chunked-vector model fits the "raw inbox-emails / calls / briefs" surface well; it only stops fitting at the `compiled/` entity-document boundary.
docs/architecture/cortexos-kb-surface-investigation.md:98:- **What this means for §3.4:** the master brief calls the seam between cortextOS and IFOS "the four `bus/kb-*.sh` shadow points." That framing assumed the same data model on both sides of the seam. With the substrate now known, the seam is not a four-file shadow but a much smaller boundary — to be defined in the second-brain design.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:5:**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:17:Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/build-brief/00-MASTER-BRIEF.md:15:If anything in `docs/build-pack/` conflicts with this brief, **this brief wins**. The build pack stays in-tree as historical record; the master brief is operative.
docs/build-brief/00-MASTER-BRIEF.md:238:git commit -m "chore: reconcile scaffold against master brief; vendor cortextos@${HARNESS_SHA:0:7}"
docs/build-brief/00-MASTER-BRIEF.md:260:git commit -m "docs: import authoritative specs + master brief"
docs/build-brief/00-MASTER-BRIEF.md:465:- [ ] Hire #1 status one-liner
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/build-brief/00-MASTER-BRIEF.md:852:Drop this verbatim at `~/code/CortexOS/CLAUDE.md`. It supersedes the existing CLAUDE.md (which keeps the path table and red lines, but defers all build-pack references to this master brief).
docs/build-brief/00-MASTER-BRIEF.md:867:start. The build pack at `docs/_archive-build-pack/` is historical; the master brief wins on
docs/build-brief/00-MASTER-BRIEF.md:907:merge. See master brief §10.
docs/build-brief/00-MASTER-BRIEF.md:910:1. Read this file, then master brief §1, §3, §6, §8, §10
docs/build-brief/00-MASTER-BRIEF.md:922:1. Check the master brief §-references first
docs/build-brief/00-MASTER-BRIEF.md:931:- Don't add features without a corresponding slice in the master brief
docs/build-brief/00-MASTER-BRIEF.md:933:- Don't relitigate the master brief without writing the disagreement to `docs/decisions/`
docs/build-brief/00-MASTER-BRIEF.md:998:*End of master brief. Drop at `docs/build-brief/00-MASTER-BRIEF.md`. Re-read §1, §3, §6, and §10 weekly.*
docs/architecture/cortexos-primitive-status.md:7:**Method:** read code under `src/daemon/`, `src/pty/`, `src/bus/`, `src/telegram/`, `src/cli/`; cross-reference with `README.md`, `CHANGELOG.md`, `CRONS_MIGRATION_GUIDE.md`, `templates/{orchestrator,analyst,agent,m2c1-worker,agent-codex}/`; line-cite `tests/unit/**` and `tests/integration/**`; cross-check Day-0 findings in `.agents/learnings/00-cortextos-quirks.md`; classify per the four-status scheme from master brief §6 Day 1.
docs/architecture/cortexos-primitive-status.md:9:Two findings need founder review before the Day 7 single-sentence test (master brief §6 / Ultraplan §12). Both are master-brief drifts against the verified SHA, surfaced in Primitive 3:
docs/architecture/cortexos-primitive-status.md:11:1. **No `chokidar` watcher in the bus** — master brief §2.4 row 3 says "bus/ shell wrappers + chokidar watcher in daemon", but the bus is poll-based (`FastChecker` default 1000ms). `chokidar` is only used by the dashboard's UI file-feed.
docs/architecture/cortexos-primitive-status.md:12:2. **The four `bus/kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 names `kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`. The actual files at SHA `c21fbfe` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`. The brain-replacement seam (§3.4 + §5) needs reconciliation before Codex ratification.
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:36:**Master-brief description:** `node-pty` + `ecosystem.config.js` regen via `cortextos ecosystem`; agents run as PM2-managed PTY processes that auto-restart on crash or after the 71-hour context rotation (master brief §2.4 row 1).
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:97:**Master-brief description:** The daemon auto-restarts a session before the context limit; pre-rotation hook checkpoints state to vault (master brief §2.4 row 2).
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:157:**Master-brief description:** `bus/` shell wrappers + `chokidar` watcher in the daemon; agents drop typed files for inter-agent handoff (master brief §2.4 row 3).
docs/architecture/cortexos-primitive-status.md:184:2. **The four `kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 lists `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`. The actual files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. This is the brain-replacement seam — the master brief's named files do not exist at SHA `c21fbfe`. Either the brief was written against a different cortextOS version, or the four shadow points need to be revised. This is a Day-7 Codex-ratification-blocking discrepancy.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:228:**Master-brief description:** Daemon enforces explicit approval before external action; `manualFireDisabled` flag on crons; standing authorisations per agent (master brief §2.4 row 4).
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:292:**Master-brief description:** Bot per agent, `.env` carries `BOT_TOKEN / CHAT_ID / ALLOWED_USER`; the escalation path for every Tier-1 agent (master brief §2.4 row 5).
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:328:**Risk if flaky:** Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5 ("iOS in v1.2 is the marketing line, not a tech blocker"). Real risk is Telegram outage during a Cash Conductor escalation, which is exactly what the activity-channel + per-agent-bot belt-and-braces pattern (primitive 4 evidence, `approval.ts:222-226`) was built to mitigate after the "50h+ Repo-B-style stall" incident.
docs/architecture/cortexos-primitive-status.md:366:**Master-brief description:** Analyst-template agents schedule overnight experiments, evaluate results, surface findings for review (master brief §2.4 row 6).
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:430:**Master-brief description:** Orchestrator template + file-bus handoff contract; supervisor agent watches the others, escalates jams, balances load (master brief §2.4 row 7).
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/architecture/cortexos-primitive-status.md:504:- **Day-7 spec drifts for Codex ratification:** the chokidar mention in master brief §2.4 row 3 and the four `kb-*.sh` filenames in master brief §3.4 do not match the verified SHA. Both need a one-line correction or a §3.4 re-scoping decision.
docs/architecture/cortexos-primitive-status.md:505:- **Standing authorisations** (master brief §2.4 row 4) are not a cortextOS primitive at this SHA. We build them in our layer — confirm scope in the Day 5 auto-send safety policy artefact.
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:297:| **Master plan citations** | Every architectural decision cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:23:Per design §5.1: the cortextOS `cortextos-ifos add-agent` command is **unchanged**. IFOS does not use it for IFOS-owned agents. The renderer is a **new** command at `packages/agent-renderer/`, invoked via `ifos-render-agent <agent-name> --tenant <slug>` (standalone Node binary per `package.json` `bin`; **errata via ADR-004 Decision 1** — earlier drafts named this `cortextos-ifos render-agent` which would have required modifying the read-only submodule per master brief §3.1 boundary 1).
docs/decisions/ADR-003-agent-bundle-renderer.md:37:Three alternatives rejected per design §3.1: `packages/brain/agent-cli/` (wrong cohesion — brain is wiki, renderer is not a wiki concern); `scripts/render-agent.sh` (JSON Schema validation + YAML parsing harder in shell); new top-level directory (loses master brief §4.1 line 195-204 `packages/` convention).
docs/decisions/ADR-003-agent-bundle-renderer.md:39:**Invocation mode** per design §3.2: manual developer invocation. Day-1 cadence (founder + Claude Code), per-tenant scope explicit, hand-off boundary clean. Three alternatives rejected per design §3.2: pre-push hook (wrong filesystem — tenant vault on Hetzner UK VPS, hook on dev laptop), CI on merge (same reachability problem), daemon auto-watcher (wrong coupling — daemon is read-only on submodule per master brief §3.1).
docs/decisions/ADR-003-agent-bundle-renderer.md:60:Two alternatives rejected per design §3.4: merge-with-conflict-markers (premature complexity — master brief §1 Rule 1 "output before architecture" favours simple); refuse-if-exists (friction without benefit — Decision 1's marker-file check handles the actual risk).
docs/decisions/ADR-003-agent-bundle-renderer.md:74:**Current** (master brief §4.1 lines 195-204):
docs/decisions/ADR-003-agent-bundle-renderer.md:94:Lands in this ADR's commit. Edit A is the minimum required to make `packages/agent-renderer/` a canonical IFOS package per master brief §4.1; Week-1 renderer implementation depends on the path existing.
docs/decisions/ADR-003-agent-bundle-renderer.md:98:**Current** (master brief §8.3 lines 614-630):
docs/decisions/ADR-003-agent-bundle-renderer.md:133:**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:151:**For the master brief atomic correction commit.** Edit C (the §8 footnote) joins ADR-001 + ADR-002 edits in the deferred single commit at end of Week 0 / early Week 1. Edits A and B land in this batch's commit because (a) Edit A is needed live before Week-1 renderer implementation can scaffold the package path, (b) Edit B is a small wording add to a code block, (c) neither is substantive enough to warrant the atomic-correction overhead.
docs/decisions/ADR-003-agent-bundle-renderer.md:163:1. Edits A and B applied to master brief §4.1 and §8.3 in this batch's commit.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:15:> "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**." (master brief §3.4 line 167)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:19:The Day-1 cortextOS primitive audit (`docs/architecture/cortexos-primitive-status.md` — Primitive 3) surfaced that **none of those four files exist at SHA `c21fbfe`**. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. Reading `kb-setup.sh` revealed the substrate underneath: `mmrag.py` over ChromaDB with Gemini embeddings and 1000-char chunks (`docs/architecture/cortexos-kb-surface-investigation.md` §"What is cortextOS's KB substrate"). That data model is incompatible with the IFOS wiki's entity-document model in master brief §5.2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:27:cortextOS's `bus/kb-*.sh` surface and the `mmrag.py` / ChromaDB / Gemini stack at `packages/harness/cortextos/knowledge-base/` remain **untouched**. IFOS agents do **not** invoke `kb-query`, `kb-ingest`, `kb-collections`, or `kb-setup`. The §3.1 "edit-exception for four `bus/kb-*.sh` shadow points" in the master brief becomes a **dead clause**: there is no shadowing, the exception is never exercised, and §3.1's "never edit `packages/harness/cortextos/*`" stands without qualifier.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:75:**Disposition update 2026-05-20 (Day 8 Codex Round 1):** all three edits landed in the atomic-correction commit **`0e5b2b4`** ("docs: master brief reconciliation — 11 edits batch-applied", Day 7 2026-05-20). Manifest-of-record below — each edit's "where it landed" is `0e5b2b4`.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:81:**Current** (master brief §3.4 line 167-176): "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**. … 1. Vendored copy at `packages/harness/cortextos/bus/kb-*.sh` is left untouched. 2. Our overrides live at `packages/brain/bus-overrides/kb-*.sh`. 3. PM2 `ecosystem.config.js` sets `PATH` so our overrides are picked up first…"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:87:**Current** (master brief §5.5 lines 416-420):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:97:**Current** (master brief §6 Day 4 line 478):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:105:This edit lands on **Day 4 of Week 0 (this week)** as part of the Postgres provisioning task per master brief §6 Day 4, **not** in the brain-ADR atomic commit. ADR-002 authorises the split; Day 4 implements it.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:119:**For cortextOS upstream.** No PR upstreamable from this ADR. cortextOS code is untouched; the submodule pin (`c21fbfe991a0030ea055bd8e2389a0801a424383`) stays. The brain-replacement boundary in master brief §3.1 simply isn't exercised — that's not a bug in cortextOS, it's an IFOS-side decision to use a parallel surface.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:127:- **Future v1.1+ ADR (Brain UI implementation choice)** — Next.js routes extending the cortextOS dashboard per master brief §5.3 vs. standalone — out of scope for Q3.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/decisions/ADR-004-renderer-implementation-deviations.md:18:The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
docs/decisions/ADR-004-renderer-implementation-deviations.md:30:**Why the deviation:** `cortextos-ifos` is the upstream CLI shipped from the cortextOS submodule at `/opt/homebrew/bin/cortextos-ifos`. Adding a `render-agent` subcommand to that binary requires modifying source in `packages/harness/cortextos/`, which violates master brief §3.1 boundary 1 (cortextOS submodule read-only). The boundary is non-negotiable per master brief §3.1 + the build-pack discipline that the submodule is a "reference pin, not the runtime."
docs/decisions/ADR-004-renderer-implementation-deviations.md:79:- **Prefix `_shared/` with a dotfile** (`.shared/`) to make the listAgents scan skip it. Rejected — Bash glob conventions + Postgres conventions both treat dot-prefix as "hidden", and we'd lose the discoverable convention that `_shared/` follows IFOS naming rules. Also drifts further from the master brief vocabulary.
docs/decisions/ADR-004-renderer-implementation-deviations.md:80:- **File an upstream issue / PR against cortextOS** to filter out `_shared/` (and other underscore-prefixed names) in `listAgents()`. **Recommended path** — open an issue on the cortextOS repo per master brief §3 boundary 1 ("the submodule is a reference pin, not the runtime; upstream changes go upstream"). Phase 2 ships the deviation as documented; founder + upstream maintainer fix it on their schedule.
docs/decisions/ADR-004-renderer-implementation-deviations.md:93:Current (post-ADR-003 Edit B at master brief §8.3 lines 614-630):
docs/decisions/ADR-004-renderer-implementation-deviations.md:136:> "invoked via `ifos-render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1 + ADR-004 Decision 1; standalone Node binary per `packages/agent-renderer/package.json` `bin`. The `cortextos-ifos render-agent` form named in earlier drafts requires modifying the read-only submodule and was rejected per master brief §3.1 boundary 1)."
docs/decisions/ADR-004-renderer-implementation-deviations.md:148:**For master brief drift.** Edit D + Edit E + Edit F enter the deferred atomic-correction queue (if not landed in this commit). Risk #7 (master-brief-drift-accumulation) is currently closed; reopening it for 3 small text edits is honest but tracked here. Founder decides at ratification time whether to land in this commit or queue for the next atomic correction.
docs/decisions/ADR-004-renderer-implementation-deviations.md:150:**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."
docs/decisions/brain-ui-scope.md:9:**Reading order:** master brief §5.5 (Brain UI build sequence stages) + ADR-002 (parallel-not-shadow + v1.0 brain build wording correction) + `second-brain-design.md` §3.4 closing paragraph (Brain UI v1.0+ scope) first; then this document end-to-end.
docs/decisions/brain-ui-scope.md:15:Per master brief §5.5 (lines 416-424) after ADR-002 Edit 2 applies in the atomic correction commit, the staged Brain UI build is:
docs/decisions/brain-ui-scope.md:19:- **v1.2:** graph view (cytoscape force-directed, master brief §5.3 line 396).
docs/decisions/brain-ui-scope.md:20:- **v2.0:** second-brain-at-scale features (reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views per master brief §5.5).
docs/decisions/brain-ui-scope.md:34:Three features named in master brief §5.5 (post-ADR-002-Edit-2 wording) + `second-brain-design.md` §3.4. Each feature scoped here without implementation commitment.
docs/decisions/brain-ui-scope.md:51:- No mobile-optimised layout (desktop-first per master brief §5.3 line 397 framework choice).
docs/decisions/brain-ui-scope.md:68:- No graph visualisation (text / list format only — graph view is v1.2 per master brief §5.5).
docs/decisions/brain-ui-scope.md:105:- Tight coupling to cortextOS submodule (`packages/harness/cortextos/dashboard/`) — submodule boundary per master brief §3.1 must hold; the `dashboard-ext` integration point is the cortextOS-blessed extension surface, not a fork.
docs/decisions/brain-ui-scope.md:112:- Needs IFOS-owned auth — WorkOS AuthKit per master brief §5.3 line 401 ("Auth: WorkOS AuthKit (per memory: founder already uses this)").
docs/decisions/brain-ui-scope.md:121:| Auth model | cortextOS dashboard auth | WorkOS AuthKit per master brief §5.3 line 401 |
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:154:**No Brain UI tour in v1.0 sales motion.** Brain UI is a forward-feature, not a v1.0 sales asset. The closing demo is the agent outputs landing in the design partner's existing tools — the wedge per master brief §0 paragraph 1. Brain UI joins the sales asset list at v1.1.
docs/decisions/brain-ui-scope.md:168:Per pre-write check: master brief §6 Day 3 line 472 contains **three drifts** bundled into a single-line rewrite.
docs/decisions/brain-ui-scope.md:170:**Current** (master brief §6 Day 3 line 472 verbatim):
docs/decisions/brain-ui-scope.md:220:| Graph visualisation for backlinks panel (cytoscape force-directed) | v1.2 per master brief §5.5 — explicitly v1.2 milestone, not v1.1 |
docs/architecture/agent-bundle-renderer-design.md:6:**Prior work referenced:** master brief §8 (bundle spec); `docs/architecture/second-brain-design.md` §1.7 (R2 inheritance recommendation); `docs/architecture/cortexos-primitive-status.md` Primitive 1 (PTY/PM2 spawn mechanism).
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:45:| `tools.yaml` (line 554) | MCP servers + scopes + degraded modes for external execution backends (Bullhorn, Companies House, Microsoft Graph etc. per master brief §3.2 first-party MCP list) | the renderer (passes through to rendered agent dir); agent uses it via Claude Code's MCP loading at PTY spawn time | **Static** — founder writes once per agent |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:48:| `tests/fixtures/01-primary/` (line 559) | Happy-path input.json + expected.md. The demo example. | CI fixture runner (master brief §8.3 line 628 "Test against fixtures"); not read at runtime | **Static** — author once, regenerate `expected.md` after intentional behaviour changes |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:54:- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:115:| `agents/recruitment/<name>/tests/fixtures/{01-primary,02-edge-case-*,99-voice-drift-canary}/` | **Not rendered** | **Stays in source** | n/a | n/a — fixtures live in the IFOS repo at `agents/recruitment/<name>/tests/fixtures/`; CI fixture runner (master brief §8.3 line 628) reads them there; runtime does not need them |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:143:| `approvals` | cortextOS's per-action approval-gate skill — agent creates an approval entry, blocks until human resolves via Telegram inline buttons | IFOS uses the same primitive 4 approval gates (cortextOS primitive — `src/bus/approval.ts`), but the approval *categories* and *escalation routing* are declared in `tools.yaml` + `agent.md` per master brief §3.2, not via inherited skill documentation |
docs/architecture/agent-bundle-renderer-design.md:153:**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:326:# Hydrate via context-assembly API per master brief §9
docs/architecture/agent-bundle-renderer-design.md:367:A non-zero exit from validate.sh blocks the action (Gate A; master brief §1 Rule 4).
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:465:Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.
docs/architecture/agent-bundle-renderer-design.md:477:- Brand new top-level dir — rejected for cohesion with master brief §4.1's existing `packages/` convention.
docs/architecture/agent-bundle-renderer-design.md:493:- **Daemon auto-renders on bundle change (filesystem watcher inside cortextOS daemon):** rejected because cortextOS daemon is read-only on the submodule (master brief §3.1), and adding render logic to the daemon would couple bundle synthesis to runtime supervision. Two concerns, one process — wrong.
docs/architecture/agent-bundle-renderer-design.md:503:(CLI name per ADR-004 Decision 1; earlier drafts of this design named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1. The corrected standalone `ifos-render-agent` Node binary ships from `packages/agent-renderer/package.json` `bin`.)
docs/architecture/agent-bundle-renderer-design.md:597:- **Merge with conflict markers:** rejected for v1.0. Renderer doesn't have a three-way-merge semantic (source bundle, last-render, current rendered output). Building it adds substantial complexity for a workflow nobody asked for; the master brief §1 Rule 1 ("output before architecture") favours the simple overwrite model.
docs/architecture/agent-bundle-renderer-design.md:622:The v1.0 minimum keeps the renderer's CLI surface small (one mode, two required args) and defers cross-tenant orchestration to bash. The Postgres `tenants` table dependency (v1.0 Day 4 per master brief §6) is what unblocks `--all-tenants`; until then there's no programmatic source of truth for "the list of active tenants."
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
docs/architecture/agent-bundle-renderer-design.md:702:New escalation code added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3:
docs/architecture/agent-bundle-renderer-design.md:764:| Postgres `decision_log` table live (per master brief §6 Day 4) | founder | Day 4 of Week 0 (already scheduled) |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:775:**Current** (master brief §4.1 line 195-204): "Create the operative directory structure" followed by an `mkdir -p` command listing `packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}`.
docs/architecture/agent-bundle-renderer-design.md:787:**Current** (master brief §8.3 lines 614-630): the `bash` block showing the bundle authoring workflow ends with: "Test against fixtures; iterate; commit; PR; merge."
docs/architecture/agent-bundle-renderer-design.md:802:**Current** (master brief §8 lines 545-568): bundle file list with no reference to renderer.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar position; actual execution 2026-05-20)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:12:From master brief §6 Day 7 lines 494-501 verbatim:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:43:- **Primitive 1 (Persistent PTY via PM2):** functional per Day-1 audit `docs/architecture/cortexos-primitive-status.md` — "shipped but flaky" per master brief §12 Risk #1. Day-1 audit found the substrate is operational for development workloads. Quirks 2-3 + 2026-04-22 restart-storm evidence document occasional instability under load, not broken.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:45:- **Primitive 5 (Telegram + iOS approval surface):** confirmed shipped per `cortexos-primitive-status.md` audit. Two-poller mechanism (`agent-manager.ts:478-575`, `maybeStartActivityChannelPoller()`) integrates with primitive 4 approval gates. Per master brief §12 Risk #1 framing: "Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:61:- **"Cleared the auth path" interpretation:** strict — "cleared" means the technical and commercial gates have both passed. Technical path documented (auth-code-against-IFOS-dev-tenant; `client_credentials` foreclosed per master brief §6 Day 2 atomic-correction Edit 6 verified at `0e5b2b4`). Commercial gates not passed. Q3 = NO.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:78:- **8 entities per master brief §6 Day 6 line 490:** `candidate`, `contractor`, `client`, `contact`, `brief` (with `role` alias), `placement`, `opportunity`, `timesheet`.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:100:**Week 0 EXTENDS per master brief §6 line 502.**
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:113:2. **`.codex/ratification/*.md` skills** — master brief §10.2 Day-1 task deferred during Days 0-6; surfaced as gap during Day-7 grounding. Build during extension period. 7 skill files (SKILL.md + 6 review-{type}.md per master brief §10.2). Estimated 2-3 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:133:- If re-run produces 4 of 5 YES (Q3 still NO because Bullhorn commercial conversations haven't completed), founder may accept Q3 as risk-noted and declare Week 0 closed with Week 1 starting under that accepted risk. This is a founder-discretion call, not automatic from the master brief test.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:26:This drift surfaced during the Day-1 primitive audit. It has no Day-0 quirk attached and no real-world brittleness — the bus itself ships and is tested (`tests/unit/bus/message.test.ts`, `tests/integration/multi-agent-crons.test.ts`, `tests/e2e/lifecycle.test.ts`). Only the master brief's mechanism description is wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:32:**1. Correct master brief §2.4 row 3.** Replace:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:47:| **B. Reduce to 250ms** | Set `pollInterval: 250` in the IFOS agent template's `config.json`. Re-measure daemon CPU on a 6-agent fleet under load (master brief §6 Day 4 stress-test addition). Keep the existing "complete in seconds" framing | ~0.5 day to add the config + re-baseline; ongoing 4× CPU per FastChecker poll (still negligible — `readdirSync` on a typically-empty inbox dir is sub-millisecond, so 4× sub-ms is still sub-ms). The risk is `bus-signing-key` HMAC verification cost × 4 if inbox traffic spikes | Pipeline floor drops to ~750ms — restores headroom for the sales narrative while leaving CPU comfortable. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:51:1. The honest-signal Rule 5 (master brief §1) makes "rewrite the claim" cheaper than "tune the substrate to fit the claim".
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:58:- Single edit to master brief §2.4 row 3 (the correction itself).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:66:- Day 4 infra stress-test (master brief §6) gains a new sub-task: measure daemon CPU on a synthetic 6-agent fleet at 250ms poll vs 1000ms baseline.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:71:- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:76:**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
docs/decisions/autosend-safety-policy.md:21:**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:188:      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:585:4. **Cyber insurance.** IFOS Limited needs cyber insurance covering policy miscategorisation events. Quote requests pending; budget impact on v1.0 founder-set cost budget (Day-4 runbook §1.4 — £20/mo for infrastructure at single-tenant pilot scale; master brief does not specify a numeric cost target).
docs/decisions/autosend-safety-policy.md:620:- **Q3 (lookup latency / 71-hour cache lifetime):** ACCEPTED for v1.0. Policy hot-reload deliberately deferred to v1.1+; v1.0 accepts up-to-71-hour delay on policy changes taking effect at agent layer. Material policy changes must wait for next 71-hour boundary (cortextOS context rotation per master brief §2.4 primitive 2) or trigger deliberate cortextOS PTY restart. Operational footgun documented in §4.
docs/decisions/autosend-safety-policy.md:648:**For atomic-correction manifest.** Edit 10 adds the path drift correction (master brief §6 Day 5 line 484-485 → docs/decisions/). Manifest grows from 9 to 10.
docs/decisions/autosend-safety-policy.md:660:**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 484-485 paths to live at `docs/decisions/`.
docs/architecture/second-brain-design.md:14:The goal: confirm what cortextOS uses its own KB for, so we know what we are deliberately leaving alone — and verify the master brief §3.1 submodule boundary is not in tension with the plan in Q3.
docs/architecture/second-brain-design.md:52:**IFOS agents do not run cortextOS's heartbeat-memory pattern.** The IFOS Agent Bundle v2 (master brief §8.1) specifies six files per agent:
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:76:- This respects master brief §3.1 ("never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points") without exercising the exception — we don't shadow them at all.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:136:1. **It honours the §3.1 boundary cleanly.** The §3.1 exception in master brief is "the four `bus/kb-*.sh` shadow points." If we don't shadow them (per §1.5), inheriting skills that call them invites confusion — the inherited skills point at cortextOS's KB, and we'd need to remember that IFOS-owned agents must not invoke them. R2 removes the question entirely.
docs/architecture/second-brain-design.md:140:**Until the renderer is built** (Week 0 has no agent code per master brief §6 Day 7; the renderer is a Week 1+ concern), the inherited-skills risk only matters for any debug/probe agents scaffolded via `cortextos-ifos add-agent` during Week 0 verification. Those probe agents will inherit the kb-* calls and write to cortextOS's KB — which is fine, because cortextOS's KB stays in place per §1.5.
docs/architecture/second-brain-design.md:161:/vault/{tenant-slug}/                               ← path per master brief §3.3 line 217, Ultraplan §5.1 line 217
docs/architecture/second-brain-design.md:163:│   ├── style-guide.md                              ← master brief §5.5 footnote, Ultraplan §5.2 wizard Day 3
docs/architecture/second-brain-design.md:169:├── wiki/                                           ← the second brain (master brief §5.1 line 306)
docs/architecture/second-brain-design.md:170:│   ├── raw/                                        ← append-only ingestion (master brief §5.1 lines 316-321)
docs/architecture/second-brain-design.md:171:│   │   ├── inbox-emails/                           ← from email ingestion (master brief §5.1 line 317)
docs/architecture/second-brain-design.md:172:│   │   ├── calls/                                  ← Fathom/Fireflies transcripts (master brief §5.1 line 318)
docs/architecture/second-brain-design.md:173:│   │   ├── briefs/                                 ← inbound brief detection (master brief §5.1 line 319)
docs/architecture/second-brain-design.md:174:│   │   ├── notes/                                  ← freeform consultant notes (master brief §5.1 line 320)
docs/architecture/second-brain-design.md:175:│   │   └── ats-snapshots/                          ← Bullhorn entity snapshots (master brief §5.1 line 321)
docs/architecture/second-brain-design.md:176:│   ├── compiled/                                   ← LLM-owned, agent-managed (master brief §5.1 line 323)
docs/architecture/second-brain-design.md:177:│   │   ├── index.md                                ← master index, one-line per page (master brief §5.1 line 324)
docs/architecture/second-brain-design.md:178:│   │   ├── candidates/                             ← one .md per Candidate (master brief §5.1 line 325)
docs/architecture/second-brain-design.md:179:│   │   ├── clients/                                ← one .md per Client (master brief §5.1 line 326)
docs/architecture/second-brain-design.md:180:│   │   ├── briefs/                                 ← one .md per Brief (master brief §5.1 line 327)
docs/architecture/second-brain-design.md:181:│   │   ├── placements/                             ← one .md per Placement (master brief §5.1 line 328)
docs/architecture/second-brain-design.md:182:│   │   ├── people/                                 ← Contacts at clients (master brief §5.1 line 329)
docs/architecture/second-brain-design.md:183:│   │   ├── concepts/                               ← firm domain concepts (master brief §5.1 line 330) — v1.2+ deferred
docs/architecture/second-brain-design.md:185:│   │   └── archive/                                ← absorbed/deleted pages (master brief §5.1 line 332)
docs/architecture/second-brain-design.md:186:│   └── .wiki/                                      ← compilation state (master brief §5.1 line 334)
docs/architecture/second-brain-design.md:187:│       ├── manifest.json                           ← per-raw-file compilation status (master brief §5.1 line 335)
docs/architecture/second-brain-design.md:188:│       ├── reflect-state.json                      ← reflect cycle state (master brief §5.1 line 336)
docs/architecture/second-brain-design.md:189:│       └── graph.json                              ← cached graph for fast UI loads (master brief §5.1 line 337) — v1.2 graph view
docs/architecture/second-brain-design.md:203:| `wiki/raw/inbox-emails/` | one file per email | markdown with frontmatter | `{epoch}-{from-domain}-{rand5}.md` | inbound email webhook handler (v1.0: Cash Conductor for AR-relevant; v1.1: Triage for everything) | Brief Decoder (v1.1), Cash Conductor (v1.0); future Pulse semantic-search-over-raw |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:227:Eight canonical entities exist per master brief §6 Day 6 / Ultraplan §11 Day 6 line 490:
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:246:**Frontmatter schema** (master brief §5.2 lines 357-369 starting example; extended for v1.0 completeness):
docs/architecture/second-brain-design.md:311:xero_contact_id: 9876                                # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:394:**Decision: adopt `[[Entity-Type: Display Name]]` verbatim** as master brief specifies. Rationale: matches master brief decision, Obsidian-compatible, human-readable in raw markdown. Cost: rename safety is fragile — renaming "Sarah Bowen" to "Sarah Bowen-Smith" breaks all links unless an explicit rewrite step runs.
docs/architecture/second-brain-design.md:398:**Spec gap 2.2-A:** master brief §5 does not specify the rewrite-backlinks mechanism. Recommended resolution: implement as part of `update-entity` in `packages/brain/wiki/lib/update.ts` v1.0.
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:437:- Graph multi-hop traversal — v1.2 graph view (master brief §5.5 line 423)
docs/architecture/second-brain-design.md:438:- Wiki health reflect (orphan detection, contradiction detection) — v1.1 (master brief §5.2 lines 371)
docs/architecture/second-brain-design.md:439:- Per-firm LoRA query — v2.0 (master brief §5.5 line 424)
docs/architecture/second-brain-design.md:456:- **Obsidian compatibility:** frontmatter restricted to YAML 1.2 features Obsidian's `gray-matter` parser accepts — strings, ints, floats, ISO 8601 strings, flow-style and block-style sequences, flow-style and block-style mappings (one level of nesting only). **No anchors, no aliases, no merge keys, no custom tags.** Wiki-links in body use Obsidian's `[[Display Name]]` and `[[Type: Display Name]]` syntax — both render. Frontmatter `linked_entities` is a list of strings that *look like* wiki-links; Obsidian doesn't render frontmatter strings as links by default, but the master brief §5.2 example uses this form and we adopt it.
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:465:**Table: `tenants`** (master brief §3.3 + Ultraplan §5.1)
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:569:**Spec gap 2.4-B:** Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`". This design splits them into `entities` + `entity_links` for clearer indexing semantics. **Recommended resolution:** adopt the split; update master brief §3.3 or Ultraplan §5.1 to reflect the two-table model. Codex-ratifiable on Day 7 by reading this section.
docs/architecture/second-brain-design.md:672:| `search-by-name` | Postgres `entities` trigram on `display_name` (`gin_trgm_ops`) | Filesystem grep over `wiki/compiled/{type}/*.md` frontmatter | Hot path; sub-second target. Fuzzy match returns top-N by similarity score; tie-break by `importance_score DESC` then `updated_at DESC`. Fallback only fires if Postgres unhealthy (per master brief §3.5 RLS / Ultraplan §3.5 degraded-mode contingency). |
docs/architecture/second-brain-design.md:701:- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
docs/architecture/second-brain-design.md:727:**Spec gap 2.6:** none of this is in the master brief. **Recommended resolution:** adopt the mechanism above verbatim; document in a `docs/architecture/vault-concurrency.md` companion file in Week 1 (before agent code starts). **Blocks v1.0 build:** no — concurrency code is a v1.0 build artefact, not a Week 0 prerequisite, but the design needs to land before the first multi-agent test in week 5.
docs/architecture/second-brain-design.md:747:**Why not atomic across all files:** filesystems aren't transactional across files. Atomic-by-emulation (write all to `.tmp` then rename all) is brittle and doesn't compose with `flock`. Eventually-consistent with Postgres-as-truth is the realistic choice and matches master brief §3.3's "Postgres is the source of truth for state and provenance."
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
docs/architecture/second-brain-design.md:893:| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
docs/architecture/second-brain-design.md:896:| **Lock-in cost** — how hard to switch to a different option later | Low. Wrappers are 3-line shims; replace with calls to a different backend (MCP server, library) by changing the `exec` line. Library is reusable. Agents see the same `cortextos-ifos bus wiki-search` invocation regardless of backend — interface stable. | Medium. Agents have MCP `tools.yaml` entries committed; migration to α means rewriting `agent.md` and `tools.yaml` for every agent (18 in full strength per master brief §0). Library is reusable. | High. Skill-installation path is per-agent; migration requires per-agent skill removal + new wrapper/MCP declaration. Also under R2 the original installation path was a hack, which makes "switch away from γ" the cleanup of that hack. |
docs/architecture/second-brain-design.md:904:**Rationale anchored to three master brief sections:**
docs/architecture/second-brain-design.md:920:- **v1.2 graph view (master brief §5.5):** add `wiki-graph-traverse.sh` and a `graphify` subcommand. Surface grows by N scripts, not by architecture.
docs/architecture/second-brain-design.md:921:- **v2.0 LoRA scale (master brief §5.5):** the LoRA pipeline operates on the `decision_log` table, not on the wiki. Wiki ops from LoRA-enhanced agents are unchanged. Both options work.
docs/architecture/second-brain-design.md:924:**v1.0 build day estimate for Option α: 11-13 days.** Fits master brief §5.5's weeks 11-13 allocation. Detail in §3.4 below.
docs/architecture/second-brain-design.md:926:### 3.4 — Impact on master brief §5.5 build sequence
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:956:- **Scope:** larger than master brief §5.5 currently states (9 ops + 4 Postgres tables + concurrency machinery, vs. the original "2 ts files"). Still fits the 11-13 day budget because the bulk of the surface area is small Postgres operations with thin shell wrappers; the heavy code is in `concurrency.ts` and `update.ts` which together are ~400-600 lines.
docs/architecture/second-brain-design.md:958:- **Earlier work needed:** Postgres schema and the entity_graph→entities+entity_links rename move to Week 0 Day 4 (this week, already planned per master brief §6).
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/architecture/second-brain-design.md:969:| **2.1-C** | `wiki/compiled/playbooks/` (master brief §5.1 line 331) collides with `/vault/{tenant}/_playbooks/` (Ultraplan §5.1) | Same folder name at two paths with different intended uses | **Recommendation:** drop `wiki/compiled/playbooks/`. Playbooks live at `/vault/{tenant}/_playbooks/` only. Update master brief §5.1 to remove the `playbooks/` line from the `wiki/compiled/` tree. | No |
docs/architecture/second-brain-design.md:973:| **2.4-B** | Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`" | Single-table model insufficient for the JSONB GIN + trigram + adjacency mix v1.0 needs | Split into `entities` + `entity_links` per §2.4.2. Update master brief §3.3 / Ultraplan §5.1 wording. **Roll into Week 0 Day 4 Postgres provisioning.** | **Tight** — Day 4 of Week 0 (this week). |
docs/architecture/second-brain-design.md:981:## Impact on master brief §5.5 build sequence — closing paragraph
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
docs/decisions/v1.0-kill-criterion.md:37:**v1.0 commitments to existing pilots are honoured under original scope.** New v1.0 contracts under rescoped terms. The master brief and Ultraplan are amended by atomic-correction commit; Codex ratifies before v1.0 resumption.
docs/decisions/v1.0-kill-criterion.md:47:**Threshold:** No design partner has confirmed pilot intent (signed LOI or equivalent written commitment to pilot in Q3 2026 per master brief §6 Day 7 question 1) by end of Week 2.
docs/decisions/v1.0-kill-criterion.md:53:**Source:** Risk #3 in `docs/RISK-REGISTER.md` (escalating status); Day-5 Risk #3 update reflects "zero design partners in pipeline" as of this commit; master brief §6 Day 7 question 1.
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:89:**Recovery path:** PIVOT is structural; resumption is via rescoped v1.0 under new ATS assumption. Pivoted v1.0 continues with adjusted master brief / Ultraplan; atomic-correction commit lands the rescope.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:134:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:156:**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
docs/decisions/v1.0-kill-criterion.md:164:**Source:** Master brief §6 Day 5 line 486 — canonical example trigger from master brief.
docs/decisions/v1.0-kill-criterion.md:182:**Unfreeze criterion:** Either (1) cortextOS upstream PR lands the fix (per master brief §3.1 cross-vertical primitive process), OR (2) IFOS vendor-patches via `packages/harness-patches/` per master brief §3.1 fallback path. Unfreeze after **2 consecutive incident-free weeks** (matched to tightened threshold).
docs/decisions/v1.0-kill-criterion.md:306:1. Rescope plan replaces affected slices of master brief and Ultraplan. New atomic-correction commit lands the rescope edits (separate from the existing 10-edit atomic-correction manifest — pivot is a wholly new manifest event).
docs/decisions/v1.0-kill-criterion.md:322:4. v1.1 — if launched — is a wholly new initiative under different premises. Not a continuation of v1.0. Has its own master brief, Ultraplan, kill criterion.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:338:- The vertical assumption: UK recruitment agencies (per master brief §0 + Product Spec)
docs/decisions/v1.0-kill-criterion.md:345:v1.1 begins when v1.0 is operationally stable with ≥1 pilot operational. v1.1 scope per master brief §9 build sequence + Product Spec:
docs/decisions/v1.0-kill-criterion.md:350:- Adds AgentMail integration (Inbound Triage only) per master brief §3.2
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/decisions/v1.0-kill-criterion.md:399:**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 486 path to live at `docs/decisions/`.
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:33:// EXISTS in upstream — read-only submodule per master brief §3.1 boundary 1
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:261:**Founder decision:** schedule for Week 9 (sequential with master brief) OR insert now (parallel with Diagnostic prep).
docs/decisions/sequencing-target.md:6:**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:46:The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
docs/decisions/sequencing-target.md:50:Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
docs/decisions/sequencing-target.md:65:Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:84:**Section 4's recommendation evaluates both orderings** (founder-prompt-Alpha and master-brief-Alpha) against the §1.3 criteria, picks whichever wins on the merits, and explicitly aligns with the master brief by default unless rationale exists to revise it. This document is the "confirm or revise" decision per master brief §6 Day 3 line 471 — both options are on the table.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:142:**Hire-#1 anchor (per Ultraplan §9 line 766 verbatim):** "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)." Cash Conductor's three-accounting-API + Open-Banking integration is the right scope for Hire #1's first sprint per Ultraplan §9 — this places Cash Conductor at W7-8 in the canonical sequence.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:184:W7-8: Cash Conductor (A4) — Hire-#1-anchored per Ultraplan §9 line 766
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:194:- W7-8: Risk #1 (cortextOS Primitives 1+4+5) — Cash Conductor first Tier-1. Reduction trigger fires.
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:232:W11:  Cash Conductor (A4)
docs/decisions/sequencing-target.md:236:**Why this ordering:** Front-load risk-de-risking by building Concierge (the most Primitive-heavy agent) early. Cash Conductor's Risk #1 exercise becomes redundant if Concierge already exercises Primitives 1+2+4+5.
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:242:3. **Hire-#1 anchor broken.** Cash Conductor at W11 is 4 weeks after Hire #1's assumed W7 start. Hire #1 again has no first-sprint scope.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:307:**Trigger 2 — Risk #4 materialises (Hire #1 doesn't start by end of Week 4).** Per RISK-REGISTER #4 tripwire "No offer accepted by end of week 4":
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:334:- Whether Cash Conductor's 2-week build can compress if Hire #1 onboarding is fast — deferred to Week 7 Cash-Conductor-kickoff check-in.
docs/decisions/sequencing-target.md:335:- Per-agent Codex-ratification timing within each build slot — every `agent.md` ratifies before merge per master brief §10.5; specific ratification cadence emerges from each agent's PR cycle.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:374:4. **If scope-cut activates twice in one v1.0 cycle, escalate to v1.0 kill criterion** — the Day 5 work (master brief §6 Day 5) defines the kill-criterion threshold; sequencing failures count toward that threshold.
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:449:- §4.3 revisit conditions name specific tripwires (Risk #2, Risk #4, Hire #1) and concrete activation actions (decider + updates required + cascade).
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:455:Per §1.5 Spec gap §1-A finding: master brief §6 Day 3 line 471 names the path `.agents/decisions/sequencing-target.md` but the convention established by Days 1-2 is `docs/decisions/`. Same path-convention drift applies to line 472 (Brain UI scope decision; will be flagged in `brain-ui-scope.md` separately if needed).
docs/decisions/sequencing-target.md:457:**Current** (master brief §6 Day 3 line 471 verbatim):
docs/decisions/sequencing-target.md:489:| §1-A | §6.8 + atomic correction commit edit 7 | Path convention `.agents/decisions/` → `docs/decisions/` for master brief §6 Day 3 line 471 (and likely line 472 per brain-ui-scope.md) |
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:491:| Revisit conditions | §4.3 | Three triggers named (Risk #2, Risk #4, Hire #1) with decider + activation + updates + cascade per trigger |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/2026-05-18-codex-ratification-manifest.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar; actual execution 2026-05-20)
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:140:**Round-4 disagreement protocol** (per master brief §10 + Day-8 pattern):
docs/decisions/2026-05-18-codex-ratification-manifest.md:188:## §2 — Ratification protocol per master brief §10.3
docs/decisions/2026-05-18-codex-ratification-manifest.md:190:Verbatim from master brief §10.3 (post-Edit 7 path correction):
docs/decisions/2026-05-18-codex-ratification-manifest.md:216:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:228:| **Build `.codex/ratification/*.md` skills** | Week 0 extension period (concurrent with Q1 design-partner work) | 2-3 person-days. 7 skill files per master brief §10.2; each follows the "RATIFIED / REJECTED with numbered issues" output contract. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:229:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:230:| **Disagreement artefacts** | If Codex REJECTS or disagrees with any artefact | `docs/decisions/codex-disagreement-<date>.md` per master brief §10.3 step 4. Founder decides on escalations. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:236:**LANDED TODAY at `0e5b2b4`** — `docs: master brief reconciliation — 11 edits batch-applied`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:271:| 9 | `brain-ui-scope.md` | Proposed pending v1.1 phase | Likely Codex ratifies as-is post-Edit 8 atomic correction (master brief §6 Day 3 line 472 + §5.5 now consistent). No founder action needed. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:286:3. **What landed today** (atomic-correction commit `0e5b2b4`; master brief fully reconciled).
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:17:Three sub-decisions, named in master brief §6 Day 2 line 466 and extended in Ultraplan §11 Day 2 lines 847-849.
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:42:This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
docs/decisions/bullhorn-integration-path.md:48:**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:70:| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
docs/decisions/bullhorn-integration-path.md:74:The Sunday design-partner conversation 2 is the most time-sensitive: it can flip the entire premise of Sub-decisions A and C. Founder cadence per master brief §6 Day 2 (line 467) and §11.2 line 791 ("Day 2 — Tuesday — Bullhorn integration path... — Design-partner conversation 2") puts this as a parallel-to-Claude-Code track.
docs/decisions/bullhorn-integration-path.md:91:- **Day 7 review (master brief §6 Day 7 Sunday):**
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:226:**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:239:This forecloses one option that the master brief §6 Day 2 line 466 pre-statement contemplated — "service-account for dev." The closest substitute is one of:
docs/decisions/bullhorn-integration-path.md:256:**Recommendation:** authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement "browser dance for production"). For IFOS dev: authorization-code grant against an IFOS-owned Bullhorn dev tenant; service-account / client_credentials grant deferred (because Bullhorn doesn't document support for it per §3.2).
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:375:3. First design partner ATS confirmed as Bullhorn (Sunday design-partner conversation 2 per master brief §6 Day 2 line 467).
docs/decisions/bullhorn-integration-path.md:381:Recommendation: authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement); authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (client_credentials grant **foreclosed** by Bullhorn OAuth docs per §3.2 — Bullhorn does not support client_credentials grant for tenant-scoped data). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:442:§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.
docs/decisions/bullhorn-integration-path.md:444:**Current** (master brief §6 Day 2 line 466 verbatim):
docs/decisions/bullhorn-integration-path.md:452:Joins the atomic correction commit at end of Week 0 / early Week 1. Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '1,390p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Cash Conductor — the FD's evenings back
     2	
     3	**Status:** Proposed (Day-18 pre-W7-8-build scaffold; awaits Q1 LOI + accounting + Open Banking commercial signups + W7 build slice OR earlier-pull-forward per ADR-005 if Bullhorn delays persist).
     4	**Date:** 2026-05-24.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
     7	**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 541.
     8	**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
     9	**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
    10	
    11	---
    12	
    13	## §1 — Output contract (one-paragraph screenshot)
    14	
    15	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    16	
    17	> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 539). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 539 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 540) — the FD-tier closer metric. Chase drafts are orange-tier per `autosend-safety-policy.yaml` (consultant approval required before send via Concierge); reconciliation writes are yellow-tier.
    18	
    19	---
    20	
    21	## §2 — Invocation surface
    22	
    23	### Webhook (v1.0 primary path)
    24	
    25	```http
    26	POST https://<tenant>.ifos.app/agents/cash-conductor/webhook
    27	Authorization: Bearer <provider-shared-secret>
    28	Content-Type: application/json
    29	
    30	# Event types (per provider):
    31	# - Xero/QuickBooks/Sage: invoice.created, invoice.sent, invoice.viewed,
    32	#   invoice.paid, payment.received
    33	# - Open Banking (TrueLayer/Plaid UK): transaction.posted, balance.updated
    34	```
    35	
    36	Per-provider webhook auth handled in `tools.yaml`.
    37	
    38	### Cron (daily reconciliation sweep)
    39	
    40	```bash
    41	# 07:00 UTC daily — bank feed catch-up + invoice age scan
    42	0 7 * * * sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode daily-sweep
    43	```
    44	
    45	### Weekly report cron
    46	
    47	```bash
    48	# Monday 06:00 UTC — cash-flow report regeneration
    49	0 6 * * 1 sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode weekly-report
    50	```
    51	
    52	### Manual triggers (v1.0)
    53	
    54	```bash
    55	ifosctl cash-conductor reconcile --tenant <slug> [--invoice <id>]
    56	ifosctl cash-conductor draft-chase --tenant <slug> --invoice <id>
    57	ifosctl cash-conductor weekly-report --tenant <slug>
    58	```
    59	
    60	### v1.1+ surfaces (deferred)
    61	
    62	- Brain UI cash-flow dashboard
    63	- Per-tenant Telegram daily summary
    64	- FD-mode end-of-month report (more detailed than weekly)
    65	
    66	---
    67	
    68	## §3 — Output shape
    69	
    70	Three outputs. All load-bearing.
    71	
    72	### Output 1 — Reconciliation rows (yellow tier)
    73	
    74	Per webhook event, Cash Conductor reconciles incoming bank deposits against the tenant's open invoice register. Match algorithm:
    75	
    76	| Stage | Match dimensions | Confidence |
    77	|---|---|---|
    78	| 1 | Exact amount + matching invoice reference in transaction memo | 0.98 |
    79	| 2 | Exact amount + matching payee name | 0.85 |
    80	| 3 | Exact amount + within-90-day-of-invoice-issue window | 0.70 |
    81	| 4 | Fuzzy amount (±0.5% rounding) + matching payee name | 0.65 |
    82	| 5 | Unmatched (queued for review) | <0.50 |
    83	
    84	Stages 1-2 auto-write reconciliation to accounting system (yellow tier; spot-check sampled). Stages 3-4 queue for consultant review. Stage 5 flagged in weekly report.
    85	
    86	Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
    87	
    88	### Output 2 — Payment-chase drafts (orange tier)
    89	
    90	For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. Output is a queued draft, NOT a send. Drafts route to Concierge (which handles the actual send pipeline + consultant approval per autosend §4 orange tier).
    91	
    92	Chase draft structure:
    93	
    94	```yaml
    95	draft_id: <uuid>
    96	invoice_id: <accounting-system-invoice-id>
    97	contact_email: <client-billing-contact-email>
    98	subject: "Friendly reminder — invoice <number> from <YYYY-MM-DD>"
    99	body_markdown: <voice-classified consultant-tone reminder>
   100	amount_due: <decimal>
   101	days_overdue: <int>
   102	prior_chases_sent: <int>
   103	escalation_ladder_position: 1-4 per §3.2 below
   104	expected_send_window: orange-tier approval expected within 24h
   105	```
   106	
   107	Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='chase_draft'`, `tier='orange'`, payload includes the draft.
   108	
   109	### §3.2 — Chase escalation ladder
   110	
   111	| Position | Trigger | Tone | Voice classifier minimum |
   112	|---|---|---|---|
   113	| 1 | 7 days overdue | "Friendly reminder, hope everything's OK on your end" | ≥0.75 |
   114	| 2 | 14 days overdue, position-1 sent | "Following up — please let us know if there's a query" | ≥0.75 |
   115	| 3 | 21 days overdue, position-2 sent | "Need to flag this; can we schedule a quick call?" | ≥0.80 (higher bar) |
   116	| 4 | 30 days overdue, position-3 sent | "Escalation to operator review" — drafts STOP; operator manual handle | n/a (not sent) |
   117	
   118	Position 4 is the kill-switch: Cash Conductor never auto-drafts beyond position 3. Operator decides next step manually.
   119	
   120	### Output 3 — Weekly cash-flow Markdown report
   121	
   122	Located at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md`. Generated Monday 06:00 UTC. Six sections:
   123	
   124	| # | Section | Content |
   125	|---|---|---|
   126	| 1 | **Week summary** | Receipts received + invoices issued + invoices paid + new chases sent |
   127	| 2 | **DSO trend** | Days-Sales-Outstanding metric this week vs prior-week vs month-0 baseline; Gate B tracking |
   128	| 3 | **Aged debtors** | Invoices outstanding bucketed (0-30 / 31-60 / 61-90 / 90+ days); per-client totals |
   129	| 4 | **Chase pipeline** | Active chase drafts by position 1-3; pending consultant approval; sent-but-no-response |
   130	| 5 | **Cash-flow forecast** | 4-week forward cash projection (open invoices + expected payments per historical conversion rate) |
   131	| 6 | **Exception list** | Reconciliation failures; bank-feed gaps; accounting-API failures; operator action items |
   132	
   133	---
   134	
   135	## §4 — Workflow
   136	
   137	14 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   138	
   139	```
   140	0. Session start (webhook OR cron OR manual)
   141	   → context.sh hydrates: tenant config + accounting-provider auth +
   142	     Open Banking auth + voice corpus + tone rules
   143	   → hh_decision_trigger("session_start", "<webhook|cron|manual>")
   144	
   145	1. Provider auth refresh
   146	   → accounting: Xero/QuickBooks/Sage OAuth refresh per provider
   147	   → Open Banking: TrueLayer/Plaid UK 90-day token refresh (CRITICAL —
   148	     gotcha §6.1 of ULTRAPLAN A4 line 542); if <30 days until expiry,
   149	     fire ESC_OPEN_BANKING_TOKEN_AGING (operator must re-authorise)
   150	   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on failure
   151	
   152	2. Event router (mode-dependent)
   153	   → if mode=webhook: parse event_type → routes to Step 3-7 path
   154	   → if mode=daily-sweep: skip to Step 8 (catch-up reconciliation)
   155	   → if mode=weekly-report: skip to Step 13
   156	
   157	3. Bank transaction ingest (mode=webhook from Open Banking)
   158	   → fetch latest transactions since last_ingested_at
   159	   → normalise schema (TrueLayer vs Plaid have different formats)
   160	   → store in /vault/<tenant>/cash-conductor-cache/transactions.jsonl
   161	     (90-day rolling; chmod 0600; LUKS-encrypted)
   162	
   163	4. Invoice register ingest (mode=webhook from accounting OR daily-sweep)
   164	   → accounting.list_open_invoices() per provider
   165	   → store in /vault/<tenant>/cash-conductor-cache/invoices.jsonl
   166	
   167	5. Reconciliation pass (5-stage match algorithm per §3 Output 1)
   168	   → for each transaction × open invoice: compute match confidence
   169	   → write Stage 1-2 matches to accounting (yellow tier) atomically
   170	   → queue Stage 3-4 matches for consultant review
   171	   → flag Stage 5 (unmatched) in weekly-report exception list
   172	
   173	6. Reconciliation write (yellow tier; per match)
   174	   → accounting.write_payment_received(invoice_id, payment_id, amount, date)
   175	   → atomic transaction; rollback on 4xx/5xx
   176	   → ESC_ACCOUNTING_WRITE_FAIL on failure
   177	   → spot-check sampling per autosend-safety-policy.yaml yellow tier
   178	
   179	7. Chase generation pass (for overdue, unmatched invoices)
   180	   → query open invoices with age >7 days AND no Stage-1/2 reconciliation
   181	   → for each, determine chase position 1-4 based on age + prior chases
   182	     sent (counted from decision_log decision_log.payload.position)
   183	   → if position=4: STOP — operator review (no auto-draft)
   184	   → else: proceed to Step 8
   185	
   186	8. LLM chase-draft generation (per overdue invoice)
   187	   → prompt = (invoice details + client context + position-N tone +
   188	     voice corpus + tone rules)
   189	   → output = email body + subject
   190	   → voice classifier scores against tenant style (≥0.75 for position 1-2;
   191	     ≥0.80 for position 3 per §3.2)
   192	   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
   193	
   194	9. Chase-draft validation (Gate A specifics)
   195	   → verify: invoice_number cited matches invoice_id
   196	   → verify: amount_due cited matches accounting record
   197	   → verify: client_contact_email matches active billing contact
   198	   → verify: NOT paid in last 24h (re-query accounting)
   199	   → ESC_SCHEMA_VIOLATION on any miss
   200	   → ESC_AUTOSEND_BLOCKED if chase proposed for paid invoice (defence-in-depth)
   201	
   202	10. Chase-draft queue to Concierge (orange tier)
   203	    → POST internal API → Concierge agent receives draft
   204	    → Concierge handles autosend-bridge call to operator (D1 path per
   205	      Founder Decision)
   206	    → hh_decision_output("chase_draft", invoice_id, payload_preview);
   207	      tier=orange; awaiting operator approval
   208	
   209	11. (Operator approves via Concierge → Concierge sends → Cash Conductor
   210	    records send event)
   211	    → Concierge fires webhook back: chase_sent
   212	    → Cash Conductor updates internal state: prior_chases_sent counter
   213	
   214	12. (Mode=webhook only) Re-trigger eligibility check
   215	    → was this webhook also a "payment received" that just hit?
   216	    → re-run Step 5 to check if any chases-in-flight should be cancelled
   217	      (paid-since-draft-but-before-send race condition)
   218	    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
   219	
   220	13. Weekly report assembly (mode=weekly-report; runs Monday 06:00 UTC)
   221	    → query decision_log + accounting + bank feed for the 7-day window
   222	    → compute DSO metric (Gate B tracking)
   223	    → 6-section Markdown report per §3 Output 3
   224	    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
   225	    → hh_decision_output("weekly_report", report_path)
   226	
   227	14. Session close
   228	    → update tenant_adapters.config.cash_conductor_last_run = now()
   229	    → hh_decision_action("cash_conductor_run_complete", session_id,
   230	      run_mode, payload_hash, payload_preview)
   231	    → exit code 0
   232	```
   233	
   234	---
   235	
   236	## §5 — Gates
   237	
   238	### Gate A — validate.sh (hard-fail before action)
   239	
   240	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 539 verbatim):
   241	
   242	- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
   243	- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
   244	- Voice classifier score ≥0.75 for position 1-2 chases; ≥0.80 for position 3
   245	- No PII outside firm boundary in chase body
   246	- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
   247	- Open Banking token >30 days from expiry (otherwise warn)
   248	- Accounting auth refresh succeeded in Step 1
   249	
   250	Gate A failures fire `ESC_SCHEMA_VIOLATION` or `ESC_AUTOSEND_BLOCKED`; draft stays in `/tmp` (auto-purged 24h); operator notified.
   251	
   252	### Gate B — Outcome threshold (FD-tier closer metric)
   253	
   254	Per ULTRAPLAN A4 line 540 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
   255	
   256	DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.
   257	
   258	Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
   259	
   260	This is THE FD-tier closer metric per master brief §8.2 line 597. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
   261	
   262	---
   263	
   264	## §6 — Escalation codes
   265	
   266	Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
   267	
   268	| Code | Trigger | Severity | Routing |
   269	|---|---|---|---|
   270	| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   271	| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
   272	| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
   273	| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking token <30 days from 90-day expiry | warn (info if <60 days; warn if <30; blocking if <7) | operator_chat_id → ifos_oncall as expiry nears |
   274	| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 3-4 match queued for review | info | (logged; aggregated to weekly report exception list) |
   275	| `ESC_AUTOSEND_BLOCKED` | Chase proposed for paid invoice OR race condition detected | **blocking** | operator + ifos_oncall |
   276	| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
   277	| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
   278	| `ESC_VOICE_DRIFT_TENANT` | Consultant edit-rate on chase drafts >50% in 30-day window | warn | operator + tenant-admin |
   279	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
   280	| `ESC_SCHEMA_VIOLATION` | Gate A miss (invoice/amount/contact validation) | **blocking** | operator + ifos_oncall |
   281	| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
   282	| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
   283	| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval >24h | info | (logged; weekly report) |
   284	
   285	Cash Conductor does NOT use Bullhorn-specific codes (no Bullhorn dependency).
   286	
   287	---
   288	
   289	## §7 — Voice + tone constraints
   290	
   291	Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   292	
   293	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
   294	  - No "Final demand" or legal-threatening language (escalation ladder caps at position 3; position 4 is operator-handled)
   295	  - No reference to the client's industry / sector pain points (chase is operational, not strategic)
   296	  - No mentions of late-payment fees unless tenant's terms explicitly state them
   297	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
   298	- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Edit-distance >150 chars on >40% of chase recent_edits fires `ESC_VOICE_DRIFT_TENANT`.
   299	
   300	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   301	
   302	---
   303	
   304	## §8 — Build dependencies (W7-8 prerequisites OR earlier per ADR-005 pull-forward)
   305	
   306	Cash Conductor build cannot start until ALL of the following are confirmed:
   307	
   308	| Dependency | Source | Status |
   309	|---|---|---|
   310	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   311	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   312	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   313	| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
   314	| **Accounting commercial signup** (developer access + sandbox) | Founder commercial | ⏸ |
   315	| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
   316	| Xero MCP connector | W7 build start (~2 days) | ⏸ |
   317	| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
   318	| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
   319	| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
   320	| Per-tenant accounting credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   321	| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   322	| Concierge agent in production (for chase-send routing) | W10-13 build | ⏸ |
   323	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   324	| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
   325	| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
   326	| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
   327	| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |
   328	
   329	**Per ADR-005 §5.1 pull-forward provision:** if Bullhorn Sub-decisions A+B answers delay past 2026-06-10, Cash Conductor may be pulled forward from W7-8 to W4-5 because it has zero Bullhorn dependency. The other prerequisites (accounting + Open Banking commercial signups) remain founder-action gates regardless.
   330	
   331	---
   332	
   333	## §9 — Status + open questions
   334	
   335	**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start (or earlier per ADR-005 pull-forward).
   336	
   337	### Open questions for founder review
   338	
   339	| # | Question | Resolution path |
   340	|---|---|---|
   341	| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
   342	| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
   343	| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
   344	| Q4 | Chase escalation ladder — 4 positions proposed in §3.2. Founder confidence each position's timing + tone is right? | Founder review with first pilot tenant; varies by tenant's payment terms (net-30 vs net-14 vs net-60). |
   345	| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
   346	| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
   347	| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
   348	| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
   349	
   350	### Gotchas (carried forward from ULTRAPLAN A4 line 542)
   351	
   352	1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
   353	2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
   354	3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
   355	4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
   356	
   357	---
   358	
   359	## §10 — When this document ratifies
   360	
   361	Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   362	
   363	Status flips Proposed → Accepted when:
   364	- Codex Round 4 Phase 2 ratifies
   365	- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
   366	- Q3 UX flow approved (operator re-auth path)
   367	
   368	Status flips Accepted → In Force when:
   369	- W7-8 build slice produces all 5 sibling bundle files + 3 fixtures
   370	- First production webhook processed end-to-end against migration-test tenant
   371	- 30-day month-0 baseline measured for first pilot
   372	- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
   373	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   374	
   375	Until then: this document is a forward-looking scaffold.
   376	
   377	*End of Cash Conductor agent.md draft.*

exec
/bin/zsh -lc 'rg --files docs | rg -i "master|brief|cortex|directive|ultra"' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/_supplementary/planning-phase-brief.md
docs/specs/ULTRAPLAN.md
docs/build-brief/00-MASTER-BRIEF.md

exec
/bin/zsh -lc "rg -n \"Cash Conductor|week 7|W7|Hire #1|FD-tier|DSO|the FD\" docs --glob '*.md' --glob '"'!docs/specs/ULTRAPLAN.md'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/specs/PRODUCT-SPEC.md:73:#### R2. Real-Time Cash Conductor — the FD's evenings back
docs/specs/PRODUCT-SPEC.md:76:- **Revenue story:** "DSO drops by 15+ days. £40k–£120k of working capital unlocked for a mid-sized agency. One bad debt caught per quarter pays for the entire suite."
docs/specs/PRODUCT-SPEC.md:164:#### R12. Recruitment Reporting — the FD's monthly close, automated
docs/specs/PRODUCT-SPEC.md:167:- **Revenue story:** "Replaces the FD's Excel hell." Indirect revenue impact: better decisions when the FD can see the numbers in time to act on them.
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:345:- Cash Conductor runs against historical invoices — produces the DSO baseline.
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:401:| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:474:- Cash Conductor (real-time mode)
docs/specs/PRODUCT-SPEC.md:523:2. **Real-Time Cash Conductor** — "DSO drops by 15+ days, working capital unlocked."
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:328:**Risk if flaky:** Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5 ("iOS in v1.2 is the marketing line, not a tech blocker"). Real risk is Telegram outage during a Cash Conductor escalation, which is exactly what the activity-channel + per-agent-bot belt-and-braces pattern (primitive 4 evidence, `approval.ts:222-226`) was built to mitigate after the "50h+ Repo-B-style stall" incident.
docs/architecture/second-brain-design.md:203:| `wiki/raw/inbox-emails/` | one file per email | markdown with frontmatter | `{epoch}-{from-domain}-{rand5}.md` | inbound email webhook handler (v1.0: Cash Conductor for AR-relevant; v1.1: Triage for everything) | Brief Decoder (v1.1), Cash Conductor (v1.0); future Pulse semantic-search-over-raw |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:311:xero_contact_id: 9876                                # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/_supplementary/planning-phase-brief.md:196:**End state of week 7:** dashboard fully spec'd; CC1 build in full flight.
docs/_supplementary/execution-plan.md:237:## PHASE 3 — Platform Engineering Specs (target: end of week 7)
docs/_supplementary/execution-plan.md:648:You have strategy, architecture, and a working prototype. You are missing the *stuff a developer actually reads* — 95 discrete documents and decisions, organised into 7 sequenced phases. Start with the 18 Open Decisions this week. Then Phase 1's 10 artifacts until one real Proposal Builder works end-to-end. Then Phase 2's 12 agent bundles. Then Phase 3's 12 platform specs. By week 7 you have everything Claude Code needs to build; Phases 4–7 happen in parallel with and after the build. Tick boxes. Resist scope creep. Ship.
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/build-brief/00-MASTER-BRIEF.md:465:- [ ] Hire #1 status one-liner
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
docs/operations/goal-week-3-polish-and-scaffold.md:352:### DAY 18 — Cash Conductor agent.md scaffold (Step 10)
docs/operations/goal-week-3-polish-and-scaffold.md:357:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:360:- `vertical-schema.yaml` §3 agent_access_matrix Cash Conductor row
docs/operations/goal-week-3-polish-and-scaffold.md:361:- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:371:- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
docs/operations/goal-week-3-polish-and-scaffold.md:459:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:618:  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:648:    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/goal-week-3-polish-and-scaffold.md:649:    - Cash Conductor build (full bundle)
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:142:**Hire-#1 anchor (per Ultraplan §9 line 766 verbatim):** "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)." Cash Conductor's three-accounting-API + Open-Banking integration is the right scope for Hire #1's first sprint per Ultraplan §9 — this places Cash Conductor at W7-8 in the canonical sequence.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:184:W7-8: Cash Conductor (A4) — Hire-#1-anchored per Ultraplan §9 line 766
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:194:- W7-8: Risk #1 (cortextOS Primitives 1+4+5) — Cash Conductor first Tier-1. Reduction trigger fires.
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:232:W11:  Cash Conductor (A4)
docs/decisions/sequencing-target.md:236:**Why this ordering:** Front-load risk-de-risking by building Concierge (the most Primitive-heavy agent) early. Cash Conductor's Risk #1 exercise becomes redundant if Concierge already exercises Primitives 1+2+4+5.
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:242:3. **Hire-#1 anchor broken.** Cash Conductor at W11 is 4 weeks after Hire #1's assumed W7 start. Hire #1 again has no first-sprint scope.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:307:**Trigger 2 — Risk #4 materialises (Hire #1 doesn't start by end of Week 4).** Per RISK-REGISTER #4 tripwire "No offer accepted by end of week 4":
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:334:- Whether Cash Conductor's 2-week build can compress if Hire #1 onboarding is fast — deferred to Week 7 Cash-Conductor-kickoff check-in.
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:449:- §4.3 revisit conditions name specific tripwires (Risk #2, Risk #4, Hire #1) and concrete activation actions (decider + updates required + cascade).
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:491:| Revisit conditions | §4.3 | Three triggers named (Risk #2, Risk #4, Hire #1) with decider + activation + updates + cascade per trigger |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |

codex
REJECTED

1. §10 cites the wrong ratification skill. Line 361 says `.codex/ratification/review-architecture-decision.md`, but this artefact is an agent bundle and the supplied type-specific contract requires `review-agent-bundle.md`. Replace the §10 citation with `review-agent-bundle.md`.

2. Multiple ULTRAPLAN line citations are off by one or more lines. Lines 7, 17, 148, 240, 254, and 350 cite A4 lines 539-542, but `docs/specs/ULTRAPLAN.md` has Gate A at line 538, Gate B at line 539, complexity at line 540, and gotchas at line 541. Correct all line references to the actual source lines.

3. §6 cites invented escalation codes as if they exist in `agents/_shared/escalation-codes.md`. Lines 270-276, 281, and 283 name `ESC_ACCOUNTING_AUTH`, `ESC_ACCOUNTING_WRITE_FAIL`, `ESC_OPEN_BANKING_AUTH`, `ESC_OPEN_BANKING_TOKEN_AGING`, `ESC_RECONCILIATION_AMBIGUOUS`, `ESC_AUTOSEND_RACE`, `ESC_GATE_B_MISS`, and `ESC_AUTOSEND_ORANGE_PENDING`, none of which appear in the catalogue. Add them to the catalogue before referencing them, or mark them explicitly as proposed additions.

4. §6 repurposes existing ESC codes beyond their catalogue definitions. Line 275 uses `ESC_AUTOSEND_BLOCKED` for “paid invoice OR race condition,” but the catalogue defines it for red-tier action attempts; line 280 uses `ESC_SCHEMA_VIOLATION` for invoice/amount/contact validation, but the catalogue defines it for vertical-schema field constraint failures. Use the catalogue semantics or register Cash-Conductor-specific codes.

5. Autosend action types and tiers do not match the runtime policy. Lines 17, 86, and 107 use `reconciliation_write` and `chase_draft` and classify chase drafts as orange, but `agents/_shared/autosend-policy.yaml` only defines Cash Conductor `xero_query_invoices` as green, `xero_reminder_draft_internal` as yellow, and `xero_reminder_send_customer` as orange. Update the artefact to use registered action_types and correct tier assignments, or extend the policy first.

6. §4 stores structured operational state in the vault. Lines 160-165 write bank transactions and invoice registers to `/vault/<tenant>/cash-conductor-cache/*.jsonl`, but the vault/Postgres split requires structured state in Postgres and Markdown narrative in vault. Move transaction/invoice cache state to Postgres or define a schema-backed state table before use.

7. §4 workflow omits required `hh_decision_*` calls at output/action points. Lines 157-177 ingest/write structured state and reconciliation actions without decision-log calls; lines 186-200 generate and validate drafts without an output/gating decision row; lines 209-218 update send state/cancel drafts without an action row. Add explicit `hh_decision_output`, `hh_decision_action`, or gating-failure calls at every output/action point.
tokens used
77,866
REJECTED

1. §10 cites the wrong ratification skill. Line 361 says `.codex/ratification/review-architecture-decision.md`, but this artefact is an agent bundle and the supplied type-specific contract requires `review-agent-bundle.md`. Replace the §10 citation with `review-agent-bundle.md`.

2. Multiple ULTRAPLAN line citations are off by one or more lines. Lines 7, 17, 148, 240, 254, and 350 cite A4 lines 539-542, but `docs/specs/ULTRAPLAN.md` has Gate A at line 538, Gate B at line 539, complexity at line 540, and gotchas at line 541. Correct all line references to the actual source lines.

3. §6 cites invented escalation codes as if they exist in `agents/_shared/escalation-codes.md`. Lines 270-276, 281, and 283 name `ESC_ACCOUNTING_AUTH`, `ESC_ACCOUNTING_WRITE_FAIL`, `ESC_OPEN_BANKING_AUTH`, `ESC_OPEN_BANKING_TOKEN_AGING`, `ESC_RECONCILIATION_AMBIGUOUS`, `ESC_AUTOSEND_RACE`, `ESC_GATE_B_MISS`, and `ESC_AUTOSEND_ORANGE_PENDING`, none of which appear in the catalogue. Add them to the catalogue before referencing them, or mark them explicitly as proposed additions.

4. §6 repurposes existing ESC codes beyond their catalogue definitions. Line 275 uses `ESC_AUTOSEND_BLOCKED` for “paid invoice OR race condition,” but the catalogue defines it for red-tier action attempts; line 280 uses `ESC_SCHEMA_VIOLATION` for invoice/amount/contact validation, but the catalogue defines it for vertical-schema field constraint failures. Use the catalogue semantics or register Cash-Conductor-specific codes.

5. Autosend action types and tiers do not match the runtime policy. Lines 17, 86, and 107 use `reconciliation_write` and `chase_draft` and classify chase drafts as orange, but `agents/_shared/autosend-policy.yaml` only defines Cash Conductor `xero_query_invoices` as green, `xero_reminder_draft_internal` as yellow, and `xero_reminder_send_customer` as orange. Update the artefact to use registered action_types and correct tier assignments, or extend the policy first.

6. §4 stores structured operational state in the vault. Lines 160-165 write bank transactions and invoice registers to `/vault/<tenant>/cash-conductor-cache/*.jsonl`, but the vault/Postgres split requires structured state in Postgres and Markdown narrative in vault. Move transaction/invoice cache state to Postgres or define a schema-backed state table before use.

7. §4 workflow omits required `hh_decision_*` calls at output/action points. Lines 157-177 ingest/write structured state and reconciliation actions without decision-log calls; lines 186-200 generate and validate drafts without an output/gating decision row; lines 209-218 update send state/cancel drafts without an action row. Add explicit `hh_decision_output`, `hh_decision_action`, or gating-failure calls at every output/action point.
