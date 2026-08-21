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
session id: 019e59c0-5979-7862-acdc-b0184c893476
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
**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are orange-tier (`xero_reminder_draft_internal` per `autosend-safety-policy.yaml` line 104; consultant approval required before send via Concierge); reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).

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

Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.

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

Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='xero_reminder_draft_internal'` (registered yellow tier — but Cash Conductor escalates to orange-tier `xero_reminder_send_customer` for the actual customer-facing send routed via Concierge; this row is the draft itself, not the send), payload includes the draft.

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
     gotcha per ULTRAPLAN A4 line 541); if <30 days until expiry,
     fire ESC_OPEN_BANKING_TOKEN_AGING (operator must re-authorise)
   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on failure

2. Event router (mode-dependent)
   → if mode=webhook: parse event_type → routes to Step 3-7 path
   → if mode=daily-sweep: skip to Step 8 (catch-up reconciliation)
   → if mode=weekly-report: skip to Step 13

3. Bank transaction ingest (mode=webhook from Open Banking)
   → fetch latest transactions since last_ingested_at
   → normalise schema (TrueLayer vs Plaid have different formats)
   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
     tenant per Day-4 §6.3 + tenancy-invariants T1-T3; W7 build slice creates
     the table per ADR-002 vault/Postgres split — structured state in Postgres,
     not vault markdown)
   → hh_decision_output("transactions_ingested", "tenant:<slug>",
     "<N> rows since <last_ingested_at>")

4. Invoice register ingest (mode=webhook from accounting OR daily-sweep)
   → accounting.list_open_invoices() per provider
   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
     W7 build slice creates per ADR-002 vault/Postgres split)
   → hh_decision_output("invoices_ingested", "tenant:<slug>", "<N> rows")

5. Reconciliation pass (5-stage match algorithm per §3 Output 1)
   → for each transaction × open invoice: compute match confidence
   → write Stage 1-2 matches to accounting (yellow tier) atomically
   → queue Stage 3-4 matches for consultant review (ESC_RECONCILIATION_AMBIGUOUS
     per stage)
   → flag Stage 5 (unmatched) in weekly-report exception list
   → hh_decision_output("reconciliation_pass", "tenant:<slug>",
     "stage1_2:<N>; stage3_4:<N>; stage5:<N>")

6. Reconciliation write (yellow tier; per match)
   → accounting.write_payment_received(invoice_id, payment_id, amount, date)
   → atomic transaction; rollback on 4xx/5xx
   → on success: hh_decision_action("accounting_reconciliation_write",
     "invoice:<id>", payload_hash, payload_preview)
   → on failure: ESC_ACCOUNTING_WRITE_FAIL
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
   → ESC_AGENT_OUTPUT_SHAPE on any miss (output-shape violation: chase cannot
     conform to its Gate A contract — invoice/amount/contact mismatch OR paid-
     invoice precondition violated). `ESC_AUTOSEND_BLOCKED` is reserved for
     red-tier action attempts per catalogue line 41; Cash Conductor's chase
     pipeline is orange-tier, so a Gate A miss is output-shape failure, not
     red-tier block.
   → hh_decision_output("chase_draft_validated", invoice_id, "passed")

10. Chase-draft queue to Concierge (orange tier)
    → POST internal API → Concierge agent receives draft
    → Concierge handles autosend-bridge call to operator (D1 path per
      Founder Decision)
    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
      payload_hash, payload_preview); tier=yellow internal-draft; the
      customer-facing send (orange tier) happens in Concierge as
      `xero_reminder_send_customer` after operator approval

11. (Operator approves via Concierge → Concierge sends → Cash Conductor
    records send event)
    → Concierge fires webhook back: chase_sent
    → Cash Conductor updates internal state: prior_chases_sent counter

12. (Mode=webhook only) Re-trigger eligibility check
    → was this webhook also a "payment received" that just hit?
    → re-run Step 5 to check if any chases-in-flight should be cancelled
      (paid-since-draft-but-before-send race condition)
    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
    → hh_decision_output("chase_cancellation_check", "invoice:<id>",
      "cancelled:<bool>")

13. Weekly report assembly (mode=weekly-report; runs Monday 06:00 UTC)
    → query decision_log + accounting + bank feed for the 7-day window
    → compute DSO metric (Gate B tracking)
    → 6-section Markdown report per §3 Output 3
    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
    → hh_decision_output("weekly_report", report_path,
      "dso_delta_days:<N>; sections:6")

14. Session close
    → update tenant_adapters.config.cash_conductor_last_run = now()
    → hh_decision_action("cash_conductor_run_complete", session_id,
      run_mode, payload_hash, payload_preview)
    → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):

- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
- Voice classifier score ≥0.75 for position 1-2 chases; ≥0.80 for position 3
- No PII outside firm boundary in chase body
- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
- Open Banking token >30 days from expiry (otherwise warn)
- Accounting auth refresh succeeded in Step 1

Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint: chase cannot meet its Gate A contract); draft stays in `/tmp` (auto-purged 24h); operator notified.

**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.

### Gate B — Outcome threshold (FD-tier closer metric)

Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.

DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.

Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.

This is THE FD-tier closer metric per master brief §8.2 line 597 — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).

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
| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss (invoice/amount/contact validation OR paid-invoice precondition violated) — output-shape constraint per catalogue line 184 | warn | operator_chat_id |
| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval >24h | info | (logged; weekly report) |

Cash Conductor does NOT use:

- Bullhorn-specific codes (no Bullhorn dependency)
- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate

---

## §7 — Voice + tone constraints

Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
  - No "Final demand" or legal-threatening language (escalation ladder caps at position 3; position 4 is operator-handled)
  - No reference to the client's industry / sector pain points (chase is operational, not strategic)
  - No mentions of late-payment fees unless tenant's terms explicitly state them
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.

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

### Gotchas (carried forward from ULTRAPLAN A4 line 541)

1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

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
I’ll verify the cited project sources and catalogue entries against the Cash Conductor scaffold, then return only the required verdict format.
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Cash Conductor — the FD's evenings back
     2	
     3	**Status:** Proposed (Day-18 pre-W7-8-build scaffold; awaits Q1 LOI + accounting + Open Banking commercial signups + W7 build slice OR earlier-pull-forward per ADR-005 if Bullhorn delays persist).
     4	**Date:** 2026-05-24.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
     7	**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
     8	**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
     9	**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
    10	
    11	---
    12	
    13	## §1 — Output contract (one-paragraph screenshot)
    14	
    15	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    16	
    17	> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are orange-tier (`xero_reminder_draft_internal` per `autosend-safety-policy.yaml` line 104; consultant approval required before send via Concierge); reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
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
    86	Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
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
   107	Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='xero_reminder_draft_internal'` (registered yellow tier — but Cash Conductor escalates to orange-tier `xero_reminder_send_customer` for the actual customer-facing send routed via Concierge; this row is the draft itself, not the send), payload includes the draft.
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
   148	     gotcha per ULTRAPLAN A4 line 541); if <30 days until expiry,
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
   160	   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
   161	     tenant per Day-4 §6.3 + tenancy-invariants T1-T3; W7 build slice creates
   162	     the table per ADR-002 vault/Postgres split — structured state in Postgres,
   163	     not vault markdown)
   164	   → hh_decision_output("transactions_ingested", "tenant:<slug>",
   165	     "<N> rows since <last_ingested_at>")
   166	
   167	4. Invoice register ingest (mode=webhook from accounting OR daily-sweep)
   168	   → accounting.list_open_invoices() per provider
   169	   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
   170	     W7 build slice creates per ADR-002 vault/Postgres split)
   171	   → hh_decision_output("invoices_ingested", "tenant:<slug>", "<N> rows")
   172	
   173	5. Reconciliation pass (5-stage match algorithm per §3 Output 1)
   174	   → for each transaction × open invoice: compute match confidence
   175	   → write Stage 1-2 matches to accounting (yellow tier) atomically
   176	   → queue Stage 3-4 matches for consultant review (ESC_RECONCILIATION_AMBIGUOUS
   177	     per stage)
   178	   → flag Stage 5 (unmatched) in weekly-report exception list
   179	   → hh_decision_output("reconciliation_pass", "tenant:<slug>",
   180	     "stage1_2:<N>; stage3_4:<N>; stage5:<N>")
   181	
   182	6. Reconciliation write (yellow tier; per match)
   183	   → accounting.write_payment_received(invoice_id, payment_id, amount, date)
   184	   → atomic transaction; rollback on 4xx/5xx
   185	   → on success: hh_decision_action("accounting_reconciliation_write",
   186	     "invoice:<id>", payload_hash, payload_preview)
   187	   → on failure: ESC_ACCOUNTING_WRITE_FAIL
   188	   → spot-check sampling per autosend-safety-policy.yaml yellow tier
   189	
   190	7. Chase generation pass (for overdue, unmatched invoices)
   191	   → query open invoices with age >7 days AND no Stage-1/2 reconciliation
   192	   → for each, determine chase position 1-4 based on age + prior chases
   193	     sent (counted from decision_log decision_log.payload.position)
   194	   → if position=4: STOP — operator review (no auto-draft)
   195	   → else: proceed to Step 8
   196	
   197	8. LLM chase-draft generation (per overdue invoice)
   198	   → prompt = (invoice details + client context + position-N tone +
   199	     voice corpus + tone rules)
   200	   → output = email body + subject
   201	   → voice classifier scores against tenant style (≥0.75 for position 1-2;
   202	     ≥0.80 for position 3 per §3.2)
   203	   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
   204	
   205	9. Chase-draft validation (Gate A specifics)
   206	   → verify: invoice_number cited matches invoice_id
   207	   → verify: amount_due cited matches accounting record
   208	   → verify: client_contact_email matches active billing contact
   209	   → verify: NOT paid in last 24h (re-query accounting)
   210	   → ESC_AGENT_OUTPUT_SHAPE on any miss (output-shape violation: chase cannot
   211	     conform to its Gate A contract — invoice/amount/contact mismatch OR paid-
   212	     invoice precondition violated). `ESC_AUTOSEND_BLOCKED` is reserved for
   213	     red-tier action attempts per catalogue line 41; Cash Conductor's chase
   214	     pipeline is orange-tier, so a Gate A miss is output-shape failure, not
   215	     red-tier block.
   216	   → hh_decision_output("chase_draft_validated", invoice_id, "passed")
   217	
   218	10. Chase-draft queue to Concierge (orange tier)
   219	    → POST internal API → Concierge agent receives draft
   220	    → Concierge handles autosend-bridge call to operator (D1 path per
   221	      Founder Decision)
   222	    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
   223	      payload_hash, payload_preview); tier=yellow internal-draft; the
   224	      customer-facing send (orange tier) happens in Concierge as
   225	      `xero_reminder_send_customer` after operator approval
   226	
   227	11. (Operator approves via Concierge → Concierge sends → Cash Conductor
   228	    records send event)
   229	    → Concierge fires webhook back: chase_sent
   230	    → Cash Conductor updates internal state: prior_chases_sent counter
   231	
   232	12. (Mode=webhook only) Re-trigger eligibility check
   233	    → was this webhook also a "payment received" that just hit?
   234	    → re-run Step 5 to check if any chases-in-flight should be cancelled
   235	      (paid-since-draft-but-before-send race condition)
   236	    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
   237	    → hh_decision_output("chase_cancellation_check", "invoice:<id>",
   238	      "cancelled:<bool>")
   239	
   240	13. Weekly report assembly (mode=weekly-report; runs Monday 06:00 UTC)
   241	    → query decision_log + accounting + bank feed for the 7-day window
   242	    → compute DSO metric (Gate B tracking)
   243	    → 6-section Markdown report per §3 Output 3
   244	    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
   245	    → hh_decision_output("weekly_report", report_path,
   246	      "dso_delta_days:<N>; sections:6")
   247	
   248	14. Session close
   249	    → update tenant_adapters.config.cash_conductor_last_run = now()
   250	    → hh_decision_action("cash_conductor_run_complete", session_id,
   251	      run_mode, payload_hash, payload_preview)
   252	    → exit code 0
   253	```
   254	
   255	---
   256	
   257	## §5 — Gates
   258	
   259	### Gate A — validate.sh (hard-fail before action)
   260	

exec
/bin/zsh -lc "rg --files | rg '("'^|/)(vertical-schema'"\\.yaml|autosend-safety-policy\\.yaml|escalation-codes\\.md|voice-loader\\.sh|v1\\.0-kill-criterion\\.md|ULTRAPLAN|master|brief|ADR-005|ADR-002)'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/escalation-codes.md
agents/_shared/voice-loader.sh
docs/verticals/recruitment/vertical-schema.yaml
docs/specs/ULTRAPLAN.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md

exec
/bin/zsh -lc "rg -n \"Cash Conductor|W7-8|Hire #1|A4|tenant DSO|chase email|Open Banking|xero_reminder|accounting_reconciliation|ESC_ACCOUNTING|ESC_OPEN_BANKING|ESC_RECONCILIATION|ESC_AUTOSEND_RACE|ESC_GATE_B|ESC_AUTOSEND_ORANGE|ESC_AGENT_OUTPUT_SHAPE|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|accounting_reconciliation_write|xero_reminder_draft_internal|xero_reminder_send_customer|§8\\.2|Change 1|Change 2\" docs agents packages -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:146:  xero_reminder_draft_internal:
agents/_shared/autosend-policy.yaml:167:  accounting_reconciliation_write:
agents/_shared/autosend-policy.yaml:171:    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
agents/_shared/autosend-policy.yaml:221:  xero_reminder_send_customer:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:129:      - Cash Conductor (R — payment reminder tone)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
packages/harness/cortextos/package-lock.json:194:      "integrity": "sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==",
packages/harness/cortextos/package-lock.json:245:      "integrity": "sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==",
packages/harness/cortextos/package-lock.json:466:      "integrity": "sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==",
packages/harness/cortextos/package-lock.json:805:      "integrity": "sha512-zYyqWgGQi3NhBcNq4Isc5rB3oEdQEh1Q/EcAnOW0FK4MpnXWkvSBYgA4cYrTM4A9UB573omouZbnL9JJ74Mq3A==",
packages/harness/cortextos/package-lock.json:1485:      "integrity": "sha512-i1okWYkA4FJICtr7KpYzFpRTHgy5jdDbZiWfvny21iIKky5YExiDXP+zbXzm3dUcFpkEeYNHgQ5fuG236JPq0g==",
packages/harness/cortextos/package-lock.json:3149:      "integrity": "sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==",
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:238:Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)
agents/_shared/escalation-codes.md:280:#### `ESC_ACCOUNTING_AUTH`
agents/_shared/escalation-codes.md:281:- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
agents/_shared/escalation-codes.md:288:#### `ESC_OPEN_BANKING_AUTH`
agents/_shared/escalation-codes.md:289:- **Severity:** **blocking** — Cash Conductor cannot fetch latest bank-feed; falls back to last-known balance
agents/_shared/escalation-codes.md:290:- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
agents/_shared/escalation-codes.md:294:- **Recovery:** founder completes Open Banking SCA reauthentication flow
agents/_shared/escalation-codes.md:296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
agents/_shared/escalation-codes.md:298:- **Trigger:** Open Banking PSD2 consent ≤14 days from 90-day expiry; emitted by nightly health check
agents/_shared/escalation-codes.md:314:#### `ESC_ACCOUNTING_WRITE_FAIL`
agents/_shared/escalation-codes.md:316:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
agents/_shared/escalation-codes.md:338:#### `ESC_AUTOSEND_ORANGE_PENDING`
agents/_shared/escalation-codes.md:353:#### `ESC_AUTOSEND_RACE`
agents/_shared/escalation-codes.md:370:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:372:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:403:- **Severity:** **blocking** — Cash Conductor refuses to send reminder/invoice
agents/_shared/escalation-codes.md:410:#### `ESC_RECONCILIATION_AMBIGUOUS`
agents/_shared/escalation-codes.md:411:- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/voice-loader.sh:4:# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
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
agents/_shared/tests/test-voice-loader.sh:125:  out=$(hh_load_recent_edits)
agents/_shared/tests/test-voice-loader.sh:132:printf '\n[7] hh_load_recent_edits accepts custom lookback_days\n'
agents/_shared/tests/test-voice-loader.sh:135:  out=$(hh_load_recent_edits 7 "concierge")
agents/_shared/tests/test-voice-loader.sh:141:printf '\n[8] hh_load_recent_edits lookback_days validation clamps to 30\n'
agents/_shared/tests/test-voice-loader.sh:144:  out=$(hh_load_recent_edits "abc")  # non-numeric → 30
agents/_shared/tests/test-voice-loader.sh:146:  out=$(hh_load_recent_edits "999")   # over cap → 30
agents/_shared/tests/test-voice-loader.sh:148:  out=$(hh_load_recent_edits "0")     # zero → 30
agents/_shared/tests/test-voice-loader.sh:156:  out1=$(hh_load_tone_rules | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:157:  out2=$(hh_load_voice_samples "task" | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:158:  out3=$(hh_load_recent_edits | wc -l | tr -d ' ')
agents/recruitment/cash-conductor/README.md:1:# Cash Conductor — directory README
agents/recruitment/cash-conductor/README.md:3:**Status:** Proposed (Day-18 pre-W7-8-build scaffold).
agents/recruitment/cash-conductor/README.md:14:**Most-independent v1.0 agent.** Zero Bullhorn dependency. Operates against accounting system + Open Banking only. Per ADR-005 §5.1: pull-forward candidate if Bullhorn paths delayed past 2026-06-10.
agents/recruitment/cash-conductor/README.md:18:Full bundle at W7-8 build (~2 weeks per ULTRAPLAN A4 line 541):
agents/recruitment/cash-conductor/README.md:20:- `tools.yaml` — Xero / QuickBooks / Sage / Open Banking (TrueLayer or Plaid UK) MCP connectors
agents/recruitment/cash-conductor/README.md:22:- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
agents/recruitment/cash-conductor/README.md:27:- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)
agents/recruitment/cash-conductor/README.md:29:## Hire #1 anchor
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
agents/recruitment/cash-conductor/README.md:32:- Open Banking MCP connector + ESC_OPEN_BANKING_TOKEN_AGING UX
agents/recruitment/cash-conductor/README.md:39:*End of Cash Conductor README.*
agents/recruitment/cash-conductor/agent.md:1:# Cash Conductor — the FD's evenings back
agents/recruitment/cash-conductor/agent.md:3:**Status:** Proposed (Day-18 pre-W7-8-build scaffold; awaits Q1 LOI + accounting + Open Banking commercial signups + W7 build slice OR earlier-pull-forward per ADR-005 if Bullhorn delays persist).
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:7:**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
agents/recruitment/cash-conductor/agent.md:8:**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are orange-tier (`xero_reminder_draft_internal` per `autosend-safety-policy.yaml` line 104; consultant approval required before send via Concierge); reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:33:# - Open Banking (TrueLayer/Plaid UK): transaction.posted, balance.updated
agents/recruitment/cash-conductor/agent.md:74:Per webhook event, Cash Conductor reconciles incoming bank deposits against the tenant's open invoice register. Match algorithm:
agents/recruitment/cash-conductor/agent.md:86:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:90:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. Output is a queued draft, NOT a send. Drafts route to Concierge (which handles the actual send pipeline + consultant approval per autosend §4 orange tier).
agents/recruitment/cash-conductor/agent.md:107:Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='xero_reminder_draft_internal'` (registered yellow tier — but Cash Conductor escalates to orange-tier `xero_reminder_send_customer` for the actual customer-facing send routed via Concierge; this row is the draft itself, not the send), payload includes the draft.
agents/recruitment/cash-conductor/agent.md:118:Position 4 is the kill-switch: Cash Conductor never auto-drafts beyond position 3. Operator decides next step manually.
agents/recruitment/cash-conductor/agent.md:137:14 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/cash-conductor/agent.md:142:     Open Banking auth + voice corpus + tone rules
agents/recruitment/cash-conductor/agent.md:147:   → Open Banking: TrueLayer/Plaid UK 90-day token refresh (CRITICAL —
agents/recruitment/cash-conductor/agent.md:148:     gotcha per ULTRAPLAN A4 line 541); if <30 days until expiry,
agents/recruitment/cash-conductor/agent.md:149:     fire ESC_OPEN_BANKING_TOKEN_AGING (operator must re-authorise)
agents/recruitment/cash-conductor/agent.md:150:   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on failure
agents/recruitment/cash-conductor/agent.md:157:3. Bank transaction ingest (mode=webhook from Open Banking)
agents/recruitment/cash-conductor/agent.md:176:   → queue Stage 3-4 matches for consultant review (ESC_RECONCILIATION_AMBIGUOUS
agents/recruitment/cash-conductor/agent.md:185:   → on success: hh_decision_action("accounting_reconciliation_write",
agents/recruitment/cash-conductor/agent.md:187:   → on failure: ESC_ACCOUNTING_WRITE_FAIL
agents/recruitment/cash-conductor/agent.md:210:   → ESC_AGENT_OUTPUT_SHAPE on any miss (output-shape violation: chase cannot
agents/recruitment/cash-conductor/agent.md:213:     red-tier action attempts per catalogue line 41; Cash Conductor's chase
agents/recruitment/cash-conductor/agent.md:222:    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:225:      `xero_reminder_send_customer` after operator approval
agents/recruitment/cash-conductor/agent.md:227:11. (Operator approves via Concierge → Concierge sends → Cash Conductor
agents/recruitment/cash-conductor/agent.md:230:    → Cash Conductor updates internal state: prior_chases_sent counter
agents/recruitment/cash-conductor/agent.md:236:    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
agents/recruitment/cash-conductor/agent.md:261:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:263:- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
agents/recruitment/cash-conductor/agent.md:268:- Open Banking token >30 days from expiry (otherwise warn)
agents/recruitment/cash-conductor/agent.md:271:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint: chase cannot meet its Gate A contract); draft stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/cash-conductor/agent.md:273:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/cash-conductor/agent.md:277:Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
agents/recruitment/cash-conductor/agent.md:281:Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
agents/recruitment/cash-conductor/agent.md:283:This is THE FD-tier closer metric per master brief §8.2 line 597 — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:289:Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/cash-conductor/agent.md:293:| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:294:| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:295:| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:296:| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking token <30 days from 90-day expiry | warn (info if <60 days; warn if <30; blocking if <7) | operator_chat_id → ifos_oncall as expiry nears |
agents/recruitment/cash-conductor/agent.md:297:| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 3-4 match queued for review | info | (logged; aggregated to weekly report exception list) |
agents/recruitment/cash-conductor/agent.md:298:| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:301:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss (invoice/amount/contact validation OR paid-invoice precondition violated) — output-shape constraint per catalogue line 184 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:302:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:303:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:304:| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval >24h | info | (logged; weekly report) |
agents/recruitment/cash-conductor/agent.md:306:Cash Conductor does NOT use:
agents/recruitment/cash-conductor/agent.md:309:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:310:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
agents/recruitment/cash-conductor/agent.md:311:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/cash-conductor/agent.md:319:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:323:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:324:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:326:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:330:## §8 — Build dependencies (W7-8 prerequisites OR earlier per ADR-005 pull-forward)
agents/recruitment/cash-conductor/agent.md:332:Cash Conductor build cannot start until ALL of the following are confirmed:
agents/recruitment/cash-conductor/agent.md:341:| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
agents/recruitment/cash-conductor/agent.md:345:| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
agents/recruitment/cash-conductor/agent.md:347:| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
agents/recruitment/cash-conductor/agent.md:355:**Per ADR-005 §5.1 pull-forward provision:** if Bullhorn Sub-decisions A+B answers delay past 2026-06-10, Cash Conductor may be pulled forward from W7-8 to W4-5 because it has zero Bullhorn dependency. The other prerequisites (accounting + Open Banking commercial signups) remain founder-action gates regardless.
agents/recruitment/cash-conductor/agent.md:361:**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start (or earlier per ADR-005 pull-forward).
agents/recruitment/cash-conductor/agent.md:368:| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
agents/recruitment/cash-conductor/agent.md:369:| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
agents/recruitment/cash-conductor/agent.md:372:| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
agents/recruitment/cash-conductor/agent.md:373:| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
agents/recruitment/cash-conductor/agent.md:376:### Gotchas (carried forward from ULTRAPLAN A4 line 541)
agents/recruitment/cash-conductor/agent.md:378:1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
agents/recruitment/cash-conductor/agent.md:381:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:395:- W7-8 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/cash-conductor/agent.md:398:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
agents/recruitment/cash-conductor/agent.md:403:*End of Cash Conductor agent.md draft.*
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:157:   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
agents/recruitment/scribe/agent.md:214:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:224:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:238:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:255:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:276:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:279:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:66:| 10 | Reporting Engine | Operations | Friday 07:00 | Weekly briefing | Stripe, GA4, Meta Ads, Slack |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:206:- GA4 (Reporting Engine)
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:804:            &mdash; share code <em>W12&nbsp;EX9&nbsp;A4T</em>, valid through Dec 2027.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:104:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:126:   → if 2+ sources fail auth: ESC_AGENT_OUTPUT_SHAPE (Sourcing Scout cannot
agents/recruitment/sourcing-scout/agent.md:198:    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
agents/recruitment/sourcing-scout/agent.md:219:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 553 verbatim):
agents/recruitment/sourcing-scout/agent.md:229:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
agents/recruitment/sourcing-scout/agent.md:239:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:260:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:261:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
agents/recruitment/sourcing-scout/agent.md:267:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:276:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:281:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:282:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:284:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
docs/architecture/architecture-cohesion-review.md:91:| A4 | **`ifos_app` Postgres role is the only role used by app code.** No path uses postgres superuser or admin role. | Day-4 §6.3 grants + RLS posture | If any path uses superuser, RLS is bypassed (RLS doesn't apply to superusers by default). |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:168:   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:177:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:187:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:195:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:197:Failing either threshold for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).
agents/recruitment/janitor/agent.md:212:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:214:| `ESC_GATE_B_MISS` | Either independent Gate-B threshold (dedup <15% OR field-completeness <10%) missed for 3 consecutive runs. NOT a composite — see §5 Gate B for the two-threshold rule. | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:222:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:230:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:234:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:237:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:263:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:328:**Risk if flaky:** Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5 ("iOS in v1.2 is the marketing line, not a tech blocker"). Real risk is Telegram outage during a Cash Conductor escalation, which is exactly what the activity-channel + per-agent-bot belt-and-braces pattern (primitive 4 evidence, `approval.ts:222-226`) was built to mitigate after the "50h+ Repo-B-style stall" incident.
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
agents/recruitment/diagnostic/tools.yaml:171:  - xero           # Cash Conductor's territory (W7-8)
agents/recruitment/diagnostic/tools.yaml:172:  - quickbooks     # Cash Conductor's territory
agents/recruitment/diagnostic/tools.yaml:173:  - sage           # Cash Conductor's territory
agents/recruitment/diagnostic/tools.yaml:174:  - open_banking   # Cash Conductor's territory
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:203:| `wiki/raw/inbox-emails/` | one file per email | markdown with frontmatter | `{epoch}-{from-domain}-{rand5}.md` | inbound email webhook handler (v1.0: Cash Conductor for AR-relevant; v1.1: Triage for everything) | Brief Decoder (v1.1), Cash Conductor (v1.0); future Pulse semantic-search-over-raw |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:311:xero_contact_id: 9876                                # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
agents/recruitment/diagnostic/context.sh:10:# the first workflow step runs. Per master brief §8.1 Change 1: load voice
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 row 1 (anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`.
agents/recruitment/diagnostic/agent.md:73:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/diagnostic/agent.md:129:                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
agents/recruitment/diagnostic/agent.md:130:                 constraint = tone rules (hh_load_tone_rules)
agents/recruitment/diagnostic/agent.md:158:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
agents/recruitment/diagnostic/agent.md:162:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
agents/recruitment/diagnostic/agent.md:164:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:185:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:200:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:204:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
agents/recruitment/diagnostic/agent.md:205:- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.
agents/recruitment/diagnostic/agent.md:207:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:116:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:253:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:264:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:275:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:287:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:310:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:311:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:312:| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
agents/recruitment/concierge/agent.md:319:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:329:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:336:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:344:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:357:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:292:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:301:- **Build wave:** W5 per master brief §8.2 line 596
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
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:369:- **§4 Workflow:** ~14 steps. Cron daily 06:00 UTC. Fetch open invoices (Xero/QB/Sage rotation per tenant config) → fetch bank transactions (Open Banking) → match invoices ↔ deposits → identify unmatched + overdue → generate chase drafts → write reconciliation rows → weekly report assembly (Mondays).
docs/operations/goal-week-3-polish-and-scaffold.md:372:- **§6 Escalation codes:** ESC_ACCOUNTING_AUTH, ESC_BANK_AUTH, ESC_RECONCILIATION_AMBIGUOUS, ESC_AUTOSEND_BLOCKED.
docs/operations/goal-week-3-polish-and-scaffold.md:374:- **§8 Build prerequisites:** Xero MCP connector (W4 build) + QuickBooks MCP + Sage MCP + Open Banking via TrueLayer (or similar; founder commercial signup) + tenant accounting credentials in `_secrets.env`.
docs/operations/goal-week-3-polish-and-scaffold.md:375:- **§9 Open questions:** 6-8 covering accounting system per-tenant choice, Open Banking provider, reconciliation heuristic (exact-amount vs fuzzy), chase escalation ladder, weekly report stakeholder list.
docs/operations/goal-week-3-polish-and-scaffold.md:379:Commit: `decision(pre-build): agents/recruitment/cash-conductor/agent.md — output contract per ULTRAPLAN §8.1 A4`
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:459:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:618:  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:640:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:648:    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/goal-week-3-polish-and-scaffold.md:649:    - Cash Conductor build (full bundle)
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:216:3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-round-2-remediation-prompt.md:256:           xero_reminder_send_customer         → financial
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
packages/harness/cortextos/dashboard/package-lock.json:3521:      "integrity": "sha512-mgLPETlrpVV1YRJIglr4Ez47g7Yxjl1lj7YKsiMCb27VJH9W8NVM6Bb9d8kkpG/uAQS5AmbA48q2IAolKKo1MA==",
packages/harness/cortextos/dashboard/package-lock.json:4085:      "integrity": "sha512-D8Vae74A4/a+mZH0FbOkFJL9DSK2R6TFPC9M+jCWYia/q2einCubX10pecpDiTmkJVUH+y8K3BZClycD8nCShA==",
packages/harness/cortextos/dashboard/package-lock.json:4099:      "integrity": "sha512-frxL4OrzOWVVsOc96+V3aqTIQl1O2TjgExV4EKgRY09AJ9leZpEg8Ak9phadbuX0BA4k8U5qtvMSQQGGmaJqcQ==",
packages/harness/cortextos/dashboard/package-lock.json:4403:      "integrity": "sha512-8iUql50EUR+uUcdRQ3HDqa6EVyo3docL8g5WJ3FNcWmu62IbkGUue/pEyLBW8VGKKucTPgqeks4fIU1DA4yowQ==",
packages/harness/cortextos/dashboard/package-lock.json:6575:      "integrity": "sha512-KmfKL3b6G+RXvP8N1vr3Tq1kL/oCFgn2NYXEtqP8/L3pKapUA4G8cFVaoF3SU323CD4XypR/ffioHmkti6/Tag==",
packages/harness/cortextos/dashboard/package-lock.json:6633:      "integrity": "sha512-CRT1WTyuQoD771GW56XEZFQ/ZoSfWid1alKGDYMmkt2yl8UXrVR4pspqWNEcqKvVIzg6PAltWjxcSSPrboA4iA==",
packages/harness/cortextos/dashboard/package-lock.json:8984:      "integrity": "sha512-abv/qOcuPfk3URPfDzmZU1LKmuw8kT+0nIHvKrKgFrwifol/doWcdA4ZqsWQ8ENrFKkd67Mfpo/LovbIUsbt3w==",
packages/harness/cortextos/dashboard/package-lock.json:9529:      "integrity": "sha512-8u/hfXFRBD1O0hPUjioLhoWFHRmt6tKA4/vZPyckBr18l1KE9uHrFaFaUi8MDRTpi4uak2goyPTSNJLXX2k2Hw==",
packages/harness/cortextos/dashboard/package-lock.json:9645:      "integrity": "sha512-smsWv2LzFjP03xmvFoJ331ss6h+jixfA4UUV/Bsiyuu4YJPfN+FIQGOIiv4w9/+MoHkfkJ22UIaQWRVFRfH6Vw==",
packages/harness/cortextos/dashboard/package-lock.json:10109:      "integrity": "sha512-24e6ynE2H+OKt4kqsOvNd8kBpV65zoxbA4BVsEOB3ARVWQki/DHzaUoC5KuON/BiccDaCCTZBuOcfZs70kR8bQ==",
packages/harness/cortextos/dashboard/package-lock.json:12450:      "integrity": "sha512-o8qghlI8NZHU1lLPrpi2+Uq7abh4GGPpYANlalzWxyWteJOCsr/P+oPBA49TOLu5FTZO4d3F9MnWJfiMo4BkmA==",
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:141:| `xero_reminder_send_customer` | `financial` |
docs/decisions/autosend-approval-bridge-spec.md:242:| A4 | 4h timeout: bridge calls `updateApproval(..., 'denied', 'ifos_timeout')` cleanly | Integration test: write `.pending` marker, advance simulated clock 4h, assert cortextOS `pending/` is empty + `resolved/` has `denied` record |
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:135:| 1. Implementation simplicity | **Medium-High** | Ultraplan §8.1 line 541 estimate **L (2 weeks)**. Three accounting integrations (Xero / QuickBooks / Sage — one per tenant per Ultraplan §8.1 line 537). Open Banking auth complexity (90-day token rotation per Ultraplan §8.1 line 542 gotcha). Tier 1 always-on (cortextOS Primitive 1 dependency) |
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:140:| 6. Tenant-onboarding readiness | **Medium** | Needs Xero/QuickBooks/Sage OAuth (one of, per tenant) + Open Banking auth (TrueLayer/Plaid UK per Ultraplan §8.1 line 539). Chase-cadence config per tenant. FD's mobile for Telegram approval per Ultraplan §8.1 line 540 |
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
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:449:- §4.3 revisit conditions name specific tripwires (Risk #2, Risk #4, Hire #1) and concrete activation actions (decider + updates required + cascade).
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:491:| Revisit conditions | §4.3 | Three triggers named (Risk #2, Risk #4, Hire #1) with decider + activation + updates + cascade per trigger |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/_supplementary/build-plan-original.md:814:- Last 7 days of data from: Stripe, GA4, Meta Ads, Google Ads, HubSpot, CRM, LinkedIn Ads, Shopify (if retail client), Klaviyo, etc.
docs/_supplementary/build-plan-original.md:821:- **GA4 MCP** — traffic + conversion
docs/_supplementary/build-plan-original.md:1261:| GA4 | No official | Build your own wrapper |
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/_supplementary/strategic-plan.md:92:8. **Reporting Engine** — pulls from Stripe, GA4, Meta Ads, CRM. Delivers weekly briefing in-Slack + PDF
docs/_supplementary/strategic-plan.md:174:│    Notion, GA4, Meta Ads, Stripe, Calendly, Dentally        │
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/_supplementary/planning-phase-brief.md:38:| **CC9** | **Custom MCP Servers (6 of them)** — DocuSign, GA4, Meta Ads, Companies House, Prospeo, Dentally | Python (FastMCP) or TypeScript | §3.8 (six of the 15 integration specs) |
docs/_supplementary/planning-phase-brief.md:178:- Session 25: Integration Specs Batch 2 — Stripe, GA4, Meta Ads, Cal.com (3.8)
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/_supplementary/technical-strategy-v2.md:259:0 7 * * 5 cd /tenant && claude -p "Run the Reporting Engine. Pull last 7 days from Stripe, GA4, Meta Ads, and HubSpot. Produce the weekly briefing. Save to /outbox/reports/. Post the summary to #leadership in Slack." --output-format json >> /logs/reporting-$(date +\%Y\%m\%d).log 2>&1
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/_supplementary/execution-plan.md:291:  - *Prompt per integration:* "Write the {Integration Name} Integration Specification: the MCP server choice (fork X / build from Y spec / official), auth setup (OAuth flow or API key), the scopes/permissions required and why, the specific operations used by agents (read leads, write deals, fetch transcript, etc.), fallback behaviour on failure, test checklist, rate limit handling. Priority 1 integrations: Fathom, HubSpot, Gmail, Slack, Notion, DocuSign. Priority 2: Companies House, Prospeo, Kaspr, Stripe, GA4, Meta Ads, Cal.com, Loom, Google Drive."
docs/build-brief/00-MASTER-BRIEF.md:465:- [ ] Hire #1 status one-liner
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:568:**Change 2 — Decision logging is enforced.** Three required calls per agent run:
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:448:      "xero_reminder_send_customer": "PT24H"
docs/specs/ULTRAPLAN.md:4:**Audience:** Maddox first. Future co-founder / Hire #1 second. The senior engineer who reads this in week six and needs to know what to do without asking.
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:146:**Change 1 — Voice handling moves into a shared module.**
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:166:**Change 2 — Decision logging is enforced, not optional.**
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:537:- **External APIs:** Xero API or QuickBooks API or Sage API; bank feed via Open Banking (TrueLayer / Plaid UK)
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:539:- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
docs/specs/ULTRAPLAN.md:540:- **Build complexity:** **L** (2 weeks) — three accounting integrations × Open Banking is the work
docs/specs/ULTRAPLAN.md:541:- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
docs/specs/ULTRAPLAN.md:601:#### A9. Real-time Cash Conductor reframe (2 weeks)
docs/specs/ULTRAPLAN.md:603:Already specified in §8.1 A4 as v1.0. The v1.1 work is the reframe of pitch and any latency optimisations needed once we have 3+ tenants in production. Not a new build, ~3 days of polish.
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
docs/specs/PRODUCT-SPEC.md:73:#### R2. Real-Time Cash Conductor — the FD's evenings back
docs/specs/PRODUCT-SPEC.md:75:- **Output contract:** Every invoice has a live status — sent, opened, escalating, paid. Payment lands → consultant gets the commission notification within minutes. Aged debt sweep runs at 07:00 with three drafted chase emails per debtor (soft, firm, escalation) ready for one-click approval.
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
packages/utilities/web-scraper/pnpm-lock.yaml:166:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:220:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/utilities/web-scraper/pnpm-lock.yaml:436:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/utilities/web-scraper/pnpm-lock.yaml:517:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/utilities/web-scraper/pnpm-lock.yaml:703:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/utilities/web-scraper/pnpm-lock.yaml:1004:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/agents-runtime/_shared/common-accounting.json:5:  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
packages/agents-runtime/_shared/common-accounting.json:12:      "description": "None = Cash Conductor not deployed for this tenant. Xero = deployed."
packages/agents-runtime/_shared/common-accounting.json:30:      "description": "Default Cash Conductor cadence; tenant-overridable per autosend-safety-policy §6 tenant-override discipline."
packages/agents-runtime/_shared/common-accounting.json:36:      "description": "Outstanding amount above which Cash Conductor escalates to operator via ESC route rather than auto-chasing."
packages/agents-runtime/_shared/common-accounting.json:42:      "description": "v1.0 closes loop via Open Banking reconciliation per Ultraplan §8.1 A4; truelayer placeholder."
packages/agents-runtime/_shared/common-voice.json:5:  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
packages/agent-renderer/templates/claude-md-preamble.md:20:Decision-log calls are mandatory per master brief §8.1 Change 2:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:162:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:216:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:432:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:513:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:699:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:996:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/agent-renderer/pnpm-lock.yaml:178:    resolution: {integrity: sha512-jOBDK5XEjA4m5IJK3bpAQF9/Lelu/Z9ZcdhTRLf4cajlB+8VEhFFRjWgfy3M1O4rO2GQ/b2dLwCUGpiF/eATNQ==}
packages/agent-renderer/pnpm-lock.yaml:232:    resolution: {integrity: sha512-GA48aKNkyQDbd3KtkplYWT102C5sn/EZTY4XROkxONgruHPU72l+gW+FfF8tf2cFjeHaRbWpOYa/uRBz/Xq1Pg==}
packages/agent-renderer/pnpm-lock.yaml:448:    resolution: {integrity: sha512-7yRhbHvPqSpRUV7Q20VuDwbjW5kIMwTHpptuUzV+AA46kiPze5Z7qgt6CLCK3pWFrHeNfDd1VKgyP4O+ng17CA==}
packages/agent-renderer/pnpm-lock.yaml:529:    resolution: {integrity: sha512-+O8OkVdyvXMtJEciu2wS/pzm1IxntEEQx3z5TAVy4l32G0etZn+RsA48ARRrFm6Ri8fvqPQfgrvNxSjKAbnd3g==}
packages/agent-renderer/pnpm-lock.yaml:693:    resolution: {integrity: sha512-8iUql50EUR+uUcdRQ3HDqa6EVyo3docL8g5WJ3FNcWmu62IbkGUue/pEyLBW8VGKKucTPgqeks4fIU1DA4yowQ==}
packages/agent-renderer/pnpm-lock.yaml:732:    resolution: {integrity: sha512-Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==}
packages/agent-renderer/pnpm-lock.yaml:736:    resolution: {integrity: sha512-Vw8qHK3bZM9y/P10u3Vib8o/DdkvA2OtPtZvD871QKjy74Wj1WSKFILMPRPSdUSx5RFK1arlJzEtA4PkFgnbuA==}
packages/agent-renderer/pnpm-lock.yaml:1050:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}

codex
I’ve found several source anchors and am checking whether the apparent line/policy references are exact enough to pass the citation-accuracy rule.
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '257,520p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   257	## §5 — Gates
   258	
   259	### Gate A — validate.sh (hard-fail before action)
   260	
   261	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
   262	
   263	- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
   264	- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
   265	- Voice classifier score ≥0.75 for position 1-2 chases; ≥0.80 for position 3
   266	- No PII outside firm boundary in chase body
   267	- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
   268	- Open Banking token >30 days from expiry (otherwise warn)
   269	- Accounting auth refresh succeeded in Step 1
   270	
   271	Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint: chase cannot meet its Gate A contract); draft stays in `/tmp` (auto-purged 24h); operator notified.
   272	
   273	**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   274	
   275	### Gate B — Outcome threshold (FD-tier closer metric)
   276	
   277	Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
   278	
   279	DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.
   280	
   281	Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
   282	
   283	This is THE FD-tier closer metric per master brief §8.2 line 597 — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
   284	
   285	---
   286	
   287	## §6 — Escalation codes
   288	
   289	Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
   290	
   291	| Code | Trigger | Severity | Routing |
   292	|---|---|---|---|
   293	| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   294	| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
   295	| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
   296	| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking token <30 days from 90-day expiry | warn (info if <60 days; warn if <30; blocking if <7) | operator_chat_id → ifos_oncall as expiry nears |
   297	| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 3-4 match queued for review | info | (logged; aggregated to weekly report exception list) |
   298	| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
   299	| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
   300	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
   301	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss (invoice/amount/contact validation OR paid-invoice precondition violated) — output-shape constraint per catalogue line 184 | warn | operator_chat_id |
   302	| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
   303	| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
   304	| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval >24h | info | (logged; weekly report) |
   305	
   306	Cash Conductor does NOT use:
   307	
   308	- Bullhorn-specific codes (no Bullhorn dependency)
   309	- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
   310	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
   311	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   312	
   313	---
   314	
   315	## §7 — Voice + tone constraints
   316	
   317	Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   318	
   319	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
   320	  - No "Final demand" or legal-threatening language (escalation ladder caps at position 3; position 4 is operator-handled)
   321	  - No reference to the client's industry / sector pain points (chase is operational, not strategic)
   322	  - No mentions of late-payment fees unless tenant's terms explicitly state them
   323	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
   324	- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
   325	
   326	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   327	
   328	---
   329	
   330	## §8 — Build dependencies (W7-8 prerequisites OR earlier per ADR-005 pull-forward)
   331	
   332	Cash Conductor build cannot start until ALL of the following are confirmed:
   333	
   334	| Dependency | Source | Status |
   335	|---|---|---|
   336	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   337	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   338	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   339	| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
   340	| **Accounting commercial signup** (developer access + sandbox) | Founder commercial | ⏸ |
   341	| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
   342	| Xero MCP connector | W7 build start (~2 days) | ⏸ |
   343	| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
   344	| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
   345	| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
   346	| Per-tenant accounting credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   347	| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   348	| Concierge agent in production (for chase-send routing) | W10-13 build | ⏸ |
   349	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   350	| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
   351	| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
   352	| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
   353	| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |
   354	
   355	**Per ADR-005 §5.1 pull-forward provision:** if Bullhorn Sub-decisions A+B answers delay past 2026-06-10, Cash Conductor may be pulled forward from W7-8 to W4-5 because it has zero Bullhorn dependency. The other prerequisites (accounting + Open Banking commercial signups) remain founder-action gates regardless.
   356	
   357	---
   358	
   359	## §9 — Status + open questions
   360	
   361	**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start (or earlier per ADR-005 pull-forward).
   362	
   363	### Open questions for founder review
   364	
   365	| # | Question | Resolution path |
   366	|---|---|---|
   367	| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
   368	| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
   369	| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
   370	| Q4 | Chase escalation ladder — 4 positions proposed in §3.2. Founder confidence each position's timing + tone is right? | Founder review with first pilot tenant; varies by tenant's payment terms (net-30 vs net-14 vs net-60). |
   371	| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
   372	| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
   373	| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
   374	| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
   375	
   376	### Gotchas (carried forward from ULTRAPLAN A4 line 541)
   377	
   378	1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
   379	2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
   380	3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
   381	4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
   382	
   383	---
   384	
   385	## §10 — When this document ratifies
   386	
   387	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   388	
   389	Status flips Proposed → Accepted when:
   390	- Codex Round 4 Phase 2 ratifies
   391	- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
   392	- Q3 UX flow approved (operator re-auth path)
   393	
   394	Status flips Accepted → In Force when:
   395	- W7-8 build slice produces all 5 sibling bundle files + 3 fixtures
   396	- First production webhook processed end-to-end against migration-test tenant
   397	- 30-day month-0 baseline measured for first pilot
   398	- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
   399	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   400	
   401	Until then: this document is a forward-looking scaffold.
   402	
   403	*End of Cash Conductor agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '130,240p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   130	    irreversible: false
   131	
   132	  bullhorn_note_append_summary:
   133	    tier: yellow
   134	    agent: scribe
   135	    sample_rate: 20
   136	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   137	    irreversible: false
   138	
   139	  linkedin_connection_request:
   140	    tier: yellow
   141	    agent: sourcing-scout
   142	    sample_rate: 5
   143	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   144	    irreversible: true
   145	
   146	  xero_reminder_draft_internal:
   147	    tier: yellow
   148	    agent: cash-conductor
   149	    sample_rate: 10
   150	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   151	    irreversible: false
   152	
   153	  bullhorn_note_draft_internal:
   154	    tier: yellow
   155	    agent: concierge
   156	    sample_rate: 10
   157	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   158	    irreversible: false
   159	
   160	  bullhorn_scribe_field_write:
   161	    tier: yellow
   162	    agent: scribe
   163	    sample_rate: 10
   164	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   165	    irreversible: false
   166	
   167	  accounting_reconciliation_write:
   168	    tier: yellow
   169	    agent: cash-conductor
   170	    sample_rate: 10
   171	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   172	    irreversible: false
   173	
   174	  concierge_email_draft:
   175	    tier: yellow
   176	    agent: concierge
   177	    sample_rate: 20
   178	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   179	    irreversible: false
   180	
   181	  # ───────────────────────────────────────────────────────────
   182	  # ORANGE — per-action human approval (10 action_types)
   183	  # ───────────────────────────────────────────────────────────
   184	
   185	  bullhorn_note_customer_visible:
   186	    tier: orange
   187	    agent: concierge
   188	    timeout: PT4H
   189	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   190	    irreversible: true
   191	    canonical: true
   192	
   193	  gmail_outlook_send_to_candidate:
   194	    tier: orange
   195	    agent: concierge
   196	    timeout: PT4H
   197	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   198	    irreversible: true
   199	
   200	  twilio_sms_send:
   201	    tier: orange
   202	    agent: concierge
   203	    timeout: PT30M
   204	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   205	    irreversible: true
   206	
   207	  calendar_invite_send:
   208	    tier: orange
   209	    agent: concierge
   210	    timeout: PT4H
   211	    reason: "Creates calendar event with attendee notification; visible to attendee"
   212	    irreversible: true
   213	
   214	  email_summary_to_customer:
   215	    tier: orange
   216	    agent: scribe
   217	    timeout: PT4H
   218	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   219	    irreversible: true
   220	
   221	  xero_reminder_send_customer:
   222	    tier: orange
   223	    agent: cash-conductor
   224	    timeout: PT24H
   225	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   226	    irreversible: true
   227	
   228	  diagnostic_email_send:
   229	    tier: orange
   230	    agent: diagnostic
   231	    timeout: PT4H
   232	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   233	    irreversible: true
   234	
   235	  diagnostic_calendar_invite:
   236	    tier: orange
   237	    agent: diagnostic
   238	    timeout: PT4H
   239	    reason: "Books intro call with prospect; reputation + scheduling friction"
   240	    irreversible: true

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '80,125p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    80	|---|---|---|
    81	| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
    82	| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
    83	| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
    84	| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
    85	| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
    86	| Concierge | `bullhorn_brief_read` | Read of inbound brief; idempotent; no comms |
    87	
    88	### Yellow examples (auto-send with spot-check sampling)
    89	
    90	| Agent | action_type | Sample rate | Why yellow |
    91	|---|---|---|---|
    92	| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
    93	| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
    94	| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
    95	| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
    96	| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
    97	
    98	### Orange examples (per-action human approval)
    99	
   100	| Agent | action_type | Why orange |
   101	|---|---|---|
   102	| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
   103	| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
   104	| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
   105	| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
   106	| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
   107	| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
   108	| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
   109	| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
   110	| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
   111	| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |
   112	
   113	### Red examples (blocked entirely; `ESC_AUTOSEND_BLOCKED`)
   114	
   115	| action_type | block_reason | Why red |
   116	|---|---|---|
   117	| `xero_payment_initiate` | `payment_action` | Payment transfer; financial-bearing; never auto-send in v1.0 |
   118	| `stripe_charge_initiate` | `payment_action` | Charges a card; financial-bearing |
   119	| `subscription_modify` | `billing_modification` | Changes tenant's IFOS subscription; structurally distinct from agent work |
   120	| `legal_document_generate` | `legal_artefact` | Offer letters, employment contracts; legal-binding |
   121	| `pii_export_outside_tenant_geography` | `pii_geographic_breach` | PII transmitted outside tenant's declared data residency (e.g., GDPR boundary breach) |
   122	| `cross_tenant_data_send` | `cross_tenant_violation` | Sending tenant-A data to tenant-B recipient; structurally enforced by RLS but red-listed for defence-in-depth |
   123	| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
   124	| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
   125	

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,430p'" in /Users/madsadmin/code/CortexOS
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
    28	## §2 — Catalogue (52 codes)
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
   117	### 2.5 — Recruitment-domain vocabulary (10 codes)
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
   231	- **Severity:** warn
   232	- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
   233	- **Phase:** `gating_failed`
   234	- **Routing:** `operator_chat_id`
   235	- **Payload fields:** `reason` (e.g. `bullhorn_auth_failed`, `mcp_connector_unreachable`), `degraded_since`, `recovery_condition`
   236	
   237	### 2.7 — Upstream provider auth (8 codes)
   238	Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)
   239	
   240	#### `ESC_REED_AUTH`
   241	- **Severity:** **blocking** — agent enters degraded mode (cached search results only)
   242	- **Trigger:** Reed jobs-board API OAuth token refresh failed twice OR REST call returned 401 indefinitely
   243	- **Phase:** `gating_failed`
   244	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   245	- **Payload fields:** `failure_type` (`refresh_failed` | `revoked_401`), `last_attempt_at`, `consecutive_failures`
   246	- **Recovery:** founder rotates Reed API key via Reed admin → `_secrets.env` reload
   247	
   248	#### `ESC_CVLIBRARY_AUTH`
   249	- **Severity:** **blocking** — agent degraded (cached search only)
   250	- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
   251	- **Phase:** `gating_failed`
   252	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   253	- **Payload fields:** `failure_type`, `last_attempt_at`, `consecutive_failures`
   254	- **Recovery:** founder rotates CV-Library credentials
   255	
   256	#### `ESC_LINKEDIN_AUTH`
   257	- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
   258	- **Trigger:** LinkedIn session cookie / OAuth token revoked or expired (LinkedIn has aggressive anti-bot session invalidation)
   259	- **Phase:** `gating_failed`
   260	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   261	- **Payload fields:** `failure_type` (`session_expired` | `bot_detected_999` | `revoked_401`), `last_attempt_at`
   262	- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
   263	
   264	#### `ESC_GMAIL_AUTH`
   265	- **Severity:** **blocking** — Concierge cannot send candidate emails; falls back to draft-only
   266	- **Trigger:** Google Workspace OAuth token refresh failed; Gmail send returns 401
   267	- **Phase:** `gating_failed`
   268	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   269	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   270	- **Recovery:** founder reauthenticates Google Workspace OAuth
   271	
   272	#### `ESC_MS_GRAPH_AUTH`
   273	- **Severity:** **blocking** — Concierge Outlook send disabled; drafts-only
   274	- **Trigger:** Microsoft Graph OAuth refresh failed; Outlook sendMail returns 401
   275	- **Phase:** `gating_failed`
   276	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   277	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   278	- **Recovery:** founder reauthenticates MS Graph OAuth
   279	
   280	#### `ESC_ACCOUNTING_AUTH`
   281	- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
   282	- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
   283	- **Phase:** `gating_failed`
   284	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   285	- **Payload fields:** `provider` (`xero` | `quickbooks` | `freeagent`), `failure_type`, `last_attempt_at`
   286	- **Recovery:** founder reauthenticates accounting OAuth
   287	
   288	#### `ESC_OPEN_BANKING_AUTH`
   289	- **Severity:** **blocking** — Cash Conductor cannot fetch latest bank-feed; falls back to last-known balance
   290	- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
   291	- **Phase:** `gating_failed`
   292	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   293	- **Payload fields:** `failure_type` (`consent_expired_90d` | `refresh_failed`), `consent_expires_at`, `bank_provider`
   294	- **Recovery:** founder completes Open Banking SCA reauthentication flow
   295	
   296	#### `ESC_OPEN_BANKING_TOKEN_AGING`
   297	- **Severity:** info — warning before blocking
   298	- **Trigger:** Open Banking PSD2 consent ≤14 days from 90-day expiry; emitted by nightly health check
   299	- **Phase:** `gating_failed`
   300	- **Routing:** `operator_chat_id` (no oncall CC — non-urgent)
   301	- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`
   302	- **Recovery:** founder schedules reauth within remaining window
   303	
   304	### 2.8 — Provider read/write failures (4 codes)
   305	Source: derived from v1.0 agent.md adapter call sites
   306	
   307	#### `ESC_BULLHORN_WRITE_FAIL`
   308	- **Severity:** warn
   309	- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
   310	- **Phase:** `gating_failed`
   311	- **Routing:** `operator_chat_id`
   312	- **Payload fields:** `endpoint`, `entity_type`, `entity_id`, `status_code`, `error_body_preview` (truncated 120 chars)
   313	
   314	#### `ESC_ACCOUNTING_WRITE_FAIL`
   315	- **Severity:** warn
   316	- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
   317	- **Phase:** `gating_failed`
   318	- **Routing:** `operator_chat_id`
   319	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   320	
   321	#### `ESC_PROVIDER_FETCH_FAIL`
   322	- **Severity:** warn
   323	- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
   324	- **Phase:** `gating_failed`
   325	- **Routing:** `operator_chat_id`
   326	- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`
   327	
   328	#### `ESC_SEND_FAIL`
   329	- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer
   330	- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
   331	- **Phase:** `gating_failed`
   332	- **Routing:** `operator_chat_id`
   333	- **Payload fields:** `channel` (`gmail` | `outlook` | `twilio` | `telegram`), `recipient_id_hash`, `error_class`, `attempts_made`
   334	
   335	### 2.9 — Auto-send orchestration (4 codes)
   336	Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
   337	
   338	#### `ESC_AUTOSEND_ORANGE_PENDING`
   339	- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
   340	- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
   341	- **Phase:** `action`
   342	- **Routing:** `operator_chat_id` (gentle reminder; no oncall)
   343	- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
   344	
   345	#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
   346	- **Severity:** warn — orange action's approval window expired without response
   347	- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
   348	- **Phase:** `gating_failed`
   349	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
   350	- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
   351	- **Recovery:** action converts to manual reconciliation; operator handles offline
   352	
   353	#### `ESC_AUTOSEND_RACE`
   354	- **Severity:** warn — concurrency violation
   355	- **Trigger:** Two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict
   356	- **Phase:** `gating_failed`
   357	- **Routing:** `operator_chat_id`
   358	- **Payload fields:** `payload_hash`, `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`
   359	- **Recovery:** second attempt suppressed; first wins (idempotency by payload_hash)
   360	
   361	#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
   362	- **Severity:** info — quality sampling, not a failure
   363	- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
   364	- **Phase:** `action`
   365	- **Routing:** `operator_chat_id`; sampled action is queued in `spot_check_queue_path` (`/vault/{tenant_slug}/spot-checks/`)
   366	- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
   367	- **Note:** Operator review of sampled rows is asynchronous (typically end-of-day batch); no SLA timer.
   368	
   369	### 2.10 — Agent workflow (10 codes)
   370	Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
   371	
   372	#### `ESC_GATE_B_MISS`
   373	- **Severity:** warn — post-send quality signal; not a hard failure
   374	- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
   375	- **Phase:** `gating_failed`
   376	- **Routing:** `operator_chat_id`
   377	- **Payload fields:** `agent_name`, `metric_name`, `actual_value`, `threshold`, `window`, `sample_size`
   378	- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
   379	
   380	#### `ESC_TONE_RULE_VIOLATION`
   381	- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
   382	- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
   383	- **Phase:** `gating_failed`
   384	- **Routing:** `operator_chat_id`
   385	- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
   386	- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
   387	
   388	#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
   389	- **Severity:** warn
   390	- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
   391	- **Phase:** `gating_failed`
   392	- **Routing:** `operator_chat_id`
   393	- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
   394	
   395	#### `ESC_CANDIDATE_DATA_INCOMPLETE`
   396	- **Severity:** warn
   397	- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
   398	- **Phase:** `gating_failed`
   399	- **Routing:** `operator_chat_id`
   400	- **Payload fields:** `candidate_id`, `missing_fields` (list), `shortlist_id`, `brief_id`
   401	
   402	#### `ESC_ADDRESSEE_MISMATCH`
   403	- **Severity:** **blocking** — Cash Conductor refuses to send reminder/invoice
   404	- **Trigger:** Outbound reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure)
   405	- **Phase:** `gating_failed`
   406	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   407	- **Payload fields:** `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`)
   408	- **Recovery:** founder reviews; either reconciles manually OR updates one system to match
   409	
   410	#### `ESC_RECONCILIATION_AMBIGUOUS`
   411	- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
   412	- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
   413	- **Phase:** `gating_failed`
   414	- **Routing:** `operator_chat_id`
   415	- **Payload fields:** `payment_id`, `amount`, `payee_name_raw`, `candidate_invoice_ids` (list), `match_basis` (e.g. `amount_only`, `payee_partial`)
   416	
   417	#### `ESC_DNC_FILTER_HIT`
   418	- **Severity:** **blocking** — outbound (email / SMS / call) refused
   419	- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
   420	- **Phase:** `gating_failed`
   421	- **Routing:** `operator_chat_id`
   422	- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
   423	
   424	#### `ESC_CONCIERGE_SLA_MISS`
   425	- **Severity:** warn
   426	- **Trigger:** Concierge SLA breached (default: inbound brief acknowledged within 4h; customer reply within 24h)
   427	- **Phase:** `gating_failed`
   428	- **Routing:** `operator_chat_id`
   429	- **Payload fields:** `brief_id`, `sla_type` (`brief_ack` | `customer_reply`), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   430	

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,610p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   560	```
   561	
   562	**The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly.** The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The `cortextos-ifos add-agent` command is **NOT** the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want.
   563	
   564	### 8.1 The three v2 changes (Ultraplan §4.2)
   565	
   566	**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
   567	
   568	**Change 2 — Decision logging is enforced.** Three required calls per agent run:
   569	
   570	```bash
   571	hh_decision_trigger   # at start; logs trigger
   572	hh_decision_output    # on output; logs the artefact
   573	hh_decision_action    # when human acts; logs the action
   574	```
   575	
   576	`validate.sh` hard-fails on missing calls. This is what enables the v2.0 LoRA pipeline — no decision log, no SFT corpus, no Scale-tier moat.
   577	
   578	**Change 3 — Escalation codes expand to recruitment vocabulary.** ~20–30 codes. Examples:
   579	
   580	- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
   581	- `ESC_BULLHORN_AUTH` — OAuth token expired/revoked
   582	- `ESC_DUPLICATE_DETECTED` — high-confidence dedup needs human review
   583	- `ESC_JSL_RED_FLAG` — Supply Chain Auditor detected red flag
   584	- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
   585	- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
   586	- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
   587	- `ESC_SCHEMA_VIOLATION` — agent produced output violating vertical schema
   588	
   589	Build the catalogue in Week 0. New codes only when production demands one.
   590	
   591	### 8.2 The build order — v1.0 only
   592	
   593	| # | Agent | Weeks | Key dependency | Why this order |
   594	|---|---|---|---|---|
   595	| 1 | Diagnostic | 3–4 | LinkedIn + Companies House + scrape | Sales tool — needed before any other agent matters |
   596	| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
   597	| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
   598	| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
   599	| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
   600	| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
   601	
   602	After Concierge ships, week 14 milestone: first pilot converts to paid.
   603	
   604	**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
   605	
   606	### 8.3 The working pattern in Claude Code
   607	
   608	For any new agent:
   609	
   610	```bash

exec
/bin/zsh -lc 'rg -n "cash_conductor_transactions|cash_conductor_invoices|tenant_adapters|decision_log|recent_edit|voice_corpus|tone_rule" docs/verticals/recruitment packages/agents-runtime agents -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:24:`hook-helpers.sh` writes to `decision_log` via two paths:
agents/_shared/README.md:27:2. **Fallback mode (degraded / offline)** — `IFOS_DB_URL` unset OR `psql` unavailable OR `psql` exited non-zero. Helpers append JSON lines to `${IFOS_DECISION_LOG_FALLBACK:-/vault/<tenant>/decision-log.jsonl}`. The trail replays into Postgres when connectivity returns via the autosend-syncer worker (Week 5+).
agents/_shared/README.md:40:| `IFOS_DECISION_LOG_FALLBACK` | no | Override fallback JSONL path | `${IFOS_VAULT_ROOT}/<tenant>/decision-log.jsonl` |
agents/_shared/README.md:44:| `HH_POLICY_VERSION_SHA` | no | Git SHA stamped into `decision_log.payload.policy_version_sha` per §7 | `unknown` |
agents/_shared/README.md:56:`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:122:3. Founder verifies via `psql` that one new row landed in `decision_log` with `phase='trigger'` + `tenant_slug='migration-test'`.
agents/_shared/README.md:125:   SELECT count(*) FROM decision_log
agents/_shared/README.md:144:   - 4 new tables (`voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`)
agents/_shared/README.md:145:   - `voice_samples_embedded` HNSW index on `voice_corpus_chunks.embedding`
agents/_shared/README.md:147:   - 1 seed row in `voice_corpus` for `migration-test` with `version='v0.2-seed'`, `is_active=TRUE`
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:19:# Schema version stamps decision_log.payload.policy_version_sha at write time.
agents/_shared/autosend-policy.yaml:68:    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
agents/_shared/autosend-policy.yaml:74:    reason: "Internal run-complete status marker written to decision_log; no external comms; informational"
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:129:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
agents/_shared/autosend-policy.yaml:306:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:317:# Defaults applied when override fields are absent in tenant_adapters
agents/_shared/hook-helpers.sh:10:# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
agents/_shared/hook-helpers.sh:11:# Offline-mode writes:     JSON-line append to $IFOS_DECISION_LOG_FALLBACK
agents/_shared/hook-helpers.sh:19:# Side-effects: appends to decision_log table OR fallback JSONL; never reads
agents/_shared/hook-helpers.sh:37:  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
agents/_shared/hook-helpers.sh:38:    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/hook-helpers.sh:102:# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
agents/_shared/hook-helpers.sh:121:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
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
agents/_shared/tests/test-hook-helpers.sh:81:export IFOS_DECISION_LOG_FALLBACK="${TMP_ROOT}/decision-log.jsonl"
agents/_shared/tests/test-hook-helpers.sh:97:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:100:  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
agents/_shared/tests/test-hook-helpers.sh:108:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:111:  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
agents/_shared/tests/test-hook-helpers.sh:131:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:135:  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
agents/_shared/tests/test-hook-helpers.sh:144:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:148:  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
agents/_shared/tests/test-hook-helpers.sh:158:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:162:  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
agents/_shared/tests/test-hook-helpers.sh:172:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:181:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:185:  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
agents/_shared/tests/test-hook-helpers.sh:235:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:239:  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
agents/_shared/tests/test-hook-helpers.sh:272:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:276:  row="$(cat "${IFOS_DECISION_LOG_FALLBACK}")"
agents/_shared/tests/test-hook-helpers.sh:286:  # (a) the autosend_emit_decision_log audit row with payload.tier='red'
agents/_shared/tests/test-hook-helpers.sh:290:  : > "${IFOS_DECISION_LOG_FALLBACK}"
agents/_shared/tests/test-hook-helpers.sh:296:  red_audit_count=$(grep -c '"tier":"red"' "${IFOS_DECISION_LOG_FALLBACK}")
agents/_shared/tests/test-hook-helpers.sh:297:  gating_failed_count=$(grep -c '"phase":"gating_failed"' "${IFOS_DECISION_LOG_FALLBACK}")
agents/_shared/tests/test-hook-helpers.sh:298:  blocked_esc_count=$(grep -c '"escalation_code":"ESC_AUTOSEND_BLOCKED"' "${IFOS_DECISION_LOG_FALLBACK}")
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:18:phase             — one of {trigger, output, action, gating_failed, agent_handoff}; per decision_log CHECK constraint at Day-4 §6.3
agents/_shared/escalation-codes.md:115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
agents/_shared/escalation-codes.md:343:- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
agents/_shared/escalation-codes.md:350:- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:355:- **Trigger:** Two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict
agents/_shared/escalation-codes.md:366:- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:380:#### `ESC_TONE_RULE_VIOLATION`
agents/_shared/escalation-codes.md:381:- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
agents/_shared/escalation-codes.md:382:- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
agents/_shared/escalation-codes.md:385:- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
agents/_shared/escalation-codes.md:386:- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
agents/_shared/escalation-codes.md:419:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:462:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:252:      tone_rules_triggered:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:343:    target: tone_rule
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:352:    target: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:75:# Returns active tone_rule rows filtered to agent_name (or all rules if
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:86:           FROM tone_rule
agents/_shared/voice-loader.sh:92:           FROM tone_rule
agents/_shared/voice-loader.sh:98:    _vl_render_tone_rules_json "${rows}"
agents/_shared/voice-loader.sh:113:_vl_render_tone_rules_json() {
agents/_shared/voice-loader.sh:137:# Runs pgvector ANN against voice_corpus_chunks for the active voice_corpus
agents/_shared/voice-loader.sh:149:#     "voice_corpus_version": "v0.2-seed",
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
agents/_shared/voice-loader.sh:230:#                  "resolution": "...", "tone_rules_triggered": [...],
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/voice-loader.sh:245:      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
agents/_shared/voice-loader.sh:246:           FROM recent_edit
agents/_shared/voice-loader.sh:252:      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
agents/_shared/voice-loader.sh:253:           FROM recent_edit
agents/_shared/voice-loader.sh:260:    _vl_render_recent_edits_json "${rows}" "${lookback_days}"
agents/_shared/voice-loader.sh:268:_vl_render_recent_edits_json() {
agents/_shared/voice-loader.sh:279:  while IFS=$'\t' read -r id action_type edit_distance resolution tone_rules resolved_at; do
agents/_shared/voice-loader.sh:282:    printf '{"id":%s,"action_type":"%s","edit_distance":%s,"resolution":"%s","tone_rules_triggered":"%s","resolved_at":"%s"}' \
agents/_shared/voice-loader.sh:287:      "$(_hh_json_escape "${tone_rules}")" \
packages/agents-runtime/_shared/common-voice.json:8:    "voice_corpus_path": {
packages/agents-runtime/_shared/common-voice.json:16:      "description": "Tag matching docs/verticals/recruitment/vertical-schema.yaml voice_corpus.version row."
packages/agents-runtime/_shared/common-voice.json:35:    "recent_edits_lookback_days": {
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:42:    "tone_rules_severity_floor": {
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/agents-runtime/_shared/common-voice.json:49:  "required": ["voice_corpus_path", "voice_classifier_threshold"],
agents/recruitment/cash-conductor/agent.md:86:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:107:Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='xero_reminder_draft_internal'` (registered yellow tier — but Cash Conductor escalates to orange-tier `xero_reminder_send_customer` for the actual customer-facing send routed via Concierge; this row is the draft itself, not the send), payload includes the draft.
agents/recruitment/cash-conductor/agent.md:160:   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
agents/recruitment/cash-conductor/agent.md:169:   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
agents/recruitment/cash-conductor/agent.md:193:     sent (counted from decision_log decision_log.payload.position)
agents/recruitment/cash-conductor/agent.md:241:    → query decision_log + accounting + bank feed for the 7-day window
agents/recruitment/cash-conductor/agent.md:249:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:319:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:323:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:324:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
agents/_shared/tests/test-voice-loader.sh:70:printf '\n[1] hh_load_tone_rules returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:71:test_tone_rules_empty() {
agents/_shared/tests/test-voice-loader.sh:73:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:76:_test_run "tone_rules fallback (no DB, no file): empty rules" test_tone_rules_empty
agents/_shared/tests/test-voice-loader.sh:78:printf '\n[2] hh_load_tone_rules reads tone-rules.yaml fallback path\n'
agents/_shared/tests/test-voice-loader.sh:79:test_tone_rules_fallback() {
agents/_shared/tests/test-voice-loader.sh:86:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:89:_test_run "tone_rules fallback: fallback_path surfaced" test_tone_rules_fallback
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
agents/_shared/tests/test-voice-loader.sh:158:  out3=$(hh_load_recent_edits | wc -l | tr -d ' ')
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:110:-- §4 — Create tone_rule table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:113:CREATE TABLE IF NOT EXISTS tone_rule (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:126:  CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:129:CREATE INDEX IF NOT EXISTS tone_rule_tenant_enabled_idx ON tone_rule (tenant_slug, enabled);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:131:ALTER TABLE tone_rule ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:132:ALTER TABLE tone_rule FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:133:DROP POLICY IF EXISTS tone_rule_tenant_isolation ON tone_rule;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:153:  tone_rules_triggered   TEXT[]      NOT NULL DEFAULT '{}',
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:161:CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:162:CREATE INDEX IF NOT EXISTS recent_edit_lookback_idx ON recent_edit (tenant_slug, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:164:ALTER TABLE recent_edit ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:165:ALTER TABLE recent_edit FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:166:DROP POLICY IF EXISTS recent_edit_tenant_isolation ON recent_edit;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:167:CREATE POLICY recent_edit_tenant_isolation ON recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:174:-- Voice corpus + tone_rule are mutable (re-index + rule revisions).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:177:GRANT SELECT, INSERT, UPDATE        ON voice_corpus        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:178:GRANT SELECT, INSERT, UPDATE, DELETE ON voice_corpus_chunks TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:179:GRANT SELECT, INSERT, UPDATE, DELETE ON tone_rule           TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:182:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_id_seq        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:183:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_chunks_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:184:GRANT USAGE, SELECT ON SEQUENCE tone_rule_id_seq           TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:199:--   ALTER TABLE voice_corpus OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:200:--   ALTER TABLE voice_corpus_chunks OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:201:--   ALTER TABLE tone_rule OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:203:--   ALTER SEQUENCE voice_corpus_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:204:--   ALTER SEQUENCE voice_corpus_chunks_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:205:--   ALTER SEQUENCE tone_rule_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:280:-- §9 — Reference rows: seed migration-test tenant with a starter voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:282:-- Inserts a single empty active voice_corpus row for migration-test only.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:289:INSERT INTO voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:313:-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:315:-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:316:--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:317:--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:27:DROP TABLE IF EXISTS tone_rule            CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:28:DROP TABLE IF EXISTS voice_corpus_chunks  CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:29:DROP TABLE IF EXISTS voice_corpus         CASCADE;
agents/recruitment/concierge/README.md:24:- `cleanup.sh` — token rotation + 14-day decision_log retention check
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
agents/recruitment/diagnostic/validate.sh:13:# decision_log; the report does NOT land in the vault.
agents/recruitment/diagnostic/validate.sh:20:#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
agents/recruitment/diagnostic/validate.sh:21:#          CTX_TONE_RULES (json string)
agents/recruitment/diagnostic/validate.sh:33:#   V5 — No banned phrases per tone_rule table
agents/recruitment/diagnostic/validate.sh:171:# V5 — Banned phrases per tone_rule
agents/recruitment/diagnostic/validate.sh:174:if [[ -n "${CTX_TONE_RULES:-}" ]]; then
agents/recruitment/diagnostic/validate.sh:175:  BANNED_HITS=$(printf '%s' "${CTX_TONE_RULES}" | python3 -c "
agents/recruitment/diagnostic/validate.sh:196:  _warn "V5: CTX_TONE_RULES empty; banned-phrase check skipped"
agents/recruitment/diagnostic/validate.sh:233:  # Emit ESC_SCHEMA_VIOLATION row to decision_log with the failure list
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:78:  decision_log_rows_min: 4  # trigger + output + validate_gate_a_fail action + cleanup
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run)
agents/recruitment/janitor/agent.md:135:   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
agents/recruitment/janitor/agent.md:136:     §1.3): SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
agents/recruitment/janitor/agent.md:138:   → join to decision_log only if action-context lookups needed
agents/recruitment/janitor/agent.md:151:   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
agents/recruitment/janitor/agent.md:166:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:230:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:234:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:132:     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
agents/recruitment/scribe/agent.md:234:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:276:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:324:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
agents/recruitment/diagnostic/tools.yaml:123:      voice-loader.sh for tenant corpus + tone rules + recent_edits.
agents/recruitment/diagnostic/tools.yaml:128:      - voice.tone_rule_check  # text + tone_rule_set → list of violations
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
agents/recruitment/diagnostic/cycle.sh:20:#   - Audit rows to decision_log (trigger + output + action)
agents/recruitment/diagnostic/fixtures/01-primary.yaml:97:expected_decision_log_rows:
agents/recruitment/diagnostic/context.sh:21:#       CTX_VOICE_CORPUS_ID   active corpus id from voice_corpus table
agents/recruitment/diagnostic/context.sh:22:#       CTX_TONE_RULES        JSON array of applicable rules
agents/recruitment/diagnostic/context.sh:23:#       CTX_RECENT_EDITS_REF  count of recent_edit rows (drift signal)
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:130:CTX_VOICE_CORPUS_ID=$(printf '%s' "${VOICE_CORPUS_JSON}" | python3 -c "
agents/recruitment/diagnostic/context.sh:135:export CTX_VOICE_CORPUS_ID
agents/recruitment/diagnostic/context.sh:137:if [[ -z "${CTX_VOICE_CORPUS_ID}" && "${CTX_TENANT_SLUG}" != "migration-test" ]]; then
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:148:export CTX_TONE_RULES
agents/recruitment/diagnostic/context.sh:150:TONE_RULE_COUNT=$(printf '%s' "${CTX_TONE_RULES}" | python3 -c "
agents/recruitment/diagnostic/context.sh:157:# 5 — Load recent_edits (voice drift signal)
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:161:export CTX_RECENT_EDITS_REF
agents/recruitment/diagnostic/context.sh:163:EDIT_COUNT=$(printf '%s' "${CTX_RECENT_EDITS_REF}" | python3 -c "
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
agents/recruitment/diagnostic/context.sh:174:  "${CTX_TENANT_SLUG}" "${CTX_VOICE_CORPUS_ID:-<empty>}" "${TONE_RULE_COUNT}" "${EDIT_COUNT}"
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:95:expected_decision_log_rows:
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:122:     voice corpus + tone rules + recent_edits + tenant comms-template
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:138:   → query decision_log for prior `concierge_email_draft` row for same
agents/recruitment/concierge/agent.md:198:   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
agents/recruitment/concierge/agent.md:268:- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
agents/recruitment/concierge/agent.md:275:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:285:- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`.
agents/recruitment/concierge/agent.md:305:| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:329:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:336:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:369:| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:396:| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
agents/recruitment/diagnostic/agent.md:130:                 constraint = tone rules (hh_load_tone_rules)
agents/recruitment/diagnostic/agent.md:158:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
agents/recruitment/diagnostic/agent.md:164:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:169:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:200:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:204:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
agents/recruitment/diagnostic/agent.md:205:- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.
agents/recruitment/sourcing-scout/agent.md:96:Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.
agents/recruitment/sourcing-scout/agent.md:276:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:281:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:282:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '529,542p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-005-week-3-diagnostic-acceleration.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# ADR-005 — Week-3 Diagnostic acceleration (Bullhorn MCP deferred)
     2	
     3	**Status:** Accepted (2026-05-24, Day 13)
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Companion:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
     6	**Supersedes:** N/A
     7	**Ratifies via:** `review-architecture-decision.md` Codex skill (next round)
     8	
     9	---
    10	
    11	## Context
    12	
    13	ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:
    14	
    15	| Week | Master plan calls for |
    16	|---|---|
    17	| 1-2 | Renderer + `_shared/` + voice corpus + schema v0.2 |
    18	| 3 | **Bullhorn MCP server build** (auth, read endpoints, write endpoints, webhook subscription) per ULTRAPLAN line 752 |
    19	| 4 | **Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint** per ULTRAPLAN line 753 |
    20	| 5 | Janitor (Bullhorn R+W) |
    21	| 6 | Scribe |
    22	| 7-8 | Cash Conductor |
    23	| 9 | Sourcing Scout |
    24	| 10-13 | Concierge |
    25	
    26	As of Day 13 (end of Week 2):
    27	
    28	- **Week 1-2 work landed early** (Day 8, commits a279226 → fe56e93). Renderer + `_shared/` + v0.2 schema + voice corpus all live + ratified.
    29	- **Bullhorn Sub-decisions A + B remain Proposed.** Founder submitted Bullhorn partnerships form 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (commit `dc15692`); response expected 2-5 business days.
    30	- **Without Sub-decision A answered, Week-3 Bullhorn-MCP work is structurally blocked:** we don't know whether marketplace registration is required for production OR whether direct-tier developer-program access suffices.
    31	- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
    32	
    33	## Decision
    34	
    35	**Week 3 (Days 13-20) is repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) is repurposed from Diagnostic-build to Diagnostic-polish + first-pilot-prep + (conditional) Bullhorn-MCP-build if A+B answered.**
    36	
    37	Concretely:
    38	
    39	| Original plan | Day-13 revision |
    40	|---|---|
    41	| W3 Days 13-20: Bullhorn MCP server build | W3 Days 13-20: Diagnostic end-to-end (per `goal-option-c-diagnostic-end-to-end.md`) |
    42	| W4 Days 21-27: Diagnostic end-to-end | W4 Days 21-27: Diagnostic polish + first-pilot prep + Bullhorn MCP if A+B answered |
    43	| W5 Day 28+: Janitor build start | W5 Day 28+: **Conditional on Bullhorn Sub-decisions A+B Accepted** |
    44	
    45	## Rationale
    46	
    47	1. **Diagnostic is the named first agent.** `sequencing-target.md` §3.1 ratified Build Wave 1 = Diagnostic. Doing it earlier doesn't violate the sequence — it accelerates it.
    48	2. **The Week-4 milestone is achievable today.** ULTRAPLAN line 755: *"Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."* Option C produces exactly this; the dependencies (LinkedIn + Companies House + scrape) are independent of Bullhorn.
    49	3. **Week-3 time is otherwise idle.** Bullhorn MCP build cannot proceed without commercial answer. Spending Week 3 on Diagnostic uses that time productively.
    50	4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
    51	5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
    52	6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
    53	
    54	## Consequences
    55	
    56	### Immediate (Days 13-20)
    57	
    58	- ✅ Web scraper + Companies House MCP connector + diagnostic-generator package shipped Day 13 (commits `800a265`, `860f29c`, `5614dcb`, `fd38254`)
    59	- ✅ Real end-to-end pipeline verified Day 13 (Gate A PASS on fake-firm smoke test)
    60	- ⏸ Step 7 (real-firm smoke run against founder's choice) pending: Companies House API key registration + firm name
    61	- ⏸ Iteration on Diagnostic output quality across 10-20 real UK firms
    62	
    63	### Week 5 (Day 28+) — Janitor build conditional gating
    64	
    65	| Bullhorn A+B state by Day 28 | Janitor action |
    66	|---|---|
    67	| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
    68	| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
    69	| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |
    70	
    71	### Downstream sequencing (Weeks 6+)
    72	
    73	- Scribe (W6) depends on Bullhorn write; same gating as Janitor
    74	- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
    75	- Sourcing Scout (W9) touches Bullhorn read; same gating
    76	- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
    77	
    78	**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
    79	
    80	### What does NOT change
    81	
    82	- Master brief five rules + four boundaries (no architectural deviation)
    83	- Schema v0.2 + tenancy invariants (verified Day 12; foundation stable)
    84	- Codex ratification loop (continues per existing manifest)
    85	- Q1 LOI gate (Jack's lane; Trigger 1 fires 2026-06-03 if no LOI)
    86	- Founder commercial workstream (Bullhorn + SeedLegals + Q1)
    87	
    88	## Implementation receipts
    89	
    90	| Step | Status | Commit |
    91	|---|---|---|
    92	| Scaffold web-scraper + companies-house packages | ✅ | `800a265` |
    93	| Web-scraper implementation + 12/12 tests | ✅ | `860f29c` |
    94	| Companies House connector + 13/13 tests | ✅ | `5614dcb` |
    95	| diagnostic-generator package + cycle.sh wiring | ✅ | `fd38254` |
    96	| ADR-005 (this document) | ✅ | (this commit) |
    97	| State files sync | ✅ | (this commit / next) |
    98	| Companies House API key registration | ⏸ Founder | — |
    99	| Smoke run against real UK firm | ⏸ Step 7 | — |
   100	| Codex ratification of bundle | ⏸ W4 | — |
   101	
   102	## Master plan citation chain
   103	
   104	- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
   105	- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
   106	- ULTRAPLAN §8.1 line 753-755 (Week-4 milestone definition)
   107	- ULTRAPLAN §10 Risk #2 row contingency (defer Bullhorn-touching agents)
   108	- `sequencing-target.md` §3.1 (Build Wave 1 = Diagnostic)
   109	- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
   110	- `bullhorn-integration-path.md` §1.4 (Direct-API fallback architecture for slow Bullhorn response)
   111	- `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
   112	
   113	## Open questions
   114	
   115	| Q | Resolution path |
   116	|---|---|
   117	| When does Bullhorn respond? | 2-5 business days from submission (sent 2026-05-24); hard cutoff 2026-06-10 per §1.4 fallback |
   118	| Does the Diagnostic v0 produce reports good enough to send Jack for Q1 pitch? | Iteration loop in W3 polish (Step 7 + follow-ups). Quality gate: founder approval after running against 5-10 real firms. |
   119	| LinkedIn deep data via Proxycurl: now or W4? | Day-13 founder pick: Option A (free unauthenticated path) for v0; Proxycurl evaluated W4 polish |
   120	| Does this break the master plan's "do not build out of order" rule? | No: ordering of agents (Diagnostic first) is preserved; only the substrate-vs-agent ordering within Weeks 3-4 is swapped, which §1.4 fallback architecture explicitly anticipates |
   121	
   122	*End of ADR-005.*

exec
/bin/zsh -lc "nl -ba packages/agents-runtime/_shared/common-accounting.json | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	{
     2	  "$schema": "https://json-schema.org/draft/2020-12/schema",
     3	  "$id": "https://intelforce.os/schemas/common-accounting.json",
     4	  "title": "common-accounting",
     5	  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
     6	  "type": "object",
     7	  "properties": {
     8	    "accounting_choice": {
     9	      "type": "string",
    10	      "enum": ["xero", "none"],
    11	      "default": "none",
    12	      "description": "None = Cash Conductor not deployed for this tenant. Xero = deployed."
    13	    },
    14	    "xero_tenant_id": {
    15	      "type": "string",
    16	      "description": "Xero tenant ID; one per IFOS-tenant. Loaded from _secrets.env."
    17	    },
    18	    "xero_oauth_path": {
    19	      "type": "string",
    20	      "default": "/vault/{tenant_slug}/_secrets.env",
    21	      "description": "Where XERO_OAUTH_REFRESH_TOKEN lives."
    22	    },
    23	    "chase_cadence": {
    24	      "type": "object",
    25	      "properties": {
    26	        "days_overdue_first_chase": { "type": "integer", "minimum": 1, "default": 3 },
    27	        "days_overdue_second_chase": { "type": "integer", "minimum": 1, "default": 14 },
    28	        "days_overdue_escalate": { "type": "integer", "minimum": 1, "default": 30 }
    29	      },
    30	      "description": "Default Cash Conductor cadence; tenant-overridable per autosend-safety-policy §6 tenant-override discipline."
    31	    },
    32	    "escalation_threshold_gbp": {
    33	      "type": "number",
    34	      "minimum": 0,
    35	      "default": 5000,
    36	      "description": "Outstanding amount above which Cash Conductor escalates to operator via ESC route rather than auto-chasing."
    37	    },
    38	    "open_banking_provider": {
    39	      "type": "string",
    40	      "enum": ["truelayer", "tink", "none"],
    41	      "default": "none",
    42	      "description": "v1.0 closes loop via Open Banking reconciliation per Ultraplan §8.1 A4; truelayer placeholder."
    43	    }
    44	  },
    45	  "required": ["accounting_choice"],
    46	  "additionalProperties": false
    47	}

exec
/bin/zsh -lc 'rg -n "cash_conductor|invoice|payment|accounting|bank|DSO|tenant_adapters" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml packages/agents-runtime/_shared/common-accounting.json -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/agents-runtime/_shared/common-accounting.json:3:  "$id": "https://intelforce.os/schemas/common-accounting.json",
packages/agents-runtime/_shared/common-accounting.json:4:  "title": "common-accounting",
packages/agents-runtime/_shared/common-accounting.json:8:    "accounting_choice": {
packages/agents-runtime/_shared/common-accounting.json:38:    "open_banking_provider": {
packages/agents-runtime/_shared/common-accounting.json:45:  "required": ["accounting_choice"],
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:129:      - Cash Conductor (R — payment reminder tone)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '163,255p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   163	# 3 hh_decision_* contracts (master brief §8.1 Change 2)
   164	# ────────────────────────────────────────────────────────────────────────
   165	
   166	# hh_decision_trigger <trigger_type> [<reason>]
   167	# Writes phase='trigger' row at session start. Required first call of every run.
   168	hh_decision_trigger() {
   169	  local trigger_type="${1:-session_start}"
   170	  local reason="${2:-}"
   171	  local payload
   172	  payload=$(printf '{"trigger_type":"%s","helpers_version":"%s"}' \
   173	    "$(_hh_json_escape "${trigger_type}")" "${_HH_HELPERS_VERSION}")
   174	  _hh_emit_row "trigger" "" "${reason}" "${payload}"
   175	}
   176	
   177	# hh_decision_output <output_type> <artefact_ref> [<reason>]
   178	# Writes phase='output' row per artefact produced. Required before producing
   179	# a customer-visible artefact (Gate B per master brief §1 Rule 4).
   180	hh_decision_output() {
   181	  local output_type="$1"
   182	  local artefact_ref="$2"
   183	  local reason="${3:-}"
   184	  local payload
   185	  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
   186	    "$(_hh_json_escape "${output_type}")" "$(_hh_json_escape "${artefact_ref}")")
   187	  _hh_emit_row "output" "produced" "${reason}" "${payload}"
   188	}
   189	
   190	# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
   191	# Writes phase='action' or phase='gating_failed' row depending on tier.
   192	# Returns 0 if action allowed; 1 if blocked or approval rejected.
   193	hh_decision_action() {
   194	  local action_type="$1"
   195	  local target="$2"
   196	  local payload_hash="$3"
   197	  local payload_preview="$4"
   198	
   199	  local tenant tier
   200	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   201	
   202	  if ! tier=$(autosend_policy_lookup "${action_type}"); then
   203	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   204	      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
   205	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   206	      "${target}" "${payload_hash}" "unknown_action_type"
   207	    return 1
   208	  fi
   209	
   210	  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
   211	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   212	      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
   213	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   214	      "${target}" "${payload_hash}" "override_resolution_failed"
   215	    return 1
   216	  fi
   217	
   218	  case "${tier}" in
   219	    green)
   220	      autosend_emit_decision_log "action" "green" "${action_type}" \
   221	        "${target}" "${payload_hash}" "${payload_preview}" ""
   222	      return 0
   223	      ;;
   224	    yellow)
   225	      autosend_emit_decision_log "action" "yellow" "${action_type}" \
   226	        "${target}" "${payload_hash}" "${payload_preview}" ""
   227	      if autosend_should_sample "${action_type}" "${tenant}"; then
   228	        autosend_spot_check_enqueue "${action_type}" "${target}" \
   229	          "${payload_hash}" "${payload_preview}" "${tenant}"
   230	      fi
   231	      return 0
   232	      ;;
   233	    orange)
   234	      autosend_emit_decision_log "action" "orange" "${action_type}" \
   235	        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
   236	      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
   237	        "${target}" "${payload_hash}" "${payload_preview}"
   238	      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
   239	      return $?
   240	      ;;
   241	    red)
   242	      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
   243	        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
   244	      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
   245	        "${target}" "${payload_hash}" "red_tier_classification"
   246	      return 1
   247	      ;;
   248	    *)
   249	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   250	        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
   251	      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   252	        "${target}" "${payload_hash}" "unknown_tier:${tier}"
   253	      return 1
   254	      ;;
   255	  esac

codex
REJECTED

1. Autosend tier claims conflict with the policy. Line 17 says `xero_reminder_draft_internal` is orange-tier and cites `autosend-safety-policy.yaml` line 104, but the live policy is `agents/_shared/autosend-policy.yaml`, where `xero_reminder_draft_internal` is yellow at lines 146-151; the orange action is `xero_reminder_send_customer` at lines 221-226. Fix §1 to distinguish yellow draft creation from orange customer send and cite the actual policy file/lines.

2. The artefact assumes unschematized Cash Conductor state. Lines 160-170 introduce Postgres tables `cash_conductor_transactions` and `cash_conductor_invoices`, and line 249 writes `tenant_adapters.config.cash_conductor_last_run`; these are not defined in `vertical-schema.yaml` or the v0.2 supplement. Fix by adding the schema/migration first, or express this as a W7 schema prerequisite rather than a current workflow contract.

3. Escalation codes are repurposed beyond the catalogue. Line 296 defines `ESC_OPEN_BANKING_TOKEN_AGING` as `<30 days` with staged warn/blocking behavior, but the catalogue lines 296-302 define `≤14 days`, severity `info`, emitted by nightly health check. Lines 236 and 298 use `ESC_AUTOSEND_RACE` for “payment received between draft and send,” but catalogue lines 353-359 define it as duplicate same-`payload_hash` sends by two agents within 60s. Fix these triggers to match the catalogue or add new catalogue codes before referencing them.

4. Decision logging is missing on workflow steps that take action or mutate state. §4 line 137 states every output/action step must call `hh_decision_*`, but Step 1 refreshes auth/fires ESC codes with no decision call, Step 7 can STOP/escalate without a decision call, Step 8 produces the draft body/subject with no output row, and Step 11 updates internal chase state with no decision call. Fix §4 so each action/output/mutation has an explicit `hh_decision_output` or `hh_decision_action` row.

5. Master-brief citation for the DSO closer metric is inaccurate. Line 283 says the 12-day Gate B target is “THE FD-tier closer metric per master brief §8.2 line 597,” but master brief line 598 says Cash Conductor’s pitch is “DSO drops by 15 days”; line 597 is Scribe. Fix by citing ULTRAPLAN line 539 for the 12-day Gate B metric and explicitly flagging drift from the master brief’s 15-day pitch.
tokens used
72,819
REJECTED

1. Autosend tier claims conflict with the policy. Line 17 says `xero_reminder_draft_internal` is orange-tier and cites `autosend-safety-policy.yaml` line 104, but the live policy is `agents/_shared/autosend-policy.yaml`, where `xero_reminder_draft_internal` is yellow at lines 146-151; the orange action is `xero_reminder_send_customer` at lines 221-226. Fix §1 to distinguish yellow draft creation from orange customer send and cite the actual policy file/lines.

2. The artefact assumes unschematized Cash Conductor state. Lines 160-170 introduce Postgres tables `cash_conductor_transactions` and `cash_conductor_invoices`, and line 249 writes `tenant_adapters.config.cash_conductor_last_run`; these are not defined in `vertical-schema.yaml` or the v0.2 supplement. Fix by adding the schema/migration first, or express this as a W7 schema prerequisite rather than a current workflow contract.

3. Escalation codes are repurposed beyond the catalogue. Line 296 defines `ESC_OPEN_BANKING_TOKEN_AGING` as `<30 days` with staged warn/blocking behavior, but the catalogue lines 296-302 define `≤14 days`, severity `info`, emitted by nightly health check. Lines 236 and 298 use `ESC_AUTOSEND_RACE` for “payment received between draft and send,” but catalogue lines 353-359 define it as duplicate same-`payload_hash` sends by two agents within 60s. Fix these triggers to match the catalogue or add new catalogue codes before referencing them.

4. Decision logging is missing on workflow steps that take action or mutate state. §4 line 137 states every output/action step must call `hh_decision_*`, but Step 1 refreshes auth/fires ESC codes with no decision call, Step 7 can STOP/escalate without a decision call, Step 8 produces the draft body/subject with no output row, and Step 11 updates internal chase state with no decision call. Fix §4 so each action/output/mutation has an explicit `hh_decision_output` or `hh_decision_action` row.

5. Master-brief citation for the DSO closer metric is inaccurate. Line 283 says the 12-day Gate B target is “THE FD-tier closer metric per master brief §8.2 line 597,” but master brief line 598 says Cash Conductor’s pitch is “DSO drops by 15 days”; line 597 is Scribe. Fix by citing ULTRAPLAN line 539 for the 12-day Gate B metric and explicitly flagging drift from the master brief’s 15-day pitch.
